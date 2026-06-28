# Deployment Guide

> **IMPORTANT NOTICE:** The application was successfully deployed to Amazon EKS during development and testing. The live AWS infrastructure has been decommissioned after project completion due to AWS credit limitations. All Kubernetes manifests, Terraform configuration, CI/CD pipeline, and deployment instructions remain available here for redeployment.

This guide outlines the process to deploy the Cloud Native DevOps Platform to an Amazon EKS cluster or a local Minikube environment.

## 1. Prerequisites
Before beginning the deployment, ensure the following tools are installed:
- AWS CLI (configured with appropriate credentials)
- Terraform (v1.x+)
- kubectl
- Docker
- GitHub Actions enabled on the repository

## 2. Infrastructure Deployment (Terraform)
The infrastructure is provisioned using Terraform, which creates a VPC, private/public subnets, NAT Gateway, IAM roles, and an EKS cluster.

```bash
cd terraform
terraform init
terraform plan
terraform apply --auto-approve
```

Once the cluster is created, configure your local `kubectl`:
```bash
aws eks update-kubeconfig --region us-east-1 --name <cluster_name>
```

## 3. Kubernetes Platform Setup
Before deploying the application, set up the necessary cluster add-ons.

### NGINX Ingress Controller
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/aws/deploy.yaml
```

### Cert-Manager
```bash
kubectl apply -f kubernetes/cert-manager/cert-manager.yaml
kubectl apply -f kubernetes/cert-manager/cluster-issuer.yaml
```

### External-DNS
Update the IAM Role ARN in `kubernetes/external-dns/external-dns.yaml` and deploy:
```bash
kubectl apply -f kubernetes/external-dns/external-dns.yaml
```

## 4. Application Deployment
You can deploy the application manually or allow the GitHub Actions CI/CD pipeline to handle it.

### Manual Deployment
```bash
kubectl apply -f kubernetes/storage/postgres-pvc.yaml
kubectl apply -f kubernetes/postgres-deployment.yaml
kubectl apply -f kubernetes/postgres-service.yaml

kubectl apply -f kubernetes/backend-deployment.yaml
kubectl apply -f kubernetes/backend-service.yaml

kubectl apply -f kubernetes/frontend-deployment.yaml
kubectl apply -f kubernetes/frontend-service.yaml

kubectl apply -f kubernetes/ingress.yaml
kubectl apply -f kubernetes/hpa/
```

### CI/CD Deployment
1. Ensure `KUBE_CONFIG_DATA`, `DOCKER_USERNAME`, and `DOCKER_PASSWORD` are set as repository secrets in GitHub.
2. Push a commit to the `main` branch.
3. The GitHub Actions workflow will automatically build, push, and deploy the application.

## 5. Teardown
To prevent ongoing AWS charges, destroy the infrastructure when finished:
```bash
cd terraform
terraform destroy --auto-approve
```
