-- Reimportar GeoJSON com nomes corretos
DROP TABLE IF EXISTS municipios_geojson CASCADE;

CREATE TABLE municipios_geojson (
    feature_json TEXT,
    municipio_nome TEXT
);

-- Importar CSV corrigido (substitua o caminho se necessário)
\copy municipios_geojson FROM 'C:/Users/SERVER/Documents/Raphael/Base de dados R/geojson-corrigido.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8');

-- Adicionar colunas estruturadas
ALTER TABLE municipios_geojson ADD COLUMN municipio_id TEXT;
ALTER TABLE municipios_geojson ADD COLUMN geometry_json JSONB;

-- Extrair dados do JSON
UPDATE municipios_geojson 
SET 
    municipio_id = (feature_json::jsonb->'properties'->>'id'),
    geometry_json = (feature_json::jsonb->'geometry');

-- Criar índices
CREATE INDEX idx_municipios_geojson_id ON municipios_geojson(municipio_id);
CREATE INDEX idx_municipios_geojson_nome ON municipios_geojson(municipio_nome);
CREATE INDEX idx_municipios_geojson_geom ON municipios_geojson USING GIN(geometry_json);

-- Verificar importação
SELECT 'IMPORTAÇÃO CONCLUÍDA:' AS status;
SELECT COUNT(*) AS total_municipios FROM municipios_geojson;
SELECT municipio_id, municipio_nome FROM municipios_geojson ORDER BY municipio_id LIMIT 10;

-- Recriar views com JOIN simples (sem normalização!)
DROP VIEW IF EXISTS superset_poligonos_covid CASCADE;
CREATE OR REPLACE VIEW superset_poligonos_covid AS
WITH covid_agg AS (
    SELECT
        municipio,
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
    GROUP BY municipio
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
    ON g.municipio_nome = c.municipio;

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
    ON g.municipio_nome = t.municipio;

-- VERIFICAÇÃO FINAL
SELECT 'RESULTADO FINAL COM NOMES CORRETOS:' AS status;
SELECT
    COUNT(*) FILTER (WHERE caso > 0) AS poligonos_com_covid,
    COUNT(*) FILTER (WHERE caso = 0 OR caso IS NULL) AS municipios_sem_match,
    COUNT(*) AS total_poligonos
FROM superset_poligonos_covid;

-- Mostrar municípios sem match (se houver)
SELECT municipio_nome AS nao_encontrado
FROM municipios_geojson g
WHERE NOT EXISTS (
    SELECT 1 FROM covid_completo c 
    WHERE g.municipio_nome = c.municipio
)
ORDER BY municipio_nome;
