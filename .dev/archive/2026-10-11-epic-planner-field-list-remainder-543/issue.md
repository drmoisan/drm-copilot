# epic-planner-field-list-remainder (Bug, Issue #543 remainder)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Draft
- Issue: #543
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/543
- GitHub issue: #543 (pre-existing; adopted, not re-promoted)
- Lifecycle record: docs/features/potential/promoted/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding.md
- Parallel run: bug-burndown-2026-10-11 (group P17)

- Work Mode: full-bug

## Summary

The checkpoint field list that `.claude/agents/epic-planner.md` instructs the epic planner to write omits `max_parallel_features` (top-level) and `research_path` (per-feature). The epic-planner-state validator requires both: `REQUIRED_KEYS` and `REQUIRED_FEATURE_KEYS` in `scripts/dev_tools/validate_epic_planner_state.py`. An epic planner that follows its own agent definition therefore writes a checkpoint that fails plain validation. The gap was recorded in the #874 spec (`docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md`, line 255) and in the 2026-10-11 issue #543 status comment.

## Environment

- OS/version: any (observed on Windows 11)
- Command/flags used: MCP `validate_orchestration_artifacts` with `artifact_type: epic-planner-state`
- Data source: an epic-planner checkpoint authored from the field list in `.claude/agents/epic-planner.md`

## Steps to Reproduce

1. Author `artifacts/orchestration/epic-planner-state.json` with exactly the fields listed in `.claude/agents/epic-planner.md`.
2. Validate it with the `epic-planner-state` artifact type.
3. Observe missing-key errors for `max_parallel_features` and for each feature's `research_path`.

## Expected Behavior

The agent definition's checkpoint field list names every key the validator requires, including `max_parallel_features` and per-feature `research_path`, and the bundled mirror (and any Codex counterpart that must match) carries the same list.

## Actual Behavior

The field list omits both keys, so the documented contract and the validator disagree.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: see issue #543 comment dated 2026-10-11 ("Related gap noted in `spec.md:255`").

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

Operator decision for this remainder: add `max_parallel_features` and `research_path` to the checkpoint field list in `.claude/agents/epic-planner.md`, with its bundled mirror under `extensions/drm-copilot/resources/claude-customizations/` and any Codex counterpart the research shows must match.

Out of scope: the per-feature `model_routing_receipt` and `topology_receipt` gating in `_validate_ready_features` / `validateReadyFeatures`; validator code changes; edits to `.claude/rules/` or `.github/instructions/`. Earlier #543 work (PR #829, PR #874) is not reopened.

## Proposed Fix / Validation Ideas

- [ ] Documentation edit in `.claude/agents/epic-planner.md` plus byte-identical mirror update
- [ ] Bundle-parity and agent-definition tests stay green
- [ ] Verify the documented list matches `REQUIRED_KEYS` / `REQUIRED_FEATURE_KEYS`

## Next Step

- [x] Promote to GitHub issue (bug-report template) — issue #543 already exists; no new issue is created
- [ ] Move to active fix folder / branch
