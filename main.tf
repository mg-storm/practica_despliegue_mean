data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "public_subnet_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private.id
}

module "web_server_sg" {
  source = "./modules/security_group"
  vpc_id = aws_vpc.this.id
  name   = "web-server-sg"
  ingress_rules = [
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 5000, to_port = 5000, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
  ]
}

module "mongodb_sg" {
  source = "./modules/security_group"
  vpc_id = aws_vpc.this.id
  name   = "mongodb-sg"
  ingress_rules = [
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 27017, to_port = 27017, protocol = "tcp", source_security_group_id = module.web_server_sg.security_group_id , cidr_blocks = ["0.0.0.0/0"]},
  ]
}

module "load_balancer_sg" {
  source = "./modules/security_group"
  vpc_id = aws_vpc.this.id
  name   = "load-balancer-sg"
  ingress_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
  ]
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags       = merge(local.common_tags, { Name = "mean-vpc" })
}

module "web_server" {
  source             = "./modules/ec2_instance"
  ami_id             = data.aws_ami.ubuntu.id
  instance_type      = var.instance_type
  subnet_id          = aws_subnet.public_subnet.id
  security_group_ids = [module.web_server_sg.security_group_id]
  user_data          = templatefile("web_server_user_data.sh.tpl", { mongo_private_ip = module.mongodb.private_ip })
  role               = "web-server"
  count              = 2
  common_tags        = local.common_tags
  depends_on         = [module.mongodb]
}

module "mongodb" {
  source             = "./modules/ec2_instance"
  ami_id             = data.aws_ami.ubuntu.id
  instance_type      = var.instance_type
  subnet_id          = aws_subnet.private_subnet.id
  security_group_ids = [module.mongodb_sg.security_group_id]
  user_data          = file("mongodb_user_data.sh")
  role               = "mongodb"
  common_tags        = local.common_tags
}

module "load_balancer" {
  source             = "./modules/load_balancer"
  load_balancer_name = "mean-load-balancer"
  security_group_ids = [module.load_balancer_sg.security_group_id]
  subnet_ids         = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
  target_group_name  = "mean-target-group"
  vpc_id             = aws_vpc.this.id
  instance_ids       = module.web_server.*.instance_id

}



