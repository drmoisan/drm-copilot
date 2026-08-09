# Remediation Cycle 1 — Caller Migration Inventory for Both Changed Functions

Timestamp: 2026-08-09T07-05

Task: [P3-T8]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
Remediation cycle: 1
State at capture: [P3-T1] through [P3-T7] applied (both engine signatures and the docstrings
corrected). Phase 4 test migration and Phase 5 consumer migration have NOT yet run.

**Pyright is deliberately NOT run by this task.** After [P3-T1] and [P3-T3] made
`current_cohort_members` and `current_cohort` required keyword-only parameters, the
not-yet-migrated test call sites make a zero-error Pyright result impossible before Phase 4. The
zero-error gate is **[P4-T13]** and again **[P7-T3]**. The absence of a Pyright run here is
intentional per the plan, not an omission.

## Check 1 — Enumerate every occurrence

Command: `grep -rn "decide_admission\|recolor_unstarted" scripts tests .claude extensions docs/features/active/2026-08-07-parallel-mutation-protocol-442`
EXIT_CODE: 0

## Definitions and Non-Call References (no migration applicable)

| File:line | Kind | Status |
| --- | --- | --- |
| `scripts/dev_tools/parallel_mutation_protocol.py:113` | `__all__` entry `"decide_admission"` | N/A — export name |
| `scripts/dev_tools/parallel_mutation_protocol.py:117` | `__all__` entry `"recolor_unstarted"` | N/A — export name |
| `scripts/dev_tools/parallel_mutation_protocol.py:121` | `decide_admission` DEFINITION | MIGRATED — carries `*, current_cohort_members: frozenset[int]` |
| `scripts/dev_tools/parallel_mutation_protocol.py:200` | `recolor_unstarted` DEFINITION | MIGRATED — carries `*, current_cohort: int` |
| `scripts/dev_tools/parallel_mutation_protocol.py:142` | docstring cross-reference to `recolor_unstarted` | MIGRATED — describes the pinned-barrier offset |
| `scripts/dev_tools/_parallel_mutation_models.py:117` | `AdmissionOutcome` docstring reference | MIGRATED by [P3-T10] |
| `scripts/dev_tools/_parallel_mutation_models.py:222` | `AdmissionDecision` docstring reference | MIGRATED — unchanged text remains true |
| `scripts/dev_tools/_parallel_mutation_models.py:290` | `RecolorResult` docstring reference | MIGRATED by [P3-T7] — absolute-index and verbatim-write contract |
| `.claude/agent-memory/atomic-planner/feedback_fix_own_contract_not_defer.md:15` | agent-memory prose about this cycle | N/A — not a call site and not a documented call shape |

## Non-Test Python Call Sites

**There are ZERO non-test Python call sites of either function.** The engine is a pure library:
`decide_admission` and `recolor_unstarted` are defined in
`scripts/dev_tools/parallel_mutation_protocol.py` and are never invoked from any other module under
`scripts/`. In particular `scripts/dev_tools/parallel_mutation_abandon_cli.py` calls neither. No
production Python caller can therefore be stale, and this sub-clause of the acceptance criterion is
satisfied vacuously but verifiably.

## Test Call Sites — Classification

### `tests/scripts/dev_tools/test_parallel_mutation_admission.py` (created by [P2-T1])

| Line | Call | Status |
| --- | --- | --- |
| 77 | `decide_admission(candidate, conflict_edges, in_flight)` | **PENDING-PHASE-4** — migrated by [P4-T1] |

### `tests/scripts/dev_tools/test_parallel_mutation_recolor.py` (created by [P2-T3])

| Line | Call | Status |
| --- | --- | --- |
| 84 | `recolor_unstarted(unstarted, conflict_edges, pinned, START_GENERATION)` | **PENDING-PHASE-4** — migrated by [P4-T3] |

### `tests/scripts/dev_tools/test_parallel_mutation_protocol.py`

| Line | Call | Status |
| --- | --- | --- |
| 140 | `recolor_unstarted(unstarted, edges, pinned, START_GENERATION)` | **PENDING-PHASE-4** — inside `TestPinnedItemsNeverMove`, relocated and migrated by [P4-T4] |
| 153 | `recolor_unstarted(unstarted, edges, frozenset({99}), START_GENERATION)` | **PENDING-PHASE-4** — [P4-T4] |
| 168 | `recolor_unstarted([11], [(11, 21)], frozenset({21}), START_GENERATION)` | **PENDING-PHASE-4** — [P4-T4] |
| 181 | `recolor_unstarted([11, 21], [(11, 21)], frozenset({21}), START_GENERATION)` | **PENDING-PHASE-4** — [P4-T4] |
| 191 | `recolor_unstarted(unstarted, edges, frozenset({21}), START_GENERATION)` | **PENDING-PHASE-4** — [P4-T4] |
| 201 | `recolor_unstarted([11], [], frozenset(), START_GENERATION)` | **PENDING-PHASE-4** — [P4-T4] |
| 214 | `recolor_unstarted([11], [], frozenset(), START_GENERATION)` | **PENDING-PHASE-4** — the surviving call site, wrapped with `current_cohort=0` by [P4-T6] |
| 331 | `decide_admission(11, [(11, 21)], frozenset({21}))` | **PENDING-PHASE-4** — inside `TestAdmissionOverAllItems`, relocated and migrated by [P4-T2] |
| 339 | `decide_admission(11, [(11, 12)], frozenset({21}))` | **PENDING-PHASE-4** — [P4-T2] |
| 347 | `recolor_unstarted([11, 12], [(11, 12)], frozenset(), START_GENERATION)` | **PENDING-PHASE-4** — inside `TestAdmissionOverAllItems`, [P4-T2] |
| 357 | `decide_admission(11, [(12, 13)], frozenset({21}))` | **PENDING-PHASE-4** — [P4-T2] |
| 375 | `decide_admission(11, [edge], frozenset({21}))` | **PENDING-PHASE-4** — [P4-T2] |
| 382 | `decide_admission(11, [], frozenset()).candidate` | **PENDING-PHASE-4** — [P4-T2] |
| 391 | `decide_admission(11, edges, frozenset({21}))` | **PENDING-PHASE-4** — [P4-T2] |
| 402 | `decide_admission(11, edges, pinned) == decide_admission(...)` (two calls on the wrapped expression beginning at 402) | **PENDING-PHASE-4** — [P4-T2] |
| 409 | `decide_admission(11, [], frozenset({21}))` | **PENDING-PHASE-4** — [P4-T2] |

