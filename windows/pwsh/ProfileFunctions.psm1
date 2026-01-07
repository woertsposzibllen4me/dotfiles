function Set-PythonPath {
  $env:PYTHONPATH = (Get-Location).Path
  Write-Output "PYTHONPATH set to: $env:PYTHONPATH"
}

function Enter-MegaScriptEnvironment {
  Set-Location $env:STREAMING_REPO_PATH
  Set-PythonPath
  .\.venv\Scripts\activate
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


function Invoke-Yazi {
  # Our yazi invocation with directory changing support
  $tmp = [System.IO.Path]::GetTempFileName()
  yazi $args --cwd-file="$tmp"
  $cwd = Get-Content -Path $tmp -Encoding UTF8
  if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
    Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
  }
  Remove-Item -Path $tmp
}

function Import-StreamingModules {
  if (-not $env:STREAMING_REPO_PATH) {
    throw "STREAMING_REPO_PATH environment variable is not set"
  }

  $obsModule = "$env:STREAMING_REPO_PATH\external\obs\version-control\obs-templater.psm1"
  $streamDeckModule = "$env:STREAMING_REPO_PATH\external\streamdeck\version-control\streamdeck-templater.psm1"

  if (-not (Test-Path $obsModule)) {
    throw "OBS module not found at: $obsModule"
  }

  if (-not (Test-Path $streamDeckModule)) {
    throw "StreamDeck module not found at: $streamDeckModule"
  }

  Import-Module $obsModule -Force -ErrorAction Stop
  Import-Module $streamDeckModule -Force -ErrorAction Stop

  Write-Host "Streaming tools loaded!" -ForegroundColor Green
}
