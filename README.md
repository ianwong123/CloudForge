# CloudForge
A complete cloud infrastructure platform built on Kubernetes

## Project Overview

This project demonstrates building a production-ready cloud platform using Kubernetes, featuring multiple services that replicate AWS-like functionality. Leveraging open-source solutions with focus on infrastructure, monitoring, and DevOps practices.

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Ingress       │    │   Monitoring    │    │   Storage       │
│   (Nginx)       │    │   Stack         │    │   Layer         │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ • Load Balancer │    │ • Prometheus    │    │ • MinIO (S3)    │
│ • SSL/TLS       │    │ • Grafana       │    │ • Persistent    │
│ • Routing       │    │ • AlertManager  │    │   Volumes       │
└─────────────────┘    └─────────────────┘    └─────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Database      │    │   Message       │    │   Cache         │
│   Services      │    │   Queue         │    │   Layer         │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ • PostgreSQL    │    │ • RabbitMQ      │    │ • Redis         │
│ • pgAdmin       │    │ • Management UI │    │ • Redis Cmdr    │
│ • Backups       │    │ • Clustering    │    │ • Monitoring    │
└─────────────────┘    └─────────────────┘    └─────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                     Kubernetes Cluster                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   Your      │  │  Message    │  │  • Management Web UIs   │  │
│  │Applications │  │  Queue      │  │  • K8s Dashboard        │  │
│  │             │  │ (RabbitMQ)  │  │  • MinIO Console        │  │
│  │ • Web Apps  │  │             │  │  • pgAdmin              │  │
│  │ • APIs      │  │             │  │  • Grafana Dashboards   │  │
│  │ • Services  │  │             │  │  • RabbitMQ Management  │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Tech Stack

| Component | Technology | Purpose | Web UI |
|-----------|------------|---------|---------|
| **Container Orchestration** | Kubernetes (KIND) | Container management |  K8s Dashboard |
| **Object Storage** | MinIO | S3-compatible storage |  MinIO Console |
| **Database** | PostgreSQL | Relational database |  pgAdmin |
| **Cache** | Redis | In-memory cache |  Redis Commander |
| **Message Queue** | RabbitMQ | Async messaging |  Management Plugin |
| **Load Balancer** | Nginx Ingress | Traffic routing |  Config-based |
| **Monitoring** | Prometheus | Metrics collection |  Basic UI |
| **Visualization** | Grafana | Dashboards & alerts |  Full Dashboard |
| **Storage** | Local Persistent Volumes | Data persistence |  K8s managed |

## Prerequisites

### Required Tools
- **KIND** (Kubernetes in Docker)
- **kubectl** (Kubernetes CLI)
- **Docker** (Container runtime)
- **WSL2** (Windows users only)
- **Helm** (Package manager - optional)

## Implementation Phases

### Phase 1: Cluster & Storage Foundation
- [ ] Set up KIND cluster with ingress-ready configuration
- [ ] Deploy Kubernetes Dashboard
- [ ] Create namespaces and basic networking and RBAC basics
- [ ] Deploy MinIO (Object Storage) with persistent volumes
- [ ] Test basic functionality, configure MinIO ingress and test file upload/download

**Deliverables:** Working object storage with web interface<br>
**Success Criteria:** Can upload/download files via MinIO console

### Phase 2: Database & Cache Services
- [ ] Deploy PostgreSQL with persistent storage
- [ ] Set up pgAdmin for database management
- [ ] Deploy Redis cache cluster
- [ ] Add Redis Commander interface
- [ ] Configure inter-service networking
- [ ] **Test data persistence across pod restarts** 


**Deliverables:** Complete data storage and cache layer<br>
**Success Criteria:** Can create databases, cache data, and data survives restarts


### Phase 3: Communication & Traffic Management 
- [ ] Deploy RabbitMQ message queue
- [ ] Configure RabbitMQ management interface
- [ ] Set up Nginx Ingress Controller
- [ ] Configure routing and load balancing
- [ ] Configure custom domains (*.local)
- [ ] Implement service discovery
- [ ] **Deploy a test application to verify end-to-end flow** (Key milestone)


**Deliverables:** Complete messaging and traffic management<br>
**Success Criteria:** Can deploy an app that uses database, cache, and messaging


### Phase 4: Monitoring & Observability 
- [ ] Deploy Prometheus for metrics collection
- [ ] Set up Grafana dashboards
- [ ] Configure service monitoring
- [ ] Set up alerting rules
- [ ] Create custom dashboards for each service

**Deliverables:** Complete monitoring stack with dashboards<br>
**Success Criteria:**
- [ ] All services (MinIO, PostgreSQL, Redis, RabbitMQ) appear in Prometheus metrics
- [ ] Grafana displays real-time dashboards for each service
- [ ] Can create custom alerts (e.g., high CPU, low disk space)
- [ ] Alert notifications work (email/webhook/Slack)
- [ ] Can view historical performance data (7+ days)
- [ ] Resource usage dashboards show cluster health
- [ ] Application metrics are captured (if test app deployed)

### Phase 5: Advanced Features for Production & Auto-Scaling
- [ ] Implement Horizontal Pod Autoscaling (HPA)
- [ ] Add resource limits and requests
- [ ] Set up backup strategies
- [ ] Implement rolling updates
- [ ] Security hardening (RBAC, NetworkPolicies)

**Deliverables:** Production-ready platform with scaling and security

## Project Structure

```
CloudForge/
├── README.md
├── docs/
│   ├── architecture.md
│   ├── deployment-guide.md
│   └── troubleshooting.md
├── manifests/
│   ├── 01-namespaces/
│   ├── 02-storage/
│   │   ├── minio/
│   │   ├── postgresql/
│   │   └── redis/
│   ├── 03-messaging/
│   │   └── rabbitmq/
│   ├── 04-ingress/
│   │   └── nginx/
│   └── 05-monitoring/
│       ├── prometheus/
│       └── grafana/
├── configs/
│   ├── grafana-dashboards/
│   ├── prometheus-rules/
│   └── nginx-configs/
├── scripts/
│   ├── setup-cluster.sh
│   ├── deploy-stack.sh
│   └── cleanup.sh
└── tests/
    ├── connectivity-tests/
    └── performance-tests/
```
# High-Level User Expectations
This project follows an AGILE approach. What do i expect as an end-user from a platform like this?

1. A unified dashboard to access all services (MinIO, Redis, Postgres, etc.).
2. One command to start/stop the entire platform.
3. Everything pre-connected (e.g., Postgres automatically talks to Redis).

## Learning Objectives

By completing this project, to gain hands-on experience with:

### **Kubernetes Concepts**
- Deployments, Services, and Ingress
- ConfigMaps and Secrets management
- Persistent Volumes and Storage Classes
- Namespaces and Resource Quotas
- Horizontal Pod Autoscaling

### **DevOps Practices**
- Infrastructure as Code
- Service discovery and networking
- Monitoring and observability
- Rolling updates and deployment strategies
- Backup and disaster recovery

### **Cloud Technologies**
- Object storage (S3-compatible)
- Database as a Service concepts
- Message queue architectures
- Load balancing and traffic management
- Metrics collection and visualisation
