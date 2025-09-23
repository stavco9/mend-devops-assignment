# Azure Dev Environment Infrastructure

This directory contains the Terraform configurations for deploying Azure infrastructure in the development environment across multiple regions. The infrastructure includes AKS clusters, networking components, DNS management, and Application Gateway with multi-region support.

## Prerequisites

Before deploying the Azure infrastructure, ensure you have:

1. **Azure CLI configured** and logged in to the correct subscription
2. **Terraform installed** (version ~> 1.0)
3. **Python 3.8+** installed for remote state management scripts
4. **Kubelogin** installed for AKS authentication

## Remote State Management

The infrastructure uses remote state storage in Azure Blob Storage. Before deploying any Terraform configurations, you must first set up the remote state backend.

### Setting up Remote State

1. **Install Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Run the state blob creation script:**
   ```bash
   python state_blob.py
   ```

This script will:
- Create a Resource Group for Terraform state
- Create an Azure Storage Account with proper security settings
- Create a blob container for Terraform state storage
- Configure encryption and access controls
- Apply appropriate tags to all resources

## Terraform Execution Order

The infrastructure must be deployed in the following specific order due to dependencies between components. The DNS module is global and only needs to be deployed once, while the networking and AKS modules need to be deployed for each region.

### 1. DNS Module (Global - Deploy Once)
**Location:** `./dns/`
**Purpose:** Sets up Azure DNS zone for the dev environment domain management.

```bash
cd dns/
terraform init
terraform plan
terraform apply
```

**Dependencies:** None
**Outputs:** DNS zone ID and name servers

### 2. Regional Infrastructure (Deploy for Each Region)

#### West Europe (west-europe)

**Networking Module:**
```bash
cd west-europe/networking/
terraform init
terraform plan
terraform apply
```

**AKS Module:**
```bash
cd west-europe/aks/
terraform init
terraform plan
terraform apply
```

#### East US (east-us)

**Networking Module:**
```bash
cd east-us/networking/
terraform init
terraform plan
terraform apply
```

**AKS Module:**
```bash
cd east-us/aks/
terraform init
terraform plan
terraform apply
```

**Dependencies for each region:**
- DNS module (for DNS configuration)
- Regional networking module (for Virtual Network and subnets)

**Outputs:** Cluster endpoint, certificate authority data, and Application Gateway information

## Module Documentation

Each Terraform module includes detailed documentation:

### Global Modules
- [DNS Module](./dns/README.md) - Azure DNS zone management

### Regional Modules

#### West Europe (west-europe)
- [Networking Module](./west-europe/networking/README.md) - Virtual Network and networking components
- [AKS Module](./west-europe/aks/README.md) - Kubernetes cluster and add-ons

#### East US (east-us)
- [Networking Module](./east-us/networking/README.md) - Virtual Network and networking components
- [AKS Module](./east-us/aks/README.md) - Kubernetes cluster and add-ons

## Post-Deployment

After successful deployment for each region:

### West Europe (west-europe)

1. **Configure kubectl:**
   ```bash
   az aks get-credentials --resource-group mend-devops-dev-west-europe-rg --name k8s-mend-devops-dev-aks
   kubelogin convert-kubeconfig -l azurecli
   ```

2. **Verify cluster access:**
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

3. **Check installed add-ons:**
   - Application Gateway Ingress Controller
   - Cert-Manager
   - External DNS
   - Workload Identity

### East US (east-us)

1. **Configure kubectl:**
   ```bash
   az aks get-credentials --resource-group mend-devops-dev-east-us-rg --name k8s-mend-devops-dev-aks
   kubelogin convert-kubeconfig -l azurecli
   ```

2. **Verify cluster access:**
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

3. **Check installed add-ons:**
   - Application Gateway Ingress Controller
   - Cert-Manager
   - External DNS
   - Workload Identity

## Environment Variables

The following environment variables may be required for certain operations:

```bash
export AZURE_SUBSCRIPTION_ID=2bcfe589-26cd-455a-bdd4-b8975088c52f
export AZURE_TENANT_ID=5f9ccf0b-2066-472e-993a-438adb2f77e0
```

## Troubleshooting

### Common Issues

1. **State lock errors:** Ensure the Azure Storage Account exists and you have proper permissions
2. **DNS zone creation issues:** Verify you have DNS zone contributor permissions
3. **AKS cluster creation failures:** Check that all dependencies (DNS, networking) are properly deployed
4. **Authentication issues:** Ensure kubelogin is installed and configured

### Useful Commands

```bash
# Check Azure CLI configuration
az account show

# List resource groups
az group list --output table

# List storage accounts
az storage account list --output table

# Check AKS cluster status
az aks show --resource-group mend-devops-dev-west-europe-rg --name mend-devops-dev-aks

# Get AKS credentials
az aks get-credentials --resource-group mend-devops-dev-west-europe-rg --name mend-devops-dev-aks
```

## Security Notes

- All resources are tagged with project, environment, and owner information
- Storage accounts have public access blocked and encryption enabled
- AKS cluster uses private subnets with proper network security groups
- Workload Identity is configured for secure pod-to-Azure service authentication
- Application Gateway provides SSL termination and load balancing
- Cert-Manager automatically manages SSL certificates

## Azure-Specific Features

### Workload Identity
The AKS cluster is configured with Workload Identity, allowing pods to authenticate to Azure services without storing credentials in the cluster.

### Application Gateway
An Application Gateway is deployed as the ingress controller, providing:
- SSL termination
- Load balancing
- Web Application Firewall (WAF) capabilities
- URL-based routing

### Cert-Manager Integration
Cert-Manager is configured to automatically provision SSL certificates from Let's Encrypt for secure HTTPS communication.
