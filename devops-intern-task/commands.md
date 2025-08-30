# DevOps Intern Task - Complete Command Reference

This document provides a step-by-step command reference for containerizing, deploying, and monitoring the WebSocket server application. Each tool operates in its dedicated terminal for better organization and monitoring.

## Prerequisites

Ensure you have the following tools installed:
- Docker
- Kubernetes cluster (minikube recommended)
- kubectl
- k6 (for load testing)

## Multi-Terminal Setup Approach

For better monitoring and organization, this guide uses dedicated terminals for each tool:

**Terminal 1: Docker Operations**
**Terminal 2: Kubernetes Operations** 
**Terminal 3: WebSocket Server & Metrics**
**Terminal 4: Prometheus Monitoring**
**Terminal 5: Grafana Dashboard**
**Terminal 6: Load Testing & Monitoring**

## Quick Verification Script

A verification script has been provided to quickly check all services:

```bash
# Make script executable
chmod +x verify-services.sh

# Run verification
./verify-services.sh
```

This script will:
- Check if minikube cluster is running
- Verify all pods are ready
- Check HPA status
- Set up port-forwards automatically
- Test all service endpoints
- Display service URLs and credentials

## Phase 1: Local Development Setup

### 1.1 Install Dependencies and Run Locally

```bash
# Navigate to server directory
cd server

# Install dependencies
npm install

# Start the server locally (for testing)
node index.js
```

The server will be available at `ws://localhost:8080` and metrics at `http://localhost:8080/metrics`

### 1.2 Run Load Test (Optional - for local testing)

```bash
# Install k6 if not already installed
# On macOS: brew install k6
# On Ubuntu/Debian: sudo apt update && sudo apt install k6

# Run the load test
k6 run loadtest/websocket-test.js
```

## Phase 2: Docker Containerization

### Terminal 1: Docker Operations
```bash
# Navigate to server directory  
cd server

# Build the Docker image
docker build -t websocket-server:latest .

# Verify the image was created
docker images | grep websocket-server

# Check Docker system info
docker system df

# Monitor Docker containers (keep this terminal open)
watch "docker ps -a | grep websocket"
```

### 2.2 Run Container Locally (Optional - for testing)

```bash
# In Terminal 1: Run the container
docker run -p 8080:8080 websocket-server:latest

# In another terminal: Test the containerized application
curl http://localhost:8080/metrics
```

### 2.3 Prepare Image for Kubernetes

If using minikube:
```bash
# Use minikube's Docker daemon
eval $(minikube docker-env)

# Rebuild the image in minikube's Docker environment
docker build -t websocket-server:latest server/
```

If using a remote registry (e.g., Docker Hub):
```bash
# Tag the image
docker tag websocket-server:latest your-registry/websocket-server:latest

# Push to registry
docker push your-registry/websocket-server:latest

# Update the image name in k8s/deployment.yaml accordingly
```

## Phase 3: Kubernetes Deployment

### Terminal 2: Kubernetes Operations
```bash
# Keep this terminal dedicated for Kubernetes monitoring
echo "=== KUBERNETES TERMINAL ==="
```

### 3.1 Start Kubernetes Cluster

```bash
# In Terminal 2: If using minikube
minikube start

# Enable necessary addons
minikube addons enable ingress
minikube addons enable metrics-server

# Verify cluster is running
kubectl cluster-info
```

### 3.2 Deploy the Application

```bash
# In Terminal 2: Navigate to project root
cd ..

# Apply all Kubernetes manifests
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
kubectl apply -f k8s/hpa.yaml
```

### 3.3 Verify Deployment

```bash
# In Terminal 2: Continuous monitoring commands
echo "All Pods:" && kubectl get pods
echo "Deployments:" && kubectl get deployments
echo "Services:" && kubectl get services
echo "HPA Status:" && kubectl get hpa
echo "Ingress:" && kubectl get ingress

# Watch resources in real-time (optional)
watch kubectl get pods,svc,deployment,hpa
```

### 3.4 Test the Application

```bash
# In Terminal 2: Get minikube IP
minikube ip

# Add entry to /etc/hosts (replace <MINIKUBE_IP> with actual IP)
echo "<MINIKUBE_IP> websocket.local" | sudo tee -a /etc/hosts

# Test the metrics endpoint
curl http://websocket.local/metrics
```

### Terminal 3: WebSocket Server Operations
```bash
# Dedicated terminal for WebSocket server
echo "=== WEBSOCKET SERVER TERMINAL ==="

# Set up port-forward for direct access (keep running)
kubectl port-forward svc/websocket-server-service 8080:8080

# In another session, test metrics
curl http://localhost:8080/metrics

# Monitor WebSocket specific metrics
watch "curl -s http://localhost:8080/metrics | grep websocket"
```

## Phase 4: Monitoring Setup (Prometheus + Grafana)

### Terminal 4: Prometheus Operations
```bash
# Dedicated terminal for Prometheus
echo "=== PROMETHEUS TERMINAL ==="
```

### 4.1 Deploy Prometheus

