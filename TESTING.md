# 🧪 Testing Documentation — Cloud Native DevOps Platform

This document covers all testing procedures for the Cloud Native DevOps Platform,
from local unit-level checks to full production cluster validation.

---

## 📋 Table of Contents

- [Test Environment URLs](#-test-environment-urls)
- [1. Local Development Tests](#1-local-development-tests)
- [2. Docker & Container Tests](#2-docker--container-tests)
- [3. API Endpoint Tests](#3-api-endpoint-tests)
- [4. Kubernetes Health Tests](#4-kubernetes-health-tests)
- [5. Ingress & Routing Tests](#5-ingress--routing-tests)
- [6. CI/CD Pipeline Tests](#6-cicd-pipeline-tests)
- [7. Argo CD GitOps Tests](#7-argo-cd-gitops-tests)
- [8. Monitoring & Alerting Tests](#8-monitoring--alerting-tests)
- [9. Auto-Scaling (HPA) Tests](#9-auto-scaling-hpa-tests)
- [10. Load Testing](#10-load-testing)
- [11. Full End-to-End Test Checklist](#11-full-end-to-end-test-checklist)
- [Expected Test Results Summary](#-expected-test-results-summary)

---

## 🌐 Test Environment URLs

| Environment | URL |
|------------|-----|
| **Production (ELB)** | `http://a4977326368864f1cbe72703bd19174a-173171894.us-east-1.elb.amazonaws.com` |
| **Grafana (port-forward)** | `http://localhost:3001` |
| **Prometheus (port-forward)** | `http://localhost:9090` |
| **Argo CD (port-forward)** | `https://localhost:8080` |

> Set this variable once to reuse in all test commands:
> ```bash
> export BASE_URL="http://a4977326368864f1cbe72703bd19174a-173171894.us-east-1.elb.amazonaws.com"
> ```

---

## 1. Local Development Tests

### 1.1 Run Backend Locally

```bash
cd backend
npm install
node server.js
```

**Expected output:**
```
✅ Server running on port 5000
📊 Metrics available at http://localhost:5000/metrics
❤️  Liveness  probe at  http://localhost:5000/health/live
✔️  Readiness probe at  http://localhost:5000/health/ready
```

### 1.2 Run Frontend Locally

```bash
cd frontend
npm install
npm start
```

**Expected:** Browser opens at `http://localhost:3000` with the dashboard UI.

### 1.3 Test with Docker Compose

```bash
docker compose up --build
```

**Expected:**
```
✅ backend  | Server running on port 5000
✅ frontend | Starting the development server...
```

Verify:
```bash
curl http://localhost:5000/api/message
curl http://localhost:3000
```

---

## 2. Docker & Container Tests

### 2.1 Build Backend Image

```bash
docker build -t test-backend ./backend
```

**Expected:** `Successfully built <image-id>` — no errors.

### 2.2 Build Frontend Image

```bash
docker build -t test-frontend ./frontend
```

**Expected:** `Successfully built <image-id>` — no errors.

### 2.3 Run Backend Container

```bash
docker run -d -p 5000:5000 --name test-backend test-backend
sleep 2
curl http://localhost:5000/health/live
docker rm -f test-backend
```

**Expected:**
```json
{"status":"alive","timestamp":"2026-..."}
```

### 2.4 Run Frontend Container

```bash
docker run -d -p 3000:3000 --name test-frontend test-frontend
sleep 2
curl -o /dev/null -s -w "%{http_code}\n" http://localhost:3000
docker rm -f test-frontend
```

**Expected:** `200`

### 2.5 Verify Docker Hub Images

```bash
docker pull chaninduimanjith/cloud-native-devops-backend:latest
docker pull chaninduimanjith/cloud-native-devops-frontend:latest
```

**Expected:** Images pull successfully without errors.

---

## 3. API Endpoint Tests

> Replace `$BASE_URL` with your ELB URL or `http://localhost:5000` for local.

### 3.1 Frontend Home Page

```bash
curl -s -o /dev/null -w "Status: %{http_code}\n" $BASE_URL/
```
**Expected:** `Status: 200`

### 3.2 API Message Endpoint

```bash
curl -s $BASE_URL/api/message | python3 -m json.tool
```

**Expected:**
```json
{
  "message": "DevOps Platform Backend Running 🚀",
  "timestamp": "2026-06-24T...",
  "version": "2.0.0"
}
```

### 3.3 API Status Endpoint

```bash
curl -s $BASE_URL/api/status | python3 -m json.tool
```

**Expected:**
```json
{
  "status": "healthy",
  "uptime": 3369.8,
  "memory": {
    "rss": 30650368,
    "heapTotal": 15958016,
    "heapUsed": 13682392
  },
  "timestamp": "2026-06-24T..."
}
```

### 3.4 Liveness Probe

```bash
curl -s $BASE_URL/health/live
```
**Expected:** `{"status":"alive","timestamp":"..."}`

### 3.5 Readiness Probe

```bash
curl -s $BASE_URL/health/ready
```
**Expected:** `{"status":"ready","timestamp":"..."}`

### 3.6 Startup Probe

```bash
curl -s $BASE_URL/health/startup
```
**Expected:** `{"status":"started","timestamp":"..."}`

### 3.7 Prometheus Metrics Endpoint

```bash
curl -s $BASE_URL/metrics | head -30
```

**Expected output includes:**
```
# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",route="/api/message",status_code="200"} ...

# HELP http_request_duration_seconds HTTP request duration in seconds
# TYPE http_request_duration_seconds histogram
...

# HELP nodejs_heap_size_total_bytes Process heap size from Node.js in bytes
...
```

### 3.8 Test CORS Headers

```bash
curl -s -I -X OPTIONS $BASE_URL/api/message \
  -H "Origin: http://example.com" \
  -H "Access-Control-Request-Method: GET"
```
**Expected:** Response includes `Access-Control-Allow-Origin` header.

### 3.9 Test Non-Existent Route (404)

```bash
curl -s -o /dev/null -w "%{http_code}\n" $BASE_URL/api/nonexistent
```
**Expected:** `404`

---

## 4. Kubernetes Health Tests

### 4.1 Check All Nodes Ready

```bash
kubectl get nodes
```

**Expected:**
```
NAME                         STATUS   ROLES    AGE   VERSION
ip-10-0-1-xxx.ec2.internal   Ready    <none>   ...   v1.30.x
ip-10-0-2-xxx.ec2.internal   Ready    <none>   ...   v1.30.x
ip-10-0-3-xxx.ec2.internal   Ready    <none>   ...   v1.30.x
```
All 3 nodes must be `Ready`.

### 4.2 Check All Pods Running

```bash
kubectl get pods -A
```

**Expected pods & status:**

| Namespace | Deployment | Expected Status |
|-----------|-----------|----------------|
| `default` | `frontend` (×2) | `Running` |
| `default` | `backend` (×2) | `Running` |
| `default` | `postgres` | `Running` |
| `default` | `ingress-nginx-controller` | `Running` |
| `argocd` | `argocd-server` | `Running` |
| `argocd` | `argocd-application-controller` | `Running` |
| `argocd` | `argocd-repo-server` | `Running` |
| `cert-manager` | `cert-manager` | `Running` |
| `monitoring` | `monitoring-grafana` | `Running` |
| `monitoring` | `prometheus-*` | `Running` |
| `monitoring` | `alertmanager-*` | `Running` |

### 4.3 Check No CrashLoopBackOff Pods

```bash
kubectl get pods -A | grep -v "Running\|Completed\|NAME"
```
**Expected:** No output (all pods healthy).

### 4.4 Check Backend Pod Logs

```bash
kubectl logs -l app=backend --tail=20
```
**Expected:** No ERROR lines; shows startup logs.

### 4.5 Check Frontend Pod Logs

```bash
kubectl logs -l app=frontend --tail=10
```
**Expected:** NGINX access logs, no errors.

### 4.6 Check Resource Usage

```bash
kubectl top nodes
kubectl top pods
```
**Expected:** CPU and memory usage well within limits.

### 4.7 Verify Services

```bash
kubectl get svc -n default
```

**Expected:**
```
NAME                      TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)
backend                   ClusterIP      172.20.x.x     <none>        5000/TCP
frontend                  ClusterIP      172.20.x.x     <none>        3000/TCP
postgres                  ClusterIP      172.20.x.x     <none>        5432/TCP
ingress-nginx-controller  LoadBalancer   172.20.x.x     <ELB-URL>     80:xxx,443:xxx
```

---

## 5. Ingress & Routing Tests

### 5.1 Verify Ingress is Configured

```bash
kubectl get ingress -n default
kubectl describe ingress cloud-native-ingress
```

**Expected:** `ADDRESS` shows ELB URL, rules show `/` → frontend and `/api` → backend.

### 5.2 Test Frontend Route via ELB

```bash
curl -s -o /dev/null -w "/ → %{http_code}\n" $BASE_URL/
```
**Expected:** `/ → 200`

### 5.3 Test API Route via ELB

```bash
curl -s -o /dev/null -w "/api/message → %{http_code}\n" $BASE_URL/api/message
```
**Expected:** `/api/message → 200`

### 5.4 Test Direct Ingress Controller

```bash
kubectl exec -it $(kubectl get pod -l app.kubernetes.io/name=ingress-nginx -o name | head -1) \
  -- curl -s http://localhost/api/status
```
**Expected:** JSON status response from backend.

---

## 6. CI/CD Pipeline Tests

### 6.1 Trigger Pipeline

```bash
git commit --allow-empty -m "test: trigger CI/CD pipeline"
git push origin main
```

**Go to:** `https://github.com/ChaninduImanjith/cloud-native-devops-platform/actions`

**Expected pipeline steps to pass:**

| Step | Expected Result |
|------|----------------|
| Checkout Repository | ✅ Pass |
| Set up Docker Buildx | ✅ Pass |
| Login to Docker Hub | ✅ Pass |
| Build & Push Backend Image | ✅ Pass |
| Build & Push Frontend Image | ✅ Pass |
| Configure AWS Credentials | ✅ Pass |
| Update KubeConfig | ✅ Pass |
| Inject Secrets to Kubernetes | ✅ Pass |
| Apply monitoring config | ✅ Pass |

### 6.2 Verify Docker Hub Updated

```bash
docker pull chaninduimanjith/cloud-native-devops-backend:latest
docker inspect chaninduimanjith/cloud-native-devops-backend:latest | grep Created
```
**Expected:** Timestamp matches recent pipeline run.

### 6.3 Test Secret Injection

```bash
kubectl get secret alertmanager-auth -n monitoring
```
**Expected:** Secret exists with `password` key.

---

## 7. Argo CD GitOps Tests

### 7.1 Access Argo CD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
```
Open: `https://localhost:8080`
**Login:** `admin` / (get password below)

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

### 7.2 Check Application Sync Status

```bash
kubectl get application -n argocd
```

**Expected:**
```
NAME               SYNC STATUS   HEALTH STATUS
cloud-native-app   Synced        Healthy
```

### 7.3 Test Auto-Sync (GitOps)

1. Make a small change to any file in `kubernetes/`
2. Push to `main`
3. Watch Argo CD detect and apply the change:

```bash
kubectl get application -n argocd -w
```
**Expected:** Status briefly shows `OutOfSync` → then returns to `Synced` automatically.

### 7.4 Test Self-Healing

```bash
# Manually delete a deployment — Argo CD should recreate it
kubectl delete deployment frontend
sleep 30
kubectl get deployment frontend
```
**Expected:** Frontend deployment is automatically recreated by Argo CD.

---

## 8. Monitoring & Alerting Tests

### 8.1 Start Monitoring Port-Forwards

```bash
# Grafana
kubectl port-forward -n monitoring svc/monitoring-grafana 3001:80 &

# Prometheus
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090 &
```

### 8.2 Test Grafana Login

Open: `http://localhost:3001`

```
Username: admin
Password: vOZuY9kJ01Mt9BZxEMuvU2FWstqZtM6qaDdJiocQ
```

**Expected:** Grafana dashboard loads with pre-configured panels.

### 8.3 Verify Prometheus Scraping Backend

Open: `http://localhost:9090/targets`

**Expected:** `default/backend-service` appears in targets with state `UP`.

### 8.4 Test Custom Metrics in Prometheus

In Prometheus UI (`http://localhost:9090`), run these queries:

```promql
# Total HTTP requests
http_requests_total

# Request rate (last 5 minutes)
rate(http_requests_total[5m])

# Average response time
rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m])

# Node.js heap usage
nodejs_heap_size_used_bytes
```

**Expected:** All queries return data points.

### 8.5 Verify Prometheus Metrics via API

```bash
curl -s http://localhost:9090/api/v1/query?query=http_requests_total | python3 -m json.tool | head -20
```
**Expected:** JSON with `"status": "success"` and `result` array.

### 8.6 Check Alert Rules Loaded

```bash
curl -s http://localhost:9090/api/v1/rules | python3 -m json.tool | grep "name"
```
**Expected:** Custom alert rule names appear (HighErrorRate, HighMemoryUsage, etc.)

### 8.7 Verify ServiceMonitor

```bash
kubectl get servicemonitor -n monitoring
kubectl describe servicemonitor -n monitoring | grep -A5 "Endpoints"
```
**Expected:** ServiceMonitor targeting `backend` on `/metrics` port `5000`.

---

## 9. Auto-Scaling (HPA) Tests

### 9.1 Check HPA Status

```bash
kubectl get hpa -A
```

**Expected:**
```
NAME           REFERENCE             TARGETS           MINPODS   MAXPODS   REPLICAS
backend-hpa    Deployment/backend    25%/70%, 40%/80%  2         5         2
frontend-hpa   Deployment/frontend   10%/70%, 30%/80%  2         5         2
```

### 9.2 Watch HPA in Real Time

```bash
kubectl get hpa -w
```
Keep this running while performing load test (Section 10).

### 9.3 Verify Metrics Server is Running

```bash
kubectl get deployment metrics-server -n kube-system
kubectl top pods -n default
```
**Expected:** `metrics-server` is `Running`, and pod metrics are displayed.

### 9.4 Manual Scale Test

```bash
# Scale down manually
kubectl scale deployment backend --replicas=1

# HPA should scale back up to minReplicas (2) within ~30 seconds
sleep 40
kubectl get pods -l app=backend
```
**Expected:** 2 backend pods running (HPA enforces minimum).

---

## 10. Load Testing

> **Tool:** `curl` loop or install `hey` / `ab` for proper load testing.

### 10.1 Basic Load Test with curl Loop

```bash
for i in {1..50}; do
  curl -s -o /dev/null -w "Request $i: %{http_code} | Time: %{time_total}s\n" \
    $BASE_URL/api/message
done
```

**Expected:** All requests return `200`, response time < 1s.

### 10.2 Concurrent Load Test (using background jobs)

```bash
for i in {1..20}; do
  curl -s -o /dev/null $BASE_URL/api/status &
done
wait
echo "All 20 concurrent requests completed"
```

**Expected:** All complete without errors.

### 10.3 Install and Use `hey` for Load Testing

```bash
# Install hey
go install github.com/rakyll/hey@latest
# OR use apt:
# sudo apt install hey

# Run 200 requests, 10 concurrent
hey -n 200 -c 10 $BASE_URL/api/message
```

**Expected output:**
```
Summary:
  Total:        X.XX secs
  Slowest:      X.XXX secs
  Fastest:      X.XXX secs
  Average:      X.XXX secs
  Requests/sec: XXX.XX

Status code distribution:
  [200] 200 responses
```

### 10.4 Watch HPA Scale During Load

While the load test runs, in another terminal:
```bash
kubectl get hpa backend-hpa -w
```
**Expected:** `REPLICAS` increases beyond `2` as CPU/memory rises during load.

### 10.5 Verify Metrics After Load Test

In Prometheus:
```promql
# Total requests processed
http_requests_total

# Requests per second
rate(http_requests_total[1m])

# 95th percentile latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

---

## 11. Full End-to-End Test Checklist

Use this checklist to verify the entire system before final submission or demo:

### Infrastructure ✅
- [ ] `terraform output` shows correct `cluster_endpoint` and `cluster_name`
- [ ] `kubectl get nodes` shows 3 nodes all in `Ready` state
- [ ] Node instance type is `t3.micro`
- [ ] VPC CNI prefix delegation enabled (max 110 pods/node)

### Application ✅
- [ ] Frontend loads at `$BASE_URL/` → HTTP 200
- [ ] Backend responds at `$BASE_URL/api/message` → HTTP 200
- [ ] Backend responds at `$BASE_URL/api/status` → HTTP 200
- [ ] Health probes return correct JSON (`/health/live`, `/health/ready`, `/health/startup`)
- [ ] Prometheus metrics available at `$BASE_URL/metrics`

### Kubernetes ✅
- [ ] All pods in `default` namespace are `Running`
- [ ] All pods in `argocd` namespace are `Running`
- [ ] All pods in `monitoring` namespace are `Running`
- [ ] All pods in `cert-manager` namespace are `Running`
- [ ] NGINX Ingress Controller has external ELB IP assigned
- [ ] HPA is active for `backend` and `frontend`

### CI/CD ✅
- [ ] Push to `main` triggers GitHub Actions workflow
- [ ] Docker images built and pushed to Docker Hub
- [ ] AWS credentials configured via GitHub Secrets
- [ ] Kubernetes secrets injected from GitHub Secrets

### GitOps ✅
- [ ] Argo CD application status: `Synced` + `Healthy`
- [ ] Auto-sync works on `git push`
- [ ] Self-healing works (deleted pod gets recreated)

### Monitoring ✅
- [ ] Grafana accessible at `http://localhost:3001`
- [ ] Prometheus targets show `backend` as `UP`
- [ ] Custom metrics (`http_requests_total`) appear in Prometheus
- [ ] Grafana dashboard shows live graphs
- [ ] Alert rules loaded in Prometheus

### Auto-Scaling ✅
- [ ] `kubectl get hpa` shows both HPAs with valid targets
- [ ] `kubectl top pods` returns live metrics
- [ ] HPA scales up under load (min 2, max 5 replicas)

---

## 📊 Expected Test Results Summary

| Test Category | Total Tests | Expected Pass |
|--------------|-------------|---------------|
| Local Dev | 3 | ✅ 3/3 |
| Docker & Container | 5 | ✅ 5/5 |
| API Endpoints | 9 | ✅ 9/9 |
| Kubernetes Health | 7 | ✅ 7/7 |
| Ingress & Routing | 4 | ✅ 4/4 |
| CI/CD Pipeline | 3 | ✅ 3/3 |
| Argo CD GitOps | 4 | ✅ 4/4 |
| Monitoring | 7 | ✅ 7/7 |
| Auto-Scaling | 4 | ✅ 4/4 |
| Load Testing | 5 | ✅ 5/5 |
| **TOTAL** | **51** | **✅ 51/51** |

---

## 🛠️ Quick Test Script

Run all critical checks at once:

```bash
#!/bin/bash
BASE_URL="http://a4977326368864f1cbe72703bd19174a-173171894.us-east-1.elb.amazonaws.com"

echo "🧪 Running Cloud Native DevOps Platform Tests..."
echo ""

# Test 1: Frontend
STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/)
echo "Frontend (/)               → HTTP $STATUS $([ "$STATUS" = "200" ] && echo "✅" || echo "❌")"

# Test 2: API Message
STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/api/message)
echo "API Message (/api/message) → HTTP $STATUS $([ "$STATUS" = "200" ] && echo "✅" || echo "❌")"

# Test 3: API Status
STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/api/status)
echo "API Status  (/api/status)  → HTTP $STATUS $([ "$STATUS" = "200" ] && echo "✅" || echo "❌")"

# Test 4: Liveness
STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/health/live)
echo "Liveness    (/health/live) → HTTP $STATUS $([ "$STATUS" = "200" ] && echo "✅" || echo "❌")"

# Test 5: Readiness
STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/health/ready)
echo "Readiness   (/health/ready)→ HTTP $STATUS $([ "$STATUS" = "200" ] && echo "✅" || echo "❌")"

# Test 6: Metrics
STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/metrics)
echo "Metrics     (/metrics)     → HTTP $STATUS $([ "$STATUS" = "200" ] && echo "✅" || echo "❌")"

# Test 7: Kubernetes Nodes
READY=$(kubectl get nodes --no-headers | grep -c "Ready")
echo "K8s Nodes Ready            → $READY/3 $([ "$READY" = "3" ] && echo "✅" || echo "❌")"

# Test 8: Running Pods
RUNNING=$(kubectl get pods -n default --no-headers | grep -c "Running")
echo "Pods Running (default ns)  → $RUNNING $([ "$RUNNING" -ge "5" ] && echo "✅" || echo "❌")"

# Test 9: Argo CD Sync
SYNC=$(kubectl get application -n argocd cloud-native-app -o jsonpath='{.status.sync.status}' 2>/dev/null)
echo "Argo CD Sync Status        → $SYNC $([ "$SYNC" = "Synced" ] && echo "✅" || echo "⚠️")"

# Test 10: HPA
HPA=$(kubectl get hpa backend-hpa --no-headers 2>/dev/null | awk '{print $6}')
echo "Backend HPA Replicas       → $HPA $([ ! -z "$HPA" ] && echo "✅" || echo "❌")"

echo ""
echo "🎯 Tests Complete!"
```

Save this as `test.sh` and run:
```bash
chmod +x test.sh
./test.sh
```

---

*Last updated: June 2026 | Cloud Native DevOps Platform v2.0.0*
