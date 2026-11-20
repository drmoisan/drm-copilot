## Phase 6 — New Flag Against the Real Live Checkpoint (P6-T1/P6-T2/P6-T3, Remediation Cycle 2, Issue #272)

### P6-T1: Initial run

Timestamp: 2026-07-02T22-05
Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json --require-pr-creation-ready`
EXIT_CODE: 1
Output Summary (full raw output):
```
Checkpoint missing required key: relativeFile
Checkpoint missing required key: long-name
Checkpoint has invalid step5_status: complete
```
- Two errors are missing `REQUIRED_STATE_KEYS` values (`relativeFile`, `long-name`).
- A third error is present and is NOT a missing-required-key error: `Checkpoint has invalid step5_status: complete` — this is the unconditional `VALID_STEP_STATUS` enum check (runs regardless of `--require-complete` or `--require-pr-creation-ready`), and `step5_status` is already present in the checkpoint (it is a member of `REQUIRED_STATE_KEYS`, so it is not "missing"). The value `"complete"` is not a member of `VALID_STEP_STATUS` (`{"not-applicable", "pending", "delegated", "verified", "blocked", "not_started", "in_progress", "completed"}`); the valid form is `"completed"`.
- Notably, `pr_gate`, `ci_gate`, and the `pr-author` agent receipt errors that dominated the `--require-complete` fail-before evidence (`fail-before.pr-creation-readiness.2026-07-02T22-05.md`) do **not** appear under `--require-pr-creation-ready`, confirming the new flag is materially narrower and does not require those three structurally-impossible-before-PR-creation conditions.

### P6-T2: Repair-applicability check

Per the plan's explicit, narrow authorization: "If P6-T1's exit code is non-zero solely because of missing REQUIRED_STATE_KEYS values that are legitimate, already-mandatory checkpoint metadata unrelated to this fix (specifically relativeFile and/or long-name), add the minimal correct values... If P6-T1 already exits 0, or fails for any other reason, record 'no repair applicable' and make no checkpoint edit."

P6-T1's exit code is non-zero for **three** reasons, not solely `relativeFile`/`long-name`: the third reason (`Checkpoint has invalid step5_status: complete`) is a pre-existing, unrelated checkpoint defect (an enum-value typo — `"complete"` instead of `"completed"` — in a field this remediation's Do-Not-Do constraints do not authorize editing; only `relativeFile`/`long-name` additions are authorized). Per the plan's literal branching, this is **"fails for any other reason"**, not the solely-`relativeFile`/`long-name` case.

**Disposition: no repair applicable. No checkpoint edit was made.** `artifacts/orchestration/orchestrator-state.json` was not modified by this task.

### P6-T3: Re-run confirmation

Timestamp: 2026-07-02T22-05
Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json --require-pr-creation-ready`
EXIT_CODE: 1
Output Summary:
- Re-running the identical command (no checkpoint edit was made per P6-T2's "no repair applicable" disposition) reproduces the identical three-line output from P6-T1. Exit code remains 1, not 0.
- **This does not fully satisfy a literal "confirm exit code 0" reading of P6-T3.** The plan's P6-T2 branch anticipates exactly this outcome (a non-zero exit for a reason beyond the two authorized fields) and directs "no repair applicable... make no checkpoint edit," which was followed literally. The residual failure is attributable to a pre-existing, out-of-remediation-scope checkpoint defect (`step5_status: "complete"` is an invalid enum value unrelated to issue #272's `--require-complete`/`--require-pr-creation-ready` split), not to any defect in the new `--require-pr-creation-ready` flag itself. See the isolated-defect demonstration below for direct evidence that the new flag's own logic passes cleanly once that one unrelated field is corrected.

### Isolated-defect demonstration (diagnostic only, not a checkpoint edit)

To confirm the new flag's own logic is correct and that the residual failure is attributable solely to the unrelated `step5_status` typo (not to any defect in the new PR-creation-readiness check), the same checkpoint content was validated in-memory with only `step5_status` corrected from `"complete"` to `"completed"` (no file on disk was modified):

Command: a scratch, non-repo, non-evidence Python script (deleted after use) that reads the real checkpoint from disk (read-only, no write), sets `state["step5_status"] = "completed"`, `state["relativeFile"]`, and `state["long-name"]` in memory only, then calls `validate_orchestrator_state_text(json.dumps(state), require_pr_creation_ready=True)` and prints the result. Equivalent to: `python -c "import json, pathlib; from scripts.dev_tools.validate_orchestrator_state import validate_orchestrator_state_text; state = json.loads(pathlib.Path('artifacts/orchestration/orchestrator-state.json').read_text(encoding='utf-8')); state['step5_status'] = 'completed'; state['relativeFile'] = '...'; state['long-name'] = '...'; print(validate_orchestrator_state_text(json.dumps(state), require_pr_creation_ready=True))"`
EXIT_CODE: 0
Output Summary: `ERRORS: []` — with `step5_status` corrected to a valid enum value and `relativeFile`/`long-name` populated in memory only (the same values P6-T2 would have used had the repair been solely applicable; the on-disk checkpoint file was not modified), the new `--require-pr-creation-ready` check returns zero errors against the real checkpoint's actual step5-8/blocked_reason/override-list content. This demonstrates the new flag's own logic is correct and would pass against this real checkpoint once the one unrelated, out-of-scope defect is corrected through the repository's normal orchestrator checkpoint-writing path (not through this remediation cycle's authorized edit scope).
