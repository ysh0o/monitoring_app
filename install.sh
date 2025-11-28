#!/bin/bash
# install.sh - Скрипт автоматизации установки приложения и системы мониторинга

set -e

# Определяем пути установки
APP_DIR="/opt/myapp"              # Папка приложения и скрипта мониторинга
CONFIG_DIR="/etc/myapp"           # Папка конфигов
SYSTEMD_DIR="/etc/systemd/system" # Папка systemd-юнитов

# Красивый вывод - начало установки
echo "==========================================="
echo "Installing MyApp monitoring system"
echo "==========================================="
echo ""

# Устанавливаем необходимые зависимости
echo "Installing dependencies..."
apt-get update
apt-get install -y curl python3-flask

# Создаём необходимые папки (-p: не ошибаться, если уже существуют)
echo "Creating directories..."
mkdir -p "$APP_DIR"
mkdir -p "$CONFIG_DIR"

# Копируем Flask-приложение
echo "Copying Flask app..."
cp app.py "$APP_DIR/app.py"

# Копируем скрипт мониторинга и делаем его исполняемым
echo "Copying monitoring script..."
cp monitor.sh "$APP_DIR/monitor.sh"
chmod +x "$APP_DIR/monitor.sh"

# Копируем конфиг мониторинга
echo "Copying monitoring conf..."
cp monitor.conf "$CONFIG_DIR/monitor.conf"

# Копируем все systemd-юниты
echo "Copying systemd units..."
cp myapp.service "$SYSTEMD_DIR/myapp.service"
cp myapp-monitor.service "$SYSTEMD_DIR/myapp-monitor.service"
cp myapp-monitor.timer "$SYSTEMD_DIR/myapp-monitor.timer"

# Перечитываем конфиг systemd (чтобы узнал о новых юнитах)
echo "Reloading systemd configuration..."
systemctl daemon-reload

# Запускаем основное приложение
echo "Starting myapp service..."
systemctl enable myapp.service    # Добавляем в автозапуск
systemctl restart myapp.service   # Запускаем (или перезапускаем)

# Запускаем таймер мониторинга
echo "Starting monitoring timer..."
systemctl enable myapp-monitor.timer    # Добавляем в автозапуск
systemctl restart myapp-monitor.timer   # Запускаем (или перезапускаем)

# Красивый вывод - конец установки
echo "============================================"
echo "Installation completed successfully!"
echo "============================================"
echo ""
echo "Next steps:"
echo "1. Check Flask app: systemctl status myapp.service"
echo "2. Check monitoring: systemctl status myapp-monitor.timer"
echo "3. View monitoring logs: sudo tail -f /var/log/myapp_monitor.log"
echo "4. Access web app: http://localhost:5000/"
echo ""
