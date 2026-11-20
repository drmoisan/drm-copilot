# Batch B12 — batch toolchain gate (Claude `enforce-epic-worktree-removal-gate.ps1`, both copies)

Timestamp: 2026-09-07T14-18

Task: [P8-T5]

Batch B12 contents: production `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` and
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1`;
test `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1`.

The batch-budget counter for this batch additionally records
`tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1`, because a one-line
comment correction was applied to that file after the batch B11 reset. That correction is described
in `evidence/qa-gates/test-suite-line-count-pr-author.2026-09-07T14-11.md`: it replaces a stale
`482` line-count assertion in the file's docstring with the measured `447`. It changes no case, no
fixture, and no assertion. The batch therefore carries 2 production files and 2 test files, both
under the 3-and-3 cap in `.claude/rules/powershell.md`.

## Stage 1 — formatting

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Porcelain capture BEFORE the formatter (15 paths):

```
 M .claude/hooks/enforce-epic-worktree-removal-gate.ps1
 M .claude/hooks/enforce-pr-author-skill-helpers.ps1
 M .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b10-toolchain.2026-09-07T14-04.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b11-toolchain.2026-09-07T14-10.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/test-suite-line-count-pr-author.2026-09-07T14-11.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-epic-base-branch-existing-suite.2026-09-07T14-07.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-epic-worktree-existing-suite.2026-09-07T14-14.md
?? tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
?? tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1
?? tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1
```

Porcelain capture AFTER the formatter (15 paths): byte-identical to the capture above; the two
captures were compared line by line and no line differs.

**Set-difference count (paths in the after-set and absent from the before-set): 0.**

Corroborating observation beyond the exit code: the edited hook's SHA-256 is
`4c6920a4f254054a7675946f105baef5fb2ac63e21d40d09d8fcc981598eb346` both before and after the
formatter run — the same value recorded by the [P8-T2] mirror comparison — the new suite's is
`01aa3f6cef6e68bd23903415728b6408443dbe8be49d8a471bc3fbc790178acf`, and the corrected pr-author
suite's is `e4ae6f4baaaf2c0cc54980d52535510c50be719d6144ae7e18f2a231734275c9`, unchanged from the
value recorded when the correction was made. The formatter neither created a path nor rewrote a file
in this batch, so no restart from stage 1 was required.

## Stage 2 — linting

Command: `mcp__drm-copilot__run_poshqc_analyze` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Result: `ok: true`, equivalent to a repository-wide total of **0** diagnostics.

| Measure | Value |
| --- | --- |
| Error-severity diagnostics on the files this batch touched | 0 |
| Repository-wide total | 0 |
| [P0-T6] baseline repository-wide total | 0 |
| At or below baseline? | yes (equal) |

## Stage 3 — targeted Pester over the test file this batch owns

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `Invoke-Pester -Path <suite>` form, which is not invocable in this session; per-suite
results were read out of `artifacts/pester/pester-junit.xml`. The run was executed after stages 1
and 2.

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 4 (folder-wide failed-test count)

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1` (owned by this batch) | 5 | **0** | 0 | 0 |
| `enforce-pr-author-skill.TriggerScoping.Tests.ps1` (comment correction) | 18 | **0** | 0 | 0 |
| `enforce-epic-worktree-removal-gate.Tests.ps1` | 46 | **0** | 0 | 0 |
| `enforce-parallel-worktree-removal-gate.Tests.ps1` | 45 | **0** | 0 | 0 |

All five cases in the suite this batch owns pass:

| Case | Result |
| --- | --- |
| denies git -C /repo/main worktree remove against a checkpoint with no authorizing record | PASS |
| resolves the operand when --force precedes the path | PASS |
| resolves the same operand when --force follows the path | PASS |
| allows a command whose quoted text merely mentions the removal phrase | PASS |
| keeps git worktree list out of scope | PASS |

`enforce-parallel-worktree-removal-gate.Tests.ps1` is recorded because [P8-T1] left that hook's own
copy of the duplicated operand logic untouched, so its 45 cases confirm the sibling gate is
unaffected by this batch. It is fixed in batch B14.

