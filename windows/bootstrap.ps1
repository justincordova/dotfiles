#Requires -Version 7.0
<#
.SYNOPSIS
  Provision a Windows dev machine to match the macOS setup.

.DESCRIPTION
  Idempotent - safe to re-run. Each phase can be run in isolation with -Only.

  Default run: packages node link tools db docker langs agents nvim ssh
  Opt-in:      opencode   (installs OpenCode 2 from npm; see README)

  ssh needs an elevated shell; without one it is skipped with a note.

.EXAMPLE
  .\bootstrap.ps1                      # everything except opencode
  .\bootstrap.ps1 -Only packages       # just winget
  .\bootstrap.ps1 -Only opencode       # install / check OpenCode 2
  .\bootstrap.ps1 -Only link,agents    # symlinks + agent config
  .\bootstrap.ps1 -WhatIf              # dry run
#>
[CmdletBinding(SupportsShouldProcess)]
param(
  [ValidateSet('packages', 'node', 'opencode', 'link', 'tools', 'db', 'docker',
               'langs', 'agents', 'nvim', 'ssh')]
  [string[]]$Only,

  # winget IDs to leave alone, e.g. -Skip Docker.DockerDesktop
  [string[]]$Skip,

  [string]$DotfilesRepo = 'git@github.com:justincordova/dotfiles.git',
  [string]$AgentRepo    = 'git@github.com:justincordova/agents.git'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$DotfilesDir = Join-Path $HOME 'dotfiles'
$AgentDir    = Join-Path $HOME 'agent'
$LocalBin    = Join-Path $HOME '.local\bin'
$Failed      = [System.Collections.Generic.List[string]]::new()
$Notes       = [System.Collections.Generic.List[string]]::new()

# x64 or arm64 - GitHub release assets are named after one of these.
$IsArm = $env:PROCESSOR_ARCHITECTURE -eq 'ARM64'

$OptIn = @('opencode')
function Phase {
  param([string]$Name)
  if ($script:Only) { return $script:Only -contains $Name }
  return $script:OptIn -notcontains $Name
}
function Info  { param($m) Write-Host "  $m" -ForegroundColor DarkGray }
function Good  { param($m) Write-Host "  $m" -ForegroundColor Green }
function Warn  { param($m) Write-Host "  $m" -ForegroundColor Yellow }
function Head  { param($m) Write-Host "`n$m" -ForegroundColor Cyan }
function Have  { param($c) [bool](Get-Command $c -ErrorAction SilentlyContinue) }

# winget changes the machine/user PATH, but this session keeps its old copy.
function Update-SessionPath {
  $machine = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
  $user    = [Environment]::GetEnvironmentVariable('PATH', 'User')
  $env:PATH = (@($LocalBin) + ("$machine;$user" -split ';') |
    Where-Object { $_ } | Select-Object -Unique) -join ';'
}

# ---------------------------------------------------------------- preflight --

Head 'Preflight'

if (-not (Have winget)) {
  throw 'winget not found. Install "App Installer" from the Microsoft Store, then re-run.'
}
Good "winget $(winget --version)"
Info ('arch: {0}' -f $(if ($IsArm) { 'arm64' } else { 'x64' }))

# Symlinks need either Developer Mode or an elevated shell.
# The AppModelUnlock key only exists once Developer Mode has been toggled at
# least once, and Set-StrictMode turns a missing property into a hard error --
# so probe for the property before reading it.
function Get-DevModeFlag {
  $key = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -ErrorAction SilentlyContinue
  if (-not $key) { return 0 }
  if ($key.PSObject.Properties.Name -notcontains 'AllowDevelopmentWithoutDevLicense') { return 0 }
  return [int]$key.AllowDevelopmentWithoutDevLicense
}
$devMode = Get-DevModeFlag
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
  ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($devMode -ne 1 -and -not $isAdmin) {
  Warn 'Developer Mode is OFF and this shell is not elevated.'
  Warn 'Symlink creation will fail. Enable it:'
  Warn '  Settings > System > For developers > Developer Mode = On'
  Warn 'Then re-run. (Or run this script as Administrator.)'
  if ((Phase 'link') -or (Phase 'agents')) { throw 'Cannot create symlinks.' }
} else {
  Good ('symlinks available ({0})' -f $(if ($devMode -eq 1) { 'Developer Mode' } else { 'elevated' }))
}

New-Item -ItemType Directory -Force -Path $LocalBin | Out-Null
Update-SessionPath

# ------------------------------------------------------------------ helpers --

# Install one winget package unless it is already present. Output is streamed:
# capturing it makes a slow installer indistinguishable from a hang and hides
# any prompt it is blocked on.
function Install-Winget {
  [CmdletBinding(SupportsShouldProcess)]
  param([string]$Id, [string]$Override)

  if ($script:Skip -and $script:Skip -contains $Id) { Warn "$Id (skipped by -Skip)"; return }

  # Installed some other way (Microsoft Store, scoop, an installer) - winget
  # doesn't match those by ID, and a second copy would shadow the first.
  $cmd = $script:WingetCommands[$Id]
  if ($cmd -and (Have $cmd)) { Info "$Id (already installed: $cmd)"; return }

  # Per-ID lookup: the table from a bare `winget list` truncates long IDs.
  winget list --id $Id --exact --disable-interactivity --accept-source-agreements *> $null
  if ($LASTEXITCODE -eq 0) { Info "$Id (already installed)"; return }
  if (-not $PSCmdlet.ShouldProcess($Id, 'winget install')) { return }

  Write-Host "  installing $Id ..." -ForegroundColor DarkGray
  $wingetArgs = @('install', '--id', $Id, '--exact', '--silent',
    '--accept-package-agreements', '--accept-source-agreements', '--disable-interactivity')
  if ($Override) { $wingetArgs += @('--override', $Override) }
  winget @wingetArgs

  switch ($LASTEXITCODE) {
    0            { Good "$Id ok" }
    -1978335189  { Info "$Id (already current)" }   # 0x8A15002B no applicable upgrade
    -1978335135  { Info "$Id (already installed)" } # 0x8A150061 already installed
    default {
      Write-Host "  $Id FAILED (exit $LASTEXITCODE)" -ForegroundColor Red
      $script:Failed.Add("winget: $Id")
    }
  }
}

# Download the newest release asset whose name matches $Pattern and copy $Exe
# out of it into ~/.local/bin. Handles .zip and .tar.gz (Windows ships tar.exe).
function Install-GitHubRelease {
  [CmdletBinding(SupportsShouldProcess)]
  param([string]$Repo, [string]$Pattern, [string]$Exe)

  if (Have ($Exe -replace '\.exe$', '')) { Info "$Exe (already installed)"; return }
  if (-not $PSCmdlet.ShouldProcess($Repo, "download $Exe")) { return }
  try {
    $rel   = Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest"
    $asset = $rel.assets | Where-Object name -Match $Pattern | Select-Object -First 1
    if (-not $asset) { throw "no asset matching $Pattern in $($rel.tag_name)" }

    $tmp = Join-Path $env:TEMP ([IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Path $tmp | Out-Null
    $file = Join-Path $tmp $asset.name
    Invoke-WebRequest $asset.browser_download_url -OutFile $file
    if ($asset.name -like '*.zip') {
      Expand-Archive $file -DestinationPath $tmp -Force
    } else {
      tar -xzf $file -C $tmp
    }
    $found = Get-ChildItem $tmp -Recurse -Filter $Exe | Select-Object -First 1
    if (-not $found) { throw "$Exe not inside $($asset.name)" }
    Copy-Item $found.FullName (Join-Path $script:LocalBin $Exe) -Force
    Remove-Item $tmp -Recurse -Force
    Good "$Exe $($rel.tag_name) -> $script:LocalBin"
  } catch {
    Warn "$Exe install failed: $($_.Exception.Message)"
    $script:Failed.Add($Exe)
  }
}

function Link {
  # Advanced function so -WhatIf propagates from the script scope rather than
  # relying on $PSCmdlet resolving through dynamic scope.
  [CmdletBinding(SupportsShouldProcess)]
  param([string]$Target, [string]$Link)

  if (-not (Test-Path -LiteralPath $Target)) { Warn "missing target: $Target"; return }
  if (-not $PSCmdlet.ShouldProcess($Link, "link -> $Target")) { return }

  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Link) | Out-Null

  $existing = Get-Item -LiteralPath $Link -Force -ErrorAction SilentlyContinue
  if ($existing) {
    if ($existing.LinkType -eq 'SymbolicLink') {
      Remove-Item -LiteralPath $Link -Force -Recurse:$false
    } else {
      $backup = "$Link.bak-$(Get-Date -Format yyyyMMddHHmmss)"
      Move-Item -LiteralPath $Link -Destination $backup
      Warn "backed up existing $Link -> $backup"
    }
  }

  New-Item -ItemType SymbolicLink -Path $Link -Target $Target | Out-Null
  Info "$Link -> $Target"
}

function Clone {
  [CmdletBinding(SupportsShouldProcess)]
  param([string]$Url, [string]$Dest)
  if (Test-Path (Join-Path $Dest '.git')) { Info "$Dest (already cloned)"; return }
  if (-not $PSCmdlet.ShouldProcess($Dest, "git clone $Url")) { return }
  git clone $Url $Dest
  if ($LASTEXITCODE -ne 0) { $script:Failed.Add("clone: $Url") }
}

# OpenCode 1 (npm `opencode-ai`) cannot load the v2 plugins this repo uses.
function Get-OpenCodeMajor {
  if (-not (Have opencode)) { return 0 }
  $v = (opencode --version 2>$null | Select-Object -First 1)
  if ("$v" -match '(\d+)\.\d+') { return [int]$Matches[1] }
  return -1
}

# ----------------------------------------------------------------- packages --

$WingetPackages = @(
  # shell + terminal
  'Microsoft.PowerShell'
  'Microsoft.WindowsTerminal'
  'Starship.Starship'
  'DEVCOM.JetBrainsMonoNerdFont'

  # vcs (Git for Windows bundles git-lfs)
  'Git.Git'
  'GitHub.cli'
  'JesseDuffield.lazygit'
  'dandavison.delta'

  # editors
  'Neovim.Neovim'
  'Microsoft.VisualStudioCode'

  # cli core
  'BurntSushi.ripgrep.MSVC'
  'sharkdp.fd'
  'sharkdp.bat'
  'eza-community.eza'
  'junegunn.fzf'
  'ajeetdsouza.zoxide'                # zsh gets `z` from oh-my-zsh; pwsh has no equivalent
  'jqlang.jq'
  'koalaman.shellcheck'
  'Casey.Just'
  'XAMPPRocky.Tokei'
  'Fastfetch-cli.Fastfetch'
  '7zip.7zip'

  # network
  'Tailscale.Tailscale'

  # languages / toolchains
  'Python.Python.3.13'
  'CoreyButler.NVMforWindows'
  'Oven-sh.Bun'
  'GoLang.Go'                         # gopls + nvim's Go tooling
  'LLVM.LLVM'                         # clang - treesitter needs a C compiler
  'Kitware.CMake'
  'ezwinports.make'                   # telescope-fzf-native builds with make
  'tree-sitter.tree-sitter-cli'
)

# The command each package provides, where checking for it is reliable. Not
# Python: Windows ships a `python` stub that opens the Store.
$WingetCommands = @{
  'Microsoft.PowerShell'        = 'pwsh'
  'Starship.Starship'           = 'starship'
  'Git.Git'                     = 'git'
  'GitHub.cli'                  = 'gh'
  'JesseDuffield.lazygit'       = 'lazygit'
  'dandavison.delta'            = 'delta'
  'Neovim.Neovim'               = 'nvim'
  'Microsoft.VisualStudioCode'  = 'code'
  'BurntSushi.ripgrep.MSVC'     = 'rg'
  'sharkdp.fd'                  = 'fd'
  'sharkdp.bat'                 = 'bat'
  'eza-community.eza'           = 'eza'
  'junegunn.fzf'                = 'fzf'
  'ajeetdsouza.zoxide'          = 'zoxide'
  'jqlang.jq'                   = 'jq'
  'koalaman.shellcheck'         = 'shellcheck'
  'Casey.Just'                  = 'just'
  'XAMPPRocky.Tokei'            = 'tokei'
  'Fastfetch-cli.Fastfetch'     = 'fastfetch'
  'Tailscale.Tailscale'         = 'tailscale'
  'CoreyButler.NVMforWindows'   = 'nvm'
  'Oven-sh.Bun'                 = 'bun'
  'GoLang.Go'                   = 'go'
  'LLVM.LLVM'                   = 'clang'
  'Kitware.CMake'               = 'cmake'
  'ezwinports.make'             = 'make'
  'tree-sitter.tree-sitter-cli' = 'tree-sitter'
  'Microsoft.Sqlcmd'            = 'sqlcmd'
  'Docker.DockerDesktop'        = 'docker'
  'JesseDuffield.Lazydocker'    = 'lazydocker'
  'Rustlang.Rustup'             = 'rustup'
}

if (Phase 'packages') {
  Head "Packages ($($WingetPackages.Count) via winget)"
  foreach ($id in $WingetPackages) { Install-Winget $id }
  Update-SessionPath
}

# --------------------------------------------------------------------- node --

if (Phase 'node') {
  Head 'Node + global CLIs'

  # ~/.local/bin holds rtk, diffnav and supabase. Put it on the persistent user
  # PATH too, not just the profile, so the OpenCode service and VS Code see rtk.
  $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
  if (($userPath -split ';') -notcontains $LocalBin) {
    if ($PSCmdlet.ShouldProcess('User PATH', "add $LocalBin")) {
      [Environment]::SetEnvironmentVariable('PATH', "$LocalBin;$userPath", 'User')
      Good "added $LocalBin to the user PATH"
    }
  }

  if (Have node) {
    Info "node $(node --version) (already installed)"
  } elseif (Have nvm) {
    if ($PSCmdlet.ShouldProcess('node lts', 'nvm install')) {
      Info 'nvm install lts ...'
      nvm install lts
      nvm use lts           # nvm-windows raises a UAC prompt to switch the link
      Update-SessionPath
      Good "node $(node --version 2>$null)"
    }
  } else {
    Warn 'nvm not on PATH yet - open a new terminal and re-run: bootstrap.ps1 -Only node'
  }

  # Output is streamed, not captured: `npm install -g` can run for minutes.
  foreach ($pkg in 'agent-browser', 'pnpm') {
    if (-not (Have npm)) { Warn 'npm unavailable - skipping global installs'; break }
    if (Have $pkg) { Info "$pkg (already installed)"; continue }
    if ($PSCmdlet.ShouldProcess($pkg, 'npm install -g')) {
      Info "npm install -g $pkg ..."
      npm install -g $pkg
      if ($LASTEXITCODE -eq 0) { Good "$pkg ok" } else { $Failed.Add("npm: $pkg") }
    }
  }
  # agent-browser drives a real Chrome, fetched separately.
  if ((Have agent-browser) -and $PSCmdlet.ShouldProcess('agent-browser', 'install Chrome')) {
    agent-browser install
    if ($LASTEXITCODE -ne 0) { $Failed.Add('agent-browser install') }
  }

  # Claude Code - native Windows installer. Kept in case it's needed.
  if (-not (Have claude)) {
    if ($PSCmdlet.ShouldProcess('claude-code', 'install')) {
      Info 'installing Claude Code ...'
      & ([scriptblock]::Create((Invoke-RestMethod https://claude.ai/install.ps1)))
    }
  } else {
    Info "claude already installed ($(claude --version 2>$null))"
  }

  # rtk - no winget/npm package. The release also ships rtk-oss-* and
  # rtk-proxy-* zips, so anchor the name; x64 runs under emulation on arm64.
  Install-GitHubRelease 'rtk-ai/rtk' '^rtk-x86_64-pc-windows-msvc\.zip$' 'rtk.exe'
}

# ----------------------------------------------------------------- opencode --

# Opt-in: `.\bootstrap.ps1 -Only opencode`. OpenCode 2 is the npm package
# @opencode/cli; `opencode-ai` and the opencode.ai/install script are still
# OpenCode 1 and can't load the v2 plugins. Manual equivalent:
#   npm install -g @opencode/cli
if (Phase 'opencode') {
  Head 'OpenCode 2'
  $major = Get-OpenCodeMajor
  if ($major -ge 2) {
    Info "$(opencode --version) (already installed)"
  } elseif (-not (Have npm)) {
    Warn 'npm unavailable - run the node phase first'
    $Failed.Add('opencode')
  } else {
    if ($major -ne 0) {
      Warn "found OpenCode $(opencode --version) - v1. Remove it first if npm installed it:"
      Warn '  npm uninstall -g opencode-ai'
    }
    if ($PSCmdlet.ShouldProcess('@opencode/cli', 'npm install -g')) {
      npm install -g @opencode/cli
      if ($LASTEXITCODE -eq 0) { Good "opencode $(opencode --version 2>$null)" } else { $Failed.Add('npm: @opencode/cli') }
    }
  }
}

# --------------------------------------------------------------------- link --

if (Phase 'link') {
  Head 'Repos'
  Clone $DotfilesRepo $DotfilesDir
  Clone $AgentRepo    $AgentDir

  Head 'Symlinks'

  # Neovim on Windows reads ~/AppData/Local/nvim, not ~/.config/nvim.
  Link (Join-Path $DotfilesDir 'nvim\.config\nvim') (Join-Path $env:LOCALAPPDATA 'nvim')

  # Starship is pointed at ~/.config/starship.toml by the profile's STARSHIP_CONFIG.
  Link (Join-Path $DotfilesDir 'starship\.config\starship.toml') (Join-Path $HOME '.config\starship.toml')

  Link (Join-Path $DotfilesDir 'git\.gitconfig')        (Join-Path $HOME '.gitconfig')
  Link (Join-Path $DotfilesDir 'git\.gitignore_global') (Join-Path $HOME '.gitignore_global')

  # gh-dash reads ~/.config/gh-dash on Windows too.
  Link (Join-Path $DotfilesDir 'gh-dash\.config\gh-dash') (Join-Path $HOME '.config\gh-dash')

  # PowerShell profile - AllHosts so it applies to Terminal, VS Code, and ISE.
  # Documents is often redirected into OneDrive, which mishandles symlinks, so
  # the profile is a one-line loader rather than a link.
  $profilePath = $PROFILE.CurrentUserAllHosts
  $loader = ". `"$(Join-Path $DotfilesDir 'windows\profile.ps1')`""
  $current = if (Test-Path -LiteralPath $profilePath) { Get-Item -LiteralPath $profilePath -Force } else { $null }
  if ($current -and $current.LinkType -ne 'SymbolicLink' -and
      (Get-Content -LiteralPath $profilePath -Raw) -match [regex]::Escape($loader)) {
    Info "$profilePath (already loads dotfiles)"
  } elseif ($PSCmdlet.ShouldProcess($profilePath, 'write loader for windows\profile.ps1')) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $profilePath) | Out-Null
    if ($current) {
      if ($current.LinkType -eq 'SymbolicLink') {
        Remove-Item -LiteralPath $profilePath -Force
      } else {
        $backup = "$profilePath.bak-$(Get-Date -Format yyyyMMddHHmmss)"
        Move-Item -LiteralPath $profilePath -Destination $backup
        Warn "backed up existing $profilePath -> $backup"
      }
    }
    @('# Loads the tracked profile. Machine-only additions: ~/.pwsh_profile.local.ps1', $loader) |
      Set-Content -LiteralPath $profilePath -Encoding utf8
    Info "$profilePath -> loads windows\profile.ps1"
  }

  # OpenCode 2 uses ~/.config/opencode on Windows as well. Link entries one by
  # one, like stow does on macOS, so secrets.env, cli.json, service.json and
  # node_modules stay local instead of landing in the checkout.
  $ocSrc = Join-Path $DotfilesDir 'opencode\.config\opencode'
  $ocDst = Join-Path $HOME '.config\opencode'
  foreach ($entry in 'opencode.json', 'tui.json', 'themes', 'v2-plugins') {
    Link (Join-Path $ocSrc $entry) (Join-Path $ocDst $entry)
  }

  # --- machine-local git settings (untracked, mirrors the macOS setup) ---
  # Identity is NOT written here. It lives in the tracked git/.gitconfig, because
  # it is the same on every machine and a per-machine copy is exactly what let the
  # name drift between "Justin Cordova" and "justincordova". Only values that
  # genuinely differ by platform belong in this file.
  $gitLocal = Join-Path $HOME '.gitconfig.local'
  if (-not (Test-Path $gitLocal)) {
    if ($PSCmdlet.ShouldProcess($gitLocal, 'write')) {
      @(
        '[core]'
        "`tautocrlf = true"
        '[credential]'
        "`thelper = manager"
      ) | Set-Content $gitLocal -Encoding utf8
      Warn "created $gitLocal - credential.helper=manager replaces osxkeychain; identity comes from the tracked git/.gitconfig"
    }
  }
}

# -------------------------------------------------------------------- tools --

if (Phase 'tools') {
  Head 'Tools'

  # gh-dash (`ghd`). `gh extension install` works before `gh auth login`, but
  # `gh extension list` doesn't -- so check gh's data directory instead.
  $ghData = if ($env:XDG_DATA_HOME) { Join-Path $env:XDG_DATA_HOME 'gh' } else { Join-Path $env:LOCALAPPDATA 'GitHub CLI' }
  if (-not (Have gh)) {
    Warn 'gh not on PATH - run the packages phase first'
  } elseif (Test-Path (Join-Path $ghData 'extensions\gh-dash')) {
    Info 'gh-dash (already installed)'
  } elseif ($PSCmdlet.ShouldProcess('dlvhdr/gh-dash', 'gh extension install')) {
    gh extension install dlvhdr/gh-dash
    if ($LASTEXITCODE -eq 0) { Good 'gh-dash' } else { $Failed.Add('gh-dash') }
  }

  # diffnav: the diff pager gh-dash's config uses.
  $arch = if ($IsArm) { 'arm64' } else { 'x86_64' }
  Install-GitHubRelease 'dlvhdr/diffnav' "^diffnav_Windows_$arch\.zip$" 'diffnav.exe'
}

# ----------------------------------------------------------------------- db --

if (Phase 'db') {
  Head 'Database clients'

  # psql: EDB's installer, client tools only. Its default also installs and
  # starts a Postgres server; databases run in Docker instead.
  $pgBin = Get-ChildItem 'C:\Program Files\PostgreSQL\*\bin\psql.exe' -ErrorAction SilentlyContinue
  if ((Have psql) -or $pgBin) {
    Info 'psql (already installed)'
  } else {
    Install-Winget 'PostgreSQL.PostgreSQL.18' `
      '--mode unattended --unattendedmodeui none --disable-components server,pgAdmin,stackbuilder'
  }

  Install-Winget 'Microsoft.Sqlcmd'

  $arch = if ($IsArm) { 'arm64' } else { 'amd64' }
  Install-GitHubRelease 'supabase/cli' "^supabase_windows_$arch\.tar\.gz$" 'supabase.exe'

  # There is no maintained native redis-cli for Windows.
  $Notes.Add('redis-cli: use the one in the container - docker exec -it <redis-container> redis-cli')
}

# ------------------------------------------------------------------- docker --

if (Phase 'docker') {
  Head 'Docker'
  # Docker Desktop runs its engine in WSL2; the installer enables that, and a
  # fresh machine needs a reboot before the first start.
  $hadDocker = Have docker
  Install-Winget 'Docker.DockerDesktop'
  Install-Winget 'JesseDuffield.Lazydocker'
  if (-not $hadDocker) {
    $Notes.Add('Docker Desktop: reboot if prompted, start it once, accept the terms')
  }
}

# -------------------------------------------------------------------- langs --

if (Phase 'langs') {
  Head 'Language toolchains (Java, .NET, Rust)'
  Install-Winget 'Microsoft.OpenJDK.21'      # jdtls needs 21+
  Install-Winget 'Microsoft.DotNet.SDK.10'   # current LTS; OmniSharp + .NET projects
  Install-Winget 'Rustlang.Rustup'
  Update-SessionPath

  if ((Have rustup) -and -not (Have rustc) -and $PSCmdlet.ShouldProcess('rust stable', 'rustup default')) {
    rustup default stable
  }
  # rustc's default MSVC target links with Visual Studio's link.exe. Formatting
  # and rust-analyzer work without it; building binaries does not.
  if (Have rustc) {
    $Notes.Add('Rust: to build binaries, install "Desktop development with C++" (Visual Studio Build Tools)')
  }
}

# ------------------------------------------------------------------- agents --

if (Phase 'agents') {
  Head 'Agent config (OpenCode + Claude Code)'

  $agentInstall = Join-Path $AgentDir 'install.ps1'
  if (Test-Path $agentInstall) {
    if ($PSCmdlet.ShouldProcess($agentInstall, 'run')) { & $agentInstall }
  } else {
    Warn "not found: $agentInstall"
  }

  # The tracked opencode.json loads ./v2-plugins/{anthropic,quotas}, which
  # import from their own node_modules. --ignore-scripts: opencode-mystatus's
  # installer rewrites opencode config, which these local ports replace.
  $plugins = Join-Path $DotfilesDir 'opencode\.config\opencode\v2-plugins'
  if (-not (Have npm)) {
    Warn 'npm unavailable - run the node phase first'
    $Failed.Add('v2-plugins npm ci')
  } elseif ($PSCmdlet.ShouldProcess($plugins, 'npm ci')) {
    Push-Location $plugins
    try { npm ci --ignore-scripts --no-audit --no-fund } finally { Pop-Location }
    if ($LASTEXITCODE -eq 0) { Good 'opencode v2-plugins deps' } else { $Failed.Add('v2-plugins npm ci') }
  }

  # RTK's shell hook. ~/.opencode applies to every project under $HOME. Do not
  # use `rtk init --opencode`: it writes an OpenCode 1 plugin.
  Link (Join-Path $plugins 'rtk.ts') (Join-Path $HOME '.opencode\plugins\rtk.ts')

  # Older versions of this script generated ~/.opencode/opencode.json with
  # opencode-claude-auth, which fights the local anthropic plugin over refresh
  # tokens. It held only {env:} placeholders, so set it aside rather than warn.
  $oldOc = Join-Path $HOME '.opencode\opencode.json'
  if (Test-Path $oldOc) {
    if ((Get-Content $oldOc -Raw) -match 'opencode-claude-auth') {
      if ($PSCmdlet.ShouldProcess($oldOc, 'move aside (old generated config)')) {
        Move-Item $oldOc "$oldOc.bak-$(Get-Date -Format yyyyMMddHHmmss)"
        Good "moved old generated $oldOc aside"
      }
    } else {
      Warn "$oldOc exists - everything now lives in the tracked config; delete it unless it holds something deliberate"
    }
  }

  # OpenCode rewrites cli.json in place, which would replace a symlink, so it is
  # seeded as a copy. The template is shared with linux/bootstrap.sh.
  $cliJson = Join-Path $HOME '.config\opencode\cli.json'
  if (-not (Test-Path $cliJson) -and $PSCmdlet.ShouldProcess($cliJson, 'seed')) {
    Copy-Item (Join-Path $DotfilesDir 'linux\opencode-cli.json') $cliJson
    Good 'seeded opencode cli.json'
  }

  # Loaded by profile.ps1; referenced from opencode.json as {env:NAME}. Same
  # format as macOS/Linux, where ~/.zshenv sources it.
  $secrets = Join-Path $HOME '.config\opencode\secrets.env'
  if (-not (Test-Path $secrets) -and $PSCmdlet.ShouldProcess($secrets, 'write template')) {
    @(
      '# Secrets for OpenCode MCP servers. Untracked; loaded by profile.ps1.'
      'export CONTEXT7_API_KEY='
      'export FIRECRAWL_API_KEY='
    ) | Set-Content $secrets -Encoding utf8
    Warn "created $secrets - fill in the API keys"
  }

  $major = Get-OpenCodeMajor
  if ($major -eq 0) {
    $Notes.Add('OpenCode is not installed: .\bootstrap.ps1 -Only opencode  (or: npm install -g @opencode/cli)')
  } elseif ($major -lt 2) {
    $Notes.Add("OpenCode $(opencode --version) is v1 and can't load the v2 plugins: .\bootstrap.ps1 -Only opencode")
  } else {
    Good "$(opencode --version) (v2 plugins supported)"
  }
}

# --------------------------------------------------------------------- nvim --

if (Phase 'nvim') {
  Head 'Neovim'
  if (-not (Have nvim)) {
    Warn 'nvim not on PATH - open a new terminal and re-run: bootstrap.ps1 -Only nvim'
  } elseif ($PSCmdlet.ShouldProcess('lazy.nvim', 'restore plugins headlessly')) {
    # restore, not sync: sync bumps every plugin and rewrites the tracked
    # lazy-lock.json. First-run bootstrap still rewrites lazy.nvim's own line,
    # so put the lockfile back -- but only if it was clean beforehand.
    $lock = 'nvim/.config/nvim/lazy-lock.json'
    git -C $DotfilesDir diff --quiet -- $lock
    $lockClean = $LASTEXITCODE -eq 0
    nvim --headless '+Lazy! restore' +qa
    if ($lockClean) { git -C $DotfilesDir checkout -q -- $lock }
    Good 'plugins restored from lazy-lock.json'
  }
}

# ---------------------------------------------------------------------- ssh --

# OpenSSH server, so the Mac or Linux box can SSH in. Logins land in pwsh.
# Password login stays on until a key is authorized, then it is turned off.
if (Phase 'ssh') {
  Head 'SSH server'
  if (-not $isAdmin) {
    Warn 'needs an elevated shell - skipped'
    $Notes.Add('SSH server: from an elevated pwsh run  .\bootstrap.ps1 -Only ssh')
  } else {
    $cap = Get-WindowsCapability -Online -Name 'OpenSSH.Server*' | Select-Object -First 1
    if ($cap.State -ne 'Installed' -and $PSCmdlet.ShouldProcess($cap.Name, 'Add-WindowsCapability')) {
      Add-WindowsCapability -Online -Name $cap.Name | Out-Null
      Good 'OpenSSH server installed'
    }

    if ($PSCmdlet.ShouldProcess('sshd', 'enable + start, default shell pwsh')) {
      Set-Service sshd -StartupType Automatic
      Start-Service sshd
      $pwsh = (Get-Command pwsh).Source
      New-Item 'HKLM:\SOFTWARE\OpenSSH' -Force | Out-Null
      New-ItemProperty 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value $pwsh -PropertyType String -Force | Out-Null
      if (-not (Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' `
          -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
      }
      Good "sshd running, login shell $pwsh"
    }

    # Members of Administrators authenticate against a machine-wide key file,
    # not ~/.ssh/authorized_keys (see the Match block in sshd_config).
    $me = [Security.Principal.WindowsIdentity]::GetCurrent().User
    # Get-LocalGroupMember throws on some machines with Entra/Microsoft-account
    # members; this phase only runs elevated, so assume an admin account then.
    try {
      $inAdmins = (Get-LocalGroupMember -SID 'S-1-5-32-544').SID -contains $me
    } catch {
      $inAdmins = $true
    }
    $keyFile = if ($inAdmins) { "$env:ProgramData\ssh\administrators_authorized_keys" } else { Join-Path $HOME '.ssh\authorized_keys' }

    $sshdConfig = "$env:ProgramData\ssh\sshd_config"
    $hasKey = (Test-Path $keyFile) -and ((Get-Content $keyFile -Raw) -match 'ssh-')
    if (-not $hasKey) {
      $Notes.Add("SSH: add your public key to $keyFile, then re-run -Only ssh (elevated) to turn off password login")
      if ($inAdmins) {
        $Notes.Add("  that file must be ACL'd to Administrators+SYSTEM:  icacls `"$keyFile`" /inheritance:r /grant Administrators:F /grant SYSTEM:F")
      }
    } elseif ((Test-Path $sshdConfig) -and $PSCmdlet.ShouldProcess($sshdConfig, 'PasswordAuthentication no')) {
      $conf = Get-Content $sshdConfig -Raw
      # Must sit above the Match block; the stock file has a commented default there.
      $re = [regex]'(?m)^#?\s*PasswordAuthentication\s+\w+'
      $conf = if ($re.IsMatch($conf)) { $re.Replace($conf, 'PasswordAuthentication no', 1) } else { "PasswordAuthentication no`n$conf" }
      Set-Content $sshdConfig $conf -NoNewline
      Restart-Service sshd
      Good 'key-only SSH login'
    }
  }
}

# ------------------------------------------------------------------ summary --

Head 'Summary'
if ($Failed.Count) {
  Warn "$($Failed.Count) item(s) failed:"
  $Failed | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
} else {
  Good 'all phases completed'
}
if ($Notes.Count) {
  Head 'Needs you'
  $Notes | ForEach-Object { Warn $_ }
}

Write-Host @'

Next:
  1. Restart your terminal (PATH changed).
  2. gh auth login
  3. Fill in ~/.config/opencode/secrets.env (context7, firecrawl keys).
  4. opencode -> /connect Anthropic (and Google), then /mcps to sign in to
     supabase and atlassian.
  5. Windows Terminal: set the font to "JetBrainsMono Nerd Font".
  6. tailscale up   (if this machine should be on the tailnet)
  Optional, Claude Code only: claude -> /login, plugins (see README), Update-ClaudeHud.

'@ -ForegroundColor DarkGray
