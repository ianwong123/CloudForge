#!/bin/bash
#
# Generate all self-signed certificate for TLS 
#
# Ref: https://kubernetes.io/docs/concepts/configuration/secret/

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SECRETS_DIR="$SCRIPT_DIR/../secrets"

echo "Generating self signed certificate secrets..."

# Create self-signed certificate for dashboard.cloudforge.local
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout dashboard-tls.key \
  -out dashboard-tls.crt \
  -subj "/CN=dashboard.cloudforge.local" \
  -addext "subjectAltName = DNS:dashboard.cloudforge.local" \

cat dashboard-tls.crt | base64 -w0
echo ""
cat dashboard-tls.key | base64 -w0

kubectl create secret tls kubernetes-dashboard-tls \
  --cert=dashboard-tls.crt \
  --key=dashboard-tls.key \
  -n kubernetes-dashboard \
  --dry-run=client -o yaml > kubernetes-tls-secret.yaml

echo ""
echo "Secrets are unencrypted."
echo "Use Sealed Secrets to encrypt before committing to Git."
echo "Ref: https://github.com/bitnami-labs/sealed-secrets"
