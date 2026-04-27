-- Criar tabela municipios_geojson no banco superset
-- Importar dados do CSV corrigido

\c superset

-- Drop se existir
DROP TABLE IF EXISTS municipios_geojson CASCADE;

-- Criar tabela
CREATE TABLE municipios_geojson (
    feature_json TEXT,
    municipio_nome TEXT
);

-- Importar CSV (path absoluto para Windows)
\copy municipios_geojson(feature_json, municipio_nome) FROM 'C:/Users/SERVER/Documents/Raphael/Base de dados R/geojson-corrigido.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8');

-- Adicionar colunas
ALTER TABLE municipios_geojson ADD COLUMN municipio_id TEXT;
ALTER TABLE municipios_geojson ADD COLUMN geometry_json JSONB;

-- Extrair ID e geometry do feature JSON
UPDATE municipios_geojson 
SET 
    municipio_id = feature_json::jsonb->'properties'->>'id',
    geometry_json = feature_json::jsonb->'geometry';

-- Verificar
SELECT 
    COUNT(*) as total_municipios,
    COUNT(geometry_json) as com_geometria
FROM municipios_geojson;

-- Exemplo
SELECT municipio_nome, LEFT(geometry_json::text, 80) as geo_sample
FROM municipios_geojson LIMIT 3;
