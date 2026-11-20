# Preflight Fixes — Issue 1164 Remediation Plan (cycle 1, R2 confirming preflight)

Timestamp: 2026-11-11T05-39
Plan: docs/features/active/parallel-planner-time-based-edge-rule-1164/remediation-plan.2026-11-11T04-47.md

Each fix below is a task-text correction made in place. No task was added, removed, or reordered, and no asserted value changed. The round-1 record `preflight-fixes.2026-11-11T05-22.md` is unchanged.

1. [P1-T5] | literal clarification | The `-ForEach` data of `rejects a path whose read title carries the write form <Form>` is now stated as hashtables `@{ Form = '<value>' }`, one per listed value. Pester expands `<Form>` in an It name from a `Form` key of the data; with a plain string list the placeholder has no backing variable and fails under strict mode. The fifteen values and the asserted outcome (no derived path) are unchanged.
