# Preflight Fixes - Issue #1023

Timestamp: 2026-10-30T21-29
Plan: docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/plan.2026-10-30T16-51.md
Directive: PREFLIGHT VALIDATION ONLY (single pass; no task executed, no checkbox changed)

## Fixes

1. [P7-T3] | AC test enumeration (spec AC S16) | `test_invalid_values_exit_two` cases now include an unknown option, so `dev.docs.update-ledger` is tested for exit 2 on an unknown option as the criterion requires for each command.
2. [P7-T5] | AC test enumeration (spec AC S16) | `test_missing_mode_exits_two` is parametrized with an unknown option as a second case, each case asserting one `DOCS_CLI_ARGUMENTS` finding and `result` `null`, so `dev.docs.validate` is tested for exit 2 on an unknown option.
3. [P9-T3] | Unobservable acceptance value (validator-blind class: asserted value not printed on a successful run) | The `-q` run prints no parameter IDs; the acceptance now reads the neutrality test's node IDs from `poetry run pytest tests/docs_runtime/test_neutrality.py --collect-only -q`. The asserted property (the sixteen new modules are in the scan scope) is unchanged.
4. [P10-T5] | Coverage comparison scope mismatch | The baseline in [P0-T6] measures `--cov=drm_copilot_docs` only, while [P10-T4] measures the configured repository source. The coverage-delta record now compares the baseline `drm_copilot_docs` totals with the post-change `drm_copilot_docs` totals from the [P10-T5] report and records the [P10-T4] repository totals separately. Per-module floors are unchanged.
5. `## Acceptance Criteria Traceability` | Traceability citation | U14 (every receipt validates against its schema; id independent of `issued_at`) added to the S6 row with `test_build_receipt_validates_against_schema`; U13 (JSON envelope keys and exit codes) added to the S17 row. Both criteria were already mapped by identifier only; the added rows name the tests that prove the schema and envelope halves.
