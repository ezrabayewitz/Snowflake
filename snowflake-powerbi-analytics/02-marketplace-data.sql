/*-------------------------------------------------
SECTION 3 - THIRD PARTY DATA FROM SNOWFLAKE MARKETPLACE
-------------------------------------------------*/

/* NOTE:
   Dependent on getting the SafeGraph: frostbyte listing from Snowflake Marketplace
*/


/*-------------------------------------------------
SET WORKSHEET CONTEXT
-------------------------------------------------*/

use role tb_dev;
use schema zts_safegraph.public;
use warehouse tb_dev_wh;


/*-------------------------------------------------
BASIC DATA EXPLORATION
-------------------------------------------------*/

/* Sample the dataset */
select *
from frostbyte_tb_safegraph_s;

/* View location counts by country */
select 
    country,
    count(*) as location_count
from frostbyte_tb_safegraph_s
group by country;


/*-------------------------------------------------
JOIN WITH INTERNAL DATA (CROSS-DATABASE JOIN)
-------------------------------------------------*/

/* Enrich internal location data with SafeGraph attributes */
select
    l.location_id,
    l.location,
    l.city as location_city,
    l.country as location_country,
    l.iso_country_code as location_country_iso,
    sg.top_category as location_category,
    sg.sub_category as location_subcategory,
    sg.latitude as location_latitude,
    sg.longitude as location_longitude,
    sg.street_address as location_street_address,
    sg.postal_code as location_postal_code
from tb_101.raw_pos.location l
left join zts_safegraph.public.frostbyte_tb_safegraph_s sg
    on sg.placekey = l.placekey;


/*-------------------------------------------------
CREATE LOCAL COPY FOR DOWNSTREAM USE
-------------------------------------------------*/

/* Copy marketplace data into raw_pos schema for use in Dynamic Tables */
create or replace table tb_101.raw_pos.safegraph_frostbyte_location as
select *
from zts_safegraph.public.frostbyte_tb_safegraph_s;
