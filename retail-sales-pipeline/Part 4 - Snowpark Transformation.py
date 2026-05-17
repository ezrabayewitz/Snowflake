from snowflake.snowpark import Session
import snowflake.snowpark.functions as F
from snowflake.snowpark.functions import col, to_date, datediff, avg, sum as sum_, count, round as round_

def main(session: Session):

    session.use_database("RETAIL_PIPELINE")
    session.use_warehouse("RETAIL_WH")

    # -------------------------------------------------------
    # FACT TABLE: fct_orders
    # -------------------------------------------------------

    orders   = session.table("RAW.ORDERS_RAW")
    payments = session.table("RAW.ORDER_PAYMENTS_RAW")
    items    = session.table("RAW.ORDER_ITEMS_RAW")

    payments_agg = payments.group_by("ORDER_ID").agg(
        sum_("PAYMENT_VALUE").alias("TOTAL_PAYMENT"),
        count("PAYMENT_SEQUENTIAL").alias("NUM_PAYMENTS")
    )

    items_agg = items.group_by("ORDER_ID").agg(
        sum_("PRICE").alias("TOTAL_ITEM_VALUE"),
        sum_("FREIGHT_VALUE").alias("TOTAL_FREIGHT"),
        count("ORDER_ITEM_ID").alias("NUM_ITEMS")
    )

    fct_orders = (
        orders
        .join(payments_agg, on="ORDER_ID", how="left")
        .join(items_agg,    on="ORDER_ID", how="left")
        .select(
            col("ORDER_ID"),
            col("CUSTOMER_ID"),
            col("ORDER_STATUS"),
            to_date(col("ORDER_PURCHASE_TIMESTAMP")).alias("ORDER_DATE"),
            to_date(col("ORDER_DELIVERED_CUSTOMER_DATE")).alias("DELIVERED_DATE"),
            to_date(col("ORDER_ESTIMATED_DELIVERY_DATE")).alias("ESTIMATED_DELIVERY_DATE"),
            datediff("day",
                col("ORDER_PURCHASE_TIMESTAMP"),
                col("ORDER_DELIVERED_CUSTOMER_DATE")
            ).alias("DAYS_TO_DELIVER"),
            col("TOTAL_PAYMENT"),
            col("NUM_PAYMENTS"),
            col("TOTAL_ITEM_VALUE"),
            col("TOTAL_FREIGHT"),
            col("NUM_ITEMS")
        )
    )

    fct_orders.write.mode("overwrite").save_as_table("ANALYTICS.FCT_ORDERS")
    print(f"fct_orders rows: {fct_orders.count()}")

    # -------------------------------------------------------
    # DIMENSION TABLE: dim_customers
    # -------------------------------------------------------

    customers = session.table("RAW.CUSTOMERS_RAW")

    dim_customers = customers.select(
        col("CUSTOMER_ID"),
        col("CUSTOMER_UNIQUE_ID"),
        col("CUSTOMER_CITY"),
        col("CUSTOMER_STATE"),
        col("CUSTOMER_ZIP_CODE_PREFIX").alias("ZIP_CODE")
    ).distinct()

    dim_customers.write.mode("overwrite").save_as_table("ANALYTICS.DIM_CUSTOMERS")
    print(f"dim_customers rows: {dim_customers.count()}")

    # -------------------------------------------------------
    # DIMENSION TABLE: dim_products
    # -------------------------------------------------------

    products = session.table("RAW.PRODUCTS_RAW")

    dim_products = products.select(
        col("PRODUCT_ID"),
        col("PRODUCT_CATEGORY_NAME").alias("CATEGORY"),
        col("PRODUCT_WEIGHT_G").alias("WEIGHT_G"),
        col("PRODUCT_PHOTOS_QTY").alias("NUM_PHOTOS")
    ).filter(col("PRODUCT_ID").is_not_null())

    dim_products.write.mode("overwrite").save_as_table("ANALYTICS.DIM_PRODUCTS")
    print(f"dim_products rows: {dim_products.count()}")

    return "✓ All analytics tables written successfully"
