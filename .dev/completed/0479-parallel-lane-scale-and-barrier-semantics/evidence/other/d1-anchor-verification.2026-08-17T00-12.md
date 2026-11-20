# D1 Anchor Re-Verification (Issue #479, [P1-T1])

Timestamp: 2026-08-17T00-12

Command: targeted `Read` of each cited range at HEAD `a43deb731c9e11296b19d5b81c233ff81625704c`

EXIT_CODE: 0

## Output Summary

All 20 cited anchors from research section D1.1 are VERIFIED at their stated locations. Zero
drift. No anchor required relocation.

| Anchor | Disposition | Observed text at the anchor |
|---|---|---|
| `.claude/skills/parallel-orchestrate/SKILL.md:118-123` | VERIFIED | `**Cohort barrier.** Cohort `N+1` branches from `main` only after every cohort-`N` item is `merged` or `worktree_removed`. ... A blocked item ... holds the barrier and cohort `N+1` does not start.` |
| `.claude/skills/parallel-orchestrate/SKILL.md:157-159` | VERIFIED | Numbered item 1 of `## Per-Item Branch and Worktree Lifecycle`: `Run one `git fetch origin main` immediately before each cohort launch, ... Record the fetched tip.` |
| `.claude/skills/parallel-orchestrate/SKILL.md:311-314` | VERIFIED | `5. On loop exhaustion, the parent records the terminal `merge_status: blocked_ci_loop_limit` ... so it holds the cohort barrier defined in `## Cohort Barrier and Max-Concurrency Slot Filling`.` The `MERGE_CONFLICT_FRAGMENTS`-pinned fragment `` terminal `merge_status: blocked_ci_loop_limit` `` sits on `:311`; the barrier-scope clause is `:312-314`. |
| `.claude/skills/parallel-orchestrate/SKILL.md:476` | VERIFIED | `third scheduling input — the current cohort index `current_cohort` that the pinned items occupy` (phrase begins on `:475`, `pinned items occupy` lands on `:476`). |
| `.claude/skills/parallel-orchestrate/SKILL.md:505-510` | VERIFIED | `**Two design corrections (spec 1.2).**` narrative, ending `...returned a deferred candidate to cohort 0, the current cohort, whenever the cohort barrier held `current_cohort` at 0.` |
| `.claude/skills/parallel-orchestrate/SKILL.md:100-103` | VERIFIED (must remain byte-unchanged) | `Items within a cohort are non-conflicting by construction — a cohort is an independent set in the conflict graph — so they may branch from the same `main` tip and may merge in any order. ... GitHub produces a merge commit.` |
| `.claude/skills/parallel-orchestrate/SKILL.md:609` | VERIFIED | Lead-in: `...the requeue is recorded through the mutation engine's `build_requeue_entry` constructor and the recolor through `recolor_unstarted`:` |
| `.claude/skills/parallel-orchestrate/SKILL.md:616-618` | VERIFIED | `:616` `Its call shape is the five-argument form`; `:617` the `recolor_unstarted(...)` call; `:618` `where `current_cohort` is required and keyword-only.` |
| `.claude/agents/parallel-orchestrator.md:190-193` | VERIFIED | `1. **Cohort barrier.** Cohort `N+1` branches from `main` only after every cohort-`N` item is `merged` or `worktree_removed`. ... so a blocked item holds the barrier.` |
| `.claude/skills/parallel-add/SKILL.md:81` | VERIFIED | `recolor_unstarted(unstarted_items, conflict_edges, pinned, current_generation, current_cohort=current_cohort)` (single line). |
| `.claude/skills/parallel-add/SKILL.md:89-90` | VERIFIED | Phrase wraps: `:89` ends `...it is F3's top-level `current_cohort` field and is the index the pinned items`; `:90` begins `occupy.` Confirms the plan's note that a whole-phrase grep cannot detect this site. |
| `.claude/skills/parallel-remove/SKILL.md:81-82` | VERIFIED | Call wraps two lines: `:81` `recolor_unstarted(unstarted_items, conflict_edges, pinned,`; `:82` `current_generation, current_cohort=current_cohort)`. |
| `.claude/skills/parallel-remove/SKILL.md:87-90` | VERIFIED | `:87-88` `` `current_cohort` is F3's top-level field, read from the re-verified durable state, and is the index the pinned items occupy. `` — single-line match on `:88`. |
| `docs/features/templates/parallel/parallel-status.md:32` | VERIFIED | `- `current_cohort`: _(index of the cohort currently launched)_` |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:154-159` | VERIFIED | `COHORT_BARRIER_FRAGMENTS` = the global sentence fragment (`:155-156`), `"max_concurrency"` (`:157`), `"ascending item-key order"` (`:158`). |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:169-176` | VERIFIED | `MERGE_CONFLICT_FRAGMENTS`, including `` "terminal `merge_status: blocked_ci_loop_limit`" `` at `:171`. Must not be edited. |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:184-192` | VERIFIED | `BOUNDARIES_REGENERATION_FRAGMENTS`, including `` "Every cohort transition, meaning every `current_cohort` increment" `` at `:187`. Must not be edited. |
| `scripts/dev_tools/parallel_mutation_protocol.py:253-262` | VERIFIED | The `current_cohort` `Args:` entry justifying the index by the global increment rule (`...the cohort barrier increments `current_cohort` only on durable confirmation that every cohort item is `merged` or `worktree_removed`...`). |
| `scripts/dev_tools/parallel_mutation_protocol.py:321-327` | VERIFIED | Offset comment `:321-326` (`The pinned items hold index ``current_cohort`` for as long as they run...`) and `:327` `cohort_offset = current_cohort + 1 if crosses_pinned else current_cohort`. |
| `scripts/dev_tools/_parallel_mutation_models.py:301-311` | VERIFIED | `RecolorResult` docstring: `...every index is at or above the run's ``current_cohort``, and strictly above it whenever an unstarted item conflicts with a pinned item...` |

## Additional in-file sites found during verification (not in the research inventory)

- `scripts/dev_tools/parallel_mutation_protocol.py:222-225` — the `recolor_unstarted` summary
  docstring also states `every unstarted index is shifted to ``current_cohort + 1`` or above`.
  This is the same claim as `:253-262` and is rewritten by `[P1-T4]` under the same task
  authority ("Update the docstrings in `parallel_mutation_protocol.py`"). Recorded here so the
  edit is traceable rather than silent.

## File line counts at verification time

| File | Lines |
|---|---|
| `.claude/skills/parallel-orchestrate/SKILL.md` | 971 |
| `.claude/agents/parallel-orchestrator.md` | 257 |
| `.claude/skills/parallel-add/SKILL.md` | 152 |
| `.claude/skills/parallel-remove/SKILL.md` | 176 |
| `docs/features/templates/parallel/parallel-status.md` | 78 |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | 323 |
| `scripts/dev_tools/parallel_mutation_protocol.py` | 499 (at the 500-line ceiling minus 1; `[P1-T2]` compaction required) |
| `scripts/dev_tools/_parallel_mutation_models.py` | 469 |
