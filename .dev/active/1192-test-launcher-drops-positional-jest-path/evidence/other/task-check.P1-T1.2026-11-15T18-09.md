# Task check P1-T1

Timestamp: 2026-11-15T18-09
Command: format-compare and PSScriptAnalyzer over the changed file (`sh SCRATCH/issue-1192-static2.sh`), then the launcher `pester` suite with `-TestPath` over the two edited test files (the P1-T4 run).
EXIT_CODE: 0 for format and analyze; 1 for the test selection, which is the expected fail-before outcome of an `[expect-fail]` task.
Output Summary:
- Changed file: `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1`.
- Selection rule: the mirrored test file of the changed path plus any test naming it; here the changed file is itself the test, and `Invoke-TestSuite.Tests.ps1` dot-sources the same helper.
- Format drift 0, analyzer findings 0.
- The updated jest case and the two new jest cases fail against the unmodified builder, in both hook copies (see regression-testing fail-before artifact).
