################################################################################
# Data sources
################################################################################

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Project Zomboid game server"
  vpc_id      = data.aws_vpc.default.id

  tags = { Name = "${var.name}-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "game" {
  security_group_id = aws_security_group.this.id
  description       = "PZ game port"
  from_port         = 16261
  to_port           = 16261
  ip_protocol       = "udp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "direct" {
  security_group_id = aws_security_group.this.id
  description       = "PZ direct connect"
  from_port         = 16262
  to_port           = 16262
  ip_protocol       = "udp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.this.id
  description       = "SSH"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

################################################################################
# EC2 Instance
################################################################################

resource "aws_instance" "this" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = data.aws_subnets.public.ids[0]
  vpc_security_group_ids = [aws_security_group.this.id]

  user_data = templatefile("${path.module}/templates/userdata.sh.tpl", {
    server_name    = var.server_name
    admin_password = var.admin_password
  })

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.volume_size
    delete_on_termination = true
  }

  tags = { Name = var.name }

  lifecycle {
    # Changing user_data would replace the instance — avoid accidental wipe of saves
    ignore_changes = [user_data]
  }
}

################################################################################
# Elastic IP
################################################################################

resource "aws_eip" "this" {
  domain = "vpc"
  tags   = { Name = "${var.name}-eip" }
}

resource "aws_eip_association" "this" {
  instance_id   = aws_instance.this.id
  allocation_id = aws_eip.this.id
}
