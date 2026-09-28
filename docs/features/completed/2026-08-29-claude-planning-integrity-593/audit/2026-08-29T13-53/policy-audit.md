# Policy Compliance Audit: Claude Planning Integrity (#593)

**Audit Date:** 2026-08-29
**Code Under Test:** Claude runtime contracts, hooks, PowerShell module, focused PowerShell and Python tests, and published Claude bundle mirrors.

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---:|---:|---|---|---|---|
| Python | 2 test files | 29 focused | PASS | 93% | 93% | N/A: test-only Python changes |
| PowerShell | 4 runtime files, 3 test files | 72 focused | PASS | 88.75% / 90.62% by hook | 90.00% / 93.75% by hook | 100.00% for the remediated PRD-hook eligible lines |

## Executive Summary

The branch is not policy-compliant for release. The prior numeric-provenance coverage finding is resolved by the recorded coverage evidence and by the focused rerun. However, `.claude/hooks/validate-prd-feature-output.ps1` is not registered in the `prd-feature` `SubagentStop` hook configuration in `.claude/settings.json` or its published mirror. The validator therefore does not execute in the Claude runtime, leaving the numeric-acceptance-criterion enforcement required by AC1 ineffective.

## 1. General Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Independence, isolation, determinism, and readability | PASS | Focused Pester tests use mocked or inline content; Python contract tests read repository content only. |
| Positive, rejection, and boundary scenarios | PASS | 72 focused Pester tests and 29 focused Python tests passed on this review. |
| Coverage | PASS for the previously blocked coverage requirement | `evidence/qa-gates/numeric-provenance-powershell-tests-and-coverage.2026-08-29T13-15.md` records 90.00% and 93.75% per-hook coverage and 100.00% new PRD-hook eligible-line coverage. |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope
- TypeScript post-change coverage artifact: N/A - out of scope
- PowerShell baseline coverage artifact: `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/numeric-provenance-pester-baseline.2026-08-29T13-15.xml`
- PowerShell post-change coverage artifact: `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-pester-post.2026-08-29T13-15.xml`
- Per-language comparison summary: `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-powershell-tests-and-coverage.2026-08-29T13-15.md` and `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/numeric-provenance-python-full-coverage.2026-08-29T13-15.md`

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93% lines -> Post-change: 93% lines. Change: 0 percentage points. New/changed-code coverage: N/A - test-only Python changes. Disposition: PASS. Evidence: `evidence/baseline/python-coverage-remediation.2026-08-29T13-15.md` and `evidence/qa-gates/numeric-provenance-python-full-coverage.2026-08-29T13-15.md`.
- PowerShell: Baseline: 88.75% task-researcher and 90.62% PRD hook -> Post-change: 90.00% and 93.75%. Change: +1.25 and +3.13 percentage points. New/changed-code coverage: 100.00% for the eligible PRD-hook line set. Disposition: PASS. Evidence: `evidence/remediation-baseline/numeric-provenance-pester-baseline.2026-08-29T13-15.xml` and `evidence/qa-gates/numeric-provenance-pester-post.2026-08-29T13-15.xml`.

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Cohesive, bounded changes | PASS | Full branch diff reviewed; no changed production, test, or reusable script file exceeds 500 lines. |
| Explicit failure behavior | PARTIAL | The PRD validator returns explicit failures when invoked, but it is not wired into the runtime hook configuration. |
| Required runtime behavior delivered | FAIL | The missing `SubagentStop` registration prevents the new validator from enforcing PRD termination behavior. |

## 3. Language-Specific Code Change Policy Compliance

### PowerShell

| Requirement | Status | Evidence |
|---|---|---|
| Formatting and analysis | PASS | Existing exact-head evidence records clean PoshQC formatting and analysis. |
| Tests and coverage | PASS | Review rerun: 72 Pester tests passed; recorded JaCoCo coverage exceeds the required thresholds. |
| Runtime integration | FAIL | `.claude/settings.json` has no `matcher: "prd-feature"` `SubagentStop` command for `validate-prd-feature-output.ps1`; the bundle mirror has the same omission. |

### Python

| Requirement | Status | Evidence |
|---|---|---|
| Focused contract tests | PASS | `poetry run pytest tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` passed 29 tests. |

## 4. Language-Specific Unit Test Policy Compliance

PowerShell and Python test suites are maintainable and deterministic for the behavior they exercise. The missing registration is not covered by a focused test, so the current suite does not establish end-to-end enforcement.

## 5. Test Coverage Detail

The previous review's coverage blocker is resolved: task-researcher changed-hook coverage is 90.00%, PRD-hook coverage is 93.75%, and the remediated PRD-hook line set is 100.00% covered. This audit does not identify a coverage regression.

## 6. Test Execution Metrics

| Metric | Value | Status |
|---|---:|---|
| Focused Pester tests | 72 passed, 0 failed | PASS |
| Focused Python tests | 29 passed | PASS |
| Whitespace diff check | clean | PASS |

## 7. Code Quality Checks

| Check | Command | Result | Status |
|---|---|---|---|
| Focused PowerShell tests | Pester configuration over four changed suites | 72 passed, 0 failed | PASS |
| Focused Python contracts | `poetry run pytest ... -q` | 29 passed | PASS |
| Branch whitespace | `git diff --check 25d4cb8b9ba81ae4a786924cd98a02c6d8e76d2b..HEAD` | no output | PASS |

## 8. Gaps and Exceptions

- Runtime registration gap: add the `prd-feature` `SubagentStop` validator command to canonical and published `.claude/settings.json`, then add a focused configuration-registration test. No exception is approved.

## 9. Summary of Changes

The branch adds numeric-derivation contracts, a PRD validator, planner internal-review requirements, a named-section checkbox counter, intake guidance, focused tests, and published Claude bundle mirrors. The missing settings registration prevents one required validator from taking effect.

## 10. Compliance Verdict

### Overall Status: NON-COMPLIANT

The branch requires remediation before PR readiness because AC1's enforcement hook is not registered. The successful focused test and coverage evidence do not substitute for the missing runtime registration.

## Appendix A: Test Inventory

- `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`
- `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1`
- `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1`
- `tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1`
- `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py`
- `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`

## Appendix B: Toolchain Commands Reference

```powershell
$configuration = New-PesterConfiguration
$configuration.Run.Path = @('tests/scripts/claude-hooks/validate-planner-output.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1','tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1','tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1')
Invoke-Pester -Configuration $configuration
```

```powershell
poetry run pytest tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
git diff --check 25d4cb8b9ba81ae4a786924cd98a02c6d8e76d2b..HEAD
```
