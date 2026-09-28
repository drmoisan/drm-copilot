# Acceptance-criteria check-off

Timestamp: 2026-09-09T02-30
Task: [P5-T6]
Work mode: `full-bug`. AC source is `spec.md`, `## Acceptance Criteria` section only.
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`

AC-48 and AC-49 were appended unchecked in P4-T3 and P4-T4, as the plan directs, and are
checked off here now that the evidence supporting each exists.

## AC-48 — the two-content-bearing-columns property and the accounting gate

Supporting evidence:

- `evidence/regression-testing/fail-before-index-blob-unaccounted.2026-09-09T00-30.md` —
  the fail-before run: three `UNIQUE` verdicts and the accounting gate failing, with the
  `M ` control and the status-code coverage floor passing, and the pre-fix record stream
  carrying `DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|ffff3333`.
- `evidence/regression-testing/pass-after-index-blob-unaccounted.2026-09-09T01-00.md` —
  the pass-after run: all four closed, controls still green, and the post-fix record
  stream carrying `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|` with no `ALL_DISPOSABLE`.
- `evidence/regression-testing/phase2-sibling-check.2026-09-09T01-00.md` — the six dirt
  suites green together, and the `dirt_staged_tree_worktree_delta` sibling unchanged.
- `evidence/qa-gates/shell-qc-test.2026-09-09T02-30.md` — TAP numbers 299, 300, 312, 313,
  314 and 315 all `ok` in the full local stage.

## AC-49 — the two admissible row kinds and the raised pin floor

Supporting evidence:

- `evidence/regression-testing/n4-parked-row-rejected.2026-09-09T01-30.md` — the
  discrimination probe: the variant registry that passed all three tests before Phase 3
  now fails all three, printing `INVARIANT-8 inadmissible kind:`,
  `OBLIGATION-5 channel comparison failed:` and `PINS NOT SATISFIED:`, and the registry
  restored byte-identically afterwards.
- `evidence/qa-gates/registry-kind-distribution.2026-09-09T01-30.md` — the end-state
  registry: 40 `SEPARATED`, 2 `ARGV`, no third kind, 40 marker ids, and
  `history-scan-bounded-range` the only id with no `SEPARATED` row.
- `evidence/qa-gates/shell-qc-test.2026-09-09T02-30.md` — TAP number 318 `ok` under the
  renamed title.

## Section-scoped counts after check-off

Command: `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -c '^- \['`
Command: `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -c '^- \[x\]'`
Command: `grep -c '^- \[ \] AC-4' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`

EXIT_CODE: 0

SectionScopedCriterionTotal: 49
SectionScopedChecked: 49
SectionScopedUnchecked: 0
UncheckedAC4Lines: 0

Only checkbox lines under `## Acceptance Criteria` are counted. The severity radio block in
`## Context` and the other checklist blocks in the document are not acceptance criteria and
are excluded by the `awk` section scope; the unscoped whole-file figure is 57 and is not
the criterion count.

## Output Summary

AC-48 and AC-49 checked off. Section-scoped total 49, checked 49, unchecked 0.
