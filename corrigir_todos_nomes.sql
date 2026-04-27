-- UPDATEs para corrigir os 63 municípios que não estão dando match
-- Substitui nomes corrompidos pelos nomes corretos sem acento

UPDATE covid_completo SET municipio = 'Abreulandia', municipio_norm = 'ABREULANDIA' WHERE municipio LIKE 'Abreul%ndia';
UPDATE covid_completo SET municipio = 'Aguiarnopolis', municipio_norm = 'AGUIARNOPOLIS' WHERE municipio LIKE 'Aguiarn%polis';
UPDATE covid_completo SET municipio = 'Alianca do Tocantins', municipio_norm = 'ALIANCA DO TOCANTINS' WHERE municipio LIKE 'Alian%a do Tocantins';
UPDATE covid_completo SET municipio = 'Ananas', municipio_norm = 'ANANAS' WHERE municipio LIKE 'Anan%s' AND LENGTH(municipio) < 10;
UPDATE covid_completo SET municipio = 'Araguacu', municipio_norm = 'ARAGUACU' WHERE municipio LIKE 'Aragua%u' AND municipio NOT LIKE '%na';
UPDATE covid_completo SET municipio = 'Araguaina', municipio_norm = 'ARAGUAINA' WHERE municipio LIKE 'Aragua%na';
UPDATE covid_completo SET municipio = 'Augustinopolis', municipio_norm = 'AUGUSTINOPOLIS' WHERE municipio LIKE 'Augustin%polis';
UPDATE covid_completo SET municipio = 'Axixa do Tocantins', municipio_norm = 'AXIXA DO TOCANTINS' WHERE municipio LIKE 'Axix%do Tocantins';
UPDATE covid_completo SET municipio = 'Babaculandia', municipio_norm = 'BABACULANDIA' WHERE municipio LIKE 'Baba%ul%ndia';
UPDATE covid_completo SET municipio = 'Barrolandia', municipio_norm = 'BARROLANDIA' WHERE municipio LIKE 'Barrol%ndia';
UPDATE covid_completo SET municipio = 'Bernardo Sayao', municipio_norm = 'BERNARDO SAYAO' WHERE municipio LIKE 'Bernardo Say%o';
UPDATE covid_completo SET municipio = 'Brasilandia do Tocantins', municipio_norm = 'BRASILANDIA DO TOCANTINS' WHERE municipio LIKE 'Brasil%ndia do Tocantins';
UPDATE covid_completo SET municipio = 'Brejinho de Nazare', municipio_norm = 'BREJINHO DE NAZARE' WHERE municipio LIKE 'Brejinho de Nazar%';
UPDATE covid_completo SET municipio = 'Carmolandia', municipio_norm = 'CARMOLANDIA' WHERE municipio LIKE 'Carmol%ndia';
UPDATE covid_completo SET municipio = 'Centenario', municipio_norm = 'CENTENARIO' WHERE municipio LIKE 'Centen%rio';
UPDATE covid_completo SET municipio = 'Colmeia', municipio_norm = 'COLMEIA' WHERE municipio LIKE 'Colm%ia';
UPDATE covid_completo SET municipio = 'Conceicao do Tocantins', municipio_norm = 'CONCEICAO DO TOCANTINS' WHERE municipio LIKE 'Concei%o do Tocantins';
UPDATE covid_completo SET municipio = 'Couto Magalhaes', municipio_norm = 'COUTO MAGALHAES' WHERE municipio LIKE 'Couto Magalh%es';
UPDATE covid_completo SET municipio = 'Cristalandia', municipio_norm = 'CRISTALANDIA' WHERE municipio LIKE 'Cristal%ndia';
UPDATE covid_completo SET municipio = 'Crixas do Tocantins', municipio_norm = 'CRIXAS DO TOCANTINS' WHERE municipio LIKE 'Crix%s do Tocantins';
UPDATE covid_completo SET municipio = 'Darcinopolis', municipio_norm = 'DARCINOPOLIS' WHERE municipio LIKE 'Darcin%polis';
UPDATE covid_completo SET municipio = 'Dianopolis', municipio_norm = 'DIANOPOLIS' WHERE municipio LIKE 'Dian%polis';
UPDATE covid_completo SET municipio = 'Divinopolis do Tocantins', municipio_norm = 'DIVINOPOLIS DO TOCANTINS' WHERE municipio LIKE 'Divin%polis do Tocantins';
UPDATE covid_completo SET municipio = 'Dois Irmaos do Tocantins', municipio_norm = 'DOIS IRMAOS DO TOCANTINS' WHERE municipio LIKE 'Dois Irm%os do Tocantins';
UPDATE covid_completo SET municipio = 'Duere', municipio_norm = 'DUERE' WHERE municipio LIKE 'Duer%';
UPDATE covid_completo SET municipio = 'Fatima', municipio_norm = 'FATIMA' WHERE municipio LIKE 'F%tima';
UPDATE covid_completo SET municipio = 'Figueiropolis', municipio_norm = 'FIGUEIROPOLIS' WHERE municipio LIKE 'Figueir%polis';
UPDATE covid_completo SET municipio = 'Filadelfia', municipio_norm = 'FILADELFIA' WHERE municipio LIKE 'Filad%lfia';
UPDATE covid_completo SET municipio = 'Fortaleza do Tabocao', municipio_norm = 'FORTALEZA DO TABOCAO' WHERE municipio LIKE 'Fortaleza do Taboc%o';
UPDATE covid_completo SET municipio = 'Guarai', municipio_norm = 'GUARAI' WHERE municipio LIKE 'Guara%' AND LENGTH(municipio) < 10;
UPDATE covid_completo SET municipio = 'Itacaja', municipio_norm = 'ITACAJA' WHERE municipio LIKE 'Itacaj%';
UPDATE covid_completo SET municipio = 'Itapora do Tocantins', municipio_norm = 'ITAPORA DO TOCANTINS' WHERE municipio LIKE 'Itapor%do Tocantins';
UPDATE covid_completo SET municipio = 'Jau do Tocantins', municipio_norm = 'JAU DO TOCANTINS' WHERE municipio LIKE 'Ja%do Tocantins';
UPDATE covid_completo SET municipio = 'Lagoa da Confusao', municipio_norm = 'LAGOA DA CONFUSAO' WHERE municipio LIKE 'Lagoa da Confus%o';
UPDATE covid_completo SET municipio = 'Luzinopolis', municipio_norm = 'LUZINOPOLIS' WHERE municipio LIKE 'Luzin%polis';
UPDATE covid_completo SET municipio = 'Marianopolis do Tocantins', municipio_norm = 'MARIANOPOLIS DO TOCANTINS' WHERE municipio LIKE 'Marian%polis do Tocantins';
UPDATE covid_completo SET municipio = 'Maurilandia do Tocantins', municipio_norm = 'MAURILANDIA DO TOCANTINS' WHERE municipio LIKE 'Mauril%ndia do Tocantins';
UPDATE covid_completo SET municipio = 'Muricilandia', municipio_norm = 'MURICILANDIA' WHERE municipio LIKE 'Muricil%ndia';
UPDATE covid_completo SET municipio = 'Nazare', municipio_norm = 'NAZARE' WHERE municipio LIKE 'Nazar%' AND municipio NOT LIKE 'Brejinho%';
UPDATE covid_completo SET municipio = 'Nova Rosalandia', municipio_norm = 'NOVA ROSALANDIA' WHERE municipio LIKE 'Nova Rosal%ndia';
UPDATE covid_completo SET municipio = 'Oliveira de Fatima', municipio_norm = 'OLIVEIRA DE FATIMA' WHERE municipio LIKE 'Oliveira de F%tima';
UPDATE covid_completo SET municipio = 'Palmeiropolis', municipio_norm = 'PALMEIROPOLIS' WHERE municipio LIKE 'Palmeir%polis';
UPDATE covid_completo SET municipio = 'Paraiso do Tocantins', municipio_norm = 'PARAISO DO TOCANTINS' WHERE municipio LIKE 'Para%so do Tocantins';
UPDATE covid_completo SET municipio = 'Parana', municipio_norm = 'PARANA' WHERE municipio LIKE 'Paran%';
UPDATE covid_completo SET municipio = 'Piraque', municipio_norm = 'PIRAQUE' WHERE municipio LIKE 'Piraqu%';
UPDATE covid_completo SET municipio = 'Recursolandia', municipio_norm = 'RECURSOLANDIA' WHERE municipio LIKE 'Recursol%ndia';
UPDATE covid_completo SET municipio = 'Rio da Conceicao', municipio_norm = 'RIO DA CONCEICAO' WHERE municipio LIKE 'Rio da Concei%o';
UPDATE covid_completo SET municipio = 'Sandolandia', municipio_norm = 'SANDOLANDIA' WHERE municipio LIKE 'Sandol%ndia';  
UPDATE covid_completo SET municipio = 'Santa Fe do Araguaia', municipio_norm = 'SANTA FE DO ARAGUAIA' WHERE municipio LIKE 'Santa F%do Araguaia';
UPDATE covid_completo SET municipio = 'Sao Bento do Tocantins', municipio_norm = 'SAO BENTO DO TOCANTINS' WHERE municipio LIKE 'S%o Bento do Tocantins';
UPDATE covid_completo SET municipio = 'Sao Felix do Tocantins', municipio_norm = 'SAO FELIX DO TOCANTINS' WHERE municipio LIKE 'S%o F%lix do Tocantins';
UPDATE covid_completo SET municipio = 'Sao Miguel do Tocantins', municipio_norm = 'SAO MIGUEL DO TOCANTINS' WHERE municipio LIKE 'S%o Miguel do Tocantins';
UPDATE covid_completo SET municipio = 'Sao Salvador do Tocantins', municipio_norm = 'SAO SALVADOR DO TOCANTINS' WHERE municipio LIKE 'S%o Salvador do Tocantins';
UPDATE covid_completo SET municipio = 'Sao Sebastiao do Tocantins', municipio_norm = 'SAO SEBASTIAO DO TOCANTINS' WHERE municipio LIKE 'S%o Sebasti%o do Tocantins';
UPDATE covid_completo SET municipio = 'Sao Valerio', municipio_norm = 'SAO VALERIO' WHERE municipio LIKE 'S%o Val%rio';
UPDATE covid_completo SET municipio = 'Silvanopolis', municipio_norm = 'SILVANOPOLIS' WHERE municipio LIKE 'Silvan%polis';
UPDATE covid_completo SET municipio = 'Sitio Novo do Tocantins', municipio_norm = 'SITIO NOVO DO TOCANTINS' WHERE municipio LIKE 'S%tio Novo do Tocantins';
UPDATE covid_completo SET municipio = 'Talisma', municipio_norm = 'TALISMA' WHERE municipio LIKE 'Talism%';
UPDATE covid_completo SET municipio = 'Tocantinia', municipio_norm = 'TOCANTINIA' WHERE municipio LIKE 'Tocant%nia';
UPDATE covid_completo SET municipio = 'Tocantinopolis', municipio_norm = 'TOCANTINOPOLIS' WHERE municipio LIKE 'Tocantin%polis';
UPDATE covid_completo SET municipio = 'Wanderlandia', municipio_norm = 'WANDERLANDIA' WHERE municipio LIKE 'Wanderl%ndia';
UPDATE cod_completo SET municipio = 'Xambioa', municipio_norm = 'XAMBIOA' WHERE municipio LIKE 'Xambio%';

