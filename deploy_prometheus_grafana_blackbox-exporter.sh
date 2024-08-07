#!/bin/bash

# Create directories
mkdir -p blackbox_exporter grafana prometheus
mkdir -p prometheus/data

# Create and write content to the blackbox.yml file
cat <<EOL > blackbox_exporter/blackbox.yml
modules:
  http_2xx:
    prober: http
    timeout: 5s
    http:
      valid_http_versions: ["HTTP/1.1", "HTTP/2"]
      method: GET
      fail_if_ssl: false
      fail_if_not_ssl: false
      valid_status_codes: []
      follow_redirects: true
      preferred_ip_protocol: "ip4"
EOL

# Create and write content to the grafana.ini file
cat <<EOL > grafana/grafana.ini
[server]
http_port = 3000

[security]
admin_user = admin
admin_password = admin
EOL

# Create and write content to the prometheus.yml file
cat <<EOL > prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
    
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
          - https://spsrcXX.iaa.csic.es/

    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: blackbox_exporter:9115
EOL

# Create and write content to the docker-compose.yml file
cat <<EOL > docker-compose.yml
version: '3.7'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - ./prometheus/data:/prometheus
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    volumes:
      - ./grafana/grafana.ini:/etc/grafana/grafana.ini
      - grafana_data:/var/lib/grafana
    ports:
      - "3000:3000"

  blackbox_exporter:
    image: prom/blackbox-exporter:latest
    container_name: blackbox_exporter
    volumes:
      - ./blackbox_exporter/blackbox.yml:/etc/blackbox_exporter/config.yml
    ports:
      - "9115::9115"
    command:
      - '--config.file=/etc/blackbox_exporter/config.yml'

volumes:
  grafana_data:
    driver: local
EOL

echo "Directories and files created successfully."
