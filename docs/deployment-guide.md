# NovaStore — AWS Deployment Guide

This guide covers local builds, AWS infrastructure preparation, image publishing, ECS/Fargate and EKS/Kubernetes deployment, verification, troubleshooting, and cleanup for the NovaStore retail e-commerce application.

NovaStore has two container deployment paths: **ECS/Fargate** and **EKS/Kubernetes**. The development Terraform root includes resources for both paths and supporting services. Applying that root may provision both platforms and incur significant AWS charges; review the complete plan before proceeding.

> Run commands from the repository root unless otherwise stated. Replace example values with settings from your own AWS environment. Commands that require existing AWS infrastructure are explicitly labeled.

## 1. Prerequisites and AWS identity

Install Git, Java 17, Maven, Node.js/npm, Docker, AWS CLI, Terraform, Helm, kubectl, and jq. Confirm tool availability:

```bash
git --version
java -version
mvn -version
node --version
npm --version
docker --version
aws --version
terraform version
helm version
kubectl version --client
jq --version
```

Set the target region and AWS profile:

```bash
export AWS_PROFILE=default
export AWS_REGION=us-east-2
aws sts get-caller-identity
aws configure get region --profile "$AWS_PROFILE"
```

Confirm the account ID and principal match the account you intend to use. Never commit AWS credentials.

## 2. Obtain and inspect the source

```bash
git clone https://github.com/Enuma-Edmund/novastore-devops.git
cd novastore-devops
git status --short
git log -1 --oneline
ls app frontend terraform helm/java-app .github/workflows
```

Major components:

| Path | Responsibility |
| --- | --- |
| `app/` | Java/Spring Boot backend and Dockerfile |
| `frontend/` | React storefront |
| `terraform/environments/dev/` | AWS development infrastructure root |
| `terraform/modules/` | Reusable AWS resource definitions |
| `helm/java-app/` | Kubernetes application chart |
| `argocd/` | Argo CD GitOps configuration |
| `Jenkinsfile` | Jenkins CI/CD pipeline |
| `.github/workflows/` | GitHub Actions workflows |
| `ansible/` | Linux configuration automation |
| `docs/troubleshooting/` | Troubleshooting investigations |

## 3. Build and test the application locally

Build and test the Java backend:

```bash
cd app
mvn --batch-mode clean verify
cd ..
```

Successful tests end with `BUILD SUCCESS`. Build and inspect the backend image:

```bash
docker build -t novastore-api:local ./app
docker image inspect novastore-api:local \
  --format 'User={{.Config.User}} Ports={{json .Config.ExposedPorts}}'
```

The backend depends on PostgreSQL. Inspect `compose.yaml` and the application's database configuration before starting the local stack. Set required environment variables in an untracked local `.env` file; never use production secrets for testing.

```bash
docker compose config --services
docker compose up -d postgres
docker compose ps
docker compose logs --tail=50 postgres
```

If the Compose service has a different name, use the name shown by `docker compose config --services`. Stop the local stack without deleting persistent volumes:

```bash
docker compose down
```

Build the React frontend:

```bash
cd frontend
npm ci
npm run lint --if-present
npm run build
cd ..
```

The backend container deployment paths below do not by themselves publish the React storefront; frontend hosting and routing are separate deployment concerns.

## 4. Validate Terraform and review the infrastructure plan

Run static validation from the repository root:

```bash
terraform -chdir=terraform/environments/dev init -backend=false
terraform -chdir=terraform/environments/dev fmt -check
terraform -chdir=terraform/environments/dev validate
```

Inspect the environment configuration and inputs:

```bash
ls terraform/environments/dev
sed -n '1,220p' terraform/environments/dev/variables.tf
sed -n '1,240p' terraform/environments/dev/main.tf
```

Before provisioning, configure the intended Terraform backend, required variables, AWS account references, IAM permissions, subnet availability zones, administrator CIDR, ECR image URI, and resource quotas. Use a private, untracked `.tfvars` file appropriate to your environment. Do not assume sample values will produce a valid or affordable deployment.

From the development environment directory, initialize the actual backend and inspect a plan:

```bash
cd terraform/environments/dev
terraform init
terraform plan -var-file=terraform.tfvars -out=novastore.tfplan
terraform show novastore.tfplan
cd ../../..
```

**Only after reviewing the complete plan**, provision explicitly:

```bash
# cd terraform/environments/dev
# terraform apply novastore.tfplan
# cd ../../..
```

A full apply of the current development root may create ECS, EKS, load balancers, NAT gateways, EC2 services, and related infrastructure. It is not a single-platform switch. Do not use Terraform `-target` as a permanent architecture-selection method.

## 5. Build, tag, and publish a Docker image to ECR

**Requires:** An ECR repository already created in the intended AWS account and region.

Choose the repository name from the Terraform output or actual AWS configuration, rather than assuming a name:

```bash
export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
export ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
export ECR_REPOSITORY=novastore-dev-app   # Confirm against your Terraform configuration
export IMAGE_TAG="$(git rev-parse --short=12 HEAD)"
export IMAGE_URI="${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"

aws ecr describe-repositories \
  --repository-names "$ECR_REPOSITORY" \
  --region "$AWS_REGION"
```

