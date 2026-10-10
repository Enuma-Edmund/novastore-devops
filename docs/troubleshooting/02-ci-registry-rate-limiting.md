# Case Study 02 — CI Pipeline Reliability: Docker Hub Rate Limiting

## Engineering Context

NovaStore uses GitHub Actions to build and test a React frontend and Java Spring Boot backend. The backend depends on PostgreSQL 17, provided as a CI service container.

## Problem and Impact

The pipeline encountered Docker Hub rate limiting while attempting to retrieve the PostgreSQL image.

This prevented reliable initialization of the test database, interrupting automated integration testing even though the failure was unrelated to application code.

## Root-Cause Investigation

The original GitHub Actions configuration referenced `postgres:17`.

Because this image reference defaults to Docker Hub, the CI runner depended on Docker Hub availability and pull limits.

The failure occurred while acquiring the service-container image, before the application integration tests could execute.

This distinguished a container registry dependency failure from a Spring Boot, PostgreSQL, or application-code failure.

## Engineering Decision

I evaluated the dependency at the registry layer rather than modifying application code or removing integration tests.

I changed the PostgreSQL image source to Amazon ECR Public while preserving PostgreSQL version 17.

This addressed the affected image-pull path without changing the intended database behavior.

## Resolution

Git commit `396162a` changed the service image from:

`postgres:17`

To:

`public.ecr.aws/docker/library/postgres:17`

The existing PostgreSQL environment configuration remained unchanged.

## Verification

The Git commit confirms the registry change. The broader GitHub Actions CI workflow subsequently completed successfully.

The result demonstrates successful CI execution using the revised dependency source, without claiming a measured reduction in registry outages.

## Prevention

- Identify external registries as CI infrastructure dependencies.
- Separate image-pull failures from application-test failures.
- Use approved image registries and consider authenticated pulls or registry mirrors.
- Pin image digests when stronger build reproducibility is required.
- Monitor recurring infrastructure failures independently from application defects.

## Supporting Evidence

- Git commit 396162a — historical private-repository commit `396162a` (not publicly accessible)
- [GitHub Actions workflow](../../.github/workflows/ci.yml)

## Scope

This documents a real CI troubleshooting exercise during NovaStore implementation, not a customer-facing production outage.
