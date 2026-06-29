# Phase 6 QA Gate — enforce-python-batch-budget.ps1

- Issue: #259
- Phase: 6 (Part 1)
- Timestamp: 2026-06-28T00-00

## Scope

Runtime hook `.claude/hooks/enforce-python-batch-budget.ps1`, its bundled mirror
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`,
and test `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` migrated to the
PreToolUse `hookSpecificOutput` deny/allow schema. Sibling keys `state`/`shouldWriteState`
preserved on allow objects; `state` key stripped before stdout emission on deny.

## Command 1 — Format

- Timestamp: 2026-06-28T00-00
- Command: `mcp__drm-copilot__run_poshqc_format` (scan: `.claude/hooks`, `tests/scripts/claude-hooks`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks`)
- EXIT_CODE: 0
- Output Summary: ok:true. No file divergence introduced; runtime and mirror remained byte-identical after formatting (`cmp` BYTE-IDENTICAL).

## Command 2 — Analyze (PSScriptAnalyzer)

- Timestamp: 2026-06-28T00-00
- Command: `mcp__drm-copilot__run_poshqc_analyze`; corroborated by direct `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` on the three changed files
- EXIT_CODE: 0
- Output Summary: ok:true. ANALYZE_FINDINGS: 0 on the three changed files (runtime hook, mirror hook, test).

## Command 3 — Pester

- Timestamp: 2026-06-28T00-00
- Command: `mcp__drm-copilot__run_poshqc_test` (scan: `tests/scripts/claude-hooks`); corroborated by direct `Invoke-Pester` on `enforce-python-batch-budget.Tests.ps1`
- EXIT_CODE: 0
- Output Summary: ok:true. PESTER Total=14 Passed=14 Failed=0 Skipped=0. Tests assert `hookEventName='PreToolUse'`, `permissionDecision='deny'`, deny-reason content, serialize-then-parse envelope, preserved `state`/`shouldWriteState`, and that the emitted deny JSON strips `state`.

## Command 4 — Bundle-parity pytest

- Timestamp: 2026-06-28T00-00
- Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
- EXIT_CODE: 0
- Output Summary: 7 passed. Runtime hook byte-identical to bundled mirror.

## Acceptance

- deny/allow emitted in `hookSpecificOutput` shape with `state`/`shouldWriteState` preserved on allow objects; `state` stripped before emission on deny.
- Entrypoint exit always 0; decision-gate comparison uses `$decision.hookSpecificOutput.permissionDecision -eq 'deny'`; emission uses `ConvertTo-Json -Compress -Depth 5`.
- Runtime hook 238 lines (<= 500); mirror byte-identical.
- Analyzer 0 findings on changed files; Pester 14/14 pass; parity pytest 7/7 pass.
