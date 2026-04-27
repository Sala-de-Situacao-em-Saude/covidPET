# 🔌 ADICIONAR DATABASE POSTGRESQL NO APACHE SUPERSET

## Passo 1: Acessar configuração de Database

1. Abra o Apache Superset no navegador
2. Faça login
3. No menu superior, clique em **Settings** (⚙️) → **Database Connections**
4. Clique no botão **+ DATABASE**

---

## Passo 2: Configurar conexão PostgreSQL

### Opção A: Configuração Simplificada (Recomendada)

1. Selecione **PostgreSQL** na lista de databases
2. Preencha os campos:

```
Display Name: Tocantins COVID-19
Host: localhost
Port: 5432
Database name: superset
Username: postgres
Password: [SUA_SENHA]
```

3. Clique em **TEST CONNECTION**
4. Se conectar com sucesso, clique em **CONNECT**

---

### Opção B: SQLAlchemy URI (Avançada)

Se preferir usar a string de conexão direta:

**String de Conexão:**
```
postgresql://postgres:[SUA_SENHA]@localhost:5432/superset
```

**Exemplo com senha:**
```
postgresql://postgres:minhasenha123@localhost:5432/superset
```

**Cole essa string no campo "SQLAlchemy URI"** e clique em **TEST CONNECTION**

---

## Passo 3: Adicionar as Tabelas/Views como Datasets

Após conectar o database:

### 3.1. Adicionar View de Polígonos (Mapa)

1. No menu superior: **Data** → **Datasets**
2. Clique em **+ DATASET**
3. Selecione:
   - **Database:** Tocantins COVID-19
   - **Schema:** public
   - **Table:** `superset_poligonos_covid`
4. Clique em **ADD**

### 3.2. Adicionar View Temporal (Séries)

Repita o processo para a view temporal:
- **Table:** `superset_poligonos_covid_temporal`

---

## 📊 ESTRUTURA DAS VIEWS DISPONÍVEIS

### View 1: `superset_poligonos_covid`
**Dados agregados por município (139 linhas)**

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `municipio_id` | TEXT | Código IBGE |
| `municipio_nome` | TEXT | Nome do município |
| `geometry_json` | JSONB | **Polígono GeoJSON** 🗺️ |
| `caso` | BIGINT | Total de casos acumulados |
| `obito` | BIGINT | Total de óbitos acumulados |
| `tx_incid` | DOUBLE | Taxa de incidência média |
| `tx_mort` | DOUBLE | Taxa de mortalidade média |
| `letalidade` | DOUBLE | Letalidade média (%) |
| `populacao` | INTEGER | População do município |
| `IDHM`, `IDHM_E`, `IDHM_R`, `IDHM_L` | DOUBLE | Índice de Desenvolvimento Humano |
| `IVS`, `IVS_C`, `IVS_R`, `IVS_I` | DOUBLE | Índice de Vulnerabilidade Social |
| `IDSC` | DOUBLE | Índice de Desenvolvimento Sustentável |
| `gini` | DOUBLE | Coeficiente de Gini |
| `dens_dem` | DOUBLE | Densidade demográfica |
| `PIB` | DOUBLE | PIB per capita |
| `longitude`, `latitude` | DOUBLE | Coordenadas geográficas |

**USO:** Mapas de polígonos, rankings, tabelas agregadas

---

### View 2: `superset_poligonos_covid_temporal`
**Série temporal completa (13.297 linhas = 139 municípios × 159 semanas)**

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `municipio_id` | TEXT | Código IBGE |
| `municipio_nome` | TEXT | Nome do município |
| `geometry_json` | JSONB | Polígono GeoJSON |
| `tempo` | DOUBLE | Semana epidemiológica (1-159) |
| `ano_semana` | TEXT | Formato "YYYY-WW" |
| `caso` | INTEGER | Casos na semana |
| `obito` | INTEGER | Óbitos na semana |
| `tx_incid` | DOUBLE | Taxa de incidência |
| `tx_mort` | DOUBLE | Taxa de mortalidade |
| `letalidade` | DOUBLE | Letalidade (%) |
| `IDHM`, `IVS`, `IDSC` | DOUBLE | Indicadores socioeconômicos |
| `longitude`, `latitude` | DOUBLE | Coordenadas |

**USO:** Gráficos de linha temporal, mapas animados, filtros por período

---

## 🗺️ CRIAR MAPA DE POLÍGONOS NO SUPERSET

### Passo 1: Criar novo Chart

1. Vá em **Charts** → **+ CHART**
2. Selecione o dataset: `superset_poligonos_covid`
3. Escolha o tipo de visualização: **Deck.gl Polygon**

### Passo 2: Configurar o Mapa

**Aba QUERY:**
- **GeoJSON Column:** `geometry_json`
- **Metrics:** 
  - `SUM(caso)` ou
  - `SUM(obito)` ou
  - `AVG(tx_incid)`
