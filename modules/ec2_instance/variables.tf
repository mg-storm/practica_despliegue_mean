variable "ami_id" {
  description = "The AMI ID to use for the instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type to use for the instance"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID to launch the instance into."
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the instance."
  type        = list(string)
}

variable "user_data" {
  description = "User data script for the instance"
  type        = string
}

variable "role" {
  description = "The role of the instance (e.g., web-server, mongodb)"
  type        = string
}

variable "common_tags" {
  type        = map(string)
  default     = {}
}