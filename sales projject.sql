
CREATE TABLE customers (
    customer_id INT           IDENTITY(1,1) PRIMARY KEY,
    name        NVARCHAR(100) NOT NULL,
    email       NVARCHAR(150) NOT NULL UNIQUE,
    created_at  DATE          NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    region      NVARCHAR(50)  NOT NULL
);

CREATE TABLE products (
    product_id INT            IDENTITY(1,1) PRIMARY KEY,
    name       NVARCHAR(100)  NOT NULL,
    category   NVARCHAR(50)   NOT NULL,
    price      DECIMAL(10,2)  NOT NULL
);

CREATE TABLE orders (
    order_id    INT           IDENTITY(1,1) PRIMARY KEY,
    customer_id INT           NOT NULL REFERENCES customers(customer_id),
    order_date  DATE          NOT NULL,
    status      NVARCHAR(20)  NOT NULL   -- 'shipped','delivered','cancelled'
);

CREATE TABLE order_items (
    order_item_id INT           IDENTITY(1,1) PRIMARY KEY,
    order_id      INT           NOT NULL REFERENCES orders(order_id),
    product_id    INT           NOT NULL REFERENCES products(product_id),
    quantity      INT           NOT NULL DEFAULT 1,
    unit_price    DECIMAL(10,2) NOT NULL,
    discount_rate DECIMAL(4,3)  NOT NULL DEFAULT 0.0  -- e.g. 0.10 = 10%
);
GO
 
