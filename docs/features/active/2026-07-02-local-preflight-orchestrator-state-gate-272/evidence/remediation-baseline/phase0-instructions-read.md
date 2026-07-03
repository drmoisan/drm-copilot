## Phase 0 Policy Read — Remediation Cycle 2 (Issue #272)

Timestamp: 2026-07-02T22-05

Policy Order:
1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`
5. `.claude/rules/python-suppressions.md`
6. `.claude/rules/self-explanatory-code-commenting.md`
7. `.claude/rules/powershell.md`
8. `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/remediation/2026-07-02T22-05/remediation-inputs.md`
9. `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/spec.md` (Technical Specifications, Boundaries and invariants to preserve)
10. `.claude/hooks/enforce-pr-author-skill.ps1` (`Invoke-OrchestratorStatePreflight`, script-level `.DESCRIPTION` Preflight bullet)
11. `.claude/hooks/validate-orchestrator-output.ps1` (`Invoke-RoutingContractValidation`, context only)
12. `scripts/dev_tools/validate_orchestrator_state.py` (full)
13. `scripts/dev_tools/validate_orchestration_artifacts.py` (full)
14. `scripts/dev_tools/_orchestrator_state_routing.py` (`validate_completion_pr_gate`, `validate_phase_completeness`, `validate_routing_contract`, context only)
15. `.claude/skills/orchestrate/SKILL.md` (`## PR Authoring (pr-author Handoff)`, `## PR Creation Gate`, `## Step S9 — CI Green Gate`)
16. `.claude/agents/orchestrator.md` (`## PR Creation Delegation`)
17. `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` (`build_complete_large_orchestrator_state` fixture, two `--require-complete` CLI tests, lines ~564-635)
18. `tests/scripts/dev_tools/test_validate_orchestrator_state.py` (`build_valid_orchestrator_state` fixture, lines ~25-79)
19. `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (grep `require-complete`)
20. `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` (lines 39 and 41)

## Files Read (full list, in order, P0-T1 through P0-T20)

1. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\CLAUDE.md` (P0-T1)
2. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\.claude\rules\general-code-change.md` (P0-T2)
3. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\.claude\rules\general-unit-test.md` (P0-T3)
4. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\.claude\rules\python.md` (P0-T4)
5. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\.claude\rules\python-suppressions.md` (P0-T5)
6. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\.claude\rules\self-explanatory-code-commenting.md` (P0-T6)
7. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\.claude\rules\powershell.md` (P0-T7)
8. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\docs\features\active\2026-07-02-local-preflight-orchestrator-state-gate-272\remediation/2026-07-02T22-05/remediation-inputs.md` (P0-T8)
9. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\docs\features\active\2026-07-02-local-preflight-orchestrator-state-gate-272\spec.md` (Technical Specifications, Boundaries and invariants sections) (P0-T9)
10. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\.claude\hooks\enforce-pr-author-skill.ps1` (full; `Invoke-OrchestratorStatePreflight` lines ~49-87, script-level `.DESCRIPTION` Preflight bullet lines ~23-24) (P0-T10)
11. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\.claude\hooks\validate-orchestrator-output.ps1` — not read this cycle beyond prior familiarity; not modified (P0-T11, context only, out of scope for edits)
12. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\scripts\dev_tools\validate_orchestrator_state.py` (full, 470 lines) (P0-T12)
13. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\scripts\dev_tools\validate_orchestration_artifacts.py` (full, 246 lines) (P0-T13)
14. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\scripts\dev_tools\_orchestrator_state_routing.py` (full, context only) (P0-T14)
15. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\.claude\skills\orchestrate\SKILL.md` (`## PR Authoring (pr-author Handoff)` lines 68-81, `## Step S9 — CI Green Gate` lines 152+, `## PR Creation Gate` line 210) (P0-T15)
16. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\.claude\agents\orchestrator.md` (`## PR Creation Delegation` lines 76-99) (P0-T16)
17. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\tests\scripts\dev_tools\test_validate_orchestration_artifacts.py` (lines 555-636: `build_complete_large_orchestrator_state` fixture and the two `--require-complete` CLI tests; file confirmed over the 500-line cap and must not be extended) (P0-T17)
18. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\tests\scripts\dev_tools\test_validate_orchestrator_state.py` (lines 1-85: `build_valid_orchestrator_state` fixture; file confirmed over the 500-line cap and must not be extended) (P0-T18)
19. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1` (grep for `require-complete` returned zero matches, confirming no assertion text there requires updating) (P0-T19)
20. `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-18-01\tests\scripts\claude-hooks\enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` (full; located the two `--require-complete` references at line 39 `It` description and line 41 comment) (P0-T20)

## Notes

- `scripts/dev_tools/validate_orchestrator_state.py` is 470 lines by `wc -l`.
- `scripts/dev_tools/validate_orchestration_artifacts.py` is 246 lines by `wc -l`.
- `.claude/hooks/enforce-pr-author-skill.ps1` is 497 lines by `wc -l`.
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` is 497 lines by `wc -l`.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` is exactly 500 lines by `wc -l` (zero margin, load-bearing per plan P3-T10).

## Key Takeaways Applied to This Cycle

- `--require-complete` must remain completely unchanged; the new `--require-pr-creation-ready` flag is additive.
- The new function must not call `validate_completion_pr_gate`, `_validate_completion_ci_gate`, `validate_phase_completeness`, or `validate_routing_contract`.
- Do not touch `.claude/hooks/validate-orchestrator-output.ps1`.
- Do not extend the two already-over-cap test files; new pytest coverage goes into new sibling split files.
- The live `artifacts/orchestration/orchestrator-state.json` checkpoint must not be deleted or renamed; only `relativeFile`/`long-name` additions are permitted if needed to clear P6-T1.
