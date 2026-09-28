# Baseline — Heading Inventory of `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` (Issue #586)

Timestamp: 2026-08-28T22-02

Task: [P0-T4]
Feature: docs/features/active/2026-08-28-atomic-preflight-convergence-586
Target file: `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`
Revision inspected: `HEAD` = `56dcad93cc3767de1191e89807fa31c248c4c87d`

## Command 1 — heading count

Command: git grep -c "^## " HEAD -- .claude/skills/remediation-handoff-atomic-planner/SKILL.md

EXIT_CODE: 0

Output Summary:

```
HEAD:.claude/skills/remediation-handoff-atomic-planner/SKILL.md:10
```

The command printed one line in the `<rev>:<path>:<count>` form. Its trailing colon-delimited count field is `10`, which equals the count the plan states for this file at baseline. No discrepancy.

## Command 2 — heading list

Command: git grep -n "^## " HEAD -- .claude/skills/remediation-handoff-atomic-planner/SKILL.md

EXIT_CODE: 0

Output Summary: 10 heading lines printed, matching the count recorded by Command 1. The list ends with `## Context Package (When Required)` at line 115, which equals the last heading the plan states for this file at baseline. Verbatim output:

```
HEAD:.claude/skills/remediation-handoff-atomic-planner/SKILL.md:10:## When to Use This Skill
HEAD:.claude/skills/remediation-handoff-atomic-planner/SKILL.md:20:## Full Handoff Chain
HEAD:.claude/skills/remediation-handoff-atomic-planner/SKILL.md:48:## Trigger Conditions
HEAD:.claude/skills/remediation-handoff-atomic-planner/SKILL.md:57:## Required Remediation Inputs
HEAD:.claude/skills/remediation-handoff-atomic-planner/SKILL.md:65:## Required Artifacts
HEAD:.claude/skills/remediation-handoff-atomic-planner/SKILL.md:84:## Plan Shape
HEAD:.claude/skills/remediation-handoff-atomic-planner/SKILL.md:96:## Preflight Sub-Loop
HEAD:.claude/skills/remediation-handoff-atomic-planner/SKILL.md:105:## Execution and Reaudit
HEAD:.claude/skills/remediation-handoff-atomic-planner/SKILL.md:111:## Exit Gate
HEAD:.claude/skills/remediation-handoff-atomic-planner/SKILL.md:115:## Context Package (When Required)
```

## Baseline Heading Titles in File Order

1. `## When to Use This Skill` (line 10)
2. `## Full Handoff Chain` (line 20)
3. `## Trigger Conditions` (line 48)
4. `## Required Remediation Inputs` (line 57)
5. `## Required Artifacts` (line 65)
6. `## Plan Shape` (line 84)
7. `## Preflight Sub-Loop` (line 96)
8. `## Execution and Reaudit` (line 105)
9. `## Exit Gate` (line 111)
10. `## Context Package (When Required)` (line 115)

Notes for Phase 1 section boundaries, derived from the list above and recorded here so the later tasks do not have to re-derive them:

- `## Required Artifacts` at line 65 is followed by `## Plan Shape` at line 84, so the `## Required Artifacts` section spans lines 65 through 83 at baseline. [P1-T13] adds the `### Cycle-Document Sweep Scope` subsection inside that span.
- `## Preflight Sub-Loop` at line 96 is followed by `## Execution and Reaudit` at line 105, so the `## Preflight Sub-Loop` section spans lines 96 through 104 at baseline. [P1-T10], [P1-T11], and [P1-T12] write inside that span.
- Phase 1 adds no `## ` heading to this file, so [P2-T7] asserts this count unchanged at 10.
