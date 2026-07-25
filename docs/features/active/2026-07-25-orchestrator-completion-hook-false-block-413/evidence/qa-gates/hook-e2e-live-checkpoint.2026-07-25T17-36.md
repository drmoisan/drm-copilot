# Late Live-Checkpoint Verification (issue #413, [P7-T2])

Timestamp: 2026-07-25T17-36

## Branch taken

**Authorized skip branch** (explicitly permitted by the [P7-T2] task text): the live checkpoint
`artifacts/orchestration/orchestrator-state.json` is owned by the enclosing orchestration and
cannot reach a completion-passing state within this execution.

EXIT_CODE: **SKIPPED** (for the required ALLOW outcome against the live checkpoint)

## Proof of the constraint — re-run of the [P5-T1] validator command at end of execution

Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json --require-complete --require-model-routing` (run at repo root)

EXIT_CODE: **1** (non-zero) — identical to the [P5-T1] precheck taken at 2026-07-25T17-19.

Output:

```text
Checkpoint completion validation failed: step6_status is pending.
Checkpoint completion validation failed: step7_status is pending.
Checkpoint completion validation failed: step8_status is pending.
Checkpoint completion validation failed: step9_status is pending.
Checkpoint completion validation failed: step10_status is pending.
Checkpoint completion validation failed: pr_gate must be an object with keys: pr_number, pr_url, head_branch, head_sha.
Checkpoint completion validation failed: ci_gate must be an object with keys: conclusion, head_sha, verified_at.
Checkpoint missing required agent receipt: atomic-executor.
Checkpoint missing required agent receipt: feature-review.
Checkpoint missing required agent receipt: pr-author.
Checkpoint missing successful MCP receipt: collect_pr_context.
Checkpoint missing successful MCP receipt: validate_orchestration_artifacts.
```

Why the constraint is structural, not remediable by this executor:

- The unmet requirements are the enclosing orchestration's **downstream** steps: `pr_gate`
  requires an actual PR (number, URL, head branch, head SHA); `ci_gate` requires a completed CI
  run; and the missing receipts are for `atomic-executor` (this agent, whose receipt the
  orchestrator writes on completion), `feature-review`, `pr-author`, `collect_pr_context`, and
  `validate_orchestration_artifacts`. None of these can exist before this executor finishes.
- Writing them would require modifying `artifacts/orchestration/orchestrator-state.json`,
  which this execution is explicitly forbidden to touch.

**The live checkpoint was never overwritten.** It was read three times in total (the [P5-T1]
precheck, this re-run, and the read-only hook invocation below) and written zero times. The
[P7-T1] diff-scope audit independently confirms the path appears in no modified, staged, or
untracked set.

## Standing acceptance evidence

The [P5-T2] fixture-path run is cited as the standing primary acceptance evidence:
`hook-e2e-allow.2026-07-25T17-19.md` records the fixed hook exiting **0** against
`<FEATURE>/evidence/other/completion-passing-checkpoint.2026-07-25T17-19.json`, a checkpoint
proven at exit 0 by the same `--require-complete --require-model-routing` validator command,
through the real Python subprocess seam.

## Supplementary read-only verification against the live checkpoint (fail-closed still holds)

Because the live checkpoint genuinely fails validation, it doubles as a fail-closed test of
the fixed hook on the real subprocess path. This run modifies nothing.

Command (POSIX-shell env-var prefix form; literal payload, inner double quotes not escaped):

```bash
CLAUDE_HOOK_INPUT='{"output":"DONE: issue #413 fix complete."}' pwsh -File .claude/hooks/validate-orchestrator-output.ps1
```

EXIT_CODE: **1**

Output Summary: the hook **blocked**, emitting

```text
ROUTING_CONTRACT_BLOCKED: Checkpoint completion validation failed: step6_status is pending. ... Checkpoint missing successful MCP receipt: validate_orchestration_artifacts.
```

This confirms three things on the live path after the fix:

1. The gate is **not weakened**: a genuine validator failure (exit 1) still blocks DONE.
2. `ErrorText` still carries the validator's real error lines, which are surfaced verbatim in
   the block message — the `{ HasErrors, ErrorText }` contract is intact.
3. The block reason is correctly `ROUTING_CONTRACT_BLOCKED:` rather than
   `MODEL_ROUTING_BLOCKED:`, because none of the error text matches
   `model_routing_receipts|complexity_assessments`. The discrimination logic works unchanged.

Contrast with the defect: before the fix, the hook returned exit 1 for **both** this failing
checkpoint and a passing one, quoting the success line as the block reason in the latter case.
After the fix, exit 1 here and exit 0 in `hook-e2e-allow.2026-07-25T17-19.md` — the gate now
discriminates.

## Verdict

Task satisfied via the authorized skip branch: the documented constraint is recorded with the
validator's non-zero precheck output as proof, the [P5-T2] fixture-path run is cited as the
standing acceptance evidence, and the live checkpoint was never overwritten. The supplementary
read-only run additionally demonstrates fail-closed behavior on the live path.
