To prevent accidental deployments, variables are required. Please use the provided .tfvars files

to create:

1. aws configure --profile rapyd
2. terraform init
3. terraform validate
4. for default use:
- aws configure --profile personal (once)
- export AWS_PROFILE=personal (linux) or $env:AWS_PROFILE = "personal" (win)
- terraform plan -var-file="terraform.tfvars"
- terraform apply -var-file="terraform.tfvars"

for rapyd use:
- aws configure --profile rapyd (once)
- export AWS_PROFILE=rapyd (linux) or $env:AWS_PROFILE = "rapyd" (win)
- terraform plan -var-file="rapyd.tfvars"
- terraform apply -var-file="rapyd.tfvars"

common section:
#Update your kubeconfig: aws eks update-kubeconfig --name <cluster_name>
- Deploy Backend manifests: kubectl apply -f k8s/backend/
- Capture the Internal NLB DNS: kubectl get svc sentinel-backend-svc
- Update gateway-proxy.yaml with the DNS and deploy: kubectl apply -f k8s/gateway/

Currently include:
1. Two Isolated VPCs: vpc-gateway for public services and vpc-backend for internal
- Subnet Strategy: Each VPC contains two private subnets across 2 (AZs)
- Egress Control: NAT Gateways are provisioned in both VPCs to allow outbound traffic
- Peering: A VPC Peering connection between the Gateway and Backend networks.

2. Compute (EKS)
- Dual Clusters: 2 operational Kubernetes clusters: eks-gateway and eks-backend.
- IAM Compliance: EKS and Sentinel-related roles are created 

3. Security & Access
- Least Privilege: Access is restricted to private subnets



## 🛑 Teardown & Cost Management

To avoid unnecessary AWS charges, destroy the infrastructure when not in use:

```powershell
# Windows (PowerShell)
$env:AWS_PROFILE = "personal" 
terraform destroy -var-file="terraform.tfvars" 

# Linux/macOS
export AWS_PROFILE=personal
terraform destroy -var-file="terraform.tfvars" 


ToDo:
1. move state to s3
2. move tf files from root to environments new folder
3. add tflint
4. add Helm/kustomize
5. add OIDC