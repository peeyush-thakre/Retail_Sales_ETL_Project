# Data Mart Data Model

The project uses a dimensional **star schema**. `fact_sales` stores one row per valid order line and references the customer, product, and date dimensions through surrogate keys.

```mermaid
erDiagram
    DIM_CUSTOMER ||--o{ FACT_SALES : customer_key
    DIM_PRODUCT  ||--o{ FACT_SALES : product_key
    DIM_DATE     ||--o{ FACT_SALES : date_key

    DIM_CUSTOMER {
        int customer_key PK
        int customer_id UK
        string customer_name
        string city
        string state
        string region
    }

    DIM_PRODUCT {
        int product_key PK
        int product_id UK
        string product_name
        string category
        decimal current_unit_price
        decimal current_unit_cost
    }

    DIM_DATE {
        int date_key PK
        date full_date UK
        int calendar_year
        int quarter_number
        int month_number
        string month_name
        string year_month
        int day_number
        string day_name
    }

    FACT_SALES {
        bigint sales_key PK
        int order_line_id UK
        string order_id
        int date_key FK
        int customer_key FK
        int product_key FK
        int quantity
        decimal unit_price
        decimal discount_pct
        decimal unit_cost
        decimal net_revenue
        decimal total_cost
        decimal gross_profit
        decimal gross_margin_pct
        string sales_channel
    }
```

## Table grain

- **Fact table grain:** one row per unique `order_line_id`.
- **Customer dimension grain:** one row per `customer_id`.
- **Product dimension grain:** one row per `product_id`.
- **Date dimension grain:** one row per calendar date present in the cleaned transactions.

## Measures

- `net_revenue`: quantity × unit price × (1 − discount fraction).
- `total_cost`: quantity × unit cost.
- `gross_profit`: net revenue − total cost.
- `gross_margin_pct`: gross profit ÷ net revenue × 100.

## Design note

The product dimension stores the maximum observed unit price and cost as current descriptive attributes. Transaction-level price and cost are also retained in `fact_sales`, preserving the values used for each transaction's financial calculations.
