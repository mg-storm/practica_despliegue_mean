variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "ami_id" {
  description = "The AMI ID to use for the instances"
  type        = string
  default     = "ami-0f8e81a3da6e2510a" # Ubuntu 22.04 LTS in us-west-2
}

variable "instance_type" {
  description = "The instance type to use for the instances"
  type        = string
  default     = "t2.micro"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# modules/ec2_instance/variables.tf
variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "instance_map" {
  type    = map(string)
  default = {}
}