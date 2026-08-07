# parallel-cohort-scheduler (Issue #445) — Design Research

- Date: 2026-08-07
- Feature: `docs/features/active/2026-08-07-parallel-cohort-scheduler-445/` (epic `parallel-orchestration`, child F2, wave 0)
- Design source: `docs/research/2026-08-07-parallel-orchestration-design-research.md` §6 (authoritative scope); §5.4, §8.1, §8.6, §11, §12, §13.3 (context)
- Structural precedent: `scripts/dev_tools/epic_wave_computation.py` and `tests/scripts/dev_tools/test_epic_wave_computation.py`
- Status: Research complete; input to atomic planning. Preparation mode — no implementation in this run.

## 1. Current State Analysis

Verified by reading the files named below in this worktree.

- `scripts/dev_tools/epic_wave_computation.py` (153 lines) is the structural precedent: a single pure function `compute_wave_numbers(manifest: Mapping[str, Sequence[str]]) -> dict[str, int]` over a caller-supplied mapping; no file I/O; one dedicated exception `EpicWaveCycleError(ValueError)` carrying an attribute (`feature_folder`) and a literal message naming the offending key; Google-style docstrings on the module, the exception, the public function, and the inner helper; `from __future__ import annotations` with collections-ABC imports under `TYPE_CHECKING`.
- `tests/scripts/dev_tools/test_epic_wave_computation.py` (112 lines, 8 tests) is the testing precedent: deterministic scenario tests with exact-output assertions, edge cases (empty manifest, disconnected vertices, self-reference), error-path tests via `pytest.raises`, and one test asserting the exception message names the offending key.
- No cohort/coloring implementation exists anywhere in the repository. The wave formula is directed longest-path layering and does not apply to the undirected `conflicts(a, b)` relation.
- `pyproject.toml`: coverage `source = ["src", "scripts/dev_tools"]`, so the new module is automatically inside the coverage denominator. Pyright runs in `strict` mode over `scripts`. Dev dependencies include `pytest`, `pytest-cov`, `black`, `ruff`, `pyright`; **`hypothesis` is not a dependency** (verified by grep of `pyproject.toml`).
- The feature folder already contains `issue.md`, `spec.md`, `user-story.md`, and a template-stub `plan.2026-08-07T11-11.md` (Phase 1/2 placeholders unfilled); this research feeds the plan's completion.

## 2. Candidate Approaches (Input Contract) and Recommendation

Two viable input shapes were compared. This is the highest-priority decision because F1 (`parallel-blast-radius`) produces the conflict graph, F2 consumes it, and F3 serializes both into the checkpoint schema (§12), so the contract must be JSON-representable.

### Candidate A — Adjacency mapping, mirroring the precedent shape

`Mapping[<key>, Sequence[<key>]]`, the same shape as `compute_wave_numbers`.

- Advantages: closest mirror of `epic_wave_computation.py`; isolated vertices are naturally keys with empty sequences.
- Limitations: (1) symmetry is not structurally guaranteed — an asymmetric mapping (`a` lists `b` but `b` omits `a`) must be either rejected or silently symmetrized, both of which add contract ambiguity; (2) **not JSON-round-trippable with integer keys** — JSON object keys are strings, so an `issue_num`-keyed mapping serialized by F3 comes back with `"445"` instead of `445`, a silent key-type corruption hazard; (3) it duplicates edge information (each undirected edge appears twice), inviting inconsistency.

### Candidate B — Explicit item-key set plus undirected edge list (recommended)

```python
def compute_cohorts(
    item_keys: Iterable[int],
    conflict_edges: Iterable[tuple[int, int]],
) -> list[list[int]]:
```

- Advantages: (1) directly matches the checkpoint record `conflict_edges[] = { a, b, reason }` (§12) after a trivial reduction — `[(e["a"], e["b"]) for e in conflict_edges]`; (2) JSON arrays preserve integer element types, so `item_keys: [443, 444, 445]` and `conflict_edges: [[443, 445]]` round-trip losslessly through F3's checkpoint; (3) an undirected edge is a single record with no duplication, and symmetry is guaranteed by normalizing each pair internally (store `(min, max)` or symmetric adjacency) — an edge supplied in either direction yields the same conflict by construction; (4) isolated vertices are represented explicitly: any key in `item_keys` that appears in no edge is an isolated vertex and lands in cohort 0.
- Limitations: two parameters instead of one; the module must validate that every edge endpoint is a member of `item_keys`.

