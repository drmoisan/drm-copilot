# Final QA pass 2: workflow lint (P6-T3, AC-25)

Timestamp: 2026-10-17T00-15
Command: sh SCRATCH/tools/run-cr.sh cr-actionlint -PathList ".github/workflows/ci.yml,.github/workflows/_quality-checks.yml,.github/workflows/_security-scan.yml,.github/workflows/_build-check.yml,.github/workflows/_shell-coverage.yml,.github/workflows/_drm-copilot-extension-tests.yml,.github/workflows/_poshqc.yml"
EXIT_CODE: 0
Output Summary: scripts/dev-tools/run-actionlint.ps1 (wrapper) and actionlint 1.7.11 (direct) both exit 0 with ACTIONLINT-FINDINGS: 0 for all seven workflow files changed by this branch, on the re-integrated head. EXIT_CODE_COMPUTED: 0.

## Output

```
RUN-CR: cr-actionlint
Running actionlint...
ACTIONLINT-WRAPPER-EXIT: 0
ACTIONLINT-VERSION: 1.7.11
ACTIONLINT-DIRECT-EXIT: 0
ACTIONLINT-FINDINGS: 0
EXIT_CODE_COMPUTED: 0
```
