# Acceptance-criterion count reconciliation

Timestamp: 2026-09-09T02-00
Task: [P4-T5]
Work mode: `full-bug`. The acceptance-criteria source is `spec.md`, `## Acceptance Criteria`
section only.
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`

## Commands

Command: `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -c '^- \['`
Command: `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -c '^- \[x\]'`
Command: `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md | grep -c '^- \[ \]'`
Command: `grep -c '^- \[' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`

EXIT_CODE: 0

## Counts

SectionScopedCriterionTotal: 49
SectionScopedChecked: 47
SectionScopedUnchecked: 2

The two unchecked boxes are **AC-48** and **AC-49**. Both were appended unchecked, as the
plan directs, and are checked off in P5-T6 once the evidence supporting them exists.

UnscopedCheckboxTotal: 57

The unscoped figure is **not** the criterion count. Eight checkbox lines sit outside the
`## Acceptance Criteria` section — the severity radio block in `## Context` and the other
checklist blocks the document carries — so an unscoped `grep -c '^- \['` counts them
alongside the criteria. It read `55` at the start of this cycle and reads `57` now; the
section-scoped figures moved from 47/47/0 to 49/47/2 over the same two additions. Only the
section-scoped derivation is authoritative.

## Baseline comparison

| Quantity | Cycle start (P0-T9) | Now |
|---|---:|---:|
| Section-scoped total | 47 | 49 |
| Section-scoped checked | 47 | 47 |
| Section-scoped unchecked | 0 | 2 |
| Unscoped checkbox lines | 55 | 57 |

## Authorized amendments applied in this phase

Two bounded spec-text amendments were authorized by the caller on the record, following
preflight round 2's two non-blocking findings. Both are recorded here because P4-T2 and
P4-T3 define no evidence artifact of their own and both amendments are edits to the
acceptance criteria this artifact reconciles.

**Amendment 1 — in [P4-T2].** Deleting the third registry row kind falsifies AC-47's
sentence `The three row kinds partition the outcome space of two comparisons`. P4-T2
instructed the edit but no acceptance search covered it, so it could have survived
silently. Two searches were added to P4-T2's acceptance, on the unwrapped stream that task
already defines:

- `grep -cF 'The three row kinds'` reports `0` — observed `0`. Pre-edit value: `1`.
- `grep -cF 'The two row kinds'` reports `1` — observed `1`. Pre-edit value: `0`.

Both pre-edit values were observed directly before the edit, so both conditions could fail.
The sentence now reads `The two row kinds partition the outcome space of two comparisons
for a (mutation, scenario) pair`.

**Amendment 2 — in [P4-T3].** AC-48's closing clause as drafted in the plan would have
overstated in the opposite direction. The plan's text said that changing any letter in the
character class "would leave every test green". That is false as written: the registry row
`index-and-worktree-both-hold-content` quotes the character class verbatim inside its
mutation, so a library-only edit to the class makes the substitution inert, the registry
suite's Obligation 2 records the mismatch, and that suite goes red. The final clause was
replaced so that it states:

- no **behavioural** assertion would move under such a change to the class; and
- the class text is coupled to the registry literal, so an **uncoordinated** library-only
  edit fails the registry suite, while an edit **coordinated** across the library line and
  the registry literal leaves every test green.

The coupling claim was verified mechanically rather than asserted: P3-T4's probe shows the
same Obligation 2 / Obligation 5 machinery reporting a registry row whose mutation no
longer matches its target, and the registry suite passes on the coordinated end state
(`evidence/qa-gates/registry-kind-distribution.2026-09-09T01-30.md`).

## Output Summary

Section-scoped total 49, checked 47, unchecked 2 (AC-48, AC-49); unscoped figure 57 and not
the criterion count. Both authorized amendments were applied and each of their acceptance
searches was observed at the required value with its pre-edit value recorded.
