-- SuperMart Analytics - Capstone Project
-- Student: NSENGIYUMVA Faustin
-- Tool: PostgreSQL
-- Note: revenue = quantity * unit_price * (1 - discount / 100.0)


-- ========================
-- Section A: Fundamentals
-- ========================

-- Q1a: customers from Lagos sorted by last name then first name
select first_name, last_name, email
from customers
where city = 'Lagos'
order by last_name, first_name;


-- Q1b: all distinct cities we have shipped orders to
select distinct shipping_city
from orders
order by shipping_city;


-- Q1c: top 10 priciest products
select product_name, category_id, unit_price
from products
order by unit_price desc
limit 10;


-- Q1d: employees hired from Jan 2021 onwards
select
    first_name || ' ' || last_name as full_name,
    role,
    hire_date,
    salary
from employees
where hire_date >= '2021-01-01'
order by hire_date;


-- Q1e: orders placed in December (any year)
select order_id, order_date, status, shipping_city
from orders
where extract(month from order_date) = 12
order by order_date desc;


-- =============================
-- Section B: Aggregate Functions
-- =============================

-- Q2a: how many orders per status, and what % of total
select
    status,
    count(*) as count,
    round(count(*) * 100.0 / sum(count(*)) over (), 2) as pct_of_total
from orders
group by status
order by count desc;


-- Q2b: min, max and avg price per category
select
    c.category_name,
    min(p.unit_price) as min_price,
    max(p.unit_price) as max_price,
    round(avg(p.unit_price), 2) as avg_price
from products p
join categories c on p.category_id = c.category_id
group by c.category_name
order by avg_price desc;


-- Q2c: revenue summary across all order line items
select
    round(sum(quantity * unit_price * (1 - discount / 100.0)), 2) as total_revenue,
    round(avg(quantity * unit_price * (1 - discount / 100.0)), 2) as avg_line_revenue,
    round(max(quantity * unit_price * (1 - discount / 100.0)), 2) as max_line_revenue,
    round(min(quantity * unit_price * (1 - discount / 100.0)), 2) as min_line_revenue
from order_items;


-- Q2d: how many unique customers ordered + average orders per customer
select
    count(distinct customer_id) as distinct_ordering_customers,
    round(count(*) * 1.0 / count(distinct customer_id), 2) as avg_orders_per_customer
from orders;


-- ====================
-- Section C: Grouping
-- ====================

-- Q3a: number of customers who registered each year (2018 to 2024)
select
    extract(year from registration_date) as registration_year,
    count(*) as customer_count
from customers
where extract(year from registration_date) between 2018 and 2024
group by registration_year
order by registration_year;


-- Q3b: cities with more than 10 delivered orders
select
    shipping_city,
    count(*) as delivered_order_count
from orders
where status = 'Delivered'
group by shipping_city
having count(*) > 10
order by delivered_order_count desc;


-- Q3c: products where total qty sold is over 50 units (all statuses)
select
    p.product_id,
    p.product_name,
    sum(oi.quantity) as total_qty_sold
from order_items oi
join products p on oi.product_id = p.product_id
group by p.product_id, p.product_name
having sum(oi.quantity) > 50
order by total_qty_sold desc;


-- Q3d: employees who handled at least 20 orders
-- using INNER JOIN here since question asks only for employees that have orders
select
    e.first_name || ' ' || e.last_name as full_name,
    count(o.order_id) as order_count
from employees e
join orders o on e.employee_id = o.employee_id
group by e.employee_id, e.first_name, e.last_name
having count(o.order_id) >= 20
order by order_count desc;


-- Q3e: yearly order summary (2021-2024)
select
    extract(year from order_date) as order_year,
    count(*) as total_orders,
    count(distinct customer_id) as distinct_customers
from orders
group by order_year
order by order_year;


-- ========================
-- Section D: LIKE & ILIKE
-- ========================

-- Q4a: customers with gmail addresses (for campaign targeting)
select first_name, last_name, email
from customers
where email like '%@gmail.com'
order by last_name;


-- Q4b: products with "set" in the name (case insensitive)
select product_name, category_id, unit_price
from products
where product_name ilike '%set%'
order by unit_price desc;


