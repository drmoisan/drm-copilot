# Pass-after: AT-6 deny preservation (issue #545)

Timestamp: 2026-09-07T13-41

Task: [P5-T9]

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `Invoke-Pester -Path <suite>` form, which is not invocable in this session; per-test
results were read out of `artifacts/pester/pester-junit.xml`.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 7 (folder-wide failed-test count; the suite this task names contributes 6 of the 7)

## Suite result — `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`

| Measure | Value |
| --- | --- |
| tests | 11 |
| failures | 6 |
| errors | 0 |
| skipped | 0 |
| passed (derived) | 5 |

Per-case outcome, all eleven cases:

| Case | Result |
| --- | --- |
| AT-1 denies a relocating git worktree remove against an epic checkpoint with no authorizing record | FAIL |
| AT-2 returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag | FAIL |
| AT-3 allows a heredoc whose JSON body names promotion tools as receipt values | FAIL |
| AT-4 allows a printf whose double-quoted text mentions the gated merge phrase | FAIL |
| AT-5 blocks a relocating gh issue create spelling that carries a repo global option | FAIL |
| **AT-6 still classifies a pwsh -Command wrapper carrying a test invocation** | **PASS** |
| AT-7 resolves the worktree path when the force flag precedes it, in both removal gates | FAIL |
| paired negative for AT-2: a bare gh pr merge --merge with no number still returns $null | PASS |
| paired negative for AT-2: the number-before-flag form gh pr merge 410 --merge still returns 410 | PASS |
| paired negative for AT-3: a genuine promotion-script invocation still returns its blocked reason | PASS |
| paired negative for AT-5: a relocating gh issue list spelling still returns $null | PASS |

## AT-6 — the acceptance condition of this task

**AT-6 passes.** The assertion is

`Test-ImplementationCommand -Command 'pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"' | Should -BeTrue`

against the rewritten `Test-ImplementationCommand` in
`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`. This is the assertion that breaks
if the issue #539 D8 fail-open objection is answered wrongly, because it is the case in which a
governed command is carried inside a wrapper's quoted argument. It passes because `pwsh` is a member
of the wrapper carve-out set returned by `Get-CommandLineWrapperName`, so the segment's `ScanText`
resolves to `RawText` under the first clause of the D2 Piece 1 selection and the quoted argument
stays visible to trigger pattern index 4. Masking was not applied to a wrapper-led segment.

The same behaviour is pinned a second time in this change by wrapper deny pin 5 in
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`
and a third time by the pre-existing case `blocks formatter and test command payloads before
readiness` in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`,
both of which report zero failures in the same run ([P5-T3]).

## Remaining failing names, checked against the [P1-T13] known-red inventory

| Failing `It` name | Inventory row | Closed by phase |
| --- | --- | --- |
| AT-1 denies a relocating git worktree remove against an epic checkpoint with no authorizing record | 1 | 8 ([P8-T14]) |
| AT-2 returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag | 2 | 9 ([P9-T11]) |
| AT-3 allows a heredoc whose JSON body names promotion tools as receipt values | 3 | 6 ([P6-T9]) |
| AT-4 allows a printf whose double-quoted text mentions the gated merge phrase | 4 | 9 ([P9-T11]) |
| AT-5 blocks a relocating gh issue create spelling that carries a repo global option | 5 | 6 ([P6-T9]) |
| AT-7 resolves the worktree path when the force flag precedes it, in both removal gates | 6 | 8 ([P8-T14]) |

All six failing names are members of the known-red inventory, and none is a row that Phase 5 closes.
The remaining failing set is therefore a subset of the [P1-T13] inventory minus the rows closed by
this phase, which is the acceptance condition.

The seventh folder-wide failure, `allows gh pr create --body-file artifacts/pr_body_12.md when
context exists` in `enforce-pr-author-skill.Tests.ps1`, is the pre-existing baseline failure recorded
in the inventory appendix. It is outside the inventory union by design and is outside this task's
suite.

Output Summary: **AT-6 passes**, which is this task's acceptance condition; the deny direction for a
wrapper-carried governed command is preserved and the issue #539 D8 fail-open objection is answered
correctly. All four paired negatives also pass. The six failing names — AT-1, AT-2, AT-3, AT-4, AT-5,
AT-7 — are exactly known-red inventory rows 1 through 6, none of which Phase 5 closes, so the
remaining failing set is a proper subset of the inventory minus this phase's closures.
