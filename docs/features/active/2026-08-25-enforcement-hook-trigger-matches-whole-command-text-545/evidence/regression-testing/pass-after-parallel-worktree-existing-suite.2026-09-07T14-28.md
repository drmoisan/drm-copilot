# Pass-after — existing `enforce-parallel-worktree-removal-gate.Tests.ps1` suite

Timestamp: 2026-09-07T14-28

Task: [P8-T13]

TOOLCHAIN_SUBSTITUTION: the plan's targeted form
`pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 -Output Detailed"`
is not invocable in this session — `pwsh`, `powershell`, and `cmd` are all refused by the runtime
worktree-isolation guard, so no process starts and no exit code is produced. The folder-scoped MCP
runner was used instead and the per-suite figures were read from the `<testsuite>` element of
`artifacts/pester/pester-junit.xml` whose `name` ends with that suite's file name, with the
individual case result read from the matching `<testcase>` element.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 3 (folder-wide failed-test count; the suite named by this task contributes 0 of the 3)

## Per-suite result

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` | 45 | **0** | 0 | 0 |

Derived passed count: `tests - failures - errors - skipped` = `45 - 0 - 0 - 0` = **45**. The
`<testsuite>` element carries no `passed` attribute, as [P0-T10] recorded, so the value is derived
rather than read.

## Comparison against the [P0-T10] baseline

| Source | Passed |
| --- | --- |
| `evidence/baseline/baseline-targeted-pester.2026-09-07T10-57.md`, row 3 | 45 |
| This run, after [P8-T10] and [P8-T11] | 45 |

Equal. All 45 pre-existing cases still pass unmodified.

## The named `--force` case

The plan requires this artifact to name the existing `It` at line 78 of that suite. Its
`<testcase>` element in this run:

```
classname = tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1
name      = enforce-parallel-worktree-removal-gate.ps1.allow when the matched item merge_status is
            terminal.allows git worktree remove --force when the matching record has merge_status merged
time      = 0.016
children  = none
```

The element carries no `<failure>` and no `<error>` child, which is how Pester's JUnit writer
records a passing case, so **`allows git worktree remove --force when the matching record has
merge_status merged` passes unmodified**. That case uses the trailing spelling
`git worktree remove /repo/worktrees/item-a-101 --force`, which the previous pattern already handled
by capturing the path before reaching the flag; the shared parser reaches the same operand by
skipping `--force` as a known zero-argument flag. The two existing helper cases in the same suite,
`extracts the target path from the command text` and `returns $null when the command does not name a
path`, also pass, so the function's `$null`-on-miss contract is intact.

## Companion suite created by [P8-T12]

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1` | 3 | **0** | 0 | 0 |

All three new cases pass: `resolves the operand when --force precedes the path`, `brings git -C
/repo/main worktree remove into scope`, and `takes a quoted mention of the removal phrase out of
scope`.

## Known-red inventory movement observed in this run

Row 6 of the [P1-T13] inventory,
`AT-7 resolves the worktree path when the force flag precedes it, in both removal gates`,
**passes for the first time in this run**. Its `It` asserts
`Get-ParallelWorktreeRemovalCommandPath` first and `Get-EpicWorktreeRemovalCommandPath` second; the
second half was already satisfied by [P8-T1], and [P8-T10] supplies the first. Row 6 is formally
recorded as closed by [P8-T14]. The folder-wide failure count fell from 4 to 3 accordingly.

Output Summary: the existing `enforce-parallel-worktree-removal-gate.Tests.ps1` suite reports
**45 tests, 0 failures, 0 errors, 0 skipped** after the [P8-T10] edit. The derived passed count of
**45** equals the [P0-T10] baseline passed count of 45, so no pre-existing case changed direction,
and the named case `allows git worktree remove --force when the matching record has merge_status
merged` is recorded passing with no `<failure>` child. The [P8-T12] sibling suite reports 3 tests and
0 failures. The folder-wide exit code of 3 is accounted for entirely by suites other than these two:
two known-red inventory rows that Phase 9 closes (AT-2, AT-4) and the documented pre-existing
ambient-state failure in `enforce-pr-author-skill.Tests.ps1`. Inventory row 6 (AT-7) passed for the
first time in this run.
