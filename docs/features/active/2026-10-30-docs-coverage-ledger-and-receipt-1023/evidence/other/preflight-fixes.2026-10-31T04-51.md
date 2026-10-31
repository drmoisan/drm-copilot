# Preflight Fixes - Issue #1023 (PowerShell plan, version 0.3)

Timestamp: 2026-10-31T04-51
Plan: docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/plan.2026-10-30T16-51.md
Directive: PREFLIGHT VALIDATION ONLY (single pass; no task executed, no checkbox changed)

## Fixes

1. [P1-T1] | Stale citation (1020 constructor signature) | The fixture description read "built with `New-DocsDiagnostic` carrying the `docs.precision-limit` marker". The 1020 spec defines `New-DocsDiagnostic -Code -Path -Message -AnalyzerId [-Blocking]` with no extensions argument (1033 spec row C5 records the same). The text now states that the diagnostic is built with `New-DocsDiagnostic` and then given the marker in its `extensions` member. The fixture content is unchanged.
2. [P4-T6] | Contract assertion wording (1034 receipt fields) | The test `It 'writes only the receipt at validation_receipt on pass and on fail with WriteReceipt'` now states that the written text, parsed with `ConvertFrom-DocsJsonText`, carries `id`, `mode`, `repository`, `revision`, and `validation_result` equal to those of the receipt in `result`. These are the fields the 1034 hook reads (epic `### Enforcement notes from the two preparations of 1034`). The receipt shape of spec `### Receipt` and the schema-conformance tests of [P3-T1], [P3-T3], and [P3-T4] are unchanged; the fix names the per-field assertion on the persisted receipt.
3. `## Acceptance Criteria Traceability` S12 row | Traceability citation | Evidence column gains `p3-validation-ledger`, because the `DOCS_REVISION_MISMATCH` case the row names is a [P3-T3] test whose evidence file is `p3-validation-ledger`.
4. `## Acceptance Criteria Traceability` S17 row | Traceability citation | Evidence column gains `p4-update-ledger-dispositions`, because the `set-disposition` and `remove-entry` operation cases the row names are [P4-T4] tests whose evidence file is `p4-update-ledger-dispositions`.
5. `## Acceptance Criteria Traceability` S24 row | Traceability citation | Evidence column gains `p4-update-ledger-pins`, because the `update-ledger` summary-line case is a [P4-T5] test whose evidence file is `p4-update-ledger-pins`.

## Validator

Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/plan.2026-10-30T16-51.md`
Result before the fixes: `plan validation passed`, EXIT_CODE 0.
Result after the fixes: recorded in the preflight return.
