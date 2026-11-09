-- Шаг 5. Безопасный DELETE — удаляем только тестовые записи.
-- Правило безопасности: сначала считаем, ЧТО удалим, потом удаляем.

-- 1) Сколько строк затронет удаление? (должно быть 3)
SELECT COUNT(*) AS rows_to_delete
FROM products
WHERE sku LIKE 'TEST-%';

-- 2) На тестовые записи не ссылается ни один заказ (orders ссылаются на
--    SP-0001..SP-0120), поэтому удалять безопасно — foreign key не сломается
DELETE FROM products
WHERE sku LIKE 'TEST-%';

-- Контроль: тестовых осталось 0, всего товаров снова 123 (126 - 3)
SELECT COUNT(*) AS test_rows_left  FROM products WHERE sku LIKE 'TEST-%';
SELECT COUNT(*) AS products_total  FROM products;
