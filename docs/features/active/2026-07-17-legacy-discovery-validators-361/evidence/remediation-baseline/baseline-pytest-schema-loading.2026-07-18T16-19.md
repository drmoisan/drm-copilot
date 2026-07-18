Timestamp: 2026-07-18T16-19
Command: `poetry run pytest --cov=scripts.dev_tools.schema_loading --cov-branch --cov-report=term-missing tests/scripts/dev_tools/test_schema_loading.py`
EXIT_CODE: 0

Output Summary:
5 passed in 0.08s.

`scripts/dev_tools/schema_loading.py` per-file coverage (test-file-scoped run, `tests/scripts/dev_tools/test_schema_loading.py` only, pre-remediation state — before Phase 1's three new test functions were added):
- Statements: 35 total, 25 covered, 10 missed.
- Line (statement) coverage: 71.43% (`percent_statements_covered`).
- Branches: 14 total, 9 covered, 5 missed, 3 partial.
- Branch coverage: 64.29% (`percent_branches_covered`).
- Blended `percent_covered` (statements+branches combined, the "Cover" column coverage.py prints): 69.39% (displayed as `69%`).
- Missing lines reported by `--cov-report=term-missing`: `94, 99-103, 113-117`.

Branch coverage (64.29%) is below the 75% uniform threshold, confirming Finding 1's blocking status before remediation.

Note on the reference figures in `remediation-inputs.2026-07-18T16-04.md` (85.71% line / 71.43% branch): those figures were measured during an independent full-suite run (`poetry run pytest --cov --cov-branch ...`, all 1717 tests), where `schema_loading.py`'s lines are also exercised indirectly by `tests/scripts/dev_tools/test_validate_json.py` via `validate_json.py`'s thin wrapper. This task's command scopes coverage measurement to `tests/scripts/dev_tools/test_schema_loading.py` alone, which does not include that indirect exercise, so the measured baseline here (71.43% line / 64.29% branch) is lower than the full-suite per-file figures. Both figures agree on the controlling fact: `schema_loading.py`'s `file://`-scheme code path (lines 98-103) and the scheme-less not-found branch (line 94) are untested, and branch coverage sits below the 75% threshold either way.
