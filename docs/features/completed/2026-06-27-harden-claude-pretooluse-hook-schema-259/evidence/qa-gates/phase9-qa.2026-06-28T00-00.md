# Phase 9 QA Gate — enforce-evidence-locations.ps1 (Part 1 + Part 7 decision)

- Issue: #259
- Phase: 9 (Part 1 + Part 7)
- Timestamp: 2026-06-28T00-00

## Scope

Runtime hook `.claude/hooks/enforce-evidence-locations.ps1`, bundled mirror, and test
migrated to the PreToolUse `hookSpecificOutput` deny/allow schema. The int-returning
`Invoke-EvidenceLocationEntryPoint` pattern and its error-path `return 1` /
`exit (Invoke-EvidenceLocationEntryPoint)` are preserved; emission uses
`ConvertTo-Json -Compress -Depth 5`. Part-7 research-path migration resolved as an
out-of-scope no-op (see `evidence/other/part7-research-path-decision.2026-06-28T00-00.md`):
`artifacts/research/` is already in the forbidden-prefix list; no code change to that list.

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
- Command: `mcp__drm-copilot__run_poshqc_test`; corroborated by direct `Invoke-Pester` on `enforce-evidence-locations.Tests.ps1`
- EXIT_CODE: 0
- Output Summary: ok:true. PESTER Total=13 Passed=13 Failed=0 Skipped=0. Tests assert `hookEventName='PreToolUse'`, `permissionDecision='deny'`/`'allow'`, deny-reason token, entrypoint serialize-then-parse for both allow and deny, and the preserved exit-code-1 malformed-JSON path.

## Command 4 — Bundle-parity pytest

- Timestamp: 2026-06-28T00-00
- Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
- EXIT_CODE: 0
- Output Summary: 7 passed. Runtime hook byte-identical to bundled mirror.

## Acceptance

- deny/allow in `hookSpecificOutput` shape; error-path int-return and `exit 1` preserved; no deny-path `exit 1`.
- Runtime hook 180 lines (<= 500); mirror byte-identical.
- Analyzer 0 findings; Pester 13/13 pass; parity pytest 7/7 pass.
