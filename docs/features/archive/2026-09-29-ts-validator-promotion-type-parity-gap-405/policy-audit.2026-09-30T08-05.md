# Policy Audit: issue #405 (TS validator promotion-type parity gap)

- Timestamp: 2026-09-30T08-05
- Scope: full branch diff `cbb53d7a..HEAD` (73 files; 8 code files, 12 fixtures, feature docs and evidence)
- Work mode: full-bug (AC source spec.md; issue.md secondary)
- Overall verdict: PASS (no blocking findings)

## Executive Summary

Overall verdict: PASS with no blocking findings. Coverage evidence for TypeScript, Python, and PowerShell was inspected directly and shows no regression. One non-blocking PARTIAL item (property-test substitution) is recorded in section 8.

## Rejected Scope Narrowing

None. The caller prompt did not narrow scope. Its base note (origin/main drift after P0-T3) is treated as context: the audited base is the requested `cbb53d7a`, and `evidence/qa-gates/diff-scope.2026-09-30T07-57.md` independently confirms the six drift paths (`.codex/config.toml`, two package manifests, mcp-server manifests, bundled codex config) are absent from this branch's changes.

## Changed-language inventory

| Language | Changed files | Coverage verdict |
|---|---|---|
| TypeScript | promotion-tools.ts (new), routing.ts (mod), jest.config.cjs (mod), 3 test files (new) | PASS |
| Python | 1 new test file only (no production change) | PASS |
| PowerShell | 1 new Pester test file only (no production change) | PASS |
| C# | none | not applicable (zero changed files) |

## 1. General Unit Test Policy Compliance

Policy verdicts for unit-test rules (test location, temp files, banned time APIs, determinism, property tests, pre-existing failures) appear in the verdict table in section 2, which combines the general policies.

### 1.1 Coverage Verification

| Language | Artifact | Result | Verdict |
|---|---|---|---|
| TypeScript | `extensions/drm-copilot/coverage/lcov.info` (mtime 07:42) | New file promotion-tools.ts: LF 51 / LH 51 (100%), BRF 7 / BRH 7 (100%). Modified routing.ts: LH 436 / LF 455 = 95.8% lines, BRH 94 / BRF 102 = 92.2% branches (baseline 95.34 / 91.17; no regression). Repo-wide 97.03% lines, 91.19% branches (evidence). | PASS |
| Python | `artifacts/python/lcov.info` (mtime 07:45) plus evidence JSON | Repo-wide 93.4% statements, 86.3% branches, unchanged from baseline. No production Python changed; the new file is a test. | PASS |
| PowerShell | `artifacts/pester/powershell-coverage.xml` (mtime 07:54) | Report-level LINE 96.25% (10688/11104), unchanged. No production PowerShell changed; no branch gate applies. | PASS |

Note: the Python routing module reads 83.6% in the targeted run (below 85%), but it is unchanged production code, improved from 83.1%, and the repo-wide figure governs. Not a finding.


### 1.2 Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `evidence/baseline` TS coverage evidence (97.02% lines, 91.17% branches, 90.87% functions, 97.02% statements)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (97.03% lines, 91.19% branches, 90.88% functions, 97.03% statements)
- PowerShell baseline coverage artifact: `artifacts/pester/powershell-coverage.xml` baseline evidence (96.25% line coverage)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (96.25% line coverage, unchanged)
- Per-language comparison summary: see section 1.2.1; TypeScript, Python, and PowerShell show no regression against baseline.

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 97.02% lines / 91.17% branches; Post-change: 97.03% lines / 91.19% branches; Change: +0.01% lines, +0.02% branches; Disposition: PASS; New/changed-code coverage: 100% lines for promotion-tools.ts; Evidence: `extensions/drm-copilot/coverage/lcov.info`
- Python: Baseline: 93.4% statements / 86.3% branches; Post-change: 93.4% statements / 86.3% branches; Change: none; Disposition: PASS; Evidence: `artifacts/python/lcov.info`
- PowerShell: Baseline: 96.25% lines; Post-change: 96.25% lines; Change: none; Disposition: PASS; Evidence: `artifacts/pester/powershell-coverage.xml`

## 2. General Code Change Policy Compliance

