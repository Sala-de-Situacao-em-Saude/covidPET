CREATE OR REPLACE FUNCTION limpar_nome(texto TEXT) 
RETURNS TEXT AS $$
DECLARE
    resultado TEXT;
BEGIN
    resultado := UPPER(TRIM(texto));
    resultado := REGEXP_REPLACE(resultado, '[^A-Z0-9 ]', '', 'g');
    resultado := REGEXP_REPLACE(resultado, '\s+', ' ', 'g');
    RETURN TRIM(resultado);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

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
        limpar_nome(municipio) AS municipio_norm
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
    ON limpar_nome(g.municipio_nome) = c.municipio_norm;

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
    ON limpar_nome(g.municipio_nome) = limpar_nome(t.municipio);

SELECT
    COUNT(*) FILTER (WHERE caso > 0) AS poligonos_com_covid,
    COUNT(*) FILTER (WHERE caso = 0) AS municipios_sem_match,
    COUNT(*) AS total_poligonos
FROM superset_poligonos_covid;

SELECT municipio_nome AS geojson_sem_match, limpar_nome(municipio_nome) AS limpo
FROM municipios_geojson g
WHERE NOT EXISTS (
    SELECT 1 FROM covid_completo c 
    WHERE limpar_nome(g.municipio_nome) = limpar_nome(c.municipio)
)
ORDER BY municipio_nome
LIMIT 10;
