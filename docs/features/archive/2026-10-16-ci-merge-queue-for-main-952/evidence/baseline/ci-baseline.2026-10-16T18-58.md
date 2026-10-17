# ORCH-1 — Baseline CI values (D-BASE, D-JUNIT, D-COV), repeated after the origin/main merge

Timestamp: 2026-10-16T18-58
Command: git merge-base origin/main HEAD; gh run list --workflow ci.yml --branch main --event push --commit fa27cd5edcb39a5d5f63054c3e38cefef18ab316 --status success --limit 1 --json databaseId,headSha; gh run download 38948304976 -n poshqc-test-results -D SCRATCH/issue-952-ci-38948304976/win; gh run download 38948304976 -n poshqc-linux-hook-test-results -D SCRATCH/issue-952-ci-38948304976/linux; D-JUNIT and D-COV computed over pester-junit.xml, pester-junit-linux-hooks.xml and powershell-coverage.xml
EXIT_CODE: 0
Output Summary:
B=fa27cd5edcb39a5d5f63054c3e38cefef18ab316
R_base=38948304976 (ci.yml, event push, branch main, headSha fa27cd5edcb39a5d5f63054c3e38cefef18ab316, conclusion success, attempt 1)
PS_BASE_CLAUDE_GATE=99.29
PS_BASE_CODEX_GATE=88.41
PS_BASE_RELEASE=94.93

## Reason for repetition

This file supersedes `ci-baseline.2026-10-16T16-39.md` (B=d72ec6a1010223f7036b9c3d15dad102ae262f98). Before remediation cycle 2 execution, four commits (release 1.1.19 and npm dependabot bumps; files: `.codex/config.toml` and its bundle mirror, `package.json` and `package-lock.json` files) reached `main`, and the orchestrator merged `origin/main` fa27cd5ed into this branch (merge commit ea32a2a98f447d4d8ed849fa1516d61097ae3a39). D-BASE primary rule applied: run 38948304976 is the successful push run of ci.yml on main at the new B. Every value equals the superseded file.

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

Each coverage path matched exactly one `sourcefile` entry. Downloads are under the scratch token `SCRATCH/issue-952-ci-38948304976/` and are not committed.
