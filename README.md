# MyTerraform
🌐 Hello World Azure Infrastructure — Terraform + GitHub Actions

This project is a complete end-to-end DevOps workflow that deploys Azure infrastructure automatically using Terraform, GitHub Actions, and OIDC authentication.

It demonstrates real-world cloud engineering practices including Infrastructure-as-Code, CI/CD automation, state management, and secure authentication.

🚀 Project Overview

This project builds and manages Azure resources using Terraform, including:

Resource Group

Virtual Network & Subnet

Network Security Group

NSG ↔ Subnet Association

Public IP

Linux Virtual Machine (SSH key authentication)

All infrastructure is fully reproducible and managed through Terraform.

⚙️ CI/CD Pipeline (GitHub Actions)

A GitHub Actions workflow automatically deploys infrastructure when changes are pushed to the main branch.

🔐 Azure Authentication with OIDC

The pipeline uses OpenID Connect (OIDC) to sign into Azure without storing secrets, following Microsoft best practices.

📦 Pipeline Tasks

The workflow performs:

Checkout the repository

Authenticate to Azure using OIDC

Install Terraform (version pinned for consistency)

Initialize Terraform

Generate SSH keys inside the pipeline

Run terraform apply automatically

This ensures infrastructure stays in sync with your code at all times.

🧠 Terraform Concepts Used
📌 State Management

Terraform maintains a state file tracking all Azure resources.
This lets Terraform know:

What exists in Azure

What needs to be changed

How to detect drift

📌 Imports vs Refresh

Import brings existing Azure resources into Terraform state

Refresh updates the state when real resources change

📌 Desired State

Terraform compares:

Your HCL configuration

Your state file

…and creates a plan to match Azure to your code.

🔄 Local + CI/CD Workflow

This project follows a clean workflow to avoid state drift or import issues:

Write Terraform locally

Test with terraform plan

Apply locally OR push to GitHub

GitHub Actions automatically updates Azure

Azure resources stay fully managed through Terraform

No manual Azure Portal changes are needed.