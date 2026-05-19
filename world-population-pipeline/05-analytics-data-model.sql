-- In this section, 4 dynamic tables will be created. These tables carry the purpose
-- of self-updating, and create the analytics layer of the pipeline.

USE DATABASE WORLD_POPULATION;
USE SCHEMA ANALYTICS;
USE WAREHOUSE WORLD_WH;


--------------------------------------------------
-- Dynamic Table 1: Country profile
-- One row per country/year with all 3 indicators
-- joined together and country metadata attached
--------------------------------------------------

CREATE OR REPLACE DYNAMIC TABLE ANALYTICS.country_profiles
    TARGET_LAG = '5 minutes'
    WAREHOUSE  = WORLD_WH
AS
SELECT
    m.country_code,
    m.country_name,
    c.region,
    c.income_group,
    m.year,
    MAX(CASE WHEN m.indicator_code = 'SP.POP.TOTL'       THEN m.value END) AS population,
    MAX(CASE WHEN m.indicator_code = 'NY.GDP.PCAP.CD'    THEN m.value END) AS gdp_per_capita,
    MAX(CASE WHEN m.indicator_code = 'SP.URB.TOTL.IN.ZS' THEN m.value END) AS urban_pct
FROM ANALYTICS.country_year_metrics m
LEFT JOIN WORLD_POPULATION.RAW.countries_raw c
    ON m.country_code = c.country_code
GROUP BY
    m.country_code, m.country_name, c.region, c.income_group, m.year;


--------------------------------------------------
-- Dynamic Table 2: Urbanization growth
-- Which countries/regions urbanized fastest?
-- Compares urban_pct in 2000 vs most recent year
--------------------------------------------------

CREATE OR REPLACE DYNAMIC TABLE ANALYTICS.urbanization_growth
    TARGET_LAG = '5 minutes'
    WAREHOUSE  = WORLD_WH
AS
SELECT
    cp.country_code,
    cp.country_name,
    cp.region,
    cp.income_group,
    MAX(CASE WHEN cp.year = 2000 THEN cp.urban_pct END) AS urban_pct_2000,
    MAX(CASE WHEN cp.year = 2023 THEN cp.urban_pct END) AS urban_pct_2023,
    MAX(CASE WHEN cp.year = 2023 THEN cp.urban_pct END)
        - MAX(CASE WHEN cp.year = 2000 THEN cp.urban_pct END) AS urban_growth_pct
FROM ANALYTICS.country_profiles cp
WHERE cp.year IN (2000, 2023)
GROUP BY cp.country_code, cp.country_name, cp.region, cp.income_group
HAVING urban_pct_2000 IS NOT NULL AND urban_pct_2023 IS NOT NULL
ORDER BY urban_growth_pct DESC;


--------------------------------------------------
-- Dynamic Table 3: GDP vs population efficiency
-- "Punching above weight" — countries with high
-- GDP per capita relative to population size
--------------------------------------------------

CREATE OR REPLACE DYNAMIC TABLE ANALYTICS.gdp_population_efficiency
    TARGET_LAG = '5 minutes'
    WAREHOUSE  = WORLD_WH
AS
SELECT
    cp.country_code,
    cp.country_name,
    cp.region,
    cp.income_group,
    cp.population,
    cp.gdp_per_capita,
    cp.urban_pct,
    ROUND(cp.gdp_per_capita / NULLIF(cp.population / 1000000, 0), 2) AS gdp_per_capita_per_million_pop,
    CASE
        WHEN cp.gdp_per_capita >= 40000                          THEN 'High Income'
        WHEN cp.gdp_per_capita >= 10000                          THEN 'Upper Middle'
        WHEN cp.gdp_per_capita >= 2000                           THEN 'Lower Middle'
        ELSE                                                          'Low Income'
    END AS gdp_tier
FROM ANALYTICS.country_profiles cp
WHERE cp.year = 2023
  AND cp.population IS NOT NULL
  AND cp.gdp_per_capita IS NOT NULL;


--------------------------------------------------
-- Dynamic Table 4: Regional summary
-- Aggregated stats per region per year
--------------------------------------------------

CREATE OR REPLACE DYNAMIC TABLE ANALYTICS.regional_trends
    TARGET_LAG = '5 minutes'
    WAREHOUSE  = WORLD_WH
AS
SELECT
    region,
    year,
    COUNT(DISTINCT country_code)        AS country_count,
    SUM(population)                     AS total_population,
    ROUND(AVG(gdp_per_capita), 2)       AS avg_gdp_per_capita,
    ROUND(AVG(urban_pct), 2)            AS avg_urban_pct,
    ROUND(MIN(gdp_per_capita), 2)       AS min_gdp_per_capita,
    ROUND(MAX(gdp_per_capita), 2)       AS max_gdp_per_capita
FROM ANALYTICS.country_profiles
WHERE region IS NOT NULL
  AND year BETWEEN 1990 AND 2023
GROUP BY region, year;


-- For more information on this script, go to:
-- world-population-pipeline/docs/README's/05-analytics-data-model-README.md/