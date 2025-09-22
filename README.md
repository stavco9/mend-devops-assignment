# Mend DevOps Assignment

This repository contains a comprehensive multi-cloud Kubernetes infrastructure project that demonstrates the deployment of managed Kubernetes clusters on both AWS (EKS) and Azure (AKS) platforms, along with a sample Flask application deployment.

## 🏗️ Project Overview

This project showcases a complete DevOps workflow including:

- **Infrastructure as Code (IaC)** using Terraform for both AWS and Azure
- **Multi-cloud Kubernetes clusters** (EKS and AKS) with production-ready configurations
- **Helm charts** for application deployment and management
- **Comprehensive documentation** for setup, deployment, and operations

## 📁 Repository Structure

```
mend-devops-assignment/
├── infra/                           # Infrastructure as Code
│   ├── modules/                     # Reusable Terraform modules
│   │   ├── aws/                    # AWS-specific modules (EKS, Networking)
│   │   └── azure/                  # Azure-specific modules (AKS, Networking)
│   └── live/                       # Environment-specific configurations
│       └── mend-devops/
│           ├── aws/dev/            # AWS infrastructure for dev environment
│           └── azure/dev/          # Azure infrastructure for dev environment
├── helm-charts/                    # Helm charts for application deployment
│   └── flask-hello-world/         # Sample Flask application chart
└── README.md                       # This file
```

## 🚀 Quick Start

### 1. Infrastructure Setup

First, deploy the infrastructure for both cloud providers:

- **[AWS Infrastructure Setup](./infra/README.md#aws-infrastructure)** - Complete EKS cluster with networking, IAM, and DNS
- **[Azure Infrastructure Setup](./infra/README.md#azure-infrastructure)** - Complete AKS cluster with networking, DNS, and Application Gateway

### 2. Application Deployment

Once the infrastructure is ready, deploy the sample Flask application:

- **[Flask Hello World Deployment](./helm-charts/flask-hello-world/README.md)** - Deploy the sample application to both clusters

## 🌐 Live Application URLs

After successful deployment, the Flask Hello World application will be available at:

- **AWS EKS:** https://flask-hello-world.k8s.eu-north-1.dev.aws.mend-devops.stavco9.com
- **Azure AKS:** https://flask-hello-world.k8s.west-europe.dev.azure.mend-devops.stavco9.com

## 🛠️ Technology Stack

### Infrastructure
- **Terraform** - Infrastructure as Code
- **AWS EKS** - Managed Kubernetes on AWS
- **Azure AKS** - Managed Kubernetes on Azure
- **Python** - Remote state management scripts

### Application Platform
- **Kubernetes** - Container orchestration
- **Helm** - Package management for Kubernetes
- **Flask** - Python web framework
- **Docker** - Containerization

### Networking & Security
- **AWS ALB** - Application Load Balancer for EKS
- **Azure Application Gateway** - Layer 7 load balancer for AKS
- **Let's Encrypt** - SSL certificate management
- **External DNS** - Automatic DNS record management
- **Workload Identity/IRSA** - Secure pod-to-cloud authentication

## 📋 Prerequisites

Before starting, ensure you have the following tools installed:

- **Terraform** (~> 1.0)
- **AWS CLI V2** (with proper profiles configured)
- **Azure CLI** (with proper subscription access)
- **Kubelogin** (for AKS authentication)
- **Python** (3.8+ for remote state scripts)
- **Helm** (3.x for application deployment)
- **kubectl** (for cluster management)

## 🔧 Cloud Account Configuration

### AWS Accounts
- **Account 739929374881** (`mend-devops` profile) - Main infrastructure account
- **Account 882709358319** (`stav-devops` profile) - DNS root domain management

### Azure Subscription
- **Subscription:** `2bcfe589-26cd-455a-bdd4-b8975088c52f`
- **Tenant:** `5f9ccf0b-2066-472e-993a-438adb2f77e0`

## 📚 Documentation

### Infrastructure Documentation
- **[Main Infrastructure Guide](./infra/README.md)** - Complete infrastructure setup and management
- **[AWS Dev Environment](./infra/live/mend-devops/aws/dev/README.md)** - AWS-specific deployment guide
- **[Azure Dev Environment](./infra/live/mend-devops/azure/dev/README.md)** - Azure-specific deployment guide

### Application Documentation
- **[Flask Hello World Helm Chart](./helm-charts/flask-hello-world/README.md)** - Application deployment and management guide

## 🔄 Deployment Workflow

### Infrastructure Deployment Order

**AWS:**
1. Remote state setup (`state_bucket.py`)
2. IAM module
3. Route53 module
4. Networking module
5. EKS module

**Azure:**
1. Remote state setup (`state_blob.py`)
2. DNS module
3. Networking module
4. AKS module

### Application Deployment
1. Connect to target cluster (AWS or Azure)
2. Deploy Helm chart with appropriate values file
3. Verify application accessibility via ingress URLs

## 🔒 Security Features

- **Encrypted remote state** storage (S3 + DynamoDB for AWS, Azure Storage for Azure)
- **Private subnets** for worker nodes with NAT gateway access
- **Workload Identity/IRSA** for secure pod-to-cloud authentication
- **SSL/TLS termination** at ingress level
- **Network security groups** with least-privilege access
- **Public access blocked** on all storage resources

## 🎯 Key Features

### Multi-Cloud Support
- Identical application deployment on both AWS and Azure
- Cloud-native ingress controllers (ALB for AWS, Application Gateway for Azure)
- Automatic DNS management with External DNS
- SSL certificate automation with Let's Encrypt

### Production-Ready Configuration
- High availability across multiple availability zones
- Horizontal Pod Autoscaling (HPA) support
- Resource limits and requests
- Health checks and monitoring
- Comprehensive logging and metrics

### DevOps Best Practices
- Infrastructure as Code with Terraform
- GitOps-ready with Helm charts
- Comprehensive documentation
- Modular and reusable components
- Environment-specific configurations

## 🤝 Contributing

This project demonstrates modern DevOps practices and can serve as a reference for:

- Multi-cloud Kubernetes deployments
- Infrastructure as Code patterns
- Helm chart development
- CI/CD pipeline integration
- Security best practices

## 📞 Support

For questions or issues related to this project, please refer to the detailed documentation in each component or create an issue in the repository.

---

**Note:** This project is designed for educational and demonstration purposes, showcasing modern DevOps practices and multi-cloud Kubernetes deployment strategies.
