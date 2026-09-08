# Pass-after — AT-2 and AT-4 close, known-red inventory reaches zero (issue #545)

Timestamp: 2026-09-07T15-06

Task: [P9-T11]

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `Invoke-Pester -Path <suite>` form, which is not invocable in this session because
`pwsh`, `powershell`, and `cmd` cannot be invoked from any context here. Per-suite and per-case
results were read out of `artifacts/pester/pester-junit.xml`.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 1 (folder-wide failed-test count; the suite this task measures contributes 0 of it)

## Suite result

`tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`: **11 tests, 0 failures,
0 errors, 0 skipped. Derived passed count: 11.**

All eleven named cases, read individually from the JUnit `testcase` elements:

| # | `It` name | Result |
| --- | --- | --- |
| 1 | `AT-1 denies a relocating git worktree remove against an epic checkpoint with no authorizing record` | PASS |
| 2 | `AT-2 returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag` | **PASS — closes inventory row 2** |
| 3 | `AT-3 allows a heredoc whose JSON body names promotion tools as receipt values` | PASS |
| 4 | `AT-4 allows a printf whose double-quoted text mentions the gated merge phrase` | **PASS — closes inventory row 4** |
| 5 | `AT-5 blocks a relocating gh issue create spelling that carries a repo global option` | PASS |
| 6 | `AT-6 still classifies a pwsh -Command wrapper carrying a test invocation` | PASS |
| 7 | `AT-7 resolves the worktree path when the force flag precedes it, in both removal gates` | PASS |
| 8 | `paired negative for AT-2: a bare gh pr merge --merge with no number still returns $null` | **PASS** |
| 9 | `paired negative for AT-2: the number-before-flag form gh pr merge 410 --merge still returns 410` | **PASS** |
| 10 | `paired negative for AT-3: a genuine promotion-script invocation still returns its blocked reason` | PASS |
| 11 | `paired negative for AT-5: a relocating gh issue list spelling still returns $null` | PASS |

Both AT-2 paired negatives pass, so the correction did not trade the fail-closed case for a
regression on the two spellings that already worked. AT-1 through AT-7 and all four paired negatives
pass, so the file reports zero failed tests, which is what this task's acceptance requires.

## Known-red inventory state after this task

The [P1-T13] inventory at `evidence/regression-testing/known-red-inventory.2026-09-07T11-53.md`
recorded 34 rows and a closure schedule reaching zero after Phase 9. The observed closure matches
that schedule exactly:

| After phase | Rows still red (planned) | Rows still red (observed) |
| --- | --- | --- |
| 1 | 34 | 34 |
| 5 | 6 | 6 |
| 6 | 4 | 4 |
| 8 | 2 | 2 |
| **9** | **0** | **0** |

**The known-red inventory is now empty.** Rows 2 (AT-2) and 4 (AT-4) were the last two, and both
closed in this task.

## Failures still present in the folder, and why none is an inventory member

`tests/scripts/claude-hooks`: 1510 tests, **1** failure.

- `enforce-pr-author-skill.Tests.ps1`, case
  `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`. Recorded in the
  inventory's appendix as a pre-existing baseline failure, explicitly excluded from the inventory
  union. Confirmed cause: the case does not mock `Get-PrAuthorCheckpointContent`, so it reads this
  run's real orchestrator-state checkpoint, which carries `epic_mode: true`, while the fixture command
  carries no `--base`. The hook denies correctly. Not repaired here; repairing it would require
  weakening an assertion or widening scope to fix the case's isolation, and neither is in scope.

On the Codex side, `tests/scripts/codex-hooks` reports 749 tests with 1 failure,
`codex-pretooluse-integration.Tests.ps1` case
`allows every registered handler for every tool name its own matcher admits`, likewise recorded in
the inventory appendix as an ambient-state case driven by this worktree's epic checkpoint.

Output Summary: `hook-command-parser.AcceptanceCases.Tests.ps1` reports **11 tests / 0 failures**, a
derived passed count of **11**. **AT-2 PASS** and **AT-4 PASS** close known-red inventory rows 2 and
4; both AT-2 paired negatives also pass. AT-1 through AT-7 and all four paired negatives pass, so the
suite is fully green. **The known-red inventory now stands at 0 of 34 rows remaining**, matching the
[P1-T13] closure schedule. The two failures still visible across the two hook folders are the
documented pre-existing, ambient-state-dependent cases recorded in that inventory's appendix, neither
of which is an inventory member.
