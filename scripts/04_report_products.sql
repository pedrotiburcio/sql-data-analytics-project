/*
===============================================================================
Relatório de Produtos
===============================================================================
Objetivo:
    - Este relatório consolida as principais métricas e comportamentos dos produtos.

Destaques:
    1. Reúne campos essenciais como nome do produto, categoria, subcategoria e custo.
    2. Segmenta os produtos por receita para identificar High-Performers, Mid-Range ou Low-Performers.
    3. Agrega métricas ao nível do produto:
       - total de pedidos
       - total de vendas
       - quantidade total vendida
       - total de clientes únicos
       - tempo de vida (lifespan em meses)
    4. Calcula KPIs valiosos:
       - recência (meses desde a última venda)
       - receita média por pedido (AOR)
       - receita mensal média
===============================================================================
*/

-- =============================================================================
-- Criar Relatório: gold.report_products
-- =============================================================================
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Consulta Base: Recuperar colunas principais de fact_sales e dim_products
---------------------------------------------------------------------------*/
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL  -- Considerar apenas datas de vendas válidas
),

product_aggregations AS (
/*---------------------------------------------------------------------------
2) Agregação por Produto: Resumir métricas principais ao nível do produto
---------------------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
    MAX(order_date) AS last_sale_date,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
FROM base_query
GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost
)

/*---------------------------------------------------------------------------
  3) Consulta Final: Combinar todos os resultados de produtos em uma saída
---------------------------------------------------------------------------*/
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
    -- Segmentar produtos por desempenho de receita
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    -- Receita Média por Pedido (AOR)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    -- Receita Mensal Média
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue
FROM product_aggregations;
GO