# Script para configurar Mapbox token no Superset Docker

# 1. Identificar o container do Superset APP
Write-Host "Containers Superset rodando:" -ForegroundColor Green
docker ps | Select-String "superset"

# 2. Entrar no container superset_app (ajuste o nome se necessário)
Write-Host "`nPara entrar no container, execute:" -ForegroundColor Yellow
Write-Host "docker exec -it superset_app bash" -ForegroundColor Cyan

# 3. Dentro do container, editar o arquivo de configuração
Write-Host "`nDentro do container, execute:" -ForegroundColor Yellow
Write-Host "echo ""MAPBOX_API_KEY = 'COLE_SEU_MAPBOX_TOKEN_AQUI'"" >> /app/pythonpath/superset_config.py" -ForegroundColor Cyan

# 4. Reiniciar o container
Write-Host "`nDepois reinicie o container:" -ForegroundColor Yellow
Write-Host "docker restart superset_app" -ForegroundColor Cyan
