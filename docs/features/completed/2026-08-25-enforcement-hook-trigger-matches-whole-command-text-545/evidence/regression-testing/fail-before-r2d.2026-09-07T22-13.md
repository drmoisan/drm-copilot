# Fail-before — R-2.d, the `cd`-chained read rule

Task: `[P4-T3]` `[expect-fail]`
Timestamp: 2026-09-07T22-13

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`
and `scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 4
ExpectedExitCode: 4

The MCP test runner exits with the folder-wide failed-test count. The folder-wide count recorded
below is 4: the three new R-2.d cases that are expected to fail before Edit 6, plus the one
tolerated pre-existing ambient failure in this folder.

## TOOLCHAIN_SUBSTITUTION

`pwsh`, `powershell`, and `cmd` are not invocable in this session; the runtime guard refuses them.
Pester was therefore run through `mcp__drm-copilot__run_poshqc_test`. Per-suite and per-case results
below are read from `artifacts/pester/pester-junit.xml`, never from the tool's exit code, per
standing constraint 10.

## The four new cases

Read from `<testcase … status="…">` in `artifacts/pester/pester-junit.xml`. All four resolve
under `Describe 'validate-bash.ps1 trigger scoping (issue #545)'`,
`Context 'R-2.d wrapper-led cd-chain'`.

| # | It name | Command fixture | Expected return | Observed `status` |
|---|---|---|---|---|
| 1 | `R2d-C1 returns head for a cd-chained read inside a bash -c argument` | `bash -c "cd /x && head f"` | `head` | `Failed` |
| 2 | `R2d-C2 returns grep for a semicolon-chained read inside an sh -c argument` | `sh -c "cd /x; grep foo bar"` | `grep` | `Failed` |
| 3 | `R2d-C3 returns cat for a cd-chained read inside a pwsh -Command argument` | `pwsh -NoProfile -Command "cd /x && cat f"` | `cat` | `Failed` |
| 4 | `R2d-N1 still returns null for an echo whose quoted text contains a cd-then-read phrase` | `echo "cd /x && head f"` | `$null` | `Passed` |

Split observed: three non-passing (`Failed`) and one passing. That is the required split.

Why the split is the one the plan predicts: `Get-CdChainedReadCommandMatch` today reads the segment
list through the `CommandWord` walk only. In C1, C2, and C3 the wrapper's quoted argument collapses
into ONE token, so the single segment's `CommandWord` is `bash`, `sh`, or `pwsh` and never `cd`; the
walk returns `$null` and the `Should -Be` assertion fails. In N1 the segment is not wrapper-led, its
quotes close and it carries no live substitution, so the scanner masks the quoted span and no `cd`
segment exists — `$null` is already the correct answer, and N1 is a preservation pin rather than a
regression case.

## Per-suite counts

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | 16 | 3 | 0 | 0 |
| `tests/scripts/claude-hooks/validate-bash.Tests.ps1` | 26 | 0 | 0 | 0 |

`validate-bash.Tests.ps1` is unmodified by this batch and records 0 failures and 0 errors, so the
eight pre-existing `cd`-chain cases it carries are unaffected by the test-only edit of `[P4-T2]`.

## Folder-wide totals

Read from the root `<testsuites …>` element.

| tests | failures | errors |
|---|---|---|
| 1545 | 4 | 0 |

## Every folder-wide failure, named

| # | Suite | It name | Classification |
|---|---|---|---|
| 1 | `enforce-pr-author-skill.Tests.ps1` | `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | tolerated row 1 — pre-existing ambient-state failure, not change-caused, not fixed here |
| 2 | `validate-bash.TriggerScoping.Tests.ps1` | `R2d-C1 returns head for a cd-chained read inside a bash -c argument` | expected fail-before, closes at `[P4-T6]` |
| 3 | `validate-bash.TriggerScoping.Tests.ps1` | `R2d-C2 returns grep for a semicolon-chained read inside an sh -c argument` | expected fail-before, closes at `[P4-T6]` |
| 4 | `validate-bash.TriggerScoping.Tests.ps1` | `R2d-C3 returns cat for a cd-chained read inside a pwsh -Command argument` | expected fail-before, closes at `[P4-T6]` |

No failure outside those four. The only non-R-2.d failure is tolerated row 1.

## Output Summary

Folder-wide 1545 tests, 4 failures, 0 errors. The three R-2.d positive cases record `Failed` and
the R-2.d negative case records `Passed`, which is the three-non-passing / one-passing split this
task requires. The fourth folder-wide failure is tolerated row 1 and is unchanged from the
`[P0-T6]` baseline.
