# PowerShell 7 profile - Windows counterpart to zsh/.zshrc.
# Symlinked to $PROFILE.CurrentUserAllHosts by windows/bootstrap.ps1.

# --- Environment ---
$env:BAT_THEME = 'Twork'
$env:BUN_INSTALL = "$HOME\.bun"
$env:GOPATH = "$HOME\go"
$env:EDITOR = 'nvim'

# --- PATH (prepend, de-duplicated) ---
$PrependPaths = @(
  "$env:BUN_INSTALL\bin"
  "$HOME\.local\bin"
  "$env:GOPATH\bin"
  "$HOME\AppData\Roaming\npm"
)
$Existing = $env:PATH -split ';' | Where-Object { $_ }
$env:PATH = (($PrependPaths + $Existing) | Select-Object -Unique) -join ';'

# --- History ---
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -MaximumHistoryCount 10000

# zsh-autosuggestions equivalent
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle InlineView

# zsh-style: Up/Down search history by what you've already typed
Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# --- Remove built-in aliases that shadow real tools ---
foreach ($a in 'ls', 'l', 'cat', 'rm', 'mv', 'cp', 'man', 'diff', 'where', 'curl', 'wget') {
  if (Test-Path "Alias:$a") { Remove-Item "Alias:$a" -Force -ErrorAction SilentlyContinue }
}

# --- Tools Initialization ---
if (Get-Command starship -ErrorAction SilentlyContinue) {
  $env:STARSHIP_CONFIG = "$HOME\.config\starship.toml"
  Invoke-Expression (&starship init powershell)
}
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# --- Aliases: core ---
function c { Clear-Host }
function reload { . $PROFILE.CurrentUserAllHosts }
function which { param($n) (Get-Command $n -ErrorAction SilentlyContinue).Source }

if (Get-Command eza -ErrorAction SilentlyContinue) {
  function ls { eza @args }
  function ll { eza -la @args }
  function l  { eza -l  @args }
  function lt { eza --tree @args }
} else {
  function ls { Get-ChildItem @args }
  function ll { Get-ChildItem -Force @args }
  function l  { Get-ChildItem @args }
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
  function cat { bat @args }
}

# --- Aliases: agents ---
function cc { claude @args }
function oc { opencode @args }
function dc { dotcor @args }

# --- Aliases: navigation / editors ---
function v { nvim @args }
function codep { code .. --reuse-window }

# `ne` - open Neovim with Neotree revealed (port of the zsh function)
function ne {
  param([string]$Path)
  $env:NVIM_NO_DASHBOARD = '1'
  try {
    if ($Path) {
      if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        Write-Error "'$Path' is not a directory"
        return
      }
      $resolved = (Resolve-Path -LiteralPath $Path).Path -replace '\\', '/'
      nvim -c "cd $resolved" -c 'Neotree reveal' -c 'wincmd l' -c 'close' -c '1bwipeout'
    } else {
      nvim -c 'Neotree reveal' -c 'wincmd l' -c 'close' -c '1bwipeout'
    }
  } finally {
    Remove-Item Env:NVIM_NO_DASHBOARD -ErrorAction SilentlyContinue
  }
}

# --- Aliases: git ---
function lg  { lazygit @args }
function gmp { git checkout main; git pull }

# --- Aliases: dev / misc ---
function py  { python @args }
function py3 { python @args }
function ghd { gh dash @args }

# --- Functions ---
function mkcd {
  param([Parameter(Mandatory)][string]$Path)
  New-Item -ItemType Directory -Force -Path $Path | Out-Null
  Set-Location -LiteralPath $Path
}

# Re-pin the claude-hud statusline after a plugin update.
function Update-ClaudeHud {
  [CmdletBinding(SupportsShouldProcess)]
  param()

  $bun = (Get-Command bun -ErrorAction SilentlyContinue).Source
  if (-not $bun) { Write-Error 'bun not found on PATH'; return }

  $cacheRoot = Join-Path $HOME '.claude\plugins\cache\claude-hud\claude-hud'
  $latest = Get-ChildItem -Directory $cacheRoot -ErrorAction SilentlyContinue |
    Sort-Object { [version]($_.Name -replace '[^\d.].*$', '') } |
    Select-Object -Last 1
  if (-not $latest) { Write-Error "claude-hud not installed under $cacheRoot"; return }

  $entry = Join-Path $latest.FullName 'src\index.ts'
  $settingsPath = Join-Path $HOME '.claude\settings.json'
  if (-not $PSCmdlet.ShouldProcess($settingsPath, "pin statusLine to $entry")) { return }

  $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

  # Direct bun.exe invocation - wrapping in `powershell -Command` spawns a
  # console window on every ~300ms statusline refresh.
  # Add-Member -Force rather than direct assignment: ConvertFrom-Json returns a
  # PSCustomObject, and assigning a property it doesn't already have throws.
  $settings | Add-Member -NotePropertyName statusLine -NotePropertyValue ([pscustomobject]@{
    type    = 'command'
    command = "`"$bun`" --env-file NUL `"$entry`""
  }) -Force

  $settings | ConvertTo-Json -Depth 20 | Set-Content $settingsPath -Encoding utf8
  Write-Host "statusLine -> $entry" -ForegroundColor Green
}

# --- Machine-local overrides (untracked) ---
$LocalProfile = Join-Path $HOME '.pwsh_profile.local.ps1'
if (Test-Path $LocalProfile) { . $LocalProfile }
