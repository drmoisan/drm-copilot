# ORCH-3 — Pull-request CI conclusions (AC-28) and PR-head coverage (AC-27)

Timestamp: 2026-10-16T23-32
Command: gh pr checks 965; gh pr view 965 --json headRefOid,statusCheckRollup; gh run view 38980256384 --json jobs,headSha,conclusion,event; gh run download 38980256384 -n poshqc-test-results -D SCRATCH/issue-952-ci-38980256384/win; gh run download 38979803405 -n poshqc-test-results -D SCRATCH/issue-952-ci-38979803405/win (main at 475bb06d5, profiler-mode baseline); D-COV and D-CHANGED (git diff -U0 475bb06d5c6caeb3e68b13f847a4097dc026fa89 ea9b652a2391936a4123c68ae250397b4c6c62a5)
EXIT_CODE: 0
Output Summary:
PR #965 head ea9b652a2391936a4123c68ae250397b4c6c62a5; R_pr=38980256384 (ci.yml, event pull_request) conclusion success
statusCheckRollup: 24 checks, 24 SUCCESS, 0 pending, 0 failing
Required contexts of the ruleset snapshot (11): all present and success
AC-28: PASS
Coverage (profiler mode, issue #953 merged): POWERSHELL: PASS; .codex/hooks/enforce-epic-merge-gate-command.ps1 100.00 (54/54) in the full run
AC-27: PASS as written; the R1 amendment (evidence/other/r1-decision.2026-10-16T23-10.md) no longer applies
REPO_PS_LINE=92.16 (main 475bb06d5 run 38979803405)

## Required contexts (protect-main.current.2026-10-16.json)

| Context | Result |
|---|---|
| drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) | pass |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) | pass |
| docs-validation / Documentation Validation | pass |
| poshqc / PowerShell QC | pass |
| shell-coverage / Shell Coverage (Bats + kcov) | pass |
| security-scan / Security Scanning | pass |
| quality-checks7 / Code Quality & Tests (3.10) | pass |
| quality-checks7 / Code Quality & Tests (3.11) | pass |
| quality-checks7 / Code Quality & Tests (3.12) | pass |
| quality-checks7 / Code Quality & Tests (3.13) | pass |
| build-check / Build Package | pass |

## PR-head coverage (job poshqc / PowerShell QC, merged shard coverage)

Baselines are from main at 475bb06d5 (run 38979803405), which uses the same profiler-mode measurement (issue #953); the earlier breakpoint-mode baselines are not comparable.

| Production path | Baseline | Post % | Changed exec lines | Covered changed | Changed-line % | Result |
|---|---|---|---|---|---|---|
| .claude/hooks/enforce-epic-merge-gate.ps1 | 99.29 | 100.00 | 4 | 4 | 100.00 | PASS |
| .claude/hooks/enforce-epic-merge-gate-command.ps1 | NEW | 100.00 | 54 | 54 | 100.00 | PASS |
| .codex/hooks/enforce-epic-merge-gate.ps1 | 98.78 | 99.35 | 4 | 4 | 100.00 | PASS |
| .codex/hooks/enforce-epic-merge-gate-command.ps1 | NEW | 100.00 | 54 | 54 | 100.00 | PASS |
| .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 | NEW | 100.00 | 48 | 48 | 100.00 | PASS |
| scripts/dev-tools/Invoke-FullReleaseFlow.ps1 | 94.20 | 94.37 | 5 | 5 | 100.00 | PASS |
| scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1 | NEW | 100.00 | 23 | 23 | 100.00 | PASS |
| .claude/hooks/hook-docs-only-diff.ps1 | 97.60 | 97.64 | 2 | 2 | 100.00 | PASS |
| .codex/hooks/hook-docs-only-diff.ps1 | 97.60 | 97.64 | 2 | 2 | 100.00 | PASS |

The Codex helper is credited at 100.00% in the full run under profiler-mode coverage, confirming that the earlier 74.07% was the issue #936 breakpoint attribution effect.
