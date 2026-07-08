# 1. Networking Module (VPC, Subnets, SG rules)
module "networking" {
  source       = "../../modules/networking"
  project_name = var.project_name
  environment  = var.environment
}

# 2. Compute Module (EC2 Host with Docker & Caddy user-data scripts)
module "compute" {
  source              = "../../modules/compute"
  project_name        = var.project_name
  environment         = var.environment
  instance_type       = var.instance_type
  subnet_id           = module.networking.public_subnet_id
  security_group_id   = module.networking.ec2_security_group_id
  ssh_public_key_path = var.ssh_public_key_path
}

# 3. Database Module (RDS Instance)
module "database" {
  source               = "../../modules/database"
  project_name         = var.project_name
  environment          = var.environment
  db_engine            = var.db_engine
  db_engine_version    = var.db_engine_version
  db_instance_class    = var.db_instance_class
  db_name              = var.db_name
  db_user              = var.db_user
  db_password          = var.db_password
  db_subnet_group_name = module.networking.db_subnet_group_name
  db_security_group_id = module.networking.db_security_group_id
}

# 4. Storage Module (S3 Bucket)
module "storage" {
  source       = "../../modules/storage"
  project_name = var.project_name
  environment  = var.environment
  bucket_name  = var.bucket_name
}
