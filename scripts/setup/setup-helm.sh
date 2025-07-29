#!/bin/bash

# Absolute path to the script directory
# This allows the script to be run from any directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$SCRIPT_DIR/../.."  

echo "Setting up Helm for CloudForge..."

# Check if Helm is installed
if command -v helm &> dev/null; then
    echo "Helm is already installed: $(helm version --short)"
else
    echo "Installing Helm..."

    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 || 
    {
        echo "Failed to download Helm installer"; exit 1
    }
    chmod 700 get_helm.sh 
    ./get_helm.sh && rm -f get_helm.sh
    echo "Helm installed successfully: $(helm version --short)"
fi

# Add repositories
echo ""
echo "Now adding Helm repositories..."

# Infrastructure repo
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add minio https://charts.min.io/

# Database storage repo for future phases (Redis and PostgreSQL)
helm repo add bitnami https://charts.bitnami.com/bitnami

# Monitoring repo 
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

# Last update 29.7.2025
# Cert-Manager repo (For future if public domain is used)
#helm repo add jetstack https://charts.jetstack.io --force-update
#helm install \
#  cert-manager jetstack/cert-manager \
#  --namespace cert-manager \
#  --create-namespace \
#  --version v1.18.2 \
#  --set crds.enabled=true

# Updated 29.7.2025 
# MetalLB installation
# Ref: https://metallb.io/installation/
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.2/config/manifests/metallb-native.yaml

  
# Update repositories
echo "Updating Helm repositories..."
helm repo update

echo ""
echo "Helm setup complete."
echo ""
echo "Available Helm repositories:"
helm repo list 
echo ""
echo "Run deploy-phase1.sh to set up infrastructure and deploy the first phase of CloudForge."