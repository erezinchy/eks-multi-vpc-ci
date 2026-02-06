To prevent accidental deployments, variables are required. Please use the provided .tfvars files

to create:

1. aws configure --profile rapyd
2. terraform init
3. terraform validate
4. apply:
- aws configure --profile rapyd (once)
- export AWS_PROFILE=rapyd (linux) or $env:AWS_PROFILE = "rapyd" (win)
- terraform plan -var-file="rapyd.tfvars"
- terraform apply -var-file="rapyd.tfvars"

5. deploy backend

- aws eks update-kubeconfig --region eu-west-2 --name eks-backend --alias backend --profile rapyd
- kubectl config use-context backend
- Deploy Backend manifests: kubectl apply -f k8s/backend-service.yaml
- Capture the Internal NLB DNS: kubectl get svc sentinel-backend-svc
- kubectl apply -f k8s/network-policy.yaml


6. deploy gateway:
- aws eks update-kubeconfig --region eu-west-2 --name eks-gateway --alias gateway --profile rapyd
- kubectl config use-context gateway
- kubectl get svc --all-namespaces --context backend # to find dns name
- Update gateway-proxy.yaml with the DNS and deploy: 
-- kubectl apply -f k8s/gateway/

7. verification:
-- kubectl get svc sentinel-gateway-public --context gateway
-- curl http://DNS_Name.eu-west-2.elb.amazonaws.com #  should get 200



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
4. add Helm/kustomize
5. add OIDC
6. automate dns section when deployinh gateway