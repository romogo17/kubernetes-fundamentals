# Kubernetes Fundamentals (LFS258)
Automation and notes developed while taking the Kubernetes Fundamentals (LFS258) course

## Requirements

- The Infrastructure as Code (IaC) in this repository was created for Google Cloud, so you need a **Google Cloud Account**. Feel free to submit a PR with the automation for other Cloud Providers
  - Aside from the account, you need a **Service Account** with enough permissions to deploy the necessary infrastructure
  - You need the **Access Keys** for that Service Account as well. Make sure to download them and define `GOOGLE_APPLICATION_CREDENTIALS={{path}}` in your shell environment
- **Terraform** is used to deploy the infrastructure. As of writing this document, I'm using `v0.14.3`
- **Ansible** is heavily used to configure the instances and overall orchestrate the deployment & configuration of everything required for the different labs. As of writing this document, I'm using `v2.10.4`
- The **Kubernetes CLI** (`kubectl`) is also required. While a lot might be orchestrated using Ansible, there might be scripts that manually use the CLI. As of writing this document, I'm using `v1.20.1`