-- Creating Database

CREATE DATABASE walmart;
USE walmart;

-- Creating tables for storing customer datas


CREATE TABLE IF NOT EXISTS customers(
	invoice_id 	VARCHAR(30) NOT NULL PRIMARY KEY,
	branch VARCHAR(30) NOT NULL,
	city VARCHAR(30) NOT NULL,
	customer_type VARCHAR(30) NOT NULL,
	gender VARCHAR(30) NOT NULL,
	product_line VARCHAR(30) NOT NULL
);

-- Creating tables for storing order and revenue datas


CREATE TABLE IF NOT EXISTS orders(
	invoice_id VARCHAR(30) NOT NULL,
	unit_price DECIMAL(10,2) NOT NULL,
	quantity INT NOT NULL,
	tax FLOAT(6,4) NOT NULL,	
    	total DECIMAL(10,2) NOT NULL, 
	date DATE NOT NULL,
	time TIME NOT NULL,
	payment_method VARCHAR(30) NOT NULL,
    	cogs DECIMAL(10,2) NOT NULL,
	margin_percentage FLOAT(11,2),
	gross_income DECIMAL(12, 2) NOT NULL,
	rating FLOAT(3, 1),
    	CONSTRAINT FK_ORDERS FOREIGN KEY (invoice_id) REFERENCES customers(invoice_id)
);



-- Data cleaning    
-- Adding day in day_name column
SELECT
	date,
	DAYNAME(date)
FROM orders;

ALTER TABLE orders 
ADD COLUMN day_name VARCHAR(10);

UPDATE orders
SET day_name = DAYNAME(date);

-- Adding month_name column
SELECT 
    date,
    MONTHNAME(date) AS month
FROM orders;

ALTER TABLE orders
	ADD COLUMN month_name VARCHAR(10);
UPDATE orders 
	SET month_name = MONTHNAME(date);
    
    
           -- Generic --
-- 1.How many unique cities does the data have?
SELECT 
	DISTINCT city
FROM customers;

-- 2.In which city is each branch?
SELECT 
	DISTINCT city,
    branch
FROM customers;

           -- product --
           
-- 3.How many unique product lines does the data have
SELECT
	DISTINCT product_line
FROM customers;

-- 4.What is the most selling product line
SELECT
	SUM(o.quantity) as qty,
    c.product_line
FROM customers c
JOIN orders o
	USING (invoice_id)
GROUP BY c.product_line
ORDER BY qty DESC;

-- 5.What is the total revenue by month
SELECT
	month_name AS month,
	SUM(total) AS total_revenue
FROM orders
GROUP BY month_name 
ORDER BY total_revenue;

-- 6.What month had the largest COGS?
SELECT
	month_name AS month,
	SUM(cogs) AS cogs
FROM orders
GROUP BY month_name 
ORDER BY cogs;

-- 7.What product line had the largest revenue?
SELECT
	c.product_line,
	SUM(o.total) as total_revenue
FROM customers c
JOIN orders o
	USING (invoice_id)
GROUP BY c.product_line
ORDER BY total_revenue DESC;

-- 8.What is the city with the largest revenue?
SELECT
	c.branch,
	c.city,
	SUM(o.total) AS total_revenue
FROM customers c
JOIN orders o
	USING (invoice_id)
GROUP BY c.city, c.branch 
ORDER BY total_revenue;

-- 9.What product line had the largest VAT?
SELECT
	c.product_line,
	AVG(o.tax) as avg_tax
FROM customers c
JOIN orders o
	USING (invoice_id)
GROUP BY c.product_line
ORDER BY avg_tax DESC;

-- 10.Fetch each product line and add a column to those product line showing 
-- "Good", "Bad". Good if its greater than average sales

SELECT 
	AVG(quantity) AS avg_qnty
FROM orders;                                        -- now we find that avg qty is 5.5
    
SELECT
	c.product_line,
	CASE
		WHEN AVG(o.quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS status
FROM customers c
JOIN orders o
GROUP BY c.product_line;

-- 11.What is the most common product line by gender
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM customers
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- 12.What is the average rating of each product line
SELECT
	ROUND(AVG(o.rating), 2) as avg_rating,
    c.product_line
FROM customers c
JOIN orders o
	USING (invoice_id)
GROUP BY c.product_line
ORDER BY avg_rating DESC;

                 -- Customers -- 
				
-- 13.How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM customers;

-- 14.How many unique payment methods does the data have?
SELECT
	DISTINCT o.payment_method
FROM customers c
JOIN orders o
	USING (invoice_id);

-- 15.What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM customers
GROUP BY customer_type
ORDER BY count DESC;

-- 16.Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*) AS no_of_customer
FROM customers
GROUP BY customer_type
ORDER BY no_of_customer DESC;

-- 17.What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM customers
GROUP BY gender
ORDER BY gender_cnt DESC;

-- 18.What is the gender distribution in branch c?
SELECT
	branch,
	gender,
	COUNT(*) as gender_cnt
FROM customers
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;

-- 19.Which time of the day do customers give most ratings?
SELECT
	o.time,
	AVG(rating) AS avg_rating
FROM customers c
JOIN orders o
	USING (invoice_id)
GROUP BY o.time
ORDER BY avg_rating DESC;

-- 20.Which time of the day do customers give most ratings in branch 'A'?
SELECT
	c.branch AS branch_name,
	o.time,
	AVG(o.rating) AS avg_rating
FROM customers c
JOIN orders o
	USING (invoice_id)
WHERE branch = "A"
GROUP BY o.time
ORDER BY avg_rating DESC;

-- 21.Which day of the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM orders
GROUP BY day_name 
ORDER BY avg_rating DESC;                           -- Mon, Friday and sunday are the top best days for good ratings

-- 22.Which day of the week has the best average ratings for branch 'C'?
SELECT 
	COUNT(o.day_name) AS Nos,
    c.branch,
	o.day_name,
	AVG(o.rating) AS ratings 
FROM customers c
JOIN orders o
	USING (invoice_id)
WHERE branch = "C"
GROUP BY o.day_name
ORDER BY ratings DESC;                        -- wednesday, Friday and saturday are the top best days for good ratings

                  -- sales --
                  
-- 23.Number of sales made in each time of the sunday 
SELECT
	day_name,
	time,
	COUNT(*) AS total_sales
FROM orders
WHERE day_name = "Sunday"
GROUP BY time 
ORDER BY total_sales DESC;                    -- Evenings experience most sales, the stores are filled during the evening hours

-- 24.Which of the customer types brings the most revenue?
SELECT
	c.customer_type,
	SUM(o.total) AS total_revenue
FROM customers c
JOIN orders o 
	USING (invoice_id)
GROUP BY customer_type
ORDER BY total_revenue;                       -- Most of the customers are in normal categories

-- 25.Which city has the largest tax/VAT percent?
SELECT
	c.city,
    ROUND(AVG(o.tax), 2) AS avg_tax_pct
FROM customers c 
JOIN orders o
	USING (invoice_id)
GROUP BY c.city 
ORDER BY avg_tax_pct DESC;                    -- Naypyitaw haves most percentage of taxes

-- 26.Which customer type pays the most in Tax?
SELECT
	c.customer_type,
	AVG(o.tax) AS total_tax
FROM customers c 
JOIN orders o 
	USING (invoice_id)
GROUP BY c.customer_type
ORDER BY total_tax DESC;                         -- Members are paying more taxex compered to normal customers

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------




