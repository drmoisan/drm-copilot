# [P1-T2] Working-directory fix passes

Timestamp: 2026-11-07T01-40
Command: branch-current Invoke-PoshQCTest over tests/scripts/claude-lib/docs and tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 (`sh SCRATCH/issue-1031-pwsh.sh issue-1031-pester-gate.ps1 -Paths ... -NoCoverage`); counts from artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: tests 2172, failures 0, errors 0, skipped 0, suites 103, including the new case and the updated parameter pin.

## Digest pair

| File | SHA-256 |
|---|---|
| `LIB/Invoke-DocsCommand.ps1` | dbf4e716507760932890c7a6d60ff4416854969619c07a5f306b2528b339f89f |
| `MIRROR/Invoke-DocsCommand.ps1` | dbf4e716507760932890c7a6d60ff4416854969619c07a5f306b2528b339f89f |

## Stale wording

`git grep -c -e "forwards unchanged" -e "arguments unchanged" -e "callers run with" -e "non-closure" -- .claude/lib/docs/Invoke-DocsCommand.ps1` printed nothing (exit 1).