Import references at lines 44 and 47 are not call sites.

### `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py`

| Line | Call | Status |
| --- | --- | --- |
| 172 | `recolor_unstarted(self.unstarted, self.edges, self.pinned, generation)` (the `GeneratedRun.recolor` helper) | **PENDING-PHASE-4** — [P4-T10] |
| 220 | `recolor_unstarted(...)` (P1 input-order independence) | **PENDING-PHASE-4** — [P4-T10] |
| 291 | `recolor_unstarted(...)` (P2 induced-subgraph equivalence) | **PENDING-PHASE-4** — [P4-T10] |
| 335 | `decide_admission(candidate, run.edges, run.pinned)` | **PENDING-PHASE-4** — inside `TestPropertyThreePinStability`, relocated and migrated by [P4-T9] |
| 346 | `recolor_unstarted(unstarted, run.edges, run.pinned, generation)` | **PENDING-PHASE-4** — inside `TestPropertyThreePinStability`, [P4-T9] |
| 388 | `decide_admission(candidate, run.edges, run.pinned)` (per-function admission property) | **PENDING-PHASE-4** — relocated and corrected by [P4-T7] |
| 492 | `decide_admission(run.keys[0], run.edges, run.pinned)` (purity test) | **PENDING-PHASE-4** — [P4-T10] |
| 493 | `recolor_unstarted(run.unstarted, run.edges, run.pinned, START_GENERATION)` (purity test) | **PENDING-PHASE-4** — [P4-T10] |

Import references at lines 50 and 54, and docstring references at 11, 18, 19, and 162, are not call
sites.

**Every PENDING-PHASE-4 entry above is a TEST call site, and each is assigned to a specific task in
the [P4-T1] through [P4-T10] range.** No non-test call site is pending.

## Documentation References — Migration Owned by Phase 5

| File:line | Documented call shape | Status |
| --- | --- | --- |
| `.claude/skills/parallel-add/SKILL.md:68` | `decide_admission(candidate, conflict_edges, in_flight)` | **PENDING-PHASE-5** — migrated by [P5-T1] |
| `.claude/skills/parallel-add/SKILL.md:73` | `recolor_unstarted(unstarted_items, ...` | **PENDING-PHASE-5** — [P5-T1] |
| `.claude/skills/parallel-remove/SKILL.md:81` | `recolor_unstarted(unstarted_items, conflict_edges, pinned, ...` | **PENDING-PHASE-5** — [P5-T2] |
| `.claude/skills/parallel-orchestrate/SKILL.md:571` | drift-requeue reference to `recolor_unstarted` | **PENDING-PHASE-5** — [P5-T3] |
| `.claude/skills/parallel-close/SKILL.md:65` | a PROHIBITION on calling `recolor_unstarted` during a close | **NO CHANGE REQUIRED** — states no argument list, so it cannot be stale; confirmed by [P5-T7] |
| the four corresponding mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/**` | same lines | **PENDING-PHASE-5** — [P5-T4] through [P5-T6] |

### Recorded Deviation from This Task's Acceptance Wording

[P3-T8]'s acceptance states that "every non-test Python call site **and every documentation
reference** is MIGRATED and names the new form", and offers only the two dispositions MIGRATED and
PENDING-PHASE-4. At the point [P3-T8] executes, the documentation references are **not yet
migrated**, because the tasks that migrate them ([P5-T1], [P5-T2], [P5-T3]) and mirror them
([P5-T4] through [P5-T6]) are Phase 5 tasks, and the plan's phase ordering is deliberate and
binding. Migrating them inside [P3-T8] would perform Phase 5 work in Phase 3.

Rather than record a false MIGRATED status, this artifact introduces the honest third disposition
**PENDING-PHASE-5** for the four stale documentation call shapes and their four mirrors, each named
with its owning task. The substantive obligation of this task is fully discharged: every occurrence
is enumerated with file and line; every non-test **Python** call site is confirmed MIGRATED (there
are zero such call sites, so none can be stale); and every PENDING entry is attributed to a specific
later task. The documentation migration is proven complete by **[P5-T7]**, whose own acceptance
requires that every remaining occurrence across `.claude` and the bundle names the new signature.
This deviation is reported in the execution summary.

## Output Summary

Zero non-test Python call sites exist for either function, so no production caller can be stale.
Both function DEFINITIONS are migrated and carry the required keyword-only parameters. 26 test call
sites are enumerated with file and line and every one is classified PENDING-PHASE-4 with its owning
task in the [P4-T1] through [P4-T10] range. Four documentation call shapes plus their four bundle
mirrors are classified PENDING-PHASE-5 with their owning tasks ([P5-T1] through [P5-T6]); the fifth
documentation occurrence (`parallel-close/SKILL.md:65`) is a prohibition carrying no argument list
and needs no change. Pyright is deliberately not run here; the zero-error gate is [P4-T13] and
[P7-T3].
