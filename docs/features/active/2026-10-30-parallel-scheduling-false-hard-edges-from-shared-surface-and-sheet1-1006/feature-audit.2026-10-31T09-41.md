# Feature Audit: parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1 (#1006)

**Audit Date:** 2026-10-31
**Feature Folder:** `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006`
**Base Branch:** `main`
**Head Branch:** `bug/parallel-scheduling-false-hard-edges-1006`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit at the exit of remediation cycle 1 (prior audit `feature-audit.2026-10-31T08-57.md`)

---

## Scope and Baseline

- **Base branch:** `main` (commit `1898400756e909b88cde5f51a05f0b11d423d3b0`, `origin/main`)
- **Head branch/commit:** `bug/parallel-scheduling-false-hard-edges-1006` (commit `d7dd48791e6ad0a1127251dcf32284c1cabd51aa`)
- **Merge base:** `1898400756e909b88cde5f51a05f0b11d423d3b0`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-31 09:39:02 UTC at the head SHA)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff 1898400756e909b88cde5f51a05f0b11d423d3b0..HEAD`
  - Feature evidence: `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/evidence/**`, including cycle 1 evidence under `remediation-baseline/`, `qa-gates/*.2026-10-31T09-*.md`, and `regression-testing/*.2026-10-31T09-*.md`
  - Additional evidence: `extensions/drm-copilot/coverage/lcov.info`, `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`, reviewer `cmp` of six bundle pairs, `validate_evidence_locations.py --root .` (exit 0), reviewer inspection of the cycle code diff `fc1d8618b..d7dd48791`
- **Feature folder used:** `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` line 12 carries `- Work Mode: full-bug`, so `spec.md` is the only AC source; no `user-story.md` exists.
- **Scope note:** Full branch diff against the merge base. CI has not run on the head because no PR exists. No AC in `spec.md` is CI-dependent. Cycle 1 changed no behavior covered by an AC; the AC re-evaluation below confirms each criterion still holds at the new head.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/spec.md` — only source (`## Acceptance Criteria`, 25 checkbox items)

### Acceptance criteria

1. AC-01 No hard edge for benign overlap: a recompute of two radii that share only append-only registry paths, generic worksheet names, and ordinary path/module overlap yields no hard edge; at `tolerance_percent` 0 the output stays identical to strict scheduling.
2. AC-02 Cross-runtime parity and key partition: the generic-contract constant and the demotion semantics are equal across Python, PowerShell, and TypeScript (where ported), and the key-partition exhaustiveness test covers the new overlay key.
3. AC-03 Mirror and published-table contracts: contract tests that pin mirrored and bundled files pass, and the published truth table carries the same `append_only_paths` change as the self-hosted table.
4. AC-04 Destination push-down: a push-down with `shared_surfaces_demote: ["quality-tiers.yml"]` and `tolerance_percent: 5000` yields `quality-tiers.yml` in `append_only_paths`, not in `shared_surfaces`, and `tolerance_percent` 5000, proven in both runtimes.
5. AC-05 Predicate definition: `is_generic_contract_token` and `Test-GenericContractToken` accept `Sheet1`, `sheet12`, `CHART3` and reject the listed negatives and look-alikes; neither raises.
6. AC-06 Python filtering sites: the three Python sites drop `Sheet1` and keep a genuine contract identifier.
7. AC-07 PowerShell filtering sites: the three PowerShell sites drop `Sheet1` and keep a genuine contract identifier; `Test-GenericContractToken` is exported and re-exported.
8. AC-08 Constant parity: a Pester parity test pins `$script:GenericContractStem` to `GENERIC_CONTRACT_STEMS`; a pytest pins the stems; the rule states TypeScript has no contract extractor.
9. AC-09 Fail-before evidence: the issue-scenario tests failed on pre-change code with a hard edge, recorded under `evidence/regression-testing/`.
10. AC-10 Truth tables: `quality-tiers.yml` absent from `shared_surfaces`, last in `append_only_paths`, present in `mandate_reads`; `conflict_tolerance` byte-equal across both copies.
11. AC-11 Truth-table tests updated and passing.
12. AC-12 Constraint 2 text rewritten as specified.
13. AC-13 Demotion move semantics in both composers.
14. AC-14 Idempotent no-op for an already append-only entry.
15. AC-15 Fail closed with identical detail text and preserved destination bytes.
16. AC-16 Forbidden-glob guard and no-directive byte identity preserved.
17. AC-17 Demotion parity corpus asserted by both runtimes; `SHARED_SURFACES_DEMOTE_KEY` constant parity.
18. AC-18 Key-partition coverage of `shared_surfaces_demote` in pytest and Pester.
19. AC-19 Overlay rule text documents `shared_surfaces_demote`.
20. AC-20 Token-shape rule text lists the generic sheet-tab shape with a matching count and the new subsection.
21. AC-21 Bundle copies byte-identical and push-down contract tests pass.
22. AC-22 Strict-identity tests pass unchanged; the skipped test keeps its unconditional marker and is unchanged.
23. AC-23 Scope boundaries held: frozen surfaces unedited; the diff touches only spec-named files plus feature documentation and evidence.
24. AC-24 Coverage: every changed or new production file meets the line and branch thresholds per file; the demote module has its own `coverageThreshold`; no production exclusion; no changed-line regression.
25. AC-25 Toolchain and isolation: the seven-stage loop passes in a single pass for all three languages, and isolation checks pass and are recorded.

The full criterion text is in `spec.md` under `## Acceptance Criteria`; the items above are abbreviated for this table and do not alter it.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-01 No hard edge for benign overlap | PASS | `test_issue_1006_scenario_has_no_hard_edge` and `..._tolerance_zero_equals_detection` pass for both tables; Pester mirror passes (13541, 0 failures at `pester-full.2026-10-31T09-35.md`) | `evidence/regression-testing/pass-after.2026-10-31T08-21.md` | No Python or production PowerShell change in cycle 1. |
| 2 | AC-02 Cross-runtime parity and key partition | PASS | Pester stem-parity row; shared corpus asserted by Python and TS (TS corpus re-run in `ts-union-helper.2026-10-31T09-15.md`); key-partition block passes after the local-variable change (`pester-keypartition.2026-10-31T09-16.md`) | Full Jest and Pester runs | |
| 3 | AC-03 Mirror and published-table contracts | PASS | Push-down contract tests exit 0; both truth tables carry the same change | `evidence/qa-gates/push-down-contracts.2026-10-31T08-30.md`; reviewer diff of both JSON files | Cycle 1 changed no bundled resource. |
| 4 | AC-04 Destination push-down | PASS | Python and TS AC-04 tests pass; the TS test is among the six named in remediation plan P1-T1 and passed unchanged | `ts-union-helper.2026-10-31T09-15.md`; full pytest run | |
| 5 | AC-05 Predicate definition | PASS | 3 recognition plus 10 rejection rows per runtime | Full pytest and Pester runs | |
| 6 | AC-06 Python filtering sites | PASS | Three site tests expect `("ParseLedger",)` | Full pytest run | |
| 7 | AC-07 PowerShell filtering sites | PASS | Pester Context 'Contract-filtering sites' and export rows | `pester-full.2026-10-31T09-35.md` | |
| 8 | AC-08 Constant parity | PASS | Pester parity row; `test_generic_contract_stems_are_sheet_and_chart`; rule text | Full pytest and Pester runs | |
| 9 | AC-09 Fail-before evidence | PASS | pytest 19 failed and Pester 21 failed pre-change with hard reasons | `evidence/regression-testing/fail-before.2026-10-31T08-11.md` | |
| 10 | AC-10 Truth tables | PASS | Reviewer diff of both tables; Class 1 parity tests pass | `git diff 1898400756e909b88cde5f51a05f0b11d423d3b0..HEAD -- config/blast-radius.json <bundle copy>` | |
| 11 | AC-11 Truth-table tests updated | PASS | Updated tests in the diff; full runs pass | Full pytest, Pester, and Jest runs | |
| 12 | AC-12 Constraint 2 text | PASS | Rule diff | `git diff ... -- .claude/rules/parallel-orchestration.md` | |
| 13 | AC-13 Demotion move semantics | PASS | Python tests and TS mirrors, including `"moves the entry and keeps the remaining order"`, pass after the union consolidation | `ts-union-helper.2026-10-31T09-15.md`; full pytest run | |
| 14 | AC-14 Idempotent no-op | PASS | `"treats an already append-only entry as a no-op"` and `"yields identical output when a composed result is composed again"` pass unchanged; Python mirrors pass | `ts-union-helper.2026-10-31T09-15.md` | The refactored union preserves de-duplication against base strings. |
| 15 | AC-15 Fail closed | PASS | Identical detail text in both runtimes; prior bytes preserved | Full pytest and Jest runs | Cycle 1 did not touch validation code. |
| 16 | AC-16 Guard and identity preserved | PASS | Guard tests pass; #508 AC01/AC18 tests (`"idempotence: composing twice equals composing once"`, `"superset: every base list entry survives"`, `"overlay inclusion: every overlay list entry and module appears"`) pass unchanged after `unionStrings` moved | `ts-union-helper.2026-10-31T09-15.md` | |
| 17 | AC-17 Demotion parity corpus | PASS | `"composes %s to its expected text"` passes for every corpus row, including the three `shared-surfaces-demote*.json` fixtures | `ts-union-helper.2026-10-31T09-15.md`; full pytest run | |
| 18 | AC-18 Key-partition coverage | PASS | `OVERLAY_DIRECTIVE_KEYS`; Pester block now uses `$overlayDirectiveKey`, 6 of 6 pass | `pester-keypartition.2026-10-31T09-16.md` | |
| 19 | AC-19 Overlay rule text | PASS | Rule diff | `git diff` of the rule | |
| 20 | AC-20 Token-shape rule text | PASS | "five token shapes" with five listed; new subsection present | `git diff` of the rule | The stale count in `.claude/skills/parallel-plan/SKILL.md` is out of scope by spec. |
| 21 | AC-21 Bundle copies byte-identical | PASS | Reviewer `cmp` at head: rule and five `.psm1` pairs identical; contract tests pass | `cmp <source> <bundle copy>` (six pairs) | |
| 22 | AC-22 Strict identity re-run | PASS | 8 passed, 1 skipped by its unconditional marker; Pester 'Strict identity' and HistoricalRuns pass; pin files unchanged | `evidence/qa-gates/strict-identity.2026-10-31T08-37.md`; full Pester run at 09-35 | |
| 23 | AC-23 Scope boundaries held | PASS | Cycle scope check: only feature-folder paths added; `.claude/skills/parallel-plan/SKILL.md`, its bundle copy, every Python file, `jest.config.cjs`, and the frozen paths unchanged since the cycle baseline | `evidence/qa-gates/scope-check.2026-10-31T09-36.md`; reviewer `git diff --name-status` | Cycle 1 code edits are confined to two spec-named TS files and one spec-named Pester file. |
| 24 | AC-24 Coverage | PASS | Python per-file in `artifacts/python/lcov.info` (98% to 100% line, 95.24% to 100% branch); PowerShell 100% line each in `artifacts/pester/powershell-coverage.xml`; TypeScript per-file read by the reviewer from `extensions/drm-copilot/coverage/lcov.info` (overlay 99.55%/96.00%, demote 100%/100%); both `coverageThreshold` entries kept; no production exclusion; no changed line uncovered | `awk` over `lcov.info`; JaCoCo LINE counters; `coverage-comparison.2026-10-31T09-17.md` | The AC is per file. The repo-wide Python figure is policy finding PA-2, not an AC-24 gap. |
| 25 | AC-25 Toolchain and isolation | PASS | Initial seven-stage pass for all languages; cycle 1 TS and PS loop in a single clean pass; isolation re-run (Jest seed 1006; Pester seeds 11/23/47) | `seven-stage-mapping.2026-10-31T08-37.md`; `ts-*.2026-10-31T09-17.md`; `ps-format`/`pssa.2026-10-31T09-18.md`; `isolation.2026-10-31T09-36.md` | |

---

## Summary

**Overall Feature Readiness:** PASS

All 25 acceptance criteria remain delivered and verified at head `d7dd48791`. Overall review readiness is governed by the policy-audit coverage-evidence finding PA-2 (Python repo-wide figure, awaiting CI), which does not concern any acceptance criterion. PA-1 was closed in cycle 1.

**Criteria summary:**
- **PASS:** 25 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None at the acceptance-criteria level.

**Recommended follow-up verification steps:**

1. Open the PR and, at the S9 CI gate, record the PR CI step `Enforce Python coverage thresholds` conclusion and pytest `TOTAL` line for the final head under `evidence/qa-gates/` (policy-audit PA-2).

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
| `spec.md` | 25 | 25 | 0 | Checkbox-backed; all 25 were already checked, and this re-audit's evaluation agrees with each. The four unchecked boxes elsewhere in `spec.md` are severity and log-attachment selectors under `## Context` and `## Repro & Evidence`, not acceptance criteria. |

No source-file checkbox change was made by this review, because every criterion was already checked and every criterion evaluated PASS.
