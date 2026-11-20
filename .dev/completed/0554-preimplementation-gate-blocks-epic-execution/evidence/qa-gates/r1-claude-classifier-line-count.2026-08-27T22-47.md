# Remediation Cycle 1 — Claude Classifier Suite Line Count

Timestamp: 2026-08-28T00-15
Cycle Timestamp: 2026-08-27T22-47
Task: [P2-T6]
Command: `pwsh -NoProfile -Command "(@(Get-Content -LiteralPath 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1')).Count"`
EXIT_CODE: 0

## Measurement

| Measurement | Value |
| --- | --- |
| Line count of the new suite | **154** |
| Cap (`.claude/rules/general-code-change.md` line 49) | 500 |
| Headroom | **346** |

**154 is at or below 500. The cap is satisfied.**

## Both PowerShell test files written by this remediation

| File | Lines | Headroom |
| --- | --- | --- |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` (edited) | 302 | 198 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` (created) | 154 | 346 |

Both are under the cap. The named Claude-side edit target
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
remains at the 494 lines [P0-T8] measured and is byte-untouched by this remediation, which is a
stronger outcome than the directive required and is confirmed independently at [P3-T11].

Output Summary: The new Claude classifier suite stands at the integer **154** lines, 346 lines below
the 500-line cap. Exit code 0.
