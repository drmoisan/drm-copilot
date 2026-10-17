# Fail-Before Exception Dossier (P1-T1, Issue #929)

Timestamp: 2026-10-16T01-10

SearchScope: docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/regression-testing/
SearchPatterns: fail-before-exception.*.md
SearchResult: none (the folder did not exist before this write)

WhyFailingRunImpossible: Every new test in this item is a characterization test against unchanged behavior (R3 table rows, R4 trim-only token cases, validator dispatch cases, and the in-process dependency-decision return). The only production edit (NB-5) removes a redundant alias of `$assistantMessage` that is never reassigned, so it does not change behavior. No regression test can therefore fail before the change.

## Alternative Proof

- The R3 regular expression, the R4 trimming logic, the discovery dispatch loop, and the dependency-decision statement are unchanged by this item; P9-T9 and P9-T13 verify this at final QA.
- The new tests pass on their first run against the unchanged behavior; P1-T6, P1-T7, P2-T2, P3-T2, and P4-T2 record those runs.
- NB-5 preservation: `$agentOutput` is assigned from `$assistantMessage` once and never reassigned, so each read returns the same value before and after the edit.

## Expect-Fail Statement

The plan contains no `[expect-fail]` task. This dossier satisfies the fail-before requirement in its place (spec AC-25).
