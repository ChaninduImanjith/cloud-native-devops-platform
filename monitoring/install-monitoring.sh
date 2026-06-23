#!/bin/bash

# Add Prometheus Community Helm Repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Kube-Prometheus-Stack (Prometheus, Grafana, Alertmanager)
echo "Installing Kube-Prometheus-Stack..."
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set alertmanager.configSecret="alertmanager-config" \
  --set alertmanager.alertmanagerSpec.secrets={"alertmanager-auth"}

echo "Waiting for monitoring pods to be ready..."
kubectl wait --namespace monitoring --for=condition=ready pod --all --timeout=120s

echo "Applying custom monitoring manifests (dashboards, alerts, service monitors)..."
kubectl apply -f monitoring/alertmanager-config.yaml
kubectl apply -f monitoring/alert-rules.yaml
kubectl apply -f monitoring/servicemonitor.yaml
kubectl apply -f monitoring/grafana-dashboard.yaml

echo "Monitoring setup completed!"
