# Final QA Gate: no python invocation (issue #491, [P7-T10])

Timestamp: 2026-08-20T11-45

Command: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 -Output Detailed"`
EXIT_CODE: 0
Output Summary: Tests Passed: 27, Failed: 0, Skipped: 0. The two headline cases both pass: "reports no Python invocation beyond the allowlist across the guarded tree" and "carries no stale allowlist entry". The guarded tree covers .claude/hooks and .claude/lib (excluding lib/bash), so the new hook and all four new library modules are in scope. No allowlist entry was added for this feature. AC-23.
