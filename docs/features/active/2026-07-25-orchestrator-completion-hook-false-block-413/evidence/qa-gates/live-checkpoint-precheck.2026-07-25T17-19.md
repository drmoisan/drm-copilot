# Live-Checkpoint DONE-Gate Precheck (issue #413, [P5-T1])

Timestamp: 2026-07-25T17-19

Purpose: determine whether `artifacts/orchestration/orchestrator-state.json` currently
satisfies the DONE gate. This result selects the branch taken in [P5-T2]. The checkpoint is
owned by the enclosing orchestration and is **read only** by this execution.

Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json --require-complete --require-model-routing` (run at repo root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a0fcdf306557436df`)

EXIT_CODE: 1 (non-zero)

Output Summary (all lines emitted to stderr, per the validator CLI contract):

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

- 12 validation errors; exit code 1.
- The failures are entirely a consequence of the enclosing orchestration being mid-run:
  steps 6-10 are still `pending`, the PR and CI gates have not been recorded yet, and the
  downstream agent/MCP receipts (`atomic-executor`, `feature-review`, `pr-author`,
  `collect_pr_context`, `validate_orchestration_artifacts`) are not yet written. None of the
  errors is caused by, or related to, the change under test.
- This also independently corroborates the fix rationale: the validator emits its errors to
  stderr **and** returns a non-zero exit code, so the exit code alone discriminates failure.

## Branch selection for [P5-T2]

Because this precheck recorded a **non-zero** exit code, [P5-T2] takes the fixture branch:
build a completion-passing checkpoint fixture under
`<FEATURE>/evidence/other/`, prove it passes the same validator command at exit 0, and run
the hook against it with `-CheckpointPath`. The live
`artifacts/orchestration/orchestrator-state.json` MUST NOT be modified; it is owned by the
enclosing orchestration.
