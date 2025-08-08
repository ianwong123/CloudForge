#!/bin/bash
#
# Deploy Sealed Secrets 
#
# Ref: https://github.com/bitnami-labs/sealed-secrets

# Absolute path to the script directory
# This allows the script to be run from any directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$SCRIPT_DIR/../.." 

echo "CloudForge Phase 2 Deployment..."
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

# Generate Kubernetes manifests
# helm template sealed-secrets sealed-secrets/sealed-secrets --output-dir .

# Deploy Sealed Secrets
echo "Deploying Sealed Secrets..."
helm upgrade --install sealed-secrets --set-string fullnameOverride=sealed-secrets-controller sealed-secrets/sealed-secrets \
 --namespace sealed-secrets \
 --create-namespace \
  -f "$ROOT_DIR/helm-values/sealed-secrets-values.yaml"

# Create TLS certificate and private key for Sealed Secrets
openssl req -x509 -days 365 -nodes -newkey rsa:4096 -keyout mytls.key -out mytls.crt -subj "/CN=sealed-secret/O=sealed-secret"

# Create secrets for tls certificate and private key
echo "Creating Sealed Secrets..."
kubectl create secret tls sealed-secrets-key \
 --namespace sealed-secrets \
 --cert="$ROOT_DIR/secrets/mylts.crt" \
 --key="$ROOT_DIR/secrets/mylts.key" \
 --dry-run=client -o yaml > "$ROOT_DIR/secrets/sealed-secrets-key.yaml"

# Install kubeseal
curl -OL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.29.0/kubeseal-0.29.0-linux-amd64.tar.gz"
tar -xvzf kubeseal-0.29.0-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
kubeseal --version

echo "Sealed Secrets deployed"
echo ""

echo ""
echo "Secrets are unencrypted."
echo "Use Sealed Secrets to encrypt before committing to Git."
echo "Ref: https://github.com/bitnami-labs/sealed-secrets"




