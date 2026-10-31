# Feature Audit: Parallel Scheduling Integration Cost (#1013)

---

**Audit Date:** 2026-10-31
**Feature Folder:** `docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013`
**Base Branch:** `main`
**Head Branch:** `feature/parallel-scheduling-integration-cost-1013`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `1174736c7a3cbd7dd5c73620b2c1ed02ec2c3cd6`)
- **Head branch/commit:** `feature/parallel-scheduling-integration-cost-1013` (commit `8683e0a7531b22794dac7b0431127cba5b390484`)
- **Merge base:** `1174736c7a3cbd7dd5c73620b2c1ed02ec2c3cd6`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-31 17:16 UTC at the head above)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `evidence/baseline/**`, `evidence/qa-gates/**`, `evidence/regression-testing/**`, `evidence/other/**` in the feature folder
  - Additional evidence: this review's check-only re-runs (Black, Ruff, Pyright, 338 targeted Python tests, evidence-location scan, source/bundle blob-hash comparison, line counts), `artifacts/python/lcov.info`, executor Pester JaCoCo report
- **Feature folder used:** `docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` line 10 carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are authoritative.
- **Scope note:** The audit scope is the full branch diff (129 files). Pester and Jest suites were not re-run by this review; their results come from executor evidence with recorded commands and exit codes. AC-14's bash lane runs only in CI and is classified as a CI-dependent criterion.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` — primary (29 checkbox items, `## Acceptance Criteria`, lines 389-444)
- `user-story.md` — secondary (29 checkbox items: US-01 to US-19 and 10 issue-traceability items, lines 62-133)

### From spec.md

Each item is identified by its stable ID and leading label; the full criterion text is in `spec.md` at the cited line and is not modified.

1. AC-01 Default tolerance pin (line 395)
2. AC-02 Cap selection (line 399)
3. AC-03 Single entry point (line 400)
4. AC-04 Strict identity (line 401)
5. AC-05 Set-level properties (line 402)
6. AC-06 Telemetry recorded (line 406)
7. AC-07 No automatic tuning (line 407)
8. AC-08 Threshold validation (line 411)
9. AC-09 Committed value and destination override (line 412)
10. AC-10 Combination library (line 416)
11. AC-11 Planner procedure (line 417)
12. AC-12 One branch, one PR, both issues closed (line 418)
13. AC-13 Prompt-shape safety (line 419)
14. AC-14 Combined item records validate (line 420)
15. AC-15 parallel-add reports only (line 421)
16. AC-16 Remediation as one unit (line 422)
17. AC-17 Plan report (line 423)
18. AC-18 Bundle copies and pack manifest (line 427)
19. AC-19 Facade export set (line 428)
20. AC-20 Token-shape sentence corrected (line 432)
21. AC-21 Dependency gate (line 433)
22. AC-22 Scope boundaries held (line 434)
23. AC-23 Fail-before evidence (line 435)
24. AC-24 Coverage (line 436)
25. AC-25 Toolchain, file size, and isolation (line 437)
26. AC-26 Contract weight validation (line 441)
27. AC-27 Cost summed once per shared contract identifier (line 442)
28. AC-28 Contract-only pair eligibility (line 443)
29. AC-29 Tolerance-0 strict identity with the contract term (line 444)

### From user-story.md

