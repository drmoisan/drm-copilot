# Phase 1 Gate Suite (Issue #479, [P1-T16])

Timestamp: 2026-08-17T00-45

Command:
```
poetry run pytest tests/scripts/dev_tools -q
poetry run pytest tests/scripts/dev_tools -q --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

EXIT_CODE: 1 (first form) / 0 (second form)

## Output Summary

- First form: `1 failed, 3698 passed, 5 skipped in 5.25s`.
- Second form (the same suite with only the environmentally-blocked test deselected):
  `3698 passed, 5 skipped, 1 deselected in 4.77s`.
- The five skips are the pre-existing `manifest_m1_*` accessor-expectation skips, identical to
  the Phase 0 baseline.
- Passing count rose from the baseline 3696 (Phase 0 `tests/scripts/dev_tools` scope) to 3698,
  the two regression tests added by `[P1-T5]` and `[P1-T6]`.

### The single failure is the Phase 0 pre-existing environmental failure

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
fails on `.claude/worktrees/agent-afc9f4fd25ec235a5/.agent_logs/atomic_executor_2026-08-15_151958.log`,
byte-for-byte the same assertion recorded at baseline in
`evidence/baseline/python-test-baseline.2026-08-16T23-55.md`. Cause: a live gitignored
`git worktree` under `.claude/worktrees/`. Not caused by, and not affected by, this feature.

### Suites specifically discharged by this run

| Suite | Result |
|---|---|
| `test_parallel_orchestrator_surface_contracts.py` (incl. `test_orchestrate_skill_section_states_its_required_obligations`, which consumes the rewritten `COHORT_BARRIER_FRAGMENTS` and the unmodified `BOUNDARIES_REGENERATION_FRAGMENTS` and `MERGE_CONFLICT_FRAGMENTS`) | 36 passed |
| `test_parallel_mutation_recolor.py` (13 pre-existing + the 2 new regressions) | 15 passed |
| `test_parallel_mutation_protocol_properties.py` | 180 passed |
| `test_parallel_orchestrator_state_cohort_barrier*` (Layer-2 barrier suites, unmodified) | passed within the run |

## AC coverage

- AC9 — `BOUNDARIES_REGENERATION_FRAGMENTS` passes unmodified; the pinned sentence
  `` Every cohort transition, meaning every `current_cohort` increment `` is present verbatim
  (`grep -cF` reported 1).
- AC10 — `COHORT_BARRIER_FRAGMENTS` now pins the per-edge sentence and
  `test_orchestrate_skill_section_states_its_required_obligations` passes.
- AC12 — `test_multi_cohort_pinned_frontier_pushes_above_the_highest_pinned_index` passes.
- AC13 — `test_single_frontier_offset_matches_the_previous_behavior` passes, and every
  pre-existing recolor test passes with signature-only edits (`git diff` over the five caller
  test modules shows only argument-explosion reflow plus the added `highest_pinned_cohort=`
  keyword; no assertion line changed).
- AC14 (Layer-2 half) — the Layer-2 barrier pytest suite passes unmodified.
