# AC Evidence Index (Issue #479, [P6-T1])

Timestamp: 2026-08-17T02-35

All 41 acceptance criteria appear below with their discharging task IDs (from the plan's AC
traceability table) and the concrete evidence produced so far. Paths are relative to
`docs/features/active/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/`.

Legend: **DONE** = evidence recorded and the AC checkbox is checked in `spec.md`;
**PENDING P7** = the AC additionally requires a Phase 7 artifact and its checkbox is still
unchecked.

## D1 — Barrier semantics

| AC | Tasks | Evidence | State |
|---|---|---|---|
| AC1 | P1-T7, P1-T16 | `.claude/skills/parallel-orchestrate/SKILL.md` `## Cohort Barrier and Max-Concurrency Slot Filling` carries the per-edge sentence verbatim; `evidence/qa-gates/p1-pytest.2026-08-17T00-45.md` | DONE |
| AC2 | P1-T10 | `.claude/agents/parallel-orchestrator.md` rewritten; `grep -n "only after every cohort"` returns zero, recorded in `evidence/other/d1-grep-gates.2026-08-17T00-47.md` | DONE |
| AC3 | P1-T8, P1-T11, P1-T12 | Four orchestrate-skill sites plus add/remove rewritten; `git grep` gates in `evidence/other/d1-grep-gates.2026-08-17T00-47.md`; anchors in `evidence/other/d1-anchor-verification.2026-08-17T00-12.md` | DONE |
| AC4 | P1-T17 | `evidence/other/d1-grep-gates.2026-08-17T00-47.md` — gate zero matches, positive control 1 | DONE |
| AC5 | P1-T9, P1-T10, P1-T13 | Progress-indicator paragraph in the skill, the agent, and `docs/features/templates/parallel/parallel-status.md:32`; invariant 14 untouched (`git diff` of the rules file shows only invariant 4, M4, A7) | DONE |
| AC6 | P1-T9 | "The two layers fail closed differently" block in the skill | DONE |
| AC7 | P1-T7, P1-T9 | "Safety argument" paragraph quoting the unchanged `:100-103` text | DONE |
| AC8 | P1-T9 | "Availability argument" paragraph | DONE |
| AC9 | P1-T7, P1-T14, P1-T16 | `grep -cF` of the pinned sentence returns 1; `BOUNDARIES_REGENERATION_FRAGMENTS` unmodified; `evidence/qa-gates/p1-pytest.2026-08-17T00-45.md` | DONE |
| AC10 | P1-T14, P1-T16 | `COHORT_BARRIER_FRAGMENTS` diff; `test_orchestrate_skill_section_states_its_required_obligations` passes (36 passed) | DONE |
| AC11 | P1-T4 | `scripts/dev_tools/parallel_mutation_protocol.py:321` uses `highest_pinned_cohort`; `grep -n "current_cohort + 1"` returns zero; `evidence/other/p1t2-compaction-accounting.2026-08-17T00-20.md` | DONE |
| AC12 | P1-T5, P1-T16 | `test_multi_cohort_pinned_frontier_pushes_above_the_highest_pinned_index` | DONE |
| AC13 | P1-T6, P1-T16 | `test_single_frontier_offset_matches_the_previous_behavior`; `evidence/other/p1t3-test-compaction.2026-08-17T00-28.md` | DONE |
| AC14 | P5-T1 (diff), P1-T16 (Layer 2), **P7-T11** (Layer-1 Pester) | `evidence/other/cross-cutting-gates.2026-08-17T02-25.md` records the diff half and the 64-passing Layer-2 suites; the Layer-1 Pester run is P7-T11 | **PENDING P7** |

## D2 — Concurrency ceiling

| AC | Tasks | Evidence | State |
|---|---|---|---|
| AC15 | P2-T2, P2-T3, P2-T4 | Six constants at 32; zero `= 8` matches; `evidence/other/d2-anchor-verification.2026-08-17T00-52.md` | DONE |
| AC16 | P2-T2/T3/T4, P2-T10, **P7-T12** | `evidence/qa-gates/p2-pytest.2026-08-17T01-05.md` (Python/bash fixture parity), `p2-jest.2026-08-17T01-06.md` (TS); the bats lane is P7-T12 | **PENDING P7** |
| AC17 | P2-T2 (docstring), P2-T5 | Per-file `through 32` positive assertions and the `through 8` zero-match gate | DONE |
| AC18 | P2-T5 | Rewritten A7 section with all five content elements; `grep -n "symmetry"` returns zero | DONE |
| AC19 | P2-T10, P5-T2 | `evidence/other/cross-cutting-gates.2026-08-17T02-25.md`; epic suite 192 passed, bound text still `1 through 8` | DONE |
| AC20 | P2-T10 | `test_invariant_m4_accessor_resolves_concurrency` passes unmodified | DONE |
| AC21 | P2-T6/T7/T8, P2-T10, **P7-T12** | pytest and Jest halves recorded; the bats half is P7-T12 | **PENDING P7** |
| AC22 | P2-T6, P2-T7, P2-T8 | `evidence/other/backward-compat-corpus.2026-08-17T02-05.md`; zero `9`/`12` out-of-range exemplars remain | DONE |
| AC23 | P2-T7, P2-T8, P2-T10, **P7-T12** | Boolean-rejection cases retained in all three runtimes; the bats half is P7-T12 | **PENDING P7** |

