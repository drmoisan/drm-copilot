# CLI Require-Complete Confirmation (P6-T3, AC-21)

Timestamp: 2026-10-29T14-51
Command: poetry run python SCRATCH/issue-992-write-checkpoints.py . SCRATCH; poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state SCRATCH/issue-992-adopted.json --require-complete; poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state SCRATCH/issue-992-no-record.json --require-complete
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Both runs exit 1 because the corpus checkpoints are partial (they carry only routing-contract fields). The adopted checkpoint's output contains no line naming `issue_adoption` or `new_active_feature_folder`. The no-record checkpoint's output contains the rule-10 error and the missing-receipt line for `new_active_feature_folder`.

## Run 1: `SCRATCH/issue-992-adopted.json` (checkpoint of `valid-large-waives-feature-folder-with-record.json`)

EXIT_CODE: 1. Lines naming `issue_adoption`: 0. Lines naming `new_active_feature_folder`: 0.

Expected lines from the partial checkpoint (all present, none related to adoption):

- 18 `Checkpoint missing required key: <key>` lines (objective, change_budget_estimate, path_selected, short-name, relativeFile, long-name, work-mode, plan-path, completed_steps, next_step, last_updated, step5_status through step10_status, blocked_reason).
- 42 `Checkpoint delegation receipt #<n> missing key: <key>` lines (six receipts, seven keys each: step, agent_id, skill_source, started_at, completed_at, result_signal, artifact_paths).
- `Checkpoint completion validation failed: pr_gate must be an object with keys: pr_number, pr_url, head_branch, head_sha.`
- `Checkpoint completion validation failed: ci_gate must be an object with keys: conclusion, head_sha, verified_at.`

## Run 2: `SCRATCH/issue-992-no-record.json` (checkpoint of `waives-new-active-feature-folder.json`)

EXIT_CODE: 1. The same 62 partial-checkpoint lines as run 1, followed by:

- `Checkpoint missing successful MCP receipt: potential_to_issue.`
- `Checkpoint missing successful MCP receipt: new_active_feature_folder.`
- `Checkpoint issue_adoption.feature_folder_record must be an object when waiving new_active_feature_folder.`
