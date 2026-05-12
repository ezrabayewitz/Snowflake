# Retail Sales Pipeline — End-to-End Snowflake Data Engineering Project

A fully functional data engineering pipeline built on Snowflake, using the Olist Brazilian E-Commerce public dataset. This project demonstrates professional data ingestion, transformation, and reporting patterns used in real-world consulting engagements.

---

## Project Overview

This pipeline ingests raw e-commerce data from CSV files, transforms it into a structured analytics layer using Snowpark Python, and exposes clean business-facing views for reporting. It follows a three-layer medallion architecture: Raw → Analytics → Reporting.

**Dataset**: [Olist Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (~100,000 orders, 5 tables)

**Platform**: Snowflake (X-Small warehouse, free trial)

**Estimated credit cost**: < $5

---

## Architecture

```
CSV Files (Kaggle)
      │
      │  COPY INTO (staged ingestion)
      ▼
┌─────────────────────────────┐
│        RAW SCHEMA           │
│  orders_raw                 │
│  customers_raw              │
│  order_items_raw            │
│  products_raw               │
│  order_payments_raw         │
└─────────────────────────────┘
      │
      │  Snowpark Python (DataFrame API)
      ▼
┌─────────────────────────────┐
│      ANALYTICS SCHEMA       │
│  fct_orders                 │
│  dim_customers              │
│  dim_products               │
└─────────────────────────────┘
      │
      │  SQL views
      ▼
┌─────────────────────────────┐
│      REPORTING SCHEMA       │
│  vw_revenue_by_state        │
│  vw_customer_ltv            │
│  vw_top_categories          │
│  vw_delivery_performance    │
└─────────────────────────────┘
```

---

## Repository Structure

```
retail-sales-pipeline/
│
├── Part 1 - Setup.sql                  # Database, schema, and warehouse setup
├── Part 2 - Staging.sql                # Internal stage and file format creation
├── Part 3 - Loading Raw Data.sql       # Table definitions and COPY INTO commands
├── Part 4 - Snowpark Transformations.py    # Snowpark Python transformation logic
├── Part 5 - Reporting Views.sql        # Business-facing SQL views
│
└── docs/
    ├── 01_setup_README.md
    ├── 02_staging_README.md
    ├── 03_load_raw_README.md
    ├── 04_snowpark_transforms_README.md
    └── 05_reporting_views_README.md
```

---

## Key Concepts Demonstrated

| Concept | Where Used |
|---|---|
| Medallion architecture (Raw → Analytics → Reporting) | Full pipeline |
| Internal stages and named file formats | Step 2 |
| COPY INTO with error handling | Step 3 |
| Snowpark Python DataFrame API | Step 4 |
| Fact and dimension table modeling | Step 4 |
| SQL window functions and aggregations | Step 5 |
| Cost-conscious warehouse configuration | Step 1 |

---

## Business Questions Answered

The four reporting views answer real questions a business stakeholder would ask:

1. **Which states generate the most revenue?** → `vw_revenue_by_state`
2. **Who are our highest-value customers?** → `vw_customer_ltv`
3. **Which product categories perform best?** → `vw_top_categories`
4. **How has delivery performance trended over time?** → `vw_delivery_performance`

---

## Row Counts (after full pipeline run)

| Table | Rows |
|---|---|
| orders_raw | 99,441 |
| customers_raw | 99,441 |
| order_items_raw | 112,650 |
| products_raw | 32,951 |
| order_payments_raw | 103,886 |
| fct_orders | 99,441 |
| dim_customers | 99,441 |
| dim_products | 32,951 |

---
