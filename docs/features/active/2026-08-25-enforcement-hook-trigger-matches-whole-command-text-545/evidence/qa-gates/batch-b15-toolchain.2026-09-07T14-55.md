# Batch B15 — batch toolchain gate (Claude `enforce-epic-merge-gate.ps1`, both copies)

Timestamp: 2026-09-07T14-55

Task: [P9-T5]

Batch B15 contents: production `.claude/hooks/enforce-epic-merge-gate.ps1` and
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`;
test `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`.

## Stage 1 — formatting

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Porcelain capture BEFORE the formatter (7 paths):

```
 M .claude/hooks/enforce-epic-merge-gate.ps1
 M docs/features/active/.../plan.2026-08-25T08-13.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1
?? docs/features/active/.../evidence/regression-testing/ea2-false-allow-direction.2026-09-07T14-52.md
?? docs/features/active/.../evidence/regression-testing/pass-after-epic-merge-existing-suite.2026-09-07T14-54.md
?? docs/features/active/.../evidence/regression-testing/pass-after-epic-merge-triggerscoping.2026-09-07T14-50.md
?? tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1
```

Porcelain capture AFTER the formatter (7 paths):

```
 M .claude/hooks/enforce-epic-merge-gate.ps1
 M docs/features/active/.../plan.2026-08-25T08-13.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1
?? docs/features/active/.../evidence/regression-testing/ea2-false-allow-direction.2026-09-07T14-52.md
?? docs/features/active/.../evidence/regression-testing/pass-after-epic-merge-existing-suite.2026-09-07T14-54.md
?? docs/features/active/.../evidence/regression-testing/pass-after-epic-merge-triggerscoping.2026-09-07T14-50.md
?? tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1
```

The feature paths are abbreviated to `docs/features/active/.../` for width; their full prefix is
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/`. The
porcelain path count is 7 both before and after.

**Set-difference count (paths in the after-set and absent from the before-set): 0.** The set
difference was computed mechanically with `comm -13` over the two sorted captures, not by eye.

Corroborating observation beyond the exit code: the edited hook's SHA-256 is
`71e89258f7461ca21e090a75e2d8722f8f6be576c586ac834635a87e36518abf` both before and after the
formatter run — the same value recorded by the [P9-T2] mirror comparison. The formatter neither
created a path nor rewrote a file in this batch, so no restart from stage 1 was required.

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
and per-case results were read out of `artifacts/pester/pester-junit.xml`. The run was executed after
stages 1 and 2.

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 1 (folder-wide failed-test count)

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` (owned by this batch) | 9 | **0** | 0 | 0 |
| `enforce-epic-merge-gate.Tests.ps1` | 56 | **0** | 0 | 0 |
| `hook-command-parser.AcceptanceCases.Tests.ps1` | 11 | **0** | 0 | 0 |

All nine cases in the suite this batch owns pass:

| Case | Result |
| --- | --- |
| returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag | PASS |
| returns null for a bare gh pr merge --merge that names no PR number | PASS |
| returns 410 for the positional spelling gh pr merge 410 --merge | PASS |
| returns 410 for the equals-joined spelling gh pr merge --merge=410 | PASS |
| allows a printf whose double-quoted text mentions the gated merge phrase | PASS |
| keeps gh --repo drmoisan/drm-copilot pr merge --merge 688 in scope | PASS |
| takes the PR number from the merge operand 777, not from the authorized item number 501 in the cd path (EA-2) | PASS |
| denies merging unauthorized PR 777 even though authorized item 501 appears earlier on the line (EA-2) | PASS |
| still allows merging the authorized PR 501 when 501 is the merge operand (EA-2) | PASS |

### Reconciliation of the folder-wide failure count

`tests/scripts/claude-hooks`: 1510 tests, **1** failure, 0 errors, 0 skipped. The count fell from 3
at the batch B14 gate because known-red inventory rows 2 (AT-2) and 4 (AT-4) both closed in this
phase.

- 0 from `hook-command-parser.AcceptanceCases.Tests.ps1`: the suite is now fully green, so the
  [P1-T13] known-red inventory has **0 rows remaining**.
- 1 from `enforce-pr-author-skill.Tests.ps1`, case
  `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` — the documented
  pre-existing, ambient-state-dependent baseline failure recorded in the inventory's appendix. Its
  confirmed cause is that the case does not mock `Get-PrAuthorCheckpointContent`, so it reads this
  run's real orchestrator-state checkpoint, which carries `epic_mode: true`, while the fixture command
  carries no `--base`. The hook denies correctly. It is out of scope for this change.

Every failing name is accounted for by the inventory appendix. No name outside that set fails.

## Batch-level parity

| File | SHA-256 | Lines |
| --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | `71e89258f7461ca21e090a75e2d8722f8f6be576c586ac834635a87e36518abf` | 472 |
| `extensions/.../claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | `71e89258f7461ca21e090a75e2d8722f8f6be576c586ac834635a87e36518abf` | 472 |

Equal, and both at or under the 500-line cap. The file was 451 lines before this work and is 472
after, a rise of 21 lines, so no addition needed relocating to a parser sibling. The new test suite
measures 133 lines and hashes to
`f5b883babfdea67ee45e951d0d59674699654c8a80165fe18ff14c4b66857c12`.

## Batch budget reset (closes B15, opens B16)

Resolved session id: `worktree-agent-a478b73e41951af31-e3281c7b`. Cross-checked against the files
actually present in `.claude/state/`, which held exactly one file,
`powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json`.

Pre-reset counter contents:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    ".../.claude/hooks/enforce-epic-merge-gate.ps1"
  ],
  "testFiles": [
    ".../tests/scripts/claude-hooks/ea2-prechange-observation.Tests.ps1",
    ".../tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1"
  ]
}
```

The bundle mirror is absent from the counter because it was written with `cp`, which does not pass
through the PreToolUse hook. `ea2-prechange-observation.Tests.ps1` is the throwaway suite created and
deleted within this session to make the EA-2 pre-change observation an executed run rather than a
derivation; it is recorded here because the counter retains it, and it is no longer on disk. Batch
B15's delivered file count is 2 production and 1 test file, under the 3-and-3 cap.

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

Post-reset listing of `.claude/state/`: the directory exists and contains no files. This reset opens
batch B16.

Output Summary: batch B15 toolchain gate PASSES in a single pass. Stage 1 formatting exited 0 with a
set-difference count of **0**; the porcelain path count is 7 before and after, and the edited hook's
SHA-256 is unchanged across the run. Stage 2 analyze returned `ok: true`, equal to **0**
repository-wide diagnostics and equal to the [P0-T6] baseline of 0. Stage 3 reports
**9 tests / 0 failures** for the suite this batch owns, and 56 passing for the existing merge-gate
suite. The folder-wide count is 1510 tests with 1 failure, down from 3, because known-red inventory
rows 2 and 4 both closed; the remaining failure is the documented pre-existing
`enforce-pr-author-skill.Tests.ps1` case. Both hook copies hash equal at 472 lines, under the 500-line
cap. No stage failed and no stage rewrote a file, so no restart from stage 1 was required. The closing
batch-budget reset exited 0.
