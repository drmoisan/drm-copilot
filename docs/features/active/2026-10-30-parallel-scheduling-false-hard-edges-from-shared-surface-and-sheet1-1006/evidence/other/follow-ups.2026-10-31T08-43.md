# Follow-Ups (issue #1006)

Timestamp: 2026-10-31T08-43
Task: P8-T18
Command: git grep -n -i 'three token shapes' -- .claude/skills/parallel-plan/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md
EXIT_CODE: 0
Output Summary: one follow-up note recorded; no issue filed by this run.

## Stale token-shape count in the parallel-plan skill

- Location: `.claude/skills/parallel-plan/SKILL.md` and its byte-identical bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`, in the sentence stating that the extractor rejects "three token shapes that were never write claims".
- State: the sentence was already stale before this change, because the rule listed four shapes. After issue #1006 the rule in `.claude/rules/parallel-orchestration.md` lists five, the fifth being a default spreadsheet sheet name (`Sheet` or `Chart` followed by ASCII digits).
- Why it is not fixed here: the spec places this edit out of scope (Scope & Non-Goals), and the plan's scope check requires the skill to be unchanged against the merge base.
- Suggested change: replace the count with a reference to `### Read-by-mandate classification` in `.claude/rules/parallel-orchestration.md`, so the skill does not restate a count that drifts, and update both copies in the same change.

## Residuals documented in the rule (no action required)

- A demoted entry still matched by a `shared_surface_globs` pattern stays shared through the glob; the bundled glob list is empty.
- Demoting a separator-free surface, or removing `quality-tiers.yml` from `shared_surfaces`, ends separator-free token acceptance for that name; the planner append obligation and `detect_escaped_paths` remain the backstops.
