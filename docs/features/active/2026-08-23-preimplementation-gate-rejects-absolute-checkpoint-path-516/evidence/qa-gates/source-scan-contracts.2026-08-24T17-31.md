# Source-Scan Contract Suites — Issue #516

Timestamp: 2026-08-24T17-31

Command: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1, tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 -CI"`

EXIT_CODE: 0

Output Summary:

- Discovery found 104 tests in 2 files.
- `Tests Passed: 104, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`. Completed in 4.99s.
- `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1` — 77 tests, all passing. Confirms the changed hooks contain no forbidden environment literals (`$env:CLAUDE_TOOL_INPUT`, `$env:CLAUDE_HOOK_INPUT`); this suite scans hook source text including comments, so the comment-based help added to `ConvertTo-WorkspaceRelativePath` is in scope of the scan and introduces no violation.
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` — 27 tests, all passing. Confirms no Python invocation was introduced into any enforcement hook by this change; `ConvertTo-WorkspaceRelativePath` is pure PowerShell string manipulation with no subprocess.

This satisfies spec Invariant 7 (Source-scan contracts).

The `-CI` flag rewrites the tracked repository-root artifact `testResults.xml`. It was restored with `git checkout -- testResults.xml` immediately after the run so the branch diff stays scoped to the fix; its contents are not treated as evidence.
