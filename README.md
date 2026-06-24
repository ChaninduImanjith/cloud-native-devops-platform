# ☁️ Cloud Native DevOps Platform

A production-grade, cloud-native full-stack application deployed on **AWS EKS** with full **CI/CD automation**, **GitOps**, **observability**, and **auto-scaling** — built from scratch using modern DevOps best practices.

---

## 🌐 Live Application

> **URL:** `http://a4977326368864f1cbe72703bd19174a-173171894.us-east-1.elb.amazonaws.com`

---

## 📋 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Step 1 — Local Development Setup](#step-1--local-development-setup)
- [Step 2 — Dockerize the Application](#step-2--dockerize-the-application)
- [Step 3 — Provision AWS Infrastructure with Terraform](#step-3--provision-aws-infrastructure-with-terraform)
- [Step 4 — Deploy to Kubernetes (EKS)](#step-4--deploy-to-kubernetes-eks)
- [Step 5 — Set Up GitOps with Argo CD](#step-5--set-up-gitops-with-argo-cd)
- [Step 6 — CI/CD Pipeline with GitHub Actions](#step-6--cicd-pipeline-with-github-actions)
- [Step 7 — Monitoring with Prometheus & Grafana](#step-7--monitoring-with-prometheus--grafana)
- [Step 8 — Auto-Scaling (HPA)](#step-8--auto-scaling-hpa)
- [API Endpoints](#-api-endpoints)
- [GitHub Secrets Required](#-github-secrets-required)
- [Troubleshooting](#-troubleshooting)

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitHub Repository                         │
│  ┌──────────────┐     ┌──────────────────────────────────────┐  │
│  │  Source Code  │────▶│   GitHub Actions CI/CD Pipeline      │  │
│  └──────────────┘     │  (Build → Push Docker → Deploy EKS)  │  │
│                        └──────────────────────────────────────┘  │
└───────────────────────────────────┬─────────────────────────────┘
                                    │
                    ┌───────────────▼──────────────────┐
                    │         Docker Hub Registry        │
                    │  chaninduimanjith/cloud-native-*  │
                    └───────────────┬──────────────────┘
                                    │
                    ┌───────────────▼──────────────────┐
                    │        AWS EKS Cluster            │
                    │  ┌────────────────────────────┐  │
                    │  │       Argo CD (GitOps)      │  │
                    │  │   (Auto-sync from GitHub)   │  │
                    │  └────────────────────────────┘  │
                    │                                    │
                    │  ┌──────────┐  ┌──────────────┐  │
                    │  │ Frontend │  │   Backend     │  │
                    │  │ (React)  │  │  (Node.js)    │  │
                    │  │ :3000    │  │   :5000       │  │
                    │  └──────────┘  └──────────────┘  │
                    │                                    │
                    │  ┌──────────┐  ┌──────────────┐  │
                    │  │PostgreSQL│  │ NGINX Ingress │  │
                    │  │   DB     │  │  Controller   │  │
                    │  └──────────┘  └──────────────┘  │
                    │                                    │
                    │  ┌──────────────────────────────┐ │
                    │  │  Prometheus + Grafana + Loki  │ │
                    │  │       (Monitoring Stack)      │ │
                    │  └──────────────────────────────┘ │
                    └──────────────────────────────────┘
                                    │
                    ┌───────────────▼──────────────────┐
                    │     AWS Load Balancer (ELB)        │
                    │  Internet Traffic → Port 80/443   │
                    └──────────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | React 19, NGINX |
| **Backend** | Node.js, Express.js |
| **Database** | PostgreSQL |
| **Containerization** | Docker, Docker Compose |
| **Container Registry** | Docker Hub |
| **Infrastructure (IaC)** | Terraform (AWS VPC + EKS modules) |
| **Cloud Provider** | AWS (EKS, EC2, VPC, ELB) |
| **Orchestration** | Kubernetes (EKS v1.30) |
| **Ingress** | NGINX Ingress Controller |
| **GitOps** | Argo CD |
| **CI/CD** | GitHub Actions |
| **Monitoring** | Prometheus, Grafana, Alertmanager |
| **Metrics** | prom-client (custom Node.js metrics) |
| **Auto-scaling** | Kubernetes HPA (Horizontal Pod Autoscaler) |
| **Secrets** | GitHub Actions Secrets → Kubernetes Secrets |

---

## 📁 Project Structure

```
cloud-native-devops-platform/
│
├── .github/
│   └── workflows/
│       └── ci-cd.yml              # GitHub Actions CI/CD pipeline
│
├── backend/
│   ├── server.js                  # Express API with Prometheus metrics
│   ├── package.json
│   ├── Dockerfile
│   └── .dockerignore
│
├── frontend/
│   ├── src/                       # React application source
│   ├── public/
│   ├── nginx.conf                 # Production NGINX config
│   ├── Dockerfile
│   └── package.json
│
├── kubernetes/
│   ├── backend-deployment.yaml    # Backend Deployment (2 replicas)
│   ├── backend-service.yaml       # Backend ClusterIP Service
│   ├── frontend-deployment.yaml   # Frontend Deployment (2 replicas)
│   ├── frontend-service.yaml      # Frontend ClusterIP Service
│   ├── postgres-deployment.yaml   # PostgreSQL Deployment
│   ├── postgres-service.yaml      # PostgreSQL ClusterIP Service
│   ├── ingress.yaml               # NGINX Ingress (routes / and /api)
│   ├── argocd/
│   │   ├── application.yaml       # Argo CD Application manifest
│   │   └── install-argocd.sh      # Argo CD installation script
│   ├── cert-manager/
│   │   └── cluster-issuer.yaml    # Let's Encrypt ClusterIssuer
│   ├── external-dns/
│   │   └── external-dns.yaml      # ExternalDNS config
│   ├── hpa/
│   │   ├── backend-hpa.yaml       # Backend HPA (2-5 replicas)
│   │   └── frontend-hpa.yaml      # Frontend HPA
│   ├── logging/                   # Loki logging manifests
│   └── storage/
│       └── postgres-pvc.yaml      # PostgreSQL PersistentVolumeClaim
│
├── monitoring/
│   ├── install-monitoring.sh      # Helm install script for Prometheus stack
│   ├── servicemonitor.yaml        # Prometheus ServiceMonitor for backend
│   ├── alert-rules.yaml           # Custom Prometheus alert rules
│   ├── alertmanager-config.yaml   # Alertmanager email config
│   └── grafana-dashboard.yaml     # Custom Grafana dashboard
│
├── terraform/
│   ├── providers.tf               # AWS provider config
│   ├── variables.tf               # Input variables
│   ├── outputs.tf                 # Output values (cluster endpoint, etc.)
│   ├── vpc.tf                     # VPC with public/private subnets
│   └── eks.tf                     # EKS cluster + managed node group
│
├── docker-compose.yml             # Local development compose file
├── deploy.sh                      # Manual redeploy script
└── .gitignore
```

---

## ✅ Prerequisites

Before you begin, ensure you have the following installed:

| Tool | Version | Purpose |
|------|---------|---------|
| `git` | any | Version control |
| `docker` | 20+ | Build & run containers |
| `docker compose` | v2+ | Local development |
| `node` + `npm` | 18+ | Run app locally |
| `terraform` | 1.5+ | Provision AWS infra |
| `aws cli` | v2 | AWS authentication |
| `kubectl` | 1.28+ | Manage Kubernetes |
| `helm` | 3.x | Install Kubernetes packages |

---

## Step 1 — Local Development Setup

### 1.1 Clone the Repository

```bash
git clone https://github.com/ChaninduImanjith/cloud-native-devops-platform.git
cd cloud-native-devops-platform
```

### 1.2 Run Backend Locally

```bash
cd backend
npm install
node server.js
# ✅ Server running on http://localhost:5000
```

### 1.3 Run Frontend Locally

```bash
cd frontend
npm install
npm start
# ✅ App running on http://localhost:3000
```

### 1.4 Run with Docker Compose (Recommended)

```bash
docker compose up --build
# Frontend → http://localhost:3000
# Backend  → http://localhost:5000
```

---

## Step 2 — Dockerize the Application

### 2.1 Backend Dockerfile

Multi-stage production image for the Node.js backend:

```bash
docker build -t cloud-native-devops-backend ./backend
docker run -p 5000:5000 cloud-native-devops-backend
```

### 2.2 Frontend Dockerfile

React app built and served via NGINX:

```bash
docker build -t cloud-native-devops-frontend ./frontend
docker run -p 3000:3000 cloud-native-devops-frontend
```

### 2.3 Push to Docker Hub

```bash
docker login
docker tag cloud-native-devops-backend chaninduimanjith/cloud-native-devops-backend:latest
docker push chaninduimanjith/cloud-native-devops-backend:latest

docker tag cloud-native-devops-frontend chaninduimanjith/cloud-native-devops-frontend:latest
docker push chaninduimanjith/cloud-native-devops-frontend:latest
```

---

## Step 3 — Provision AWS Infrastructure with Terraform

### 3.1 Configure AWS Credentials

```bash
aws configure
# Enter: AWS Access Key ID
# Enter: AWS Secret Access Key
# Enter: Default region: us-east-1
# Enter: Output format: json
```

### 3.2 Initialize Terraform

```bash
cd terraform
terraform init
```

### 3.3 Review the Plan

```bash
terraform plan
```

This will provision:
- **VPC** with CIDR `10.0.0.0/16`
- **3 Private Subnets** (for EKS nodes): `10.0.1.0/24`, `10.0.2.0/24`, `10.0.3.0/24`
- **3 Public Subnets** (for Load Balancers): `10.0.101.0/24`, `10.0.102.0/24`, `10.0.103.0/24`
- **NAT Gateway** (single, for cost optimization)
- **EKS Cluster** (`cloud-native-devops-cluster`) on Kubernetes v1.30
- **Managed Node Group** — 3× `t3.micro` instances (min: 2, max: 4)
- **VPC CNI Addon** with prefix delegation (max 110 pods/node)

### 3.4 Apply Infrastructure

```bash
terraform apply
# Type: yes
# ⏳ Takes ~15-20 minutes
```

### 3.5 Configure kubectl

```bash
aws eks update-kubeconfig --name cloud-native-devops-cluster --region us-east-1
kubectl get nodes  # Should show 3 Ready nodes
```

---

## Step 4 — Deploy to Kubernetes (EKS)

### 4.1 Deploy PostgreSQL Database

```bash
kubectl apply -f kubernetes/storage/postgres-pvc.yaml
kubectl apply -f kubernetes/postgres-deployment.yaml
kubectl apply -f kubernetes/postgres-service.yaml
```

### 4.2 Deploy Backend

```bash
kubectl apply -f kubernetes/backend-deployment.yaml
kubectl apply -f kubernetes/backend-service.yaml
```

### 4.3 Deploy Frontend

```bash
kubectl apply -f kubernetes/frontend-deployment.yaml
kubectl apply -f kubernetes/frontend-service.yaml
```

### 4.4 Install NGINX Ingress Controller

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace default \
  --set controller.service.type=LoadBalancer
```

### 4.5 Apply Ingress Rules

```bash
kubectl apply -f kubernetes/ingress.yaml
```

> Routes:
> - `/` → Frontend (port 3000)
> - `/api` → Backend (port 5000)

### 4.6 Get Your Application URL

```bash
kubectl get ingress
# EXTERNAL-IP column shows your AWS Load Balancer URL
```

### 4.7 Verify All Pods are Running

```bash
kubectl get pods -A
# All pods should be in Running state
```

---

## Step 5 — Set Up GitOps with Argo CD

### 5.1 Install Argo CD

```bash
bash kubernetes/argocd/install-argocd.sh
# OR manually:
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 5.2 Access Argo CD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Open: https://localhost:8080
```

Get the admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

> Login: **admin** / (password from above command)

### 5.3 Deploy the Argo CD Application

```bash
kubectl apply -f kubernetes/argocd/application.yaml
```

This creates an Argo CD Application that:
- **Watches** `https://github.com/ChaninduImanjith/cloud-native-devops-platform.git`
- **Syncs** the `kubernetes/` directory (recursively) to the cluster
- **Auto-prunes** deleted resources
- **Self-heals** if someone manually changes cluster state

From this point, every `git push` to `main` will automatically sync to your EKS cluster via Argo CD.

---

## Step 6 — CI/CD Pipeline with GitHub Actions

The pipeline is defined in `.github/workflows/ci-cd.yml` and triggers on every push to `main`.

### Pipeline Flow

```
Push to main
    │
    ▼
┌─────────────────────────────────┐
│  Job 1: docker                  │
│  ✅ Checkout code               │
│  ✅ Setup Docker Buildx         │
│  ✅ Login to Docker Hub         │
│  ✅ Build & Push Backend image  │
│  ✅ Build & Push Frontend image │
└─────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────┐
│  Job 2: deploy                  │
│  ✅ Checkout code               │
│  ✅ Configure AWS credentials   │
│  ✅ Update kubeconfig (EKS)     │
│  ✅ Inject Kubernetes Secrets   │
│  ✅ Apply monitoring config     │
└─────────────────────────────────┘
```

### Docker Hub Images

| Image | Tag |
|-------|-----|
| `chaninduimanjith/cloud-native-devops-backend` | `latest` |
| `chaninduimanjith/cloud-native-devops-frontend` | `latest` |

---

## Step 7 — Monitoring with Prometheus & Grafana

### 7.1 Install the Monitoring Stack

```bash
bash monitoring/install-monitoring.sh
```

This installs via Helm:
- **Prometheus** — metrics collection & alerting
- **Grafana** — dashboards & visualization
- **Alertmanager** — alert routing (email notifications)
- **Node Exporter** — hardware/OS metrics per node
- **Kube State Metrics** — Kubernetes object metrics

### 7.2 Apply Custom Manifests

```bash
kubectl apply -f monitoring/servicemonitor.yaml    # Scrape backend /metrics
kubectl apply -f monitoring/alert-rules.yaml       # Custom alert rules
kubectl apply -f monitoring/grafana-dashboard.yaml # Pre-built dashboard
kubectl apply -f monitoring/alertmanager-config.yaml
```

### 7.3 Access Grafana

```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3001:80 &
# Open: http://localhost:3001
# Login: admin / prom-operator
```

### 7.4 Access Prometheus

```bash
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090 &
# Open: http://localhost:9090
```

### 7.5 Custom Backend Metrics (Prometheus)

The backend exposes these custom metrics at `/metrics`:

| Metric | Type | Description |
|--------|------|-------------|
| `http_requests_total` | Counter | Total HTTP requests by method, route, status |
| `http_request_duration_seconds` | Histogram | Request latency in seconds |
| `http_requests_in_flight` | Gauge | Current active requests |
| `nodejs_*` | Default | Node.js runtime metrics (heap, GC, event loop) |

---

## Step 8 — Auto-Scaling (HPA)

Horizontal Pod Autoscaler is configured for both backend and frontend.

### Backend HPA

```yaml
# kubernetes/hpa/backend-hpa.yaml
minReplicas: 2
maxReplicas: 5
CPU target:    70% utilization
Memory target: 80% utilization
```

```bash
kubectl apply -f kubernetes/hpa/backend-hpa.yaml
kubectl apply -f kubernetes/hpa/frontend-hpa.yaml

# Watch scaling in real time:
kubectl get hpa -w
```

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/message` | Returns platform status message |
| `GET` | `/api/status` | Returns uptime, memory, health |
| `GET` | `/metrics` | Prometheus metrics scrape endpoint |
| `GET` | `/health/live` | Liveness probe |
| `GET` | `/health/ready` | Readiness probe |
| `GET` | `/health/startup` | Startup probe |

**Example:**
```bash
curl http://<ELB-URL>/api/message
# {"message":"DevOps Platform Backend Running 🚀","timestamp":"...","version":"2.0.0"}

curl http://<ELB-URL>/api/status
# {"status":"healthy","uptime":123.45,"memory":{...},"timestamp":"..."}
```

---

## 🔐 GitHub Secrets Required

Go to **GitHub → Repository → Settings → Secrets and variables → Actions** and add:

| Secret Name | Description |
|-------------|-------------|
| `DOCKER_USERNAME` | Docker Hub username (`chaninduimanjith`) |
| `DOCKER_TOKEN` | Docker Hub access token (not password) |
| `AWS_ACCESS_KEY_ID` | AWS IAM access key |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM secret key |
| `GMAIL_APP_PASSWORD` | Gmail App Password for Alertmanager email alerts |

---

## 🔧 Troubleshooting

### Check Pod Status
```bash
kubectl get pods -A
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Check Ingress
```bash
kubectl get ingress
kubectl describe ingress cloud-native-ingress
```

### Pods Stuck in Pending (Too Many Pods)
EKS `t3.micro` has limited pod capacity. This was resolved by enabling VPC CNI prefix delegation:
```bash
# Already configured in terraform/eks.tf
# ENABLE_PREFIX_DELEGATION = "true" → allows up to 110 pods/node
```

### Rolling Restart After Image Update
```bash
kubectl rollout restart deployment/backend
kubectl rollout restart deployment/frontend
kubectl rollout status deployment/backend
```

### Destroy Infrastructure (Save AWS Costs)
```bash
cd terraform
terraform destroy
# Type: yes
```

---

## 📊 Cluster Info

| Property | Value |
|----------|-------|
| **Cluster Name** | `cloud-native-devops-cluster` |
| **Region** | `us-east-1` |
| **Kubernetes Version** | `1.30` |
| **Node Instance Type** | `t3.micro` |
| **Node Count** | 3 (min: 2, max: 4) |
| **Max Pods/Node** | 110 (via VPC CNI prefix delegation) |
| **VPC CIDR** | `10.0.0.0/16` |

---

## 👨‍💻 Author

**Chanindu Imanjith**
- GitHub: [@ChaninduImanjith](https://github.com/ChaninduImanjith)
- Docker Hub: [chaninduimanjith](https://hub.docker.com/u/chaninduimanjith)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).