-- Q4c: customers whose last name starts with 'Ad'
select
    first_name || ' ' || last_name as full_name,
    city,
    registration_date
from customers
where last_name ilike 'Ad%';


-- Q4d: products with combo, kit or pack in the name
select product_name, category_id, unit_price
from products
where product_name ilike '%combo%'
   or product_name ilike '%kit%'
   or product_name ilike '%pack%';


-- Q4e: customers from cities with 'an' in the name (e.g. Kano, Kaduna)
select first_name, last_name, city
from customers
where city ilike '%an%'
order by city, last_name;


-- ================
-- Section E: JOINs
-- ================

-- Q5a: 50 most recent orders with customer and employee names
select
    o.order_id,
    c.first_name || ' ' || c.last_name as customer_name,
    e.first_name || ' ' || e.last_name as employee_name,
    o.order_date,
    o.status,
    o.shipping_city
from orders o
inner join customers c on o.customer_id = c.customer_id
inner join employees e on o.employee_id = e.employee_id
order by o.order_date desc
limit 50;


-- Q5b: all 800 customers with their order count (0 if they never ordered)
select
    c.customer_id,
    c.first_name || ' ' || c.last_name as full_name,
    c.city,
    count(o.order_id) as order_count
from customers c
left join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.first_name, c.last_name, c.city
order by order_count desc, c.last_name;


-- Q5c: full order line detail report
select
    o.order_id,
    o.order_date,
    c.first_name || ' ' || c.last_name as customer_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.discount,
    round(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0), 2) as line_total
from order_items oi
join orders o on oi.order_id = o.order_id
join customers c on o.customer_id = c.customer_id
join products p on oi.product_id = p.product_id
order by o.order_id, p.product_name;


-- Q5d: all 35 employees with their region and total orders (including 0)
select
    e.first_name || ' ' || e.last_name as full_name,
    e.role,
    r.region_name,
    count(o.order_id) as total_orders
from employees e
join regions r on e.region_id = r.region_id
left join orders o on e.employee_id = o.employee_id
group by e.employee_id, e.first_name, e.last_name, e.role, r.region_name
order by total_orders desc, e.last_name;


-- Q5e: per category, show each product with how many orders it appeared in
select
    c.category_name,
    p.product_name,
    count(distinct oi.order_id) as times_ordered,
    sum(oi.quantity) as total_qty_sold
from products p
join categories c on p.category_id = c.category_id
left join order_items oi on p.product_id = oi.product_id
group by c.category_name, p.product_name
order by c.category_name, total_qty_sold desc;


-- ==========================
-- Section F: CASE Expressions
-- ==========================

-- Q6a: label each product with a price tier
select
    p.product_name,
    c.category_name,
    p.unit_price,
    case
        when p.unit_price < 10000 then 'Budget'
        when p.unit_price between 10000 and 99999 then 'Mid-Range'
        else 'Premium'
    end as price_tier
from products p
join categories c on p.category_id = c.category_id
order by p.unit_price;


-- Q6b: classify employees by salary band
select
    first_name || ' ' || last_name as full_name,
    role,
    salary,
    case
        when salary >= 100000 then 'Executive'
        when salary between 80000 and 99999 then 'Senior'
        else 'Entry Level'
    end as pay_band
from employees
order by salary desc;


-- Q6c: total value per order and classify it as high/medium/low
select
    o.order_id,
    o.order_date,
    o.status,
    round(sum(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)), 2) as total_order_value,
    case
        when sum(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)) > 500000 then 'High Value'
        when sum(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)) between 100000 and 500000 then 'Medium Value'
        else 'Low Value'
    end as value_category
from orders o
join order_items oi on o.order_id = oi.order_id
group by o.order_id, o.order_date, o.status
order by total_order_value desc;


-- Q6d: count of products per price tier, grouped by category
select
    c.category_name,
    count(case when p.unit_price < 10000 then 1 end) as budget_count,
    count(case when p.unit_price between 10000 and 99999 then 1 end) as mid_range_count,
    count(case when p.unit_price >= 100000 then 1 end) as premium_count
from products p
join categories c on p.category_id = c.category_id
group by c.category_name
order by c.category_name;


-- ======================
-- Section G: Subqueries
-- ======================

