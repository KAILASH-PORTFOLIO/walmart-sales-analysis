												-- CREATE TABLE --

CREATE TABLE sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    vat DECIMAL(10,2) NOT NULL,
    total DECIMAL(12,4) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct DECIMAL(5,2),
    gross_income DECIMAL(12,4),
    rating DECIMAL(3,1)
);

select * from sales
limit 5;



												-- FEATURE ENGINEERING --

												

1. Time_of_day

select time,
(CASE
		when 'time' between '00:00:00' AND '12:00:00' then 'Morning'
		when 'time' between '12:01:00' AND '16:00:00' then 'Afternoon'
  else 'Evening'
end) as time_of_day
FROM sales;

alter table sales add column time_of_day varchar(20);

update sales
set time_of_day = (
case
		when 'time' between '00:00:00' AND '12:00:00' then 'Morning'
		when 'time' between '12:01:00' AND '16:00:00' then 'Afternoon'
  else 'Evening'
end
);


2.Day_name

select date,
To_CHAR(date,'day') as day_name
from sales;

alter table sales add column day_name varchar(10);

UPDATE sales
SET day_name = TRIM(TO_CHAR(date, 'Day'));


3.Month_name

select date,
To_CHAR(date,'month') as month_name
from sales;

alter table sales add column month_name varchar(10);

UPDATE sales
SET month_name = TRIM(TO_CHAR(date, 'month'));


												--EXPLORATORY DATA ANALYSIS--


-- Generic Questions --

-- 1.How many distinct cities are present in the dataset?
select distinct city
from sales;

-- 2.In which city is each branch situated?
select distinct city,branch
from sales
order by city, branch

--Product analysis--
-- 1.How many distinct product lines are there in the dataset?
select distinct(product_line)
from sales;

-- 2.What is the most common payment method?
select payment, count(payment) as payment_method
from sales
group by payment
order by payment_method desc
limit 1;

-- 3.What is the most selling product line?
select product_line, count(product_line) as most_selling_product
from sales
group by product_line
order by most_selling_product desc
limit 1;

-- 4.What is the total revenue by month?
select month_name, sum(total) as total_revenue
from sales
group by month_name
order by total_revenue desc;

-- 5.Which month recorded the highest Cost of Goods Sold (COGS)?
select month_name, sum(cogs) as highest_cogs
from sales
group by month_name
order by highest_cogs desc;

-- 6.Which product line generated the highest revenue?
select product_line, sum(total) as highest_revenue
from sales
group by product_line
order by highest_revenue desc
limit 1;

-- 7.Which city has the highest revenue?
select city, sum(total) as highest_revenue
from sales
group by city
order by highest_revenue desc
limit 1;

select * from sales
limit 5

-- 8.Which product line incurred the highest VAT?
select product_line, sum(vat) as highest_vat
from sales
group by product_line
order by highest_vat desc
limit 1;

-- 9.Retrieve each product line and add a column product_category, indicating 'Good' or 'Bad,'based on whether its sales are above the average.
alter table sales add column product_category varchar(20);

update sales
set product_category =
( case
	when total >= (
	select avg(total) from sales) then 'Good'
	else 'bad'
end );

select * from sales
limit 5;

-- 10.Which branch sold more products than average product sold?
select branch, sum(quantity) as quantity
from sales
group by branch
having sum(quantity)> avg(quantity)
order by quantity desc
limit 1;

-- 11.What is the most common product line by gender?
select product_line, gender, count(gender) as total_count
from sales
group by product_line, gender
order by total_count desc;

-- 12.What is the average rating of each product line?
select product_line, round(avg(rating),2) as average_rating
from sales
group by product_line
order by average_rating desc

																-- SALES ANALYSIS --
-- 1.Number of sales made in each time of the day per weekday
select day_name, time_of_day, count(invoice_id) as total_sales
from sales
group by day_name, time_of_day
having day_name not in ('Sunday','Saturday');

-- 2.Identify the customer type that generates the highest revenue.
select customer_type, round(sum(total),2) as total_revenue
from sales
group by customer_type
order by total_revenue desc
limit 1;

-- 3.Which city has the largest tax percent/ VAT (Value Added Tax)?
select city, sum(vat) as total_vat
from sales
group by city
order by total_vat desc
limit 1;

-- 4.Which customer type pays the most in VAT?
select customer_type, sum(vat) as total_vat
from sales
group by customer_type
order by total_vat desc
limit 1;

																	-- CUSTOMER ANALYSIS --

-- 1.How many unique customer types does the data have?
select distinct customer_type
from sales;

-- 2.How many unique payment methods does the data have?
select distinct payment
from sales;

-- 3.Which is the most common customer type?
select customer_type, count(customer_type) as common_customer
from sales
group by customer_type
order by common_customer desc
limit 1;

-- 4.Which customer type buys the most?
select customer_type, sum(total) as most_buyer
from sales
group by customer_type
order by most_buyer desc
limit 1;

-- 5.What is the gender of most of the customers?
select gender, count(*) as all_gender
from sales
group by gender
order by all_gender desc
limit 1;

-- 6.What is the gender distribution per branch?
select gender, branch, count(branch) as gender_p_branch
from sales
group by branch,gender
order by branch asc

-- 7.Which time of the day do customers give most ratings?
select time_of_day, sum(rating) as most_rating
from sales
group by time_of_day
order by most_rating desc
limit 1;

-- 8.Which time of the day do customers give most ratings per branch?
select time_of_day, branch, avg(rating) as avg_rating
from sales
group by time_of_day, branch
order by avg_rating desc;

-- 9.Which day of the week has the best avg ratings?
select day_name, avg(rating) as avg_rating
from sales
group by day_name
order by avg_rating desc
limit 1;

-- 10.Which day of the week has the best average ratings per branch?
select day_name, branch, avg(rating) as avg_rating
from sales
group by day_name, branch
order by avg_rating desc
limit 1;

