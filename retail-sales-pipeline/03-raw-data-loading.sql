-- This script loads raw data into Snowflake tables for the retail sales pipeline project.

USE DATABASE RETAIL_PIPELINE;
USE SCHEMA RAW;
USE WAREHOUSE RETAIL_WH;

-- Create a file format for the CSV files to ensure consistent parsing of the data.

CREATE OR REPLACE FILE FORMAT retail_csv_format
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null', '')
  EMPTY_FIELD_AS_NULL = TRUE;


-- Create raw orders table. The table structure is based on 
-- the columns present in the olist_orders_dataset.csv file.

CREATE OR REPLACE TABLE orders_raw (
    order_id                VARCHAR,
    customer_id             VARCHAR,
    order_status            VARCHAR,
    order_purchase_timestamp TIMESTAMP_NTZ,
    order_approved_at       TIMESTAMP_NTZ,
    order_delivered_carrier_date TIMESTAMP_NTZ,
    order_delivered_customer_date TIMESTAMP_NTZ,
    order_estimated_delivery_date TIMESTAMP_NTZ
);

-- Create raw customers table. The table structure is based on
-- the columns present in the olist_customers_dataset.csv file.

CREATE OR REPLACE TABLE customers_raw (
    customer_id             VARCHAR,
    customer_unique_id      VARCHAR,
    customer_zip_code_prefix VARCHAR,
    customer_city           VARCHAR,
    customer_state          VARCHAR
);

-- Create raw order items table. The table structure is based on
-- the columns present in the olist_order_items_dataset.csv file.

CREATE OR REPLACE TABLE order_items_raw (
    order_id                VARCHAR,
    order_item_id           NUMBER,
    product_id              VARCHAR,
    seller_id               VARCHAR,
    shipping_limit_date     TIMESTAMP_NTZ,
    price                   NUMBER(10,2),
    freight_value           NUMBER(10,2)
);

-- Create raw products table. The table structure is based on
-- the columns present in the olist_products_dataset.csv file.

CREATE OR REPLACE TABLE products_raw (
    product_id              VARCHAR,
    product_category_name   VARCHAR,
    product_name_length     NUMBER,
    product_description_length NUMBER,
    product_photos_qty      NUMBER,
    product_weight_g        NUMBER,
    product_length_cm       NUMBER,
    product_height_cm       NUMBER,
    product_width_cm        NUMBER
);

-- Create raw order payments table. The table structure is based on
-- the columns present in the olist_order_payments_dataset.csv file.

CREATE OR REPLACE TABLE order_payments_raw (
    order_id                VARCHAR,
    payment_sequential      NUMBER,
    payment_type            VARCHAR,
    payment_installments    NUMBER,
    payment_value           NUMBER(10,2)
);



-- Load data from the stage into the raw tables using the COPY INTO command.
-- The ON_ERROR = 'CONTINUE' option allows the load to continue even if some rows
-- fail to load due to data issues, which is common when loading raw data.

  
COPY INTO orders_raw
FROM @raw_stage/olist_orders_dataset.csv
FILE_FORMAT = (FORMAT_NAME = 'retail_csv_format')
ON_ERROR = 'CONTINUE';

COPY INTO customers_raw
FROM @raw_stage/olist_customers_dataset.csv
FILE_FORMAT = (FORMAT_NAME = 'retail_csv_format')
ON_ERROR = 'CONTINUE';

COPY INTO order_items_raw
FROM @raw_stage/olist_order_items_dataset.csv
FILE_FORMAT = (FORMAT_NAME = 'retail_csv_format')
ON_ERROR = 'CONTINUE';

COPY INTO products_raw
FROM @raw_stage/olist_products_dataset.csv
FILE_FORMAT = (FORMAT_NAME = 'retail_csv_format')
ON_ERROR = 'CONTINUE';

COPY INTO order_payments_raw
FROM @raw_stage/olist_order_payments_dataset.csv
FILE_FORMAT = (FORMAT_NAME = 'retail_csv_format')
ON_ERROR = 'CONTINUE';


-- After loading the data, we can run some queries to verify that the data has been loaded correctly.
-- For example, we can check the number of rows loaded into each table.

SELECT 'orders'    AS tbl, COUNT(*) AS row_count FROM orders_raw      UNION ALL
SELECT 'customers' AS tbl, COUNT(*) AS row_count FROM customers_raw     UNION ALL
SELECT 'items'     AS tbl, COUNT(*) AS row_count FROM order_items_raw   UNION ALL
SELECT 'products'  AS tbl, COUNT(*) AS row_count FROM products_raw      UNION ALL
SELECT 'payments'  AS tbl, COUNT(*) AS row_count FROM order_payments_raw;


-- For more information on this script, go to:
-- retail-sales-pipeline/docs/README's/03-raw-data-loading-README.md/
