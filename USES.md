# AWS Deployment Platform Usage Guide

This document explains the conceptual model of this repository layout and how to run Terraform commands (`init`, `plan`, `apply`, `destroy`).

---

## Conceptual Layout

1. **`modules/` (Reusable Building Blocks)**
   - These define individual infrastructure components (e.g. `storage` for S3 buckets, `networking` for VPCs).
   - **Important**: Do not run `terraform` commands directly inside `modules/`. They have no environment-specific configuration or state files.

2. **`environments/` (Target Deployments)**
   - Each folder represents a real deployment target (e.g., `development`, `staging`, `production`).
   - Each environment folder contains configurations (like `main.tf`, `variables.tf`, and `terraform.tfvars`) that reference and consume the modules.
   - **Important**: This is where you run your Terraform commands.

3. **`bootstrap/` (Initial Setup)**
   - Setup resources needed _before_ running environments (e.g., S3 Buckets for Terraform remote state backend, DynamoDB tables for state locking).
   - Once configured, you run Terraform commands here to establish the backend.

---

## How to Run Terraform Commands

To manage infrastructure for a specific environment (e.g. `development`):

### 1. Navigate to the Environment

Open your terminal and go to the directory of the target environment:

```bash
cd environments/development
```

### 2. Initialize Terraform

Initializes the working directory containing Terraform configuration files. This downloads the necessary provider plugins (e.g. AWS provider) and prepares the backend:

```bash
terraform init
```

### 3. Generate a Execution Plan

Creates an execution plan, letting you preview the actions Terraform will take to reach the desired state without making any actual changes:

```bash
terraform plan
```

### 4. Apply the Changes

Executes the actions proposed in the plan to create or update the infrastructure:

```bash
terraform apply
```

### 5. Destroy the Infrastructure (Optional)

If you need to tear down the infrastructure created for this environment:

```bash
terraform destroy
```