```bash
# In Terminal 4: Apply Prometheus configuration
kubectl apply -f k8s/monitoring/prometheus.yaml

# Verify Prometheus deployment
kubectl get pods -l app=prometheus
kubectl get services -l app=prometheus

# Set up Prometheus port-forward (keep running)
kubectl port-forward svc/prometheus-service 9090:9090

# Check Prometheus targets
curl -s "http://localhost:9090/api/v1/targets" | python3 -c "import json,sys; data=json.load(sys.stdin); [print(f'Target: {t[\"labels\"][\"job\"]}, Health: {t[\"health\"]}') for t in data['data']['activeTargets']]"
```

### Terminal 5: Grafana Operations
```bash
# Dedicated terminal for Grafana
echo "=== GRAFANA TERMINAL ==="
```

### 4.2 Deploy Grafana

```bash
# In Terminal 5: Apply Grafana configuration
kubectl apply -f k8s/monitoring/grafana.yaml

# Verify Grafana deployment
kubectl get pods -l app=grafana
kubectl get services -l app=grafana

# Set up Grafana port-forward (keep running)
kubectl port-forward svc/grafana-service 3000:3000
```

### 4.3 Access Grafana Dashboard

```bash
# In Terminal 5: Get Grafana URL via NodePort (direct access)
echo "http://$(minikube ip):30000"

# Or use localhost with port-forward already running
echo "Grafana available at: http://localhost:3000"

# Alternative: Use minikube service command
minikube service grafana-service --url
```

**Login credentials:**
- Username: `admin`
- Password: `admin`

The WebSocket Server Dashboard should be automatically provisioned and available.

### 4.4 Verify Monitoring Setup

```bash
# Check all port-forwards are active (run in any terminal)
ps aux | grep "kubectl port-forward"

# Verify all endpoints are accessible
curl -I http://localhost:8080/metrics  # WebSocket metrics
curl -I http://localhost:9090          # Prometheus  
curl -I http://localhost:3000          # Grafana
```

## Phase 5: Load Testing and Scaling Verification

### Terminal 6: Load Testing & Monitoring
```bash
# Dedicated terminal for load testing and monitoring
echo "=== LOAD TESTING & MONITORING TERMINAL ==="
```

### 5.1 Run Load Test Against Kubernetes Deployment

```bash
# In Terminal 6: Navigate to load test directory
cd loadtest

# Run various load test scenarios
k6 run --vus 10 --duration 1m websocket-test.js
k6 run --vus 50 --duration 2m websocket-test.js  # Heavy load
k6 run --vus 100 --duration 30s websocket-test.js  # Stress test

# Monitor metrics during load test
watch "curl -s http://localhost:8080/metrics | grep -E '(websocket_|process_cpu_seconds_total|process_resident_memory_bytes)'"
```

### 5.2 Monitor Scaling Events

```bash
# In Terminal 2: Watch HPA in real-time
kubectl get hpa websocket-server-hpa --watch

# In Terminal 2: Watch pod scaling  
kubectl get pods -l app=websocket-server --watch

# In Terminal 6: Monitor resource usage
watch kubectl top pods
```

### 5.3 Monitor in Grafana

While running the load test:
1. Open Grafana dashboard at http://localhost:3000
2. Navigate to "WebSocket Server Monitoring" dashboard  
3. Observe in real-time:
   - **Active connections increasing**
   - **Message throughput** (received/sent per second)
   - **CPU/Memory usage** (updated with working metrics)
   - **Scaling metrics** (replica count, CPU usage, connections)

### Updated Dashboard Panels (Latest Changes)

**Fixed Panels:**
- **CPU Utilization**: Now shows `rate(process_cpu_seconds_total[5m]) * 100`
- **Memory Usage**: Shows `process_resident_memory_bytes` and `nodejs_heap_size_used_bytes`
- **Total Messages**: Fixed with proper field configuration and thresholds
- **Scaling Metrics**: Replaced HPA metrics with `count(up{job="websocket-server-static"})` and CPU usage

## Phase 6: Multi-Terminal Management

### Managing All Terminals

**Terminal Overview:**
```bash
# Terminal 1: Docker monitoring
watch "docker ps -a | grep websocket"

# Terminal 2: Kubernetes monitoring  
watch "kubectl get pods,svc,deployment,hpa"

# Terminal 3: WebSocket server (port-forward running)
kubectl port-forward svc/websocket-server-service 8080:8080

# Terminal 4: Prometheus (port-forward running)
kubectl port-forward svc/prometheus-service 9090:9090

# Terminal 5: Grafana (port-forward running)
kubectl port-forward svc/grafana-service 3000:3000

# Terminal 6: Load testing and metrics monitoring
watch "curl -s http://localhost:8080/metrics | grep websocket"
```

## Phase 6: Troubleshooting Commands

### 6.1 Port Conflict Resolution

