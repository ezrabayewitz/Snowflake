# ❄️ Part 1 – Zero to Snowflake (Getting Started)

## Overview
This section follows the Snowflake “Getting Started” quickstart and focuses on foundational concepts such as virtual warehouses, query execution, data transformation, and basic platform features.

This is a hands-on implementation of Snowflake’s introductory lab, with added structure and documentation to reinforce learning.

---

## 🎯 Learning Objectives

- Understand virtual warehouse architecture and scaling
- Run and analyze SQL queries in Snowflake
- Work with query result caching (persisted results)
- Perform basic data transformations using SQL
- Learn zero-copy cloning and Time Travel recovery
- Understand cost and resource monitoring concepts

---

## 🧭 Workflow Summary

1. Configure and manage virtual warehouse (`my_wh`)
2. Run exploratory SQL queries
3. Observe query result caching behavior
4. Transform semi-structured data (VARIANT type)
5. Use zero-copy cloning for safe development
6. Perform data cleaning and table swaps
7. Recover dropped objects using UNDROP
8. Set up resource monitors and budgets
9. Explore Snowflake universal search

---

## 🧠 Key Concepts Learned

### Virtual Warehouses
Compute in Snowflake is decoupled from storage. Warehouses can be scaled up/down without affecting data.

### Query Result Cache
Repeated queries execute faster due to cached results stored in the cloud services layer.

### Zero-Copy Cloning
Tables can be cloned instantly without duplicating storage, enabling safe development workflows.

### Time Travel (UNDROP)
Dropped tables can be restored within a retention window using UNDROP.

### Resource Management
Warehouses can be controlled using:
- Resource Monitors (credit-based limits)
- Budgets (cost tracking across resources)

---

## 🛠️ Files in This Part
