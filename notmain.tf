terraform {
	required_version = ">= 1.0.0"
	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = ">= 4.0"
		}
	}
}

provider "aws" {
	region = var.aws_region
}

# Lookup latest Amazon Linux 2 AMI via SSM
data "aws_ssm_parameter" "amzn2_ami" {
	name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Lookup latest Windows Server 2022 English Full Base AMI via SSM
data "aws_ssm_parameter" "windows_2022_ami" {
	name = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base"
}

data "aws_ami" "amzn2" {
	most_recent = true
	owners      = ["amazon"]
	filter {
		name   = "image-id"
		values = [data.aws_ssm_parameter.amzn2_ami.value]
	}
}

data "aws_ami" "windows2022" {
	most_recent = true
	owners      = ["amazon"]
	filter {
		name   = "image-id"
		values = [data.aws_ssm_parameter.windows_2022_ami.value]
	}
}

# Simple VPC + subnet for example deployments
resource "aws_vpc" "this" {
	cidr_block           = "10.81.0.0/16"
	enable_dns_hostnames = true
	tags = {
		Name = "tn-example-vpc"
	}
}

resource "aws_subnet" "public" {
	vpc_id                  = aws_vpc.this.id
	cidr_block              = "10.81.1.0/24"
	map_public_ip_on_launch = true
	availability_zone       = "${var.aws_region}a"
	tags = {
		Name = "tn-example-subnet"
	}
}

resource "aws_internet_gateway" "igw" {
	vpc_id = aws_vpc.this.id
	tags = { Name = "tn-example-igw" }
}

resource "aws_route_table" "public" {
	vpc_id = aws_vpc.this.id
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.igw.id
	}
	tags = { Name = "tn-example-rt" }
}

resource "aws_route_table_association" "public" {
	subnet_id      = aws_subnet.public.id
	route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ssh_rdp" {
	name        = "tn-allow-ssh-rdp"
	description = "Allow SSH (Linux) and RDP (Windows) from allowed CIDR"
	vpc_id      = aws_vpc.this.id

	ingress {
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		cidr_blocks = [var.allowed_cidr]
		description = "SSH"
	}

	ingress {
		from_port   = 3389
		to_port     = 3389
		protocol    = "tcp"
		cidr_blocks = [var.allowed_cidr]
		description = "RDP"
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	tags = { Name = "tn-allow-ssh-rdp" }
}

resource "tls_private_key" "key" {
	algorithm = "RSA"
	rsa_bits  = 4096
}

resource "aws_key_pair" "default" {
	key_name   = "tn-key"
	public_key = tls_private_key.key.public_key_openssh
}

# EC2 instance with var.image_os controlling OS selection
resource "aws_instance" "server" {
	ami           = var.image_os == "windows" ? data.aws_ami.windows2022.id : data.aws_ami.amzn2.id
	instance_type = var.instance_type
	subnet_id     = aws_subnet.public.id
	key_name      = aws_key_pair.default.key_name
	vpc_security_group_ids = [aws_security_group.ssh_rdp.id]
	associate_public_ip_address = true

	tags = {
		Name = "tn-ec2-server"
		OS   = var.image_os
	}
}

output "instance_id" {
	description = "EC2 instance id"
	value       = aws_instance.server.id
}

output "public_ip" {
	description = "Public IP of the instance"
	value       = aws_instance.server.public_ip
}

output "private_key_pem" {
	description = "Private key material (PEM) — store securely"
	value       = tls_private_key.key.private_key_pem
	sensitive   = true
}

