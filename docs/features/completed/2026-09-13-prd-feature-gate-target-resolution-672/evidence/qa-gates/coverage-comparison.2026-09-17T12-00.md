# Coverage Delta and Threshold Verification

Timestamp: 2026-09-17T12-09 (values below are the final pass, pass 3 of the `[P6-T1]`-`[P6-T4]` loop; the filename carries the timestamp of the first writing of this artifact at 12-00, after pass 2)

Command: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1`

That is the command that produced the post-change reading; it is named unconditionally rather than as a fallback, and it ran from the worktree root through the scratchpad wrapper `sh runps.sh runtest.ps1`.

Changed-line derivation command: `git diff --unified=0 d039e89b2b2569151e9170e1bbefb9f974419f87 -- .claude/hooks/enforce-prd-feature-before-planner.ps1 .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, run from the worktree root and not chained after a `cd` — **exit 0**. Anchor precondition `git merge-base --is-ancestor d039e89b2b2569151e9170e1bbefb9f974419f87 HEAD` — **exit 0**, so the halt branch does not fire. `$baselineHead` is the 40-character identifier recorded in `evidence/baseline/baseline-worktree-state.2026-09-17T10-28.md`.

EXIT_CODE: 0

## Per-file line coverage

| file | baseline (`[P0-T5]`) | post-extraction (`[P2-T10]`) | post-change (`[P6-T3]`) | threshold |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 91.35 % (95/104) | 85.25 % (52/61) | **90.91 %** (90/99) | >= 85 % |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | n/a (file did not exist) | 100.00 % (44/44) | **93.55 %** (58/62) | >= 85 % |

Both post-change per-file figures are at or above the 85 percent floor `spec.md` line 667 requires. No value here is a placeholder.

## Overall line coverage

| aggregate | covered | total | percent |
| --- | --- | --- | --- |
| baseline (`[P0-T5]`, 104 `sourcefile` nodes, 0 fallback) | 9333 | 9757 | 95.65 % |
| post-change (`[P6-T3]`, 105 nodes, 0 fallback) | 9386 | 9814 | 95.64 % |
| post-change recomputed with the `sourcefile` node for `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` excluded | 9328 | 9752 | 95.65 % |

The two headline aggregates are taken over different denominators by construction: `[P0-T5]` measured the baseline before `[P0-T12]` created the sibling and before `[P2-T6]` added it to `CodeCoverage.Path`. The recomputation is the like-for-like comparison, and at the precision recorded it equals the baseline: 95.65 percent against 95.65 percent, so the recomputed figure is not lower than the overall baseline.

Recorded precisely rather than rounded away: at full precision the baseline is 9333/9757 = 95.6544 percent and the recomputation is 9328/9752 = 95.6521 percent, a difference of 0.002 percentage points. The whole of that difference is arithmetic and not a testing regression. The two aggregates differ by exactly 5 covered lines and exactly 5 total lines, the net effect of the fully covered lines the extraction moved out of the parent hook and into the sibling against the lines this change adds to the parent; removing an equal covered and total count from a set whose ratio is below 100 percent lowers the ratio by a fraction of a point. No line that was covered at baseline is uncovered now: the parent's uncovered set is the same two regions it carried at baseline, renumbered.

The recomputation is not a waiver. The sibling's own per-file figure is separately gated at 85 percent by the clause above and measures 93.55 percent, and both aggregates are recorded with their two summed integers either way.

## New-and-changed-line coverage

The changed-line set is not selected by the executor: it is the union of the post-image line ranges reported by the anchored `--unified=0` diff above. All three post-image hunk-header spellings occur in that diff and all three are handled — `+c,d` names lines `c` through `c + d - 1`; the count-omitted `+c` names the single line `c` (for example `@@ -120 +126 @@`); and `+c,0` names an empty range contributing no line (for example `@@ -216 +205,0 @@`). A file's new-and-changed-line coverage is the count of its changed lines appearing as a child `line` element with `ci` greater than zero under its `sourcefile` node, divided by the count of its changed lines appearing as a child `line` element at all; lines the report does not analyze, such as comments and blank lines, are outside both counts.

| file | changed post-image lines | of those, analyzed | covered | new-and-changed-line coverage |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 150 | 49 | 44 | **89.80 %** |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 314 | 62 | 58 | **93.55 %** |

Uncovered changed lines are 143, 144, 150, 151, and 153 in the parent (the `Get-PrdFeatureCheckpointFolder` file-read body, which reads a real checkpoint from disk and was uncovered at baseline as well) and 121, 126, 138, and 237 in the sibling (three early returns in `ConvertTo-PrdFeatureFolderToken` and the no-match return in `Select-PrdFeatureFolderByTarget`).

Because `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` is created by this plan, its changed-line set is the whole file and its new-and-changed-line coverage equals its per-file coverage, 93.55 percent. That identity is recorded rather than treated as an error.

No branch-coverage figure is reported, because Pester does not measure it.
