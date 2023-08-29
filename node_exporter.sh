#!/bin/bash
#==============================================================================#
#title           :node_exporter.sh                                             #
#description     :This Bash script will automatically install Node Exporter    #
#date            :05-08-2023                                                   #
#email           :ibshafique@gmail.com                                         #
#==============================================================================#
# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

# Installing Node Exporter
useradd -rs /bin/false node_exporter
echo "downloading node_exporter-1.6.1"
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
echo "extracting the packages"
tar -xzvf node_exporter-1.6.1.linux-amd64.tar.gz 
mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Creating Systemd File
cat << EOF > /etc/systemd/system/node-exporter.service
#Node Exporter service file — /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Starting Node Exporter
echo "starting node_exporter.service"
systemctl daemon-reload
systemctl enable --now node-exporter.service

# Checking if node_exporter.service is running
status=$(systemctl is-active node-exporter.service)
# Print status message
if [[ $status == "active" ]]; then
    echo "Node Exporter is running okay."
    curl localhost:9100
else
    echo "Node Exporter is not running or in an unknown state."
fi
