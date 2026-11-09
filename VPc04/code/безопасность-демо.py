"""Мини-демо ДЗ VPc04: небезопасная конкатенация SQL против параметризации.

Запуск: python3 code/безопасность-демо.py
Вывод показывает: сломанная строка собирает чужой SQL,
параметризованный запрос — нет.

Правило: пользовательский ввод НИКОГДА не склеиваем с текстом запроса —
едет отдельно, заменяя каждый '?' по порядку.
"""
import sqlite3


# --- ВАРИАНТ 1 — УЯЗВИМЫЙ (код для понимания, в работу НЕ запускать) ---
def unsafe_login_query(login: str, password: str) -> str:
    """Собирает SQL строкой из пользовательского ввода.

    ОСТОРОЖНО, так НЕ надо!
    """
    return ("SELECT * FROM users "
            f"WHERE login = '{login}' AND password = '{password}'")


# --- ВАРИАНТ 2 — ЗАЩИЩЁННЫЙ (параметризация, placeholders '?') ---------
def safe_login_check(
    conn: sqlite3.Connection, login: str, password: str
) -> bool:
    """Ввод едет ОТДЕЛЬНО от SQL.

    Подставить его в запрос и выполнить — невозможно.
    """
    cur = conn.execute(
        "SELECT 1 FROM users WHERE login = ? AND password = ?",
        (login, password),
    )
    return cur.fetchone() is not None


def main() -> None:
    attacker_input = "' OR 1=1; --"

    # --- что получает уязвимый код (демонстрация строки, НЕ выполнение) ---
    print("Уязвимый запрос склеит строку ввода прямо в SQL:")
    print("  ", unsafe_login_query(attacker_input, "12345"))

    # --- параметризация на реальной учебной базе ---
    conn = sqlite3.connect(":memory:")
    conn.execute("CREATE TABLE users (login TEXT, password TEXT)")
    conn.execute("INSERT INTO users VALUES ('mikhail', '12345')")

    print("Безопасный вход (нормальные данные) =>",
          safe_login_check(conn, "mikhail", "12345"))
    print("Безопасный вход (атака ' OR 1=1; --) =>",
          safe_login_check(conn, attacker_input, "whatever"))


if __name__ == "__main__":
    main()
