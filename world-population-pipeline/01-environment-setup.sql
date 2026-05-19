-- Create the environment for the world population pipeline. This includes the database,
-- the 3 schemas of our pipeline (RAW, ANALYTICS, REPORTING), and the warehouse.

CREATE DATABASE IF NOT EXISTS WORLD_POPULATION;

CREATE SCHEMA IF NOT EXISTS WORLD_POPULATION.RAW;
CREATE SCHEMA IF NOT EXISTS WORLD_POPULATION.ANALYTICS;
CREATE SCHEMA IF NOT EXISTS WORLD_POPULATION.REPORTING;

CREATE WAREHOUSE IF NOT EXISTS WORLD_WH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;

USE DATABASE WORLD_POPULATION;
USE WAREHOUSE WORLD_WH;


-- For more information on this script, go to:
-- world-population-pipeline/docs/README's/01-environment-setup-README.md/