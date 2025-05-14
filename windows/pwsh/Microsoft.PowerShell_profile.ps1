# Keep prompt at the bottom of the terminal during startup
$consoleHeight = $host.UI.RawUI.WindowSize.Height
Write-Host ("`n" * $consoleHeight)

## Constants
$claudeApiKey = Get-Content -Path "C:\Users\ville\myfiles\documents\api-keys\Anthropic\loïc-onboarding-api-key.txt" -Raw

## Environment variables
$env:PYTHONIOENCODING="utf-8"
$env:ANTHROPIC_API_KEY = $claudeApiKey.Trim()
$env:FZF_DEFAULT_OPTS='--bind=esc:toggle-down,ctrl-c:abort' # avoid accidental exit from fzf (toggle-down does nothing)
$env:YAZI_FILE_ONE="C:\Program Files\Git\usr\bin\file.exe"
$env:DOTFILES = "$HOME\dotfiles"

## Modules
Import-Module Terminal-Icons
Import-Module PSFzf
Import-Module posh-git

## Custom modules
Import-Module "$env:DOTFILES\windows\pwsh\Cut-Paste.psm1"
Import-Module "$env:DOTFILES\windows\pwsh\ProfileFunctions.psm1"
# cut paste aliases
Set-Alias -Name cut -Value Move-ItemToBuffer
Set-Alias -Name paste -Value Restore-ItemFromBuffer
# general functions aliases
Set-Alias -Name spp -Value Set-PythonPath
Set-Alias -Name eme -Value Enter-MegaScriptEnvironment
Set-Alias -Name cpath -Value Copy-PathToClipboard
Set-Alias -Name dsize -Value Get-DirectorySize
Set-Alias -Name virepro -Value Start-NvimBugRepro

## Path additions
$env:PATH += "$env:DOTFILES\windows\batch\"
$env:Path += ";C:\Users\ville\myfiles\programs\PROGRAMS_ON_PATH\"
$env:PATH = "$env:USERPROFILE\scoop\shims;$env:PATH"

## Vi mode options
$OnViModeChange = [scriptblock]{
  if ($args[0] -eq 'Command')
  {
    # Set the cursor to a steady block.
    Write-Host -NoNewLine "`e[0 q"
  } else
  {
    # Set the cursor to a steady line.
    Write-Host -NoNewLine "`e[6 q"
  }
}
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $OnViModeChange
# Start in insert mode cursor
Write-Host -NoNewLine "`e[6 q"

## PSReadLine options
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -ShowToolTips
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PSReadLineKeyHandler -Chord 'U' -Function Redo -ViMode Command
Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardKillWord -ViMode Insert
Set-PSReadLineKeyHandler -Key 'RightArrow' -Function AcceptNextSuggestionWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Chord 'Alt-;' -Function AcceptSuggestion

## Module options
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r' -PSReadlineChordSetLocation 'Alt+c'

## Minor utility functions
function Update-Profile
{
  Add-Type -AssemblyName System.Windows.Forms
  [System.Windows.Forms.SendKeys]::SendWait(". $")
  [System.Windows.Forms.SendKeys]::SendWait("PROFILE")
  [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
}

function Edit-Profile
{
  nvim $PROFILE
}

function Edit-Wezterm-Profile
{
  nvim "$env:DOTFILES\.wezterm.lua"
}

function Edit-Lazygit-Config
{
  nvim "$env:DOTFILES\lazygit-config.yml"
}

function Edit-Git-Config
{
  git config --global -e
}

function Edit-Kanata-Config
{
  nvim "$env:DOTFILES\kanata.kbd"
}

function Show-TreeList
{
  eza --icons -lT $args
}

function Clear-AndPutPromptAtBottom
{
  $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0, 0
  Clear-Host
  $consoleHeight = $host.UI.RawUI.WindowSize.Height
  Write-Host "$([char]27)[${consoleHeight}B" -NoNewline
}

function Hide-Taskbar
{
  Start-Process -FilePath "nircmd.exe" -ArgumentList "win trans class Shell_TrayWnd 256" -NoNewWindow
}

function Show-Taskbar
{
  Start-Process -FilePath "nircmd.exe" -ArgumentList "win trans class Shell_TrayWnd 255" -NoNewWindow
}

## Minor functions aliases
Set-Alias -Name rel -Value Update-Profile

Set-Alias -Name cfg -Value Edit-Profile
Set-Alias -Name wzcfg -Value Edit-Wezterm-Profile
Set-Alias -Name lgcfg -Value Edit-Lazygit-Config
Set-Alias -Name gitcfg -Value Edit-Git-Config
Set-Alias -Name kacfg -Value Edit-Kanata-Config

Set-Alias -Name zf -Value Invoke-FzfCd
Set-Alias -Name lst -Value Show-TreeList
Set-Alias -Name clear -Value Clear-AndPutPromptAtBottom

## Exec aliases
Set-Alias -Name lg -Value lazygit
Set-Alias -Name vi -Value nvim
Set-Alias -Name ex -Value explorer
Set-Alias -Name d -Value dir
Set-Alias -Name wh -Value where.exe
Set-Alias -Name kan -Value kanata


## Location functions
function ahk
{
  Set-Location "$env:DOTFILES\windows\autohotkey"
}

function vidata
{
  Set-Location "$HOME\AppData\Local\nvim-data"
}

function vid
{
  Set-Location "$env:DOTFILES\nvim-config3.0"
}

function roam
{
  Set-Location "$HOME\AppData\Roaming"
}

function loc
{
  Set-Location "$HOME\AppData\Local"
}

function dot
{
  Set-Location "$env:DOTFILES"
}

function my
{
  Set-Location "$HOME\myfiles"
}

## Starship
$global:lastDirectory = (Get-Location).Path

function Invoke-Starship-TransientFunction
{
  $currentDirectory = (Get-Location).Path

  $time = &starship module time
  $char = &starship module character

  if ($global:lastDirectory -ne $currentDirectory)
  {
    $dir = &starship module directory
    $global:lastDirectory = $currentDirectory
    return "`n$dir`n$time$char"
  } else
  {
    return "$time$char"
  }
}

# Update directory tracking after each command
function Invoke-Starship-PostCommand
{
  $global:lastDirectory = (Get-Location).Path
}

Invoke-Expression (&starship init powershell)
Enable-TransientPrompt

# OSC compatible prompt
$prompt = ""
function Invoke-Starship-PreCommand
{
  $current_location = $executionContext.SessionState.Path.CurrentLocation
  if ($current_location.Provider.Name -eq "FileSystem")
  {
    $ansi_escape = [char]27
    $provider_path = $current_location.ProviderPath -replace "\\", "/"
    $prompt = "$ansi_escape]7;file://${env:COMPUTERNAME}/${provider_path}$ansi_escape\"
  }
  $host.ui.Write($prompt)
  Write-Host "`n`n`n`n" -NoNewline
  Write-Host "$([char]27)[4A" -NoNewline
}

## Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })
