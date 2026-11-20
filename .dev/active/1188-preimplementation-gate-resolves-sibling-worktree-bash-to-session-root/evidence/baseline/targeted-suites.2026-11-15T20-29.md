# Baseline: targeted suites (remediation cycle 2, P0-T1)

Timestamp: 2026-11-15T20-29
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1
EXIT_CODE: 0
Output Summary: Pester 5 tests, 0 failures, 0 errors (one shard, JUnit read). Launcher exit 75 (lock busy) occurred on the first retries and was re-run after the holder finished; recorded as a queue timeout.

Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_execution_environment_brief_contracts.py tests/scripts/dev_tools/test_bash_command_shape_surfaces.py
EXIT_CODE: 0
Output Summary: pytest 35 passed, 0 failed (pytest -n auto, 24 workers). Coverage not applicable: no production file changes.
