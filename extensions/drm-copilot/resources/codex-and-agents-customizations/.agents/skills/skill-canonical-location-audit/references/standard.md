# Gold Standard: skill-canonical-location-audit

## Objective

Audit skills for canonical-location duplication. Use when ensuring a canonical location for a given item is defined in exactly one skill and duplicates are flagged. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Scope: Applies to every `SKILL.md` file at any depth under the repository's skill folder.
- **OB-2** Audit Workflow: 1) Inventory canonical-location statements.
- **OB-3** Output Template (Suggested): Item: <canonical item name>.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Scope, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Audit Workflow, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Output Template (Suggested), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-1, OB-2, OB-3) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
