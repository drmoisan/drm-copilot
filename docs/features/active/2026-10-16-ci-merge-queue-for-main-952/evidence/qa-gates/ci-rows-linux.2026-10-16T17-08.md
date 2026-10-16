# ORCH-R2 — Linux per-suite results on R_final_2 (remediation cycle 1)

Timestamp: 2026-10-16T17-08
Command: gh run download 38933561015 -n poshqc-linux-hook-test-results -D SCRATCH/issue-952-ci-38933561015/linux; D-JUNIT over pester-junit-linux-hooks.xml
EXIT_CODE: 0
Output Summary:
R_final_2=38933561015 (headSha fd1913a0d1d555959edca41289fc38ace1c5d439); job poshqc / PowerShell hook suites (Linux) = success
Every listed claude-hooks and codex-hooks suite: 0 failing or erroring testcases and the expected Passed count
VERDICT: ORCH-R2 PASS (no coverage claim)

| Suite | Passed | Fail/error | Expected | Result |
|---|---|---|---|---|
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | 57 | 0 | 57 | PASS |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | 16 | 0 | 16 | PASS |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 | 37 | 0 | 37 | PASS |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | 2 | 0 | 2 | PASS |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | 20 | 0 | 20 | PASS |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | 13 | 0 | 13 | PASS |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | 11 | 0 | 11 | PASS |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | 29 | 0 | 29 | PASS |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | 14 | 0 | 14 | PASS |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | 8 | 0 | 8 | PASS |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 | 40 | 0 | 40 | PASS |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 | 35 | 0 | 35 | PASS |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | 15 | 0 | 15 | PASS |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 | 14 | 0 | 14 | PASS |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 | 9 | 0 | 9 | PASS |

Rows (g), (h), (j), (k) and (l) pass in their paired suites on Linux as well.
