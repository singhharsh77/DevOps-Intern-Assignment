#!/bin/bash

# Setup script for Edge Device Observability Stack
# DevOps Intern Assignment - 10xConstruction

set -e

echo "=========================================="
echo "Edge Device Observability Stack Setup"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is installed
echo -n "Checking for Docker... "
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗${NC}"
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi
echo -e "${GREEN}✓${NC}"

# Check if Docker Compose is installed
echo -n "Checking for Docker Compose... "
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}✗${NC}"
    echo "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi
echo -e "${GREEN}✓${NC}"

# Check if Docker daemon is running
echo -n "Checking if Docker is running... "
if ! docker info &> /dev/null; then
    echo -e "${RED}✗${NC}"
    echo "Docker daemon is not running. Please start Docker first."
    exit 1
fi
echo -e "${GREEN}✓${NC}"

echo ""
echo "Creating required directories..."

# Create directories
mkdir -p grafana-provisioning/datasources
mkdir -p grafana-provisioning/dashboards
mkdir -p vm-data
mkdir -p grafana-data

echo -e "${GREEN}✓${NC} Directories created"

echo ""
echo "Creating Grafana datasource configuration..."

# Create datasource configuration
cat > grafana-provisioning/datasources/datasource.yml << 'EOF'
apiVersion: 1

datasources:
  - name: VictoriaMetrics
    type: prometheus
    access: proxy
    url: http://victoriametrics:8428
    isDefault: true
    editable: false
    jsonData:
      httpMethod: POST
      timeInterval: 15s
EOF

echo -e "${GREEN}✓${NC} Datasource configuration created"

echo ""
echo "Creating Grafana dashboard provider..."

# Create dashboard provider
cat > grafana-provisioning/dashboards/dashboard-provider.yml << 'EOF'
apiVersion: 1

providers:
  - name: 'Edge Dashboards'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 30
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF

echo -e "${GREEN}✓${NC} Dashboard provider created"

echo ""
echo "Setting proper permissions..."

# Set permissions (important for volumes)
chmod -R 755 grafana-provisioning
chmod -R 777 vm-data
chmod -R 777 grafana-data

echo -e "${GREEN}✓${NC} Permissions set"

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Start the stack:    docker-compose up -d"
echo "  2. Wait 30 seconds for services to initialize"
echo "  3. Access services:"
echo "     - Sensor:           http://localhost:8000/metrics"
echo "     - VictoriaMetrics:  http://localhost:8428"
echo "     - Grafana:          http://localhost:3000"
echo "                         (username: admin, password: admin)"
echo ""
echo "Quick commands:"
echo "  - Check status:   docker-compose ps"
echo "  - View logs:      docker-compose logs -f"
echo "  - Stop services:  docker-compose down"
echo "  - Memory usage:   docker stats --no-stream"
echo ""
echo "For more commands, run: make help"
echo ""
echo -e "${GREEN}Happy monitoring! 🚀${NC}"