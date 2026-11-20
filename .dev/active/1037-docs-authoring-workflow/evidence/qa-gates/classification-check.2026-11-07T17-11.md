# Classification Check (P7-T7)

Timestamp: 2026-11-07T17-11
Command: pwsh -NoProfile -File SCRATCH/issue-1037-classification.ps1 (expands each `## Artifact Classification` row over the Named Sets and compares the expansion with the 176-path branch file list recorded by [P7-T6])
EXIT_CODE: 0
Output Summary: Acceptance NOT MET (the comparison script ran to completion; the result below fails the task's acceptance). 12 file-bearing rows expand to 144 paths with no path in two rows; every expanded path exists and is in the branch list (0 absent rows). The `<FEATURE>/**` row covers 31 paths. One branch path is covered by no row: `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`.

## Row expansion

| Row | Paths |
|---|---|
| Copilot agents and bundle copies | 8 |
| Claude agents and bundle copies | 8 |
| Codex agents and bundle copies | 8 |
| Skills, six roots | 48 |
| Templates, six roots | 48 |
| Hooks and bundle copies | 6 |
| Settings copies | 2 |
| Routing copies | 3 |
| Pack manifests | 2 |
| Hook suites | 3 |
| Structural suites and helper | 6 |
| Edited guard suites (`hook-dependency-failure.Claude.Tests.ps1`, `subagentstop-uncaught-error.Tests.ps1`) | 2 |
| `<FEATURE>/**` | 31 |
| Codex generator run | 0 (the write run changed no path) |

## Uncovered path

`tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` received one additive `$script:ExemptHook` row in [P2-T4]. The issue #1026 inventory guard in that file (`lists every hook registered for the Bash, Write|Edit, and Agent matchers as composed or exempted`) fails once `enforce-docs-role-write-scope.ps1` is registered under `PreToolUse`, so the row was mechanically necessary for the [P7-T3] zero-failure acceptance. The plan's classification table and the [P2-T4] disposition list do not name this file.

Plan delta that closes the gap (for the planner or orchestrator): in `## Artifact Classification`, extend the row `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1, tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1 (edit: additive rows)` to also list `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`, and add to the [P2-T4] disposition list: "`cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` updated (one `$script:ExemptHook` row for `enforce-docs-role-write-scope.ps1`; the #1026 inventory test requires every registered Bash, Write, Edit or Agent hook to be composed or exempted)".
