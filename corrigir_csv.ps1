# Script para corrigir os nomes dos municípios no CSV do GeoJSON
# Lê os nomes corretos e substitui no CSV linha por linha

# Ler lista de nomes corretos
$nomesCorretos = Get-Content "lista_139_municipios_limpos.txt"
Write-Host "Lidos $($nomesCorretos.Count) nomes corretos"

# Ler o CSV original (com encoding UTF-8)
$csvContent = Get-Content "geojson-sem-acentos.csv" -Encoding UTF8

# Linha 0 é o header, manter como está
$novoCSV = @($csvContent[0])

# Processar linhas 1 a 139 (índices 1 a 139)
for ($i = 1; $i -le 139; $i++) {
    $linha = $csvContent[$i]
    $nomeCorreto = $nomesCorretos[$i - 1]  # Array começa em 0
    
    # Split por ponto-e-vírgula (delimitador do CSV)
    $partes = $linha -split ';', 2
    
    if ($partes.Count -eq 2) {
        # Reconstruir linha: feature_json + ; + nome_correto
        $novaLinha = $partes[0] + ";" + $nomeCorreto
        $novoCSV += $novaLinha
    } else {
        Write-Warning "Linha $i com formato inesperado"
        $novoCSV += $linha
    }
}

# Salvar novo CSV
$novoCSV | Out-File "geojson-corrigido.csv" -Encoding UTF8
Write-Host "`nArquivo geojson-corrigido.csv criado com sucesso!"
Write-Host "Total de linhas: $($novoCSV.Count) (1 header + 139 municípios)"
