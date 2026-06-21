# Phase 0 — Instructions Read Evidence

- Timestamp: 2026-06-21T12-06
- Issue: #221
- Task: [P0-T1]

## Policy Order

Policy files read in the required order:

1. `CLAUDE.md` — repository tone and communication policy, policy-compliance reading order, architecture.
2. `.claude/rules/general-code-change.md` — cross-language code change policy (design principles, toolchain loop, file size limit, error handling).
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy (core principles, coverage requirements, scenario completeness, mocking).
4. `.claude/rules/powershell.md` — PowerShell toolchain (PoshQC format -> analyze -> Pester test; type-check not applicable), coding standards, wrapper-seam mocking rules, coverage thresholds.
5. `.claude/rules/quality-tiers.md` — T1–T4 module rigor tiers and the uniform coverage thresholds (line >= 85%, branch >= 75%).
6. `.claude/rules/tonality.md` — required professional tone policy.

## Files Read

- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-21-12-02\CLAUDE.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-21-12-02\.claude\rules\general-code-change.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-21-12-02\.claude\rules\general-unit-test.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-21-12-02\.claude\rules\powershell.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-21-12-02\.claude\rules\quality-tiers.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-21-12-02\.claude\rules\tonality.md

## Output Summary

All six policy files read in the required order. Language in scope is PowerShell only; type-checking is not applicable. Toolchain loop is PoshQC format -> analyze -> Pester test. Coverage thresholds: line >= 85%, branch >= 75%. Wrapper-seam isolation (Invoke-GitExe / Invoke-NpmExe / Invoke-GhExe) must be preserved; mock the wrapper, never the executable.
