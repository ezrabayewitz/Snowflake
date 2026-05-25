-- =========================================================
-- Part 1 – Zero to Snowflake (Getting Started)
-- Annotated Implementation of Official Quickstart Lab
-- Focus: Warehouses, transformations, caching, recovery, cost control
-- =========================================================

-- =========================================================
-- Session Setup
-- =========================================================

ALTER SESSION SET query_tag = 
'{"project":"zero-to-snowflake","part":1,"type":"learning-lab"}';

USE DATABASE tb_101;
USE ROLE accountadmin;

-- =========================================================
-- 1. Virtual Warehouses
-- =========================================================

-- Inspect existing warehouses
SHOW WAREHOUSES;

-- Create a new warehouse for compute
CREATE OR REPLACE WAREHOUSE my_wh
    COMMENT = 'Learning warehouse for Zero to Snowflake Part 1'
    WAREHOUSE_TYPE = 'STANDARD'
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = FALSE
    INITIALLY_SUSPENDED = TRUE;

USE WAREHOUSE my_wh;

-- First query attempt (will fail if warehouse is suspended)
SELECT * FROM raw_pos.truck;

-- Resume warehouse
ALTER WAREHOUSE my_wh RESUME;

-- Enable auto-resume
ALTER WAREHOUSE my_wh SET AUTO_RESUME = TRUE;

-- Re-run query
SELECT * FROM raw_pos.truck;

-- Scale warehouse for performance testing
ALTER WAREHOUSE my_wh SET WAREHOUSE_SIZE = 'XLARGE';

-- Analytical query: sales per truck brand
SELECT
    o.truck_brand_name,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(o.price) AS total_sales
FROM analytics.orders_v o
GROUP BY o.truck_brand_name
ORDER BY total_sales DESC;

-- Scale warehouse back down
ALTER WAREHOUSE my_wh SET WAREHOUSE_SIZE = 'XSMALL';

-- =========================================================
-- 2. Query Result Cache
-- =========================================================

-- Re-run previous query to observe caching performance improvement
SELECT
    o.truck_brand_name,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(o.price) AS total_sales
FROM analytics.orders_v o
GROUP BY o.truck_brand_name
ORDER BY total_sales DESC;

-- =========================================================
-- 3. Data Transformation (VARIANT → structured)
-- =========================================================

SELECT truck_build FROM raw_pos.truck;

-- Create development clone (zero-copy cloning)
CREATE OR REPLACE TABLE raw_pos.truck_dev 
CLONE raw_pos.truck;

-- Add structured columns
ALTER TABLE raw_pos.truck_dev ADD COLUMN year NUMBER;
ALTER TABLE raw_pos.truck_dev ADD COLUMN make VARCHAR(255);
ALTER TABLE raw_pos.truck_dev ADD COLUMN model VARCHAR(255);

-- Extract structured values from VARIANT column
UPDATE raw_pos.truck_dev
SET 
    year = truck_build:year::NUMBER,
    make = truck_build:make::VARCHAR,
    model = truck_build:model::VARCHAR;

-- Validate transformation
SELECT year, make, model FROM raw_pos.truck_dev;

-- Aggregation example
SELECT 
    make,
    COUNT(*) AS count
FROM raw_pos.truck_dev
GROUP BY make
ORDER BY count DESC;

-- Fix inconsistent values
UPDATE raw_pos.truck_dev
SET make = 'Ford'
WHERE make = 'Ford_';

-- =========================================================
-- 4. Swap Tables (Promotion to Production)
-- =========================================================

ALTER TABLE raw_pos.truck SWAP WITH raw_pos.truck_dev;

-- Verify results
SELECT make, COUNT(*) 
FROM raw_pos.truck
GROUP BY make
ORDER BY COUNT DESC;

-- Drop unnecessary column
ALTER TABLE raw_pos.truck DROP COLUMN truck_build;

-- =========================================================
-- 5. Data Recovery (Time Travel)
-- =========================================================

-- Simulate accidental drop scenario
-- DESCRIBE TABLE raw_pos.truck;

-- Restore dropped table
UNDROP TABLE raw_pos.truck;

-- Cleanup dev table
DROP TABLE raw_pos.truck_dev;

-- =========================================================
-- 6. Resource Monitor
-- =========================================================

USE ROLE accountadmin;

CREATE OR REPLACE RESOURCE MONITOR my_resource_monitor
WITH CREDIT_QUOTA = 100
FREQUENCY = MONTHLY
START_TIMESTAMP = IMMEDIATELY
TRIGGERS
    ON 75 PERCENT DO NOTIFY
    ON 90 PERCENT DO SUSPEND
    ON 100 PERCENT DO SUSPEND_IMMEDIATE;

ALTER WAREHOUSE my_wh
SET RESOURCE_MONITOR = my_resource_monitor;

-- =========================================================
-- 7. Cleanup
-- =========================================================

DROP RESOURCE MONITOR IF EXISTS my_resource_monitor;
DROP TABLE IF EXISTS raw_pos.truck_dev;

ALTER SESSION UNSET query_tag;
