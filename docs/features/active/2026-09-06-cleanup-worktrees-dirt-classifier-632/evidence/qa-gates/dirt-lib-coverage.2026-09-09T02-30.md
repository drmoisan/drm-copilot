# Phase 5 — post-change bash line coverage from the merged Cobertura artifact (cycle 3)

Timestamp: 2026-09-09T02-30
Task: [P5-T9]
Performed by: orchestrator (EA-4 gate ownership; kcov has no local route and exits 127).

Command: gh api repos/drmoisan/drm-copilot/actions/runs/34255859868/artifacts
  then gh api repos/drmoisan/drm-copilot/actions/artifacts/10068076892/zip
  then parse kcov-merged/cov.xml, counting line elements with non-zero hits per class
EXIT_CODE: 0

Source run: 34255859868, conclusion `success`, headSha `5ad0ef09088f68ad2818ae01292b8290cdf18d12`.
Artifact: `shell-coverage`, id `10068076892`.

## Headline figures

PostChangeRepoLineCoverage: 93.69
PostChangeDirtLibLineCoverage: 94.22
Threshold: 85.0

Both are numbers and both are at or above the 85.0 line threshold.

## Covered-over-total line pair for the classifier library

`scripts/bash/cleanup_worktrees_dirt_lib.sh`: **163 / 173** lines covered, 94.22%.

The denominator moved from cycle 2's 170 to 173 for the three executable lines the N3 fix adds —
the `bothloc` assignment and the two nested gates. All three are covered, which is why the
percentage rose rather than being diluted.

## Derivation method

The percentages were computed by counting `<line>` elements with `hits` greater than zero against
the total `<line>` count per class, which is the method the plan requires and the method the Phase
0 baseline used. The Cobertura `line-rate` attribute on a `<class>` element is rounded to three
decimal places, so reading it at one end of a delta while counting exactly at the other would not
be a like-for-like comparison. The report root carries `lines-covered="2169"` and
`lines-valid="2315"`; recomputed, 2169 / 2315 = 93.69%.

## Branch coverage

Not evaluated, and no branch gate is asserted. kcov measures no branch coverage for bash, so the
75% branch threshold does not apply, per `.claude/rules/shell.md` and
`.claude/rules/quality-tiers.md`. That is a threshold exemption only: no bash production file is
excluded from measurement, and all eight `cleanup[-_]worktrees*` files remain in the denominator.

Output Summary: repository-wide bash line coverage 93.69% (2169/2315) and
`cleanup_worktrees_dirt_lib.sh` 94.22% (163/173), both above the 85.0 threshold, read from the
merged Cobertura artifact of CI run 34255859868 at headSha `5ad0ef09`.
