-- ============================================================
-- 04 — Relatorio Consolidado (View do Dashboard)
-- Projeto: curso-eba-493312 | Dataset: AulasSQL
-- ============================================================

-- 1. KPIs gerais de vendas
SELECT
    COUNT(*) AS total_compras,
    COUNT(DISTINCT id_usuario) AS clientes_unicos,
    ROUND(SUM(valor), 2) AS receita_total,
    ROUND(AVG(valor), 2) AS ticket_medio,
    MIN(data_compra) AS primeira_compra,
    MAX(data_compra) AS ultima_compra
FROM `curso-eba-493312.AulasSQL.compras`;

-- 2. Receita e volume por mes (evolucao 2024)
SELECT
    FORMAT_DATE('%b %Y', data_compra) AS mes,
    FORMAT_DATE('%Y-%m', data_compra) AS mes_ordem,
    COUNT(*) AS qtd_compras,
    ROUND(SUM(valor), 2) AS receita_total,
    ROUND(AVG(valor), 2) AS valor_medio
FROM `curso-eba-493312.AulasSQL.compras`
GROUP BY mes, mes_ordem ORDER BY mes_ordem;

-- 3. Distribuicao de produtos vendidos
SELECT
    product_type,
    COUNT(*) AS qtd_vendas,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_volume,
    ROUND(SUM(valor), 2) AS receita,
    ROUND(SUM(valor) * 100.0 / SUM(SUM(valor)) OVER (), 1) AS pct_receita
FROM `curso-eba-493312.AulasSQL.compras`
GROUP BY product_type ORDER BY qtd_vendas DESC;

-- 4. View consolidada de atendimento (fonte do dashboard)
SELECT
    atendente,
    ROUND(AVG(nps), 2) AS nps_medio,
    ROUND(AVG(DATE_DIFF(ticket_closed, data_envio, DAY)), 1) AS tempo_medio_dias,
    COUNT(*) AS qtd_tickets,
    SUM(CASE WHEN ticket_resolvido = true THEN 1 ELSE 0 END) AS tickets_resolvidos
FROM `curso-eba-493312.AulasSQL.zendesk`
WHERE nps > 0
GROUP BY atendente ORDER BY nps_medio DESC;

-- 5. Receita por tipo de produto ao longo do tempo
SELECT
    FORMAT_DATE('%Y-%m', data_compra) AS mes,
    product_type,
    ROUND(SUM(valor), 2) AS receita
FROM `curso-eba-493312.AulasSQL.compras`
GROUP BY mes, product_type ORDER BY mes, product_type;
