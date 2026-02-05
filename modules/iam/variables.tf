# modules/iam/variables.tf

variable "cluster_name" {
  description = "The name of the EKS cluster (used to name the roles)"
  type        = string
}

# You can keep principal if you want it to be configurable, 
# but we'll hardcode it in the module for simplicity if you prefer.
variable "principal" {
  description = "The service principal (e.g., eks.amazonaws.com)"
  type        = string
  default     = "eks.amazonaws.com"
}