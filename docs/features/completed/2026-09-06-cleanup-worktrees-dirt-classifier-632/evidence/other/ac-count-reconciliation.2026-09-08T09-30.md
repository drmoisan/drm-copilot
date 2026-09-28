# AC count reconciliation — cycle 2, Phase 4 (P4-T4)

Timestamp: 2026-09-08T09-30
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ac72d35e7980bc69d`
AC source (work mode `full-bug`): `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`,
`## Acceptance Criteria` section only.

## Commands

Command: `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -c '^- \['`
EXIT_CODE: 0
SectionScopedTotal: 47

Command: `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -c '^- \[x\]'`
EXIT_CODE: 0
SectionScopedChecked: 45

Command: `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -c '^- \[ \]'`
EXIT_CODE: 0
SectionScopedUnchecked: 2

Command: `grep -c '^- \[' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
EXIT_CODE: 0
UnscopedFigure: 55

## Output Summary

Section-scoped total 47, section-scoped checked 45, section-scoped unchecked 2, unscoped figure 55.

## The unscoped figure is not the criterion count

`grep -c '^- \['` run over the whole of `spec.md` reports **55**, and that figure is **not** the
acceptance-criterion count. `spec.md` carries eight checkbox lines outside the
`## Acceptance Criteria` section — at `:24`, `:25`, `:26`, `:27`, `:84`, `:595`, `:597` and `:599`
before this phase's insertions — which belong to the severity radio block in `## Context` and to
other non-criteria lists. 55 minus 8 = 47, which is the section-scoped total. An unscoped count
would therefore overstate the criterion set by exactly those eight lines, which is why every count
in this cycle is derived with the `awk` section filter above.

## The two unchecked boxes

The two unchecked boxes inside the section are AC-46 and AC-47:

- AC-46 — "Rung 4's tracked half resolves CONTENT_ON_MAIN only when the path is present in main ..."
- AC-47 — "Every line in scripts/bash/cleanup_worktrees_dirt_lib.sh that carries an arithmetic
  comparison of a variable against a numeric literal carries a # guard: marker ..."

Both were appended unchecked by P4-T2 and P4-T3 respectively. They are checked off by P5-T10 once
their supporting evidence exists.

## Arithmetic

The section began this cycle with 45 boxes, all checked, the last being AC-45 at `spec.md:848`.
P4-T2 added AC-46 and P4-T3 added AC-47, both unchecked, giving 45 + 2 = 47 total, 45 checked and
2 unchecked. These are checkbox counts and are unaffected by the guard arithmetic recorded
elsewhere in this cycle (31 arithmetic guard lines, 37 marker lines, 39 registry rows).
