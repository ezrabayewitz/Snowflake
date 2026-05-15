USE DATABASE WORLD_POPULATION;
USE SCHEMA RAW;
USE WAREHOUSE WORLD_WH;

CREATE OR REPLACE FILE FORMAT world_bank_csv
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

-- Snowpipe for population data
CREATE OR REPLACE PIPE pop_pipe
  AUTO_INGEST = FALSE
  AS
  COPY INTO RAW.POPULATION_RAW
  FROM @world_stage/WORLD_POPULATION.zip
  FILE_FORMAT = (FORMAT_NAME = world_bank_csv)
  ON_ERROR = 'CONTINUE';

  
-- Snowpipe for GDP/indicators data
CREATE OR REPLACE PIPE indicators_pipe
  AUTO_INGEST = FALSE
  AS
  COPY INTO RAW.INDICATORS_RAW
  FROM @world_stage/GDP_PER_CAPITA.zip
  FILE_FORMAT = (FORMAT_NAME = world_bank_csv)
  ON_ERROR = 'CONTINUE';

-- Snowpipe for country metadata
CREATE OR REPLACE PIPE countries_pipe
  AUTO_INGEST = FALSE
  AS
  COPY INTO RAW.COUNTRIES_RAW
  FROM @world_stage/URBAN_POPULATION_PCT.zip
  FILE_FORMAT = (FORMAT_NAME = world_bank_csv)
  ON_ERROR = 'CONTINUE';

LIST @world_stage;