**Recommendation: Candidate B.** The JSON-representability requirement is decisive: F3 serializes this module's input and output, and only the array-based shape survives a JSON round trip with integer keys intact.

**`{ a, b, reason }` versus normalized reduction:** accept the normalized reduction (`Iterable[tuple[int, int]]`), not the dict shape. `reason` is audit metadata (§12) with no effect on coloring; accepting the dict shape would couple F2 to F3's schema, inverting the epic dependency direction (F3 depends on F2, not the reverse). Callers perform the one-line reduction. Record this reduction explicitly in the module docstring so F1/F3/F4 planners can cite it.

**Item-key type:** `int`, because §11 states "`issue_num` is the primary key" and the epic Shared Design item 3 repeats it. Typing keys as `int` also eliminates two determinism hazards (mixed-type comparison `TypeError`, and lexicographic string ordering where `"10" < "9"`). Pyright strict enforces this statically; the module should not add a generic key-type parameter (simplicity first; no consumer needs it).

### Rejected alternatives (brief)

- Adjacency mapping (Candidate A): rejected per above — JSON key-type corruption and unenforced symmetry.
- Accepting `{ a, b, reason }` dicts directly: rejected — couples F2 to F3's schema and imports dead metadata.
- Generic/str item keys: rejected — contradicts the §11 primary-key decision and reintroduces ordering hazards.
- Optimal or randomized coloring (DSatur with randomized ties, ILP, etc.): out of scope by accepted decision §13.3; not evaluated further.

## 3. Output Contract

**Primary function:** `compute_cohorts(item_keys, conflict_edges) -> list[list[int]]` — an ordered list of cohorts. List position is the cohort index; each cohort's item keys are sorted ascending. Rationale:

