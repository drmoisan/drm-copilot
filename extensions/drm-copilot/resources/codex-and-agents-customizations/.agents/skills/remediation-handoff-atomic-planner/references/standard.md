# Gold Standard: remediation-handoff-atomic-planner

## Objective

Reusable remediation trigger and atomic_planner handoff steps. Use when audits require remediation inputs and a delegated remediation plan. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Required Remediation Inputs: Each cycle creates `remediation/<timestamp>/remediation-inputs.md` in its own timestamped `remediation/` folder, holding an enumerated fix list with file paths, expected behavior, and verification commands, a do-not-do list that excludes scope creep, policy weakening, and silent skips, and exactly one mode line.
- **OB-2** Context Package (When Required): If the calling agent requires a context package, inline the specified audit artifacts, PR context artifacts, and any relevant plan files in the delegated prompt.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Required Remediation Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Context Package (When Required), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-1, OB-2) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
