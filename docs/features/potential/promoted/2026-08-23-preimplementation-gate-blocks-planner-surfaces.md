# preimplementation-gate-blocks-planner-surfaces (Issue #535)

- Date captured: 2026-08-23
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/preimplementation-gate-blocks-planner-surfaces/ (Issue #535)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #535
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/535
- Last Updated: 2026-08-24
## Summary

`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` denies every multi-item planning surface before any implementation work is attempted. The planner agents (`parallel-planner`, `epic-planner`) cannot write their own checkpoints and cannot launch preparation-mode `Agent(orchestrator)` delegations, so `/parallel-plan` and `/epic-plan` are blocked at their first mandatory operation.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Command/flags used: `/parallel-plan` (forked skill session, 2026-08-23); hook reproduced directly with constructed PreToolUse payloads
- Data source or fixture: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` at `main`

## Steps to Reproduce

1. Invoke the hook with a Write payload whose `file_path` is `artifacts/orchestration/parallel-planner-state.json` and no ready `orchestrator-state.json` present. The decision is `deny`. The same payload with `file_path` `artifacts/orchestration/orchestrator-state.json` is allowed, because `Test-ImplementationPath` exempts exactly that one literal (line 49) before applying the `\.(...|json|...)$` implementation-path match.
2. Invoke the hook with an `Agent` delegation payload carrying the preparation-mode kickoff text pinned verbatim by `.claude/skills/parallel-plan/SKILL.md`. The payload necessarily contains the substrings `atomic-executor` and `execute`, so `Test-ImplementationDelegation` (line 91) classifies it as an implementation delegation and denies it.
3. Observe that `Test-OrchestrationReady` requires a single `issue-num`, a single `feature-folder` under `docs/features/active/`, `route_id`, and `lifecycle_ready`. A multi-item planner run has no such tuple, so the gate can never be satisfied for the planner surfaces.

## Expected Behavior

- The four orchestration checkpoints (`orchestrator-state.json`, `parallel-planner-state.json`, `parallel-orchestrator-state.json`, `epic-planner-state.json`, `epic-orchestrator-state.json`) are all writable by their owning agents without a single-feature ready checkpoint, since checkpoint authoring is orchestration bookkeeping, not implementation.
- A preparation-mode delegation (payload carrying `Preparation mode: true.` / `route_id: preparation.`) is not classified as an implementation delegation, because preparation performs promotion, research, planning, and preflight only — no atomic execution.

## Actual Behavior

- `Write`/`Edit` of `artifacts/orchestration/parallel-planner-state.json` and `artifacts/orchestration/epic-planner-state.json` is denied with `PREIMPLEMENTATION_GATE_BLOCKED` unless a single-feature-ready `orchestrator-state.json` exists. By inspection the same applies to `parallel-orchestrator-state.json` and `epic-orchestrator-state.json`.
- Every preparation-mode `Agent(orchestrator)` delegation is denied because the delegation matcher regex-matches the whole payload against `...|atomic-executor|implementation|execute`.
- Consequence: `/parallel-plan` and `/epic-plan` cannot start in this repository. A `/parallel-plan` run on 2026-08-23 was blocked before fan-out after completing triage only.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

  ```text
  PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require
  artifacts/orchestration/orchestrator-state.json to contain issue number,
  feature folder, route metadata, lifecycle readiness, and checkpoint state
  before implementation begins.
  ```

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

- The gate is keyed to the single-feature `orchestrator` route only. It predates the epic and parallel surfaces and has no concept of a planning (non-implementation) phase.
- `Test-ImplementationPath` exempts one literal checkpoint path; the other orchestration checkpoints end in `.json` and match the implementation-path extension pattern.
- `Test-ImplementationDelegation` serializes the entire tool payload and substring-matches `execute`/`implementation`, which fire on prose that merely mentions the execution phase.
- This is distinct from issue #516, which concerns absolute-path normalization of the one exempt literal; the denials above reproduce with the repo-relative spelling.
- Related standing finding: the gate also pattern-matches every `git add|commit`, leaving housekeeping changes with no legitimate staging route. Any fix should keep the gate fail-closed for genuine implementation operations.

## Proposed Fix / Validation Ideas

- Widen the exempt path set in `Test-ImplementationPath` from the single literal to the orchestration checkpoint set under `artifacts/orchestration/` (planner and orchestrator checkpoints for the standard, parallel, and epic surfaces).
- Make `Test-ImplementationDelegation` treat a delegation payload that carries the preparation-mode markers (`Preparation mode: true.` / `route_id: preparation.`) as non-implementation, while continuing to deny execution-mode delegations.
- [x] Unit coverage areas: Pester tests for each checkpoint path (allow) and a non-checkpoint `.json` path (deny); preparation-mode payload (allow) versus execution-mode payload (deny); fail-closed behavior on malformed payloads unchanged.
- [x] Integration scenario to retest: `/parallel-plan` reaches its preparation fan-out and writes `artifacts/orchestration/parallel-planner-state.json` without a fabricated single-feature checkpoint.
- [x] Manual verification notes: invoke the hook directly with the constructed payloads from Steps to Reproduce and confirm the decision flips for the checkpoint and preparation cases while remaining deny for implementation paths and execution delegations.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
