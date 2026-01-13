# PREPARAÇÃO DE DADOS PARA SUPERSET
# PAINEL COVID-19 TOCANTINS

# Limpar ambiente
rm(list = ls())

# Definir diretório
setwd("c:/Users/SERVER/Documents/Raphael/Base de dados R")

# Carregar as bases
base_gam <- readRDS("base_gam.rds")
base_gam2 <- readRDS("base_gam2.rds")

# Verificar se existe variável de gênero em alguma base
cat("\n=== VERIFICANDO VARIÁVEIS RELACIONADAS A GÊNERO ===\n")
cat("Colunas base_gam:\n")
print(names(base_gam))
cat("\nColunas base_gam2:\n")
print(names(base_gam2))

# Buscar variáveis que contenham 'sexo', 'genero', 'masculino', 'feminino'
genero_cols <- grep("sexo|genero|masculino|feminino|sex|gender", 
                     names(base_gam2), 
                     ignore.case = TRUE, 
                     value = TRUE)
cat("\n=== Variáveis relacionadas a gênero encontradas: ===\n")
print(genero_cols)

# ============================================================
# PREPARAR DADOS AGREGADOS PARA O SUPERSET
# ============================================================

# 1. Dados agregados por período (série temporal)
dados_temporal <- aggregate(
  cbind(caso, obito, tx_incid, tx_mort, letalidade) ~ ano_semana + tempo,
  data = base_gam2,
  FUN = sum,
  na.rm = TRUE
)

# Ordenar por tempo
dados_temporal <- dados_temporal[order(dados_temporal$tempo), ]

cat("\n=== DADOS TEMPORAIS ===\n")
head(dados_temporal, 10)
cat("\nTotal de períodos:", nrow(dados_temporal), "\n")

# 2. Dados por município (mais recente)
dados_municipio <- base_gam2[base_gam2$tempo == max(base_gam2$tempo, na.rm = TRUE), ]

cat("\n=== DADOS POR MUNICÍPIO (PERÍODO MAIS RECENTE) ===\n")
cat("Total de municípios:", nrow(dados_municipio), "\n")
head(dados_municipio[, c("municipio", "caso", "obito", "tx_incid", "letalidade", "IDHM", "IVS", "IDSC")])

# 3. Resumo geral (indicadores totais)
resumo_geral <- data.frame(
  total_casos = sum(base_gam2$caso, na.rm = TRUE),
  total_obitos = sum(base_gam2$obito, na.rm = TRUE),
  incidencia_media = mean(base_gam2$tx_incid, na.rm = TRUE),
  letalidade_media = mean(base_gam2$letalidade, na.rm = TRUE),
  idhm_medio = mean(base_gam2$IDHM, na.rm = TRUE),
  ivs_medio = mean(base_gam2$IVS, na.rm = TRUE),
  idsc_medio = mean(base_gam2$IDSC, na.rm = TRUE)
)

cat("\n=== RESUMO GERAL ===\n")
print(resumo_geral)

# 4. Dados completos para análises detalhadas
# Selecionar colunas relevantes
colunas_superset <- c(
  "tempo", "ano_semana", "municipio", "nome_regiao", "Populacao",
  "caso", "obito", "tx_incid", "tx_mort", "letalidade",
  "IDHM", "IDHM_E", "IDHM_R", "IDHM_L",
  "IVS", "IVS_C", "IVS_R", "IVS_I",
  "IDSC", "IDSC_3", "gini",
  "dens_dem", "PIB", "TOE", "TMI", "TxL",
  "longitude", "latitude"
)

# Verificar se existe percentual_vacinados e percentual_idosos
if("percentual_vacinados" %in% names(base_gam2)) {
  colunas_superset <- c(colunas_superset, "percentual_vacinados", "percentual_idosos")
}

dados_completos <- base_gam2[, colunas_superset]

# ============================================================
# EXPORTAR DADOS PARA CSV (FORMATO SUPERSET)
# ============================================================

cat("\n=== EXPORTANDO DADOS ===\n")

# Exportar dados temporais
write.csv(dados_temporal, 
          "covid_temporal.csv", 
          row.names = FALSE, 
          fileEncoding = "UTF-8")
cat("✓ Exportado: covid_temporal.csv\n")

# Exportar dados por município
write.csv(dados_municipio, 
          "covid_municipio.csv", 
          row.names = FALSE, 
          fileEncoding = "UTF-8")
cat("✓ Exportado: covid_municipio.csv\n")

# Exportar resumo geral
write.csv(resumo_geral, 
          "covid_resumo.csv", 
          row.names = FALSE, 
          fileEncoding = "UTF-8")
cat("✓ Exportado: covid_resumo.csv\n")

# Exportar dados completos
write.csv(dados_completos, 
          "covid_completo.csv", 
          row.names = FALSE, 
          fileEncoding = "UTF-8")
cat("✓ Exportado: covid_completo.csv\n")

# ============================================================
# ESTATÍSTICAS FINAIS
# ============================================================

cat("\n=== ESTATÍSTICAS DOS ARQUIVOS EXPORTADOS ===\n")
cat("1. covid_temporal.csv:", nrow(dados_temporal), "linhas\n")
cat("2. covid_municipio.csv:", nrow(dados_municipio), "linhas\n")
cat("3. covid_resumo.csv: 1 linha (resumo geral)\n")
cat("4. covid_completo.csv:", nrow(dados_completos), "linhas\n")

cat("\n=== PREPARAÇÃO CONCLUÍDA ===\n")
cat("Os arquivos CSV estão prontos para importação no Apache Superset!\n")
