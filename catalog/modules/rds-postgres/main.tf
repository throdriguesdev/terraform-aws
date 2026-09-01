################################################################################
# Security Group
################################################################################

resource "aws_security_group" "this" {
  name        = "${var.identifier}-rds-sg"
  description = "PostgreSQL access for ${var.identifier}"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.identifier}-rds-sg" }
}

################################################################################
# Subnet Group + Parameter Group
################################################################################

resource "aws_db_subnet_group" "this" {
  name        = var.identifier
  subnet_ids  = var.subnet_ids
  description = "Subnet group for ${var.identifier}"
}

resource "aws_db_parameter_group" "this" {
  name   = var.identifier
  family = "postgres${split(".", var.engine_version)[0]}"

  parameter {
    name  = "log_connections"
    value = var.enable_log_connections ? "1" : "0"
  }

  parameter {
    name  = "log_disconnections"
    value = var.enable_log_disconnections ? "1" : "0"
  }
}

################################################################################
# RDS PostgreSQL Instance
################################################################################

resource "aws_db_instance" "this" {
  identifier     = var.identifier
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name  = var.database_name
  username = var.master_username

  # RDS manages the password in Secrets Manager — no plaintext in state
  manage_master_user_password   = true
  master_user_secret_kms_key_id = var.kms_key_arn

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  parameter_group_name   = aws_db_parameter_group.this.name

  multi_az               = var.multi_az
  publicly_accessible    = var.publicly_accessible
  deletion_protection    = var.deletion_protection
  skip_final_snapshot    = var.skip_final_snapshot
  backup_retention_period = var.backup_retention_period

  performance_insights_enabled = var.performance_insights_enabled
}
