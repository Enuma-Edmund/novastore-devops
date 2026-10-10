# NovaStore — Retail E-Commerce DevOps Modernization

## Architecture

![NovaStore AWS DevOps Architecture](docs/architecture/novastore-architecture.png)

**Full-Stack Application | AWS Cloud | Infrastructure as Code | CI/CD | DevSecOps | GitOps**

## Project Overview

NovaStore is a full-stack retail e-commerce application used to demonstrate the modernization of application delivery and cloud infrastructure using DevOps engineering practices.

The project combines a React storefront, Java Spring Boot REST API, PostgreSQL database, automated testing, containerization, infrastructure provisioning, security scanning, and cloud deployment workflows.

## Business Problem

Traditional application environments often struggle with:

- Manual, error-prone deployments
- Inconsistent server configurations
- Slow release cycles
- Limited scalability and resilience
- Security vulnerabilities discovered late
- Insufficient monitoring and troubleshooting visibility

## Engineering Solution

The modernization work covers:

| Engineering Area | Technologies |
|---|---|
| Application | React, Java 17, Spring Boot, PostgreSQL |
| Cloud Infrastructure | AWS VPC, EC2, ECS/Fargate, EKS, ALB, ECR, S3, IAM |
| Infrastructure as Code | Terraform |
| CI/CD | GitHub Actions, Jenkins |
| GitOps | Argo CD, Helm, Kubernetes |
| Configuration Management | Ansible, Bash, Python |
| DevSecOps | Gitleaks, Trivy, Checkov, SonarQube |
| Observability | CloudWatch, Prometheus, Grafana |
| Local Development | Docker, Docker Compose, Vagrant |

## Engineering Implementation & Results

### Application Engineering
- Built a React storefront backed by a Java Spring Boot REST API and PostgreSQL database.
- Verified database connectivity, product retrieval, application health checks, and successful frontend/backend builds.
- Containerized the Java application using Docker and validated runtime behavior.

### AWS Infrastructure & Networking
- Developed reusable Terraform modules for VPC networking, public/private subnets, routing, NAT Gateway, security groups, IAM, EC2, ALB, ECR, ECS/Fargate, and EKS.
- Implemented infrastructure spanning two AWS Availability Zones, with public-facing load balancing and private application workloads.
- Practiced infrastructure provisioning, validation, troubleshooting, and teardown to control cloud costs.

### CI/CD & Release Engineering
- Implemented GitHub Actions workflows for automated application builds, testing, and security scanning.
- Developed Jenkins pipelines integrating application builds, SonarQube, Docker, Amazon ECR, and security checks.
- Implemented container delivery workflows using Amazon ECR, ECS/Fargate, and Kubernetes deployment configurations.

### Kubernetes & GitOps
- Implemented Kubernetes application deployment patterns using EKS, Helm, and Argo CD.
- Worked with deployment health checks, scaling, configuration management, and GitOps reconciliation.
- Practiced troubleshooting container startup, image retrieval, service connectivity, and deployment failures.

### DevSecOps
- Integrated Gitleaks, Trivy, Checkov, and SonarQube into application and infrastructure delivery workflows.
- Remediated container and Java dependency vulnerabilities.
- Verified zero HIGH and CRITICAL findings in the final local Trivy image scan.
- Completed a successful GitHub Actions CI run with automated security checks.

### Automation & Observability
- Automated infrastructure configuration and operational tasks using Ansible, Bash, and Python.
- Implemented monitoring and troubleshooting exercises using Amazon CloudWatch, Prometheus, and Grafana.
- Practiced interpreting application and infrastructure health signals to investigate operational issues.

### Database Engineering
- Implemented PostgreSQL integration for the NovaStore application.
- Completed additional MySQL and MongoDB exercises covering relational data, queries, and document-oriented data models.

## CI/CD and Security

The repository contains GitHub Actions and Jenkins delivery workflows covering automated testing, code analysis, container builds, security scanning, and container registry integration.

Security controls include secret scanning with Gitleaks, container scanning with Trivy, Terraform scanning with Checkov, and code quality analysis through SonarQube.

**Current CI enforcement:** GitHub Actions blocks CRITICAL Trivy findings; Checkov runs in reporting mode (`soft_fail: true`).

## Infrastructure and Deployment

Terraform modules define reusable AWS infrastructure, including VPC networking, public and private subnets, NAT Gateway, IAM, ECR, ECS/Fargate, EKS, Jenkins, and supporting resources.

The project also includes Helm charts and Argo CD configuration for Kubernetes deployment and GitOps workflows.

Cloud resources are currently shut down to avoid unnecessary AWS charges. A green CI run does not imply that a live AWS deployment is currently running.

## Engineering Documentation

- [Architecture](docs/architecture/)
- [Screenshots and Evidence](docs/screenshots/)
- [Troubleshooting](docs/troubleshooting/)

## Engineering Troubleshooting & Incident Response

Beyond infrastructure provisioning and automated deployments, NovaStore documents real engineering troubleshooting across application availability, Kubernetes networking, GitOps, CI/CD, IAM, and container security.

### Featured Engineering Investigations

| Incident | Engineering Focus |
|---|---|
| [EKS Application Inaccessible Through ALB](docs/troubleshooting/06-eks-alb-application-connectivity.md) | Diagnosing the ALB-to-Pod request path, Ingress routing, health checks, IAM, and subnet discovery |
| [Unhealthy Kubernetes Deployment](docs/troubleshooting/07-unhealthy-kubernetes-deployment.md) | Investigating runtime health, readiness/liveness probes, service ports, and recovery strategies |
| [Argo CD Synchronization Failure](docs/troubleshooting/08-argocd-gitops-synchronization.md) | Troubleshooting Git repository access, authentication, and GitOps reconciliation |

**[Explore all 8 engineering troubleshooting case studies →](docs/troubleshooting/README.md)**

The case studies distinguish confirmed configuration changes from diagnostic procedures and verification steps where historical runtime evidence is unavailable.

## Project Status

**Application and GitHub Actions CI:** Verified.

**AWS infrastructure and deployment workflows:** Implemented or configured during the broader engineering work; live deployment is not currently active.

**Portfolio documentation:** In progress.
