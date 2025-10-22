try {
  docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Ports}}"
} catch {
  Write-Error $_
  exit 1
}