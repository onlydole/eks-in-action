variable "project_name" {
  type        = string
  description = "Globally used project name for this demo."
  default     = "eks-in-action"
}

variable "region" {
  type        = string
  description = "AWS US-based Region that will be used in this demo."
  default     = "us-west-2"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones that will be used in this demo."
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "cluster_version" {
  type        = string
  description = "The Kubernetes version for our clusters"
  default     = "1.19"
}

variable "cidr" {
  type        = string
  description = "The CIDR block to use for this demo"
  default     = "10.0.0.0/16"
}
