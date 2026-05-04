Use urban_mobility;
-- View 1: hourly_summary
-- Total trips per hour, with peak category label
-- -------------------------------------------------------
CREATE OR REPLACE VIEW hourly_summary AS
SELECT
    hour_of_day,
    COUNT(*)                          AS total_trips,
    ROUND(AVG(trip_distance_km), 2)   AS avg_distance_km,
    ROUND(AVG(passenger_count), 2)    AS avg_passengers,
    CASE
        WHEN COUNT(*) >= 30000 THEN 'Peak'
        WHEN COUNT(*) >= 20000 THEN 'Shoulder'
        ELSE 'Off-Peak'
    END                               AS hour_category
FROM trips
GROUP BY hour_of_day
ORDER BY hour_of_day;


-- -------------------------------------------------------
-- View 2: weekday_summary
-- Total trips per day of week, with weekday/weekend label
-- -------------------------------------------------------
CREATE OR REPLACE VIEW weekday_summary AS
SELECT
    day_of_week,
    is_weekend,
    COUNT(*)                          AS total_trips,
    ROUND(AVG(trip_distance_km), 2)   AS avg_distance_km,
    ROUND(AVG(passenger_count), 2)    AS avg_passengers
FROM trips
GROUP BY day_of_week, is_weekend
ORDER BY FIELD(day_of_week,
    'Monday','Tuesday','Wednesday',
    'Thursday','Friday','Saturday','Sunday');


-- -------------------------------------------------------
-- View 3: distance_summary
-- Trip volume and averages by distance bucket
-- -------------------------------------------------------
CREATE OR REPLACE VIEW distance_summary AS
SELECT
    distance_bucket,
    COUNT(*)                          AS total_trips,
    ROUND(AVG(trip_distance_km), 2)   AS avg_distance_km,
    ROUND(MIN(trip_distance_km), 2)   AS min_distance_km,
    ROUND(MAX(trip_distance_km), 2)   AS max_distance_km,
    ROUND(AVG(passenger_count), 2)    AS avg_passengers
FROM trips
GROUP BY distance_bucket
ORDER BY FIELD(distance_bucket, 'Short', 'Medium', 'Long');


-- -------------------------------------------------------
-- View 4: vendor_summary
-- Trip volume and behavior breakdown by vendor
-- -------------------------------------------------------
CREATE OR REPLACE VIEW vendor_summary AS
SELECT
    vendor_id,
    COUNT(*)                          AS total_trips,
    ROUND(AVG(trip_distance_km), 2)   AS avg_distance_km,
    ROUND(AVG(passenger_count), 2)    AS avg_passengers,
    SUM(CASE WHEN distance_bucket = 'Long'   THEN 1 ELSE 0 END) AS long_trips,
    SUM(CASE WHEN distance_bucket = 'Medium' THEN 1 ELSE 0 END) AS medium_trips,
    SUM(CASE WHEN distance_bucket = 'Short'  THEN 1 ELSE 0 END) AS short_trips
FROM trips
GROUP BY vendor_id
ORDER BY vendor_id;


-- -------------------------------------------------------
-- View 5: weekend_summary
-- Weekday vs Weekend comparison for dashboard KPI card
-- -------------------------------------------------------
CREATE OR REPLACE VIEW weekend_summary AS
SELECT
    CASE WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    COUNT(*)                                                    AS total_trips,
    ROUND(AVG(trip_distance_km), 2)                             AS avg_distance_km,
    ROUND(AVG(passenger_count), 2)                              AS avg_passengers,
    SUM(CASE WHEN passenger_count > 1 THEN 1 ELSE 0 END)        AS group_trips,
    ROUND(
        SUM(CASE WHEN passenger_count > 1 THEN 1 ELSE 0 END)
        * 100 / COUNT(*), 2
    )                                                           AS group_trip_pct
FROM trips
GROUP BY is_weekend;

-- -------------------------------------------------------
SELECT * FROM hourly_summary;
SELECT * FROM weekday_summary;
SELECT * FROM distance_summary;
SELECT * FROM vendor_summary;
SELECT * FROM weekend_summary;