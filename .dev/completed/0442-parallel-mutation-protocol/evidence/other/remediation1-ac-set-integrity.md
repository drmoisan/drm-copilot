# Remediation Cycle 1 — Acceptance-Criteria Set Integrity After the Amendments

Timestamp: 2026-08-09T06-42

Task: [P1-T14]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
Base for the diff checks: **`a9e2463c`** (the base for every "what this remediation cycle changed"
check, per the plan's `## Conventions Used in This Plan`)

## Check 1 — Count `- [` items under `## Acceptance Criteria`

Command: a Python count of `^- \[` lines in the `## Acceptance Criteria` section of each AC source
file (`spec.md` between `## Acceptance Criteria` and `## Definition of Done`; `user-story.md`
between `## Acceptance Criteria` and `## Non-Goals`)
EXIT_CODE: 0

| AC source | Expected | Counted | Verdict |
| --- | --- | --- | --- |
| `<FEATURE>/spec.md` (S1-S15) | 15 | **15** | PASS |
| `<FEATURE>/user-story.md` (U1-U9) | 9 | **9** | PASS |

## Check 2 — No criterion added, removed, reordered, or renumbered

Command: `git diff a9e2463c -- docs/features/active/2026-08-07-parallel-mutation-protocol-442/spec.md docs/features/active/2026-08-07-parallel-mutation-protocol-442/user-story.md`, filtered to
changed AC checkbox lines (`^[+-]- \[`)
EXIT_CODE: 0

### `spec.md` — changed AC lines

Exactly three criteria have a changed line, each as a paired removal-and-addition at the same
position in the list (a text amendment, not an insertion or deletion):

| Criterion | Change | Verdict |
| --- | --- | --- |
| **S2** | admission clause: "conflicts with no in-flight item" -> "conflicts with no member of the current cohort, in-flight or unstarted" | text amendment only |
| **S5** | recolor clause: `(remaining subgraph, pinned set)` -> `(remaining subgraph, pinned set, pinned cohort index)` plus the strictly-above-pinned-index clause; property list gains P4 | text amendment only |
| **S9** | completion-invariant clause now names the two-signal formalization, open-mode terminality, non-firing conditions, and F3 invariant 20's role | text amendment only |

No other `- [` line in `spec.md` appears in the diff, so S1, S3, S4, S6, S7, S8, S10, S11, S12,
S13, S14, and S15 are byte-identical to `a9e2463c`. Every `[x]` marker is preserved on all 15
items; no marker was added, removed, or toggled by this phase.

### `user-story.md` — changed AC lines

Exactly two criteria have a changed line, each as a paired removal-and-addition at the same
position:

| Criterion | Change | Verdict |
| --- | --- | --- |
| **U1** | admission clause: "conflicts with no in-flight item" -> "conflicts with no member of the current cohort, in-flight or unstarted" | text amendment only |
| **U5** | recolor clause: `(remaining subgraph, pinned set)` -> `(remaining subgraph, pinned set, pinned cohort index)` plus "never places an unstarted item in the pinned items' cohort when the two conflict"; determinism clause retained verbatim | text amendment only |

No other `- [` line in `user-story.md` appears in the diff, so U2, U3, U4, U6, U7, U8, and U9 are
byte-identical to `a9e2463c`. All nine `[x]` markers are preserved.

## Output Summary

Counts are exactly **15** and **9**, matching plan Constraint 11. The **only** criteria whose text
changed are **S2, S5, S9, U1, and U5** — the exact five the plan authorizes ([P1-T8], [P1-T9],
[P1-T10], [P1-T11], [P1-T12]). Nothing was added, removed, reordered, or renumbered in either AC
list; the labels and file order of every criterion are unchanged; every `[x]` marker is unchanged.
The honesty of those five `[x]` markers under the amended text is re-verified separately at
[P7-T11] against the delivered work.
