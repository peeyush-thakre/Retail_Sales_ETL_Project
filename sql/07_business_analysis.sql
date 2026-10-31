-- 07 | Business analysis queries
USE retail_sales_etl;

-- 1. Executive KPIs
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(net_revenue), 2) AS total_revenue,
    ROUND(SUM(total_cost), 2) AS total_cost,
    ROUND(SUM(gross_profit), 2) AS gross_profit,
    ROUND(SUM(gross_profit) / NULLIF(SUM(net_revenue), 0) * 100, 2)
        AS gross_margin_pct
FROM fact_sales;

-- 2. Monthly revenue and profit trend
SELECT
    d.year_month,
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROUND(SUM(f.net_revenue), 2) AS revenue,
    ROUND(SUM(f.gross_profit), 2) AS gross_profit
FROM fact_sales AS f
JOIN dim_date AS d ON d.date_key = f.date_key
GROUP BY d.year_month
ORDER BY d.year_month;

-- 3. Category performance
SELECT
    p.category,
    SUM(f.quantity) AS units_sold,
    ROUND(SUM(f.net_revenue), 2) AS revenue,
    ROUND(SUM(f.gross_profit), 2) AS gross_profit,
    ROUND(SUM(f.gross_profit) / NULLIF(SUM(f.net_revenue), 0) * 100, 2)
        AS margin_pct
FROM fact_sales AS f
JOIN dim_product AS p ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY revenue DESC;

-- 4. Top 10 customers by net revenue
SELECT
    c.customer_id, c.customer_name, c.city,
    ROUND(SUM(f.net_revenue), 2) AS customer_revenue,
    COUNT(DISTINCT f.order_id) AS orders_placed
FROM fact_sales AS f
JOIN dim_customer AS c ON c.customer_key = f.customer_key
GROUP BY c.customer_id, c.customer_name, c.city
ORDER BY customer_revenue DESC
LIMIT 10;

-- 5. Sales channel performance
SELECT
    sales_channel,
    COUNT(DISTINCT order_id) AS orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(net_revenue), 2) AS revenue,
    ROUND(SUM(gross_profit), 2) AS gross_profit
FROM fact_sales
GROUP BY sales_channel
ORDER BY revenue DESC;

-- 6. Product performance
SELECT
    p.product_name, p.category,
    SUM(f.quantity) AS units_sold,
    ROUND(SUM(f.net_revenue), 2) AS revenue
FROM fact_sales AS f
JOIN dim_product AS p ON p.product_key = f.product_key
GROUP BY p.product_key, p.product_name, p.category
ORDER BY revenue DESC;
