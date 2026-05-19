-- This script sets up the data ingestion environment for the retail sales pipeline project.
-- It creates a stage for raw data ingestion and configures the necessary settings, 
-- such as file format options for CSV files. It also lists the contents of the stage to verify the setup.

USE DATABASE RETAIL_PIPELINE;
USE SCHEMA RAW;
USE WAREHOUSE RETAIL_WH;

CREATE STAGE IF NOT EXISTS raw_stage
  FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
  );


-- List the contents of the stage to verify that it has been set up correctly.

  LIST @raw_stage;



-- For more information on this script, go to:
-- retail-sales-pipeline/docs/README's/02-data-ingestion-setup-README.md/