#!/bin/bash
#
# Deploy Phase 1: Foundational Infrastructure
# Helm + K8s Dashboard, Nginx Ingress Controller + MinIO

# Absolute path to the script directory
# This allows the script to be run from any directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$SCRIPT_DIR/../.." 

echo "CloudForge Phase 1 Deployment..."
echo ""

# Chcck prerequisites
echo "Checking prerequisites..."

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Install from: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo "Helm not. Please run ./scripts/setup/setup-helm.sh first."
    exit 1
fi

# Check if cluster exist
if ! kubectl cluster-info &> dev/null; then
    echo "No Kubernetes cluster not found. Run ./scripts/setup/setup-cluster.sh first"
    exit 1
fi 

echo "Prerequisites check passed. Proceeding with deployments..."
echo ""

# Check if namespace exist
echo "Creating namespace..."
    kubectl apply -f "$ROOT_DIR/namespaces/namespaces.yaml"
echo "Namespace ready."
echo ""

# Deploy nginx ingress controller
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \ 
 --namespace ingress-nginx \ 
 --create-namespace \
 --set controller.service.type=NodePort \
 --set controller.nodeSelector."kubernetes\.io/os"=linux \
 --set controller.nodeSelector."node-type"="ingress" \
 --set controller.hostPort.enabled=true \
 --set controller.metrics.enabled=true \
 --set controller.podAnnotations."prometheus\.io/scrape"="true" \
 --set controller.podAnnotations."prometheus\.io/port"="10254" \
 --wait --timeout 300s

echo "NGINX Ingress Controller deployed"
echo ""

# Deploy k8s dashboard
echo "Deploying foundational infrastructure..."
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard
 --namespace kubernetes-dashboard \
 --create-namespace \
 --set nodeSelector."node-type"="general" \
 --wait --timeout 300s \

echo "Kubernetes Dashboard deployed"
echo ""

# Deploy MinIO for object storage
helm install minio minio/minio
echo ""

# Database storage setup
echo "Deploying database storage..."
helm install redis bitnami/redis
helm install postgresql bitnami/postgresql
echo ""

# Monitoring setup
echo "Deploying monitoring tools..."
helm install prometheus prometheus-community/prometheus
helm install grafana grafana/grafana
echo ""

echo "Phase 1 deployment complete."



