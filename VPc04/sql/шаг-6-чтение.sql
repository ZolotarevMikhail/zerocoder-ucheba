-- Шаг 6. Чтение данных: топ-N выборка, агрегация с HAVING, поиск через LIKE.

-- 1) Топ-10 дорогих товаров в разумном диапазоне цен
SELECT name, category, price
FROM products
WHERE price BETWEEN 500 AND 5000
ORDER BY price DESC
LIMIT 10;

-- 2) Сколько товаров в каждой категории; показываем только категории,
--    где товаров больше 5 (HAVING — фильтр ПОСЛЕ группировки)
SELECT category,
       COUNT(*) AS goods_count,
       ROUND(AVG(price), 2) AS avg_price
FROM products
GROUP BY category
HAVING COUNT(*) > 5
ORDER BY goods_count DESC;

-- 3) Поиск без учёта регистра: UPPER(колонка) LIKE 'ШАБЛОН%'
--    UPPER() поднимает только латиницу, поэтому ищем по артикулу (SP-...)
SELECT sku, name FROM products WHERE UPPER(sku) LIKE 'SP-004%';
-- тот же запрос в нижнем регистре шаблона — результат тот же:
SELECT sku, name FROM products WHERE UPPER(sku) LIKE 'sp-004%';