-- Atualizar também o Araguana que já funciona  
UPDATE covid_completo SET municipio = 'Araguana', municipio_norm = 'ARAGUANA' WHERE municipio LIKE 'Araguan%';

-- Verificar resultado
SELECT COUNT(DISTINCT municipio) AS total_municipios_corrigidos FROM covid_completo;
SELECT DISTINCT municipio FROM covid_completo ORDER BY municipio LIMIT 10;

-- Recriar views
DROP VIEW IF EXISTS superset_poligonos_covid CASCADE;
CREATE OR REPLACE VIEW superset_poligonos_covid AS
WITH covid_agg AS (
    SELECT
        municipio,
        SUM(caso) AS caso,
        SUM(obito) AS obito,
        AVG(tx_incid) AS tx_incid,
        AVG(tx_mort) AS tx_mort,
        AVG(letalidade) AS letalidade,
        MAX(populacao) AS populacao,
        AVG(IDHM) AS IDHM,
        AVG(IDHM_E) AS IDHM_E,
        AVG(IDHM_R) AS IDHM_R,
        AVG(IDHM_L) AS IDHM_L,
        AVG(IVS) AS IVS,
        AVG(IVS_C) AS IVS_C,
        AVG(IVS_R) AS IVS_R,
        AVG(IVS_I) AS IVS_I,
        AVG(IDSC) AS IDSC,
        AVG(gini) AS gini,
        AVG(dens_dem) AS dens_dem,
        AVG(PIB) AS PIB,
        AVG(longitude) AS longitude,
        AVG(latitude) AS latitude
    FROM covid_completo
    GROUP BY municipio
)
SELECT
    g.municipio_id,
    g.municipio_nome,
    g.geometry_json,
    COALESCE(c.caso, 0) AS caso,
    COALESCE(c.obito, 0) AS obito,
    c.tx_incid,
    c.tx_mort,
    c.letalidade,
    c.populacao,
    c.IDHM, c.IDHM_E, c.IDHM_R, c.IDHM_L,
    c.IVS, c.IVS_C, c.IVS_R, c.IVS_I,
    c.IDSC, c.gini, c.dens_dem, c.PIB,
    c.longitude, c.latitude
