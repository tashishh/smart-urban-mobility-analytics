-- Classify each hour as Peak, Shoulder, or Off-Peak based on trip volume
-- Peak-Very busy-high demand	Hours with 30,000+ trips
-- Shoulder-Moderate-in between	Hours with 20,000–29,999 trips
-- Off-Peak-Quiet-low demand	Hours with under 20,000 trips

SELECT hour_of_day,
COUNT(*) AS total_trips,
CASE
	WHEN COUNT(*) >= 30000 THEN 'Peak'
	WHEN COUNT(*) >= 20000 THEN 'Shoulder'
	ELSE 'Off-Peak'
END AS hour_category
FROM trips
GROUP BY hour_of_day
ORDER BY total_trips DESC;


-- Average trips per day for weekdays vs weekends
SELECT CASE WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
COUNT(*) AS total_trips,
ROUND(COUNT(*) / COUNT(DISTINCT day_of_week), 0) AS avg_trips_per_day
FROM trips
GROUP BY is_weekend;


-- What percentage of trips are long distance for each day of the week
SELECT day_of_week,
COUNT(*) AS total_trips,
SUM(CASE WHEN distance_bucket = 'Long' THEN 1 ELSE 0 END) AS long_trips,
ROUND(SUM(CASE WHEN distance_bucket = 'Long' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS long_trip_pct
FROM trips
GROUP BY day_of_week
ORDER BY long_trip_pct DESC;


-- Average and max trip distance within each distance bucket
SELECT distance_bucket,
COUNT(*) AS total_trips,
ROUND(AVG(trip_distance_km), 2) AS avg_distance_km,
ROUND(MIN(trip_distance_km), 2) AS min_distance_km,
ROUND(MAX(trip_distance_km), 2) AS max_distance_km
FROM trips
GROUP BY distance_bucket
ORDER BY avg_distance_km ASC;


-- Total trips and percentage share by hour category
SELECT
    hour_category,
    SUM(trip_count) AS total_trips,
    ROUND(SUM(trip_count) * 100 / (SELECT COUNT(*) FROM trips), 2) AS percentage
FROM (
    SELECT
        hour_of_day,
        COUNT(*) AS trip_count,
        CASE
            WHEN COUNT(*) >= 30000 THEN 'Peak'
            WHEN COUNT(*) >= 20000 THEN 'Shoulder'
            ELSE 'Off-Peak'
        END AS hour_category
    FROM trips
    GROUP BY hour_of_day
) AS hourly
GROUP BY hour_category
ORDER BY total_trips DESC;


-- How each vendor's trips break down across distance buckets
SELECT vendor_id,
distance_bucket,
COUNT(*) AS total_trips,
ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (PARTITION BY vendor_id), 2) AS pct_of_vendor
FROM trips
GROUP BY vendor_id, distance_bucket
ORDER BY vendor_id, total_trips DESC;


-- Find the single busiest hour for each day of the week
SELECT
    day_of_week,
    hour_of_day,
    total_trips
FROM (
    SELECT
        day_of_week,
        hour_of_day,
        COUNT(*) AS total_trips,
        RANK() OVER (PARTITION BY day_of_week ORDER BY COUNT(*) DESC) AS rnk
    FROM trips
    GROUP BY day_of_week, hour_of_day
) AS ranked
WHERE rnk = 1
ORDER BY total_trips DESC;


-- Compare distance bucket distribution on weekdays vs weekends
SELECT CASE WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
distance_bucket,
COUNT(*) AS total_trips,
ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (PARTITION BY is_weekend), 2) AS percentage
FROM trips
GROUP BY is_weekend, distance_bucket
ORDER BY day_type, total_trips DESC;


-- Top 5 busiest hour and day combinations
SELECT day_of_week,
hour_of_day,
COUNT(*) AS total_trips
FROM trips
GROUP BY day_of_week, hour_of_day
ORDER BY total_trips DESC
LIMIT 5;


-- Average passenger count on weekdays vs weekends
SELECT CASE WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
ROUND(AVG(passenger_count), 2) AS avg_passengers,
MAX(passenger_count) AS max_passengers,
SUM(CASE WHEN passenger_count > 1 THEN 1 ELSE 0 END) AS group_trips,
ROUND(SUM(CASE WHEN passenger_count > 1 THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS group_trip_pct
FROM trips
GROUP BY is_weekend;