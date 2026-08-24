# QA Gate — Python Coverage Delta — [P8-T5]

Timestamp: 2026-08-23T05-18

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T5]
Run: revision-6 re-run.

Command: `git add -A` (at the repository root)

Command: `git diff main` and `git diff --name-status main`

Command: `git rev-parse main`

Resolved `main` SHA: `d782ee1c8b05192ed1bda40936ba5e37d9a5512e`

EXIT_CODE: 0

## Why both the staging step and the anchor are required

Neither is optional. An unanchored diff misses committed changes, and an unstaged diff omits a newly
created file entirely, which would make its changed-line set empty and let a vacuous zero satisfy the
coverage figure. `git add -A` was run at the repository root before the diff was taken.

The staging step matters differently on this run than on the previous one, and the difference is
instructive. The implementation is now committed as `fd20019d`, so a bare worktree-against-index diff
reads clean where it previously showed the whole change. That is precisely why these gates are
ref-anchored rather than bare: the anchored form is indifferent to commit state, and this run is the
observed proof of it.

## Ref-position diagnosis

`main` is **not** an ancestor of `HEAD`. `origin/main` is 27 commits ahead and `HEAD` is 9 ahead,
because issue #500 merged as pull request #514.

| Ref | SHA |
| --- | --- |
| `HEAD` | `fd20019d654f7e50a33408582d2e9fb2fe0d32ca` |
| `main` | `d782ee1c8b05192ed1bda40936ba5e37d9a5512e` |
| merge base | `bee15c0660d382ed74c642d2e028fd136051046f` |

A `main`-anchored diff therefore contains #500's commits as inverted changes, which would make the
changed-line set for this item's files unreadable. The changed-line sets below are computed against
the **merge base**, a fixed commit containing exactly this branch's changes. Both anchors were
resolved and recorded; the substitution is stated rather than made silently. No rebase or merge was
performed: the coordinator handles that after this run, before the pull request opens.

## Diff file-list completeness — all eight created paths present

The acceptance requires the `git diff --name-status main` file list to contain all eight created
paths. It contains **all eight**:

| # | Created path | Status |
| --- | --- | --- |
| 1 | `scripts/dev_tools/_blast_radius_token_shapes.py` | **A** |
| 2 | `tests/scripts/dev_tools/test_blast_radius_token_shapes.py` | **A** |
| 3 | `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | **A** |
| 4 | `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` | **A** |
| 5 | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | **A** |
| 6 | `tests/fixtures/blast_radius/derivation-placeholder-token-rejected.json` | **A** |
| 7 | `tests/fixtures/blast_radius/derivation-placeholder-marker-variants.json` | **A** |
| 8 | `tests/fixtures/blast_radius/validation-placeholder-self-consistent.json` | **A** |

Eight of eight, with no absence to attribute. The previous run recorded eight of nine against the
then-current nine-path list, because [P5-T3]'s conflict fixture was unsatisfiable; revision 6 replaced
that fixture with a named test per runtime that creates no file, so the list is now eight and is
complete.

## Changed and added line sets, computed from the merge-base-anchored diff

| Path | Added lines | Removed lines |
| --- | --- | --- |
| `scripts/dev_tools/_blast_radius_token_shapes.py` | **117** | 0 |
| `scripts/dev_tools/_blast_radius_extraction.py` | 27 | 40 |

The added-line count for the new leaf module is **117**, strictly greater than zero. **PASS.** That
condition is the guard against a vacuous result: had staging been skipped, the new file would have
been invisible and its count would have been zero, which any coverage figure would satisfy trivially.

The extraction module's 40 removed lines are the relocated span predicate and its two constants; its
27 added lines are the leaf-module import, the marker guard, the guard's decision-logic comment, and
the `Returns:` docstring amendment. Both counts are unchanged from the previous run, as expected:
[P5-T3] touched only a test file.

## Changed-line coverage

| Path | Stmts | Miss | File line coverage | Changed-line coverage |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/_blast_radius_token_shapes.py` | 14 | **0** | **100%** | **100%** |
| `scripts/dev_tools/_blast_radius_extraction.py` | 101 | **0** | **100%** | **100%** |

Both recorded as numbers, not placeholders. The derivation is by containment and is exact rather than
estimated: a file whose `Miss` count is **0** has every statement covered, so every subset of its
statements, including the changed and newly added set, is covered. Both files also report `BrPart` 0,
so branch coverage on the changed set is likewise 100% — including the new guard branch, whose
rejecting outcome is exercised by the five parametrized marker cases and whose falling-through
outcome by every marker-free acceptance case in the same file.

## No regression against the baseline

| Metric | Baseline ([P0-T5]) | Post-change ([P8-T4]) | Delta | Regression |
| --- | --- | --- | --- | --- |
| line coverage | 92.60% | **92.61%** | **+0.01 pp** | none |
| branch coverage | 89.81% | **89.82%** | **+0.01 pp** | none |

Both improved marginally. **No regression on either metric.** Both figures were derived by the
identical method from the identical `TOTAL`-row columns in both states, which is what makes them
comparable. The denominator grew by 7 statements and 2 branches — the leaf module's executable
surface — while `Miss` and `BrPart` did not move, so a fully covered addition raised both ratios
slightly.

## Output Summary

`git add -A` was run at the repository root and the staged, anchored diff was taken. The file list
contains **all eight** created paths. The added-line count for the new leaf module is **117**,
strictly greater than zero. Changed-line coverage is **100%** for both touched Python modules,
established exactly from a zero `Miss` count on each. Neither the line metric (92.60% to 92.61%) nor
the branch metric (89.81% to 89.82%) regressed.
