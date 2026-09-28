# Pass-after — R-2.a merge-gate scope filter — [P2-T8]

Timestamp: 2026-09-07T21-43

Task: `[P2-T8]` — re-run the `[P2-T4]` command after Edit 2 and Edit 3 and record the
pass-after state.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`
and `scan_folders=["tests/scripts/claude-hooks","tests/scripts/codex-hooks"]`

EXIT_CODE: 2

ExpectedExitCode: 2

The exit code is the folder-wide failed-test count, which is 2 because of the two pre-existing
tolerated failures named below. It fell from 4 at `[P2-T4]` to 2 here, which is exactly the two
R-2.a regression cases turning green. Acceptance is read from `artifacts/pester/pester-junit.xml`
per-case `status` attributes, never from this exit code.

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session, so
Pester was not run directly. The substitute route is the MCP function
`mcp__drm-copilot__run_poshqc_test`, with per-suite `<testsuite>` counts and per-case `status`
attributes read out of `artifacts/pester/pester-junit.xml`.

## Root totals

`<testsuites name="Pester" tests="2396" errors="0" failures="2">`

## The five new cases — all five now pass

| # | Suite | It name | status |
|---|---|---|---|
| 1 | `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | `R2a-C1 denies a gh pr merge --merge carried inside a bash -c argument` | `Passed` |
| 2 | `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | `R2a-N1 still allows a commit message quoting the merge phrase and the merge flag` | `Passed` |
| 3 | `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | `R2a-N2 keeps a gh pr merge --merge relocated through xargs in scope` | `Passed` |
| 4 | `enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | `R2a-X1 denies a gh pr merge --merge carried inside a bash -c argument` | `Passed` |
| 5 | `enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | `R2a-X2 still allows a commit message quoting the merge phrase and the merge flag` | `Passed` |

## Preservation rows — the AT-4 paired negative the reaudit requires

These are pre-existing `It` names that the edit must not disturb. A non-passing row on any of
them would mean an existing allow was turned into a deny, or an existing extraction was broken.

### Claude, `Context 'PR-number extraction comes from the matched segment only'` — four rows

| It name | status |
|---|---|
| `returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag` | `Passed` |
| `returns null for a bare gh pr merge --merge that names no PR number` | `Passed` |
| `returns 410 for the positional spelling gh pr merge 410 --merge` | `Passed` |
| `returns 410 for the equals-joined spelling gh pr merge --merge=410` | `Passed` |

### Claude, the existing scope-filter negative

| It name | status |
|---|---|
| `allows a printf whose double-quoted text mentions the gated merge phrase` | `Passed` |

### Codex, the existing scope-filter negative

| It name | status |
|---|---|
| `allows a quoted mention of the gated merge phrase` | `Passed` |

### Claude, `Context 'the false-allow direction of the whole-line PR-number defect'` — three rows

| It name | status |
|---|---|
| `takes the PR number from the merge operand 777, not from the authorized item number 501 in the cd path` | `Passed` |
| `denies merging unauthorized PR 777 even though authorized item 501 appears earlier on the line` | `Passed` |
| `still allows merging the authorized PR 501 when 501 is the merge operand` | `Passed` |

**The EA-2 binding case explicitly: `denies merging unauthorized PR 777 even though authorized
item 501 appears earlier on the line` records `Passed`.** Execution amendment EA-2 makes that
case binding on this feature, and a non-passing row on it would block this phase. It passes.

The three rows in that Context depend on `Get-EpicMergeGateCommandPrNumber`, which Edit 2 leaves
byte-unchanged. That function is also fail-closed-correct call site 5, verified unchanged in
`[P2-T5]`: `git diff` against the cycle-scope anchor
`26dba29533ba70f6cd80d14ac3c87ac24ca82aca` for `.claude/hooks/enforce-epic-merge-gate.ps1`
reports `14 insertions(+)` and zero deletions, so no existing line in that file was removed or
altered.

## Per-suite counts

| Suite | tests | failures | errors |
|---|---|---|---|
| `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 12 | 0 | 0 |
| `enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | 7 | 0 | 0 |
| `enforce-epic-merge-gate.Tests.ps1` | 56 | 0 | 0 |
| `enforce-epic-merge-gate-decision-surface.Tests.ps1` | 13 | 0 | 0 |

`failures` and `errors` are 0 for both edited suites and for both unedited merge-gate suites.

## Folder-wide failures — both tolerated, named

1. `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` — `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` (tolerated row 1)
2. `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` — `allows every registered handler for every tool name its own matcher admits` (tolerated row 2)

There are zero failures other than those two. Neither is fixed by this cycle and neither is
change-caused.

## Output Summary

All five new R-2.a rows record `Passed`. All nine preservation rows record `Passed`, including
the EA-2 binding case `denies merging unauthorized PR 777 even though authorized item 501
appears earlier on the line`. Per-suite `failures` and `errors` are 0 for all four merge-gate
suites. The only folder-wide failures are the two tolerated rows, so the folder-wide failed
count fell from 4 to 2 and the delta is exactly the two R-2.a regression cases.
