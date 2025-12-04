# Script pour lancer le serveur HTTP et ngrok

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Démarrage du serveur HTTP et ngrok" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Démarrer le serveur HTTP Python en arrière-plan
Write-Host "Démarrage du serveur HTTP sur le port 8000..." -ForegroundColor Green
$serverJob = Start-Job -ScriptBlock {
    Set-Location "$using:PWD"
    python -m http.server 8000
}

# Attendre un peu pour que le serveur démarre
Start-Sleep -Seconds 2

Write-Host "✓ Serveur HTTP démarré sur http://localhost:8000" -ForegroundColor Green
Write-Host ""
Write-Host "Démarrage de ngrok..." -ForegroundColor Green
Write-Host ""
Write-Host "Une fois ngrok démarré, vous verrez l'URL publique ici." -ForegroundColor Yellow
Write-Host "Vous pouvez aussi consulter http://localhost:4040 pour l'interface ngrok" -ForegroundColor Yellow
Write-Host ""
Write-Host "Appuyez sur Ctrl+C pour arrêter ngrok et le serveur" -ForegroundColor Yellow
Write-Host ""

# Lancer ngrok (cela va bloquer jusqu'à Ctrl+C)
try {
    ngrok http 8000
} finally {
    # Nettoyer le job du serveur quand ngrok se ferme
    Write-Host ""
    Write-Host "Arrêt du serveur HTTP..." -ForegroundColor Yellow
    Stop-Job $serverJob -ErrorAction SilentlyContinue
    Remove-Job $serverJob -ErrorAction SilentlyContinue
    Write-Host "✓ Serveur arrêté" -ForegroundColor Green
}
