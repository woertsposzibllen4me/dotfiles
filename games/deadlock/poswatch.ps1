# Original script by discord user ProStoKrut
# Edited by Leif

$GameRoot = Get-Location
$Log  = Join-Path $GameRoot 'game\citadel\console.log'
$Out  = Join-Path $GameRoot 'game\citadel\cfg\lastpos.cfg'

$pat = 'setpos_exact ([\s0-9.-]*);'

if (-not (Test-Path $Out)) {
  Set-Content -Path $Out -Value 'setpos 0 0 0' -Encoding Ascii
}

Get-Content -Path $Log -Wait | ForEach-Object {
  $m = [regex]::Match($_, $pat)
  if ($m.Success) {
    $s = $m.Value.Remove(0,12)
    Set-Content -Path $Out -Value ('setpos ' + $s) -Encoding Ascii
  }
}



