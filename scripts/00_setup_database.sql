/*
=============================================================
Criar Banco de Dados e Schemas
=============================================================
Objetivo do Script:
    Este script cria um novo banco de dados chamado 'DataWarehouseAnalytics' após verificar se ele já existe. 
    Se o banco de dados existir, ele é excluído e recriado. Além disso, o script cria um schema chamado 'gold'.
	
AVISO:
    A execução deste script excluirá todo o banco de dados 'DataWarehouseAnalytics', caso ele exista. 
    Todos os dados serão apagados permanentemente. Prossiga com cautela 
    e garanta que possui backups adequados antes de executar este script.
*/

USE master;
GO

-- Excluir e recriar o banco de dados 'DataWarehouseAnalytics'
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

-- Criar o banco de dados 'DataWarehouseAnalytics'
CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

-- Criar Schemas

CREATE SCHEMA gold;
GO

-- Criar as Tabelas do Data Warehouse

CREATE TABLE gold.dim_customers(
	customer_key int,
	customer_id int,
	customer_number nvarchar(50),
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date
);
GO

CREATE TABLE gold.dim_products(
	product_key int ,
	product_id int ,
	product_number nvarchar(50) ,
	product_name nvarchar(50) ,
	category_id nvarchar(50) ,
	category nvarchar(50) ,
	subcategory nvarchar(50) ,
	maintenance nvarchar(50) ,
	cost int,
	product_line nvarchar(50),
	start_date date 
);
GO

CREATE TABLE gold.fact_sales(
	order_number nvarchar(50),
	product_key int,
	customer_key int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int 
);
GO

-- Limpar e Inserir Dados (Carga Bulk)

TRUNCATE TABLE gold.dim_customers;
GO

BULK INSERT gold.dim_customers
FROM 'C:\Projetos SQL\sql-eda-project\datasets\gold.dim_customers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.dim_products;
GO

BULK INSERT gold.dim_products
FROM 'C:\Projetos SQL\sql-eda-project\datasets\gold.dim_products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.fact_sales;
GO

BULK INSERT gold.fact_sales
FROM 'C:\Projetos SQL\sql-eda-project\datasets\gold.fact_sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO