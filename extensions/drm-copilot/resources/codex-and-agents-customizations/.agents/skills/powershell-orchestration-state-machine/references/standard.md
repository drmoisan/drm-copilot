# Gold Standard: powershell-orchestration-state-machine

## Objective

Checkpoint schema and resume protocol for long-running PowerShell orchestration workflows. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Canonical Checkpoint Location: `artifacts/orchestration/powershell-orchestrator-state.json`.
- **OB-2** Required Checkpoint Fields: `path_selected` (`small` or `large`).
- **OB-3** Update Protocol: Write checkpoint after every completed orchestration sub-step.
- **OB-4** Resume Protocol: On invocation: 1) Read checkpoint if it exists. 2) If incomplete, resume from `next_step` without re-running `completed_steps`. 3) If missing or completed, start at phase-0 intake. 4) If user explicitly requests restart, reset checkpoint and start phase-0.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Canonical Checkpoint Location, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Required Checkpoint Fields, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Update Protocol, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Resume Protocol, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-1, OB-2, OB-3, OB-4) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
