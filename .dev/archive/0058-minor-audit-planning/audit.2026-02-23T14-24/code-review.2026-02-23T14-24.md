# Code Review: minor-audit-planning (Issue #58)

**Base Branch:** `main`  
**Feature Folder:** `docs/features/active/2026-02-23-minor-audit-planning-58`  
**Feature Folder Selection Rule:** User-provided feature path was treated as authoritative and validated.

## Executive summary

The feature successfully implements mode-aware prompt contracts for planning and hard-lock flows in Python and template/task layers:
- Mode placeholders were added to planning/hard-lock prompts.
- Resolver scripts now inject `${work-mode}` and `${fallback-reason}` using shared parsing logic.
- Resume hard-lock got dynamic `${plan-path}` and a dedicated VS Code task.

Top risks:
1. **Blocker:** PowerShell test failure (`new-potential-entry.Tests.ps1`) reveals implementation/test mismatch for insiders behavior.
2. **Blocker:** PowerShell lint failure due to indentation warnings in the same updated test file.
3. **Major:** PR context summary is commit-range centric and may underrepresent uncommitted feature work without appendix cross-check.

**PR readiness:** **No-Go (needs revision).**

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` + `scripts/dev-tools/new-potential-entry.ps1` | test lines 249, 265; impl line 100 | Test expects `code-insiders` preference in insider sessions, but implementation always checks/launches `code`. | Update `Invoke-VSCodeOpen` to prefer `code-insiders` when insider session signal exists and both commands are available; keep fallback to `code`. | Current behavior and expected contract diverge, causing failing Pester gate. | `Invoke-PoshQCTest -Root .` failure + source/test line evidence. |
| Blocker | `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` | lines 257–267 | PSScriptAnalyzer reports inconsistent indentation warnings (10 findings). | Reformat/align indentation to pass `PSUseConsistentIndentation`. | PowerShell lint gate must pass per repo policy. | `Invoke-PoshQCAnalyze -Root .` output shows warnings and exit code 1. |
| Major | `artifacts/pr_context.summary.txt` | changed-files sections | Summary shows commit-range subset while active feature includes additional unstaged scope captured in appendix. | Continue using appendix as diff source-of-truth for this review run; consider improving summary generation for working-tree review mode. | Prevents under-scoping acceptance checks. | Summary + appendix comparison from this run. |

## Typed Python audit

- **Type safety:** ✅ `pyright` clean (`0 errors`), new shared helper `scripts/dev_tools/prompt_mode_contract.py` is typed and has narrow string-union behavior by contract.
- **No weakening:** ✅ No broad `type: ignore` additions in reviewed Python files beyond pre-authorized optional-import patterns.
- **Contract centralization:** ✅ Mode decision logic is centralized (`parse_issue_work_mode`, `resolve_selected_work_mode`, `build_fallback_reason`) and reused by resolver entry points.
- **Error handling:** ✅ Fail-closed behavior for missing/malformed/unreadable `issue.md` is explicit and deterministic.
- **Public API clarity/docstrings:** ✅ Added Python functions include robust intent docstrings and branch comments aligned with repo commenting policy.

## Test quality audit

- **Determinism:** ✅ New Python tests are deterministic, focused, and isolated via monkeypatch/mocks.
- **Coverage of key branches:** ✅ Includes positive (`minor-audit`), missing marker, malformed marker, missing file, unreadable file, and resume-template selection scenarios.
- **Failure diagnostics:** ✅ Assertions produce precise mismatch details for resolver outputs.
- **Policy gate status:** ⚠️ Python suite passes, but overall feature test quality is blocked by one failing PowerShell test.

## Security and correctness checks

- ✅ No secret material introduced in reviewed files.
- ✅ Subprocess clipboard calls remain path-validated via `shutil.which` in Python resolver scripts.
- ✅ Input boundary handling for mode marker is strict and fail-closed to `full`.

## Review evidence snapshot

- Template placeholders and mode context:
  - `.github/prompts/generate-atomic-plan.prompt.md` lines 17–18
  - `.github/codex/execute-hard-lock.prompt.md` lines 88–92
  - `.github/codex/resume-hard-lock.prompt.md` lines 30–33
- Task wiring:
  - `.vscode/tasks.json` lines 468–473 (`Dev: Resolve Resume Hard-Lock Prompt`)
- Resolver mode injection:
  - `scripts/dev_tools/resolve_file_prompt.py` lines 381, 473–475
  - `scripts/dev_tools/resolve_hard_lock_prompt.py` lines 138, 203–215, 245–260
  - `scripts/dev_tools/resolve_execute_plan_prompt.py` lines 298, 314–325, 456
- Focused mode tests:
  - `tests/scripts/dev_tools/test_prompt_mode_contract.py` line 10+
  - `tests/scripts/dev_tools/test_resolve_file_prompt.py` lines 195, 223, 251
  - `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py` lines 119, 147, 442
  - `tests/scripts/dev_tools/test_resolve_execute_plan_prompt_part2.py` lines 457, 481, 525
