-- 02 | Create the raw staging table
-- Raw fields are VARCHAR intentionally: preserve source values before validation.
USE retail_sales_etl;

DROP TABLE IF EXISTS stg_retail_sales_clean;
DROP TABLE IF EXISTS stg_retail_sales_raw;

CREATE TABLE stg_retail_sales_raw (
    order_line_id   VARCHAR(30),
    order_id        VARCHAR(30),
    order_date      VARCHAR(30),
    customer_id     VARCHAR(30),
    customer_name   VARCHAR(150),
    city            VARCHAR(100),
    state           VARCHAR(100),
    region          VARCHAR(50),
    product_id      VARCHAR(30),
    product_name    VARCHAR(150),
    category        VARCHAR(100),
    quantity        VARCHAR(30),
    unit_price      VARCHAR(30),
    discount_pct    VARCHAR(30),
    unit_cost       VARCHAR(30),
    sales_channel   VARCHAR(50)
);
