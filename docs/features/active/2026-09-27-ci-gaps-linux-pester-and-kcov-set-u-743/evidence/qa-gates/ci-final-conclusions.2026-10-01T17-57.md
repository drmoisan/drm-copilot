# Final Check Conclusions (P7-T17)

Timestamp: 2026-10-01T17-57
RUN_ID: 36901896617 (https://github.com/drmoisan/drm-copilot/actions/runs/36901896617)
CI_SHA: ecba8829604f6265dc491c74cf42546f9d5aab57

Command: gh run view 36901896617 --json jobs,headSha
EXIT_CODE: 0
Output Summary: `headSha` ecba8829604f6265dc491c74cf42546f9d5aab57, equal to CI_SHA and to the P7-T15 remote head. Run conclusion `failure`, caused only by `poshqc / PowerShell hook suites (Linux)`.

Asserted jobs:

| Job | databaseId | Conclusion | AC |
| --- | --- | --- | --- |
| poshqc / PowerShell hook suites (Linux) | 110502826491 | failure | AC-6 (not met; every failed test is in a file marked REMEDIATION-REQUIRED by P5-T7) |
| poshqc / PowerShell QC | 110502826187 | success | AC-7 |
| shell-coverage / Shell Coverage (Bats + kcov) | 110502826537 | success | AC-16 |

Recorded, not asserted (jobs owned by other items):

| Job | databaseId | Conclusion |
| --- | --- | --- |
| security-scan / Security Scanning | 110502826116 | success |
| root-typescript-tests / Root TypeScript Tests (windows-latest) | 110502826222 | success |
| root-typescript-tests / Root TypeScript Tests (ubuntu-latest) | 110502826453 | success |
| quality-checks7 / Code Quality & Tests (3.10) | 110502826246 | success |
| quality-checks7 / Code Quality & Tests (3.11) | 110502826388 | success |
| quality-checks7 / Code Quality & Tests (3.12) | 110502826383 | success |
| quality-checks7 / Code Quality & Tests (3.13) | 110502826552 | success |
| build-check / Build Package | 110502826265 | success |
| docs-validation / Documentation Validation | 110502826298 | success |
| NPM Audit Gate / npm audit (extensions/drm-copilot) | 110502826338 | success |
| NPM Audit Gate / npm audit (packages/mcp-server) | 110502826456 | success |
| NPM Audit Gate / npm audit (.) | 110502826507 | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) | 110502826467 | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) | 110502826517 | success |

`poshqc / PowerShell QC` steps: `Format PowerShell` success, `Analyze PowerShell` success, `Test PowerShell` success, `Upload PowerShell test artifacts` success. In a called workflow the log labels every step `UNKNOWN STEP`, so the format counts are taken over the whole job: 596 `Already formatted:` lines (baseline job total 595, of which 2 come from tests; the new `PoshQcWorkflow.Tests.ps1` adds one) and one `Formatted:` line, `Formatted: /repo/test.ps1`, which a test prints and which also appears in the baseline. The format step therefore reformatted nothing (D2 corroboration for P7-T1). The Analyze step printed `PSScriptAnalyzer passed: no findings under <RUNNER_ROOT>` (D3 finding set for P7-T2: empty).

P7-T10 did not record KNOWN-ISSUE-510, so `ci-final-parity-pytest.*.md` is not required.