```bash
# Check what processes are using required ports (8080, 9090, 3000, 30000)
sudo ss -tlnp | grep -E ':(8080|9090|3000|30000)\s'

# Kill specific port-forward processes by terminal
sudo pkill -f "kubectl port-forward.*websocket-server-service"  # Terminal 3
sudo pkill -f "kubectl port-forward.*prometheus-service"        # Terminal 4  
sudo pkill -f "kubectl port-forward.*grafana-service"          # Terminal 5

# Kill all port-forwards
sudo pkill -f "kubectl port-forward"

# Restart individual port-forwards in their respective terminals
# Terminal 3:
kubectl port-forward svc/websocket-server-service 8080:8080
# Terminal 4:
kubectl port-forward svc/prometheus-service 9090:9090  
# Terminal 5:
kubectl port-forward svc/grafana-service 3000:3000
```

### 6.2 Terminal-Specific Debugging

**Terminal 1 - Docker Issues:**
```bash
# Check Docker daemon status
docker system info

# View container logs
docker logs <container-id>

# Clean up Docker resources
docker system prune -f
```

**Terminal 2 - Kubernetes Issues:**
```bash
# View all resources
kubectl get all -o wide

# Check events
kubectl get events --sort-by='.metadata.creationTimestamp'

# Debug pod issues  
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# Debug service connectivity
kubectl exec -it <pod-name> -- /bin/sh

# Check resource usage
kubectl top pods
kubectl top nodes

# Debug HPA
kubectl describe hpa websocket-server-hpa
```

**Terminal 3-5 - Port-Forward Issues:**
```bash
# Check if port-forwards are running
ps aux | grep "kubectl port-forward" | grep -v grep

# Test individual endpoints
curl -I http://localhost:8080/metrics  # WebSocket
curl -I http://localhost:9090          # Prometheus  
curl -I http://localhost:3000          # Grafana

# Restart specific port-forward if needed
kubectl port-forward svc/<service-name> <port>:<port>
```

**Terminal 6 - Load Testing Issues:**
```bash
# Check k6 installation
k6 version

# Validate WebSocket connection
curl -I http://localhost:8080

# Test simple HTTP connection before WebSocket
curl http://localhost:8080/metrics | head -5
```

### 6.2 Restart Deployments

```bash
# Restart WebSocket server deployment
kubectl rollout restart deployment websocket-server

# Restart Prometheus
kubectl rollout restart deployment prometheus

# Restart Grafana
kubectl rollout restart deployment grafana
```

## Phase 7: Cleanup

### 7.1 Remove All Resources

```bash
# Delete application resources
kubectl delete -f k8s/deployment.yaml
kubectl delete -f k8s/service.yaml
kubectl delete -f k8s/ingress.yaml
kubectl delete -f k8s/hpa.yaml

# Delete monitoring resources
kubectl delete -f k8s/monitoring/prometheus.yaml
kubectl delete -f k8s/monitoring/grafana.yaml

# Stop minikube (if using)
minikube stop
minikube delete
```

## Expected Outcomes

After following all steps, you should have:

1. ✅ **Containerized Application**: WebSocket server running in Docker container
2. ✅ **Kubernetes Deployment**: Application deployed with auto-scaling capabilities
3. ✅ **Monitoring Stack**: Prometheus collecting metrics and Grafana visualizing them
4. ✅ **Complete Observability**: Dashboard showing:
   - Connection Overview (Active connections, Connection rate)
   - Message Throughput (Messages received/sent per second)
   - Scaling Events (Pod count over time, CPU utilization)
   - System Health (Pod status, Resource usage)

## Verification Checklist

- [ ] Docker image builds successfully
- [ ] Application pods are running and ready
- [ ] Service endpoints are accessible
- [ ] HPA is configured and responsive to load
- [ ] Prometheus is scraping metrics from WebSocket server
- [ ] Grafana dashboard displays real-time metrics
- [ ] Load testing triggers auto-scaling
- [ ] All dashboard panels show relevant data

## Notes

- Default Grafana credentials: admin/admin
- Prometheus is accessible at port 9090
- Grafana is accessible at port 3000 (or NodePort 30000)
- WebSocket server exposes metrics at `/metrics` endpoint
- HPA is configured to scale between 2-10 replicas based on CPU (70%) and Memory (80%) utilization

## Port Troubleshooting

If you encounter port conflicts after restarting your system:

1. **Check for conflicting processes:**
   ```bash
   sudo ss -tlnp | grep -E ':(8080|9090|3000|30000)\s'
   ```

2. **Kill conflicting processes:**
   ```bash
   sudo pkill -f grafana
   sudo pkill -f prometheus  
   sudo pkill -f "kubectl port-forward"
   ```

3. **Restart minikube if needed:**
   ```bash
   minikube stop
   minikube start
   minikube addons enable ingress
   minikube addons enable metrics-server
   ```

4. **Use the verification script:**
   ```bash
   ./verify-services.sh
   ```

## Current Status Summary

✅ All services are properly configured and running:
- **WebSocket Server**: Deployed with 2+ replicas, auto-scaling enabled
- **Prometheus**: Collecting metrics from WebSocket server pods
- **Grafana**: Dashboard pre-configured with WebSocket monitoring panels
- **Load Testing**: k6 tests working with WebSocket connections
- **Port Management**: All services accessible on standard ports (8080, 9090, 3000, 30000)
