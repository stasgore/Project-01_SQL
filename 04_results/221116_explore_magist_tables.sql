USE magist;


-- 3. Is Magist having user growth?
-- A platform losing users left and right isn’t going to be very useful to us. 
-- It would be a good idea to check for the number of orders grouped by year and month. 
-- Tip: you can use the functions YEAR() and MONTH() to separate the year and 
-- the month of the order_purchase_timestamp.

SELECT
	YEAR(order_purchase_timestamp) AS year_, 
    MONTH(order_purchase_timestamp) AS month_,
    COUNT(customer_id)
FROM 
	orders
GROUP BY year_ , month_
ORDER BY year_ , month_;

-- How many products are there on the products table? (Make sure that there are no duplicate products.)

SELECT DISTINCT COUNT(*)
FROM products;

-- same thing other version
SELECT 
	COUNT(DISTINCT product_id) AS products_count
FROM
	products;

-- Answer: 32951
	

-- Which are the categories with the most products? 
-- Since this is an external database and has been partially anonymized, 
-- we do not have the names of the products. But we do know which categories
-- products belong to. This is the closest we can get to know what sellers are 
-- offering in the Magist marketplace. By counting the rows in the products table 
-- and grouping them by categories, we will know how many products are offered in each category. 
-- This is not the same as how many products are actually sold by category. To acquire 
-- this insight we will have to combine multiple tables together: we’ll do this in the next lesson.

SELECT 
	product_category_name , 
    COUNT(*) 'number of products'
FROM 
	products 
GROUP BY product_category_name
ORDER BY `number of products` DESC;

-- EXPERIMENT
-- How many of the products are actually beeing sold?
-- I picked the the column category with DISTINCT and also COUNT, so that I can count all 
-- items in each category. Then I joined (with INNER JOIN) the products table with order_items table to 
-- filter the products that were sold. 

SELECT  
	product_category_name AS category,
    COUNT(DISTINCT p.product_id) AS 'number of products'
FROM products p
INNER JOIN order_items oi
ON
	p.product_id = oi.product_id
GROUP BY category
ORDER BY `number of products` DESC;

-- How many of those products were present in actual transactions?
-- not categorized 

SELECT 
	COUNT(DISTINCT product_id) AS n_products
FROM order_items;

-- Day#4 Repeating  -------------------------------
-- -------------------------------------------------

SELECT *
FROM orders o
INNER JOIN order_items oi
ON o.order_id = oi.order_id;

SELECT COUNT(*) AS orders_n
FROM orders;


-- Counting each order category (status) 
SELECT COUNT(*) AS orders_n, order_status
FROM orders
GROUP BY order_status;

-- Is Magist having user growth? 

SELECT 
	YEAR(order_purchase_timestamp) AS year_,
    MONTH(order_purchase_timestamp) AS month_,
    COUNT(customer_id)
FROM 
	orders
GROUP BY year_, month_
ORDER BY year_, month_;

-- How many products are there on the products table?

SELECT COUNT(DISTINCT product_id)
FROM products;
-- 32951


-- Which are the categories with the most products?

SELECT COUNT(DISTINCT product_id) AS n_products, product_category_name AS category
FROM products
GROUP BY category
ORDER BY n_products DESC;


-- How many of those products were present in actual transactions?

SELECT COUNT(DISTINCT product_id)
FROM order_items;
-- 32951. All of them.



-- What’s the price for the most expensive and cheapest products? 

SELECT MAX(price) AS 'most expencive', MIN(price) AS 'cheapest'
FROM order_items;
--  most expencive 6735, cheapest: 0.85


-- What are the highest and lowest payment values? 

SELECT MAX(payment_value) AS 'max payment', MIN(payment_value) AS 'min payment'
FROM order_payments;

-- max payment: 13664.1, min payment: 0

-- Day 5; 18.11.2022 -------------- Exploring data
-- --------------------------------

-- just using functions YEAR, MONTH, DAY
SELECT 
	YEAR(shipping_limit_date) AS year_, 
    MONTH(shipping_limit_date) AS month_,
    DAY(shipping_limit_date) AS day_
FROM order_items 
GROUP BY year_, month_, day_
ORDER BY year_, month_, day_;

-- Give me every record where 'estimated delivery' within the same month is bigger than 'order_delivered_costomer_date'

