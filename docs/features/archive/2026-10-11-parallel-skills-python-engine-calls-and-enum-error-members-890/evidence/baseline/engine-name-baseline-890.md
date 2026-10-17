# Engine-Name Baseline (Issue #890)

Timestamp: 2026-10-12T20-10
Task: P0-T9
Command: `git grep -n -E "parallel_mutation_protocol|decide_admission|recolor_unstarted|build_add_entry|decide_close|build_close_entry|build_requeue_entry" -- .claude/skills/parallel-add/SKILL.md .claude/skills/parallel-close/SKILL.md .claude/skills/parallel-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-close/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`
EXIT_CODE: 0
Output Summary: 22 matched lines (expected 22): eleven per tree, identical line numbers in the repository tree and the bundled mirror. The parallel-add positions are shifted by +9 relative to the plan (see the line-number corrections below).

## Line-number corrections (planned vs. actual)

The merge of origin/main (85ffd5aae, merge commit e22dbe55c) brought in #885 (PR #913), which inserted an issue-adoption block after step 2 of `parallel-add/SKILL.md`. The parallel-close and parallel-orchestrate positions are unchanged.

| File | Planned line | Actual line |
| --- | --- | --- |
| parallel-add | 100 | 109 |
| parallel-add | 101 | 110 |
| parallel-add | 108 | 117 |
| parallel-add | 150 | 159 |
| parallel-close | 48 | 48 |
| parallel-close | 49 | 49 |
| parallel-close | 55 | 55 |
| parallel-close | 65 | 65 |
| parallel-orchestrate | 666 | 666 |
| parallel-orchestrate | 821 | 821 |
| parallel-orchestrate | 829 | 829 |

The same eleven actual positions apply in the mirror tree.

## Matched lines

```text
.claude/skills/parallel-add/SKILL.md:109:   `decide_admission(candidate, conflict_edges, in_flight, current_cohort_members=current_cohort_members)`
.claude/skills/parallel-add/SKILL.md:110:   from `scripts/dev_tools/parallel_mutation_protocol.py`.
.claude/skills/parallel-add/SKILL.md:117:     `recolor_unstarted(unstarted_items, conflict_edges, pinned, current_generation, current_cohort=current_cohort, highest_pinned_cohort=highest_pinned_cohort)`.
.claude/skills/parallel-add/SKILL.md:159:   `build_add_entry` from `scripts/dev_tools/parallel_mutation_protocol.py`:
.claude/skills/parallel-close/SKILL.md:48:2. **Gate the close on no item being in flight.** Call `decide_close(items)` from
.claude/skills/parallel-close/SKILL.md:49:   `scripts/dev_tools/parallel_mutation_protocol.py`. It raises the dedicated rejection exception
.claude/skills/parallel-close/SKILL.md:55:   `build_close_entry` from `scripts/dev_tools/parallel_mutation_protocol.py`:
.claude/skills/parallel-close/SKILL.md:65:   UNCHANGED and `cohorts[]` is not rewritten. Do not call `recolor_unstarted` as part of a close.
.claude/skills/parallel-orchestrate/SKILL.md:666:`scripts/dev_tools/parallel_mutation_protocol.py`. It decides; it never applies. Item keys are
.claude/skills/parallel-orchestrate/SKILL.md:821:engine's `build_requeue_entry` constructor and the recolor through `recolor_unstarted`:
.claude/skills/parallel-orchestrate/SKILL.md:829:  `recolor_unstarted(unstarted_items, conflict_edges, pinned, current_generation, current_cohort=current_cohort, highest_pinned_cohort=highest_pinned_cohort)`,
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md:109:   `decide_admission(candidate, conflict_edges, in_flight, current_cohort_members=current_cohort_members)`
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md:110:   from `scripts/dev_tools/parallel_mutation_protocol.py`.
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md:117:     `recolor_unstarted(unstarted_items, conflict_edges, pinned, current_generation, current_cohort=current_cohort, highest_pinned_cohort=highest_pinned_cohort)`.
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md:159:   `build_add_entry` from `scripts/dev_tools/parallel_mutation_protocol.py`:
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-close/SKILL.md:48:2. **Gate the close on no item being in flight.** Call `decide_close(items)` from
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-close/SKILL.md:49:   `scripts/dev_tools/parallel_mutation_protocol.py`. It raises the dedicated rejection exception
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-close/SKILL.md:55:   `build_close_entry` from `scripts/dev_tools/parallel_mutation_protocol.py`:
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-close/SKILL.md:65:   UNCHANGED and `cohorts[]` is not rewritten. Do not call `recolor_unstarted` as part of a close.
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md:666:`scripts/dev_tools/parallel_mutation_protocol.py`. It decides; it never applies. Item keys are
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md:821:engine's `build_requeue_entry` constructor and the recolor through `recolor_unstarted`:
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md:829:  `recolor_unstarted(unstarted_items, conflict_edges, pinned, current_generation, current_cohort=current_cohort, highest_pinned_cohort=highest_pinned_cohort)`,
```
