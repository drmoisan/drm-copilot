# Task check P1-T1 (issue #1157, cycle 1)

Timestamp: 2026-11-13T14-45
Command: sh SCRATCH/issue-1157-static.sh -File tests/scripts/claude-hooks/enforce-owner-directive-pass-down.Tests.ps1; sh SCRATCH/issue-1157-taskcheck.sh -Path tests/scripts/claude-hooks/enforce-owner-directive-pass-down.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Changed files: tests/scripts/claude-hooks/enforce-owner-directive-pass-down.Tests.ps1.
- Selection rule: the changed test file itself (a changed test file is its own selection).
- Format (Invoke-Formatter, check-only): drift 0, EXIT_CODE 0. Lint (Invoke-ScriptAnalyzer): 0 findings, EXIT_CODE 0. Type check: not applicable.
- Pester: 83 tests, 81 passed, 2 failed (the two [expect-fail] rows of this task); EXIT_CODE 1, as expected. Fail-before evidence: evidence/regression-testing/fail-before.F3.2026-11-13T14-45.md.
