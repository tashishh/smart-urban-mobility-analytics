USE urban_mobility;
-- Total number of trips in the dataset
-- 601662
SELECT COUNT(*) AS total_trips
FROM trips;

-- Total trips grouped by day of week
-- Friday busiest (92,727), Monday quietest (77,456)
SELECT day_of_week,
COUNT(*) AS total_trips
FROM trips
GROUP BY day_of_week
ORDER BY total_trips DESC;

-- Average trip distance in kilometers
-- 3.43 km
SELECT ROUND(AVG(trip_distance_km), 2) AS avg_distance_km
FROM trips;

-- Total trips grouped by hour of day (24-hour format)
-- Peak at hour 18 (6 PM) with 37,535 trips
SELECT hour_of_day,
COUNT(*) AS total_trips
FROM trips
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- Total trips grouped by distance category
-- Short 47.6%, Medium 46.4%, Long 6%
SELECT distance_bucket,
COUNT(*) AS total_trips,
ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM trips), 2) AS percentage
FROM trips
GROUP BY distance_bucket
ORDER BY total_trips DESC;

-- Total trips grouped by passenger count
-- Solo rides (1 passenger) = 73% of all trips
SELECT passenger_count,
COUNT(*) AS total_trips,
ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM trips), 2) AS percentage
FROM trips
GROUP BY passenger_count
ORDER BY passenger_count ASC;

-- Trips split between weekdays and weekends
-- Weekday 71.6%, Weekend 28.4%
SELECT CASE WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
COUNT(*) AS total_trips,
ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM trips), 2) AS percentage
FROM trips
GROUP BY is_weekend
ORDER BY is_weekend ASC;

-- Average trip distance for each day of the week
-- Sunday longest (3.69 km), Saturday shortest (3.32 km)
SELECT day_of_week,
ROUND(AVG(trip_distance_km), 2) AS avg_distance_km
FROM trips
GROUP BY day_of_week
ORDER BY avg_distance_km DESC;

-- Average trip distance for each hour of the day
-- 5 AM longest (5.21 km), likely airport/late night runs
SELECT hour_of_day,
ROUND(AVG(trip_distance_km), 2) AS avg_distance_km
FROM trips
GROUP BY hour_of_day
ORDER BY avg_distance_km DESC
LIMIT 5;

-- Total trips and average distance per vendor
-- Vendor 2 slightly larger (51.9%) with longer avg distance
SELECT vendor_id,
COUNT(*) AS total_trips,
ROUND(AVG(trip_distance_km), 2) AS avg_distance_km,
ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM trips), 2) AS percentage
FROM trips
GROUP BY vendor_id
ORDER BY vendor_id ASC;
