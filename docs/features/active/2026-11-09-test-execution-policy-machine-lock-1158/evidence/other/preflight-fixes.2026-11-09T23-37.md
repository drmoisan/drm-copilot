# Preflight Fixes (round three, confirming preflight)

Timestamp: 2026-11-09T23-37
Plan: docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/plan.2026-11-09T16-31.md

Each entry is a defect fixed in task text. No task was added, removed, or reordered, and no task acceptance condition changed. The earlier records `preflight-fixes.2026-11-09T22-35.md` and `preflight-fixes.2026-11-09T23-00.md` are unchanged.

1. [P1-T1] | incomplete reference to an enumerated rule set | "one case per validation rule" pointed at the spec configuration table, while the unknown-top-level-key rule is stated in the sentence below that table. Spec AC1 already lists it among the required `Test-TestExecutionPolicyDocument` cases, so the task text now names it explicitly. The AC meaning is unchanged.
2. [P6-T3] | spec statement with no failing test in the task's own test list | spec `## Constraints & Risks` (MCP gap) and AC5 require the brief copies to state the MCP gap until the extension release, and P6-T3 already writes that statement into `## PowerShell Route and PoshQC MCP Limits`, but the per-copy test list carried no token for it. The list now also requires `extension release` within that section of each copy. A section-scoped search of the current canonical brief confirmed that the section does not contain this token today, so the added check fails if the statement is omitted. The AC meaning is unchanged.

Each fix was checked against the rules the plan enforces. The fix text contains no line or commit citation, no host path, no restated tool route, no placeholder in an asserted token, and no promotional wording.
