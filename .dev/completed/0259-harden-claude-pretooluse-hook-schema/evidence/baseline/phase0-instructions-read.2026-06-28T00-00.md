# Phase 0 — Policy Instructions Read

Timestamp: 2026-06-28T00-00

Policy Order:
1. CLAUDE.md (standing instructions, always loaded)
2. .claude/rules/general-code-change.md (cross-language code change policy)
3. .claude/rules/general-unit-test.md (cross-language unit test policy)
4. .claude/rules/powershell.md (PowerShell toolchain and coding standards)
5. .claude/rules/quality-tiers.md (module rigor tiers and coverage thresholds)

Files Read (explicit list):
- C:\Users\DanMoisan\repos\drm-copilot\CLAUDE.md (loaded as project instructions)
- C:\Users\DanMoisan\repos\drm-copilot\.claude\rules\general-code-change.md
- C:\Users\DanMoisan\repos\drm-copilot\.claude\rules\general-unit-test.md
- C:\Users\DanMoisan\repos\drm-copilot\.claude\rules\powershell.md
- C:\Users\DanMoisan\repos\drm-copilot\.claude\rules\quality-tiers.md

Key constraints carried into execution:
- 500-line cap on every production/test/reusable script `.ps1`.
- PowerShell toolchain order: format -> analyze (PSScriptAnalyzer) -> Pester (v5). No type-check stage for PowerShell.
- Line coverage >= 85%, branch coverage >= 75% across all tiers; no regression on changed lines.
- Per-batch cap: at most 3 production `.ps1` and 3 test `.ps1`. A runtime hook + bundled mirror counts as 2 production files.
- Tone policy: professional, factual, neutral.
