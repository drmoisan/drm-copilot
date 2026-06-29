# Phase 1 QA — validate-bash.ps1

Timestamp: 2026-06-28T00-00

## Format
Command: mcp__drm-copilot__run_poshqc_format (scan: .claude/hooks, tests/scripts/claude-hooks, extensions/.../claude-customizations/.claude/hooks)
EXIT_CODE: 0
Output Summary: Format ran successfully (`ok:true`). Runtime and mirror remain byte-identical after formatting.

## Analyze (PSScriptAnalyzer)
Command: mcp__drm-copilot__run_poshqc_analyze (same scan folders)
EXIT_CODE: 0
Output Summary: 0 findings. An initial run reported 2 findings (PSUseOutputTypeCorrectly on
`Get-BlockedBashPattern` in runtime + mirror); resolved by casting the return value to
`[string[]]`. Re-run is clean (`ok:true`).

## Test (Pester)
Command: mcp__drm-copilot__run_poshqc_test (scan: tests/scripts/claude-hooks)
EXIT_CODE: 0
Output Summary: validate-bash.Tests.ps1 — 13 tests, 0 failures, 0 errors. Asserts
`Get-BlockedPatternMatch`/`Get-BashBlockReason` return the matched pattern on blocked
commands and `$null` otherwise; `Get-BashDenyDecision` serialize-then-parse yields
`hookSpecificOutput.hookEventName='PreToolUse'` and `permissionDecision='deny'`; the hook
source contains no deny-path `exit 1` statement. Two initial test-fixture defects (expected
pattern for `git push origin --force`; comment-embedded `exit 1` mention) were corrected;
re-run passes.

## Bundle-parity pytest
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
EXIT_CODE: 0
Output Summary: 7 passed in 0.06s. Runtime `.claude/hooks/validate-bash.ps1` and bundled
mirror are byte-identical (MIRROR_IDENTICAL).

## Line counts
- .claude/hooks/validate-bash.ps1: 179 lines (<= 500)
- mirror validate-bash.ps1: 179 lines (<= 500)
- tests/scripts/claude-hooks/validate-bash.Tests.ps1: <= 500 lines
