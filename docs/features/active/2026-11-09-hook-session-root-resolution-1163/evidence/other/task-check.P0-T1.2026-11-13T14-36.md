# Task check: remediation cycle 1, [P0-T1] (finding F1), after the fix

Timestamp: 2026-11-13T14-35
Command: sh SCRATCH/issue-1163-f1-taskcheck.sh (PowerShell 7; New-PesterConfiguration with Run.Path set to the 13 selected test files, Run.Exit = $true, Output.Verbosity = Normal)
EXIT_CODE: 0
Output Summary: Tests Passed: 504, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0. The four rows that failed before the fix (fail-before.F1.2026-11-13T14-33.md under evidence/regression-testing/, 500 passed and 4 failed) now pass in both shared-row suites, so the detail names `branch 'bug/item'` before the stale root.

## Changed files

- `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` (`Resolve-AgentTargetWorktree`): `$branches` is assigned as `@(if (...) { ... } else { ... })`, so a single branch stays a one-element array; `$stale` now holds the matching dropped records, and the detail names `$stale[0].Branch` and `$stale[0].Root` instead of `$branches[0]` and the first root.
- `.codex/hooks/agent-target-worktree.ps1`: the same function text.
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/agent-target-worktree.ps1`: copied from the sources; `cmp` reports both byte-identical.
- `tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Rows.Helpers.ps1`: changed in step 1 (two tightened `DetailPattern` values).

## Scoped static check

| Step | Command | EXIT_CODE | Finding count |
|---|---|---|---|
| Format | sh SCRATCH/issue-1163-f1-static.sh: Invoke-Formatter with pssa.settings.psd1 over the three changed files, compared with the file text (non-writing) | 0 | 0 files would change |
| Lint | the same launcher: Invoke-ScriptAnalyzer with pssa.settings.psd1 per file | 0 | 0 |
| Type check | not applicable to PowerShell | n/a | n/a |

## Selection

Rule (#1167 Test Cadence): the test files that import, dot-source, or name a changed file, from `git grep -l -e AgentTargetWorktree -e agent-target-worktree -- tests`, excluding the dot-sourced rows helper. The 13 files are listed in fail-before.F1.2026-11-13T14-33.md. `agent-target-worktree.Tests.ps1` also asserts that the Codex twin's function text equals the module's.

This is a task check, not a gate; it measures no coverage. The full QA loop follows as the final gate of this cycle.
