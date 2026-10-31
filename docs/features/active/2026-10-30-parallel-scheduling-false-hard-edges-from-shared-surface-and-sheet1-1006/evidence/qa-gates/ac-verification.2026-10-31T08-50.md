# Acceptance Criteria Verification (issue #1006)

Timestamp: 2026-10-31T08-50
Task: P8-T18
Command: none (mapping of FEATURE/spec.md AC-01 to AC-25 to recorded evidence)
EXIT_CODE: 0
Output Summary: 25 of 25 acceptance criteria verified locally and checked off in `FEATURE/spec.md`. CI on the pull-request head is pending and owned by the orchestrator at S9.

Evidence paths are relative to `FEATURE/evidence/`; a consumer selects the lexicographically greatest `<name>.*.md`.

| AC | Status | Evidence |
|---|---|---|
| AC-01 No hard edge for benign overlap; tolerance 0 equals strict scheduling | Verified | regression-testing/pass-after (`test_issue_1006_scenario_has_no_hard_edge` and `..._tolerance_zero_equals_detection` for both tables; Pester `'Issue 1006 scenario'` rows); qa-gates/strict-identity |
| AC-02 Cross-runtime parity and key partition | Verified | Pester `'pins GenericContractStem to GENERIC_CONTRACT_STEMS in the Python source'` (qa-gates/pester-full); `test_shared_surfaces_demote_key_constants_match` and the shared corpus (P5-T6); key-partition rows (P5-T9) |
| AC-03 Mirror and published-table contracts | Verified | qa-gates/push-down-contracts; other/mirror-parity; `test_class_one_keys_are_equal_across_both_committed_copies` (qa-gates/python-tests) |
| AC-04 Destination push-down with demotion and tolerance 5000 | Verified | `test_ac04_push_demotes_quality_tiers_with_tolerance_5000`; "demotes quality-tiers.yml with tolerance 5000 on push (issue #1006 AC-04)" (qa-gates/python-tests, qa-gates/ts-jest) |
| AC-05 Predicate definition | Verified | predicate rows in `test_blast_radius_generic_contracts.py` and `BlastRadiusGenericContract.Tests.ps1` (regression-testing/fail-before shows them failing before; qa-gates/python-tests and qa-gates/pester-full show them passing) |
| AC-06 Python filtering sites | Verified | three site tests in `test_blast_radius_generic_contracts.py` (qa-gates/python-tests) |
| AC-07 PowerShell filtering sites and exports | Verified | three site rows and two export rows in `BlastRadiusGenericContract.Tests.ps1` (qa-gates/pester-full) |
| AC-08 Constant parity; no TS or bash extractor; rule states it | Verified | Pester parity row; `test_generic_contract_stems_are_sheet_and_chart`; baseline/premise-searches search (b); rule subsection `#### Generic contract-token rejection (issue #1006)` |
| AC-09 Fail-before evidence | Verified | regression-testing/fail-before |
| AC-10 Truth tables | Verified | P4-T1 and P4-T2 membership check; `test_class_one_keys_are_equal_across_both_committed_copies`; Pester `'declares equal values for the runtime-describing keys in both copies'` |
| AC-11 Truth-table tests updated | Verified | `PORTABLE_SHARED_SURFACES`, `test_committed_conflict_tolerance_values`, `test_committed_conflict_tolerance_reads_cleanly`, Pester `'lists quality-tiers.yml as an append-only path and a mandate read, not a shared surface, in both copies'`, and the `SOURCE_BLAST_RADIUS` pin (qa-gates/python-tests, qa-gates/pester-full, qa-gates/ts-jest) |
| AC-12 Constraint 2 text | Verified | `.claude/rules/parallel-orchestration.md` `### Read-by-mandate classification` constraint 2 (P6-T1) |
| AC-13 Demotion move semantics | Verified | move, consumed-key, and after-all-keys tests in both demote suites; corpus `shared-surfaces-demote.json` |
| AC-14 Idempotent no-op | Verified | no-op and compose-twice tests in both suites; corpus `shared-surfaces-demote-already-append-only.json` |
| AC-15 Fail closed | Verified | four fail-closed cases asserted with full messages and the prior-bytes tests in both suites; corpus `shared-surfaces-demote-unknown-entry.json` |
| AC-16 Guard and identity preserved | Verified | forbidden-glob tests in both suites; unchanged issue #508 AC01 and AC18 tests pass (qa-gates/python-tests, qa-gates/ts-jest) |
| AC-17 Demotion parity corpus | Verified | `test_ac16_corpus_composition_matches_expected` and "composes %s to its expected text" over nine files; `test_shared_surfaces_demote_key_constants_match` |
| AC-18 Key-partition coverage | Verified | `OVERLAY_DIRECTIVE_KEYS`; `test_every_top_level_key_is_classified_and_shared_by_both_copies`; Pester `'requires every top-level key in both copies to be classified and shared'` |
| AC-19 Overlay rule text | Verified | issue #508 overlay paragraph in `### The published truth table is not a copy of this one (issue #500)` (P6-T3) |
| AC-20 Token-shape rule text | Verified | five-shape paragraph and subsection heading (P6-T2) |
| AC-21 Bundle copies byte-identical | Verified | other/mirror-parity; qa-gates/push-down-contracts |
| AC-22 Strict identity re-run | Verified | qa-gates/strict-identity |
| AC-23 Scope boundaries held | Verified | qa-gates/scope-check |
| AC-24 Coverage | Verified | qa-gates/coverage-comparison; `coverageThreshold` entry for `claude-blast-radius-overlay-demote.ts` |
| AC-25 Toolchain and isolation | Verified | qa-gates/python-black, python-ruff, python-pyright, python-tests, ps-format, pssa, pester-full, ts-prettier, ts-lint, ts-typecheck, ts-jest, seven-stage-mapping; regression-testing/isolation |

## Pending CI (orchestrator-owned at S9)

The following required checks on the pull-request head have not run yet; the orchestrator dispatches and polls them at S9:

- `poshqc / PowerShell QC` (aggregates `poshqc / PowerShell QC static` and the shard jobs `poshqc / PowerShell QC shard 1`, `shard 2`, and `shard 3` on `windows-latest`)
- `quality-checks7 / Code Quality & Tests (3.10)`, `(3.11)`, `(3.12)`, `(3.13)`
- `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)` and `(windows-latest)`
- `shell-coverage / Shell Coverage (Bats + kcov)`
- `security-scan / Security Scanning`
- `docs-validation / Documentation Validation`
- `build-check / Build Package`

No acceptance criterion in `FEATURE/spec.md` depends on the CI result, so none is left unchecked for CI.

## Follow-ups

Recorded in other/follow-ups: the stale "three token shapes" sentence in `.claude/skills/parallel-plan/SKILL.md` and its bundle copy.
