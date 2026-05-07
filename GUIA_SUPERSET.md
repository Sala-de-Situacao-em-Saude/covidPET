# GUIA: CONFIGURAÇÃO DO PAINEL COVID-19 NO APACHE SUPERSET

##  ARQUIVOS EXPORTADOS

Foram gerados 4 arquivos CSV prontos para importação no Superset:

### 1. **covid_completo.csv** (13.297 linhas)
Base principal com todos os dados temporais e espaciais
- Série temporal completa (159 semanas)
- 139 municípios do Tocantins
- Variáveis: casos, óbitos, taxas, índices socioeconômicos

### 2. **covid_temporal.csv** (159 linhas)
Agregação temporal para gráficos de série
- Dados agregados por semana epidemiológica
- Ideal para gráficos de linha temporal

### 3. **covid_municipio.csv** (34 linhas)
Dados do período mais recente por município
- Snapshot atual para mapas e rankings
- Inclui coordenadas geográficas

### 4. **covid_resumo.csv** (1 linha)
Indicadores totais acumulados
- KPIs principais do dashboard

---

##  ESTRUTURA DO PAINEL SUPERSET

### Cards de Indicadores Principais (KPIs)
```
┌─────────────┬─────────────┬─────────────┬─────────────┐
│  CASOS      │   ÓBITOS    │ INCIDÊNCIA  │ LETALIDADE  │
│  390.058    │   4.322     │  24.799,18  │   1,10%     │
└─────────────┴─────────────┴─────────────┴─────────────┘
```

**Dataset:** covid_resumo.csv
**Métricas:**
- Casos: SUM(total_casos)
- Óbitos: SUM(total_obitos)
- Incidência: AVG(incidencia_media)
- Letalidade: AVG(letalidade_media)

---

### Gráfico de Série Temporal
**Tipo:** Line Chart
**Dataset:** covid_temporal.csv
**Configuração:**
- X-Axis: ano_semana
- Metrics: SUM(caso), SUM(obito)
- Group by: tempo

---

### Índices Socioeconômicos
**Tipo:** Big Number with Trend ou Gauge Chart
**Dataset:** covid_completo.csv
**Métricas:**
- IDHM: AVG(IDHM) → Meta: 0.700
- IVS: AVG(IVS) → Meta: < 0.300 (baixa vulnerabilidade)
- IDSC: AVG(IDSC) → Meta: > 50 (bom desempenho)

**Detalhamento IDHM:**
- IDHM_E (Educação): AVG(IDHM_E)
- IDHM_R (Renda): AVG(IDHM_R)
- IDHM_L (Longevidade): AVG(IDHM_L)

**Detalhamento IVS:**
- IVS_C (Capital Humano): AVG(IVS_C)
- IVS_R (Renda e Trabalho): AVG(IVS_R)
- IVS_I (Infraestrutura): AVG(IVS_I)

---

### Mapa Coroplético
**Tipo:** Deck.gl Polygon
**Dataset:** covid_municipio.csv
**Configuração:**
- Longitude: longitude
- Latitude: latitude
- Metric: SUM(caso) ou tx_incid
- Color: Gradiente baseado na métrica

---

## ⚠️ OBSERVAÇÕES IMPORTANTES

### Variável GÊNERO
**Status:** NÃO DISPONÍVEL nas bases atuais

As bases `base_gam.rds` e `base_gam2.rds` não contêm informações de gênero/sexo.
Para incluir essa dimensão no painel, você precisará:

1. **Obter dados originais do SIVEP-Gripe/e-SUS Notifica**
   - Acessar: https://opendatasus.saude.gov.br/
   - Baixar dados brutos de COVID-19 do Tocantins
   - Agregar por gênero

2. **Integrar com banco de dados existente**
   - Se você tem acesso ao banco original que gerou base_gam/base_gam2
   - Fazer JOIN com tabela que contém informação de sexo

---

## 🔌 INTEGRAÇÃO COM APIs (ÍNDICES)

### APIs Disponíveis para Índices Brasileiros

#### 1. IBGE - Atlas do Desenvolvimento Humano
**IDHM e componentes**
- API: http://api.atlasbrasil.org.br/
- Endpoint: `/consulta/municipio/{codigo_ibge}`
- Retorna: IDHM, IDHM_E, IDHM_R, IDHM_L

