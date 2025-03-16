SELECT * FROM walmart;

SELECT COUNT(*) FROM walmart;

SELECT payment_method,
COUNT(*) 
FROM walmart
GROUP BY payment_method

SELECT 
	COUNT(DISTINCT branch)
FROM  walmart

SELECT MAX(quantity)
FROM walmart

-- Business problems

-- Find the different payment method and number of transactions and no of quantities sold.
SELECT payment_method,
	COUNT(*) as no_payments,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method

--Identify the highest-rated category in each branch, 
--displaying the branch, category, AVG Rating
SELECT *
FROM 
(	SELECT 
		branch, 
		category, 
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
)
WHERE rank=1

--Identify the busiset day for each branch based on the number of transaction

SELECT * 
FROM 
(SELECT 
	branch, 
	TO_CHAR(TO_DATE(date, 'DD/MM/YY'),'Day') as day_name,
	COUNT(*) as no_transactions,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank 
FROM walmart
GROUP BY 1, 2
)
WHERE rank = 1

-- Calculate the total quantity of items sold per payment method. List payment method and total quantity.
SELECT payment_method,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method

--Determine the average, minimum, and maximum rating of category for each city.
-- List the city, average_rating, min_rating, max_rating
SELECT 
	city, 
	category, 
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating
FROM walmart
GROUP BY 1,2

-- Calculate the total profit for each category by considering total_profit as
--(unit_price * quantity * profit_margin).
-- List category and total_profit. ordered from highest to lowest profit.

SELECT 
	category,
	SUM(total) as total_revenue,
	SUM(unit_price * quantity * profit_margin) as total_profit
FROM walmart
GROUP BY 1
ORDER BY total_profit DESC;


-- Q.7 Determine the most common payment method for each branch. 
-- Display Branch and the preferred_payment_method.
WITH cte
AS
(SELECT
	branch,
	payment_method,
	COUNT(*) as total_trans,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1, 2
)
SELECT * 
FROM cte
WHERE rank = 1

--  Categorize sales into 3 group MORNING, AFTERNOON, EVENING
-- Find out which of the shift and number of invoices.

SELECT 
	branch,
CASE
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'MORNING'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		ELSE 'EVENING'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC

-- Identify 5 branch with highest decrease ratio in revenue 
-- compare to last year(current year 2023 and last year 2022).

-- Revenue Decrease ratio(rdr) = last_rev - cr_rev / ls_rev * 100
SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
	branch, 
	SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
	GROUP BY 1
),

revenue_2023
AS
(
	SELECT 
	branch, 
	SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)
SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as current_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/ 
		ls.revenue::numeric * 100,
		2) as revenue_decrease_ratio
FROM revenue_2022 as ls 
JOIN 
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue >cs.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5 





























