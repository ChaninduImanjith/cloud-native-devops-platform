#!/bin/bash
# Install cert-manager using Helm

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install the cert-manager Helm chart
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.14.4 \
  --set installCRDs=true

echo "Waiting for cert-manager pods to be ready..."
kubectl wait --namespace cert-manager --for=condition=ready pod --all --timeout=120s

echo "Cert-manager installed successfully!"
