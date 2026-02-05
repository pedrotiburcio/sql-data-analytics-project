-- =========================================
--	Projeto: Análise Exploratória de Dados (EDA) 
-- =========================================

------------------------------
-- 1. Integração de Dados -- 
------------------------------

-- Explorar todos os objetos no Banco de Dados
SELECT * FROM INFORMATION_SCHEMA.TABLES

-- Explorar todas as colunas no Banco de Dados
SELECT * FROM INFORMATION_SCHEMA.COLUMNS


-- Explorar uma tabela específica
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'gold.dim_customers'

------------------------------
-- 2. Exploração de Dimensões -- 
------------------------------

-- Explorar todos os países de onde vêm nossos clientes
SELECT DISTINCT country 
FROM gold.dim_customers

-- Explorar todas as categorias "As Divisões Principais"
SELECT DISTINCT category
FROM gold.dim_products

-- Explorar todos os produtos dentro de cada categoria
SELECT DISTINCT category, subcategory, product_name
FROM gold.dim_products
ORDER BY 1,2,3

------------------------------
-- 3. Exploração de Datas -- 
------------------------------

-- Encontrar o primeiro pedido, o último pedido e o intervalo entre eles
SELECT 
	MIN(order_date) AS first_order_date, 
	MAX(order_date) AS last_order_date, 
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales

-- Encontrar o cliente mais jovem e o mais velho, e a diferença entre eles
SELECT 
	MIN(birthdate) AS oldest_birthdate,
	DATEDIFF(YEAR, MIN(birthdate), GETDATE()) oldest_age,
    Max(birthdate) AS youngest_birthdate,
	DATEDIFF(YEAR, MAX(birthdate), GETDATE()) youngest_age,
	DATEDIFF(YEAR, MIN(birthdate), MAX(birthdate)) birthdate_range_years
FROM gold.dim_customers

------------------------------
-- 4. Exploração de Métricas -- 
------------------------------

-- Encontrar o Total de Vendas
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales

-- Encontrar quantos itens foram vendidos
SELECT SUM(quantity) AS total_items_sold FROM gold.fact_sales

-- Encontrar o preço médio de venda
SELECT AVG(price) AS avg_price FROM gold.fact_sales

-- Encontrar o número total de pedidos
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales

-- Encontrar o número total de produtos
SELECT COUNT(product_key) AS total_products FROM gold.dim_products

-- Encontrar o número total de clientes
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers

-- Encontrar o número total de clientes que realizaram um pedido
SELECT COUNT(DISTINCT customer_key) AS total_customers_orders FROM gold.fact_sales

-- Gerar relatório que mostra todas as métricas principais do negócio
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Products', COUNT(product_key) FROM gold.dim_products
UNION ALL
SELECT 'Total Nr. Customers', COUNT(customer_key) FROM gold.dim_customers

------------------------------------
-- 5. Análise de Magnitude e Ranking
------------------------------------

-- Encontrar o total de clientes por país
SELECT country, COUNT(customer_key) AS total_customers
FROM gold.dim_customers 
GROUP BY country ORDER BY total_customers DESC

-- Encontrar o total de clientes por gênero
SELECT gender, COUNT(customer_key) AS total_customers
FROM gold.dim_customers 
GROUP BY gender ORDER BY total_customers DESC

-- Encontrar o total de produtos por categoria
SELECT category, COUNT(product_key) AS total_products 
FROM gold.dim_products 
GROUP BY category ORDER BY total_products DESC

-- Encontrar o custo médio em cada categoria
SELECT category, AVG(cost) average_cost 
FROM gold.dim_products 
GROUP BY category ORDER BY average_cost DESC

-- Encontrar a receita total gerada para cada categoria
SELECT pr.category, SUM(sa.sales_amount) AS total_revenue
FROM gold.fact_sales sa
LEFT JOIN gold.dim_products pr
ON sa.product_key = pr.product_key
GROUP BY pr.category
ORDER BY total_revenue DESC

-- Encontrar a receita total gerada por cada cliente
SELECT ct.customer_key, CONCAT(ct.first_name, ' ', ct.last_name) AS customer, SUM(sa.sales_amount) AS total_revenue
FROM gold.fact_sales sa
LEFT JOIN gold.dim_customers ct
ON sa.customer_key = ct.customer_key
GROUP BY ct.customer_key, CONCAT(ct.first_name, ' ', ct.last_name)
ORDER BY total_revenue DESC

-- Encontrar a distribuição de itens vendidos entre os países
SELECT ct.country, SUM(sa.quantity) quantity_sold
FROM gold.fact_sales sa
LEFT JOIN gold.dim_customers ct
ON sa.customer_key = ct.customer_key
GROUP BY ct.country
ORDER BY quantity_sold DESC

-- Encontrar os países que possuem o maior valor de receita (Canadá foi o 3º em quantidade vendida, mas o 6º em valor de receita) 
SELECT ct.country, SUM(sa.sales_amount) total_sold
FROM gold.fact_sales sa
LEFT JOIN gold.dim_customers ct
ON sa.customer_key = ct.customer_key
GROUP BY ct.country
ORDER BY total_sold DESC

-- Encontrar os 5 produtos que geram a maior receita
SELECT TOP 5 pr.product_name, SUM(sa.sales_amount) AS total_revenue
FROM gold.fact_sales sa
LEFT JOIN gold.dim_products pr
ON sa.product_key = pr.product_key
GROUP BY pr.product_name
ORDER BY total_revenue DESC

-- Encontrar os Top 5 produtos usando a Window Function ROW_NUMBER
SELECT TOP 5 pr.product_name, SUM(sa.sales_amount) AS total_revenue, 
ROW_NUMBER() OVER(ORDER BY SUM(sa.sales_amount) DESC) rank_products
FROM gold.fact_sales sa
LEFT JOIN gold.dim_products pr
ON sa.product_key = pr.product_key
GROUP BY pr.product_name

-- Encontrar os 5 produtos com pior desempenho de vendas
SELECT TOP 5 pr.product_name, 
SUM(sa.sales_amount) AS total_revenue
FROM gold.fact_sales sa
LEFT JOIN gold.dim_products pr
ON sa.product_key = pr.product_key
GROUP BY pr.product_name
ORDER BY total_revenue

-- Encontrar os 10 clientes que geraram a maior receita
SELECT TOP 10 ct.customer_key, 
ct.first_name, 
ct.last_name, 
SUM(sa.sales_amount) AS total_revenue
FROM gold.fact_sales sa
LEFT JOIN gold.dim_customers ct
ON sa.customer_key = ct.customer_key
GROUP BY ct.customer_key, ct.first_name, ct.last_name
ORDER BY total_revenue DESC

-- Encontrar os 3 clientes com o menor número de pedidos realizados
SELECT TOP 3 
ct.customer_key, 
ct.first_name,
ct.last_name,
COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales sa
LEFT JOIN gold.dim_customers ct
ON sa.customer_key = ct.customer_key
GROUP BY ct.customer_key, ct.first_name, ct.last_name
ORDER BY total_orders