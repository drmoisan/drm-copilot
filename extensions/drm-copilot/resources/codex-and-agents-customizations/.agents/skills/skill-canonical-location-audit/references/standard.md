# Gold Standard: skill-canonical-location-audit

## Objective

Audit skills for canonical-location duplication. Use when ensuring a canonical location for a given item is defined in exactly one skill and duplicates are flagged. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Scope: Applies to every `SKILL.md` file at any depth under the repository's skill folder.
- **OB-2** Audit Workflow: The audit runs three steps in order: it inventories canonical-location statements by reading each skill file, extracting its explicit canonical location statements (paths, folders and file names) and grouping them by the item they describe; it detects duplicates by verifying that exactly one skill defines each item's canonical location and flagging any item whose canonical location two or more skills define; and it reports the results in a short report that lists each item with a duplicated canonical location, the conflicting skills, and a consolidation recommendation naming the single skill to keep as the source of truth.
- **OB-3** Output Template (Suggested): The suggested output gives, for each item with a duplicated canonical location, the canonical item name, the skills with definitions of it, and a recommendation that keeps one named skill as canonical and removes the duplicates from the others.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Scope, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Audit Workflow, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Output Template (Suggested), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-1, OB-2, OB-3) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
