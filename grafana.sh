#!/bin/bash
#==============================================================================#
#title           :grafana.sh                                                   #
#description     :This Bash script will automatically install Grafana          #
#date            :05-08-2023                                                   #
#email           :ibshafique@gmail.com                                         #
#==============================================================================#
# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

### Installing Grafana
echo "installing required packages for grafana"
yum localinstall -y grafana-enterprise-10.0.3-1.x86_64.rpm

# Starting Grafana
echo "starting grafana.service"
systemctl daemon-reload
systemctl enable --now grafana-server.service

# Checking if grafana.service is running
status=$(systemctl is-active grafana-server)
# Print status message
if [[ $status == "active" ]]; then
    echo "Grafana is running okay."
    curl localhost:3000
else
    echo "Grafana is not running or in an unknown state."
fi