# Script para criar SQL que atualiza os nomes dos municípios na tabela covid_completo
# Usa a lista de nomes corretos sem acento

$nomesCorretos = Get-Content "lista_139_municipios_limpos.txt"

# Header do SQL
$sql = @"
-- Script para corrigir nomes dos municípios na tabela covid_completo
-- Substitui nomes com acentos corrompidos pelos nomes corretos sem acento

"@

# Para cada nome correto, criar um UPDATE
$nomesCorretos | ForEach-Object {
    $nomeCorreto = $_
    # Pegar as primeiras letras para fazer o LIKE
    $prefixo = $nomeCorreto.Substring(0, [Math]::Min(10, $nomeCorreto.Length))
    
    $sql += "UPDATE covid_completo SET municipio = '$nomeCorreto', municipio_norm = UPPER('$nomeCorreto') WHERE UPPER(TRIM(REGEXP_REPLACE(municipio, '[^A-Za-z ]', '', 'g'))) LIKE UPPER('$prefixo%') AND LENGTH(REGEXP_REPLACE(municipio, '[^A-Za-z ]', '', 'g')) BETWEEN " + ($nomeCorreto.Length - 3) + " AND " + ($nomeCorreto.Length + 3) + ";" + "`n"
}

$sql += @"

-- Verificar resultado
SELECT DISTINCT municipio, municipio_norm FROM covid_completo ORDER BY municipio LIMIT 10;

-- Recriar views
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
        AVG(latitude) AS latitude
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
    ON g.municipio_nome = c.municipio;

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
    ON g.municipio_nome = t.municipio;

-- VERIFICAÇÃO FINAL
SELECT '===============================================' AS info;
SELECT 'RESULTADO FINAL - DEVE SER 139/139!' AS info;
SELECT '===============================================' AS info;
SELECT
    COUNT(*) FILTER (WHERE caso > 0) AS poligonos_com_covid,
    COUNT(*) FILTER (WHERE caso = 0 OR caso IS NULL) AS municipios_sem_match,
    COUNT(*) AS total_poligonos
FROM superset_poligonos_covid;
"@

# Salvar SQL
$sql | Out-File "atualizar_nomes_covid.sql" -Encoding UTF8
Write-Host "Arquivo atualizar_nomes_covid.sql criado!"
