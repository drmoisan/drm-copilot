# orchestration-state-contract-divergences (Issue #412)

- Date captured: 2026-07-25
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/orchestration-state-contract-divergences/ (Issue #412)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #412
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/412
- Last Updated: 2026-07-25
- Work Mode: full-bug

## Summary

Two documented-contract-versus-implementation divergences exist in the orchestration state machine. First, the `step9_status` values documented in `.claude/skills/orchestrate/SKILL.md` (`passed`, `failed_remediation_required`, `blocked_ci_loop_limit`) are all rejected by the validator's shared step-status enumeration, so a CI failure or a CI-loop-limit halt has no valid representation in the checkpoint. Second, the documented complexity-floor semantics ("each present `[floor]` signal contributes a candidate band of `C3`") do not match the reference implementations, which return `C3` for any non-empty signal list regardless of the signal's `floor` flag.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `poetry run python -m scripts.dev_tools.validate_orchestrator_state`; direct invocation of `scripts/dev_tools/compute_complexity_floor.py` and `.claude/lib/model-routing/ModelRouting.psm1` (`Get-ComplexityFloor`)
- Data source or fixture: `artifacts/orchestration/orchestrator-state.json`, `config/orchestration-routing.json`

## Steps to Reproduce

1. Write a checkpoint containing `step9_status: "passed"` (the value documented in `.claude/skills/orchestrate/SKILL.md` `## Checkpoint Schema — CI Gate Fields`) and run the orchestrator-state validator.
2. Observe `Checkpoint has invalid step9_status: passed`. Repeat with `failed_remediation_required` and `blocked_ci_loop_limit`; all three documented non-`pending` values are rejected by `VALID_STEP_STATUS`.
3. Call `compute_complexity_floor(["docs_or_comment_only"])` (a `"floor": false` signal in `config/orchestration-routing.json`) and observe `C3` rather than `C1`. Repeat with `Get-ComplexityFloor -SignalsPresent docs_or_comment_only` in `.claude/lib/model-routing/ModelRouting.psm1` and observe the same result.

## Expected Behavior

The documented S9 status vocabulary and the documented complexity-floor semantics are each consistent with exactly one authoritative side, and both the validator and the reference implementations agree with the documented contract.

## Actual Behavior

`Checkpoint has invalid step9_status: passed` is produced for a checkpoint written to the documented S9 contract. `VALID_STEP_STATUS = {not-applicable, pending, delegated, verified, blocked, not_started, in_progress, completed}` is applied uniformly to `step5_status`..`step10_status`, so no documented S9 failure state is representable and the fail-closed CI halt path cannot be persisted. Separately, both complexity-floor reference implementations return `C3` for every non-empty signal list, so the `"floor": false` flag and the unknown-signal case are dead configuration.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `Checkpoint has invalid step9_status: passed`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The S9 CI-gate vocabulary was documented in the skill without a corresponding widening of the validator's shared step-status set. The complexity-floor reference implementations were written to accept a pre-filtered floor-signal sequence, while the checkpoint records the full `signals_present[]` set that the validator then recomputes from. Files to inspect: `scripts/dev_tools/validate_orchestrator_state.py`, `scripts/dev_tools/compute_complexity_floor.py`, `.claude/lib/model-routing/ModelRouting.psm1`, `config/orchestration-routing.json`, `.claude/skills/orchestrate/SKILL.md`, `.claude/rules/orchestrator-state.md`, and any TypeScript mirror under `extensions/drm-copilot/src/`.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: step-status validation, complexity-floor computation, config-parity between Python and PowerShell implementations
- [x] Integration scenario to retest: full-lifecycle checkpoint validation under `--require-complete --require-model-routing`
- [x] Manual verification notes: research must first determine, per divergence, which side is authoritative, and must determine the backward-compatibility consequence of a floor-formula change for stored `complexity_assessments[]` entries

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
