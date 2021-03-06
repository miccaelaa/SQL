-- Make the company’s database your default database:
DATABASE ua_company;

-- Exercise 1 --
-- How many distinct dates are there in the saledate column of the transaction table for each month/year combination in the database?
SELECT EXTRACT(YEAR FROM saledate) AS year_num,
       EXTRACT(MONTH  FROM saledate) AS month_num,
       COUNT(DISTINCT saledate) AS distinct_days
FROM trnsact
GROUP BY year_num, month_num
ORDER BY year_num ASC, month_num ASC;


-- Exercise 2 --
-- Determine which sku had the greatest total sales during the combined summer months of June, July, and August. 
SELECT sku,
       SUM(CASE WHEN EXTRACT(MONTH FROM saledate)=6 AND stype='P' THEN amt END) AS june_sales,
       SUM(CASE WHEN EXTRACT(MONTH FROM saledate)=7 AND stype='P' THEN amt END) AS july_sales,
       SUM(CASE WHEN EXTRACT(MONTH FROM saledate)=8 AND stype='P' THEN amt END) AS august_sales, 
       (june_sales + july_sales + august_sales) AS summer_sales      
FROM trnsact
GROUP BY sku
ORDER BY summer_sales DESC;


-- Exercise 3 --
-- How many distinct dates are there in the saledate column of the transaction table for each month/year/store combination in the database?
-- Sort your results by the number of days per combination in ascending order. 
SELECT EXTRACT(YEAR FROM saledate) AS year_num,
       EXTRACT(MONTH FROM saledate) AS month_num,
       store,
       COUNT(DISTINCT saledate) AS num_saledates
FROM trnsact
GROUP BY month_num, year_num, store
ORDER BY num_saledates ASC; 


-- Exercise 4 --
-- What is the average daily revenue for each store/month/year combination in the database?
SELECT store,
       EXTRACT(MONTH FROM saledate) AS month_num,
       EXTRACT(YEAR FROM saledate) AS year_num,
       COUNT(DISTINCT saledate) AS dates_num,
       SUM(amt) / COUNT(DISTINCT saledate) AS avg_daily_rev
FROM trnsact
WHERE stype = 'P' 
GROUP BY store, month_num, year_num
ORDER BY year_num ASC, month_num ASC;

-- (a) Modify the query above with a clause that removes all the data from August, 2005 and at least 20 days of data within each month.
SELECT store,
       EXTRACT(MONTH FROM saledate) AS month_num,
       EXTRACT(YEAR FROM saledate) AS year_num,
       COUNT(DISTINCT saledate) AS dates_num,
       SUM(amt) / COUNT(DISTINCT saledate) AS avg_daily_rev
FROM trnsact
WHERE stype = 'P' AND saledate < '2005-08-01'
GROUP BY store, month_num, year_num
HAVING dates_num >= 20
ORDER BY year_num ASC, month_num ASC;


-- Exercise 5 --
-- What is the average daily revenue brought in by company’s stores in areas of high, medium, or low levels of high school education?
SELECT 
       CASE WHEN s.msa_high >= 50 AND s.msa_high <= 60 THEN 'low'
            WHEN s.msa_high >= 60.01 AND s.msa_high <= 70 THEN 'medium'
            WHEN s.msa_high >= 70.01 THEN 'high'
            END AS education_level,
       SUM(cleaned_data.total_rev)/SUM(cleaned_data.dates_num) AS avg_daily_revenue
FROM store_msa s 
 JOIN (SELECT store,
       EXTRACT(MONTH FROM saledate) AS month_num,
       EXTRACT(YEAR FROM saledate) AS year_num,
       COUNT(DISTINCT saledate) AS dates_num,
       SUM(amt) AS total_rev
       FROM trnsact
       WHERE stype = 'P' AND saledate < '2005-08-01'
       GROUP BY store, month_num, year_num
       HAVING dates_num >= 20) AS cleaned_data
  ON cleaned_data.store = s.store
GROUP BY education_level;


-- Exercise 6 --
-- Compare the average daily revenues of the stores with the highest median msa_income and the lowest median msa_income. 
-- In what city and state were these stores, and which store had a higher average daily revenue?
SELECT s.city, 
       s.state,
       s.store,
       SUM(cleaned_data.total_rev)/SUM(cleaned_data.dates_num) AS avg_daily_revenue
FROM store_msa s 
 JOIN (SELECT store,
       EXTRACT(MONTH FROM saledate) AS month_num,
       EXTRACT(YEAR FROM saledate) AS year_num,
       COUNT(DISTINCT saledate) AS dates_num,
       SUM(amt) AS total_rev
       FROM trnsact
       WHERE stype = 'P' AND saledate < '2005-08-01'
       GROUP BY store, month_num, year_num
       HAVING dates_num >= 20) AS cleaned_data
  ON cleaned_data.store = s.store
WHERE s.msa_income IN (
	(SELECT MAX(msa_income) FROM store_msa),
	(SELECT MIN(msa_income) FROM store_msa))
GROUP BY s.city, s.state;


-- Exercise 7 --
-- What is the brand of the sku with the greatest standard deviation in sprice?
-- Only examine skus that have been part of over 100 transactions. 

SELECT s.sku, s.brand, STDDEV_SAMP(t.sprice) AS std_sprice
FROM skuinfo s 
 JOIN trnsact t
   ON s.sku = t.sku 
WHERE t.stype='P' AND s.sku IS NOT NULL
GROUP BY s.brand, s.sku
HAVING COUNT(t.trannum) >= 100
ORDER BY std_sprice DESC; 


-- Exercise 8 --
-- Examine all the transactions for the sku with the greatest standard deviation in sprice, but only consider skus that are part of more than 100 transactions.

SELECT DISTINCT(s.sku) AS sku, s.brand, STDDEV_SAMP(t.sprice) AS std_sprice, COUNT(distinct(t.trannum)) AS distinct_transactions
FROM skuinfo s 
 JOIN trnsact t
  ON s.sku=t.sku
WHERE stype='P' AND s.sku IS NOT NULL
GROUP BY sku 
HAVING distinct_transactions >= 100
ORDER BY std_sprice DESC;


-- Exercise 9 --
-- What was the average daily revenue Dillard’s brought in during each month of the year?
SELECT month_num,
      SUM(dates_num) AS num_days_in_month,
      SUM(total_revenue)/SUM(dates_num) AS avg_monthly_rev
FROM (SELECT EXTRACT(MONTH FROM saledate) AS month_num,
              EXTRACT(YEAR FROM saledate) AS year_num,
              COUNT(DISTINCT saledate) AS dates_num,
              SUM(amt) AS total_revenue
      FROM trnsact
      WHERE stype = 'P' AND saledate < '2005-08-01'
      GROUP BY month_num, year_num
      HAVING dates_num >= 20
      ) AS d
GROUP BY month_num
ORDER BY avg_monthly_rev DESC;


-- Exercise 10 --
-- Which department, in which city and state of what store, had the greatest % increase in average daily sales revenue from Nov to Dec?