- It is exactly the shape F3 serializes: `cohorts[] = { index, generation, item_keys[] }` (§12) — the caller wraps each list with its positional `index` and the current generation.
- The alternative (`dict[int, int]` mapping `item_key -> cohort_index`, the closest analogue of `compute_wave_numbers`'s return) is trivially derivable from the list form by the caller; returning both would duplicate information across the public surface. Recommend returning only the list form and documenting the one-line derivation in the docstring. (If the planner prefers the mapping as the primary return with a small grouping helper, both satisfy the acceptance criteria; the list form is recommended because it is the serialized shape and the direct input to slot filling.)

**Slot-filling function:** `compute_concurrency_batches(cohort_item_keys: Sequence[int], max_concurrency: int) -> list[list[int]]` — sorts the cohort's keys ascending, then chunks into consecutive batches of at most `max_concurrency`. A cohort of twelve with `max_concurrency = 4` yields three batches of four; a remainder case (e.g., ten items, `max_concurrency = 4`) yields batches of 4, 4, 2. `max_concurrency >= len(cohort)` yields one batch; `max_concurrency = 1` yields singleton batches. The function sorts its input itself rather than trusting the caller, so determinism does not depend on caller discipline.

**Boundary confirmations:**

- `generation` is the caller-owned `recolor_generation` counter (§8.6). This module never produces, increments, or accepts a generation value. Confirmed against §8.6 and §12: `recolor_generation` lives in the mutation log and checkpoint, owned by the orchestrator/mutation-protocol surfaces (F5/F6).
- `current_cohort` (§12) is likewise caller-owned execution state, not a module output.
- The module computes no blast radii and never evaluates `conflicts(a, b)`; it consumes the already-computed edge set (F1 boundary).

## 4. Welsh-Powell Precise Semantics and Determinism Hazards

**Ordering rule:** compute each vertex's degree as the number of *distinct* neighbors after normalizing edges (deduplicate `(a, b)` / `(b, a)` and repeated edges). Sort vertices by the composite key `(-degree, item_key)` ascending. Because item keys are unique, this key is a total order; the sort outcome is independent of input order and of Python sort stability.

**Assignment rule:** visit vertices in that order; assign each vertex the smallest non-negative integer not present in the set of cohort indices already assigned to its neighbors. Cohort index = color. Isolated vertices and the first vertex always receive cohort 0.

**Determinism hazards a plan must guard against** (determinism under permuted input ordering is a stated epic NFR):

1. **Vertex order derived from input iteration order.** Sorting by `(-degree, item_key)` — never by insertion order, never relying on sort stability to break ties — is the single load-bearing guard. A stable sort on `-degree` alone would leak input order into equal-degree groups.
2. **Set iteration.** Adjacency stored as `set[int]` is safe for the min-excluded-color computation (a set-membership property, order-insensitive) but must never be iterated to produce an ordered result. Any place a set or dict feeds an ordered output must pass through `sorted(...)` first — including the final per-cohort key lists.
3. **Dict insertion order.** Python dicts preserve insertion order; building the result by iterating an insertion-ordered structure silently encodes input order. Emit cohort membership sorted ascending explicitly.
4. **Mixed-type item keys.** `int` vs `str` comparison raises `TypeError` at sort time in Python 3, and all-string keys sort lexicographically (`"10" < "9"`). Closed by the contract decision that keys are `int` (§11). Duplicate keys in `item_keys` would break the uniqueness assumption behind the total order; recommend rejecting duplicates as malformed input.
5. **Tie-break direction.** "Ascending item key" must be verified by a dedicated test with equal-degree vertices, since an accidental descending tie-break also produces a deterministic — but wrong — order.

Repeated invocation with identical input, and invocation with permuted `item_keys` / permuted and direction-flipped `conflict_edges`, must produce identical output; both are explicit test conditions.

## 5. Error Handling Conventions

Precedent: one dedicated exception `EpicWaveCycleError(ValueError)` with an identifying attribute and a literal message naming the offending key. The issue text for F2 states "a dedicated exception type for malformed input" (singular).

**Recommendation:** a single `ParallelCohortInputError(ValueError)` raised for every malformed-input mode, with a specific literal message per mode:

| Failure mode | Raised by | Message content |
| --- | --- | --- |
| Edge endpoint not in `item_keys` | `compute_cohorts` | Names the unknown key and the offending edge |
| Self-loop (`a == b`) | `compute_cohorts` | Names the self-conflicting key |
| Duplicate key in `item_keys` | `compute_cohorts` | Names the duplicated key |
| Non-positive `max_concurrency` | `compute_concurrency_batches` | States the invalid value and the `>= 1` requirement |

One class keeps the public surface minimal (repo design principle: simplicity first) while `ValueError` lineage matches the precedent. Give the class an attribute identifying the offending value (mirroring `EpicWaveCycleError.feature_folder`); a single `offending_value`-style attribute plus the literal message is sufficient — per-mode subclasses were considered and rejected as surface growth with no consumer. Tests assert both the exception type and that the message names the offending key, mirroring `test_epic_wave_cycle_error_message_names_the_feature_folder`.

A note for the plan: the design treats a self-loop as malformed rather than as "item serializes alone" because `conflicts(a, b)` is defined over distinct items (§5.4); a self-edge can only be produced by an F1 defect, and failing fast surfaces that defect (fail-closed principle, epic Shared Design item 7).

## 6. Pinning Invariant Interaction (§8.1) — Recommendation: No Pinned-Set Parameter in F2

**Recommendation: F2 must not expose a pinned-set parameter.** Rationale grounded in the epic dependency graph:

- The pinning invariant belongs to F6 (mutation protocol), which depends on F5 only — not on F2 (verified against the epic decomposition table). No F2 consumer in the dependency graph needs pinning: F4 seeds cohorts over the full graph; F5 schedules from the checkpoint's cohort table.
- The invariant is satisfied compositionally without any F2 API support: §8.1 requires recoloring to be "a pure function of `(remaining subgraph, pinned set)`". Because `compute_cohorts` is a pure function of its input, the caller achieves this by passing the induced subgraph — the not-yet-started `item_keys` and the edges among them. The pinned set influences *admission* (conflict checks against in-flight items, §8.3), which operates on conflict edges, not on coloring, and is F6 logic.
- Adding the parameter now would speculate on F6's design during wave 0, while F6's design is two waves of contract evolution away. If F6 later determines a parameter is needed, adding an optional keyword parameter with a default is a non-breaking extension (repo API policy prefers keyword parameters with defaults).

**Action for the plan:** document in the module docstring that recoloring over a mutated set is performed by invoking `compute_cohorts` on the induced not-yet-started subgraph, and that in-flight (pinned) items must be excluded by the caller. This states the boundary without implementing it.

## 7. "Parity Test" Scope — Empirical Findings

Searched the repository for the epic-wave counterparts and the model-routing parity mechanism. Findings:

1. **`epic_wave_computation.py` has no PowerShell counterpart.** `.claude/lib/` contains only `model-routing/ModelRouting.psm1`, `orchestrator-state/OrchestratorState.psm1`, and `orchestrator-state/OrchestratorStateCompletion.psm1`. No wave-computation `.psm1` exists, and no Pester test executes the Python wave module.
2. **A TypeScript mirror exists** at `extensions/drm-copilot/src/lib/validate/epic-wave-computation.ts`, consumed by `epic-planner-state-core.ts` (the MCP validator recomputes expected waves). Its Jest test (`extensions/drm-copilot/test/lib/validate/epic-wave-computation.test.ts`) repeats the same diamond-DAG scenario as the Python test and even pins the Python-`repr` exception-message format. Parity is achieved by **mirrored scenario fixtures across independently tested implementations**, not by an executed cross-process comparison.
3. **The model-routing parity mechanism is static config pinning:** `tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1` reads `config/orchestration-routing.json` and asserts the PowerShell module's embedded constants equal the config values; `tests/scripts/dev_tools/test_compute_complexity_floor.py` reads the same config on the Python side. There is also a byte-identity guard pattern (`test_orchestration_routing_config_parity.py`). No test executes Python and PowerShell together.
4. The epic's F1 entry explicitly names `.claude/lib/blast-radius/BlastRadius.psm1`; the F2 entry names only `scripts/dev_tools/parallel_cohort_computation.py` "plus … a parity test". The asymmetry is consistent with consumers: F1's radius/conflict logic is needed by PowerShell hooks (F7 Layer 1 evaluates conflicts per `Agent` call), whereas no PowerShell surface recomputes coloring — F7's barrier hook reads the checkpoint's already-computed cohort table.

**Recommendation:** F2 ships **Python only** — no `.claude/lib/**` PowerShell module. "A parity test in the manner of the existing `epic_wave_computation.py` tests" means, empirically: a deterministic pytest suite with exact-output scenario assertions, including explicit determinism-under-permutation tests, structured so a future mirror (TypeScript in F3's MCP validator, if F3 chooses to recompute cohorts there, or PowerShell if a later consumer emerges) can replicate the same scenario fixtures. The plan should state this scope decision and its evidence so feature review does not flag a missing `.psm1`. Keep exception messages simple and stable, since the epic-wave TS mirror demonstrates that mirrors pin message text verbatim.

## 8. Quality-Tier Classification and Test Obligations

**Verified: no `quality-tiers.yml` exists at the repository root** (glob search returned nothing), confirming the epic's F1 known-constraint note. The actual classification mechanism today is prose-only: `.claude/rules/quality-tiers.md` defines T1–T4 with examples; `scripts/dev_tools/**` matches the T4 examples ("build scripts, dev tooling"). The precedent modules (`epic_wave_computation.py`, `compute_complexity_floor.py`, `resolve_delegation_model.py`) carry no property-based tests and no mutation-testing configuration, consistent with T4 treatment.

**Classification: T4 (dev tooling).** Concrete obligations that follow:

- Uniform gates (all tiers): Black format pass; Ruff zero errors; Pyright strict zero errors; **line coverage >= 85%, branch coverage >= 75%** — and the module is automatically measured because `[tool.coverage.run] source` includes `scripts/dev_tools`.
- T4-specific: **no property-based tests required** (T1/T2 only), **no mutation score required** (T1 only). This matters materially: `hypothesis` is not in `pyproject.toml`, and adding dependencies without explicit user instruction is prohibited by `.claude/rules/python.md`. The determinism NFR is instead covered by explicit permutation tests (repeated invocation, shuffled `item_keys`, shuffled and direction-flipped edges — fixed literal permutations, not seeded RNG, keeping tests trivially deterministic).
- **F2 must not create `quality-tiers.yml`.** The epic assigns resolving the missing-file constraint to F1's research, and F1 is prepared concurrently in the same wave; F2 touching that file would create exactly the shared-surface blast-radius conflict this epic is built to prevent.

## 9. File-Size Budget and File Layout

- **Production:** `scripts/dev_tools/parallel_cohort_computation.py`. Estimated 250–350 lines with the mandatory Google-style docstrings and intent comments (`epic_wave_computation.py` spends ~60% of its 153 lines on documentation; this module has two public functions, one exception, and input validation). Comfortably under 500 lines in one file.
- **Tests:** `tests/scripts/dev_tools/test_parallel_cohort_computation.py`, single file. The `issue.md` test-condition list yields roughly 20–25 tests across nine groups (empty/single/isolated; complete graph; Welsh-Powell ordering vs insertion order; tie-breaking; determinism under repetition and permutation; slot filling exact-multiple/remainder; `max_concurrency` of 1 and above cohort size; malformed input ×4; symmetry). At the precedent's ~14 lines per test, that is ~350–420 lines — near, but under, the 500-line limit, provided `pytest.mark.parametrize` compresses the malformed-input and `max_concurrency` boundary matrices (the repo's Pytest rules recommend parametrize for boundary matrices).
- **Contingency:** if the file approaches 500 lines during implementation, split by concern into `tests/scripts/dev_tools/test_parallel_cohort_computation.py` (coloring: ordering, tie-breaks, determinism, graph shapes) and `tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py` (malformed input plus slot-filling boundaries). Multiple test files per module family are established practice in `tests/scripts/dev_tools/`. The plan should name the single-file layout as primary and this split as the pre-approved fallback so the executor does not improvise.

## 10. Behavior Semantics Summary (for the plan's acceptance mapping)

- Success: `compute_cohorts` returns cohorts such that (a) every cohort is an independent set of the input graph; (b) vertices were colored in `(-degree, ascending item_key)` order with lowest-available-index assignment; (c) each cohort's `item_keys` are ascending; (d) the concatenation of cohorts covers `item_keys` exactly once. Empty input returns `[]`. All-isolated input returns one cohort. A complete graph on n vertices returns n singleton cohorts.
- Success: `compute_concurrency_batches` returns ascending-ordered batches of size `max_concurrency` except a possibly smaller final batch; concatenation equals the sorted cohort.
- Failure: `ParallelCohortInputError` for unknown edge endpoint, self-loop, duplicate item key, non-positive `max_concurrency`; message names the offending value.
- Invariants: pure functions — no I/O, no input mutation, no clock/RNG; identical output for identical or permuted-equivalent input.

## 11. Constraints Recorded

- Surface name is `parallel` throughout; module name `parallel_cohort_computation.py` as fixed by the epic.
- Optimality is not the objective; determinism and explainability are (§13.3). No optimal or randomized coloring.
- Identical inputs produce identical cohort assignments (epic NFR).
- Additive only: `epic_wave_computation.py` and other epic implementations are not modified; reuse is by near-verbatim adaptation into the new file.
- `.claude/skills/atomic-plan-contract/SKILL.md` is not modified (epic non-goal).
- No new Python dependencies (`hypothesis` explicitly not added; T4 does not require it).
- F2 does not create or modify `quality-tiers.yml` (F1 scope, same wave).

## Automation Feasibility

Fully automatable. This feature is a pure Python computation module plus a pytest suite: no third-party UI, no external service, no credential, no manual verification step, and no host-bound runtime is involved. The complete toolchain (Black, Ruff, Pyright, pytest with coverage) runs non-interactively via the repository's standard commands. No human interaction is required at any step.
