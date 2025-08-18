/*
  Sales Insight Project - SQL Queries
  Author: Syed Abbas Mujthahed
  Description: This file contains SQL queries for data exploration, cleaning, and analysis of sales transactions, products, customers, and markets.
 */

/* SECTION 1: Database & Tables */

-- Show the currently selected database
SELECT DATABASE() AS current_db;

-- List all tables in the current database
SHOW TABLES;

-- Count the number of rows in each table
SELECT 'transactions' AS table_name, COUNT(*) AS row_count FROM transactions
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'markets', COUNT(*) FROM markets
UNION ALL SELECT 'date', COUNT(*) FROM date;


/* SECTION 2: Data Quality Checks */

-- Find the earliest and latest order date in transactions
SELECT MIN(order_date) as min_order_date, 
       MAX(order_date) as max_order_date
FROM transactions;

-- Check the number of rows and total revenue for each currency
SELECT 
    COALESCE(currency, '(NULL)') as currency,
    COUNT(*) as rows_count,
    ROUND(SUM(sales_amount), 2) as total_revenue
FROM transactions
GROUP BY currency
ORDER BY rows_count DESC;

-- Count the number of NULLs in key columns
SELECT
    SUM(product_code IS NULL) AS null_product_code,
    SUM(customer_code IS NULL) AS null_customer_code,
    SUM(market_code IS NULL) AS null_market_code,
    SUM(order_date IS NULL) AS null_order_date
FROM transactions;

-- Count orphan records where foreign keys do not exist in reference tables
SELECT COUNT(*) AS orphan_products
FROM transactions t
LEFT JOIN products p
ON t.product_code = p.product_code
WHERE p.product_code IS NULL;

SELECT COUNT(*) AS orphan_customers
FROM transactions t
LEFT JOIN customers c
ON t.customer_code = c.customer_code
WHERE c.customer_code IS NULL;

SELECT COUNT(*) AS orphan_markets
FROM transactions t 
LEFT JOIN markets m
ON t.market_code = m.markets_code
WHERE m.markets_code IS NULL;

SELECT COUNT(*) AS orphan_dates
FROM transactions t
LEFT JOIN date d
ON t.order_date = d.date
WHERE d.date IS NULL;


/* SECTION 3: Currency Checks & Updates */

-- List distinct currencies used in transactions
SELECT DISTINCT currency FROM transactions;

-- Count transactions per currency
SELECT currency, COUNT(*) AS rows_count
FROM transactions
GROUP BY currency;

-- Convert USD sales to INR
UPDATE transactions
SET sales_amount = sales_amount * 85,
    currency = "INR"
WHERE currency = "USD";

-- Check missing values after currency conversion
SELECT 
    COUNT(*) - COUNT(sales_amount) AS missing_sales,
    COUNT(*) - COUNT(product_code) AS missing_products,
    COUNT(*) - COUNT(customer_code) AS missing_customers,
    COUNT(*) - COUNT(market_code) AS missing_markets
FROM transactions;


/* SECTION 4: Exploratory Data Analysis (EDA) */

-- Total number of transactions
SELECT COUNT(*) AS total_transactions
FROM transactions;

-- Total sales amount
SELECT SUM(sales_amount) AS total_sales
FROM transactions;

-- Total quantity sold
SELECT SUM(sales_qty) AS total_quantity
FROM transactions;

-- Number of unique products, customers, and markets
SELECT
    COUNT(DISTINCT product_code) AS unique_products,
    COUNT(DISTINCT customer_code) AS unique_customers,
    COUNT(DISTINCT market_code) AS unique_markets
FROM transactions;

-- Yearly sales trend
SELECT YEAR(order_date) AS Year,
       SUM(sales_amount) as total_sales
FROM transactions
GROUP BY year
ORDER BY Year;

-- Monthly sales trend
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       SUM(sales_amount) as total_sales
FROM transactions
GROUP BY month
ORDER BY month;


/* SECTION 5: Top Products & Product Types */

-- Top 10 products by sales
SELECT product_code AS product, 
       SUM(sales_amount) AS total_sales
FROM transactions
GROUP BY product_code
ORDER BY total_sales DESC
LIMIT 10;

-- Top 10 product types by sales (joins with products table)
SELECT p.product_type, t.product_code AS product, 
       SUM(t.sales_amount) AS total_sales
FROM products p
JOIN transactions t
ON p.product_code = t.product_code
GROUP BY p.product_code, t.product_code
ORDER BY total_sales DESC
LIMIT 10;


/* SECTION 6: Top Customers */

-- Top 10 customers by sales
SELECT customer_code AS customer,
       SUM(sales_amount) AS total_sales
FROM transactions
GROUP BY customer
ORDER BY total_sales DESC
LIMIT 10;

-- Top 10 customer names by sales (joins with customers table)
SELECT c.customer_name, SUM(t.sales_amount) AS total_sales
FROM customers c
JOIN transactions t
ON c.customer_code = t.customer_code
GROUP BY c.customer_name
ORDER BY total_sales DESC
LIMIT 10;


/* SECTION 7: Sales Distribution Across Markets */

-- Sales distribution across markets by market_code
SELECT market_code, 
       SUM(sales_amount) AS total_sales
FROM transactions
GROUP BY market_code
ORDER BY total_sales DESC;

-- Sales distribution across markets by market name (joins with markets table)
SELECT m.markets_name, t.market_code, SUM(t.sales_amount) AS total_sales
FROM markets m
JOIN transactions t
ON m.markets_code = t.market_code
GROUP BY m.markets_name, t.market_code
ORDER BY total_sales DESC;
