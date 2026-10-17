# Repro After Fix, Invalid Checkpoint (Issue #464)

Timestamp: 2026-09-30T09-21
Command: poetry run python -m scripts.dev_tools.validate_orchestrator_state docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464/evidence/other/invalid-checkpoint.json
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- stdout: empty.
- stderr: 22 lines, one per missing required key, in validator order. The first line is `Checkpoint missing required key: objective` (the required line), followed by `change_budget_estimate`, `path_selected`, `promotion-type`, `short-name`, `relativeFile`, `long-name`, `issue-num`, `feature-folder`, `work-mode`, `plan-path`, `completed_steps`, `next_step`, `last_updated`, `step5_status` through `step10_status`, `delegation_receipts`, and `blocked_reason`, each prefixed `Checkpoint missing required key: `.