SELECT
-- estimated delivery date split into year, month and day
    YEAR(order_estimated_delivery_date) AS esti_year, 
    MONTH(order_estimated_delivery_date) AS esti_month, 
    DAY(order_estimated_delivery_date) AS esti_day, 
-- order delivered carrier date
	YEAR(order_delivered_carrier_date) AS del_year, 
	MONTH(order_delivered_carrier_date) AS del_month, 
	DAY(order_delivered_carrier_date) AS del_day
FROM orders 
-- GROUP BY esti_year, esti_month, esti_day, del_year, del_month, del_day;
ORDER BY esti_year;
    
    
    
-- compare order_delivered_customer_date and order_delivered_carrier_date
SELECT
-- order_delivered_customer_date split into year, month and day
    YEAR(order_delivered_customer_date) AS cust_del_year, 
    MONTH(order_delivered_customer_date) AS cust_del_month, 
    DAY(order_delivered_customer_date) AS cust_del_day, 
-- order_delivered_carrier_date split into year, month and day
	YEAR(order_delivered_carrier_date) AS del_year, 
	MONTH(order_delivered_carrier_date) AS del_month, 
	DAY(order_delivered_carrier_date) AS del_day
FROM orders 
ORDER BY cust_del_year, cust_del_month, cust_del_day;


