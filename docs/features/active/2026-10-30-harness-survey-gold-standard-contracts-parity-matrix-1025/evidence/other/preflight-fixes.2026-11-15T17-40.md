# Preflight In-Place Fixes (Plan A, final confirming preflight after scope change S1, D-R6)

Timestamp: 2026-11-15T17-40
Plan: docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/plan.2026-10-30T17-06.md

## Fixes

1. Plan preamble, `Requirements sources` | stale citation | The spec version cited for `## Acceptance Criteria` was 0.5; the spec is now version 0.7 and carries decision D-R6 in `### Owner Decisions`. The citation now reads version 0.7 and names D-R6. No assertion changed.

## Design-Check Confirmation (narrowed rules, no artifact beyond this record)

- `## Data & State` invariant 7 (narrowed): unknown properties, required fields, enums, `const`, pattern, path-shape, `minLength`, `minItems`, `uniqueItems` and the `owner_child` integer-range rule are implemented by P2-T3 and each has a failing It listed in P2-T3; per-field type checking is deferred (D-R6 a).
- Schema acceptance criterion (narrowed): property-name sets at both levels are part of `Get-HarnessParityMatrixRuleSet` (P2-T3) and compared, with enums, required lists, the five conditional rules and the `id` pattern, by the P3-T10 agreement It; keyword-level agreement is deferred (D-R6 b).
- `### Contract Format` rule 3 (narrowed): non-whitespace content and at least one list item are implemented by P2-T4 with the `empty section` and `a list section with prose but no list item` Its; the `## Objective` prose statement is advisory (D-R6 c).
- Pre-Mortem `Coverage` bullet: consistent with D-R6.

## Validation

- Python CLI `scripts/dev_tools/validate_orchestration_artifacts.py plan`: EXIT_CODE 0 after the fix.
- MCP `validate_orchestration_artifacts` (`plan`): ok after the fix.
