#!/bin/bash
#
# Deploy Phase 1: Foundational Infrastructure
# Nginx Ingress Controller 
#
# Ref: https://github.com/kubernetes/ingress-nginx

# Absolute path to the script directory
# This allows the script to be run from any directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$SCRIPT_DIR/../.." 

echo "CloudForge Phase 1 Deployment..."
echo ""

# Check prerequisites
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
if ! kubectl cluster-info &> /dev/null; then
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
echo "Deploying NGINX Ingress Controller..."
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
 --namespace ingress-nginx \
 --create-namespace \
  -f "$ROOT_DIR/helm-values/ingress-nginx-controller-values.yaml" \

 --wait --timeout 300s

echo "NGINX Ingress Controller deployed"
echo ""


echo "Phase 1 deployment complete."



