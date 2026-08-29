# preflight-signal-enforcement-and-agent-drift (Issue #589)

- Date captured: 2026-08-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/preflight-signal-enforcement-and-agent-drift/ (Issue #589)

- Issue: #589
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/589
- Last Updated: 2026-08-29
## Problem / Why

Issue #586 (PR #587) added two required handoff signals to the skill contracts — `SELF-REVIEW: RE-DERIVED THIS PASS` / `SELF-REVIEW: BLOCKED` for `atomic-planner`, and `CONVERGENCE: NO FURTHER ROUNDS EXPECTED` / `CONVERGENCE: FURTHER ROUNDS LIKELY` for `atomic-executor` — plus a stated target of at most two preflight rounds per plan. The `feature-review` audit for that change made its Go recommendation conditional on this follow-up, for two reasons:

1. **The new signals have no hook enforcement.** The sibling `PREFLIGHT:` signals are checked by `.claude/hooks/validate-executor-output.ps1` and `.claude/hooks/validate-planner-output.ps1`; the new `SELF-REVIEW:` and `CONVERGENCE:` signals are checked by nothing. A handoff that omits them passes every gate, so the two-round bar the change introduces is documented but cannot fail. That is the same defect class `.claude/rules/plan-acceptance-gates.md` exists to detect, appearing in the feature whose purpose is to strengthen those gates.

2. **Three agent-definition statements now contradict the contracts they govern.** These were rated non-blocking and deferred by design (`issue.md` for #586 declared the first out of scope in advance), but they instruct agents that also preload the revised skills, so each agent receives two conflicting instructions at once.

## Proposed Behavior

1. Extend the two SubagentStop hooks so a planner handoff must carry exactly one `SELF-REVIEW:` signal, and an executor preflight return must carry exactly one `CONVERGENCE:` signal, blocking otherwise. Preserve the existing presence-matching behavior for `PREFLIGHT:` — it is presence-based rather than exclusivity-based, which is what allows a `CONVERGENCE:` line to coexist with a `PREFLIGHT:` signal today.
2. Enforce that a `SELF-REVIEW: RE-DERIVED THIS PASS` signal is followed by a non-empty enumeration of re-derived citations, since the contract already states that a signal carrying no enumeration is not a completed declaration.
3. Reconcile the three agent-definition statements listed below with the revised contracts.
4. Decide whether `preflight.iterations` exceeding the two-round target should be recorded, warned, or blocked, and implement the chosen behavior consistently with `blocked_preflight_iteration_limit` in `remediation-handoff-atomic-planner`.

## Acceptance Criteria (early draft)

- [ ] `.claude/hooks/validate-planner-output.ps1` blocks a planner handoff that carries no `SELF-REVIEW:` signal, and blocks one that carries `SELF-REVIEW: RE-DERIVED THIS PASS` with no following citation enumeration.
- [ ] `.claude/hooks/validate-executor-output.ps1` blocks a preflight return that carries no `CONVERGENCE:` signal.
- [ ] Both hooks continue to accept a return carrying a `PREFLIGHT:` signal alongside a `CONVERGENCE:` line, with a regression test pinning that coexistence.
- [ ] `.claude/agents/atomic-executor.md` no longer describes preflight as "format and structure validation only", which contradicts the delta-prose and tonality checks the revised `## Preflight Validation (Planner <-> Executor)` section requires.
- [ ] `.claude/agents/atomic-executor.md`'s "Return exactly one of:" wording is reconciled with the separately required `CONVERGENCE:` line, so the two-value `PREFLIGHT:` set and the additional required line are both stated without contradiction.
- [ ] `.claude/agents/orchestrator.md` includes `blocked_preflight_iteration_limit` wherever it enumerates `final_status` values (currently lines 104 and 144 state a three-value set in two different spellings).
- [ ] Every change above is mirrored byte-identically into `extensions/drm-copilot/resources/claude-customizations/`, verified by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
- [ ] Orchestrator behavior when `preflight.iterations` exceeds 2 is defined and implemented, or explicitly recorded as intentionally advisory-only.

## Constraints & Risks

- Enforcement hooks must not be implemented in Python: bash is preferred and PowerShell is acceptable, per the established repository position that a Python leg creates a second implementation that drifts.
- Tightening a SubagentStop hook affects every in-flight orchestration, so a hook that blocks on a missing signal will fail existing agents until their prompts and definitions are updated. Sequence the definition reconciliation before or with the hook change.
- Risk of over-enforcement: the `CONVERGENCE:` line is a forward-looking judgment, so a hook can verify its presence and form but not its accuracy. Do not build a gate that appears to validate the judgment.
- The `.agents/` and `.github/` copies of these skills are intentionally divergent variants, not stale mirrors; their parity tests compare each surface against its own bundle. Do not "fix" them by syncing to `.claude/`.

## Test Conditions to Consider

- [ ] Unit coverage areas: hook signal matching for present, absent, malformed, and duplicated signals; the enumeration-required branch of `SELF-REVIEW: RE-DERIVED THIS PASS`.
- [ ] Integration scenarios: a planner handoff and an executor preflight return exercised end to end through the hooks, including the coexistence case.
- [ ] CLI/API examples: bundle-parity run confirming the mirrored agent-definition edits.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/preflight-signal-enforcement-and-agent-drift/` folder from the template
