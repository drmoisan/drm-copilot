# Gold Standard: make-skill-template

## Objective

Produce the outcome that the make-skill-template skill exists for, with the same observable result in every tool that runs it. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Prerequisites: Understanding of what the skill should accomplish.
- **OB-2** Creating a New Skill: CRITICAL: The `description` is the PRIMARY mechanism for automatic skill discovery.
- **OB-3** Example: Complete Skill Structure: The skill defines its example: complete skill structure and applies it on every run.
- **OB-4** Quick Start: Duplicate This Template: Copy the `make-skill-template/` folder.
- **OB-5** Validation Checklist: The skill defines its validation checklist and applies it on every run.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Prerequisites, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Creating a New Skill, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Example, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Quick Start, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Validation Checklist, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
