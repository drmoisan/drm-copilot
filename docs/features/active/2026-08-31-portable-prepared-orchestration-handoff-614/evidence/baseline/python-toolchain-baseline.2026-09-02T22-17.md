# Python Toolchain Baseline

Timestamp: 2026-09-03T02-53
Command: `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/python-baseline.2026-09-02T22-17.json`
ExpectedExitCode: 1
EXIT_CODE: 1

Output Summary: The repository collected 4,387 tests and completed with 4,380 passed, 2 failed, and 5 skipped in 21.51 seconds. The only failures were the two parameterized TaskMaster #469 raw plan-byte hash assertions. Both expected `54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f` and observed `089467fcb70ebc8b3fd999b1426d41dfbf40016c062d560e76948558b3927864`. Coverage JSON was written to the declared canonical evidence path.

LINE_COVERAGE: 92.86076591427847%
BRANCH_COVERAGE: 85.41811846689896%
LINE_COVERED: 14646
LINE_TOTAL: 15772
BRANCH_COVERED: 4903
BRANCH_TOTAL: 5740

## Failure signatures

- `test_taskmaster_469_fixture_hashes_and_source_history_are_pinned[claude-to-codex]` failed at `tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py:77` because actual `089467...7864` did not equal expected `54c971...ba2f`.
- `test_taskmaster_469_fixture_hashes_and_source_history_are_pinned[codex-to-claude]` failed at the same raw-byte assertion for the same actual and expected values.
- Pytest summary: `2 failed, 4380 passed, 5 skipped in 21.51s`.

Post-command raw-byte verification: `git diff --quiet HEAD -- <both plan fixture paths>` returned `0`; each fixture still hashes to `089467fcb70ebc8b3fd999b1426d41dfbf40016c062d560e76948558b3927864`. No fixture hydration or newline rewrite occurred.
