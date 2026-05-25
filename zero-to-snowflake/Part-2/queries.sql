-- =========================================================
-- Part 2 – Zero to Snowflake
-- Simple Data Pipeline (Ingestion → Transformation → Automation)
-- =========================================================

ALTER SESSION SET query_tag =
'{"project":"zero-to-snowflake","part":2,"type":"data-pipeline"}';

USE DATABASE tb_101;
USE ROLE tb_data_engineer;
USE WAREHOUSE tb_de_wh;

-- =========================================================
-- 1. External Data Ingestion (S3 Stage)
-- =========================================================

CREATE OR REPLACE STAGE raw_pos.menu_stage
COMMENT = 'Stage for menu data from S3'
URL = 's3://sfquickstarts/frostbyte_tastybytes/raw_pos/menu/'
FILE_FORMAT = public.csv_ff;

-- Staging table for raw ingestion
CREATE OR REPLACE TABLE raw_pos.menu_staging (
    menu_id NUMBER(19,0),
    menu_type_id NUMBER(38,0),
    menu_type VARCHAR,
    truck_brand_name VARCHAR,
    menu_item_id NUMBER(38,0),
    menu_item_name VARCHAR,
    item_category VARCHAR,
    item_subcategory VARCHAR,
    cost_of_goods_usd NUMBER(38,4),
    sale_price_usd NUMBER(38,4),
    menu_item_health_metrics_obj VARIANT
);

-- Load data from external stage
COPY INTO raw_pos.menu_staging
FROM @raw_pos.menu_stage;

SELECT * FROM raw_pos.menu_staging;

-- =========================================================
-- 2. Semi-Structured Data (VARIANT)
-- =========================================================

-- Inspect JSON-like structure
SELECT menu_item_health_metrics_obj
FROM raw_pos.menu_staging;

-- Extract nested JSON fields
SELECT
    menu_item_name,
    menu_item_health_metrics_obj:menu_item_id::INTEGER AS menu_item_id,
    menu_item_health_metrics_obj:menu_item_health_metrics[0]:ingredients::ARRAY AS ingredients
FROM raw_pos.menu_staging;

-- Flatten nested ingredient arrays
SELECT
    f.value::STRING AS ingredient_name,
    m.menu_item_health_metrics_obj:menu_item_id::INTEGER AS menu_item_id
FROM raw_pos.menu_staging m,
LATERAL FLATTEN(
    INPUT => m.menu_item_health_metrics_obj:menu_item_health_metrics[0]:ingredients::ARRAY
) f;

-- =========================================================
-- 3. Dynamic Table: Ingredient Base Layer
-- =========================================================

CREATE OR REPLACE DYNAMIC TABLE harmonized.ingredient
    LAG = '1 minute'
    WAREHOUSE = 'TB_DE_WH'
AS
SELECT
    i.value::STRING AS ingredient_name,
    ARRAY_AGG(DISTINCT m.menu_item_id) AS menu_ids
FROM raw_pos.menu_staging m,
LATERAL FLATTEN(
    INPUT => m.menu_item_health_metrics_obj:menu_item_health_metrics[0]:ingredients::ARRAY
) i
GROUP BY i.value::STRING;

SELECT * FROM harmonized.ingredient;

-- =========================================================
-- 4. Simulated Data Change (Pipeline Trigger)
-- =========================================================

INSERT INTO raw_pos.menu_staging
SELECT
    10101,
    15,
    'Sandwiches',
    'Better Off Bread',
    157,
    'Banh Mi',
    'Main',
    'Cold Option',
    9.0,
    12.0,
    PARSE_JSON('{
      "menu_item_health_metrics": [
        {
          "ingredients": [
            "French Baguette",
            "Mayonnaise",
            "Pickled Daikon",
            "Cucumber",
            "Pork Belly"
          ],
          "is_dairy_free_flag": "N",
          "is_gluten_free_flag": "N",
          "is_healthy_flag": "Y",
          "is_nut_free_flag": "Y"
        }
      ],
      "menu_item_id": 157
    }'
);

-- =========================================================
-- 5. Ingredient → Menu Mapping Layer
-- =========================================================

CREATE OR REPLACE DYNAMIC TABLE harmonized.ingredient_to_menu_lookup
    LAG = '1 minute'
    WAREHOUSE = 'TB_DE_WH'
AS
SELECT
    i.value::STRING AS ingredient_name,
    m.menu_item_health_metrics_obj:menu_item_id::INTEGER AS menu_item_id
FROM raw_pos.menu_staging m,
LATERAL FLATTEN(
    INPUT => m.menu_item_health_metrics_obj:menu_item_health_metrics[0]:ingredients
) i
JOIN harmonized.ingredient ing
    ON i.value::STRING = ing.ingredient_name;

SELECT * FROM harmonized.ingredient_to_menu_lookup;

-- =========================================================
-- 6. Order Simulation (Pipeline Activation)
-- =========================================================

INSERT INTO raw_pos.order_header
SELECT
    459520441,
    15,
    1030,
    101565,
    NULL,
    200322900,
    TO_TIMESTAMP_NTZ('08:00:00', 'hh:mi:ss'),
    TO_TIMESTAMP_NTZ('14:00:00', 'hh:mi:ss'),
    NULL,
    TO_TIMESTAMP_NTZ('2022-01-27 08:21:08'),
    NULL,
    'USD',
    14.00,
    NULL,
    NULL,
    14.00;

INSERT INTO raw_pos.order_detail
SELECT
    904745311,
    459520441,
    157,
    NULL,
    0,
    2,
    14.00,
    28.00,
    NULL;

-- =========================================================
-- 7. Downstream Aggregation Layer
-- =========================================================

CREATE OR REPLACE DYNAMIC TABLE harmonized.ingredient_usage_by_truck
    LAG = '2 minute'
    WAREHOUSE = 'TB_DE_WH'
AS
SELECT
    oh.truck_id,
    EXTRACT(YEAR FROM oh.order_ts) AS order_year,
    MONTH(oh.order_ts) AS order_month,
    i.ingredient_name,
    SUM(od.quantity) AS total_ingredients_used
FROM raw_pos.order_detail od
JOIN raw_pos.order_header oh
    ON od.order_id = oh.order_id
JOIN harmonized.ingredient_to_menu_lookup iml
    ON od.menu_item_id = iml.menu_item_id
JOIN harmonized.ingredient i
    ON iml.ingredient_name = i.ingredient_name
JOIN raw_pos.location l
    ON l.location_id = oh.location_id
WHERE l.country = 'United States'
GROUP BY
    oh.truck_id,
    order_year,
    order_month,
    i.ingredient_name;

SELECT *
FROM harmonized.ingredient_usage_by_truck
WHERE order_month = 1
  AND truck_id = 15;

-- =========================================================
-- CLEANUP
-- =========================================================

DROP TABLE IF EXISTS raw_pos.menu_staging;
DROP TABLE IF EXISTS harmonized.ingredient;
DROP TABLE IF EXISTS harmonized.ingredient_to_menu_lookup;
DROP TABLE IF EXISTS harmonized.ingredient_usage_by_truck;

DELETE FROM raw_pos.order_detail WHERE order_detail_id = 904745311;
DELETE FROM raw_pos.order_header WHERE order_id = 459520441;

ALTER SESSION UNSET query_tag;
ALTER WAREHOUSE tb_de_wh SUSPEND;
