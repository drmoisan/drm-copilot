# Baseline — Heading Inventory of `.claude/skills/atomic-plan-contract/SKILL.md` (Issue #586)

Timestamp: 2026-08-28T22-02

Task: [P0-T3]
Feature: docs/features/active/2026-08-28-atomic-preflight-convergence-586
Target file: `.claude/skills/atomic-plan-contract/SKILL.md`
Revision inspected: `HEAD` = `56dcad93cc3767de1191e89807fa31c248c4c87d`

## Command 1 — heading count

Command: git grep -c "^## " HEAD -- .claude/skills/atomic-plan-contract/SKILL.md

EXIT_CODE: 0

Output Summary:

```
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:17
```

The command printed one line in the `<rev>:<path>:<count>` form. Its trailing colon-delimited count field is `17`, which equals the count the plan states for this file at baseline. No discrepancy.

## Command 2 — heading list

Command: git grep -n "^## " HEAD -- .claude/skills/atomic-plan-contract/SKILL.md

EXIT_CODE: 0

Output Summary: 17 heading lines printed, matching the count recorded by Command 1. The list ends with `## Mode-Specific Mandatory Plan Gates` at line 206, which equals the last heading the plan states for this file at baseline. Verbatim output:

```
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:10:## When to Use This Skill
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:17:## Canonical Plan Format
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:24:## Short-Path Minimal Plan Contract
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:53:## Minimal-Audit Directive Contract (Small Path)
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:69:## Phase-0-Only Execution Contract (Small Path)
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:79:## Phase 0 Requirements
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:92:## Non-Overridable Evidence Path Clause
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:107:## Coverage Evidence Contract (Mandatory when policy requires coverage)
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:119:## Final QA Loop (Required for Code/Test Changes)
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:131:## No-SKIPPED Rule for Planned Command Tasks
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:138:## Expect-Fail Test Tasks
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:142:## Preflight Validation (Planner ↔ Executor)
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:152:## Validator Gate (Mandatory)
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:164:## Wrap-Tolerant Assertion Authoring (Mandatory)
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:184:## Plan-Path Continuity Contract (Mandatory)
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:194:## Mode source precedence (Mandatory)
HEAD:.claude/skills/atomic-plan-contract/SKILL.md:206:## Mode-Specific Mandatory Plan Gates
```

## Baseline Heading Titles in File Order

1. `## When to Use This Skill` (line 10)
2. `## Canonical Plan Format` (line 17)
3. `## Short-Path Minimal Plan Contract` (line 24)
4. `## Minimal-Audit Directive Contract (Small Path)` (line 53)
5. `## Phase-0-Only Execution Contract (Small Path)` (line 69)
6. `## Phase 0 Requirements` (line 79)
7. `## Non-Overridable Evidence Path Clause` (line 92)
8. `## Coverage Evidence Contract (Mandatory when policy requires coverage)` (line 107)
9. `## Final QA Loop (Required for Code/Test Changes)` (line 119)
10. `## No-SKIPPED Rule for Planned Command Tasks` (line 131)
11. `## Expect-Fail Test Tasks` (line 138)
12. `## Preflight Validation (Planner ↔ Executor)` (line 142)
13. `## Validator Gate (Mandatory)` (line 152)
14. `## Wrap-Tolerant Assertion Authoring (Mandatory)` (line 164)
15. `## Plan-Path Continuity Contract (Mandatory)` (line 184)
16. `## Mode source precedence (Mandatory)` (line 194)
17. `## Mode-Specific Mandatory Plan Gates` (line 206)

Note for [P1-T1]: entries 11 and 12 (`## Expect-Fail Test Tasks` at line 138 and `## Preflight Validation (Planner ↔ Executor)` at line 142) are adjacent at baseline. [P1-T1] inserts `## Planner Adversarial Self-Review (Mandatory)` between them, which is what [P2-T7] measures as an end-state count of 18.
