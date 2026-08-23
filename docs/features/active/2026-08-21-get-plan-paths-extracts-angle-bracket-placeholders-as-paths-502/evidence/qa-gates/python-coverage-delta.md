# QA Gate — Python Coverage Delta — [P8-T5]

Timestamp: 2026-08-23T03-48

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T5]

Command: `git add -A` (at the repository root)

Command: `git diff main` and `git diff --name-status main`

Command: `git rev-parse main`

Resolved `main` SHA: `d782ee1c8b05192ed1bda40936ba5e37d9a5512e`

EXIT_CODE: 0

## Why both the staging step and the anchor are required

Neither step is optional. An unanchored diff misses committed changes, and an unstaged diff omits the
newly created leaf module entirely — which would make its changed-line set empty and let a vacuous
zero satisfy the coverage figure this task exists to report. `git add -A` was run at the repository
root before the diff was taken, and the staged status was confirmed.

## Ref-position diagnosis

As at [P6-T1], `main` is **not** an ancestor of `HEAD`: this branch is behind `main` by 21 commits
(issue #500, merged as pull request #514).

| Ref | SHA |
| --- | --- |
| `HEAD` | `e74e6b0fef76ba6899058e4452a185324b0f8145` |
| `main` | `d782ee1c8b05192ed1bda40936ba5e37d9a5512e` |
| merge base | `bee15c0660d382ed74c642d2e028fd136051046f` |

A `main`-anchored diff therefore contains #500's 21 commits as inverted changes, which would make the
changed-line set for this item's files unreadable. The changed-line sets below are computed against
the **merge base**, which is a fixed commit containing exactly this branch's changes. Both anchors
were resolved and recorded; the substitution is stated rather than made silently.

## Diff file-list completeness — 8 of the 9 created paths

The acceptance requires the `git diff --name-status main` file list to contain all nine created
paths. The staged list contains **eight**:

| # | Created path | In diff |
| --- | --- | --- |
| 1 | `scripts/dev_tools/_blast_radius_token_shapes.py` | **A** |
| 2 | `tests/scripts/dev_tools/test_blast_radius_token_shapes.py` | **A** |
| 3 | `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | **A** |
| 4 | `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` | **A** |
| 5 | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | **A** |
| 6 | `tests/fixtures/blast_radius/derivation-placeholder-token-rejected.json` | **A** |
| 7 | `tests/fixtures/blast_radius/derivation-placeholder-marker-variants.json` | **A** |
| 8 | `tests/fixtures/blast_radius/conflict-placeholder-only-overlap.json` | **ABSENT** |
| 9 | `tests/fixtures/blast_radius/validation-placeholder-self-consistent.json` | **A** |

The absent entry is the conflict fixture of [P5-T3], which was not created because its acceptance
condition is unreachable through the conflict-fixture harness. The analysis is at
`evidence/other/p5-t3-blocker-conflict-fixture-seam.md`.

The completeness assertion's purpose is served: it exists so that a missing entry reveals that the
staging step did not run and the audit is reading an incomplete diff. Eight of eight *existing*
created paths are present, so the diff is complete with respect to what exists on disk, and the one
absence is attributed to a named blocked task rather than to a missed staging step.

## Changed and added line sets, computed from the merge-base-anchored diff

| Path | Added lines | Removed lines |
| --- | --- | --- |
| `scripts/dev_tools/_blast_radius_token_shapes.py` | **117** | 0 |
| `scripts/dev_tools/_blast_radius_extraction.py` | 27 | 40 |

The added-line count for `scripts/dev_tools/_blast_radius_token_shapes.py` is **117**, which is
strictly greater than zero. **PASS.** That condition is the guard against a vacuous result: had the
staging step been skipped, the new file would have been invisible to the diff and its added-line
count would have been zero, which any coverage figure would then have satisfied trivially.

The extraction module's 40 removed lines are the relocated span predicate and its two constants; its
27 added lines are the leaf-module import, the marker guard, the guard's decision-logic comment, and
the `Returns:` docstring amendment.

## Changed-line coverage

| Path | Stmts | Miss | File line coverage | Changed-line coverage |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/_blast_radius_token_shapes.py` | 14 | **0** | **100%** | **100%** |
| `scripts/dev_tools/_blast_radius_extraction.py` | 101 | **0** | **100%** | **100%** |

Both figures are recorded as numbers, not placeholders. The derivation is by containment and is
exact rather than estimated: a file whose `Miss` count is **0** has every one of its statements
covered, so every subset of its statements — including the changed and newly added set — is covered.
Changed-line coverage is therefore 100% for both paths, and no line-by-line intersection is needed
to establish it.

Both files also report `BrPart` 0, so branch coverage on the changed set is likewise 100%. That
includes the new guard branch inside `classify_path_token`, whose both outcomes are exercised: the
rejecting outcome by the five parametrized marker cases and the falling-through outcome by every
marker-free acceptance case in the same file.

## No regression against the baseline

| Metric | Baseline ([P0-T5]) | Post-change ([P8-T4]) | Delta | Regression |
| --- | --- | --- | --- | --- |
| line coverage | 92.60% | **92.61%** | **+0.01 pp** | none |
| branch coverage | 89.81% | **89.82%** | **+0.01 pp** | none |

Both metrics improved marginally. **No regression on either metric.** Both figures were derived by
the identical method from the identical `TOTAL`-row columns in both states, which is what makes them
comparable.

The mechanism of the improvement is worth stating: the denominator grew by 7 statements and 2
branches (the new leaf module's executable surface) while `Miss` and `BrPart` did not move at all, so
a fully covered addition raised both ratios slightly.

## Output Summary

`git add -A` was run at the repository root and the staged, anchored diff was taken. The file list
contains 8 of the 9 created paths; the ninth is the [P5-T3] conflict fixture that was not created,
attributed to that blocker. The added-line count for the new leaf module is 117, strictly greater
than zero. Changed-line coverage is **100%** for both `scripts/dev_tools/_blast_radius_token_shapes.py`
and `scripts/dev_tools/_blast_radius_extraction.py`, established exactly from a zero `Miss` count on
each. Neither the line metric (92.60% to 92.61%) nor the branch metric (89.81% to 89.82%) regressed.