- **Filters:** (opcional) Adicionar filtros por indicadores

**Aba CUSTOMIZE:**
- **Filled:** ✅ Ativado
- **Stroked:** ✅ Ativado
- **Extruded:** ⬜ Desativado (ou ativado para 3D)
- **Opacity:** 0.6 - 0.8
- **Stroke Width:** 1-2

**Color Scheme:**
- Escolha uma paleta sequencial (ex: `blue_to_red`, `purple_to_yellow`)
- Ajuste os valores min/max conforme a métrica

### Passo 3: Salvar

1. Clique em **RUN** para visualizar
2. Clique em **SAVE** 
3. Dê um nome: "Mapa COVID-19 Tocantins - Casos por Município"

---

## 📈 OUTROS TIPOS DE VISUALIZAÇÃO SUGERIDOS

### Ranking de Municípios (Table)
- Dataset: `superset_poligonos_covid`
- Colunas: `municipio_nome`, `caso`, `obito`, `populacao`
- Ordenar por: `caso DESC`
- Limite: 20

### Série Temporal (Line Chart)
- Dataset: `superset_poligonos_covid_temporal`
- X-Axis: `tempo` ou `ano_semana`
- Metrics: `SUM(caso)`, `SUM(obito)`
- Group by: `municipio_nome` (para comparar municípios)

### Mapa de Pontos (Scatterplot)
- Dataset: `superset_poligonos_covid`
- Longitude: `longitude`
- Latitude: `latitude`
- Size: `caso`
- Color: `letalidade`

---

## 🔄 ATUALIZAR DATABASE EXISTENTE NO SUPERSET

Se você já tem uma conexão PostgreSQL no Superset e quer atualizar:

### Opção 1: Atualizar a Conexão
1. Vá em **Settings** → **Database Connections**
2. Encontre sua database PostgreSQL na lista
3. Clique no **ícone de lápis (Edit)** ✏️
4. Atualize as configurações conforme necessário
5. Clique em **TEST CONNECTION** e depois **SAVE**

### Opção 2: Atualizar os Datasets
Se a conexão está OK mas os dados mudaram:

1. Vá em **Data** → **Datasets**
2. Encontre o dataset (ex: `superset_poligonos_covid`)
3. Clique nos **três pontos (⋮)** → **Edit**
4. Na aba **Columns**, clique em **SYNC COLUMNS FROM SOURCE**
5. Clique em **SAVE**

### Opção 3: Recriar Dataset do Zero
Se houver problemas:

1. **Data** → **Datasets**
2. Encontre o dataset antigo
3. Clique nos **três pontos (⋮)** → **Delete**
4. Confirme a exclusão
5. Clique em **+ DATASET** e adicione novamente:
   - Database: Tocantins COVID-19
   - Schema: public
   - Table: `superset_poligonos_covid`

### Atualizar Cache
Para forçar refresh dos dados nos charts:

1. Abra o chart que quer atualizar
2. Clique nos **três pontos (⋮)** no canto superior direito
3. Selecione **Force refresh** 🔄
4. Ou pressione **Ctrl + R** na página do chart

---

## ✅ VERIFICAÇÃO DA CONEXÃO

Execute no terminal para confirmar que os dados estão disponíveis:

```powershell
& "C:\Program Files\PostgreSQL\13\bin\psql.exe" -U postgres -d superset -c "SELECT COUNT(*) AS total_municipios FROM superset_poligonos_covid; SELECT COUNT(*) AS total_registros_temporais FROM superset_poligonos_covid_temporal;"
```

**Resultado esperado:**
- `total_municipios`: 139
- `total_registros_temporais`: 13.297 (ou 22.071 se incluir todas as 159 semanas)

---

## 🚨 TROUBLESHOOTING

### Erro: "Could not connect to database"
- Verifique se o PostgreSQL está rodando
- Confirme a senha do usuário `postgres`
- Teste a conexão no terminal primeiro

### Erro: "Table not found"
- Confirme que as views foram criadas executando:
```sql
\dt+ superset_poligonos_covid*
```

### GeoJSON não aparece no mapa
- Confirme que a coluna `geometry_json` está selecionada
- Verifique se o tipo de dados é JSONB (não TEXT)
- Confirme que há dados: `SELECT municipio_nome, geometry_json IS NOT NULL FROM superset_poligonos_covid LIMIT 5;`

---

## 📚 DOCUMENTAÇÃO ADICIONAL

- **Superset Docs:** https://superset.apache.org/docs/intro
- **Deck.gl Polygon:** https://superset.apache.org/docs/configuration/viz-types/#deckgl-polygon
- **PostgreSQL Connection:** https://superset.apache.org/docs/databases/postgres/

---

**✅ Após seguir esses passos, você terá:**
- Database PostgreSQL conectada
- 2 datasets disponíveis (agregado + temporal)  
- Pronto para criar visualizações de mapas com polígonos! 🗺️
