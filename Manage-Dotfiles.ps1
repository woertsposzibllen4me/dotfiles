# File: Manage-Dotfiles.ps1
$dotfilesRepo = "C:\Users\ville\myfiles\dotfiles"
$dotfilesConfig = @{

  "PowerShell profile" = @{
    "source" = "$dotfilesRepo\Microsoft.PowerShell_profile.ps1"
    "target" = "$HOME\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
  }

  "Git config" = @{
    "source" = "$dotfilesRepo\.gitconfig"
    "target" = "$HOME\.gitconfig"
  }

  "Lazygit config" = @{
    "source" = "$dotfilesRepo\lazygit_config.yml"
    "target" = "C:\Users\ville\AppData\Local\lazygit\config.yml"
  }

  "VS Code keybinds" = @{
    "source" = "$dotfilesRepo\vscode\keybindings.json"
    "target" = "C:\Users\ville\AppData\Roaming\Code\User\keybindings.json"
  }

  "VS Code settings" = @{
    "source" = "$dotfilesRepo\vscode\settings.json"
    "target" = "C:\Users\ville\AppData\Roaming\Code\User\settings.json"
  }

  "Wezterm config" = @{
    "source" = "$dotfilesRepo\.wezterm.lua"
    "target" = "C:\Users\ville\.wezterm.lua"
  }

  "Autohotkey scripts dir" = @{
    "source" = "$dotfilesRepo\scripts\autohotkey\"
    "target" = "C:\Users\ville\myfiles\scripts\autohotkey\"
  }
  # Add more configurations as needed
}

function Sync-Dotfiles {
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
Write-Host "To sync dotfiles, run the Sync-Dotfiles function."
