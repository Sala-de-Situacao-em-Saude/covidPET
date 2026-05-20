# Guia: Mapa Coroplético no Apache Superset com Dados IBGE

Passo a passo completo para criar um mapa choropleth (deck.gl Polygon) no Superset usando polígonos do IBGE e dados epidemiológicos.

---

## Pré-requisitos

| Item | Versão / Detalhes |
|------|-------------------|
| PostgreSQL | 13+ com extensão `unaccent` |
| Apache Superset | 2.x ou 3.x |
| Python | 3.8+ com `psycopg2-binary` e `requests` |
| Acesso à internet | Para baixar GeoJSON do IBGE |

---

## 1. Importar Polígonos do IBGE

### 1.1 APIs do IBGE utilizadas

```
# Polígonos (GeoJSON) — substitua /17 pelo código do estado desejado
https://servicodados.ibge.gov.br/api/v3/malhas/estados/17
    ?formato=application/vnd.geo+json
    &qualidade=intermediaria
    &intrarregiao=municipio

# Nomes dos municípios
https://servicodados.ibge.gov.br/api/v1/localidades/estados/17/municipios
```

> **Códigos de estado:** 17 = Tocantins, 35 = São Paulo, 11 = Rondônia, etc.

### 1.2 Executar o script de importação

```bash
# Instalar dependência
pip install psycopg2-binary

# Configurar senha e rodar
export DW_PASSWORD='sua_senha'
export DW_HOST='10.48.75.21'
export DW_PORT='5432'
export DW_DBNAME='data_lake'
export DW_USER='integra'
python3 importar_geojson_dw.py
```

No Windows (PowerShell):

```powershell
$env:DW_PASSWORD = 'sua_senha'
python importar_geojson_dw.py
```

### 1.3 Resultado esperado

```
139 features recebidas.
139 nomes mapeados.
Municípios na tabela:       139
Municípios com polígono:    139
Municípios com dados COVID: 139
```

### 1.4 Estrutura da tabela criada

```sql
CREATE TABLE municipios_geojson (
    id              SERIAL PRIMARY KEY,
    municipio_id    VARCHAR(20),   -- código IBGE (codarea)
    municipio_nome  VARCHAR(120),  -- nome oficial IBGE
    geometry_json   TEXT,          -- GeoJSON completo da geometria
    feature_json    JSONB          -- feature GeoJSON original
);
```

---

## 2. Preparar os Dados de Saúde

### 2.1 Habilitar extensão unaccent

```sql
CREATE EXTENSION IF NOT EXISTS unaccent;
```

### 2.2 Criar a view de agregação

```sql
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
    -- IMPORTANTE: deck.gl espera apenas o array de coordenadas, não o objeto GeoJSON completo
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
    -- JOIN por nome normalizado (sem acentos, maiúsculas, sem espaços extras)
    ON unaccent(UPPER(TRIM(g.municipio_nome))) = c.municipio_norm
    -- Caso especial: municípios com nomes diferentes entre as fontes
    OR (unaccent(UPPER(TRIM(g.municipio_nome))) = 'TABOCAO'
        AND c.municipio_norm = 'FORTALEZA DO TABOCAO');
```

> **Por que `(geometry_json::jsonb->'coordinates'->0)::text`?**
> O IBGE retorna `{"type":"Polygon","coordinates":[[...]]}`. O deck.gl do Superset espera apenas
> o array de coordenadas do anel externo: `[[lon,lat],[lon,lat],...]`. O `->0` extrai o primeiro
> (e único) anel. O cast final para `::text` garante que o Superset receba uma string JSON, não
> um objeto Python com aspas simples.

### 2.3 Verificar qualidade do JOIN

```sql
-- Deve retornar 139 municípios com covid (para Tocantins)
SELECT
    COUNT(*) FILTER (WHERE caso > 0)  AS com_covid,
    COUNT(*) FILTER (WHERE caso = 0)  AS sem_match,
    COUNT(*)                           AS total
FROM superset_poligonos_covid;

-- Listar municípios sem match para diagnóstico
SELECT g.municipio_nome
FROM municipios_geojson g
WHERE NOT EXISTS (
    SELECT 1 FROM covid_completo cc
    WHERE unaccent(UPPER(TRIM(cc.municipio))) = unaccent(UPPER(TRIM(g.municipio_nome)))
);
```

### 2.4 View temporal (por semana epidemiológica)

```sql
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
```

---

## 3. Configurar Dataset no Superset

1. Acesse **Data → Datasets → + Dataset**
2. Preencha:
   - **Database**: selecione a conexão correta (ex: `PostgreSQLTesteCovid`)
   - **Schema**: `public`
   - **Table**: `superset_poligonos_covid`
3. Clique em **Save**

> **Atenção**: confirme que o Database aponta para o banco correto. Se existirem múltiplas conexões com nomes parecidos (ex: "DW" e "PostgreSQLTesteCovid"), abra cada uma em **Settings → Database Connections** e compare a URI.

---

## 4. Criar o Gráfico (deck.gl Polygon)

### 4.1 Novo gráfico

1. **Charts → + Chart**
2. Selecione o dataset `superset_poligonos_covid`
3. Tipo de gráfico: **deck.gl Polygon**
4. Clique em **Create new chart**

### 4.2 Configurações obrigatórias

| Campo | Valor |
|-------|-------|
| **Polygon column** | `geometry_json` |
| **Metric** | `SUM(caso)` ou `AVG(tx_incid)` |
| **Stroke color** | RGB(0, 0, 0) — borda dos polígonos |
| **Filled** | ✓ Ativado |
| **Extruded** | ✗ Desativado (mapa 2D) |

### 4.3 Cor e opacidade

