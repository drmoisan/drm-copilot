# Batch C Line Counts Against The 500-Line Cap

Timestamp: 2026-09-08T04-45

Task: [P3-T25]

Command:
`wc -l` over the five Batch C files, run against the current tree.

EXIT_CODE: 0

## Measured counts

The plan's Phase 3 preamble records that a newline-counting measurement reports one fewer line than
a content-line measurement for a file ending in a newline, and directs the larger, conservative
figure to be held against the cap. Both figures are recorded below.

| File | `wc -l` | Content lines | At most 500 |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 467 | 468 | yes |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 335 | 336 | yes |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | 495 | 496 | yes |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` | 457 | 458 | yes |
| `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1` | 318 | 319 | yes |

Every recorded count is at most 500.

## Split and move contingencies: none fired

The plan carries three split contingencies for this task. None was needed, so no split file was
written, no test was moved, and no additional batch-budget counter reset was performed.

1. **Gate-matrix suite split.** `CleanupWorktreeManifestGateMatrix.Tests.ps1` stands at 319 content
   lines, 181 lines below the cap. The conditions 6 through 9 cases were not split into
   `CleanupWorktreeManifestGateMatrixValues.Tests.ps1`. The suite stays compact because the 41 cases
   are carried in two data tables consumed by four `-ForEach` `It` blocks rather than written as 41
   separate blocks, and because the manifest fixtures are composed from two ordered member tables
   rather than repeated as whole JSON documents per case.
2. **Existing gate suite split.** The epic suite stands at 496 content lines and the parallel suite
   at 458, both below the cap, so neither gate's AC-05 reason test nor its AC-07 allow-set test was
   moved into a `-manifest-pins.Tests.ps1` file. The epic suite's remaining headroom is **4 lines**,
   which is the tightest margin in this change set and is recorded here so a later phase does not
   add to that file without re-measuring. No phase after Phase 3 in this plan writes to it: Phase 4
   changes Markdown only, Phase 5 writes the `.claude` PowerShell mirrors, and Phase 6 changes the
   two `pester.runsettings.psd1` files, `core.json`, and the `SKILL.md` mirror.
3. **Epic hook composed-condition move.** `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`
   stands at 468 content lines against the 500-line cap, so the composed manifest condition was not
   moved into `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`. The file began this phase
   at 445 content lines with 55 lines of headroom, the tightest budget in this change set. P3-T2 and
   P3-T3 together added 23 lines to it, within the 40-line budget the plan set for the pair, leaving
   32 lines of headroom. The branch was authored as a single composed `if` condition rather than as
   a sequence of guard clauses, which is what kept the addition inside the budget.

## Anchored diff line accounting

`git diff --numstat d250cf72ee24139735e7f08b07d002ae0e4f1d00` reported, at the time of this
measurement, 23 added and 0 deleted for the epic hook and 22 added and 0 deleted for the parallel
hook. Zero deleted lines on both production files is what shows the additions sit alongside the
unchanged code rather than replacing any of it.

Output Summary: All five Batch C files are within the 500-line cap. Highest content-line count is
496 for `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`, leaving 4 lines
of headroom; the epic gate hook stands at 468 with 32 lines of headroom. None of the three split
contingencies fired, so no split file was created, no test was moved, and no additional
batch-budget counter reset was required. Contributes to AC-27.
