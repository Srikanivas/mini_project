CREATE DATABASE IF NOT EXISTS retail_db;
USE retail_db;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(8,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO customers VALUES
(1,'Ravi Kumar','Hyderabad'),
(2,'Priya Sharma','Chennai'),
(3,'Arjun Reddy','Bangalore'),
(4,'Sneha Patel','Mumbai'),
(5,'Kiran Babu','Delhi'),
(6,'Meena Raj','Pune');

INSERT INTO products VALUES
(1,'Laptop','Electronics',45000),
(2,'Mobile','Electronics',18000),
(3,'Headphones','Electronics',2500),
(4,'Desk Chair','Furniture',8000),
(5,'Notebook','Stationery',120),
(6,'Pen Set','Stationery',80),
(7,'Monitor','Electronics',12000),
(8,'Bookshelf','Furniture',5500);

INSERT INTO orders VALUES
(101,1,'2024-01-15'),
(102,2,'2024-01-22'),
(103,3,'2024-02-10'),
(104,1,'2024-02-18'),
(105,4,'2024-03-05'),
(106,2,'2024-03-20'),
(107,5,'2024-04-11'),
(108,3,'2024-04-25');

INSERT INTO order_items VALUES
(101,1,1),
(101,3,2),
(102,2,1),
(103,4,1),
(103,5,3),
(104,7,1),
(105,1,2),
(106,3,1),
(107,6,5),
(108,8,1),
(108,5,2);

CREATE VIEW top_products AS
SELECT p.name, SUM(oi.quantity) AS total_qty
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.name
ORDER BY total_qty DESC;

CREATE VIEW customer_spending AS
SELECT c.name, c.city, SUM(p.price * oi.quantity) AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.name, c.city
ORDER BY total_spent DESC;

CREATE VIEW monthly_revenue AS
SELECT DATE_FORMAT(o.date, '%Y-%m') AS month,
       SUM(p.price * oi.quantity) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY month
ORDER BY month;

SELECT p.name, SUM(oi.quantity) AS total_qty
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.name
ORDER BY total_qty DESC;

SELECT c.name, SUM(p.price * oi.quantity) AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.name
ORDER BY total_spent DESC;

SELECT DATE_FORMAT(o.date, '%Y-%m') AS month,
       SUM(p.price * oi.quantity) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY month
ORDER BY month;

SELECT p.category, SUM(p.price * oi.quantity) AS sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY sales DESC;

SELECT name FROM customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id FROM orders
);

SELECT * FROM top_products;
SELECT * FROM customer_spending;
SELECT * FROM monthly_revenue;
