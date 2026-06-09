# SuperMart Analytics – SQL Capstone Project

**Program:** AICA x DataCamp Scholarship  
**Student:** NSENGIYUMVA Faustin  
**Tool:** PostgreSQL  

---

## About the Project

SuperMart is a Nigerian retail chain operating across six regions and 30 cities, selling 68 products across 8 categories. The company has 35 employees across three tiers: Regional Managers, Sales Managers, and Sales Reps. Sales data covers January 2021 to June 2024.

This project involves writing SQL queries against the SuperMart database to surface insights on revenue performance, employee effectiveness, customer behaviour, and product inventory.

---

## Database Schema

| Table | Key Columns |
|---|---|
| regions | region_id, region_name |
| categories | category_id, category_name |
| employees | employee_id, first_name, last_name, role, region_id, hire_date, salary |
| customers | customer_id, first_name, last_name, email, city, country, registration_date |
| products | product_id, product_name, category_id, unit_price, stock_quantity |
| orders | order_id, customer_id, employee_id, order_date, status, shipping_city |
| order_items | order_item_id, order_id, product_id, quantity, unit_price, discount |

**Revenue formula used throughout:** `quantity * unit_price * (1 - discount / 100.0)`

---

## What's Covered

| Section | Topic |
|---|---|
| A | SELECT, WHERE, DISTINCT, ORDER BY, LIMIT |
| B | Aggregate functions – COUNT, SUM, AVG, MIN, MAX |
| C | GROUP BY and HAVING |
| D | Pattern matching with LIKE and ILIKE |
| E | INNER JOIN, LEFT JOIN, multi-table joins |
| F | CASE expressions and conditional aggregation |
| G | Subqueries – scalar, IN/NOT IN, derived tables |
| H | Common Table Expressions (CTEs) |
| I | Capstone challenge – Employee Sales Performance Report |
| J | Bonus – Customer Lifetime Value Report |

---

## Files

- `supermart_capstone_answers.sql` – all SQL queries for sections A through J