#### 2. IPEA - Atlas da Vulnerabilidade Social
**IVS e dimensões**
- Dados disponíveis em: http://ivs.ipea.gov.br/
- Formato: Download CSV ou consulta por município

#### 3. Ministério da Saúde - IDSC
**IDSUS/IDSC**
- API DATASUS: http://tabnet.datasus.gov.br/
- Requer web scraping ou download de planilhas

**Observação:** Os índices IDHM, IVS e IDSC já estão presentes nas suas bases!
Eles foram coletados de censos e pesquisas oficiais (IBGE, IPEA, MS).

---

## 🚀 PRÓXIMOS PASSOS

### 1. Importar Dados no Superset
```bash
# No Superset, vá em:
Data → Upload a CSV → Selecionar arquivos
```

### 2. Criar Dataset
- Database: CSV Files
- Schema: main
- Table: covid_completo, covid_temporal, covid_municipio, covid_resumo

### 3. Configurar Métricas Calculadas
```sql
-- Taxa de Incidência por 100k habitantes
SUM(caso) / SUM(Populacao) * 100000

-- Letalidade Percentual
SUM(obito) / SUM(caso) * 100

-- IDHM Classificação
CASE 
  WHEN AVG(IDHM) >= 0.8 THEN 'Muito Alto'
  WHEN AVG(IDHM) >= 0.7 THEN 'Alto'
  WHEN AVG(IDHM) >= 0.6 THEN 'Médio'
  ELSE 'Baixo'
END
```

### 4. Criar Dashboard
- Layout: Grid 12 colunas
- Filtros: Data, Município, Região de Saúde
- Refresh automático: 1 hora (se dados atualizados)

---

## 📋 CHECKLIST DE IMPLEMENTAÇÃO

- [ ] Upload dos 4 arquivos CSV no Superset
- [ ] Criar datasets vinculados
- [ ] Configurar métricas calculadas
- [ ] Card: Total de Casos
- [ ] Card: Total de Óbitos
- [ ] Card: Incidência (por 100k hab)
- [ ] Card: Letalidade (%)
- [ ] Card: IDHM médio
- [ ] Card: IVS médio
- [ ] Card: IDSC médio
- [ ] Gráfico: Série temporal de casos
- [ ] Gráfico: Série temporal de óbitos
- [ ] Gráfico: Distribuição por região
- [ ] Mapa: Casos por município
- [ ] Tabela: Ranking de municípios
- [ ] Filtros interativos
- [ ] Configurar cores e tema
- [ ] Testar responsividade

---

## 🎨 SUGESTÕES DE VISUALIZAÇÃO

### Paleta de Cores
- Casos: #FF6B6B (vermelho)
- Óbitos: #4A4A4A (cinza escuro)
- Incidência: #FFA500 (laranja)
- Letalidade: #8B0000 (vermelho escuro)
- IDHM: #4CAF50 (verde)
- IVS: #F44336 (vermelho)
- IDSC: #2196F3 (azul)

### Layout Recomendado
```
┌────────────────────────────────────────────────────┐
│  FILTROS: [Data] [Município] [Região]             │
├──────┬──────┬──────┬──────┬──────┬──────┬────────┤
│CASOS │ÓBITOS│INCID │LETAL │IDHM  │ IVS  │ IDSC   │
├──────────────────────────────────────────────────┤
│  GRÁFICO TEMPORAL (Linha)                        │
├──────────────────┬──────────────────────────────┤
│  MAPA MUNICÍPIOS │  RANKING MUNICÍPIOS          │
└──────────────────┴──────────────────────────────┘
```

---

## 🔗 RECURSOS ADICIONAIS

### Documentação Oficial
- Apache Superset: https://superset.apache.org/docs/intro
- Deck.gl Maps: https://deck.gl/
- SQL Lab: Para queries customizadas

### Fontes de Dados
- SIVEP-Gripe: https://opendatasus.saude.gov.br/
- Atlas Brasil: http://www.atlasbrasil.org.br/
- IPEA: https://www.ipea.gov.br/
