# Main-Session Execution Exception Runbook

## Cue

Use this runbook when the orchestrator records an `exception` response because a required delegated executor cannot write the planned `.agents/skills/` files under its active permission profile, and the user explicitly approves main-session execution for the same approved plan.

## Prerequisites

- The active checkpoint is `artifacts/orchestration/orchestrator-state.json`.
- The active feature folder is `docs/features/active/2026-06-24-harden-orchestrate-skill-232`.
- The approved plan is `docs/features/active/2026-06-24-harden-orchestrate-skill-232/plan.2026-06-24T15-45.md`.
- The user has provided explicit approval to continue in the main session.
- The main session has workspace write access to the planned files.

## Step-by-step Instructions

1. Confirm the delegated executor block is recorded in the checkpoint with `blocked_reason: delegation_launch_failed`.
2. Confirm the user approval message is present in the conversation before editing files directly in the main session.
3. Record the exception in `artifacts/orchestration/orchestrator-state.json` under `human_interaction.requirements[]` with `response: exception` and this runbook path.
4. Execute only the approved plan tasks that the delegated executor was blocked from performing.
5. Write validation evidence under `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/<kind>/`.
6. Do not treat the exception as a general delegation bypass for future runs.

## Verification

- The checkpoint contains this runbook path.
- The changed files remain within the approved plan scope.
- The final evidence artifacts identify the commands run, exit codes, and output summaries.
- The final response reports that main-session execution was an approved exception.

## Source and Citation

- Source: `.agents/skills/human-exception-runbook/SKILL.md`
- updated_at: 2026-06-24
