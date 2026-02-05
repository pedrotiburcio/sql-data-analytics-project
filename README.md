# 📊 SQL Data Analytics: Inteligência de Negócios e Análise de Performance

Este projeto demonstra a aplicação de técnicas avançadas de SQL para transformar dados brutos em insights estratégicos. O foco principal é a extração e transformação de dados provenientes de um ambiente de Data Warehouse para gerar indicadores de performance (KPIs) sobre o comportamento de clientes e o desempenho de produtos.

## 🛠️ Escopo Analítico
O projeto utiliza SQL para navegar por grandes volumes de dados e consolidar visões analíticas fundamentais para a gestão do negócio:

* **Exploração de Dados (EDA):** Auditoria e diagnóstico da base de dados para garantir a confiabilidade das métricas e entender a distribuição das dimensões (Clientes e Produtos).
* **Análise Avançada de Negócio:** Implementação de lógica analítica complexa utilizando CTEs e Window Functions para calcular tendências e métricas acumulativas.
* **Desenvolvimento de KPIs Estratégicos:** Criação de métricas como **AOV** (*Average Order Value*), **Recência** e **Lifespan** para medir a saúde do relacionamento com o cliente.
* **Camada de Entrega (Reporting):** Construção de **Views** de relatório que simplificam dados complexos, servindo como "fonte única da verdade" para dashboards e tomadores de decisão.

---

## 🔍 Técnicas Analíticas Aplicadas
Os scripts deste repositório cobrem as principais necessidades de análise de um ambiente corporativo:

* **Mudanças ao Longo do Tempo:** Análise da evolução mensal de vendas e aquisição de clientes.
* **Análise Cumulativa:** Cálculos de *Running Total* e Médias Móveis para suavização de tendências.
* **Análise de Desempenho:** Comparação Ano a Ano (**YoY**) e análise de desvios em relação às médias históricas.
* **Segmentação de Dados:** Classificação de clientes (**VIP/Regular/Novo**) e agrupamento de produtos por faixas de custo.
* **Análise de Participação (Part-to-Whole):** Cálculo da contribuição percentual de cada categoria no faturamento total.

---

## 💡 Key Insights (Destaques de Negócio)
* **Segmentação de Base:** Identificação automatizada de clientes de alto valor (VIP) e novos clientes, permitindo estratégias de retenção direcionadas.
* **Performance de Produto:** Diferenciação clara entre produtos *High-Performers* e *Low-Performers*, facilitando a gestão de estoque e marketing.
* **Monitoramento de Tendências:** Visibilidade sobre o crescimento da receita e identificação de períodos de sazonalidade através de métricas comparativas.

---

## 📂 Estrutura do Repositório
Para facilitar a navegação, os scripts foram organizados na seguinte ordem lógica:

1.  `01_database_setup.sql`: Criação do banco de dados, schemas e carga de dados via Bulk Insert.
2.  `02_exploratory_analysis.sql`: Scripts voltados para a exploração inicial e limpeza dos dados.
3.  `03_advanced_analysis.sql`: Aplicação de lógicas complexas e métricas de negócio.
4.  `04_report_customers.sql`: Criação da View consolidada de métricas de Clientes.
5.  `05_report_products.sql`: Criação da View consolidada de métricas de Produtos.

---

## 💻 Tecnologias e Ferramentas
* **Linguagem:** SQL (T-SQL)
* **IDE:** Microsoft SQL Server Management Studio (SSMS)
* **Principais Conceitos SQL:**
    * Common Table Expressions (CTEs)
    * Window Functions (`RANK`, `DATEDIFF`, `SUM OVER`)
    * Lógica Condicional (`CASE WHEN`)
    * Agregações e Joins complexos
    * Data Modeling (Star Schema)

---
*Desenvolvido por Pedro Tibúrcio – Conecte-se comigo no [LinkedIn](https://www.linkedin.com/in/pedro-tiburcio/)*
