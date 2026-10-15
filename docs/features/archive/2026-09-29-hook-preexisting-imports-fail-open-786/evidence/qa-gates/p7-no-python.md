# No-Python Guard ([P7-T7])

Timestamp: 2026-10-10T00-17
Command: R-SCOPED over tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 (scans .claude/hooks and, through tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1, .codex/hooks)
EXIT_CODE: 0
Output Summary: PassedCount 32, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0. No hook edited in Phases 5 to 7 invokes Python.

```text

Starting discovery in 1 files.
Discovery found 32 tests in 137ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1 3.47s (3.03s|322ms)
Tests completed in 3.48s
Tests Passed: 32, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 32
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | result=Passed | passed=32 | failed=0
PASSED: ships an empty allowlist
PASSED: detects a bare python invocation
PASSED: detects an ampersand-invoked python invocation
PASSED: detects a dot-invoked python invocation
PASSED: detects a quoted python constant invocation
PASSED: detects python3, py, and poetry as interpreter commands
PASSED: detects an interpreter name written in mixed case
PASSED: detects a subprocess start whose FilePath is an interpreter
PASSED: detects a subprocess start whose first positional argument is an interpreter
PASSED: reports no finding for a subprocess start targeting an unrelated executable
PASSED: detects an ampersand-invoked variable that is not a scriptblock parameter
PASSED: detects an ampersand-invoked expression in the command position
PASSED: detects an Invoke-Expression call
PASSED: detects the built-in alias of Invoke-Expression
PASSED: reports no finding for interpreter names inside string literals
PASSED: reports no finding for interpreter names inside comments
PASSED: reports no finding for function names beginning with Invoke-Python
PASSED: reports no finding for a scriptblock-parameter seam invocation
PASSED: reports no finding when a seam variable differs from its parameter by letter case
PASSED: reports no finding for dot-sourcing a sibling helper path variable
PASSED: reports no finding for dot-sourcing an inline sibling helper path
PASSED: still reports a dot-sourced expression that is not a Join-Path call
PASSED: still reports a Join-Path load that does not resolve a ps1 sibling
PASSED: still reports an ampersand-invoked inline sibling-load expression
PASSED: enumerates only the guarded roots and never the bundled mirror
PASSED: reports no Python invocation beyond the allowlist across the guarded tree
PASSED: carries no stale allowlist entry
PASSED: AC-15 claude hooks path is under a scan root
PASSED: AC-15 codex hooks path is under a scan root
PASSED: AC-15 bundled mirror path is outside every scan root
PASSED: AC-15 unrelated path is outside every scan root
PASSED: AC-15 enumeration includes at least one codex hooks file
```
