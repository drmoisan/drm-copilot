# Fail-before — R-2.a merge-gate scope filter — [P2-T4]

Timestamp: 2026-09-07T21-37

Task: `[P2-T4]` `[expect-fail]` — record the pre-change state of the five new merge-gate cases.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`
and `scan_folders=["tests/scripts/claude-hooks","tests/scripts/codex-hooks"]`

EXIT_CODE: 4

ExpectedExitCode: 4

The exit code is the folder-wide failed-test count across the two scanned folders, not a
pass/fail signal. It is 4 here: the two R-2.a regression cases below plus the two pre-existing
tolerated failures. Acceptance for this task is read from `artifacts/pester/pester-junit.xml`
per-case `status` attributes, never from this exit code.

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session, so
Pester was not run directly. The substitute route is the MCP function
`mcp__drm-copilot__run_poshqc_test`, with per-suite `<testsuite>` counts and per-case `status`
attributes read out of `artifacts/pester/pester-junit.xml`.

## Root totals

`<testsuites name="Pester" tests="2396" errors="0" failures="4" disabled="0" time="114.188">`

## The five new cases

| # | Suite | It name | status |
|---|---|---|---|
| 1 | `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | `R2a-C1 denies a gh pr merge --merge carried inside a bash -c argument` | `Failed` |
| 2 | `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | `R2a-N1 still allows a commit message quoting the merge phrase and the merge flag` | `Passed` |
| 3 | `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | `R2a-N2 keeps a gh pr merge --merge relocated through xargs in scope` | `Passed` |
| 4 | `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | `R2a-X1 denies a gh pr merge --merge carried inside a bash -c argument` | `Failed` |
| 5 | `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | `R2a-X2 still allows a commit message quoting the merge phrase and the merge flag` | `Passed` |

Observed split: **2 non-passing, 3 passing**. That is the split `[P2-T4]` requires. `R2a-C1`
and `R2a-X1` are the two R-2.a regression cases and both record a status other than `passed`.
`R2a-N1`, `R2a-N2`, and `R2a-X2` each pin behaviour that is already correct and each records
`Passed`.

`R2a-N2` passing before the fix is the expected observation, not an anomaly. `|` is a segment
delimiter, so the fixture's second segment is `xargs gh pr merge --merge`; `xargs` is a wrapper
name, so the segment is wrapper-led and is already matched by raw containment; and nothing in
that segment is quoted, so `--merge` is already a plain token that the token loop already reads.
The command already denies today and this case pins that it keeps denying.

## Per-suite counts

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 12 | 1 | 0 | 0 |
| `enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | 7 | 1 | 0 | 0 |
| `enforce-epic-merge-gate.Tests.ps1` | 56 | 0 | 0 | 0 |
| `enforce-epic-merge-gate-decision-surface.Tests.ps1` | 13 | 0 | 0 | 0 |

## Folder-wide failures, all four named

1. `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` — `R2a-C1 denies a gh pr merge --merge carried inside a bash -c argument` (this task's expected failure)
2. `enforce-epic-merge-gate-trigger-scoping.Tests.ps1` — `R2a-X1 denies a gh pr merge --merge carried inside a bash -c argument` (this task's expected failure)
3. `enforce-pr-author-skill.Tests.ps1` — `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` (tolerated row 1; pre-existing, not change-caused, not fixed here)
4. `codex-pretooluse-integration.Tests.ps1` — `allows every registered handler for every tool name its own matcher admits` (tolerated row 2; pre-existing, not change-caused, not fixed here)

There is no folder-wide failure other than the two new expected ones and the two tolerated rows.

## Output Summary

Two non-passing and three passing across the five new R-2.a cases, which is the required split.
`R2a-C1` and `R2a-X1` fail because a wrapper's quoted argument collapses into one token, so
`Test-CommandLineFlag` reports `--merge` absent and the scope filter allows the command. Both
edited suites record `errors` 0. Folder-wide failures are 4: the two expected new failures plus
the two tolerated pre-existing rows, both named above.