FROM municipios_geojson g
LEFT JOIN covid_agg c
    ON g.municipio_nome = c.municipio;

DROP VIEW IF EXISTS superset_poligonos_covid_temporal CASCADE;
CREATE OR REPLACE VIEW superset_poligonos_covid_temporal AS
SELECT
    g.municipio_id,
    g.municipio_nome,
    g.geometry_json,
    t.tempo,
    t.ano_semana,
    t.caso,
    t.obito,
    t.tx_incid,
    t.tx_mort,
    t.letalidade,
    t.IDHM,
    t.IVS,
    t.IDSC,
    t.longitude,
    t.latitude
FROM municipios_geojson g
INNER JOIN covid_completo t
    ON g.municipio_nome = t.municipio;

-- RESULTADO FINAL!
SELECT '================================================' AS info;
SELECT '  🎉 FINALIZADO - VERIFICACAO FINAL 🎉  ' AS info;
SELECT '================================================' AS info;

SELECT
    COUNT(*) FILTER (WHERE caso > 0) AS com_dados_covid,
    COUNT(*) FILTER (WHERE caso = 0 OR caso IS NULL) AS sem_match,
    COUNT(*) AS total_139_poligonos
FROM superset_poligonos_covid;

SELECT '================================================' AS info;
SELECT 'Todas as views estao prontas para o Superset!' AS info;
SELECT '================================================' AS info;
