#!/bin/bash
# ==============================================================================
# AWS Deployment Automation Pipeline
# ==============================================================================
set -e

# Define root workspace path relative to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

ENV_FILE="$PROJECT_ROOT/.env.production"

# Check if .env.production exists
if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: Configuration file '.env.production' not found at project root."
    echo "Please copy 'examples/env.production.example' to '.env.production' and fill in your variables."
    exit 1
fi

echo "========================================="
echo "1. Loading Configuration & Env Bindings..."
echo "========================================="

# Source variables from .env.production
# Temporarily turn off pipefail to handle comment lines safely
set +e
export $(grep -v '^#' "$ENV_FILE" | grep -v '^[[:space:]]*$' | xargs)
set -e

# Export AWS credentials & default region for Terraform provider
export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="$AWS_REGION"

# Bind variables to Terraform (TF_VAR_ prefixed variables are read automatically)
export TF_VAR_aws_region="$AWS_REGION"
export TF_VAR_project_name="$PROJECT_NAME"
export TF_VAR_environment="$ENVIRONMENT"
export TF_VAR_instance_type="$INSTANCE_TYPE"
export TF_VAR_ssh_public_key_path="$SSH_PUBLIC_KEY_PATH"
export TF_VAR_db_engine="$DB_ENGINE"
export TF_VAR_db_engine_version="$DB_ENGINE_VERSION"
export TF_VAR_db_instance_class="$DB_INSTANCE_CLASS"
export TF_VAR_db_name="$DB_NAME"
export TF_VAR_db_user="$DB_USER"
export TF_VAR_db_password="$DB_PASSWORD"
export TF_VAR_bucket_name="$BUCKET_NAME"

echo "Configuration loaded for project: $PROJECT_NAME ($ENVIRONMENT)"
echo "AWS Region: $AWS_REGION"

echo "========================================="
echo "2. Provisioning Infrastructure (Terraform)..."
echo "========================================="
cd "$PROJECT_ROOT/environments/production"

terraform init -input=false
terraform apply -auto-approve -input=false

# Capture outputs from Terraform
echo "Extracting infrastructure details..."
EC2_IP=$(terraform output -raw ec2_public_ip)
RDS_ADDRESS=$(terraform output -raw rds_address)

echo "EC2 Host Public IP: $EC2_IP"
echo "RDS Database Address: $RDS_ADDRESS"

echo "========================================="
echo "3. Waiting for EC2 Host Initialization..."
echo "========================================="
# Wait for SSH to be responsive and Docker service setup via user_data to finish
echo "Pinging EC2 instance until Docker and SSH are ready..."
SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=5 -i $SSH_PRIVATE_KEY_PATH"

RETRIES=0
MAX_RETRIES=40
until ssh $SSH_OPTS ubuntu@$EC2_IP "docker --version && docker-compose --version" >/dev/null 2>&1; do
    RETRIES=$((RETRIES+1))
    if [ $RETRIES -gt $MAX_RETRIES ]; then
        echo "ERROR: Timed out waiting for EC2 instance Docker initialization."
        exit 1
    fi
    echo "Waiting for Docker daemon to initialize... (Try $RETRIES/$MAX_RETRIES)"
    sleep 10
done
echo "EC2 Host is fully ready with Docker!"

echo "========================================="
echo "4. Deploying Application Stack (Docker)..."
echo "========================================="
# Create deployment directory on host
ssh $SSH_OPTS ubuntu@$EC2_IP "mkdir -p /home/ubuntu/app/docker"

# Create a runtime environment file specifically for containers
# We build the database connection URL from RDS outputs
RUNTIME_DB_URL="postgresql://${DB_USER}:${DB_PASSWORD}@${RDS_ADDRESS}:5432/${DB_NAME}"

cat <<EOF > "$PROJECT_ROOT/docker/.env.runtime"
APP_DOMAIN=$APP_DOMAIN
API_DOMAIN=$API_DOMAIN
DATABASE_URL=$RUNTIME_DB_URL
JWT_SECRET=$JWT_SECRET
PORT=$PORT
EOF

# Copy Docker compose, Caddyfile, and the runtime .env to host
scp $SSH_OPTS "$PROJECT_ROOT/docker/docker-compose.yaml" ubuntu@$EC2_IP:/home/ubuntu/app/
scp $SSH_OPTS "$PROJECT_ROOT/docker/Caddyfile" ubuntu@$EC2_IP:/home/ubuntu/app/
scp $SSH_OPTS "$PROJECT_ROOT/docker/.env.runtime" ubuntu@$EC2_IP:/home/ubuntu/app/.env

# Start docker services on remote host
echo "Starting containers on remote EC2..."
ssh $SSH_OPTS ubuntu@$EC2_IP "cd /home/ubuntu/app && docker compose pull && docker compose up -d --build"

# Clean up local runtime env file
rm -f "$PROJECT_ROOT/docker/.env.runtime"

echo "========================================="
echo "DEPLOMENT COMPLETED SUCCESSFULY!"
echo "========================================="
echo "Frontend Domain: https://$APP_DOMAIN"
echo "API Backend Domain: https://$API_DOMAIN"
echo "EC2 Public IP: http://$EC2_IP"
echo "========================================="
