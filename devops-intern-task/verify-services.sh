#!/bin/bash

# DevOps Intern Task - Service Verification Script
# This script verifies all services are running on the correct ports

echo "🔍 DevOps Intern Task - Service Verification"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if port is accessible
check_service() {
    local name=$1
    local url=$2
    local expected_status=$3
    
    echo -n "Checking $name... "
    
    if curl -s --max-time 5 -I "$url" | head -n 1 | grep -q "$expected_status"; then
        echo -e "${GREEN}✓ WORKING${NC}"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        return 1
    fi
}

# Check Kubernetes cluster
echo -n "Checking Kubernetes cluster... "
if kubectl cluster-info &>/dev/null; then
    echo -e "${GREEN}✓ RUNNING${NC}"
else
    echo -e "${RED}✗ NOT RUNNING${NC}"
    echo "Please run: minikube start"
    exit 1
fi

# Check if pods are running
echo -n "Checking pods... "
pods_ready=$(kubectl get pods -l app=websocket-server --no-headers 2>/dev/null | grep "Running" | wc -l)
if [ "$pods_ready" -ge 2 ]; then
    echo -e "${GREEN}✓ $pods_ready PODS RUNNING${NC}"
else
    echo -e "${RED}✗ PODS NOT READY${NC}"
    kubectl get pods
    exit 1
fi

# Check HPA
echo -n "Checking HPA... "
if kubectl get hpa websocket-server-hpa &>/dev/null; then
    hpa_status=$(kubectl get hpa websocket-server-hpa --no-headers 2>/dev/null | awk '{print $4}')
    echo -e "${GREEN}✓ ACTIVE (Replicas: $hpa_status)${NC}"
else
    echo -e "${RED}✗ NOT FOUND${NC}"
fi

# Setup port-forwards if not already running
echo -e "\n📡 Setting up port-forwards..."
pkill -f "kubectl port-forward" 2>/dev/null

nohup kubectl port-forward svc/websocket-server-service 8080:8080 > /dev/null 2>&1 &
nohup kubectl port-forward svc/prometheus-service 9090:9090 > /dev/null 2>&1 &
nohup kubectl port-forward svc/grafana-service 3000:3000 > /dev/null 2>&1 &

sleep 3

# Check services
echo -e "\n🌐 Checking service endpoints..."
check_service "WebSocket Server Metrics" "http://localhost:8080/metrics" "200"
check_service "Prometheus" "http://localhost:9090" "405"
check_service "Grafana" "http://localhost:3000" "302"

# Check Grafana via NodePort
minikube_ip=$(minikube ip)
check_service "Grafana (NodePort)" "http://$minikube_ip:30000" "302"

# Summary
echo -e "\n📊 Service Summary:"
echo "===================="
echo "WebSocket Server: http://localhost:8080/metrics"
echo "Prometheus: http://localhost:9090"
echo "Grafana (Port-forward): http://localhost:3000"
echo "Grafana (NodePort): http://$minikube_ip:30000"
echo ""
echo "Login credentials for Grafana:"
echo "Username: admin"
echo "Password: admin"

# Check metrics
echo -e "\n📈 Testing WebSocket metrics..."
if curl -s http://localhost:8080/metrics | grep -q "websocket_active_connections"; then
    connections=$(curl -s http://localhost:8080/metrics | grep "websocket_active_connections" | awk '{print $2}')
    echo -e "${GREEN}✓ Metrics available - Active connections: $connections${NC}"
else
    echo -e "${RED}✗ Metrics not available${NC}"
fi

echo -e "\n🎉 Verification complete!"
echo -e "${YELLOW}You can now run load tests and view dashboards${NC}"
