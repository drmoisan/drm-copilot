# Policy Compliance Audit: Claude Planning Integrity (#593)

**Audit Date:** 2026-08-29
**Code Under Test:** Claude runtime contracts, PowerShell hooks and module, their bundle mirrors, and focused PowerShell and Python tests changed by `4c87251f2783c0e4383fe33545fd8b8df5eded53` relative to `25d4cb8b9ba81ae4a786924cd98a02c6d8e76d2b`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---:|---|---|---|---|---|
| TypeScript | 0 | N/A | N/A | N/A - no changed TypeScript files | N/A - no changed TypeScript files | N/A - no changed TypeScript files |
| Python | 2 test files | 4,216 passed, 5 skipped | PASS; numeric baseline artifact absent | N/A - test-only files; no numeric baseline coverage artifact was captured | N/A - baseline-comparison evidence is incomplete | N/A - test-only files |
| PowerShell | 4 production files | 65 focused Pester tests passed | PASS | 93.86% / 88.52% | 94.92% / 88.75% | 90.62% / 100% |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no changed TypeScript files.
- TypeScript post-change coverage artifact: N/A - no changed TypeScript files.
- PowerShell baseline coverage artifact: `evidence/baseline/powershell.2026-08-29T12-07.md`.
- PowerShell post-change coverage artifact: `evidence/qa-gates/powershell-coverage.2026-08-29T12-07.md`.
- Per-language comparison summary: Section 1.2.1.

## Executive Summary

The branch has passing recorded toolchain evidence, complete Claude bundle parity, and coverage meeting the documented thresholds. The review nevertheless identifies one material functional gap: the numeric-derivation hooks accept a `Cross-check Count` that equals the primary count without recording or validating a distinct cross-check search. This does not provide enforceable evidence that the required second, independently constructed search occurred. The policy verdict is therefore FAIL pending remediation.

Policy documents evaluated: `AGENTS.md`, the repository general code and unit-test policies, and the PowerShell and Python policies applicable to the reviewed files.

## 1. General Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Independence, isolation, determinism, and readability | PASS | Focused Pester tests use inline content and mocks; Python contract tests read repository files only. |
| Positive, negative, and boundary coverage | PARTIAL | Missing-evidence and unequal-count cases are covered, but the acceptance case permits a count-only cross-check with no independent-search evidence. |
| Coverage thresholds | PASS | The PowerShell final coverage evidence reports 90.62% for the new hook and 100% for the new counter module; existing hooks do not regress. |
| External dependencies | PASS | The reviewed focused tests use no network or temporary-file fixture. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 93.86% lines for `validate-planner-output.ps1` and 88.52% lines for `validate-task-researcher-output.ps1`. Post-change: 94.92% and 88.75% lines. Change: no regression. New/changed-code coverage: 90.62% for the new hook and 100% for the new module. Disposition: PASS. Evidence: `evidence/baseline/powershell.2026-08-29T12-07.md` and `evidence/qa-gates/powershell-coverage.2026-08-29T12-07.md`.

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Scope, cohesion, and file size | PASS | The 14 canonical Claude runtime paths are mirrored byte-for-byte; reviewed new and changed PowerShell files are below 500 lines. |
| Explicit error handling | PASS | Hooks reject missing payloads, paths, and malformed JSON with explicit messages. |
| Separation of concerns | PASS | The named-section counter is a small pure module; workflow policies and hook validation remain separate. |
| Required behavior | FAIL | The PRD and researcher hooks at `Test-NumericDerivationEvidence` accept a matching `Cross-check Count` without a distinct search description or independently derived member set. |

## 3. Language-Specific Code Change Policy Compliance

### PowerShell

| Requirement | Status | Evidence |
|---|---|---|
| Format and analyzer | PASS | `evidence/qa-gates/powershell-toolchain.2026-08-29T12-07.md` records already-formatted output and zero analyzer findings. |
| Focused Pester execution | PASS | The same evidence records 65 focused tests passing. |
| New-code coverage | PASS | `validate-prd-feature-output.ps1` is 29/32 lines (90.62%); `GeneratedDocumentCounters.psm1` is 14/14 lines (100%). |
| Numeric provenance enforcement | FAIL | Matching numeric fields do not prove a second independent search; see the code-review finding. |

### Python

| Requirement | Status | Evidence |
|---|---|---|
| Black, Ruff, Pyright, and Pytest | PASS | `evidence/qa-gates/python-toolchain.2026-08-29T12-07.md` records 458 files unchanged, Ruff clean, Pyright 0 errors, and 4,216 passed with 93% coverage. |
| Contract coverage | PARTIAL | The text contract checks only for `Cross-check Count`; it does not require cross-check search evidence or a distinct derivation. The retained baseline records focused pass count only, not a numeric Python coverage baseline. |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Status | Evidence |
|---|---|---|
| PowerShell | PARTIAL | The Pester suite covers error paths and section boundaries, but no fixture demonstrates rejection of a non-independent duplicate count. |
| Python | PARTIAL | `test_claude_planning_integrity_contracts.py` asserts labels, not independent derivation evidence. |

## 5. Test Coverage Detail

PowerShell coverage is complete for the policy threshold: `validate-planner-output.ps1` 112/118, `validate-task-researcher-output.ps1` 71/80, `validate-prd-feature-output.ps1` 29/32, and `GeneratedDocumentCounters.psm1` 14/14. The coverage result does not remove the behavioral gap because the absent rejection case is a test-design omission rather than an uncovered line.

## 6. Test Execution Metrics

- Focused PowerShell: 65 passed, 0 failed.
- Full Python: 4,216 passed, 5 skipped; `scripts.dev_tools` line coverage 93%.
- Focused Python Claude-contract suite: 29 passed.

## 7. Code Quality Checks

`git diff --check` is clean. The canonical-to-bundle mirror comparison checked all 14 changed `.claude/**` paths and found zero missing or differing mirrors.

## 8. Gaps and Exceptions

**FAIL — independent cross-check evidence is not mechanically required.** Both hook implementations require `Family`, inclusion and exclusion rules, a member set, and matching count values, but neither requires the primary search procedure or a separately documented cross-check search/member set. A research artifact can therefore state any matching second count without showing that it was independently constructed. Add explicit primary-derivation and cross-check-derivation fields, reject missing or equivalent derivation evidence, and add rejection fixtures to both hook and Python contract tests.

**PARTIAL — no numeric Python baseline coverage artifact is present.** The retained Python baseline records 25 focused tests passing, but not a coverage value that can be compared with the 93% post-change report. Preserve a numeric baseline in the next remediation execution or document a policy-approved test-only exception.

## 9. Summary of Changes

Commit `4c87251f` adds Claude-native numeric-provenance, planner-review, section-bounded counting, and parallel-intake contracts; their required published bundle mirrors; focused Pester coverage; and focused Python contract coverage.

## 10. Compliance Verdict

### Overall Status: NON-COMPLIANT

The evidence supports the completed toolchain, coverage, and bundle-parity checks. PR readiness is blocked by the missing independently constructed search evidence required for numeric criteria.

## Appendix A: Test Inventory

- `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1`
- `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1`
- `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`
- `tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1`
- `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py`
- `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`

## Appendix B: Toolchain Commands Reference

```powershell
Invoke-PoshQCFormat
Invoke-PoshQCAnalyze
Invoke-Pester -Configuration $configuration
```

```powershell
poetry run black .
poetry run ruff check .
poetry run pyright
poetry run pytest --cov=scripts.dev_tools --cov-report=term-missing
```

**Audit Completed By:** Codex feature reviewer
