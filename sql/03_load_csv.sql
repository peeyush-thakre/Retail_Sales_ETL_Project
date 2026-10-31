-- 03 | Load the source CSV into raw staging
-- IMPORTANT: replace the path with the absolute path on YOUR computer.
-- Example: 'C:/Users/YourName/Downloads/retail-sales-etl/data/raw_retail_sales.csv'
-- Enable LOCAL INFILE in both the MySQL client and server if required.
USE retail_sales_etl;

LOAD DATA LOCAL INFILE 'C:/REPLACE/WITH/YOUR/PATH/raw_retail_sales.csv'
INTO TABLE stg_retail_sales_raw
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    order_line_id, order_id, order_date, customer_id, customer_name, city,
    state, region, product_id, product_name, category, quantity, unit_price,
    discount_pct, unit_cost, sales_channel
);

-- Basic load verification
SELECT COUNT(*) AS raw_row_count FROM stg_retail_sales_raw;
SELECT * FROM stg_retail_sales_raw LIMIT 10;
