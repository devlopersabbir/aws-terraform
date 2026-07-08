# AWS target region
variable "aws_region" {
  type        = string
  description = "The target AWS region for deployment"
}

# Project identifier
variable "project_name" {
  type        = string
  description = "Name of the project"
}

# Environment
variable "environment" {
  type        = string
  description = "Environment identifier (e.g. production)"
  default     = "production"
}

# EC2 Configs
variable "instance_type" {
  type        = string
  description = "EC2 Instance type"
  default     = "t3.micro"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key for EC2 key pair registration"
}

# RDS database configs
variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_engine_version" {
  type    = string
  default = "16.3"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "postgres"
}

variable "db_user" {
  type    = string
  default = "db_admin_user"
}

variable "db_password" {
  type      = string
  sensitive = true
}

# S3 configs
variable "bucket_name" {
  type        = string
  description = "Unique name for the S3 assets bucket"
}
