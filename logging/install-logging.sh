#!/bin/bash

# Add Grafana Helm Repository
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Loki-Stack (Loki + Promtail)
echo "Installing Loki-Stack..."
helm install loki grafana/loki-stack \
  --namespace logging \
  --create-namespace \
  --set grafana.enabled=false \
  --set prometheus.enabled=false \
  --set prometheus.alertmanager.persistentVolume.enabled=false \
  --set prometheus.server.persistentVolume.enabled=false \
  --set loki.persistence.enabled=true \
  --set loki.persistence.size=10Gi

echo "Waiting for logging pods to be ready..."
kubectl wait --namespace logging --for=condition=ready pod --all --timeout=120s

echo "Logging setup completed!"
echo ""
echo "To view logs in Grafana:"
echo "1. Open Grafana UI (from the monitoring namespace)"
echo "2. Go to Configuration -> Data Sources"
echo "3. Add Loki data source with URL: http://loki.logging.svc.cluster.local:3100"
