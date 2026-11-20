# ORCH-R2 — Linux per-suite results on R_final_3 (remediation cycle 2)

Timestamp: 2026-10-16T21-28
Command: gh run download 38967059138 -n poshqc-linux-hook-test-results -D SCRATCH/issue-952-ci-38967059138/linux; D-JUNIT over pester-junit-linux-hooks.xml
EXIT_CODE: 0
Output Summary:
R_final_3=38967059138 (headSha 11242f03aae9b839a2a7b5d2bca37fb90594850f); job poshqc / PowerShell hook suites (Linux) = success
Every listed claude-hooks and codex-hooks suite: 0 failing or erroring testcases and the expected Passed count; rows (g), (h), (j), (k), (l), (m), (n), (o), (p) and (q) PASS in their paired suites
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
| tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 | 15 | 0 | 15 | PASS |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 | 10 | 0 | 10 | PASS |
| tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 | 44 | 0 | 44 | PASS |
| tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 | 40 | 0 | 40 | PASS |
| tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | 30 | 0 | at least 1, none failing | PASS |

ORCH-R1 and ORCH-R2 both pass on R_final_3, so AC-1, AC-2 and AC-5 to AC-15 are checked off in `spec.md` with this artifact.
