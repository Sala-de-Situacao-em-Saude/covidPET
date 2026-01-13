# Coordenadas completas de todos os 139 municípios do Tocantins
# Fonte: IBGE / OpenStreetMap

base <- readRDS("base_gam.rds")

# Tabela completa de coordenadas (139 municípios do TO)
coords_tocantins <- read.table(text = "
municipio|latitude|longitude
Abreulândia|-9.6225|-49.1497
Aguiarnópolis|-6.6111|-47.4789
Aliança do Tocantins|-11.2936|-48.9383
Almas|-11.5683|-47.1803
Alvorada|-12.4833|-49.1244
Ananás|-6.3667|-48.0722
Angico|-6.3922|-47.8628
Aparecida do Rio Negro|-9.9533|-47.9619
Aragominas|-7.1656|-48.5306
Araguacema|-8.8117|-49.5528
Araguaçu|-12.9328|-49.8278
Araguaína|-7.1911|-48.2072
Araguanã|-6.5500|-48.7011
Araguatins|-5.6467|-48.1211
Arapoema|-7.6550|-49.0594
Arraias|-12.9311|-46.9392
Augustinópolis|-5.4750|-47.8822
Aurora do Tocantins|-12.7142|-46.4061
Axixá do Tocantins|-5.6122|-47.7739
Babaçulândia|-7.2089|-47.7778
Bandeirantes do Tocantins|-7.7564|-48.5828
Barra do Ouro|-7.7069|-47.6978
Barrolândia|-9.8339|-48.7297
Bernardo Sayão|-7.8764|-48.8900
Bom Jesus do Tocantins|-8.9692|-48.1736
Brasilândia do Tocantins|-8.3906|-48.4803
Brejinho de Nazaré|-11.0125|-48.5667
Buriti do Tocantins|-5.3167|-48.2242
Cachoeirinha|-6.1250|-47.9242
Campos Lindos|-7.9917|-46.8683
Cariri do Tocantins|-11.8939|-49.1558
Carmolândia|-7.0350|-48.3947
Carrasco Bonito|-5.3147|-48.0317
Caseara|-9.2733|-49.9572
Centenário|-8.9636|-47.3500
Chapada da Natividade|-11.6186|-47.7472
Chapada de Areia|-10.1383|-49.1461
Colinas do Tocantins|-8.0583|-48.4744
Colméia|-8.7264|-48.7656
Combinado|-12.7981|-46.5328
Conceição do Tocantins|-12.2200|-47.2983
Couto Magalhães|-8.2867|-49.2578
Cristalândia|-10.6000|-49.1958
Crixás do Tocantins|-11.0972|-48.9211
Darcinópolis|-6.7161|-47.7589
Dianópolis|-11.6233|-46.8467
Divinópolis do Tocantins|-9.7947|-49.2158
Dois Irmãos do Tocantins|-9.2572|-49.0589
Dueré|-11.3450|-49.2700
Esperantina|-5.3667|-48.5400
Fátima|-10.7636|-48.9053
Figueirópolis|-12.1328|-49.1728
Filadélfia|-7.3322|-47.8692
Formoso do Araguaia|-11.7958|-49.5297
Fortaleza do Tabocão|-9.0681|-48.5169
Goianorte|-8.7739|-48.9289
Goiatins|-7.7094|-47.3178
Guaraí|-8.8372|-48.5078
Gurupi|-11.7294|-49.0681
Ipueiras|-11.2344|-48.4572
Itacajá|-8.3931|-47.7653
Itaguatins|-5.7697|-47.4858
Itapiratins|-8.3800|-48.6908
Itaporã do Tocantins|-8.5733|-48.6883
Jaú do Tocantins|-12.6500|-48.8997
Juarina|-8.1153|-49.0806
Lagoa da Confusão|-10.7942|-49.6222
Lagoa do Tocantins|-10.3167|-47.5800
Lajeado|-9.7500|-48.3583
Lavandeira|-12.8017|-46.5719
Lizarda|-9.5839|-46.6522
Luzinópolis|-6.1722|-47.8567
Marianópolis do Tocantins|-9.7908|-49.6764
Mateiros|-10.5522|-46.4214
Maurilândia do Tocantins|-5.9506|-47.5039
Miracema do Tocantins|-9.5633|-48.3931
Miranorte|-9.5264|-48.5856
Monte do Carmo|-10.7583|-47.0028
Monte Santo do Tocantins|-10.0167|-48.9989
Muricilândia|-7.1503|-48.6083
Natividade|-11.7089|-47.7217
Nazaré|-6.3767|-47.6681
Nova Olinda|-7.6364|-48.4161
Nova Rosalândia|-10.5647|-48.9125
Novo Acordo|-9.9567|-47.6747
Novo Alegre|-12.9144|-46.5814
Novo Jardim|-11.8319|-46.6308
Oliveira de Fátima|-10.6922|-48.9072
Palmas|-10.1839|-48.3336
Palmeirante|-7.8578|-47.9244
Palmeiras do Tocantins|-6.6086|-47.5444
Palmeirópolis|-13.0439|-48.4017
Paraíso do Tocantins|-10.1750|-48.8828
Paranã|-12.6150|-47.8811
Pau D'Arco|-7.5364|-49.3733
Pedro Afonso|-8.9672|-48.1731
Peixe|-12.0250|-48.5369
Pequizeiro|-8.5939|-48.9317
Pindorama do Tocantins|-11.1281|-47.5742
Piraquê|-6.7772|-48.2922
Pium|-10.4400|-49.1872
Ponte Alta do Bom Jesus|-12.0856|-46.4797
Ponte Alta do Tocantins|-10.7453|-47.5308
Porto Alegre do Tocantins|-11.6117|-47.0617
Porto Nacional|-10.7081|-48.4169
Praia Norte|-5.3800|-48.6483
Presidente Kennedy|-8.4294|-48.5050
Pugmil|-10.4544|-49.0928
Recursolândia|-8.7383|-47.2908
Riachinho|-6.4317|-48.1322
Rio da Conceição|-11.4306|-46.9536
Rio dos Bois|-9.3322|-49.0006
Rio Sono|-9.3639|-47.2594
Sampaio|-5.3111|-47.9094
Sandolândia|-12.5600|-49.9311
Santa Fé do Araguaia|-7.3006|-48.7222
Santa Maria do Tocantins|-8.8269|-47.7519
Santa Rita do Tocantins|-10.8572|-48.9044
Santa Rosa do Tocantins|-11.4194|-48.1269
Santa Tereza do Tocantins|-10.2997|-47.8089
Santa Terezinha do Tocantins|-6.4336|-47.6642
São Bento do Tocantins|-5.9750|-47.8903
São Félix do Tocantins|-10.1789|-46.5772
São Miguel do Tocantins|-5.5756|-47.5875
São Salvador do Tocantins|-12.7336|-48.2883
São Sebastião do Tocantins|-5.2581|-48.2019
São Valério|-11.9772|-48.2150
Silvanópolis|-11.1281|-48.1925
Sítio Novo do Tocantins|-5.5944|-47.6503
Sucupira|-11.4281|-48.8808
Taguatinga|-12.4047|-46.4328
Taipas do Tocantins|-12.1956|-46.9711
Talismã|-12.7553|-49.0936
Tocantínia|-9.5606|-48.3500
Tocantinópolis|-6.3150|-47.4208
Tupirama|-8.7500|-48.1333
Tupiratins|-8.3944|-48.1236
Wanderlândia|-6.8486|-47.9678
Xambioá|-6.4106|-48.5381
", sep = "|", header = TRUE, stringsAsFactors = FALSE)

cat(paste("Total de coordenadas carregadas:", nrow(coords_tocantins), "\n\n"))

# Normalizar nomes para merge
base$municipio_norm <- toupper(iconv(base$municipio, to = "ASCII//TRANSLIT"))
coords_tocantins$municipio_norm <- toupper(iconv(coords_tocantins$municipio, to = "ASCII//TRANSLIT"))

# Ver municípios únicos na base
municipios_base <- unique(base$municipio_norm)
cat(paste("Municípios únicos na base COVID:", length(municipios_base), "\n"))

# Ver quais vão dar match
match_count <- sum(municipios_base %in% coords_tocantins$municipio_norm)
cat(paste("Municípios que terão coordenadas:", match_count, "\n\n"))

# Fazer merge
base_merged <- merge(
  base,
  coords_tocantins[, c("municipio_norm", "latitude", "longitude")],
  by = "municipio_norm",
  all.x = TRUE,
  suffixes = c("_antigo", "")
)

# Remover coluna temporária e antigas
base_merged$municipio_norm <- NULL
if ("latitude_antigo" %in% names(base_merged)) {
  base_merged$latitude_antigo <- NULL
}
if ("longitude_antigo" %in% names(base_merged)) {
  base_merged$longitude_antigo <- NULL
}

# Verificar cobertura
total_registros <- nrow(base_merged)
com_coords <- sum(!is.na(base_merged$latitude))
cat(paste("Total de registros:", total_registros, "\n"))
cat(paste("Registros com coordenadas:", com_coords, "\n"))
cat(paste("Cobertura:", round(com_coords/total_registros * 100, 1), "%\n\n"))

# Exportar
write.csv(
  base_merged,
  "covid_completo_coords_completo.csv",
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

cat("Arquivo exportado: covid_completo_coords_completo.csv\n")
cat("Pronto para importar no PostgreSQL!\n")
