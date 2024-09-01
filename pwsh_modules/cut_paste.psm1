# Create a script-level variable to store the moved item path
$script:BufferPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "PowerShellBuffer"

# Ensure buffer directory exists
if (-not (Test-Path $script:BufferPath)) {
  New-Item -Path $script:BufferPath -ItemType Directory | Out-Null
}

function Move-ItemToBuffer {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$Path
  )

  if (Test-Path $Path) {
    $item = Get-Item $Path
    $destination = Join-Path -Path $script:BufferPath -ChildPath $item.Name
    Move-Item -Path $Path -Destination $destination
    $script:MovedItem = $destination
    Write-Host "Moved $Path to temp Buffer: $script:BufferPath"
  } else {
    Write-Error "Path not found: $Path"
  }
}

function Restore-ItemFromBuffer {
  [CmdletBinding()]
  param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$Destination = "."
  )
  
  # Resolve '.' to the current directory
  $resolvedDestination = if ($Destination -eq ".") {
    Get-Location 
  } else {
    Resolve-Path $Destination -ErrorAction SilentlyContinue
  }

  if ($null -eq $resolvedDestination) {
    Write-Error "Invalid destination path: $Destination"
    return
  }

  if ($null -ne $script:MovedItem -and (Test-Path $script:MovedItem)) {
    $destinationPath = Join-Path -Path $resolvedDestination -ChildPath (Get-Item $script:MovedItem).Name
    if (Test-Path $destinationPath) {
      Write-Error "A file or directory with the same name already exists at the destination."
    } else {
      Move-Item -Path $script:MovedItem -Destination $destinationPath
      Write-Host "Item restored to: $destinationPath"
      $script:MovedItem = $null
    }
  } else {
    Write-Error "No item in buffer or buffer item not found. Use Move-ItemToBuffer first."
  }
}

# Create an alias 'paste' for Restore-ItemFromBuffer
Set-Alias -Name paste -Value Restore-ItemFromBuffer




# Example usage
# Move-ItemToBuffer "C:\path\to\your\file.txt"
# Set-Location "C:\new\destination"
# Restore-ItemFromBuffer

Export-ModuleMember -Function Move-ItemToBuffer, Restore-ItemFromBuffer

