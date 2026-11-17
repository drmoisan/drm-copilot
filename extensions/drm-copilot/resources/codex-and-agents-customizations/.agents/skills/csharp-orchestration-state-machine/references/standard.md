# Gold Standard: csharp-orchestration-state-machine

## Objective

Checkpoint schema and resume protocol for long-running C# orchestration workflows. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Canonical Checkpoint Location: `artifacts/orchestration/csharp-orchestrator-state.json`.
- **OB-2** Required Checkpoint Fields: The checkpoint records `objective`, `change_budget_estimate`, `path_selected` (`small` or `large`), `promotion-type`, `short-name`, `relativeFile`, `long-name`, `issue-num`, `feature-folder`, `work-mode` (`minor-audit`, `full-feature` or `full-bug`, with legacy `full` normalized to `full-feature` before persistence), `plan-path` (the minimal or full plan path), `completed_steps`, `next_step` and `last_updated`, and a short-path run also persists `small_path_qc_summary`, `small_path_audit_artifacts`, `bootstrap_mode` (`manual-bootstrap` or `auto-small-dev`), `phase0_execution_summary` and `resume_after_manual_bootstrap` (the next step token).
- **OB-3** Update Protocol: Write checkpoint after every completed orchestration sub-step.
- **OB-4** Resume Protocol: On invocation the orchestrator reads the checkpoint if it exists, resumes from `next_step` without re-running `completed_steps` when the checkpoint is incomplete, starts at phase-0 intake when the checkpoint is missing or completed, and resets the checkpoint and starts phase-0 when the user explicitly requests a restart.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Canonical Checkpoint Location, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Required Checkpoint Fields, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Update Protocol, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Resume Protocol, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-1, OB-2, OB-3, OB-4) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
