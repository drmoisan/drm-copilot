# CI baseline run (P0-T12)

Timestamp: 2026-10-16T01-32
Command: CI job poshqc / PowerShell hook suites (Linux) (Invoke-Pester), run https://github.com/drmoisan/drm-copilot/actions/runs/38833589314
EXIT_CODE: 0
Output Summary: Job `poshqc / PowerShell hook suites (Linux)` concluded success on headSha 2fe0469956f4a3ce916e31350d5090bd1097b9d6. Run conclusion success. Baseline JUnit failed set is empty (COUNT_FAILED=0 of 6289 testcases).

## Run

- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/38833589314
- databaseId: 38833589314
- headSha: 2fe0469956f4a3ce916e31350d5090bd1097b9d6
- P0-T11 commit (`git rev-parse HEAD` reported at handoff and re-checked): 2fe0469956f4a3ce916e31350d5090bd1097b9d6 (match)
- status: completed
- Run conclusion: success
- Source: SCRATCH/ci-baseline-run.json (saved by the orchestrator; event workflow_dispatch)

## Jobs (name | conclusion)

| Job | Conclusion |
|---|---|
| drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) | success |
| root-typescript-tests / Root TypeScript Tests (ubuntu-latest) | success |
| quality-checks7 / Code Quality & Tests (3.11) | success |
| quality-checks7 / Code Quality & Tests (3.12) | success |
| poshqc / PowerShell hook suites (Linux) | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) | success |
| NPM Audit Gate / npm audit (packages/mcp-server) | success |
| docs-validation / Documentation Validation | success |
| shell-coverage / Shell Coverage (Bats + kcov) | success |
| NPM Audit Gate / npm audit (extensions/drm-copilot) | success |
| root-typescript-tests / Root TypeScript Tests (windows-latest) | success |
| build-check / Build Package | success |
| poshqc / PowerShell QC | success |
| quality-checks7 / Code Quality & Tests (3.13) | success |
| security-scan / Security Scanning | success |
| NPM Audit Gate / npm audit (.) | success |
| quality-checks7 / Code Quality & Tests (3.10) | success |

## JUnit failed set

Command: poetry run python -I SCRATCH/junit_status.py SCRATCH/ci-baseline-linux/pester-junit-linux-hooks.xml
EXIT_CODE: 0

Printed output (verbatim; no FAILED or MESSAGE lines were printed):

```
COUNT_MATCHED=6289
COUNT_PASSED=6289
COUNT_FAILED=0
COUNT_SKIPPED=0
```

Baseline failed set: empty (COUNT_FAILED=0). Nothing is carried into P1-T13 or P3-T10 as pre-existing.
