-- DB selection
USE hotels;

-- First query: Statistics about amount and types of reserved rooms by
-- year
SELECT arrival_year, reserved_room_type, COUNT(*)
FROM HotelBooking
GROUP BY reserved_room_type, arrival_year
ORDER BY reserved_room_type, arrival_year;

-- Second query: We are interested in demographics about Spanish
-- travellers in august, concretely about family compositions
SELECT adults, children, babies, count(*)
FROM HotelBooking
WHERE country = "ESP" and arrival_month = "August"
GROUP BY adults, children, babies
ORDER BY count(*) DESC;
