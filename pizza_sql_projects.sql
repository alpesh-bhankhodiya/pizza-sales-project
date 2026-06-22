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


-- Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS total_order FROM orders;


-- Calculate the total revenue generated from pizza sales.
SELECT SUM(p.price * o.quantity) AS total_revenue
FROM pizzas p 
JOIN orders_details o 
ON p.pizza_id = o.pizza_id; 


-- Identify the highest-priced pizza.
SELECT p1.pizza_id,
       p1.pizza_type_id,
	   p2.name,
	   p1.price,
	   p2.category
FROM pizzas p1
JOIN pizza_types p2
ON p1.pizza_type_id = p2.pizza_type_id
ORDER BY price DESC
LIMIT 1;



-- Identify the most common pizza size ordered.
SELECT p.size,
       COUNT(o.order_id) AS order_count 
FROM orders_details o
JOIN pizzas p 
ON p.pizza_id = o.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;


-- List the top 5 most ordered pizza types along with their quantities.
SELECT p1.pizza_type_id,
       p1.name,
	   SUM(o.quantity) AS quantities
FROM orders_details o
JOIN pizzas p
ON p.pizza_id = o.pizza_id
JOIN pizza_types p1
ON p.pizza_type_id = p1.pizza_type_id
GROUP BY p1.pizza_type_id,p1.name
ORDER BY quantities DESC 
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT p1.category,
       SUM(quantity) AS total_quantity
FROM orders_details o
JOIN pizzas p
ON p.pizza_id = o.pizza_id 
JOIN pizza_types p1
ON p.pizza_type_id = p1.pizza_type_id
GROUP BY p1.category
ORDER BY total_quantity DESC;


-- Determine the distribution of orders by hour of the day.
SELECT DATE_PART('hour',order_time),COUNT(order_id) AS total_orders
FROM orders 
GROUP BY DATE_PART('hour',order_time)
ORDER BY DATE_PART('hour',order_time);
 
	   
-- Find the percentage distribution of pizzas by category.
SELECT p1.category,
       SUM(o.quantity) AS total_quantity,
       ROUND(SUM(o.quantity) * 100 / SUM(SUM(o.quantity)) OVER(),2) AS percentage_share
FROM orders_details o
JOIN pizzas p
ON p.pizza_id = o.pizza_id
JOIN pizza_types p1
ON p.pizza_type_id = p1.pizza_type_id
GROUP BY p1.category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT AVG(daily_total) 
FROM
(
	SELECT o.order_date AS date_cat,
            SUM(o1.quantity) AS daily_total
     FROM orders o
     JOIN orders_details o1
     ON o.order_id = o1.order_id
     GROUP BY o.order_date
     ORDER BY  daily_total
) t;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(daily_total),2) AS avg_pizzas_per_day
FROM
(
    SELECT o.order_date,
           SUM(od.quantity) AS daily_total
    FROM orders o
    JOIN orders_details od
        ON o.order_id = od.order_id
    GROUP BY o.order_date
) t;



-- Determine the top 3 most ordered pizza types based on revenue.
SELECT p.pizza_type_id,
       pt.name,
       SUM(od.quantity * p.price) AS total_by_pizza_type
FROM orders_details od
JOIN pizzas p 
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY p.pizza_type_id,pt.name
ORDER BY total_by_pizza_type DESC
LIMIT 3;



-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT p.pizza_type_id,
       pt.name,
       SUM(od.quantity * p.price) AS total_by_pizza_type,
	   ROUND(SUM(od.quantity * p.price) * 100 / SUM(SUM(od.quantity * p.price)) OVER(),2) AS percentage_contribution
FROM orders_details od
JOIN pizzas p 
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY p.pizza_type_id,pt.name
ORDER BY total_by_pizza_type DESC;



-- Analyze the cumulative revenue generated over time.
SELECT DATE_TRUNC('month', order_date) AS month,
       SUM(od.quantity * p.price) AS monthly_revenue,
	   SUM(
	   SUM(od.quantity * p.price)
	   ) OVER(
	   ORDER BY DATE_TRUNC('month', order_date)
	   ) AS cumulative_revenue
FROM orders o
JOIN orders_details od
ON o.order_id = od.order_id 
JOIN pizzas p
ON p.pizza_id = od.pizza_id
GROUP BY DATE_TRUNC('month', order_date);


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT *
FROM ( 
      SELECT pt.pizza_type_id,
             pt.name,
	         pt.category,
             SUM(od.quantity * p.price) AS total,
	         DENSE_RANK() OVER(
			 PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC
			 ) AS rank
FROM orders_details od
JOIN pizzas p 
ON p.pizza_id = od.pizza_id
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.pizza_type_id,pt.name,pt.category
) t
WHERE rank <= 3;



-- Find the revenue generated by each pizza size.
SELECT p.size,SUM(od.quantity * p.price)
FROM orders_details od
JOIN pizzas p
ON p.pizza_id = od.pizza_id
GROUP BY p.size;



-- Find the revenue generated by each pizza category.
SELECT pt.category,
       SUM(od.quantity * p.price) AS total_revenue
FROM orders_details od
JOIN pizzas p 
ON p.pizza_id = od.pizza_id
JOIN pizza_types pt 
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category;



