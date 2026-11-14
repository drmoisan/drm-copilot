# Code Review: Parallel Scheduling Integration Cost (#1013)

---

**Review Date:** 2026-10-31
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013`
**Feature Folder Selection Rule:** The only active feature folder in the diff; its suffix matches issue 1013 in the branch name.
**Base Branch:** `main` (merge base `1174736c7a3cbd7dd5c73620b2c1ed02ec2c3cd6`)
**Head Branch:** `feature/parallel-scheduling-integration-cost-1013` @ `94d972f9d6a23c62b503a775be48d263a57e7afc`
**Review Type:** Re-review after remediation cycle 1 (prior review `code-review.2026-10-31T17-21.md`)

---

## Executive Summary

The branch adds an aggregate per-item integration-cost cap inside the single scheduling entry point (`schedule_conflict_edges`, `Get-BlastRadiusConflictEdge`), a planning-time issue-combination library (`find_combinations`, `Get-BlastRadiusCombination`), an optional validated `conflict_tolerance.combination_threshold_percent` member (default 400), a required `conflict_tolerance.weights.contract` cost weight summed once per shared contract identifier, and the procedure text in the parallel skills, agents, rule, and status template. The full branch diff is 150 files.

Remediation cycle 1 (commit `94d972f9d`) added one Python test and one Pester row for the duplicate-key rejection and recorded TypeScript, Python, and PowerShell coverage evidence. No production, bundle, configuration, or policy file changed in that cycle (`git diff 8683e0a75 HEAD -- scripts .claude extensions config` is empty).

Evidence reviewed: the full branch diff; the PR context summary and appendix (generated at HEAD `94d972f9d`); remediation evidence under `evidence/`; this review's re-runs of Black, Ruff, Pyright, 277 feature Python tests with branch coverage, and the evidence-location scanner; parsing of `coverage/lcov.info`, `extensions/drm-copilot/coverage/lcov.info`, `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`, and the full-suite JaCoCo report; and logical line counts of all 36 changed covered files.

**What changed in this cycle:**
- `tests/scripts/dev_tools/test_blast_radius_combination.py`: `test_find_combinations_rejects_a_repeated_item_key` (lines 207-219) asserts a nonzero tolerance precondition and then `pytest.raises(ValueError, match="must be distinct")`.
- `tests/scripts/claude-lib/blast-radius/BlastRadiusCombination.Tests.ps1`: `rejects a repeated item key with the distinct-keys message` (lines 125-130) asserts `Should -Throw -ExpectedMessage '*must be distinct*'`.
- Evidence: `evidence/qa-gates/typescript-coverage.2026-10-31T17-48.md` and the cycle's format, lint, typecheck, test, isolation, file-size, scope, and contract-test records.

**Top 3 risks:**
1. AC-14's bash validator lane (`tests/shell/parallel_manifest_parity.bats`) runs only in CI; it remains pending until the PR's CI run.
2. PowerShell 5.1 is not exercised by any recorded run; the production modules show no 7-only syntax on inspection.
3. The canonical `artifacts/pester/powershell-coverage.xml` reflects a single-file run, so a later reader could misread the low figures it shows for other blast-radius modules as a regression.

**PR readiness recommendation:** **Ready** — both prior findings are closed and verified; no blocking finding remains.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `extensions/drm-copilot/test/lib/**`, `coverage/lcov.info` | n/a | Prior finding F-1 resolved: root TypeScript coverage 98.21% line (67744/68978), 93.41% branch (10029/10737); extension 97.06% line (61859/63730), 93.67% branch (9389/10023). | None. | Figures parsed by this review match `typescript-coverage.2026-10-31T17-48.md`; both exceed 85% / 75%. | `coverage/lcov.info`; `extensions/drm-copilot/coverage/lcov.info` |
| Info | `tests/scripts/dev_tools/test_blast_radius_combination.py` | lines 207-219 | Prior finding F-2 (Python) resolved: `_blast_radius_combination.py` line 246 is covered; module now 80/80 lines, 23/24 branches. | None. | The test asserts the specific message and guards its own precondition (`tolerance_percent > 0`), so it cannot pass through the tolerance-0 early return. | This review's pytest coverage run (`Missing: 217->215` only) |
| Info | `tests/scripts/claude-lib/blast-radius/BlastRadiusCombination.Tests.ps1` | lines 118-130 | Prior finding F-2 (PowerShell) resolved. The file already held a row `rejects repeated item keys` (line 118, bare `Should -Throw`) before remediation, which the prior review did not detect; the new row adds the message pattern, so two rows now cover the same input. | Optionally fold the two rows into one by adding `-ExpectedMessage` to the original row. Non-blocking. | Redundant but correct; the new row is the stricter of the two. | `git show 94d972f9d -- tests/`; Grep for `repeated` |
| Info | `artifacts/pester/powershell-coverage.xml` | n/a | The canonical artifact now exists but was produced by a run of one test file; it reports BlastRadiusCombination.psm1 72/72 and lower figures for unrelated modules. The full-suite figures (356/356 over the four changed modules) remain in the session-scratch JaCoCo report. | When the full blast-radius Pester suite is next run with coverage, write it to the canonical path. Non-blocking. | No production module changed after the full run, so the full-run figures still describe HEAD. | `jacoco.py` parse of both files |
| Info | `scripts/dev_tools/_blast_radius_combination.py` | `find_combinations` / `_qualifying_pair`, lines 164-201 | `decide_pair` re-reads and re-validates `conflict_tolerance` for every pair (carried from the prior review). | No change required for current run sizes. | Same pattern as `schedule_conflict_edges`; not a correctness issue. | Diff inspection |
| Info | branch history | commit `5374dc1ad` | A `wip(1013)` commit remains in history (carried from the prior review). | Squash on merge. | Commit hygiene only. | `git log 1174736c7..HEAD` |

No Blocker, Major, or Minor findings. No covered file is at or above 700 logical lines (largest: `_blast_radius_scheduling.py` 561, `BlastRadiusScheduling.psm1` 530 and its bundle copy 530), so no file-size Warning applies; `config/file-size-baseline.json` is unchanged on the branch.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `select_capped_pairs` sorts once and selects by the total key `(benefit, -cost, a, b)`; termination and input-order independence follow directly and are pinned by the properties module.
- `_apply_aggregate_cap` converts promoted overlaps with `reasons[0]` and `hard=False`, re-sorts edges, and leaves the reason enum unchanged.
- The optional member is admitted to the exact-name check only when present, so unknown siblings are still rejected.
- The contract term uses `set(a.contracts) & set(b.contracts)` and counts each identifier once.
- The new negative test reuses the fixture loaders and `cast` helpers already in the file, keeping it typed without `Any`.

#### Typing and API notes

- Pyright reports 0 errors on the three production modules and the edited test file (this review). Public surface unchanged by remediation.

#### Error handling and logging

- Reader errors name the exact key with `TypeError`/`ValueError`; the duplicate-key `ValueError` is now exercised.

### TypeScript implementation audit

#### What changed well

- No production TypeScript changed. Test updates restate the committed `weights` map with `contract: 8` and add an in-memory default-tolerance pin.

#### Type safety and maintainability

- Prettier, ESLint, and both `tsc` projects pass per executor evidence; coverage is now measured and above threshold.

#### Error handling and logging

- Not applicable to test-only changes.

### PowerShell implementation audit

#### What changed well

- The ports mirror the Python reference, use Int64 copies for key comparison, and sort with explicit multi-key script blocks; the named `Get-UnionFindRoot` satisfies the hook scan.
- `Get-BlastRadiusPairCost` uses an ordinal `HashSet[string]` intersection.

#### API and safety notes

- `[CmdletBinding()]`, `[OutputType()]`, approved verbs, `Set-StrictMode -Version Latest`, `$ErrorActionPreference = 'Stop'`. Facade export set grows by `Get-BlastRadiusCombination` only.

#### Error handling and logging

- Explicit `throw` with labels matching Python; the duplicate-key message is now asserted.

---

## Test Quality Audit

Fixture-driven tests bind the two runtimes: three aggregate fixtures and four combination fixtures are asserted to identical results in Python and Pester. The duplicate-key reject case is now asserted with the same message pattern in both runtimes, restoring reject-case parity.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_blast_radius_combination.py` — re-run by this review with coverage (pass; 80/80 lines).
- `tests/scripts/claude-lib/blast-radius/BlastRadiusCombination.Tests.ps1` — `evidence/qa-gates/powershell-tests.2026-10-31T17-51.md` (22 tests, 0 failures, both duplicate-key rows passed).
- `evidence/qa-gates/typescript-coverage.2026-10-31T17-48.md` — figures confirmed against both lcov files.
- `evidence/regression-testing/isolation-python.2026-10-31T17-49.md`, `isolation-pester.2026-10-31T17-51.md`, `isolation-jest.2026-10-31T17-48.md` — order independence after the change.
- `evidence/qa-gates/scope-check.2026-10-31T17-58.md` — cycle touched only the two test files and feature-folder files; confirmed by `git diff --stat 8683e0a75 HEAD`.
- `evidence/qa-gates/file-size.2026-10-31T17-58.md` uses `wc -l`; this review re-measured with logical line counts (same values, 302 and 191).

### Quality assessment prompts

- **Determinism:** No RNG, clock, or I/O beyond reading committed fixtures.
- **Isolation:** One behavior per test; reversed and seeded shuffles pass.
- **Speed:** 277 feature Python tests with coverage in 40.47s.
- **Diagnostics:** Message-pattern assertions identify the failing guard precisely.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess or `Invoke-Expression` in new code. |
| Input validation at boundaries | ✅ PASS | Reader validates every member; duplicate keys rejected and tested. |
| Error handling remains explicit | ✅ PASS | Specific exceptions; no broad catches. |
| Configuration / path handling is safe | ✅ PASS | Both truth tables carry byte-equal `conflict_tolerance`; contract tests pass (`contract-tests.2026-10-31T17-58.md`). |
| Scope boundaries held | ✅ PASS | No production, bundle, config, or policy change in the remediation cycle; no `artifacts/` path in the branch diff. |

---

## Research Log

No external research was required. All conclusions derive from the repository diff, the feature-folder evidence, and check-only commands run in this review.

---

## Verdict

The implementation is correct and consistent across Python and PowerShell, with coverage above the governing thresholds for every language that has changed files. Both prior findings are closed and verified independently. The branch is ready for PR authoring; AC-14 and its dependent user-story items are checked off at S9 once the CI bats lane passes.
