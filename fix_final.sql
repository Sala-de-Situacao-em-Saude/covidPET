-- Solução final: Atualizar tabela covid_completo removendo TODOS os acentos
-- Usar transliteração para substituir caracteres acentuados

-- Instalar extensão unaccent se disponível (opcional, pode falhar)
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Atualizar municipio_norm com nomes limpos (apenas letras normais)
UPDATE covid_completo SET municipio_norm = 
    UPPER(TRIM(
        TRANSLATE(municipio, 
            'ÁÀÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ',
            'AAAAAAECEEEEIIIIDNOOOOOOUUUUYBSAAAAAAAECEEEEIIIIDNOOOOOOUUUUYBY'
        )
    ));

-- Verificar alguns exemplos
SELECT DISTINCT municipio AS original, municipio_norm AS normalizado 
FROM covid_completo 
WHERE municipio LIKE 'Abreul%' OR municipio LIKE 'Aguiarn%' OR municipio LIKE 'Alian%'
ORDER BY municipio;

-- Contar municípios distintos
SELECT COUNT(DISTINCT municipio_norm) AS total_municipios_normalizados FROM covid_completo;

-- Recriar views com JOIN usando nome normalizado
DROP VIEW IF EXISTS superset_poligonos_covid CASCADE;
CREATE OR REPLACE VIEW superset_poligonos_covid AS
WITH covid_agg AS (
    SELECT
        municipio_norm,
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
    WHERE municipio_norm IS NOT NULL
    GROUP BY municipio_norm
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
    ON UPPER(TRIM(g.municipio_nome)) = c.municipio_norm;

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
INNER JOIN covid_completo t
    ON UPPER(TRIM(g.municipio_nome)) = t.municipio_norm;

-- VER RESULTADO FINAL
SELECT '=============================================' AS separador;
SELECT 'TESTE FINAL - DEVE SER 139 POLIGONOS COM COVID!' AS resultado;
SELECT '=============================================' AS separador;

SELECT
    COUNT(*) FILTER (WHERE caso > 0) AS poligonos_com_covid,
    COUNT(*) FILTER (WHERE caso =  0 OR caso IS NULL) AS municipios_sem_match,
    COUNT(*) AS total_poligonos
FROM superset_poligonos_covid;

-- Mostrar exemplos
SELECT municipio_id, municipio_nome, caso, obito, populacao 
FROM superset_poligonos_covid 
WHERE caso > 0 
ORDER BY caso DESC 
LIMIT 10;
