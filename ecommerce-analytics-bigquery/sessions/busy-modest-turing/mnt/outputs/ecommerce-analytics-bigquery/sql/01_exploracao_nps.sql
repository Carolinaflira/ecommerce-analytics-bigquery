-- ============================================================
-- 01 — Exploração e diagnóstico do campo NPS
-- Projeto: curso-eba-493312 | Dataset: AulasSQL
-- ============================================================
-- CONTEXTO:
--   Durante a exploração inicial, notamos que NPS = 0 estava
--   inflando a contagem de clientes "insatisfeitos". Esta query
--   investigou a distribuição real dos valores de NPS para
--   entender o que de fato os zeros representavam.
-- ============================================================


-- 1. Distribuição de NPS — incluindo zeros
SELECT
    nps,
    COUNT(*) AS qtd_tickets,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_total
FROM `curso-eba-493312.AulasSQL.zendesk`
GROUP BY nps
ORDER BY nps;

-- RESULTADO:
--   nps = 0 → representava tickets sem avaliação do cliente
--   (o formulário de NPS não foi respondido, não insatisfação real)


-- 2. Comparação: NPS médio COM e SEM os zeros
SELECT
    'Com zeros (incorreto)'  AS cenario,
    ROUND(AVG(nps), 2)       AS nps_medio,
    COUNT(*)                 AS total_tickets
FROM `curso-eba-493312.AulasSQL.zendesk`

UNION ALL

SELECT
    'Sem zeros (correto)'    AS cenario,
    ROUND(AVG(nps), 2)       AS nps_medio,
    COUNT(*)                 AS total_tickets
FROM `curso-eba-493312.AulasSQL.zendesk`
WHERE nps > 0;

-- Esse resultado foi apresentado para justificar o filtro
-- aplicado em todos os KPIs e gráficos do dashboard.


-- 3. Tickets sem avaliação vs. avaliados
SELECT
    CASE WHEN nps = 0 THEN 'Sem avaliação (nps=0)' ELSE 'Avaliados (nps>0)' END AS status_avaliacao,
    COUNT(*)                                                                       AS qtd_tickets,
    ROUND(AVG(CASE WHEN nps > 0 THEN nps END), 2)                                AS nps_medio_real
FROM `curso-eba-493312.AulasSQL.zendesk`
GROUP BY status_avaliacao;


-- 4. Distribuição de NPS apenas dos avaliados (para o dashboard)
SELECT
    nps,
    COUNT(*) AS qtd_tickets,
    ROUND(AVG(DATE_DIFF(ticket_closed, data_envio, DAY)), 1) AS tempo_medio_dias
FROM `curso-eba-493312.AulasSQL.zendesk`
WHERE nps > 0
  AND ticket_resolvido = true
GROUP BY nps
ORDER BY nps;
