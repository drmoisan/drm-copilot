Timestamp: 2026-09-27T16-00

Edit: replaced `@($files).Count | Should -BeGreaterThan 0` with
`@($files | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0` at the same indentation
and same line position in
`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (the file at the
500-line ceiling — same-line, zero-line-delta edit).

Command: sh <scratchpad>/run-ps.sh <scratchpad>/select-string-count.ps1 -Path tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 -Pattern '@($files).Count | Should -BeGreaterThan 0'
EXIT_CODE: 0
Output: 0

Command: sh <scratchpad>/run-ps.sh <scratchpad>/select-string-count.ps1 -Path tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 -Pattern '@($files | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0'
EXIT_CODE: 0
Output: 1

Command: sh <scratchpad>/run-ps.sh <scratchpad>/line-counts.ps1 tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1
EXIT_CODE: 0
Output: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 LineCount=500

Output Summary: old-literal count 0, new-literal count 1, line count 500 equals the P0-T17 baseline exactly (net-zero delta, zero-headroom constraint satisfied). AC-2's edit is complete and verified.
