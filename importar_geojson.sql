-- ============================================================
-- IMPORTAR POLÍGONOS GEOJSON DOS MUNICÍPIOS DO TOCANTINS
-- Para uso no Mapa de Polígonos (Deck.gl Polygon) do Superset
-- ============================================================

-- 1. Criar tabela temporária para receber o CSV bruto
DROP TABLE IF EXISTS municipios_geojson_raw CASCADE;
CREATE TABLE municipios_geojson_raw (
    feature_json_raw TEXT,
    municipio_nome_raw TEXT
);

-- 2. Importar CSV (separador ; conforme o arquivo geojson-1771592215599.csv)
\copy municipios_geojson_raw(feature_json_raw, municipio_nome_raw) FROM 'geojson-1771592215599.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8');

-- 3. Criar tabela definitiva com campos extraídos do JSON
DROP TABLE IF EXISTS municipios_geojson CASCADE;
CREATE TABLE municipios_geojson (
    id            SERIAL PRIMARY KEY,
    municipio_id  VARCHAR(20),       -- Código IBGE (ex: "1700251")
    municipio_nome VARCHAR(120),     -- Nome correto decodificado do JSON
    geometry_json  TEXT,             -- GeoJSON somente da geometria → usado no Deck.gl Polygon
    feature_json   JSONB             -- Feature GeoJSON completo (uso avançado)
);

-- 4. Inserir dados extraindo campos via JSONB
INSERT INTO municipios_geojson (municipio_id, municipio_nome, geometry_json, feature_json)
SELECT
    (feature_json_raw::jsonb) -> 'properties' ->> 'id'                AS municipio_id,
    (feature_json_raw::jsonb) -> 'properties' ->> 'name'              AS municipio_nome,
    ((feature_json_raw::jsonb) -> 'geometry')::text                   AS geometry_json,
    feature_json_raw::jsonb                                            AS feature_json
FROM municipios_geojson_raw;

-- 5. Remover tabela temporária
DROP TABLE IF EXISTS municipios_geojson_raw;

-- 6. Índices para performance
CREATE INDEX idx_mun_geojson_id   ON municipios_geojson(municipio_id);
CREATE INDEX idx_mun_geojson_nome ON municipios_geojson(municipio_nome);

-- 7. Verificação
SELECT 
    COUNT(*)           AS total_municipios,
    COUNT(geometry_json) AS com_geometria,
    COUNT(municipio_id)  AS com_codigo_ibge
FROM municipios_geojson;

SELECT municipio_id, municipio_nome
FROM municipios_geojson
ORDER BY municipio_nome
LIMIT 10;
