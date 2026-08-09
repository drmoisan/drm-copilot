# Phase 4 `SKILL.md` Reserved-Section Append — Issue #440 (F7)

Timestamp: 2026-08-08T22-24

Task: [P4-T4]

Command: `git diff -U0 .claude/skills/parallel-orchestrate/SKILL.md`

EXIT_CODE: 0

## Section Name Used

`## Enforcement Hooks (F7)` — F5's reserved placeholder heading, verbatim.

This supersedes the plan's fallback name `## Cohort Barrier Enforcement (F7)`, per plan Binding
Constraint 2 and Frozen Constant 2 in
`docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/other/frozen-constants.2026-08-08T21-09.md`.
No new heading was created and the fallback name was not introduced anywhere in the file.

## Diff Scope Proof (single hunk, F7 region only)

```
 .claude/skills/parallel-orchestrate/SKILL.md | 50 +++++++++++++++++++++++++++-
 1 file changed, 49 insertions(+), 1 deletion(-)
```

Hunk header from `git diff -U0`:

```
@@ -441 +441,49 @@ Reserved for F6; content is appended by that feature and must not be relocated.
```

Exactly one hunk, anchored at line 441 — the F7 placeholder body line. The single deletion line is:

```
-Reserved for F7; content is appended by that feature and must not be relocated.
```

No other line in the file was deleted or modified. The `## Enforcement Hooks (F7)` heading line itself
is unchanged (it is outside the hunk).

## Reserved-Heading Survival and Order

Post-edit `grep -n "^## "` of the file, tail:

```
435:## Mutation Protocol (F6)
439:## Enforcement Hooks (F7)
491:## Radius Drift Detection (F8)
```

All three concurrent-feature reserved headings survive, in their original relative order. The F6
placeholder body (line 437) and the F8 placeholder body (line 493) are untouched — neither appears in
the diff. Nothing was relocated, reflowed, reordered, or retitled.

## Content Delivered

Under the reserved heading:

- **Layer 1**, `.claude/hooks/enforce-parallel-cohort-barrier.ps1` as a `PreToolUse` `Agent` hook, its
  `Parallel mode: true` activation marker, prompt-based target resolution, current-generation cohort
  projection, and the `PARALLEL_COHORT_BARRIER_BLOCKED` deny reason, including that `ci_green` does not
  satisfy the barrier and that same-cohort/later-cohort neighbours do not block Layer 1.
- **Layer 2**, `validate_cohort_barrier_ordering` reached at `parallel-orchestrator` `SubagentStop`
  time, emitting one `PARALLEL_COHORT_BARRIER_VIOLATION` message per violated edge, key-gated and
  adding no checkpoint fields.
- **Why neither layer alone closes the gap** — per-call hook visibility versus retrospective batch
  visibility.
- **The worktree removal gate** and its `PARALLEL_WORKTREE_REMOVAL_BLOCKED` deny reason.
- **The invocation-origin extension**, its `PARALLEL_INVOCATION_ORIGIN_BLOCKED` deny reason, the
  preserved allow paths, and the byte-identical epic reason string.

Cross-references to other sections are by exact heading text only
(`## Parallel-Mode Kickoff Parameter`, `## Cohort Barrier and Max-Concurrency Slot Filling`,
`## Worktree Cleanup`), never by position or line number.

File length after the edit: 493 lines (under the 500-line limit).

## Output Summary

The F7 content was appended into the existing reserved `## Enforcement Hooks (F7)` section, replacing
only its single placeholder body line. `git diff -U0` shows exactly one hunk at line 441 with 49
insertions and 1 deletion, that deletion being the F7 placeholder line. All three reserved headings —
`## Mutation Protocol (F6)`, `## Enforcement Hooks (F7)`, `## Radius Drift Detection (F8)` — survive in
their original order, and the F6 and F8 placeholder bodies are unchanged and absent from the diff. The
section documents both barrier layers, the rationale for requiring both, the worktree removal gate, and
the invocation-origin extension, referencing sibling sections by exact heading text. File is 493 lines.
