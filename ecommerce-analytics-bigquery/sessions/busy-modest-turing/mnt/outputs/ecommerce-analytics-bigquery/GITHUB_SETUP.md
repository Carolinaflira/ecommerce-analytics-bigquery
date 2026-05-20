# Como subir esse projeto no GitHub

## Passo 1 — Criar o repositório no GitHub

1. Acesse https://github.com/new
2. Preencha:
   - **Repository name:** `ecommerce-analytics-bigquery`
   - **Description:** `Análise de vendas e atendimento ao cliente com BigQuery + Looker Studio — identificação de bugs nos dados e geração de insights acionáveis`
   - **Visibility:** Public ✅ (portfólio precisa ser público)
   - **NÃO** marque "Add a README file" (já temos um)
3. Clique em **Create repository**

---

## Passo 2 — Subir os arquivos pelo terminal

Abra o terminal na pasta onde estão os arquivos e rode:

```bash
# Entrar na pasta do projeto
cd ecommerce-analytics-bigquery

# Iniciar o git
git init

# Adicionar todos os arquivos
git add .

# Primeiro commit
git commit -m "feat: análise completa de vendas e atendimento com BigQuery + Looker Studio"

# Conectar ao repositório que você criou no GitHub
git remote add origin https://github.com/carolinaflira/ecommerce-analytics-bigquery.git

# Enviar para o GitHub
git push -u origin main
```

> Se der erro no `git push` com `main`, tente:
> ```bash
> git branch -M main
> git push -u origin main
> ```

---

## Passo 3 — Adicionar screenshots (recomendado)

1. Tire prints das seções do dashboard (Cmd+Shift+4 no Mac ou Print Screen no Windows)
2. Salve na pasta `screenshots/` com nomes descritivos:
   - `01_visao_geral.png`
   - `02_produtos.png`
   - `03_perfil_usuarios.png`
   - `04_atendimento_ranking.png`
3. Adicione ao README (já tem o placeholder `> 📸 Screenshots na pasta /screenshots`)
4. Suba novamente:
   ```bash
   git add screenshots/
   git commit -m "docs: adiciona screenshots do dashboard"
   git push
   ```

---

## Resultado final

Seu repositório ficará em:
**https://github.com/carolinaflira/ecommerce-analytics-bigquery**
