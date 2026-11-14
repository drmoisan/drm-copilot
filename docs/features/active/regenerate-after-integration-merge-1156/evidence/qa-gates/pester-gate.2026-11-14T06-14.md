# Pester Gate at the Merged Head — feature review, remediation cycle 1 re-audit

Timestamp: 2026-11-14T06-14
Command: sh SCRATCH/issue-1156-review-pester.sh (pwsh 7 from the item worktree root: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree root>; exit with the returned ExitCode)
EXIT_CODE: 0
Output Summary:
- Reason: the merge of origin/main at 2c8dee6dd (commit 6bb6365d1, #1175) changed 68 PowerShell files after the executor's final gate `pester-final.2026-11-14T05-44.md`, so no Pester run described the merged head. `git status --porcelain` was empty before the run; head 6bb6365d1bf4aafcbc958ebf2b9e295a22dc1a90.
- One Invoke-PoshQCParallelTest run, 8 shards all exit 0, ExitCode 0; 06:01:36 to 06:14:24 UTC. Merged JUnit and coverage written 2026-11-14T06:14:24Z.
- artifacts/pester/pester-junit.xml: 24724 tests, 0 failures, 0 errors, 10 disabled. Named suites: `Invoke-RegenerationPath.ProcessStart.Tests.ps1` 17/0, `Invoke-RegenerationPath.Tests.ps1` 123/0, `regeneration-path-skill-contract.Tests.ps1` 52/0, `enforcement-hooks-no-python-invocation.Tests.ps1` 35/0, `ProcessReductionChain.Tests.ps1` 53/0, `ProcessReductionLedger.Tests.ps1` 72/0, `FileSizePolicy.RepoGate.Tests.ps1` 5/0.
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 95.94% (40926 covered, 1734 missed); `Phase 0 baseline` 95.80%.
- Branch production files: `Invoke-RegenerationPath.ps1` 293/321 = 91.28%; `RegenerationConfig.psm1` 98/100 = 98.00%; `RegenerationClassifier.psm1` 30/30 = 100%; `RegenerationDelta.psm1` 102/102 = 100%; Claude `enforce-epic-merge-gate-regeneration.ps1` 44/44 = 100%; Claude `hook-epic-regeneration.ps1` 89/91 = 97.80%; Codex `enforce-epic-merge-gate-regeneration.ps1` 43/44 = 97.73%; Codex `hook-epic-regeneration.ps1` 89/91 = 97.80%; edited entry files Claude `enforce-epic-merge-gate.ps1` 98.63%, Codex `enforce-epic-merge-gate.ps1` 99.44%, Claude epic-scope gate 97.73%, Codex epic-scope gate 98.01%. Each equals the executor's pre-merge figure.
- The run is a feature-review verification step; it refreshed the gitignored `artifacts/pester/` outputs and changed no tracked file.
