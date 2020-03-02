-- Database creation
CREATE DATABASE IF NOT EXISTS hotels LOCATION '/user/impala/impalahotels.db'

-- Database selection
USE hotels;

-- Table creation (last line ignores header)
CREATE TABLE IF NOT EXISTS HotelBooking (
hotel STRING, canceled INT, lead_time INT, arrival_year INT, arrival_month STRING,
arrival_week INT, arrival_day INT, days_in_weekend INT, days_in_week INT, adults INT,
children INT, babies INT, meal STRING, country STRING, market_segment STRING,
distribution_channel STRING, repeated_guest INT, previous_cancellations INT,
previous_bookings_not_cancelled INT, reserved_room_type STRING, assigned_room_type STRING,
booking_changes INT, deposit_type STRING, agent INT, company INT, days_in_waiting INT,
customer_type STRING, adr FLOAT, parking_places INT, special_requests INT,
reservation_status STRING, reservation_status_date TIMESTAMP
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\,' LINES TERMINATED BY '\n'
tblproperties("skip.header.line.count"="1");

-- Data ingestion
LOAD DATA INPATH '/user/impala/input/hotel_bookings.csv' OVERWRITE INTO TABLE HotelBooking;
