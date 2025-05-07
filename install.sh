#!/bin/bash

# Set variables
PROM_VERSION="2.52.0"
USER_HOME="/home/$(whoami)"
INSTALL_DIR="/opt/prometheus"

# Create Prometheus user
sudo useradd --no-create-home --shell /bin/false prometheus

# Download Prometheus
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz

# Extract
tar xvf prometheus-${PROM_VERSION}.linux-amd64.tar.gz

# Move binaries
sudo mkdir -p ${INSTALL_DIR}
sudo cp prometheus-${PROM_VERSION}.linux-amd64/prometheus ${INSTALL_DIR}
sudo cp prometheus-${PROM_VERSION}.linux-amd64/promtool ${INSTALL_DIR}

# Move config
sudo mkdir -p /etc/prometheus
sudo cp prometheus-${PROM_VERSION}.linux-amd64/prometheus.yml /etc/prometheus/
sudo cp -r prometheus-${PROM_VERSION}.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-${PROM_VERSION}.linux-amd64/console_libraries /etc/prometheus

# Create systemd service
sudo bash -c 'cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus Monitoring
After=network.target

[Service]
User=prometheus
ExecStart=/opt/prometheus/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF'

# Create data dir
sudo mkdir -p /var/lib/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus ${INSTALL_DIR}

# Enable and start
sudo systemctl daemon-reexec
sudo systemctl enable prometheus
sudo systemctl restart prometheus

