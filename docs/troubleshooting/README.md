# NovaStore — Engineering Troubleshooting Case Studies

This collection documents real engineering problems, configuration corrections, and troubleshooting investigations encountered while building the NovaStore AWS DevOps platform.

The case studies focus on identifying failures, isolating the affected infrastructure or application layer, evaluating remediation options, and verifying outcomes.

Where original logs or runtime verification records are unavailable, the documentation distinguishes confirmed Git evidence from troubleshooting methods and recommended verification.

## Application Availability and Kubernetes

| Case | Engineering Problem | Technologies |
|---|---|---|
| [06 — EKS Application Inaccessible Through ALB](06-eks-alb-application-connectivity.md) | ALB created, but the application was inaccessible | EKS, ALB, Ingress, Kubernetes Service, IAM, VPC |
| [07 — Unhealthy Kubernetes Deployment](07-unhealthy-kubernetes-deployment.md) | Deployment completed, but application health deteriorated | Kubernetes, Helm, Jenkins, readiness/liveness probes |
| [08 — Argo CD Synchronization Failure](08-argocd-gitops-synchronization.md) | GitOps application changes could not synchronize reliably | Argo CD, Git, SSH, Helm, EKS |

## CI/CD, Security, and Infrastructure Automation

| Case | Engineering Problem | Technologies |
|---|---|---|
| [01 — Container Security Remediation](01-container-security-remediation.md) | Container image vulnerabilities and runtime hardening | Docker, Trivy, Java, Spring Boot |
| [02 — CI Registry Rate Limiting](02-ci-registry-rate-limiting.md) | Container registry rate limits disrupted CI dependencies | GitHub Actions, PostgreSQL, Amazon ECR Public |
| [03 — GitHub OIDC Trust Policy](03-github-oidc-trust-policy.md) | AWS workload identity and IAM trust configuration | GitHub Actions, AWS IAM, OIDC, ECR |
| [04 — Trivy Action Version Failure](04-trivy-action-version-failure.md) | Security scanning workflow dependency could not resolve correctly | GitHub Actions, Trivy |
| [05 — Jenkins Java Build Environment](05-jenkins-java-build-environment.md) | Build agent lacked the required Java development toolchain | Jenkins, EC2, Maven, JDK, Terraform |

## Engineering Troubleshooting Method

Across these investigations, the approach is consistent:

1. Establish the affected business or engineering capability.
2. Identify the failing layer using logs, configuration, events, and metrics.
3. Separate symptoms from confirmed root causes.
4. Apply a targeted correction while considering security and availability.
5. Verify the affected workflow end to end.
6. Document prevention measures and supporting evidence.

## Evidence Standards

These cases describe engineering implementation and troubleshooting work, not fabricated customer-facing production outages.

Configuration changes are linked to repository history where available. Diagnostic commands and recovery strategies are identified separately from actions independently established by Git evidence.
