/*-------------------------------------------------
SECTION 4 - STAR SCHEMA & DYNAMIC TABLES
-------------------------------------------------*/

/*-------------------------------------------------
SET CONTEXT
-------------------------------------------------*/
use role sysadmin;
use database tb_101;
use schema powerbi;
use warehouse tb_dev_wh;


/*-------------------------------------------------
SCALE WAREHOUSE FOR INITIAL LOAD
-------------------------------------------------*/
alter warehouse tb_de_wh set warehouse_size = '2x-large';


/*-------------------------------------------------
STATIC DIMENSIONS
-------------------------------------------------*/

/*-------------------------
DIM_DATE
-------------------------*/
set min_date = to_date('2018-01-01');
set max_date = to_date('2024-12-31');
set days = (select $max_date - $min_date);

create or replace table dim_date as
with dates as (
    select dateadd(day, seq4(), $min_date) as d
    from table(generator(rowcount => $days))
)
select 
    to_number(replace(to_varchar(d), '-', '')) as date_id,
    d as date,
    year(d) as year,
    month(d) as month,
    monthname(d) as month_name,
    day(d) as day_of_month,
    dayofweek(d) as day_of_week,
    dayname(d) as weekday,
    weekofyear(d) as week_of_year,
    dayofyear(d) as day_of_year,
    case when dayofweek(d) in (0,6) then 1 else 0 end as weekend_flag
from dates;


/*-------------------------
DIM_TIME
-------------------------*/
set min_time = to_time('00:00:00');
set seconds = 86400;

create or replace table dim_time as
with times as (
    select timeadd(second, seq4(), $min_time) as t
    from table(generator(rowcount => $seconds))
)
select
    to_number(left(to_varchar(t),2) || substr(to_varchar(t),4,2) || right(to_varchar(t),2)) as time_id,
    t as time,
    hour(t) as hour,
    minute(t) as minute,
    second(t) as second,
    case when hour(t) < 12 then 'AM' else 'PM' end as am_pm
from times;


/*-------------------------------------------------
DYNAMIC DIMENSIONS
-------------------------------------------------*/

/*-------------------------
DIM_TRUCK
-------------------------*/
create or replace dynamic table dt_dim_truck
target_lag = 'DOWNSTREAM'
warehouse = tb_de_wh
refresh_mode = incremental
as
select distinct
    t.truck_id,
    t.franchise_id,
    m.truck_brand_name,
    t.primary_city as city,
    t.region,
    t.country,
    year as truck_year,
    (2023 - year) as truck_age,
    replace(t.make, 'Ford_', 'Ford') as make,
    t.model,
    t.ev_flag
from tb_101.raw_pos.truck t
join tb_101.raw_pos.menu m 
    on m.menu_type_id = t.menu_type_id;


/*-------------------------
DIM_FRANCHISE
-------------------------*/
create or replace dynamic table dt_dim_franchise
target_lag = 'DOWNSTREAM'
warehouse = tb_de_wh
refresh_mode = incremental
as
with dedup as (
    select *,
        row_number() over (partition by franchise_id order by city) as rn
    from tb_101.raw_pos.franchise
)
select *
from dedup
where rn = 1;


/*-------------------------
DIM_MENU_ITEM
-------------------------*/
create or replace dynamic table dt_dim_menu_item
target_lag = 'DOWNSTREAM'
warehouse = tb_de_wh
refresh_mode = incremental
as
select 
    menu_item_id,
    menu_type,
    item_category,
    item_subcategory,
    menu_item_name,
    cost_of_goods_usd,
    sale_price_usd
from tb_101.raw_pos.menu;


/*-------------------------
DIM_LOCATION
-------------------------*/
create or replace dynamic table dt_dim_location
target_lag = 'DOWNSTREAM'
warehouse = tb_de_wh
refresh_mode = incremental
as
select
    location_id,
    location,
    city,
    case
        when country in ('United States','Canada','Mexico') then 'North America'
        when country in ('England','France','Germany') then 'EMEA'
        else 'Other'
    end as region,
    country
from tb_101.raw_pos.location;


/*-------------------------
DIM_CUSTOMER
-------------------------*/
create or replace dynamic table dt_dim_customer
target_lag = 'DOWNSTREAM'
warehouse = tb_de_wh
refresh_mode = full
as
select
    customer_id,
    first_name,
    last_name,
    first_name || ' ' || last_name as full_name,
    city,
    country
from tb_101.raw_customer.customer_loyalty;


/*-------------------------------------------------
FACT TABLES
-------------------------------------------------*/

/*-------------------------
FACT_ORDER_DETAIL
-------------------------*/
create or replace dynamic table dt_fact_order_detail
target_lag = 'DOWNSTREAM'
warehouse = tb_de_wh
refresh_mode = full
as
select
    od.order_id,
    od.order_detail_id,
    oh.truck_id,
    t.franchise_id,
    oh.location_id,
    od.menu_item_id,
    to_date(oh.order_ts) as date_id,
    to_time(oh.order_ts) as time_id,
    oh.customer_id,
    od.quantity,
    od.unit_price,
    od.price as line_total
from tb_101.raw_pos.order_detail od
join tb_101.raw_pos.order_header oh 
    on oh.order_id = od.order_id
join tb_101.raw_pos.truck t 
    on t.truck_id = oh.truck_id;


/*-------------------------
FACT_ORDER_HEADER
-------------------------*/
create or replace dynamic table dt_fact_order_header
target_lag = 'DOWNSTREAM'
warehouse = tb_de_wh
refresh_mode = full
as
select
    order_id,
    truck_id,
    franchise_id,
    location_id,
    customer_id,
    date_id,
    time_id,
    count(order_detail_id) as line_count,
    sum(quantity) as total_qty,
    sum(line_total) as order_total
from dt_fact_order_detail
group by
    order_id,
    truck_id,
    franchise_id,
    location_id,
    customer_id,
    date_id,
    time_id;


/*-------------------------
FACT_ORDER_AGG
-------------------------*/
create or replace dynamic table dt_fact_order_agg
target_lag = '1 hour'
warehouse = tb_de_wh
refresh_mode = full
as
select
    truck_id,
    franchise_id,
    location_id,
    customer_id,
    date_id,
    count(order_id) as orders,
    sum(line_count) as lines,
    sum(total_qty) as quantity,
    sum(order_total) as revenue
from dt_fact_order_header
group by
    truck_id,
    franchise_id,
    location_id,
    customer_id,
    date_id;


/*-------------------------------------------------
RESET WAREHOUSE
-------------------------------------------------*/
alter warehouse tb_de_wh set warehouse_size = 'medium';
alter warehouse tb_de_wh suspend;
