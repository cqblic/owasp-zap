# OWASP ZAP MCP Server

This project provides a Model Context Protocol (MCP) server for OWASP ZAP. It allows AI models and agents to interact with OWASP ZAP to run security scans and retrieve vulnerability alerts via an SSE (Server-Sent Events) interface.

The project includes an infrastructure-as-code setup using Terraform/OpenTofu to deploy the service serverlessly on Azure Container Apps (ACA) for a scalable, low-cost security assessment pipeline.

## Features

- **MCP Tools Exposed**:
  - `spider_scan`: Run a ZAP spider scan against a target URL.
  - `active_scan`: Run a ZAP active scan against a target URL.
  - `get_alerts`: Retrieve vulnerability alerts for a given base URL.
- **Serverless Deployment**: Ready to deploy on Azure Container Apps using Terraform.
- **Scale-to-Zero**: Designed to scale to zero when not in use to minimize cloud costs.
- **All-in-One Container**: The Dockerfile packages both OWASP ZAP and the Node.js MCP server together.

## Quick Start: Deploy in Azure

The deployment uses Terraform (or OpenTofu) to provision an Azure Resource Group, Container Registry (ACR), Log Analytics Workspace, and Container App (ACA).

### Prerequisites

1. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and authenticated (`az login`).
2. [Terraform](https://developer.hashicorp.com/terraform/install) or [OpenTofu](https://opentofu.org/) installed.
3. Docker installed locally (if building the image manually).

### Deployment Steps

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Review variables (Optional):**
   Check `variables.tf` or create a `terraform.tfvars` file to override default settings (like `location`, `prefix`, `dns_zone`, etc.).

3. **Plan and Apply:**
   ```bash
   terraform plan
   terraform apply
   ```
   *(Note: This provisions the infrastructure including the Azure Container Registry (ACR) and the Container App. You will need to build and push the Docker image to your ACR so the Container App can pull it and start successfully.)*

## Continuous Deployment (GitHub Actions)

This repository already includes a GitHub Actions workflow (`.github/workflows/deploy.yml`) that automates the entire deployment process. 

The workflow will automatically run when you push to the `main` branch, or you can trigger it manually. It handles:
1. Provisioning the Azure Container Registry (ACR) via OpenTofu/Terraform.
2. Building and pushing the `zap-mcp` Docker image to the new registry.
3. Deploying the rest of the infrastructure (including the Container App).

**Required GitHub Secrets**:
To use the workflow, you must configure the following secrets in your GitHub repository (`Settings > Secrets and variables > Actions`):
- `AZURE_CREDENTIALS`: Azure service principal credentials JSON (for `azure/login`).
- `AZURE_CLIENT_ID`: Your Azure Service Principal App ID.
- `AZURE_CLIENT_SECRET`: Your Azure Service Principal Password/Secret.
- `AZURE_TENANT_ID`: Your Azure Tenant ID.
- `AZURE_SUBSCRIPTION_ID`: Your Azure Subscription ID.

## How to Start (Local Development)

You can run the ZAP MCP server locally using Docker, which is the easiest way since it requires both the OWASP ZAP Java application and Node.js.

### Using Docker

1. **Build the image:**
   ```bash
   docker build -t zap-mcp-server .
   ```

2. **Run the container:**
   ```bash
   docker run -p 3000:3000 zap-mcp-server
   ```
   The startup script (`start.sh` in the container) will automatically launch ZAP in headless mode, wait for it to be ready, and then start the Node.js MCP server.

### Connecting to the MCP Server

Once the server is running (locally or in Azure), an MCP client can connect to it using the SSE transport:
- **SSE Endpoint:** `http://<your-host>:3000/sse`
- **Messages Endpoint:** `http://<your-host>:3000/messages`

If deployed to Azure Container Apps, use the FQDN provided by the ACA deployment or your custom DNS record.
