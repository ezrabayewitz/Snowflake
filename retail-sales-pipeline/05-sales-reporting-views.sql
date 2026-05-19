-- Create sales reporting views tables

USE DATABASE RETAIL_PIPELINE;
USE SCHEMA REPORTING;
USE WAREHOUSE RETAIL_WH;


-- -------------------------------------------------------
-- VIEW 1: Revenue by state
-- -------------------------------------------------------
CREATE OR REPLACE VIEW vw_revenue_by_state AS
SELECT
    c.CUSTOMER_STATE,
    COUNT(DISTINCT o.ORDER_ID)        AS total_orders,
    ROUND(SUM(o.TOTAL_PAYMENT), 2)    AS total_revenue,
    ROUND(AVG(o.TOTAL_PAYMENT), 2)    AS avg_order_value
FROM ANALYTICS.FCT_ORDERS o
JOIN ANALYTICS.DIM_CUSTOMERS c ON o.CUSTOMER_ID = c.CUSTOMER_ID
WHERE o.ORDER_STATUS = 'delivered'
GROUP BY c.CUSTOMER_STATE
ORDER BY total_revenue DESC;


-- -------------------------------------------------------
-- VIEW 2: Customer lifetime value
-- -------------------------------------------------------
CREATE OR REPLACE VIEW vw_customer_ltv AS
SELECT
    c.CUSTOMER_UNIQUE_ID,
    c.CUSTOMER_STATE,
    COUNT(DISTINCT o.ORDER_ID)        AS total_orders,
    ROUND(SUM(o.TOTAL_PAYMENT), 2)    AS lifetime_value,
    ROUND(AVG(o.TOTAL_PAYMENT), 2)    AS avg_order_value,
    MIN(o.ORDER_DATE)                 AS first_order_date,
    MAX(o.ORDER_DATE)                 AS last_order_date
FROM ANALYTICS.FCT_ORDERS o
JOIN ANALYTICS.DIM_CUSTOMERS c ON o.CUSTOMER_ID = c.CUSTOMER_ID
WHERE o.ORDER_STATUS = 'delivered'
GROUP BY c.CUSTOMER_UNIQUE_ID, c.CUSTOMER_STATE
ORDER BY lifetime_value DESC;


-- -------------------------------------------------------
-- VIEW 3: Top performing product categories
-- -------------------------------------------------------
CREATE OR REPLACE VIEW vw_top_categories AS
SELECT
    p.CATEGORY,
    COUNT(DISTINCT o.ORDER_ID)        AS total_orders,
    ROUND(SUM(o.TOTAL_ITEM_VALUE), 2) AS total_revenue,
    ROUND(AVG(o.TOTAL_ITEM_VALUE), 2) AS avg_order_value,
    ROUND(AVG(o.DAYS_TO_DELIVER), 1)  AS avg_days_to_deliver
FROM ANALYTICS.FCT_ORDERS o
JOIN ANALYTICS.DIM_PRODUCTS p ON o.ORDER_ID IN (
    SELECT ORDER_ID FROM RAW.ORDER_ITEMS_RAW WHERE PRODUCT_ID = p.PRODUCT_ID
)
WHERE o.ORDER_STATUS = 'delivered'
AND p.CATEGORY IS NOT NULL
GROUP BY p.CATEGORY
ORDER BY total_revenue DESC;


-- -------------------------------------------------------
-- VIEW 4: Delivery performance over time
-- -------------------------------------------------------
CREATE OR REPLACE VIEW vw_delivery_performance AS
SELECT
    DATE_TRUNC('month', ORDER_DATE)   AS order_month,
    COUNT(DISTINCT ORDER_ID)          AS total_orders,
    ROUND(AVG(DAYS_TO_DELIVER), 1)    AS avg_days_to_deliver,
    SUM(CASE WHEN DELIVERED_DATE <= ESTIMATED_DELIVERY_DATE
        THEN 1 ELSE 0 END)            AS on_time_deliveries,
    ROUND(
        SUM(CASE WHEN DELIVERED_DATE <= ESTIMATED_DELIVERY_DATE
            THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT ORDER_ID), 1
    )                                 AS on_time_pct
FROM ANALYTICS.FCT_ORDERS
WHERE ORDER_STATUS = 'delivered'
AND ORDER_DATE IS NOT NULL
GROUP BY DATE_TRUNC('month', ORDER_DATE)
ORDER BY order_month;


SELECT * FROM vw_revenue_by_state      LIMIT 5;
SELECT * FROM vw_customer_ltv          LIMIT 5;
SELECT * FROM vw_top_categories        LIMIT 5;
SELECT * FROM vw_delivery_performance  LIMIT 5;
