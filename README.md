# Analise de Vendas e Atendimento ao Cliente — BigQuery + Looker Studio

Stack: BigQuery · SQL · Looker Studio
Setor: E-commerce de Educacao
Periodo analisado: Janeiro–Dezembro 2024

[Acessar Dashboard ao vivo](https://datastudio.google.com/reporting/bf6e1328-c0fc-4312-a7f7-c9bb1720682c/page/tEnnC)

---

## O Problema

Uma empresa de cursos online tinha dados espalhados em tres fontes distintas (vendas, cadastros de clientes e tickets de suporte) e nunca havia cruzado essas informacoes de forma estruturada. O objetivo do projeto foi unificar esses dados, garantir a qualidade das metricas e responder 12 perguntas de negocio que orientam decisoes de produto, vendas e atendimento.

---

## Perguntas de Negocio

1. Qual o faturamento total e o ticket medio de vendas no periodo?
2. Como evoluiu a receita mes a mes ao longo de 2024?
3. Quais produtos foram mais vendidos e qual a participacao de cada um na receita?
4. Qual o perfil de renda dos clientes por tipo de produto?
5. Quantos clientes realizaram compras no periodo?
6. Qual a distribuicao geografica dos clientes por estado?
7. Como evoluiu a aquisicao de novos clientes ao longo do tempo?
8. Qual o NPS medio do time de atendimento?
9. Qual o tempo medio de resolucao dos tickets de suporte?
10. Quais os atendentes com melhor desempenho em NPS?
11. Existe relacao entre o tempo de resolucao e a satisfacao do cliente (NPS)?
12. Qual a taxa de resolucao de tickets?

---

## Problemas Encontrados nos Dados

### NPS = 0 nao significava insatisfacao

Na tabela `zendesk`, tickets com `nps = 0` nao representavam clientes insatisfeitos: eram tickets sem avaliacao (o cliente nao respondeu ao formulario de NPS). Isso inflava artificialmente a percepcao de insatisfacao e distorcia todas as medias.

```sql
-- Antes: media incluia zeros (sem avaliacao)
SELECT AVG(nps) FROM zendesk  -- resultado distorcido

-- Depois: apenas tickets avaliados
SELECT AVG(nps) FROM zendesk WHERE nps > 0
```

### Tempo medio incluia tickets ainda abertos

O KPI de tempo medio de atendimento calculava a diferenca de datas incluindo tickets em aberto, cujas datas de fechamento eram parciais ou nulas, inflando o resultado.

Solucao: filtrar `ticket_resolvido = true` antes de calcular qualquer metrica de tempo.

---

## Insights Acionaveis

| Insight | Dados | Acao Recomendada |
|---------|-------|-----------------|
| Clientes que compram curso tem renda media mais alta | Curso R$ 8.510 vs Ebook R$ 8.347 | Estrategia de upsell de mentoria para base de ebook |
| NPS mais alto se concentra em tickets resolvidos em 1 a 3 dias | zendesk filtrado | Definir SLA de resolucao com meta de ate 3 dias |
| 20 atendentes concentram a maior parte dos tickets avaliados | relatorio_final | Foco em capacitacao dos demais para distribuir carga |

### Perfil geral da base (2024)

- Total de clientes: 1.200
- Compras realizadas: 3.000
- Ticket medio: R$ 653,42
- Receita total: R$ 1.960.252
- Renda media geral: R$ 8.364
- Idade media: 38 anos
- Distribuicao de produtos: ebook 34,7% · curso 33,1% · mentoria 32,1%

### Renda media por tipo de produto

- Curso: R$ 8.510,04
- Mentoria: R$ 8.487,43
- Ebook: R$ 8.346,50

---

## Fontes de Dados

```
projeto: curso-eba-493312
dataset: AulasSQL
```

| Tabela | Descricao | Campos principais |
|--------|-----------|-------------------|
| `compras` | Transacoes de venda | id_usuario, product_type, valor, data_compra, status |
| `usuarios` | Cadastro de clientes | id_usuario, renda, idade, estado |
| `zendesk` | Tickets de suporte | atendente, nps, ticket_resolvido, data_envio, ticket_closed |
| `relatorio_final` | Tabela consolidada (37 colunas) | Todas as colunas acima unificadas via LEFT JOIN |

---

## Decisoes Tecnicas

### Construcao da tabela relatorio_final no BigQuery

Para cruzar os dados de vendas, perfil de clientes e atendimento em uma unica fonte, foi criada a tabela `relatorio_final` no BigQuery como uma tabela desnormalizada com 37 colunas. A logica utilizada foi um LEFT JOIN entre as tres fontes:

```
relatorio_final:
  compras    (base)
  LEFT JOIN usuarios ON id_usuario
  LEFT JOIN zendesk  ON id_usuario
```

Isso elimina a necessidade de joins no momento da consulta e simplifica a criacao de visualizacoes no Looker Studio, que utiliza essa tabela como unica fonte de dados para o dashboard.

### Filtros aplicados por componente

| Componente | Filtro | Motivo |
|-----------|--------|--------|
| KPIs de NPS | `nps > 0` | Excluir tickets sem avaliacao |
| Tabela de atendentes | `nps > 0` | Mesma razao |
| KPI tempo medio | `ticket_resolvido = true` | Excluir tickets em aberto |
| Grafico NPS x tempo | `nps > 0` + `ticket_resolvido = true` | Analise limpa de ambas as metricas |

---

## O Dashboard

O dashboard foi construido no Looker Studio com 4 secoes:

1. Visao Geral de Compras: meta de vendas, evolucao mensal, ticket medio
2. Visao de Produtos: distribuicao e receita por tipo (ebook, curso, mentoria)
3. Perfil de Usuarios: mapa por estado, renda media por produto, distribuicao mensal de novos clientes
4. Atendimento: ranking Top 20 atendentes por NPS, correlacao NPS x tempo de resolucao

---

## Estrutura do Repositorio

```
ecommerce-analytics-bigquery/
├── README.md
├── sql/
│   ├── 01_exploracao_nps.sql        # Diagnostico dos zeros no NPS
│   ├── 02_atendimento_performance.sql  # Ranking de atendentes
│   ├── 03_perfil_usuario.sql        # Renda e perfil por produto
│   └── 04_relatorio_final.sql       # Query consolidada do dashboard
└── screenshots/
    └── (prints do dashboard)
```

---

## O que esse projeto demonstra

- Limpeza de dados real: identificacao e correcao de um bug de logica de negocio (NPS=0 diferente de insatisfacao real)
- Joins entre multiplas fontes: cruzamento de dados de vendas, CRM e suporte em uma unica tabela no BigQuery
- Raciocinio analitico: nao so "o que os dados mostram" mas "por que os dados estavam errados"
- Storytelling com dados: cada visual tem uma pergunta clara que responde
- Decisoes de BI: escolha consciente de filtros, agregacoes e tipos de grafico para nao distorcer a leitura

---

*Projeto desenvolvido como parte do curso de analise de dados — [Ana Carolina Lira](https://carolinaflira.github.io)*
