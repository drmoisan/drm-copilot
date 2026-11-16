# Gold Standard: make-skill-template

## Objective

Create new Agent Skills from prompts or by duplicating this template. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Prerequisites: Understanding of what the skill should accomplish.
- **OB-2** Creating a New Skill: CRITICAL: The `description` is the PRIMARY mechanism for automatic skill discovery.
- **OB-3** Example: Complete Skill Structure: A skill folder holds a required `SKILL.md` and optional `LICENSE.txt`, `scripts/`, `references/`, `assets/`, and `templates/` entries.
- **OB-4** Quick Start: Duplicate This Template: Copy the `make-skill-template/` folder.
- **OB-5** Validation Checklist: A new skill has a lowercase, hyphenated folder name that its `name` field matches exactly, a single-quoted `description` of 10 to 1024 characters that states what the skill does and when to use it, a body under 500 lines, and bundled assets under 5MB each.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Prerequisites, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Creating a New Skill, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Example, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Quick Start, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Validation Checklist, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
