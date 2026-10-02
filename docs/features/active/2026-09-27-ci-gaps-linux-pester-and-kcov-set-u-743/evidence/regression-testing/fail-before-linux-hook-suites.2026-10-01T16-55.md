# Fail-Before: Linux Hook Suites (P4-T3) [expect-fail]

Timestamp: 2026-10-01T16-55
RUN_ID: 36894194578
CI_SHA: 90b6bd4a8646f0a510509c839e9daec77dff69d1
Command: gh run view 36894194578 --json conclusion,jobs
EXIT_CODE: 0
Output Summary: job `PowerShell hook suites (Linux)` (databaseId 110476951732) concluded `failure` in step `Test PowerShell hook suites`; JUnit `tests=3412 failures=21 errors=0`. Run URL https://github.com/drmoisan/drm-copilot/actions/runs/36894194578.

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
