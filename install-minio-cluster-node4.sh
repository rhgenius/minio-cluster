#!/bin/bash

# Variables
MINIO_VERSION="RELEASE.2024-05-10T01-41-38Z"
MINIO_USER="minio-user"
MINIO_GROUP="minio-user"
MINIO_DATA_DIR="/mnt/data"
MINIO_DISTRIBUTED_NODES="http://node1/mnt/data http://node2/mnt/data http://node3/mnt/data http://node4/mnt/data"
MINIO_ACCESS_KEY="minioadmin"
MINIO_SECRET_KEY="minioadmin"

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y wget

# Create MinIO user and group
sudo adduser --system --group $MINIO_USER || true

# Create data directory
sudo mkdir -p $MINIO_DATA_DIR
sudo chown $MINIO_USER:$MINIO_GROUP $MINIO_DATA_DIR

# Download MinIO binary
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio.${MINIO_VERSION} -O minio
chmod +x minio
sudo mv minio /usr/local/bin/minio

# Create systemd service
sudo tee /etc/systemd/system/minio.service > /dev/null <<EOF
[Unit]
Description=MinIO
After=network.target

[Service]
User=$MINIO_USER
Group=$MINIO_GROUP
ExecStart=/usr/local/bin/minio server $MINIO_DISTRIBUTED_NODES --console-address ":9001"
Environment="MINIO_ROOT_USER=$MINIO_ACCESS_KEY"
Environment="MINIO_ROOT_PASSWORD=$MINIO_SECRET_KEY"
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start MinIO
sudo systemctl daemon-reload
sudo systemctl enable minio
sudo systemctl start minio

echo "MinIO node4 installation complete."