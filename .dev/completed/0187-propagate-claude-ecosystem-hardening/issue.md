# propagate-claude-ecosystem-hardening (Issue #187)

- Date captured: 2026-06-16
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187/ (Issue #187)

- Issue: #187
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/187
- Last Updated: 2026-06-16
- Work Mode: full-feature

## Problem / Why

A Claude customization tree copied from another repository (`artifacts/tocompare/.claude`) was audited against this repository's canonical `.claude` runtime and its bundled mirrors. The audit (`artifacts/research/20260616-tocompare-claude-ecosystem-hardening-audit-research.md`) identified seven hardened elements present in the source tree that this repository lacks or has in a weaker form. These elements form a coherent autonomous-execution / human-exception enforcement subsystem plus two independent rule and skill improvements. Without them, the orchestrator can write DONE while unautomatable steps remain unresolved, research artifacts can omit automation-feasibility assessments, coverage measurement can silently exclude production paths, and remediation handoff cycles can be malformed.

## Proposed Behavior

Propagate the seven hardened elements into the canonical `.claude` runtime and both bundled mirrors (`extensions/drm-copilot/resources/claude-customizations/` and `packages/mcp-server/resources/claude-customizations/`), and extend the Python orchestrator-state validator:

1. Add `Test-HumanInteractionShape` to `hooks/validate-orchestrator-output.ps1` — block DONE when `human_interaction` requirements are unresolved, halted, or an exception lacks a runbook.
2. Add `Test-AutomationFeasibilitySection` to `hooks/validate-task-researcher-output.ps1` — block autonomous-execution research artifacts lacking an `## Automation Feasibility` section.
3. Add `## Autonomous-Execution Mandate` section to `skills/orchestrate/SKILL.md`.
4. Create `skills/human-exception-runbook/` (SKILL.md + example.runbook.md).
5. Port `human_interaction` invariants into `scripts/dev_tools/validate_orchestrator_state.py` and update `rules/orchestrator-state.md` accordingly.
6. Add `## Coverage Exclusion Policy` and `## Test File Location` sections to `rules/general-unit-test.md`.
7. Replace `skills/remediation-handoff-atomic-planner/SKILL.md` with the expanded source version.

## Acceptance Criteria (early draft)

- [ ] `Test-HumanInteractionShape` is present in `validate-orchestrator-output.ps1` (canonical + both mirrors), wired into the validation entrypoint, with Pester coverage for absent-key, missing-requirements, missing-response, invalid-enum, halt, and exception-without-runbook cases.
- [ ] `Test-AutomationFeasibilitySection` is present in `validate-task-researcher-output.ps1` (canonical + both mirrors), with Pester coverage for matching and non-matching artifacts.
- [ ] `## Autonomous-Execution Mandate` section is present in `orchestrate/SKILL.md` (canonical + both mirrors).
- [ ] `skills/human-exception-runbook/SKILL.md` and `example.runbook.md` exist (canonical + both mirrors).
- [ ] `validate_orchestrator_state.py` enforces the `human_interaction` invariants with pytest coverage; `rules/orchestrator-state.md` documents them.
- [ ] `general-unit-test.md` contains the Coverage Exclusion Policy and Test File Location sections (canonical + both mirrors).
- [ ] `remediation-handoff-atomic-planner/SKILL.md` matches the expanded source version (canonical + both mirrors).
- [ ] Bundle-sync contract tests (`test_push_down_claude_resource_contracts.py`) pass.
- [ ] Full toolchain (PowerShell, Python, contract tests) passes.

## Constraints & Risks

- Do not copy `schemas/orchestrator-state.schema.json` verbatim (foreign-schema policy in `rules/orchestrator-state.md`); enforce `human_interaction` invariants via the existing Python validator pattern.
- Do not propagate `settings.local.json` or `agent-memory/**` from the source tree (developer-local / other-repo project memory).
- Every runtime file edit must be mirrored to both bundled mirrors; the contract test enforces parity for the `extensions/` mirror.
- The repo is ahead on `rules/orchestrator-state.md`; do not regress it.

## Test Conditions to Consider

- [ ] Pester unit tests for both new PowerShell hook functions.
- [ ] pytest tests for the new `human_interaction` validator invariants (backward-compatibility for checkpoints without `human_interaction`).
- [ ] Bundle-sync contract tests for mirror parity.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/` folder from the template