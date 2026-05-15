# 05 — Dynamic Tables

This script creates four Dynamic Tables that form the self-updating analytics layer of the pipeline. Dynamic Tables are one of Snowflake's most powerful modern features — they declaratively define a transformation result and Snowflake automatically keeps them fresh as upstream data changes.

---

## What This Script Does

- Creates `country_profiles` — a unified view of all three indicators per country per year, joined with country metadata
- Creates `urbanization_growth` — ranks countries by how much their urban population percentage grew from 2000 to 2023
- Creates `gdp_population_efficiency` — identifies countries that punch above their weight economically relative to population size
- Creates `regional_trends` — aggregated population, GDP, and urbanization statistics by World Bank region from 1990 to 2023
- Verifies all four dynamic tables populated correctly


---

## Dynamic Table Descriptions

### 1. country_profiles
The foundational dynamic table. Pivots `country_year_metrics` from long format back into a wide analytical format — one row per country per year with population, GDP per capita, and urbanization as separate columns. Also joins in country metadata (region, income group) from `countries_raw`.

The `MAX(CASE WHEN indicator_code = '...' THEN value END)` pattern is a conditional aggregation pivot — a standard SQL technique for reshaping long data into wide columns without a native PIVOT syntax dependency.

This table is the upstream source for all three other dynamic tables, forming a dependency chain that Snowflake manages automatically.

### 2. urbanization_growth
Answers the question: **which countries urbanized fastest between 2000 and 2023?**

Compares `urban_pct` at year 2000 vs year 2023 for each country and calculates the absolute percentage point change. The `HAVING` clause filters out countries missing data for either anchor year, ensuring the growth calculation is always valid.

### 3. gdp_population_efficiency
Answers the question: **which countries punch above their weight economically relative to their population size?**

The derived metric `gdp_per_capita_per_million_pop` normalizes GDP per capita against population in millions, surfacing countries that generate disproportionate economic output for their size. `NULLIF(..., 0)` prevents division-by-zero errors for any country with near-zero population.

The `gdp_tier` classification uses a CASE statement to bucket countries into income tiers (High Income, Upper Middle, Lower Middle, Low Income) — mirroring the World Bank's own income group classifications for easy comparison.

### 4. regional_trends
Answers the question: **how have World Bank regions evolved on population, GDP, and urbanization from 1990 to 2023?**

Aggregates country-level data to the regional level, providing min/max GDP per capita alongside averages to expose within-region inequality. Filtered to `region IS NOT NULL` to exclude aggregate World Bank rows (e.g. "World", "OECD members") that don't belong to a specific region.

---

## Design Decisions

### Dynamic Tables chain off each other
`urbanization_growth`, `gdp_population_efficiency`, and `regional_trends` all query `country_profiles` rather than the base `country_year_metrics` table. This creates a dependency chain — Snowflake automatically refreshes downstream tables after upstream tables update, in the correct order. This is a key advantage of Dynamic Tables over manually orchestrated pipelines.

### TARGET_LAG = '5 minutes'
All four tables use a 5-minute lag, matching the Task schedule from Step 4. This ensures the full pipeline — from new raw data arriving to analytics tables refreshing — completes within a 5-10 minute window end to end.

### year = 2023 for point-in-time tables
`gdp_population_efficiency` is filtered to 2023 as the most recent complete data year. Using `MAX(year)` instead would be more dynamic but risks mixing years across countries if some have 2024 data and others don't. 2023 is the last year with near-complete global coverage in the World Bank dataset.

### Mathematical precision with ROUND and NULLIF
All derived numeric columns use `ROUND(..., 2)` for clean output and `NULLIF(..., 0)` where division is involved. These are small details that prevent common data quality issues — the kind of precision a mathematics background naturally produces.

---
