[Console]::Write("`e[?2004h")
# Constants
$global:MegaScriptPath = "C:\Users\ville\MyMegaScript"
$global:ScriptDirPath ="C:\Users\ville\MyScripts"
Import-Module Terminal-Icons
Import-Module PSFzf
$env:PYTHONIOENCODING="utf-8"
Invoke-Expression "$(thefuck --alias)"

oh-my-posh init pwsh --config 'C:\Users\ville\AppData\Local\Programs\oh-my-posh\themes\montys.omp.json' | Invoke-Expression
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+g' -Function AcceptNextSuggestionWord
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'

# Functions
function Set-PythonPath {
  $env:PYTHONPATH = (Get-Location).Path
  Write-Output "PYTHONPATH set to: $env:PYTHONPATH"
}

function Enter-MegaScriptEnvironment {
  Set-Location $MegaScriptPath
  Set-PythonPath
  .\venv\Scripts\activate
}

function Start-PythonServer {
  py src\core\server.py
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

# Function aliases
Set-Alias -Name gpu -Value Get-PortUsage
Set-Alias -Name spp -Value Set-PythonPath
Set-Alias -Name eme -Value Enter-MegaScriptEnvironment
Set-Alias -Name sps -Value Start-PythonServer
Set-Alias -Name c -Value Clear-Host
Set-Alias -Name gds -Value Get-DirectorySize
Set-Alias -Name cpc -Value Copy-PathToClipboard
Set-Alias -Name lg -Value lazygit
Set-Alias -Name vi -Value nvim
Set-Alias -Name ex -Value explorer


# Path aliases (these are fine as-is since they're not cmdlets)
function scri {
  Set-Location "C:\Users\ville\MyScripts" 
}

function vidata {
  Set-Location "C:\Users\ville\AppData\Local\nvim-data"
}

function vid {
  Set-Location "C:\Users\ville\AppData\Local\nvim"
}

function lgcfg {
  Set-Location "C:\Users\ville\AppData\Local\lazygit\"
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
