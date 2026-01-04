USE pizza;


select * from orders;
select * from orders_details;
select * from pizza_types;
select * from pizzas;


-- Retrieve the total number of orders placed.
select count(order_id)  as total_orders from orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    round(SUM(od.quantity * p.price)) AS total_sales
FROM orders_details AS od
JOIN pizzas AS p
    ON p.pizza_id = od.pizza_id;

-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(od.order_details_id) AS order_count
FROM
    pizzas AS p
        JOIN
    orders_details AS od ON p.pizza_id = od.pizza_id
GROUP BY p.size;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name,
    SUM(od.quantity) AS quantity
FROM pizza_types AS pt
JOIN pizzas AS p
    ON pt.pizza_type_id = p.pizza_type_id
JOIN orders_details AS od
    ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC limit 5 ;


-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category,
    SUM(od.quantity) AS quantity
FROM pizza_types AS pt
JOIN pizzas AS p
    ON pt.pizza_type_id = p.pizza_type_id
JOIN orders_details AS od
    ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT AVG(quantity)
FROM (
    SELECT 
        o.order_date,
        SUM(od.quantity) AS quantity
    FROM orders AS o
    JOIN orders_details AS od
        ON o.order_id = od.order_id
    GROUP BY o.order_date
) AS order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name,
    SUM(od.quantity * p.price) AS revenue
FROM pizza_types AS pt
JOIN pizzas AS p
    ON pt.pizza_type_id = p.pizza_type_id
JOIN orders_details AS od
    ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;


-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND(
        (SUM(orders_details.quantity * pizzas.price) /
        (SELECT SUM(orders_details.quantity * pizzas.price)
         FROM orders_details
         JOIN pizzas
             ON pizzas.pizza_id = orders_details.pizza_id)
        ) * 100, 2
    ) AS revenue_percentage
FROM pizza_types
JOIN pizzas
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details
    ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_percentage DESC;

-- Analyze the cumulative revenue generated over time.
SELECT 
    order_date,
    SUM(revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT 
        orders.order_date,
        SUM(orders_details.quantity * pizzas.price) AS revenue
    FROM orders_details
    JOIN pizzas
        ON orders_details.pizza_id = pizzas.pizza_id
    JOIN orders
        ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date
) AS sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT 
    category,
    name,
    revenue,
    RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
FROM (
    SELECT 
        pizza_types.category,
        pizza_types.name,
        SUM(orders_details.quantity * pizzas.price) AS revenue
    FROM pizza_types
    JOIN pizzas
        ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN orders_details
        ON orders_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.category, pizza_types.name
) AS a;






