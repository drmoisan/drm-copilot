# Acceptance-Criteria Check-Off (Issue #479, [P7-T15])

Timestamp: 2026-08-17T03-15

AC source: `docs/features/active/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/spec.md`
(work mode `full-bug`, so `spec.md` is the SOLE AC source and `user-story.md` is correctly absent).

Verification: `re.findall(r"- \[([ x])\] (AC\d+):", spec_text)` reports **41 items, 41 checked,
0 remaining**.

Paths below are relative to the feature folder.

## D1 — Barrier semantics

| AC | State | Discharging tasks | Evidence |
|---|---|---|---|
| AC1 | `[x]` | P1-T7, P1-T16 | Per-edge sentence verbatim in `.claude/skills/parallel-orchestrate/SKILL.md`; `evidence/qa-gates/p1-pytest.2026-08-17T00-45.md` |
| AC2 | `[x]` | P1-T10 | `.claude/agents/parallel-orchestrator.md:190+`; `grep "only after every cohort"` zero matches |
| AC3 | `[x]` | P1-T8, P1-T11, P1-T12 | `evidence/other/d1-anchor-verification.2026-08-17T00-12.md`, `d1-grep-gates.2026-08-17T00-47.md` |
| AC4 | `[x]` | P1-T17 | `evidence/other/d1-grep-gates.2026-08-17T00-47.md` — gate exit 1 (zero matches), positive control 1 |
| AC5 | `[x]` | P1-T9, P1-T10, P1-T13 | Progress-indicator prose in skill, agent, and template; rules diff touches no invariant-14 line |
| AC6 | `[x]` | P1-T9 | "The two layers fail closed differently" block |
| AC7 | `[x]` | P1-T7, P1-T9 | "Safety argument" paragraph quoting the byte-unchanged `:100-103` text |
| AC8 | `[x]` | P1-T9 | "Availability argument" paragraph |
| AC9 | `[x]` | P1-T7, P1-T14, P1-T16 | `grep -cF` of the pinned sentence = 1; `BOUNDARIES_REGENERATION_FRAGMENTS` unmodified; 36 surface tests pass |
| AC10 | `[x]` | P1-T14, P1-T16 | `COHORT_BARRIER_FRAGMENTS` diff; `test_orchestrate_skill_section_states_its_required_obligations` passes |
| AC11 | `[x]` | P1-T4 | `parallel_mutation_protocol.py:321` uses `highest_pinned_cohort`; `grep "current_cohort + 1"` zero matches; both docstrings rewritten |
| AC12 | `[x]` | P1-T5, P1-T16 | `test_multi_cohort_pinned_frontier_pushes_above_the_highest_pinned_index` |
| AC13 | `[x]` | P1-T6, P1-T16 | `test_single_frontier_offset_matches_the_previous_behavior`; test-diff review shows signature-only edits |
| AC14 | `[x]` | P5-T1, P1-T16, P7-T11 | `evidence/other/cross-cutting-gates.2026-08-17T02-25.md` (zero `.ps1`, no barrier module or port); Layer-2 suites 64 passed; Layer-1 Pester suite 56 tests, 0 failures, unmodified (`evidence/qa-gates/final-powershell-test.2026-08-17T02-57.md`) |

## D2 — Concurrency ceiling

| AC | State | Discharging tasks | Evidence |
|---|---|---|---|
| AC15 | `[x]` | P2-T2/T3/T4 | Six constants at 32; zero `= 8` matches in any runtime |
| AC16 | `[x]` | P2-T2/T3/T4, P2-T10, P7-T12 | All five messages interpolate the constant (zero hardcoded `through 32`); Python/bash parity corpus green in both lanes (`p2-pytest`, `final-shell-qc` `ok 89`); TS core tests green (`p2-jest`) |
| AC17 | `[x]` | P2-T2, P2-T5 | Per-file `through 32` positive assertions; `through 8` zero-match gate across all four prose files plus the `_parallel_state_common.py` docstring |
| AC18 | `[x]` | P2-T5 | Rewritten A7 with all five content elements; `grep "symmetry"` zero matches |
| AC19 | `[x]` | P2-T10, P5-T2 | Epic files absent from the diff; 192 epic tests pass; epic bound text still `1 through 8` |
| AC20 | `[x]` | P2-T10 | `test_invariant_m4_accessor_resolves_concurrency` passes unmodified |
| AC21 | `[x]` | P2-T6/T7/T8, P2-T10, P7-T12 | accept-32 / reject-33 in pytest, Jest, and bats; bats `ok 99`/`ok 105` in run 31998496925 |
| AC22 | `[x]` | P2-T6/T7/T8 | `evidence/other/backward-compat-corpus.2026-08-17T02-05.md`; zero `9`/`12` out-of-range exemplars remain |
| AC23 | `[x]` | P2-T7/T8, P2-T10, P7-T12 | Boolean-rejection cases retained in Python, TypeScript, and bash; bats `ok 103` |

