# Feature Audit — minor-audit-planning (Issue #58)

## Scope and baseline

- **Base branch:** `main`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Diff/details: `artifacts/pr_context.appendix.txt`
- **Feature folder:** `docs/features/active/2026-02-23-minor-audit-planning-58`
- **Work mode marker:** `full` (from `issue.md`)

## Acceptance criteria inventory (authoritative)

From refreshed `pr_context.summary.txt` + `spec.md` + `user-story.md`:
1. `generate-atomic-plan` resolves mode via canonical precedence and emits mode context.
2. Execute/resume hard-lock resolve dynamic plan-path with mode-consistent instructions.
3. Resolver scripts share one observable mode contract.
4. Ineligible `minor-audit` falls back to `full` with deterministic reason.
5. Existing full-mode workflows remain backward compatible.
6. Python changes pass Black/Ruff/Pyright/Pytest and docs/commenting standards.
7. Rollout/validation treated as full-process work for this issue.

## Acceptance criteria evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| 1 | PASS | Mode placeholders and resolver propagation are present; tests cover mode-resolution behavior. | `poetry run pytest tests/scripts/dev_tools/test_prompt_mode_contract.py tests/scripts/dev_tools/test_resolve_file_prompt.py` | Matches canonical precedence contract. |
| 2 | PASS | Execute/resume templates and resolvers use dynamic plan path and mode context. | `poetry run pytest tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py tests/scripts/dev_tools/test_resolve_execute_plan_prompt_part2.py -k mode` | No hardcoded plan path required in behavior flow. |
| 3 | PASS | Shared mode helper module (`prompt_mode_contract.py`) is used across entry points. | `poetry run pyright`; targeted pytest above | Observable outputs aligned across resolvers. |
| 4 | PASS | Fail-closed fallback reason behavior covered in tests and reflected in helper contract. | `poetry run pytest tests/scripts/dev_tools/test_prompt_mode_contract.py` | Deterministic fallback retained. |
| 5 | PASS | Full-mode default/fallback remains valid; command signatures remain usable. | `poetry run pytest tests/scripts/dev_tools/test_resolve_file_prompt.py tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py` | Backward-compat maintained. |
| 6 | PASS | Python gates all green in current run. | `poetry run black --check .`; `poetry run ruff check .`; `poetry run pyright`; `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | 797 passed; coverage 81% in configured scope. |
| 7 | PASS | Full-process validation currently green across Python, JSON, PowerShell. | `poetry run python -m scripts.dev_tools.validate_json`; `pwsh ... Invoke-PoshQCAnalyze -Root .; Invoke-PoshQCTest -Root .` | PowerShell remediation outcomes verified. |

## Overall readiness

**Overall feature readiness:** ✅ **PASS**

No acceptance criteria are currently FAIL/PARTIAL based on refreshed branch evidence and direct toolchain runs.

Follow-up (non-blocking):
- Confirm intentional keep/delete strategy for historical timestamped audit/remediation markdown files currently shown as deleted in working tree status.
