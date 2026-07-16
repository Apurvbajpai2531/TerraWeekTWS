# Terraform Modules - TerraWeek Day 5 🚀

This project demonstrates how to create and use **Terraform Modules** to build reusable and scalable infrastructure components.

## 📌 Overview

Terraform modules allow us to organize infrastructure code into reusable components. Instead of writing the same Terraform configuration repeatedly, we can create modules once and reuse them across different environments.

In this project, we created a reusable **AWS EC2 Module**.

---

# Project Structure

```
terraform-module/
│
├── main.tf
├── variables.tf
├── outputs.tf
│
└── ec2/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

---

# What are Terraform Modules?

A Terraform module is a collection of Terraform configuration files grouped together to create reusable infrastructure.

A module can contain:

* Resources
* Variables
* Outputs
* Providers
* Dependencies

Modules help in creating clean, maintainable, and scalable Infrastructure as Code.

---

# Benefits of Terraform Modules

## 1. Reusability

Write infrastructure code once and reuse it multiple times.

Example:

* Development EC2
* Testing EC2
* Production EC2

can use the same EC2 module.

---

## 2. Maintainability

Changes can be made in one place instead of updating multiple Terraform files.

---

## 3. Scalability

Modules make it easier to manage large infrastructure environments.

---

## 4. Consistency

Same infrastructure standards can be followed across multiple projects.

---

# AWS EC2 Module Implementation

## Module Resource

`ec2/main.tf`

```hcl
resource "aws_instance" "ec2" {

  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }

}
```

---

# Module Variables

`ec2/variables.tf`

```hcl
variable "ami_id" {}

variable "instance_type" {}

variable "instance_name" {}
```

---

# Module Outputs

`ec2/outputs.tf`

```hcl
output "instance_id" {
  value = aws_instance.ec2.id
}


output "public_ip" {
  value = aws_instance.ec2.public_ip
}
```

---

# Calling the Module

Root `main.tf`

```hcl
provider "aws" {
  region = "ap-south-1"
}


module "web_server" {

  source = "./ec2"

  ami_id        = "your-ami-id"
  instance_type = "t2.micro"
  instance_name = "TerraWeek-EC2"

}
```

---

# Terraform Commands Used

## Initialize Terraform

```bash
terraform init
```

Downloads providers and initializes modules.

---

## Validate Configuration

```bash
terraform validate
```

Checks Terraform syntax and configuration.

---

## Create Execution Plan

```bash
terraform plan
```

Shows the changes Terraform will perform.

---

## Deploy Infrastructure

```bash
terraform apply
```

Creates AWS resources.

---

## Destroy Infrastructure

```bash
terraform destroy
```

Deletes resources created by Terraform.

---

# Modular Composition

Modular composition means combining multiple Terraform modules to create complete infrastructure.

Example:

```
Infrastructure

      |
      |
      ├── VPC Module
      |
      ├── Security Group Module
      |
      ├── EC2 Module
      |
      ├── IAM Module
      |
      └── Database Module
```

Each module performs a specific responsibility.

---

# Terraform Module Versioning

Module versioning helps maintain stable and predictable infrastructure.

Ways to lock module versions:

## Git Tag

```hcl
module "ec2" {

 source = "git::https://github.com/company/aws-ec2.git?ref=v1.0.0"

}
```

---

## Git Commit Hash

```hcl
module "ec2" {

 source = "git::https://github.com/company/aws-ec2.git?ref=8b6e92c"

}
```

---

## Terraform Registry Version

```hcl
module "vpc" {

 source  = "terraform-aws-modules/vpc/aws"
 version = "5.5.0"

}
```

---

## Version Constraints

### Exact Version

```hcl
version = "= 5.5.0"
```

### Greater Than

```hcl
version = ">= 5.5.0"
```

### Compatible Version

```hcl
version = "~> 5.5"
```

---

# Key Learnings 🎯

* Terraform modules help create reusable infrastructure.
* Modules reduce duplicate code.
* Modules improve scalability and maintainability.
* Modular composition helps build complex infrastructure using smaller components.
* Version locking prevents unexpected infrastructure changes.
* EC2 infrastructure was successfully created using a custom Terraform module.

---

# Technologies Used

* Terraform
* AWS EC2
* Infrastructure as Code (IaC)
* Terraform Modules
* AWS CLI

---

## TerraWeek Day 5 Completed ✅

#TerraWeek #Terraform #DevOps #AWS #InfrastructureAsCode #CloudComputing
