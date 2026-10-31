# Source Data Profile

Profile generated from the included `data/raw_retail_sales.csv`.

| Check | Observed value |
|---|---:|
| Source rows | 256 |
| Columns | 16 |
| Duplicate `order_line_id` rows | 2 rows across 1 duplicate key |
| Zero-quantity records | 1 |
| Negative unit-price records | 1 |
| Invalid date strings | 1 |
| Missing values in the supplied CSV | 0 |

The dataset uses `DD-MM-YYYY` date strings. The ETL cleaning script parses this format explicitly. The duplicate is an exact repeated row. The three invalid records are excluded by the validation filters.
