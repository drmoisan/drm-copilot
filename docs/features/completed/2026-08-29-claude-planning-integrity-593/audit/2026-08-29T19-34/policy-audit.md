# Policy Compliance Audit: Claude Planning Integrity (#593)

**Audit Date:** 2026-08-29  
**Code Under Test:** Complete feature range `25d4cb8b9ba81ae4a786924cd98a02c6d8e76d2b..881469fc96cc029e1797159075b97d8782a32094`.

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---:|---|---|---|---|---|
| TypeScript | 0 files | N/A | N/A | N/A | N/A | N/A |
| Python | 3 files | 4,220 full; 33 focused | 4,220 passed, 5 skipped; Black FAIL | 93% lines | 93% lines | N/A: test-only changed scope |
| PowerShell | 14 files | full-root Pester coverage | PASS | 90.00% lines | 94.78% lines | 96.28% modified planner hook |
| JSON | 4 files | focused settings and contract tests | PASS | N/A | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope.
- TypeScript post-change coverage artifact: N/A - out of scope.
- PowerShell baseline coverage artifact: `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-powershell-tests-and-coverage-baseline.2026-08-29T14-41.md`.
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`, refreshed during this review.
- Per-language comparison summary: Section 1.2.1.

## Executive Summary

Result: **PARTIAL / remediation required.** The feature implementation, current PowerShell format/analyzer/Pester coverage run, Python lint/type checks, focused Python tests, and full Python coverage pass. The Python formatting check reports that `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` would be reformatted. `git diff --check main...HEAD` also reports five blank-line-at-EOF errors in committed evidence files. These are toolchain failures; no implementation defect was found in the planner-review validator during this review.

Policy documents evaluated: `AGENTS.md`, `.agents/skills/general-code-change/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`, `.agents/skills/powershell/SKILL.md`, `.agents/skills/python/SKILL.md`, and `.agents/skills/python-suppressions/SKILL.md`.

## 1. General Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Independent, isolated tests | PASS | Focused Pester fixtures use mocked file access and inline payloads; focused Python tests completed 33/33. |
| Positive, negative, and boundary coverage | PASS | Planner-review Pester fixtures cover valid records, missing/duplicate/blank declarations, invalid citations, mappings, and unresolved gaps. |
| Coverage thresholds | PASS | Current PowerShell repository coverage is 94.78%; modified planner hook is 96.28%; Python repository coverage is 93%. |
| Source formatting | FAIL | Black would reformat `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: N/A -> Post-change: N/A. Change: N/A. New/changed-code coverage: N/A - out of scope. Disposition: N/A. Evidence: no TypeScript files changed.
- Python: Baseline: 93% lines -> Post-change: 93% lines. Change: +0% lines. New/changed-code coverage: N/A - test-only changed scope. Disposition: PASS. Evidence: `artifacts/python/lcov.info` from current `poetry run pytest --cov`.
- PowerShell: Baseline: 90.00% lines -> Post-change: 94.78% lines. Change: +4.78% lines. New/changed-code coverage: 96.28% for `validate-planner-output.ps1`. Disposition: PASS. Evidence: baseline artifact and current `artifacts/pester/powershell-coverage.xml`.

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Scope and architecture | PASS | Diff review confirms Claude runtime surfaces and their published mirrors are changed; canonical and bundled planner hooks are byte-identical. |
| Explicit failure handling | PASS | `Get-PlannerInternalReviewValidation` rejects malformed bounded records with specific messages. |
| File size | PASS | Reviewed changed PowerShell source and test files are below 500 lines. |
| Required toolchain loop | FAIL | Black and `git diff --check` are not clean, so the required clean pass has not occurred. |

## 3. Language-Specific Code Change Policy Compliance

### Python

Ruff passed, Pyright returned 0 errors, and focused pytest returned 33 passed. Full pytest coverage returned 4,220 passed and 5 skipped at 93%. Black check failed for one changed test file.

### PowerShell

The full-root PoshQC format, analyzer, and Pester operations each returned `ok: true`. The refreshed coverage XML records 7,310 covered and 403 missed repository line units (94.78%). `validate-planner-output.ps1` records 181 covered and 7 missed line units (96.28%).

## 4. Language-Specific Unit Test Policy Compliance

| Language | Status | Evidence |
|---|---|---|
| Python | PARTIAL | Tests and coverage pass, but Black identifies a required formatting change. |
| PowerShell | PASS | Full-root PoshQC format, analyzer, and test-with-coverage checks pass. |

## 5. Test Coverage Detail

- Python: 93% repository coverage from the current `poetry run pytest --cov` run; no new production Python module was added.
- PowerShell: 94.78% repository coverage; the materially modified planner hook is 96.28%, above the 80% modified-file threshold.

## 6. Test Execution Metrics

- Focused Python contracts: 33 passed in 0.20 seconds.
- Full Python suite: 4,220 passed, 5 skipped in 11.67 seconds.
- Full-root PowerShell format, analysis, and Pester coverage: passed through the MCP PoshQC surface.

## 7. Code Quality Checks

| Check | Result | Status |
|---|---|---|
| `git diff --check main...HEAD` | Five EOF blank-line findings | FAIL |
| Black check | One changed Python test would be reformatted | FAIL |
| Ruff | All checks passed | PASS |
| Pyright | 0 errors, 0 warnings, 0 information messages | PASS |
| Focused pytest | 33 passed | PASS |
| Full pytest coverage | 4,220 passed, 5 skipped; 93% | PASS |
| PoshQC format/analyze/test | All returned `ok: true` | PASS |

## 8. Gaps and Exceptions

No approved exceptions apply. Remediate the Black finding and remove the five trailing blank lines reported by `git diff --check`; rerun the complete format, lint, type-check, test, and coverage loop.

## 9. Summary of Changes

The branch adds numeric-provenance validation, planner internal-review record enforcement, named-section generated-document counting, parallel-intake constraints, settings registration, focused tests, and published Claude bundle mirrors. The final planner validator has direct positive and negative coverage and is byte-identical with its bundle mirror.

## 10. Compliance Verdict

**Overall Status: PARTIALLY COMPLIANT.** The branch is not ready for PR creation until the formatting and whitespace failures are corrected and the toolchain is rerun cleanly.

## Appendix A: Test Inventory

- `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`
- `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1`
- `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1`
- `tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1`
- `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py`
- `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`

## Appendix B: Toolchain Commands Reference

```powershell
mcp__drm_copilot__run_poshqc_format -scan_folders '.'
mcp__drm_copilot__run_poshqc_analyze -scan_folders '.'
mcp__drm_copilot__run_poshqc_test -scan_folders '.'
git diff --check main...HEAD
```

```powershell
poetry run black --check tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
poetry run ruff check tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
poetry run pyright tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
poetry run pytest --cov
```
