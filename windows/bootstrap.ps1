#Requires -Version 7.0
<#
.SYNOPSIS
  Provision a Windows dev machine to match the macOS setup.

.DESCRIPTION
  Idempotent - safe to re-run. Each phase can be run in isolation with -Only.

.EXAMPLE
  .\bootstrap.ps1                      # everything
  .\bootstrap.ps1 -Only packages       # just winget
  .\bootstrap.ps1 -Only link,agents    # symlinks + agent config
  .\bootstrap.ps1 -WhatIf              # dry run
#>
[CmdletBinding(SupportsShouldProcess)]
param(
  [ValidateSet('packages', 'node', 'agents', 'link', 'nvim')]
  [string[]]$Only,

  [string]$DotfilesRepo = 'git@github.com:justincordova/dotfiles.git',
  [string]$AgentRepo    = 'git@github.com:justincordova/agents.git'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$DotfilesDir = Join-Path $HOME 'dotfiles'
$AgentDir    = Join-Path $HOME 'agent'
$Failed      = [System.Collections.Generic.List[string]]::new()

function Phase {
  param([string]$Name)
  if ($script:Only) { return $script:Only -contains $Name }
  return $true
}
function Info  { param($m) Write-Host "  $m" -ForegroundColor DarkGray }
function Good  { param($m) Write-Host "  $m" -ForegroundColor Green }
function Warn  { param($m) Write-Host "  $m" -ForegroundColor Yellow }
function Head  { param($m) Write-Host "`n$m" -ForegroundColor Cyan }
function Have  { param($c) [bool](Get-Command $c -ErrorAction SilentlyContinue) }

# ---------------------------------------------------------------- preflight --

Head 'Preflight'

if (-not (Have winget)) {
  throw 'winget not found. Install "App Installer" from the Microsoft Store, then re-run.'
}
Good "winget $(winget --version)"

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
  if (Phase 'link') { throw 'Cannot create symlinks.' }
} else {
  Good ('symlinks available ({0})' -f $(if ($devMode -eq 1) { 'Developer Mode' } else { 'elevated' }))
}

# ----------------------------------------------------------------- packages --

$WingetPackages = @(
  # shell + terminal
  'Microsoft.PowerShell'
  'Microsoft.WindowsTerminal'
  'wez.wezterm'                       # Ghostty has no Windows build
  'Starship.Starship'
  'DEVCOM.JetBrainsMonoNerdFont'

  # vcs
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
  'ajeetdsouza.zoxide'
  'jqlang.jq'
  'Atuinsh.Atuin'
  'Casey.Just'
  'XAMPPRocky.Tokei'
  'Fastfetch-cli.Fastfetch'
  '7zip.7zip'

  # languages / toolchains
  'Python.Python.3.13'
  'CoreyButler.NVMforWindows'
  'Oven-sh.Bun'
  'LLVM.LLVM'                         # clang - treesitter needs a C compiler
  'Kitware.CMake'
)

if (Phase 'packages') {
  Head "Packages ($($WingetPackages.Count) via winget)"

  $installed = (winget list --disable-interactivity 2>$null | Out-String)

  foreach ($id in $WingetPackages) {
    if ($installed -match [regex]::Escape($id)) { Info "$id (already installed)"; continue }
    if (-not $PSCmdlet.ShouldProcess($id, 'winget install')) { continue }

    # Stream winget's own output. Capturing it makes a slow installer (Python,
    # LLVM) indistinguishable from a hang, and hides any prompt it is blocked on.
    Write-Host "  installing $id ..." -ForegroundColor DarkGray
    winget install --id $id --exact --silent `
      --accept-package-agreements --accept-source-agreements `
      --disable-interactivity

    switch ($LASTEXITCODE) {
      0            { Good "$id ok" }
      -1978335189  { Info "$id (already current)" }   # 0x8A15002B no applicable upgrade
      -1978335135  { Info "$id (already installed)" } # 0x8A150061 already installed
      default {
        Write-Host "  $id FAILED (exit $LASTEXITCODE)" -ForegroundColor Red
        $Failed.Add("winget: $id")
      }
    }
  }
  Warn 'Restart your shell before the next phase so PATH updates apply.'
}

