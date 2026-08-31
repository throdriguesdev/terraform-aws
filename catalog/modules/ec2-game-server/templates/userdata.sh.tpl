#!/bin/bash
set -euo pipefail

# Dependencies for SteamCMD (requires 32-bit glibc)
dnf install -y glibc.i686 libstdc++.i686 wget tar

# Dedicated user
useradd -m -s /bin/bash steamuser

# SteamCMD
mkdir -p /home/steamuser/steamcmd
wget -q -O /tmp/steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzf /tmp/steamcmd.tar.gz -C /home/steamuser/steamcmd
chown -R steamuser:steamuser /home/steamuser/steamcmd

# Project Zomboid dedicated server (b42 branch — remove -beta flag once b42 is default)
runuser -l steamuser -c '
  /home/steamuser/steamcmd/steamcmd.sh \
    +force_install_dir /home/steamuser/pzserver \
    +login anonymous \
    +app_update 380870 -beta b42 validate \
    +quit
'

cat > /etc/systemd/system/pzserver.service << UNIT
[Unit]
Description=Project Zomboid Dedicated Server (b42)
After=network.target

[Service]
Type=simple
User=steamuser
WorkingDirectory=/home/steamuser/pzserver
ExecStart=/home/steamuser/pzserver/start-server.sh -servername ${server_name} -adminpassword ${admin_password}
Restart=on-failure
RestartSec=15

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable pzserver
systemctl start pzserver
