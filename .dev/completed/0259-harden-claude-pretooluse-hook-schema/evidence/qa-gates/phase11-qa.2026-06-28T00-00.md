# Phase 11 QA — enforce-checkpoint-monotonic.ps1 (Part 1 + Part 4 prerequisite gate)

Issue: #259

## Command 1 — PoshQC format

- Timestamp: 2026-06-28T00-00
- Command: `mcp__drm-copilot__run_poshqc_format` (scan folders: `.claude/hooks`, `tests/scripts/claude-hooks`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks`)
- EXIT_CODE: 0
- Output Summary: ok:true. Format pass. Runtime and mirror remained byte-identical after format (diff confirmed BYTE_IDENTICAL).

## Command 2 — PSScriptAnalyzer

- Timestamp: 2026-06-28T00-00
- Command: `mcp__drm-copilot__run_poshqc_analyze` (same scan folders)
- EXIT_CODE: 0
- Output Summary: ok:true. 0 analyzer findings on changed files (`enforce-checkpoint-monotonic.ps1` runtime + mirror, `enforce-checkpoint-monotonic.Tests.ps1`).

## Command 3 — Pester

- Timestamp: 2026-06-28T00-00
- Command: `Invoke-Pester -Path tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1 -Output Detailed` (also `mcp__drm-copilot__run_poshqc_test` over `tests/scripts/claude-hooks`)
- EXIT_CODE: 0
- Output Summary: Tests Passed: 23, Failed: 0, Skipped: 0. Includes the new negative prerequisite-gate test (serialize-then-parse, deny reason names S3_promotion and S4_atomic_planning) and the positive in-order allow fixture now containing S3_promotion and S4_atomic_planning.

## Command 4 — Bundle-parity pytest

- Timestamp: 2026-06-28T00-00
- Command: `python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
- EXIT_CODE: 0
- Output Summary: 7 passed in 0.06s. Runtime `.claude/**` hooks byte-identical to bundled mirrors.

## Schema-shape confirmation

- Both deny sites (order-violation and missing-prerequisite) emit `hookSpecificOutput.permissionDecision='deny'` with `hookEventName='PreToolUse'`.
- All allow paths emit `hookSpecificOutput.permissionDecision='allow'`.
- Entrypoint emission uses `ConvertTo-Json -Compress -Depth 5`.
- Error-path `exit 1` retained; no deny-path `exit 1`.
- `Test-StepHasPrefix`, `Get-MissingPrerequisiteForAdvancedStep`, `ConvertFrom-CheckpointJson` unchanged.
- File line counts: runtime and mirror 311 lines each; test 172 lines (all <= 500).
