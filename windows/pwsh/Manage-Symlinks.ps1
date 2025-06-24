$dotfilesRepo = "C:\Users\ville\dotfiles"
$dotfilesConfig = @{
  "PowerShell profile" = @{
    "source" = "$dotfilesRepo\windows\pwsh\Microsoft.PowerShell_profile.ps1"
    "target" = "$HOME\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
  }
  "Git config" = @{
    "source" = "$dotfilesRepo\.gitconfig"
    "target" = "$HOME\.gitconfig"
  }
  "Lazygit config" = @{
    "source" = "$dotfilesRepo\lazygit-config.yml"
    "target" = "$HOME\AppData\Local\lazygit\config.yml"
  }
  "VS Code keybinds" = @{
    "source" = "$dotfilesRepo\vscode\keybindings.json"
    "target" = "$HOME\AppData\Roaming\Code\User\keybindings.json"
  }
  "VS Code settings" = @{
    "source" = "$dotfilesRepo\vscode\settings.json"
    "target" = "$HOME\AppData\Roaming\Code\User\settings.json"
  }
  "Wezterm config" = @{
    "source" = "$dotfilesRepo\.wezterm.lua"
    "target" = "$HOME\.wezterm.lua"
  }
  "Nvim config" = @{
    "source"  = "$dotfilesRepo\nvim-config3.0"
    "target" = "$HOME\AppData\Local\nvim\"
  }
  "Starship config" = @{
    "source"  = "$dotfilesRepo\starship.toml"
    "target" = "$HOME\.config\starship.toml"
  }
  "Kanata config" = @{
    "source"  = "$dotfilesRepo\kanata.kbd"
    "target" = "$HOME\AppData\Roaming\kanata\kanata.kbd"
  }
  "Yazi general config" = @{
    "source"  = "$dotfilesRepo\yazi-config\yazi.toml"
    "target" = "$HOME\AppData\Roaming\yazi\config\yazi.toml"
  }
  "Yazi package" = @{
    "source"  = "$dotfilesRepo\yazi-config\package.toml"
    "target" = "$HOME\AppData\Roaming\yazi\config\package.toml"
  }
  "Yazi theme" = @{
    "source"  = "$dotfilesRepo\yazi-config\theme.toml"
    "target" = "$HOME\AppData\Roaming\yazi\config\theme.toml"
  }
  "Yazi keymap" = @{
    "source"  = "$dotfilesRepo\yazi-config\keymap.toml"
    "target" = "$HOME\AppData\Roaming\yazi\config\keymap.toml"
  }
}

# Test if terminal supports emojis by checking encoding and terminal type
function Test-EmojiSupport {
  try {
    # Check if we're in Windows Terminal, VSCode, or other modern terminals
    $terminalProgram = $env:TERM_PROGRAM
    $wtSession = $env:WT_SESSION

    # Also check if console can handle UTF-8
    $canUseEmoji = $false

    if ($wtSession -or $terminalProgram -eq "vscode" -or $terminalProgram -eq "WezTerm") {
      $canUseEmoji = $true
    }

    return $canUseEmoji
  } catch {
    return $false
  }
}

function Get-StatusIcon {
  param([string]$Status)

  $useEmoji = Test-EmojiSupport

  if ($useEmoji) {
    switch ($Status) {
      "OK" {
        return "✅" 
      }
      "LINKED" {
        return "🔗" 
      }
      "FAILED" {
        return "❌" 
      }
      "NOSOURCE" {
        return "❓" 
      }
      default {
        return "❓" 
      }
    }
  } else {
    switch ($Status) {
      "OK" {
        return "[OK]" 
      }
      "LINKED" {
        return "[LINKED]" 
      }
      "FAILED" {
        return "[FAILED]" 
      }
      "NOSOURCE" {
        return "[NOSOURCE]" 
      }
      default {
        return "[?]" 
      }
    }
  }
}

function Sync-Symlinks {
  $emojiSupport = Test-EmojiSupport
  Write-Host "Dotfiles Sync Status (Emoji support: $emojiSupport)" -ForegroundColor Cyan
  Write-Host ( "=" * 50 ) -ForegroundColor Cyan

  foreach ($item in $dotfilesConfig.GetEnumerator()) {
    $source = $item.Value.source
    $target = $item.Value.target
    $name = $item.Key

    if (-not (Test-Path $source)) {
      $icon = Get-StatusIcon "NOSOURCE"
      Write-Host "$icon $name" -ForegroundColor Yellow
      Write-Host "    Source not found: $source" -ForegroundColor DarkYellow
      continue
    }

    $isDirectory = (Get-Item $source) -is [System.IO.DirectoryInfo]

    if (Test-Path $target) {
      # Check if target is already a symlink pointing to our source
      $existingLink = Get-Item $target -ErrorAction SilentlyContinue
      if ($existingLink.LinkType -eq "SymbolicLink" -and $existingLink.Target -eq $source) {
        $icon = Get-StatusIcon "OK"
        Write-Host "$icon link exists for $name" -ForegroundColor Green
        continue
      }

      # Remove existing file/directory
      Remove-Item $target -Force -Recurse
    }

    # Ensure target directory exists
    $targetDir = Split-Path $target -Parent
    if (-not (Test-Path $targetDir)) {
      New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    # Create symlink
    if ($isDirectory) {
      $command = "cmd /c mklink /D `"$target`" `"$source`""
    } else {
      $command = "cmd /c mklink `"$target`" `"$source`""
    }

    $result = Invoke-Expression $command

    if ($LASTEXITCODE -eq 0) {
      $icon = Get-StatusIcon "LINKED"
      Write-Host "$icon linked $name :"
      Write-Host "target $target ->"
      Write-Host "source $source"
    } else {
      $icon = Get-StatusIcon "FAILED"
      Write-Host "$icon failed to link $name :" -ForegroundColor Red
      Write-Host "target $target ->" -ForegroundColor DarkRed
      Write-Host "source $source" -ForegroundColor DarkRed
      Write-Host "Error: $result" -ForegroundColor DarkRed
    }
  }

  Write-Host "`nSync completed!" -ForegroundColor Cyan
}

# Don't run automatically, require explicit execution
Write-Host "To sync dotfiles symlinks, run the Sync-Symlinks function."
