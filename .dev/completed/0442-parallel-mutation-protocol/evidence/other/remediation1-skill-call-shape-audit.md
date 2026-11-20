# Remediation Cycle 1 — Skill Call-Shape Audit and Unnecessary-Edit Check

Timestamp: 2026-08-09T08-25

Task: [P5-T7]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
State at capture: [P5-T1] through [P5-T6] applied (three skills corrected, three mirrors written)

## Check 1 — Every occurrence across `.claude` and the bundle

Command: `grep -rn "decide_admission\|recolor_unstarted" .claude extensions/drm-copilot/resources/claude-customizations`
EXIT_CODE: 0

| File:line | Occurrence | Argument list | Verdict |
| --- | --- | --- | --- |
| `.claude/skills/parallel-add/SKILL.md:69` | `decide_admission(candidate, conflict_edges, in_flight, current_cohort_members=current_cohort_members)` | four arguments, the fourth keyword-only | **MIGRATED** — matches `## Mandated Signatures` |
| `.claude/skills/parallel-add/SKILL.md:77` | `recolor_unstarted(unstarted_items, conflict_edges, pinned, current_generation, current_cohort=current_cohort)` | five arguments, the fifth keyword-only | **MIGRATED** |
| `.claude/skills/parallel-remove/SKILL.md:81` | `recolor_unstarted(unstarted_items, conflict_edges, pinned, current_generation, current_cohort=current_cohort)` (wrapped across lines 81-82) | five arguments, the fifth keyword-only | **MIGRATED** |
| `.claude/skills/parallel-orchestrate/SKILL.md:598` | prose reference "the recolor through `recolor_unstarted`" | no argument list | no change required |
| `.claude/skills/parallel-orchestrate/SKILL.md:606` | `recolor_unstarted(unstarted_items, conflict_edges, pinned, current_generation, current_cohort=current_cohort)` | five arguments, the fifth keyword-only | **MIGRATED** ([P5-T3], drift-requeue append contract) |
| `.claude/skills/parallel-close/SKILL.md:65` | "Do not call `recolor_unstarted` as part of a close." | **a PROHIBITION on calling the function at all**; states no argument list | **NO CHANGE REQUIRED** — a prohibition cannot carry a stale call shape |
| the six corresponding lines in `extensions/drm-copilot/resources/claude-customizations/.claude/skills/**` | identical to their `.claude/**` originals | identical | **MIGRATED** via the byte-for-byte mirrors ([P5-T4] through [P5-T6]) |

**No four-argument `recolor_unstarted` call shape and no three-argument `decide_admission` call
shape remains anywhere in `.claude` or in the bundle.** Every occurrence either names the new
signature or is the `parallel-close` prohibition, which needs no change.

One further match under `.claude/agent-memory/atomic-planner/` is agent-memory prose about this
remediation cycle, not a documented call shape, and is excluded from the table.

This check also discharges the documentation half of [P3-T8]'s acceptance, which [P3-T8] recorded
as **PENDING-PHASE-5** because the tasks that migrate these lines ([P5-T1], [P5-T2], [P5-T3]) and
mirror them ([P5-T4] through [P5-T6]) are Phase 5 tasks and the plan's phase ordering is binding.

## Check 2 — No unnecessary skill edit

Command: `git diff --numstat a9e2463c -- .claude/skills/parallel-close/SKILL.md`
EXIT_CODE: 0
Output Summary: **empty output** — `.claude/skills/parallel-close/SKILL.md` shows **no diff** against
the pinned base `a9e2463c`. Its line 65 is a prohibition on calling `recolor_unstarted` during a
close, so it correctly required no change and was not edited.

## Output Summary

Twelve occurrences enumerated with file and line across `.claude` and the bundle. Four documented
call shapes are MIGRATED to the mandated signatures (two in `parallel-add`, one in
`parallel-remove`, one in `parallel-orchestrate`), each with its argument list confirmed; one prose
reference carries no argument list; one is a prohibition needing no change; and the six bundle-mirror
lines are byte-identical to their originals. `parallel-close/SKILL.md` shows no diff against
`a9e2463c`, confirming no unnecessary skill edit was made.
