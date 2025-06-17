#!/bin/bash

# Variables
GRAFANA_ADMIN_USER="admin"
GRAFANA_ADMIN_PASSWORD="Granada@2025"
PROMETHEUS_TARGET="node-exporter:9100"
DATASOURCE_URL="http://192.168.200.187:18027"
DASHBOARD_ID="13659"
DASHBOARD_URL="https://grafana.com/api/dashboards/${DASHBOARD_ID}/revisions/1/download"

# Crear estructura de carpetas
mkdir -p grafana/provisioning/dashboards
mkdir -p grafana/provisioning/datasources
mkdir -p prometheus
mkdir -p grafana/dashboards

# Crear docker-compose.yml
cat > docker-compose.yml <<EOF
version: '3.8'

services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  node-exporter:
    image: prom/node-exporter
    ports:
      - "9100:9100"

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=${GRAFANA_ADMIN_USER}
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD}
    volumes:
      - ./grafana/provisioning:/etc/grafana/provisioning
      - ./grafana/dashboards:/var/lib/grafana/dashboards
      - grafana-data:/var/lib/grafana

volumes:
  grafana-data:
EOF

# Crear prometheus.yml
cat > prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['prometheus:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
EOF

# Crear datasource.yaml para Grafana
cat > grafana/provisioning/datasources/datasource.yaml <<EOF
apiVersion: 1

datasources:
  - name: 'MyDataSource'
    type: prometheus
    access: proxy
    url: ${DATASOURCE_URL}
    isDefault: true
EOF

# Crear dashboard.yaml para Grafana
cat > grafana/provisioning/dashboards/dashboard.yaml <<EOF
apiVersion: 1

providers:
  - name: 'Default'
    orgId: 1
    folder: ''
    type: file
    options:
      path: /var/lib/grafana/dashboards
      foldersFromFilesStructure: true
EOF

# Descargar dashboard JSON
curl -o grafana/dashboards/dashboard-${DASHBOARD_ID}.json ${DASHBOARD_URL}

# Lanzar los servicios
docker compose up -d

echo "✅ Grafana, Prometheus y Node Exporter están desplegados."
echo "🔗 Accede a Grafana: http://localhost:3000 (Usuario: ${GRAFANA_ADMIN_USER}, Contraseña: ${GRAFANA_ADMIN_PASSWORD})"
