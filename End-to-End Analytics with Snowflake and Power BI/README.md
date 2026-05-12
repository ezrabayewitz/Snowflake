# End-to-End Analytics with Snowflake and Power BI

A structured, hands-on walkthrough, learning how to easily transform raw data into an optimal format for analysis within Power BI.


Concepts applied using a sample dataset called Tasty Bytes.



---

# Objective

To gain practical experience with core Snowflake concepts including:
- How to easily profile data with Snowsight
- How to enrich your organizational data with third party datasets from the Snowflake Marketplace
- Understanding the fundamentals and benefits of a star schema design
- How to build simple ELT pipelines with SQL using Dynamic Tables
- How to tag and protect your data with Snowflake Horizon's governance features
- Connecting Power BI to Snowflake to perform near-real time analytics


To gain hands-on experience in the following areas:
- Data engineering pipelines using declarative SQL with Dynamic Tables
- A star schema that is protected with Snowflake Horizon features such as masking policies
- A Power BI DirectQuery semantic model that is designed for performance and near real-time analytics without the hassle of scheduling refreshes

---

# Project Structure

```
End-to-End Analytics with Snowflake and Power BI/
├── README.md
├── Part-1/
│   ├── README.md
│   └── queries.sql
├── Part-2/
│   ├── README.md
│   └── queries.sql
├── Part-3/
│   ├── README.md
│   └── queries.sql
├── Part-4/
│   ├── README.md
│   └── queries.sql
├── Streamlit/
│   ├── README.md
│   └── queries.sql

```


---

# Learning Progress

## Part 1 – Data Profiling

Learned how to use Snowflake Horizon to protect sensitive data. You auto-classified PII columns and applied custom tags, then created dynamic masking policies that hide or partially obscure names, emails, phone numbers, and dates of birth based on the user's role. Finally, you implemented row access policies so regional analyst roles can only see data for their assigned region. All of this is enforced at the engine level and is transparent to Power BI.

## Part 2 – Marketplace Data


Learned how to enrich first-party data with third-party datasets from the Snowflake Marketplace. Accessed a SafeGraph listing containing location metadata (coordinates, street addresses, categories), explored it with sample queries, then performed a cross-database join to combine it with existing location data using a shared placekey. Copied the marketplace data into my own schema so it could be consumed by dynamic tables in the next section — all without any data movement or ETL pipelines.

## Part 3 – Star Schema with Dynamic Tables

Learned how to model a star schema using Dynamic Tables. Created static date and time dimensions using Snowflake's generator functions, then built dimension tables (truck, franchise, menu item, location, customer) and layered fact tables (order detail → order header → order aggregate) as dynamic tables with DOWNSTREAM and time-based target lags. The dynamic tables form a dependency graph that Snowflake automatically refreshes as upstream data changes — giving a continuously up-to-date star schema without manual ETL orchestration. Used elastic compute by temporarily scaling up a warehouse for the initial load, then scaling it back down when finished.

## Part 4 – Data Governance

Learned how to use Snowflake Horizon to protect sensitive data. Auto-classified PII columns and applied custom tags, then created dynamic masking policies that hide or partially obscure names, emails, phone numbers, and dates of birth based on the user's role. Implemented row access policies so regional analyst roles can only see data for their assigned region. All of this is enforced at the engine level and is transparent to Power BI.


## Streamlit – Tasty Bytes - Regional Sales Dashboard

This Streamlit dashboard is a Regional Sales Comparison tool for Tasty Bytes that visualizes monthly sales performance across regions (North America, EMEA, APAC). It connects to the star schema dynamic tables built in earlier sections and provides four views: a monthly revenue trend line chart, a stacked bar chart showing revenue composition by region, side-by-side line charts for total orders and average order value, and a summary table with revenue, orders, AOV, and unique customers per region. A sidebar year filter lets users drill into a specific year or view all time. It demonstrates how Snowflake's governance (row access policies from Section 4) flows through to the app — each user only sees the regions their role permits.

---

# Notes

This project is based on a guided Snowflake Quickstart. The implementation follows the provided framework, sample data, and code structure from Snowflake.
