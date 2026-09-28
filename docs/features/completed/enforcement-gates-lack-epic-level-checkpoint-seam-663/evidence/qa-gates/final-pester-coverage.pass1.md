# Full Pester with Coverage, Pass 1 (abandoned) ([P8-T7])

Pass: 1
Timestamp: 2026-09-25T19-57
Command: sh <SCRATCHPAD>/i663/run.sh p8-test  (fresh PowerShell 7 process: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root $root -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1); then sh <SCRATCHPAD>/i663/run.sh p8-report
EXIT_CODE: 1
Output Summary: The test run itself was green (console `Tests Passed: 5044, Failed: 0, Skipped: 9`; root tests=5053 failures=0 errors=0 disabled=9; every section 4 name Passed in its owning testsuite; 214 testsuites, none with failures or errors). The pass failed its coverage acceptance: `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` measured 66.67% (covered 18, missed 9), below the 85% floor. The report script exited 1 on that condition. Pass 1 was abandoned and the loop restarted from [P8-T1] after the remediation below.

## Per-file line coverage (pass 1)

| File | Percent | covered | missed |
| --- | --- | --- | --- |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 96.97% | 160 | 5 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 96.97% | 160 | 5 |
| .claude/hooks/enforce-pr-author-skill-helpers.ps1 | 97.00% | 97 | 3 |
| .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 | 93.55% | 29 | 2 |
| .claude/hooks/enforce-model-routing-receipt.ps1 | 95.52% | 64 | 3 |
| .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 93.42% | 142 | 10 |
| .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 90.38% | 94 | 10 |
| .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 | 95.92% | 47 | 2 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 66.67% | 18 | 9 |

## Cause

The nine missed lines of the sibling were lines 41-45 and 53-57 (the bodies of `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent`, which [P5-T4] relocated verbatim from the gate file) and line 114 (the early `return $null` for a call with neither a command nor a path). The relocated seam bodies were already unexecuted in the gate file before the move: the gate's missed count fell from 18 at baseline to 10 after the move, by the same eight lines. No existing test executed them, because every gate suite supplies the checkpoint text directly or shadows the seams by name.

## Remediation (between pass 1 and pass 2)

- Rule 5 budget reset recorded in `evidence/other/batch-budget-resets.md` (entry `P8 pass-1 remediation`; `none present`).
- One test file changed: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` gained the Context `issue #663 relocated read seams and the no-leg guard of the epic-scope sibling` with five rows:
  - `issue #663 the relocated epic read seam returns an empty string when the epic checkpoint file is absent`
  - `issue #663 the relocated epic read seam returns the raw epic checkpoint text when the file exists`
  - `issue #663 the relocated parallel read seam returns an empty string when the parallel checkpoint file is absent`
  - `issue #663 the relocated parallel read seam returns the raw parallel checkpoint text when the file exists`
  - `issue #663 the epic-scope decision returns null without resolving when the call carries neither a command nor a path`
  The rows mock `Get-OrchestrationDelegationCheckpointPath`, `Test-Path`, `Get-Content`, and `Resolve-EpicScopeCheckpoint`; no file is created or read. The file grows from 227 to 310 lines (numstat against origin/main: 310 added, 0 deleted; it is a new file).
- No production file and no mirror changed, so no mirror re-copy was required.
- Scoped check (R-SCOPED over the edited suite and `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`): PassedCount 23, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0; all five new names on PASSED lines. A first attempt failed two of the new rows because the path mock used `.GetNewClosure()`, which hid the bound `-Mode` argument from the mock body; the body was changed to read `$script:` values without a closure.

Result: FAIL (pass abandoned; loop restarted at pass 2)
