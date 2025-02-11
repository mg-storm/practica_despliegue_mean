variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "name" {
  description = "The name of the security group"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}