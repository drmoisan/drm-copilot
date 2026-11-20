# Task Check P8-T8 self-review fix (issue #1163)

Timestamp: 2026-11-13T13-53
Command: sh SCRATCH/issue-1163-taskcheck.sh (pwsh 7: New-PesterConfiguration with Run.Path set to the three selected files and Run.PassThru; exit 1 when any test fails)
EXIT_CODE: 0
Output Summary: Task check for the fix of the two FAIL rows found by the P8-T8 self-review walk (a catch that discarded the error with no context). Run 1, at 2026-11-13T13-52 against unmodified production code with the new assertions in place: 256 passed, 3 failed, exit 1; each failure is one of the new assertions, failing on the missing failure context. Run 2, at 2026-11-13T13-53 after the fix: 259 passed, 0 failed, exit 0. This is a task check under the Test Cadence, not a gate; the full QA loop from P8-T1 follows.

## Changed files

- `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1`: the working-directory leg of `Resolve-AgentTargetWorktree` keeps the session-root fallback when the worktree list throws, and now records `the worktree list failed: <message>` in `Detail`, as `Resolve-HookTargetWorktree` does for the same failure.
- `.codex/hooks/agent-target-worktree.ps1`: the same edit, so the function text stays byte-identical to the Claude module.
- `.claude/hooks/enforce-docs-complete-gate.ps1`: `Get-DocsCompleteGateReceiptRoot` keeps the repository-root fallback when the resolver throws, and now writes the exception message through `Write-Verbose`, as the file-size hooks on this branch do.
- Bundle mirrors of the three files under `extensions/drm-copilot/resources/` (byte-identical copies; SHA-256 prefixes 1a5456b5b8ffc502, bc68f70cd9498c4e, d794d97e2fa34012 equal for each pair).
- `tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Rows.Helpers.ps1`: the shared row 'a throwing listing for a working directory applies the session root' gains `DetailPattern` 'the worktree list failed: synthetic worktree list failure'; its other expectations are unchanged.
- `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1`: new row 'Get-DocsCompleteGateReceiptRoot returns the repository root and reports the failure when the resolver throws' in `Describe 'enforce-docs-complete-gate receipt root (issue #1163)'`.

## Selection and rule

Mirrored test files of the changed production files, plus the Codex twin suite that runs the shared rows and asserts byte-identical function text:

- `tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Tests.ps1`
- `tests/scripts/codex-hooks/agent-target-worktree.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1`

The other suites that import the changed modules run in the full Pester gate of the re-run QA loop.

## Results

| Run | Suite | Passed | Failed |
|---|---|---|---|
| 1 (before fix) | AgentTargetWorktree.Tests.ps1 | 76 | 1 |
| 1 (before fix) | agent-target-worktree.Tests.ps1 | 25 | 1 |
| 1 (before fix) | enforce-docs-complete-gate.Tests.ps1 | 155 | 1 |
| 2 (after fix) | AgentTargetWorktree.Tests.ps1 | 77 | 0 |
| 2 (after fix) | agent-target-worktree.Tests.ps1 | 26 | 0 |
| 2 (after fix) | enforce-docs-complete-gate.Tests.ps1 | 156 | 0 |

Run 1 failures:

- 'a throwing listing for a working directory applies the session root' (both resolver suites): expected the detail to match 'the worktree list failed: synthetic worktree list failure'; observed 'the agent working directory ... is inside no live registered worktree, so the session root applies'.
- 'Get-DocsCompleteGateReceiptRoot returns the repository root and reports the failure when the resolver throws': the returned root was the repository root, and no verbose record carried 'synthetic resolver failure'.
