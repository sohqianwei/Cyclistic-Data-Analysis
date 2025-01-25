-- Creating a new Database --
CREATE DATABASE cyclistic_data;

-- Switch to the Database --
USE cyclistic_data;

-- Design the table schema
CREATE TABLE trips (
    ride_id VARCHAR(50) PRIMARY KEY,
    rideable_type VARCHAR(20),
    start_time DATETIME,
    end_time DATETIME,
    start_station_name VARCHAR(100),
    start_station_id VARCHAR(50),
    end_station_name VARCHAR(100),
    end_station_id VARCHAR(50),
    member_casual VARCHAR(20)
);

-- Alter table to allow NULL values 
ALTER TABLE trips
MODIFY start_station_name VARCHAR(255) NULL,
MODIFY start_station_id VARCHAR(255) NULL,
MODIFY end_station_name VARCHAR(255) NULL, 
MODIFY end_station_id VARCHAR(255) NULL;


-- Check the table for Duplicated values and delete, if any --
DELETE FROM trips
WHERE ride_id IN (
    SELECT ride_id
    FROM (
        SELECT ride_id, COUNT(*) AS cnt
        FROM trips
        GROUP BY ride_id
        HAVING cnt > 1
    ) AS duplicates
);

-- Fix Anomalies, remove trips with negative duration --
SET SQL_SAFE_UPDATES = 0;
DELETE FROM trips
WHERE TIMESTAMPDIFF(MINUTE, start_time, end_time) < 0;
SET SQL_SAFE_UPDATES = 1;

-- Analyse the Cyclistic Data -- 
-- Count total rides by user type --
SELECT member_casual, 
COUNT(*) AS total_rides
FROM trips
GROUP BY member_casual;

-- Calculate average trip duration by user type -- 
SELECT member_casual, 
AVG(TIMESTAMPDIFF(MINUTE, start_time, end_time)) AS avg_trip_duration
FROM trips
GROUP BY member_casual;

-- Rides by day of the week by user type --
SELECT DAYNAME(start_time) AS day_of_week, 
member_casual, 
COUNT(*) AS total_rides
FROM trips
GROUP BY day_of_week, member_casual
ORDER BY FIELD(day_of_week, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');

-- Identify peak hour usage -- 
SELECT HOUR(start_time) AS hour, member_casual, COUNT(*) AS total_rides
FROM trips
GROUP BY member_casual, hour
ORDER BY member_casual, hour;

-- Rides by month by rider type --
SELECT 
MONTH(start_time) AS month, 
member_casual, 
COUNT(*) as total_rides
FROM trips
GROUP BY month, member_casual
ORDER BY month;

-- Average ride length by month by user type -- 
SELECT 
member_casual,
MONTH(start_time) AS month,
AVG(TIMESTAMPDIFF(MINUTE, start_time, end_time)) AS avg_ride_length
FROM trips
GROUP BY month, member_casual
ORDER BY month;

-- bike type preferences by user type --
SELECT 
member_casual, 
rideable_type AS bike_type, 
COUNT(*) AS total_rides
FROM trips
GROUP BY member_casual, bike_type;

