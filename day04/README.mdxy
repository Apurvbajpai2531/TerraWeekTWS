# TerraWeek Day 4 🌱 — Terraform State Management

This document covers Day 4 of the **#TerraWeek** challenge: understanding Terraform state, working with local state and the `terraform state` command, and migrating to remote state management using **AWS S3** (with DynamoDB for state locking).

---

## Task 1: Importance of Terraform State 📚

### What is Terraform State?
Terraform state is a JSON file (`terraform.tfstate`) that Terraform uses to keep track of the real-world resources it manages. It maps the resources defined in your `.tf` configuration files to the actual infrastructure objects created in the cloud provider.

### Why State Matters
- **Resource Tracking**: State stores metadata (resource IDs, attributes, dependencies) so Terraform knows what already exists, instead of scanning your entire cloud account on every run.
- **Performance**: Terraform uses the cached state instead of querying every resource's live status, making `plan` and `apply` much faster.
- **Dependency Mapping**: Terraform builds a dependency graph from state to determine the correct order of resource creation, update, or deletion.
- **Collaboration**: When shared (via remote backends), state allows teams to work on the same infrastructure without conflicts.
- **Drift Detection**: Terraform compares the state file with real infrastructure to detect if something was changed manually outside of Terraform (configuration drift).
- **Plan Accuracy**: Without state, Terraform wouldn't know the difference between "create new resource" and "update existing resource" — every apply would try to recreate everything from scratch.

### Key Takeaway
> State is the single source of truth for Terraform. Losing or corrupting it can cause Terraform to lose track of your infrastructure, potentially leading to duplicate resources or accidental deletion.

---

## Task 2: Local State and `terraform state` Command 📚

### Local State Storage
By default, Terraform stores state locally in a file named `terraform.tfstate` in the working directory, along with a backup `terraform.tfstate.backup`.

**Pros**: Simple, no extra setup, good for learning/testing.
**Cons**: No locking, not shareable across a team, risk of loss if the machine/file is deleted, sensitive data stored in plain text on disk.

### Sample Terraform Configuration

```hcl
# main.tf
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "demo_bucket" {
  bucket = "terraweek-day4-demo-bucket-12345"

  tags = {
    Name        = "TerraWeek Day4 Demo"
    Environment = "Learning"
  }
}
```

### Initialize and Apply

```bash
# Initialize the working directory (downloads providers, sets up backend)
terraform init

# Preview the changes
terraform plan

# Apply the configuration (creates local state file)
terraform apply -auto-approve
```

After running `apply`, you'll see a `terraform.tfstate` file generated in your directory.

### Working with the `terraform state` Command

The `terraform state` command lets you inspect and manipulate objects tracked in your state file.

```bash
# List all resources tracked in state
terraform state list

# Show detailed attributes of a specific resource
terraform state show aws_s3_bucket.demo_bucket

# Move/rename a resource in state (e.g., after renaming in code)
terraform state mv aws_s3_bucket.demo_bucket aws_s3_bucket.renamed_bucket

# Remove a resource from state (without destroying actual infra)
terraform state rm aws_s3_bucket.demo_bucket

# Pull the current state and display it (or save to a file)
terraform state pull > state_backup.json

# Push a modified local state file back (rarely needed, use with caution)
terraform state push state_backup.json
```

### Common Use Cases
| Command | Use Case |
|---|---|
| `state list` | Quickly audit what Terraform is managing |
| `state show` | Debug a resource's current attributes |
| `state mv` | Refactor code (rename resources/modules) without destroying infra |
| `state rm` | Stop tracking a resource without deleting it (e.g., handing off to another team) |
| `state pull` / `push` | Backup or manually edit state (advanced/emergency use) |

---

## Task 3: Remote State Management 📚

### Why Remote State?
Local state doesn't scale for teams:
- No locking → two people running `apply` simultaneously can corrupt state.
- Not shared → everyone has a different "truth" of the infrastructure.
- Not secure → sensitive values (passwords, keys) sit unencrypted on a laptop.

### Popular Remote Backend Options

