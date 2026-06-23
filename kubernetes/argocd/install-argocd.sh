#!/bin/bash

echo "Creating argocd namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for Argo CD pods to be ready..."
kubectl wait --namespace argocd --for=condition=ready pod --all --timeout=120s

echo "Argo CD installed successfully!"
echo ""
echo "To get the initial admin password, run:"
echo "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d; echo"
echo ""
echo "To access the Argo CD UI:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Then visit https://localhost:8080 in your browser."
