# Phase 8 QA Gate — enforce-powershell-batch-budget.ps1 (Part 1 + Part 5 confirmation)

- Issue: #259
- Phase: 8 (Part 1 + Part 5)
- Timestamp: 2026-06-28T00-00

## Scope

Runtime hook `.claude/hooks/enforce-powershell-batch-budget.ps1`, bundled mirror, and test
migrated to the PreToolUse `hookSpecificOutput` deny/allow schema. Sibling keys
`state`/`shouldWriteState` preserved on allow objects; `state` stripped before stdout
emission on deny; entrypoint gate uses `permissionDecision -eq 'deny'`; emission uses
`ConvertTo-Json -Compress -Depth 5`. Part-5 registration confirmed (see
`evidence/other/pwsh-batch-budget-registration.2026-06-28T00-00.md`): hook registered at
`.claude/settings.json` line 110 under the `Write|Edit` matcher; settings.json mirror
byte-identical.

## Command 1 — Format

- Timestamp: 2026-06-28T00-00
- Command: `mcp__drm-copilot__run_poshqc_format`
- EXIT_CODE: 0
- Output Summary: ok:true. Runtime and mirror byte-identical after formatting (`cmp` BYTE-IDENTICAL).

## Command 2 — Analyze (PSScriptAnalyzer)

- Timestamp: 2026-06-28T00-00
- Command: `mcp__drm-copilot__run_poshqc_analyze`; corroborated by direct `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` on the three changed files
- EXIT_CODE: 0
- Output Summary: ok:true. ANALYZE_FINDINGS: 0 on the three changed files.

## Command 3 — Pester

- Timestamp: 2026-06-28T00-00
- Command: `mcp__drm-copilot__run_poshqc_test`; corroborated by direct `Invoke-Pester` on `enforce-powershell-batch-budget.Tests.ps1`
- EXIT_CODE: 0
- Output Summary: ok:true. PESTER Total=15 Passed=15 Failed=0 Skipped=0. Tests assert `hookEventName='PreToolUse'`, `permissionDecision='deny'`, deny-reason content, serialize-then-parse envelope, preserved `state`/`shouldWriteState`, and that the emitted deny JSON strips `state`.

## Command 4 — Bundle-parity pytest

- Timestamp: 2026-06-28T00-00
- Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
- EXIT_CODE: 0
- Output Summary: 7 passed. Runtime hook byte-identical to bundled mirror.

## Acceptance

- deny/allow in `hookSpecificOutput` shape; `state`/`shouldWriteState` preserved on allow; `state` stripped before emission on deny; exit always 0.
- Runtime hook 241 lines (<= 500); mirror byte-identical.
- Analyzer 0 findings; Pester 15/15 pass; parity pytest 7/7 pass.
