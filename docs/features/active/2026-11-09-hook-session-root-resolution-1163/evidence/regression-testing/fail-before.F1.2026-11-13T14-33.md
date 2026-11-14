# Fail-before: remediation cycle 1, finding F1 ([P0-T1])

Timestamp: 2026-11-13T14-32
Command: sh SCRATCH/issue-1163-f1-taskcheck.sh (PowerShell 7; New-PesterConfiguration with Run.Path set to the 13 selected test files, Run.Exit = $true, Output.Verbosity = Normal)
EXIT_CODE: 4
ExpectedExitCode: 4
Output Summary:
- Tests Passed: 500, Failed: 4, Skipped: 0, Inconclusive: 0, NotRun: 0.
- The four failures are the two tightened AC-7 rows, each run by both shared-row suites:
  - Resolve-AgentTargetWorktree shared rows.prunable a command branch registered only at a prunable root is not derivable and names the repair
  - Resolve-AgentTargetWorktree shared rows.prunable a prompt branch registered only at a prunable root fails closed and names the repair
  - agent-target-worktree.ps1 shared rows.prunable a command branch registered only at a prunable root is not derivable and names the repair
  - agent-target-worktree.ps1 shared rows.prunable a prompt branch registered only at a prunable root fails closed and names the repair
- Each failure reports: Expected regular expression '(?s)branch 'bug/item'.*/host-a/repo/\.claude/worktrees/item.*git worktree repair' to match 'branch 'b' is registered only at the stale root '/host-a/repo/.claude/worktrees/item'; run git worktree repair to register the worktree at its current path', but it did not match.
- The observed detail names `branch 'b'`, the first character of the single branch, which confirms F1 against the current function text (Resolve-AgentTargetWorktree and its Codex twin are unchanged at this point).

## Change under test

- `tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Rows.Helpers.ps1`: the `DetailPattern` of the rows 'prunable a command branch registered only at a prunable root is not derivable and names the repair' and 'prunable a prompt branch registered only at a prunable root fails closed and names the repair' now requires `branch 'bug/item'` before the stale root.

## Task-check selection

Rule: the test files that import, dot-source, or name a changed file (`AgentTargetWorktree.psm1`, `agent-target-worktree.ps1`, `AgentTargetWorktree.Rows.Helpers.ps1`), from `git grep -l -e AgentTargetWorktree -e agent-target-worktree -- tests`, excluding the dot-sourced helper itself:

- tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1
- tests/scripts/claude-hooks/enforce-file-size-limit.TargetWorktree.Tests.ps1
- tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1
- tests/scripts/claude-hooks/subagentstop-target-worktree.Tests.ps1
- tests/scripts/claude-hooks/validate-orchestrator-output-target.Tests.ps1
- tests/scripts/claude-hooks/validate-orchestrator-output.TargetWorktree.Tests.ps1
- tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Tests.ps1
- tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1
- tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1
- tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.RelativeRecord.Tests.ps1
- tests/scripts/codex-hooks/agent-target-worktree.Tests.ps1
- tests/scripts/codex-hooks/enforce-file-size-limit-target-worktree.Tests.ps1

This is a task check under the #1167 Test Cadence, not a gate; it measures no coverage.
