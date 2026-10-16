# ORCH-1 — Baseline CI values (D-BASE, D-JUNIT, D-COV), repeated after the origin/main merge

Timestamp: 2026-10-16T09-57
Command: git merge-base origin/main HEAD; gh run list --workflow ci.yml --branch main --event push --commit 04f594f2ad2b891cbd8d1388a2e7fe2c67044d28 --status success --limit 1 --json databaseId,headSha; gh run download 38881687469 -n poshqc-test-results -D SCRATCH/issue-952-ci-38881687469/win; gh run download 38881687469 -n poshqc-linux-hook-test-results -D SCRATCH/issue-952-ci-38881687469/linux; D-JUNIT and D-COV computed over pester-junit.xml, pester-junit-linux-hooks.xml and powershell-coverage.xml
EXIT_CODE: 0
Output Summary:
B=04f594f2ad2b891cbd8d1388a2e7fe2c67044d28
R_base=38881687469 (ci.yml, event push, branch main, headSha 04f594f2ad2b891cbd8d1388a2e7fe2c67044d28, conclusion success, attempt 1)
PS_BASE_CLAUDE_GATE=99.25
PS_BASE_CODEX_GATE=87.90
PS_BASE_RELEASE=94.93

## Reason for repetition

This file supersedes `ci-baseline.2026-10-16T09-22.md` (B=c415af626c292f38b910e3a27e70ab3e1903b31a). After that file was written, issues #928 (PR #954) and #929 (PR #958) merged into `main`, and the orchestrator merged `origin/main` 04f594f2a into this branch (merge commit 1195107340f811b565a2ee311e1ad3ce731c5680). D-BASE primary rule applied: run 38881687469 is the successful push run of ci.yml on main at the new B. Every value below equals its value in the superseded file.

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
| .claude/hooks/enforce-epic-merge-gate.ps1 (PS_BASE_CLAUDE_GATE) | 99.25 | 132 | 1 |
| .codex/hooks/enforce-epic-merge-gate.ps1 (PS_BASE_CODEX_GATE) | 87.90 | 138 | 19 |
| scripts/dev-tools/Invoke-FullReleaseFlow.ps1 (PS_BASE_RELEASE) | 94.93 | 131 | 7 |
| scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1 | 100.00 | 30 | 0 |

Each coverage path matched exactly one `sourcefile` entry. Downloads are under the scratch token `SCRATCH/issue-952-ci-38881687469/` and are not committed.
