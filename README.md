# Comercial Kurbenetes

A sample containerized Python web application with Kubernetes manifests and Terraform infrastructure code for AWS.

## Repository structure

- `App/` — Python FastAPI application, Dockerfile, docker-compose, frontend assets, and application-specific README.
- `manifests/` — Kubernetes deployment and service manifests.
- `Terraform/` — Terraform configuration for AWS resources, EKS cluster, IAM, VPC, and related infrastructure.
- `PRIVATE.txt` — Private notes or secrets placeholder. Do not commit sensitive data.

## App overview

The application in `App/` includes:

- `server.py` — FastAPI backend
- `database.py` — database connection and models
- `requirements.txt` — Python dependencies
- `docker-compose.yml` — local multi-service development
- `Dockerfile` — container image definition
- `public/` — web frontend static assets

For application-level usage details, see `App/README.md`.

## Getting started

### Run locally

1. Change into the app directory:
   ```bash
   cd App
   ```

2. Create and activate a Python virtual environment:
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Start the server:
   ```bash
   python server.py
   ```

5. Open the app in a browser at `http://localhost:8000`.

### Run with Docker

Build the image from the `App/` directory:

```bash
cd App
docker build -t comercial-kurbenetes-app .
```

Run the container:

```bash
docker run -p 8000:8000 comercial-kurbenetes-app
```

### Kubernetes deployment

The `manifests/` directory contains Kubernetes manifests for deploying the application.

Apply them with `kubectl`:

```bash
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/service.yaml
```

### Terraform infrastructure

`Terraform/` contains infrastructure-as-code for AWS resources and EKS cluster setup. Review the Terraform configuration files and the `Terraform/BootStrap/` folder for bootstrap resources.

Common commands:

```bash
cd Terraform
terraform init
terraform plan
terraform apply
```

> Do not store AWS credentials, secret keys, or private data in this repository.

## License

This repository is licensed under the MIT License. See `LICENSE` for details.
