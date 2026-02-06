🛡️ Sentinel Split: Multi-Env EKS Orchestration

An automated, cross-VPC Kubernetes architecture featuring VPC Peering, Internal NLB, and Remote-State CI/CD.

🚀 Quick Start
Variables are required to prevent accidental deployments. Use the provided rapyd.tfvars.

1. Infrastructure Setup
# Setup Profile
aws configure --profile rapyd
export AWS_PROFILE=rapyd  # Windows: $env:AWS_PROFILE = "rapyd"

# Provision
terraform init
terraform plan -var-file="rapyd.tfvars"
terraform apply -var-file="rapyd.tfvars"

2. Backend & Gateway Deployment
# Connect to Backend & Deploy
aws eks update-kubeconfig --region eu-west-2 --name eks-backend --alias backend --profile rapyd
kubectl apply -f k8s/backend-deployment.yaml -f k8s/backend-service.yaml -f k8s/network-policy.yaml

# Capture Internal NLB DNS and update k8s/gateway-proxy.yaml, then:
aws eks update-kubeconfig --region eu-west-2 --name eks-gateway --alias gateway --profile rapyd
kubectl apply -f k8s/gateway-proxy.yaml

🏗️ Architecture & Security
Networking: Two isolated VPCs connected via VPC Peering. Traffic flows from Gateway Proxy -> Peering -> Internal NLB -> Backend Pods (8080).

Compute: Dual EKS clusters in private subnets with NAT Gateways for secure egress.

Security: Least-privilege IAM, SGs restricted to cross-VPC CIDRs, and K8s NetworkPolicy for pod-level isolation.

⚖️ Design Trade-offs (3-Day Limit)
Connectivity: Used VPC Peering for simplicity/low-latency; Transit Gateway would be the choice for 3+ VPCs to reduce mesh complexity.

High Availability: Used a single NAT Gateway per VPC to optimize cost; production requires one per Availability Zone.

Identity: Used standard IAM credentials due to environment scope; OIDC Federation is preferred for production CI/CD.

Service Discovery: Manual DNS updates for the proxy; production would utilize ExternalDNS or a Service Mesh.

📝 Roadmap (ToDo)
[ ] Resilience: Add DynamoDB for Terraform state locking and concurrency.
[ ] Organization: Refactor .tf files into an environments/ directory structure.
[ ] Packaging: Transition K8s manifests to Helm or Kustomize.
[ ] Security: Implement OIDC for fine-grained IRSA.
[ ] Automation: Implement ArgoCD for GitOps and ExternalDNS for endpoint mapping.
[ ] Observability: Deploy Prometheus/Grafana for cross-cluster traffic monitoring.