--   3: INDEXES
CREATE INDEX idx_orders_customer   ON orders(customer_id);
CREATE INDEX idx_orders_date       ON orders(order_date);
CREATE INDEX idx_orders_status     ON orders(status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_prod  ON order_items(product_id);
GO
 
--   4: SEED DATA
--   10 customers, 12 products, 32 orders across 14 months
--   Seasonal spikes in Nov/Dec, discounts, one cancelled order
--   Revenue = quantity * unit_price * (1 - discount_rate)
--   Completed = status IN ('shipped','delivered')
 

INSERT INTO customers (name, email, created_at, region) VALUES
  ('Alice Martin',  'alice@example.com',  '2023-01-10', 'North'),
  ('Bob Hassan',    'bob@example.com',    '2023-02-15', 'South'),
  ('Carol Nour',    'carol@example.com',  '2023-03-20', 'East'),
  ('David Kim',     'david@example.com',  '2023-04-05', 'West'),
  ('Eva Petrov',    'eva@example.com',    '2023-05-18', 'North'),
  ('Frank Diaz',    'frank@example.com',  '2023-06-22', 'South'),
  ('Grace Liu',     'grace@example.com',  '2023-07-30', 'East'),
  ('Hana Yilmaz',   'hana@example.com',   '2023-08-14', 'West'),
  ('Ivan Osei',     'ivan@example.com',   '2023-09-09', 'North'),
  ('Julia Brown',   'julia@example.com',  '2023-10-01', 'South');

INSERT INTO products (name, category, price) VALUES
  ('Laptop Pro 15',      'Electronics',  1200.00),
  ('Wireless Mouse',     'Electronics',    25.00),
  ('USB-C Hub',          'Electronics',    45.00),
  ('Office Chair',       'Furniture',     320.00),
  ('Standing Desk',      'Furniture',     550.00),
  ('Notebook A5',        'Stationery',      5.00),
  ('Ballpoint Pens x10', 'Stationery',      8.00),
  ('Python Book',        'Books',          40.00),
  ('SQL Mastery',        'Books',          35.00),
  ('Headphones BT',      'Electronics',   150.00),
  ('Monitor 27"',        'Electronics',   400.00),
  ('Ergonomic Keyboard', 'Electronics',    90.00);

INSERT INTO orders (customer_id, order_date, status) VALUES
  (1,  '2024-01-05', 'delivered'),   -- 1
  (2,  '2024-01-18', 'shipped'),     -- 2
  (3,  '2024-02-02', 'delivered'),   -- 3
  (4,  '2024-02-20', 'delivered'),   -- 4
  (5,  '2024-03-08', 'shipped'),     -- 5
  (6,  '2024-03-25', 'cancelled'),   -- 6  cancelled order
  (7,  '2024-04-10', 'delivered'),   -- 7
  (8,  '2024-04-28', 'delivered'),   -- 8
  (1,  '2024-05-03', 'shipped'),     -- 9
  (9,  '2024-05-19', 'delivered'),   -- 10
  (2,  '2024-06-07', 'delivered'),   -- 11
  (10, '2024-06-22', 'shipped'),     -- 12
  (3,  '2024-07-14', 'delivered'),   -- 13
  (4,  '2024-07-29', 'shipped'),     -- 14
  (5,  '2024-08-05', 'delivered'),   -- 15
  (6,  '2024-08-20', 'delivered'),   -- 16
  (7,  '2024-09-11', 'shipped'),     -- 17
  (8,  '2024-09-30', 'delivered'),   -- 18
  (9,  '2024-10-06', 'delivered'),   -- 19
  (10, '2024-10-21', 'shipped'),     -- 20
  (1,  '2024-11-01', 'delivered'),   -- 21  (November spike)
  (2,  '2024-11-05', 'delivered'),   -- 22
  (3,  '2024-11-10', 'shipped'),     -- 23
  (4,  '2024-11-15', 'delivered'),   -- 24
  (5,  '2024-11-22', 'delivered'),   -- 25
  (6,  '2024-12-01', 'delivered'),   -- 26  (December spike)
  (7,  '2024-12-05', 'shipped'),     -- 27
  (8,  '2024-12-10', 'delivered'),   -- 28
  (9,  '2024-12-18', 'delivered'),   -- 29
  (10, '2024-12-26', 'shipped'),     -- 30
  (1,  '2025-01-08', 'delivered'),   -- 31  (14th month)
  (2,  '2025-01-20', 'shipped');     -- 32

INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_rate) VALUES
  (1,  1, 1, 1200.00, 0.000),
  (1,  2, 1,   25.00, 0.000),
  (2,  3, 2,   45.00, 0.050),
  (3,  4, 1,  320.00, 0.100),
  (4,  5, 1,  550.00, 0.000),
  (5,  6, 5,    5.00, 0.000),
  (5,  7, 2,    8.00, 0.000),
  (6,  8, 1,   40.00, 0.000),
  (7,  9, 1,   35.00, 0.000),
  (7, 10, 1,  150.00, 0.000),
  (8, 11, 1,  400.00, 0.050),
  (9, 12, 1,   90.00, 0.000),
  (10, 1, 1, 1200.00, 0.150),
  (11, 2, 3,   25.00, 0.000),
  (11, 3, 1,   45.00, 0.000),
  (12, 4, 1,  320.00, 0.000),
  (13, 5, 1,  550.00, 0.100),
  (14, 6,10,    5.00, 0.000),
  (14, 7, 5,    8.00, 0.000),
  (15, 8, 2,   40.00, 0.050),
  (16, 9, 1,   35.00, 0.000),
  (16,10, 1,  150.00, 0.100),
  (17,11, 2,  400.00, 0.000),
  (18,12, 1,   90.00, 0.050),
  (19, 1, 1, 1200.00, 0.200),
  (20, 2, 4,   25.00, 0.000),
  (21, 1, 1, 1200.00, 0.100),
  (21,11, 1,  400.00, 0.100),
  (22, 5, 1,  550.00, 0.000),
  (22,12, 2,   90.00, 0.050),
  (23,10, 2,  150.00, 0.000),
  (23, 4, 1,  320.00, 0.050),
  (24, 9, 2,   35.00, 0.000),
  (24, 8, 3,   40.00, 0.050),
  (25, 1, 1, 1200.00, 0.000),
  (25, 3, 3,   45.00, 0.000),
  (26, 1, 2, 1200.00, 0.150),
  (26,10, 1,  150.00, 0.000),
  (27, 5, 1,  550.00, 0.050),
  (27,11, 1,  400.00, 0.100),
  (28, 4, 2,  320.00, 0.000),
  (28,12, 1,   90.00, 0.000),
  (29, 1, 1, 1200.00, 0.100),
  (29, 2, 5,   25.00, 0.000),
  (30, 9, 3,   35.00, 0.000),
  (30, 8, 4,   40.00, 0.050),
  (31, 1, 1, 1200.00, 0.050),
  (32, 3, 2,   45.00, 0.000);

--create a view to calculate monthly revenue
create or alter view vw_monthly_revenue
as
select year(o.order_date) as 'Order Year' , month(o.order_date) as 'Order Month' , sum(quantity * unit_price *(1-discount_rate)) as 'Revenue'
from orders o join order_items oi on o.order_id = oi.order_id
where o.status not in ('cancelled')
group by month(o.order_date) , year(o.order_date)

