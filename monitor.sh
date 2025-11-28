#!/bin/bash
# monitor.sh - Скрипт мониторинга веб-приложения
# Проверяет доступность приложения по HTTP и перезапускает при сбое

# Путь к конфигурационному файлу
CONFIG_FILE="/etc/myapp/monitor.conf"

# Проверяем, существует ли конфиг-файл
if [ -f "$CONFIG_FILE" ]; then
    # Загружаем переменные из конфига (APP_URL, LOG_FILE, APP_SERVICE)
    source "$CONFIG_FILE"
else
    # Если конфига нет - выводим ошибку в stderr и выходим
    echo "Config file $CONFIG_FILE not found" >&2
    exit 1
fi

# Получаем текущее время для логов
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Делаем HTTP-запрос к приложению и берём только код ответа
# -s: тихий режим (без прогресс-бара)
# -o /dev/null: не сохраняем тело ответа
# -w "%{http_code}": выводим только HTTP-код (200, 500, и т.д.)
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL")

# Проверяем, равен ли код ответа 200 (OK)
if [ "$RESPONSE" != "200" ]; then
    # Приложение не отвечает нормально - логируем ошибку
    echo "$TIMESTAMP: ERROR - APP IS DOWN (HTTP $RESPONSE)" >> "$LOG_FILE"
    
    # Перезапускаем сервис приложения
    systemctl restart "$APP_SERVICE"
    
    # Логируем факт перезапуска
    echo "$TIMESTAMP: APP RESTARTED" >> "$LOG_FILE"
else
    # Приложение отвечает нормально - логируем статус
    echo "$TIMESTAMP: APP IS UP" >> "$LOG_FILE"
fi
