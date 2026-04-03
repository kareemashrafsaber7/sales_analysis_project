📊 Sales Analytics SQL Project

A SQL Server database project for simulating and analyzing an e-commerce sales system.

This project includes:

Database schema design
Indexes for optimization
Seed/sample business data
Analytical SQL queries
Views for reporting
Foreign key cascading rules
Revenue, customer, product, and regional performance analysis

It is a great practice project for:

SQL fundamentals
Database design
Reporting queries
Window functions
CTEs
Views
Query optimization basics
📁 Project Overview

This database models a small sales/order management system with 4 core tables:

customers
products
orders
order_items

It also includes:

useful indexes
sample seed data
reusable views
business-style analytics queries
🧱 Database Schema
1) Customers

Stores customer information.

Column	Type	Description
customer_id	INT	Primary Key
name	NVARCHAR(100)	Customer full name
email	NVARCHAR(150)	Unique email
created_at	DATE	Account creation date
region	NVARCHAR(50)	Customer region
2) Products

Stores available products.

Column	Type	Description
product_id	INT	Primary Key
name	NVARCHAR(100)	Product name
category	NVARCHAR(50)	Product category
price	DECIMAL(10,2)	Product price
3) Orders

Stores customer orders.

Column	Type	Description
order_id	INT	Primary Key
customer_id	INT	Foreign Key → customers
order_date	DATE	Date of order
status	NVARCHAR(20)	Order status (shipped, delivered, cancelled)
4) Order Items

Stores products inside each order.

Column	Type	Description
order_item_id	INT	Primary Key
order_id	INT	Foreign Key → orders
product_id	INT	Foreign Key → products
quantity	INT	Quantity ordered
unit_price	DECIMAL(10,2)	Price at order time
discount_rate	DECIMAL(4,3)	Discount applied
🗂️ Entity Relationship Summary
customers (1) ───────< orders (1) ───────< order_items >─────── (1) products
One customer can have many orders
One order can have many order items
One product can appear in many order items
⚡ Indexes Used

To improve query performance, the following indexes were created:

CREATE INDEX idx_orders_customer   ON orders(customer_id);
CREATE INDEX idx_orders_date       ON orders(order_date);
CREATE INDEX idx_orders_status     ON orders(status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_prod  ON order_items(product_id);
CREATE NONCLUSTERED INDEX ind11    ON customers(name);
Why these indexes?

They help speed up:

filtering by customer
searching by order date
filtering by order status
joining orders and order items
product-based analytics
searching customers by name
🌱 Seed Data

The project includes realistic sample data:

10 customers
12 products
32 orders
multiple order items
discounted sales
cancelled orders
seasonal spikes in November and December
14 months of sales history

This makes the project useful for practicing real-world analytics queries.

📈 Business Logic
Revenue Formula

Revenue is calculated as:

quantity * unit_price * (1 - discount_rate)
Completed Orders

For analytics, completed orders are generally considered:

status IN ('shipped', 'delivered')

Cancelled orders are excluded from most reporting queries.

👁️ Views Included
1) vw_monthly_revenue

Shows monthly revenue grouped by year and month.

create or alter view vw_monthly_revenue
as
select year(o.order_date) as 'Order Year' ,
       month(o.order_date) as 'Order Month' ,
       sum(quantity * unit_price *(1-discount_rate)) as 'Revenue'
from orders o
join order_items oi on o.order_id = oi.order_id
where o.status not in ('cancelled')
group by month(o.order_date), year(o.order_date)
Purpose

Useful for:

monthly sales reporting
trend analysis
dashboard visuals
2) vw_active_customers_90d

Shows customers who placed a non-cancelled order in the last 90 days relative to the latest order date in the dataset.

create or alter view vw_active_customers_90d
as
select o.customer_id,
       name,
       max(order_date) as 'Latest order'
from customers c
join orders o on c.customer_id = o.customer_id
where order_date > dateadd(day, -90, (select max(order_date) from orders))
  and o.status <> 'cancelled'
group by o.customer_id, name
Purpose

Useful for:

customer retention analysis
identifying recently engaged customers
CRM targeting
3) vw_top_selling_products

Shows products whose sales count is above the average product sales count.

create or alter view vw_top_selling_products
as
select oi.product_id,
       name,
       count(oi.product_id) as 'Sold units'
from products p
join order_items oi on p.product_id = oi.product_id
group by oi.product_id, name
having count(oi.product_id) > (
    select avg(ordercount)
    from (
        select count(*) as ordercount
        from order_items
        group by product_id
    ) as temp
)
Purpose

Useful for:

identifying strong-performing products
inventory insights
sales ranking
🔍 Analytical Queries Included
1) High-Value Customers

Identifies customers whose total spending is above average.

