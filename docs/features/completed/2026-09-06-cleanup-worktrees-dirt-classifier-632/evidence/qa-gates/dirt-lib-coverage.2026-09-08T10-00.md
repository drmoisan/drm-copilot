# Phase 5 — post-change bash line coverage from the merged Cobertura artifact

Timestamp: 2026-09-08T10-00
Task: [P5-T8]
Performed by: orchestrator (EA-4 gate ownership; kcov has no local route).

Command: gh api repos/drmoisan/drm-copilot/actions/runs/34229386300/artifacts
  then gh api repos/drmoisan/drm-copilot/actions/artifacts/10057356590/zip
  then parse kcov-merged/cov.xml
EXIT_CODE: 0

Source run: 34229386300, conclusion `success`, headSha `7d7a661f88c082184a892e153922f22af43e6a40`.
Artifact: `shell-coverage`, id `10057356590`, 385025 bytes.

## Headline figures

PostChangeRepoLineCoverage: 93.69
PostChangeDirtLibLineCoverage: 94.12
Threshold: 85.0

Both are numbers and both are at or above the 85.0 line threshold.

## Covered-over-total line pair for the classifier library

`scripts/bash/cleanup_worktrees_dirt_lib.sh`: **160 / 170** lines covered, 94.12%.

The denominator moved from the baseline's 168 to 170 because the N1 fix adds two executable
lines to rung 4. Both new lines are covered, which is why the percentage rose rather than
being diluted.

## Derivation method, and why the rounded attribute is not used

The percentages above were computed by counting `<line>` elements with `hits` greater than
zero against the total `<line>` count per class, which is the same method the Phase 0 baseline
artifact used. The Cobertura `line-rate` attribute on a `<class>` element is rounded to three
decimal places and reports this file as `0.941`, which is consistent with anything from 94.05%
to 94.15% and therefore cannot support a like-for-like comparison against a baseline recorded
to two decimals. Using the rounded attribute at one end of a delta and an exact count at the
other would produce a comparison that is not meaningful.

The report root carries `line-rate="0.937"`, `lines-covered="2166"`, `lines-valid="2312"`.
Recomputed, 2166 / 2312 = 93.69%.

## Branch coverage

Not evaluated, and no branch gate is asserted. kcov measures no branch coverage for bash, so
the 75% branch threshold does not apply, per `.claude/rules/shell.md` and
`.claude/rules/quality-tiers.md`. That is a threshold exemption only: no bash production file
is excluded from measurement, and all eight `cleanup[-_]worktrees*` files remain in the
denominator.

Output Summary: repository-wide bash line coverage 93.69% (2166/2312) and
`cleanup_worktrees_dirt_lib.sh` 94.12% (160/170), both above the 85.0 threshold, read from the
merged Cobertura artifact of CI run 34229386300 at headSha `7d7a661f`.
