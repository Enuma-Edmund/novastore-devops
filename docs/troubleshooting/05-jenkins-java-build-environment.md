# Case Study 05 — Jenkins Java Build Environment Failure

## Engineering Context

NovaStore uses Jenkins on an AWS EC2 instance to automate Java application testing, packaging, Docker image creation, and publishing to Amazon ECR.

Terraform provisions the Jenkins infrastructure, while an EC2 user-data script installs the required build tools.

## Problem and Engineering Impact

The Jenkins build environment was initially provisioned with the Java Runtime Environment (JRE) instead of the Java Development Kit (JDK).

The pipeline included Maven test and packaging stages that required Java compilation capabilities.

This created a build-environment dependency problem that could prevent the pipeline from progressing to container creation and image publishing.

## Investigation

The Jenkinsfile defined these build commands:

- `mvn test`
- `mvn clean package`

The investigation identified the Java installation in the Terraform-managed Jenkins bootstrap script.

The original configuration installed:

`openjdk-21-jre`

This package provides Java runtime capabilities but not the complete Java development toolchain required for source compilation.

## Root Cause

The Jenkins server was configured to run Java applications but was not fully equipped to compile them.

The missing development toolchain was an infrastructure configuration issue rather than an application source-code defect.

## Engineering Resolution

Updated the Jenkins EC2 bootstrap script from:

`openjdk-21-jre`

to:

`openjdk-21-jdk`

The JDK provides the Java compiler and development utilities required by Maven build workflows.

The correction was recorded in Git commit `28eccbe`.

## Verification and Evidence

The Git commit confirms the infrastructure configuration correction.

The Jenkinsfile confirms that the pipeline invokes Maven test and packaging commands.

The available commit evidence does not include the original Jenkins console error or a post-change successful pipeline execution log.

A complete runtime verification would check:

- `java -version`
- `javac -version`
- `mvn -version`
- Successful Jenkins Test and Package stages

## Prevention

- Define build-tool requirements before provisioning CI agents.
- Install a JDK rather than only a JRE when Java compilation is required.
- Validate Java and Maven versions during agent initialization.
- Keep CI agent configuration under version control.
- Use repeatable Terraform and bootstrap configuration to reduce environment drift.
- Confirm toolchain compatibility with the application's Java version.

## Engineering Lesson

An environment that can run a Java application is not necessarily equipped to build one.

Troubleshooting should distinguish missing CI infrastructure dependencies from application defects before changing source code.

## Supporting Evidence

- Jenkins Java environment fix — historical private-repository commit `28eccbe` (not publicly accessible)
- [Jenkins bootstrap script](../../terraform/modules/jenkins/user-data.sh)
- [Jenkins pipeline](../../Jenkinsfile)

## Scope

This case documents a Jenkins build-environment correction during NovaStore engineering implementation, not a customer-facing production outage.
