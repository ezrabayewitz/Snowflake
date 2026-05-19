USE DATABASE WORLD_POPULATION;
USE SCHEMA ANALYTICS;
USE WAREHOUSE WORLD_WH;


--------------------------------------------------
-- ANALYTICS TARGET TABLE (long/unpivoted format)
--------------------------------------------------

CREATE OR REPLACE TABLE ANALYTICS.country_year_metrics (
    country_name        VARCHAR,
    country_code        VARCHAR,
    indicator_name      VARCHAR,
    indicator_code      VARCHAR,
    year                NUMBER,
    value               FLOAT,
    loaded_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


--------------------------------------------------
-- STREAMS (detect new rows in raw tables)
--------------------------------------------------

CREATE OR REPLACE STREAM RAW.population_stream
    ON TABLE RAW.POPULATION_RAW
    APPEND_ONLY = TRUE;

CREATE OR REPLACE STREAM RAW.indicators_stream
    ON TABLE RAW.INDICATORS_RAW
    APPEND_ONLY = TRUE;


--------------------------------------------------
-- STORED PROCEDURE: unpivot & load new stream data
--------------------------------------------------

CREATE OR REPLACE PROCEDURE ANALYTICS.transform_raw_to_analytics()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN

    INSERT INTO ANALYTICS.country_year_metrics
        (country_name, country_code, indicator_name, indicator_code, year, value)
    SELECT
        country_name, country_code, indicator_name, indicator_code,
        TO_NUMBER(REPLACE(year_col, 'YEAR_', '')) AS year,
        value
    FROM RAW.population_stream
    UNPIVOT(value FOR year_col IN (
        YEAR_1960, YEAR_1961, YEAR_1962, YEAR_1963, YEAR_1964, YEAR_1965,
        YEAR_1966, YEAR_1967, YEAR_1968, YEAR_1969, YEAR_1970, YEAR_1971,
        YEAR_1972, YEAR_1973, YEAR_1974, YEAR_1975, YEAR_1976, YEAR_1977,
        YEAR_1978, YEAR_1979, YEAR_1980, YEAR_1981, YEAR_1982, YEAR_1983,
        YEAR_1984, YEAR_1985, YEAR_1986, YEAR_1987, YEAR_1988, YEAR_1989,
        YEAR_1990, YEAR_1991, YEAR_1992, YEAR_1993, YEAR_1994, YEAR_1995,
        YEAR_1996, YEAR_1997, YEAR_1998, YEAR_1999, YEAR_2000, YEAR_2001,
        YEAR_2002, YEAR_2003, YEAR_2004, YEAR_2005, YEAR_2006, YEAR_2007,
        YEAR_2008, YEAR_2009, YEAR_2010, YEAR_2011, YEAR_2012, YEAR_2013,
        YEAR_2014, YEAR_2015, YEAR_2016, YEAR_2017, YEAR_2018, YEAR_2019,
        YEAR_2020, YEAR_2021, YEAR_2022, YEAR_2023, YEAR_2024, YEAR_2025
    ))
    WHERE METADATA$ACTION = 'INSERT';

    INSERT INTO ANALYTICS.country_year_metrics
        (country_name, country_code, indicator_name, indicator_code, year, value)
    SELECT
        country_name, country_code, indicator_name, indicator_code,
        TO_NUMBER(REPLACE(year_col, 'YEAR_', '')) AS year,
        value
    FROM RAW.indicators_stream
    UNPIVOT(value FOR year_col IN (
        YEAR_1960, YEAR_1961, YEAR_1962, YEAR_1963, YEAR_1964, YEAR_1965,
        YEAR_1966, YEAR_1967, YEAR_1968, YEAR_1969, YEAR_1970, YEAR_1971,
        YEAR_1972, YEAR_1973, YEAR_1974, YEAR_1975, YEAR_1976, YEAR_1977,
        YEAR_1978, YEAR_1979, YEAR_1980, YEAR_1981, YEAR_1982, YEAR_1983,
        YEAR_1984, YEAR_1985, YEAR_1986, YEAR_1987, YEAR_1988, YEAR_1989,
        YEAR_1990, YEAR_1991, YEAR_1992, YEAR_1993, YEAR_1994, YEAR_1995,
        YEAR_1996, YEAR_1997, YEAR_1998, YEAR_1999, YEAR_2000, YEAR_2001,
        YEAR_2002, YEAR_2003, YEAR_2004, YEAR_2005, YEAR_2006, YEAR_2007,
        YEAR_2008, YEAR_2009, YEAR_2010, YEAR_2011, YEAR_2012, YEAR_2013,
        YEAR_2014, YEAR_2015, YEAR_2016, YEAR_2017, YEAR_2018, YEAR_2019,
        YEAR_2020, YEAR_2021, YEAR_2022, YEAR_2023, YEAR_2024, YEAR_2025
    ))
    WHERE METADATA$ACTION = 'INSERT';

    RETURN 'Transform complete';
END;
$$;


--------------------------------------------------
-- TASK: runs every 5 min when streams have data
--------------------------------------------------

CREATE OR REPLACE TASK ANALYTICS.transform_population_task
    WAREHOUSE = WORLD_WH
    SCHEDULE  = '5 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('RAW.population_stream')
      OR SYSTEM$STREAM_HAS_DATA('RAW.indicators_stream')
AS
    CALL ANALYTICS.transform_raw_to_analytics();

ALTER TASK ANALYTICS.transform_population_task RESUME;


--------------------------------------------------
-- INITIAL LOAD: backfill existing raw data
-- (streams only capture future inserts, so we
--  load historical data manually on first run)
--------------------------------------------------

INSERT INTO ANALYTICS.country_year_metrics
    (country_name, country_code, indicator_name, indicator_code, year, value)
SELECT
    country_name, country_code, indicator_name, indicator_code,
    TO_NUMBER(REPLACE(year_col, 'YEAR_', '')) AS year,
    value
FROM WORLD_POPULATION.RAW.POPULATION_RAW
UNPIVOT(value FOR year_col IN (
    YEAR_1960, YEAR_1961, YEAR_1962, YEAR_1963, YEAR_1964, YEAR_1965,
    YEAR_1966, YEAR_1967, YEAR_1968, YEAR_1969, YEAR_1970, YEAR_1971,
    YEAR_1972, YEAR_1973, YEAR_1974, YEAR_1975, YEAR_1976, YEAR_1977,
    YEAR_1978, YEAR_1979, YEAR_1980, YEAR_1981, YEAR_1982, YEAR_1983,
    YEAR_1984, YEAR_1985, YEAR_1986, YEAR_1987, YEAR_1988, YEAR_1989,
    YEAR_1990, YEAR_1991, YEAR_1992, YEAR_1993, YEAR_1994, YEAR_1995,
    YEAR_1996, YEAR_1997, YEAR_1998, YEAR_1999, YEAR_2000, YEAR_2001,
    YEAR_2002, YEAR_2003, YEAR_2004, YEAR_2005, YEAR_2006, YEAR_2007,
    YEAR_2008, YEAR_2009, YEAR_2010, YEAR_2011, YEAR_2012, YEAR_2013,
    YEAR_2014, YEAR_2015, YEAR_2016, YEAR_2017, YEAR_2018, YEAR_2019,
    YEAR_2020, YEAR_2021, YEAR_2022, YEAR_2023, YEAR_2024, YEAR_2025
));

INSERT INTO ANALYTICS.country_year_metrics
    (country_name, country_code, indicator_name, indicator_code, year, value)
SELECT
    country_name, country_code, indicator_name, indicator_code,
    TO_NUMBER(REPLACE(year_col, 'YEAR_', '')) AS year,
    value
FROM WORLD_POPULATION.RAW.INDICATORS_RAW
UNPIVOT(value FOR year_col IN (
    YEAR_1960, YEAR_1961, YEAR_1962, YEAR_1963, YEAR_1964, YEAR_1965,
    YEAR_1966, YEAR_1967, YEAR_1968, YEAR_1969, YEAR_1970, YEAR_1971,
    YEAR_1972, YEAR_1973, YEAR_1974, YEAR_1975, YEAR_1976, YEAR_1977,
    YEAR_1978, YEAR_1979, YEAR_1980, YEAR_1981, YEAR_1982, YEAR_1983,
    YEAR_1984, YEAR_1985, YEAR_1986, YEAR_1987, YEAR_1988, YEAR_1989,
    YEAR_1990, YEAR_1991, YEAR_1992, YEAR_1993, YEAR_1994, YEAR_1995,
    YEAR_1996, YEAR_1997, YEAR_1998, YEAR_1999, YEAR_2000, YEAR_2001,
    YEAR_2002, YEAR_2003, YEAR_2004, YEAR_2005, YEAR_2006, YEAR_2007,
    YEAR_2008, YEAR_2009, YEAR_2010, YEAR_2011, YEAR_2012, YEAR_2013,
    YEAR_2014, YEAR_2015, YEAR_2016, YEAR_2017, YEAR_2018, YEAR_2019,
    YEAR_2020, YEAR_2021, YEAR_2022, YEAR_2023, YEAR_2024, YEAR_2025
));


--------------------------------------------------
-- VERIFY
--------------------------------------------------

SELECT indicator_code, COUNT(*) AS row_count
FROM ANALYTICS.country_year_metrics
GROUP BY indicator_code
ORDER BY row_count DESC;


-- For more information on this script, go to:
-- world-population-pipeline/docs/README's/04-data-transformation-README.md/