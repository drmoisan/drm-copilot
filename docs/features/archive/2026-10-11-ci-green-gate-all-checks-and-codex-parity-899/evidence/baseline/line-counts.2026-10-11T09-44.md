# Baseline Line Counts (P0-T5)

Timestamp: 2026-10-12T16-17
Task: P0-T5
Command: git grep -c "" -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1
EXIT_CODE: 0

Output:
```
.claude/lib/ci-gate/Invoke-CiGateParser.ps1:401
tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1:410
```

Output Summary: `.claude/lib/ci-gate/Invoke-CiGateParser.ps1:401` and `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1:410`; both are at or below 500. P2-T11 compares the parser count against 401.
