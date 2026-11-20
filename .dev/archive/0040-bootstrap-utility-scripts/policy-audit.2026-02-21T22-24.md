# Policy Compliance Audit: bootstrap-utility-scripts (#40)

**Audit Date:** 2026-02-21  
**Base branch:** development (from refreshed `artifacts/pr_context.summary.txt`)  
**Head branch:** bootstrap-utilities-#40  
**Work mode marker:** `- Work Mode: minor-audit` (from `docs/features/active/2026-02-21-bootstrap-utility-scripts-40/issue.md`)  
**Feature folder selection rule:** used `docs/features/active/2026-02-21-bootstrap-utility-scripts-40/` because it is the active issue #40 folder and contains the authoritative `minor-audit` marker.

## Executive Summary

Overall status: **⚠️ PARTIAL / ❌ FAIL for merge readiness**.

- Python toolchain is not fully compliant: `poetry run pyright` fails (`PYRIGHT_EXIT=1`) due analysis of `node_modules/flatted/python/flatted.py` and unrecognized `diagnosticMode` setting.
- File-size policy is violated by multiple changed files well above the 500-line cap.
- PowerShell and TypeScript gates pass in this environment.

Recommendation: **Needs revision** before PR merge.

## Policy Documents Evaluated

- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`
- [✅] `python-code-change.instructions.md`
- [✅] `python-unit-test.instructions.md`
- [✅] `powershell-code-change.instructions.md`
- [✅] `powershell-unit-test.instructions.md`
- [✅] `typescript-code-change.instructions.md`
- [✅] `typescript-unit-test.instructions.md`

## Compliance Findings

### General code-change policy

| Requirement | Status | Evidence |
|---|---|---|
| Toolchain loop executed | [⚠️] PARTIAL | Python: format/lint/tests pass but type-check fails. PowerShell and TypeScript loops passed. |
| Modules under 500 lines | [❌] FAIL | Examples: `scripts/dev_tools/atomic_executor/cli.py` (2327), `scripts/dev_tools/new_active_feature_folder.py` (1190), `scripts/dev_tools/fix_all.py` (944), `scripts/dev_tools/pr_context/render.py` (615), tests also exceed cap. |
| Cohesive structure and SoC | [⚠️] PARTIAL | Large monolithic files materially increase maintenance risk and conflict with policy size constraint. |

### Python policy

| Requirement | Status | Evidence |
|---|---|---|
| Black | [✅] PASS | `poetry run black --check .` -> `79 files would be left unchanged.` |
| Ruff | [✅] PASS | `poetry run ruff check .` -> `All checks passed!` |
| Pyright strict typing | [❌] FAIL | `poetry run pyright` -> `PYRIGHT_EXIT=1`; 162 errors in `node_modules/flatted/python/flatted.py`; warning: `Config contains unrecognized setting "diagnosticMode"`. |
| Pytest | [✅] PASS | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` -> `765 passed`; total coverage 81%. |

### PowerShell policy

| Requirement | Status | Evidence |
|---|---|---|
| Direct PoshQC formatting command | [✅] PASS | `Invoke-PoshQCFormat -Root .` -> `POSH_FORMAT_EXIT=0` |
| Direct PoshQC analyze command | [✅] PASS | `Invoke-PoshQCAnalyze -Root .` -> `PSScriptAnalyzer passed: no findings under .`; `POSH_ANALYZE_EXIT=0` |
| Direct PoshQC test command | [✅] PASS | `Invoke-PoshQCTest -Root .` -> `211 passed, 0 failed, 7 skipped`; `POSH_TEST_EXIT=0` |

### TypeScript policy

| Requirement | Status | Evidence |
|---|---|---|
| Prettier check | [✅] PASS | `npm run format:check` -> all matched files formatted |
| ESLint | [✅] PASS | `npm run lint` -> no errors |
| Type check | [✅] PASS | `npm run typecheck` -> success |
| Jest unit tests | [✅] PASS | `npm run test:unit` -> `1 passed, 1 total` |

## Merge Recommendation

**Needs revision**.

Blocking conditions:
1. Python type-check gate fails.
2. Multiple files violate mandatory 500-line file-size policy.

## Appendix A: Key line-count evidence

- `scripts/dev_tools/atomic_executor/cli.py`: 2327
- `tests/scripts/dev_tools/atomic_executor/test_cli.py`: 1635
- `scripts/dev_tools/new_active_feature_folder.py`: 1190
- `tests/scripts/dev_tools/test_new_active_feature_folder.py`: 1135
- `tests/scripts/dev_tools/test_collect_pr_context.py`: 1022
- `scripts/dev_tools/fix_all.py`: 944
- `scripts/dev_tools/atomic_executor/qc_runner.py`: 897
- `tests/scripts/dev_tools/test_github.py`: 779
- `scripts/dev_tools/potential_to_issue.py`: 762
- `tests/scripts/dev_tools/test_resolve_execute_plan_prompt.py`: 673
- `scripts/dev_tools/pr_context/render.py`: 615

## Appendix B: Commands executed

- `poetry run python -m scripts.dev_tools.pr_context.collector --base development`
- `poetry run black --check .`
- `poetry run ruff check .`
- `poetry run pyright`
- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Install-PoshQCTools"`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
- `npm run format:check`
- `npm run lint`
- `npm run typecheck`
- `npm run test:unit`
