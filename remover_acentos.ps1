# Remover acentos do CSV GeoJSON

$inputFile  = "geojson-1771592215599.csv"
$outputFile = "geojson-sem-acentos.csv"

Write-Host "Processando arquivo..." -ForegroundColor Yellow

# Ler arquivo
$texto = [System.IO.File]::ReadAllText($inputFile, [System.Text.Encoding]::UTF8)

# Normalizar - remover diacriticos usando .NET
$normalizado = $texto.Normalize([System.Text.NormalizationForm]::FormD)
$semAcentos = New-Object System.Text.StringBuilder

foreach ($char in $normalizado.ToCharArray()) {
    $categoria = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($char)
    if ($categoria -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
        [void]$semAcentos.Append($char)
    }
}

$resultado = $semAcentos.ToString().Normalize([System.Text.NormalizationForm]::FormC)

# Salvar
[System.IO.File]::WriteAllText($outputFile, $resultado, [System.Text.Encoding]::UTF8)

Write-Host "Arquivo criado: $outputFile" -ForegroundColor Green
Write-Host ""

# Importar
Write-Host "Importando para PostgreSQL..." -ForegroundColor Yellow

$env:PGPASSWORD = Read-Host "Senha PostgreSQL" -AsSecureString | ConvertFrom-SecureString -AsPlainText

& "C:\Program Files\PostgreSQL\13\bin\psql.exe" -U postgres -d superset -f reimportar_geojson_sem_acentos.sql

$env:PGPASSWORD = ""

Write-Host "Concluido!" -ForegroundColor Green
