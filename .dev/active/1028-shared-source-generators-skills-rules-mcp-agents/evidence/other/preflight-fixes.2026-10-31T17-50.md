# Preflight Fixes — Issue 1028 (PQ-2 option (a) revision)

Timestamp: 2026-10-31T17-50
Plan: docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/plan.2026-10-30T18-30.md

1. [P0-T1] | wording, decided-status coverage | The pass rule named only the `decided by owner` status, while PQ-2 carries `decided by coordinator under owner standing instruction (option (a), 2026-10-31)`. Spec `## Owner Decisions` states that this status is handled the same way as `decided by owner`, and the plan's `## Owner Questions` preamble states that [P0-T1] treats PQ-2 as a decided row. The task text now names both decided statuses and states the follow condition for each: OQ-6 as before; PQ-2 when `## Scope Boundary` states the zero-diff rule with the single append-only `extensions/drm-copilot/jest.config.cjs` exemption and [P0-T6], [P1-T22] and [P6-T10] enforce it. The assertion is unchanged; the edit removes the ambiguity about which rule applies to PQ-2.
2. ## Scope Boundary (exemption item) | incomplete citation | "in the blast radius of item 1003" now reads "items 1003 and 1006". The run manifest on `origin/parallel/bugs-1001-1002-1003-1006-plan` lists `extensions/drm-copilot/jest.config.cjs` under both items. The exemption mechanism is unchanged: [P0-T6] already requires the merge commit of every manifest item to be an ancestor of the merge base.
3. ## Owner Questions, PQ-2 row | incomplete citation | "(item 1003's blast radius)" now reads "(in the blast radius of items 1003 and 1006)", for the same reason as fix 2.

Validation after the fixes: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` exited 0 ("plan validation passed"), and the MCP `validate_orchestration_artifacts` (`artifact_type: plan`) returned ok.
