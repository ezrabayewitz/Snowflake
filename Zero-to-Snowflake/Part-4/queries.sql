-- =========================================================
-- Part 4 – Zero to Snowflake
-- Governance with Horizon (Security, Privacy, Data Quality)
-- =========================================================

ALTER SESSION SET query_tag =
'{"project":"zero-to-snowflake","part":4,"type":"governance"}';

USE ROLE useradmin;
USE DATABASE tb_101;
USE WAREHOUSE tb_dev_wh;

-- =========================================================
-- 1. Roles & Access Control (RBAC)
-- =========================================================

SHOW ROLES;

CREATE OR REPLACE ROLE tb_data_steward
    COMMENT = 'Custom data governance role';

USE ROLE securityadmin;

-- Warehouse access
GRANT OPERATE, USAGE ON WAREHOUSE tb_dev_wh TO ROLE tb_data_steward;

-- Database + schema access
GRANT USAGE ON DATABASE tb_101 TO ROLE tb_data_steward;
GRANT USAGE ON ALL SCHEMAS IN DATABASE tb_101 TO ROLE tb_data_steward;

-- Table access
GRANT SELECT ON ALL TABLES IN SCHEMA raw_customer TO ROLE tb_data_steward;
GRANT ALL ON SCHEMA governance TO ROLE tb_data_steward;
GRANT ALL ON ALL TABLES IN SCHEMA governance TO ROLE tb_data_steward;

-- Assign role to current user
SET my_user = CURRENT_USER();
GRANT ROLE tb_data_steward TO USER IDENTIFIER($my_user);

USE ROLE tb_data_steward;

SELECT TOP 100 * FROM raw_customer.customer_loyalty;

-- =========================================================
-- 2. Tag-Based Classification (PII Detection)
-- =========================================================

USE ROLE accountadmin;

CREATE OR REPLACE TAG governance.pii;
GRANT APPLY TAG ON ACCOUNT TO ROLE tb_data_steward;

GRANT EXECUTE AUTO CLASSIFICATION ON SCHEMA raw_customer TO ROLE tb_data_steward;
GRANT DATABASE ROLE SNOWFLAKE.CLASSIFICATION_ADMIN TO ROLE tb_data_steward;
GRANT CREATE SNOWFLAKE.DATA_PRIVACY.CLASSIFICATION_PROFILE ON SCHEMA governance TO ROLE tb_data_steward;

USE ROLE tb_data_steward;

CREATE OR REPLACE SNOWFLAKE.DATA_PRIVACY.CLASSIFICATION_PROFILE
  governance.tb_classification_profile(
    {
      'minimum_object_age_for_classification_days': 0,
      'maximum_classification_validity_days': 30,
      'auto_tag': true
    });

CALL governance.tb_classification_profile!SET_TAG_MAP(
  {'column_tag_map':[
    {
      'tag_name':'tb_101.governance.pii',
      'tag_value':'pii',
      'semantic_categories':['NAME','PHONE_NUMBER','POSTAL_CODE','DATE_OF_BIRTH','CITY','EMAIL']
    }]});

CALL SYSTEM$CLASSIFY(
    'tb_101.raw_customer.customer_loyalty',
    'tb_101.governance.tb_classification_profile'
);

-- View tagging results
SELECT 
    column_name,
    tag_name,
    tag_value
FROM TABLE(
    INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS(
        'raw_customer.customer_loyalty',
        'table'
    )
);

-- =========================================================
-- 3. Column-Level Security (Masking Policies)
-- =========================================================

CREATE OR REPLACE MASKING POLICY governance.mask_string_pii
AS (val STRING) RETURNS STRING ->
CASE
    WHEN CURRENT_ROLE() NOT IN ('ACCOUNTADMIN','TB_ADMIN')
    THEN '****MASKED****'
    ELSE val
END;

CREATE OR REPLACE MASKING POLICY governance.mask_date_pii
AS (val DATE) RETURNS DATE ->
CASE
    WHEN CURRENT_ROLE() NOT IN ('ACCOUNTADMIN','TB_ADMIN')
    THEN DATE_TRUNC('year', val)
    ELSE val
END;

ALTER TAG governance.pii SET
    MASKING POLICY governance.mask_string_pii,
    MASKING POLICY governance.mask_date_pii;

-- Test masking
USE ROLE public;
SELECT TOP 100 * FROM raw_customer.customer_loyalty;

USE ROLE tb_admin;
SELECT TOP 100 * FROM raw_customer.customer_loyalty;

