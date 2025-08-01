#!/bin/bash

# Absolute path to the script directory
# This allows the script to be run from any directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$SCRIPT_DIR/../.."  

# Load environment variables
CLUSTER_NAME='cloudforge'
CONFIG_PATH="$ROOT_DIR/kind-cluster-config/kind-cluster-config.yaml"

# Check if cluster already exists
if kind get clusters | grep -q "$CLUSTER_NAME"; then
    echo "Cluster "$CLUSTER_NAME" already exists. Deleting existing cluster..."
    kind delete cluster --name "$CLUSTER_NAME"
fi

echo "Creating multi-node kind cluster with name '$CLUSTER_NAME'..."
echo "Creating control plane node.."
echo "Creating worker nodes..."

# Create multi-node kind cluster
if ! kind create cluster --config "$CONFIG_PATH"; then 
    echo "Failed to create kind cluster. Please check the configuration and try again."
    exit 1
fi

# Display cluster information
kubectl get nodes -o wide


echo "Cluster '$CLUSTER_NAME' setup complete!"


