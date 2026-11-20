# Preflight Fixes

Timestamp: 2026-11-03T12-47
Plan: docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/plan.2026-11-03T06-52.md
Issue: #1047

Each entry below is a trivial in-place fix to task text. No task was added, removed, or reordered, and no task box was checked.

1. [P0-T2] | stale expected path set | The merge-base diff of the branch already lists the promoted lifecycle record `docs/features/potential/promoted/2026-10-31-parallel-add-and-plan-resume-prepared-items-without-replanning.md` (added by the promotion commit), so "only paths under `<FEATURE>/`" could not be met. The acceptance now names that record as the one permitted path outside `<FEATURE>/`. The assertion still states that the baseline holds feature documentation only.
2. [P5-T2] | text precision within the task's own section | The `## Prerequisites` edit now also states that `--after` and `--band` flags are not items, so the existing multi-item rejection applies to positional items only, as `spec.md` `## Inputs / Outputs` requires. Without it, `/parallel-add <item> --after <earlier>` reads as a multi-item argument under the existing `$ARGUMENTS` bullet.
3. [P5-T3] | text precision against AC-13 | Step 3 now states that each `--after` pair is recorded as a top-level `precedence[]` entry `{before, after, source, recorded_at}` with `source` `operator`, which is the AC-13 wording; the task previously named only the separating-edge use.
4. [P5-T5] | validator-blind pinned-text defect | The phrase "no `-Pinned` option" would place the word `pinned` in `parallel-plan/SKILL.md`, which `test_parallel_planner_no_scratch_worktree_contracts.py::test_skill_contains_no_pinned_word_and_no_forbidden_fragments` rejects case-insensitively. The task now says "no pinning option" and states that the skill text avoids the word.
5. [P5-T8] | missing anchor | The two new `SECTION_OBLIGATION_CASES` entries now name their heading constants, `KICKOFF_HEADING` and `MERGE_ON_GREEN_HEADING`, which the `(case_id, heading, fragments)` tuple shape requires.
6. [P6-T5] | validator-blind untracked-file defect | `check_quality_tiers.py` discovers projects from `git ls-files`, so an untracked `.claude/lib/parallel-admission/` directory leaves the new `quality-tiers.yml` entry stale (QT007, exit 1). The task now states the precondition that the three lib files are in the index. The assertion (exit 0, discovered-project count one above baseline) is unchanged.

Verification: `mcp__drm-copilot__validate_orchestration_artifacts` (artifact_type plan) re-run after the fixes.
