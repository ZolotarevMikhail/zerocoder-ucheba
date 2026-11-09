-- Шаг 2. Создаём таблицы products и orders (как на уроке).

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

-- Контроль: должны быть созданы обе таблицы
SELECT name FROM sqlite_master WHERE type='table';
