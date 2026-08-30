# [P1-T2] PowerShell suite edit — three added `It` blocks

Timestamp: 2026-08-30T00-18

Task: [P1-T2] `[expect-fail]` of the cycle-1 remediation plan.

## Execution context

The plan states its commands worktree-relative. Each command was executed with the absolute prefix
`cd "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5" && ` prepended
to the plan's command text, which is recorded verbatim below.

## Step 1 — modification check

Command: `git status --porcelain tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`

EXIT_CODE: 0

Output Summary: ` M tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`. The file is
reported as modified.

## Step 2 — the three `It` titles

The three titles the phase preamble fixes verbatim are all present, each exactly once:

- `discards an absolute candidate path in a sibling directory whose name extends the root`
- `admits a candidate path that is exactly the resolved root`
- `falls through to the worktree-derived id when the session-id file is unreadable`

All three are inside the existing `Context 'session identity, containment, and rehydrate filter'`,
placed after the final pre-existing test in that context.

## Step 3 — file-size budget

Command: `pwsh -NoProfile -Command "(Get-Content -LiteralPath 'tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1').Count"`

EXIT_CODE: 0

Output Summary: `495`. Baseline recorded by [P0-T5] was `473`, so the addition is `+22`, matching the
plan's projected addition exactly. `495` is at most `500` and strictly greater than `473`, and it
equals the plan's predicted value, leaving the projected 5 lines of headroom.

### One correction made during authoring

The first authored form measured `496`. The B-3 call was already on one physical line, so the plan's
stated remedy for an over-495 measurement (rewrite the call in the one-line form) did not apply. The
single excess line was one blank separator inside the B-3 test body, between the
`$env:CLAUDE_SESSION_ID = ''` arrange line and the `Get-PowerShellBatchBudgetSessionId` act line.
Removing that separator produced the plan's 7-line shape for that test and the plan's projected
total of `495`. The blank separator preceding the assertion is retained, so the Assert boundary of
the Arrange-Act-Assert structure is preserved. No assertion, title, or argument was changed.

## Authored shapes

- Test 1 is modelled line for line on the pre-existing
  `discards an absolute candidate path outside the resolved root` test, with the candidate
  `/repo-sibling/scripts/tool.ps1`. The `.ps1` extension is mandatory because
  `Invoke-PowerShellBatchBudgetDecision` applies its `\.(ps1|psm1|psd1)$` scope filter before the
  containment check.
- Test 2 calls `Test-PowerShellBatchBudgetPathInRoot -Path '/repo' -Root '/repo'` directly and
  asserts the result is true. It is a regression guard against the D-1 edit narrowing behaviour and
  is not expected to fail before the fix.
- Test 3 calls `Get-PowerShellBatchBudgetSessionId` directly with a throwing `-ReadSessionIdFile`
  scriptblock, driving the catch block at `.claude/hooks/enforce-powershell-batch-budget.ps1:151-156`.
  It is not expected to fail before the fix. The call is authored on one physical line.

No temporary file is created and no real filesystem path is touched by any of the three tests. The
suite's existing `AfterEach` resets `$env:CLAUDE_SESSION_ID`, so test 3 leaves no cross-test state.

## Verdict

PASS. No suite split was required and no BLOCKED branch was taken.
