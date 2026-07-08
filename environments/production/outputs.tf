output "ec2_public_ip" {
  description = "The public IP address of the EC2 deployment host"
  value       = module.compute.public_ip
}

output "rds_endpoint" {
  description = "The database endpoint (host:port)"
  value       = module.database.endpoint
}

output "rds_address" {
  description = "The database host address"
  value       = module.database.address
}
