#!/usr/bin/env python3
"""
Baixa os polígonos dos municípios do Tocantins diretamente da API do IBGE
e importa para o banco DW (PostgreSQL), criando a tabela e a view
prontas para o Deck.gl Polygon no Superset.

Uso:
    python3 importar_geojson_dw.py
"""

import json
import sys
import urllib.request

# ── Configurações do banco DW ─────────────────────────────────────────────────
# Defina as variáveis de ambiente antes de rodar:
#   export DW_HOST=10.48.75.20
#   export DW_PASSWORD=sua_senha
import os

DB_CONFIG = {
    'host':     os.environ.get('DW_HOST',     '10.48.75.20'),
    'port':     int(os.environ.get('DW_PORT', '5432')),
    'dbname':   os.environ.get('DW_DBNAME',   'dw'),
    'user':     os.environ.get('DW_USER',     'postgres'),
    'password': os.environ.get('DW_PASSWORD', ''),
}

# ── URLs da API do IBGE ───────────────────────────────────────────────────────
IBGE_MALHAS_URL = (
    'https://servicodados.ibge.gov.br/api/v3/malhas/estados/17'
    '?formato=application%2Fvnd.geo%2Bjson&qualidade=intermediaria&intrarregiao=municipio'
)
IBGE_NOMES_URL = (
    'https://servicodados.ibge.gov.br/api/v1/localidades/estados/17/municipios'
)

# ── DDL ───────────────────────────────────────────────────────────────────────
SQL_CREATE_TABLE = """
DROP TABLE IF EXISTS municipios_geojson CASCADE;
CREATE TABLE municipios_geojson (
    id              SERIAL PRIMARY KEY,
    municipio_id    VARCHAR(20),
    municipio_nome  VARCHAR(120),
    geometry_json   TEXT,       -- geometria GeoJSON (Deck.gl Polygon)
    feature_json    JSONB       -- feature GeoJSON completa
);
CREATE INDEX idx_mgj_id   ON municipios_geojson (municipio_id);
CREATE INDEX idx_mgj_nome ON municipios_geojson (municipio_nome);
"""

SQL_VIEW_POLIGONOS = """
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
        AVG(IDHM)              AS idhm,
        AVG(IDHM_E)            AS idhm_e,
        AVG(IDHM_R)            AS idhm_r,
        AVG(IDHM_L)            AS idhm_l,
        AVG(IVS)               AS ivs,
        AVG(IVS_C)             AS ivs_c,
        AVG(IVS_R)             AS ivs_r,
        AVG(IVS_I)             AS ivs_i,
        AVG(IDSC)              AS idsc,
        AVG(gini)              AS gini,
        AVG(dens_dem)          AS dens_dem,
        AVG(PIB)               AS pib,
        AVG(longitude)         AS longitude,
        AVG(latitude)          AS latitude,
        UPPER(TRIM(municipio)) AS municipio_norm
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
LEFT JOIN covid_agg c
    ON REGEXP_REPLACE(UPPER(TRIM(g.municipio_nome)), '[^A-Z0-9 ]', '', 'g') = c.municipio_norm;
"""

SQL_VERIFY = """
SELECT
    (SELECT COUNT(*) FROM municipios_geojson)                                        AS total_municipios,
    (SELECT COUNT(*) FROM superset_poligonos_covid WHERE geometry_json IS NOT NULL)  AS com_poligono,
    (SELECT COUNT(*) FROM superset_poligonos_covid WHERE caso IS NOT NULL)           AS com_covid;
"""


def fetch_json(url, label):
    import gzip
    print(f"Baixando {label} ...")
    req = urllib.request.Request(url, headers={'Accept-Encoding': 'gzip, deflate'})
    with urllib.request.urlopen(req, timeout=30) as r:
        raw = r.read()
        if r.info().get('Content-Encoding') == 'gzip' or raw[:2] == b'\x1f\x8b':
            raw = gzip.decompress(raw)
        data = json.loads(raw.decode('utf-8'))
    return data


def build_nome_map(localidades):
    """Retorna dict {codarea_str: nome} para os 139 municípios do TO."""
    return {str(m['id']): m['nome'] for m in localidades}


def import_to_dw(features, nome_map):
    try:
        import psycopg2
    except ImportError:
        print("\nERRO: psycopg2 não instalado. Execute: pip install psycopg2-binary\n")
        sys.exit(1)

    print("\nConectando ao banco DW ...")
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    print("Criando tabela municipios_geojson ...")
    cur.execute(SQL_CREATE_TABLE)

    insert_sql = """
        INSERT INTO municipios_geojson (municipio_id, municipio_nome, geometry_json, feature_json)
        VALUES (%s, %s, %s, %s)
    """
    print(f"Inserindo {len(features)} municípios ...")
    sem_nome = []
    for feat in features:
        cod = feat['properties'].get('codarea', '')
        nome = nome_map.get(cod, '')
        if not nome:
            sem_nome.append(cod)
        cur.execute(insert_sql, (
            cod,
            nome,
            json.dumps(feat['geometry'], ensure_ascii=False),
            json.dumps(feat, ensure_ascii=False),
        ))

    if sem_nome:
        print(f"  Atenção: {len(sem_nome)} feature(s) sem nome mapeado: {sem_nome[:5]}")

    print("Criando view superset_poligonos_covid ...")
    cur.execute(SQL_VIEW_POLIGONOS)

    conn.commit()

    print("\nVerificando resultados ...")
    cur.execute(SQL_VERIFY)
    row = cur.fetchone()
    print(f"  Municípios na tabela:        {row[0]}")
    print(f"  Municípios com polígono:     {row[1]}")
    print(f"  Municípios com dados COVID:  {row[2]}")

    cur.close()
    conn.close()

    print("""
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRÓXIMOS PASSOS NO SUPERSET — Deck.gl Polygon
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Data → Datasets → + Dataset
   Database: DW (postgresql://postgres@10.48.75.20:5432/dw)
   Schema: public  |  Table: superset_poligonos_covid  → SALVAR

2. Charts → + Chart
   Dataset: superset_poligonos_covid
   Chart type: Deck.gl Polygon

3. Configurar:
   - Polygon column : geometry_json
   - Metric         : SUM(caso)  ou  AVG(tx_incid)
   - Color scheme   : Inferno
   - Opacity        : 80

4. Salvar e adicionar ao dashboard.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
""")


if __name__ == '__main__':
    geojson   = fetch_json(IBGE_MALHAS_URL, 'polígonos IBGE (TO)')
    features  = geojson.get('features', [])
    print(f"  {len(features)} features recebidas.")

    localidades = fetch_json(IBGE_NOMES_URL, 'nomes dos municípios IBGE')
    nome_map    = build_nome_map(localidades)
    print(f"  {len(nome_map)} nomes mapeados.")

    import_to_dw(features, nome_map)
