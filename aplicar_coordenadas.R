# Aplicar coordenadas completas à base COVID

base <- readRDS("base_gam.rds")
coords <- read.csv("coordenadas_completas.csv", stringsAsFactors = FALSE)

cat(paste("Base COVID:", nrow(base), "registros\n"))
cat(paste("Coordenadas:", nrow(coords), "municípios\n\n"))

# Merge
base_final <- merge(
  base,
  coords,
  by = "municipio",
  all.x = TRUE,
  suffixes = c("_old", "")
)

# Remover colunas antigas se existirem
if ("latitude_old" %in% names(base_final)) {
  base_final$latitude_old <- NULL
}
if ("longitude_old" %in% names(base_final)) {
  base_final$longitude_old <- NULL
}

# Verificar
total <- nrow(base_final)
com_coords <- sum(!is.na(base_final$latitude))
cat(paste("Total de registros:", total, "\n"))
cat(paste("Com coordenadas:", com_coords, "\n"))
cat(paste("Cobertura:", round(com_coords/total * 100, 1), "%\n\n"))

# Exportar
write.csv(
  base_final,
  "covid_completo_final.csv",
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

cat("Arquivo exportado: covid_completo_final.csv\n")
cat("Pronto para importar no PostgreSQL!\n")
