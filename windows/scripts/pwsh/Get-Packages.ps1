# Create a script to collect package information from different package managers
$inventoryFile = "$env:USERPROFILE\myfiles\dotfiles\windows\docs\package-inventory.md"
$directory = [System.IO.Path]::GetDirectoryName($inventoryFile)
if (!(Test-Path -Path $directory)) {
  New-Item -ItemType Directory -Path $directory -Force | Out-Null
}

# Header for the file with timestamp
$timestamp = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
"# Package Inventory - $timestamp" | Out-File $inventoryFile

# Scoop packages in code block
"## Scoop Packages" | Out-File $inventoryFile -Append
try {
  $scoopOutput = $(scoop list)
  if ($scoopOutput) {
    "``````" | Out-File $inventoryFile -Append
    $scoopOutput | Out-File $inventoryFile -Append
    "``````" | Out-File $inventoryFile -Append
  } else {
    "No Scoop packages found." | Out-File $inventoryFile -Append
  }
} catch {
  "Failed to get Scoop packages: $($_.Exception.Message)" | Out-File $inventoryFile -Append
}

# Chocolatey packages in code block with better column alignment
"" | Out-File $inventoryFile -Append
"## Chocolatey Packages" | Out-File $inventoryFile -Append
try {
  # Get Chocolatey version first
  $chocoVersion = $(choco --version)
  # Get the raw list
  $chocoOutput = $(choco list)

  if ($chocoOutput) {
    # Create a formatted list with proper alignment
    "``````" | Out-File $inventoryFile -Append
    "Chocolatey v$chocoVersion" | Out-File $inventoryFile -Append

    # Define column headers
    $nameHeader = "Name"
    $versionHeader = "Version"
    $nameWidth = 40  # Adjust as needed for your package names

    # Print the header row
    "{0,-$nameWidth} {1}" -f $nameHeader, $versionHeader | Out-File $inventoryFile -Append
    "{0,-$nameWidth} {1}" -f ("-" * $nameHeader.Length), ("-" * $versionHeader.Length) | Out-File $inventoryFile -Append

    # Process each package line
    foreach ($line in $chocoOutput) {
      # Skip the promotional lines and other non-package lines
      if ($line -match '^(\S+)\s+(.+)$' -and 
        $line -notmatch '^Chocolatey' -and 
        $line -notmatch 'packages installed' -and
        $line -notmatch 'Did you know' -and
        $line -notmatch 'Features\?' -and
        $line -notmatch 'chocolatey\.org') {

        # Extract name and version
        $packageInfo = $line -split "\s+", 2
        if ($packageInfo.Count -eq 2) {
          $name = $packageInfo[0]
          $version = $packageInfo[1]
          # Format with proper column alignment
          "{0,-$nameWidth} {1}" -f $name, $version | Out-File $inventoryFile -Append
        } else {
          # Just output the line as-is if it doesn't match our pattern
          $line | Out-File $inventoryFile -Append
        }
      }
    }

    # Add the packages count at the end
    $packageCountLine = $chocoOutput | Where-Object { $_ -match 'packages installed' } | Select-Object -First 1
    if ($packageCountLine) {
      "" | Out-File $inventoryFile -Append
      $packageCountLine | Out-File $inventoryFile -Append
    }

    "``````" | Out-File $inventoryFile -Append
  } else {
    "No Chocolatey packages found." | Out-File $inventoryFile -Append
  }
} catch {
  "Failed to get Chocolatey packages: $($_.Exception.Message)" | Out-File $inventoryFile -Append
}

# MSYS2 packages
"" | Out-File $inventoryFile -Append
"## MSYS2 Packages" | Out-File $inventoryFile -Append
"*MSYS2 packages must be checked manually with 'pacman -Qe'*" | Out-File $inventoryFile -Append

Write-Host "Inventory saved to $inventoryFile"

