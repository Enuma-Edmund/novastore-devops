# Case Study 08 — Argo CD GitOps Synchronization Failure

## Engineering Context

NovaStore uses Argo CD to manage Kubernetes application deployments through GitOps.

The application configuration is stored in Git, while Helm defines the Kubernetes resources deployed to Amazon EKS.

Argo CD compares the desired configuration in Git with the actual state of the Kubernetes cluster.

## Incident

During GitOps implementation, Argo CD encountered difficulty synchronizing application changes from the Git repository.

This affected the deployment workflow because application changes could not reliably progress from the desired configuration in Git to the Kubernetes cluster.

The incident occurred during engineering implementation, not a customer-facing production outage.

## Troubleshooting Approach

### 1. Inspect Argo CD Application Status

Start by determining whether the problem involves repository access, manifest generation, or Kubernetes reconciliation.

Useful commands:

    argocd app get <application-name>
    argocd app history <application-name>
    kubectl describe application <application-name> -n argocd

An application can be OutOfSync because its live resources differ from Git, while a repository access failure can prevent Argo CD from calculating or applying the desired state.

These conditions require different fixes.

### 2. Verify Repository Connectivity

The original Argo CD application configuration used an HTTPS repository URL.

Commit 5852f3f changed the repository reference to SSH:

Before:

    https://github.com/Enuma-Edmund/novastore-devops.git

After:

    git@github.com:Enuma-Edmund/novastore-devops.git

This is a confirmed repository configuration change.

For a private Git repository, Argo CD must have credentials compatible with the configured transport.

Using SSH requires an authorized SSH key and appropriate repository configuration within Argo CD.

Changing the URL alone does not guarantee successful authentication.

### 3. Validate the Git Revision and Helm Path

The Argo CD Application defines:

- A Git repository URL
- A target Git revision
- A Helm chart path
- A Kubernetes deployment destination

A missing branch, incorrect Helm path, or inaccessible repository can prevent Argo CD from generating the intended Kubernetes manifests.

The repository revision and chart path must be verified together.

### 4. Separate Git Authentication from Kubernetes Deployment Failures

Repository authentication problems prevent Argo CD from retrieving source configuration.

Manifest-generation failures can occur when Helm templates or values are invalid.

Kubernetes reconciliation failures can occur when cluster permissions, resource definitions, or admission policies reject changes.

The correct troubleshooting approach identifies the failing layer before changing application resources.

## Engineering Resolution

The recorded remediation changed the Argo CD repository URL from HTTPS to SSH.

This aligned the application manifest with an SSH-based repository access approach.

The repository history establishes this configuration correction.

The available evidence does not independently confirm the original Argo CD error message, the registered SSH credentials, or the final successful synchronization event.

## Verification Strategy

After configuring repository access, verify:

1. Argo CD can connect to the Git repository.
2. The target branch exists and is accessible.
3. The Helm chart path is correct.
4. Manifest generation succeeds.
5. The Application reports the expected synchronization status.
6. The deployed Kubernetes workloads are healthy.
7. An application smoke test succeeds.

Useful commands:

    argocd repo list
    argocd app get <application-name>
    argocd app diff <application-name>
    kubectl get pods -A

A successful Git connection alone does not prove that the deployed application is healthy.

## Prevention

- Use a consistent Git authentication method for Argo CD.
- Manage SSH credentials securely and rotate them when required.
- Validate repository access before registering applications.
- Keep Git revisions and Helm paths accurate.
- Monitor Argo CD synchronization and application health.
- Separate repository errors from Kubernetes reconciliation errors.
- Define appropriate automated or manual synchronization policies.
- Verify runtime health after synchronization.

## Engineering Lesson

GitOps depends on more than storing Kubernetes manifests in Git.

Argo CD must authenticate to the repository, retrieve the correct revision, render valid manifests, reconcile Kubernetes resources, and verify application health.

Troubleshooting must isolate which part of that chain is failing.

## Supporting Evidence

- Argo CD repository URL correction — historical private-repository commit `5852f3f` (not publicly accessible)
- [Argo CD Application configuration](../../argocd/novastore-java.yaml)
- [Helm chart values](../../helm/java-app/values.yaml)

## Scope

This case documents an Argo CD GitOps synchronization incident encountered during NovaStore implementation. Specific error logs and a successful post-fix synchronization record are not preserved in the available Git evidence.
