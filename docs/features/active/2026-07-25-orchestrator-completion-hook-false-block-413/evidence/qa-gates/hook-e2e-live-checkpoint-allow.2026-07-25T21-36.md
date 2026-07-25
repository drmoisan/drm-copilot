# Primary Acceptance Evidence — Fixed Hook Allows DONE Against the Live Checkpoint

Timestamp: 2026-07-25T21-36

This artifact records the decisive end-to-end run that was structurally impossible before the issue #413 fix. During plan execution the live `artifacts/orchestration/orchestrator-state.json` was mid-orchestration and could not satisfy `--require-complete`, so `[P5-T2]` used the sanctioned fixture branch. After PR #416 was opened and all required checks passed, the live checkpoint became genuinely completion-passing, allowing the real scenario to be exercised.

## Step 1 — Confirm the live checkpoint genuinely passes the authoritative validator

Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json --require-complete --require-model-routing`

EXIT_CODE: 0

Output Summary: `orchestrator-state validation passed: artifacts/orchestration/orchestrator-state.json`. The validator exits 0 and prints its 85-character success line to stdout — precisely the condition that triggered the defect.

## Step 2 — Run the fixed hook against that same live checkpoint

Command:

```
CLAUDE_HOOK_INPUT='{"output":"DONE: issue #413 orchestrator completion-hook false-block fixed; PR #416 open with all required checks green."}' pwsh -NoLogo -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1
```

EXIT_CODE: 0

Output Summary: No output; the hook allowed termination. The default `$Invoker` shelled the real Python validator subprocess — no mock, no injected seam, no `-CheckpointPath` override.

## Before/after comparison

| Condition | Before the fix | After the fix |
|---|---|---|
| Validator exits 0, prints success line to stdout | Hook exits **1** with `ROUTING_CONTRACT_BLOCKED: orchestrator-state validation passed: artifacts/orchestration/orchestrator-state.json` | Hook exits **0** (verified above) |
| Validator exits non-zero, prints errors to stderr | Hook exits 1 with `ROUTING_CONTRACT_BLOCKED:` and the real error lines | Hook exits 1 with `ROUTING_CONTRACT_BLOCKED:` and the real error lines (unchanged) |

The fail-closed direction was re-verified independently during this orchestration: run against the same live checkpoint earlier in the session, while it was still mid-run and genuinely failing, the fixed hook exited 1 and surfaced the validator's actual errors (`step6_status is pending`, `pr_gate must be an object with keys: ...`, `Checkpoint missing required agent receipt: ...`). The gate was not weakened.

## Significance

This closes the gap noted against AC12 at execution time. The criterion's substance — hook exit 0 against a checkpoint independently proven to pass `--require-complete --require-model-routing`, through the real Python subprocess seam — is now satisfied against the live checkpoint itself, not only the fixture. The fixture evidence at `evidence/qa-gates/hook-e2e-allow.2026-07-25T17-19.md` remains valid and is superseded in scope, not contradicted.
