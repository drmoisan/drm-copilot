# Policy Compliance Audit: minor-audit-planning (Issue #58)

**Audit Date:** 2026-02-23  
**Base Branch:** `main`  
**Feature Folder:** `docs/features/active/2026-02-23-minor-audit-planning-58`  
**Feature Folder Selection Rule:** User-provided folder path was used directly and verified on disk.

**Code Under Test (review scope):**
- `.github/prompts/generate-atomic-plan.prompt.md`
- `.github/codex/execute-hard-lock.prompt.md`
- `.github/codex/resume-hard-lock.prompt.md`
- `.vscode/tasks.json`
- `scripts/dev_tools/prompt_mode_contract.py`
- `scripts/dev_tools/resolve_file_prompt.py`
- `scripts/dev_tools/resolve_hard_lock_prompt.py`
- `scripts/dev_tools/resolve_execute_plan_prompt.py`
- `tests/scripts/dev_tools/test_prompt_mode_contract.py`
- `tests/scripts/dev_tools/test_resolve_file_prompt.py`
- `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py`
- `tests/scripts/dev_tools/test_resolve_execute_plan_prompt_part2.py`
- `tests/scripts/dev-tools/new-potential-entry.Tests.ps1`

## Executive Summary

`pr_context` artifacts were regenerated against `main` via `poetry run python -m scripts.dev_tools.pr_context.collector --base main`.

Compliance status is **partial / needs revision**:
- Python and JSON quality gates passed.
- Acceptance-criteria-aligned resolver behavior is strongly covered by focused Python tests and passed.
- PowerShell policy gates failed:
  - `Invoke-PoshQCAnalyze` failed with 10 indentation warnings in `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` (lines 257–267).
  - `Invoke-PoshQCTest` failed (1 failing Pester test) because test expects `code-insiders` selection, but implementation in `scripts/dev-tools/new-potential-entry.ps1` still always launches `code`.

## Compliance Verdict

**Status:** ⚠️ PARTIALLY COMPLIANT  
**Recommendation:** **Needs revision** before PR merge.

## Policy document coverage

- [✅] `general-code-change.instructions.md` reviewed
- [✅] `general-unit-test.instructions.md` reviewed
- [✅] `python-code-change.instructions.md` reviewed
- [✅] `python-unit-test.instructions.md` reviewed
- [✅] `powershell-code-change.instructions.md` reviewed
- [✅] `powershell-unit-test.instructions.md` reviewed

## PR context validation

| Requirement | Status | Evidence |
|---|---|---|
| PR context regenerated/validated | ⚠️ PARTIAL | Regenerated using `scripts.dev_tools.pr_context.collector --base main`; summary reflects commit-range state, while authoritative current working-tree evidence was taken from `artifacts/pr_context.appendix.txt` (unstaged diff section). |
| Base/head traceability | ✅ PASS | `Base: origin/main @ e593df2...`, `Head: feature/minor-audit-planning-58 @ c791d17...` from `artifacts/pr_context.summary.txt`. |

## Quality-gate results

| Check | Command | Result | Status |
|---|---|---|---|
| Python format (check-only) | `poetry run black --check .` | 116 files unchanged | ✅ PASS |
| Python lint | `poetry run ruff check .` | All checks passed | ✅ PASS |
| Python type check | `poetry run pyright` | 0 errors | ✅ PASS |
| Targeted Python tests | `poetry run pytest tests/scripts/dev_tools/test_prompt_mode_contract.py tests/scripts/dev_tools/test_resolve_file_prompt.py tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py tests/scripts/dev_tools/test_resolve_execute_plan_prompt_part2.py` | 62 passed | ✅ PASS |
| Full Python tests + coverage | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | 797 passed, total coverage 81% | ✅ PASS |
| JSON validation | `poetry run python -m scripts.dev_tools.validate_json` | No validation errors reported | ✅ PASS |
| PowerShell analyze | `pwsh ... Invoke-PoshQCAnalyze -Root .` | 10 indentation warnings; exit code 1 | ❌ FAIL |
| PowerShell tests | `pwsh ... Invoke-PoshQCTest -Root .` | 211 passed / 1 failed / 7 skipped | ❌ FAIL |

## Policy findings (material)

1. **PowerShell lint policy violation**  
   - File: `tests/scripts/dev-tools/new-potential-entry.Tests.ps1`  
   - Evidence: `PSUseConsistentIndentation` warnings at lines 257–267.  
   - Impact: `Invoke-PoshQCAnalyze` fails, violating required PowerShell toolchain pass.

2. **PowerShell test-policy violation / behavior mismatch**  
   - Test: `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` line 249+ (`prefers code-insiders...`).  
   - Failing assertion line: 265 expects `code-insiders`.  
   - Implementation: `scripts/dev-tools/new-potential-entry.ps1` line 100 hard-codes `GetCommand 'code'` and launches `code`.  
   - Impact: `Invoke-PoshQCTest` fails; intended behavior and implementation diverge.

## Recommendation

**Needs revision.**
- Fix PowerShell implementation for insiders command preference and align indentation in the modified Pester test file.
- Re-run PowerShell analyze + Pester, then repeat full policy gate pass.

## Appendix B: Commands executed

- `poetry run python -m scripts.dev_tools.pr_context.collector --base main`
- `poetry run black --check .`
- `poetry run ruff check .`
- `poetry run pyright`
- `poetry run pytest tests/scripts/dev_tools/test_prompt_mode_contract.py tests/scripts/dev_tools/test_resolve_file_prompt.py tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py tests/scripts/dev_tools/test_resolve_execute_plan_prompt_part2.py`
- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
- `poetry run python -m scripts.dev_tools.validate_json`