| Campo | Valor sugerido |
|-------|----------------|
| **Color scheme** | `Inferno` ou `Viridis` |
| **Opacity** | 80% |
| **Stroke width** | 1 |

### 4.4 Viewport inicial (Tocantins)

```
Longitude:  -48.3
Latitude:   -10.2
Zoom:        6
Bearing:     0
Pitch:       0
```

### 4.5 Extra data for JS (tooltip)

No campo **Extra data for JS**, adicione os campos que devem aparecer no tooltip:

```
municipio_nome, caso, obito, tx_incid, tx_mort, letalidade, populacao
```

---

## 5. Configurar o Tooltip (JavaScript)

No campo **JavaScript tooltip generator**, cole:

```javascript
function(object) {
  if (!object || !object.object) return '';
  var d = object.object;
  var extra = d.extraProps || {};
  var nome = extra.municipio_nome || d.municipio_nome || 'Município';
  var casos = object['SUM(caso)'] !== undefined ? object['SUM(caso)'] : (extra.caso || 0);
  var obitos = extra.obito || 0;
  var incid = extra.tx_incid ? extra.tx_incid.toFixed(2) : 'N/A';
  var mort = extra.tx_mort ? extra.tx_mort.toFixed(2) : 'N/A';
  var letal = extra.letalidade ? extra.letalidade.toFixed(2) : 'N/A';
  return '<div style="background:#1a1a2e;color:#fff;padding:10px;border-radius:6px;font-family:sans-serif;min-width:180px">'
    + '<b style="font-size:14px">' + nome + '</b><br>'
    + '<hr style="border-color:#444;margin:5px 0">'
    + '<span style="color:#ff6b6b">Casos: </span>' + Number(casos).toLocaleString('pt-BR') + '<br>'
    + '<span style="color:#ffd93d">Óbitos: </span>' + Number(obitos).toLocaleString('pt-BR') + '<br>'
    + '<span style="color:#6bcb77">Incidência: </span>' + incid + '<br>'
    + '<span style="color:#4d96ff">Mortalidade: </span>' + mort + '<br>'
    + '<span style="color:#ff6b6b">Letalidade: </span>' + letal + '%'
    + '</div>';
}
```

> **Nota**: o nome da métrica no objeto JavaScript é igual à expressão SQL exata. Para `SUM(caso)`,
> use `object['SUM(caso)']`. Para `AVG(tx_incid)`, use `object['AVG(tx_incid)']`.

---

## 6. Salvar e Adicionar ao Dashboard

1. Clique em **Save** no chart
2. Vá em **Dashboards → + Dashboard**
3. Clique em **Edit dashboard → Add component → Chart**
4. Selecione o chart criado e arraste para o layout
5. Clique em **Save**

---

## 7. Resolução de Problemas

| Sintoma | Causa provável | Solução |
|---------|---------------|---------|
| Mapa em branco, sem polígonos | `geometry_json` contém objeto GeoJSON completo em vez de array de coordenadas | Use `(geometry_json::jsonb->'coordinates'->0)::text` na view |
| Tooltip mostra `undefined` | Campos não adicionados em "Extra data for JS" | Adicione os campos desejados nesse campo |
| Nomes de municípios trocados | `municipios_geojson` importada com IDs errados | Reimporte com `importar_geojson_dw.py` |
| Apenas X/139 municípios com match | Diferença de acentuação entre fontes | Use `unaccent()` nos dois lados do JOIN |
| Erro `operator does not exist: text -> unknown` | Coluna `geometry_json` é TEXT, não JSONB | Use cast explícito: `geometry_json::jsonb` |
| Erro `cannot update table ... replica identity` | Tabela em publicação de replicação lógica sem PK | Execute `ALTER TABLE ... REPLICA IDENTITY FULL` antes do UPDATE |
| Erro `cannot change data type of view column` | `CREATE OR REPLACE VIEW` com tipo de coluna diferente | Faça `DROP VIEW ... CASCADE` antes de recriar |
| Dataset aponta para banco errado | Múltiplas conexões com nomes parecidos no Superset | Verifique a URI em Settings → Database Connections |

---

## 8. Diagnóstico Rápido

```sql
-- Verificar formato do geometry_json armazenado
SELECT LEFT(geometry_json, 100) FROM municipios_geojson LIMIT 3;

-- Verificar coordenadas de um município específico
SELECT
    municipio_nome,
    (geometry_json::jsonb->'coordinates'->0->0->>0)::numeric AS lon,
    (geometry_json::jsonb->'coordinates'->0->0->>1)::numeric AS lat
FROM municipios_geojson
WHERE municipio_nome IN ('Palmas', 'Araguaína', 'Gurupi');

-- Verificar cobertura do JOIN
SELECT
    COUNT(*) FILTER (WHERE caso > 0)  AS com_covid,
    COUNT(*) FILTER (WHERE caso = 0)  AS sem_match,
    COUNT(*)                           AS total
FROM superset_poligonos_covid;

-- Listar municípios sem match
SELECT g.municipio_nome, unaccent(UPPER(TRIM(g.municipio_nome))) AS norm
FROM municipios_geojson g
WHERE NOT EXISTS (
    SELECT 1 FROM covid_completo cc
    WHERE unaccent(UPPER(TRIM(cc.municipio))) = unaccent(UPPER(TRIM(g.municipio_nome)))
)
ORDER BY g.municipio_nome;
```

---

## 9. Atualização dos Dados

Quando os dados de `covid_completo` forem atualizados, a view `superset_poligonos_covid` reflete
automaticamente as mudanças — não é necessário nenhuma ação adicional. Se os polígonos do IBGE
precisarem ser atualizados (ex: novo estado, nova qualidade), reexecute `importar_geojson_dw.py`.

---

*Desenvolvido pela Sala de Situação em Saúde — Tocantins*
