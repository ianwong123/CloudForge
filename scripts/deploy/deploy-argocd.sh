#!/bin/bash
#
# Deploy ArgoCD for GitOps
#
# Ref: https://argo-cd.readthedocs.io/en/stable/getting_started/

# Absolute path to the script directory
# This allows the script to be run from any directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$SCRIPT_DIR/../.." 

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

# Deploy ArgoCD
# Inspect the manifest first before proceeding to apply the manifest
# curl -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml | less

echo "Deploying ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo ""
echo "ArgoCD deployed"