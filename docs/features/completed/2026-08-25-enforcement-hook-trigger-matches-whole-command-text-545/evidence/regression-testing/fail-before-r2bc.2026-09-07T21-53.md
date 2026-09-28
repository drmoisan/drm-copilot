# Fail-before — R-2.b and R-2.c — [P3-T4]

Timestamp: 2026-09-07T21-53

Task: `[P3-T4]` `[expect-fail]` — record the fail-before state of the eight new cases.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`
and `scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 5

ExpectedExitCode: 5

The exit code is the folder-wide failed-test count: the four R-2.b and R-2.c regression cases
below plus the one pre-existing tolerated failure in this folder. Acceptance is read from
`artifacts/pester/pester-junit.xml` per-case `status` attributes, never from this exit code.

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session, so
Pester was not run directly. The substitute route is the MCP function
`mcp__drm-copilot__run_poshqc_test`, with per-suite `<testsuite>` counts and per-case `status`
attributes read out of `artifacts/pester/pester-junit.xml`.

## Root totals

`<testsuites name="Pester" tests="1541" errors="0" failures="5">`

## The eight new cases

| # | Suite | It name | status |
|---|---|---|---|
| 1 | `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | `R2b-C1 denies the space-separated disposition carried inside a bash -c argument` | `Failed` |
| 2 | `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | `R2b-C2 denies the equals-joined disposition carried inside a bash -c argument` | `Failed` |
| 3 | `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | `R2b-C3 allows a wrapper-led abandon carrying the confirmation marker in the same segment` | `Passed` |
| 4 | `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | `R2b-N1 still allows a commit message quoting the disposition token` | `Passed` |
| 5 | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `R2c-C1 denies a gh pr edit inline body carried inside a bash -c argument` | `Failed` |
| 6 | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `R2c-C2 routes a wrapper-led --body-file to the context check rather than the inline-body case` | `Failed` |
| 7 | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `R2c-N1 still routes a non-wrapper --body-file edit to the context check` | `Passed` |
| 8 | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `R2c-N2 still allows a quoted --body mention inside a JSON receipt value` | `Passed` |

Observed split: **4 non-passing, 4 passing**. That is the split `[P3-T4]` requires.

`R2b-C1`, `R2b-C2`, `R2c-C1`, and `R2c-C2` are the four regression cases and each records a
status other than `passed`. `R2b-C3`, `R2b-N1`, `R2c-N1`, and `R2c-N2` each pin behaviour that
is already correct and each records `Passed`.

`R2b-C3` passing before the fix is expected and is not evidence that R-2.b is absent: the gate
currently takes the whole wrapper-led command out of scope, so it allows, and the case asserts
allow. After Edit 4 it must still allow, but for the correct reason — the disposition is in
scope and the confirmation marker is found in the same segment. The case is a preservation pin
across both states.

## Per-suite counts

| Suite | tests | failures | errors |
|---|---|---|---|
| `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | 7 | 2 | 0 |
| `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | 22 | 2 | 0 |
| `enforce-parallel-abandon-gate.Tests.ps1` | 24 | 0 | 0 |
| `enforce-pr-author-skill.epic-base-branch.Tests.ps1` | 9 | 0 | 0 |
| `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | 3 | 0 | 0 |
| `enforce-pr-author-skill.Tests.ps1` | 43 | 1 | 0 |

## Folder-wide failures, all five named

1. `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` — `R2b-C1 denies the space-separated disposition carried inside a bash -c argument` (expected failure)
2. `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` — `R2b-C2 denies the equals-joined disposition carried inside a bash -c argument` (expected failure)
3. `enforce-pr-author-skill.TriggerScoping.Tests.ps1` — `R2c-C1 denies a gh pr edit inline body carried inside a bash -c argument` (expected failure)
4. `enforce-pr-author-skill.TriggerScoping.Tests.ps1` — `R2c-C2 routes a wrapper-led --body-file to the context check rather than the inline-body case` (expected failure)
5. `enforce-pr-author-skill.Tests.ps1` — `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` (tolerated row 1; pre-existing, not change-caused, not fixed here)

There is no folder-wide failure other than the four expected new ones and tolerated row 1.
Tolerated row 2 lives in `tests/scripts/codex-hooks` and is out of this scan's scope.

## Output Summary

Four non-passing and four passing across the eight new cases, which is the required split. The
four failures are the R-2.b and R-2.c regression cases: a wrapper's quoted argument collapses
into one token, so the abandon gate never sees the disposition option and the pr-author helper
reads both body flags absent. `errors` is 0 in every suite. Folder-wide failures are 5: the
four expected new failures plus tolerated row 1, all named above.