## D3 — Lane-grouping assertion seam

| AC | Tasks | Evidence | State |
|---|---|---|---|
| AC24 | P3-T1 | M8 in `.claude/rules/parallel-orchestration.md`; the rules diff deletes only invariant 4, M4, and the A7 opening | DONE |
| AC25 | P3-T2, P3-T5, P3-T12 | `evidence/qa-gates/p3-pytest.2026-08-17T02-00.md`; `TestM8KeyAbsent` byte-identical comparison | DONE |
| AC26 | P3-T5, P3-T12 | 22 M8 tests covering every negative class plus both positive forms | DONE |
| AC27 | P3-T6/T7/T8, P3-T12 (Python lane), **P7-T12** (bash lane) | Python parity lane 104 passed; `evidence/other/backward-compat-corpus.2026-08-17T02-05.md` records a LOCAL bash probe with `54 fixtures compared; mismatches: 0`; the bats harness itself is P7-T12 | **PENDING P7** |
| AC28 | P3-T3, P3-T4 | `evidence/qa-gates/p3-lane-assertion-coverage.2026-08-17T01-30.md` — 100% line, 100% branch, 43 tests, module 499 lines | DONE |
| AC29 | P3-T9 | `## Cohort Seeding` step 2 and the completion-report line-item, both advisory-only | DONE |
| AC30 | P3-T3, P3-T10 | `evidence/other/d3-scope-gates.2026-08-17T01-55.md` gates (a) and (b) | DONE |
| AC31 | P3-T10 | `evidence/other/d3-scope-gates.2026-08-17T01-55.md` gate (c) | DONE |

## D4 — Bounded preparation fan-out

| AC | Tasks | Evidence | State |
|---|---|---|---|
| AC32 | P4-T1 | `## Preparation Fan-Out` rewritten; `grep -n "launch ALL"` returns zero | DONE |
| AC33 | P4-T2 | `.claude/agents/parallel-planner.md` frontmatter description and `## Delegation Model` | DONE |
| AC34 | P4-T1 | `/parallel-add` intake paragraph and the deferred-key paragraph | DONE |
| AC35 | P4-T4 | `evidence/qa-gates/p4-pytest.2026-08-17T02-15.md` — 23 passed, Markdown-only diff | DONE |

## Cross-cutting

| AC | Tasks | Evidence | State |
|---|---|---|---|
| AC36 | P1-T15, P2-T9, P3-T11, P4-T3 | Per-pair `cmp` at each phase plus a full byte-identity sweep over all 161 tracked `.claude` files: zero missing, zero differing | DONE |
| AC37 | P5-T3 | `evidence/other/cross-cutting-gates.2026-08-17T02-25.md` | DONE |
| AC38 | P3-T13, P3-T12, **P7-T12** | `evidence/other/backward-compat-corpus.2026-08-17T02-05.md`; the bash-lane half is P7-T12 | **PENDING P7** |
| AC39 | P2-T3, P3-T7, P5-T4 | `evidence/other/cross-cutting-gates.2026-08-17T02-25.md`, including the by-name fixture review | DONE |
| AC40 | P5-T5 | `evidence/other/cross-cutting-gates.2026-08-17T02-25.md`, all three diff-scoped conditions | DONE |
| AC41 | **P7-T1 through P7-T14** | Not yet produced | **PENDING P7** |

## Summary

- Total AC items: **41**
- Checked off in `spec.md` at this point: **34**
- Pending Phase 7: **7** — AC14, AC16, AC21, AC23, AC27, AC38, AC41

## Known pre-existing condition carried through every phase

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
fails in this working copy because a live gitignored `git worktree` at
`.claude/worktrees/agent-afc9f4fd25ec235a5/` places untracked agent log files inside the
`.claude` tree the test enumerates. Established as pre-existing at the untouched baseline
commit `a43deb73` in `evidence/baseline/python-test-baseline.2026-08-16T23-55.md`, and absent
in CI where the directory does not exist. Mirror parity (AC36) is discharged by direct per-pair
byte comparison instead.
