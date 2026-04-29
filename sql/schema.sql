-- Create the database
CREATE DATABASE urban_mobility;

SHOW DATABASES;

-- Switch to it
USE urban_mobility;

-- Confirm 
SELECT DATABASE();

USE urban_mobility;

DROP TABLE IF EXISTS trips;

CREATE TABLE trips (
    id                  VARCHAR(20)     NOT NULL,
    vendor_id           TINYINT         NOT NULL,
    pickup_datetime     DATETIME        NOT NULL,
    passenger_count     TINYINT         NOT NULL,
    pickup_longitude    DECIMAL(9,6)    NOT NULL,
    pickup_latitude     DECIMAL(8,6)    NOT NULL,
    dropoff_longitude   DECIMAL(9,6)    NOT NULL,
    dropoff_latitude    DECIMAL(8,6)    NOT NULL,
    store_and_fwd_flag  TINYINT         NOT NULL,
    hour_of_day         TINYINT         NOT NULL,
    day_of_week         VARCHAR(10)     NOT NULL,
    is_weekend          TINYINT         NOT NULL,
    trip_distance_km    DECIMAL(8,3)    NOT NULL,
    distance_bucket     VARCHAR(10)     NOT NULL,

    PRIMARY KEY (id)
);

DESCRIBE trips;
SELECT COUNT(*) FROM trips;
