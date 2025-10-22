param([string]$ReportPath)
if (-not (Test-Path $ReportPath)) { Write-Error "No existe el archivo: $ReportPath"; exit 1 }
try { $raw = Get-Content -Raw $ReportPath } catch { Write-Error "No se pudo leer archivo: $($_.Exception.Message)"; exit 1 }
try { $json = $raw | ConvertFrom-Json } catch { Write-Error "Error ConvertFrom-Json: $($_.Exception.Message)"; Write-Output "RAW LENGTH: $($raw.Length)"; exit 1 }
Write-Output "TYPE: $($json.GetType().FullName)"
if ($json -is [System.Collections.IEnumerable] -and -not ($json -is [string])) {
  $arr = @($json)
  Write-Output "COUNT: $($arr.Count)"
}