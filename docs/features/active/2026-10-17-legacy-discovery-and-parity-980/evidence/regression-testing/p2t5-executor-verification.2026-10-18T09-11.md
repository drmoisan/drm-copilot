# P2-T5 independent executor verification

Timestamp: 2026-10-18T09-11
Command: poetry run python SCRATCH/issue-980-verify-p2t5.py 2026-10-18T09-09 38
EXIT_CODE: 0
Output Summary: P2-T5 accepted. Three exact staged paths, 186 unchanged prior paths, 24 frozen compatibility paths, 38 independent cases, 183/183 lines and 75/76 arcs verified; all 19 new callable/class ranges have 100% line coverage.

## Task acceptance

The [specialist handoff](../other/p2t5-scoped-decisions.2026-10-18T09-09.md), [raw coverage](p2t5-coverage.2026-10-18T09-09.json), [metrics](p2t5-coverage-metrics.2026-10-18T09-09.json) and [independent checks](p2t5-executor-checks.2026-10-18T09-11.json) match the final staged bytes. Only `decision_rules.py` and the two prescribed decision test modules were added. Physical lengths are 477, 474 and 357 lines. No earlier production file, dependency, suppression or coverage setting changed.

Only a current, evidenced, configured-owner approval produces an eligible target requirement scope. Resolved repository/feature identity and all four selector axes remain explicit; empty non-feature selectors mean unrestricted scope. Proposed/rejected records do not become target policy. Invalid owners, missing or altered approval payloads, missing required evidence types, ambiguous features and unconfigured clients block eligibility. An eligible record grants no native mutation authority or implementation verification.

Supersession requires the same key and complete predecessor coverage. Proposals and partial overlaps cannot remove existing approval obligations. Directed cycles block regardless of proposal status. Current overlapping approvals conflict; valid replacement of multiple overlapping predecessors removes those historical conflict claims. Retiring a whole feature requires a whole-feature approval. Resolution links preserve owner, target text, scope and active approval identity; observation-based resolution requires observed evidence rather than a product decision.

The coordinator-confirmed split-question case preserves historical facts: target policy may be resolved while a separate, explicitly linked legacy question remains open for unknown observations. A target decision alone cannot close that remaining uncertainty or cause a verified legacy claim. Both validators accept the split representation, and all probe snapshots remain unchanged. Carry this behavior into P2-T7/P2-T9 acceptance/completion composition and the later documentation; accepted claim rules remain unchanged.

## Verification results

| Gate | Actual result |
| --- | --- |
| Black pass 4 | Three files unchanged, exit 0 |
| Ruff pass 4 | Zero findings, exit 0 |
| Full repository Pyright pass 4 | Zero errors, warnings or informational diagnostics, exit 0 |
| Focused Pytest pass 4 | 88 passed, zero failures, 6.34 seconds |
| Reversed module order | 88 passed, zero failures, 2.96 seconds |
| New production lines | 183/183, 100% |
| New production branch arcs | 75/76, 98.684211% |
| New callable/class ranges | 19/19 measured, each 100% lines |
| Independent semantic/compatibility probes | 36/36 against final source hash |
| Long-history/bounded-finding probes | 2/2 against the same final source hash |
| Tracked quality tiers | 26 entries and 26 discovered projects |
| Packaged resource check | 33-resource closure current, exit 0 |
| Prior/frozen preservation | 186 accepted paths and 24 frozen v1/export paths unchanged |
| Staged whitespace and scope | Passed; exactly the three new owned paths |

[Individual semantic command receipt](p2t5-executor-probes.2026-10-18T09-11.md) and [bounded-history command receipt](p2t5-executor-bounds.2026-10-18T09-11.md) preserve separate command outcomes. The final source SHA-256 is `618289a9f28eaad58a86148e9a3dba2a9513701fb319900657021c9a71a00c65`. The 1,200-record valid chain completes with one final approval and no recursion error. The 110-invalid-owner graph retains exactly 100 findings including one blocking truncation marker, and no approval.

The [initial 36-case diagnostic review](p2t5-executor-review.2026-10-18T09-07.md) is retained with its one corrected defect and one subsequently confirmed behavior expectation. Two independent probe setup failures and all specialist failed lint/type attempts remain explicit. No failure was relabeled as a clean gate. The already accepted [62-receipt normalization proof](p2-command-receipt-normalization-verification.2026-10-18T09-02.md) is reused; captured gates were not rerun.

## Acceptance criteria and transition

[AC-13 verification](../other/p2t5-ac13-verification.2026-10-18T09-11.md) combines accepted P2-T2 identity/reference proof with this task's cyclic supersession proof. Only AC-13 is newly checked in spec.md, user-story.md and issue.md: five of 66 feature criteria are now verified in each source. Full validation-mode integration, consumer operations, native enforcement, publication and final repository QA remain later tasks.

P2-T5 is checked. Plan progress is 20/84. The next unchecked task is P2-T6; only the coordinator releases its specialist execution. This is task acceptance, not feature completion.
