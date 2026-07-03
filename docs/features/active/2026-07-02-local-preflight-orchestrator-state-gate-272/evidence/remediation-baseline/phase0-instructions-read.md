## Phase 0 Policy Read — Remediation Cycle 1 (Issue #272)

**Timestamp:** 2026-07-02T20-30
**Policy Order:**
1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/remediation-inputs.2026-07-02T20-15.md`
6. `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/policy-audit.2026-07-02T20-15.md` (Section 5 "Test Coverage Detail", Section 8 "Gaps and Exceptions")
7. `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/code-review.2026-07-02T20-15.md` (Findings Table rows 1-4)

**Files read (full list, in order):**
1. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\CLAUDE.md`
2. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\.claude\rules\general-code-change.md`
3. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\.claude\rules\general-unit-test.md`
4. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\.claude\rules\powershell.md`
5. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\docs\features\active\2026-07-02-local-preflight-orchestrator-state-gate-272\remediation-inputs.2026-07-02T20-15.md`
6. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\docs\features\active\2026-07-02-local-preflight-orchestrator-state-gate-272\policy-audit.2026-07-02T20-15.md` (lines 259-345: Section 5 and Section 8)
7. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\docs\features\active\2026-07-02-local-preflight-orchestrator-state-gate-272\code-review.2026-07-02T20-15.md` (Findings Table rows 1-4, lines 33-42)

**Key takeaways applied to this cycle:**
- Coverage fix must regenerate the real canonical artifact (`artifacts/pester/powershell-coverage.xml`) by bypassing the MCP tool's stale bundled `pester.runsettings.psd1`, not by excluding the file or lowering thresholds.
- Documentation corrections must not remove the `pr_author_preflight` documentation already present.
- The live `artifacts/orchestration/orchestrator-state.json` checkpoint must not be deleted or renamed.
- AC #11 in `spec.md` must be unchecked pending corroboration, then re-checked only after the regenerated artifact confirms >= 85% line coverage and no regression.