-- Q7a: products priced above the catalogue average (scalar subquery)
select product_name, category_id, unit_price
from products
where unit_price > (select avg(unit_price) from products)
order by unit_price desc;


-- Q7b: customers who placed at least one order (using IN, no JOIN)
select
    first_name || ' ' || last_name as full_name,
    city
from customers
where customer_id in (select distinct customer_id from orders);


-- Q7c: products that never appeared in any order
select product_id, product_name, category_id, unit_price
from products
where product_id not in (select distinct product_id from order_items);


-- Q7d: top 5 customers by lifetime revenue using a derived table
select
    c.first_name || ' ' || c.last_name as full_name,
    c.city,
    sub.total_revenue
from (
    select
        o.customer_id,
        round(sum(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)), 2) as total_revenue
    from orders o
    join order_items oi on o.order_id = oi.order_id
    group by o.customer_id
) sub
join customers c on sub.customer_id = c.customer_id
order by sub.total_revenue desc
limit 5;


-- Q7e: customers whose revenue is above the average customer revenue
select
    c.first_name || ' ' || c.last_name as full_name,
    c.city,
    sub.total_revenue
from (
    select
        o.customer_id,
        round(sum(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)), 2) as total_revenue
    from orders o
    join order_items oi on o.order_id = oi.order_id
    group by o.customer_id
) sub
join customers c on sub.customer_id = c.customer_id
where sub.total_revenue > (
    select avg(r.total_revenue)
    from (
        select
            o2.customer_id,
            sum(oi2.quantity * oi2.unit_price * (1 - oi2.discount / 100.0)) as total_revenue
        from orders o2
        join order_items oi2 on o2.order_id = oi2.order_id
        group by o2.customer_id
    ) r
)
order by sub.total_revenue desc;


-- ==============================
-- Section H: CTEs
-- ==============================

-- Q8a: top 10 customers by revenue using a CTE
with customer_revenue as (
    select
        o.customer_id,
        round(sum(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)), 2) as total_revenue
    from orders o
    join order_items oi on o.order_id = oi.order_id
    group by o.customer_id
)
select
    c.customer_id,
    c.first_name || ' ' || c.last_name as full_name,
    c.city,
    cr.total_revenue
from customer_revenue cr
join customers c on cr.customer_id = c.customer_id
order by cr.total_revenue desc
limit 10;


-- Q8b: best selling product per category
with product_qty as (
    select
        p.product_id,
        p.product_name,
        p.category_id,
        sum(oi.quantity) as total_qty_sold
    from products p
    join order_items oi on p.product_id = oi.product_id
    group by p.product_id, p.product_name, p.category_id
)
select
    c.category_name,
    pq.product_name,
    pq.total_qty_sold
from product_qty pq
join categories c on pq.category_id = c.category_id
where pq.total_qty_sold = (
    select max(pq2.total_qty_sold)
    from product_qty pq2
    where pq2.category_id = pq.category_id
)
order by c.category_name;


-- Q8c: monthly revenue for 2023 vs monthly average (two chained CTEs)
with monthly_revenue as (
    select
        extract(month from o.order_date) as month_num,
        round(sum(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)), 2) as monthly_total
    from orders o
    join order_items oi on o.order_id = oi.order_id
    where extract(year from o.order_date) = 2023
    group by month_num
),
avg_revenue as (
    select avg(monthly_total) as avg_monthly
    from monthly_revenue
)
select
    mr.month_num,
    mr.monthly_total as total_revenue,
    case
        when mr.monthly_total > ar.avg_monthly then 'Above Average'
        else 'Below Average'
    end as vs_average
from monthly_revenue mr
cross join avg_revenue ar
order by mr.month_num;


-- Q8d: segment customers by how frequently they order
with order_counts as (
    select
        c.customer_id,
        count(o.order_id) as order_count
    from customers c
    left join orders o on c.customer_id = o.customer_id
    group by c.customer_id
)
select
    case
        when order_count >= 8 then 'High Frequency'
        when order_count >= 4 then 'Regular'
        when order_count >= 1 then 'Occasional'
        else 'Inactive'
    end as segment,
    count(*) as customer_count
from order_counts
group by segment
order by customer_count desc;


