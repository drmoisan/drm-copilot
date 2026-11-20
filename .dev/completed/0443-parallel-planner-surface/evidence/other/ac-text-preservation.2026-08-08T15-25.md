# Acceptance-Criterion Text Preservation Verification

Timestamp: 2026-08-08T15-25

Task: [P7-T4]
Working directory: repository root

Command: `git diff -U0 -- docs/features/active/2026-08-07-parallel-planner-surface-443/spec.md docs/features/active/2026-08-07-parallel-planner-surface-443/user-story.md`

EXIT_CODE: 0

Output Summary: The two AC source files carry exactly ONE changed line between them for this entire remediation cycle, and it is not an acceptance criterion. `spec.md` has a net-zero diff. `user-story.md` has one changed line at line 135, which is Non-Goals prose. Zero criterion-text changes occurred, so the preserve-text rule of `.claude/skills/acceptance-criteria-tracking/SKILL.md` holds and the phase is not blocked.

## Enumeration of Every Changed Line

| File | Line | Change | Classification |
|---|---|---|---|
| `spec.md` | — | none | Net-zero diff. [P0-T11] and [P0-T12] changed two criteria from `[x]` to `[ ]`; [P7-T1] and [P7-T2] changed the same two back to `[x]`. The two pairs cancel, so the committed file is byte-identical to its pre-cycle state while the check-off is now evidence-supported. |
| `user-story.md` | 135 | `` `conflicts(a, b)` `` -> `` `conflicts(a, b, config)` `` | [P6-T4] Non-Goals prose change (N3). NOT a checkbox-state change and NOT an acceptance criterion. |

Raw diff:

```diff
diff --git a/docs/features/active/2026-08-07-parallel-planner-surface-443/user-story.md b/docs/features/active/2026-08-07-parallel-planner-surface-443/user-story.md
index d059c8d9..4a338fbb 100644
--- a/docs/features/active/2026-08-07-parallel-planner-surface-443/user-story.md
+++ b/docs/features/active/2026-08-07-parallel-planner-surface-443/user-story.md
@@ -135 +135 @@ skill text (the `[ASSUMPTION]` regime defined in `spec.md`).
-- Implementing radius derivation, V1-V3 validation, `conflicts(a, b)`, Welsh-Powell coloring, or
+- Implementing radius derivation, V1-V3 validation, `conflicts(a, b, config)`, Welsh-Powell coloring, or
```

## Classification Basis for the `user-story.md` Change

Line 135 sits inside the `## Non-Goals` bullet list. It begins `- Implementing ...`, a plain list item, not `- [ ]` or `- [x]`. `user-story.md` carries exactly 8 acceptance criteria, at lines 98, 101, 104, 108, 112, 116, 120, and 123; line 135 is not among them. The preserve-text rule is therefore not engaged for this change, and the diff shows no checkbox-state change in `user-story.md`.

## `spec.md` Checkbox Accounting

Although the net diff is zero, the intermediate states are recorded so the audit trail is complete:

| Criterion | Line | Pre-cycle | After [P0-T11]/[P0-T12] | After [P7-T1]/[P7-T2] |
|---|---|---|---|---|
| 11 — kickoff artifact per R5 | 655 | `[x]` (unsupported) | `[ ]` | `[x]` (supported by seam tests and CLI runs) |
| 20 — `parallel_kickoff_contract.py` validates the R5 shape | 689 | `[x]` (unsupported) | `[ ]` | `[x]` (supported by the widened matcher and three-alternant tests) |

All 22 `spec.md` criterion texts and all 8 `user-story.md` criterion texts are byte-identical to their pre-cycle text. The stale `conflicts(a, b)` token inside `spec.md:645` is deliberately left untouched because it sits inside criterion 8's text; that deliberate non-edit is recorded in `evidence/other/evidence-filename-normalization.2026-08-08T15-25.md`.
