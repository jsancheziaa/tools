#!/bin/bash

# Variables
NODE_EXPORTER_VERSION="1.3.1"
DOWNLOAD_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
INSTALL_DIR="/usr/local/bin"
SERVICE_FILE="/etc/systemd/system/node_exporter.service"
USER="node_exporter"

# Update and install prerequisites
# sudo apt-get update && sudo apt-get install -y wget tar

# Download and extract Node Exporter
wget $DOWNLOAD_URL -O node_exporter.tar.gz
tar xvf node_exporter.tar.gz

# Move binary to installation directory
sudo cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter $INSTALL_DIR

# Create a system user for Node Exporter
sudo useradd --no-create-home --shell /bin/false $USER

# Change ownership of the binary
sudo chown $USER:$USER $INSTALL_DIR/node_exporter

# Create the systemd service file
sudo tee $SERVICE_FILE > /dev/null <<EOL
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=$USER
Group=$USER
ExecStart=$INSTALL_DIR/node_exporter \
  --collector.mountstats \
  --collector.logind \
  --collector.processes \
  --collector.ntp \
  --collector.systemd \
  --collector.tcpstat \
  --collector.wifi
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, start and enable the service
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Check the service logs
# journalctl -u node_exporter -f
