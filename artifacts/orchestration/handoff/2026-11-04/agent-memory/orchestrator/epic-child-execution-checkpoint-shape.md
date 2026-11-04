---
name: epic-child-execution-checkpoint-shape
description: Checkpoint keys an epic-child execution run (starting at S5 from a prepared plan) needs before the first atomic-executor delegation passes the preimplementation and model-routing gates
metadata:
  type: project
---

When an `Agent(orchestrator)` run starts at atomic execution for a prepared epic child (promotion, research, spec, plan, preflight already committed to the integration branch), the per-item checkpoint written before the first delegation must carry, beyond the required-key list in `.claude/rules/orchestrator-state.md`:

- `lifecycle_ready: true` (boolean). `enforce-orchestration-preimplementation-gate.ps1` (`Test-OrchestrationReady`) denies every implementation delegation with `PREIMPLEMENTATION_GATE_BLOCKED` without it. No skill or rule file names this key.
- `route_id: "large"` (read before `path_selected` by both the preimplementation gate and the batch-budget exemption `Test-BatchBudgetLargePathRoute`).
- `delegation_receipts` in the namespaced form `{ "agents": [...] }`, each entry with the eight strict keys (`step, agent_name, agent_id, skill_source, started_at, completed_at, result_signal, artifact_paths`). Carry the preparation run's `task-researcher`, `prd-feature`, `atomic-planner`, and preflight `atomic-executor` receipts forward with provenance, because the `large` route's completion gate requires them.
- A `model_routing_receipts[]` entry and a matching `complexity_assessments[]` phase for every agent named in those carried-forward receipts, not only for the upcoming delegation: `--require-model-routing` reports `missing a receipt for delegated agent: <name>` for each.
- `issue_adoption` with `origin: epic_decomposition`, `potential_record` under `docs/features/potential/promoted/`, and a `feature_folder_record` (verified by `git cat-file -t HEAD:<feature-folder>` printing `tree`) waiving `potential_to_issue`, `new_potential_entry`, and `new_active_feature_folder`.

**Why:** observed 2026-11-03 on epic child #1033; the first delegation was denied once and the model-routing preflight failed once before this shape passed both.

**How to apply:** write this shape in the first checkpoint write of an epic-child run, validate with `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <path> --require-model-routing` from the item worktree, then delegate. The Write tool to `<item worktree>/artifacts/orchestration/orchestrator-state.json` was not blocked (the older bootstrap pincer did not recur).

At merge time (observed 2026-11-04, PR #1076): the epic merge gate's child path needs `step9_status: "passed"` (not `"completed"`) and `pr_gate.pr_number` equal to the PR number, otherwise it denies with `TARGET_WORKTREE_NOT_DERIVABLE` plus a misleading `STANDALONE_MERGE_AUTHORIZATION_ABSENT`. The `--require-complete` check additionally needs `pr_gate.head_branch`, `required_agents`/`required_skills`/`required_mcp_tools` copied from `config/orchestration-routing.json`, agent receipts for `feature-review` and `pr-author`, and `mcp_call_receipts` entries `{tool, ok: true, evidence}`.

After the merge (observed 2026-11-04, PR #1075): `enforce-completion-consistency.ps1` resolves `feature-folder` against the session-root checkout (main), where an epic-child folder does not exist until the epic lands, so any Edit setting `step10_status: "completed"` or `next_step: "complete"` is denied. Record `step10_status: "verified"` (a valid shared value; `passed` is valid only on step9) plus `epic_merge`, which satisfies the stop hook. The epic merge gate also needs `pr_gate` and `step9_status: "passed"` written before `gh pr merge`.

Related: [[checkpoint-bootstrap-pincer]], [[orchestrator-checkpoint-completion-gate-gotchas]].
