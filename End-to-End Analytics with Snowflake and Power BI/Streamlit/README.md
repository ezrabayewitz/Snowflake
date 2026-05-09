# Tasty Bytes - Regional Sales Dashboard

An interactive Streamlit dashboard analyzing monthly sales performance across global regions for the Tasty Bytes food truck business, built on Snowflake Dynamic Tables.

> **Note:** This Streamlit dashboard was built as an alternative to the Power BI section of the [End-to-End Analytics with Snowflake and Power BI](https://quickstarts.snowflake.com/) quickstart guide. I did not have access to Power BI, so I created this interactive dashboard in Streamlit in Snowflake to demonstrate the same analytical capabilities using the star schema and Dynamic Tables built throughout the guide.

## Features

- Monthly revenue trend lines by region (EMEA, North America, APAC)
- Stacked bar chart showing regional revenue composition
- Side-by-side order volume and average order value comparisons
- Summary metrics table with revenue, orders, AOV, and unique customers
- Interactive year filter for drill-down analysis

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Data Warehouse | Snowflake |
| Data Modeling | Star Schema (Dynamic Tables) |
| Application | Streamlit in Snowflake |
| Visualizations | Altair |
| Language | Python |
| Data Access | Snowpark |

## Data Architecture

The dashboard queries a star schema of Dynamic Tables in `TB_101.POWERBI`, built during the quickstart:

- **Fact Tables:** `DT_FACT_ORDER_AGG`, `DT_FACT_ORDER_HEADER`, `DT_FACT_ORDER_DETAIL`
- **Dimension Tables:** `DT_DIM_LOCATION`, `DT_DIM_CUSTOMER`, `DT_DIM_FRANCHISE`, `DT_DIM_TRUCK`, `DT_DIM_MENU_ITEM`

## Demo

<!-- Add your screen recording or GIF here -->

## Author

Ezra Bayewitz
