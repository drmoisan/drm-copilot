# Phase 0 — pre-edit control-count re-measurement

Timestamp: 2026-09-17T13-56

Task: `[P0-T4]` of `remediation-plan.2026-09-17T12-29.md`

Command, run once per table row for each of the two projections:

- `Select-String -SimpleMatch -Pattern '<token>' -Path '<path>' | Select-Object -ExpandProperty LineNumber`
- `Select-String -SimpleMatch -Pattern '<token>' -Path '<path>' | Measure-Object | Select-Object -ExpandProperty Count`

`-SimpleMatch` is supplied on every invocation, as the plan's search-assertion form requires. Without it the
tokens `[A-Za-z]:[\\/]` and `$segments[0..3]` carry regular-expression meaning and would match nothing
whatever the files contain.

EXIT_CODE: 0 for every invocation. No path was missing and no pattern raised a parse error.

This task ran before any file in the remediation's file set was edited. The `[P0-T2]` capture records the
tree state at that point: the only modifications present were the plan's own checkbox transitions and Phase 0
evidence artifacts, none of which is a file this table measures.

Output Summary:

## Measured rows

Six target counts and one control count, each recorded as an integer with the line number of every match:

| # | role | asserted token | path | measured count | match line numbers | preamble table value | verdict |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | target | `absolutely-placed` | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 2 | 219, 242 | 2 at lines 219 and 242 | **MATCHES** |
| 2 | target | `[A-Za-z]:[\\/]` | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 1 | 243 | 1 at line 243 | **MATCHES** |
| 3 | control | `[A-Za-z]:[\\/]` | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` | 1 | 57 | 1 at line 57 | **MATCHES** |
| 4 | target | `earliest-occurring candidate` | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 1 | 28 | 1 at line 28 | **MATCHES** |
| 5 | target | `If no candidate was found in the prompt` | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 1 | 31 | 1 at line 31 | **MATCHES** |
| 6 | target | `It is loaded for its declarations only` | `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 1 | 13 | 1 at line 13 | **MATCHES** |
| 7 | target | `$segments[0..3]` | `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 1 | 154 | 1 at line 154 | **MATCHES** |

Target rows: 1, 2, 4, 5, 6, 7 — six target counts.
Control row: 3 — one control count, measured non-zero at 1.

No measured value is a placeholder. Every one of the seven rows carries an explicit **MATCHES** verdict, and
every match line number agrees with the preamble table as well, so no supersession is recorded: the preamble
table's values stand as the controls the later tasks compare against.

## Consequences fixed by these measurements

- `[P2-T2]` compares its post-edit zero counts for `absolutely-placed` and `[A-Za-z]:[\\/]` in the parent hook
  against the pre-change counts **2** and **1** recorded here, and compares the surviving
  `[A-Za-z]:[\\/]` count in `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` against the
  control count **1** recorded here. A post-edit control count other than 1 would mean the edit reached the
  resolution module, which it must not.
- `[P2-T3]` compares its post-edit zero counts for `earliest-occurring candidate` and
  `If no candidate was found in the prompt` against the pre-change count **1** for each.
- `[P2-T5]` compares its post-edit zero count for `It is loaded for its declarations only` against the
  pre-change count **1**.
- `[P2-T6]` asserts the `$segments[0..3]` count is still exactly **1** at line **154**, which is the #518
  four-segment slice the remediation must leave byte-unmodified.

Acceptance: six target counts and one control count are recorded as integers, none a placeholder, and each is
compared against the preamble table with an explicit `MATCHES` verdict. Satisfied. No `DIFFERS` verdict was
produced, so no value supersedes the table.
