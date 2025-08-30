# WebSocket Node.js Application with Complete DevOps Pipeline

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)](https://grafana.com/)
[![Node.js](https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)

A production-ready WebSocket Node.js application with comprehensive DevOps implementation including Docker containerization, Kubernetes deployment, monitoring with Prometheus and Grafana, and automated load testing.

## 🚀 Features

- **Real-time WebSocket Communication**: Bidirectional messaging between client and server
- **Express.js HTTP Server**: RESTful API endpoints and health checks
- **Prometheus Metrics**: Custom metrics for monitoring WebSocket connections and messages
- **Docker Containerization**: Multi-stage build with security best practices
- **Kubernetes Deployment**: Auto-scaling with HPA (Horizontal Pod Autoscaler)
- **Monitoring & Observability**: Grafana dashboards for real-time monitoring
- **Load Testing**: k6 scripts for performance testing
- **Production Security**: Non-root user, minimal attack surface

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Load Balancer │────│  Kubernetes     │────│   Monitoring    │
│   (Ingress)     │    │   Pods          │    │  (Prometheus)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │                        │
                              │                        │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Clients      │────│  WebSocket      │────│   Grafana       │
│   (WebSocket)   │    │   Server        │    │  (Dashboard)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📁 Project Structure

```
devops-intern-task/
├── server/
│   ├── index.js              # Main WebSocket server application
│   ├── package.json          # Node.js dependencies and scripts
│   └── Dockerfile           # Multi-stage Docker build configuration
├── k8s/
│   ├── deployment.yaml      # Kubernetes deployment with auto-scaling
│   ├── service.yaml         # Kubernetes service configuration
│   ├── ingress.yaml         # Ingress controller for external access
│   ├── hpa.yaml            # Horizontal Pod Autoscaler configuration
│   └── monitoring/
│       ├── prometheus.yaml  # Prometheus configuration
│       └── grafana.yaml    # Grafana dashboard configuration
├── loadtest/
│   ├── websocket-test.js    # k6 load testing script
│   └── websocket-test-k8s.js # k6 script for Kubernetes testing
├── commands.md             # Comprehensive command reference
├── outcomes.md            # Project outcomes and results
├── verify-services.sh     # Service verification script
└── README.md             # This file
```

## 🛠️ Technology Stack

### Backend
- **Node.js**: JavaScript runtime environment
- **Express.js**: Web application framework
- **WebSocket (ws)**: Real-time bidirectional communication
- **Prometheus Client**: Metrics collection and exposition

### DevOps & Infrastructure
- **Docker**: Containerization platform
- **Kubernetes**: Container orchestration
- **Prometheus**: Monitoring and alerting system
- **Grafana**: Observability and visualization platform
- **k6**: Load testing tool

### Monitoring Metrics
- `websocket_active_connections`: Current active WebSocket connections
- `websocket_messages_received_total`: Total messages received by server
- `websocket_messages_sent_total`: Total messages sent by server
- `process_cpu_user_seconds_total`: CPU usage metrics
- `process_resident_memory_bytes`: Memory usage metrics

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- Kubernetes cluster (minikube, k3s, or cloud provider)
- kubectl CLI tool
- k6 for load testing

### 1. Clone Repository
```bash
git clone https://github.com/samarth93/Web-socket-Node-application-.git
cd Web-socket-Node-application-
```

### 2. Build and Run with Docker
```bash
# Build Docker image
docker build -t websocket-app:latest ./server

# Run container
docker run -d -p 8080:8080 --name websocket-server websocket-app:latest
```

### 3. Deploy to Kubernetes
```bash
# Apply all Kubernetes manifests
kubectl apply -f k8s/

# Verify deployment
kubectl get pods,svc,ingress,hpa
```

### 4. Start Monitoring Stack
```bash
# Deploy Prometheus
kubectl apply -f k8s/monitoring/prometheus.yaml

# Deploy Grafana
kubectl apply -f k8s/monitoring/grafana.yaml

# Port forward to access services
kubectl port-forward svc/prometheus-service 9090:9090 &
kubectl port-forward svc/grafana-service 3000:3000 &
```

## 📊 Monitoring & Observability

### Prometheus Metrics
Access Prometheus at `http://localhost:9090`

Key queries:
- `websocket_active_connections` - Current connections
- `rate(websocket_messages_received_total[5m])` - Message rate
- `process_resident_memory_bytes` - Memory usage

### Grafana Dashboards
Access Grafana at `http://localhost:3000` (admin/admin)

**Dashboard Panels:**
1. **Active WebSocket Connections**: Real-time connection count
2. **Message Throughput**: Messages per second (sent/received)
3. **CPU Usage**: Process CPU utilization
4. **Memory Usage**: RAM consumption
5. **Pod Scaling**: HPA scaling events

## 🧪 Load Testing

### Basic Load Test
```bash
# Test local deployment
k6 run loadtest/websocket-test.js

# Test Kubernetes deployment
k6 run loadtest/websocket-test-k8s.js
```

### Intensive Load Test
```bash
# High-load test with 10 virtual users for 60 seconds
k6 run --vus 10 --duration 60s loadtest/websocket-test.js
```

**Expected Results:**
- Successful WebSocket connections
- Message exchange verification
- Performance metrics collection
- Auto-scaling triggers (if HPA configured)

## 🔧 Configuration

### Environment Variables
- `PORT`: Server port (default: 8080)
- `NODE_ENV`: Environment mode (development/production)
- `METRICS_PATH`: Prometheus metrics endpoint (default: /metrics)

### Kubernetes Configuration
- **Replicas**: 2-10 pods (auto-scaling)
- **Resources**: 
  - CPU: 100m-500m
  - Memory: 128Mi-512Mi
- **HPA Triggers**: 70% CPU, 80% Memory

### Security Features
- Non-root user execution
- Minimal base image (Alpine Linux)
- Read-only file system capabilities
- Resource limits enforcement

## 🚦 Health Checks

The application provides several endpoints for monitoring:

- `GET /`: Basic health check
- `GET /health`: Detailed health status
- `GET /metrics`: Prometheus metrics
- WebSocket endpoint: `ws://localhost:8080/`

## 🔍 Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Kill process using port 8080
   sudo lsof -ti:8080 | xargs kill -9
   ```

2. **Kubernetes Pod Not Starting**
   ```bash
   # Check pod logs
   kubectl logs -l app=websocket-server
   
   # Describe pod for events
   kubectl describe pod <pod-name>
   ```

3. **Metrics Not Appearing**
   ```bash
   # Verify metrics endpoint
   curl http://localhost:8080/metrics
   
   # Check Prometheus targets
   # Visit http://localhost:9090/targets
   ```

4. **Grafana Dashboard Empty**
   ```bash
   # Verify Prometheus data source
   # Check port-forward is active
   kubectl port-forward svc/prometheus-service 9090:9090
   ```

## 🧪 Testing

### Manual WebSocket Testing
```javascript
// Browser console test
const ws = new WebSocket('ws://localhost:8080/');
ws.onopen = () => ws.send('Hello Server!');
ws.onmessage = (event) => console.log('Received:', event.data);
```

### API Testing
```bash
# Health check
curl http://localhost:8080/health

# Metrics
curl http://localhost:8080/metrics
```

## 📈 Performance Benchmarks

**Load Test Results (10 VUs, 60s):**
- ✅ 200 iterations completed
- ✅ 1,831 messages processed
- ✅ 100% success rate
- ✅ Average response time: <100ms
- ✅ Auto-scaling triggered at high load

## 🚀 Production Deployment

### Multi-Terminal Workflow

1. **Terminal 1 - Docker**
   ```bash
   docker build -t websocket-app:latest ./server
   docker run -d -p 8080:8080 websocket-app:latest
   ```

2. **Terminal 2 - Kubernetes**
   ```bash
   kubectl apply -f k8s/
   kubectl get pods -w
   ```

3. **Terminal 3 - Monitoring**
   ```bash
   kubectl port-forward svc/prometheus-service 9090:9090
   ```

4. **Terminal 4 - Dashboard**
   ```bash
   kubectl port-forward svc/grafana-service 3000:3000
   ```

5. **Terminal 5 - Load Testing**
   ```bash
   k6 run --vus 10 --duration 60s loadtest/websocket-test.js
   ```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push to branch: `git push origin feature/new-feature`
5. Submit pull request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:
- Create an issue in this repository
- Contact: [samarth93@github.com]

## 🎯 Project Outcomes

This project demonstrates:
- ✅ **Docker Containerization**: Multi-stage builds, security hardening
- ✅ **Kubernetes Orchestration**: Auto-scaling, load balancing, service discovery
- ✅ **Monitoring & Observability**: Prometheus metrics, Grafana dashboards
- ✅ **Performance Testing**: Load testing with k6, performance optimization
- ✅ **Production Readiness**: Health checks, logging, error handling
- ✅ **DevOps Best Practices**: CI/CD ready, infrastructure as code

---

**Built with ❤️ for DevOps Excellence**
