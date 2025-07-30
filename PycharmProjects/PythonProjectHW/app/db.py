import sqlite3
from datetime import datetime

DB_NAME = "operations.db"

def init_db():
    conn = sqlite3.connect(DB_NAME)
    cur = conn.cursor()
    cur.execute('''
        CREATE TABLE IF NOT EXISTS logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            operation TEXT,
            input TEXT,
            result TEXT,
            timestamp TEXT
        )
    ''')
    conn.commit()
    conn.close()

def log_operation(operation: str, input_data: str, result: str):
    conn = sqlite3.connect(DB_NAME)
    cur = conn.cursor()
    cur.execute('''
        INSERT INTO logs (operation, input, result, timestamp)
        VALUES (?, ?, ?, ?)
    ''', (operation, input_data, result, datetime.utcnow().isoformat()))
    conn.commit()
    conn.close()
