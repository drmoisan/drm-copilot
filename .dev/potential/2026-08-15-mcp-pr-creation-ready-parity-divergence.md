# mcp-pr-creation-ready-parity-divergence (Potential Bug)

- Date captured: 2026-08-15
- Author: Dan Moisan
- Status: Draft

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

## Summary

The MCP `validate_orchestration_artifacts` TypeScript surface reports `ok: true` under `require_pr_creation_ready` for an orchestrator-state checkpoint that the Python validator rejects. Because the orchestrator's documented PR preflight runs through the MCP tool while the `enforce-pr-author-skill.ps1` PreToolUse hook enforces via the Python validator, an orchestrator can record a passing preflight and then be blocked at the hook.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Command/flags used: `mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type: orchestrator-state` and `require_pr_creation_ready: true`, compared against `validate_orchestrator_state_text(text, require_pr_creation_ready=True)`
- Data source or fixture: `artifacts/orchestration/orchestrator-state.json` for issue 472 with `step8_status: "pending"` and `next_step: "S8_create_pr"`

## Steps to Reproduce

1. Author an orchestrator-state checkpoint that satisfies every PR-creation-readiness condition except that `step8_status` is `"pending"`, with `next_step: "S8_create_pr"`.
2. Call `mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type: "orchestrator-state"` and `require_pr_creation_ready: true`.
3. Call `validate_orchestrator_state_text(text, require_pr_creation_ready=True)` against the identical file.
4. Compare the two results.

## Expected Behavior

Both surfaces agree. A checkpoint that the Python validator rejects under `require_pr_creation_ready` is also rejected by the MCP surface, so the orchestrator's recorded preflight matches what the PreToolUse hook will enforce.

## Actual Behavior

The MCP surface returned:

```
{"ok":true,"tool":"validate_orchestration_artifacts","summary":"Validated orchestrator-state artifact at 'artifacts/orchestration/orchestrator-state.json'."}
```

The Python validator, against the same bytes, returned one error:

```
PYTHON validator require_pr_creation_ready errors: 1
  - Checkpoint PR-creation readiness validation failed: step8_status is pending.
```

The orchestrator recorded `pr_author_preflight.status: "pass"` citing the MCP result, then delegated PR creation. The `pr-author` agent dry-ran `.claude/hooks/enforce-pr-author-skill.ps1` and received `ORCHESTRATOR_STATE_PREFLIGHT_FAILED: Checkpoint PR-creation readiness validation failed: step8_status is pending.` It correctly refused to create the pull request and refused to edit the checkpoint to clear the gate.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see Actual Behavior.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

The divergence does not permit an unsafe PR: the hook is the enforcement point and it failed closed, which is the correct direction. The impact is that the orchestrator's documented preflight is not a reliable predictor of the hook's verdict, so a run can record a truthful-looking `pr_author_preflight.status: "pass"` that is wrong. That makes the checkpoint's own preflight record untrustworthy as evidence, and it wastes a full `pr-author` delegation cycle per occurrence.

## Suspected Cause / Notes

`PR_CREATION_READY_STEP_KEYS` in `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py` covers `step5_status` through `step8_status`, and `PR_CREATION_BLOCKING_STEP_STATUS` is `{pending, blocked, blocked_remediation_loop_limit}`. The TypeScript core dispatched by `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` appears not to reproduce the `step8_status` arm of that check, or not to run the readiness gate at all under this flag.

This is the same class of gap already documented for the model-routing flag, where `.claude/rules/orchestrator-state.md` records that "the MCP TypeScript surface performs the existence check only ... the Python validator remains authoritative for per-receipt correctness." If a comparable subset relationship holds for `require_pr_creation_ready`, it is currently undocumented, and the rule file does not warn a caller that an MCP pass is weaker than a Python pass for this flag.

Note the self-blocking shape of the condition: `next_step: "S8_create_pr"` with `step8_status: "pending"` cannot pass, so step 8 must be advanced off `pending` before the `gh pr create` that step 8 describes. That is defensible but undocumented, and the orchestrate skill does not state which `step8_status` value is correct while a PR is being created.

## Proposed Fix / Validation Ideas

The owner directive of 2026-08-15 sets the resolution direction: **no enforcement hook may use Python.** Every enforcement hook must be implemented in bash or PowerShell, and bash is preferred because the hook surface is migrating to bash long-term. That reframes this defect. The correct fix is not to add a third parity obligation across TypeScript, Python, and PowerShell; it is to remove the Python leg from the enforcement path entirely so the divergence has nowhere to occur.

- [ ] Remove the Python deference from `.claude/lib/orchestrator-state/OrchestratorState.psm1`. The module already carries a complete PowerShell mirror of the readiness logic but calls `Test-PythonOrchestratorValidatorAvailable` and defers to the Python CLI whenever it is importable. Deleting that branch makes the hook enforce one implementation everywhere.
- [ ] Preferred target per the directive: port the readiness logic to a bash library under `.claude/lib/bash/` and have the hook call that, so the enforcement path is identical in drm-copilot and in every destination.
- [ ] Unit coverage areas: assert the hook returns the same verdict with and without a Python environment present. That is the assertion which would have caught this, and it is stronger than a TypeScript-versus-Python parity corpus.
- [ ] Integration scenario to retest: a checkpoint with each blocking `stepN_status` value in turn must be rejected by the hook in an environment with no Python available.
- [ ] Document the expected `step8_status` value during PR creation. `in_progress` clears the gate truthfully while a PR is being created; `pending` is self-blocking and `completed` would be false before the PR exists.

Note that this is not only a drm-copilot concern. Because the module runs the Python validator here and the PowerShell mirror in a destination, the same hook enforces via a different implementation depending on the repository — which is the portability failure mode the directive is intended to prevent.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