| Policy | Verdict | Evidence |
|---|---|---|
| Tone policy | PASS | Artifacts and evidence use neutral factual wording. |
| Simplicity, separation of concerns (pure logic separate) | PASS | `orchestrator-state-promotion-tools.ts` (51 lines) has no imports and no I/O; routing.ts change is a 4-line wiring edit. |
| Naming, docs, error handling | PASS | Descriptive exported constants, JSDoc on every export, no new error strings. |
| Public API compatibility | PASS | No signature change to `validateRoutingContract`. |
| 500-line limit | PASS | Largest changed file routing.ts 455; new tests 114-231; jest.config.cjs 363 (`file-size-gate.2026-09-30T07-57.md`, re-derived from diff stat). |
| Coverage exclusion policy | PASS | The only jest.config.cjs change adds a coverage threshold entry (85/75) for the new production file; no `exclude` entry added. |
| Test location mirrors source | PASS | TS tests under `extensions/drm-copilot/test/lib/validate/` (the extension's established layout); Python and Pester under `tests/scripts/...`. No colocation. |
| No temp files / banned time APIs in tests | PASS | Grep for tmp, mkdtemp, writeFile, setTimeout, Date.now, Sleep, tmp_path, TestDrive over all five new test files returned no match. Tests read committed fixtures read-only. |
| Determinism, Arrange-Act-Assert | PASS | Parity reader reviewed in full; guards for corpus size, disk count equality, and both verdict paths. |
| Property tests (T1/T2 pure function) | PARTIAL (non-blocking) | `fast-check` is not in `extensions/drm-copilot/package.json`; plan substituted a deterministic fixed-grid invariant test (`promotion-tools.test.ts` line 155). Reasonable given the no-new-dependency rule and spec constraint; tier of this module could not be confirmed because `quality-tiers.yml` was not found at worktree root. |
| Mandatory toolchain loop | PASS | Evidence: ts-format/lint/typecheck/coverage, py-black/ruff/pyright/pytest, ps-format/analyze/Pester. Dependency-cruiser absent from the extension; boundary tests run inside Jest (plan note). |
| Pre-existing test failures | PASS (accepted) | Pester: 2 failures identical by name to baseline (enforce-pr-author-skill allowed-commands; codex-pretooluse-integration handler). Passed count rose 6082 to 6097 (+15 new tests). |
| Forbidden-path / scope guard | PASS | `git diff --name-status` shows no change to `.claude/lib`, `extensions/drm-copilot/resources`, `scripts/dev_tools/_orchestrator_state_routing.py`, `config/orchestration-routing.json`, or hooks. |

## 3. Language-Specific Code Change Policy Compliance

TypeScript: the new pure module and the 4-line routing.ts wiring edit satisfy the TypeScript rules (no imports, no I/O, JSDoc on exports, file size below 500 lines). Python and PowerShell: no production change. Verdicts are in the section 2 table.

## 4. Language-Specific Unit Test Policy Compliance

TypeScript, Python, and PowerShell tests contain no temp files or banned time APIs and mirror the corpus with identical guards. Test location follows the established layout per section 2.

## 5. Test Coverage Detail

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| TypeScript | 6 (3 production/config, 3 tests) | Jest 3357 pass | PASS | 97.02% lines / 91.17% branches | 97.03% lines / 91.19% branches | 100% lines / 100% branches (promotion-tools.ts) |
| Python | 1 (test only) | 15 new, all pass | PASS | 93.4% statements / 86.3% branches | 93.4% statements / 86.3% branches | N/A (no production change) |
| PowerShell | 1 (test only) | Pester 15 new, 0 new failures | PASS | 96.25% lines | 96.25% lines | N/A (no production change) |

## 6. Test Execution Metrics

- Jest: 3357 passing.
- Python parity tests: 15 passing.
- Pester: passed count rose from 6082 to 6097 (+15 new tests); 2 pre-existing failures identical by name to baseline (accepted).

## 7. Code Quality Checks

Mandatory toolchain loop evidence: ts-format, ts-lint, ts-typecheck, ts-coverage; py-black, py-ruff, py-pyright, py-pytest; ps-format, ps-analyze, Pester. See the toolchain row in section 2.

## 8. Gaps and Exceptions

- Property tests: PARTIAL (non-blocking), see section 2.
- Pre-existing Pester failures accepted.

## Evidence Location Compliance

- `validate_evidence_locations.py --root .` exit code 0.
- Branch diff contains no path under `artifacts/`; all evidence lies under `<FEATURE>/evidence/{baseline,qa-gates,regression-testing,other}/`.
- Verdict: PASS. No EVIDENCE_LOCATION_OVERRIDE_REJECTED events.

## 9. Summary of Changes

- Blocking: none.
- Non-blocking: (1) property-test substitution above; (2) `evidence/other/spec-ac-checkoff.2026-09-30T08-00.md` admits AC-to-artifact mapping for criteria 4, 6, 7, 11 was not re-derived (this review re-derived them; see feature-audit).

## 10. Compliance Verdict

PASS. No blocking findings; no remediation required.

## Appendix A: Test Inventory

- `extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-type-parity.test.ts`
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-tools.test.ts`
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-routing.promotion-type.test.ts`
- Python parity reader `test_orchestrator_state_promotion_type_parity.py` (15 tests)
- Pester parity reader (15 tests)
- Corpus: 12 fixtures under `tests/fixtures/orchestrator_state_promotion_type/`

## Appendix B: Toolchain Commands Reference

Commands and outputs are recorded in the evidence folders `evidence/baseline`, `evidence/qa-gates`, `evidence/regression-testing`, and `evidence/other` of this feature.
