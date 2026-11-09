"""ДЗ VPc04: наполнение созданных таблиц товарами и заказами.

Порядок работы (как в уроке):
1) таблицы products и orders создаются руками в DBeaver (CREATE TABLE);
2) этот скрипт только ДОБАВЛЯЕТ данные: >=100 товаров + заказы.

Запуск: python3 code/seed.py   (базу таблиц должен видеть — vpvc04/learning.db)
Если таблиц нет — скрипт подскажет, что сначала создать их в DBeaver.

Вставки — параметризованные (знаки '?'), как требует ДЗ по безопасности.
"""
import random
import sqlite3
from pathlib import Path

random.seed(42)  # воспроизводимость: у всех одинаковые данные

DB_PATH = Path(__file__).resolve().parent.parent / "learning.db"

CATEGORY_GOODS = {
    "Гантели": [
        "гантель разборная 16 кг",
        "гантель наборная 24 кг",
        "штанга олимпийская",
        "гриф W-образный",
    ],
    "Коврики": [
        "коврик для йоги 6 мм",
        "коврик для йоги 10 мм",
        "матрас для гимнастики",
        "пенка складная",
    ],
    "Мячи": [
        "мяч футбольный №5",
        "мяч баскетбольный №7",
        "мяч волейбольный",
        "медбол 8 кг",
        "мяч для фитнеса 55 см",
    ],
    "Бег": [
        "гантевые беговые утяжелители",
        "степпер домашний",
        "скакалка скоростная",
        "бутылка для бега 750 мл",
    ],
    "Эспандеры": [
        "эспандер кистевой",
        "резинка для растяжки 15 кг",
        "петельный эспандер",
        "эспандер восьмёрка",
    ],
    "Аксессуары": [
        "ремень тяжелоатлета",
        "наколенники волейбольные",
        "перчатки боксёрские",
        "бутылка для воды 1 л",
    ],
}

N_PRODUCTS = 120
N_ORDERS = 48


def make_sku(product_index: int) -> str:
    """Стабильный уникальный артикул вида SP-0001."""
    return f"SP-{product_index:04d}"


def generate_products() -> list[dict]:
    """Собираем >=100 спортивных товаров:

    имя, описание, категория, цена, SKU.
    """
    rows = []
    for i in range(1, N_PRODUCTS + 1):
        category = random.choice(list(CATEGORY_GOODS))
        base_name = random.choice(CATEGORY_GOODS[category])
        name = (f"{base_name.title()} "
                f"{random.choice(['Про', 'Лайт', 'Спорт', 'Эко'])}")
        description = (
            f"{base_name.capitalize()} для тренировок"
            f" в категории '{category}'. "
            f"Прочный материал, подходит для дома и зала."
        )
        price = round(random.uniform(150, 15000), 2)
        rows.append({
            "name": name, "description": description,
            "category": category, "price": price, "sku": make_sku(i),
        })
    return rows


def check_tables(conn: sqlite3.Connection) -> None:
    """Проверяем, что tables products и orders уже созданы (Этап 1)."""
    existing = {
        row[0]
        for row in conn.execute(
            "SELECT name FROM sqlite_master WHERE type='table'"
        )
    }
    missing = {"products", "orders"} - existing
    if missing:
        raise SystemExit(
            f"Нет таблиц: {', '.join(sorted(missing))}. "
            f"Сначала создайте их в DBeaver (Этап 1 — CREATE TABLE)."
        )


def insert_products(cur: sqlite3.Cursor, rows: list[dict]) -> None:
    """Массовая параметризованная вставка товаров (executemany)."""
    cur.executemany(
        "INSERT INTO products (name, description, category, price, sku) "
        "VALUES (?, ?, ?, ?, ?)",
        [
            (r["name"], r["description"], r["category"],
             r["price"], r["sku"])
            for r in rows
        ],
    )


def insert_orders(cur: sqlite3.Cursor) -> None:
    """Заказы на случайные товары (продукт по id, параметризованно)."""
    product_ids = [
        row[0] for row in cur.execute("SELECT id FROM products").fetchall()
        if row[0] is not None
    ]
    data = []
    for _ in range(N_ORDERS):
        data.append((
            random.choice(product_ids),
            random.randint(1, 3),
            f"2026-{random.randint(9, 12):02d}-{random.randint(1, 28):02d}",
        ))
    cur.executemany(
        "INSERT INTO orders (product_id, quantity, order_date) "
        "VALUES (?, ?, ?)", data
    )


def main() -> None:
    if not DB_PATH.exists():
        raise SystemExit(
            f"Файл базы не найден: {DB_PATH}. "
            f"Сначала подключите базу в DBeaver (Этап 1) — "
            f"файл создаст DBeaver."
        )
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON")
    try:
        check_tables(conn)
        cur = conn.cursor()
        fill = cur.execute("SELECT COUNT(*) FROM products").fetchall()[0][0]
        if fill:
            raise SystemExit(
                f"products уже наполнен ({fill} строк) — "
                f"скрипт добавляет данные в пустые таблицы."
            )
        rows = generate_products()
        insert_products(cur, rows)
        insert_orders(cur)
        conn.commit()
        totals = cur.execute(
            "SELECT (SELECT COUNT(*) FROM products),"
            " (SELECT COUNT(*) FROM orders)"
        ).fetchone()
        print(f"База: {DB_PATH}")
        print(f"Товаров: {totals[0]} | Заказов: {totals[1]}")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
