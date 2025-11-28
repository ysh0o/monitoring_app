# MyApp Monitoring System

Система мониторинга веб-приложения Flask с автоматическим перезапуском при сбое.

## Что это?

Приложение на Flask, которое возвращает "Hello World!" на порту 5000.
Каждые 10 секунд скрипт проверяет, живо ли приложение.
Если приложение упадёт - скрипт его перезапустит.

## Файлы

- `app.py` - Flask-приложение
- `monitor.sh` - Bash-скрипт мониторинга
- `monitor.conf` - Конфигурация
- `myapp.service` - systemd-сервис приложения
- `myapp-monitor.service` - systemd-сервис мониторинга
- `myapp-monitor.timer` - systemd-таймер (запуск каждые 10 сек)
- `install.sh` - Скрипт установки

## Установка

```bash
sudo ./install.sh
```

Это создаст папки, скопирует файлы и включит все сервисы.

## Использование

### Проверить статус приложения
```bash
sudo systemctl status myapp.service
```

### Проверить статус мониторинга
```bash
sudo systemctl status myapp-monitor.timer
```

### Посмотреть логи мониторинга
```bash
sudo tail -f /var/log/myapp_monitor.log
```

В логах каждые 10 секунд пишется:
```
2025-11-28 20:00:30: APP IS UP
```

Если приложение упадёт:
```
2025-11-28 20:00:40: ERROR - APP IS DOWN (HTTP 000)
2025-11-28 20:00:40: APP RESTARTED
```

### Управление приложением
```bash
# Перезапустить
sudo systemctl restart myapp.service

# Остановить
sudo systemctl stop myapp.service

# Запустить
sudo systemctl start myapp.service
```

## Как это работает

1. **Flask-приложение** запускается как systemd-сервис (myapp.service)
   - Слушает на порту 5000
   - systemd перезапускает его при падении

2. **systemd-таймер** (myapp-monitor.timer) срабатывает каждые 10 секунд

3. **Скрипт мониторинга** (monitor.sh):
   - Делает HTTP-запрос к приложению
   - Если ответ не 200 - перезапускает приложение
   - Логирует всё в файл

## Конфигурация

Файл `/etc/myapp/monitor.conf`:
```bash
APP_URL="http://localhost:5000"        # URL приложения
LOG_FILE="/var/log/myapp_monitor.log"  # Файл логов
APP_SERVICE="myapp.service"            # Имя сервиса
CHECK_INTERVAL=10                      # Интервал (информационно)
```

### Изменить интервал проверки

Отредактировать `/etc/systemd/system/myapp-monitor.timer`:
```bash
sudo nano /etc/systemd/system/myapp-monitor.timer
```

Изменить `OnBootSec` и `OnUnitActiveSec` (например, на `30s`).

Перезагрузить:
```bash
sudo systemctl daemon-reload
sudo systemctl restart myapp-monitor.timer
```

## Тестирование

Проверить, что мониторинг ловит ошибки:

```bash
# 1. Останови приложение
sudo systemctl stop myapp.service

# 2. Жди 10 секунд, смотри логи
sudo tail -f /var/log/myapp_monitor.log

# Должна увидеть ошибку и перезапуск:
# ... ERROR - APP IS DOWN ...
# ... APP RESTARTED

# 3. Проверь, что приложение ожило
systemctl status myapp.service
```

## Логи

### Логи приложения
```bash
sudo journalctl -u myapp.service -f
```

### Логи мониторинга
```bash
sudo tail -f /var/log/myapp_monitor.log
```

## Удаление

```bash
# Остановить
sudo systemctl stop myapp-monitor.timer
sudo systemctl stop myapp.service

# Отключить из автозапуска
sudo systemctl disable myapp-monitor.timer
sudo systemctl disable myapp.service

# Удалить юниты
sudo rm /etc/systemd/system/myapp.service
sudo rm /etc/systemd/system/myapp-monitor.service
sudo rm /etc/systemd/system/myapp-monitor.timer

# Обновить systemd
sudo systemctl daemon-reload

# Удалить файлы
sudo rm -rf /opt/myapp
sudo rm -rf /etc/myapp
sudo rm /var/log/myapp_monitor.log
```

## Обновление

```bash
sudo ./install.sh
```
