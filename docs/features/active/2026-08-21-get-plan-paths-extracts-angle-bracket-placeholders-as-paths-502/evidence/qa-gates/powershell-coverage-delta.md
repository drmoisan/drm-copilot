# QA Gate — PowerShell Coverage Delta — [P8-T9]

Timestamp: 2026-08-23T04-08

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T9]

Command: `git add -A` (at the repository root)

Command: `git diff main` and `git diff --name-status main`

Command: `git rev-parse main`

Resolved `main` SHA: `d782ee1c8b05192ed1bda40936ba5e37d9a5512e`

EXIT_CODE: 0

## Why both the staging step and the anchor are required

The same two reasons given at [P8-T5] apply verbatim. An unanchored diff misses committed changes,
and an unstaged diff omits the newly created leaf module entirely, which would make its changed-line
set empty and let a vacuous zero satisfy the coverage figure. `git add -A` was run at the repository
root before the diff was taken.

## Ref-position diagnosis

`main` is **not** an ancestor of `HEAD`; this branch is behind `main` by 21 commits (issue #500,
merged as pull request #514).

| Ref | SHA |
| --- | --- |
| `HEAD` | `e74e6b0fef76ba6899058e4452a185324b0f8145` |
| `main` | `d782ee1c8b05192ed1bda40936ba5e37d9a5512e` |
| merge base | `bee15c0660d382ed74c642d2e028fd136051046f` |

The changed-line sets below are computed against the merge base, a fixed commit containing exactly
this branch's changes. Both anchors were resolved and recorded; the substitution is stated rather
than made silently.

## Diff file-list completeness — 8 of the 9 created paths

The staged name-status list contains 8 of the 9 created paths. The ninth,
`tests/fixtures/blast_radius/conflict-placeholder-only-overlap.json`, was not created because
[P5-T3]'s acceptance condition is unreachable through the conflict-fixture harness; the analysis is at
`evidence/other/p5-t3-blocker-conflict-fixture-seam.md`. The completeness assertion's purpose is
served: all eight existing created paths appear, so the diff is not truncated by a missed staging
step, and the single absence is attributed to a named blocked task. The full 9-row table is recorded
at [P8-T5].

## Changed and added line sets, computed from the merge-base-anchored diff

| Path | Added lines | Removed lines |
| --- | --- | --- |
| `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | **162** | 0 |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | 31 | 50 |

The added-line count for `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` is **162**, strictly
greater than zero. **PASS.** That condition is the guard against a vacuous result: had staging been
skipped, the new file would have been invisible to the diff and its added-line count would have been
zero, which any coverage figure would then satisfy trivially.

The extraction module's 50 removed lines are the relocated span function and its two script-scoped
constants; its 31 added lines are the leaf-module import with its explanatory comment, the marker
guard, the guard's decision-logic comment, the `.DESCRIPTION` amendment, and the re-export entry.

## Changed-line coverage

Measured against the `CodeCoverage.Path` allow-list this item edited, with the blast-radius test
folder as the run scope:

| Path | LINE missed | LINE covered | File line coverage | Changed-line coverage |
| --- | --- | --- | --- | --- |
| `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | **0** | 19 | **100%** | **100%** |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | **0** | 85 | **100%** | **100%** |

Both figures are recorded as numbers, not placeholders. The derivation is by containment and is exact
rather than estimated: a file whose missed-line count is **0** has every one of its measured lines
covered, so every subset of those lines — including the changed and newly added set — is covered.
Changed-line coverage is therefore 100% for both paths.

Instruction (command) coverage is likewise 0 missed on both files: 22 covered for the new module and
98 for the extraction module. Pester reports no branch coverage, so no branch figure exists to report
and none is claimed.

Note on the measurement source: the MCP-driven run's coverage output does not list the new module,
because the MCP server executes from a published npm package whose bundled allow-list predates this
change. That boundary and its root-cause evidence are recorded at [P8-T8]. The figures above come
from a run against the repository allow-list, which is the configuration whose changed lines this task
must report on.

## No regression against the baseline

| Metric | Baseline ([P0-T8]) | Post-change ([P8-T8]) | Delta | Regression |
| --- | --- | --- | --- | --- |
| line coverage (full configured scope) | 96.47% | **96.46%** | **-0.01 pp** | none material |

The full-scope figure moved by one hundredth of a percentage point. The movement is not caused by any
line this item left uncovered — both touched files are at zero missed lines — but by the relocation:
8 measured lines moved out of `BlastRadiusExtraction.psm1` into a file the MCP run's frozen allow-list
does not yet name, so those 8 covered lines left the numerator and the denominator together
(5758 covered / 211 missed at baseline versus 5750 covered / 211 missed now, with the missed count
unchanged).

The missed-line count is identical in both states at **211**, which is the load-bearing observation:
no line that was covered became uncovered, and no new uncovered line was introduced. Under the
repository allow-list, which names the relocation target, all 8 relocated lines remain measured and
covered, so the figure recovers at the next publish of the MCP package. There is no coverage
regression on changed lines, which is the blocking condition the PowerShell rule states.

## Output Summary

`git add -A` was run at the repository root and the staged, anchored diff was taken. The file list
contains 8 of the 9 created paths, with the ninth attributed to the [P5-T3] blocker. The added-line
count for the new module is **162**, strictly greater than zero. Changed-line coverage is **100%** for
both `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` (19 of 19 lines) and
`.claude/lib/blast-radius/BlastRadiusExtraction.psm1` (85 of 85 lines), established exactly from a
zero missed-line count on each. The full-scope figure moved from 96.47% to 96.46% with the missed-line
count unchanged at 211, so no line regressed.
