# infrastructure_monitoring_with_grafana_prometheus

### Why Prometheus and Grafana?

### Work Flow

<img src="https://github.com/ibshafique/infrastructure_monitoring_with_grafana_prometheus/blob/main/assets/workflow.png">

### Special Features





# Installing The Software Stack

Please make sure to switch to root user for installing the Prometheus-Grafana software stack. 

### How To Install Prometheus

To install Prometheus, run the script using the following command:

```bash prometheus.sh  ```

### How To Install Grafana

To install Grafana, run the script using the following command:

```bash grafana.sh  ```

### How To Install Node Exporter
Node Exporter has to be installed in machines which are going to be monitored with the Grafana-Prometheus stack.

To install Node Exporter, run the script using the following command:

```bash node_exporter.sh  ```

# Setting Up The Stack

### Configuring Prometheus

/etc/promtheus/prometheus.yml

```
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  #port: 9000 

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
#
scrape_configs:
  - job_name: "Environment-1"
    static_configs:
      - targets: ["10.10.10.1:9100"]          #env1-host1
        labels:
                instance: 'env1-host1'
      - targets: ["10.10.10.2:9100"]          #env1-host2
        labels:
                instance: 'env1-host2'

  - job_name: "Environment-2"
    static_configs:
      - targets: ["10.10.20.1:9100"]          #env2-host1
        labels:
                instance: 'env2-host1'
      - targets: ["10.10.20.2:9100"]          #env2-host2
        labels:
                instance: 'env2-host2'
  - job_name: 'Env-1 TCP Port Check'
    metrics_path: /probe
    params:
        module: [tcp_connect] 
    static_configs:
      - targets: ["10.10.10.1:9100"]          #env1-host1
        labels:
                instance: "env1-host1:9100"
      - targets: ["10.10.20.1:9100"]          #env2-host1
        labels:
                instance: 'env2-host1:9100'
    relabel_configs:
          - source_labels: [__address__]
            target_label: __param_target
          - target_label: __address__
            replacement: 172.0.0.1:9115

  - job_name: 'Website Monitoring'
    metrics_path: /probe
    params:
        module: [http_2xx]
    static_configs:
          - targets:
            - https://www.abc.com
            - https://www.xyz.com
    relabel_configs:
          - source_labels: [__address__]
            target_label: __param_target
          - source_labels: [__param_target]
            target_label: instance
          - target_label: __address__
            replacement: 172.0.0.1:9115
```


/etc/systemd/system/prometheus.service

```
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml --storage.tsdb.path /var/lib/prometheus/ --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries --web.listen-address=0.0.0.0:9000 --storage.tsdb.retention.time=30d
```


### Configuring Grafana

Path of configuration file for Grafana:

```/etc/grafana/grafana.ini```

Change the following parameters:

```http_addr = ```

```http_port = ```

```root_url = ```

```
[smtp]
enabled = true
host = localhost:25
;user =
# If the password contains # or ; you have to wrap it with triple quotes. Ex """#password;"""
;password =
;cert_file =
;key_file =
;skip_verify = false
from_address = 
from_name = GrafanaNinja
# EHLO identity in SMTP dialog (defaults to instance_name)
;ehlo_identity = dashboard.example.com
# SMTP startTLS policy (defaults to 'OpportunisticStartTLS')
;startTLS_policy = NoStartTLS
```

```
[database]
# You can configure the database connection by specifying type, host, name, user and password
# as separate properties or as on string using the url properties.

# Either "mysql", "postgres" or "sqlite3", it's your choice
type = sqlite3
wal = true
;host = 127.0.0.1:3306
;name = grafana
;user = root
```


# Accessing The WebUIs

The Prometheus WebUI can be accessed using:

```http://ipaddress:9000/graph```

The Grafana WebUI can be accessed using:

```http://ipaddress:3000/login```


The Default Admin ID-Password for logging into Grafana is:

Username : admin

Password : admin


# Backup And Restore
