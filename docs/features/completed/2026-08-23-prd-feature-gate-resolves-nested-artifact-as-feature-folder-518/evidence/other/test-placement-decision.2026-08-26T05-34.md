# Test Placement Decision — [P1-T1]

Timestamp: 2026-08-26T05-34

Task: [P1-T1]
Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3`

## Rule Being Applied

[P1-T1] states: if the existing test file `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`
would reach or exceed 500 lines once the 25 new `It` blocks declared in the plan's
"Named regression cases" section are added, the new cases go into the companion file
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`,
and edits to the existing file are limited to the assertions invalidated by [P2-T4] and
[P2-T5] (enumerated in [P1-T9] and [P1-T10]).

## Measured Pre-Change Line Count

Two counting methods were recorded, and the decision is the same under both.

| Method | Command | `enforce-prd-feature-before-planner.Tests.ps1` |
| --- | --- | --- |
| Non-blank line count, as recorded by [P0-T2] | `Get-Content -LiteralPath $_ \| Measure-Object -Line` | 360 |
| Physical line count | `wc -l tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | 408 |

The [P0-T2] artifact `evidence/baseline/baseline-line-counts.2026-08-26T05-21.md` recorded 360 using
`Measure-Object -Line`, which counts only lines carrying content. The physical count of the same file
is 408. The 500-line limit in `.claude/rules/general-code-change.md` is stated in terms of file lines,
so the physical count of 408 is the figure the limit is measured against; the 360 figure is recorded
here as well because it is the measurement [P1-T1] names as its input.

**Measured pre-change line count used for this decision: 408 physical lines (360 non-blank).**

## Estimated Added Line Count

The plan declares 25 new `It` blocks. The seven pre-existing `It` blocks the plan enumerates with
explicit line ranges span 8, 14, 13, 9, 16, 18, and 8 lines respectively — a mean of 12.3 lines per
block. The new cases are not structurally smaller: the decision-level, selection, and indeterminate
cases each require one or more of the mocked seams `Get-PrdFeatureIssueContent`,
`Get-PrdFeatureFileExistence`, and `Get-PrdFeatureCheckpointFolder`, plus an in-line
`ConvertTo-Json` envelope, which is at or above the existing average.

| Estimate | Lines per block | Added lines | Projected total (physical, from 408) | Projected total (non-blank, from 360) |
| --- | --- | --- | --- | --- |
| Observed mean of existing blocks | 12.3 | 308 | 716 | 668 |
| Conservative floor | 8.0 | 200 | 608 | 560 |

**Estimated added line count: approximately 308 lines (conservative floor 200 lines).**

## Resulting Projected Total

**Projected total: approximately 716 physical lines (668 non-blank), with a conservative floor of
608 physical lines (560 non-blank).**

Every one of the four projections exceeds 500. The projection is not marginal: even the conservative
floor overshoots the limit by more than 100 lines, and the excess does not depend on which of the two
counting methods is used.

## Chosen Placement

The [P1-T1] trigger condition is met. The 25 new `It` blocks go into the companion file:

**`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`**

Consequences fixed by this decision, applied by the tasks that follow:

- Edits to `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` are limited to
  the assertions invalidated by [P2-T4] and [P2-T5]: the three `It` blocks enumerated in [P1-T9] and
  the seven `It` blocks enumerated in [P1-T10]. No new `It` block is added to that file.
- The companion file is a test file, not a production file, so no `pester.runsettings.psd1`
  `CodeCoverage.Path` entry is added in either copy and the production-file change budget in
  `.claude/rules/powershell.md:37-40` is unaffected. This matches the Scope & Non-Goals section of
  `spec.md`, which excludes both `pester.runsettings.psd1` copies from the write set.
- The companion file is named in the plan's Declared write set at item 4 as conditional on this
  decision. The condition is satisfied, so the file is part of the write set.
- The repository already uses this convention for the same reason. `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1`
  documents itself as a sibling of a test file with no headroom, and the `enforce-pr-author-skill`
  test files follow the same pattern.

Output Summary: Measured pre-change line count 408 physical (360 non-blank); estimated addition
approximately 308 lines (conservative floor 200); projected total approximately 716 physical (668
non-blank), conservative floor 608 physical (560 non-blank). All projections exceed the 500-line
limit, so the 25 new `It` blocks are placed in the companion file
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`.
