-- Load data from CSV
hotel_bookings = LOAD '/user/pig/hotel_bookings.csv' USING PigStorage(',') AS (
hotel:chararray, canceled:int, lead_time:int, arrival_year:int, arrival_month:chararray,
arrival_week:int, arrival_day:int, days_in_weekend:int, days_in_week:int, adults:int,
children:int, babies:int, meal:chararray, country:chararray, market_segment:chararray,
distribution_channel:chararray, repeated_guest:int, previous_cancellations:int,
previous_bookings_not_cancelled:int, reserved_room_type:chararray, assigned_room_type:chararray,
booking_changes:int, deposit_type:chararray, agent:int, company:int, days_in_waiting:int,
customer_type:chararray, adr:float, parking_places:int, special_requests:int,
reservation_status:chararray, reservation_status_date:chararray);

-- Select information to keep only relevant columns
nations_and_people = foreach hotel_bookings generate adults, children, country, babies, market_segment;

-- Filter rows we are interested in (alone adults)
alone_adults = filter nations_and_people by adults == 1 and children == 0 and babies == 0;

-- Group travellers by market segment and country
travels_by_segment = group alone_adults by (country, market_segment);

-- Count size of each group
num_travels_by_segment = foreach travels_by_segment generate
FLATTEN(group) as (country, segment),
COUNT(alone_adults) as num_travels;

-- Delete irrelevant groups (missing data or too small)
filtered_travels = filter num_travels_by_segment by num_travels >= 100 and country != 'NULL';

-- Rank information to make it easier to interpret
ordered_travels = order filtered_travels by num_travels desc;

-- Show retrieved via terminal
dump ordered_travels;
