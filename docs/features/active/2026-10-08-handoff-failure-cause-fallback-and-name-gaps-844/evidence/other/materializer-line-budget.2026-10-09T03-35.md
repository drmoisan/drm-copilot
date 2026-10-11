# Materializer Line Budget (P3-T10)

Timestamp: 2026-10-09T03-35
Task: [P3-T10]
Command: Grep tool, pattern `^`, output mode count, over each path below (post-format)
EXIT_CODE: 0

| File | Expected (approx.) | Observed | Limit | Result |
| --- | --- | --- | --- | --- |
| extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts | 491 | 494 | 500 | within budget |
| extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-request.ts | 150 | 155 | 500 | within budget |

The materializer count is 3 above the planning estimate because Prettier wraps the `describeHandoffFailureCause("destination-projection", error)` call across four lines, as the plan anticipated in P3-T6.

Output Summary: Pass. Both files are at or under 500 lines (494 and 155). LINE BUDGET EXCEEDED does not apply.
