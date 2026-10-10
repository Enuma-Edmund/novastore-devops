# Case Study 01 — Java Dependency and Container Security Remediation

## Engineering Context

NovaStore uses Java 17, Spring Boot, PostgreSQL, and Docker. Its delivery workflows include automated builds, testing, and security scanning.

The engineering objective was to remediate identified vulnerabilities while preserving application functionality and container security.

## Problem and Risk

Security findings affected the Java dependency stack and container image.

The release risk was twofold:

- Known vulnerabilities could remain in the deployable artifact.
- Upgrading frameworks or replacing the runtime image could introduce compatibility or startup failures.

A successful security fix therefore required both vulnerability remediation and application regression testing.

## Investigation

The remediation separated two areas of responsibility:

**Application dependency layer:** Spring Boot and its managed libraries, including the embedded web server and JSON-processing dependencies.

**Container runtime layer:** The Java runtime base image, operating-system packages, and non-root execution configuration.

These layers require different remediation approaches. Replacing a container image alone does not necessarily fix vulnerable Java libraries.

## Root Cause and Engineering Changes

Commit `059e7ef` records the following changes:

| Component | Before | After |
|---|---|---|
| Runtime image | `eclipse-temurin:17-jre` | `amazoncorretto:17-alpine` |
| Spring Boot | `3.5.14` | `4.1.1` |
| Jackson BOM | Previously managed version | `3.1.7` |
| Tomcat | Previously managed version | `11.0.25` |
| Runtime user creation | `useradd --system --uid 1001` | `adduser -D -u 1001` |
| Web dependency | `spring-boot-starter-web` | `spring-boot-starter-webmvc` |
| Test dependency | `spring-boot-starter-test` | `spring-boot-starter-webmvc-test` |

The base-image change also required adapting the Dockerfile's user-creation command to Alpine Linux.

The application continued to run under a non-root user rather than weakening container privileges to resolve compatibility issues.

The Spring Boot upgrade required updating the web and test starters to match the newer framework structure.

## Engineering Decisions

1. Address the Java dependency and container operating-system layers separately.
2. Preserve Java 17 compatibility while upgrading the framework.
3. Retain non-root execution after changing the base image.
4. Validate application behavior after security remediation.
5. Distinguish scanner execution from actual release-blocking enforcement.

## Verification

The project validation established:

- Successful Java application build and tests.
- Successful frontend lint and build.
- Working PostgreSQL integration and product retrieval.
- Successful containerized application execution.
- Zero HIGH and CRITICAL findings in the final local Trivy image scan.
- Successful GitHub Actions CI execution.

The GitHub Actions workflow blocks CRITICAL Trivy findings. Checkov currently runs in reporting mode with `soft_fail: true`.

These policies should not be confused with a claim that every security finding blocks deployment.

## Prevention and Operational Lessons

- Maintain visibility into both application and operating-system vulnerabilities.
- Rebuild and rescan images after dependency changes.
- Preserve least-privilege container execution.
- Treat framework upgrades as compatibility changes requiring regression tests.
- Use version-controlled CI security controls.
- Review security-gate thresholds according to release risk.

## Supporting Evidence

- Remediation commit — historical private-repository commit `059e7ef` (not publicly accessible)
- [Dockerfile](../../app/Dockerfile)
- [Maven configuration](../../app/pom.xml)
- [GitHub Actions CI](../../.github/workflows/ci.yml)
- [Jenkinsfile](../../Jenkinsfile)

## Scope

This documents security remediation and validation performed during the NovaStore engineering project. It is not presented as a customer-facing production incident.
