# Pass-after — existing `enforce-epic-worktree-removal-gate.Tests.ps1` suite

Timestamp: 2026-09-07T14-14

Task: [P8-T4]

TOOLCHAIN_SUBSTITUTION: the plan's targeted form
`pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 -Output Detailed"`
is not invocable in this session — `pwsh`, `powershell`, and `cmd` are all refused by the runtime
worktree-isolation guard, so no process starts and no exit code is produced. The folder-scoped MCP
runner was used instead and the per-suite figures were read from the `<testsuite>` element of
`artifacts/pester/pester-junit.xml` whose `name` ends with that suite's file name. Pester emits one
`<testsuite>` element per test FILE carrying that file's own `tests`, `failures`, `errors`, and
`skipped` attributes, so these are exactly the counts a per-file run would report.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 4 (folder-wide failed-test count; the suite named by this task contributes 0 of the 4)

## Per-suite result

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | 46 | **0** | 0 | 0 |

Derived passed count: `tests - failures - errors - skipped` = `46 - 0 - 0 - 0` = **46**. The
`<testsuite>` element carries no `passed` attribute, as [P0-T10] recorded, so the value is derived
rather than read.

## Comparison against the [P0-T10] baseline

| Source | Passed |
| --- | --- |
| `evidence/baseline/baseline-targeted-pester.2026-09-07T10-57.md`, row 4 | 46 |
| This run, after [P8-T1] and [P8-T2] | 46 |

Equal. All 46 pre-existing cases still pass unmodified after the scope filter in
`Invoke-EpicWorktreeRemovalGateDecision` and the operand resolution in
`Get-EpicWorktreeRemovalCommandPath` were moved onto `Test-CommandLineInvocation`,
`Get-CommandLineOperand`, and `Test-CommandLineFlag`. That includes both cases in the existing
`Get-EpicWorktreeRemovalCommandPath helper` Context — `extracts the target path from the command
text` and `returns $null when the command does not name a path` — so the function's null-on-miss
contract is intact, and both branch-1 allow cases, the whole non-terminal `merge_status` deny matrix,
the branch-2 parallel-checkpoint cases, the Windows-separator normalization case, and the
envelope-anomaly cases.

## Companion suite created by [P8-T3]

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1` | 5 | **0** | 0 | 0 |

All five new cases pass:

| Case | Result |
| --- | --- |
| denies git -C /repo/main worktree remove against a checkpoint with no authorizing record | PASS |
| resolves the operand when --force precedes the path | PASS |
| resolves the same operand when --force follows the path | PASS |
| allows a command whose quoted text merely mentions the removal phrase | PASS |
| keeps git worktree list out of scope | PASS |

## Known-red inventory movement observed in this run

Row 1 of the [P1-T13] inventory,
`AT-1 denies a relocating git worktree remove against an epic checkpoint with no authorizing record`,
**passes for the first time in this run**. It is formally recorded as closed by [P8-T14], which
re-runs `hook-command-parser.AcceptanceCases.Tests.ps1` after the parallel gate is fixed as well.
The folder-wide failure count fell from 5 to 4 accordingly.

Output Summary: the existing `enforce-epic-worktree-removal-gate.Tests.ps1` suite reports
**46 tests, 0 failures, 0 errors, 0 skipped** after the [P8-T1] edit. The derived passed count of
**46** equals the [P0-T10] baseline passed count of 46 for the same suite, so no pre-existing case
changed direction. The [P8-T3] sibling suite reports 5 tests and 0 failures. The folder-wide exit
code of 4 is accounted for entirely by suites other than these two: three known-red inventory rows
still open at this point (AT-2, AT-4, AT-7) and the documented pre-existing ambient-state failure in
`enforce-pr-author-skill.Tests.ps1`. Inventory row 1 (AT-1) passed for the first time in this run.
