SELECT * FROM cleaned_data limit 10;

ALTER TABLE raw_data_copy RENAME TO cleaned_data;   

-- Finding the top 5 customers in terms of total sales
SELECT 
    customer_id,
    SUM(total_sale) AS total_sales_amount
FROM cleaned_data
GROUP BY customer_id
ORDER BY total_sales_amount DESC
LIMIT 5;

-- Looking at sales trends over category
SELECT
    category,
    SUM(quantity) AS total_quantity_sold,
    SUM(total_sale) AS total_sales_amount
FROM cleaned_data
GROUP BY category
ORDER BY total_sales_amount DESC;   

USE retail_analysis;
-- How many total transactions did we have
select count(*) from cleaned_data; -- 1997 total transactions

-- How many customers do we have
SELECT COUNT(DISTINCT customer_id) FROM cleaned_data; -- 155 unique customers


