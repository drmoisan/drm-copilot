# CI Baseline (P1-T1, P1-T2)

Timestamp: 2026-10-13T11-14
Command: gh workflow run ci.yml --ref bug/round-2-review-nits-and-evidence-timestamps-903; gh run watch 38386628228 --exit-status; gh run view 38386628228 --json jobs; gh run view 38386628228 --log --job 115259919229; gh run view 38386628228 --log --job 115259919252 (executed by the orchestrator; outputs saved to git-ignored artifacts/scratch-903/ci-baseline-run-903.json, ci-baseline-poshqc-log-903.txt, ci-baseline-poshqc-linux-log-903.txt and read by the executor)
EXIT_CODE: 0

- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/38386628228
- Event: workflow_dispatch of ci.yml on bug/round-2-review-nits-and-evidence-timestamps-903
- headSha: 95d6c9b22088b885225b63313b7bdb34968caa40
- PHASE0: 95d6c9b22088b885225b63313b7bdb34968caa40 (headSha equals PHASE0)
- Run conclusion: success (`gh run watch --exit-status` exit 0)

## Jobs (name | conclusion)

| Job | Conclusion |
|---|---|
| build-check / Build Package | success |
| security-scan / Security Scanning | success |
| docs-validation / Documentation Validation | success |
| quality-checks7 / Code Quality & Tests (3.10) | success |
| quality-checks7 / Code Quality & Tests (3.11) | success |
| quality-checks7 / Code Quality & Tests (3.12) | success |
| quality-checks7 / Code Quality & Tests (3.13) | success |
| poshqc / PowerShell QC | success |
| poshqc / PowerShell hook suites (Linux) | success |
| root-typescript-tests / Root TypeScript Tests (ubuntu-latest) | success |
| root-typescript-tests / Root TypeScript Tests (windows-latest) | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) | success |
| NPM Audit Gate / npm audit (packages/mcp-server) | success |
| NPM Audit Gate / npm audit (extensions/drm-copilot) | success |
| NPM Audit Gate / npm audit (.) | success |
| shell-coverage / Shell Coverage (Bats + kcov) | success |

All 17 jobs concluded success. No failing job or test is pre-existing.

## `poshqc / PowerShell QC` log lines (quoted, ANSI codes removed)

- `PSScriptAnalyzer passed: no findings under D:\a\drm-copilot\drm-copilot`
- `Tests Passed: 10244, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0`
- `Covered 89.52% / 0%. 26,265 analyzed Commands in 202 Files.`

## `poshqc / PowerShell hook suites (Linux)`

- Conclusion: success
- Log line: `Tests Passed: 6169, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`

Output Summary: CI run 38386628228 on PHASE0 head 95d6c9b22 concluded success with all 17 jobs success. Windows PowerShell QC: analyzer no findings, 10244 passed / 0 failed / 10 skipped, coverage 89.52%. Linux hook suites: success, 6169 passed / 0 failed.
