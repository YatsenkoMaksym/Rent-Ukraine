-- Standartize a bit more
UPDATE rental_listings
SET "location" = COALESCE("location",'Not specified');

UPDATE rental_listings
SET district = COALESCE(district,'Not specified');

UPDATE rental_listings
SET district = 'Not specified'
WHERE district = 'Unknown';

-- Average price and size by city and room count
CREATE OR REPLACE VIEW vw_prices_by_city_rooms AS
SELECT city, room_count
	, COUNT(listing_id) AS total_listings
	, AVG(price) AS mean_price
	, AVG(size) AS mean_size
	, AVG(price_per_sqm) AS mean_price_sqm
	, PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY price) AS median_price
FROM rental_listings
GROUP BY city, room_count
ORDER BY city, room_count;

-- Total listings and average price per origin (OLX, Dom.ria, Lun)
CREATE OR REPLACE VIEW vw_listings_by_origin AS
SELECT origin
	, COUNT(listing_id) AS total_listings
	, AVG(price) AS mean_price
	, AVG(size) AS mean_size
	, AVG(price_per_sqm) AS mean_price_sqm
	, PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY price) AS median_price 
FROM rental_listings
GROUP BY origin
ORDER BY origin;

-- Ranking listings by price within each city and room count
CREATE OR REPLACE VIEW listing_rank_city_rooms AS
SELECT listing_id, price, size, room_count, city
	,RANK() OVER(PARTITION BY city, room_count ORDER BY price) AS rank_city_rooms   
FROM rental_listings
ORDER BY city, room_count;

-- Difference in price in a region and city
CREATE OR REPLACE VIEW region_city_performance AS
SELECT region, city
	, AVG(price) AS mean_price_city
	, AVG(price) OVER(PARTITION BY region) AS mean_price_region
	, AVG(price) - AVG(price) OVER(PARTITION BY region) AS mean_price_diff
FROM rental_listings
GROUP BY region, city,price
ORDER BY region, city;

-- Difference in price depending on origin
CREATE OR REPLACE VIEW vw_origin_performance AS
SELECT origin
	, COUNT(listing_id) AS total_listings
	, AVG(price) AS mean_price
	, AVG(price_per_sqm) AS mean_price_per_sqm
	, PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY price) AS median_price
FROM
    rental_listings
GROUP BY
    origin;
