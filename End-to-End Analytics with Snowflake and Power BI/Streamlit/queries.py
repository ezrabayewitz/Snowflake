import streamlit as st
import altair as alt

st.title("Tasty Bytes - Regional Sales Comparison (Monthly)")

conn = st.connection("snowflake")
session = conn.session()

st.subheader("Monthly Revenue by Region")
df_monthly = session.sql("""
    SELECT DATE_TRUNC('MONTH', TO_DATE(f.date_id::VARCHAR, 'YYYYMMDD')) AS month,
           dl.location_region AS region,
           SUM(f.order_total) AS total_revenue
    FROM TB_101.POWERBI.DT_FACT_ORDER_AGG f
    JOIN TB_101.POWERBI.DT_DIM_LOCATION dl ON f.location_id = dl.location_id
    GROUP BY month, dl.location_region
    ORDER BY month
""").to_pandas()

chart_trend = alt.Chart(df_monthly).mark_line(point=True).encode(
    x=alt.X("MONTH:T", title="Month"),
    y=alt.Y("TOTAL_REVENUE:Q", title="Revenue ($)"),
    color=alt.Color("REGION:N", title="Region"),
    tooltip=["MONTH:T", "REGION:N", "TOTAL_REVENUE:Q"]
).properties(height=400)
st.altair_chart(chart_trend, use_container_width=True)

st.sidebar.header("Filters")
df_years = session.sql("""
    SELECT DISTINCT YEAR(TO_DATE(date_id::VARCHAR, 'YYYYMMDD')) AS yr
    FROM TB_101.POWERBI.DT_FACT_ORDER_AGG
    ORDER BY yr
""").to_pandas()
years = ["All"] + df_years["YR"].astype(str).tolist()
selected_year = st.sidebar.selectbox("Year", years)

year_filter = f"AND YEAR(TO_DATE(f.date_id::VARCHAR, 'YYYYMMDD')) = {selected_year}" if selected_year != "All" else ""

st.subheader("Monthly Revenue Breakdown (Stacked)")
df_stacked = session.sql(f"""
    SELECT DATE_TRUNC('MONTH', TO_DATE(f.date_id::VARCHAR, 'YYYYMMDD')) AS month,
           dl.location_region AS region,
           SUM(f.order_total) AS total_revenue
    FROM TB_101.POWERBI.DT_FACT_ORDER_AGG f
    JOIN TB_101.POWERBI.DT_DIM_LOCATION dl ON f.location_id = dl.location_id
    WHERE 1=1 {year_filter}
    GROUP BY month, dl.location_region
    ORDER BY month
""").to_pandas()

chart_stacked = alt.Chart(df_stacked).mark_bar().encode(
    x=alt.X("MONTH:T", title="Month"),
    y=alt.Y("TOTAL_REVENUE:Q", title="Revenue ($)", stack="zero"),
    color=alt.Color("REGION:N", title="Region"),
    tooltip=["MONTH:T", "REGION:N", "TOTAL_REVENUE:Q"]
).properties(height=400)
st.altair_chart(chart_stacked, use_container_width=True)

st.subheader("Monthly Orders & Avg Order Value")
df_metrics = session.sql(f"""
    SELECT DATE_TRUNC('MONTH', TO_DATE(f.date_id::VARCHAR, 'YYYYMMDD')) AS month,
           dl.location_region AS region,
           SUM(f.order_count) AS total_orders,
           ROUND(SUM(f.order_total) / SUM(f.order_count), 2) AS avg_order_value
    FROM TB_101.POWERBI.DT_FACT_ORDER_AGG f
    JOIN TB_101.POWERBI.DT_DIM_LOCATION dl ON f.location_id = dl.location_id
    WHERE 1=1 {year_filter}
    GROUP BY month, dl.location_region
    ORDER BY month
""").to_pandas()

col1, col2 = st.columns(2)
with col1:
    st.caption("Total Orders")
    chart_orders = alt.Chart(df_metrics).mark_line().encode(
        x="MONTH:T", y=alt.Y("TOTAL_ORDERS:Q", title="Orders"), color="REGION:N"
    ).properties(height=300)
    st.altair_chart(chart_orders, use_container_width=True)
with col2:
    st.caption("Avg Order Value ($)")
    chart_aov = alt.Chart(df_metrics).mark_line().encode(
        x="MONTH:T", y=alt.Y("AVG_ORDER_VALUE:Q", title="Avg Order Value ($)"), color="REGION:N"
    ).properties(height=300)
    st.altair_chart(chart_aov, use_container_width=True)

st.subheader("Region Summary")
df_summary = session.sql(f"""
    SELECT dl.location_region AS region,
           SUM(f.order_total) AS total_revenue,
           SUM(f.order_count) AS total_orders,
           ROUND(SUM(f.order_total) / SUM(f.order_count), 2) AS avg_order_value,
           COUNT(DISTINCT f.customer_id) AS unique_customers
    FROM TB_101.POWERBI.DT_FACT_ORDER_AGG f
    JOIN TB_101.POWERBI.DT_DIM_LOCATION dl ON f.location_id = dl.location_id
    WHERE 1=1 {year_filter}
    GROUP BY dl.location_region
    ORDER BY total_revenue DESC
""").to_pandas()
st.dataframe(df_summary, use_container_width=True)
