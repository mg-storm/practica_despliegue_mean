# modules/ec2_instance/main.tf
resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  user_data = var.user_data

  tags = merge(var.common_tags, { Role = var.role })
}