Authenticate, build, and push:

```bash
aws ecr get-login-password --region "$AWS_REGION" | \
  docker login --username AWS --password-stdin "$ECR_REGISTRY"

cd app
mvn --batch-mode clean package
cd ..

docker build -t novastore-api:local ./app
docker tag novastore-api:local "$IMAGE_URI"
docker push "$IMAGE_URI"
```

Verify the image exists:

```bash
aws ecr describe-images \
  --repository-name "$ECR_REPOSITORY" \
  --image-ids imageTag="$IMAGE_TAG" \
  --region "$AWS_REGION"
```

Ensure the ECS task definition or Helm values reference this exact image. The repository includes historical image references that must be aligned with the image you publish.

## 6. ECS/Fargate deployment path

**Traffic path:** Internet → Application Load Balancer → Target Group → ECS Service → Fargate Task → Spring Boot API.

**Requires:** VPC, subnets, IAM roles, ECR image, ALB, target group, ECS cluster/service, task networking, database connectivity, and appropriate security groups.

Inspect the actual names from Terraform outputs:

```bash
cd terraform/environments/dev
terraform output
terraform output -raw ecs_cluster_name
terraform output -raw ecs_service_name
terraform output -raw ecs_alb_url
cd ../../..
```

Set names using the output values (adjust if your environment differs):

```bash
export ECS_CLUSTER=novastore-dev-cluster
export ECS_SERVICE=novastore-dev-service

aws ecs describe-clusters \
  --clusters "$ECS_CLUSTER" --region "$AWS_REGION"
aws ecs describe-services \
  --cluster "$ECS_CLUSTER" --services "$ECS_SERVICE" \
  --region "$AWS_REGION"
```

Wait for service stability and inspect tasks:

```bash
aws ecs wait services-stable \
  --cluster "$ECS_CLUSTER" --services "$ECS_SERVICE" \
  --region "$AWS_REGION"

aws ecs list-tasks \
  --cluster "$ECS_CLUSTER" --service-name "$ECS_SERVICE" \
  --desired-status RUNNING --region "$AWS_REGION"
```

Inspect CloudWatch logs (confirm the log-group name from the Terraform output):

```bash
aws logs tail /ecs/novastore-dev --since 30m --region "$AWS_REGION"
```

Smoke-test the ALB endpoint after the application and database are ready:

```bash
cd terraform/environments/dev
ALB_URL="$(terraform output -raw ecs_alb_url)"
cd ../../..
curl -i "${ALB_URL%/}/health"
```

Check ECS service events, stopped task reasons, ALB target health, application port, database connectivity, and logs if the request fails. An HTTP 200 from the health endpoint is an application-level check; it does not replace a full end-to-end storefront test.

## 7. EKS/Kubernetes deployment path

**Traffic path:** Internet → ALB → Kubernetes Ingress → Service → Spring Boot Pods.

**Requires:** EKS cluster and worker nodes, ECR image access, database connectivity, Kubernetes Secrets, metrics components for HPA, and the AWS Load Balancer Controller for ALB-backed Ingress.

Configure cluster access:

```bash
export EKS_CLUSTER=novastore-dev-eks  # Confirm against Terraform output
aws eks update-kubeconfig --name "$EKS_CLUSTER" --region "$AWS_REGION"
kubectl config current-context
kubectl get nodes -o wide
```

Verify the ALB controller if enabling Ingress:

```bash
kubectl get deployment aws-load-balancer-controller -n kube-system
```

The controller's IAM role is not the same as an installed controller. If the deployment is missing, follow the AWS Load Balancer Controller installation procedure and verify its service account permissions and subnet discovery.

Lint and render the chart before deployment:

```bash
helm lint helm/java-app
helm template novastore helm/java-app
```

Inspect the actual chart's Deployment and Service names before using commands that reference them:

```bash
helm template novastore helm/java-app | grep -E '^kind:|^  name:'
```

With dependencies configured, deploy the image built in Section 5:

```bash
helm upgrade --install novastore helm/java-app \
  --namespace default \
  --set image.repository="${ECR_REGISTRY}/${ECR_REPOSITORY}" \
  --set image.tag="$IMAGE_TAG" \
  --wait --timeout 10m
```

Verify the resulting resources:

```bash
kubectl get deployments,pods,services,ingress
kubectl get events --sort-by=.lastTimestamp | tail -30
kubectl get hpa
```

Use the Deployment and Service names printed by `kubectl get` for the following checks:

```bash
# Replace <deployment-name> and <service-name> with actual values:
# kubectl rollout status deployment/<deployment-name> --timeout=300s
# kubectl logs deployment/<deployment-name> --tail=100
# kubectl port-forward service/<service-name> 8080:80
```

In a second terminal, after starting port-forwarding:

```bash
curl -i http://localhost:8080/health
```

A functioning ALB Ingress also requires appropriate controller permissions, subnet tags, and security-group routing.

## 8. Argo CD and CI/CD alignment

