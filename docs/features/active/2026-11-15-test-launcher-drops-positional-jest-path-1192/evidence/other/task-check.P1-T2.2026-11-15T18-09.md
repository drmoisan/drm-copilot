# Task check P1-T2

Timestamp: 2026-11-15T18-09
Command: format-compare and PSScriptAnalyzer over the changed file (`sh SCRATCH/issue-1192-static2.sh`), then the launcher `pester` suite with `-TestPath` over the two edited test files (the P1-T4 run).
EXIT_CODE: 0 for format and analyze; 1 for the test selection, which is the expected fail-before outcome of an `[expect-fail]` task.
Output Summary:
- Changed file: `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1`.
- Selection rule: as P1-T1.
- Format drift 0, analyzer findings 0.
- The pester `-TestPath` ordering case fails against the unmodified builder (both copies); the no-extras cases for jest and pester and the ordering cases for pytest, dotnet-test, and bats pass before the fix.
