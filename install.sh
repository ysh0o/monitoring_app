#!/bin/bash

set -e

APP_DIR="/opt/myapp"
CONFIG_DIR="/etc/myapp"
SYSTEMD_DIR="/etc/systemd/system"

echo "==========================================="
echo "Installing MyApp monitoring system"
echo "==========================================="


echo "Creating directories..."
mkdir -p "$APP_DIR"
mkdir -p "$CONFIG_DIR"

echo "Copying Flask app..."
cp app.py "$APP_DIR/app.py"

echo "Copying monitoring script..."
cp monitor.sh "$APP_DIR/monitor.sh"
chmod +x "$APP_DIR/monitor.sh"

echo "Copying  monitoring conf..."
cp monitor.conf "$CONFIG_DIR/monitor.conf"

echo "Copying systemd units..."
cp myapp.service "$SYSTEMD_DIR/myapp.service"
cp myapp-monitor.service "$SYSTEMD_DIR/myapp-monitor.service"
cp myapp-monitor.timer "$SYSTEMD_DIR/myapp-monitor.timer"

echo "Reloading systemd configuration..."
systemctl daemon-reload

echo "Starting myapp service..."
systemctl enable myapp.service
systemctl restart myapp.service

echo "Starting monitoring timer..."
systemctl enable myapp-monitor.timer
systemctl restart myapp-monitor.timer

echo "============================================"
echo "Installation completed successfully!"
echo "============================================"
echo ""
echo "Next steps:"
echo "1. Check Flask app: systemctl status myapp.service"
echo "2. Check monitoring: systemctl status myapp-monitor.timer"
echo "3. View monitoring logs: sudo tail -f /var/log/myapp_monitor.log"
echo "4. Access web app: http://192.168.0.43:5000/"
echo ""
