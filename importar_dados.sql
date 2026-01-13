-- IMPORTAR DADOS COVID-19 PARA POSTGRESQL VIA PSQL
-- Script SQL para importar CSVs no PostgreSQL

-- ============================================================
-- 1. CRIAR TABELA COVID_COMPLETO
-- ============================================================

DROP TABLE IF EXISTS covid_completo CASCADE;

CREATE TABLE covid_completo (
    tempo INTEGER,
    ano_semana VARCHAR(10),
    municipio VARCHAR(100),
    nome_regiao VARCHAR(100),
    Populacao NUMERIC,
    caso INTEGER,
    tx_incid NUMERIC,
    obito INTEGER,
    tx_mort NUMERIC,
    letalidade NUMERIC,
    IDSC NUMERIC,
    IDSC_3 NUMERIC,
    gini NUMERIC,
    IVS NUMERIC,
    IVS_C NUMERIC,
    IVS_R NUMERIC,
    IVS_I NUMERIC,
    IDHM NUMERIC,
    IDHM_E NUMERIC,
    IDHM_R NUMERIC,
    IDHM_L NUMERIC,
    dens_dem NUMERIC,
    PIB NUMERIC,
    TOE NUMERIC,
    TMI NUMERIC,
    TxL NUMERIC,
    percentual_vacinados NUMERIC,
    percentual_idosos NUMERIC,
    longitude NUMERIC,
    latitude NUMERIC
);

-- Importar dados
COPY covid_completo FROM 'C:\Users\SERVER\Documents\Raphael\Base de dados R\covid_completo.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- Criar índices
CREATE INDEX idx_covid_completo_tempo ON covid_completo(tempo);
CREATE INDEX idx_covid_completo_municipio ON covid_completo(municipio);
CREATE INDEX idx_covid_completo_ano_semana ON covid_completo(ano_semana);

-- ============================================================
-- 2. CRIAR TABELA COVID_TEMPORAL
-- ============================================================

DROP TABLE IF EXISTS covid_temporal CASCADE;

CREATE TABLE covid_temporal (
    ano_semana VARCHAR(10),
    tempo INTEGER,
    caso INTEGER,
    obito INTEGER,
    tx_incid NUMERIC,
    tx_mort NUMERIC,
    letalidade NUMERIC
);

-- Importar dados
COPY covid_temporal FROM 'C:\Users\SERVER\Documents\Raphael\Base de dados R\covid_temporal.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- Criar índices
CREATE INDEX idx_covid_temporal_tempo ON covid_temporal(tempo);
CREATE INDEX idx_covid_temporal_ano_semana ON covid_temporal(ano_semana);

-- ============================================================
-- 3. CRIAR TABELA COVID_MUNICIPIO
-- ============================================================

DROP TABLE IF EXISTS covid_municipio CASCADE;

CREATE TABLE covid_municipio (
    tempo INTEGER,
    municipioibge VARCHAR(20),
    municipio VARCHAR(100),
    nome_regiao VARCHAR(100),
    Populacao NUMERIC,
    caso INTEGER,
    tx_incid NUMERIC,
    obito INTEGER,
    tx_mort NUMERIC,
    letalidade NUMERIC,
    IDSC NUMERIC,
    IDSC_3 NUMERIC,
    gini NUMERIC,
    IVS NUMERIC,
    IVS_C NUMERIC,
    IVS_R NUMERIC,
    IVS_I NUMERIC,
    IDHM NUMERIC,
    IDHM_E NUMERIC,
    IDHM_R NUMERIC,
    IDHM_L NUMERIC,
    dens_dem NUMERIC,
    PIB NUMERIC,
    TOE NUMERIC,
    TMI NUMERIC,
    TxL NUMERIC,
    percentual_vacinados NUMERIC,
    percentual_idosos NUMERIC,
    longitude NUMERIC,
    latitude NUMERIC,
    ano_semana VARCHAR(10),
    tx_incid_padronizada NUMERIC,
    tx_mort_padronizada NUMERIC,
    obitos_esperados NUMERIC
);

-- Importar dados
COPY covid_municipio FROM 'C:\Users\SERVER\Documents\Raphael\Base de dados R\covid_municipio.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- Criar índices
CREATE INDEX idx_covid_municipio_municipio ON covid_municipio(municipio);
CREATE INDEX idx_covid_municipio_municipioibge ON covid_municipio(municipioibge);

-- ============================================================
-- 4. CRIAR TABELA COVID_RESUMO
-- ============================================================

DROP TABLE IF EXISTS covid_resumo CASCADE;

CREATE TABLE covid_resumo (
    total_casos INTEGER,
    total_obitos INTEGER,
    incidencia_media NUMERIC,
    letalidade_media NUMERIC,
    idhm_medio NUMERIC,
    ivs_medio NUMERIC,
    idsc_medio NUMERIC
);

# Importar dados
COPY covid_resumo FROM 'C:\Users\SERVER\Documents\Raphael\Base de dados R\covid_resumo.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

# ============================================================
# VERIFICAÇÕES
# ============================================================

# Contar registros
SELECT 'covid_completo' as tabela, COUNT(*) as registros FROM covid_completo
UNION ALL
SELECT 'covid_temporal', COUNT(*) FROM covid_temporal
UNION ALL
SELECT 'covid_municipio', COUNT(*) FROM covid_municipio
UNION ALL
SELECT 'covid_resumo', COUNT(*) FROM covid_resumo;

# Exemplo de consulta - Top 5 municípios
SELECT 
    municipio,
    SUM(caso) as total_casos,
    SUM(obito) as total_obitos
FROM covid_completo
GROUP BY municipio
ORDER BY total_casos DESC
LIMIT 5;
