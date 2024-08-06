variable "region" {
  description = "Region to deploy the resources"
  type        = string
  default     = "eu-central-1"
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "instance_type" {
  description = "Instance type of EKS worker node"
  type        = string
  default     = "t3.medium"
}

variable "ami_type" {
  description = "AMI Type for the EKS worker node"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}
