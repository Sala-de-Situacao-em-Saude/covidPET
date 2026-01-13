# IMPORTAR DADOS COVID-19 PARA POSTGRESQL (SUPERSET)

# Instalar pacotes necessários (descomente se precisar)
# install.packages("RPostgres")
# install.packages("DBI")

library(DBI)
library(RPostgres)

# ============================================================
# CONFIGURAÇÃO DA CONEXÃO POSTGRESQL
# ============================================================

cat("\n=== TENTANDO CONECTAR AO POSTGRESQL ===\n")

# Configurações de conexão
# Ajuste conforme sua instalação do Superset
config <- list(
  host = "localhost",      # ou "127.0.0.1"
  port = 5432,            # porta padrão PostgreSQL
  dbname = "superset",    # banco de dados
  user = "postgres",      # usuário padrão
  password = ""           # AJUSTE AQUI
)

cat("\nConfiguração:\n")
cat("Host:", config$host, "\n")
cat("Porta:", config$port, "\n")
cat("Database:", config$dbname, "\n")
cat("Usuário:", config$user, "\n\n")

# Tentar conexão
tryCatch({
  con <- dbConnect(
    RPostgres::Postgres(),
    host = config$host,
    port = config$port,
    dbname = config$dbname,
    user = config$user,
    password = config$password
  )
  
  cat("✓ CONEXÃO ESTABELECIDA COM SUCESSO!\n\n")
  
  # ============================================================
  # CARREGAR ARQUIVOS CSV
  # ============================================================
  
  setwd("c:/Users/SERVER/Documents/Raphael/Base de dados R")
  
  cat("=== CARREGANDO ARQUIVOS CSV ===\n")
  
  covid_completo <- read.csv("covid_completo.csv", stringsAsFactors = FALSE)
  covid_temporal <- read.csv("covid_temporal.csv", stringsAsFactors = FALSE)
  covid_municipio <- read.csv("covid_municipio.csv", stringsAsFactors = FALSE)
  covid_resumo <- read.csv("covid_resumo.csv", stringsAsFactors = FALSE)
  
  cat("✓ covid_completo.csv:", nrow(covid_completo), "linhas\n")
  cat("✓ covid_temporal.csv:", nrow(covid_temporal), "linhas\n")
  cat("✓ covid_municipio.csv:", nrow(covid_municipio), "linhas\n")
  cat("✓ covid_resumo.csv:", nrow(covid_resumo), "linhas\n\n")
  
  # ============================================================
  # IMPORTAR DADOS PARA POSTGRESQL
  # ============================================================
  
  cat("=== IMPORTANDO PARA POSTGRESQL ===\n\n")
  
  # 1. Tabela completa
  cat("1. Importando covid_completo...\n")
  dbWriteTable(con, "covid_completo", covid_completo, overwrite = TRUE, row.names = FALSE)
  cat("   ✓ Tabela 'covid_completo' criada com", nrow(covid_completo), "registros\n\n")
  
  # 2. Tabela temporal
  cat("2. Importando covid_temporal...\n")
  dbWriteTable(con, "covid_temporal", covid_temporal, overwrite = TRUE, row.names = FALSE)
  cat("   ✓ Tabela 'covid_temporal' criada com", nrow(covid_temporal), "registros\n\n")
  
  # 3. Tabela município
  cat("3. Importando covid_municipio...\n")
  dbWriteTable(con, "covid_municipio", covid_municipio, overwrite = TRUE, row.names = FALSE)
  cat("   ✓ Tabela 'covid_municipio' criada com", nrow(covid_municipio), "registros\n\n")
  
  # 4. Tabela resumo
  cat("4. Importando covid_resumo...\n")
  dbWriteTable(con, "covid_resumo", covid_resumo, overwrite = TRUE, row.names = FALSE)
  cat("   ✓ Tabela 'covid_resumo' criada com", nrow(covid_resumo), "registros\n\n")
  
  # ============================================================
  # VERIFICAR TABELAS CRIADAS
  # ============================================================
  
  cat("=== VERIFICANDO TABELAS NO BANCO ===\n")
  tabelas <- dbListTables(con)
  cat("Tabelas disponíveis no banco 'superset':\n")
  print(tabelas[grep("covid", tabelas)])
  
  # ============================================================
  # CRIAR ÍNDICES PARA MELHOR PERFORMANCE
  # ============================================================
  
  cat("\n=== CRIANDO ÍNDICES ===\n")
  
  # Índice na tabela completa
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_covid_completo_tempo ON covid_completo(tempo)")
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_covid_completo_municipio ON covid_completo(municipio)")
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_covid_completo_ano_semana ON covid_completo(ano_semana)")
  cat("✓ Índices criados em covid_completo\n")
  
  # Índice na tabela temporal
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_covid_temporal_tempo ON covid_temporal(tempo)")
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_covid_temporal_ano_semana ON covid_temporal(ano_semana)")
  cat("✓ Índices criados em covid_temporal\n")
  
  # Índice na tabela município
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_covid_municipio_municipio ON covid_municipio(municipio)")
  cat("✓ Índices criados em covid_municipio\n\n")
  
  # ============================================================
  # ESTATÍSTICAS DAS TABELAS
  # ============================================================
  
  cat("=== ESTATÍSTICAS FINAIS ===\n")
  
  result <- dbGetQuery(con, "SELECT COUNT(*) as total FROM covid_completo")
  cat("• covid_completo:", result$total, "registros\n")
  
  result <- dbGetQuery(con, "SELECT COUNT(*) as total FROM covid_temporal")
  cat("• covid_temporal:", result$total, "registros\n")
  
  result <- dbGetQuery(con, "SELECT COUNT(*) as total FROM covid_municipio")
  cat("• covid_municipio:", result$total, "registros\n")
  
  result <- dbGetQuery(con, "SELECT COUNT(*) as total FROM covid_resumo")
  cat("• covid_resumo:", result$total, "registros\n\n")
  
  # Exemplo de consulta
  cat("=== EXEMPLO DE CONSULTA ===\n")
  resultado <- dbGetQuery(con, "
    SELECT 
      municipio,
      SUM(caso) as total_casos,
      SUM(obito) as total_obitos
    FROM covid_completo
    GROUP BY municipio
    ORDER BY total_casos DESC
    LIMIT 5
  ")
  
  cat("\nTop 5 municípios com mais casos:\n")
  print(resultado)
  
  # Fechar conexão
  dbDisconnect(con)
  cat("\n✓ Conexão encerrada\n")
  
  cat("\n============================================================\n")
  cat("SUCESSO!\n")
  cat("============================================================\n\n")
  cat("As 4 tabelas foram importadas para o PostgreSQL!\n")
  cat("Agora no Superset:\n")
  cat("1. Vá em: Data → Databases\n")
  cat("2. Selecione o database 'superset' (PostgreSQL)\n")
  cat("3. As tabelas já estarão disponíveis:\n")
  cat("   - covid_completo\n")
  cat("   - covid_temporal\n")
  cat("   - covid_municipio\n")
  cat("   - covid_resumo\n\n")
  cat("Você pode criar datasets e dashboards diretamente!\n")
  
}, error = function(e) {
  cat("\n✗ ERRO NA CONEXÃO\n")
  cat("Mensagem:", e$message, "\n\n")
  
  cat("============================================================\n")
  cat("POSSÍVEIS SOLUÇÕES\n")
  cat("============================================================\n\n")
  
  cat("1. VERIFICAR SE O POSTGRESQL ESTÁ RODANDO\n")
  cat("   No PowerShell:\n")
  cat("   Get-Service -Name postgresql*\n\n")
  
  cat("2. AJUSTAR A SENHA\n")
  cat("   Edite a linha 'password' no script com a senha correta\n\n")
  
  cat("3. VERIFICAR PORTA\n")
  cat("   A porta padrão é 5432. Verifique se está correta.\n\n")
  
  cat("4. INSTALAR PACOTE RPostgres\n")
  cat("   No R: install.packages('RPostgres')\n\n")
  
  cat("5. USAR OUTRO MÉTODO\n")
  cat("   - Upload manual dos CSVs no Superset (Data → Upload CSV)\n")
  cat("   - Usar psql (linha de comando PostgreSQL)\n\n")
})
