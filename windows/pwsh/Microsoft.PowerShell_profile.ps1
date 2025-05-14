# Keep prompt at the bottom of the terminal during startup
$consoleHeight = $host.UI.RawUI.WindowSize.Height
Write-Host ("`n" * $consoleHeight)

## Constants
$claudeApiKey = Get-Content -Path "C:\Users\ville\myfiles\documents\api-keys\Anthropic\loïc-onboarding-api-key.txt" -Raw
$dotfiles = "$env:USERPROFILE\dotfiles"

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
Import-Module "$dotfiles\windows\pwsh\Cut-Paste.psm1"
Set-Alias -Name cut -Value Move-ItemToBuffer
Set-Alias -Name paste -Value Restore-ItemFromBuffer

## Path additions
$env:PATH += "$dotfiles\windows\batch\"
$env:Path += ";C:\Users\ville\myfiles\programs\PROGRAMS_ON_PATH\"
$env:PATH = "$env:USERPROFILE\scoop\shims;$env:PATH"

# Vi mode options
$OnViModeChange = [scriptblock]{
  if ($args[0] -eq 'Command') {
    # Set the cursor to a steady block.
    Write-Host -NoNewLine "`e[0 q"
  } else {
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


## Custom functions
function Set-PythonPath {
  $env:PYTHONPATH = (Get-Location).Path
  Write-Output "PYTHONPATH set to: $env:PYTHONPATH"
}

function Enter-MegaScriptEnvironment {
  Set-Location "$HOME\MyMegaScript\"
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

function Edit-Kanata-Config {
  nvim "$dotfiles\kanata.kbd"
}

function Start-NvimBugRepro {
  $ConfigPath = "$dotfiles\nvim-config3.0\bug-repro\init.lua"
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

function lf {
  $tmp = [System.IO.Path]::GetTempFileName()
  yazi $args --cwd-file="$tmp"
  $cwd = Get-Content -Path $tmp -Encoding UTF8
  if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
    Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
  }
  Remove-Item -Path $tmp
}

function Clear-AndPutPromptAtBottom {
  $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0, 0
  Clear-Host
  $consoleHeight = $host.UI.RawUI.WindowSize.Height
  Write-Host "$([char]27)[${consoleHeight}B" -NoNewline
}

function Hide-Taskbar {
  Start-Process -FilePath "nircmd.exe" -ArgumentList "win trans class Shell_TrayWnd 256" -NoNewWindow
}

function Show-Taskbar {
  Start-Process -FilePath "nircmd.exe" -ArgumentList "win trans class Shell_TrayWnd 255" -NoNewWindow
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
Set-Alias -Name kacfg -Value Edit-Kanata-Config
Set-Alias -Name zf -Value Invoke-FzfCd
Set-Alias -Name virepro -Value Start-NvimBugRepro
Set-Alias -Name lst -Value Show-TreeList
Set-Alias -Name clear -Value Clear-AndPutPromptAtBottom

## Exec aliases
Set-Alias -Name lg -Value lazygit
Set-Alias -Name vi -Value nvim
Set-Alias -Name ex -Value explorer
Set-Alias -Name d -Value dir
Set-Alias -Name wh -Value where.exe
Set-Alias -Name kan -Value kanata


## Location aliases
function ahk {
  Set-Location "$dotfiles\windows\autohotkey"
}

function vidata {
  Set-Location "$HOME\AppData\Local\nvim-data"
}

function vid {
  Set-Location "$dotfiles\nvim-config3.0"
}

function roam {
  Set-Location "$HOME\AppData\Roaming"
}

function loc {
  Set-Location "$HOME\AppData\Local"
}

function dot {
  Set-Location "$dotfiles"
}

function my {
  Set-Location "$HOME\myfiles"
}

## Starship
$global:lastDirectory = (Get-Location).Path

function Invoke-Starship-TransientFunction {
  $currentDirectory = (Get-Location).Path

  # Get time and character modules (always shown)
  $time = &starship module time
  $char = &starship module character

  # If directory has changed, show directory module
  if ($global:lastDirectory -ne $currentDirectory) {
    $dir = &starship module directory
    $global:lastDirectory = $currentDirectory
    return "`n$dir`n$time$char"
  } else {
    # If same directory, only show time and character
    return "$time$char"
  }
}

# Update directory tracking after each command
function Invoke-Starship-PostCommand {
  $global:lastDirectory = (Get-Location).Path
}

Invoke-Expression (&starship init powershell)
Enable-TransientPrompt

# OSC compatible prompt
$prompt = ""
function Invoke-Starship-PreCommand {
  $current_location = $executionContext.SessionState.Path.CurrentLocation
  if ($current_location.Provider.Name -eq "FileSystem") {
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
