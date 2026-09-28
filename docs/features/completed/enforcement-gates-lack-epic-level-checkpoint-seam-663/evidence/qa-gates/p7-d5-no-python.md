# D5 Authority Lines and No-Python Check ([P7-T7], AC-23)

Timestamp: 2026-09-25T19-51
Command: sh <SCRATCHPAD>/i663/run.sh p7-lines  (`@(Select-String -SimpleMatch -Pattern 'PowerShell-authoritative' -LiteralPath <module>).Count` per module); sh <SCRATCHPAD>/i663/run.sh p7-t7  (R-SCOPED, Run.Path tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1)
EXIT_CODE: 0
Output Summary: `PowerShell-authoritative` occurs once in each module (EpicScopeResolution.psm1: 1; EpicScopeReadiness.psm1: 1). R-SCOPED: PassedCount 27, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0; `PASSED: reports no Python invocation beyond the allowlist across the guarded tree` is present.

## Authority-line counts

```
AUTHORITY_COUNT .claude/lib/worktree-resolution/EpicScopeResolution.psm1: 1
AUTHORITY_COUNT .claude/lib/worktree-resolution/EpicScopeReadiness.psm1: 1
```

## R-SCOPED output

```
Resolved Run.Path:
  tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1

Starting discovery in 1 files.
Discovery found 27 tests in 144ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1
 2.07s (1.62s|321ms)
Tests completed in 2.08s
Tests Passed: 27, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
PassedCount: 27
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
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
PASSED: enumerates only the two guarded roots and never the bundled mirror
PASSED: reports no Python invocation beyond the allowlist across the guarded tree
PASSED: carries no stale allowlist entry
RSCOPED_EXIT_CODE: 0
PROCESS_EXIT_CODE: 0
```

Result: PASS
