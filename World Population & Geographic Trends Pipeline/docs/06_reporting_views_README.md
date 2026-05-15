# 06 — Reporting Views

This script creates five business-facing SQL views that sit on top of the Dynamic Tables layer and answer specific geographic and economic questions. These are the outputs a business stakeholder or analyst would query directly.

---

## What This Script Does

- Creates five reporting views, each answering a distinct business question
- Verifies all five views return data via row count checks
- Provides preview queries for each view with download instructions for exporting results as CSV
- Includes direct Dynamic Table previews for pipeline inspection

---

## View Descriptions

### v_top_urbanizing_countries
**Question: Which countries urbanized fastest between 2000 and 2023?**

Surfaces countries ranked by absolute urbanization growth (percentage points gained). Includes region and income group context so results can be filtered by geography or development level. Filters out null growth values to ensure only countries with complete data for both anchor years appear.

### v_gdp_leaders_2023
**Question: Which countries had the highest GDP per capita in 2023?**

A ranked snapshot of economic output per person for the most recent complete data year. Includes population and urbanization alongside GDP per capita, making it easy to spot whether high-income countries also tend to be highly urbanized. The `gdp_tier` classification (from the Dynamic Table layer) provides instant income group context.

### v_regional_population_trends
**Question: How has each World Bank region's population, GDP, and urbanization evolved over time?**

A time-series view covering 1990–2023, aggregated by region. Designed for trend analysis — suitable for charting regional population trajectories or comparing how GDP per capita has grown across regions over three decades.

### v_country_snapshot_2023
**Question: What does each country look like today across all key metrics?**

The most comprehensive view in the reporting layer. Joins `country_profiles`, `urbanization_growth`, and `gdp_population_efficiency` to produce a single-row summary per country for 2023, including current population, GDP per capita, urbanization rate, urbanization growth since 2000, and income tier. Results are ordered by population size, making it easy to see how the world's largest countries compare.

### v_urbanization_vs_gdp
**Question: Does higher urbanization correlate with higher GDP per capita?**

An analytical view designed for correlation exploration. Groups countries into four urbanization buckets (Highly Urban, Mostly Urban, Mixed, Mostly Rural) alongside their GDP per capita, enabling visual or statistical analysis of the relationship between urban development and economic output. This view is directly motivated by the geographic question: does where people live predict how wealthy their country is?

---

## Design Decisions

### Views over additional Dynamic Tables
The reporting layer uses standard SQL views rather than additional Dynamic Tables. Views are appropriate here because:
- They add no storage cost and no compute cost until queried
- They are simple projections and joins of already-materialized Dynamic Table data
- Query performance is fast because the underlying Dynamic Tables are pre-computed
- Any analyst can inspect the view definition to understand exactly what they're looking at

### Consistent ROUND() across all views
Every numeric output column is rounded — `ROUND(..., 2)` for rates and currency, `ROUND(..., 0)` for population. This ensures that results look clean when exported to CSV or presented to a stakeholder, without trailing decimal noise.

### v_country_snapshot_2023 as the flagship view
The country snapshot is the most interview-ready view in this project. It answers a question any business stakeholder would immediately understand ("what does Country X look like today?"), joins multiple analytical layers together, and produces output that could be dropped directly into a client presentation. It demonstrates the full pipeline value in a single query.

### urbanization_bucket in v_urbanization_vs_gdp
The four-bucket classification (Highly Urban / Mostly Urban / Mixed / Mostly Rural) makes the correlation analysis accessible to a non-technical audience. Rather than presenting a scatter plot of raw numbers, this bucketing lets a stakeholder immediately see patterns — for example, that nearly all High Income countries fall in the Highly Urban bucket.


---

## Business Questions Answered

| View | Business question |
|---|---|
| `v_top_urbanizing_countries` | Which countries are urbanizing fastest? |
| `v_gdp_leaders_2023` | Who are the economic leaders in 2023? |
| `v_regional_population_trends` | How are world regions evolving over time? |
| `v_country_snapshot_2023` | What does each country look like today? |
| `v_urbanization_vs_gdp` | Does urbanization correlate with wealth? |

---
