param([string]$ReportPath, [int]$MaxDepth = 3)
if (-not (Test-Path $ReportPath)) { Write-Error "No existe el archivo: $ReportPath"; exit 1 }
try {
  $json = Get-Content -Raw $ReportPath | ConvertFrom-Json
} catch {
  Write-Error "No se pudo leer JSON: $($_.Exception.Message)"; exit 1 }
function Show-Keys($obj, [string]$prefix, [int]$depth) {
  if ($depth -gt $MaxDepth) { return }
  if ($null -eq $obj) { return }
  # Si es un array, inspeccionar el primer elemento
  if ($obj -is [System.Collections.IEnumerable] -and -not ($obj -is [string])) {
    $arr = @($obj)
    Write-Output "$prefix[] (count=$($arr.Count))"
    if ($arr.Count -gt 0) {
      Show-Keys -obj $arr[0] -prefix "$prefix[0]." -depth ($depth + 1)
    }
    return
  }
  $props = Get-Member -InputObject $obj -MemberType NoteProperty | Select-Object -ExpandProperty Name
  foreach ($p in $props) {
    Write-Output "$prefix$p"
    $val = $obj.$p
    if ($val -is [System.Management.Automation.PSCustomObject]) {
      Show-Keys -obj $val -prefix "$prefix$p." -depth ($depth + 1)
    } elseif ($val -is [System.Collections.IEnumerable] -and -not ($val -is [string])) {
      $enum = @($val)
      Write-Output "$prefix$p[] (count=$($enum.Count))"
      if ($enum.Count -gt 0) {
        $first = $enum[0]
        if ($first -is [System.Management.Automation.PSCustomObject]) {
          Show-Keys -obj $first -prefix "$prefix$p[0]." -depth ($depth + 1)
        }
      }
    }
  }
}
Show-Keys -obj $json -prefix "" -depth 1