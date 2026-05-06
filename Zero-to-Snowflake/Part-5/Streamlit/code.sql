st.title("Menu Item Sales in Japan for February 2022")
  
@st.cache_data()
def load_data():
    japan_sales_df = session.table(
        "tb_101.analytics.japan_menu_item_sales_feb_2022"
    ).to_pandas()
    return japan_sales_df

japan_sales = load_data()

menu_item_names = japan_sales['MENU_ITEM_NAME'].unique().tolist()

menu_item_sales = japan_sales[
    japan_sales['MENU_ITEM_NAME'] == selected_menu_item
]

daily_totals = (
    menu_item_sales
    .groupby('DATE')['ORDER_TOTAL']
    .sum()
    .reset_index()
)

min_value = daily_totals['ORDER_TOTAL'].min()
max_value = daily_totals['ORDER_TOTAL'].max()

chart_margin = (max_value - min_value) / 2
y_margin_min = min_value - chart_margin
y_margin_max = max_value + chart_margin
