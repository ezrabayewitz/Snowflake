## Apps & Collaboration

Leveraged Snowflake Marketplace data shares and Streamlit to enrich Tasty Bytes analytics with third-party weather and geospatial data — uncovering how external factors like wind and precipitation impact food truck sales.

### What's Covered

1. **Snowflake Marketplace** — Acquired live, ready-to-query datasets (Weather Source, Safegraph POI) directly into the account with zero data duplication or ETL pipelines
2. **Weather Integration** — Built a `daily_weather_v` view joining Weather Source historical data with Tasty Bytes location data, then created a `daily_sales_by_weather_v` analytics view correlating sales with temperature, precipitation, and snowfall
3. **Safegraph POI Analysis** — Joined Point-of-Interest data with weather metrics to identify the windiest truck locations and quantify weather impact on sales by brand
4. **CTEs & Conditional Aggregation** — Used Common Table Expressions and CASE-based bucketing to compare "calm day" vs. "windy day" sales performance per brand, revealing weather-resilient vs. weather-vulnerable operations
5. **Streamlit in Snowflake** — Built interactive data applications directly within Snowflake for visual exploration

### Key Insights

- Identified top 3 windiest US truck locations using weather + POI data
- Compared brand sales on calm days (≤20 mph) vs. windy days (>20 mph) to reveal weather resilience
- Discovered precipitation's impact on Seattle market sales by menu item

### Tech Stack

| Component | Purpose |
|-----------|---------|
| Snowflake Marketplace | Third-party data acquisition (zero-copy sharing) |
| Weather Source | Historical daily weather metrics by location |
| Safegraph POI | Point-of-interest and geospatial context |
| Views & CTEs | Data harmonization and modular query design |
| Streamlit in Snowflake | Interactive data applications |
| Snowsight Charts | Visual analytics (line, bar) |
