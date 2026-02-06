variable "aws_region" {
  type = string
}



variable "gateway_vpc_cidr" {
  type    = string
  default = "10.1.0.0/16" # CIDRs are usually safe to default
}


variable "backend_vpc_cidr" {
  type    = string
  default = "10.2.0.0/16"
}


variable "gateway_cluster_name" {
  type = string
}


variable "backend_cluster_name" {
  type = string
}

