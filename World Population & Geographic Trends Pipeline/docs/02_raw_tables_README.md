# 02 — Raw Tables

This script defines the three raw tables that form the landing zone for all World Bank source data. These tables receive data loaded by the Snowpipe definitions created in the previous step.

---

## What This Script Does

- Creates `countries_raw` — country metadata including region, income group, and World Bank classification
- Creates `population_raw` — total population by country across all available years (1960–2025)
- Creates `indicators_raw` — GDP per capita and urbanization rate by country across all available years (1960–2025)

---

## Table Structure

### countries_raw
| Column | Type | Description |
|---|---|---|
| country_code | VARCHAR | ISO 3-letter country code (e.g. USA, BRA) |
| region | VARCHAR | World Bank region classification |
| income_group | VARCHAR | World Bank income group (Low, Middle, High) |
| special_notes | VARCHAR | Additional metadata notes from World Bank |
| table_name | VARCHAR | World Bank table reference name |
| _extra | VARCHAR | Overflow column for any unparsed fields |

### population_raw / indicators_raw
| Column | Type | Description |
|---|---|---|
| country_name | VARCHAR | Full country name |
| country_code | VARCHAR | ISO 3-letter country code |
| indicator_name | VARCHAR | Human-readable indicator description |
| indicator_code | VARCHAR | World Bank indicator code (e.g. SP.POP.TOTL) |
| year_1960–year_2025 | FLOAT | Indicator value for that year (null if unavailable) |
| _extra | VARCHAR | Overflow column for any unparsed fields |

---

## Design Decisions

### Raw tables are never modified
Once data lands in the raw layer it is never updated or deleted. If a transformation breaks or produces incorrect output downstream, the raw tables are the source of truth to re-run from. This is a foundational principle of modern data engineering — separating ingestion from transformation protects against data loss.

### Wide format matches the World Bank CSV structure
World Bank datasets are distributed in a wide format — one row per country, with a separate column for each year. The raw tables mirror this structure exactly so no transformation is needed during ingestion. Converting to a long format (one row per country per year) happens in the analytics layer, where it belongs.

### Extended to year_2025
The year columns extend to 2025 to accommodate any forward-looking or projected data the World Bank includes in recent releases, ensuring the table won't reject rows as the dataset is updated over time.

### _extra column
An `_extra` VARCHAR column is included in all three tables as a catch-all for any additional fields in the source CSV that don't map to defined columns. This prevents load failures if the World Bank adds new columns to future dataset releases — a defensive pattern used in production ingestion pipelines.

### CREATE TABLE IF NOT EXISTS vs CREATE OR REPLACE
`countries_raw` uses `CREATE OR REPLACE` while `population_raw` and `indicators_raw` use `CREATE TABLE IF NOT EXISTS`. The latter is the safer choice in production — it prevents accidentally wiping a table that already contains data. `CREATE OR REPLACE` is appropriate during initial development when a clean slate is needed.

### FLOAT for all year columns
Year columns are typed as FLOAT rather than INTEGER to handle decimal values in indicator data (e.g. urbanization rates like `67.3`) and to gracefully accommodate nulls, which are common in historical data for smaller or newer countries.

---

## What to Verify

After triggering the Snowpipes, confirm row counts:

```sql
SELECT 'countries'  AS tbl, COUNT(*) AS rows FROM countries_raw  UNION ALL
SELECT 'population' AS tbl, COUNT(*) AS rows FROM population_raw UNION ALL
SELECT 'indicators' AS tbl, COUNT(*) AS rows FROM indicators_raw;
```

Expected approximate counts:

| Table | Expected rows |
|---|---|
| countries_raw | ~265 |
| population_raw | ~265 |
| indicators_raw | ~530 (two indicators × ~265 countries) |