The repository includes `argocd/novastore-java.yaml`. Inspect its Git URL, target revision, chart path, destination namespace, and Helm image values before applying:

```bash
cat argocd/novastore-java.yaml
```

After installing Argo CD and configuring Git access:

```bash
kubectl apply -f argocd/novastore-java.yaml
kubectl get applications -n argocd
kubectl describe application novastore-java -n argocd
```

Ensure the Git revision in the manifest exists. The checked configuration has previously referenced `feature/retail-fullstack`; use the intended maintained branch for new deployments.

GitHub Actions and Jenkins handle build, tests, scanning, and image publishing; Argo CD continuously reconciles the Kubernetes desired state. Inspect the implementation:

```bash
cat .github/workflows/ci.yml
cat Jenkinsfile
```

**Configuration alignment to check:** The GitHub Actions ECR publishing trigger has been configured for `develop`, while the Terraform GitHub OIDC trust configuration has allowed `main`. Those must agree before relying on automated ECR publishing. Checkov has been configured with `soft_fail: true`, meaning findings do not necessarily block the workflow. These are implementation decisions to review, not reasons to assume an automated release occurred.

## 9. Deployment verification checklist

For the selected platform, confirm:

1. The intended image tag exists in ECR and is referenced by the running workload.
2. ECS tasks or Kubernetes Pods are running and ready.
3. Application logs contain no unresolved startup errors.
4. Database connectivity and required Secrets work.
5. Health endpoint responds through the intended Service/ALB path.
6. ALB target groups are healthy and security groups allow the required ports.
7. Monitoring and alert routing are configured for the target environment.
8. The application endpoint passes a smoke test after the release.

Capture the deployed image tag, environment, timestamp, and smoke-test result for an auditable release record.

## 10. Troubleshooting commands

### Backend build or container startup

```bash
cd app && mvn --batch-mode clean verify && cd ..
docker build --progress=plain -t novastore-api:debug ./app
```

Check Java version, dependency resolution, Dockerfile JAR path, environment variables, database connection, and the actual application listening port.

### ECR authentication or image pull

```bash
aws sts get-caller-identity
aws ecr describe-images \
  --repository-name "$ECR_REPOSITORY" \
  --image-ids imageTag="$IMAGE_TAG" \
  --region "$AWS_REGION"
```

Check account/region mismatch, ECR repository and tag, task execution role or node IAM permissions, and network egress.

### ECS tasks failing or ALB unhealthy

```bash
aws ecs describe-services \
  --cluster "$ECS_CLUSTER" --services "$ECS_SERVICE" \
  --region "$AWS_REGION"
aws logs tail /ecs/novastore-dev --since 30m --region "$AWS_REGION"
```

Check task stopped reasons, target group health, health-check path, container port, security groups, and PostgreSQL connectivity.

### Kubernetes Pending, ImagePullBackOff, or no Service endpoints

```bash
kubectl get pods -o wide
kubectl describe pods
kubectl get nodes
kubectl get services,endpointslices
kubectl get events --sort-by=.lastTimestamp | tail -30
```

Check resource requests, node capacity, image URI, ECR access, readiness probes, Service selectors, and target port.

### Ingress exists but no ALB

```bash
kubectl get ingress
kubectl describe ingress
kubectl get deployment aws-load-balancer-controller -n kube-system
```

Check controller installation, IAM permissions, ingress class, subnet discovery, and AWS controller logs.

### Argo CD OutOfSync

Compare the Git-defined manifests and Helm values with the live cluster. Prefer correcting Git desired state over making persistent manual changes to GitOps-managed resources.

See [Engineering Troubleshooting and Incident Response](troubleshooting/README.md) for project investigation narratives.

## 11. Rollback

For Helm-based releases, inspect release history and select a known-good revision:

```bash
helm history novastore
# Replace REVISION with a confirmed earlier revision:
# helm rollback novastore REVISION --wait
```

For ECS, restore the last known-good task definition/image through the established release process and ensure Terraform configuration will not immediately overwrite the rollback. For Argo CD, revert the desired state in Git and allow reconciliation.

## 12. Cleanup and cost control

**Destructive operations require account and Terraform state verification.** Removing AWS resources may permanently delete data. Kubernetes-created ALBs may need controller-managed cleanup before EKS is destroyed.

```bash
aws sts get-caller-identity
cd terraform/environments/dev
terraform plan -destroy -var-file=terraform.tfvars
```

Review the complete destroy plan and confirm it applies only to the intended NovaStore environment. If authorized, perform cleanup:

```bash
# terraform destroy -var-file=terraform.tfvars
```

Check the AWS console and billing for resources left outside Terraform management, including load balancers, EBS volumes, ECR storage, CloudWatch logs, and NAT gateways.

## Engineering references

- [Terraform infrastructure](../terraform/)
- [GitHub Actions](../.github/workflows/ci.yml)
- [Jenkins pipeline](../Jenkinsfile)
- [Helm chart](../helm/java-app/)
- [Argo CD application](../argocd/novastore-java.yaml)
- [Troubleshooting investigations](troubleshooting/README.md)
