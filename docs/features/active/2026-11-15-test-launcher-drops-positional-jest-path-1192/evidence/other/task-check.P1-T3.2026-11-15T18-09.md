# Task check P1-T3

Timestamp: 2026-11-15T18-09
Command: format-compare and PSScriptAnalyzer over the changed file (`sh SCRATCH/issue-1192-static2.sh`), then the launcher `pester` suite with `-TestPath` over the two edited test files (the P1-T4 run).
EXIT_CODE: 0 for format and analyze; 1 for the test selection, which is the expected fail-before outcome of an `[expect-fail]` task.
Output Summary:
- Changed file: `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1`.
- Selection rule: the changed file is itself the mirrored test of `Invoke-TestSuite.ps1`.
- Format drift 0, analyzer findings 0.
- The jest-extension ordering case fails against the unmodified builder; the jest-extension refusal case passes (shard 2: Passed 38, Failed 1).
