-- 05 | Create the dimensional data mart (star schema)
USE retail_sales_etl;

-- Drop fact first because it references the dimensions.
DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_customer;

CREATE TABLE dim_customer (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL UNIQUE,
    customer_name VARCHAR(150) NOT NULL,
    city VARCHAR(100),
    state VARCHAR(100),
    region VARCHAR(50)
);

CREATE TABLE dim_product (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL UNIQUE,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    current_unit_price DECIMAL(12,2),
    current_unit_cost DECIMAL(12,2)
);

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY, -- YYYYMMDD
    full_date DATE NOT NULL UNIQUE,
    calendar_year SMALLINT NOT NULL,
    quarter_number TINYINT NOT NULL,
    month_number TINYINT NOT NULL,
    month_name VARCHAR(15) NOT NULL,
    year_month CHAR(7) NOT NULL,
    day_number TINYINT NOT NULL,
    day_name VARCHAR(15) NOT NULL
);

CREATE TABLE fact_sales (
    sales_key BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_line_id INT NOT NULL UNIQUE,
    order_id VARCHAR(30) NOT NULL,
    date_key INT NOT NULL,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    discount_pct DECIMAL(7,4) NOT NULL,
    unit_cost DECIMAL(12,2) NOT NULL,
    net_revenue DECIMAL(14,2) NOT NULL,
    total_cost DECIMAL(14,2) NOT NULL,
    gross_profit DECIMAL(14,2) NOT NULL,
    gross_margin_pct DECIMAL(7,2) NOT NULL,
    sales_channel VARCHAR(50),
    CONSTRAINT fk_sales_date FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    CONSTRAINT fk_sales_customer FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    CONSTRAINT fk_sales_product FOREIGN KEY (product_key) REFERENCES dim_product(product_key)
);

CREATE INDEX idx_fact_order_id ON fact_sales(order_id);
CREATE INDEX idx_fact_channel ON fact_sales(sales_channel);
