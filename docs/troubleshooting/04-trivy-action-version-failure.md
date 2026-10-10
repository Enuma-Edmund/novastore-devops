# Case Study 04 — CI Security Scanning: Invalid GitHub Action References

## Engineering Context

NovaStore uses GitHub Actions to build and test its application, create a Docker image, and scan that image with Trivy before proceeding through the delivery workflow.

A reliable security gate must initialize correctly before it can evaluate the image.

## Problem and Engineering Impact

The Trivy scanning step encountered an action-version configuration issue.

This affected CI reliability because the pipeline could not dependably execute its container vulnerability assessment.

The engineering challenge was to distinguish a workflow dependency problem from an actual vulnerability finding.

## Investigation and Root-Cause Analysis

The investigation focused on the GitHub Actions `uses` reference for the Trivy integration.

GitHub Actions resolves an action by its repository and specified Git reference. If the referenced release tag or commit cannot be resolved, the action cannot initialize.

The recorded changes were:

- Initial reference: aquasecurity/trivy-action@0.33.1
- First correction: aquasecurity/trivy-action@0.33.0
- Final correction: aquasecurity/trivy-action@v0.35.0

Commits 8d00779 and 3b26bd2 establish this progression.

The root-cause category was action dependency version resolution, rather than the application image or its vulnerability scan results.

## Engineering Decision

The appropriate fix was to correct the action reference instead of disabling Trivy or bypassing the security stage.

The final configuration used a verified release tag.

For more tightly controlled environments, pinning GitHub Actions to reviewed commit SHAs provides stronger protection against unexpected changes to release references.

## Resolution

Updated the GitHub Actions workflow to use:

aquasecurity/trivy-action@v0.35.0

The existing Docker image build and scanning workflow remained in place.

## Verification

The repository history confirms the action-reference corrections.

The broader NovaStore GitHub Actions CI workflow subsequently completed successfully with its integrated security checks.

This establishes successful workflow execution after the changes without claiming a specific error message not preserved in the commit evidence.

## Prevention and Engineering Lessons

- Verify third-party action tags before adding them to CI workflows.
- Separate action initialization failures from security findings.
- Do not bypass security gates to resolve dependency configuration errors.
- Pin reviewed action versions or commit SHAs according to supply-chain requirements.
- Validate the complete workflow after changing security tooling.
- Keep CI dependencies under version control and review.

## Supporting Evidence

- First correction — historical private-repository commit `8d00779` (not publicly accessible)
- Verified release tag — historical private-repository commit `3b26bd2` (not publicly accessible)
- [GitHub Actions workflow](../../.github/workflows/ci.yml)

## Scope

This case documents CI security-tool integration troubleshooting during NovaStore implementation, not a customer-facing production outage.
