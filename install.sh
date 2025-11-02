#!/bin/bash
set -e

PROJECT_DIR="/opt/openvpn_manager"
REPO_URL="https://github.com/chakpimi-lab/op-mg2.git"
VENV_DIR="$PROJECT_DIR/venv"
SERVICE_NAME="openvpn_manager"
PORT=8080

echo "[INFO] Cloning repository..."
rm -rf "$PROJECT_DIR"
git clone $REPO_URL "$PROJECT_DIR"

echo "[INFO] Installing OpenVPN WebPanel Manager..."
apt update -y
apt install -y python3 python3-venv python3-pip rsync git

cd "$PROJECT_DIR"
python3 -m venv "$VENV_DIR"
"$VENV_DIR/bin/pip" install --upgrade pip >/dev/null 2>&1 || true
"$VENV_DIR/bin/pip" install -r "$PROJECT_DIR/requirements.txt" >/dev/null 2>&1

mkdir -p "$PROJECT_DIR/vpn_configs"
chmod -R 750 "$PROJECT_DIR"

cat > /etc/systemd/system/${SERVICE_NAME}.service <<EOF
[Unit]
Description=OpenVPN Manager (Flask + gunicorn)
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=${PROJECT_DIR}
Environment="PATH=${VENV_DIR}/bin"
ExecStart=${VENV_DIR}/bin/gunicorn --bind 0.0.0.0:${PORT} --workers 3 --timeout 120 app:app
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now ${SERVICE_NAME}.service

if command -v ufw >/dev/null 2>&1; then
  ufw allow ${PORT}/tcp || true
fi

echo "[SUCCESS] Installed successfully!"
echo "Access panel: http://$(hostname -I | awk '{print $1}'):${PORT}"
echo "Default credentials: admin / admin123"

fi
echo "[SUCCESS] Installed successfully!"
echo "Access panel: http://$(hostname -I | awk '{print $1}'):${PORT}"
echo "Default credentials: admin / admin123"
