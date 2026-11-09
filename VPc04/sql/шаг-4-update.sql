-- Шаг 4. UPDATE — три осмысленных изменения, каждое С WHERE (требование ДЗ).

-- 1) Скидка 10% на всю категорию (WHERE по категории)
UPDATE products
SET price = ROUND(price * 0.90, 2)
WHERE category = 'Эспандеры';

-- 2) Помечаем тестовые записи — они не для продажи (WHERE по LIKE)
UPDATE products
SET description = 'Тестовая запись: для демонстрации UPDATE и DELETE, в продажу не идёт'
WHERE sku LIKE 'TEST-%';

-- 3) Точечная правка одной строки (WHERE по артикулу)
UPDATE products
SET price = 1990.00
WHERE sku = 'TEST-0003';

-- Контроль: видно и новую цену скакалки, и скидку категории
SELECT sku, price, description
FROM products
WHERE sku LIKE 'TEST-%' OR category = 'Эспандеры';
