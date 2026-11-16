# Gold Standard: policy-compliance-order

## Objective

Repository policy compliance order and hard constraints. Use when an agent must read mandatory policy files, apply repo-wide constraints, or restate policy precedence without duplicating blocks across agents. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Required Policy Reading Order (Baseline): Python: `.agents/skills/python/SKILL.md`, `.agents/skills/python-suppressions/SKILL.md`.
- **OB-2** Hard Constraints (Baseline): Do NOT modify policy documents under `.agents/skills/` or `.agents/skills/`.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Required Policy Reading Order (Baseline), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Hard Constraints (Baseline), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-1, OB-2) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
