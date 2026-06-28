# Monitoring and Observability

To ensure the reliability and performance of the Cloud Native DevOps Platform, a comprehensive monitoring stack based on Prometheus and Grafana is utilized.

> **IMPORTANT NOTICE:** The application was successfully deployed to Amazon EKS. The infrastructure is currently offline due to AWS credit limitations.

## Architecture

1. **Prometheus:** Acts as the core metrics collection engine. It is configured to scrape metrics from:
   - Kubernetes Node Exporter (CPU, Memory, Disk, Network)
   - Kubernetes cAdvisor (Container metrics)
   - Application-level metrics (e.g., custom HTTP response times, error rates)
   
2. **Grafana:** Connects to Prometheus as a data source to provide rich, visual dashboards.

3. **Alertmanager:** Evaluates alerting rules against Prometheus metrics and sends notifications (e.g., Slack, Email, PagerDuty) when critical thresholds are breached.

## Dashboards
Custom Grafana dashboards are provisioned via ConfigMaps to visualize:
- Cluster Health (Node CPU/Memory usage, Pod counts).
- Application Performance (API latency, Request rates, 4xx/5xx error rates).
- Database Metrics (Active connections, Query performance).

## Alerting Rules
Examples of configured alerts include:
- **NodeMemoryPressure:** Triggered if a Kubernetes node exceeds 85% memory utilization.
- **HighErrorRate:** Triggered if the backend API returns >5% 5xx errors over a 5-minute window.
- **PodCrashLooping:** Triggered if any pod enters a CrashLoopBackOff state.

## Installation
The monitoring stack can be deployed using the manifests located in the `monitoring/` directory or via the official kube-prometheus-stack Helm chart.

```bash
kubectl create namespace monitoring
kubectl apply -f monitoring/ -n monitoring
```

## Accessing Grafana
When deployed, Grafana can be accessed via Port Forwarding or an Ingress route (if configured).

```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
```
Default Login: `admin` / `admin` (You will be prompted to change the password upon first login).
