# ORCH-R1 — Windows per-suite results on R_final_3 (remediation cycle 2)

Timestamp: 2026-10-16T21-28
Command: git fetch origin; git rev-parse origin/bug/ci-merge-queue-for-main-952; gh workflow run ci.yml --ref bug/ci-merge-queue-for-main-952; gh run watch 38967059138; gh run view 38967059138 --json jobs,headSha,conclusion,event; gh run download 38967059138 -n poshqc-test-results -D SCRATCH/issue-952-ci-38967059138/win; gh run download 38933561015 -n poshqc-test-results -D SCRATCH/issue-952-ci-38933561015/win (base counts); D-JUNIT over pester-junit.xml
EXIT_CODE: 0
Output Summary:
H_final_3=11242f03aae9b839a2a7b5d2bca37fb90594850f
R_final_3=38967059138 event=workflow_dispatch headSha=11242f03aae9b839a2a7b5d2bca37fb90594850f conclusion=success; jobs 17 of 17 success (poshqc / PowerShell QC and poshqc / PowerShell hook suites (Linux) success)
MERGE_EXEMPTION_BASE=43 CODEX_DOCSONLY_DIFF_BASE=39 (R_final_2 38933561015 Windows file; equal to the planner static counts)
Every listed suite: 0 testcases with a failure or error child; every Passed count equals its expected value; named rows (a) to (q) PASS
H2=REJECTED
MAPPED_ROW_SUITES=PASS (command 15, merge-queue 35, trigger-scoping 8, zero failures)
WINDOWS_ARTIFACT=PRESENT
VERDICT: ORCH-R1 PASS

## Passed counts (Windows file, job poshqc / PowerShell QC)

| Suite | Passed | Fail/error | Expected | Result |
|---|---|---|---|---|
| tests/scripts/workflows/CiWorkflow.Tests.ps1 | 4 | 0 | 4 | PASS |
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
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | 17 | 0 | 17 | PASS |
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 | 23 | 0 | 23 | PASS |
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1 | 22 | 0 | 22 | PASS |
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 | 11 | 0 | 11 | PASS |
| tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1 | 2 | 0 | 2 | PASS |
| tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | 35 | 0 | 35 | PASS |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 | 40 | 0 | 40 | PASS |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 | 35 | 0 | 35 | PASS |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | 15 | 0 | 15 | PASS |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 | 15 | 0 | 15 (14 + N2) | PASS |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 | 10 | 0 | 10 (9 + N3) | PASS |
| tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 | 44 | 0 | 44 (43 + N1) | PASS |
| tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 | 40 | 0 | 40 (39 + N4) | PASS |
| tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 | 17 | 0 | 17 | PASS |
| tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1 | 2 | 0 | 2 | PASS |
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1 | 12 | 0 | 12 | PASS |
| tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | 598 | 0 | at least 1, none failing | PASS |
| tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | 12 | 0 | at least 1, none failing | PASS |
| tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | 43 | 0 | at least 1, none failing | PASS |

## Named rows (each evaluated only within its paired suite)

| Row | Suite | Matches | Not passed | Result |
|---|---|---|---|---|
| (a) declares merge_group with types checks_requested and no branch or path filter | tests/scripts/workflows/CiWorkflow.Tests.ps1 | 1 | 0 | PASS |
| (b) reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph | tests/scripts/workflows/CiWorkflow.Tests.ps1 | 1 | 0 | PASS |
| (c) denies gh pr merge --squash without a checkpoint (issue #952 method-agnostic scope) | tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | 1 | 0 | PASS |
| (d) denies a bare gh pr merge --squash with the method-agnostic message | tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 | 1 | 0 | PASS |
| (d) denies a bare gh pr merge --squash with the method-agnostic message | tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 | 1 | 0 | PASS |
| (e) keeps the existing fall-through text for a bare merge even with a valid record present | tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | 1 | 0 | PASS |
| (f) keeps the existing deny text for a bare merge even with a valid record present | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | 1 | 0 | PASS |
| (g) resolves the selector helper functions from the Codex helper file | tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 | 1 | 0 | PASS |
| (h) returns 5 for gh pr merge --merge=true 5 | tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 | 1 | 0 | PASS |
| (h) returns 5 for gh pr merge --merge=true 5 | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | 1 | 0 | PASS |
| (i) maps MERGED with a null mergedAt to merged with an empty merge time | tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 | 1 | 0 | PASS |
| (j) converts https://github.com/o/r/pull/5 to 5 | tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | 1 | 0 | PASS |
| (k) makes no docs-only call for a bare merge and keeps its exact deny text (issue #927) | tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 | 1 | 0 | PASS |
| (l) keeps the bare-merge deny text unchanged (codex, issue #927) | tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 | 1 | 0 | PASS |
| (m) N1 denies a pull-request URL selector before any process (issue #952) | tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 | 1 | 0 | PASS |
| (n) N2 denies a pull-request URL selector with the PR_UNRESOLVED docs-only reason and no process call (issue #952) | tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 | 1 | 0 | PASS |
| (o) N3 denies a pull-request URL selector with PR_UNRESOLVED and no process call (codex, issue #952) | tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 | 1 | 0 | PASS |
| (p) N4 a pull-request URL selector | tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 | 1 | 0 | PASS |
| (q) is byte-identical across all four copies (issue #927) | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | 1 | 0 | PASS |

Downloads are under the scratch token `SCRATCH/issue-952-ci-38967059138/` and are not committed.
