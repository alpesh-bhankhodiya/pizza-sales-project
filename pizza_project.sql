CREATE TABLE pizzas(
   pizza_id VARCHAR(100),
   pizza_type_id VARCHAR(100) NOT NULL,
   size VARCHAR(50) NOT NULL,
   price NUMERIC(5,2) NOT NULL
);
SELECT * FROM pizzas;


CREATE TABLE pizza_types(
   pizza_type_id VARCHAR(100),
   name VARCHAR(300) NOT NULL,
   category VARCHAR(100) NOT NULL,
   ingredient VARCHAR(300) NOT NULL
);
SELECT * FROM pizza_types;


CREATE TABLE orders(
   order_id INT PRIMARY KEY NOT NULL,
   order_date DATE NOT NULL,
   order_time TIME NOT NULL
);
SELECT * FROM orders;


CREATE TABLE orders_details(
   order_details_id INT PRIMARY KEY NOT NULL,
   order_id INT NOT NULL,
   pizza_id TEXT NOT NULL,
   quantity INT NOT NULL
);
SELECT * FROM orders_details;


SELECT * FROM orders_details od
JOIN orders o ON o.order_id = od.order_id
JOIN pizzas p ON p.pizza_id = od.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id;



--ans-1 for Retrieve the total number of orders placed.
SELECT COUNT(order_id) FROM orders;

--ans-2 for Calculate the total revenue generated from pizza sales.
SELECT SUM(od.quantity * p.price) AS Total_revenue FROM orders_details od 
JOIN pizzas p ON p.pizza_id = od.pizza_id;

--ans-3 for Identify the highest-priced pizza.
SELECT pt.name,p.price FROM pizzas p
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC LIMIT 1;

--ans-4 for Identify the most common pizza size ordered.
SELECT p.size,COUNT(o.order_id) AS order_count FROM orders_details od
JOIN orders o ON o.order_id = od.order_id
JOIN pizzas p ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;

--ans-5 for List the top 5 most ordered pizza types along with their quantities.
SELECT pt.pizza_type_id,pt.name,SUM(od.quantity) AS total_sum FROM orders_details od
JOIN pizzas p ON p.pizza_id = od.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.pizza_type_id,pt.name 
ORDER BY total_sum DESC LIMIT 5;

--ans-6 for Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pt.category,SUM(od.quantity) AS total FROM orders_details od
JOIN pizzas p ON p.pizza_id = od.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY total DESC;

--ans-7 for Determine the distribution of orders by hour of the day.
SELECT DATE_PART('hour',order_time),COUNT(order_id) AS total_orders
FROM orders 
GROUP BY DATE_PART('hour',order_time)
ORDER BY DATE_PART('hour',order_time);

--ans-8 for Join relevant tables to find the category-wise distribution of pizzas.
SELECT category,COUNT(name) FROM pizza_types
GROUP BY category;

--ans-9 for Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(quantity),0) FROM (SELECT o.order_date,SUM(od.quantity) as quantity
FROM orders o
JOIN orders_details od ON o.order_id = od.order_id
GROUP BY o.order_date) as order_quantity;

--ans-10 for Determine the top 3 most ordered pizza types based on revenue.
SELECT pt.name,SUM(od.quantity * p.price) as cat_revenue FROM orders_details od
JOIN orders o ON o.order_id = od.order_id
JOIN pizzas p ON p.pizza_id = od.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name 
ORDER BY cat_revenue DESC LIMIT 3;

--ans-11 for Calculate the percentage contribution of each pizza type to total revenue.
SELECT pt.category,
    ROUND(SUM(od.quantity * p.price) * 100 / 
    (SELECT SUM(od.quantity * p.price) FROM orders_details od 
       JOIN pizzas p ON p.pizza_id = od.pizza_id),2) as revenue_percentage
FROM orders_details od
JOIN pizzas p ON p.pizza_id = od.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY revenue_percentage DESC;

--ans-12 for Analyze the cumulative revenue generated over time.
WITH daily_sales AS
(
SELECT o.order_date,SUM(od.quantity * p.price) AS total_by_date FROM 
orders o 
JOIN orders_details od ON o.order_id = od.order_id 
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.order_date
ORDER BY total_by_date DESC
)

SELECT order_date,total_by_date,SUM(total_by_date) 
OVER(ORDER BY order_date) AS cumulative_revenue
FROM daily_sales;

--ans-13 for Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT * FROM 
(WITH revenue_by_type AS
(
SELECT pt.name,pt.category,SUM(od.quantity * p.price) AS revenue FROM orders_details od
JOIN orders o ON o.order_id = od.order_id
JOIN pizzas p ON p.pizza_id = od.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name,pt.category
)
SELECT 
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn,
category,name,revenue 
FROM revenue_by_type) AS b 
WHERE rn <= 3;