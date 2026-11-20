# Code Review: Parallel Scheduling Integration Cost (#1013)

---

**Review Date:** 2026-10-31
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013`
**Feature Folder Selection Rule:** The only active feature folder in the diff; its suffix matches issue 1013 in the branch name.
**Base Branch:** `main` (merge base `1174736c7a3cbd7dd5c73620b2c1ed02ec2c3cd6`)
**Head Branch:** `feature/parallel-scheduling-integration-cost-1013` @ `8683e0a7531b22794dac7b0431127cba5b390484`
**Review Type:** Initial review

---

## Executive Summary

The branch adds an aggregate per-item integration-cost cap inside the single scheduling entry point (`schedule_conflict_edges`, `Get-BlastRadiusConflictEdge`), a planning-time issue-combination library (`find_combinations`, `Get-BlastRadiusCombination`), an optional validated `conflict_tolerance.combination_threshold_percent` member (default 400), a required `conflict_tolerance.weights.contract` cost weight summed once per shared contract identifier, and the procedure text in the parallel skills, agents, rule, and status template. Production logic lives in two new pure leaf modules per runtime; the scheduling modules gain only the reader changes, the contract cost term, and the post-pass call. 129 files changed, of which 76 match the spec's Complete File List exactly and the remainder are feature-folder documents and evidence.

Evidence reviewed: the full branch diff; the PR context summary and appendix; executor evidence under `evidence/`; `artifacts/python/lcov.info`; the executor's Pester JaCoCo report; and this review's own re-runs of Black, Ruff, Pyright, 338 targeted Python tests, the evidence-location scanner, blob-hash comparison of the 12 source/bundle pairs, and logical line counts of all 36 changed covered files. Implementation quality is high: the two runtimes mirror each other closely, every choice is made by a total order, and the strict tolerance-0 identity is preserved structurally (nothing is tolerated at tolerance 0, so the cap is a no-op).

**What changed:**
- `scripts/dev_tools/_blast_radius_aggregate.py` (new, 122 lines): `select_capped_pairs` with a structural `CappableOverlap` Protocol; `ConflictTolerance` imported under `TYPE_CHECKING` only.
- `scripts/dev_tools/_blast_radius_combination.py` (new, 247 lines): `find_combinations`, `has_same_file_overlap`, union-find `_components`, frozen record dataclasses.
- `scripts/dev_tools/_blast_radius_scheduling.py`: `WEIGHT_NAMES` gains `contract`; `COMBINATION_THRESHOLD_DEFAULT`; optional-member read; `pair_cost` contract term; `_apply_aggregate_cap` post-pass.
- PowerShell ports `BlastRadiusAggregate.psm1` (154) and `BlastRadiusCombination.psm1` (228); `BlastRadiusScheduling.psm1` and facade `BlastRadius.psm1` edits; byte-identical bundle copies; `core.json` lists the two new modules.
- Both truth tables gain `"contract": 8` and `"combination_threshold_percent": 400`.

**Top 3 risks:**
1. TypeScript coverage was not measured on this branch (no `coverage/lcov.info`), so the mandatory per-language coverage gate cannot be evaluated for the four changed TypeScript test files.
2. The duplicate-key rejection path in both combination implementations has no test; a regression in that guard would go undetected.
3. AC-14's bash validator lane (`tests/shell/parallel_manifest_parity.bats`) runs only in CI; it remains pending until the PR's CI run.

**PR readiness recommendation:** **Needs Revision** — two small, autonomous gaps (TypeScript coverage evidence; duplicate-key negative tests) should be closed in one proportionate remediation cycle before PR authoring.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `extensions/drm-copilot/test/lib/push-down/*.ts`, `extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts` | n/a (coverage artifact) | TypeScript has 4 changed files on the branch, but no TypeScript coverage artifact exists: `coverage/lcov.info` and `extensions/drm-copilot/coverage/lcov.info` are absent, and every recorded Jest run omitted `--coverage`. | Run `npm run test:unit:coverage` at the repository root (and the extension Jest run with `--coverage`), confirm repository-wide TypeScript line >= 85% and branch >= 75%, and record `evidence/qa-gates/typescript-coverage.<timestamp>.md` with the parsed figures. | Coverage verification is mandatory for every language with changed files on the branch; the gate cannot be evaluated without an artifact. | `ls coverage/lcov.info` (absent); `evidence/qa-gates/typescript.2026-10-31T16-01.md`; `extensions/drm-copilot/jest.config.cjs:19` (`collectCoverage: false`) |
| Minor | `scripts/dev_tools/_blast_radius_combination.py` | `_ordered_by_key`, lines 238-247 | The duplicate-key `ValueError` (line 246) is never exercised; it is the only uncovered line in the module (`DA:246,0`, branch `BRDA:245,...,0`). No test in `test_blast_radius_combination.py` or `test_blast_radius_combination_threshold.py` references the error. | Add `test_find_combinations_rejects_a_repeated_item_key` asserting `pytest.raises(ValueError, match="must be distinct")`. | Scenario Completeness requires negative flows for invalid inputs; the guard protects the union-find and `primary` derivation from ambiguous keys. | `artifacts/python/lcov.info`; Grep for `distinct` in the combination tests (no match) |
| Minor | `.claude/lib/blast-radius/BlastRadiusCombination.psm1` | `Get-CombinationOrderedItem`, lines 92-97 | Same gap in the PowerShell port: the `throw "combination item keys must be distinct..."` path has no Pester row (instruction coverage 134/135 for this module). | Add an `It` in `BlastRadiusCombination.Tests.ps1` that passes two items with the same key to `Get-BlastRadiusCombination` and asserts `Should -Throw` with the pattern `*must be distinct*`. | Cross-runtime parity of reject cases is a stated design property of this feature. | JaCoCo `issue-1013-p9t6b-coverage.xml` INSTRUCTION 134/135; Grep for `distinct` in `BlastRadiusCombination.Tests.ps1` (no match) |
| Info | `scripts/dev_tools/_blast_radius_combination.py` | `find_combinations` / `_qualifying_pair`, lines 164-201 | `decide_pair` re-reads and re-validates `conflict_tolerance` for every pair, so combination validates the config O(n^2) times. | No change required for current run sizes; consider passing the validated tolerance if run sizes grow. | Same pattern as the existing `schedule_conflict_edges`; not a correctness issue. | Diff inspection |
| Info | `scripts/dev_tools/_blast_radius_combination.py` | line 36 | Imports the private helper `_entries_overlap` from `_blast_radius_glob`. | None; `pair_cost` in `_blast_radius_scheduling.py` uses the same helper, and the module docstring states the reuse is deliberate so the same-file test mirrors `pair_cost`. | Reuse avoids duplicating overlap semantics. | `_blast_radius_scheduling.py` `pair_cost` |
| Info | `artifacts/pester/powershell-coverage.xml` | n/a | The PowerShell coverage artifact exists only in the executor's session scratch directory, not at the canonical `artifacts/pester/powershell-coverage.xml`. | During remediation, write the post-change Pester coverage to the canonical path as well, so a later review in a fresh session can inspect it. | The scratch directory is session-scoped and may not survive. | Scratch listing; `evidence/qa-gates/powershell-tests.2026-10-31T16-59.md` |
| Info | branch history | commit `5374dc1ad` | A `wip(1013)` commit remains in history. | Squash on merge, as is the repository's usual PR merge mode. | Commit hygiene only. | `git log 1174736c7..HEAD` |

No Blocker findings. No covered file is at or above 700 logical lines (largest: `_blast_radius_scheduling.py` 561, `BlastRadiusScheduling.psm1` 530), so no file-size Warning applies; `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `select_capped_pairs` sorts once and selects by the total key `(benefit, -cost, a, b)`; each round removes one overlap, so termination and input-order independence follow directly and are pinned by the properties module.
- `_apply_aggregate_cap` converts promoted overlaps with `reasons[0]` and `hard=False`, re-sorts edges, and leaves the reason enum unchanged.
- The optional member is admitted to the exact-name check only when present, so unknown siblings are still rejected (`config_conflict_tolerance`, lines 250-254).
- The contract term uses `set(a.contracts) & set(b.contracts)`, matching the relation's `contract_dependency` level in `_blast_radius_conflicts.py:201`, and counts each identifier once.

#### Typing and API notes

- Fully annotated; Pyright reports 0 errors on the changed files. `CappableOverlap` is a read-only-property Protocol, which accepts the frozen `ToleratedOverlap` dataclass without a runtime import of the scheduling module (AC-03).
- New public surface: `select_capped_pairs`, `find_combinations`, `has_same_file_overlap`, three record dataclasses, `COMBINATION_THRESHOLD_DEFAULT`. `ConflictTolerance` gains a defaulted field, so existing constructor calls remain valid.

#### Error handling and logging

- Reader errors name the exact key (`config["conflict_tolerance"]["combination_threshold_percent"]`, `["weights"]["contract"]`) with `TypeError`/`ValueError`. The cap and combination functions are total over valid input. No logging is added, consistent with the pure-library pattern.

### TypeScript implementation audit

#### What changed well

- No production TypeScript changed (the push-down derivers carry `conflict_tolerance` verbatim). Test updates restate the committed `weights` map with `contract: 8` and add an in-memory default-tolerance pin.

#### Type safety and maintainability

- Prettier, ESLint, and both `tsc` projects pass per executor evidence. Coverage was not measured (finding above).

#### Error handling and logging

- Not applicable to test-only changes.

### PowerShell implementation audit

#### What changed well

- The ports mirror the Python reference line for line, use Int64 copies so keys of any integer width compare equal, and sort with explicit multi-key script blocks. The closure was replaced by the named `Get-UnionFindRoot` to satisfy the no-Python-invocation hook scan.
- `Get-BlastRadiusPairCost` uses an ordinal `HashSet[string]` intersection, matching the relation's ordinal comparison.

#### API and safety notes

- `[CmdletBinding()]`, `[OutputType()]`, approved verbs (`Get-`, `Test-`), `Set-StrictMode -Version Latest`, `$ErrorActionPreference = 'Stop'`, sibling imports with `-ErrorAction Stop`. Each new module exports exactly one function; the facade export set grows by `Get-BlastRadiusCombination` only (AC-19).

#### Error handling and logging

- Explicit `throw` with the same labels as Python; `-Relation` absence fails fast with a message naming the facade.

---

## Test Quality Audit

Fixture-driven tests bind the two runtimes: three aggregate fixtures and four combination fixtures are asserted to identical results in Python and Pester. Properties for the cap (superset/subset, tolerance-0 identity, within-cap, order invariance, idempotence) are exhaustive over a finite domain. Contract-text tests pin the skill, agent, rule, and template fragments and the absence of any `observed_resolution` reader.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_blast_radius_aggregate.py`, `test_blast_radius_aggregate_properties.py` — cap selection, tie-break, cascade, properties; re-run by this review (pass).
- `tests/scripts/dev_tools/test_blast_radius_combination.py`, `test_blast_radius_combination_threshold.py`, `test_blast_radius_contract_weight.py` — library, reader accept/reject, contract-weight cost and tolerance-0 identity; re-run (pass). Gap: duplicate-key rejection.
- `tests/scripts/claude-lib/blast-radius/BlastRadiusAggregate.Tests.ps1`, `BlastRadiusCombination.Tests.ps1`, `BlastRadiusScheduling.ContractWeight.Tests.ps1` — PowerShell parity, including a row that reads `COMBINATION_THRESHOLD_DEFAULT` from the Python source.
- `evidence/regression-testing/fail-before.2026-10-31T15-20.md` — new tests failed before implementation (expected exit 1).
- `evidence/regression-testing/isolation-*.md` — order-independence in all three runtimes.
- `evidence/qa-gates/coverage-delta.2026-10-31T16-59.md` — per-file baseline and post-change figures; confirmed against `artifacts/python/lcov.info` and the JaCoCo report.

### Quality assessment prompts

- **Determinism:** No RNG, clock, or I/O beyond reading committed fixtures.
- **Isolation:** One behavior per test; seeded shuffles pass.
- **Speed:** 338 targeted Python tests in 1.46s.
- **Diagnostics:** Pester assertions compare formatted record strings; Python assertions compare full tuples.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess or `Invoke-Expression` in new code. |
| Input validation at boundaries | ✅ PASS | Reader validates every member and weight name with fail-fast errors naming the key. |
| Error handling remains explicit | ✅ PASS | Specific exceptions; no broad catches. |
| Configuration / path handling is safe | ✅ PASS | Both truth tables carry byte-equal `conflict_tolerance` (Class 1 contract test); 12 source/bundle pairs share identical blob hashes at HEAD. |
| Scope boundaries held | ✅ PASS | `decide_pair`, `conflicts`, `HARD_REASON_KINDS`, `pair_benefit`, validators, drift module, and the author-asserted hook are unchanged (scope-check evidence and diff). |

---

## Research Log

No external research was required. All conclusions derive from the repository diff, the feature-folder evidence, and check-only commands run in this review.

---

## Verdict

The implementation is correct, well-structured, and consistent across Python and PowerShell, with coverage well above the governing thresholds for every changed production file. It is not yet ready for PR authoring because the mandatory TypeScript coverage evidence is absent and the duplicate-key negative flow is untested in both runtimes. Both items are small, autonomous, and fit one proportionate remediation cycle; after they are closed and re-reviewed, the branch is ready for the normal PR flow, with AC-14 checked off at S9 once the CI bats lane passes.
