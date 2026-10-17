# First Linux Run of _poshqc.yml (P4-T2, P4-T3)

Timestamp: 2026-10-01T16-44

## P4-T2 dispatch

Dispatch time (UTC): 2026-10-01T16:43:56Z

Command: gh workflow run _poshqc.yml --ref bug/ci-gaps-linux-pester-and-kcov-set-u-743
EXIT_CODE: 0
Output Summary: run https://github.com/drmoisan/drm-copilot/actions/runs/36894194578

Command: gh run list --workflow=_poshqc.yml --branch bug/ci-gaps-linux-pester-and-kcov-set-u-743 --event workflow_dispatch --limit 1 --json databaseId,headSha,status,conclusion,createdAt
EXIT_CODE: 0
Output Summary: databaseId 36894194578, createdAt 2026-10-01T16:44:00Z (after dispatch time), headSha 90b6bd4a8646f0a510509c839e9daec77dff69d1 (equals CI_SHA_1), status in_progress.

RUN_ID: 36894194578
CI_SHA: 90b6bd4a8646f0a510509c839e9daec77dff69d1

## P4-T3 results [expect-fail]

Deviation: D9 (the SP7 summary is produced by `<session-scratchpad>/pester_xml_summary.py`, run with `poetry run python`).

Command: gh run view 36894194578 --json conclusion,jobs
EXIT_CODE: 0
Output Summary: run conclusion `failure`. Job `PowerShell hook suites (Linux)` databaseId 110476951732 concluded `failure`; its failing step is `Test PowerShell hook suites`; `Upload PowerShell hook-suite test results` concluded `success` (if: always()). Job `PowerShell QC` databaseId 110476951925 concluded `success` (every step `success`).

Command: gh run view 36894194578 --log --job 110476951732 | grep -F 'Tests Passed:'
EXIT_CODE: 0
Output Summary: `Tests Passed: 3391, Failed: 21, Skipped: 0, Inconclusive: 0, NotRun: 0`

Command: gh run download 36894194578 --name poshqc-linux-hook-test-results --dir <session-scratchpad>/linux-first-run-743
EXIT_CODE: 0
Output Summary: `pester-junit-linux-hooks.xml` downloaded.

Command: poetry run python <session-scratchpad>/pester_xml_summary.py junit <session-scratchpad>/linux-first-run-743/pester-junit-linux-hooks.xml
EXIT_CODE: 0
Output Summary: `JUNIT-ROOT: tests=3412 failures=21 errors=0` (tests greater than 0); 21 `FAIL:` lines in 8 suites.

Suites with failures:

```
SUITE: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | tests=48 | failures=8 | errors=0 | skipped=0
SUITE: tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 | tests=47 | failures=1 | errors=0 | skipped=0
SUITE: tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 | tests=32 | failures=1 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | tests=49 | failures=1 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | tests=34 | failures=1 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | tests=20 | failures=5 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | tests=19 | failures=3 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | tests=22 | failures=1 | errors=0 | skipped=0
```

FAIL lines:

```
FAIL: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | enforce-parallel-drift-gate.ps1.Layer-1 finding-presence narrowing to the current drift event.denies when the only finding file predates the latest drift event
FAIL: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | enforce-parallel-drift-gate.ps1.Layer-1 finding-presence narrowing to the current drift event.allows when the finding file timestamp equals the latest drift event at
FAIL: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | enforce-parallel-drift-gate.ps1.Layer-1 finding-presence narrowing to the current drift event.allows when the finding file timestamp follows the latest drift event at
FAIL: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | enforce-parallel-drift-gate.ps1.Layer-1 finding-presence narrowing to the current drift event.denies when the finding file name carries a non-conforming embedded substring
FAIL: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | enforce-parallel-drift-gate.ps1.Layer-1 finding-presence narrowing to the current drift event.names the current-event requirement in the deny reason for a stale finding file
FAIL: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | enforce-parallel-drift-gate.ps1.read seams.Test-ParallelDriftFindingPresent reports absence when the feature folder does not exist
FAIL: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | enforce-parallel-drift-gate.ps1.read seams.Test-ParallelDriftFindingPresent reports absence when no remediation-inputs file is present
FAIL: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | enforce-parallel-drift-gate.ps1.read seams.Test-ParallelDriftFindingPresent reports presence for a remediation-inputs markdown file
FAIL: tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 | enforce-powershell-batch-budget.ps1 large-path routing.checkpoint seam.the default reader yields direct mode when the checkpoint file is absent
FAIL: tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 | enforce-python-batch-budget.ps1 large-path routing.checkpoint seam.the default reader yields direct mode when the checkpoint file is absent
FAIL: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | Codex enforce-powershell-batch-budget.ps1 large-path routing.checkpoint seam.the default reader yields direct mode when the checkpoint file is absent
FAIL: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | Codex enforce-python-batch-budget.ps1 large-path routing.checkpoint seam.the default reader yields direct mode when the checkpoint file is absent
FAIL: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | Codex enforce-epic-worktree-removal-gate decision surface (issue #545).Get-NormalizedCodexWorktreePath resolves both rooted and relative inputs.resolves a relative path against the supplied working directory
FAIL: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | Codex enforce-epic-worktree-removal-gate decision surface (issue #545).Get-NormalizedCodexWorktreePath resolves both rooted and relative inputs.keeps a rooted path and trims a trailing separator
FAIL: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | Codex enforce-epic-worktree-removal-gate decision surface (issue #545).Find-CodexWorktreeFeature tolerates incomplete checkpoints.skips a feature record whose worktree_path is blank and reports no match
FAIL: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | Codex enforce-epic-worktree-removal-gate decision surface (issue #545).Find-CodexWorktreeFeature tolerates incomplete checkpoints.returns the matching feature record when the normalized paths agree
FAIL: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | Codex enforce-epic-worktree-removal-gate decision surface (issue #545).the decision router scope and operand branches.allows a removal whose feature record reports worktree_removed
FAIL: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | Codex epic-child launcher hardening.uses inline project trust, ignores user config, and denies Codex install paths
FAIL: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | Codex epic-child launcher hardening.preflights the elevated Windows sandbox from an isolated CODEX_HOME
FAIL: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | Codex epic-child launcher hardening.repeats the exact terminal receipt timestamp under the matching status key
FAIL: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | Codex epic-child worktree launcher and guard.immutable launch specification validation.builds codex exec with exact model, reasoning, instructions, skills, permissions, and worktree
```

Acceptance check: the five named cases S1 (`preflights the elevated Windows sandbox from an isolated CODEX_HOME`), S1b (`uses inline project trust, ignores user config, and denies Codex install paths`), S1c (`builds codex exec with exact model, reasoning, instructions, skills, permissions, and worktree`), and S2 (`resolves a relative path against the supplied working directory`, `keeps a rooted path and trims a trailing separator`) each appear once among the FAIL lines. The job did not conclude `success`, so no DISCOVERY-DIVERGENCE.

`PowerShell QC` job conclusion: `success` (`Tests Passed: 6091, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0`); no Windows failure outside the P0-T23 baseline failure set (which is empty).

P4-T5: NOT REQUIRED (the Linux job failed only in `Test PowerShell hook suites`).
