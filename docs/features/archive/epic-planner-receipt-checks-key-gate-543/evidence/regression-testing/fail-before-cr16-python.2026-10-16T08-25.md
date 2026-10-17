# Remediation Cycle 3 CR-16 Fail-Before (P1-T2, expect-fail)

Timestamp: 2026-10-16T08-25
Command: poetry run pytest --no-cov tests/scripts/dev_tools/test_typescript_twin_test_support.py -vv > SCRATCH/rc3/py-cr16-fail-before.txt; grep -e ' passed' -e ' failed' -e 'FileNotFoundError' SCRATCH/rc3/py-cr16-fail-before.txt
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Run on the pre-fix tests/scripts/dev_tools/typescript_twin_test_support.py (read_text called without an existence check).
- ========================= 1 failed, 1 passed in 0.15s =========================
- FAILED tests/scripts/dev_tools/test_typescript_twin_test_support.py::test_missing_twin_fails_with_clear_assertion - FileNotFoundError: [Errno 2] No such file or directory: '<worktree>\\extensions\\drm-copilot\\test\\lib\\validate\\no-such-twin.test.ts'
- ...\Lib\pathlib\_local.py:537: FileNotFoundError
- The failure is the pre-fix failure mode CR-16 reports: a missing twin raises FileNotFoundError instead of an AssertionError naming the twin. test_present_twin_reports_only_absent_literals passed.
- Host path prefix replaced with <worktree> in this record.
