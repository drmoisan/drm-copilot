# Phase 10 QA Gate — enforce-feature-folder-order.ps1 (Part 1)

- Issue: #259
- Phase: 10 (Part 1)
- Timestamp: 2026-06-28T00-00

## Scope

Runtime hook `.claude/hooks/enforce-feature-folder-order.ps1`, bundled mirror, and test
migrated to the PreToolUse `hookSpecificOutput` deny/allow schema. The inline block literal
and the three allow literals in `Invoke-FeatureFolderOrderDecision` were replaced; emission
uses `ConvertTo-Json -Compress -Depth 5`; the error-path `exit 1` (malformed-JSON catch
block) is retained; `Get-FeatureFolderFileExistence` seam unchanged.

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
- Command: `mcp__drm-copilot__run_poshqc_test`; corroborated by direct `Invoke-Pester` on `enforce-feature-folder-order.Tests.ps1` and on the full `tests/scripts/claude-hooks` suite
- EXIT_CODE: 0
- Output Summary: ok:true. enforce-feature-folder-order PESTER Total=20 Passed=20 Failed=0 Skipped=0. Full claude-hooks suite PESTER Total=364 Passed=364 Failed=0 Skipped=0 (no cross-hook regression across phases 6-10). Tests assert `hookEventName='PreToolUse'`, `permissionDecision='deny'`/`'allow'`, deny-reason content, serialize-then-parse envelope, and entrypoint emission for both allow and deny.

## Command 4 — Bundle-parity pytest

- Timestamp: 2026-06-28T00-00
- Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
- EXIT_CODE: 0
- Output Summary: 7 passed. Runtime hook byte-identical to bundled mirror.

## Acceptance

- deny/allow in `hookSpecificOutput` shape; error-path `exit 1` retained; no deny-path `exit 1`.
- Runtime hook 152 lines (<= 500); mirror byte-identical.
- Analyzer 0 findings; per-hook Pester 20/20 pass; full suite 364/364 pass; parity pytest 7/7 pass.
