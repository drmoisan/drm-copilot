# Phase 0 — Policy Instructions Read

Timestamp: 2026-06-24T17-40

Policy Order:
1. CLAUDE.md (standing instructions, always loaded)
2. .claude/rules/general-code-change.md (cross-language code change policy)
3. .claude/rules/general-unit-test.md (cross-language unit test policy)
4. .claude/rules/powershell.md (PowerShell-specific toolchain and coding standards)
5. .claude/rules/quality-tiers.md (module rigor tiers and coverage thresholds)

Files Read (explicit list):
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-24-13-02\CLAUDE.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-24-13-02\.claude\rules\general-code-change.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-24-13-02\.claude\rules\general-unit-test.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-24-13-02\.claude\rules\powershell.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-24-13-02\.claude\rules\quality-tiers.md

Also read for execution context (not part of the required-order list but governing this feature):
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-24-13-02\.claude\rules\self-explanatory-code-commenting.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-24-13-02\.claude\skills\orchestrate\SKILL.md (Step S9 + Checkpoint Schema sections)

Key constraints recorded for this feature:
- PowerShell toolchain order: format -> analyze -> Pester (type-check skipped); restart on any failure or auto-fix.
- Coverage: line >= 85%, branch >= 75% uniform across tiers; no regression on changed lines.
- Advanced functions with CmdletBinding and validation; approved verbs; avoid global/script-scoped mutable state; no Invoke-Expression; under 500 lines.
- No temporary files in tests; deterministic tests (no network, no live executables, no wall-clock reads).
- Evidence only under docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/<kind>/.
