# NovaStore — AWS Deployment Guide

This guide describes how to prepare, provision, deploy, validate, and clean up the NovaStore retail e-commerce environment.

NovaStore supports two alternative AWS container deployment architectures: **ECS/Fargate** and **EKS/Kubernetes**. Both use the Java Spring Boot application and AWS infrastructure defined in this repository.

> **Deployment verification:** Local application builds, Terraform validation, and Helm linting have been verified. A fresh end-to-end AWS deployment from this public repository has not yet been validated. Review environment-specific configuration before provisioning resources.

## 1. Prerequisites

- An AWS account with appropriate permissions
- AWS CLI configured with credentials for the target account
- Terraform
- Docker
- Java 17 and Maven
- Git
- Helm and kubectl for Kubernetes deployments
- Access to Amazon ECR
- An AWS region and environment-specific configuration

Confirm the AWS identity before provisioning:

    aws sts get-caller-identity

Select the intended AWS region:

    export AWS_REGION=us-east-2
    aws configure get region

## 2. Review the Repository

Key implementation locations:

- `app/` — Java Spring Boot application
- `frontend/` — React storefront
- `terraform/` — AWS infrastructure definitions
- `Jenkinsfile` — Jenkins pipeline
- `.github/workflows/` — GitHub Actions workflows
- `helm/java-app/` — Helm chart
- `argocd/` — Argo CD configuration
- `ansible/` — Server configuration automation

Review Terraform variables, IAM permissions, image references, networking settings, and environment-specific identifiers before deployment.

## 3. Build and Validate the Application

Build and test the Java application:

    cd app
    mvn clean package
    cd ..

Build the Docker image:

    docker build -t novastore-api:local ./app

These commands validate the application build and image packaging. They do not deploy the application to AWS.

## 4. Prepare AWS Infrastructure with Terraform

Initialize the development configuration without activating its remote backend:

    terraform -chdir=terraform/environments/dev init -backend=false

Validate the Terraform configuration:

    terraform -chdir=terraform/environments/dev validate

Before an actual deployment:

1. Review the development environment's backend configuration.
2. Supply the required Terraform variable values.
3. Replace example account identifiers and other placeholders.
4. Confirm IAM permissions and AWS resource quotas.
5. Review networking, NAT Gateway, load balancer, and Kubernetes costs.
6. Initialize the intended backend and review a Terraform plan.

Do not apply Terraform until the plan has been reviewed and the required configuration has been supplied.

## 5. Build and Publish the Container Image

The delivery workflows define the intended process:

1. Retrieve application source from GitHub.
2. Build and test the application.
3. Run configured security and quality checks.
4. Build the Docker image.
5. Authenticate to Amazon ECR.
6. Tag and publish the image.
7. Deploy the selected application version.

Implementation references:

- `Jenkinsfile`
- `.github/workflows/`
- `app/Dockerfile`

The ECR repository, account, region, image tag, and deployment credentials must match the target environment.

## 6. Deployment Option A — Amazon ECS/Fargate

**Traffic flow:** Internet → ALB → ECS Service → Fargate Task → Spring Boot application

Deployment sequence:

1. Provision the required VPC, subnets, IAM, ALB, ECR, and ECS resources.
2. Publish the application image to Amazon ECR.
3. Configure the ECS task definition to reference the published image.
4. Configure the ECS service, networking, target group, and health checks.
5. Deploy or update the ECS service.
6. Verify that tasks reach the RUNNING state and ALB targets become healthy.

Relevant infrastructure is defined under `terraform/`.

ECS/Fargate is an alternative to the Kubernetes deployment path; both paths do not need to be provisioned for a single application deployment.

## 7. Deployment Option B — Amazon EKS/Kubernetes

**Traffic flow:** Internet → ALB → Ingress → Kubernetes Service → Pod → Spring Boot application

Deployment sequence:

1. Provision the required AWS networking, IAM, ECR, and EKS resources.
2. Configure kubectl access to the intended EKS cluster.
3. Publish the application image to Amazon ECR.
4. Update the Helm image repository, tag, and environment-specific values.
5. Confirm Kubernetes Secrets and required dependencies are configured.
6. Deploy the Helm release using the intended environment values.
7. Verify Pods, Services, Ingress, and application health.
8. If using Argo CD, configure repository access and confirm synchronization.

Validate the Helm chart locally:

    helm lint helm/java-app
    helm template novastore helm/java-app

Review the Helm chart and Argo CD manifests before executing deployment commands against a live cluster.

## 8. Verify the Deployment

For the selected deployment platform, confirm:

- Application containers start successfully
- Application health checks pass
- Load balancer targets are healthy
- The application responds through the expected endpoint
- Database connectivity works
- Application logs show no startup errors
- Monitoring and alerting are configured appropriately

Record the deployed image version and the results of smoke tests.

## 9. Troubleshooting

Review the engineering investigations in:

`docs/troubleshooting/README.md`

Topics include IAM permissions, container images, application health, Kubernetes networking, ALB routing, and Argo CD synchronization.

## 10. Infrastructure Cleanup

When the environment is no longer needed:

1. Confirm the correct AWS account, region, and environment.
2. Identify any resources or data that must be retained.
3. Review the Terraform destroy plan.
4. Remove the intended resources using the corresponding Terraform state.
5. Confirm that billable resources have been removed.

**Warning:** Destruction can permanently remove infrastructure and data. Never run cleanup commands against an unverified environment.

## Deployment Status

The repository provides implementation code and validation instructions for both deployment architectures. Fresh end-to-end provisioning and deployment from this repository require additional environment-specific verification.
