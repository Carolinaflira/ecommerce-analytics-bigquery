# 📊 Análise de Vendas & Atendimento ao Cliente — BigQuery + Looker Studio

> **Stack:** BigQuery · SQL · Looker Studio · Data Blending  
> **Setor:** E-commerce de Educação  
> **Período analisado:** Janeiro–Dezembro 2024

🔗 **[Acessar Dashboard ao vivo](https://datastudio.google.com/reporting/bf6e1328-c0fc-4312-a7f7-c9bb1720682c/page/tEnnC)**

---

## 🎯 O Problema

Uma empresa de cursos online precisava responder três perguntas estratégicas que seus relatórios padrão não conseguiam responder:

1. **Quem são nossos melhores atendentes?** — e como medir isso de forma justa, sem distorções nos dados
2. **Existe relação entre a demora no atendimento e a satisfação do cliente (NPS)?**
3. **Qual o perfil de renda do nosso público por tipo de produto?** — para orientar precificação e marketing

Os dados existiam, mas estavam espalhados em três fontes distintas (vendas, usuários e tickets de suporte) e nunca tinham sido cruzados.

---

## 🔍 Descobertas — Onde Estava o Problema Real

### ⚠️ Dado com bug: NPS = 0 não significava insatisfação

Ao explorar os dados da tabela `zendesk`, identifiquei que tickets com `nps = 0` não representavam clientes insatisfeitos — eram **tickets sem avaliação** (o cliente não respondeu ao formulário de NPS). Isso inflava artificialmente a percepção de insatisfação e distorcia todas as médias.

**Impacto:** O NPS médio calculado originalmente estava incorreto. Após filtrar `nps > 0`, a média do time subiu significativamente — refletindo a realidade.

```sql
-- Antes: média incluía zeros (sem avaliação)
SELECT AVG(nps) FROM zendesk  -- resultado distorcido

-- Depois: apenas tickets avaliados
SELECT AVG(nps) FROM zendesk WHERE nps > 0
```

### ⚠️ Tempo médio de resolução incluía tickets ainda abertos

O KPI de "tempo médio de atendimento" calculava a diferença de datas incluindo tickets ainda em aberto — ou seja, tickets com `ticket_resolvido = false` entravam no cálculo com datas parciais, inflando artificialmente o tempo médio.

**Solução:** Filtrar apenas `ticket_resolvido = true` antes de calcular qualquer métrica de tempo.

---

## 📈 Insights Acionáveis

| Insight | Dados | Ação Recomendada |
|--------|-------|-----------------|
| Clientes de **curso** têm renda média ~R$ 9.000 | Cruzamento compras × usuários | Aumentar preço ou criar upsell |
| Clientes de **mentoria** têm renda média ~R$ 8.500 | Cruzamento compras × usuários | Ampliar oferta de mentoria premium |
| Clientes de **ebook** têm renda média ~R$ 7.000 | Cruzamento compras × usuários | Porta de entrada ideal para funil |
| NPS mais alto se concentra em tickets resolvidos em **1–3 dias** | zendesk filtrado | SLA de resolução: meta ≤ 3 dias |
| **20 atendentes** são responsáveis pela maioria dos tickets | relatorio_final | Foco em treinamento dos demais |

### Perfil geral da base (2024):
- **3.000 compras** realizadas · Ticket médio: **R$ 653,42**
- **1.200 usuários únicos** · Renda média: **R$ 8.364** · Idade média: **38 anos**
- Receita total: **R$ 1.960.252**
- Distribuição de produtos: ebook 34,7% · curso 33,1% · mentoria 32,1%

---

## 🗂️ Fontes de Dados

```
projeto: curso-eba-493312
dataset: AulasSQL
```

| Tabela | Descrição | Campos principais |
|--------|-----------|-------------------|
| `compras` | Transações de venda | id_usuario, product_type, valor, data_compra, status |
| `usuarios` | Cadastro de clientes | id_usuario, renda, idade, estado |
| `zendesk` | Tickets de suporte | id_atendente, nps, dias_diferenca, ticket_resolvido, data_envio |
| `relatorio_final` | View consolidada | atendente, nps_medio, tempo_medio, qtd_tickets |

---

## 🛠️ Decisões Técnicas

### Data Blending no Looker Studio
Para cruzar renda (tabela `usuarios`) com tipo de produto (tabela `compras`), foi necessário criar um **blend de dados** no próprio Looker Studio.

**Problema encontrado:** A pré-agregação do Looker Studio agrupa cada tabela pelas suas dimensões *antes* do join. Se `id_usuario` estiver como métrica em vez de dimensão na tabela de compras, o join retorna vazio.

**Solução:** Adicionar `id_usuario` como **dimensão** (não métrica) na Tabela 1 do blend, garantindo que o join com `id_usuario` da tabela de usuários funcione corretamente.

```
Blend: compras × usuarios
├── Tabela 1 (compras): Dimensões → [product_type, id_usuario]
├── Tabela 2 (usuarios): Dimensões → [id_usuario] | Métricas → [AVG(renda)]
└── Join: id_usuario ↔ id_usuario (Left outer join)
```

### Filtros aplicados por componente

| Componente | Filtro | Motivo |
|-----------|--------|--------|
| KPIs de NPS | `nps > 0` | Excluir tickets sem avaliação |
| Tabela de atendentes | `nps > 0` | Mesma razão |
| KPI tempo médio | `ticket_resolvido = true` | Excluir tickets em aberto |
| Gráfico NPS × tempo | `nps > 0` + `ticket_resolvido = true` | Análise limpa de ambos |

---

## 📊 O Dashboard

O dashboard foi construído no Looker Studio com 4 seções:

**1. Visão Geral de Compras** — Meta de vendas, evolução mensal, ticket médio  
**2. Visão de Produtos** — Distribuição e receita por tipo (ebook, curso, mentoria)  
**3. Perfil de Usuários** — Mapa por estado, renda média por produto, distribuição mensal de novos clientes  
**4. Atendimento** — Ranking Top 20 atendentes por NPS, correlação NPS × tempo de resolução

> 📸 *Screenshots na pasta `/screenshots` do repositório*

---

## 🗃️ Estrutura do Repositório

```
ecommerce-analytics-bigquery/
├── README.md
├── sql/
│   ├── 01_exploracao_nps.sql        # Diagnóstico dos zeros no NPS
│   ├── 02_atendimento_performance.sql  # Ranking de atendentes
│   ├── 03_perfil_usuario.sql        # Renda e perfil por produto
│   └── 04_relatorio_final.sql       # Query consolidada do dashboard
└── screenshots/
    └── (adicionar prints do dashboard aqui)
```

---

## 💡 O que esse projeto demonstra

- **Limpeza de dados real:** identificação e correção de um bug de lógica de negócio (NPS=0 ≠ insatisfação)
- **Joins entre múltiplas fontes:** cruzamento de dados de vendas, CRM e suporte
- **Raciocínio analítico:** não só "o que os dados mostram" mas "por que os dados estavam errados"
- **Storytelling com dados:** cada visual tem uma pergunta clara que responde
- **Decisões de BI:** escolha consciente de filtros, agregações e tipos de gráfico para não enganar o leitor

---

*Projeto desenvolvido como parte do curso de análise de dados — [Ana Carolina Lira](https://carolinaflira.github.io)*
