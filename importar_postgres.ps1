# SCRIPT PARA IMPORTAR DADOS COVID-19 PARA POSTGRESQL
# Execute este script no PowerShell

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "IMPORTAR DADOS COVID-19 PARA POSTGRESQL (SUPERSET)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Configuracoes
$psqlPath = "C:\Program Files\PostgreSQL\12\bin\psql.exe"
$database = "superset"
$username = "postgres"
$sqlFile = "importar_dados.sql"

# Verificar se psql existe
if (-not (Test-Path $psqlPath)) {
    Write-Host "X psql.exe nao encontrado em: $psqlPath" -ForegroundColor Red
    Write-Host "Tentando localizar automaticamente..." -ForegroundColor Yellow
    
    $psqlCmd = Get-Command psql -ErrorAction SilentlyContinue
    if ($psqlCmd) {
        $psqlPath = $psqlCmd.Source
        Write-Host "Encontrado em: $psqlPath" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "X psql nao encontrado. Instale o PostgreSQL primeiro." -ForegroundColor Red
        Write-Host ""
        exit 1
    }
}

# Verificar se arquivo SQL existe
if (-not (Test-Path $sqlFile)) {
    Write-Host "X Arquivo $sqlFile nao encontrado" -ForegroundColor Red
    Write-Host "Execute este script na pasta correta" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "Configuracao:" -ForegroundColor Yellow
Write-Host "  Database: $database"
Write-Host "  Usuario: $username"
Write-Host "  SQL File: $sqlFile"
Write-Host ""

# Solicitar senha
$password = Read-Host "Digite a senha do PostgreSQL (usuario $username)" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

Write-Host ""
Write-Host "Conectando ao PostgreSQL..." -ForegroundColor Yellow

# Definir variavel de ambiente com senha
$env:PGPASSWORD = $plainPassword

# Executar importacao
try {
    Write-Host "Executando script SQL..." -ForegroundColor Yellow
    Write-Host ""
    
    & $psqlPath -U $username -d $database -f $sqlFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "============================================================" -ForegroundColor Green
        Write-Host "SUCESSO! DADOS IMPORTADOS" -ForegroundColor Green
        Write-Host "============================================================" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "Tabelas criadas no banco superset:" -ForegroundColor Cyan
        Write-Host "  - covid_completo"
        Write-Host "  - covid_temporal"
        Write-Host "  - covid_municipio"
        Write-Host "  - covid_resumo"
        Write-Host ""
        
        Write-Host "Proximos passos no Superset:" -ForegroundColor Yellow
        Write-Host "  1. Abra o Superset"
        Write-Host "  2. Va em: Data -> Databases"
        Write-Host "  3. Selecione superset (PostgreSQL)"
        Write-Host "  4. As tabelas ja estarao disponiveis!"
        Write-Host "  5. Crie datasets e dashboards"
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "X Erro na importacao. Verifique as mensagens acima." -ForegroundColor Red
        Write-Host ""
    }
} catch {
    Write-Host ""
    Write-Host "X Erro ao executar psql: $_" -ForegroundColor Red
    Write-Host ""
} finally {
    # Limpar senha da memoria
    $env:PGPASSWORD = $null
}

Write-Host "Pressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
