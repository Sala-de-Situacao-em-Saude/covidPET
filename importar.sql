-- IMPORTAR DADOS COVID-19 PARA POSTGRESQL

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

\copy covid_completo FROM 'covid_completo.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

CREATE INDEX idx_covid_completo_tempo ON covid_completo(tempo);
CREATE INDEX idx_covid_completo_municipio ON covid_completo(municipio);

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

\copy covid_temporal FROM 'covid_temporal.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

CREATE INDEX idx_covid_temporal_tempo ON covid_temporal(tempo);

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

\copy covid_municipio FROM 'covid_municipio.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

CREATE INDEX idx_covid_municipio_municipio ON covid_municipio(municipio);

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

\copy covid_resumo FROM 'covid_resumo.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

SELECT 'IMPORTACAO CONCLUIDA!' as status;
SELECT 'covid_completo' as tabela, COUNT(*) as registros FROM covid_completo
UNION ALL SELECT 'covid_temporal', COUNT(*) FROM covid_temporal
UNION ALL SELECT 'covid_municipio', COUNT(*) FROM covid_municipio
UNION ALL SELECT 'covid_resumo', COUNT(*) FROM covid_resumo;
