-- Домашнее задание VPc04: SQL-запросы по порядку урока.
-- База: learning.db (SQLite в DBeaver). Таблицы products и orders.

-- ============================================================
-- Часть 1. Создание таблиц products и orders (как на уроке)
-- ============================================================

-- Товары: название, описание, категория, цена, артикул (уникальный)
CREATE TABLE products (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL,
    description TEXT,
    category    TEXT,
    price       REAL,
    sku         TEXT UNIQUE
);

-- Заказы: какой товар, сколько, когда (связь по product_id -> products.id)
CREATE TABLE orders (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER,
    quantity   INTEGER,
    order_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- ============================================================
-- Часть 2. Наполнение: 120 товаров через скрипт (code/seed.py),
-- потом 3 ручных INSERT + 1 массовая вставка
-- ============================================================

-- 1) Три ручные вставки (каждый товар по одной строке, как руками в DBeaver).
--    Товары с TEST- в артикуле — тестовые: их удалим в части 4 через DELETE.
INSERT INTO products (name, description, category, price, sku) VALUES
  ('Мяч тренировочный тест 1', 'Тестовая запись для домашнего задания', 'Мячи', 999.00, 'TEST-0001'),
  ('Коврик тестовый тест 2', 'Тестовая запись для домашнего задания', 'Коврики', 1000.00, 'TEST-0002'),
  ('Скакалка тестовая тест 3', 'Тестовая запись для домашнего задания', 'Бег', 500.00, 'TEST-0003');

-- 2) Массовая вставка — много строк одним INSERT (...),(...),(...)
INSERT INTO products (name, description, category, price, sku) VALUES
  ('Наколенники Волейбольные Про', 'Наколенники для волейбола, усиленная накладка.', 'Аксессуары', 1790.00, 'SP-9001'),
  ('Ремень Тяжелоатлета Про', 'Ремень для становой тяги, натуральная кожа.', 'Аксессуары', 3200.00, 'SP-9002'),
  ('Скакалка Скоростная Лайт', 'Скакалка со счётчиком вращений.', 'Бег', 1450.00, 'SP-9003');

-- Контроль: после скрипта было 120, стало 126
SELECT COUNT(*) AS products_total FROM products;

-- ============================================================
-- Часть 3. UPDATE — три осмысленных изменения, каждое С WHERE
-- ============================================================

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

-- ============================================================
-- Часть 4. Безопасный DELETE — удаляем только тестовые записи
-- ============================================================

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

-- ============================================================
-- Часть 5. Чтение: топ-N выборка, агрегация с HAVING, поиск через LIKE
-- ============================================================

-- 1) Топ-10 дорогих товаров в разумном диапазоне цен
--    (WHERE фильтрует цены, ORDER BY сортирует, LIMIT оставляет верхние 10)
SELECT name, category, price
FROM products
WHERE price BETWEEN 500 AND 5000
ORDER BY price DESC
LIMIT 10;

-- 2) Сколько товаров в каждой категории; показываем только категории,
--    где товаров больше 5
--    (HAVING — фильтр ПОСЛЕ группировки; COUNT > 5 — требование ДЗ)
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

-- ============================================================
-- Часть 6. JOIN: связываем заказы с товарами (orders -> products)
-- ============================================================

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

-- ============================================================
-- Часть 7. Безопасность SQL (запросов здесь нет — пример в code/безопасность-демо.py)
-- ============================================================
-- Плохо: логин пользователя вклеивают в текст запроса конкатенацией,
-- и ввод ' OR 1=1; -- превращается в SQL, который отвечает «пароль верный»:
--      "SELECT * FROM users WHERE login = '" + login + "' AND password = '...'"
-- Хорошо: ?-placeholder — sqlite3 сам подставляет значение как данные,
-- оно остаётся текстом и SQL испортить не может:
--      SELECT * FROM users WHERE login = ? AND password = ?
-- Запуск демо: python3 code/безопасность-демо.py
