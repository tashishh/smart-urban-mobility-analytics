-- ============================================================
-- File     : load_data.sql
-- Project  : Smart Urban Mobility
-- Database : urban_mobility
-- Table    : trips
-- Day      : 9 - Load CSV Data into MySQL
-- Author   : Ashish
-- Date     : April 29, 2026
-- ============================================================
-- NOTE: The LOAD DATA LOCAL INFILE block in this script did
-- NOT work inside MySQL Workbench 8.0.44.
-- Error received:
--   Error Code: 2068. LOAD DATA LOCAL INFILE file request
--   rejected due to restrictions on access.
--
-- FIX: The LOAD DATA block was run via MySQL Command Line:
--   Step 1: Open CMD
--   Step 2: Run: mysql --local-infile=1 -u root -p
--   Step 3: Enter password
--   Step 4: Paste the LOAD DATA block below and press Enter
--
-- All other queries in this file run fine in Workbench.
-- ============================================================


-- Allow MySQL to read files from your local machine
SET GLOBAL local_infile = 1;

-- Confirm it is ON
-- Expected: local_infile | ON
SHOW GLOBAL VARIABLES LIKE 'local_infile';

USE urban_mobility;

-- Confirm you are in the right database
-- Expected: urban_mobility
SELECT DATABASE();

-- Confirm the table is empty and ready
SELECT COUNT(*) FROM trips;

SELECT * FROM trips;

-- Clear any existing rows (safe to re-run)
TRUNCATE TABLE trips;


-- ============================================================
-- !! THIS BLOCK DID NOT WORK IN WORKBENCH (Error Code 2068) !!
-- It was run via CMD using: mysql --local-infile=1 -u root -p
-- Result: Query OK, 601662 rows affected (36.07 sec)
--         Records: 601662  Deleted: 0  Skipped: 0
-- ============================================================

-- mysql --local-infile=1 -u root -p

-- Load the CSV into the trips table
LOAD DATA LOCAL INFILE 'D:/innosp/Smart_Urban_Mobility_Project/data/cleaned/taxi_cleaned.csv'
INTO TABLE trips
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    id,
    vendor_id,
    pickup_datetime,
    passenger_count,
    pickup_longitude,
    pickup_latitude,
    dropoff_longitude,
    dropoff_latitude,
    store_and_fwd_flag,
    hour_of_day,
    day_of_week,
    is_weekend,
    trip_distance_km,
    distance_bucket
);


-- ============================================================
-- POST-LOAD VALIDATION 
-- ============================================================

-- Confirm row count
-- Expected: 601662
SELECT COUNT(*) FROM urban_mobility.trips;

-- Check a sample of data looks right
SELECT * FROM urban_mobility.trips LIMIT 5;

-- Check for any NULL issues in key columns
-- Expected: all NULL counts = 0
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN trip_distance_km IS NULL THEN 1 ELSE 0 END) AS null_distance,
    SUM(CASE WHEN pickup_datetime  IS NULL THEN 1 ELSE 0 END) AS null_datetime,
    SUM(CASE WHEN passenger_count  IS NULL THEN 1 ELSE 0 END) AS null_passengers
FROM urban_mobility.trips;

SELECT * FROM trips;

-- vendor_id must only be 1 or 2
SELECT DISTINCT vendor_id
FROM trips
ORDER BY vendor_id;

-- day_of_week must have exactly 7 values
SELECT DISTINCT day_of_week
FROM trips
ORDER BY day_of_week;

-- distance_bucket must have exactly 3 values
SELECT DISTINCT distance_bucket
FROM trips
ORDER BY distance_bucket;

-- is_weekend must only be 0 or 1
SELECT DISTINCT is_weekend
FROM trips
ORDER BY is_weekend;

SELECT
    MIN(hour_of_day)                AS min_hour,
    MAX(hour_of_day)                AS max_hour,
    MIN(passenger_count)            AS min_pax,
    MAX(passenger_count)            AS max_pax,
    ROUND(MIN(trip_distance_km), 3) AS min_dist,
    ROUND(MAX(trip_distance_km), 3) AS max_dist,
    ROUND(AVG(trip_distance_km), 3) AS avg_dist
FROM trips;

-- Peak hour must be 18 (6 PM) with 37,535 trips
SELECT
    hour_of_day,
    COUNT(*) AS trip_count
FROM trips
GROUP BY hour_of_day
ORDER BY trip_count DESC
LIMIT 5;

-- Busiest day must be Friday with 92,727 trips
SELECT
    day_of_week,
    COUNT(*) AS trip_count
FROM trips
GROUP BY day_of_week
ORDER BY trip_count DESC
LIMIT 7;