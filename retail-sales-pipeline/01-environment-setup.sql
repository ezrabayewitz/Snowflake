-- This script sets up the environment for the retail sales pipeline project.
-- It creates a database, schemas, and a warehouse for the project.

CREATE DATABASE if not exists Retail_Pipeline;

CREATE SCHEMA IF NOT EXISTS RETAIL_PIPELINE.RAW;
CREATE SCHEMA IF NOT EXISTS RETAIL_PIPELINE.ANALYTICS;
CREATE SCHEMA IF NOT EXISTS RETAIL_PIPELINE.REPORTING;

CREATE WAREHOUSE IF NOT EXISTS RETAIL_WH
  WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

Use DATABASE RETAIL_PIPELINE;
use warehouse retail_wh;
  
