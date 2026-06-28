# Phase 7 QA Gate — check-powershell-test-purity.ps1 (Part 1 + Part 5 restructuring)

- Issue: #259
- Phase: 7 (Part 1 + Part 5)
- Timestamp: 2026-06-28T00-00

## Scope

Restructured runtime hook `.claude/hooks/check-powershell-test-purity.ps1` from a flat
inline script into pure functions plus orchestrator:
- pure `Get-PowerShellTestPurityBlockDecision` deny-builder returning the
  `[ordered]@{ hookSpecificOutput = [ordered]@{ ... permissionDecision='deny'; permissionDecisionReason } }` envelope;
- pure `Test-PowerShellTestFilePath` path detector;
- pure `Invoke-PowerShellTestPurityDecision` decision function (injectable `ToolInputRaw`);
- dot-sourcing guard `if ($MyInvocation.InvocationName -eq '.') { return }`;
- entrypoint emits via `ConvertTo-Json -Compress -Depth 5`.
Plain `@{}` block literal converted to `[ordered]@{}`. Behavior preserved: malformed/absent
input and non-test paths pass through with no decision and exit 0.
Bundled mirror replicated byte-identically. Test updated to dot-source and assert the new
deny shape via the pure functions and entrypoint.

## Command 1 — Format

- Timestamp: 2026-06-28T00-00
- Command: `mcp__drm-copilot__run_poshqc_format` (scan: `.claude/hooks`, `tests/scripts/claude-hooks`, mirror hooks)
- EXIT_CODE: 0
- Output Summary: ok:true. Runtime and mirror remained byte-identical after formatting (`cmp` BYTE-IDENTICAL).

## Command 2 — Analyze (PSScriptAnalyzer)

- Timestamp: 2026-06-28T00-00
- Command: `mcp__drm-copilot__run_poshqc_analyze`; corroborated by direct `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` on the three changed files
- EXIT_CODE: 0
- Output Summary: ok:true. ANALYZE_FINDINGS: 0 on the three changed files.

## Command 3 — Pester

- Timestamp: 2026-06-28T00-00
- Command: `mcp__drm-copilot__run_poshqc_test` (scan: `tests/scripts/claude-hooks`); corroborated by direct `Invoke-Pester` on `check-powershell-test-purity.Tests.ps1`
- EXIT_CODE: 0
- Output Summary: ok:true. PESTER Total=8 Passed=8 Failed=0 Skipped=0. Tests assert `hookEventName='PreToolUse'`, `permissionDecision='deny'`, deny-reason content for all 16 forbidden patterns, serialize-then-parse round-trip, and entrypoint emit/no-emit behavior.

## Command 4 — Bundle-parity pytest

- Timestamp: 2026-06-28T00-00
- Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
- EXIT_CODE: 0
- Output Summary: 7 passed. Runtime hook byte-identical to bundled mirror.

## Acceptance

- deny emitted in `hookSpecificOutput` shape; `[ordered]` used throughout; dot-sourcing guard present; exit always 0.
- Runtime hook 149 lines (<= 500); mirror byte-identical.
- Analyzer 0 findings on changed files; Pester 8/8 pass; parity pytest 7/7 pass.
