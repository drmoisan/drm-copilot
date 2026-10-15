# Follow-Up Note: `/parallel-add` Issue-Adoption Residual (P9-T6, Issue #849)

Timestamp: 2026-10-10T15-17
Command: none (documentation note; no command executed)
EXIT_CODE: 0

## Residual

`/parallel-add` preparation children for issue-number items do not receive the issue-adoption instruction. This change adds the issue-adoption line to the `/parallel-plan` preparation fan-out (`.claude/skills/parallel-plan/SKILL.md`, `## Preparation Fan-Out`) and to kickoff element 4 of `.claude/skills/parallel-orchestrate/SKILL.md`, but `.claude/skills/parallel-add/SKILL.md` was not edited. A preparation child admitted through `/parallel-add` for an existing GitHub issue therefore does not record a top-level `issue_adoption` object and can still fail completion on the missing `potential_to_issue` and promotion-entry receipts.

## Reason for exclusion

`.claude/skills/parallel-add/SKILL.md` is out of scope for issue #849 because it overlaps with the work tracked in issue #843. Editing it here would create a conflicting change on the same file.

## Coverage that is in place

The execution child is covered for every item regardless of admission route: kickoff element 4 of `.claude/skills/parallel-orchestrate/SKILL.md` now instructs the execution child to verify the issue read-only and to record its own `issue_adoption` object, because the preparation checkpoint does not carry over to execution. The validator change (rule 9 accepting an absent `potential_record` for `transferred` and `filed_before_orchestration` origins) applies in all three runtimes to any checkpoint, including one produced by a `/parallel-add` child that records an adoption.

## Recommended follow-up item (for the orchestrator to file)

Title: `/parallel-add` preparation children for issue-number items should receive the issue-adoption line

Scope: after issue #843 lands, add the same issue-adoption delegation line used in `/parallel-plan` `## Preparation Fan-Out` to the `/parallel-add` preparation delegation prompt for issue-number items only (omitted for potential-entry items), update the bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`, and extend `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` with a contract case for the `/parallel-add` prompt (single occurrence, no mode marker, no digits, no active feature-folder path).

Output Summary: Residual recorded: `/parallel-add` preparation children for issue-number items lack the issue-adoption instruction; excluded because of overlap with #843; the execution child is covered by the parallel-orchestrate element-4 change; recommended follow-up item stated for the orchestrator to file. No file outside the feature folder was written.
