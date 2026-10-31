# Feature Audit: parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1 (#1006)

**Audit Date:** 2026-10-31
**Feature Folder:** `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006`
**Base Branch:** `main`
**Head Branch:** `bug/parallel-scheduling-false-hard-edges-1006`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `1898400756e909b88cde5f51a05f0b11d423d3b0`, `origin/main`)
- **Head branch/commit:** `bug/parallel-scheduling-false-hard-edges-1006` (commit `fc1d8618bf26e9e2ffa2e81dec5e1380ec2763f8`)
- **Merge base:** `1898400756e909b88cde5f51a05f0b11d423d3b0`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-31 08:53:30 UTC at the head SHA)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff 1898400756e909b88cde5f51a05f0b11d423d3b0...HEAD`
  - Feature evidence: `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/evidence/**`
  - Additional evidence: `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`, reviewer `cmp` checks of bundle copies, `validate_evidence_locations --root .` (exit 0)
- **Feature folder used:** `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` line 12 carries `- Work Mode: full-bug`, so `spec.md` is the only AC source; no `user-story.md` exists.
- **Scope note:** Full branch diff against the merge base. CI has not run on the head because no PR exists. No AC in `spec.md` is CI-dependent.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/spec.md` — only source (`## Acceptance Criteria`, 25 checkbox items)

### Acceptance criteria

1. AC-01 No hard edge for benign overlap: a recompute of two radii that share only append-only registry paths, generic worksheet names, and ordinary path/module overlap yields no hard edge. At `tolerance_percent` 0 the output stays identical to strict scheduling (the strict-identity proof still holds).
2. AC-02 Cross-runtime parity and key partition: the generic-contract constant and the demotion semantics are equal across Python, PowerShell, and TypeScript (where ported), and the key-partition exhaustiveness test covers the new overlay key.
3. AC-03 Mirror and published-table contracts: contract tests that pin mirrored and bundled files pass, and the published truth table carries the same `append_only_paths` change as the self-hosted table.
4. AC-04 Destination push-down: a push-down into a destination whose overlay has `shared_surfaces_demote: ["quality-tiers.yml"]` and `conflict_tolerance.tolerance_percent: 5000` produces a composed `config/blast-radius.json` in which `quality-tiers.yml` is in `conflict_tolerance.append_only_paths`, is not in `shared_surfaces`, and `tolerance_percent` is 5000; proven by in-memory push-down tests in both `test_push_down_claude_blast_radius_overlay_demote.py` and `claude-blast-radius-overlay-demote.test.ts`.
5. AC-05 Predicate definition: `is_generic_contract_token` and `Test-GenericContractToken` return true for `Sheet1`, `sheet12`, and `CHART3`, and false for `Sheet`, `Sheet1a`, `MySheet1`, `Sheet1.Range`, the empty string, a full-width-digit variant, a Kelvin-sign (U+212A) variant, `Book1`, and `Table1`; neither predicate raises on any string input.
6. AC-06 Python filtering sites: `extract_contract_identifiers`, `extract_write_intent_contracts`, and `normalize_declared_radius` each drop `Sheet1` and keep a genuine contract identifier in the same input, asserted in `test_blast_radius_generic_contracts.py`.
7. AC-07 PowerShell filtering sites: `Get-ContractIdentifier`, `Get-WriteIntentSpecContract`, and `Get-NormalizedDeclaredRadius` each drop `Sheet1` and keep a genuine contract identifier in the same input, asserted in `BlastRadiusGenericContract.Tests.ps1`; `Test-GenericContractToken` is exported from `BlastRadiusTokenShape.psm1` and re-exported from `BlastRadiusExtraction.psm1`.
8. AC-08 Constant parity: a Pester parity test reads `GENERIC_CONTRACT_STEMS` from `_blast_radius_token_shapes.py` and asserts it equals `$script:GenericContractStem`; a pytest pins `GENERIC_CONTRACT_STEMS` to the stems `Sheet` and `Chart`. No TypeScript or bash contract extractor exists, and the rule text states that TypeScript has no contract extractor.
9. AC-09 Fail-before evidence: the end-to-end issue-scenario tests in `test_blast_radius_generic_contracts.py` and `BlastRadiusGenericContract.Tests.ps1` were run against the pre-change code and failed with a hard `contract_dependency` or `shared_surface_overlap` edge, and the run is recorded under `evidence/regression-testing/` in this feature folder.
10. AC-10 Truth tables: in both `config/blast-radius.json` and `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`, `quality-tiers.yml` is absent from `shared_surfaces`, is the last entry of `conflict_tolerance.append_only_paths` with the prior entries unchanged and in their prior order, and is present in `mandate_reads`; `conflict_tolerance` is byte-equal across both copies (`test_class_one_keys_are_equal_across_both_committed_copies` and Pester `'declares equal values for the runtime-describing keys in both copies'` pass).
11. AC-11 Truth-table tests updated: `PORTABLE_SHARED_SURFACES`, `test_committed_conflict_tolerance_values`, `test_committed_conflict_tolerance_reads_cleanly`, the rewritten Pester truth-table test asserting the new membership in both copies, and the `SOURCE_BLAST_RADIUS` pin in `claude-config-carriage.test.ts` all pass against the edited tables.
12. AC-12 Constraint 2 text: in `.claude/rules/parallel-orchestration.md` under `### Read-by-mandate classification`, constraint 2 no longer states that `quality-tiers.yml` stays a shared surface; it states that `quality-tiers.yml` is an append-only registry and a mandate read, contends on `path_overlap` at the `append_only` weight, is never a hard edge (issue #1006), and that separator-free token acceptance for it through the root-surface rule no longer applies.
13. AC-13 Demotion move semantics: in both composers, each `shared_surfaces_demote` entry present in the composed `shared_surfaces` is removed from it with the order of the remaining entries preserved and is unioned into `conflict_tolerance.append_only_paths`; the directive key is absent from the composed output; demotion runs after all other keys are composed.
14. AC-14 Idempotent no-op: an entry already present in the composed `conflict_tolerance.append_only_paths` and absent from `shared_surfaces` is accepted without error and leaves both lists unchanged; composing an already-composed result again yields identical output.
15. AC-15 Fail closed: both composers raise `BlastRadiusOverlayError` with the identical detail text stated under Error handling and logging updates for a non-list value, a non-string member, a missing `conflict_tolerance.append_only_paths`, and an unknown entry; on rejection the destination `config/blast-radius.json` keeps its prior bytes.
16. AC-16 Guard and identity preserved: the `modules` forbidden-glob guard (`FORBIDDEN_GLOBS`) still rejects forbidden globs when the overlay also carries `shared_surfaces_demote`; an overlay without the directive, or no overlay, composes byte-identically to the pre-change composer (existing issue #508 AC01 and AC18 tests pass unchanged).
17. AC-17 Demotion parity corpus: the corpus fixtures `shared-surfaces-demote.json`, `shared-surfaces-demote-already-append-only.json`, and `shared-surfaces-demote-unknown-entry.json` (the last carrying `expected_error`) are asserted to the same expected text or error by both `test_ac16_corpus_composition_matches_expected` and the TypeScript "composes %s to its expected text" test; a constant-parity test pins `SHARED_SURFACES_DEMOTE_KEY` equal across the TypeScript and Python sources.
18. AC-18 Key-partition coverage: `OVERLAY_DIRECTIVE_KEYS` in `blast_radius_parity_test_support.py` declares `shared_surfaces_demote`; `test_every_top_level_key_is_classified_and_shared_by_both_copies` and Pester `'requires every top-level key in both copies to be classified and shared'` assert that the directive key is disjoint from every declared truth-table key class and absent from both committed truth tables.
19. AC-19 Overlay rule text: the issue #508 overlay paragraph in `.claude/rules/parallel-orchestration.md` no longer states that the overlay cannot remove a shipped surface; it documents `shared_surfaces_demote`, its fail-closed conditions, that the key is consumed, the already-append-only no-op, the unchanged forbidden-glob guard, and the `shared_surface_globs` residual.
20. AC-20 Token-shape rule text: the token-shape rejection paragraph under `### Read-by-mandate classification` lists the generic sheet-tab shape (`Sheet` or `Chart` followed by ASCII digits, compared case-insensitively) alongside the existing rejected shapes, its stated count of shapes matches the shapes listed, and a subsection "Generic contract-token rejection (issue #1006)" states that the stems are a code constant pinned equal across Python and PowerShell by a Pester parity test.
21. AC-21 Bundle copies byte-identical: each edited `.claude/lib/blast-radius/*.psm1` file and `.claude/rules/parallel-orchestration.md` is byte-identical to its copy under `extensions/drm-copilot/resources/claude-customizations/`, and `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, and `test_push_down_pack_manifest_dependency_closure.py` pass.
22. AC-22 Strict identity re-run: `test_property_tolerance_zero_equals_conflict`, `test_strict_identity_over_existing_conflict_fixtures`, `test_before_strict_scheduling_equals_detection`, `test_tolerance_zero_output_equals_conflict_only_output`, the Pester Context `'Strict identity'` in `BlastRadiusScheduling.Tests.ps1`, and `BlastRadius.HistoricalRuns.Tests.ps1` pass unchanged; `test_strictest_tolerance_keeps_a_scheduling_edge_for_every_must_conflict_case` carries an unconditional skip marker, is reported as skipped by that marker, and its file is unchanged against the merge base.
23. AC-23 Scope boundaries held: the change does not edit `HARD_REASON_KINDS`, `decide_pair`, `conflicts`, the `conflict_edges[].reason` enum, the parallel checkpoint schema, drift detection, `quality-tiers.yml`, or any `.github/instructions/` file; the diff touches only files named under Files/modules to change and feature-folder documentation and evidence.
24. AC-24 Coverage: every changed or new production file meets the line and branch coverage thresholds of `.claude/rules/general-unit-test.md` (line only for PowerShell), measured per file as described in the execution-environment brief; `claude-blast-radius-overlay-demote.ts` has its own `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs`; no production file is excluded from measurement; coverage on changed lines does not regress.
25. AC-25 Toolchain and isolation: the seven-stage toolchain loop passes in a single pass for Python, PowerShell, and TypeScript, and the test-isolation checks in the execution-environment brief pass and are recorded under `evidence/regression-testing/` in this feature folder.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-01 No hard edge for benign overlap | PASS | `test_issue_1006_scenario_has_no_hard_edge` and `..._tolerance_zero_equals_detection` (both tables) pass; Pester mirror passes; fail-before showed `path_overlap, shared_surface_overlap, contract_dependency` hard reasons | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_generic_contracts.py` (recorded in `evidence/regression-testing/pass-after.2026-10-31T08-21.md`) | Test inspected: scenario shares an ordinary path, `quality-tiers.yml`, and `Sheet1`. |
| 2 | AC-02 Cross-runtime parity and key partition | PASS | Pester stem-parity row; shared corpus asserted by Python and TS; `test_shared_surfaces_demote_key_constants_match`; `OVERLAY_DIRECTIVE_KEYS` and the Pester key-partition block | Full pytest, Pester, and Jest runs (`evidence/qa-gates/python-tests…`, `pester-full…`, `ts-jest…`) | TypeScript has no contract extractor, so constant parity is Python and PowerShell only, as the AC allows. |
| 3 | AC-03 Mirror and published-table contracts | PASS | Push-down contract tests exit 0; both truth-table diffs append `quality-tiers.yml` to `append_only_paths` identically | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py ...` (`evidence/qa-gates/push-down-contracts.2026-10-31T08-30.md`); reviewer `git diff` of both JSON files | |
| 4 | AC-04 Destination push-down | PASS | `test_ac04_push_demotes_quality_tiers_with_tolerance_5000` asserts all four conditions against the committed bundled table; the TS test "demotes quality-tiers.yml with tolerance 5000 on push" does the same | Full pytest and Jest runs | Tests inspected. |
| 5 | AC-05 Predicate definition | PASS | 3 recognition plus 10 rejection rows per runtime, including U+FF11, U+212A, and U+017F variants | Full pytest and Pester runs | The predicate is total: `isascii()` and `fullmatch`, and `-cnotmatch` and `IsMatch`, never raise on a string. |
| 6 | AC-06 Python filtering sites | PASS | `test_extract_contract_identifiers_drops_a_generic_token`, `test_extract_write_intent_contracts_drops_a_generic_token`, `test_normalize_declared_radius_drops_a_recorded_generic_contract` each expect `("ParseLedger",)` | Full pytest run | Diff confirms one conjunct per site. |
| 7 | AC-07 PowerShell filtering sites | PASS | Pester Context 'Contract-filtering sites' (3 rows); export rows for both modules; reviewer diff shows `Test-GenericContractToken` in both `Export-ModuleMember` lists | Pester full run (`evidence/qa-gates/pester-full.2026-10-31T08-49.md`) | |
| 8 | AC-08 Constant parity | PASS | Pester 'pins GenericContractStem to GENERIC_CONTRACT_STEMS in the Python source'; `test_generic_contract_stems_are_sheet_and_chart`; rule text "TypeScript has no contract extractor, so no TypeScript parity applies." | Full pytest and Pester runs; premise search in `evidence/baseline/premise-searches.2026-10-31T08-02.md` | |
| 9 | AC-09 Fail-before evidence | PASS | pytest 19 failed and Pester 21 failed on pre-change code, with hard reasons including `shared_surface_overlap` and `contract_dependency` | Recorded in `evidence/regression-testing/fail-before.2026-10-31T08-11.md` | |
| 10 | AC-10 Truth tables | PASS | Reviewer diff: `quality-tiers.yml` removed from `shared_surfaces` and appended last to `append_only_paths` in both copies, with prior entries unchanged; `mandate_reads` unchanged and still contains it; Class 1 parity tests pass in the full runs | `git diff 1898400756e909b88cde5f51a05f0b11d423d3b0...HEAD -- config/blast-radius.json extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` | |
| 11 | AC-11 Truth-table tests updated | PASS | `PORTABLE_SHARED_SURFACES` no longer lists `quality-tiers.yml`; tolerance-key, Pester truth-table, and `config-carriage.test-helpers.ts` updates are in the diff; full runs pass | Full pytest, Pester, and Jest runs | The `SOURCE_BLAST_RADIUS` pin lives in `config-carriage.test-helpers.ts`, which `claude-config-carriage.test.ts` consumes. |
| 12 | AC-12 Constraint 2 text | PASS | Rule diff: constraint 2 rewritten with every required statement | `git diff ... -- .claude/rules/parallel-orchestration.md` | |
| 13 | AC-13 Demotion move semantics | PASS | `test_demotion_moves_the_entry_and_keeps_the_remaining_order`, `test_demotion_consumes_the_directive_key`, `test_demotion_runs_after_every_other_key`, and the TS mirrors | Full pytest and Jest runs | |
| 14 | AC-14 Idempotent no-op | PASS | `test_already_append_only_entry_is_a_no_op`, `test_composing_a_composed_result_again_is_identical`, corpus `shared-surfaces-demote-already-append-only.json` | Full pytest and Jest runs | |
| 15 | AC-15 Fail closed | PASS | Python and TS assert the identical full messages for all four conditions; `test_rejection_keeps_the_prior_destination_bytes` and the TS equivalent | Full pytest and Jest runs | Detail text in both sources matches the spec verbatim (reviewer diff). |
| 16 | AC-16 Guard and identity preserved | PASS | `test_forbidden_glob_guard_still_runs_with_the_directive` and the TS mirror; existing #508 AC01 and AC18 tests unchanged and passing; the TS no-directive path returns the prior serialization | Full pytest and Jest runs | |
| 17 | AC-17 Demotion parity corpus | PASS | Three fixtures added; `test_ac16_corpus_composition_matches_expected` and TS "composes %s to its expected text" handle `expected_error`; `test_shared_surfaces_demote_key_constants_match` | Full pytest and Jest runs | |
| 18 | AC-18 Key-partition coverage | PASS | `OVERLAY_DIRECTIVE_KEYS = ("shared_surfaces_demote",)`; Pester block asserts absence from declared keys and from the union of both copies' keys | Full pytest and Pester runs | |
| 19 | AC-19 Overlay rule text | PASS | Rule diff: the "cannot remove a shipped surface" sentence is replaced; all required elements are documented, and the paragraph keeps "cannot remove a derived module" | `git diff` of the rule | |
| 20 | AC-20 Token-shape rule text | PASS | Paragraph says "five token shapes" and lists five; new subsection "Generic contract-token rejection (issue #1006)" states the Pester parity pin | `git diff` of the rule | The stale count in `.claude/skills/parallel-plan/SKILL.md` is out of scope by spec (code-review Minor). |
| 21 | AC-21 Bundle copies byte-identical | PASS | Reviewer `cmp`: rule and all five `.psm1` copies identical; the three contract tests pass | `cmp <source> <bundle copy>` for 6 pairs; `evidence/qa-gates/push-down-contracts.2026-10-31T08-30.md` | |
| 22 | AC-22 Strict identity re-run | PASS | 8 passed and 1 skipped by its unconditional marker; Pester 'Strict identity' 15/15 and HistoricalRuns 9/9; the seven pin files are unchanged against the merge base | `evidence/qa-gates/strict-identity.2026-10-31T08-37.md` | |
| 23 | AC-23 Scope boundaries held | PASS | `git diff --quiet` exit 0 over the frozen paths; reviewer diff stat lists only spec items 1 to 40, feature-folder documents and evidence, and the issue-promotion record | `evidence/qa-gates/scope-check.2026-10-31T08-40.md`; reviewer `git diff --stat` | The promotion record `docs/features/potential/promoted/...` is the feature's lifecycle documentation written at promotion; it is treated as feature documentation (code-review Info). |
| 24 | AC-24 Coverage | PASS | Per-file: Python verified in `artifacts/python/lcov.info` (98% to 100% line, 95.24% to 100% branch); PowerShell verified in `artifacts/pester/powershell-coverage.xml` (100% line each); TS per-file `coverageThreshold` entries (85/75) passed in a `--coverage` run that exited 0; no production exclusion added; changed lines 100% covered | `grep` of LF/LH/BRF/BRH and the JaCoCo LINE counters; `evidence/qa-gates/coverage-comparison.2026-10-31T08-49.md` | The AC is per file. The repo-wide artifact gaps are policy findings PA-1 and PA-2, not AC-24 gaps. |
| 25 | AC-25 Toolchain and isolation | PASS | All seven stages exit 0 per language; Jest seeded shuffle, reversed pytest, and three seeded Pester orders pass | `evidence/qa-gates/seven-stage-mapping.2026-10-31T08-37.md`; `evidence/regression-testing/isolation.2026-10-31T08-39.md` | |

---

## Summary

**Overall Feature Readiness:** PASS

All 25 acceptance criteria are delivered and verified. Overall review readiness is still governed by the policy-audit coverage-evidence findings PA-1 (autonomous) and PA-2 (awaiting CI). Those findings concern repo-wide coverage reporting, not any acceptance criterion.

**Criteria summary:**
- **PASS:** 25 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None at the acceptance-criteria level.

**Recommended follow-up verification steps:**

1. Produce `extensions/drm-copilot/coverage/lcov.info` with `npm --prefix extensions/drm-copilot run test:coverage` and record per-file and repo-wide TypeScript figures (policy-audit PA-1).
2. Confirm the PR CI step `Enforce Python coverage thresholds` concludes `success` on the final head (policy-audit PA-2).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file if they are markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/spec.md`
- Total AC items: 25
- Checked off (delivered): 25
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 25 | 25 | 0 | Checkbox-backed; all 25 were already checked by the executor, and this audit's evaluation agrees with each. |

No source-file checkbox change was made by this review, because every criterion was already checked and every criterion evaluated PASS.
