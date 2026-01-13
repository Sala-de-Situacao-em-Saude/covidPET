# Processar GeoJSON e adicionar dados COVID

library(jsonlite)

# Ler GeoJSON
geojson <- fromJSON("tocantins_municipios.geojson", simplifyVector = FALSE)

# Ler dados COVID e agregar por município (total acumulado)
base <- readRDS("base_gam.rds")

# Agregar dados por município
dados_covid <- aggregate(
  cbind(caso, obito, Populacao) ~ municipio,
  data = base,
  FUN = sum
)

# Calcular médias para taxas e índices
medias <- aggregate(
  cbind(tx_incid, tx_mort, letalidade, IDHM, IVS) ~ municipio,
  data = base,
  FUN = mean
)

# Merge
dados_covid <- merge(dados_covid, medias, by = "municipio")

cat("GeoJSON carregado:", length(geojson$features), "municípios\n")
cat("Dados COVID:", nrow(dados_covid), "municípios\n\n")

# Função para normalizar nomes
normalizar <- function(nome) {
  nome <- toupper(iconv(nome, to = "ASCII//TRANSLIT"))
  nome <- gsub("\\s+", " ", nome)
  return(trimws(nome))
}

# Normalizar nomes nos dados COVID
dados_covid$municipio_norm <- sapply(dados_covid$municipio, normalizar)

# Atualizar properties de cada feature com dados COVID
matches <- 0
for (i in 1:length(geojson$features)) {
  feature <- geojson$features[[i]]
  nome_geo <- normalizar(feature$properties$name)
  
  # Buscar dados correspondentes
  idx <- which(dados_covid$municipio_norm == nome_geo)
  
  if (length(idx) > 0) {
    row <- dados_covid[idx[1], ]
    
    # Adicionar dados às properties
    feature$properties$populacao <- row$Populacao
    feature$properties$casos <- row$caso
    feature$properties$obitos <- row$obito
    feature$properties$tx_incid <- row$tx_incid
    feature$properties$tx_mort <- row$tx_mort
    feature$properties$letalidade <- row$letalidade
    feature$properties$IDHM <- row$IDHM
    feature$properties$IVS <- row$IVS
    
    geojson$features[[i]] <- feature
    matches <- matches + 1
  } else {
    cat("Não encontrado:", nome_geo, "\n")
  }
}

cat("\nTotal de matches:", matches, "/", length(geojson$features), "\n")

# Salvar novo GeoJSON
write(toJSON(geojson, auto_unbox = TRUE, pretty = TRUE), "tocantins_covid_completo.geojson")

cat("\nArquivo salvo: tocantins_covid_completo.geojson\n")
cat("Pronto para usar no Superset!\n")
