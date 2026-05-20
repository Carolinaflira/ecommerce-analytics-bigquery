-- ============================================================
-- 02 — Performance dos Atendentes
-- Projeto: curso-eba-493312 | Dataset: AulasSQL
-- ============================================================
-- Filtros: nps > 0 (exclui sem avaliacao) | ticket_resolvido = true

-- 1. Ranking Top 20 atendentes
SELECT
    atendente,
    ROUND(AVG(nps), 2)                                         AS nps_medio,
    ROUND(AVG(DATE_DIFF(ticket_closed, data_envio, DAY)), 1)   AS tempo_medio_dias,
    COUNT(*)                                                    AS qtd_tickets
FROM `curso-eba-493312.AulasSQL.zendesk`
WHERE nps > 0 AND ticket_resolvido = true
GROUP BY atendente
ORDER BY nps_medio DESC
LIMIT 20;

-- 2. Comparacao: tempo medio COM e SEM tickets em aberto
SELECT 'Todos os tickets' AS escopo,
    ROUND(AVG(DATE_DIFF(ticket_closed, data_envio, DAY)), 1) AS tempo_medio_dias,
    COUNT(*) AS total
FROM `curso-eba-493312.AulasSQL.zendesk` WHERE nps > 0
UNION ALL
SELECT 'Somente resolvidos' AS escopo,
    ROUND(AVG(DATE_DIFF(ticket_closed, data_envio, DAY)), 1) AS tempo_medio_dias,
    COUNT(*) AS total
FROM `curso-eba-493312.AulasSQL.zendesk`
WHERE nps > 0 AND ticket_resolvido = true;

-- 3. Correlacao NPS x Tempo de Resolucao
SELECT
    nps,
    COUNT(*) AS qtd_tickets,
    ROUND(AVG(DATE_DIFF(ticket_closed, data_envio, DAY)), 1) AS tempo_medio_dias
FROM `curso-eba-493312.AulasSQL.zendesk`
WHERE nps > 0 AND ticket_resolvido = true
GROUP BY nps ORDER BY nps;

-- 4. KPIs gerais do atendimento
SELECT
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN ticket_resolvido = true THEN 1 ELSE 0 END) AS tickets_resolvidos,
    SUM(CASE WHEN ticket_resolvido = false THEN 1 ELSE 0 END) AS tickets_em_aberto,
    ROUND(AVG(CASE WHEN nps > 0 THEN nps END), 2) AS nps_medio,
    ROUND(AVG(CASE WHEN ticket_resolvido = true
        THEN DATE_DIFF(ticket_closed, data_envio, DAY) END), 1) AS tempo_medio_resolucao_dias
FROM `curso-eba-493312.AulasSQL.zendesk`;
