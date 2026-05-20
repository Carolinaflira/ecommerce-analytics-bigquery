-- ============================================================
-- 02 — Performance dos Atendentes
-- Projeto: curso-eba-493312 | Dataset: AulasSQL
-- ============================================================
-- CONTEXTO:
--   Ranking dos atendentes por NPS médio e tempo de resolução.
--   Filtros aplicados:
--     - nps > 0: exclui tickets sem avaliação
--     - ticket_resolvido = true: exclui tickets em aberto
--       (tickets abertos distorcem o tempo médio pois não têm
--       data de fechamento definitiva)
-- ============================================================


-- 1. Ranking Top 20 atendentes (base do dashboard)
SELECT
    atendente,
    ROUND(AVG(nps), 2)                                         AS nps_medio,
    ROUND(AVG(DATE_DIFF(ticket_closed, data_envio, DAY)), 1)   AS tempo_medio_dias,
    COUNT(*)                                                    AS qtd_tickets
FROM `curso-eba-493312.AulasSQL.zendesk`
WHERE nps > 0
  AND ticket_resolvido = true
GROUP BY atendente
ORDER BY nps_medio DESC
LIMIT 20;


-- 2. Comparação: tempo médio COM e SEM tickets em aberto
--    (justificativa para o filtro ticket_resolvido = true)
SELECT
    'Todos os tickets'            AS escopo,
    ROUND(AVG(DATE_DIFF(ticket_closed, data_envio, DAY)), 1) AS tempo_medio_dias,
    COUNT(*)                      AS total
FROM `curso-eba-493312.AulasSQL.zendesk`
WHERE nps > 0

UNION ALL

SELECT
    'Somente resolvidos'          AS escopo,
    ROUND(AVG(DATE_DIFF(ticket_closed, data_envio, DAY)), 1) AS tempo_medio_dias,
    COUNT(*)                      AS total
FROM `curso-eba-493312.AulasSQL.zendesk`
WHERE nps > 0
  AND ticket_resolvido = true;


-- 3. Correlação NPS × Tempo de Resolução
--    (base do gráfico de barras adicionado ao dashboard)
SELECT
    nps,
    COUNT(*)                                                   AS qtd_tickets,
    ROUND(AVG(DATE_DIFF(ticket_closed, data_envio, DAY)), 1)  AS tempo_medio_dias
FROM `curso-eba-493312.AulasSQL.zendesk`
WHERE nps > 0
  AND ticket_resolvido = true
GROUP BY nps
ORDER BY nps;

-- INSIGHT:
--   NPS mais altos (8, 9, 10) tendem a se concentrar em
--   tickets resolvidos em 1–3 dias.
--   NPS mais baixos têm tempo médio maior.


-- 4. Visão geral do atendimento (KPIs do dashboard)
SELECT
    COUNT(*)                                                   AS total_tickets,
    SUM(CASE WHEN ticket_resolvido = true THEN 1 ELSE 0 END)  AS tickets_resolvidos,
    SUM(CASE WHEN ticket_resolvido = false THEN 1 ELSE 0 END) AS tickets_em_aberto,
    ROUND(AVG(CASE WHEN nps > 0 THEN nps END), 2)            AS nps_medio,
    ROUND(
        AVG(CASE WHEN ticket_resolvido = true
                 THEN DATE_DIFF(ticket_closed, data_envio, DAY) END),
        1
    )                                                          AS tempo_medio_resolucao_dias
FROM `curso-eba-493312.AulasSQL.zendesk`;
