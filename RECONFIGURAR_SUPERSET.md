# 🔄 GUIA RÁPIDO: Reconfigurar Superset

## ✅ DADOS ESTÃO SALVOS
- 139 municípios com geometrias → OK
- 13.297 registros temporais COVID → OK
- Views prontas no PostgreSQL → OK

---

## 📋 PASSO A PASSO (5 minutos)

### 1️⃣ Adicionar Database PostgreSQL

1. **Settings** → **Database Connections** → **+ DATABASE**
2. Selecione: **PostgreSQL**
3. Cole a string de conexão:
   ```
   postgresql://postgres:covid2026@host.docker.internal:5432/superset
   ```
4. **CONNECT**
5. **FINISH**

---

### 2️⃣ Adicionar Dataset 1 (Agregado)

1. **Data** → **Datasets** → **+ DATASET**
2. Selecione:
   - **Database:** PostgreSQL (a que você acabou de criar)
   - **Schema:** public
   - **Table:** `superset_poligonos_covid`
3. **ADD DATASET AND CREATE CHART**
4. **SKIP** (por enquanto)

---

### 3️⃣ Adicionar Dataset 2 (Temporal)

1. **Data** → **Datasets** → **+ DATASET**
2. Selecione:
   - **Database:** PostgreSQL
   - **Schema:** public
   - **Table:** `superset_poligonos_covid_temporal`
3. **ADD DATASET AND CREATE CHART**
4. **SKIP**

---

### 4️⃣ Criar Chart Deck.gl Polygon (Mapa)

1. **Charts** → **+ CHART**
2. Selecione:
   - **Dataset:** `superset_poligonos_covid`
   - **Chart Type:** **deck.gl Polygon**
3. **CREATE NEW CHART**

#### Configurações do Chart:

**Aba QUERY:**
- **Polygon Column:** `geometry_json`
- **Metrics:** Clique em **+ METRIC**
  - **Aggregate:** SUM
  - **Column:** `caso`
  - **Label:** Total Casos
  - **SAVE**

**Aba MAP:**
- **Map Style:** `mapbox://styles/mapbox/light-v10`
- **Viewport:**
  - **Default Latitude:** `-10.2`
  - **Default Longitude:** `-48.3`
  - **Zoom:** `6`

**Aba CUSTOMIZE:**
- **Polygon Fill Color:**
  - **Metric:** Total Casos
  - **Color Scheme:** Escolha uma paleta (ex: reds, blues, etc.)
  - **Opacity:** 0.7
- **Polygon Stroke Color:** `#333333`
- **Stroke Width:** 1

4. Clique **UPDATE CHART**
5. **SAVE** (dê um nome: "Mapa COVID Tocantins")

---

## 🗺️ VERIFICAR MAPBOX TOKEN

Se o mapa não renderizar, verifique se o token está configurado:

```powershell
docker exec -it superset_app bash -c "cat /app/pythonpath/superset_config.py | grep MAPBOX"
```

Deve mostrar:
```
MAPBOX_API_KEY = 'COLE_SEU_MAPBOX_TOKEN_AQUI'
```

Se não mostrar, adicione novamente:
```powershell
docker exec -it superset_app bash
echo "MAPBOX_API_KEY = 'COLE_SEU_MAPBOX_TOKEN_AQUI'" >> /app/pythonpath/superset_config.py
exit
docker restart superset_app
```

---

## 📊 MÉTRICAS DISPONÍVEIS

No dataset `superset_poligonos_covid` você tem:

- **caso** - Total de casos COVID
- **obito** - Total de óbitos
- **caso_acum** - Casos acumulados
- **obito_acum** - Óbitos acumulados
- **tx_incid** - Taxa de incidência
- **tx_mort** - Taxa de mortalidade
- **letalidade** - Taxa de letalidade
- **pop_estimada** - População estimada

Crie múltiplos charts com diferentes métricas!

---

## 🎯 CHART TEMPORAL (Opcional)

Para visualizar a evolução ao longo do tempo:

1. Crie novo chart com dataset: `superset_poligonos_covid_temporal`
2. Use **Time Column:** `semana_epidem_dt`
3. Configure animação por semana
4. Veja os polígonos mudarem de cor conforme casos aumentam

---

## 🆘 RESOLUÇÃO DE PROBLEMAS

### Erro de conexão database:
- Use `host.docker.internal` no lugar de `localhost`
- Verifique se PostgreSQL está rodando

### Mapa não renderiza:
- Verifique Mapbox token
- Limpe cache do navegador (Ctrl+Shift+Delete)
- Verifique console do navegador (F12)

### Geometria não aparece:
- Confirme que selecionou coluna `geometry_json`
- Verifique se dataset tem 139 rows (no topo do chart)

---

## ✨ PRONTO!

Agora você tem:
- ✅ Conexão PostgreSQL
- ✅ 2 Datasets prontos
- ✅ Mapa de polígonos com 139 municípios
- ✅ Visualização de dados COVID por município

Explore diferentes métricas e crie seu dashboard!
