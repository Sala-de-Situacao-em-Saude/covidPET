-- Corrigir view para retornar Feature completo (não apenas geometry)

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
        AVG(idhm) AS idhm,
        AVG(idhm_e) AS idhm_e,
        AVG(idhm_r) AS idhm_r,
        AVG(idhm_l) AS idhm_l,
        AVG(ivs) AS ivs,
        AVG(ivs_c) AS ivs_c,
        AVG(ivs_r) AS ivs_r,
        AVG(ivs_i) AS ivs_i,
        AVG(idsc) AS idsc,
        AVG(gini) AS gini,
        AVG(dens_dem) AS dens_dem,
        AVG(pib) AS pib,
        AVG(longitude) AS longitude,
        AVG(latitude) AS latitude
    FROM covid_completo
    GROUP BY municipio
)
SELECT 
    g.municipio_id,
    g.municipio_nome,
    -- RETORNAR FEATURE COMPLETO
    g.feature_json::text AS geometry_json,
    COALESCE(c.caso, 0) AS caso,
    COALESCE(c.obito, 0) AS obito,
    c.tx_incid,
    c.tx_mort,
    c.letalidade,
    c.populacao,
    c.idhm,
    c.idhm_e,
    c.idhm_r,
    c.idhm_l,
    c.ivs,
    c.ivs_c,
    c.ivs_r,
    c.ivs_i,
    c.idsc,
    c.gini,
    c.dens_dem,
    c.pib,
    c.longitude,
    c.latitude
FROM municipios_geojson g
LEFT JOIN covid_agg c ON g.municipio_nome = c.municipio;

-- Verificar formato
SELECT 
    municipio_nome,
    LEFT(geometry_json, 100) AS feature_preview,
    caso
FROM superset_poligonos_covid
LIMIT 2;
