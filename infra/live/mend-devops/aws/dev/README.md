# AWS Dev Environment Infrastructure

This directory contains the Terraform configurations for deploying AWS infrastructure in the development environment across multiple regions. The infrastructure includes EKS clusters, networking components, IAM roles, and DNS management with multi-region support.

## Prerequisites

Before deploying the AWS infrastructure, ensure you have:

1. **AWS CLI configured** with the `mend-devops` profile (Account: 739929374881)
2. **Terraform installed** (version ~> 1.0)
3. **Python 3.8+** installed for remote state management scripts
4. **AWS profile "stav-devops"** configured for DNS zone delegation (Account: 882709358319)

## Remote State Management

The infrastructure uses remote state storage in S3 with DynamoDB locking. Before deploying any Terraform configurations, you must first set up the remote state backend.

### Setting up Remote State

1. **Install Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Run the state bucket creation script:**
   ```bash
   python state_bucket.py
   ```

This script will:
- Create an S3 bucket for Terraform state storage
- Create a DynamoDB table for state locking
- Configure proper encryption and access controls
- Apply appropriate tags to all resources

## Terraform Execution Order

The infrastructure must be deployed in the following specific order due to dependencies between components. The IAM and Route53 modules are global and only need to be deployed once, while the networking and EKS modules need to be deployed for each region.

### 1. IAM Module (Global - Deploy Once)
**Location:** `./iam/`
**Purpose:** Creates IAM policies and roles required by the EKS clusters and other AWS services.

```bash
cd iam/
terraform init
terraform plan
terraform apply
```

**Dependencies:** None
**Outputs:** IAM policy ARNs for load balancer controller and external DNS

### 2. Route53 Module (Global - Deploy Once)
**Location:** `./route53/`
**Purpose:** Sets up DNS zone delegation from the root domain (stavco9.com) to the dev environment.

```bash
cd route53/
terraform init
terraform plan
terraform apply
```

**Dependencies:** None
**Outputs:** DNS zone ID and name servers

### 3. Regional Infrastructure (Deploy for Each Region)

#### EU North 1 (eu-north-1)

**Networking Module:**
```bash
cd eu-north-1/networking/
terraform init
terraform plan
terraform apply
```

**EKS Module:**
```bash
cd eu-north-1/eks/
terraform init
terraform plan
terraform apply
```

#### US East 1 (us-east-1)

**Networking Module:**
```bash
cd us-east-1/networking/
terraform init
terraform plan
terraform apply
```

**EKS Module:**
```bash
cd us-east-1/eks/
terraform init
terraform plan
terraform apply
```

**Dependencies for each region:**
- IAM module (for service account policies)
- Route53 module (for DNS configuration)
- Regional networking module (for VPC and subnets)

**Outputs:** Cluster endpoint, certificate authority data, and OIDC provider information

## Module Documentation

Each Terraform module includes detailed documentation:

### Global Modules
- [IAM Module](./iam/README.md) - IAM policies and roles
- [Route53 Module](./route53/README.md) - DNS zone management

### Regional Modules

#### EU North 1 (eu-north-1)
- [Networking Module](./eu-north-1/networking/README.md) - VPC and networking components
- [EKS Module](./eu-north-1/eks/README.md) - Kubernetes cluster and add-ons

#### US East 1 (us-east-1)
- [Networking Module](./us-east-1/networking/README.md) - VPC and networking components
- [EKS Module](./us-east-1/eks/README.md) - Kubernetes cluster and add-ons

## Post-Deployment

After successful deployment for each region:

### EU North 1 (eu-north-1)

1. **Configure kubectl:**
   ```bash
   aws eks update-kubeconfig --region eu-north-1 --name k8s-mend-devops-dev --profile mend-devops
   ```

2. **Verify cluster access:**
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

3. **Check installed add-ons:**
   - AWS Load Balancer Controller
   - External DNS
   - Metrics Server
   - Cert-Manager (if enabled)

### US East 1 (us-east-1)

1. **Configure kubectl:**
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name k8s-mend-devops-dev --profile mend-devops
   ```

2. **Verify cluster access:**
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

3. **Check installed add-ons:**
   - AWS Load Balancer Controller
   - External DNS
   - Metrics Server
   - Cert-Manager (if enabled)

## Environment Variables

The following environment variables may be required for certain operations:

```bash
export AWS_PROFILE=mend-devops
export AWS_DEFAULT_REGION=eu-north-1
```

## Troubleshooting

### Common Issues

1. **State lock errors:** Ensure the DynamoDB table exists and you have proper permissions
2. **DNS delegation issues:** Verify the stav-devops profile is configured and has access to the root domain
3. **EKS cluster creation failures:** Check that all dependencies (IAM, networking) are properly deployed

### Useful Commands

```bash
# Check AWS profile configuration
aws sts get-caller-identity --profile mend-devops

# List S3 buckets
aws s3 ls --profile mend-devops

# Check DynamoDB tables
aws dynamodb list-tables --profile mend-devops --region eu-north-1

# Verify EKS cluster status
aws eks describe-cluster --name mend-devops-dev-eks --profile mend-devops --region eu-north-1
```

## Security Notes

- All resources are tagged with project, environment, and owner information
- S3 buckets have public access blocked and encryption enabled
- DynamoDB tables use pay-per-request billing
- EKS cluster uses private subnets with NAT gateway for outbound internet access
- IAM roles follow least-privilege principles
