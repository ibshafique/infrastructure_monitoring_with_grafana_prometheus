#!/bin/bash
#==============================================================================#
#title           :prometheus.sh                                                #
#description     :This Bash script will automatically install Prometheus       #
#date            :05-08-2023                                                   #
#email           :ibshafique@gmail.com                                         #
#==============================================================================#
# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

package_manager="yum"
firewall-cmd --permanent --add-port=3000/tcp --add-port=9090/tcp
firewall-cmd --reload

# Install required packages
$package_manager update -y
$package_manager install -y wget tar

# Prerequisites 
adduser --no-create-home --system --shell /sbin/nologin prometheus
groupadd prometheus
mkdir /var/lib/prometheus /etc/prometheus/

# Download Prometheus
prometheus_version="2.36.2"
instance_ip=$(hostname --all-ip-addresses | cut -d ' ' -f 1)

# Extract the downloaded tarball
echo "Extracting Prometheus tarball..."
tar xzf ./prometheus-$prometheus_version.linux-amd64.tar.gz -C /tmp/

# Copy required files
echo "Copying Prometheus files..."
cp -r /tmp/prometheus-$prometheus_version.linux-amd64/{prometheus,promtool} /usr/local/bin/
cp -r /tmp/prometheus-$prometheus_version.linux-amd64/{consoles,console_libraries,prometheus.yml} /etc/prometheus

# Create Prometheus configuration file
echo "setting up the prometheus.yml config file"

cat << EOF > /etc/prometheus/prometheus.yml
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label "job=<job_name>" to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]
EOF

# Changing ownership of prometheus directory
echo "changing ownership of some relevant directories"
chown prometheus:prometheus -R /etc/prometheus
chown prometheus:prometheus -R /var/lib/prometheus
chown prometheus:prometheus -R /usr/local/bin/{prometheus,promtool}

#create a systemd service file to manage the Prometheus service via systemd
echo "creating systemd service for prometheus"
cat << EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now prometheus

# Checking if prometheus.service is running
status=$(systemctl is-active prometheus)
# Print status message
if [[ $status == "active" ]]; then
    echo "Prometheus is running okay."
    curl localhost:9090
else
    echo "Prometheus is not running or in an unknown state."
fi
