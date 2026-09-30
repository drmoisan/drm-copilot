# blocked-reason-premise-falsified-halt (Potential Bug)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Draft
- Source issue: #523 (pre-existing, OPEN). Epic: #771 (`orchestrator-state-contract-correctness`).

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Work Mode: full-bug

## Summary

The orchestrator checkpoint's `blocked_reason` field is a seven-member enum covering only **mechanical** failure modes (`delegation_launch_failed`, `validator_failed`, and similar). It cannot express a halt in which every delegation and every validator **succeeded** but the work's premise was falsified by evidence gathered during execution.

## Environment

- OS/version: any
- Python version: repository Poetry environment
- Command/flags used: orchestrator-state validation (Python `scripts/dev_tools/validate_orchestrator_state.py`, PowerShell `.claude/lib/orchestrator-state/OrchestratorState.psm1`, TypeScript `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`)
- Data source or fixture: an orchestrator checkpoint recording a halt whose premise was falsified

## Steps to Reproduce

1. Run an orchestration whose delegations and validators all succeed, but whose measurements falsify the defect hypothesis the plan was built on.
2. Attempt to record the halt in `artifacts/orchestration/orchestrator-state.json` using `blocked_reason`.
3. Observe that no enum member describes the halt; the only non-misrepresenting value is `none`.

## Expected Behavior

The halt is expressible in structured checkpoint fields, and a genuinely blocked run is distinguishable from an unblocked one without reading free-form text.

## Actual Behavior

During the `quickfiler-suite-determinism-foundation` epic run (2026-08-22), the child for drmoisan/TaskMaster#511/#571 completed Phases 0 through 4 with every delegation and validator green, then halted because its own measurements falsified the defect hypothesis the plan was built on. No enum member describes that.

The child set `blocked_reason: none` and recorded the real reason in free-form keys, explicitly declining to pick a mechanical member that would misrepresent the halt. That is the correct call, but it means a genuinely blocked run is indistinguishable from an unblocked one by the enum alone, and any tooling that reads `blocked_reason` to triage halts will mis-triage this class.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `blocked_reason: none` recorded on a halted child checkpoint (TaskMaster#511/#571, 2026-08-22).

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

A premise-falsified halt is the most valuable kind of halt — it is the orchestration system catching a planning error before it reaches `main`. Making it unrepresentable in the structured field pushes it into prose, where automated triage cannot see it.

The enum is defined in three runtimes: `VALID_BLOCKED_REASONS` in `scripts/dev_tools/validate_orchestrator_state.py` (authoritative), `$script:VALID_BLOCKED_REASONS` in `.claude/lib/orchestrator-state/OrchestratorState.psm1` (plus its bundled copy), and `VALID_BLOCKED_REASONS` in `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: enum acceptance and rejection in all three runtimes; cross-runtime parity fixtures.
- [ ] Integration scenario to retest: existing checkpoints validate byte-identically.
- [ ] Manual verification notes: skill documents enumerating `blocked_reason` values list the new representation.

## Acceptance Criteria

- [ ] `blocked_reason` can express a halt where all delegations and validators succeeded but the premise was falsified (for example a `premise_falsified` member, or an orthogonal `blocked_class` field).
- [ ] The validator accepts the new value and continues to reject values outside the enum.
- [ ] The distinction between "not blocked" and "blocked for a non-mechanical reason" is recoverable from the structured fields alone, without reading free-form text.
- [ ] Existing checkpoints that omit the field, or set it to an existing member, validate byte-identically.

## Next Step

- [x] Promote to GitHub issue (bug-report template) — already exists as #523
- [ ] Move to active fix folder / branch
