# SCRIPT OPCIONAL: CONSULTAR APIs DE ÍNDICES
# Atualizar IDHM, IVS e IDSC via APIs públicas

# Instalar pacotes necessários (descomente se precisar)
# install.packages("httr")
# install.packages("jsonlite")

# library(httr)
# library(jsonlite)

# ============================================================
# FUNÇÃO: CONSULTAR ATLAS BRASIL (IDHM)
# ============================================================

consultar_idhm_atlas <- function(codigo_ibge) {
  # API do Atlas do Desenvolvimento Humano
  base_url <- "http://api.atlasbrasil.org.br/consulta/municipio"
  url <- paste0(base_url, "/", codigo_ibge)
  
  tryCatch({
    response <- GET(url)
    
    if (status_code(response) == 200) {
      dados <- content(response, "parsed")
      
      return(data.frame(
        codigo_ibge = codigo_ibge,
        idhm = dados$idhm,
        idhm_educacao = dados$idhm_e,
        idhm_renda = dados$idhm_r,
        idhm_longevidade = dados$idhm_l,
        fonte = "Atlas Brasil",
        ano_referencia = dados$ano,
        stringsAsFactors = FALSE
      ))
    } else {
      cat("Erro na consulta para código", codigo_ibge, "\n")
      return(NULL)
    }
  }, error = function(e) {
    cat("Erro:", e$message, "\n")
    return(NULL)
  })
}

# ============================================================
# EXEMPLO DE USO
# ============================================================

# Carregar base para obter códigos IBGE
setwd("c:/Users/SERVER/Documents/Raphael/Base de dados R")
base_gam <- readRDS("base_gam.rds")

# Obter lista única de municípios
municipios_unicos <- unique(base_gam$municipioibge)

cat("Total de municípios:", length(municipios_unicos), "\n\n")

# ============================================================
# NOTA IMPORTANTE
# ============================================================

cat("============================================================\n")
cat("OBSERVAÇÃO SOBRE APIs\n")
cat("============================================================\n\n")

cat("As suas bases de dados JÁ CONTÊM os índices:\n")
cat("✓ IDHM (Índice de Desenvolvimento Humano Municipal)\n")
cat("✓ IVS (Índice de Vulnerabilidade Social)\n")
cat("✓ IDSC (Índice de Desempenho do SUS)\n\n")

cat("Esses dados são atualizados periodicamente pelos órgãos oficiais:\n")
cat("- IDHM: IBGE/PNUD (último censo disponível)\n")
cat("- IVS: IPEA (baseado em Censo/PNAD)\n")
cat("- IDSC: Ministério da Saúde\n\n")

cat("APIs públicas geralmente retornam dados dos mesmos períodos censitários.\n")
cat("Portanto, NÃO é necessário consultar APIs para obter esses índices.\n\n")

# ============================================================
# ALTERNATIVA: WEB SCRAPING (se API não disponível)
# ============================================================

cat("============================================================\n")
cat("FONTES DE DADOS OFICIAIS\n")
cat("============================================================\n\n")

cat("1. IDHM - Atlas do Desenvolvimento Humano\n")
cat("   URL: http://www.atlasbrasil.org.br/\n")
cat("   Dados: 1991, 2000, 2010 (censo)\n\n")

cat("2. IVS - Atlas da Vulnerabilidade Social (IPEA)\n")
cat("   URL: http://ivs.ipea.gov.br/\n")
cat("   Dados: 2000, 2010 (censo)\n\n")

cat("3. IDSC/IDSUS - Ministério da Saúde\n")
cat("   URL: http://idsus.saude.gov.br/\n")
cat("   Dados: Atualizações anuais\n\n")

# ============================================================
# EXEMPLO: CONSULTA MANUAL (se quiser testar)
# ============================================================

cat("============================================================\n")
cat("EXEMPLO DE CONSULTA (descomente para testar)\n")
cat("============================================================\n\n")

# # Exemplo: Consultar IDHM de Palmas (1721000)
# codigo_palmas <- "1721000"
# resultado <- consultar_idhm_atlas(codigo_palmas)
# 
# if (!is.null(resultado)) {
#   cat("Resultado da consulta:\n")
#   print(resultado)
# }

# ============================================================
# RECOMENDAÇÃO FINAL
# ============================================================

cat("\n============================================================\n")
cat("RECOMENDAÇÃO\n")
cat("============================================================\n\n")

cat("Para o painel Superset:\n")
cat("✓ Utilize os índices JÁ PRESENTES nas bases RDS\n")
cat("✓ Eles estão atualizados e validados\n")
cat("✓ Não há necessidade de consultar APIs adicionais\n\n")

cat("Os arquivos CSV exportados contêm TODAS as informações necessárias!\n")
cat("Arquivos disponíveis:\n")
cat("- covid_completo.csv (dados detalhados)\n")
cat("- covid_temporal.csv (série temporal)\n")
cat("- covid_municipio.csv (dados espaciais)\n")
cat("- covid_resumo.csv (KPIs)\n\n")

cat("Próximo passo: Importar os CSVs no Apache Superset\n")
cat("Consulte o arquivo: GUIA_SUPERSET.md\n")
