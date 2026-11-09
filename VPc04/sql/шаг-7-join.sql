-- Шаг 7. JOIN: связываем заказы с товарами (orders -> products).

-- 1) Каждая строка заказа с названием и ценой товара
SELECT o.id AS order_id, o.order_date, o.quantity,
       p.name AS product, p.category,
       ROUND(o.quantity * p.price, 2) AS order_sum
FROM orders o
JOIN products p ON p.id = o.product_id
ORDER BY o.id
LIMIT 20;

-- 2) Итог: выручка по категориям (JOIN + агрегация вместе)
SELECT p.category,
       COUNT(*) AS orders_count,
       ROUND(SUM(o.quantity * p.price), 2) AS total_sum
FROM orders o
JOIN products p ON p.id = o.product_id
GROUP BY p.category
ORDER BY total_sum DESC;
