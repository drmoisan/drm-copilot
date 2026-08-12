# Final Python Coverage Gate

Timestamp: `2026-08-11T16:18:57.3848958-04:00`

Command: `poetry run pytest -o addopts='' --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/python-coverage.2026-08-10T20-25.json`

EXIT_CODE: `0`

Output Summary: The coverage-enabled Pytest command completed successfully as the fourth command in one clean P6-T6 through P6-T9 pass. Every executed test passed.

## Test result

- Collected: `3,931`.
- Passed: `3,926`.
- Failed: `0`.
- Skipped: `5`.
- Pytest-reported time: `16.91 seconds`.
- Elapsed wall time: `19.4 seconds`.

## Repository coverage

| Metric | Covered / total | Percent |
| --- | ---: | ---: |
| Lines/statements | `14,289 / 15,505` | `92.16%` |
| Branches | `4,865 / 5,776` | `84.23%` |
| Combined line and branch opportunities | `19,154 / 21,281` | `90.01%` |

- Missing lines: `1,216`.
- Missing branches: `911`.
- Partial branches: `649`.
- Excluded lines: `428`.

Canonical JSON report: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/python-coverage.2026-08-10T20-25.json`.

JSON report SHA-256: `DDF0234DFD541DD889F38A27CF6214C1113DA6E10AC41ECBC50F6F40650B603E`.

## New and changed Python coverage

The changed-code calculation used added line ranges relative to baseline HEAD `fe0413d4aca1e76b2d02d05701fba79a887d5405` and every line in new `src/**` or `scripts/dev_tools/**` Python files, intersected with the final coverage JSON's executed and missing line records.

- Changed production Python files: `16`.
- Added or changed physical lines: `2,570`.
- Instrumented added or changed lines: `1,129`.
- Covered added or changed lines: `1,021`.
- Uncovered added or changed lines: `108`.
- New/changed-code line coverage: `90.43%`.
- Changed production files below the repository's `80%` line threshold: `0`.

## Restart history

Two prior coverage invocations are excluded from the accepted result:

1. The first invocation identified one stale migration-inventory classification for the two native parallel root agent contracts. The test classifier was corrected without changing production behavior.
2. The required restart passed that correction but detected the completed Python batch-budget receipt as transient `.codex/state` input. The sole receipt was verified to name only `tests/scripts/dev_tools/test_codex_full_migration_inventory.py`, then removed with the resulting empty state directory.
3. The complete Black, Ruff, Pyright, and coverage sequence was restarted. The results above are from that clean ordered pass.

## Output and policy verification

- `.coverage`: absent.
- Pre-existing tracked `coverage.xml`: clean and unchanged; the final command did not write it.
- Noncanonical new coverage reports: `0`.
- Changed Python files checked for size: `38`.
- Files above `500` physical lines: `0`; maximum: `499` lines.
- New Python suppression additions: `0`.
- `.claude` baseline/current files: `150 / 150`.
- `.claude` baseline/current manifest SHA-256: `34FE91AA14F9622BF4B9BF10E87BE787B95E992FFD69DFE09728937A779AA07C`.
- `.claude` missing, added, or mismatched files: `0 / 0 / 0`; tracked or untracked status paths: `0`.
- `.codex/state`: absent.
- `git diff --check`: exit `0`, no output.

`P6_T9_STATUS: COMPLETE`
