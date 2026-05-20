-- Opção B: adiciona municipioibge em covid_completo e reescreve as views
-- Banco: postgresql://integra:***@10.48.75.21:5432/data_lake
-- Execute via psql ou Superset SQL Lab

-- 0. Extensão para normalização de acentos
CREATE EXTENSION IF NOT EXISTS unaccent;

-- 1. Adicionar coluna
ALTER TABLE covid_completo ADD COLUMN IF NOT EXISTS municipioibge VARCHAR(20);

-- 2. Habilitar UPDATE em tabelas com replicação lógica sem PK
--    FULL é necessário pois não há PK nem índice único na tabela
ALTER TABLE public.covid_completo REPLICA IDENTITY FULL;
ALTER TABLE covid_tocantins.covid_completo REPLICA IDENTITY FULL;

-- 3. Popular a partir de covid_municipio (join por nome)
UPDATE covid_completo cc
SET municipioibge = cm.municipioibge
FROM (
    SELECT DISTINCT ON (UPPER(TRIM(municipio))) municipioibge, municipio
    FROM covid_municipio
) cm
WHERE UPPER(TRIM(cc.municipio)) = UPPER(TRIM(cm.municipio));

-- 4. Índice
CREATE INDEX IF NOT EXISTS idx_covid_completo_ibge ON covid_completo(municipioibge);

-- 5. Verificar resultado
SELECT
    COUNT(*)                                        AS total_registros,
    COUNT(municipioibge)                            AS com_codigo,
    COUNT(*) FILTER (WHERE municipioibge IS NULL)   AS sem_codigo
FROM covid_completo;

-- ─── Reescrever views usando código IBGE (sem normalização de nome) ────────────

DROP VIEW IF EXISTS superset_poligonos_covid_temporal;
DROP VIEW IF EXISTS superset_poligonos_covid;

CREATE OR REPLACE VIEW superset_poligonos_covid AS
WITH covid_agg AS (
    SELECT
        unaccent(UPPER(TRIM(municipio))) AS municipio_norm,
        SUM(caso)        AS caso,
        SUM(obito)       AS obito,
        AVG(tx_incid)    AS tx_incid,
        AVG(tx_mort)     AS tx_mort,
        AVG(letalidade)  AS letalidade,
        MAX(populacao)   AS populacao,
        AVG(IDHM)        AS idhm,
        AVG(IDHM_E)      AS idhm_e,
        AVG(IDHM_R)      AS idhm_r,
        AVG(IDHM_L)      AS idhm_l,
        AVG(IVS)         AS ivs,
        AVG(IVS_C)       AS ivs_c,
        AVG(IVS_R)       AS ivs_r,
        AVG(IVS_I)       AS ivs_i,
        AVG(IDSC)        AS idsc,
        AVG(gini)        AS gini,
        AVG(dens_dem)    AS dens_dem,
        AVG(PIB)         AS pib,
        AVG(longitude)   AS longitude,
        AVG(latitude)    AS latitude
    FROM covid_completo
    GROUP BY unaccent(UPPER(TRIM(municipio)))
)
SELECT
    g.municipio_id,
    g.municipio_nome,
    (g.geometry_json::jsonb->'coordinates'->0)::text AS geometry_json,
    COALESCE(c.caso, 0)  AS caso,
    COALESCE(c.obito, 0) AS obito,
    c.tx_incid,
    c.tx_mort,
    c.letalidade,
    c.populacao,
    c.idhm, c.idhm_e, c.idhm_r, c.idhm_l,
    c.ivs,  c.ivs_c,  c.ivs_r,  c.ivs_i,
    c.idsc, c.gini, c.dens_dem, c.pib,
    c.longitude, c.latitude
FROM municipios_geojson g
LEFT JOIN covid_agg c
    ON unaccent(UPPER(TRIM(g.municipio_nome))) = c.municipio_norm
    OR (unaccent(UPPER(TRIM(g.municipio_nome))) = 'TABOCAO'
        AND c.municipio_norm = 'FORTALEZA DO TABOCAO');

CREATE OR REPLACE VIEW superset_poligonos_covid_temporal AS
SELECT
    g.municipio_id,
    g.municipio_nome,
    (g.geometry_json::jsonb->'coordinates'->0)::text AS geometry_json,
    cc.tempo,
    cc.ano_semana,
    cc.caso,
    cc.obito,
    cc.tx_incid,
    cc.tx_mort,
    cc.letalidade,
    cc.IDHM,
    cc.IVS,
    cc.IDSC,
    cc.longitude,
    cc.latitude
FROM municipios_geojson g
LEFT JOIN covid_completo cc
    ON unaccent(UPPER(TRIM(g.municipio_nome))) = unaccent(UPPER(TRIM(cc.municipio)));

-- Verificar matches
SELECT
    COUNT(*) FILTER (WHERE c.caso > 0)  AS poligonos_com_covid,
    COUNT(*) FILTER (WHERE c.caso = 0)  AS municipios_sem_match,
    COUNT(*)                             AS total_poligonos
FROM superset_poligonos_covid c;
