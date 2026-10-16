# ORCH-4 — Windows per-suite results on R_final (AC-1, AC-2, AC-5 to AC-15)

Timestamp: 2026-10-16T12-40
Command: git fetch origin; git rev-parse origin/bug/ci-merge-queue-for-main-952; gh workflow run ci.yml --ref bug/ci-merge-queue-for-main-952; gh run list --workflow ci.yml --branch bug/ci-merge-queue-for-main-952 --event workflow_dispatch --commit d039138bad7010475997c09aea1b55b64e0ca9b5 --limit 1 --json databaseId,headSha,status,conclusion; gh run watch 38899600487 --exit-status; gh run view 38899600487 --json jobs,headSha,conclusion,event; gh run download 38899600487 -n poshqc-test-results -D SCRATCH/issue-952-ci-38899600487/win; D-JUNIT over pester-junit.xml
EXIT_CODE: 0
Output Summary:
H_final=d039138bad7010475997c09aea1b55b64e0ca9b5
R_final=38899600487 event=workflow_dispatch headSha=d039138bad7010475997c09aea1b55b64e0ca9b5 conclusion=success (registered on the first gh run list attempt)
Jobs: 17 of 17 success, including poshqc / PowerShell QC = success and poshqc / PowerShell hook suites (Linux) = success
Every listed suite: 0 testcases with a failure or error child; all Passed counts equal their expected values; all six named rows (seven evaluations) PASS
VERDICT: ORCH-4 PASS

## R_final jobs

root-typescript-tests (windows-latest, ubuntu-latest), quality-checks7 (3.10, 3.11, 3.12, 3.13), drm-copilot-extension-tests (windows-latest, ubuntu-latest), NPM Audit Gate (., packages/mcp-server, extensions/drm-copilot), poshqc / PowerShell QC, poshqc / PowerShell hook suites (Linux), build-check, docs-validation, shell-coverage, security-scan: all `success`.

## Passed counts (Windows file, job poshqc / PowerShell QC)

ORCH-1 values are from `ci-baseline.2026-10-16T12-18.md` (B=5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea, R_base 38885440106).

| Suite | Passed | Fail/error | Expected | Result |
|---|---|---|---|---|
| tests/scripts/workflows/CiWorkflow.Tests.ps1 | 4 | 0 | ORCH-1 2 + 2 = 4 | PASS |
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
| tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 | 36 | 0 | 36 | PASS |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 | 34 | 0 | 34 | PASS |
| tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 | 13 | 0 | 13 | PASS |
| tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1 | 2 | 0 | 2 | PASS |
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1 | 12 | 0 | 12 | PASS |
| tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | 598 | 0 | at least 1, none failing | PASS |
| tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | 12 | 0 | at least 1, none failing | PASS |
| tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | 43 | 0 | at least 1, none failing | PASS |

## Named rows (each evaluated only within its paired suite)

| Row | Suite | Matches | Not passed | Result |
|---|---|---|---|---|
| (a) declares merge_group with types checks_requested and no branch or path filter (AC-1) | tests/scripts/workflows/CiWorkflow.Tests.ps1 | 1 | 0 | PASS |
| (b) reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph (AC-2) | tests/scripts/workflows/CiWorkflow.Tests.ps1 | 1 | 0 | PASS |
| (c) denies gh pr merge --squash without a checkpoint (issue #952 method-agnostic scope) (AC-10) | tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | 1 | 0 | PASS |
| (d) denies a bare gh pr merge --squash with the method-agnostic message (AC-11) | tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 | 1 | 0 | PASS |
| (d) denies a bare gh pr merge --squash with the method-agnostic message (AC-11) | tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 | 1 | 0 | PASS |
| (e) keeps the existing fall-through text for a bare merge even with a valid record present (AC-10, AC-11) | tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | 1 | 0 | PASS |
| (f) keeps the existing deny text for a bare merge even with a valid record present (AC-10, AC-11) | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | 1 | 0 | PASS |

Downloads are under the scratch token `SCRATCH/issue-952-ci-38899600487/` and are not committed.
