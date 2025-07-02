#!/bin/bash

# exit on error
set -e 

# Absolute path to the script directory
# This allows the script to be run from any directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$SCRIPT_DIR/../.."  

# Load environment variables
CLUSTER_NAME='cloudforge'
CONFIG_PATH="$ROOT_DIR/prerequisites/kind-cluster-config.yaml"

# Check if cluster already exists
if kind get clusters | grep -q "$CLUSTER_NAME"; then
    echo "Cluster "$CLUSTER_NAME" already exists. Deleting existing cluster..."
    kind delete cluster --name "$CLUSTER_NAME"
fi

# Create a new kind cluster
echo "Creating kind cluster '$CLUSTER_NAME'..."
if ! kind create cluster --config "$CONFIG_PATH"; then 
    echo "Failed to create kind cluster. Please check the configuration and try again."
    exit 1
fi
echo "Cluster '$CLUSTER_NAME' created successfully."


