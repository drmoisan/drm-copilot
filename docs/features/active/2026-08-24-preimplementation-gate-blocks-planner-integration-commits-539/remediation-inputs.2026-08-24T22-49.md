# Remediation Inputs — Issue #539 (S7 Feature Review)

- Feature: 2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539
- Date: 2026-08-24T22-49
- Source artifacts:
  - `policy-audit.2026-08-24T22-49.md`
  - `code-review.2026-08-24T22-49.md`
  - `feature-audit.2026-08-24T22-49.md`

## Blocking Findings

None. No code, test, registration, coverage, parity, or policy remediation is required. The
branch is merge-eligible from this review's perspective.

## Non-Blocking Remediation (documentation only)

### R1 — Correct spec.md D4 row 14 and the post-fix decision table (D-EXEC-2)

- File: `docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md`
- Locations: D4 rule table row 14 (line 128); post-fix decision table row
  `git -C ../x add docs/... / --git-dir / --work-tree | deny` (line 149); D8 section (lines
  183–185).
- Defect class: spec documentation defect. The implementation is correct; the spec misstates the
  gate-level outcome for bare relocating spellings, which is allow-by-non-match (the unchanged
  trigger regex never fires), not deny. Asserting deny on the bare spellings is unsatisfiable
  under the spec's own AC 14 trigger freeze.
- Exact replacement text: see `feature-audit.2026-08-24T22-49.md`, section "D-EXEC-2
  Adjudication" (row-14 replacement, two-row decision-table replacement, one-sentence D8
  addendum).
- Timing: may be applied in this branch before merge or as an immediate follow-up commit;
  it does not gate merge.

### R2 — Follow-up issue candidate (not filed by this feature, per D8)

- Scope: the whole-command-text trigger's over-match (D8 as recorded) and under-match
  (bare relocating spellings unclassified) are two directions of the same trigger-scope
  limitation. Any future issue should treat them together, and any trigger change must
  re-establish the fail-closed argument against wrapper bypasses (`xargs git add`,
  `bash -c "git add ."`, nested shells).

### R3 — Stale mid-execution pair-hash artifacts (no action required)

- Files: `evidence/other/claude-pair-hash.2026-08-24T19-57.md`,
  `evidence/other/codex-pair-hash.2026-08-24T20-06.md`.
- Status: superseded by `evidence/other/pair-hash-recomputed-final.2026-08-24T22-24.md`, which
  documents the discrepancy and matches this review's independent hashing. Recommendation: keep
  as-is. Recorded here only so a later review does not re-open them as a parity failure.
