# large-route-matrix-promotion-type-gap (Issue #399)

- Date captured: 2026-07-22
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/large-route-matrix-promotion-type-gap/ (Issue #399)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #399
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/399
- Last Updated: 2026-07-22
- Work Mode: minor-audit

## Summary

The `"large"` route entry in `config/orchestration-routing.json` lists two `required_skills` names that do not exist anywhere in `.claude/`, and its `required_mcp_tools` list hardcodes the feature-type promotion tool regardless of `promotion_type`. Both defects make it structurally impossible for `validate_routing_contract` (in `scripts/dev_tools/_orchestrator_state_routing.py`) to pass `--require-complete` for any large-route orchestration in this repository's current configuration.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: not applicable (config/JSON + validator logic defect, not a runtime failure)
- Command/flags used: `scripts/dev_tools/validate_orchestration_artifacts orchestrator-state <path> --require-complete --require-model-routing`
- Data source or fixture: `config/orchestration-routing.json` (`routes.large`), `scripts/dev_tools/_orchestrator_state_routing.py`

## Steps to Reproduce

1. Inspect `config/orchestration-routing.json`, `routes.large.required_skills`: it lists `"orchestrator-workflow"` and `"repo-automation-adapter"` alongside valid skill names (lines 45-54 of the file as read on 2026-07-22).
2. Run a repo-wide search for either file under `.claude/`: `find .claude -iname "*orchestrator-workflow*" -o -iname "*repo-automation-adapter*"`. The search returns no results — confirmed empty during this investigation.
3. Read `scripts/dev_tools/_orchestrator_state_routing.py`, function `validate_routing_contract` (lines 469-527). For each name in the route's `required_skills`, it requires a matching entry in `_receipt_skills(state)` (checkpoint `skill_receipts` with `required: true` and non-empty `evidence`) or appends a blocking error (`"Checkpoint missing required skill receipt: {skill}."`, line 517). Because `orchestrator-workflow` and `repo-automation-adapter` are not real skills, no checkpoint can ever produce a truthful receipt for them.
4. Separately, inspect `routes.large.required_mcp_tools`: it hardcodes `"new_potential_entry"` (lines 55-61), the feature-type promotion tool per `.claude/skills/feature-promotion-lifecycle/SKILL.md`'s documented tool set (`feature potential entry: mcp__drm-copilot__new_potential_entry` vs `bug potential entry: mcp__drm-copilot__new_potential_bug_entry`).
5. Trace a bug-type large-route orchestration (for example, issue #397 / PR #398, an npm-audit-vulnerabilities fix): it correctly calls `mcp__drm-copilot__new_potential_bug_entry`, not `new_potential_entry`. `validate_routing_contract`'s `required_mcp_tools` loop (lines 519-522) requires a truthful `mcp_call_receipts` entry for `new_potential_entry` specifically, which a bug-type promotion never produces (short of fabricating a spurious feature-type potential doc it does not otherwise need).

## Expected Behavior

`--require-complete --require-model-routing` should be able to reach a clean pass for a well-executed large-route orchestration, for both `promotion_type: feature` and `promotion_type: bug`, using only the skills and MCP tools that genuinely exist and are genuinely exercised by that promotion type.

## Actual Behavior

- `validate_routing_contract` unconditionally appends `"Checkpoint missing required skill receipt: orchestrator-workflow."` and `"Checkpoint missing required skill receipt: repo-automation-adapter."` for every large-route checkpoint, because no skill file with either name exists to acknowledge.
- For bug-type large-route work, `validate_routing_contract` additionally appends `"Checkpoint missing successful MCP receipt: new_potential_entry."`, because the correct tool for a bug promotion is `new_potential_bug_entry`, which the matrix does not list as an acceptable alternative.
- Net effect: `--require-complete` can never honestly pass for the `"large"` route in this repository's current configuration, for any promotion type.

## Acceptance Criteria

- [ ] `config/orchestration-routing.json`'s `routes.large.required_skills` no longer names `orchestrator-workflow` or `repo-automation-adapter` unless a corresponding skill file is created under `.claude/skills/` for each.
- [ ] `config/orchestration-routing.json`'s `routes.large.required_mcp_tools` reflects the correct promotion tool per `promotion_type`: `new_potential_entry` for `feature`, `new_potential_bug_entry` for `bug` (either by promotion-type-aware branching in the matrix, or by corresponding promotion-type-aware handling in `validate_routing_contract`).
- [ ] `scripts/dev_tools/_orchestrator_state_routing.py`'s `validate_routing_contract` passes cleanly (zero errors) for a synthetic large-route, bug-type checkpoint that records a truthful `new_potential_bug_entry` MCP receipt and no fabricated `orchestrator-workflow` / `repo-automation-adapter` skill receipts.
- [ ] `validate_routing_contract` continues to pass cleanly for the existing large-route, feature-type case (no regression).
- [ ] Unit test coverage added for `scripts/dev_tools/_orchestrator_state_routing.py` (or its test module) asserting both fixed behaviors above.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet:
  ```
  Checkpoint missing required skill receipt: orchestrator-workflow.
  Checkpoint missing required skill receipt: repo-automation-adapter.
  Checkpoint missing successful MCP receipt: new_potential_entry.   (bug-type only)
  ```
  (Reconstructed from reading `validate_routing_contract`'s error-message templates at lines 500-522 of `scripts/dev_tools/_orchestrator_state_routing.py`, applied to the `routes.large` entries confirmed present in `config/orchestration-routing.json`. Not machine-captured from an actual validator run.)

## Impact / Severity

- [x] High
- Rationale: every large-route orchestration in this repository is structurally blocked from an honest `--require-complete` pass; this is a repo-wide orchestration-tooling defect, not a one-off. It was discovered as a byproduct of finalizing the checkpoint for issue #397 / PR #398 (npm audit vulnerabilities CI gate fix), which is itself unaffected because PR #398 followed a different route.

## Suspected Cause / Notes

- `required_skills` for `routes.large` in `config/orchestration-routing.json` appears to reference skill names that were either planned and never created, or created and later removed, without the routing matrix being updated to match. `routes.small` and `routes.remediation` do not reference either dead name, suggesting `routes.large` alone drifted.
- `required_mcp_tools` for `routes.large` was seemingly copied from `routes.small` (both lists are byte-identical) without accounting for the fact that `routes.large` covers both `feature` and `bug` promotion types, whereas `routes.small`'s minor-audit path may skew toward one type in practice. The list needs to vary by `promotion_type`, or list both `new_potential_entry` and `new_potential_bug_entry` as an either/or requirement resolved by the checkpoint's actual `promotion-type` variable.
- Files to inspect for the fix: `config/orchestration-routing.json` (the `routes.large.required_skills` and `routes.large.required_mcp_tools` arrays), `scripts/dev_tools/_orchestrator_state_routing.py` (`validate_routing_contract`, `_receipt_skills`, `_mcp_tools`, and the `required_mcp_tools` loop at lines 519-522 — may need promotion-type-aware branching), and `.claude/skills/feature-promotion-lifecycle/SKILL.md` (documents the correct feature-vs-bug tool split that the matrix should honor).

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: extend the existing test suite for `scripts/dev_tools/_orchestrator_state_routing.py` (or its companion tests under `tests/dev_tools/`) with cases asserting that `routes.large.required_skills` contains only names with a corresponding real skill file under `.claude/skills/`, and that a bug-type large-route checkpoint recording only `new_potential_bug_entry` (not `new_potential_entry`) can pass `validate_routing_contract`.
- [ ] Integration scenario to retest: run `scripts/dev_tools/validate_orchestration_artifacts orchestrator-state <checkpoint> --require-complete --require-model-routing` against a synthetic large-route, bug-type checkpoint with a truthful `new_potential_bug_entry` MCP receipt and no fabricated `orchestrator-workflow` / `repo-automation-adapter` skill receipts, confirming it passes cleanly once the matrix is corrected.
- [ ] Manual verification notes: after editing `config/orchestration-routing.json`, re-run the repo-wide search (`find .claude -iname "*orchestrator-workflow*" -o -iname "*repo-automation-adapter*"`) to confirm the dead names were either removed from the matrix or the corresponding skill files were actually created (removal is the simpler fix absent evidence the skills are still planned).

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
