#!/bin/bash
# ============================================================
# test.sh — Quick test script for Cloud Native DevOps Platform
# ============================================================

BASE_URL="http://a4977326368864f1cbe72703bd19174a-173171894.us-east-1.elb.amazonaws.com"

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║   🧪 Cloud Native DevOps Platform — Test Runner     ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

PASS=0
FAIL=0

check() {
  local label="$1"
  local result="$2"
  local expected="$3"
  if [ "$result" = "$expected" ]; then
    printf "  ✅ %-40s → %s\n" "$label" "$result"
    PASS=$((PASS + 1))
  else
    printf "  ❌ %-40s → %s (expected: %s)\n" "$label" "$result" "$expected"
    FAIL=$((FAIL + 1))
  fi
}

echo "── 🌐 API Endpoint Tests ──────────────────────────────"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 $BASE_URL/)
check "Frontend (/)" "$STATUS" "200"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 $BASE_URL/api/message)
check "API Message (/api/message)" "$STATUS" "200"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 $BASE_URL/api/status)
check "API Status (/api/status)" "$STATUS" "200"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 $BASE_URL/health/live)
check "Liveness Probe (/health/live)" "$STATUS" "200"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 $BASE_URL/health/ready)
check "Readiness Probe (/health/ready)" "$STATUS" "200"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 $BASE_URL/health/startup)
check "Startup Probe (/health/startup)" "$STATUS" "200"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 $BASE_URL/metrics)
check "Prometheus Metrics (/metrics)" "$STATUS" "200"

echo ""
echo "── ☸️  Kubernetes Health Tests ────────────────────────"

READY_NODES=$(kubectl get nodes --no-headers 2>/dev/null | grep -c "Ready")
check "Nodes Ready (expect 3)" "$READY_NODES" "3"

BACKEND_PODS=$(kubectl get pods -n default -l app=backend --no-headers 2>/dev/null | grep -c "Running")
check "Backend Pods Running (min 2)" "$([ "$BACKEND_PODS" -ge 2 ] && echo "OK" || echo "FAIL")" "OK"

FRONTEND_PODS=$(kubectl get pods -n default -l app=frontend --no-headers 2>/dev/null | grep -c "Running")
check "Frontend Pods Running (min 2)" "$([ "$FRONTEND_PODS" -ge 2 ] && echo "OK" || echo "FAIL")" "OK"

POSTGRES_PODS=$(kubectl get pods -n default -l app=postgres --no-headers 2>/dev/null | grep -c "Running")
check "Postgres Pod Running" "$([ "$POSTGRES_PODS" -ge 1 ] && echo "OK" || echo "FAIL")" "OK"

NGINX_PODS=$(kubectl get pods -n default -l app.kubernetes.io/name=ingress-nginx --no-headers 2>/dev/null | grep -c "Running")
check "NGINX Ingress Running" "$([ "$NGINX_PODS" -ge 1 ] && echo "OK" || echo "FAIL")" "OK"

echo ""
echo "── 🔄 GitOps & CI/CD Tests ────────────────────────────"

ARGOCD_SYNC=$(kubectl get application -n argocd cloud-native-app -o jsonpath='{.status.sync.status}' 2>/dev/null)
check "Argo CD Sync Status" "${ARGOCD_SYNC:-UNKNOWN}" "Synced"

ARGOCD_HEALTH=$(kubectl get application -n argocd cloud-native-app -o jsonpath='{.status.health.status}' 2>/dev/null)
check "Argo CD Health Status" "${ARGOCD_HEALTH:-UNKNOWN}" "Healthy"

echo ""
echo "── 📊 Monitoring Tests ─────────────────────────────────"

GRAFANA_POD=$(kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana --no-headers 2>/dev/null | grep -c "Running")
check "Grafana Pod Running" "$([ "$GRAFANA_POD" -ge 1 ] && echo "OK" || echo "FAIL")" "OK"

PROMETHEUS_POD=$(kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus --no-headers 2>/dev/null | grep -c "Running")
check "Prometheus Pod Running" "$([ "$PROMETHEUS_POD" -ge 1 ] && echo "OK" || echo "FAIL")" "OK"

ALERTMGR_POD=$(kubectl get pods -n monitoring -l app.kubernetes.io/name=alertmanager --no-headers 2>/dev/null | grep -c "Running")
check "Alertmanager Pod Running" "$([ "$ALERTMGR_POD" -ge 1 ] && echo "OK" || echo "FAIL")" "OK"

echo ""
echo "── 📈 Auto-Scaling Tests ───────────────────────────────"

BACKEND_HPA=$(kubectl get hpa backend-hpa -n default --no-headers 2>/dev/null | awk '{print $6}')
check "Backend HPA Active" "$([ ! -z "$BACKEND_HPA" ] && echo "OK" || echo "FAIL")" "OK"

FRONTEND_HPA=$(kubectl get hpa frontend-hpa -n default --no-headers 2>/dev/null | awk '{print $6}')
check "Frontend HPA Active" "$([ ! -z "$FRONTEND_HPA" ] && echo "OK" || echo "FAIL")" "OK"

echo ""
echo "╔══════════════════════════════════════════════════════╗"
printf  "║  Results: ✅ %d Passed  |  ❌ %d Failed               ║\n" "$PASS" "$FAIL"
if [ "$FAIL" -eq 0 ]; then
echo "║  🎉 ALL TESTS PASSED! Platform is HEALTHY!          ║"
else
echo "║  ⚠️  Some tests failed. Check logs above.           ║"
fi
echo "╚══════════════════════════════════════════════════════╝"
echo ""
