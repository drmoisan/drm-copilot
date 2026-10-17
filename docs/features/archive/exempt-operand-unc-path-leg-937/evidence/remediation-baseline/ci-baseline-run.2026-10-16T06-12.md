# CI Remediation Baseline Run, Cycle 1 (issue #937)

Timestamp: 2026-10-16T06-12
Command: CI job poshqc / PowerShell hook suites (Linux) (Invoke-Pester), run https://github.com/drmoisan/drm-copilot/actions/runs/38858408695
EXIT_CODE: 0
Output Summary: Run 38858408695 (workflow_dispatch, ci.yml) on headSha 879764889bec9244657f348c17a23d34218f0401 (equals the P0-T15 commit and the reported HEAD) concluded success; all 17 jobs concluded success, including poshqc / PowerShell QC and poshqc / PowerShell hook suites (Linux). Linux hook-suite JUnit: TESTCASES=6335, COUNT_FAILED=0, COUNT_SKIPPED=0. Baseline failed set: empty.

Task: P0-T16 (remediation-plan.2026-10-16T03-39.md), stage `c1baseline`. The `gh` steps were run by the orchestrator (handoff); the run JSON was saved as `SCRATCH/ci-c1baseline-run.json` and the artifacts were downloaded to `SCRATCH/ci-c1baseline-linux` and `SCRATCH/ci-c1baseline-windows`.

## Run identity (from SCRATCH/ci-c1baseline-run.json)

- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/38858408695
- databaseId: 38858408695
- headSha: 879764889bec9244657f348c17a23d34218f0401
- Reported HEAD (`git rev-parse HEAD` at handoff): 879764889bec9244657f348c17a23d34218f0401 (match)
- status: completed
- conclusion: success

## Jobs

| Job | Conclusion |
|---|---|
| security-scan / Security Scanning | success |
| poshqc / PowerShell QC | success |
| docs-validation / Documentation Validation | success |
| build-check / Build Package | success |
| quality-checks7 / Code Quality & Tests (3.13) | success |
| quality-checks7 / Code Quality & Tests (3.10) | success |
| poshqc / PowerShell hook suites (Linux) | success |
| root-typescript-tests / Root TypeScript Tests (windows-latest) | success |
| shell-coverage / Shell Coverage (Bats + kcov) | success |
| NPM Audit Gate / npm audit (packages/mcp-server) | success |
| NPM Audit Gate / npm audit (.) | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) | success |
| quality-checks7 / Code Quality & Tests (3.12) | success |
| NPM Audit Gate / npm audit (extensions/drm-copilot) | success |
| quality-checks7 / Code Quality & Tests (3.11) | success |
| root-typescript-tests / Root TypeScript Tests (ubuntu-latest) | success |

## Command: poetry run python -I SCRATCH/junit_status.py SCRATCH/ci-c1baseline-linux/pester-junit-linux-hooks.xml

EXIT_CODE: 0

```text
COUNT_MATCHED=6335
COUNT_PASSED=6335
COUNT_FAILED=0
COUNT_SKIPPED=0
```

No `FAILED` or `MESSAGE` lines were printed.

## Command: poetry run python -I SCRATCH/junit_totals.py SCRATCH/ci-c1baseline-linux/pester-junit-linux-hooks.xml

EXIT_CODE: 0

```text
ROOT_TAG=testsuites
ROOT_TESTS=6335
ROOT_FAILURES=0
ROOT_ERRORS=0
TESTCASES=6335
FAILED=0
SKIPPED=0
```

## Baseline values carried forward

- Baseline failed set (for P1-T18 and P3-T11): empty. COUNT_FAILED=0.
- Linux TESTCASES (for P3-T6): 6335.
- Jobs not concluding success at the c1 baseline (for P3-T11): none.
