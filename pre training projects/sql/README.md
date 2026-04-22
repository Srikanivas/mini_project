# Retail Store Database

A MySQL project that models a retail store with customers, products, orders, and order items. Includes table creation, data insertion, views, and analytical queries.

## Files

| File         | Purpose                                       |
| ------------ | --------------------------------------------- |
| `retail.sql` | Full SQL script: schema, data, views, queries |

## Run

```sql
source retail.sql;
```

Or open `retail.sql` in MySQL Workbench and execute all statements.

## Schema

```
customers (customer_id, name, city)
products  (product_id, name, category, price)
orders    (order_id, customer_id, date)
order_items (order_id, product_id, quantity)
```

## Features

- Normalized schema with foreign key constraints
- Sample data: 6 customers, 8 products, 8 orders, 11 order items
- Three analytical views: top products, customer spending, monthly revenue
- Queries for sales analysis, customer insights, and inactive customer detection

## Views

| View                | Description                            |
| ------------------- | -------------------------------------- |
| `top_products`      | Products ranked by total quantity sold |
| `customer_spending` | Total spend per customer with city     |
| `monthly_revenue`   | Revenue grouped by month               |

## Queries

| Query                    | Description                              |
| ------------------------ | ---------------------------------------- |
| Top products by quantity | Products ordered by total units sold     |
| Customer spending        | Total amount spent per customer          |
| Monthly revenue          | Revenue breakdown by month               |
| Category sales           | Total sales grouped by product category  |
| Customers with no orders | Customers who have never placed an order |
| SELECT \* FROM views     | Query all three analytical views         |

## Screenshots

**Create Database**
![Create Database](screenshots/01_create_database.png)

**Create Table: Customers**
![Create Table Customers](screenshots/02_create_table_customers.png)

**Create Remaining Tables**
![Create Tables](screenshots/03_create_tables.png)

**Insert Customers**
![Insert Customers](screenshots/04_insert_customers.png)

**Insert Products**
![Insert Products](screenshots/05_insert_products.png)

**Insert Orders**
![Insert Orders](screenshots/06_insert_orders.png)

**Insert Order Items**
![Insert Order Items](screenshots/07_insert_order_items.png)

**Create Views**
![Create Views](screenshots/08_create_views.png)

**Select: Top Products**
![Select Top Products](screenshots/09_select_top_products.png)

**Select: Customer Spending**
![Select Customer Spending](screenshots/10_select_customer_spending.png)

**Select: Monthly Revenue**
![Select Monthly Revenue](screenshots/11_select_monthly_revenue.png)

**Select: Category Sales**
![Select Category Sales](screenshots/12_select_category_sales.png)

**Select: Customers with No Orders**
![Select No Orders](screenshots/13_select_no_orders.png)