-- just looking into order_delivered_cutomer_date
-- doesn`t properly work -> gives NULL in all cells as an answer. It does work, when I don't use ORDER BY. Then it shows all the records. 
SELECT
	YEAR(order_delivered_customer_date) AS cust_del_year, 
    MONTH(order_delivered_customer_date) AS cust_del_month, 
    DAY(order_delivered_customer_date) AS cust_del_day
FROM orders
-- ORDER BY cust_del_year;
-- GROUP BY cust_del_year, cust_del_month, cust_del_day
ORDER BY cust_del_year, cust_del_month, cust_del_day;
-- ORDER BY cust_del_year, cust_del_month, cust_del_day;


-- looking at table with reviews. Goal extract vailuble information with regards to delivery (complains?)
SELECT *-- COUNT(*)
FROM order_reviews; 


-- 
SELECT
	YEAR(review_creation_date) AS rev_year,
    MONTH(review_creation_date) AS rev_month,
    COUNT(review_score) AS 'review <= 3'
FROM order_reviews
WHERE review_score <= 3
GROUP BY rev_year, rev_month
ORDER BY rev_year, rev_month;

-- Scores <= 3 stars for products of categories: 'computers_accessories' OR 'electronics' over the years
SELECT
	YEAR(review_creation_date) AS rev_year,
    MONTH(review_creation_date) AS rev_month,
    COUNT(review_score) AS 'review <= 3'
-- joining the tables to get the translation for the categories
FROM order_reviews orev
INNER JOIN order_items oi
ON orev.order_id = oi.order_id
INNER JOIN products p
ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation p_trans
ON p.product_category_name = p_trans.product_category_name

-- conditioning with all the scores less or equal to 3 AND relevant categories
WHERE review_score <= 3 AND product_category_name_english = 'computers_accessories' OR 'electronics' 
GROUP BY rev_year, rev_month
ORDER BY rev_year, rev_month;


-- Note to Hana I'm trying to put the scores that are <= 3 in relation to all the scores (i.e. including 4 and 5 stars)
SELECT
	YEAR(review_creation_date) AS rev_year,
    MONTH(review_creation_date) AS rev_month,
    COUNT(review_score) AS 'score <= 3'
-- joining the tables to get the translation for the categories
FROM order_reviews orev
INNER JOIN order_items oi
ON orev.order_id = oi.order_id
INNER JOIN products p
ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation p_trans
ON p.product_category_name = p_trans.product_category_name

-- conditioning with all the scores less or equal to 3 AND relevant categories
WHERE review_score <= 3 AND product_category_name_english = 'computers_accessories' OR 'electronics'  OR 'pc_games'
GROUP BY rev_year, rev_month
ORDER BY rev_year, rev_month;


-- Looking into complaints with regards to the delivery in the reviews/comments. Delivery in Portuguese is 'entrega'
-- How do I remove dublicates?
-- Why does it show only 2018? Where there no complains before with regard to delivery?
SELECT 
review_score, 
-- review_comment_title AS 'comment title',
YEAR(review_creation_date) AS rev_year,
MONTH(review_creation_date) AS rev_month,
review_comment_message AS message
FROM order_reviews orev
-- joining the tables to get the translation for the categories
INNER JOIN order_items oi
ON orev.order_id = oi.order_id
INNER JOIN products p
ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation p_trans
ON p.product_category_name = p_trans.product_category_name
-- checking categories that are relevat for us; ONLY scores that are 3 or less; only with 'title of the review'
WHERE review_comment_message LIKE '%entrega%' AND review_comment_title IS NOT NULL 
 AND review_score <= 3 
-- AND product_category_name_english = 'computers_accessories' OR 'electronics' OR 'pc_games'
-- WHERE review_comment_message IS NOT NULL
-- GROUP BY review_score, rev_year, rev_month
ORDER BY review_score, rev_year, rev_month;

-- ----------------------------------------------------------
-- ----------------------------------------------------------
-- percentage of bad reviews with Hana's help

WITH first_table AS(
SELECT
    YEAR(review_creation_date) AS rev_year,
    MONTH(review_creation_date) AS rev_month,
    COUNT(*) as num_reviews,
    (select count(review_id) from order_reviews orev
    INNER JOIN order_items oi
	ON orev.order_id = oi.order_id
	INNER JOIN products p
	ON oi.product_id = p.product_id
	INNER JOIN product_category_name_translation p_trans
	ON p.product_category_name = p_trans.product_category_name

-- conditioning with all the scores less or equal to 3 AND relevant categories, which are 'computers_accessories', 'electronics',	 'pc_games'
WHERE product_category_name_english = 'computers_accessories' OR 'electronics'  OR 'pc_games'
    
    ) as All_Reviews,
    CASE
        WHEN review_score <= 3 THEN 'less than 3'
        ELSE 'more'
    END AS less_or_more
    -- SUM(counting) AS divide
-- joining the tables to get the translation for the categories
FROM order_reviews orev
INNER JOIN order_items oi
ON orev.order_id = oi.order_id
INNER JOIN products p
ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation p_trans
ON p.product_category_name = p_trans.product_category_name

-- conditioning with all the scores less or equal to 3 AND relevant categories
WHERE product_category_name_english = 'computers_accessories' OR 'electronics'  OR 'pc_games'
GROUP BY rev_year, rev_month,less_or_more
HAVING less_or_more = 'less than 3'
ORDER BY rev_year, rev_month,less_or_more
)
select rev_year AS 'year', rev_month AS 'month', ROUND(((num_reviews/All_Reviews)*100),2) as 'reviews <= 3 stars in %'
from first_table
;
-- num_reviews




WITH first_table AS(
SELECT
    YEAR(review_creation_date) AS rev_year,
    MONTH(review_creation_date) AS rev_month,
    COUNT(*) as num_reviews,
    (select count(review_id) from order_reviews orev
    INNER JOIN order_items oi
    ON orev.order_id = oi.order_id
    INNER JOIN products p
    ON oi.product_id = p.product_id
    INNER JOIN product_category_name_translation p_trans
    ON p.product_category_name = p_trans.product_category_name

-- conditioning with all the scores less or equal to 3 AND relevant categories, which are 'computers_accessories', 'electronics',     'pc_games'
WHERE product_category_name_english = 'computers_accessories' OR 'electronics'  OR 'pc_games'

    ) as All_Reviews,
    CASE
        WHEN review_score <= 3 THEN 'less than 3'
        ELSE 'more'
    END AS less_or_more
    -- SUM(counting) AS divide
-- joining the tables to get the translation for the categories
FROM order_reviews orev
INNER JOIN order_items oi
ON orev.order_id = oi.order_id
INNER JOIN products p
ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation p_trans
ON p.product_category_name = p_trans.product_category_name

-- conditioning with all the scores less or equal to 3 AND relevant categories
WHERE product_category_name_english = 'computers_accessories' OR 'electronics'  OR 'pc_games'
GROUP BY rev_year, rev_month,less_or_more
HAVING less_or_more = 'less than 3'
ORDER BY rev_year, rev_month,less_or_more
)
select 
concat(rev_year,"-",rev_month),
ROUND(((num_reviews/All_Reviews)*100),2) as 'reviews <= 3 stars in %'
from first_table;



-- ----------------------------------------------------------------------