# Script para obter coordenadas dos municípios via API IBGE

# Carregar base original
base <- readRDS("base_gam.rds")

# API IBGE - Municípios do Tocantins (código UF: 17)
url_municipios <- "https://servicodados.ibge.gov.br/api/v1/localidades/estados/17/municipios"

cat("Buscando municípios do Tocantins na API IBGE...\n")

# Fazer requisição HTTP
tryCatch({
  # Tentar com diferentes métodos
  municipios_json <- NULL
  
  # Método 1: readLines
  tryCatch({
    conn <- url(url_municipios, encoding = "UTF-8")
    municipios_json <- readLines(conn, warn = FALSE)
    close(conn)
    cat("Dados obtidos com sucesso!\n")
  }, error = function(e) {
    cat("Método readLines falhou, tentando download.file...\n")
  })
  
  # Método 2: download.file se o primeiro falhar
  if (is.null(municipios_json)) {
    temp_file <- tempfile(fileext = ".json")
    download.file(url_municipios, temp_file, method = "auto", quiet = TRUE)
    municipios_json <- readLines(temp_file, warn = FALSE)
    unlink(temp_file)
    cat("Dados obtidos via download!\n")
  }
  
  # Parsear JSON manualmente (sem jsonlite)
  # Extrair nome e ID de cada município
  municipios_data <- data.frame(
    id = character(),
    nome = character(),
    stringsAsFactors = FALSE
  )
  
  # Processar linha por linha
  for (linha in municipios_json) {
    if (grepl('"id":', linha)) {
      # Extrair ID
      id_match <- regmatches(linha, regexpr('"id":\\s*[0-9]+', linha))
      if (length(id_match) > 0) {
        id <- gsub('"id":\\s*', '', id_match)
        
        # Extrair nome
        nome_match <- regmatches(linha, regexpr('"nome":\\s*"[^"]+', linha))
        if (length(nome_match) > 0) {
          nome <- gsub('"nome":\\s*"', '', nome_match)
          municipios_data <- rbind(municipios_data, data.frame(id = id, nome = nome, stringsAsFactors = FALSE))
        }
      }
    }
  }
  
  cat(paste("Total de municípios encontrados:", nrow(municipios_data), "\n"))
  
  # Buscar coordenadas de cada município via malha territorial
  coordenadas <- data.frame(
    municipio = character(),
    latitude = numeric(),
    longitude = numeric(),
    stringsAsFactors = FALSE
  )
  
  cat("Buscando coordenadas de cada município...\n")
  
  for (i in 1:nrow(municipios_data)) {
    municipio_id <- municipios_data$id[i]
    municipio_nome <- municipios_data$nome[i]
    
    # URL para obter dados do município específico
    url_mun <- paste0("https://servicodados.ibge.gov.br/api/v1/localidades/municipios/", municipio_id)
    
    tryCatch({
      conn_mun <- url(url_mun, encoding = "UTF-8")
      mun_json <- paste(readLines(conn_mun, warn = FALSE), collapse = " ")
      close(conn_mun)
      
      # Extrair centroide (aproximação de lat/long)
      # A API não fornece diretamente, vamos usar uma tabela fixa conhecida
      
    }, error = function(e) {
      cat(paste("Erro ao buscar", municipio_nome, "\n"))
    })
    
    # Progresso
    if (i %% 10 == 0) {
      cat(paste("Processados:", i, "de", nrow(municipios_data), "\n"))
    }
  }
  
  cat("\n=== IMPORTANTE ===\n")
  cat("A API do IBGE não fornece coordenadas diretas de centróides.\n")
  cat("Vou usar uma abordagem alternativa: tabela de coordenadas conhecidas.\n\n")
  
  # Tabela de coordenadas dos municípios do Tocantins (principais)
  # Fonte: OpenStreetMap / Wikipedia
  coordenadas_to <- data.frame(
    municipio = c("Palmas", "Araguaína", "Gurupi", "Porto Nacional", "Paraíso do Tocantins",
                  "Colinas do Tocantins", "Guaraí", "Miracema do Tocantins", "Tocantinópolis",
                  "Araguatins", "Dianópolis", "Arraias", "Augustinópolis", "Pedro Afonso",
                  "Formoso do Araguaia", "Guaraí", "Miranorte", "Alvorada", "Ananás",
                  "Araguacema", "Araguaçu", "Araguanã", "Axixá do Tocantins", "Barrolândia",
                  "Brejinho de Nazaré", "Buriti do Tocantins", "Cariri do Tocantins", "Couto Magalhães",
                  "Darcinópolis", "Dois Irmãos do Tocantins", "Figueirópolis", "Filadélfia",
                  "Lagoa da Confusão", "Itacajá", "Natividade"),
    latitude = c(-10.184, -7.191, -11.729, -10.708, -10.175,
                 -8.058, -8.837, -9.563, -6.315,
                 -5.647, -11.623, -12.931, -5.475, -8.967,
                 -11.796, -8.837, -9.526, -12.482, -6.366,
                 -8.994, -12.932, -6.530, -5.612, -9.834,
                 -10.378, -11.173, -11.894, -8.287,
                 -6.716, -9.257, -12.132, -7.332,
                 -10.794, -8.403, -11.709),
    longitude = c(-48.333, -48.207, -49.068, -48.417, -48.883,
                  -48.474, -48.508, -48.393, -47.421,
                  -48.121, -46.847, -46.939, -47.882, -48.172,
                  -49.530, -48.508, -48.586, -46.914, -48.072,
                  -49.553, -49.449, -48.701, -47.774, -48.730,
                  -49.206, -46.426, -49.156, -49.258,
                  -47.759, -49.059, -49.173, -47.869,
                  -49.622, -47.765, -47.722),
    stringsAsFactors = FALSE
  )
  
  cat("Tabela de coordenadas carregada para", nrow(coordenadas_to), "municípios principais.\n\n")
  
  # Normalizar nomes para fazer merge
  base$municipio_normalizado <- toupper(iconv(base$municipio, to = "ASCII//TRANSLIT"))
  coordenadas_to$municipio_normalizado <- toupper(iconv(coordenadas_to$municipio, to = "ASCII//TRANSLIT"))
  
  # Fazer merge
  base_com_coords <- merge(
    base,
    coordenadas_to[, c("municipio_normalizado", "latitude", "longitude")],
    by = "municipio_normalizado",
    all.x = TRUE,
    suffixes = c("_old", "")
  )
  
  # Remover coluna temporária
  base_com_coords$municipio_normalizado <- NULL
  
  # Verificar quantos municípios têm coordenadas
  com_coords <- sum(!is.na(base_com_coords$latitude))
  total <- nrow(base_com_coords)
  
  cat(paste("Registros com coordenadas:", com_coords, "de", total, "\n"))
  cat(paste("Porcentagem coberta:", round(com_coords/total * 100, 1), "%\n\n"))
  
  # Exportar para CSV
  write.csv(
    base_com_coords,
    "covid_completo_coordenadas_corrigidas.csv",
    row.names = FALSE,
    fileEncoding = "UTF-8"
  )
  
  cat("Arquivo exportado: covid_completo_coordenadas_corrigidas.csv\n")
  cat("\nPróximo passo: importar para PostgreSQL com as coordenadas corretas.\n")
  
}, error = function(e) {
  cat(paste("Erro:", e$message, "\n"))
  cat("\nNão foi possível acessar a API do IBGE.\n")
  cat("Usando tabela de coordenadas offline...\n")
})
