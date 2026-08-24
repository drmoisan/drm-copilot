# Fail-Before — Divergence 1 (Python validator), Pre-Fix Reproduction (Issue #412)

Task: [P0-T16] `[expect-fail]`

Timestamp: 2026-07-25T17-41

Command (the exact one-liner used, run from the repo root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585`):

```
poetry run python -c 'import json; from scripts.dev_tools.validate_orchestrator_state import validate_orchestrator_state_text as v; s={"objective":"execute one feature","change_budget_estimate":"small","path_selected":"small","promotion-type":"feature","short-name":"sample","relativeFile":"docs/features/potential/sample.md","long-name":"sample-1","issue-num":"1","feature-folder":"docs/features/active/sample-1","work-mode":"minor-audit","plan-path":"docs/features/active/sample-1/plan.md","completed_steps":[],"next_step":"S5_atomic_execution","last_updated":"2026-07-10T10:00:00Z","step5_status":"pending","step6_status":"pending","step7_status":"pending","step8_status":"pending","step9_status":"passed","step10_status":"pending","delegation_receipts":[],"blocked_reason":"none"}; print(v(json.dumps(s)))'
```

EXIT_CODE: 0

Output Summary:

Observed output, verbatim:

```
['Checkpoint has invalid step9_status: passed']
```

The returned error list contains exactly one entry, and it is byte-identical to the documented
expected string:

```
Checkpoint has invalid step9_status: passed
```

## Fixture Construction

The checkpoint is built entirely in memory as a Python dict, serialized with `json.dumps`, and
passed directly to `validate_orchestrator_state_text`. No file is written or read; no temporary
file is created, in compliance with `.claude/rules/general-unit-test.md`.

The dict carries every key in `REQUIRED_STATE_KEYS` and mirrors the shape of the existing
small-path fixture `_base_state()` in
`tests/scripts/dev_tools/test_validate_orchestrator_state_codex_topology.py` (lines 34-63),
with `delegation_receipts` left empty. The single deviation from a fully valid checkpoint is
`"step9_status": "passed"` in place of `"pending"`.

That the returned list has exactly one element confirms the checkpoint is otherwise valid: the
only complaint the validator raises is the step-status rejection under test, so nothing else is
contaminating the reproduction.

## Why This Is the Defect

`VALID_STEP_STATUS` in `scripts/dev_tools/validate_orchestrator_state.py` is the shared set
`{not-applicable, pending, delegated, verified, blocked, not_started, in_progress, completed}`
and is applied uniformly to every `stepN_status` key. It does not admit `passed` on
`step9_status`, even though the authoritative documentation vocabulary uses that value. The
same uniform check is what rejects `failed_remediation_required` and `blocked_ci_loop_limit` on
`step9_status` and `blocked_remediation_loop_limit` on `step6_status`.

The exit code is 0 because `validate_orchestrator_state_text` returns an error list rather than
raising; the `[expect-fail]` outcome for this task is the presence of the error string above,
which is what was observed.

Phase 1 makes the vocabulary additive per step key while leaving the `VALID_STEP_STATUS`
literal unchanged (plan Hard Constraint 8), after which this call must return an empty list.