select o.customer_id,
       name,
       sum(quantity * unit_price * (1 - oi.discount_rate)) as 'Total spendings'
from customers c
join orders o on c.customer_id = o.customer_id
join order_items oi on oi.order_id = o.order_id
group by o.customer_id, name
having sum(quantity * unit_price * (1 - oi.discount_rate)) >
       (select avg(quantity * unit_price *(1-discount_rate)) from order_items)
Skills used
joins
aggregation
nested subquery
HAVING clause
2) Monthly Revenue with Growth

Tracks monthly revenue and compares it with previous periods using a window function.

select month(order_date) as 'Month',
       year(order_date) as 'Year',
       sum(quantity * unit_price * (1-discount_rate)) as 'Revenue', 
       lag(sum(quantity * unit_price * (1-discount_rate))) over (order by year(order_date)) as 'prev_month_revenue',
       sum(quantity * unit_price * (1-discount_rate)) -
       lag(sum(quantity * unit_price * (1-discount_rate))) over (order by year(order_date)) as 'mon_growth_pct'
from orders o
join order_items oi on o.order_id = oi.order_id
group by month(order_date), year(order_date)
Skills used
aggregation
LAG()
window functions
time-based analysis

⚠️ Note: This query currently orders only by year(order_date).
For fully accurate month-over-month analysis, it should order by year and month together.

Recommended improvement:

order by year(order_date), month(order_date)
3) Category Performance

Measures product category performance.

select category,
       count(distinct order_id) as 'Orders',
       sum(quantity) as 'items',
       sum(quantity * unit_price * (1-discount_rate)) as 'revenue',
       sum(quantity * unit_price * (1-discount_rate)) / count(distinct order_id) as 'avg_order_value'
from products p
join order_items oi on oi.product_id = p.product_id
group by category
Metrics included
number of orders
total items sold
total revenue
average order value
4) Regional Leaderboard

Ranks regions by revenue and shows the top-performing product in each region.

with RegionProductRevenue as (
    select c.region,
           p.name as product_name,
           sum(oi.quantity * oi.unit_price * (1 - oi.discount_rate)) as revenue 
    from orders o
    join order_items oi on o.order_id = oi.order_id
    join customers c on o.customer_id = c.customer_id 
    join products p on oi.product_id = p.product_id
    where o.status not in ('cancelled')
    group by c.region, p.name
),
RankedProducts as (
    select *,
           row_number() over (partition by region order by revenue desc) as rn
    from RegionProductRevenue
),
RegionStats as (
    select c.region,
           count(distinct c.customer_id) as customers,
           sum(oi.quantity * oi.unit_price * (1 - oi.discount_rate)) as revenue
    from orders o
    join order_items oi on o.order_id = oi.order_id
    join customers c on o.customer_id = c.customer_id
    where o.status not in ('cancelled')
    group by c.region
)
select rs.region,
       rs.customers,
       rs.revenue,
       rp.product_name as top_product_by_revenue
from RegionStats rs
join RankedProducts rp on rs.region = rp.region and rp.rn = 1
order by rs.revenue desc;
Skills used
Common Table Expressions (CTEs)
ROW_NUMBER()
partitioning
ranking
regional sales analytics
🔐 Referential Integrity & Cascading

The project updates foreign keys to support:

ON DELETE CASCADE
ON UPDATE CASCADE

This ensures that related rows are automatically updated or deleted to preserve referential integrity.

Applied Cascades
Orders → Customers
alter table orders
add constraint ord_cust_fk
foreign key (customer_id) references customers(customer_id)
on delete cascade
on update cascade
Order Items → Orders
alter table order_items
add constraint ord_item_ord_fk
foreign key (order_id) references orders(order_id)
on update cascade
on delete cascade
Order Items → Products
alter table order_items
add constraint ord_item_prod_fk
foreign key (product_id) references products(product_id)
on update cascade
on delete cascade
Why this matters

If a parent record is deleted or updated:

related child rows stay consistent
orphaned rows are prevented
database integrity is maintained automatically
🛠️ Technologies Used
SQL Server
T-SQL
Views
Indexes
CTEs
Window Functions
Nested Queries
🚀 How to Run
1) Create a new database

Example:

CREATE DATABASE SalesAnalyticsDB;
GO
USE SalesAnalyticsDB;
GO
2) Run the SQL script in order

Execute:

Table creation
Index creation
Seed inserts
Views
Analytical queries
Constraint updates
3) Query the views
SELECT * FROM vw_monthly_revenue;
SELECT * FROM vw_active_customers_90d;
SELECT * FROM vw_top_selling_products;
📚 Learning Outcomes

This project demonstrates practical SQL skills such as:

designing relational schemas
defining primary and foreign keys
creating indexes
inserting structured seed data
writing reusable views
using subqueries
writing CTEs
applying window functions
performing business analytics in SQL