### Reconciliation of the folder-wide failure count

`tests/scripts/claude-hooks`: 1498 tests, **4** failures, 0 errors, 0 skipped. The count fell from 5
at the batch B11 gate because inventory row 1 closed.

- 3 from `hook-command-parser.AcceptanceCases.Tests.ps1`: `AT-2`, `AT-4`, and `AT-7` — rows 2, 4, and
  6 of the [P1-T13] known-red inventory. AT-7 remains red because its `It` asserts
  `Get-ParallelWorktreeRemovalCommandPath` FIRST and that extractor is not fixed until [P8-T10];
  the `Get-EpicWorktreeRemovalCommandPath` half of the same case is already satisfied, as the two
  operand cases in this batch's own suite show. AT-2 and AT-4 close in [P9-T11].
- 1 from `enforce-pr-author-skill.Tests.ps1`, case
  `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` — the documented
  pre-existing, ambient-state-dependent baseline failure, unchanged.

Inventory row 1, `AT-1 denies a relocating git worktree remove against an epic checkpoint with no
authorizing record`, now passes. It is formally closed at [P8-T14].

## Batch-level parity

| File | SHA-256 | Lines |
| --- | --- | --- |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | `4c6920a4f254054a7675946f105baef5fb2ac63e21d40d09d8fcc981598eb346` | 447 |
| `extensions/.../claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | `4c6920a4f254054a7675946f105baef5fb2ac63e21d40d09d8fcc981598eb346` | 447 |

Equal, and both at or under the 500-line cap. The new test suite measures 107 lines.

## Downstream-contract check

Epic child D edits this hook next, so the diff was checked against the plan's confinement
requirement. `git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- .claude/hooks/enforce-epic-worktree-removal-gate.ps1`
shows four hunks: two dot-source lines with their comment, placed immediately after the existing
`Import-Module` line in the file's import region; a documentation and body change inside
`Get-EpicWorktreeRemovalCommandPath`; and the scope-filter change inside
`Invoke-EpicWorktreeRemovalGateDecision`. No other function is touched. The `EPIC_WORKTREE_REMOVAL_BLOCKED`
reason string is byte-unchanged, and `Get-EpicWorktreeRemovalCommandPath` keeps its function name,
its single `[Parameter(Mandatory)][string] $CommandText` signature, and its `$null`-on-miss contract,
which the two pre-existing helper cases in `enforce-epic-worktree-removal-gate.Tests.ps1` still pin.
The import-region hunk sits outside both named functions; it is the mechanically necessary import
that those two functions consume, and it is recorded here rather than absorbed silently.

## Batch budget reset (closes B12, opens B13)

Resolved session id: `worktree-agent-a478b73e41951af31-e3281c7b`. Cross-checked against the files
actually present in `.claude/state/`, which held exactly one file,
`powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json`.

Pre-reset counter contents:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    ".../.claude/hooks/enforce-epic-worktree-removal-gate.ps1"
  ],
  "testFiles": [
    ".../tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1",
    ".../tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1"
  ]
}
```

The bundle mirror is absent from the counter because it was written with `cp`, which does not pass
through the PreToolUse hook.

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

Post-reset listing of `.claude/state/`: the directory exists and contains no files.

Output Summary: batch B12 toolchain gate PASSES in a single pass. Stage 1 formatting exited 0 with a
set-difference count of **0**; the before and after porcelain captures are identical and all three
touched files' SHA-256 values are unchanged across the run. Stage 2 analyze returned `ok: true`,
equal to **0** repository-wide diagnostics and equal to the [P0-T6] baseline of 0. Stage 3 reports
**5 tests / 0 failures** for the suite this batch owns, plus 46 and 45 passing cases for the two
existing removal-gate suites. The folder-wide count is 1498 tests with 4 failures, down from 5,
because known-red inventory row 1 (AT-1) closed: the remainder is three inventory rows (AT-2, AT-4,
AT-7) and the documented pre-existing `enforce-pr-author-skill` baseline failure. No stage failed and
no stage rewrote a file, so no restart from stage 1 was required. The closing batch-budget reset
exited 0.
