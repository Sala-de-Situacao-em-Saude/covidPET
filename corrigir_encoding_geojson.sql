-- ============================================================
-- CORRIGIR ENCODING DOS NOMES NA TABELA municipios_geojson
-- Causa: R/jsonlite codificou acentos como sequências UTF-8
-- duplas (ex: "á" → "Ã¡") ao exportar o CSV
-- ============================================================

-- Corrigir municipio_nome com todos os pares UTF-8 → caractere correto
UPDATE municipios_geojson SET municipio_nome =
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(
    municipio_nome,
    -- Minúsculas
    'Ã£', 'ã'), 'Ã¡', 'á'), 'Ã©', 'é'), 'Ã­', 'í'),
    'Ã³', 'ó'), 'Ãº', 'ú'), 'Ã¢', 'â'), 'Ãª', 'ê'),
    'Ã´', 'ô'), 'Ã§', 'ç'), 'Ã ', 'à'), 'Ã¨', 'è'),
    'Ã¬', 'ì'), 'Ã²', 'ò'), 'Ã¹', 'ù'), 'Ã¼', 'ü'),
    'Ãµ', 'õ'), 'Ã±', 'ñ'), 'Ã­', 'í'), 'Ã®', 'î'),
    -- Maiúsculas
    'Ã‡', 'Ç'), 'Ã‰', 'É'), 'Ã"', 'Ó'), 'Ã', 'Á'),
    'Ãš', 'Ú'), 'Ã‚', 'Â'), 'ÃŠ', 'Ê'), 'Ã"', 'Ô'),
    'Ãœ', 'Ü'), 'Ã•', 'Õ'), 'Ã€', 'À'), 'Ã†', 'Æ'),
    'Ãƒ', 'Ã'), 'Ã˜', 'Ø'), 'Ã†', 'Æ'), 'Ã‡', 'Ç'),
    -- Casos extras comuns nos municípios do Tocantins
    'Ã±', 'ñ'), 'â€™', ''''), 'â€"', '–'), 'Â°', '°')
WHERE municipio_nome ~ '[ÃÂ]';

-- Verificar resultado (listar nomes com caracteres ainda suspeitos)
SELECT COUNT(*) AS ainda_com_problema
FROM municipios_geojson
WHERE municipio_nome ~ '[ÃÂ]';

-- Mostrar amostra dos nomes agora
SELECT municipio_id, municipio_nome
FROM municipios_geojson
ORDER BY municipio_nome
LIMIT 20;
