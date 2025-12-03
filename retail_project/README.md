# Retail Sales Analysis SQL Project

## Objectives
1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Dataset 
- **Source:** [Retail Dataset](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)  
- **Key Fields:** transactions_id, customer_id,category, price_per_unit, quantity, total_sale

## Project Structure

## 1) Database Setup

- **Database Creation**: The project starts by creating a database named `retail_analysis`.
- **Table Creation**: A table named `raw_data` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.
  -  First the table is created setting all of the columns to varchar(100) before changing the datatype for speed and simplicity.
- ** Datatypes adjusted and data cleaning**

```sql
# Creating the database

CREATE DATABASE retail_analysis

# Creating the table

CREATE TABLE raw_data(
transactions_id varchar(100),
sale_date varchar(100),
sale_time varchar(100),
customer_id varchar(100),
gender varchar(100),
age varchar(100),
category varchar(100),
quantiy varchar(100),
price_per_unit varchar(100),
cogs varchar(100),
total_sale vachar(100)
);
USE retail_analysis;
LOAD DATA LOCAL INFILE '/Users/ryan/Desktop/learning_python_sql/sql_projects/Retail Project/retail_sales.csv'
INTO TABLE raw_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- checking for nulls after cleaning
SELECT 
    SUM(CASE WHEN transactions_id IS NULL THEN 1 ELSE 0 END) AS null_values
FROM raw_data_copy; -- NO NULL VALUES IN transaction id
SELECT 
    SUM(CASE WHEN sale_date IS NULL THEN 1 ELSE 0 END) AS null_values
FROM raw_data_copy; -- no null values in sale date
SELECT 
    SUM(CASE WHEN sale_time IS NULL THEN 1 ELSE 0 END) AS null_values
FROM raw_data_copy; -- no null values in sale time
SELECT 
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_values
FROM raw_data_copy; -- no null values in customer id
SELECT 
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS null_values
FROM raw_data_copy; -- this does have null values

SELECT 
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_values
FROM raw_data_copy; -- no null values in quantity
SELECT 
    SUM(CASE WHEN price_per_unit IS NULL THEN 1 ELSE 0 END) AS null_values
FROM raw_data_copy; -- 3 nulls in price per unit
SELECT 
    SUM(CASE WHEN total_sale IS NULL THEN 1 ELSE 0 END) AS null_values
FROM raw_data_copy; -- no null values in total sale
SELECT 
    SUM(CASE WHEN cogs IS NULL THEN 1 ELSE 0 END) AS null_values
FROM raw_data_copy; -- no null values in cogs

SELECT *
FROM raw_data_copy
WHERE age IS null -- only 10 rows have nulls so we dont have to remove them

SELECT *
FROM raw_data_copy
WHERE price_per_unit IS null; -- we can calculate price per unit using total sale and quantity

DELETE FROM raw_data_copy
WHERE price_per_unit IS NULL;


-- setting not null constraints and check constraints
ALTER TABLE raw_data_copy
ADD CONSTRAINT chk_age CHECK (age >= 0 AND age <= 120); -- 3 rows were removed
ALTER TABLE raw_data_copy
MODIFY COLUMN age INT NOT NULL;
ALTER TABLE raw_data_copy
MODIFY COLUMN price_per_unit INT NOT NULL;
ALTER TABLE raw_data_copy
ADD CONSTRAINT chk_quantity CHECK (quantity > 0);
ALTER TABLE raw_data_copy
MODIFY COLUMN quantity INT NOT NULL;
ALTER TABLE raw_data_copy
MODIFY COLUMN transactions_id INT PRIMARY KEY NOT NULL;
ALTER TABLE raw_data_copy
MODIFY COLUMN sale_date DATE NOT NULL;
ALTER TABLE raw_data_copy
MODIFY COLUMN sale_time TIME NOT NULL;
ALTER TABLE raw_data_copy
MODIFY COLUMN customer_id INT NOT NULL;
DESCRIBE raw_data_copy;
```

## 2) Data Exploration

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.

``` sql
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

```

## 3) Data Analysis and Findings

``` sql


-- 1): Retrieve all columns for sales made on '2022-11-05'

SELECT * FROM cleaned_data WHERE sale_date = '2022-11-05';

--2) Retrieve all transactions where the category is clothing
-- and the total sale is more than 50 in the month of Nov 2022

SELECT * 
FROM cleaned_data
WHERE category ='clothing' AND total_sale >50 AND sale_date
BETWEEN '2022-11-01' AND '2022-11-30'; -- 41 sales returned

-- Calculate total sales for each category
SELECT 
    category,
    SUM(total_sale) total_sales,
    COUNT(*) total_orders
FROM cleaned_data
GROUP BY category
ORDER BY total_sales desc;

-- Find the avg age of customers who purchased items from the beauty category

SELECT AVG(age) AvgAge FROM cleaned_data WHERE category='Beauty'; --40.42

-- Find all transactions where total_sale is greater than 1000

SELECT * FROM cleaned_data 
WHERE total_sale >1000; -- 306 transactions

-- Find total transactions made by each cateogry for each gender

SELECT
category,
gender,
COUNT(*) total_transactions
FROM cleaned_data
GROUP BY category, gender
ORDER BY category, total_transactions;

-- Write a query to calcualte the avg sale of each month. 
-- Find out best selling month in each year

SELECT * FROM cleaned_data;
SELECT 
    MONTHNAME(sale_date) AS SaleMonth,
    AVG(total_sale) Avg_sales
FROM cleaned_data
GROUP BY MONTHNAME(sale_date), MONTH(sale_date)
ORDER BY MONTH(sale_date) asc;
SELECT 
OrderMonth,
OrderYear,
TotalSales
FROM (
SELECT
    YEAR(sale_date) OrderYear,
    MONTHNAME(sale_date) OrderMonth,
    SUM(total_sale) TotalSales,
    RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY sum(total_sale) desc) MonthRank
FROM cleaned_data
GROUP BY YEAR(sale_date),month(sale_date), monthname(sale_date)
) sub
WHERE MonthRank <=1;

-- Write a sql query fo ind the top 5 customers based on the highest total sales
USE retail_analysis;

SELECT
    customer_id,
    TotalSales,
    OrderRank
FROM (
SELECT
    customer_id,
    SUM(total_sale) TotalSales,
    RANK() OVER( ORDER BY SUM(total_sale) desc) OrderRank
FROM cleaned_data
group by customer_id
) sub
WHERE OrderRank <=5
ORDER BY OrderRank ASC;


-- Find the number of unique customers who purchased items from each category
SELECT  
    category,
    COUNT(DISTINCT customer_id) CustomerCount
FROM cleaned_data
GROUP BY category
ORDER BY CustomerCount DESC;

-- Create a shift and numer of orders (morning <=12, afternoon between 
-- 12 and 17, Evening >17)
SELECT * FROM cleaned_data;
SELECT 
    COUNT(transactions_id) NumberOfOrders,
    sale_window
FROM (

SELECT
    transactions_id,
    CASE 
        WHEN HOUR(sale_time) BETWEEN 0 AND 11 THEN 'Morning'
        WHEN HOUR(sale_time) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN hour(sale_time) BETWEEN 17 AND 23 THEN 'Evening'
     ELSE 'Unknown'
END AS sale_window
FROM cleaned_data
) sub
GROUP BY sale_window;


```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.





