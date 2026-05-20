# 📊 Análise de Vendas & Atendimento ao Cliente — BigQuery + Looker Studio

> **Stack:** BigQuery · SQL · Looker Studio · Data Blending  
> **Setor:** E-commerce de Educação  
> **Período analisado:** Janeiro–Dezembro 2024

🔗 **[Acessar Dashboard ao vivo](https://datastudio.google.com/reporting/bf6e1328-c0fc-4312-a7f7-c9bb1720682c/page/tEnnC)**

---

## 🎯 O Problema

Uma empresa de cursos online precisava responder três perguntas estratégicas que seus relatórios padrão não conseguiam responder:

1. **Quem são nossos melhores atendentes?**
2. **Existe relação entre a demora no atendimento e a satisfação do cliente (NPS)?**
3. **Qual o perfil de renda do nosso público por tipo de produto?**

Os dados existiam, mas estavam espalhados em três fontes distintas e nunca tinham sido cruzados.

---

## 🔍 Descobertas — Onde Estava o Problema Real

### ⚠️ NPS = 0 não significava insatisfação
Tickets com nps = 0 eram tickets sem avaliação, não clientes insatisfeitos.
Filtro aplicado: WHERE nps > 0

### ⚠️ Tempo médio incluía tickets em aberto
Filtro aplicado: WHERE ticket_resolvido = true

---

## 📈 Insights Acionáveis

| Insight | Dados | Ação Recomendada |
|--------|-------|-----------------|
| Clientes de **curso** têm renda média ~R$ 9.000 | Cruzamento compras × usuários | Aumentar preço ou criar upsell |
| Clientes de **mentoria** têm renda média ~R$ 8.500 | Cruzamento compras × usuários | Ampliar oferta de mentoria premium |
| Clientes de **ebook** têm renda média ~R$ 7.000 | Cruzamento compras × usuários | Porta de entrada ideal para funil |
| NPS alto se concentra em tickets resolvidos em **1–3 dias** | zendesk filtrado | SLA meta: ≤ 3 dias |

---

## 🗂️ Fontes de Dados

Projeto: curso-eba-493312 | Dataset: AulasSQL

| Tabela | Descrição |
|--------|-----------|
| compras | Transações de venda |
| usuarios | Cadastro de clientes |
| zendesk | Tickets de suporte |
| relatorio_final | View consolidada |

---

## 💡 O que esse projeto demonstra

- **Limpeza de dados real:** bug de lógica de negócio (NPS=0 ≠ insatisfação)
- **Joins entre múltiplas fontes:** vendas, CRM e suporte
- **Raciocínio analítico:** por que os dados estavam errados
- **Storytelling com dados:** cada visual responde uma pergunta clara
