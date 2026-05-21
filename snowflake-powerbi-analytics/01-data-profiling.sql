/*-------------------------------------------------
SECTION 2 - REVIEWING THE DATASET
-------------------------------------------------*/

/* Set database, schema, role, and warehouse context */
use role sysadmin;
use database tb_101;
use schema raw_pos;
use warehouse tb_dev_wh;


/*-------------------------------------------------
BASIC DATA PROFILING
-------------------------------------------------*/

/* Review tables in schema */
show tables in schema tb_101.raw_pos;

/* Sample the data */
select *
from order_header
where customer_id is not null
limit 1000;

/* Identify duplicate franchise_id records */
with dupes as (
    select franchise_id, count(*) as record_count
    from tb_101.raw_pos.franchise
    group by franchise_id
    having count(*) > 1
)
select *
from tb_101.raw_pos.franchise f
where exists (
    select 1
    from dupes d
    where d.franchise_id = f.franchise_id
);


/*-------------------------------------------------
CREATE POWERBI SCHEMA AND WAREHOUSE
-------------------------------------------------*/

/* Create Power BI schema */
use role sysadmin;

create or replace schema tb_101.powerbi;

use schema tb_101.powerbi;

/* Create Power BI warehouse */
create or replace warehouse tb_powerbi_wh
warehouse_size = 'MEDIUM'
max_cluster_count = 1
min_cluster_count = 1
auto_suspend = 300
initially_suspended = true
comment = 'Warehouse used for the TB Power BI DQ semantic model';

/* Switch back to dev warehouse */
use warehouse tb_dev_wh;


/*-------------------------------------------------
CREATE USER, ROLES, AND GRANTS
-------------------------------------------------*/

/* Create BI analyst user */
use role useradmin;

create or replace user tb_bi_analyst
  password = '<your_password>'
  default_role = 'tb_bi_analyst_global';


/* Create roles */
use role securityadmin;

create or replace role tb_bi_analyst_global;
create or replace role tb_bi_analyst_emea;
create or replace role tb_bi_analyst_na;
create or replace role tb_bi_analyst_apac;

/* Grant roles to user */
grant role tb_bi_analyst_global to user tb_bi_analyst;
grant role tb_bi_analyst_emea to user tb_bi_analyst;
grant role tb_bi_analyst_na to user tb_bi_analyst;
grant role tb_bi_analyst_apac to user tb_bi_analyst;

/* Assign roles to sysadmin */
grant role tb_bi_analyst_global to role sysadmin;
grant role tb_bi_analyst_emea to role sysadmin;
grant role tb_bi_analyst_na to role sysadmin;
grant role tb_bi_analyst_apac to role sysadmin;


/*-------------------------------------------------
GRANT DATABASE & SCHEMA PERMISSIONS
-------------------------------------------------*/

/* Database usage */
grant usage on database tb_101 to role tb_bi_analyst_global;
grant usage on database tb_101 to role tb_bi_analyst_emea;
grant usage on database tb_101 to role tb_bi_analyst_na;
grant usage on database tb_101 to role tb_bi_analyst_apac;

/* Schema permissions */
grant all on schema tb_101.powerbi to role tb_data_engineer;
grant all on schema tb_101.powerbi to role tb_bi_analyst_global;
grant all on schema tb_101.powerbi to role tb_bi_analyst_emea;
grant all on schema tb_101.powerbi to role tb_bi_analyst_na;
grant all on schema tb_101.powerbi to role tb_bi_analyst_apac;


/*-------------------------------------------------
FUTURE GRANTS (TABLES & DYNAMIC TABLES)
-------------------------------------------------*/

/* Future tables */
grant all on future tables in schema tb_101.powerbi to role tb_data_engineer;
grant all on future tables in schema tb_101.powerbi to role tb_bi_analyst_global;
grant all on future tables in schema tb_101.powerbi to role tb_bi_analyst_emea;
grant all on future tables in schema tb_101.powerbi to role tb_bi_analyst_na;
grant all on future tables in schema tb_101.powerbi to role tb_bi_analyst_apac;

/* Future dynamic tables */
grant all on future dynamic tables in schema tb_101.powerbi to role tb_data_engineer;
grant all on future dynamic tables in schema tb_101.powerbi to role tb_bi_analyst_global;
grant all on future dynamic tables in schema tb_101.powerbi to role tb_bi_analyst_emea;
grant all on future dynamic tables in schema tb_101.powerbi to role tb_bi_analyst_na;
grant all on future dynamic tables in schema tb_101.powerbi to role tb_bi_analyst_apac;


/*-------------------------------------------------
WAREHOUSE ACCESS
-------------------------------------------------*/

/* Power BI warehouse access */
grant usage on warehouse tb_powerbi_wh to role tb_bi_analyst_global;
grant usage on warehouse tb_powerbi_wh to role tb_bi_analyst_emea;
grant usage on warehouse tb_powerbi_wh to role tb_bi_analyst_na;
grant usage on warehouse tb_powerbi_wh to role tb_bi_analyst_apac;

/* Dev warehouse access */
grant usage on warehouse tb_dev_wh to role tb_bi_analyst_global;
grant usage on warehouse tb_dev_wh to role tb_bi_analyst_emea;
grant usage on warehouse tb_dev_wh to role tb_bi_analyst_na;
grant usage on warehouse tb_dev_wh to role tb_bi_analyst_apac;
