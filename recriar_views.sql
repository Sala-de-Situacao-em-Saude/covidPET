-- ============================================================
-- RECRIAR VIEWS COM JOIN SEM ACENTOS
-- Ambos os lados do JOIN usam nomes normalizados (sem acentos)
-- Execute: psql -U postgres -d superset -f recriar_views.sql
-- ============================================================

-- Função auxiliar para remover acentos via unaccent (se disponível)
-- Se unaccent não estiver instalado, usamos TRANSLATE
CREATE OR REPLACE FUNCTION remover_acentos(texto TEXT) 
RETURNS TEXT AS $$
BEGIN
    RETURN TRANSLATE(
        UPPER(TRIM(texto)),
        'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇÑáàãâäéèêëíìîïóòõôöúùûüçñ',
        'AAAAAEEEEIIIIOOOOOÚUUUCNAAAAAEEEEIIIIOOOOOÚUUUCN'
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- View principal: dados agregados de todos os municípios
DROP VIEW IF EXISTS superset_poligonos_covid CASCADE;
CREATE OR REPLACE VIEW superset_poligonos_covid AS
WITH covid_agg AS (
    SELECT
        municipio,
        SUM(caso)              AS caso,
        SUM(obito)             AS obito,
        AVG(tx_incid)          AS tx_incid,
        AVG(tx_mort)           AS tx_mort,
        AVG(letalidade)        AS letalidade,
        MAX(populacao)         AS populacao,
        AVG(IDHM)              AS IDHM,
        AVG(IDHM_E)            AS IDHM_E,
        AVG(IDHM_R)            AS IDHM_R,
        AVG(IDHM_L)            AS IDHM_L,
        AVG(IVS)               AS IVS,
        AVG(IVS_C)             AS IVS_C,
        AVG(IVS_R)             AS IVS_R,
        AVG(IVS_I)             AS IVS_I,
        AVG(IDSC)              AS IDSC,
        AVG(gini)              AS gini,
        AVG(dens_dem)          AS dens_dem,
        AVG(PIB)               AS PIB,
        AVG(longitude)         AS longitude,
        AVG(latitude)          AS latitude,
        remover_acentos(municipio) AS municipio_norm
    FROM covid_completo
    GROUP BY municipio
)
SELECT
    g.municipio_id,
    g.municipio_nome,
    g.geometry_json,
    c.caso,
    c.obito,
    c.tx_incid,
    c.tx_mort,
    c.letalidade,
    c.populacao,
    c.IDHM, c.IDHM_E, c.IDHM_R, c.IDHM_L,
    c.IVS,  c.IVS_C,  c.IVS_R,  c.IVS_I,
    c.IDSC, c.gini, c.dens_dem, c.PIB,
    c.longitude, c.latitude
FROM municipios_geojson g
LEFT JOIN covid_agg c
    ON remover_acentos(g.municipio_nome) = c.municipio_norm;

-- View temporal: polígonos com série por semana epidemiológica
DROP VIEW IF EXISTS superset_poligonos_covid_temporal;
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
    ON remover_acentos(g.municipio_nome) = remover_acentos(t.municipio);

-- ============================================================
-- VERIFICAÇÃO DE MATCHES
-- ============================================================
SELECT
    (SELECT COUNT(*) FROM superset_poligonos_covid
     WHERE geometry_json IS NOT NULL AND caso IS NOT NULL)  AS poligonos_com_covid,
    (SELECT COUNT(*) FROM superset_poligonos_covid
     WHERE geometry_json IS NOT NULL AND caso IS NULL)      AS municipios_sem_match,
    (SELECT COUNT(*) FROM superset_poligonos_covid)         AS total_poligonos;

-- Listar os sem match (para diagnóstico)
SELECT municipio_nome AS sem_match_geojson
FROM superset_poligonos_covid
WHERE caso IS NULL
ORDER BY municipio_nome;
