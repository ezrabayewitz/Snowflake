USE DATABASE WORLD_POPULATION;
USE SCHEMA RAW;
USE WAREHOUSE WORLD_WH;


-- File format for main data files (population, GDP, urbanization)
-- These files include a 5-line header

CREATE OR REPLACE FILE FORMAT world_bank_csv
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 5
  NULL_IF = ('NULL', 'null', '', 'NA', '..')
  EMPTY_FIELD_AS_NULL = TRUE
  TRIM_SPACE = TRUE
  COMPRESSION = 'AUTO';

-- File format for country metadata file, whivch has 1-line header

CREATE OR REPLACE FILE FORMAT world_bank_metadata_csv
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null', '', 'NA', '..')
  EMPTY_FIELD_AS_NULL = TRUE
  TRIM_SPACE = TRUE
  COMPRESSION = 'AUTO';

-- Internal stage

CREATE STAGE IF NOT EXISTS world_stage
    FILE_FORMAT = (FORMAT_NAME = world_bank_csv)
    COMMENT = 'Internal stage for World Bank CSV uploads';


-- -------------------------------------------------------
-- SNOWPIPE FOR LOADING DATA
-- -------------------------------------------------------


-- Loading population data

CREATE OR REPLACE PIPE pop_pipe
  AUTO_INGEST = FALSE
  AS
  COPY INTO RAW.POPULATION_RAW
  FROM @world_stage/API_SP.POP.TOTL_DS2_en_csv_v2_127039.csv
  FILE_FORMAT = (FORMAT_NAME = world_bank_csv)
  ON_ERROR = 'CONTINUE';

  
-- Loading GDP/indicators data

CREATE OR REPLACE PIPE indicators_pipe
  AUTO_INGEST = FALSE
  AS
  COPY INTO RAW.INDICATORS_RAW
  FROM @world_stage/API_NY.GDP.PCAP.CD_DS2_en_csv_v2_121663.csv
  FILE_FORMAT = (FORMAT_NAME = world_bank_csv)
  ON_ERROR = 'CONTINUE';

-- Loading country metadata

CREATE OR REPLACE PIPE countries_pipe
  AUTO_INGEST = FALSE
  AS
  COPY INTO RAW.COUNTRIES_RAW
  FROM @world_stage/Metadata_Country_API_SP.POP.TOTL_DS2_en_csv_v2_127039.csv
  FILE_FORMAT = (FORMAT_NAME = world_bank_metadata_csv)
  ON_ERROR = 'CONTINUE';

-- Loading urbaization data

CREATE OR REPLACE PIPE urban_pipe
  AUTO_INGEST = FALSE
  AS
  COPY INTO RAW.INDICATORS_RAW
  FROM @world_stage/API_SP.URB.TOTL.IN.ZS_DS2_en_csv_v2_121583.csv
  FILE_FORMAT = (FORMAT_NAME = world_bank_csv)
  ON_ERROR = 'CONTINUE';

LIST @world_stage;

ALTER PIPE pop_pipe REFRESH;
ALTER PIPE indicators_pipe REFRESH;
ALTER PIPE countries_pipe REFRESH;


-- For more information on this script, go to:
-- world-population-pipeline/docs/README's/03-data-ingestion-snowpipe-README.md/