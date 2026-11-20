# Preflight Fixes

Timestamp: 2026-11-09T23-30
Plan: docs/features/active/regenerate-after-integration-merge-1156/plan.2026-11-09T16-31.md
Pass: single remaining preflight after one planner revision

## Fix 1

- Location: [P4-T6], bullet "Epic skill `## Integration-Tip Regeneration`", RSC-TIP list.
- Defect class: literal-formatting (assertion list truncated relative to the literal the plan already requires).
- Before: the RSC-TIP list quoted "does not merge another child and does not launch another wave".
- After: the RSC-TIP list quotes the full [P4-T2] (a) literal "does not merge another child and does not launch another wave until the integration tip has a successful completed CI run".
- Rationale: `## Contract Literals and Collision Check` requires [P4-T6] to assert every quoted literal of [P4-T2] verbatim inside its scope, and the RSC-TIP bullet says it asserts "every (a) AC5.1 literal of [P4-T2]". The shortened quotation let the "until the tip CI succeeds" clause of AC5.1 be removed without failing the test. The literal written by [P4-T2] is unchanged, so what is asserted matches what the task already writes.
