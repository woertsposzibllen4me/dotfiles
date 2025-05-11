## Constants
$claudeApiKey = Get-Content -Path "C:\Users\ville\myfiles\documents\api-keys\Anthropic\loïc-onboarding-api-key.txt" -Raw
$dotfiles = "$env:USERPROFILE\myfiles\dotfiles"

## Environment variables
$env:PYTHONIOENCODING="utf-8"
$env:ANTHROPIC_API_KEY = $claudeApiKey.Trim()
$env:FZF_DEFAULT_OPTS='--bind=esc:toggle-down,ctrl-c:abort' # avoid accidental exit from fzf (toggle-down does nothing)
$env:YAZI_FILE_ONE="C:\Program Files\Git\usr\bin\file.exe"

## Modules
Import-Module Terminal-Icons
Import-Module PSFzf
Import-Module posh-git

## Custom modules
Import-Module "C:\Users\ville\myfiles\dotfiles\windows\scripts\pwsh\Cut-Paste.psm1"
Set-Alias -Name cut -Value Move-ItemToBuffer
Set-Alias -Name paste -Value Restore-ItemFromBuffer

## Path additions
$env:PATH += ";C:\Users\ville\myfiles\dotfiles\windows\scripts\batch\"
$env:Path += ";C:\Users\ville\myfiles\programs\PROGRAMS_ON_PATH\"
$env:PATH = "$env:USERPROFILE\scoop\shims;$env:PATH"

## PSReadLine options
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -ShowToolTips
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PSReadLineKeyHandler -Chord 'U' -Function Redo -ViMode Command
Set-PSReadLineKeyHandler -Chord 'Ctrl+g' -Function AcceptNextSuggestionWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -Function AcceptSuggestion

## Module options
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r' -PSReadlineChordSetLocation 'Alt+c'


## Custom functions
function Set-PythonPath {
  $env:PYTHONPATH = (Get-Location).Path
  Write-Output "PYTHONPATH set to: $env:PYTHONPATH"
}

function Enter-MegaScriptEnvironment {
  Set-Location "C:\Users\ville\MyMegaScript\"
  Set-PythonPath
  .\venv\Scripts\activate
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

function Update-Profile {
  Add-Type -AssemblyName System.Windows.Forms
  [System.Windows.Forms.SendKeys]::SendWait(". $")
  [System.Windows.Forms.SendKeys]::SendWait("PROFILE")
  [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
}

function Edit-Profile {
  nvim $PROFILE
}

function Edit-Wezterm-Profile {
  nvim "$dotfiles\.wezterm.lua"
}

function Edit-Lazygit-Config {
  nvim "$dotfiles\lazygit-config.yml"
}

function Edit-Git-Config {
  git config --global -e
}

function Start-NvimBugRepro {
  $ConfigPath = "$env:USERPROFILE\myfiles\dotfiles\nvim-config3.0\bug-repro\init.lua"
  if (-not (Test-Path $ConfigPath)) {
    throw "Config file does not exist: $ConfigPath"
  }
  $ConfigDir = Split-Path -Parent $ConfigPath
  Set-Location $ConfigDir
  nvim -u $ConfigPath
}

function Show-TreeList {
  eza --icons -lT $args
}

## Function aliases
Set-Alias -Name spp -Value Set-PythonPath
Set-Alias -Name eme -Value Enter-MegaScriptEnvironment
Set-Alias -Name dsize -Value Get-DirectorySize
Set-Alias -Name cpath -Value Copy-PathToClipboard
Set-Alias -Name rel -Value Update-Profile
Set-Alias -Name cfg -Value Edit-Profile
Set-Alias -Name wzcfg -Value Edit-Wezterm-Profile
Set-Alias -Name lgcfg -Value Edit-Lazygit-Config
Set-Alias -Name gitcfg -Value Edit-Git-Config
Set-Alias -Name zf -Value Invoke-FzfCd
Set-Alias -Name virepro -Value Start-NvimBugRepro
Set-Alias -Name lst -Value Show-TreeList

## Exec aliases
Set-Alias -Name lg -Value lazygit
Set-Alias -Name vi -Value nvim
Set-Alias -Name ex -Value explorer
Set-Alias -Name d -Value dir
Set-Alias -Name wh -Value where.exe
Set-Alias -Name lf -Value yazi


## Location aliases
function ahk {
  Set-Location "C:\Users\ville\myfiles\dotfiles\windows\scripts\autohotkey"
}

function vidata {
  Set-Location "C:\Users\ville\AppData\Local\nvim-data"
}

function vid {
  Set-Location "C:\Users\ville\MyFiles\dotfiles\nvim-config3.0"
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

## Starship
Invoke-Expression (&starship init powershell)

## Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })
