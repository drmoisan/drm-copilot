# Pass-after — R-2.b and R-2.c — [P3-T9]

Timestamp: 2026-09-07T21-58

Task: `[P3-T9]` — re-run the `[P3-T4]` command after Edit 4 and Edit 5 and record the pass-after
state.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`
and `scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 1

ExpectedExitCode: 1

The exit code is the folder-wide failed-test count, which is 1 because of the single tolerated
failure in this folder. It fell from 5 at `[P3-T4]` to 1 here, which is exactly the four R-2.b
and R-2.c regression cases turning green. Acceptance is read from
`artifacts/pester/pester-junit.xml` per-case `status` attributes, never from this exit code.

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session, so
Pester was not run directly. The substitute route is the MCP function
`mcp__drm-copilot__run_poshqc_test`, with per-suite `<testsuite>` counts and per-case `status`
attributes read out of `artifacts/pester/pester-junit.xml`.

## Root totals

`<testsuites name="Pester" tests="1541" errors="0" failures="1">`

## The eight new cases — all eight now pass

| # | Suite | It name | status |
|---|---|---|---|
| 1 | `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | `R2b-C1 denies the space-separated disposition carried inside a bash -c argument` | `Passed` |
| 2 | `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | `R2b-C2 denies the equals-joined disposition carried inside a bash -c argument` | `Passed` |
| 3 | `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | `R2b-C3 allows a wrapper-led abandon carrying the confirmation marker in the same segment` | `Passed` |
| 4 | `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | `R2b-N1 still allows a commit message quoting the disposition token` | `Passed` |
| 5 | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `R2c-C1 denies a gh pr edit inline body carried inside a bash -c argument` | `Passed` |
| 6 | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `R2c-C2 routes a wrapper-led --body-file to the context check rather than the inline-body case` | `Passed` |
| 7 | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `R2c-N1 still routes a non-wrapper --body-file edit to the context check` | `Passed` |
| 8 | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `R2c-N2 still allows a quoted --body mention inside a JSON receipt value` | `Passed` |

## Preservation rows — twenty-one pre-existing `It` names

A non-passing row on any of the twenty-one below blocks this phase. All twenty-one record
`Passed`.

### `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` — three rows

| # | It name | status |
|---|---|---|
| 1 | `AT-11 takes a grep whose quoted search term is the disposition token out of scope` | `Passed` |
| 2 | `AT-12 brings the equals-joined spelling of the disposition option into scope` | `Passed` |
| 3 | `does not accept a confirmation marker that sits in a different segment from the disposition token` | `Passed` |

Row 1 is the case Edit 4's raw-scan leg could most plausibly have broken, because the fixture is
a `grep` whose quoted search term is the disposition token. It still allows: the `grep` segment
is not wrapper-led, carries no live substitution, and is balanced, so the raw-scan predicate
reports `$false` and the leg never runs on it.

Row 3 pins the same-segment requirement for the confirmation marker, which Edit 4c preserves:
both the disposition and the confirmation marker must be found in the same segment record.

### `enforce-pr-author-skill.TriggerScoping.Tests.ps1` — eighteen rows

| # | Context | It name | status |
|---|---|---|---|
| 1 | over-match removal | `allows a quoted --body-file mention inside a JSON receipt value` | `Passed` |
| 2 | under-match removal | `classifies gh --repo drmoisan/drm-copilot pr create --body-file artifacts/pr_body_545.md` | `Passed` |
| 3 | under-match removal | `classifies gh -R drmoisan/drm-copilot pr edit --body-file artifacts/pr_body_545.md` | `Passed` |
| 4 | flag distinction | `does not match --body against a --body-file token` | `Passed` |
| 5 | wrapper deny pins | `wrapper deny pin 1: classifies a gh pr create relocated through xargs` | `Passed` |
| 6 | wrapper deny pins | `wrapper deny pin 2: classifies a gh pr create nested inside a bash -c argument` | `Passed` |
| 7 | wrapper deny pins | `wrapper deny pin 3: classifies a gh pr create nested inside an sh -c argument` | `Passed` |
| 8 | wrapper deny pins | `wrapper deny pin 4: classifies a gh pr create behind the env transparent wrapper` | `Passed` |
| 9 | wrapper deny pins | `wrapper deny pin 5: classifies a gh pr create behind the pwsh -Command wrapper` | `Passed` |
| 10 | wrapper deny pins | `wrapper deny pin 6: classifies a heredoc body piped into bash` | `Passed` |
| 11 | wrapper deny pins | `wrapper deny pin 7: classifies a live substitution inside a double-quoted span` | `Passed` |
| 12 | every PR_* reason code | `PR_AUTHOR_SKILL_BLOCKED for gh pr create with no body flag` | `Passed` |
| 13 | every PR_* reason code | `PR_CONTEXT_MISSING for gh pr create --body-file when the context artifact is absent` | `Passed` |
| 14 | every PR_* reason code | `PR_BODY_PATH_NONCANONICAL for a --body-file path outside the canonical pattern` | `Passed` |
| 15 | every PR_* reason code | `PR_AUTHOR_RECEIPT_MISSING when the sibling receipt is absent` | `Passed` |
| 16 | every PR_* reason code | `PR_AUTHOR_RECEIPT_NUMBER_MISMATCH when the receipt number does not equal the path number` | `Passed` |
| 17 | every PR_* reason code | `PR_AUTHOR_RECEIPT_HASH_MISMATCH when the body hash does not equal the recorded hash` | `Passed` |
| 18 | every PR_* reason code | `PR_AUTHOR_RECEIPT_STALE when created_at is not newer than the context last-write` | `Passed` |

That is the seven wrapper deny pins (rows 5–11), the seven `PR_*` reason-code cases
(rows 12–18), and `allows a quoted --body-file mention inside a JSON receipt value` (row 1),
plus the three remaining pre-existing rows 2, 3, and 4. Eighteen rows in total, all `Passed`.

Total preservation rows: 3 + 18 = **21, all `Passed`**.

## Per-suite counts

| Suite | tests | failures | errors |
|---|---|---|---|
| `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | 7 | 0 | 0 |
| `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | 22 | 0 | 0 |
| `enforce-parallel-abandon-gate.Tests.ps1` | 24 | 0 | 0 |
| `enforce-pr-author-skill.epic-base-branch.Tests.ps1` | 9 | 0 | 0 |
| `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | 3 | 0 | 0 |

`failures` and `errors` are 0 for both edited suites and for the three named unedited suites.

## Folder-wide failures

One, and it is tolerated row 1:
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` It
`allows gh pr create --body-file artifacts/pr_body_12.md when context exists`. It is
pre-existing, not change-caused, and not fixed by this cycle. There is no other failure in the
folder. Tolerated row 2 lives in `tests/scripts/codex-hooks` and is out of this scan's scope.

## Output Summary

All eight new R-2.b and R-2.c rows record `Passed`. All twenty-one preservation rows record
`Passed`: three in the abandon suite and eighteen in the pr-author trigger-scoping suite. Both
edited suites and the three named unedited suites report `failures` 0 and `errors` 0. The only
folder-wide failure is tolerated row 1, so the folder-wide failed count fell from 5 to 1 and the
delta is exactly the four regression cases.
