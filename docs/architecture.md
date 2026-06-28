# Architecture

The following diagram illustrates the architecture of the Cloud Native DevOps Platform, covering the software delivery lifecycle from source code commit to production deployment, as well as runtime cluster architecture.

```mermaid
flowchart TD
    %% Define Styles
    classDef gitHub fill:#181717,stroke:#fff,stroke-width:2px,color:#fff
    classDef gitHubActions fill:#2088FF,stroke:#fff,stroke-width:2px,color:#fff
    classDef dockerHub fill:#2496ED,stroke:#fff,stroke-width:2px,color:#fff
    classDef awsEks fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#232F3E
    classDef k8s fill:#326CE5,stroke:#fff,stroke-width:2px,color:#fff
    classDef database fill:#4169E1,stroke:#fff,stroke-width:2px,color:#fff
    classDef monitor fill:#E6522C,stroke:#fff,stroke-width:2px,color:#fff

    %% Source Control and CI/CD
    GitHub("GitHub Repository"):::gitHub
    CI_CD("GitHub Actions (CI/CD)"):::gitHubActions
    DockerRegistry("Docker Hub (Container Registry)"):::dockerHub
    
    %% AWS Infrastructure
    subgraph AWS_Cloud ["Amazon Web Services (AWS)"]
        EKS_Cluster["Amazon EKS Cluster"]:::awsEks
        
        subgraph K8s_Cluster ["Kubernetes (EKS)"]
            IngressController("NGINX Ingress Controller"):::k8s
            
            subgraph App_Layer ["Application Layer"]
                Frontend("React Frontend"):::k8s
                Backend("Node.js Backend"):::k8s
            end
            
            subgraph Data_Layer ["Data Layer"]
                DB[("PostgreSQL")]:::database
            end
            
            subgraph Observability ["Observability Stack"]
                Prometheus("Prometheus"):::monitor
                Grafana("Grafana"):::monitor
                Alertmanager("Alertmanager"):::monitor
            end
        end
    end

    %% Flow of data / Deployment
    GitHub -->|Push to main| CI_CD
    CI_CD -->|Build & Push Image| DockerRegistry
    CI_CD -->|Deploy Manifests| EKS_Cluster
    DockerRegistry -->|Pull Image| Frontend
    DockerRegistry -->|Pull Image| Backend

    %% Traffic Flow
    User((User)) -->|HTTPS Requests| IngressController
    IngressController -->|Route /| Frontend
    IngressController -->|Route /api| Backend
    Backend -->|Read/Write Data| DB

    %% Monitoring Flow
    Prometheus -.->|Scrape Metrics| Frontend
    Prometheus -.->|Scrape Metrics| Backend
    Prometheus -.->|Scrape Metrics| DB
    Prometheus -.->|Trigger Alerts| Alertmanager
    Grafana -.->|Query Data| Prometheus
```

## Description
1. **GitHub** acts as the single source of truth for application code and infrastructure configuration.
2. **GitHub Actions** automates the building of Docker images, testing, and deployment to the Kubernetes cluster.
3. **Docker Hub** serves as the container registry storing production-ready artifacts.
4. **Amazon EKS** provides a highly scalable managed Kubernetes control plane.
5. **NGINX Ingress** handles external user traffic, performing TLS termination and routing to the appropriate microservice.
6. **Frontend & Backend** microservices are dynamically scaled via HPA (Horizontal Pod Autoscaling).
7. **PostgreSQL** maintains state using Persistent Volume Claims mapped to AWS EBS.
8. **Prometheus, Grafana, & Alertmanager** constantly monitor cluster health and alert operators in the event of anomalies.
