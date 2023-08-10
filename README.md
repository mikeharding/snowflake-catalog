# Snowflake Native Data Catalog Dashboard

A Snowflake Snowsight Dashboard that displays Tables and Views, Object Lineage, and Data Lineage that can be filtered.  The Dashboard is text based.

The sample code assumes you are creating the Dashboard using the ACCOUNTADMIN role.  You should create the Dashboard using a custom role and grant the required privileges to access the source data, namely `snowflake.account_usage` views.

![Catalog](./images/catalog.png)

The dashboard is created using a combination of data from `snowflake.account_usage` views and locally copied data from the views to enhance performance.

The filters are based on snowflake.account_usage.tables.  You can refresh the filter values daily or hourly.

To build the dashboard, follow these steps:

1. Create the local tables based on snowflake.account_usage views.
2. Created the Dashboard Filters
3. Create the Dashboard Tiles

## 1 - Create Local Tables

Using local snapshots from `snowflake.account_usage` views can speed up the Dashboard and allow using a smaller size Warehouse but you will need to schedule a refresh of the snapshots.

Run [local_tables.sql](./local_tables.sql)

## 2 - Create the Dashboard Filters

List of filters in order, as configured on the Dashboard

- :tablename
- :database
- :schema
- :tabletype
- :deleted

![filters](./images/filters.png)

&nbsp;

&nbsp;

---
#### :tablename
<img src='images/table_name.png' width='750px'>

__Query:__
```
SELECT DISTINCT table_name
FROM snowflake.account_usage.tables
ORDER BY 1;
```
&nbsp;

&nbsp;

---
#### :database
<img src='images/database.png' width='750px'>

__Query:__
```
SELECT DISTINCT table_catalog
FROM snowflake.account_usage.tables
ORDER BY 1 asc;
```
&nbsp;

&nbsp;

---
#### :schema
<img src='images/schema.png' width='750px'>

__Query:__
```
SELECT DISTINCT table_schema
FROM snowflake.account_usage.tables
ORDER BY 1 asc;
```
&nbsp;

&nbsp;

---
#### :tabletype
<img src='images/table_type.png' width='750px'>

__Query:__
```
SELECT DISTINCT table_type
FROM snowflake.account_usage.tables
ORDER BY 1 asc;
```
&nbsp;

&nbsp;

---
#### :deleted
<img src='images/deleted_flag.png' width='750px'>

__Query:__
```
SELECT DISTINCT CASE WHEN deleted IS NOT NULL THEN 'Exists' ELSE 'Deleted' END AS IsDeleted
FROM snowflake.account_usage.tables;
```
&nbsp;

&nbsp;

---

## 3 - Create Dashboard Tiles

### Tile 1

__Name:__ Tables

__Query:__
```
select  table_name as "Table Name"
       ,table_catalog as "Database"
       ,table_schema as "Schema"
       ,table_type as "Table Type"
       ,clustering_key as "Clustering Key"
       ,row_count as "Row Count"
       ,bytes/1024/1024 as "Megabytes"
       ,retention_time as "Retention Time"
       ,created as "Created On"
       ,last_altered as "Last Modified"
       ,auto_clustering_on as "Auto Clustering On"
       ,comment as "Comment"
       ,case when deleted is null then 'Exists' else 'Deleted' end as "Is Deleted"
       ,deleted as "Deleted Date"
from catalog.account_usage.tables
where true
  and "Table Name" = :tablename
  and "Database" = :database
  and "Schema" = :schema
  AND "Table Type" = :tabletype
  and "Is Deleted" = :deleted
order by 1 asc;
```
