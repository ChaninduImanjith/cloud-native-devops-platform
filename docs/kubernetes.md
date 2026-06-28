# Kubernetes Architecture

This project heavily leverages Kubernetes to orchestrate the application, ensuring high availability, self-healing, and seamless scalability.

> **IMPORTANT NOTICE:** The application was successfully deployed to Amazon EKS. The infrastructure is currently offline due to AWS credit limitations.

## Core Components

### 1. Pods and Deployments
- **Frontend Deployment:** Runs the React application behind an NGINX static server. Configured with liveness and readiness probes to ensure traffic is only routed to healthy pods.
- **Backend Deployment:** Runs the Node.js API. Configured with resource requests and limits to guarantee QoS (Quality of Service) and prevent node starvation.
- **PostgreSQL Deployment:** Uses a StatefulSet (or Deployment with a singular replica and PVC) to manage the database engine.

### 2. Services
- **ClusterIP:** Used for internal communication between the backend and PostgreSQL. The backend communicates with the database using the internal DNS name `postgres-service`.
- **NodePort/ClusterIP:** Used for exposing the frontend and backend to the Ingress controller.

### 3. Ingress
- An **NGINX Ingress Controller** is utilized to route external traffic to the internal services based on paths.
- `/api(/|$)(.*)` routes traffic to the backend service.
- `/(.*)` routes all other traffic to the frontend service.

### 4. Storage (PVC)
- A **Persistent Volume Claim (PVC)** requests block storage (AWS EBS in production) for the PostgreSQL database, ensuring data persists across pod restarts or node failures.

### 5. Horizontal Pod Autoscaler (HPA)
- HPA is configured for both the frontend and backend deployments.
- It dynamically scales the number of replicas up or down based on CPU and memory utilization metrics gathered by the Kubernetes Metrics Server.

### 6. Configuration and Secrets
- **ConfigMaps:** Used to store non-sensitive configuration data such as environment variables.
- **Secrets:** Used to securely store database credentials, Docker registry tokens, and TLS certificates. (Note: in a production GitOps environment, tools like External Secrets Operator or SOPS would be used to manage secrets).

## High Availability
By deploying across multiple availability zones within the AWS EKS cluster and utilizing multiple replicas, the platform is resilient against individual node or availability zone failures.
