-- 06 | Load dimensions first, then the sales fact table
USE retail_sales_etl;

-- Clear existing rows so this load script can be rerun safely.
DELETE FROM fact_sales;
DELETE FROM dim_date;
DELETE FROM dim_product;
DELETE FROM dim_customer;

INSERT INTO dim_customer (customer_id, customer_name, city, state, region)
SELECT customer_id, MAX(customer_name), MAX(city), MAX(state), MAX(region)
FROM stg_retail_sales_clean
GROUP BY customer_id;

INSERT INTO dim_product
    (product_id, product_name, category, current_unit_price, current_unit_cost)
SELECT product_id, MAX(product_name), MAX(category),
       MAX(unit_price), MAX(unit_cost)
FROM stg_retail_sales_clean
GROUP BY product_id;

INSERT INTO dim_date
    (date_key, full_date, calendar_year, quarter_number, month_number,
     month_name, year_month, day_number, day_name)
SELECT DISTINCT
    CAST(DATE_FORMAT(order_date, '%Y%m%d') AS UNSIGNED),
    order_date,
    YEAR(order_date),
    QUARTER(order_date),
    MONTH(order_date),
    MONTHNAME(order_date),
    DATE_FORMAT(order_date, '%Y-%m'),
    DAYOFMONTH(order_date),
    DAYNAME(order_date)
FROM stg_retail_sales_clean;

INSERT INTO fact_sales
    (order_line_id, order_id, date_key, customer_key, product_key,
     quantity, unit_price, discount_pct, unit_cost, net_revenue,
     total_cost, gross_profit, gross_margin_pct, sales_channel)
SELECT
    s.order_line_id, s.order_id, d.date_key, c.customer_key, p.product_key,
    s.quantity, s.unit_price, s.discount_pct, s.unit_cost, s.net_revenue,
    s.total_cost, s.gross_profit, s.gross_margin_pct, s.sales_channel
FROM stg_retail_sales_clean AS s
JOIN dim_date AS d ON d.full_date = s.order_date
JOIN dim_customer AS c ON c.customer_id = s.customer_id
JOIN dim_product AS p ON p.product_id = s.product_id;

SELECT
    (SELECT COUNT(*) FROM dim_customer) AS customers,
    (SELECT COUNT(*) FROM dim_product) AS products,
    (SELECT COUNT(*) FROM dim_date) AS dates,
    (SELECT COUNT(*) FROM fact_sales) AS fact_sales_rows;
