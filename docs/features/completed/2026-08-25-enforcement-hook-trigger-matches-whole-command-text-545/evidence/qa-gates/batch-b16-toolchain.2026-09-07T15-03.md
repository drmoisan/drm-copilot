# Batch B16 — batch toolchain gate (Codex `enforce-epic-merge-gate.ps1`, both copies)

Timestamp: 2026-09-07T15-03

Task: [P9-T10]

Batch B16 contents: production `.codex/hooks/enforce-epic-merge-gate.ps1` and
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`;
test `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1`.

## Stage 1 — formatting

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Porcelain capture BEFORE the formatter (12 paths):

```
 M .claude/hooks/enforce-epic-merge-gate.ps1
 M .codex/hooks/enforce-epic-merge-gate.ps1
 M docs/features/active/.../plan.2026-08-25T08-13.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1
?? docs/features/active/.../evidence/qa-gates/batch-b15-toolchain.2026-09-07T14-55.md
?? docs/features/active/.../evidence/qa-gates/codex-merge-gate-no-digit-scan.2026-09-07T14-59.md
?? docs/features/active/.../evidence/regression-testing/ea2-false-allow-direction.2026-09-07T14-51.md
?? docs/features/active/.../evidence/regression-testing/pass-after-epic-merge-existing-suite.2026-09-07T14-51.md
?? docs/features/active/.../evidence/regression-testing/pass-after-epic-merge-triggerscoping.2026-09-07T14-50.md
?? tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1
?? tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
```

Porcelain capture AFTER the formatter: the same 12 paths, in the same order.

The feature paths are abbreviated to `docs/features/active/.../` for width; their full prefix is
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/`. Both
captures were taken with `git status --porcelain` and the path count is 12 before and after. The two
evidence filenames shown above are the corrected ones; see the timestamp-correction note at the end
of this artifact.

**Set-difference count (paths in the after-set and absent from the before-set): 0.** Computed
mechanically with `comm -13` over the two sorted captures.

Corroborating observation beyond the exit code: the edited Codex hook's SHA-256 is
`11169c09014b1b9165cba04bf4e2a335d467205d6928f4aa2cd98141dc71e4f4` both before and after the
formatter run — the same value recorded by the [P9-T7] mirror comparison. The formatter neither
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

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/codex-hooks"]`

EXIT_CODE: 1 (folder-wide failed-test count)

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `enforce-epic-merge-gate-trigger-scoping.Tests.ps1` (owned by this batch) | 5 | **0** | 0 | 0 |
| `legacy-codex-hook-contracts.Tests.ps1` | 43 | **0** | 0 | 0 |
| `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | 23 | **0** | 0 | 0 |
| `enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1` | 5 | **0** | 0 | 0 |

All five cases in the suite this batch owns pass:

| Case | Result |
| --- | --- |
| resolves 410 for the positional spelling gh pr merge 410 --merge | PASS |
| resolves 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag | PASS |
| returns null for a bare gh pr merge --merge that names no PR number | PASS |
| allows a quoted mention of the gated merge phrase | PASS |
| keeps a real gh pr merge --merge invocation in scope and denies it without a checkpoint | PASS |

`legacy-codex-hook-contracts.Tests.ps1` at **43 tests / 0 failures** carries the four Codex-side
contract checks the [P0-T12] baseline named: byte identity between each `.codex` file and its bundle
mirror, pack-manifest completeness, parse success, and the 500-line cap. All four remain green with
the edited hook in place, which independently confirms the [P9-T7] mirror.

### Reconciliation of the folder-wide failure count

`tests/scripts/codex-hooks`: 749 tests, **1** failure, 0 errors, 0 skipped.

- 1 from `codex-pretooluse-integration.Tests.ps1`, case
  `allows every registered handler for every tool name its own matcher admits`. This is the
  documented pre-existing, ambient-state-dependent baseline failure recorded in the appendix of
  `evidence/regression-testing/known-red-inventory.2026-09-07T11-53.md`:
  `enforce-epic-wave-barrier.ps1` denies with `EPIC_WAVE_BARRIER_BLOCKED` because the epic checkpoint
  in this worktree names item `545` with unmerged `depends_on` edges. It is driven by this worktree's
  live epic checkpoint, not by this change, and is out of scope.

The [P1-T13] known-red inventory contributes **0** failures on the Codex side. No name outside the
inventory appendix fails.

## Batch-level parity

| File | SHA-256 | Lines |
| --- | --- | --- |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | `11169c09014b1b9165cba04bf4e2a335d467205d6928f4aa2cd98141dc71e4f4` | 174 |
| `extensions/.../codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | `11169c09014b1b9165cba04bf4e2a335d467205d6928f4aa2cd98141dc71e4f4` | 174 |

