# ==============================================================================
# Database Module (RDS Instance)
# ==============================================================================

variable "project_name" { type = string }
variable "environment" { type = string }
variable "db_engine" { type = string }
variable "db_engine_version" { type = string }
variable "db_instance_class" { type = string }
variable "db_name" { type = string }
variable "db_user" { type = string }
variable "db_password" { type = string }
variable "db_subnet_group_name" { type = string }
variable "db_security_group_id" { type = string }

resource "aws_db_instance" "this" {
  identifier             = "${var.project_name}-rds"
  allocated_storage      = 20
  max_allocated_storage  = 100
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_security_group_id]
  skip_final_snapshot    = true

  tags = {
    Name        = "${var.project_name}-rds"
    Environment = var.environment
  }
}

output "endpoint" {
  description = "Connection endpoint for the RDS instance"
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "Hostname of the RDS instance"
  value       = aws_db_instance.this.address
}
