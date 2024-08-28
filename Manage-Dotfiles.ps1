# File: Manage-Dotfiles.ps1

$dotfilesRepo = "C:\Users\ville\myfiles\dotfiles"
$dotfilesConfig = @{
  "PowerShell Profile" = @{
    "source" = "$dotfilesRepo\Microsoft.PowerShell_profile.ps1"
    "target" = "$HOME\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
  }
  "Git Config" = @{
    "source" = "$dotfilesRepo\.gitconfig"
    "target" = "$HOME\.gitconfig"
  }
  # Add more configurations as needed
}

function Sync-Dotfiles {
  foreach ($item in $dotfilesConfig.GetEnumerator()) {
    $source = $item.Value.source
    $target = $item.Value.target

    if (-not (Test-Path $source)) {
      Write-Host "Source file not found: $source. Skipping."
      continue
    }

    if (Test-Path $target) {
      if (-not (Test-Path "$target.backup")) {
        Copy-Item $target "$target.backup"
        Write-Host "Backup created: $target.backup"
      }

      # Check if target is already a symlink pointing to our source
      $existingLink = Get-Item $target -ErrorAction SilentlyContinue
      if ($existingLink.LinkType -eq "SymbolicLink" -and $existingLink.Target -eq $source) {
        Write-Host "Symlink already exists and is correct for $($item.Key). Skipping."
        continue
      }

      Remove-Item $target -Force
    }

    cmd /c mklink $target $source
    if ($LASTEXITCODE -eq 0) {
      Write-Host "Linked $($item.Key): $target -> $source"
    } else {
      Write-Host "Failed to link $($item.Key): $target -> $source"
      if (Test-Path "$target.backup") {
        Copy-Item "$target.backup" $target
        Write-Host "Restored from backup: $target"
      }
    }
  }
}

# Don't run automatically, require explicit execution
Write-Host "To sync dotfiles, run the Sync-Dotfiles function."
