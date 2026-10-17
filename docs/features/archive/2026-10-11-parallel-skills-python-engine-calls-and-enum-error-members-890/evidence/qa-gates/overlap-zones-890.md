# Overlap Zones (Issue #890, AC-7)

Timestamp: 2026-10-12T20-31
Task: P2-T9
Command: `git diff origin/main...HEAD -U0 -- .claude/skills/parallel-add/SKILL.md .claude/skills/parallel-orchestrate/SKILL.md`; block anchors located with `git show 85ffd5aaecd9004b7d82e9db6ab0f18a4add02f6:<path>` (the P0-T3 merge base) and a fixed-string search for each anchor line.
EXIT_CODE: 0
Output Summary: no old-file hunk range intersects either overlap zone. parallel-add hunks start at old line 108 (zone 53-74); parallel-orchestrate hunks lie at 665-831 (zone 371-385).

## Overlap-zone locations at the merge base (planned vs. actual)

| Zone | Owner | Anchors | Planned (at 2ef8d361e) | Actual (at 85ffd5aae) |
| --- | --- | --- | --- | --- |
| parallel-add step 2 | #885 | "2. **Prepare the item.**" through the line before "3. **Compute conflict edges" | 53-64 | 53-74 |
| parallel-orchestrate child-DONE CI acceptance passage | #899 | "Procedure, per item:" through "the check-off and re-runs S9, and the parent does not commit the check-off itself." | 371-385 | 371-385 |

The parallel-add step-2 block grew from 53-64 to 53-74 because the merge of origin/main (merge commit e22dbe55c) brought in #885 (PR #913), which appended the issue-adoption paragraph (lines 65-73) to step 2. That block is fully intact: no hunk touches lines 53-74.

## Hunk headers

parallel-add (old ranges 108-111, 115-118, 142-143, 158-159, 169):

```text
@@ -108,4 +108,10 @@
@@ -115,4 +121,9 @@
@@ -142,2 +153,3 @@
@@ -158,2 +170,11 @@
@@ -169 +190,2 @@
```

parallel-orchestrate (old ranges 665-667, 771-772, 820-821, 827-831):

```text
@@ -665,3 +665,4 @@
@@ -771,2 +772,3 @@
@@ -820,2 +822,6 @@
@@ -827,5 +833,8 @@
```

## Line-number corrections for the engine-call edit sites (planned vs. actual)

| File | Plan citation | Actual old line |
| --- | --- | --- |
| parallel-add, step 4 `decide_admission` call | 100-101 | 108-110 |
| parallel-add, `recolor_unstarted` call | 108 | 115-117 |
| parallel-add, step 5 `RecolorResult` | (step 5 anchor) | 142-143 |
| parallel-add, step 6 `build_add_entry` | 150 | 158-159 |
| parallel-add, clock-seam sentence | (step 6 anchor) | 169 |
| parallel-orchestrate, decision-logic paragraph | 666 | 665-667 |
| parallel-orchestrate, clock-seam sentence | (anchor) | 771-772 |
| parallel-orchestrate, Drift-requeue append contract | 821, 829 | 820-821, 827-831 |

Lines not edited, confirmed by the hunk list: parallel-orchestrate 785 (`is_closed_mode_complete`), 1064 (`has_unresolved_drift(events, items)`), and 1072 (`request_requeue_via_recolor`).
