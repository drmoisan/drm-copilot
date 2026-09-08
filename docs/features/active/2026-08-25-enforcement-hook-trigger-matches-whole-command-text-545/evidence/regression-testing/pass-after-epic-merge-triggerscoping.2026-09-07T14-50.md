# Pass-after — `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` (issue #545)

Timestamp: 2026-09-07T14-50

Task: [P9-T3], plus binding execution amendment EA-2

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `Invoke-Pester -Path <suite>` form. `pwsh`, `powershell`, and `cmd` are not invocable in
this session from any context, so the plan's direct `Invoke-Pester` form cannot run. Per-suite and
per-case results were read out of `artifacts/pester/pester-junit.xml`.

Timestamps in this artifact series are UTC, matching the convention already used by every earlier
artifact of this feature (verified by comparing `batch-b14-toolchain.2026-09-07T14-31.md` against its
own filesystem mtime).

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 1 (folder-wide failed-test count; see the reconciliation section)

## Suite this task owns

`tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`: **9 tests, 0 failures,
0 errors, 0 skipped.**

| # | Case | Source | Result |
| --- | --- | --- | --- |
| 1 | `returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag` | [P9-T3] | PASS |
| 2 | `returns null for a bare gh pr merge --merge that names no PR number` | [P9-T3] | PASS |
| 3 | `returns 410 for the positional spelling gh pr merge 410 --merge` | [P9-T3] | PASS |
| 4 | `returns 410 for the equals-joined spelling gh pr merge --merge=410` | [P9-T3] | PASS |
| 5 | `allows a printf whose double-quoted text mentions the gated merge phrase` | [P9-T3] | PASS |
| 6 | `keeps gh --repo drmoisan/drm-copilot pr merge --merge 688 in scope` | [P9-T3] | PASS |
| 7 | `takes the PR number from the merge operand 777, not from the authorized item number 501 in the cd path` | **EA-2** | PASS |
| 8 | `denies merging unauthorized PR 777 even though authorized item 501 appears earlier on the line` | **EA-2** | PASS |
| 9 | `still allows merging the authorized PR 501 when 501 is the merge operand` | **EA-2** | PASS |

Cases 1 through 6 are the six the plan task enumerates. Cases 7, 8, and 9 are the additional
false-allow-direction cases required by binding execution amendment EA-2; case 8 is the named
false-allow case, case 7 pins the extraction it depends on, and case 9 is its complement, confirming
the fix does not deny an authorized merge. The full EA-2 record, including the fixture item table and
the executed pre-change observation, is in
`evidence/regression-testing/ea2-false-allow-direction.2026-09-07T14-51.md`.

## EA-2 case, stated in full

- Case name: `denies merging unauthorized PR 777 even though authorized item 501 appears earlier on the line`
- Command text: `cd /repo/worktrees/501 && gh pr merge --merge 777`
- Fixture item table (parallel-orchestrator checkpoint, `route_id` = `parallel`):

| `item_id` | `pr_number` | `merge_status` | Authorized to merge? |
| --- | --- | --- | --- |
| `item-501` | 501 | `ci_green` | yes |
| `item-777` | 777 | `pr_open` | no |

- Observed decision after [P9-T1]: **deny**, reason matching `EPIC_MERGE_GATE_BLOCKED`.
- Observed extraction after [P9-T1]: **777**, the operand of the merge segment.

## Reconciliation of the folder-wide failure count

`tests/scripts/claude-hooks`: **1510 tests, 1 failure, 0 errors, 0 skipped.**

The single failure is `enforce-pr-author-skill.Tests.ps1`, case
`allows gh pr create --body-file artifacts/pr_body_12.md when context exists`. It is the documented
pre-existing, ambient-state-dependent baseline failure recorded in the appendix of
`evidence/regression-testing/known-red-inventory.2026-09-07T11-53.md`. It is not a member of the
known-red inventory and is out of scope for this change: the case does not mock
`Get-PrAuthorCheckpointContent`, so it reads this run's real orchestrator-state checkpoint, which
carries `epic_mode: true`, while the fixture command carries no `--base`. The hook denies correctly.

`hook-command-parser.AcceptanceCases.Tests.ps1` reports **11 tests, 0 failures** in this same run,
so known-red inventory rows 2 (AT-2) and 4 (AT-4) are closed. That closure is recorded formally under
[P9-T11].

`enforce-epic-merge-gate.Tests.ps1` reports **56 tests, 0 failures**, equal to its [P0-T10] baseline
passed count, so no pre-existing assertion in that suite was weakened.

Output Summary: the suite this task owns reports **9 tests / 0 failures**, covering the six cases the
plan enumerates plus the three EA-2 false-allow-direction cases. The EA-2 case
`denies merging unauthorized PR 777 even though authorized item 501 appears earlier on the line`
observes a **deny** decision against a two-item fixture in which 501 is authorized at `ci_green` and
777 is unauthorized at `pr_open`. Folder-wide the run is 1510 tests with 1 failure, which is the
documented pre-existing `enforce-pr-author-skill.Tests.ps1` case and not an inventory member. The
existing merge-gate suite is unchanged at 56 passing.
