# ============================================================
# IMPORTAR POLÍGONOS GEOJSON PARA POSTGRESQL
# Execute na pasta: "Base de dados R"
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " IMPORTAR GEOJSON (POLÍGONOS) PARA POSTGRESQL / SUPERSET  " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ----- Configurações -----
$database = "superset"
$username = "postgres"
$csvFile  = "geojson-1771592215599.csv"
$sqlFile  = "importar_geojson.sql"
$viewFile = "view_superset_poligonos.sql"

# ----- Localizar psql -----
$psqlPath = "C:\Program Files\PostgreSQL\17\bin\psql.exe"
if (-not (Test-Path $psqlPath)) {
    # Tentar versões alternativas
    $versoes = @("17","16","15","14","13","12","11")
    foreach ($v in $versoes) {
        $tentativa = "C:\Program Files\PostgreSQL\$v\bin\psql.exe"
        if (Test-Path $tentativa) { $psqlPath = $tentativa; break }
    }
}
if (-not (Test-Path $psqlPath)) {
    $psqlCmd = Get-Command psql -ErrorAction SilentlyContinue
    if ($psqlCmd) { $psqlPath = $psqlCmd.Source }
    else {
        Write-Host "X psql nao encontrado. Instale o PostgreSQL primeiro." -ForegroundColor Red
        exit 1
    }
}
Write-Host "psql encontrado: $psqlPath" -ForegroundColor Green

# ----- Verificar arquivos necessários -----
foreach ($f in @($csvFile, $sqlFile, $viewFile)) {
    if (-not (Test-Path $f)) {
        Write-Host "X Arquivo nao encontrado: $f" -ForegroundColor Red
        exit 1
    }
}
Write-Host "Arquivos verificados OK" -ForegroundColor Green

# ----- Senha -----
Write-Host ""
$password = Read-Host "Senha do PostgreSQL (usuario '$username')" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
$env:PGPASSWORD = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

Write-Host ""
Write-Host "Importando tabela municipios_geojson..." -ForegroundColor Yellow

# ----- Execução -----
$args = @(
    "-U", $username,
    "-d", $database,
    "-f", $sqlFile,
    "--set=ON_ERROR_STOP=1"
)

& $psqlPath @args
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "X Erro na importacao da tabela GeoJSON." -ForegroundColor Red
    Write-Host "  Verifique se o banco '$database' existe e as credenciais estao corretas." -ForegroundColor Yellow
    $env:PGPASSWORD = ""
    exit 1
}

Write-Host ""
Write-Host "Criando view superset_poligonos_covid..." -ForegroundColor Yellow

& $psqlPath @("-U", $username, "-d", $database, "-f", $viewFile, "--set=ON_ERROR_STOP=1")
if ($LASTEXITCODE -ne 0) {
    Write-Host "X Erro ao criar a view." -ForegroundColor Red
    $env:PGPASSWORD = ""
    exit 1
}

$env:PGPASSWORD = ""

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host " CONCLUIDO COM SUCESSO!                                    " -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Proximos passos no Superset:" -ForegroundColor Cyan
Write-Host "  1. Va em Datasets > + Dataset"
Write-Host "  2. Selecione o banco '$database'"
Write-Host "  3. Selecione a view 'superset_poligonos_covid'"
Write-Host "  4. Crie um grafico do tipo 'Deck.gl Polygon'"
Write-Host "  5. Configure:"
Write-Host "       Geometry Column : geometry_json"
Write-Host "       Metric          : SUM(caso) ou tx_incid"
Write-Host "       Tooltip         : municipio_nome, caso, tx_incid, IDHM, IVS"
Write-Host ""
