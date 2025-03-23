[Console]::Write("`e[?2004h")
# Constants
$global:MegaScriptPath = "C:\Users\ville\MyMegaScript"
Import-Module Terminal-Icons
Import-Module PSFzf
$env:PYTHONIOENCODING="utf-8"

# Importing my custom modules
Import-Module "C:\Users\ville\myfiles\dotfiles\pwsh_modules\cut_paste.psm1"
Set-Alias -Name cut -Value Move-ItemToBuffer
Set-Alias -Name paste -Value Restore-ItemFromBuffer

# Path additions
$env:PATH += ";C:\Users\ville\myfiles\dotfiles\scripts\batch"
$env:Path += ";C:\Users\ville\myfiles\programs\PROGRAMS_ON_PATH\"
$env:PATH = "$env:USERPROFILE\scoop\shims;$env:PATH"


Set-PSReadLineOption -EditMode Vi
Set-PSReadLineKeyHandler -Chord 'U' -Function Redo -ViMode Command
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+g' -Function AcceptNextSuggestionWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

if (Get-Module -ListAvailable -Name posh-git) {
  # Import posh-git module
  Import-Module posh-git
} else {
  # If posh-git is not installed, install it
  Write-Host "posh-git is not installed. Installing..."
  Install-Module posh-git -Scope CurrentUser -Force
  Import-Module posh-git
}

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'

function Invoke-FzfCd {
  # navigate to the directory of selected file in fzf
  $selected = fzf

  if (-not $selected) {
    Write-Host "No selection made."
    return
  }

  if (Test-Path -Path $selected -PathType Container) {
    z $selected
  } else {
    $parent = Split-Path -Path $selected -Parent
    z $parent
  }
}


function Set-PythonPath {
  $env:PYTHONPATH = (Get-Location).Path
  Write-Output "PYTHONPATH set to: $env:PYTHONPATH"
}

function Enter-MegaScriptEnvironment {
  Set-Location $MegaScriptPath
  Set-PythonPath
  .\venv\Scripts\activate
}

function Get-PortUsage {
  param (
    [Parameter(Mandatory=$true)]
    [int]$Port
  )

  netstat -aon | findstr ":$Port"
}

function Copy-PathToClipboard {
  param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Item
  )
  $fullPath = (Get-Item $Item).FullName
  $fullPath | Set-Clipboard
  Write-Host "Copied to clipboard: $fullPath"
}

function Get-DirectorySize {
  Get-ChildItem | Select-Object Name, @{
    Name = "Type"
    Expression = {
      if ($_.PSIsContainer) {
        "Directory"
      } else {
        "File"
      }
    }
  }, @{
    Name = "Size (MB)"
    Expression = {
      if ($_.PSIsContainer) {
        # If the item is a directory, calculate the total size of its contents
        [math]::Round((Get-ChildItem $_.FullName -Recurse -Force | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
      } else {
        # If the item is a file, return its size
        [math]::Round($_.Length / 1MB, 2)
      }
    }
  } | Format-Table -AutoSize
}

function Update-Profile{
  Add-Type -AssemblyName System.Windows.Forms
  [System.Windows.Forms.SendKeys]::SendWait(". $")
  [System.Windows.Forms.SendKeys]::SendWait("PROFILE")
  [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
}

function Edit-Profile {
  nvim $PROFILE
}

function Edit-Wezterm-Profile{
  nvim "C:\Users\ville\myfiles\dotfiles\.wezterm.lua"
}

function Edit-Lazygit-Config {
  nvim "C:\Users\ville\AppData\Local\lazygit\config.yml"
}

# Function aliases
Set-Alias -Name gpu -Value Get-PortUsage
Set-Alias -Name spp -Value Set-PythonPath
Set-Alias -Name eme -Value Enter-MegaScriptEnvironment
Set-Alias -Name c -Value Clear-Host
Set-Alias -Name dsize -Value Get-DirectorySize
Set-Alias -Name cpc -Value Copy-PathToClipboard
Set-Alias -Name lg -Value lazygit
Set-Alias -Name vi -Value nvim
Set-Alias -Name ex -Value explorer
Set-Alias -Name rel -Value Update-Profile
Set-Alias -Name cfg -Value Edit-Profile
Set-Alias -Name wzcfg -Value Edit-Wezterm-Profile
Set-Alias -Name lgcfg -Value Edit-Lazygit-Config
Set-Alias -Name d -Value dir
Set-Alias -Name zf -Value Invoke-FzfCd


# Path aliases (these are fine as-is since they're not cmdlets)
function ahk{
  Set-Location "C:\Users\ville\myfiles\dotfiles\scripts\autohotkey"
}

function vidata {
  Set-Location "C:\Users\ville\AppData\Local\nvim-data"
}

function vid {
  Set-Location "C:\Users\ville\AppData\Local\nvim"
}

function roam {
  Set-Location "C:\Users\ville\AppData\Roaming"
}

function loc {
  Set-Location "C:\Users\ville\AppData\Local"
}

function dot {
  Set-Location "C:\Users\ville\myfiles\dotfiles\"
}

function my {
  Set-Location "C:\Users\ville\myfiles"
}

function prompt {
  # Call the Starship prompt
  &starship prompt --status=$LASTEXITCODE --jobs=(Get-Job | Measure-Object).Count

  # Re-enable bracketed paste mode after each command
  [Console]::Write("`e[?2004h")
}

$prompt = ""
function Invoke-Starship-PreCommand {
  $current_location = $executionContext.SessionState.Path.CurrentLocation
  if ($current_location.Provider.Name -eq "FileSystem") {
    $ansi_escape = [char]27
    $provider_path = $current_location.ProviderPath -replace "\\", "/"
    $prompt = "$ansi_escape]7;file://${env:COMPUTERNAME}/${provider_path}$ansi_escape\"
  }
  $host.ui.Write($prompt)
}

$env:PATH += ";C:\Program Files\starship\bin"
Invoke-Expression (&starship init powershell)

# Register an exit handler to disable bracketed paste mode
$ExecutionContext.SessionState.InvokeCommand.CommandNotFoundAction = {
  param($commandName, $errorRecord)
  if ($commandName -eq 'exit') {
    [Console]::Write("`e[?2004l")
  }
}

# Optionally, you can also add this to handle when PowerShell is closed directly
$null = Register-EngineEvent PowerShell.Exiting -Action { [Console]::Write("`e[?2004l") }

Invoke-Expression (& { (zoxide init powershell | Out-String) })
