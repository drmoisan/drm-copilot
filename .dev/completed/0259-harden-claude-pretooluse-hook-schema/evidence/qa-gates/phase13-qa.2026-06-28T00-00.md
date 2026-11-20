# Phase 13 QA — enforce-prd-feature-before-planner.ps1 (Part 1; two block sites)

Issue: #259

## Command 1 — PoshQC format

- Timestamp: 2026-06-28T00-00
- Command: `mcp__drm-copilot__run_poshqc_format` (scan folders: `.claude/hooks`, `tests/scripts/claude-hooks`, mirror hooks)
- EXIT_CODE: 0
- Output Summary: ok:true. Format pass. Runtime/mirror confirmed byte-identical after format.

## Command 2 — PSScriptAnalyzer

- Timestamp: 2026-06-28T00-00
- Command: `mcp__drm-copilot__run_poshqc_analyze` (same scan folders)
- EXIT_CODE: 0
- Output Summary: ok:true. 0 analyzer findings on changed files (`enforce-prd-feature-before-planner.ps1` runtime + mirror, test).

## Command 3 — Pester

- Timestamp: 2026-06-28T00-00
- Command: `Invoke-Pester -Path tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 -Output Detailed`
- EXIT_CODE: 0
- Output Summary: Tests Passed: 20, Failed: 0, Skipped: 0. Both deny paths (no-folder and missing spec.md/user-story.md) assert `hookSpecificOutput.permissionDecision='deny'`; entrypoint regex asserts `"permissionDecision":"deny"`/`"allow"`.

## Command 4 — Bundle-parity pytest

- Timestamp: 2026-06-28T00-00
- Command: `python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
- EXIT_CODE: 0
- Output Summary: 7 passed. Runtime `.claude/**` hooks byte-identical to bundled mirrors.

## Schema-shape confirmation

- Both deny sites (no-folder and missing-files) emit `hookSpecificOutput.permissionDecision='deny'` with `hookEventName='PreToolUse'`.
- All allow paths emit `hookSpecificOutput.permissionDecision='allow'`.
- Entrypoint emission uses `ConvertTo-Json -Compress -Depth 5`. Error-path `exit 1` retained; no deny-path `exit 1`.
- `Get-PrdFeatureFileExistence` / `Get-PrdFeatureCheckpointFolder` unchanged.
- Line counts: runtime/mirror 224 each; test 163 (all <= 500).
