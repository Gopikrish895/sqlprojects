/*Create table using the postgre sql command and importing files from the excel.
The outline of the table is created using the below commands*/
Drop table if exists retail_sales
create table retail_sales
		(
		transcation_id int primary key,
		sale_date DATE,
		sales_time time,
		customer_id int,
		age int,
		category varchar(15),
		quantity int,
		price_per_unit float,
		cogs float,
		total_sales float
		);

-- To check if all the columns names are correct/ appropriate in the table
select * from retail_sales
limit 5 

/* after executing the above code here we find there is a spelling error in 
the column name to correct it we are using the below code to alter only the 
name of the column */
--To rename a column
Alter table retail_sales
rename column quantiy to quantity;

-- Data Cleaning
--To find if all rows have transaction ids
select * from retail_sales
where transactions_id is null
/* Here we all rows in the transactions_id has a unique id*/

/*Since we have check for null values in all the columns, we will combine 
all the column names that is to be checked for null values in a single query*/
select * from retail_sales
where 
	transactions_id is null
	or
	sale_date is null
	or 
	sale_time is null
	or 
	customer_id is null
	or 
	gender is null
	or 
	quantity is null 
	or
	category is null 
	or
	cogs is null
	or 
	total_sale is null;
/*We have found few rows having no data. Since we cant find the data,its best 
to delete the rows found using the above query */
--To delete the records
Delete from retail_sales
where 
	transactions_id is null
	or
	sale_date is null
	or 
	sale_time is null
	or 
	customer_id is null
	or 
	gender is null
	or 
	quantity is null 
	or
	category is null 
	or
	cogs is null
	or 
	total_sale is null;
/*Using where condition in delete is necessary as this will specify the rows to
be deleted,otherwise the all records might be affected*/

--Data Exploration

-- How many sales we have ?
select count(*) as total_sales
from retail_sales

--how many unique customers we have ?
select count(distinct(customer_id))as different_customer from retail_sales 

--how many different category we have ?
select distinct(category)as different_category from retail_sales

--Data Analysis & Business key problems & Answes

--Q1.Write a SQL query to retrieve all columns for sales made on '2022-11-05
select *
from retail_sales
where sale_date = '2022-11-05'

/*Q2.Write a SQL query to retrieve all transactions where the category is 'Clothing' and
the quantity sold is more than 4 in the month of Nov-2022: */

select *
from retail_sales
where category ='Clothing' and 
quantity >= 4 and 
to_char(sale_date,'YYYY-MM') = '2022-11'
group by category;

/*Q3. Write a SQL query to calculate the total sales (total_sale) for each category.*/
select category, sum(total_sale) as net_sales, count(total_sale) as Orders
from retail_sales
group by category

/*Q4. Write a SQL query to find the average age of customers who purchased items 
from the 'Beauty' category. */
select round(avg(age),2) as avg_age
from retail_sales
where category= 'Beauty'

/*Q5.Write a SQL query to find all transactions where the total_sale 
is greater than 1000.*/
select *
from retail_sales
where total_sale >1000

/*Q6.Write a SQL query to find the total number of transactions (transaction_id)
made by each gender in each category. */
Select category,gender, count(transactions_id) as no_of_transcation
from retail_sales
group by category, gender
order by 1

/* Q7. Write a SQL query to calculate the average sale for each month. 
Find out best selling month in each year*/

Select year, month,avg_sales 
from
	(select
	extract(year from sale_date) as year,
	extract(month from sale_date) as month,
	avg(total_sale) as avg_sales,
	rank() over (partition by extract(year from sale_date) 
			order by avg(total_sale) desc) as ranking
	from retail_sales
	group by 1,2) as t1
where t1.ranking = 1;

/*Q8.Write a SQL query to find the top 5 customers based on 
the highest total sales */
select customer_id, sum(total_sale) as total_sales
from retail_sales
group by customer_id
order by 2 desc
limit 5;

/*Q9 Write a SQL query to find the number of unique customers 
who purchased items from each category.*/
select category, count(distinct (customer_id)) as Unique_customers
from retail_sales
group by category

/*Q10.Write a SQL query to create each shift and number of orders 
(Example Morning <12, Afternoon Between 12 & 17, Evening >17) */
with hourly_sales as
(
	select *,
		case 
			when extract(hour from sale_time) <12 then 'Morning'
			when extract(hour from sale_time) between 12 and 17 then 'afternoon'
			Else 'Evening'
		end as shift
	from retail_sales
  )
select shift, count(*) as total_orders
from hourly_sales
group by shift