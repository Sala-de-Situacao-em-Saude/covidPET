# PROJETO: PERFIL EPIDEMIOLÓGICO DA COVID-19 NO ESTADO DO TOCANTINS
# A INFLUÊNCIA DA SITUAÇÃO SOCIOECONÔMICA E DA QUALIDADE DA ATENÇÃO À SAÚDE

# Limpar ambiente
rm(list = ls())

# Definir diretório de trabalho
setwd("c:/Users/SERVER/Documents/Raphael/Base de dados R")

# Carregar as bases de dados
base_gam <- readRDS("base_gam.rds")
base_gam2 <- readRDS("base_gam2.rds")

# Visualizar estrutura das bases
cat("\n=== Estrutura da base_gam ===\n")
str(base_gam)
cat("\n=== Dimensões:", dim(base_gam)[1], "linhas x", dim(base_gam)[2], "colunas ===\n")

cat("\n=== Estrutura da base_gam2 ===\n")
str(base_gam2)
cat("\n=== Dimensões:", dim(base_gam2)[1], "linhas x", dim(base_gam2)[2], "colunas ===\n")

# Ver primeiras linhas
cat("\n=== Primeiras linhas da base_gam ===\n")
head(base_gam)

cat("\n=== Primeiras linhas da base_gam2 ===\n")
head(base_gam2)

# Ver resumo estatístico
cat("\n=== Resumo da base_gam ===\n")
summary(base_gam)

cat("\n=== Resumo da base_gam2 ===\n")
summary(base_gam2)
