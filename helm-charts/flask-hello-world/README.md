# Flask Hello World Helm Chart

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

A production-ready Flask sample application designed for deployment on both AWS EKS and Azure AKS clusters. This Helm chart includes comprehensive ingress configurations, autoscaling capabilities, and monitoring support.

## Prerequisites

Before deploying this Helm chart, ensure you have:

1. **Helm 3.x** installed
2. **kubectl** configured and connected to your target cluster
3. **Proper cluster access** (see cluster connection instructions below)

## Cluster Connection Instructions

### AWS EKS Cluster Connection

#### EU North 1 (eu-north-1)

1. **Configure AWS CLI with the correct profile:**
   ```bash
   # Ensure you have the mend-devops profile configured with access keys
   aws configure list --profile mend-devops
   ```

2. **Update kubeconfig for the EKS cluster:**
   ```bash
   aws eks update-kubeconfig --region eu-north-1 --name k8s-mend-devops-dev --profile mend-devops
   ```

3. **Verify the correct context is active:**
   ```bash
   kubectl config current-context
   # Should show: arn:aws:eks:eu-north-1:739929374881:cluster/k8s-mend-devops-dev
   ```

4. **Test cluster connectivity:**
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

#### US East 1 (us-east-1)

1. **Configure AWS CLI with the correct profile:**
   ```bash
   # Ensure you have the mend-devops profile configured with access keys
   aws configure list --profile mend-devops
   ```

2. **Update kubeconfig for the EKS cluster:**
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name k8s-mend-devops-dev --profile mend-devops
   ```

3. **Verify the correct context is active:**
   ```bash
   kubectl config current-context
   # Should show: arn:aws:eks:us-east-1:739929374881:cluster/k8s-mend-devops-dev
   ```

4. **Test cluster connectivity:**
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

### Azure AKS Cluster Connection

#### West Europe (west-europe)

1. **Login to Azure CLI with device code:**
   ```bash
   az login --tenant 5f9ccf0b-2066-472e-993a-438adb2f77e0 --use-device-code
   ```

2. **Set the active subscription:**
   ```bash
   az account set --subscription 2bcfe589-26cd-455a-bdd4-b8975088c52f
   ```

3. **Get AKS cluster credentials:**
   ```bash
   az aks get-credentials --resource-group mend-devops-dev-west-europe-rg --name k8s-mend-devops-dev-aks
   ```

4. **Convert kubeconfig for kubelogin:**
   ```bash
   kubelogin convert-kubeconfig -l azurecli
   ```

5. **Verify the correct context is active:**
   ```bash
   kubectl config current-context
   # Should show: k8s-mend-devops-dev-aks
   ```

6. **Test cluster connectivity:**
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

#### East US (east-us)

1. **Login to Azure CLI with device code:**
   ```bash
   az login --tenant 5f9ccf0b-2066-472e-993a-438adb2f77e0 --use-device-code
   ```

2. **Set the active subscription:**
   ```bash
   az account set --subscription 2bcfe589-26cd-455a-bdd4-b8975088c52f
   ```

3. **Get AKS cluster credentials:**
   ```bash
   az aks get-credentials --resource-group mend-devops-dev-east-us-rg --name k8s-mend-devops-dev-aks
   ```

4. **Convert kubeconfig for kubelogin:**
   ```bash
   kubelogin convert-kubeconfig -l azurecli
   ```

5. **Verify the correct context is active:**
   ```bash
   kubectl config current-context
   # Should show: k8s-mend-devops-dev-aks
   ```

6. **Test cluster connectivity:**
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

## Deployment

### AWS Deployment

#### EU North 1 (eu-north-1)

1. **Navigate to the chart directory:**
   ```bash
   cd helm-charts/flask-hello-world
   ```

2. **Deploy using the AWS values file:**
   ```bash
   helm upgrade flask-hello-world . --namespace flask-hello-world --create-namespace \
       --values values-mend-devops-dev-eu-north-1-aws.yaml
   ```

   Or use the provided PowerShell script:
   ```powershell
   .\install-aws-us-north-1.ps1
   ```

#### US East 1 (us-east-1)

1. **Navigate to the chart directory:**
   ```bash
   cd helm-charts/flask-hello-world
   ```

2. **Deploy using the AWS values file:**
   ```bash
   helm upgrade flask-hello-world . --namespace flask-hello-world --create-namespace \
       --values values-mend-devops-dev-us-east-1-aws.yaml
   ```

   Or use the provided PowerShell script:
   ```powershell
   .\install-aws-us-east-1.ps1
   ```

### Azure Deployment

#### West Europe (west-europe)

1. **Navigate to the chart directory:**
   ```bash
   cd helm-charts/flask-hello-world
   ```

2. **Deploy using the Azure values file:**
   ```bash
   helm upgrade flask-hello-world . --namespace flask-hello-world --create-namespace \
       --values values-mend-devops-dev-west-europe-azure.yaml
   ```

   Or use the provided PowerShell script:
   ```powershell
   .\install-azure-west-europe.ps1
   ```

#### East US (east-us)

1. **Navigate to the chart directory:**
   ```bash
   cd helm-charts/flask-hello-world
   ```

2. **Deploy using the Azure values file:**
   ```bash
   helm upgrade flask-hello-world . --namespace flask-hello-world --create-namespace \
       --values values-mend-devops-dev-east-us-azure.yaml
   ```

   Or use the provided PowerShell script:
   ```powershell
   .\install-azure-east-us.ps1
   ```

## Ingress Options

This Helm chart supports multiple ingress controllers and configurations:

### AWS EKS - Application Load Balancer (ALB)

**Configuration:** `ingressClassName: alb`

**Features:**
- Internet-facing ALB with SSL termination
- Automatic HTTP to HTTPS redirect
- Integration with AWS Certificate Manager (ACM)
- External DNS integration for automatic DNS record creation
- Target type: IP (direct pod targeting)

**Annotations Applied:**
- `alb.ingress.kubernetes.io/scheme: internet-facing`
- `alb.ingress.kubernetes.io/target-type: ip`
- `alb.ingress.kubernetes.io/backend-protocol: HTTP`
- `alb.ingress.kubernetes.io/listen-ports: [{"HTTP":80}, {"HTTPS":443}]`
- `alb.ingress.kubernetes.io/ssl-redirect: '443'`
- `external-dns.alpha.kubernetes.io/hostname: <hostname>`

**URL:** `https://flask-hello-world.k8s.eu-north-1.dev.aws.mend-devops.stavco9.com`

