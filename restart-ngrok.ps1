# Script pour redémarrer ngrok sur le bon port

Write-Host "Arrêt de ngrok..." -ForegroundColor Yellow
Get-Process -Name ngrok -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "Vérification du serveur sur le port 8000..." -ForegroundColor Cyan
$serverRunning = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue
if (-not $serverRunning) {
    Write-Host "⚠️  Aucun serveur détecté sur le port 8000" -ForegroundColor Yellow
    Write-Host "Démarrage du serveur HTTP..." -ForegroundColor Green
    Start-Job -ScriptBlock {
        Set-Location "$using:PWD"
        python -m http.server 8000
    } | Out-Null
    Start-Sleep -Seconds 2
}

Write-Host "Démarrage de ngrok sur le port 8000..." -ForegroundColor Green
Start-Process ngrok -ArgumentList "http","8000" -WindowStyle Minimized

Start-Sleep -Seconds 3

Write-Host ""
Write-Host "Récupération de l'URL ngrok..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:4040/api/tunnels" -UseBasicParsing
    $json = $response.Content | ConvertFrom-Json
    $tunnel = $json.tunnels | Where-Object { $_.config.addr -like "*8000*" } | Select-Object -First 1
    
    if ($tunnel) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "  ✅ Ngrok est actif !" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "URL publique: " -NoNewline -ForegroundColor White
        Write-Host $tunnel.public_url -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Interface web: http://localhost:4040" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Appuyez sur Ctrl+C pour arrêter" -ForegroundColor Gray
    } else {
        Write-Host "⚠️  Aucun tunnel trouvé sur le port 8000" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur: Impossible de récupérer l'URL ngrok" -ForegroundColor Red
    Write-Host "Essayez d'ouvrir http://localhost:4040 manuellement" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Ngrok fonctionne en arrière-plan." -ForegroundColor Green
Write-Host "Ouvrez http://localhost:4040 pour voir l'interface web" -ForegroundColor Yellow



