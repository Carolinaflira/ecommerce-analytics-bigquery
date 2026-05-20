-- ============================================================
-- 03 — Perfil de Usuarios x Tipo de Produto
-- Projeto: curso-eba-493312 | Dataset: AulasSQL
-- ============================================================

-- 1. Renda media por tipo de produto
SELECT
    c.product_type,
    ROUND(AVG(u.renda), 2) AS renda_media,
    COUNT(DISTINCT u.id_usuario) AS qtd_clientes_unicos
FROM `curso-eba-493312.AulasSQL.compras` c
INNER JOIN `curso-eba-493312.AulasSQL.usuarios` u ON c.id_usuario = u.id_usuario
GROUP BY c.product_type
ORDER BY renda_media DESC;

-- INSIGHT:
--   curso    -> renda media ~R$ 9.000
--   mentoria -> renda media ~R$ 8.500
--   ebook    -> renda media ~R$ 7.000 (porta de entrada do funil)

-- 2. Perfil demografico geral dos usuarios
SELECT
    COUNT(DISTINCT id_usuario) AS total_usuarios,
    ROUND(AVG(renda), 2) AS renda_media,
    ROUND(AVG(idade), 0) AS idade_media,
    estado,
    COUNT(*) AS qtd_por_estado
FROM `curso-eba-493312.AulasSQL.usuarios`
GROUP BY estado
ORDER BY qtd_por_estado DESC;

-- 3. Novos clientes por mes
SELECT
    FORMAT_DATE('%Y-%m', data_compra) AS mes,
    COUNT(DISTINCT id_usuario) AS novos_clientes
FROM `curso-eba-493312.AulasSQL.compras`
GROUP BY mes ORDER BY mes;

-- 4. Distribuicao de compras por produto e status
SELECT
    product_type, status,
    COUNT(*) AS qtd_compras,
    ROUND(SUM(valor), 2) AS receita_total,
    ROUND(AVG(valor), 2) AS ticket_medio
FROM `curso-eba-493312.AulasSQL.compras`
GROUP BY product_type, status
ORDER BY product_type, status;
