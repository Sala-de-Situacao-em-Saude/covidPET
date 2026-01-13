# Criar GeoJSON simplificado dos municípios do Tocantins

base <- readRDS("base_gam.rds")
coords <- read.csv("coordenadas_completas.csv", stringsAsFactors = FALSE)

# Pegar última semana
ultima_semana <- max(base$tempo)
dados_ultima <- base[base$tempo == ultima_semana, ]

# Merge com coordenadas
dados_geo <- merge(dados_ultima, coords, by = "municipio", all.x = TRUE)

# Criar estrutura GeoJSON (FeatureCollection)
# Como não temos polígonos, vamos criar pontos circulares (buffers)

cat('{\n')
cat('  "type": "FeatureCollection",\n')
cat('  "features": [\n')

total <- nrow(dados_geo)
contador <- 0
for (i in 1:total) {
  row <- dados_geo[i, ]
  
  lat <- row$latitude
  lon <- row$longitude
  
  if (!is.na(lat) && !is.na(lon)) {
    contador <- contador + 1
    if (contador > 1) {
      cat(',\n')
    }
    # Feature individual
    cat('    {\n')
    cat('      "type": "Feature",\n')
    cat('      "properties": {\n')
    cat(paste0('        "municipio": "', row$municipio, '",\n'))
    cat(paste0('        "populacao": ', row$Populacao, ',\n'))
    cat(paste0('        "casos": ', row$caso, ',\n'))
    cat(paste0('        "obitos": ', row$obito, ',\n'))
    cat(paste0('        "tx_incid": ', row$tx_incid, ',\n'))
    cat(paste0('        "letalidade": ', row$letalidade, '\n'))
    cat('      },\n')
    cat('      "geometry": {\n')
    cat('        "type": "Point",\n')
    cat(paste0('        "coordinates": [', lon, ', ', lat, ']\n'))
    cat('      }\n')
    cat('    }')
  }
}

cat('  ]\n')
cat('}\n')
