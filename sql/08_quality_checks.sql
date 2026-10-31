-- 08 | Data quality and reconciliation checks
USE retail_sales_etl;

-- Each query should return zero rows/count unless noted otherwise.

-- 1. Duplicate order-line business keys in the fact table
SELECT order_line_id, COUNT(*) AS row_count
FROM fact_sales
GROUP BY order_line_id
HAVING COUNT(*) > 1;

-- 2. Invalid quantities or financial values
SELECT *
FROM fact_sales
WHERE quantity <= 0
   OR unit_price <= 0
   OR unit_cost < 0
   OR net_revenue < 0
   OR total_cost < 0
   OR discount_pct NOT BETWEEN 0 AND 1;

-- 3. Missing dimension references
SELECT COUNT(*) AS unmatched_dimension_rows
FROM stg_retail_sales_clean AS s
LEFT JOIN dim_customer AS c ON c.customer_id = s.customer_id
LEFT JOIN dim_product AS p ON p.product_id = s.product_id
LEFT JOIN dim_date AS d ON d.full_date = s.order_date
WHERE c.customer_key IS NULL
   OR p.product_key IS NULL
   OR d.date_key IS NULL;

-- 4. Clean staging vs fact reconciliation
SELECT
    (SELECT COUNT(*) FROM stg_retail_sales_clean) AS clean_stage_rows,
    (SELECT COUNT(*) FROM fact_sales) AS fact_rows,
    (SELECT COUNT(*) FROM stg_retail_sales_clean)
      - (SELECT COUNT(*) FROM fact_sales) AS row_difference;

-- 5. Revenue calculation validation
SELECT COUNT(*) AS revenue_calculation_mismatches
FROM fact_sales
WHERE ABS(net_revenue -
    ROUND(quantity * unit_price * (1 - discount_pct), 2)) > 0.01;

-- 6. Gross profit calculation validation
SELECT COUNT(*) AS gross_profit_calculation_mismatches
FROM fact_sales
WHERE ABS(gross_profit - (net_revenue - total_cost)) > 0.01;
