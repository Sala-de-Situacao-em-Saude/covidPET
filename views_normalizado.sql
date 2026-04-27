-- Funcao robusta para remover acentos (ambos os lados)
CREATE OR REPLACE FUNCTION normalizar_municipio(texto TEXT) 
RETURNS TEXT AS $$
DECLARE
    resultado TEXT;
BEGIN
    resultado := UPPER(TRIM(texto));
    -- Remover acentos manualmente
    resultado := REPLACE(resultado, 'Á', 'A');
    resultado := REPLACE(resultado, 'À', 'A');
    resultado := REPLACE(resultado, 'Ã', 'A');
    resultado := REPLACE(resultado, 'Â', 'A');
    resultado := REPLACE(resultado, 'É', 'E');
    resultado := REPLACE(resultado, 'Ê', 'E');
    resultado := REPLACE(resultado, 'Í', 'I');
    resultado := REPLACE(resultado, 'Ó', 'O');
    resultado := REPLACE(resultado, 'Ô', 'O');
    resultado := REPLACE(resultado, 'Õ', 'O');
    resultado := REPLACE(resultado, 'Ú', 'U');
    resultado := REPLACE(resultado, 'Ç', 'C');
    RETURN resultado;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Recriar view principal
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
        AVG(latitude) AS latitude,
        normalizar_municipio(municipio) AS municipio_norm
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
    ON normalizar_municipio(g.municipio_nome) = c.municipio_norm;

-- View temporal
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
    ON normalizar_municipio(g.municipio_nome) = normalizar_municipio(t.municipio);

-- Verificacao com detalhes
SELECT
    COUNT(*) FILTER (WHERE caso > 0) AS poligonos_com_covid,
    COUNT(*) FILTER (WHERE caso = 0 OR caso IS NULL) AS municipios_sem_match,
    COUNT(*) AS total_poligonos
FROM superset_poligonos_covid;

-- Listar municipios sem match para debug
SELECT g.municipio_nome AS geojson_nome, c.municipio AS covid_nome
FROM municipios_geojson g
LEFT JOIN (
    SELECT DISTINCT municipio, normalizar_municipio(municipio) AS norm
    FROM covid_completo
) c ON normalizar_municipio(g.municipio_nome) = c.norm
WHERE c.municipio IS NULL
ORDER BY g.municipio_nome
LIMIT 20;
