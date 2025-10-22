param(
  [string]$ApkPath = (Join-Path (Get-Location) "app\build\outputs\apk\debug\app-debug.apk"),
  [string]$MobSFUrl = "http://localhost:8000",
  [string]$ApiKey = "",
  [string]$ContainerName = "",
  [string]$OutDir = (Join-Path (Get-Location) "mobsf_reports")
)

function Get-MobSFContainerName {
  param([string]$Requested)
  if ($Requested) { return $Requested }
  try {
    $name = docker ps --filter "ancestor=opensecurity/mobile-security-framework-mobsf" --format "{{.Names}}" 2>$null | Select-Object -First 1
    if ($name) { return $name }
    $list = docker ps --format "{{.Names}} {{.Image}}" 2>$null
    foreach ($line in $list) {
      if ($line -match "mobsf") {
        return ($line -split ' ')[0]
      }
    }
  } catch {}
  return $null
}

function Get-MobSFApiKey {
  param([string]$Provided,[string]$Container)
  if ($Provided) { return $Provided }
  if ($env:MOBSF_API_KEY) { return $env:MOBSF_API_KEY }
  if ($Container) {
    try {
      $logs = docker logs $Container 2>&1
      $m = [regex]::Match($logs, "REST API Key:\s*([a-f0-9]{32,64})", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
      if ($m.Success) { return $m.Groups[1].Value }
    } catch {}
    try {
      $cfgText = docker exec $Container cat /home/mobsf/.MobSF/config.py 2>&1
      $m2 = [regex]::Match($cfgText, "API_KEY\s*=\s*'([0-9a-f]{32,64})", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
      if ($m2.Success) { return $m2.Groups[1].Value }
    } catch {}
  }
  throw "Could not get API Key. Pass -ApiKey or ensure MobSF is running."
}

# Ensure output directory
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Force -Path $OutDir | Out-Null }

# Validate APK
if (-not (Test-Path $ApkPath)) { throw ("APK not found at {0}" -f $ApkPath) }

# Resolve container and API Key
$container = Get-MobSFContainerName -Requested $ContainerName
$apiKey = Get-MobSFApiKey -Provided $ApiKey -Container $container

Write-Host ("Using MobSF at {0}" -f $MobSFUrl) -ForegroundColor Cyan
Write-Host ("API Key: {0}" -f $apiKey) -ForegroundColor DarkGray

# Connectivity check
try {
  $ping = Invoke-WebRequest -Uri ("{0}/" -f $MobSFUrl) -Method Get -TimeoutSec 10
} catch {
  throw ("Cannot reach {0}. Is MobSF running?" -f $MobSFUrl)
}

# Upload APK (multipart/form-data)
Add-Type -AssemblyName System.Net.Http
$client = New-Object System.Net.Http.HttpClient
$client.Timeout = [TimeSpan]::FromMinutes(10)
$client.DefaultRequestHeaders.Add("Authorization",$apiKey)

$content = New-Object System.Net.Http.MultipartFormDataContent
$fileStream = [System.IO.File]::OpenRead($ApkPath)
$streamContent = New-Object System.Net.Http.StreamContent($fileStream)
$streamContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse("application/vnd.android.package-archive")
$fname = [System.IO.Path]::GetFileName($ApkPath)
$content.Add($streamContent, "file", $fname)

Write-Host ("Uploading APK: {0}" -f $fname) -ForegroundColor Cyan
$response = $client.PostAsync(("{0}/api/v1/upload" -f $MobSFUrl), $content).Result
$fileStream.Dispose()
if (-not $response.IsSuccessStatusCode) {
  throw ("Upload failed: {0} {1}" -f $response.StatusCode, $response.Content.ReadAsStringAsync().Result)
}
$uploadJson = $response.Content.ReadAsStringAsync().Result | ConvertFrom-Json
$hash = $uploadJson.hash
Write-Host ("Upload ok. Hash: {0}" -f $hash) -ForegroundColor Green

# Start scan
$headers = @{ Authorization = $apiKey }
$scanBody = @{ scan_type = "apk"; file_name = $uploadJson.file_name; hash = $hash } | ConvertTo-Json
try {
  $scan = Invoke-RestMethod -Uri ("{0}/api/v1/scan" -f $MobSFUrl) -Method Post -Headers $headers -Body $scanBody -ContentType "application/json"
  Write-Host ("Scan started: {0}" -f $scan.message) -ForegroundColor Green
} catch {
  Write-Host "Scan request returned an error; continuing to poll for report..." -ForegroundColor DarkYellow
}

# Poll for JSON report
$reportBody = @{ scan_type = "apk"; hash = $hash } | ConvertTo-Json
$report = $null
for ($i=0; $i -lt 40; $i++) { # ~120s max
  try {
    $report = Invoke-RestMethod -Uri ("{0}/api/v1/report_json" -f $MobSFUrl) -Method Post -Headers $headers -Body $reportBody -ContentType "application/json"
    if ($report) { break }
  } catch {
    Start-Sleep -Seconds 3
  }
}
if (-not $report) { throw "Failed to obtain JSON report after scanning." }

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportPath = Join-Path $OutDir ("MobSF_Report_{0}.json" -f $timestamp)
$report | ConvertTo-Json -Depth 8 | Out-File -FilePath $reportPath -Encoding utf8
Write-Host ("JSON report saved: {0}" -f $reportPath) -ForegroundColor Yellow

# Print summary if available
if ($report.analysis -and $report.analysis.summary) {
  $sev = $report.analysis.summary
  Write-Host "Summary:" -ForegroundColor Cyan
  Write-Host ("- High:   {0}" -f $sev.high)
  Write-Host ("- Medium: {0}" -f $sev.medium)
  Write-Host ("- Low:    {0}" -f $sev.low)
}

return $reportPath