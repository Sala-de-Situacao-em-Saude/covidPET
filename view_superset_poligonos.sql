-- ============================================================
-- VIEW PARA MAPA DE POLÍGONOS NO SUPERSET (Deck.gl Polygon)
-- Junta a geometria dos municípios com os dados COVID
-- ============================================================

-- CTE auxiliar: normaliza nomes removendo acentos via unaccent ou lower/trim
-- e agrega covid_completo (139 municípios) por município
DROP VIEW IF EXISTS superset_poligonos_covid CASCADE;
CREATE OR REPLACE VIEW superset_poligonos_covid AS
WITH covid_agg AS (
    SELECT
        municipio,
        -- Totais acumulados
        SUM(caso)              AS caso,
        SUM(obito)             AS obito,
        -- Médias das taxas e índices
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
        -- Chave normalizada para join
        UPPER(TRIM(municipio)) AS municipio_norm
    FROM covid_completo
    GROUP BY municipio
)
SELECT
    g.municipio_id,
    g.municipio_nome,
    -- Coluna de geometria: obrigatória para Deck.gl Polygon
    g.geometry_json,
    -- Dados COVID agregados (todos os 139 municípios)
    c.caso,
    c.obito,
    c.tx_incid,
    c.tx_mort,
    c.letalidade,
    c.populacao,
    -- Índices socioeconômicos
    c.IDHM,
    c.IDHM_E,
    c.IDHM_R,
    c.IDHM_L,
    c.IVS,
    c.IVS_C,
    c.IVS_R,
    c.IVS_I,
    c.IDSC,
    c.gini,
    c.dens_dem,
    c.PIB,
    -- Coordenadas do centroide
    c.longitude,
    c.latitude
FROM municipios_geojson g
LEFT JOIN covid_agg c
    ON UPPER(TRIM(g.municipio_nome)) = c.municipio_norm;

-- ============================================================
-- View temporal: polígonos com série histórica por semana
-- Útil para filtros de tempo no Superset
-- ============================================================
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
    ON UPPER(TRIM(g.municipio_nome)) = UPPER(TRIM(t.municipio));

-- Verificar resultados
SELECT
    (SELECT COUNT(*) FROM superset_poligonos_covid WHERE geometry_json IS NOT NULL)
        AS poligonos_com_covid,
    (SELECT COUNT(*) FROM superset_poligonos_covid WHERE geometry_json IS NULL OR caso IS NULL)
        AS municipios_sem_match;
