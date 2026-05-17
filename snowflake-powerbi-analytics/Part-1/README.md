## Data Profiling

Designed the foundational data layer and access control framework to serve Tasty Bytes analytics through Power BI, with region-based role segregation.

### What's Covered

1. **Data Profiling** — Reviewed table volumes, sampled records, and identified duplicates using CTEs with `HAVING` clauses
2. **Schema & Warehouse Setup** — Created a dedicated `POWERBI` schema and a medium-sized `tb_powerbi_wh` warehouse optimized for BI query patterns (auto-suspend at 5 min)
3. **User & Role Creation** — Created a `tb_bi_analyst` service user and region-specific roles (`_global`, `_emea`, `_na`, `_apac`) for granular access control
4. **Privilege Management** — Applied database, schema, warehouse, and future grants (tables + Dynamic Tables) to all analyst roles, ensuring new objects are automatically accessible
5. **Network Policy** — Included scaffolding for user-level network policies to restrict Power BI connection IPs

### Access Control Design

```
SYSADMIN
├── tb_bi_analyst_global   (all regions)
├── tb_bi_analyst_emea     (Europe, Middle East, Africa)
├── tb_bi_analyst_na       (North America)
└── tb_bi_analyst_apac     (Asia-Pacific)
```

All roles granted to user `tb_bi_analyst` with future grants ensuring Dynamic Tables in the `POWERBI` schema are automatically accessible.

### Tech Stack

| Component | Purpose |
|-----------|---------|
| Data Profiling (CTEs) | Duplicate detection and data sampling |
| Dynamic Tables | Auto-refreshing analytics layer for Power BI |
| Region-Based RBAC | Row-level security by geography |
| Future Grants | Automatic privilege inheritance for new objects |
| Dedicated BI Warehouse | Isolated compute for Power BI workloads |
| Power BI | External BI semantic model and dashboards |
