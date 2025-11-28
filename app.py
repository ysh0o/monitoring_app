#!/usr/bin/env python3
# app.py - Простое Flask-приложение, возвращающее "Hello World!"

from flask import Flask

# Создаём объект приложения Flask
app = Flask(__name__)

# Маршрут "/" - обработчик главной страницы
@app.route("/")
def hello():
    return "Hello World!"

# Запуск приложения
if __name__ == "__main__":
    # Слушаем на всех интерфейсах (0.0.0.0) чтобы было доступно с других машин
    # Порт 5000 - стандартный для Flask
    app.run(host="0.0.0.0", port=5000)
