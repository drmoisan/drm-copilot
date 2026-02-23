# Code Review: testing-missing-mock-injections (#42)

## Executive summary

This feature fixes a unit-test isolation defect by enforcing explicit launcher injection and adding a scoped guard that blocks unmocked VS Code launcher subprocess calls in `tests/scripts/dev_tools/test_new_active_feature_folder.py`.

Feature-folder selection rule used: explicit user-provided folder `docs/features/active/2026-02-22-testing-missing-mock-injections-42` is authoritative for this review.

**Top 3 risks (non-blocking):**
1. Guard allowlist is name-based (`default_code_launcher`) and may need maintenance if test names change.
2. Scoped subprocess monkeypatch could hide future legitimate subprocess expectations in the guarded module if new scenarios are added without updates.
3. Branch-level PR context is noisy due to unrelated branch history; reviewers should use feature-local evidence/documents for this feature decision.

**Recommendation:** **Go** (PR-ready for this feature scope).

## Findings table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/conftest.py` | `guard_unmocked_code_launcher_subprocess` | Allowlist is string-based and tied to test naming convention. | Consider centralizing allowlisted node-id patterns in a constant with a short maintenance note. | Prevents brittle coupling if test function names evolve. | Scoped fixture implementation and allowlist tuple in `tests/conftest.py`. |
| Nit | `tests/scripts/dev_tools/test_new_active_feature_folder.py` | alias function export for long test names | A few scenario tests are surfaced through alias assignment patterns. | Keep as-is for now; optionally normalize naming style in a follow-up cleanup-only change. | Not correctness-impacting; readability-only. | Existing alias patterns around `scenario_single_work_mode_marker_before_first_heading`. |

## Typed Python audit

- **Type safety:** No type-check weakening observed in scoped changes; current run shows `0 errors, 0 warnings, 0 informations` from Pyright.
- **`Any`/ignore usage:** No new broad ignores introduced in scoped code.
- **Error handling:** Guard raises explicit `AssertionError` with executable token + node id context.
- **Logging/diagnostics:** Failure messages are specific and actionable for test triage.
- **Public API clarity:** Production API behavior preserved; change remains test-infrastructure-focused.

## Test quality audit

- Deterministic fail-before evidence exists (`guard-fail-before...`).
- Deterministic pass-after evidence exists (`guard-and-launcher-verification...`, `pytest-target-green...`).
- Broader dev-tools suite evidence exists (`pytest-dev-tools-green...`).
- Full Python QA loop evidence exists (`qa-loop-summary...`).

## Security and correctness checks

- No secrets introduced in reviewed scope.
- Unsafe subprocess usage reduced in tests via scoped interception and explicit launcher injection.
- Input boundary validation remains covered by existing tests for invalid feature type / missing templates / fallback behavior.

## Verification commands executed in this review

- `poetry run black --check .` → PASS
- `poetry run ruff check` → PASS
- `poetry run pyright` → PASS
- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` → PASS (`771 passed`)
