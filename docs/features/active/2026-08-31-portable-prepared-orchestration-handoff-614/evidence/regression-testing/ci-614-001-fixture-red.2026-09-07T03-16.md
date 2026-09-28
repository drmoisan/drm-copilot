# Pester Fixture Retarget — Red Run — [P1-T14] `[expect-fail]`

Timestamp: 2026-09-07T11-47
Task: [P1-T14]

Command: `pwsh -NoProfile -Command '& { Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path "tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1" -Output Detailed -PassThru; Write-Output ("RESULT={0} PASSED={1} FAILED={2}" -f $r.Result, $r.PassedCount, $r.FailedCount); if ($r.Result -ne "Passed") { exit 1 } }'`
EXIT_CODE: 1
ExpectedExitCode: 1

## Changes made

Four edits to `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1`. No file was created by this task.

1. In the outer `BeforeAll`, after the `$script:HookRoot` assignment, `$script:PreparationCheckpointFixture` was assigned `Join-Path $script:RepoRoot 'tests/fixtures/codex-hooks/epic-planning-preparation-checkpoint.json'`, followed by a guard that throws when `Test-Path -LiteralPath` for that path with `-PathType Leaf` is false. The throw message interpolates `$script:PreparationCheckpointFixture`, so the output names the missing fixture path.
2. Inside `Invoke-EpicPlanningDecisionProcess`, `$startInfo.Environment['EPIC_PLANNING_CHECKPOINT_PATH']` was set to that fixture path, alongside the two existing `$startInfo.Environment` assignments.
3. In the child here-string, the hard-coded `-CheckpointRaw '{"route_id":"preparation"}'` argument was replaced with `-CheckpointRaw (Get-Content -Raw -LiteralPath $env:EPIC_PLANNING_CHECKPOINT_PATH)`.
4. The `$checkpointPath` assignment in the six-case byte-identity block, which previously joined the gitignored `artifacts/orchestration/orchestrator-state.json`, now reads `$script:PreparationCheckpointFixture`.

File line count after this task: 453 (pre-change 445; within the 500-line limit).

## Observed failure (verbatim)

```
Starting discovery in 1 files.
Discovery found 50 tests in 155ms.
Describing Codex epic preparation, wave, merge, and worktree gates
[-] Describe Codex epic preparation, wave, merge, and worktree gates failed
  RuntimeException: Preparation checkpoint fixture is missing: C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29\tests\fixtures\codex-hooks\epic-planning-preparation-checkpoint.json
  at <ScriptBlock>, C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1:13
Tests Passed: 0, Failed: 50, Skipped: 0, Inconclusive: 0, NotRun: 0
BeforeAll \ AfterAll failed: 1
  - Codex epic preparation, wave, merge, and worktree gates
RESULT=Failed PASSED=0 FAILED=50
```

Output Summary: The run exited 1, which is the expected outcome for this `[expect-fail]` task. The recorded `RESULT=` value is `Failed`. The output names the missing fixture path in full: `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29\tests\fixtures\codex-hooks\epic-planning-preparation-checkpoint.json`. The failure originates in the outer `BeforeAll` guard at line 13, so all 50 discovered cases are reported failed rather than only the six retargeted ones; that is the guard behaving as intended, since a missing fixture makes every case in the file unrunnable rather than silently reading a different file. [P1-T15] creates the fixture and [P1-T16] re-runs this same command green.
