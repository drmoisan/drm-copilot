# R3 Deferral Note (Cycle 1, Issue #401)

Timestamp: 2026-07-22T21-30

## Deferral Decision

R3 (follow-up decomposition of pre-existing over-500-line Python files) is DEFERRED to a follow-up issue at the orchestrator's discretion, per the remediation-inputs Exit Condition allowance ("R2 either resolved ... and blocking_count == 0"; R3 marked "optional/deferrable"). No code work is performed for R3 in this cycle.

## Affected Files and Line Counts

- scripts/dev_tools/potential_to_issue.py = 639 lines (634 at merge-base a0b251d3; +5 from the required Defect B lockstep branch reorder delivered in the original cycle).
- tests/scripts/dev_tools/test_potential_to_issue.py = 1076 lines (1017 at merge-base a0b251d3; +59 from the required regression cases delivered in the original cycle).

Both files exceeded the 500-line limit at merge-base and predate this branch. Their over-limit status is a pre-existing violation not attributable to the #401 bug fix.

## Rationale

Decomposing these files is parity-sensitive: production `potential_to_issue.py` is bound to `promotion.ts` by a byte-parity contract for every PromotionError message, emitted line, constant, and decision branch. The parity contract pins semantics, not file layout, so any production split must be coordinated with the parity-header references in `promotion.ts` and landed in lockstep. This is a distinct, larger unit of work than the R1 + R2 scope of this cycle.

## Precedent

The April 2026 precedent for these same files defers pre-existing over-500-line violations that are not attributable to the immediate bug fix: docs/features/archive/2026-04-05-potential-to-issue-missing-label-123/policy-audit.2026-04-05T15-30.md.

## Cycle-Exit Status

R1 (blocking) is resolved and R2 (AC-11) is resolved this cycle; R3 is deferred with the rationale above. This satisfies the remediation-inputs Exit Condition for cycle 1.
