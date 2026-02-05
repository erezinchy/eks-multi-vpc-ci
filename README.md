To prevent accidental deployments, variables are required. Please use the provided .tfvars files

to create:

1. aws configure --profile rapyd
2. terraform init
3. terraform validate
for default use: 
- terraform plan -var-file="terraform.tfvars"
- terraform apply -var-file="terraform.tfvars"

for rapyd use:
- terraform plan -var-file="rapyd.tfvars"
- terraform apply -var-file="rapyd.tfvars"

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


ToDo:
1. move state to s3
2. move tf files from root to environments new folder
3. add tflint