# --------------------------------------------------------------------- node --

if (Phase 'node') {
  Head 'Node + global CLIs'

  if (Have nvm) {
    if ($PSCmdlet.ShouldProcess('node lts', 'nvm install')) {
      nvm install lts | Out-Null
      nvm use lts     | Out-Null
      Good "node $(node --version 2>$null)"
    }
  } else {
    Warn 'nvm not on PATH yet - open a new terminal and re-run: bootstrap.ps1 -Only node'
  }

  # OpenCode has no winget package; npm is the supported Windows path.
  $npmGlobals = @('opencode-ai', 'agent-browser')
  foreach ($pkg in $npmGlobals) {
    if (-not (Have npm)) { Warn 'npm unavailable - skipping global installs'; break }
    if ($PSCmdlet.ShouldProcess($pkg, 'npm install -g')) {
      npm install -g $pkg 2>&1 | Out-Null
      if ($LASTEXITCODE -eq 0) { Good $pkg } else { $Failed.Add("npm: $pkg") }
    }
  }

  # Claude Code - native Windows installer.
  if (-not (Have claude)) {
    if ($PSCmdlet.ShouldProcess('claude-code', 'install')) {
      Info 'installing Claude Code ...'
      & ([scriptblock]::Create((Invoke-RestMethod https://claude.ai/install.ps1)))
    }
  } else {
    Info "claude already installed ($(claude --version 2>$null))"
  }

  # rtk - no winget/npm package; pull the MSVC zip from GitHub releases.
  if (-not (Have rtk)) {
    if ($PSCmdlet.ShouldProcess('rtk', 'download from releases')) {
      try {
        $rel = Invoke-RestMethod 'https://api.github.com/repos/rtk-ai/rtk/releases/latest'
        $asset = $rel.assets | Where-Object name -Match 'x86_64-pc-windows-msvc.*\.zip$' | Select-Object -First 1
        if (-not $asset) { throw 'no windows-msvc asset in latest release' }

        $binDir = Join-Path $HOME '.local\bin'
        New-Item -ItemType Directory -Force -Path $binDir | Out-Null
        $zip = Join-Path $env:TEMP $asset.name
        Invoke-WebRequest $asset.browser_download_url -OutFile $zip
        Expand-Archive $zip -DestinationPath $binDir -Force
        Remove-Item $zip -Force
        Good "rtk -> $binDir (run 'rtk init -g' after restarting your shell)"
      } catch {
        Warn "rtk install failed: $($_.Exception.Message)"
        $Failed.Add('rtk')
      }
    }
  } else {
    Info "rtk already installed ($(rtk --version 2>$null))"
  }
}

# --------------------------------------------------------------------- link --

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
  if ($LASTEXITCODE -ne 0) { $Failed.Add("clone: $Url") }
}

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

  # PowerShell profile - AllHosts so it applies to Terminal, VS Code, and ISE.
  Link (Join-Path $DotfilesDir 'windows\profile.ps1') $PROFILE.CurrentUserAllHosts

  # OpenCode global config. Mirrors what `stow opencode` does on macOS: link the
  # entries individually so the generated node_modules/ and lockfiles stay put.
  $ocSrc = Join-Path $DotfilesDir 'opencode\.config\opencode'
  $ocDst = Join-Path $HOME '.config\opencode'
  foreach ($entry in 'agents', 'command', 'skills', 'themes', 'tui.json', 'opencode.json') {
    Link (Join-Path $ocSrc $entry) (Join-Path $ocDst $entry)
  }

  # --- machine-local git identity (untracked, mirrors the macOS setup) ---
  $gitLocal = Join-Path $HOME '.gitconfig.local'
  if (-not (Test-Path $gitLocal)) {
    @(
      '[user]'
      "`tname = Justin Cordova"
      "`temail = CHANGE_ME"
      '[core]'
      "`tautocrlf = true"
      '[credential]'
      "`thelper = manager"
    ) | Set-Content $gitLocal -Encoding utf8
    Warn "created $gitLocal - set your email, and note credential.helper=manager replaces osxkeychain"
  }
}

# ------------------------------------------------------------------- agents --

if (Phase 'agents') {
  Head 'Agent config (Claude Code + OpenCode)'

  $agentInstall = Join-Path $AgentDir 'install.ps1'
  if (Test-Path $agentInstall) {
    if ($PSCmdlet.ShouldProcess($agentInstall, 'run')) { & $agentInstall }
  } else {
    Warn "not found: $agentInstall"
  }

  # --- OpenCode: ~/.opencode/opencode.json ---
  # Secrets come from the environment, never from the repo.
  $ocDir = Join-Path $HOME '.opencode'
  New-Item -ItemType Directory -Force -Path $ocDir | Out-Null

  foreach ($k in 'CONTEXT7_API_KEY', 'FIRECRAWL_API_KEY') {
    if (-not [Environment]::GetEnvironmentVariable($k, 'User')) {
      Warn "env var $k is not set - set it with: [Environment]::SetEnvironmentVariable('$k','<key>','User')"
    }
  }

  $ocConfig = [ordered]@{
    '$schema' = 'https://opencode.ai/config.json'
    plugin    = @('opencode-gemini-auth@latest', 'opencode-claude-auth@latest', 'opencode-mystatus')
    command   = @{
      mystatus = @{
        description = 'Query quota usage for all AI accounts'
        template    = 'Use the mystatus tool to query quota usage. Return the result as-is without modification.'
      }
    }
    mcp = [ordered]@{
      context7 = [ordered]@{
        type    = 'remote'
        url     = 'https://mcp.context7.com/mcp'
        headers = @{ CONTEXT7_API_KEY = '{env:CONTEXT7_API_KEY}' }
        enabled = $true
      }
      firecrawl = [ordered]@{
        type        = 'local'
        command     = @('npx', '-y', 'firecrawl-mcp')
        environment = @{ FIRECRAWL_API_KEY = '{env:FIRECRAWL_API_KEY}' }
        enabled     = $true
      }
    }
  }
  $ocPath = Join-Path $ocDir 'opencode.json'
  if ($PSCmdlet.ShouldProcess($ocPath, 'write')) {
    $ocConfig | ConvertTo-Json -Depth 20 | Set-Content $ocPath -Encoding utf8
    Good $ocPath
  }

  # --- Claude Code plugins + statusline ---
  Warn 'Claude Code plugins are not file-portable. In `claude`, run:'
  Warn '  /plugin marketplace add jarrodwatts/claude-hud'
  Warn '  /plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill'
  Warn '  /plugin install claude-hud@claude-hud'
  Warn '  /plugin install typescript-lsp@claude-plugins-official  (+ gopls, pyright, clangd, lua)'
  Warn '  /plugin install context7@claude-plugins-official code-review commit-commands claude-md-management'
  Warn 'Then run Update-ClaudeHud to pin the statusline (avoids the PowerShell window-flash bug).'
}

# --------------------------------------------------------------------- nvim --

if (Phase 'nvim') {
  Head 'Neovim'
  if (Have nvim) {
    if ($PSCmdlet.ShouldProcess('lazy.nvim', 'sync plugins headlessly')) {
      nvim --headless '+Lazy! sync' +qa
      Good 'plugins synced'
    }
  } else {
    Warn 'nvim not on PATH - open a new terminal and re-run: bootstrap.ps1 -Only nvim'
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

Write-Host @'

Next:
  1. Restart your terminal (PATH changed).
  2. rtk init -g
  3. gh auth login
  4. claude   -> /login, then install plugins (see above), then Update-ClaudeHud
  5. opencode -> /connect
  6. Set Windows Terminal font to "JetBrainsMono Nerd Font"
  7. Edit ~/.gitconfig.local with your email

'@ -ForegroundColor DarkGray
