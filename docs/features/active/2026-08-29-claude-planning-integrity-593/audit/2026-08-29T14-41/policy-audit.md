# Policy Compliance Audit: Claude Planning Integrity (#593)

**Audit Date:** 2026-08-29
**Code Under Test:** Complete branch range `25d4cb8b9ba81ae4a786924cd98a02c6d8e76d2b..3658effcc58c946ee430c758fce666a5d451686c`, including Claude agents, skills, hooks, the generated-document counter, settings, tests, evidence, and bundle mirrors.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---:|---:|---|---|---|---|
| Python | 1 | 31 focused; 4,218 full | PASS | 93% | 93% | N/A: remediation changed a test only |
| PowerShell | 4 production; 5 focused test files | 77 focused | PARTIAL | 90.00% / 93.75% hooks | 90.00% / 93.75% hooks | 100% for the original PRD validator; planner-record contract requires remediation |
| JSON | 2 mirrored settings files | 2 independent parsers | PASS | N/A | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope
- TypeScript post-change coverage artifact: N/A - out of scope
- PowerShell baseline coverage artifact: `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/prd-feature-registration-powershell-tests-and-coverage.2026-08-29T13-53.md`
- PowerShell post-change coverage artifact: `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/prd-feature-registration-powershell-tests-and-coverage.2026-08-29T13-53.md`
- Per-language comparison summary: `## 5. Test Coverage Detail`

## Executive Summary

Result: **PARTIAL / remediation required.** Existing quality evidence and the focused re-review checks pass, but the changed planner stop-hook does not enforce the self-review record required by the specification and its own plan. `Test-HasPlannerInternalReview` accepts a three-token declaration without results, citations, acceptance-criterion mapping, or unresolved-gap disposition. This prevents AC2 from being verified.

Policy documents evaluated: `AGENTS.md`, `.agents/skills/general-code-change/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`, `.agents/skills/powershell/SKILL.md`, and `.agents/skills/python/SKILL.md`.

## 1. General Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Independence, isolation, determinism | PASS | The reviewed Pester and pytest fixtures use inline strings and in-memory JSON; no temporary files or external services are used. |
| Positive, negative, and boundary coverage | PARTIAL | Numeric provenance, counter boundaries, and settings registration have focused positive and negative coverage. The planner-review gate lacks rejection coverage for absent citation enumeration, AC mapping, results, and unresolved-gap disposition. |
| Coverage baseline and regression | PASS | PowerShell hook coverage remains 90.00% and 93.75%; full Python coverage remains 93%. See `evidence/qa-gates/numeric-provenance-powershell-tests-and-coverage.2026-08-29T13-15.md` and `evidence/qa-gates/prd-feature-registration-python-full-coverage.2026-08-29T13-53.md`. |

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Scope and architecture | PASS | Diff inspection and parity verification cover only the Claude surfaces, bundle mirrors, focused tests, and feature evidence described by the plan. |
| Explicit failure handling | PARTIAL | Numeric and settings validators reject invalid data explicitly. The planner validator’s implementation omits required self-review record validation. |
| File size and maintainability | PASS | Reviewed production and test files are below 500 lines; added counter is a small pure module. |

## 3. Language-Specific Code Change Policy Compliance

### Python

PASS. The focused Python contracts pass (31 tests), Black check reports two files unchanged, Ruff passes, and Pyright reports 0 errors, warnings, and information messages. The recorded full suite is 4,218 passed, 5 skipped at 93% coverage.

### PowerShell

PARTIAL. The focused Pester suite passes 77/77, and all inspected changed scripts parse successfully. Recorded formatter/analyzer and coverage evidence is passing. The missing planner-record validation is a behavioral contract gap, not a formatting or parse error.

## 4. Language-Specific Unit Test Policy Compliance

