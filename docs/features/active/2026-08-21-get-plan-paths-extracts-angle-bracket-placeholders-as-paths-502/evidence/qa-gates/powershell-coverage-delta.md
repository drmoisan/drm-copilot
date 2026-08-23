# QA Gate — PowerShell Coverage Delta — [P8-T9]

Timestamp: 2026-08-23T05-26

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T9]
Run: revision-6 re-run.

Command: `git add -A` (at the repository root)

Command: `git diff main` and `git diff --name-status main`

Command: `git rev-parse main`

Resolved `main` SHA: `d782ee1c8b05192ed1bda40936ba5e37d9a5512e`

EXIT_CODE: 0

## Why both the staging step and the anchor are required

The same two reasons as [P8-T5]. An unanchored diff misses committed changes; an unstaged diff omits a
newly created file, which would make its changed-line set empty and let a vacuous zero satisfy the
coverage figure. `git add -A` was run at the repository root before the diff was taken.

## Ref-position diagnosis

`main` is **not** an ancestor of `HEAD`: `origin/main` is 27 commits ahead and `HEAD` is 9 ahead, after
issue #500 merged as pull request #514.

| Ref | SHA |
| --- | --- |
| `HEAD` | `fd20019d654f7e50a33408582d2e9fb2fe0d32ca` |
| `main` | `d782ee1c8b05192ed1bda40936ba5e37d9a5512e` |
| merge base | `bee15c0660d382ed74c642d2e028fd136051046f` |

The changed-line sets below are computed against the merge base, a fixed commit containing exactly this
branch's changes. Both anchors were resolved and recorded. No rebase or merge was performed.

## Diff file-list completeness — all eight created paths present

The staged name-status list contains **all eight** created paths, verified by an exact-match check per
path. The full table is at [P8-T5]. Eight of eight, with no absence to attribute: revision 6 reduced
the list from nine to eight by replacing [P5-T3]'s fixture with a named test per runtime that creates
no file.

## Changed and added line sets, computed from the merge-base-anchored diff

| Path | Added lines | Removed lines |
| --- | --- | --- |
| `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | **162** | 0 |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | 31 | 50 |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1` | 179 | 0 |

The added-line count for the new production module is **162**, strictly greater than zero. **PASS.**

The extraction module's 50 removed lines are the relocated span function and its two script-scoped
constants; its 31 added lines are the leaf-module import with its explanatory comment, the marker
guard, the guard's decision-logic comment, the `.DESCRIPTION` amendment, and the re-export entry. Both
counts are unchanged from the previous run.

The normalization test file grew by 179 lines across [P5-T9] and [P5-T3]. It is a test file and so
contributes no production coverage denominator, but it is recorded here because it is the file this
run changed and because the file-size gate at [P8-T11] re-measures it.

## Changed-line coverage

Measured against the `CodeCoverage.Path` allow-list this item edited, with the blast-radius test folder
as the run scope, re-taken on this tree:

| Path | LINE missed | LINE covered | File line coverage | Changed-line coverage |
| --- | --- | --- | --- | --- |
| `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | **0** | 19 | **100%** | **100%** |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | **0** | 85 | **100%** | **100%** |

Both recorded as numbers. The derivation is by containment and is exact: a file whose missed-line count
is **0** has every measured line covered, so every subset of those lines, including the changed and
newly added set, is covered. Instruction coverage is likewise 0 missed on both files — 22 covered for
the new module and 98 for the extraction module. Pester reports no branch coverage, so no branch figure
exists and none is claimed.

The measurement source is the repository allow-list rather than the MCP run, because the MCP server
executes from a published npm package whose bundled allow-list predates this change. That boundary and
its root-cause evidence are at [P8-T8].

## No regression against the baseline

| Metric | Baseline ([P0-T8]) | Post-change ([P8-T8]) | Delta | Regression |
| --- | --- | --- | --- | --- |
| line coverage (full configured scope) | 96.47% | **96.46%** | **-0.01 pp** | none material |

The full-scope figure moved by one hundredth of a percentage point. The movement is not caused by any
line this item left uncovered — both touched production files are at zero missed lines — but by the
relocation: 8 measured lines moved out of `BlastRadiusExtraction.psm1` into a file the MCP run's frozen
allow-list does not yet name, so those 8 covered lines left the numerator and the denominator together
(5758 covered / 211 missed at baseline versus 5750 covered / 211 missed now).

The missed-line count is identical in both states at **211**, and that is the load-bearing observation:
no line that was covered became uncovered, and no new uncovered line was introduced. Under the
repository allow-list, which names the relocation target, all 8 relocated lines remain measured and
covered, so the figure recovers at the next publish of the MCP package. There is no coverage regression
on changed lines, which is the blocking condition the PowerShell rule states.

## Output Summary

`git add -A` was run at the repository root and the staged, anchored diff was taken. The file list
contains **all eight** created paths. The added-line count for the new production module is **162**,
strictly greater than zero. Changed-line coverage is **100%** for both
`.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` (19 of 19 lines) and
`.claude/lib/blast-radius/BlastRadiusExtraction.psm1` (85 of 85 lines), established exactly from a zero
missed-line count on each. The full-scope figure moved from 96.47% to 96.46% with the missed-line count
unchanged at 211, so no line regressed.