### Azure AKS - Application Gateway

**Configuration:** `ingressClassName: appgw`

**Features:**
- Azure Application Gateway with SSL termination
- Automatic HTTP to HTTPS redirect
- Integration with Let's Encrypt for SSL certificates
- External DNS integration for automatic DNS record creation
- Layer 7 load balancing

**Annotations Applied:**
- `kubernetes.io/ingress.class: azure/application-gateway`
- `appgw.ingress.kubernetes.io/ssl-redirect: "true"`
- `cert-manager.io/cluster-issuer: letsencrypt-prod`
- `kubernetes.io/tls-acme: 'true'`
- `external-dns.alpha.kubernetes.io/hostname: <hostname>`

**URL:** `https://flask-hello-world.k8s.west-europe.dev.azure.mend-devops.stavco9.com`

### NGINX Ingress Controller (Alternative)

**Configuration:** `ingressClassName: nginx`

**Features:**
- Standard NGINX ingress controller
- SSL termination with Let's Encrypt
- Force SSL redirect
- External DNS integration

**Annotations Applied:**
- `nginx.ingress.kubernetes.io/force-ssl-redirect: 'true'`
- `cert-manager.io/cluster-issuer: letsencrypt-prod`
- `kubernetes.io/tls-acme: 'true'`
- `external-dns.alpha.kubernetes.io/hostname: <hostname>`

## Application URLs

After successful deployment, the application will be available at:

### AWS EKS Clusters
- **EU North 1:** https://flask-hello-world.k8s.eu-north-1.dev.aws.mend-devops.stavco9.com
- **US East 1:** https://flask-hello-world.k8s.us-east-1.dev.aws.mend-devops.stavco9.com

### Azure AKS Clusters
- **West Europe:** https://flask-hello-world.k8s.west-europe.dev.azure.mend-devops.stavco9.com
- **East US:** https://flask-hello-world.k8s.east-us.dev.azure.mend-devops.stavco9.com

## Verification

1. **Check deployment status:**
   ```bash
   kubectl get pods -n flask-hello-world
   kubectl get ingress -n flask-hello-world
   kubectl get svc -n flask-hello-world
   ```

2. **Test the application:**
   ```bash
   # Test locally (port-forward)
   kubectl port-forward -n flask-hello-world svc/flask-hello-world 8080:5000
   curl http://localhost:8080
   
   # Test via ingress (replace with your actual URL)
   curl https://flask-hello-world.k8s.eu-north-1.dev.aws.mend-devops.stavco9.com
   ```

## Uninstallation

To remove the application:

```bash
helm uninstall flask-hello-world -n flask-hello-world
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaling.cpu.enabled | bool | `false` |  |
| autoscaling.cpu.percentage | int | `90` |  |
| autoscaling.customMetrics | list | `[]` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxPods | int | `10` |  |
| autoscaling.memory.enabled | bool | `false` |  |
| autoscaling.memory.percentage | int | `70` |  |
| autoscaling.minPods | int | `1` |  |
| imagePath | string | `"digitalocean/flask-helloworld"` |  |
| ingress.enabled | bool | `true` |  |
| ingress.host | string | `"flask-hello-world.example.com"` |  |
| ingress.ingressClassName | string | `"alb"` |  |
| ingress.protocol | string | `"https"` |  |
| microservice.environment | string | `"dev"` |  |
| microservice.healthCheckPath | string | `"/"` |  |
| microservice.logLevel | string | `"INFO"` |  |
| microservice.name | string | `"flask-hello-world"` |  |
| microservice.port | int | `5000` |  |
| microservice.protocol | string | `"http"` |  |
| microservice.replicas | int | `2` |  |
| microservice.tag | string | `"latest"` |  |
| prometheusMetrics.enabled | bool | `false` |  |
| provider | string | `"aws"` |  |
| resources.cpu | string | `"100m"` |  |
| resources.memory | string | `"128Mi"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
