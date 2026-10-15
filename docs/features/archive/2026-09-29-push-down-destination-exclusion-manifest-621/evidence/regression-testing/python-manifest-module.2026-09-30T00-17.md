# Python Manifest Module Tests and Coverage — Issue #621

Task: [P3-T4]
Branch: feature/push-down-destination-exclusion-manifest-exec-621

Timestamp: 2026-09-30T00-17
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_exclusion_manifest.py --cov=scripts.dev_tools.push_down_exclusion_manifest --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json -q
EXIT_CODE: 0
Output Summary:
- Summary line: `75 passed in 0.23s` (0 failed, 0 errors, 0 skipped). The 16 test functions expand to 75 cases through parametrization (five property tests over ten seeds each).
- Term-missing row: `scripts\dev_tools\push_down_exclusion_manifest.py 104 0 34 0 100%`.
- From `artifacts/python/coverage.json`, key `scripts/dev_tools/push_down_exclusion_manifest.py` (after `\` to `/`): `num_statements` 104, `covered_lines` 104, `num_branches` 34, `covered_branches` 34.
- Line coverage: 104 / 104 = 1.00 (threshold 0.85, met).
- Branch coverage: 34 / 34 = 1.00 (threshold 0.75, met).
- Toolchain on the two Phase 3 Python files before this run: `poetry run black` reported `1 file left unchanged` on the final pass, `poetry run ruff check` printed `All checks passed!`, `poetry run pyright` printed `0 errors, 0 warnings, 0 informations`.

AC status: the Python half of AC-2 (`test_manifest_relative_path_is_root_level_outside_root_folders`) and of AC-16 (the five `test_property_*` functions) is proven by this run. No checkbox is changed here; per plan rule 12 the check-off occurs at [P5-T4] once the TypeScript half passes.
