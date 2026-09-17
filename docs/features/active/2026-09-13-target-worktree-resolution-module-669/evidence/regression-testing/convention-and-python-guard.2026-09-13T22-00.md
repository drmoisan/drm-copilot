# Convention and Python-Invocation Guard Suites

Timestamp: 2026-09-17T08:24:03-04:00
Command: $r = Invoke-Pester -Path 'tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1','tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1' -PassThru
EXIT_CODE: 0
Output Summary: PassedCount=33, FailedCount=0, SkippedCount=0. Both suites discover files from disk, so the two new modules under .claude/lib/worktree-resolution/ are inside their scan scope: all six ClaudeLibModuleConvention tests pass (fail-fast guard, sibling-import guard, convention sentence, caller preference, 500-line limit), and the Python guard's repository scan reports no invocation beyond its empty allowlist.

## Counts

- PassedCount: 33
- FailedCount: 0
- SkippedCount: 0

## Passed tests (full names, verbatim)

```text
Claude library module conventions.discovers the claude library modules on disk
Claude library module conventions.sets the fail-fast error preference at module scope in every discovered module
Claude library module conventions.guards every load-time sibling import with an explicit stop preference
Claude library module conventions.states the fail-fast convention in the module help block
Claude library module conventions.leaves the caller error preference unchanged after import
Claude library module conventions.keeps every claude library module within the five hundred line limit
enforcement hooks must not invoke Python.allowlist policy.ships an empty allowlist
enforcement hooks must not invoke Python.detection class 1 - constant interpreter command.detects a bare python invocation
enforcement hooks must not invoke Python.detection class 1 - constant interpreter command.detects an ampersand-invoked python invocation
enforcement hooks must not invoke Python.detection class 1 - constant interpreter command.detects a dot-invoked python invocation
enforcement hooks must not invoke Python.detection class 1 - constant interpreter command.detects a quoted python constant invocation
enforcement hooks must not invoke Python.detection class 1 - constant interpreter command.detects python3, py, and poetry as interpreter commands
enforcement hooks must not invoke Python.detection class 1 - constant interpreter command.detects an interpreter name written in mixed case
enforcement hooks must not invoke Python.detection class 2 - subprocess start targeting an interpreter.detects a subprocess start whose FilePath is an interpreter
enforcement hooks must not invoke Python.detection class 2 - subprocess start targeting an interpreter.detects a subprocess start whose first positional argument is an interpreter
enforcement hooks must not invoke Python.detection class 2 - subprocess start targeting an interpreter.reports no finding for a subprocess start targeting an unrelated executable
enforcement hooks must not invoke Python.detection class 3 - dynamic invocation fail-closed.detects an ampersand-invoked variable that is not a scriptblock parameter
enforcement hooks must not invoke Python.detection class 3 - dynamic invocation fail-closed.detects an ampersand-invoked expression in the command position
enforcement hooks must not invoke Python.detection class 4 - arbitrary text execution.detects an Invoke-Expression call
enforcement hooks must not invoke Python.detection class 4 - arbitrary text execution.detects the built-in alias of Invoke-Expression
enforcement hooks must not invoke Python.non-detection - constructs that must never be reported.reports no finding for interpreter names inside string literals
enforcement hooks must not invoke Python.non-detection - constructs that must never be reported.reports no finding for interpreter names inside comments
enforcement hooks must not invoke Python.non-detection - constructs that must never be reported.reports no finding for function names beginning with Invoke-Python
enforcement hooks must not invoke Python.non-detection - constructs that must never be reported.reports no finding for a scriptblock-parameter seam invocation
enforcement hooks must not invoke Python.non-detection - constructs that must never be reported.reports no finding when a seam variable differs from its parameter by letter case
enforcement hooks must not invoke Python.non-detection - constructs that must never be reported.reports no finding for dot-sourcing a sibling helper path variable
enforcement hooks must not invoke Python.non-detection - constructs that must never be reported.reports no finding for dot-sourcing an inline sibling helper path
enforcement hooks must not invoke Python.carve-out boundaries - the inline sibling-load exemption stays tight.still reports a dot-sourced expression that is not a Join-Path call
enforcement hooks must not invoke Python.carve-out boundaries - the inline sibling-load exemption stays tight.still reports a Join-Path load that does not resolve a ps1 sibling
enforcement hooks must not invoke Python.carve-out boundaries - the inline sibling-load exemption stays tight.still reports an ampersand-invoked inline sibling-load expression
enforcement hooks must not invoke Python.repository scan.enumerates only the two guarded roots and never the bundled mirror
enforcement hooks must not invoke Python.repository scan.reports no Python invocation beyond the allowlist across the guarded tree
enforcement hooks must not invoke Python.repository scan.carries no stale allowlist entry
```
