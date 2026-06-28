# Phase 2 QA — enforce-promotion-mcp-only.ps1

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
Output Summary: enforce-promotion-mcp-only.Tests.ps1 — 25 tests, 0 failures, 0 errors. Asserts
`hookSpecificOutput.hookEventName='PreToolUse'` and `permissionDecision='deny'` on all block
paths and `permissionDecision='allow'` on allow paths, including serialize-then-parse on
`Get-PromotionMcpOnlyBlockDecision` / `Get-PromotionMcpOnlyAllowDecision` and end-to-end
entrypoint emission. Malformed-JSON error path still exits 1.

## Bundle-parity pytest
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
EXIT_CODE: 0
Output Summary: 7 passed in 0.06s. Runtime and bundled mirror byte-identical (MIRROR_IDENTICAL).

## Line counts
- .claude/hooks/enforce-promotion-mcp-only.ps1: 238 lines (<= 500)
- mirror: 238 lines (<= 500)
