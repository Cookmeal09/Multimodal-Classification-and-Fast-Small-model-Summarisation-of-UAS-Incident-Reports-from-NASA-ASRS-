
-- Step 3: sql/queries.sql
CREATE OR REPLACE TABLE r AS SELECT * FROM df_view;

-- Q1: reports by year and group
SELECT year AS year, is_uas AS is_uas, COUNT(*) AS n 
FROM r GROUP BY 1, 2 ORDER BY 1, 2;

-- Q2: flight phase distribution, within-group share via window function
SELECT is_uas AS is_uas, 'UNKNOWN' AS flight_phase, COUNT(*) AS n,
       COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY is_uas) AS pct
FROM r GROUP BY 1, 2 ORDER BY 1, pct DESC;

-- Q3: label and narrative length by class
SELECT 'other' AS y, COUNT(*) AS n, AVG(length('')) AS len 
FROM r GROUP BY 1 ORDER BY n DESC;

-- Q4: model table (compact structured fields)
CREATE OR REPLACE TABLE feat AS
SELECT ROW_NUMBER() OVER () AS id, year AS year, is_uas AS is_uas, 
       'other' AS y, '' AS narrative, 'UNKNOWN' AS flight_phase 
FROM r;
