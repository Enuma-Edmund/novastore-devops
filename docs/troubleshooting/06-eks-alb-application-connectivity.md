# Case Study 06 — EKS Application Inaccessible Through AWS ALB

## Business and Engineering Context

NovaStore runs a containerized Java application on Amazon EKS.

The application is deployed using Kubernetes and Helm, with an internet-facing AWS Application Load Balancer providing external access.

A critical availability requirement is that users can reach the application through the load balancer, not merely that the Kubernetes Pods are running.

## Incident

During the EKS deployment, the Application Load Balancer was created, but the application remained inaccessible through the external endpoint.

This exposed a gap between successful infrastructure provisioning and actual application availability.

The incident occurred during engineering implementation; it is not presented as a customer-facing production outage.

## Troubleshooting Approach

The investigation followed the request path:

Internet -> ALB -> Ingress routing -> Kubernetes Service -> Application Pods

The objective was to identify which layer prevented requests from reaching a healthy application.

### 1. Validate Kubernetes Workloads

Check the application Pods, Services, and endpoints:

    kubectl get pods -A
    kubectl get svc -A
    kubectl get endpoints -A

A running Pod alone does not establish external connectivity.

The Service must select the correct Pods and expose the intended application port.

### 2. Inspect Ingress Configuration

Check the Ingress resource and its events:

    kubectl get ingress -A
    kubectl describe ingress <ingress-name> -n <namespace>

The configuration must be recognized by the AWS Load Balancer Controller and route to the intended Kubernetes Service.

### 3. Inspect AWS Load Balancer Target Health

Review the ALB listener, target group, target registration, and health-check configuration.

An ALB can exist while its targets are unhealthy or traffic routing is misconfigured.

Potential failure areas include incorrect health-check paths, ports, security groups, and application responses.

### 4. Review Controller Permissions and Subnet Discovery

The AWS Load Balancer Controller needs appropriate IAM permissions to manage AWS resources.

For EKS, IAM Roles for Service Accounts (IRSA) can provide those permissions through an OIDC trust relationship.

The controller also needs to identify appropriate subnets for the load balancer.

## Configuration Changes Recorded in Git

Commit cc414d0 introduced several related changes:

1. Explicitly set `ingressClassName: alb`.
2. Enabled Ingress in Helm values.
3. Configured the ALB health-check path as `/health`.
4. Set the health-check port to `traffic-port`.
5. Required HTTP `200` for successful health checks.
6. Added an AWS IAM role and policy for the Load Balancer Controller.
7. Configured EKS OIDC integration for controller authentication.
8. Added Kubernetes load-balancer discovery tags to public and private subnets.

These changes addressed important dependencies across Kubernetes routing and AWS infrastructure.

## Root-Cause Assessment

The confirmed incident was that the ALB existed but the application was inaccessible.

The Git evidence shows corrections to the Ingress and supporting AWS configuration.

However, the available commit does not isolate one setting as the sole root cause or preserve the original target-health error.

The defensible engineering conclusion is that external application availability depended on aligning Kubernetes routing, ALB health checks, controller permissions, and AWS network configuration.

## Verification Strategy

After applying corrections, validate the complete request path rather than relying on Pod status alone.

    kubectl get ingress -A
    kubectl get pods -A
    kubectl get svc -A

Then verify:

- Ingress has the expected ALB address.
- ALB listener forwards to the intended target group.
- Registered targets report healthy.
- Health-check endpoint returns HTTP 200.
- Kubernetes Service resolves to the intended application Pods.
- External requests reach the application successfully.

The commit history supports the configuration changes. It does not independently establish the final target-health status or preserve an external HTTP test result.

## Prevention and Operational Improvements

- Define application health checks explicitly.
- Validate Service selectors and target ports during deployment.
- Monitor ALB target health and HTTP 5XX metrics.
- Check AWS Load Balancer Controller logs and Kubernetes events.
- Validate IAM permissions and subnet discovery configuration.
- Include an external smoke test after deployment.
- Treat infrastructure readiness and application availability as separate checks.

## Engineering Lessons

A successfully created ALB does not prove that an EKS application is available.

Production troubleshooting must follow the complete traffic path and distinguish AWS infrastructure, Kubernetes routing, application health, and controller permissions.

## Supporting Evidence

- ALB Controller and Ingress implementation — historical private-repository commit `cc414d0` (not publicly accessible)
- [Helm Ingress configuration](../../helm/java-app/templates/ingress.yaml)
- [Helm values](../../helm/java-app/values.yaml)
- [AWS Load Balancer Controller IAM configuration](../../terraform/environments/dev/alb-controller.tf)
- [Terraform VPC networking](../../terraform/modules/vpc/main.tf)
