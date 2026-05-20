-- ============================================================
-- 03 — Perfil de Usuários × Tipo de Produto
-- Projeto: curso-eba-493312 | Dataset: AulasSQL
-- ============================================================
-- CONTEXTO:
--   Cruzamento entre dados de compras e perfil dos usuários.
--   Objetivo: entender se o perfil de renda varia por produto
--   — informação estratégica para precificação e targeting.
--
--   No Looker Studio, esse cruzamento foi feito via Data Blending.
--   Aqui, a mesma lógica é reproduzida em SQL puro com JOIN.
--
--   CUIDADO com pré-agregação: ao blender no Looker Studio,
--   id_usuario deve ser DIMENSÃO (não métrica) na tabela compras
--   para que o join funcione corretamente.
-- ============================================================


-- 1. Renda média por tipo de produto
--    (base do gráfico de barras horizontais "Renda × Produto")
SELECT
    c.product_type,
    ROUND(AVG(u.renda), 2)  AS renda_media,
    COUNT(DISTINCT u.id_usuario) AS qtd_clientes_unicos
FROM `curso-eba-493312.AulasSQL.compras` c
INNER JOIN `curso-eba-493312.AulasSQL.usuarios` u
    ON c.id_usuario = u.id_usuario
GROUP BY c.product_type
ORDER BY renda_media DESC;

-- INSIGHT:
--   curso    → renda média ~R$ 9.000
--   mentoria → renda média ~R$ 8.500
--   ebook    → renda média ~R$ 7.000
--
--   Ebook funciona como porta de entrada do funil.
--   Clientes de mentoria têm poder aquisitivo para upsell.


-- 2. Perfil demográfico geral dos usuários
SELECT
    COUNT(DISTINCT id_usuario)  AS total_usuarios,
    ROUND(AVG(renda), 2)        AS renda_media,
    ROUND(AVG(idade), 0)        AS idade_media,
    estado,
    COUNT(*) AS qtd_por_estado
FROM `curso-eba-493312.AulasSQL.usuarios`
GROUP BY estado
ORDER BY qtd_por_estado DESC;


-- 3. Novos clientes por mês (evolução da aquisição)
SELECT
    FORMAT_DATE('%Y-%m', data_compra)  AS mes,
    COUNT(DISTINCT id_usuario)          AS novos_clientes
FROM `curso-eba-493312.AulasSQL.compras`
GROUP BY mes
ORDER BY mes;


-- 4. Distribuição de compras por produto e status
SELECT
    product_type,
    status,
    COUNT(*)                    AS qtd_compras,
    ROUND(SUM(valor), 2)        AS receita_total,
    ROUND(AVG(valor), 2)        AS ticket_medio
FROM `curso-eba-493312.AulasSQL.compras`
GROUP BY product_type, status
ORDER BY product_type, status;
