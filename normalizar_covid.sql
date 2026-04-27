-- Adicionar coluna normalizada na tabela covid_completo para acelerar JOIN
ALTER TABLE covid_completo ADD COLUMN IF NOT EXISTS municipio_norm TEXT;

-- Normalizar todos os nomes (remove acentos e caracteres especiais)
UPDATE covid_completo 
SET municipio_norm = REGEXP_REPLACE(UPPER(TRIM(municipio)), '[^A-Z0-9 ]', '', 'g');

-- Criar índice
CREATE INDEX IF NOT EXISTS idx_covid_municipio_norm ON covid_completo(municipio_norm);

-- Verificar alguns exemplos
SELECT DISTINCT municipio, municipio_norm FROM covid_completo WHERE municipio LIKE 'Abreul%' OR municipio LIKE 'Aguiarn%' OR municipio LIKE 'Alian%' LIMIT 5;

-- Contar quantos municípios únicos temos
SELECT COUNT(DISTINCT municipio_norm) AS municipios_distintos FROM covid_completo;

-- Recriar views com JOIN usando a coluna normalizada
DROP VIEW IF EXISTS superset_poligonos_covid CASCADE;
CREATE OR REPLACE VIEW superset_poligonos_covid AS
WITH covid_agg AS (
    SELECT
        municipio_norm,
        SUM(caso) AS caso,
        SUM(obito) AS obito,
        AVG(tx_incid) AS tx_incid,
        AVG(tx_mort) AS tx_mort,
        AVG(letalidade) AS letalidade,
        MAX(populacao) AS populacao,
        AVG(IDHM) AS IDHM,
        AVG(IDHM_E) AS IDHM_E,
        AVG(IDHM_R) AS IDHM_R,
        AVG(IDHM_L) AS IDHM_L,
        AVG(IVS) AS IVS,
        AVG(IVS_C) AS IVS_C,
        AVG(IVS_R) AS IVS_R,
        AVG(IVS_I) AS IVS_I,
        AVG(IDSC) AS IDSC,
        AVG(gini) AS gini,
        AVG(dens_dem) AS dens_dem,
        AVG(PIB) AS PIB,
        AVG(longitude) AS longitude,
        AVG(latitude) AS latitude
    FROM covid_completo
    GROUP BY municipio_norm
)
SELECT
    g.municipio_id,
    g.municipio_nome,
    g.geometry_json,
    COALESCE(c.caso, 0) AS caso,
    COALESCE(c.obito, 0) AS obito,
    c.tx_incid,
    c.tx_mort,
    c.letalidade,
    c.populacao,
    c.IDHM, c.IDHM_E, c.IDHM_R, c.IDHM_L,
    c.IVS, c.IVS_C, c.IVS_R, c.IVS_I,
    c.IDSC, c.gini, c.dens_dem, c.PIB,
    c.longitude, c.latitude
FROM municipios_geojson g
LEFT JOIN covid_agg c
    ON UPPER(TRIM(g.municipio_nome)) = c.municipio_norm;

DROP VIEW IF EXISTS superset_poligonos_covid_temporal CASCADE;
CREATE OR REPLACE VIEW superset_poligonos_covid_temporal AS
SELECT
    g.municipio_id,
    g.municipio_nome,
    g.geometry_json,
    t.tempo,
    t.ano_semana,
    t.caso,
    t.obito,
    t.tx_incid,
    t.tx_mort,
    t.letalidade,
    t.IDHM,
    t.IVS,
    t.IDSC,
    t.longitude,
    t.latitude
FROM municipios_geojson g
LEFT JOIN covid_completo t
    ON UPPER(TRIM(g.municipio_nome)) = t.municipio_norm;

-- VERIFICAÇÃO FINAL
SELECT 'RESULTADO FINAL:' AS status;
SELECT
    COUNT(*) FILTER (WHERE caso > 0) AS poligonos_com_covid,
    COUNT(*) FILTER (WHERE caso = 0 OR caso IS NULL) AS municipios_sem_match,
    COUNT(*) AS total_poligonos
FROM superset_poligonos_covid;

-- Mostrar exemplo de dados
SELECT municipio_id, municipio_nome, caso, obito, populacao FROM superset_poligonos_covid WHERE caso > 0 LIMIT 5;
