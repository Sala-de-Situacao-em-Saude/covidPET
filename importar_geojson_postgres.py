#!/usr/bin/env python3
"""
Importa os polígonos dos municípios do Tocantins (GeoJSON do IBGE)
para o PostgreSQL e cria as views necessárias para o Deck.gl Polygon no Superset.

Uso:
    python3 importar_geojson_postgres.py
"""

import json
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
GEOJSON_PATH = os.path.join(SCRIPT_DIR, 'tocantins_municipios.geojson')

DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'dbname': 'superset',
    'user': 'superset',
    'password': 'superset',
}

SQL_CREATE_TABLE = """
DROP TABLE IF EXISTS municipios_geojson CASCADE;
CREATE TABLE municipios_geojson (
    id             SERIAL PRIMARY KEY,
    municipio_id   VARCHAR(20),
    municipio_nome VARCHAR(120),
    geometry_json  TEXT,
    feature_json   JSONB
);
"""

SQL_INDEXES = """
CREATE INDEX idx_mun_geojson_id   ON municipios_geojson(municipio_id);
CREATE INDEX idx_mun_geojson_nome ON municipios_geojson(municipio_nome);
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
    c.longitude,
    c.latitude
FROM municipios_geojson g
LEFT JOIN covid_agg c
    ON UPPER(TRIM(g.municipio_nome)) = c.municipio_norm;
"""

SQL_VIEW_TEMPORAL = """
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
    ON UPPER(TRIM(g.municipio_nome)) = UPPER(TRIM(t.municipio));
"""

SQL_VERIFY = """
SELECT
    (SELECT COUNT(*) FROM municipios_geojson)                                        AS total_municipios,
    (SELECT COUNT(*) FROM superset_poligonos_covid WHERE geometry_json IS NOT NULL)  AS poligonos_com_geometria,
    (SELECT COUNT(*) FROM superset_poligonos_covid WHERE caso IS NOT NULL)           AS municipios_com_covid;
"""


def load_geojson():
    print(f"Lendo {GEOJSON_PATH} ...")
    with open(GEOJSON_PATH, encoding='utf-8') as f:
        data = json.load(f)
    features = data.get('features', [])
    print(f"  {len(features)} features encontradas.")
    return features


def import_to_postgres(features):
    try:
        import psycopg2
    except ImportError:
        print("\nERRO: psycopg2 não instalado. Execute: pip install psycopg2-binary\n")
        sys.exit(1)

    print("\nConectando ao PostgreSQL ...")
    try:
        conn = psycopg2.connect(**DB_CONFIG)
    except Exception as e:
        print(f"ERRO ao conectar: {e}")
        sys.exit(1)

    cur = conn.cursor()

    print("Criando tabela municipios_geojson ...")
    cur.execute(SQL_CREATE_TABLE)

    print(f"Inserindo {len(features)} municípios ...")
    insert_sql = """
        INSERT INTO municipios_geojson (municipio_id, municipio_nome, geometry_json, feature_json)
        VALUES (%s, %s, %s, %s)
    """
    for feat in features:
        props = feat.get('properties', {})
        cur.execute(insert_sql, (
            props.get('id', ''),
            props.get('name', ''),
            json.dumps(feat['geometry'], ensure_ascii=False),
            json.dumps(feat, ensure_ascii=False),
        ))

    print("Criando índices ...")
    cur.execute(SQL_INDEXES)

    print("Criando view superset_poligonos_covid ...")
    cur.execute(SQL_VIEW_POLIGONOS)

    print("Criando view superset_poligonos_covid_temporal ...")
    cur.execute(SQL_VIEW_TEMPORAL)

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
   Database: PostgreSQL | Schema: public
   Table: superset_poligonos_covid → SALVAR

2. Charts → + Chart
   Dataset: superset_poligonos_covid
   Chart type: Deck.gl Polygon

3. Configurar:
   - Polygon column : geometry_json
   - Metric         : SUM(caso)  ou  AVG(tx_incid)
   - Color scheme   : Inferno
   - Opacity        : 80

4. Salvar e adicionar ao dashboard.
""")


if __name__ == '__main__':
    features = load_geojson()
    import_to_postgres(features)
