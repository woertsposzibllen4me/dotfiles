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


function Sync-Symlinks {
  foreach ($item in $dotfilesConfig.GetEnumerator()) {
    $source = $item.Value.source
    $target = $item.Value.target

    if (-not (Test-Path $source)) {
      Write-Host "Source not found: $source. Skipping."
      continue
    }

    $isDirectory = (Get-Item $source) -is [System.IO.DirectoryInfo]

    if (Test-Path $target) {
      # Check if target is already a symlink pointing to our source
      $existingLink = Get-Item $target -ErrorAction SilentlyContinue
      if ($existingLink.LinkType -eq "SymbolicLink" -and $existingLink.Target -eq $source) {
        Write-Host "Symlink already exists and is correct for $($item.Key). Skipping."
        continue
      }
      Remove-Item $target -Force -Recurse
    }

    if ($isDirectory) {
      $command = "cmd /c mklink /D `"$target`" `"$source`""
    } else {
      $command = "cmd /c mklink `"$target`" `"$source`""
    }

    $result = Invoke-Expression $command
    if ($LASTEXITCODE -eq 0) {
      Write-Host "Linked $($item.Key): $target -> $source"
    } else {
      Write-Host "Failed to link $($item.Key): $target -> $source"
      Write-Host "Error: $result"
    }
  }
}

# Don't run automatically, require explicit execution
Write-Host "To sync dotfiles symlinks, run the Sync-Symlinks function."
