# Baseline — enforcement-hooks-no-python-invocation suite, issue #491

Timestamp: 2026-08-19T10-30

Command: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 -Output Detailed"`

EXIT_CODE: 0

Output Summary: `Tests Passed: 27, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0` in 2.05s.
The `Context repository scan` cases confirm the suite recursively scans `.claude/hooks` and
`.claude/lib` (excluding `lib/bash`) and reports no Python invocation beyond the allowlist. Baseline
green. This suite is the hard gate against a Python leg in the new hook or library (AC-23).
