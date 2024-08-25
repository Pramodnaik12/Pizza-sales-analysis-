CREATE DATABASE PizzaSales;

CREATE TABLE orders(
order_id INT NOT NULL,
order_date DATE NOT NULL,
order_time TIME NOT NULL,
primary key(order_id));

CREATE TABLE order_details(
order_details_id INT NOT NULL,
order_id INT NOT NULL,
pizza_id TEXT NOT NULL,
quantity INT NOT NULL,
PRIMARY KEY(order_details_id));

SELECT * FROM order_details
SELECT * FROM orders
SELECT * FROM pizzas
SELECT * FROM pizza_types

-- --------------------------------------------------------------------
-- Retreive total number of orders placed.
SELECT count(order_id) AS Total_orders FROM orders 

-- Calculate the total revenue generated from pizza sales.
SELECT 
ROUND(sum((order_details.quantity * pizzas.price)),2) AS Total_sales
FROM order_details JOIN pizzas
ON pizzas.pizza_id=order_details.pizza_id

-- Identify the highest-priced pizza.
SELECT
NAME , pizza_id, price
FROM pizza_types JOIN pizzas 
ON pizzas.pizza_type_id=pizza_types.pizza_type_id
ORDER BY price DESC LIMIT 5

-- Identify the most common pizza size ordered.
SELECT  size, count(order_details_id) AS count FROM order_details
JOIN pizzas ON pizzas.pizza_id=order_details.pizza_id
GROUP BY size
ORDER BY count DESC

-- List the top 5 most ordered pizza types along with their quantities.
SELECT NAME, count(order_details_id) AS order_count, sum(quantity) AS total_quantity_ordered, round(avg(price),2) as avg_price
FROM pizza_types JOIN pizzas
ON pizzas.pizza_type_id=pizza_types.pizza_type_id
JOIN order_details
ON order_details.pizza_id=pizzas.pizza_id
GROUP BY NAME
ORDER BY 3 asc
LIMIT 5

-- -------------------------------------------------------------------------------------------------------
-- ---------------------------------------Intermediate----------------------------------------------------

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT
 category , sum(quantity) total_quantity FROM pizza_types
 JOIN pizzas ON pizza_types.pizza_type_id=pizzas.pizza_type_id
 JOIN order_details ON pizzas.pizza_id=order_details.pizza_id
 GROUP BY category
 
 -- Determine the distribution of orders by hour of the day.
SELECT HOUR(order_time) as Hour, count(order_id) as Count_of_orders  FROM orders
group by 1 order by 2 desc

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, count(name) AS count
FROM pizza_types
GROUP BY category

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(total_pizzas_ordered),0) AS avg_order_per_day FROM 
(SELECT DATE(order_date) AS Date ,sum(quantity) AS total_pizzas_ordered
FROM orders JOIN order_details
ON orders.order_id=order_details.order_id
GROUP BY 1) AS data

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT name ,count(order_id) as orders,round(sum(quantity*price),2) AS total_revenue, round(avg(price),2) AS average
FROM pizza_types JOIN
pizzas ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN order_details
ON pizzas.pizza_id=order_details.pizza_id
GROUP BY name
ORDER BY 3 DESC 
LIMIT 5

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT category ,
(round(sum(quantity*price) /(SELECT ROUND(SUM(quantity * price),2)AS total_sales
 FROM order_details JOIN pizzas ON order_details.pizza_id=pizzas.pizza_id )*100,2)) as revenue_percentage
FROM pizza_types JOIN
pizzas ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN order_details
ON pizzas.pizza_id=order_details.pizza_id
GROUP BY category
ORDER BY 2 DESC 

-- Analyze the cumulative revenue generated over time.
SELECT Month,  sum(revenue) OVER (order by Month) AS cum_revenue
FROM
(SELECT MONTH(order_date) AS Month, ROUND(sum(quantity*price),2) AS revenue FROM ORDERS
JOIN order_details ON 
orders.order_id=order_details.order_id
JOIN pizzas ON 
order_details.pizza_id=pizzas.pizza_id
group by Month) AS revenue_by_date

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name, revenue , category FROM
(SELECT category, name, revenue , RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
FROM
(SELECT category, name, sum(quantity * price) AS revenue
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN order_details ON 
pizzas.pizza_id=order_details.pizza_id
GROUP BY category, name  
ORDER BY category) AS revenue_by_cat_name) AS b
WHERE rn<=3;