-- =========================================================
-- 4. Row-Level Security (Row Access Policy)
-- =========================================================

USE ROLE tb_data_steward;

CREATE OR REPLACE TABLE governance.row_policy_map (
    role STRING,
    country_permission STRING
);

INSERT INTO governance.row_policy_map
VALUES ('tb_data_engineer','United States');

CREATE OR REPLACE ROW ACCESS POLICY governance.customer_loyalty_policy
AS (country STRING) RETURNS BOOLEAN ->
    CURRENT_ROLE() IN ('ACCOUNTADMIN','SYSADMIN')
    OR EXISTS (
        SELECT 1
        FROM governance.row_policy_map rp
        WHERE UPPER(rp.role) = CURRENT_ROLE()
          AND rp.country_permission = country
    );

ALTER TABLE raw_customer.customer_loyalty
ADD ROW ACCESS POLICY governance.customer_loyalty_policy ON (country);

-- Test row filtering
USE ROLE tb_data_engineer;
SELECT TOP 100 * FROM raw_customer.customer_loyalty;

-- =========================================================
-- 5. Data Quality Monitoring (DMFs)
-- =========================================================

USE ROLE tb_data_steward;

-- System DMFs
SELECT SNOWFLAKE.CORE.NULL_PERCENT(
    SELECT customer_id FROM raw_pos.order_header
);

SELECT SNOWFLAKE.CORE.DUPLICATE_COUNT(
    SELECT order_id FROM raw_pos.order_header
);

SELECT SNOWFLAKE.CORE.AVG(
    SELECT order_total FROM raw_pos.order_header
);

-- Custom DMF
CREATE OR REPLACE DATA METRIC FUNCTION governance.invalid_order_total_count(
    order_prices_t TABLE(
        order_total NUMBER,
        unit_price NUMBER,
        quantity INTEGER
    )
)
RETURNS NUMBER
AS
'SELECT COUNT(*) FROM order_prices_t
 WHERE order_total != unit_price * quantity';

-- Simulate bad data
INSERT INTO raw_pos.order_detail
SELECT
    904745311,
    459520442,
    52,
    NULL,
    0,
    2,
    5.0,
    5.0,
    NULL;

SELECT governance.invalid_order_total_count(
    SELECT price, unit_price, quantity
    FROM raw_pos.order_detail
);

ALTER TABLE raw_pos.order_detail
SET DATA_METRIC_SCHEDULE = 'TRIGGER_ON_CHANGES';

ALTER TABLE raw_pos.order_detail
ADD DATA METRIC FUNCTION governance.invalid_order_total_count
ON (price, unit_price, quantity);

-- =========================================================
-- 6. Trust Center (Manual UI Step)
-- =========================================================

-- Grant Trust Center admin permissions
USE ROLE accountadmin;
GRANT APPLICATION ROLE SNOWFLAKE.TRUST_CENTER_ADMIN TO ROLE tb_admin;

-- NOTE:
-- Remaining Trust Center steps are completed in Snowsight UI:
-- Governance & Security → Trust Center
-- Enable scanner packages (CIS Benchmarks, Threat Intelligence)

-- =========================================================
-- CLEANUP
-- =========================================================

USE ROLE accountadmin;

DROP ROLE IF EXISTS tb_data_steward;

ALTER TAG IF EXISTS governance.pii UNSET
    MASKING POLICY governance.mask_string_pii,
    MASKING POLICY governance.mask_date_pii;

DROP MASKING POLICY IF EXISTS governance.mask_string_pii;
DROP MASKING POLICY IF EXISTS governance.mask_date_pii;

ALTER TABLE raw_customer.customer_loyalty
DROP ROW ACCESS POLICY governance.customer_loyalty_policy;

DROP ROW ACCESS POLICY IF EXISTS governance.customer_loyalty_policy;

DELETE FROM raw_pos.order_detail WHERE order_detail_id = 904745311;

ALTER TABLE raw_pos.order_detail
DROP DATA METRIC FUNCTION governance.invalid_order_total_count
ON (price, unit_price, quantity);

DROP FUNCTION governance.invalid_order_total_count(TABLE(NUMBER, NUMBER, INTEGER));

ALTER TABLE raw_pos.order_detail UNSET DATA_METRIC_SCHEDULE;

DROP TAG IF EXISTS governance.pii;

ALTER SESSION UNSET query_tag;
ALTER WAREHOUSE tb_dev_wh SUSPEND;