-- Q8e: year on year revenue from delivered orders only
with yearly_revenue as (
    select
        extract(year from o.order_date) as order_year,
        round(sum(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)), 2) as total_revenue
    from orders o
    join order_items oi on o.order_id = oi.order_id
    where o.status = 'Delivered'
    group by order_year
)
select order_year, total_revenue
from yearly_revenue
order by order_year;


-- ======================================================
-- Section I: Capstone Challenge (Q9)
-- Employee Sales Performance Report
-- Delivered orders only, Jan 2021 - Jun 2024
-- All 35 employees included even if they had zero orders
-- ======================================================

with order_revenue as (
    -- first get the total revenue for each individual order
    select
        oi.order_id,
        sum(oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)) as order_total
    from order_items oi
    group by oi.order_id
),
employee_stats as (
    -- then aggregate per employee for delivered orders in the date window
    select
        o.employee_id,
        count(o.order_id) as total_delivered_orders,
        sum(orr.order_total) as total_revenue,
        avg(orr.order_total) as avg_order_value,
        max(orr.order_total) as best_single_order
    from orders o
    join order_revenue orr on o.order_id = orr.order_id
    where o.status = 'Delivered'
      and o.order_date between '2021-01-01' and '2024-06-30'
    group by o.employee_id
)
select
    e.first_name || ' ' || e.last_name as employee_name,
    e.role,
    r.region_name,
    coalesce(es.total_delivered_orders, 0) as total_delivered_orders,
    round(coalesce(es.total_revenue, 0), 2) as total_revenue,
    round(coalesce(es.avg_order_value, 0), 2) as avg_order_value,
    round(coalesce(es.best_single_order, 0), 2) as best_single_order,
    case
        when coalesce(es.total_revenue, 0) > 5000000 then 'Elite'
        when coalesce(es.total_revenue, 0) between 1000000 and 5000000 then 'Strong'
        when coalesce(es.total_revenue, 0) between 100000 and 999999 then 'Developing'
        else 'Inactive'
    end as performance_band
from employees e
join regions r on e.region_id = r.region_id
left join employee_stats es on e.employee_id = es.employee_id
order by total_revenue desc, employee_name;


-- ======================================================
-- Section J: Bonus (Q10)
-- Customer Lifetime Value Report
-- Only customers registered before 2024
-- ======================================================

with customer_stats as (
    select
        c.customer_id,
        count(o.order_id) as total_orders,
        count(case when o.status = 'Delivered' then 1 end) as delivered_orders,
        count(case when o.status = 'Cancelled' then 1 end) as cancelled_orders,
        round(
            coalesce(
                sum(case when o.status = 'Delivered'
                    then oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)
                    else 0 end
                ), 0
            ), 2
        ) as lifetime_revenue,
        round(
            case
                when count(case when o.status = 'Delivered' then 1 end) > 0
                then coalesce(
                    sum(case when o.status = 'Delivered'
                        then oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)
                        else 0 end
                    ), 0
                ) / nullif(count(case when o.status = 'Delivered' then 1 end), 0)
                else 0
            end, 2
        ) as avg_order_value
    from customers c
    left join orders o on c.customer_id = o.customer_id
    left join order_items oi on o.order_id = oi.order_id
    where extract(year from c.registration_date) < 2024
    group by c.customer_id
)
select
    c.first_name || ' ' || c.last_name as customer_name,
    c.city,
    extract(year from c.registration_date) as registration_year,
    cs.total_orders,
    cs.delivered_orders,
    cs.cancelled_orders,
    cs.lifetime_revenue,
    cs.avg_order_value,
    case
        when cs.lifetime_revenue > 500000 and cs.delivered_orders >= 5 then 'VIP'
        when cs.lifetime_revenue between 100000 and 500000
             or cs.delivered_orders between 2 and 4 then 'Loyal'
        when cs.delivered_orders = 1 then 'One-Time Buyer'
        when cs.delivered_orders = 0 and cs.total_orders >= 1 then 'No Conversions'
        else 'Inactive'
    end as customer_segment
from customer_stats cs
join customers c on cs.customer_id = c.customer_id
order by cs.lifetime_revenue desc, customer_name;
