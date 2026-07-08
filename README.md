# AWS Deployment Platform

A modular, reusable, and production-grade Infrastructure as Code platform on AWS using Terraform.

## Directory Structure

- `bootstrap/` - Initial resources (e.g. S3 remote state, locking tables).
- `modules/` - Reusable components (e.g. networking, compute, database).
- `environments/` - Deployments (e.g. development, staging, production).
- `docker/` - Dockerized assets and configurations.
- `scripts/` - Utility scripts.
- `github/` - GitHub configurations/actions.
- `examples/` - Example configurations.
- `docs/` - Documentation.

For details on how to run and use the platform, see [USES.md](file:///Users/sabbir/own/aws-terraform/USES.md).
