# Code Review — minor-audit-planning (Issue #58)

**Base Branch:** `main`  
**Feature Folder:** `docs/features/active/2026-02-23-minor-audit-planning-58`  
**Feature Folder Selection Rule:** User-targeted feature path; validated via refreshed `pr_context`.

## Executive summary

This feature standardizes mode-resolution behavior (`minor-audit` vs `full`) across planning prompts, execute/resume hard-lock prompts, and Python resolver entrypoints.

Top risks:
1. Working-tree churn includes deletion/replacement of historical audit/remediation docs.
2. Cross-file contract changes span `.github` prompts/agents + Python resolvers + tasks wiring.
3. Backward-compatibility risk if mode defaults diverged (mitigated by fail-closed tests).

**PR readiness recommendation:** ✅ **Go** (with a final intentionality check on deleted/moved historical markdown artifacts).

## Findings table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `docs/features/active/...` | working tree status | Historical audit/remediation files are currently deleted and partially replaced in new paths. | Confirm intended keep/delete set before final commit/PR. | Prevent accidental loss of traceability docs. | `artifacts/pr_context.appendix.txt` status/diff section. |
| Minor | `tests/scripts/dev_tools/test_resolve_execute_plan_prompt_part2.py` | imports/type-only usage | `Callable` moved to `TYPE_CHECKING` import path during lint compliance work. | Keep pattern; it is Ruff-compliant and typing-safe. | Preserves strict linting without runtime import side-effects. | Current file diff + green Ruff/Pyright. |

## Typed Python audit

- ✅ Shared mode contract centralized in `scripts/dev_tools/prompt_mode_contract.py` and consumed by resolver entry points.
- ✅ No type-check weakening detected (`pyright` clean).
- ✅ `Ruff` clean; no unauthorized suppressions introduced in this run.
- ✅ Public behavior contracts are test-covered (mode parse, fallback reason, dynamic path propagation).

## Test quality audit

- ✅ Deterministic, isolated unit tests pass for resolver and mode-contract areas.
- ✅ Full Python suite passes (`797` tests).
- ✅ PowerShell suite passes (`212` tests, `0` failures) and analyzer is clean.
- ✅ Coverage meets repo floor in reported target scope (81% total in configured coverage scope).

## Security/correctness checks

- ✅ No secrets introduced in reviewed changes.
- ✅ Fail-closed fallback to `full` behavior is explicitly validated by tests and reflected in prompt/resolver flow.
- ✅ Dynamic plan-path handling replaces static hardcoded behavior in resume hard-lock flow.

## Verification commands used

- `poetry run black --check .`
- `poetry run ruff check .`
- `poetry run pyright`
- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
- `poetry run python -m scripts.dev_tools.validate_json`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .; Invoke-PoshQCTest -Root ."`