select * from vw_monthly_revenue

--create a view to show active customers in the last 90 days
create or alter view vw_active_customers_90d
as
select o.customer_id, name, max(order_date) as 'Latest order'
from customers c join orders o on c.customer_id = o.customer_id
where order_date > dateadd(day, -90, (select max(order_date) from orders)) and o.status <> 'cancelled'
group by o.customer_id, name

select * from vw_active_customers_90d

--create a view to show the top selling products
create or alter view vw_top_selling_products
as
select oi.product_id, name , count(oi.product_id) as 'Sold units'
from products p join order_items oi
on p.product_id = oi.product_id
group by oi.product_id, name
having count(oi.product_id) > (select avg(ordercount) from (select count(*) as ordercount from order_items group by product_id) as temp)

select * from vw_top_selling_products

--Nested query for high-value customers

select o.customer_id, name, sum(quantity * unit_price * (1 - oi.discount_rate)) as 'Total spendings'
from customers c join orders o on c.customer_id = o.customer_id
join order_items oi on oi.order_id = o.order_id
group by o.customer_id, name
having sum(quantity * unit_price * (1 - oi.discount_rate)) > (select avg(quantity * unit_price *(1-discount_rate)) from order_items)

--1. Monthly Revenue with Growth
select month(order_date) as 'Month',year(order_date) as 'Year', sum(quantity * unit_price * (1-discount_rate)) as 'Revenue', 
lag(sum(quantity * unit_price * (1-discount_rate))) over (order by year(order_date)) as 'prev_month_revenue',
sum(quantity * unit_price * (1-discount_rate)) - lag(sum(quantity * unit_price * (1-discount_rate))) over (order by year(order_date)) as 'mon_growth_pct
'
from orders o join order_items oi on o.order_id = oi.order_id
group by month(order_date),year(order_date)

--2. Category Performance 
select category, count(distinct order_id) as 'Orders', sum(quantity) as 'items', sum(quantity * unit_price * (1-discount_rate)) as 'revenue',
sum(quantity * unit_price * (1-discount_rate)) / count(distinct order_id) as 'avg_order_value'
from products p join order_items oi on oi.product_id = p.product_id
group by category

--3. Regional Leaderboard
with RegionProductRevenue as (
select c.region, p.name as product_name, sum(oi.quantity * oi.unit_price * (1 - oi.discount_rate)) as revenue 
from orders o join order_items oi on o.order_id = oi.order_id join customers c on o.customer_id = c.customer_id 
join products p on oi.product_id = p.product_id
where o.status not in ('cancelled')
group by c.region, p.name
),
RankedProducts as (
    select *, row_number() over (partition by region order by revenue desc) as rn
    from RegionProductRevenue
),
RegionStats as (
    select 
        c.region,
        count(distinct c.customer_id) as  customers,
        sum(oi.quantity * oi.unit_price * (1 - oi.discount_rate)) as revenue
    from orders o
    join order_items oi on o.order_id = oi.order_id
    join customers c  on o.customer_id = c.customer_id
    where o.status not in ('cancelled')
    group by c.region
)
select rs.region, rs.customers, rs.revenue, rp.product_name as top_product_by_revenue from RegionStats rs
join RankedProducts rp  on rs.region = rp.region and rp.rn = 1
order by rs.revenue desc;

--extra customer name index
create nonclustered index ind11
on customers(name)

--adding on delete cascade and on update cascade
--in case the primary key being referenced by the foreign keys get deleted or updated
--that would reflect on their rows as foreign keys to keep the referential integrity in the database
alter table orders 
drop constraint FK__orders__customer__3D5E1FD2

alter table orders
add constraint ord_cust_fk
foreign key (customer_id) references customers(customer_id)
on delete cascade
on update cascade

alter table  order_items
drop constraint FK__order_ite__order__403A8C7D

alter table order_items
add constraint ord_item_ord_fk
foreign key (order_id) references orders(order_id)
on update cascade
on delete cascade

alter table order_items
drop constraint FK__order_ite__produ__412EB0B6

alter table order_items
add constraint ord_item_prod_fk
foreign key (product_id) references products(product_id)
on update cascade
on delete cascade