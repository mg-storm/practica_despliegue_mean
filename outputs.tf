output "web_server_public_ips" {
  description = "Public IPs of the web server instances"
  value       = module.web_server.*.public_ip
}

output "web_server_private_ips" {
  description = "Private IPs of the web server instances"
  value       = module.web_server.*.private_ip
}

output "mongodb_instance_private_ip" {
  description = "Private IP of the MongoDB instance"
  value       = module.mongodb.private_ip
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.load_balancer.dns_name
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT gateway"
  value       = aws_nat_gateway.this.public_ip
}