| Backend | Description |
|---|---|
| **Terraform Cloud** | HashiCorp's managed service; built-in locking, versioning, UI, run history, and free for small teams. |
| **AWS S3 (+ DynamoDB)** | Store state in an S3 bucket with versioning; use a DynamoDB table for state locking. Very popular for AWS-centric workflows. |
| **Azure Storage Account** | Store state as a blob in Azure Blob Storage; supports native locking via blob leases. |
| **HashiCorp Consul** | Key-value store backend, useful in Consul-heavy environments; supports locking natively. |

### Chosen Backend: **AWS S3 + DynamoDB**

I chose **S3** because it's cost-effective, durable (11 nines of durability), supports versioning (so you can roll back to a previous state if something goes wrong), and integrates natively with AWS IAM for access control. DynamoDB is added alongside it purely for **state locking**, preventing concurrent `apply` operations from corrupting the state.

#### Setup Steps

**1. Create an S3 bucket for state storage**

```bash
aws s3api create-bucket \
  --bucket terraweek-tfstate-bucket-12345 \
  --region us-east-1
```

**2. Enable versioning on the bucket (critical for state recovery)**

```bash
aws s3api put-bucket-versioning \
  --bucket terraweek-tfstate-bucket-12345 \
  --versioning-configuration Status=Enabled
```

**3. Enable server-side encryption (optional but recommended)**

```bash
aws s3api put-bucket-encryption \
  --bucket terraweek-tfstate-bucket-12345 \
  --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
  }'
```

**4. Create a DynamoDB table for state locking**

```bash
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

**5. Block public access to the bucket (best practice)**

```bash
aws s3api put-public-access-block \
  --bucket terraweek-tfstate-bucket-12345 \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

---

## Task 4: Remote State Configuration 📚

### Backend Configuration Block

Add this block to your Terraform configuration to migrate from local to remote state:

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "terraweek-tfstate-bucket-12345"
    key            = "terraweek/day4/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### Migrating Existing Local State to Remote

```bash
# Re-initialize Terraform to pick up the new backend
terraform init

# Terraform will detect the backend change and prompt:
# "Do you want to copy existing state to the new backend?"
# Type "yes" to migrate your local terraform.tfstate into S3
```

After migration:
- Your local `terraform.tfstate` file becomes a thin pointer/cache; the real state now lives in S3.
- Every `terraform plan` / `apply` will pull the latest state from S3 and use DynamoDB to acquire a lock before making changes.
- Team members running the same configuration (with access to the bucket/table) will share the same state — no more "it works on my machine" infrastructure drift.

### Verifying Remote State

```bash
# Confirm state is stored remotely
terraform state list

# Check the object directly in S3
aws s3 ls s3://terraweek-tfstate-bucket-12345/terraweek/day4/

# Confirm DynamoDB lock table exists and is empty (no active locks)
aws dynamodb scan --table-name terraform-locks
```

---

## 🎯 Key Learnings from Day 4

1. Terraform state is the backbone of how Terraform tracks and manages infrastructure — without it, Terraform can't reliably plan or apply changes.
2. Local state works for solo/learning projects but is risky and doesn't scale for teams.
3. The `terraform state` command family (`list`, `show`, `mv`, `rm`, `pull`, `push`) is essential for inspecting and safely refactoring managed resources.
4. Remote backends (S3, Terraform Cloud, Azure Storage, Consul) solve collaboration, locking, and durability problems inherent to local state.
5. S3 + DynamoDB is a robust, low-cost combination: S3 for durable/versioned storage, DynamoDB for locking to prevent concurrent state corruption.
6. Migrating from local to remote state is as simple as adding a `backend` block and running `terraform init` again.

---

## 📺 Reference Videos
- [Terraform State Explained](https://youtu.be/kqJIKjkJ1Lo)
- [Remote State Management](https://youtu.be/VyB_vETjvT0)

## 🙌 Credits
Part of the **#TerraWeek** community challenge. Reach out to the TWS Community Builders/Leaders for guidance.

#TerraWeek #Terraform #IaC #DevOps #CloudComputing #AWS #LearningInPublic
