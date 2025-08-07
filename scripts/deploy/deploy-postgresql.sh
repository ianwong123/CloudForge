#!/bin/bash
#
# Deploy Phase 4: PostgreSQL
# 
#
# Ref:
 
# Absolute path to the script directory
# This allows the script to be run from any directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$SCRIPT_DIR/../.." 

echo "CloudForge Phase 3 Deployment..."
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


# PostgreSQL deployment
echo "Deploying PostgreSQL database..."
helm upgrade --install postgresql bitnami/postgresql \
 --namespace postgresql \
 --create-namespace \
  -f "$ROOT_DIR/helm-values/postgresql-values.yaml" \

# Create PostgreSQL secret
#echo "Creating PostgreSQL secret..."
#kubectl create secret generic postgresql-secret \
# --namespace postgresql \
# --from-literal=POSTGRES_USER=postgres \
# --from-literal=POSTGRES_PASSWORD=$(openssl rand -base64 32) \
# --from-literal=POSTGRES_DB=CloudForge \
# --dry-run=client -o yaml > postgresql-secret.yaml

echo "PostgreSQL database deployed"
echo ""

echo "Phase 4 deployment complete."

echo ""
echo "Secrets are unencrypted."
echo "Use Sealed Secrets to encrypt before committing to Git."
echo "Ref: https://github.com/bitnami-labs/sealed-secrets"




