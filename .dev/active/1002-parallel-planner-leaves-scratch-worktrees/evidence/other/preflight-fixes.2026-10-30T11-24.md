# Preflight Fixes

Timestamp: 2026-10-30T11-24
Plan: docs/features/active/2026-10-30-parallel-planner-leaves-scratch-worktrees-1002/plan.2026-10-30T06-59.md

## Fix 1

- Location: `## Tree Verification Recorded at Planning Time`, third bullet.
- Defect class: citation correction.
- Finding: the bullet stated that `tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py` names the planner only in a docstring. The module also uses the `parallel-planner-state` artifact type in test names, a constant, and imports. It reads neither planner-surface file, so the disposition (unaffected) is unchanged.
- Change: the bullet now states that the module references only the `parallel-planner-state` artifact type and reads neither file.

## Fix 2

- Location: `## Design Decisions (fixed by this plan)`, Design Decision 6.
- Defect class: asserting-test disposition omitted (validator-blind class; meaning kept).
- Finding: `test_no_unqualified_spec_section_citation_under_claude` in `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` scans the Markdown documents under `.claude/`, including both edited files, and rejects a `spec.md` citation followed by a section sign. The new Read access text names `spec.md`. The module is already in the contract module list, so the test runs, but the constraint was not listed among the wording constraints.
- Change: Design Decision 6 now lists that constraint and names the asserting test.

## Fix 3

- Location: `[P5-T13]`.
- Defect class: conflict with the `acceptance-criteria-tracking` skill (Check-Off Protocol rule 3, "Preserve text"); correction keeps the asserted check-off.
- Finding: the task instructed appending the evidence path to each checked spec bullet, which modifies criterion text.
- Change: the task now changes only `- [ ]` to `- [x]`, takes each AC's evidence path from `## Acceptance Criteria Traceability`, and its acceptance requires every AC checked, its traceability evidence on disk, and no criterion text changed.