## D3 — Lane-grouping assertion seam

| AC | State | Discharging tasks | Evidence |
|---|---|---|---|
| AC24 | `[x]` | P3-T1 | M8 in `.claude/rules/parallel-orchestration.md`; M7 and the Enum Ownership table untouched (rules diff deletes only invariant 4, M4, A7 opening) |
| AC25 | `[x]` | P3-T2, P3-T5, P3-T12 | `TestM8KeyAbsent` byte-identical comparison; `evidence/qa-gates/p3-pytest.2026-08-17T02-00.md` |
| AC26 | `[x]` | P3-T5, P3-T12 | 25 M8 tests covering every negative class plus both positive block-sequence forms |
| AC27 | `[x]` | P3-T6/T7/T8, P3-T12, P7-T12 | Python lane 104 passed; bash lane `ok 89` reproduces every corpus fixture; `ok 110` accepts a block-sequence M8 fixture; local probe `54 fixtures compared; mismatches: 0` |
| AC28 | `[x]` | P3-T3, P3-T4 | `evidence/qa-gates/p3-lane-assertion-coverage.2026-08-17T01-30.md` — 499 lines, 100% line, 100% branch, 43 tests |
| AC29 | `[x]` | P3-T9 | `## Cohort Seeding` step 2 and the required completion-report line-item, both advisory-only |
| AC30 | `[x]` | P3-T3, P3-T10 | `evidence/other/d3-scope-gates.2026-08-17T01-55.md` gates (a) and (b) |
| AC31 | `[x]` | P3-T10 | `evidence/other/d3-scope-gates.2026-08-17T01-55.md` gate (c) |

## D4 — Bounded preparation fan-out

| AC | State | Discharging tasks | Evidence |
|---|---|---|---|
| AC32 | `[x]` | P4-T1 | `## Preparation Fan-Out` rewritten; `grep "launch ALL"` zero matches |
| AC33 | `[x]` | P4-T2 | `.claude/agents/parallel-planner.md` frontmatter description and `## Delegation Model` |
| AC34 | `[x]` | P4-T1 | `/parallel-add` incremental-admission paragraph and the deferred `max_preparation_concurrency` paragraph |
| AC35 | `[x]` | P4-T4 | `evidence/qa-gates/p4-pytest.2026-08-17T02-15.md` — 23 passed unmodified, Markdown-only diff |

## Cross-cutting

| AC | State | Discharging tasks | Evidence |
|---|---|---|---|
| AC36 | `[x]` | P1-T15, P2-T9, P3-T11, P4-T3 | Per-pair `cmp` at each phase plus a full sweep over all 161 tracked `.claude` files: zero missing, zero differing. `parallel-items-validate.sh` was NOT edited, so its conditional mirror does not apply |
| AC37 | `[x]` | P5-T3 | No `templates/parallel` path under extensions resources; `pack-manifests/core.json` absent from the diff |
| AC38 | `[x]` | P3-T13, P3-T12, P7-T12 | `evidence/other/backward-compat-corpus.2026-08-17T02-05.md` itemizes all 6 changed and 13 added fixtures; both parity lanes green |
| AC39 | `[x]` | P2-T3, P3-T7, P5-T4 | Divergence-class files absent from the diff; by-name fixture review in `evidence/other/cross-cutting-gates.2026-08-17T02-25.md` |
| AC40 | `[x]` | P5-T5 | All three diff-scoped conditions in `evidence/other/cross-cutting-gates.2026-08-17T02-25.md` |
| AC41 | `[x]` | P7-T1 through P7-T14 | `evidence/qa-gates/final-toolchain-summary.2026-08-17T03-12.md` (seven-stage mapping) and `final-coverage-delta.2026-08-17T03-08.md` (every threshold met, no regression) |

## Summary

- Source: `spec.md`
- Total AC items: **41**
- Checked off (delivered): **41**
- Remaining (unchecked): **0**
- Items remaining: none

Every AC is backed by a named evidence artifact or a recorded command result. No AC was checked
without evidence, and no assertion, test, or threshold was weakened to reach a check.