1. US-01 An item whose tolerated overlaps exceed its aggregate cap has its cheapest-to-serialize pair converted to an edge, deterministically, in both Python and PowerShell (spec AC-02, AC-03).
2. US-02 At `tolerance_percent` 0 the edge set equals strict scheduling, and the existing strict-identity pins pass with test bodies unchanged (spec AC-04).
3. US-03 The set-level scheduling properties are pinned and the rule text narrows the monotonicity statement to the pairwise decision (spec AC-05).
4. US-04 A pair meeting the combination threshold, with candidates limited to `contract_dependency` or same-file overlap, is combined by the library with deterministic members, primary, pairs, and estimated savings (spec AC-10).
5. US-18 A pair that shares only contracts has a nonzero cost (`conflict_tolerance.weights.contract` summed once per shared contract identifier) and is combined when that cost meets the threshold; `contract_dependency` remains a hard edge class, and at `tolerance_percent` 0 the edge set stays identical to strict scheduling (spec AC-27, AC-28, AC-29).
6. US-05 The planner combines without operator approval, re-plans on the primary branch, assigns the combined item a band from a fresh complexity assessment, and records `combined_issue_nums` and the `combinations` list (spec AC-11, AC-14).
7. US-06 The combined item runs as one child with one branch and one PR whose autoclose line names every member issue; no umbrella issue is created (spec AC-12, AC-13).
8. US-07 A combined item that fails review or CI remediates as one unit and never splits back into separate PRs (spec AC-16).
9. US-08 The plan report lists each combination with its members, pairs, threshold, and estimated savings, and lists not-combined qualifying pairs with the reason (spec AC-17).
10. US-09 `parallel-add` reports a qualifying overlap with an unstarted item without combining it (spec AC-15).
11. US-10 Observed resolution time per tolerated pair is recorded in the orchestrator checkpoint and projected into the run's `parallel-status.md` (spec AC-06).
12. US-11 No code reads the recorded telemetry, and no weight changes automatically (spec AC-07).
13. US-12 A destination with no overlay receives `tolerance_percent` 100 and `combination_threshold_percent` 400 from the published truth table (spec AC-01).
14. US-13 `combination_threshold_percent` is read from `conflict_tolerance`, validated like the other members, and its accept, reject, and default behavior is equal across Python and PowerShell (spec AC-08).
15. US-14 The committed value is equal in both truth tables, and a destination overlay value is composed identically by the TypeScript and Python composers (spec AC-09).
16. US-19 `conflict_tolerance.weights.contract` is a required integer of at least 1, validated like the other weights with fail-fast errors naming the key and booleans rejected, equal across Python and PowerShell, carried by the TypeScript push-down and overlay surfaces, and committed byte-equal in both truth tables; a destination overlay can change it (spec AC-09, AC-26).
17. US-15 Mirrored and bundled copies are byte-identical to their sources, the pack manifest lists the new modules, and the contract tests pass (spec AC-18, AC-19, AC-20).
18. US-16 The change stays within its declared scope: no edge-reason enum change, no validated checkpoint schema change, no validator, drift, or hook change (spec AC-22), and it is delivered on top of merged #1006 (spec AC-21).
19. US-17 Fail-before evidence, coverage, toolchain, file-size, and isolation gates pass and are recorded (spec AC-23, AC-24, AC-25).
20. Traceability items T-1 to T-10 (`user-story.md` lines 124-133), restating the ten issue acceptance criteria; T-4 is "A pair meeting the combination threshold becomes one item with one branch and one PR closing both issues; its complexity band comes from a fresh assessment (US-04, US-05, US-06; spec AC-10 to AC-14)."

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-01 Default tolerance pin | PASS | `test_push_down_claude_blast_radius_default_tolerance.py` (re-run, pass); `blast-radius-default-tolerance.test.ts` (Jest pass per `typescript.2026-10-31T16-01.md`); dossier `fail-before-exception.2026-10-31T15-21.md` | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_blast_radius_default_tolerance.py --no-cov` | Behavior holds at base; exception dossier is the specified fail-before route. |
| 2 | AC-02 Cap selection | PASS | `_blast_radius_aggregate.py:66-122`, `BlastRadiusAggregate.psm1:86-152`; three aggregate fixtures in both suites | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_aggregate.py --no-cov` | Key `(benefit, -cost, a, b)` matches spec D-2. |
| 3 | AC-03 Single entry point | PASS | `_apply_aggregate_cap` in `_blast_radius_scheduling.py:454-484`; PowerShell post-pass in `Get-BlastRadiusConflictEdge`; aggregate module imports scheduling under `TYPE_CHECKING` only (line 31-34) | diff inspection; aggregate tests | |
| 4 | AC-04 Strict identity | PASS | Named strict-identity tests pass in the full suite (`python-tests.2026-10-31T16-08.md`) and Pester (`powershell-tests.2026-10-31T16-59.md`); regression-452 skip unchanged | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_scheduling.py --no-cov` (re-run, pass) | |
| 5 | AC-05 Set-level properties | PASS | `test_blast_radius_aggregate_properties.py` (re-run, pass); rule text narrowed in `.claude/rules/parallel-orchestration.md` | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_aggregate_properties.py --no-cov` | |
| 6 | AC-06 Telemetry recorded | PASS | Rule, skill, template edits; validator acceptance tests pass (`validator-acceptance.2026-10-31T15-46.md`; Python re-run) | `poetry run pytest tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py --no-cov` | |
| 7 | AC-07 No automatic tuning | PASS | `test_parallel_issue_combination_contracts.py` (re-run, pass); weight values `same_file` 8, `possible_overlap` 2, `append_only` 1, `module` 2 unchanged in `config/blast-radius.json` diff | `poetry run pytest tests/scripts/dev_tools/test_parallel_issue_combination_contracts.py --no-cov` | |
| 8 | AC-08 Threshold validation | PASS | `test_blast_radius_combination_threshold.py` (re-run, pass); Pester parity row in `BlastRadiusCombination.Tests.ps1` | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_combination_threshold.py --no-cov` | |
| 9 | AC-09 Committed value and destination override | PASS | Both truth tables end `conflict_tolerance` with `"combination_threshold_percent": 400` and `weights` with `"contract": 8`; overlay fixture `conflict-tolerance-combination-threshold.json`; contract tests pass (`contract-tests.2026-10-31T15-55.md`) | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py --no-cov` (re-run, pass) | |
| 10 | AC-10 Combination library | PASS | `_blast_radius_combination.py`, `BlastRadiusCombination.psm1`; four combination fixtures asserted in both runtimes | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_combination.py --no-cov` (re-run, pass) | Duplicate-key reject path untested in both runtimes (policy finding F-2; not part of the AC text). |
| 11 | AC-11 Planner procedure | PASS | `.claude/skills/parallel-plan/SKILL.md` `## Issue Combination`; `.claude/agents/parallel-planner.md`; contract tests pass (`contract-text.2026-10-31T15-53.md`) | `poetry run pytest tests/scripts/dev_tools/test_parallel_issue_combination_contracts.py --no-cov` | |
| 12 | AC-12 One branch, one PR, both issues closed | PASS | Skill text in parallel-orchestrate, pr-author, orchestrate; two new allow rows in `enforce-model-routing-receipt.AuthorAsserted.Tests.ps1` (Pester pass) | contract tests; `powershell-tests.2026-10-31T16-59.md` | |
| 13 | AC-13 Prompt-shape safety | PASS | `test_parallel_issue_combination_contracts.py` hook-pattern and path-absence assertions (re-run, pass) | as row 11 | |
| 14 | AC-14 Combined item records validate | UNVERIFIED | Python manifest contract (`test_parallel_manifest_bash_parity.py[manifest_valid_combined_item]`, re-run, pass); Python and TypeScript validator suites pass. The bash validator lane `tests/shell/parallel_manifest_parity.bats` runs only in CI `shell-coverage / Shell Coverage (Bats + kcov)`. | `poetry run pytest tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py --no-cov`; CI bats lane pending | CI-dependent criterion: left unchecked; the item's orchestrator run checks it off at S9 after `ci_gate.conclusion == success`. Not a blocking review finding. |
| 15 | AC-15 parallel-add reports only | PASS | `.claude/skills/parallel-add/SKILL.md` step 3; contract test | as row 11 | |
| 16 | AC-16 Remediation as one unit | PASS | parallel-orchestrate skill and parallel-orchestrator agent text; contract test | as row 11 | |
| 17 | AC-17 Plan report | PASS | parallel-plan `## Completion Report`, parallel-planner item 7; contract test | as row 11 | |
| 18 | AC-18 Bundle copies and pack manifest | PASS | 12 source/bundle pairs share identical blob hashes at HEAD (this review); `core.json` lists both new modules; `contract-tests.2026-10-31T15-55.md` | `git ls-tree -r HEAD -- <24 paths>` | |
| 19 | AC-19 Facade export set | PASS | `BlastRadius.psm1` export list gains only `Get-BlastRadiusCombination`; `BlastRadius.Tests.ps1` count row updated (Pester pass) | `git diff 1174736c7 HEAD -- .claude/lib/blast-radius/BlastRadius.psm1` | |
| 20 | AC-20 Token-shape sentence corrected | PASS | contract test in `test_parallel_issue_combination_contracts.py` (re-run, pass) | as row 11 | |
| 21 | AC-21 Dependency gate | PASS | `evidence/baseline/dependency-1006-gate.2026-10-31T15-01.md` | evidence inspection | |
| 22 | AC-22 Scope boundaries held | PASS | `scope-check.2026-10-31T17-05.md`; this review's diff list matches the 76-entry Complete File List plus feature-folder files | `git diff --name-status 1174736c7 HEAD` | |
| 23 | AC-23 Fail-before evidence | PASS | `fail-before.2026-10-31T15-20.md` (exit 1, expected 1) | evidence inspection | |
| 24 | AC-24 Coverage | PASS | Python: scheduling 100.00%/100.00%, aggregate 100.00%/100.00%, combination 98.75%/91.67% (`artifacts/python/lcov.info`, parsed); PowerShell: four modules 100.00% line (JaCoCo, parsed) | lcov and JaCoCo parsing | No TypeScript production file changed; the separate TypeScript coverage-artifact requirement is policy finding F-1. |
| 25 | AC-25 Toolchain, file size, and isolation | PASS | QA-gate evidence for all three runtimes; largest new file 406 lines; largest edited code file 561 lines; isolation evidence in three runtimes | this review: Black/Ruff/Pyright re-run; logical line counts | |
| 26 | AC-26 Contract weight validation | PASS | `test_blast_radius_contract_weight.py` (re-run, pass); `BlastRadiusScheduling.ContractWeight.Tests.ps1` (Pester pass); overlay fixture `conflict-tolerance-contract-weight.json` | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_contract_weight.py --no-cov` | |
| 27 | AC-27 Cost summed once per shared contract identifier | PASS | `pair_cost` adds `weights["contract"] * len(set(a) & set(b))`; PowerShell ordinal `HashSet` intersection; tests for 0, 1, 2 identifiers and repeats | as row 26 | |
| 28 | AC-28 Contract-only pair eligibility | PASS | `combination-contract-only.json` asserted in both runtimes; `test_contract_only_pair_combines_when_its_cost_meets_the_threshold` | as row 10 | |
| 29 | AC-29 Tolerance-0 strict identity with the contract term | PASS | property test in `test_blast_radius_contract_weight.py`; equivalent Pester Context | as row 26 | |
| 30 | US-01 | PASS | AC-02, AC-03 | see rows 2-3 | |
| 31 | US-02 | PASS | AC-04 | see row 4 | |
| 32 | US-03 | PASS | AC-05 | see row 5 | |
| 33 | US-04 | PASS | AC-10 | see row 10 | |
| 34 | US-18 | PASS | AC-27, AC-28, AC-29 | see rows 27-29 | |
| 35 | US-05 | UNVERIFIED | Depends on AC-14 (CI bats lane); AC-11 PASS | see rows 11, 14 | CI-dependent; left unchecked. |
| 36 | US-06 | PASS | AC-12, AC-13 | see rows 12-13 | |
| 37 | US-07 | PASS | AC-16 | see row 16 | |
| 38 | US-08 | PASS | AC-17 | see row 17 | |
| 39 | US-09 | PASS | AC-15 | see row 15 | |
| 40 | US-10 | PASS | AC-06 | see row 6 | |
| 41 | US-11 | PASS | AC-07 | see row 7 | |
| 42 | US-12 | PASS | AC-01 | see row 1 | |
| 43 | US-13 | PASS | AC-08 | see row 8 | |
| 44 | US-14 | PASS | AC-09 | see row 9 | |
| 45 | US-19 | PASS | AC-09, AC-26 | see rows 9, 26 | |
| 46 | US-15 | PASS | AC-18, AC-19, AC-20 | see rows 18-20 | |
| 47 | US-16 | PASS | AC-21, AC-22 | see rows 21-22 | |
| 48 | US-17 | PASS | AC-23, AC-24, AC-25 | see rows 23-25 | |
| 49 | Traceability T-1, T-2, T-3, T-5 to T-10 | PASS | Mapped US and spec items above | see rows above | Nine items, already checked. |
| 50 | Traceability T-4 (combination becomes one item ... spec AC-10 to AC-14) | UNVERIFIED | Depends on AC-14 | see row 14 | CI-dependent; left unchecked. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

Acceptance criteria are delivered except for the CI-dependent AC-14 chain. The NEEDS REVISION verdict comes from two policy findings recorded in `policy-audit.2026-10-31T17-21.md` and `code-review.2026-10-31T17-21.md`, not from an acceptance-criteria failure.

**Criteria summary:**
- **PASS:** 55 criteria (28 spec, 27 user-story)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 3 criteria (AC-14, US-05, traceability T-4; all pending the CI bats lane)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. TypeScript coverage artifact absent for a language with changed files (policy finding F-1, autonomous).
2. Duplicate-key rejection untested in `find_combinations` and `Get-BlastRadiusCombination` (policy finding F-2, autonomous).
3. AC-14 bash lane pending CI (CI-dependent; resolved at S9, not by remediation).

**Recommended follow-up verification steps:**

1. After remediation, confirm `coverage/lcov.info` exists and record TypeScript repository-wide line and branch figures in `evidence/qa-gates/`.
2. Re-run `test_blast_radius_combination.py` and `BlastRadiusCombination.Tests.ps1` and confirm the new duplicate-key rows pass and `_blast_radius_combination.py` reaches 100% line coverage.
3. At S9, confirm `shell-coverage / Shell Coverage (Bats + kcov)` passes, then check off AC-14, US-05, and T-4.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `spec.md`, `user-story.md`
- Total AC items: 58 (29 in `spec.md`, 29 in `user-story.md`)
- Checked off (delivered): 55
- Remaining (unchecked): 3
- Items remaining: AC-14 Combined item records validate (`spec.md`); US-05 The planner combines without operator approval ... (`user-story.md`); traceability item "A pair meeting the combination threshold becomes one item with one branch and one PR closing both issues; its complexity band comes from a fresh assessment" (`user-story.md`).

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 29 | 28 | 1 | Checkbox-backed; AC-14 CI-dependent |
| `user-story.md` | 29 | 27 | 2 | Checkbox-backed; US-05 and T-4 depend on AC-14 |

No source-file checkbox change was made by this review: every criterion evaluated PASS was already checked by the executor, and this review's evidence confirms each of those check-offs. The three UNVERIFIED items remain unchecked for the S9 check-off.
