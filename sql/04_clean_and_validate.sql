-- 04 | Profile, parse, deduplicate and validate source records
-- Source dates use DD-MM-YYYY (for example, 27-02-2026).
USE retail_sales_etl;

-- A. Raw data profiling
SELECT COUNT(*) AS raw_rows FROM stg_retail_sales_raw;

SELECT
    SUM(order_line_id IS NULL OR TRIM(order_line_id) = '') AS missing_line_ids,
    SUM(order_id IS NULL OR TRIM(order_id) = '') AS missing_order_ids,
    SUM(customer_id IS NULL OR TRIM(customer_id) = '') AS missing_customer_ids,
    SUM(product_id IS NULL OR TRIM(product_id) = '') AS missing_product_ids
FROM stg_retail_sales_raw;

-- Duplicate business keys
SELECT TRIM(order_line_id) AS order_line_id, COUNT(*) AS duplicate_count
FROM stg_retail_sales_raw
GROUP BY TRIM(order_line_id)
HAVING COUNT(*) > 1;

-- B. Parse source values safely. Invalid numeric strings become NULL rather than 0.
DROP TABLE IF EXISTS stg_retail_sales_clean;

CREATE TABLE stg_retail_sales_clean AS
WITH parsed AS (
    SELECT
        CASE WHEN TRIM(order_line_id) REGEXP '^[0-9]+$'
             THEN CAST(TRIM(order_line_id) AS UNSIGNED) END AS order_line_id,
        NULLIF(TRIM(order_id), '') AS order_id,
        CASE WHEN TRIM(order_date) REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
             THEN STR_TO_DATE(TRIM(order_date), '%d-%m-%Y') END AS order_date,
        CASE WHEN TRIM(customer_id) REGEXP '^[0-9]+$'
             THEN CAST(TRIM(customer_id) AS UNSIGNED) END AS customer_id,
        NULLIF(TRIM(customer_name), '') AS customer_name,
        NULLIF(TRIM(city), '') AS city,
        NULLIF(TRIM(state), '') AS state,
        NULLIF(TRIM(region), '') AS region,
        CASE WHEN TRIM(product_id) REGEXP '^[0-9]+$'
             THEN CAST(TRIM(product_id) AS UNSIGNED) END AS product_id,
        NULLIF(TRIM(product_name), '') AS product_name,
        NULLIF(TRIM(category), '') AS category,
        CASE WHEN TRIM(quantity) REGEXP '^[0-9]+$'
             THEN CAST(TRIM(quantity) AS UNSIGNED) END AS quantity,
        CASE WHEN TRIM(unit_price) REGEXP '^-?[0-9]+([.][0-9]+)?$'
             THEN CAST(TRIM(unit_price) AS DECIMAL(12,2)) END AS unit_price,
        CASE WHEN TRIM(discount_pct) REGEXP '^-?[0-9]+([.][0-9]+)?$'
             THEN CAST(TRIM(discount_pct) AS DECIMAL(7,4)) END AS discount_pct,
        CASE WHEN TRIM(unit_cost) REGEXP '^-?[0-9]+([.][0-9]+)?$'
             THEN CAST(TRIM(unit_cost) AS DECIMAL(12,2)) END AS unit_cost,
        NULLIF(TRIM(sales_channel), '') AS sales_channel
    FROM stg_retail_sales_raw
),
deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY order_line_id
            ORDER BY order_id, order_date, customer_id, product_id
        ) AS row_num
    FROM parsed
)
SELECT
    order_line_id, order_id, order_date, customer_id, customer_name,
    city, state, region, product_id, product_name, category, quantity,
    unit_price, discount_pct, unit_cost, sales_channel,
    ROUND(quantity * unit_price * (1 - discount_pct), 2) AS net_revenue,
    ROUND(quantity * unit_cost, 2) AS total_cost,
    ROUND((quantity * unit_price * (1 - discount_pct))
          - (quantity * unit_cost), 2) AS gross_profit,
    CASE
        WHEN quantity * unit_price * (1 - discount_pct) = 0 THEN 0
        ELSE ROUND(
            ((quantity * unit_price * (1 - discount_pct))
             - (quantity * unit_cost))
            / (quantity * unit_price * (1 - discount_pct)) * 100, 2
        )
    END AS gross_margin_pct
FROM deduplicated
WHERE row_num = 1
  AND order_line_id IS NOT NULL
  AND order_id IS NOT NULL
  AND order_date IS NOT NULL
  AND customer_id IS NOT NULL
  AND customer_name IS NOT NULL
  AND product_id IS NOT NULL
  AND product_name IS NOT NULL
  AND quantity > 0
  AND unit_price > 0
  AND unit_cost >= 0
  AND discount_pct BETWEEN 0 AND 1;

-- C. Reconciliation summary
SELECT
    (SELECT COUNT(*) FROM stg_retail_sales_raw) AS raw_rows,
    (SELECT COUNT(*) FROM stg_retail_sales_clean) AS clean_rows,
    (SELECT COUNT(*) FROM stg_retail_sales_raw)
      - (SELECT COUNT(*) FROM stg_retail_sales_clean) AS rows_removed;
