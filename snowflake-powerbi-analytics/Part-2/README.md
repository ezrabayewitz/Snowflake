## Marketplace Data

Acquired and integrated SafeGraph geospatial data from the Snowflake Marketplace to enrich Tasty Bytes truck locations with point-of-interest metadata.

### What's Covered

1. **Data Sampling** — Explored the shared `frostbyte_tb_safegraph_s` dataset and profiled location counts by country
2. **Cross-Database Join** — Joined internal `raw_pos.location` with the Safegraph Marketplace dataset on `placekey` to enrich each location with coordinates, street address, postal code, and business category/subcategory
3. **Data Materialization** — Created a local copy (`raw_pos.safegraph_frostbyte_location`) of the shared data so it can be referenced in downstream Dynamic Table definitions

### Tech Stack

| Component | Purpose |
|-----------|---------|
| Snowflake Marketplace | Zero-copy third-party data acquisition |
| SafeGraph POI Data | Geospatial & category enrichment per location |
| Cross-Database Joins | Enrich internal data with external datasets |
| CTAS | Materialize shared data for Dynamic Table compatibility |
