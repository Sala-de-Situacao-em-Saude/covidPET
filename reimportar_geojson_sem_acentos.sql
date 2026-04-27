-- ============================================================
-- REIMPORTAR GEOJSON SEM ACENTOS
-- Dropa tabela anterior e recria com dados normalizados
-- ============================================================

-- 1. Dropar tabela antiga
DROP TABLE IF EXISTS municipios_geojson CASCADE;

-- 2. Criar tabela temporária para CSV bruto
DROP TABLE IF EXISTS municipios_geojson_raw CASCADE;
CREATE TABLE municipios_geojson_raw (
    feature_json_raw TEXT,
    municipio_nome_raw TEXT
);

-- 3. Importar CSV sem acentos
\copy municipios_geojson_raw(feature_json_raw, municipio_nome_raw) FROM 'geojson-sem-acentos.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8');

-- 4. Criar tabela definitiva
CREATE TABLE municipios_geojson (
    id            SERIAL PRIMARY KEY,
    municipio_id  VARCHAR(20),
    municipio_nome VARCHAR(120),
    geometry_json  TEXT,
    feature_json   JSONB
);

-- 5. Inserir dados extraindo do JSON
INSERT INTO municipios_geojson (municipio_id, municipio_nome, geometry_json, feature_json)
SELECT
    (feature_json_raw::jsonb) -> 'properties' ->> 'id'    AS municipio_id,
    municipio_nome_raw                                     AS municipio_nome,
    ((feature_json_raw::jsonb) -> 'geometry')::text       AS geometry_json,
    feature_json_raw::jsonb                                AS feature_json
FROM municipios_geojson_raw;

-- 6. Limpar
DROP TABLE municipios_geojson_raw;

-- 7. Índices
CREATE INDEX idx_mun_geojson_id   ON municipios_geojson(municipio_id);
CREATE INDEX idx_mun_geojson_nome ON municipios_geojson(municipio_nome);

-- 8. Verificar
SELECT COUNT(*) AS total_municipios FROM municipios_geojson;

SELECT municipio_id, municipio_nome
FROM municipios_geojson
ORDER BY municipio_nome
LIMIT 20;
