# loading the table, if secure file priv is happening, go to connection, edit and go to advanced
# under advanced go to other and add OPT_LOCAL_INFILE=1
# Then reconnect to the database

# Inserting the data into the raw_data table
USE retail_analysis;
LOAD DATA LOCAL INFILE '/Users/ryan/Desktop/learning_python_sql/sql_projects/Retail Project/retail_sales.csv'
INTO TABLE raw_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

ALTER TABLE raw_data_copy 
CHANGE COLUMN quantiy quantity varchar(100);
SELECT * FROM raw_data;
# Making a copy of the raw data table
CREATE TABLE raw_data_copy as (
SELECT * FROM raw_data);
# Updating so that all empty strings and invalid values are converted to nulls
UPDATE raw_data_copy
SET age = NULL
WHERE age = '';
UPDATE raw_data_copy
SET sale_date = NULL
WHERE sale_date = '';
UPDATE raw_data_copy
SET sale_time = NULL
WHERE sale_time = '';
SET SQL_SAFE_UPDATES = 0;

UPDATE raw_data_copy
SET price_per_unit = NULL
WHERE price_per_unit = '';

UPDATE raw_data_copy
# cogs = COALESCE(NULLIF(cogs, ''), 0.0),
    SET total_sale = COALESCE(NULLIF(TRIM(REPLACE(total_sale,'$','')), ''), 0);
# first fix the datatypes
ALTER TABLE raw_data_copy 
MODIFY COLUMN transactions_id INT,
MODIFY COLUMN sale_date DATE,
MODIFY COLUMN sale_time TIME,
MODIFY COLUMN customer_id INT,
MODIFY COLUMN age INT,
#MODIFY COLUMN quantity INT,
MODIFY COLUMN price_per_unit INT,
MODIFY COLUMN cogs DECIMAL(10,3),
MODIFY COLUMN total_sale int;
DESCRIBE raw_data_copy;




