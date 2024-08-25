# Constants
$global:MegaScriptPath = "C:\Users\ville\MyMegaScript"
$global:ScriptDirPath ="C:\Users\ville\MyScripts"
Import-Module Terminal-Icons
Import-Module PSFzf

oh-my-posh init pwsh --config 'C:\Users\ville\AppData\Local\Programs\oh-my-posh\themes\tonybaloney.omp.json' | Invoke-Expression
Set-PSReadLineOption -EditMode Emacs
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
  asd
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
Set-Alias -Name p -Value Get-Location
Set-Alias -Name c -Value Clear-Host
Set-Alias -Name gds -Value Get-DirectorySize
Set-Alias -Name vi -Value nvim
Set-Alias -Name cpc -Value Copy-PathToClipboard

# Path aliases (these are fine as-is since they're not cmdlets)
function scri {
  Set-Location "C:\Users\ville\MyScripts" 
}

function vidata {
  Set-Location "C:\Users\ville\AppData\Local\nvim-data"
}



