# Phase 0 — Instructions Read

Timestamp: 2026-07-06T14-03

Policy Order: CLAUDE.md (standing instructions, auto-loaded) -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> language/domain rules (PowerShell) -> quality tiers -> orchestrator-state invariants.

Files read (in required order):
- CLAUDE.md standing instructions (auto-loaded rules surfaced in session context: benchmark-baselines.md, ci-workflows.md, general-code-change.md, general-unit-test.md, orchestrator-state.md, quality-tiers.md, tonality.md)
- .claude/rules/general-code-change.md (cross-language code change policy)
- .claude/rules/general-unit-test.md (cross-language unit test policy)
- .claude/rules/powershell.md (PowerShell standards, toolchain, design seams, mocking rules)
- .claude/rules/quality-tiers.md (T1-T4 tier system, uniform coverage thresholds)
- .claude/rules/orchestrator-state.md (orchestrator-state invariants, model-routing gate)
- .claude/rules/self-explanatory-code-commenting.md (docstring and comment policy)
- .claude/rules/tonality.md (professional tone policy)

Additional required references read (per plan "Required References"):
- docs/features/active/portable-orchestrator-state-preflight/spec.md
- docs/features/active/portable-orchestrator-state-preflight/plan.2026-07-06T09-54.md
- scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py (parity source)
- scripts/dev_tools/_orchestrator_state_model_routing_gate.py (parity source)
- scripts/dev_tools/validate_orchestrator_state.py (REQUIRED_STATE_KEYS, STEP_STATUS_KEYS, VALID_STEP_STATUS, VALID_BLOCKED_REASONS)
- .claude/lib/model-routing/ModelRouting.psm1 (portable-pattern exemplar)
- tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1 (manifest-test exemplar)
- .claude/hooks/enforce-pr-author-skill.ps1 and .claude/hooks/validate-orchestrator-output.ps1 (touchpoints)

Output Summary: All required policy and reference files read prior to any code change. PowerShell is the sole production language in scope; no Python validator/MCP logic will be modified.
