# ORCH-1 — Baseline CI values (D-BASE, D-JUNIT, D-COV), repeated after the origin/main merge

Timestamp: 2026-10-16T14-23
Command: git merge-base origin/main HEAD; gh run list --workflow ci.yml --branch main --event push --commit 5d2d9a9728b3763cb4398bdae1e54ef84ee98936 --status success --limit 1 --json databaseId,headSha; gh run download 38911869997 -n poshqc-test-results -D SCRATCH/issue-952-ci-38911869997/win; gh run download 38911869997 -n poshqc-linux-hook-test-results -D SCRATCH/issue-952-ci-38911869997/linux; D-JUNIT and D-COV computed over pester-junit.xml, pester-junit-linux-hooks.xml and powershell-coverage.xml
EXIT_CODE: 0
Output Summary:
B=5d2d9a9728b3763cb4398bdae1e54ef84ee98936
R_base=38911869997 (ci.yml, event push, branch main, headSha 5d2d9a9728b3763cb4398bdae1e54ef84ee98936, conclusion success, attempt 1)
PS_BASE_CLAUDE_GATE=99.29
PS_BASE_CODEX_GATE=88.41
PS_BASE_RELEASE=94.93

## Reason for repetition

This file supersedes `ci-baseline.2026-10-16T12-18.md` (B=5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea). During remediation cycle 1, issues #937 (PR #960) and #927 (PR #961) merged into `main`, and the orchestrator merged `origin/main` 5d2d9a972 into this branch (merge commit f03bc9b7258362900969778c504561bc7c3eca5c; conflicts in both epic merge gates resolved by keeping both sides). D-BASE primary rule applied: run 38911869997 is the successful push run of ci.yml on main at the new B. All Passed counts equal the superseded file; the two gate coverage values changed with #927.

## Windows Passed counts (job poshqc / PowerShell QC, pester-junit.xml)

| Suite | Passed | Failure/error | Skipped |
|---|---|---|---|
| tests/scripts/workflows/CiWorkflow.Tests.ps1 | 2 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | 57 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | 16 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 | 37 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | 2 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | 20 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | 13 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | 11 | 0 | 0 |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | 29 | 0 | 0 |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | 14 | 0 | 0 |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | 8 | 0 | 0 |
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | 17 | 0 | 0 |
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 | 23 | 0 | 0 |
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1 | 22 | 0 | 0 |
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 | 11 | 0 | 0 |
| tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1 | 2 | 0 | 0 |
| tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | 35 | 0 | 0 |

## Linux Passed counts (job poshqc / PowerShell hook suites (Linux), pester-junit-linux-hooks.xml)

| Suite | Passed | Failure/error | Skipped |
|---|---|---|---|
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | 57 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | 16 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 | 37 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | 2 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | 20 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | 13 | 0 | 0 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | 11 | 0 | 0 |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | 29 | 0 | 0 |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | 14 | 0 | 0 |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | 8 | 0 | 0 |

## Per-file line coverage (D-COV, powershell-coverage.xml, job poshqc / PowerShell QC)

| Production path | Line % | Covered | Missed |
|---|---|---|---|
| .claude/hooks/enforce-epic-merge-gate.ps1 (PS_BASE_CLAUDE_GATE) | 99.29 | 139 | 1 |
| .codex/hooks/enforce-epic-merge-gate.ps1 (PS_BASE_CODEX_GATE) | 88.41 | 145 | 19 |
| scripts/dev-tools/Invoke-FullReleaseFlow.ps1 (PS_BASE_RELEASE) | 94.93 | 131 | 7 |
| scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1 | 100.00 | 30 | 0 |

Each coverage path matched exactly one `sourcefile` entry. Downloads are under the scratch token `SCRATCH/issue-952-ci-38911869997/` and are not committed.
