USE ROLE accountadmin;

CREATE DATABASE catalog;
CREATE SCHEMA account_usage;

CREATE OR REPLACE TABLE catalog.account_usage.object_dependencies AS (
  SELECT * 
  FROM snowflake.account_usage.object_dependencies
);

 

CREATE OR REPLACE TABLE catalog.public.full_history AS (
// 1

SELECT
  direct_source_columns.value: "objectId" AS source_object_id,
  direct_source_columns.value: "objectName" AS source_object_name,
  direct_source_columns.value: "columnName" AS source_column_name,
  'DIRECT' AS source_column_type,
  query_text,
  query_type,
  om.value: "objectName" AS target_object_name,
  columns_modified.value: "columnName" AS target_column_name,
  t.queryid AS query_id,
  t.starttime AS start_time
FROM
  (
    SELECT
      qh.query_id AS queryid, qh.start_time as starttime, *
    FROM
      snowflake.account_usage.access_history ah
    JOIN
      snowflake.account_usage.query_history qh
      ON ah.query_id = qh.query_id
  ) t,
  LATERAL FLATTEN(INPUT => t.OBJECTS_MODIFIED) om,
  LATERAL FLATTEN(INPUT => om.value: "columns", outer => true) columns_modified,
  LATERAL FLATTEN(
    INPUT => columns_modified.value: "directSourceColumns",
    outer => true
  ) direct_source_columns
WHERE t.query_start_time::date >= current_date() - 1 -- set how far back you want to capture lineage
--AND split_part(om.value:"objectName"::string, '.', 1) = 'CITIBIKE' -- filter to a single database if needed


UNION

// 2

SELECT
  base_source_columns.value: "objectId" AS source_object_id,
  base_source_columns.value: "objectName" AS source_object_name,
  base_source_columns.value: "columnName" AS source_column_name,
  'BASE' AS source_column_type,
  query_text,
  query_type,
  om.value: "objectName" AS target_object_name,
  columns_modified.value: "columnName" AS target_column_name,
  t.queryid AS query_id,
  t.starttime AS start_time
FROM
  (
    SELECT
      qh.query_id AS queryid, qh.start_time AS starttime, *
    FROM
      snowflake.account_usage.access_history ah
    JOIN
      snowflake.account_usage.query_history qh
      ON ah.query_id = qh.query_id
  ) t,
  LATERAL FLATTEN(INPUT => t.OBJECTS_MODIFIED) om,
  LATERAL FLATTEN(INPUT => om.value: "columns", outer => true) columns_modified,
  LATERAL FLATTEN(
    INPUT => columns_modified.value: "baseSourceColumns",
    outer => true
  ) base_source_columns
WHERE t.query_start_time::date >= current_date()-1 -- set how far back you want to capture lineage
--AND split_part(om.value:"objectName"::string, '.', 1) = 'CITIBIKE' -- filter to a single database
);
