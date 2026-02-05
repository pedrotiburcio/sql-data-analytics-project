-- =========================================
--	Projeto: Análise Avançada de Dados
-- =========================================

------------------------------
-- 7. Mudanças ao Longo do Tempo -- 
------------------------------

-- Encontrar a evolução mensal de vendas, clientes e quantidade
SELECT 
YEAR(order_date) order_year,
MONTH(order_date) order_month, 
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)

------------------------------
-- 8. Análise Cumulativa -- 
------------------------------

-- Calcular o total de vendas por mês, o total acumulado (running total)
-- e a média móvel do preço
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
    avg_price,
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
    SELECT 
        DATETRUNC(year, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) t

------------------------------
-- 9. Análise de Desempenho -- 
------------------------------

/* Analisar o desempenho anual dos produtos comparando suas vendas
com a média histórica e com as vendas do ano anterior */
WITH yearly_product_sales AS (
    SELECT 
        YEAR(f.order_date) AS order_year, 
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER(PARTITION BY product_name) as average_sales,
    current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
    CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
         WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
         ELSE 'Avg'
    END avg_change,
    -- Análise Ano a Ano (Year-over-year)
    LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
         WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
         ELSE 'No Change'
    END py_change
FROM yearly_product_sales
ORDER BY product_name, order_year

------------------------------
-- 10. Análise de Participação (Part-to-Whole) -- 
------------------------------

-- Encontrar quais categorias mais contribuem para o total de vendas
WITH sales_by_category AS (
SELECT  category, 
        SUM(sales_amount) total_by_category
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY category
)

SELECT category,
       total_by_category,
       SUM(total_by_category) OVER() overall_sales,
       CONCAT(ROUND((CAST(total_by_category AS FLOAT) / SUM(total_by_category) OVER()) * 100, 2), '%') AS percent_contribution
FROM sales_by_category
ORDER BY total_by_category DESC
       
------------------------------
-- 11. Análise de Segmentação de Dados -- 
------------------------------

-- Segmentar produtos em faixas de custo e contar quantos produtos existem em cada segmento
WITH product_cost_segmentation AS (
SELECT product_key,
       product_name, 
       cost,
       CASE WHEN COST < 100 THEN 'Below 100'
            WHEN COST BETWEEN 100 AND 500 THEN '100-500'
            WHEN COST BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
       END AS cost_range
FROM gold.dim_products)

SELECT cost_range, COUNT(product_key) total_products
FROM product_cost_segmentation
GROUP BY cost_range
ORDER BY total_products DESC

/* Agrupar clientes em três segmentos baseados no comportamento de compra:
    - VIP: Clientes com pelo menos 12 meses de histórico e gastos acima de €5.000
    - Regular: Clientes com pelo menos 12 meses de histórico, mas gastos de €5.000 ou menos
    - New: Clientes com menos de 12 meses de histórico
Encontrar o total de clientes por grupo
*/

WITH customer_spending AS (
SELECT c.customer_key, SUM(sales_amount) AS total_spending, 
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY c.customer_key
),

customer_segmented AS (
SELECT *,
       CASE WHEN total_spending > 5000 AND lifespan >= 12 THEN 'VIP' 
            WHEN total_spending <= 5000 AND lifespan >= 12 THEN 'Regular'
            ELSE 'New'
       END AS customer_segment
FROM customer_spending
)

SELECT customer_segment,
       COUNT(customer_key) AS total_customers
FROM customer_segmented
GROUP BY customer_segment
ORDER BY total_customers DESC