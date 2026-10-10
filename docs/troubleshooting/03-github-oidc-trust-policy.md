# Case Study 03 — GitHub Actions OIDC Trust-Policy Troubleshooting

## Engineering Context

NovaStore uses GitHub Actions and AWS IAM OIDC federation to support secure CI/CD access to Amazon ECR without storing long-lived AWS access keys.

## Problem and Engineering Risk

The OIDC configuration required investigation of the repository identity used in the AWS IAM role trust policy.

A mismatch between the GitHub-issued token's subject claim and the IAM trust condition can prevent the workflow from assuming its AWS role.

This creates an authentication failure before ECR authorization or image publishing can proceed.

## Investigation

Rather than broadening AWS permissions, temporary diagnostic steps were added to GitHub Actions to inspect:

- GITHUB_REPOSITORY
- GITHUB_REPOSITORY_ID
- GITHUB_REPOSITORY_OWNER_ID

Commit b0e7060 records this diagnostic change.

These values helped establish the repository identity to use when configuring the trust relationship.

## Root-Cause Analysis

AWS IAM evaluates the OIDC token against the role's trust policy.

The relevant conditions are:

- Audience: sts.amazonaws.com
- Subject: the expected GitHub repository identity

The original Terraform policy used a repository-name-based subject pattern.

Commit 215b16f changed that pattern to an ID-based repository subject and removed the temporary diagnostic step.

The exact OIDC token subject and successful role-assumption result must match this configuration for authentication to work.

## Engineering Resolution

The Terraform configuration defines:

1. An AWS IAM OIDC provider for token.actions.githubusercontent.com.
2. An IAM role permitting sts:AssumeRoleWithWebIdentity.
3. Audience validation using StringEquals.
4. Repository subject validation using StringLike.
5. A separate IAM permissions policy for Amazon ECR operations.

The ECR policy allows authentication-token retrieval and restricts repository-specific image operations to the application ECR repository ARN.

## Engineering Decision

The investigation focused on identity claims and trust-policy matching rather than introducing static AWS credentials or granting broader permissions.

Temporary diagnostics were removed after the trust-policy change, keeping the CI workflow focused on delivery.

## Verification and Evidence Boundaries

The Git commits establish that repository identity was investigated and the Terraform trust policy was changed.

They do not independently establish the exact AWS authentication error, customized GitHub OIDC token claims, or a successful STS role-assumption test.

Those require workflow execution evidence or AWS STS verification.

## Prevention

- Validate OIDC audience and subject claims against IAM trust conditions.
- Use temporary diagnostic instrumentation when investigating identity mismatches.
- Prefer short-lived federated credentials over stored AWS access keys.
- Keep trust-policy scope separate from ECR authorization permissions.
- Restrict registry operations to the intended ECR repository.
- Verify role assumption before troubleshooting downstream image-push permissions.

## Supporting Evidence

- Identity diagnostic commit — historical private-repository commit `b0e7060` (not publicly accessible)
- Trust-policy update commit — historical private-repository commit `215b16f` (not publicly accessible)
- [Terraform OIDC configuration](../../terraform/environments/dev/github-oidc.tf)
- [GitHub Actions workflow](../../.github/workflows/ci.yml)

## Scope

This case documents OIDC identity investigation and IAM trust-policy configuration during the NovaStore engineering project. It does not claim a customer-facing production incident.
