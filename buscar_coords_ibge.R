# Script para buscar coordenadas via API de Geocoding

base <- readRDS("base_gam.rds")
municipios_unicos <- unique(base$municipio)

cat(paste("Total de municípios para buscar:", length(municipios_unicos), "\n\n"))

# Função para buscar coordenadas usando Nominatim (OpenStreetMap)
buscar_coordenadas <- function(municipio) {
  # Construir query
  query <- paste0(municipio, ", Tocantins, Brazil")
  query_encoded <- URLencode(query)
  
  url <- paste0("https://nominatim.openstreetmap.org/search?q=", 
                query_encoded, 
                "&format=json&limit=1")
  
  tryCatch({
    # User-Agent obrigatório para Nominatim
    req <- url(url)
    json_raw <- readLines(req, warn = FALSE, encoding = "UTF-8")
    close(req)
    
    # Parse manual do JSON
    if (length(json_raw) > 0 && json_raw != "[]") {
      # Extrair lat e lon
      lat_match <- regmatches(json_raw, regexpr('"lat":"[^"]+', json_raw))
      lon_match <- regmatches(json_raw, regexpr('"lon":"[^"]+', json_raw))
      
      if (length(lat_match) > 0 && length(lon_match) > 0) {
        lat <- as.numeric(gsub('"lat":"', '', lat_match))
        lon <- as.numeric(gsub('"lon":"', '', lon_match))
        
        # Esperar 1 segundo entre requisições (política do Nominatim)
        Sys.sleep(1)
        
        return(c(lat, lon))
      }
    }
    
    return(c(NA, NA))
    
  }, error = function(e) {
    return(c(NA, NA))
  })
}

# Criar dataframe de resultados
coords_result <- data.frame(
  municipio = character(),
  latitude = numeric(),
  longitude = numeric(),
  stringsAsFactors = FALSE
)

cat("Buscando coordenadas... (isso vai levar alguns minutos)\n\n")

for (i in 1:length(municipios_unicos)) {
  mun <- municipios_unicos[i]
  
  cat(paste0("[", i, "/", length(municipios_unicos), "] ", mun, "... "))
  
  coords <- buscar_coordenadas(mun)
  
  if (!is.na(coords[1])) {
    cat(paste0("OK (", round(coords[1], 4), ", ", round(coords[2], 4), ")\n"))
  } else {
    cat("FALHOU\n")
  }
  
  coords_result <- rbind(coords_result, data.frame(
    municipio = mun,
    latitude = coords[1],
    longitude = coords[2],
    stringsAsFactors = FALSE
  ))
}

# Salvar resultados
write.csv(coords_result, "coordenadas_completas.csv", row.names = FALSE, fileEncoding = "UTF-8")

# Estatísticas
sucesso <- sum(!is.na(coords_result$latitude))
cat(paste0("\n\n=== RESULTADO ===\n"))
cat(paste0("Total buscado: ", nrow(coords_result), "\n"))
cat(paste0("Sucesso: ", sucesso, " (", round(sucesso/nrow(coords_result)*100, 1), "%)\n"))
cat(paste0("Falhou: ", sum(is.na(coords_result$latitude)), "\n\n"))

cat("Arquivo salvo: coordenadas_completas.csv\n")