| Language | Status | Evidence |
|---|---|---|
| Python | PASS | `poetry run pytest tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -p no:cacheprovider -q` returned 31 passed. |
| PowerShell | PARTIAL | The five focused Pester files returned 77 passed. `validate-planner-output.Tests.ps1` only tests missing dimensions and the minimal three-token declaration, so it does not enforce the complete required record. |

## 5. Test Coverage Detail

PowerShell baselines and post-change values are retained at 90.00% for `validate-task-researcher-output.ps1` and 93.75% for `validate-prd-feature-output.ps1`. The Python full-suite baseline and post-change value are both 93% (15,210 statements and 1,109 missed). The planner-hook gap is uncovered behavioral surface rather than a quantified coverage regression.

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93% lines -> Post-change: 93% lines. Change: +0% lines. New/changed-code coverage: N/A - test-only remediation. Disposition: PASS. Evidence: `evidence/remediation-baseline/prd-feature-registration-python-full-coverage.2026-08-29T13-53.md` and `evidence/qa-gates/prd-feature-registration-python-full-coverage.2026-08-29T13-53.md`.
- PowerShell: Baseline: 90.00% lines -> Post-change: 90.00% lines. Change: +0.00% lines. New/changed-code coverage: 100.00% for the new PRD validator. Disposition: PASS. Evidence: `evidence/remediation-baseline/prd-feature-registration-powershell-tests-and-coverage.2026-08-29T13-53.md` and `evidence/qa-gates/prd-feature-registration-powershell-tests-and-coverage.2026-08-29T13-53.md`. Functional planner-record remediation remains required.

## 6. Test Execution Metrics

Focused re-review: 77 Pester tests passed in 1.49 seconds; 31 pytest tests passed in 0.20 seconds. All inspected PowerShell targets parse successfully. Full QA evidence recorded by the feature is current for head `3658effcc58c946ee430c758fce666a5d451686c` except that it cannot establish the missing planner-record enforcement.

## 7. Code Quality Checks

| Check | Result | Status |
|---|---|---|
| Git diff whitespace | `git diff --check` passed | PASS |
| PowerShell parser | All reviewed changed PowerShell files parsed | PASS |
| Black | Two focused Python files would be left unchanged | PASS |
| Ruff | All checks passed | PASS |
| Pyright | 0 errors, 0 warnings, 0 information messages | PASS |
| Focused Pester | 77 passed, 0 failed | PASS |
| Focused pytest | 31 passed | PASS |

## 8. Gaps and Exceptions

**Gap:** `.claude/hooks/validate-planner-output.ps1:113-120` validates only the presence of `PLANNER-INTERNAL-REVIEW:` and three dimension labels. It does not validate passing results, re-derived citation enumeration, AC-to-implementation mapping, or an unresolved-gap record. Direct invocation with only those four tokens returned `True`.

No approved exceptions apply.

## 9. Summary of Changes

The branch implements numeric-provenance controls, planner-review guidance, named-section counting, batched parallel intake, bundle parity, and the later `prd-feature` settings registration remediation. The settings registration is correct in both canonical and bundled settings files, including the requested negative test cases. The branch remains incomplete only for enforceable planner self-review evidence.

## 10. Compliance Verdict

**Overall Status: PARTIALLY COMPLIANT.** Remediation is required before PR readiness because AC2 is currently checked despite the missing enforcement.

## Appendix A: Test Inventory

- `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1`
- `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1`
- `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`
- `tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1`
- `tests/scripts/claude-runtime/claude-settings.Tests.ps1`
- `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py`
- `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`

## Appendix B: Toolchain Commands Reference

```powershell
Invoke-Pester -Path tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1,tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1,tests/scripts/claude-hooks/validate-planner-output.Tests.ps1,tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1,tests/scripts/claude-runtime/claude-settings.Tests.ps1 -PassThru
```

```powershell
poetry run black --check tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py
poetry run ruff check tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py
poetry run pyright tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py
poetry run pytest tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -p no:cacheprovider -q
```