-- Identify the bottom 5 pizzas by revenue.
SELECT pt.name,
       SUM(od.quantity * p.price) AS total_revenue
FROM orders_details od
JOIN pizzas p 
ON p.pizza_id = od.pizza_id
JOIN pizza_types pt 
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue
LIMIT 5;



-- Find pizzas whose revenue is above the overall average pizza revenue.
WITH pizza_revenue AS 
       (SELECT pt.name,
               SUM(od.quantity * p.price) AS total_revenue
        FROM orders_details od
        JOIN pizzas p 
        ON p.pizza_id = od.pizza_id
        JOIN pizza_types pt 
        ON pt.pizza_type_id = p.pizza_type_id
        GROUP BY pt.name
)

SELECT * 
FROM pizza_revenue 
WHERE total_revenue > (
                       SELECT AVG(total_revenue)
					   FROM pizza_revenue
);

		

-- Determine the busiest day of the week based on number of orders.
SELECT TO_CHAR(order_date,'Day') AS week_day,
       COUNT(order_id) AS total_order
FROM orders
GROUP BY TO_CHAR(order_date,'Day')
ORDER BY total_order DESC LIMIT 1;


-- Calculate monthly revenue trends.
SELECT DATE_TRUNC('month', order_date) AS month,
       SUM(od.quantity * p.price) AS monthly_revenue
FROM orders_details od
JOIN orders o
ON o.order_id = od.order_id
JOIN pizzas p 
ON p.pizza_id = od.pizza_id
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;


-- Identify the hour that generates the highest revenue.
SELECT EXTRACT(HOUR FROM o.order_time) AS hour,
       SUM(od.quantity * p.price) AS hourly_revenue
FROM orders_details od
JOIN orders o
ON o.order_id = od.order_id
JOIN pizzas p 
ON p.pizza_id = od.pizza_id
GROUP BY EXTRACT(HOUR FROM o.order_time)
ORDER BY hourly_revenue DESC
LIMIT 1;


-- Which 5 pizza types generated the highest revenue?
SELECT pt.pizza_type_id,pt.name,
       SUM(od.quantity * p.price) AS total_revenue
FROM orders_details od
JOIN pizzas p 
ON p.pizza_id = od.pizza_id
JOIN pizza_types pt 
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name,pt.pizza_type_id
ORDER BY total_revenue DESC 
LIMIT 5;


-- Which pizzas are High Revenue, Medium Revenue, and Low Revenue performers?
WITH pizza_revenue AS (
    SELECT pt.pizza_type_id,
           pt.name,
           SUM(od.quantity * p.price) AS total_revenue
    FROM orders_details od
    JOIN pizzas p
    ON p.pizza_id = od.pizza_id
    JOIN pizza_types pt
    ON pt.pizza_type_id = p.pizza_type_id
    GROUP BY pt.pizza_type_id, pt.name
)

SELECT *,
       CASE
           WHEN total_revenue >
                (SELECT AVG(total_revenue) * 1.2 FROM pizza_revenue) 
		   THEN 'HIGH'
		   WHEN total_revenue <
                (SELECT AVG(total_revenue) * 0.8 FROM pizza_revenue)
           THEN 'LOW'
		   ELSE 'MEDIUM'
       END AS revenue_category
FROM pizza_revenue
ORDER BY total_revenue DESC;



-- Which pizza categories outperform the average category revenue?
WITH pizza_revenue AS (
    SELECT pt.category,
           SUM(od.quantity * p.price) AS total_revenue
    FROM orders_details od
    JOIN pizzas p
    ON p.pizza_id = od.pizza_id
    JOIN pizza_types pt
    ON pt.pizza_type_id = p.pizza_type_id
	GROUP BY pt.category)

SELECT *
FROM pizza_revenue 
WHERE total_revenue > (
                      SELECT AVG(total_revenue)
					  FROM pizza_revenue
);
	


-- Rank all pizzas based on revenue
WITH pizza_revenue AS (
    SELECT pt.pizza_type_id,pt.name,
           SUM(od.quantity * p.price) AS total_revenue
    FROM orders_details od
    JOIN pizzas p
    ON p.pizza_id = od.pizza_id
    JOIN pizza_types pt
    ON pt.pizza_type_id = p.pizza_type_id
	GROUP BY pt.name,pt.pizza_type_id)

SELECT DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS revenue_rank,
       *
FROM pizza_revenue;	   
	   
	   

-- Find the top 3 revenue-generating pizzas within each category
WITH pizza_revenue AS (
    SELECT DENSE_RANK() OVER(
	                         PARTITION BY category 
					         ORDER BY SUM(od.quantity * p.price) DESC 
		   ) AS revenue_rank,
	       pt.name,
	       pt.category,
           SUM(od.quantity * p.price) AS total_revenue
    FROM orders_details od
    JOIN pizzas p
    ON p.pizza_id = od.pizza_id
    JOIN pizza_types pt
    ON pt.pizza_type_id = p.pizza_type_id
	GROUP BY pt.name,pt.category)

SELECT * 
FROM pizza_revenue 
WHERE revenue_rank <= 3;
	
	

























































































