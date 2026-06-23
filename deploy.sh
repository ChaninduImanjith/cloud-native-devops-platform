#!/usr/bin/env bash
# =============================================================================
# deploy.sh  —  Full redeploy script for Cloud Native DevOps Platform (Phase 7)
# =============================================================================
set -euo pipefail

DOCKER_USER="chaninduimanjith"
BACKEND_IMAGE="${DOCKER_USER}/cloud-native-devops-backend:latest"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        Cloud Native DevOps Platform — Phase 7 Deploy        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ── Step 1: Point Docker CLI at Minikube's Docker daemon ──────────────────────
echo "▶ Step 1: Pointing Docker to Minikube's daemon..."
eval "$(minikube docker-env)"
echo "   ✅ Done"

# ── Step 2: Build the new backend image inside Minikube ───────────────────────
echo ""
echo "▶ Step 2: Building backend Docker image..."
docker build -t "${BACKEND_IMAGE}" ./backend
echo "   ✅ Image built: ${BACKEND_IMAGE}"

# ── Step 3: Apply backend Kubernetes manifests ────────────────────────────────
echo ""
echo "▶ Step 3: Applying Kubernetes manifests..."
kubectl apply -f kubernetes/backend-service.yaml
kubectl apply -f kubernetes/backend-deployment.yaml
echo "   ✅ Backend deployment & service applied"

# ── Step 4: Rolling restart to pick up the new image ─────────────────────────
echo ""
echo "▶ Step 4: Triggering rolling restart of backend..."
kubectl rollout restart deployment/backend
kubectl rollout status deployment/backend --timeout=120s
echo "   ✅ Backend rollout complete"

# ── Step 5: Apply monitoring manifests ───────────────────────────────────────
echo ""
echo "▶ Step 5: Applying monitoring manifests..."
kubectl apply -f monitoring/servicemonitor.yaml
kubectl apply -f monitoring/alert-rules.yaml
kubectl apply -f monitoring/grafana-dashboard.yaml
echo "   ✅ ServiceMonitor, AlertRules, and Grafana Dashboard applied"

# ── Step 6: Print access URLs ────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    Deployment Complete! 🎉                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
MINIKUBE_IP=$(minikube ip)
echo "  Backend NodePort : http://${MINIKUBE_IP}:31500"
echo "  Metrics endpoint : http://${MINIKUBE_IP}:31500/metrics"
echo "  Health (live)    : http://${MINIKUBE_IP}:31500/health/live"
echo "  Health (ready)   : http://${MINIKUBE_IP}:31500/health/ready"
echo ""
echo "  ⚡ To open Grafana:"
echo "     kubectl port-forward -n monitoring svc/monitoring-grafana 3001:80 &"
echo "     Then visit: http://localhost:3001"
echo ""
echo "  ⚡ To open Prometheus:"
echo "     kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090 &"
echo "     Then visit: http://localhost:9090"
echo ""
