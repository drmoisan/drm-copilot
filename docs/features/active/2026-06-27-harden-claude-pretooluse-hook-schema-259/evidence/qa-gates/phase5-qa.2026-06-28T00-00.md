# Phase 5 QA — check-python-test-purity.ps1

Timestamp: 2026-06-28T00-00

## Format
Command: mcp__drm-copilot__run_poshqc_format (scan: .claude/hooks, tests/scripts/claude-hooks, extensions/.../claude-customizations/.claude/hooks)
EXIT_CODE: 0
Output Summary: Format ran successfully (`ok:true`). Runtime and mirror byte-identical after formatting.

## Analyze (PSScriptAnalyzer)
Command: mcp__drm-copilot__run_poshqc_analyze (same scan folders)
EXIT_CODE: 0
Output Summary: 0 findings (`ok:true`) on changed files.

## Test (Pester)
Command: mcp__drm-copilot__run_poshqc_test (scan: tests/scripts/claude-hooks)
EXIT_CODE: 0
Output Summary: check-python-test-purity.Tests.ps1 — 9 tests, 0 failures, 0 errors. The
block literal in `Get-PythonTestPurityBlockDecision` now emits the `hookSpecificOutput`
deny shape; allow paths return `$null` (no decision, valid allow at PreToolUse); entrypoint
emits only on `permissionDecision='deny'` via `ConvertTo-Json -Compress -Depth 5`. Tests
assert deny shape on all forbidden patterns, malformed-JSON deny, serialize-then-parse
`Get-PythonTestPurityBlockDecision`, deny emission from the entrypoint, and no-output (allow)
emission on safe content.

## Bundle-parity pytest
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
EXIT_CODE: 0
Output Summary: 7 passed in 0.06s. Runtime and bundled mirror byte-identical (MIRROR_IDENTICAL).

## Line counts
- .claude/hooks/check-python-test-purity.ps1: 149 lines (<= 500)
- mirror: 149 lines (<= 500)
