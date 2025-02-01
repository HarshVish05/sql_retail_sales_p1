--  SQL Retail Sales Analysis ---
create database sales_p1;

-- create table
Drop table if exists retail_sales;
create table retail_sales (
	transactions_id int primary key,
    sale_date date,
    sale_time time,
    customer_id int,
    gender varchar(15),
    age int,
    category varchar(20),
    quantity int,
	price_per_unit float,
    cogs float,
    total_sale float
); 

-- did this whole thing to import the data 
-- modify the col to varchar so that the data can be imported
alter table retail_sales
modify column sale_time varchar(50);
-- first turn off the safe mode
SET SQL_SAFE_UPDATES = 0;
-- second run the query to replace . with :
update retail_sales
set sale_time = replace(sale_time, '.', ':');
-- third turn on the safe mode
SET SQL_SAFE_UPDATES = 0;
-- fourth modify the col to time format
alter table retail_sales
modify column sale_time time;

--  DATA CLEANING --	
-- will give me total records 
select count(*) from sales_p1.retail_sales;

select * from retail_sales
where 
quantity is null or
price_per_unit is null or
gender is null;

-- deleting rows where data has null values
delete from retail_sales
where 
quantity is null or
price_per_unit is null or
gender is null;


-- DATA EXPLORATION --
-- How many sales or records we have
select count(*) as total_sales from retail_sales;

-- How many customers are there ( here we have used distinct to make sure the customers are unique)
select count(distinct customer_id) Total_customers from retail_sales;

-- Get all distinct categories
select distinct category as categories from retail_sales;

-- DATA ANALYSIS AND KEY BUSINESS PROBLEMS

-- Q1) Write a SQL query to retrieve all columns for sales made on '2022-11-05'
select * from retail_sales
where sale_date = '2022-11-05';

-- Q2) Write a SQL query to retrive all the transactions where the category is 'clothing' and the quantity sold is more than 3 
--     in the month of Nov-22
select *
from retail_sales
where category = 'Clothing' and 
	  sale_date like '2022-11-%%' and
      quantity > 3;

-- Q3) Write a SQL query to calculate the total sales for each category
select distinct category, sum(total_sale) as Total_sales
from retail_sales
group by category;

-- Q4) Write a SQL query to find the average age of customers who purchased items from 'Beauty' category
select category, round(avg(age), 2) as Average_age
from retail_sales
where category = 'Beauty';

--  Q5) Write a SQL query to find all transactions where the total sale is greater than 1000
select * from retail_sales
where total_sale > 1000;

-- Q6) Write the total no of transactions made by each gender in each category
select category, gender, count(transactions_id) as Total_transaction
from retail_sales
group by category, gender;

--  Q7) Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
select * from 
(
select year(sale_date) as year,
		month(sale_date) as month,
        avg(total_sale) as average,
        rank() over(partition by year(sale_date) order by avg(total_sale) desc ) as rank_sale
from retail_sales
group by year, month
order by  year, average desc
) as t1
where rank_sale = 1;

--  Q8) Write a SQL query to find the top 5 customers based on the highest total sales
select customer_id, sum(total_sale), rank() over(order by sum(total_sale) desc)
from retail_sales
group  by customer_id limit 5;

-- or you can use another method for above query
select customer_id, sum(total_sale) as total_sale
from retail_sales
group  by customer_id order by total_sale desc limit 5;

--  Q9) Write a SQL query to find the no of unique customers who purchased items from each category
select distinct category, count(distinct customer_id)
from retail_sales
group by category;

--  Q10) Write a SQL query to create each shift and no of orders ( example morning < 12, afternoon b/w 12 & 17, evening > 17 )
select 
   case
		when hour(sale_time) < 12 then 'Morning'
        when hour(sale_time) >= 12  and  hour(sale_time) <= 17 then 'Afternoon'
        else 'Evening'
	end as Shift,
    count(*) as Number_of_orders
from retail_sales
group by Shift
ORDER BY FIELD(shift, 'Morning', 'Afternoon', 'Evening');