Equal, and both at or under the 500-line cap. The file was 140 lines before this work and is 174
after. The new test suite measures 86 lines and hashes to
`a6e531659c66188c7157c05e4ee1fc7f0034fda85ed399fb0410cf43a64e1488`.

## Phase 9 file-size summary

| File | Lines | At or under 500? |
| --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 472 | yes |
| `extensions/.../claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | 472 | yes |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 174 | yes |
| `extensions/.../codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | 174 | yes |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 133 | yes |
| `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | 86 | yes |

The Claude copy was 451 lines before this work, which the delegation flagged as the file to watch.
It rose by 21 lines to 472, so the addition did not need relocating to a parser sibling.

## Batch budget reset (closes B16, opens B17)

Resolved session id: `worktree-agent-a478b73e41951af31-e3281c7b`. Cross-checked against the files
actually present in `.claude/state/`, which held exactly one file,
`powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json`.

Pre-reset counter contents:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    ".../.codex/hooks/enforce-epic-merge-gate.ps1"
  ],
  "testFiles": [
    ".../tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1"
  ]
}
```

The bundle mirror is absent from the counter because it was written with `cp`, which does not pass
through the PreToolUse hook. Batch B16's real file count is 2 production and 1 test file, under the
3-and-3 cap.

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

Post-reset listing of `.claude/state/`: the directory exists and contains no files. This reset opens
batch B17, the first batch of Phase 10.

## Timestamp-correction note

Four Phase 9 evidence artifacts were initially written with a filename and internal `Timestamp:`
value a few minutes ahead of their actual UTC write time. They were renamed to their observed write
time and their internal `Timestamp:` values and one cross-reference were corrected in the same pass:

| Original name | Corrected name |
| --- | --- |
| `batch-b15-toolchain.2026-09-07T14-58.md` | `batch-b15-toolchain.2026-09-07T14-55.md` |
| `codex-merge-gate-no-digit-scan.2026-09-07T15-04.md` | `codex-merge-gate-no-digit-scan.2026-09-07T14-59.md` |
| `ea2-false-allow-direction.2026-09-07T14-52.md` | `ea2-false-allow-direction.2026-09-07T14-51.md` |
| `pass-after-epic-merge-existing-suite.2026-09-07T14-54.md` | `pass-after-epic-merge-existing-suite.2026-09-07T14-51.md` |

No artifact in this feature now carries a future timestamp. The series convention is UTC, confirmed
by comparing `batch-b14-toolchain.2026-09-07T14-31.md` against its own filesystem mtime.

Output Summary: batch B16 toolchain gate PASSES in a single pass. Stage 1 formatting exited 0 with a
set-difference count of **0**; the porcelain path count is 12 before and after, and the edited Codex
hook's SHA-256 is unchanged across the run. Stage 2 analyze returned `ok: true`, equal to **0**
repository-wide diagnostics and equal to the [P0-T6] baseline of 0. Stage 3 reports
**5 tests / 0 failures** for the suite this batch owns and **43 tests / 0 failures** for
`legacy-codex-hook-contracts.Tests.ps1`, so byte identity, pack-manifest completeness, parse success,
and the 500-line cap all remain green. The folder-wide count is 749 tests with 1 failure, which is the
documented pre-existing ambient-state `codex-pretooluse-integration.Tests.ps1` case; the known-red
inventory contributes zero. Both Codex copies hash equal at 174 lines and both Claude copies at 472,
all under the 500-line cap. No stage failed and no stage rewrote a file, so no restart from stage 1
was required. The closing batch-budget reset exited 0.
