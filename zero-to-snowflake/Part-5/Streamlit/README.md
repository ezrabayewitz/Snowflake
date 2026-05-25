## Streamlit in Snowflake

Built an interactive Streamlit application directly within Snowflake to visualize daily menu item sales performance in Japan for February 2022.

### App Features

- **Dynamic Menu Item Selector** — Dropdown widget lets users explore sales trends for any menu item
- **Daily Sales Line Chart** — Altair-powered visualization with dynamic y-axis scaling and hover tooltips
- **Snowpark Integration** — Queries data directly from Snowflake using `get_active_session()` with no external connections
- **Performance Caching** — Uses `@st.cache_data` to avoid redundant data fetches on user interaction

### Architecture

```
Snowflake Table (analytics.japan_menu_item_sales_feb_2022)
    ↓ Snowpark Session
Pandas DataFrame (cached)
    ↓ User Selection (selectbox)
Filtered & Grouped Data
    ↓ Altair
Interactive Line Chart
```

### Tech Stack

| Component | Purpose |
|-----------|---------|
| Streamlit in Snowflake | Interactive web app hosted natively in Snowflake |
| Snowpark Python | Secure data access via active session |
| Pandas | Data filtering and aggregation |
| Altair | Declarative interactive charting |
| st.cache_data | Performance optimization for repeated queries |
