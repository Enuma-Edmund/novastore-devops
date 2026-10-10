# Case Study 07 — Deployment Completed but Kubernetes Application Became Unhealthy

## Engineering Context

NovaStore uses Jenkins for continuous integration, Docker for application packaging, Amazon ECR for image storage, and Helm to define Kubernetes workloads on Amazon EKS.

The application runs with two desired replicas and is exposed through a Kubernetes Service and AWS Application Load Balancer.

The business requirement is to maintain application availability during software releases.

## Incident

During application deployment testing, the deployment completed but the application became unhealthy.

This demonstrated that successfully applying Kubernetes manifests does not guarantee application readiness or successful request handling.

The incident was encountered during engineering implementation and is not represented as a customer-facing production outage.

## Investigation

### 1. Separate Build Success from Runtime Health

The Jenkins pipeline performs:

- Git checkout
- Gitleaks secret scanning
- Maven tests
- SonarQube analysis and quality-gate evaluation
- Maven packaging
- Checkov infrastructure scanning
- Docker image creation
- Trivy container scanning
- ECR image publishing

These stages validate important aspects of software delivery, but they do not prove the application will become healthy after deployment.

### 2. Examine Kubernetes Rollout Status

Useful diagnostic commands:

    kubectl get deployments -A
    kubectl get pods -A
    kubectl describe deployment <deployment-name> -n <namespace>
    kubectl rollout status deployment/<deployment-name> -n <namespace>

The investigation should distinguish a successfully submitted deployment from a successfully completed rollout.

### 3. Inspect Pod Failures and Application Logs

    kubectl describe pod <pod-name> -n <namespace>
    kubectl logs <pod-name> -n <namespace>
    kubectl get events -n <namespace> --sort-by=.lastTimestamp

Possible failure categories include application startup errors, missing configuration, image pull failures, resource constraints, and failed health probes.

These are diagnostic possibilities, not independently established causes of this incident.

### 4. Review Health Probes

The Helm chart configures:

Readiness probe:
- HTTP endpoint: /health
- Container port: 8080
- Initial delay: 10 seconds
- Period: 10 seconds

Liveness probe:
- HTTP endpoint: /health
- Container port: 8080
- Initial delay: 20 seconds
- Period: 20 seconds

Readiness determines whether a Pod should receive Service traffic.

Liveness determines whether Kubernetes should restart an unhealthy container.

Incorrect endpoints, startup timing, or application behavior can cause a deployed workload to remain unavailable.

### 5. Validate Service and Container Ports

The Helm values specify:

- Application container port: 8080
- Kubernetes Service port: 80
- Kubernetes Service target port: 8080

The Service must forward requests to the actual application listening port.

A mismatch can cause connection failures even when the Pod is running.

### 6. Evaluate Resource Constraints

The Helm chart specifies:

- CPU request: 100m
- CPU limit: 250m
- Memory request: 128Mi
- Memory limit: 256Mi

CPU throttling, memory exhaustion, or insufficient cluster capacity can affect application startup and health.

The investigation should use Pod events and resource metrics before concluding that resource limits caused the failure.

## Recovery and Rollback Strategy

When a newly deployed release is unhealthy, first determine whether the problem can be corrected safely or whether restoring the previous known-good version is preferable.

Useful Helm commands:

    helm history <release-name> -n <namespace>
    helm status <release-name> -n <namespace>
    helm rollback <release-name> <revision> -n <namespace>

For Kubernetes rollout history:

    kubectl rollout history deployment/<deployment-name> -n <namespace>

A rollback must be followed by readiness, target-health, and application smoke-test verification.

These commands describe the recovery approach; the available repository evidence does not independently prove that a particular rollback command was executed during this incident.

## Evidence and Root-Cause Boundary

The user encountered an unhealthy application deployment.

The repository confirms the delivery architecture, configured readiness and liveness probes, Service-to-container port mapping, and resource limits.

The available Git history does not identify a single confirmed root cause or preserve the exact failed release logs.

Accordingly, this case documents the incident and evidence-based troubleshooting approach without inventing a specific failure message or claiming an unverified rollback.

## Prevention

- Validate application health endpoints before deployment.
- Require readiness checks before directing traffic to new Pods.
- Monitor Kubernetes events and application logs during rollout.
- Verify Service selectors, ports, and endpoint availability.
- Use versioned container images for traceable releases.
- Include post-deployment smoke tests.
- Define rollback criteria and test recovery procedures.
- Consider Helm `--wait` and `--atomic` where appropriate for the deployment workflow.
- Alert on unhealthy Pods and ALB target-health deterioration.

## Engineering Lesson

A successful CI pipeline proves that the software passed its configured build and security checks.

A successful Kubernetes manifest submission proves that the deployment request was accepted.

Neither guarantees that the application is healthy or available to users.

Production release engineering requires runtime verification and a controlled recovery strategy.

## Supporting Evidence

- [Jenkins pipeline](../../Jenkinsfile)
- [Helm Deployment](../../helm/java-app/templates/deployment.yaml)
- [Helm values](../../helm/java-app/values.yaml)
- Kubernetes application implementation — historical private-repository commit `f1f22b1` (not publicly accessible)
- Helm chart implementation — historical private-repository commit `ede289f` (not publicly accessible)
