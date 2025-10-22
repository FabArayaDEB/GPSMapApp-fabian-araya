param([string]$ReportPath)
if (-not (Test-Path $ReportPath)) { Write-Error "No existe el archivo: $ReportPath"; exit 1 }
try {
  $json = Get-Content -Raw $ReportPath | ConvertFrom-Json
} catch {
  Write-Error "No se pudo leer JSON: $($_.Exception.Message)"; exit 1 }
if ($json.analysis -and $json.analysis.summary) {
  Write-Output ("high={0}" -f $json.analysis.summary.high)
  Write-Output ("medium={0}" -f $json.analysis.summary.medium)
  Write-Output ("low={0}" -f $json.analysis.summary.low)
} else {
  Write-Output "no_summary"
}