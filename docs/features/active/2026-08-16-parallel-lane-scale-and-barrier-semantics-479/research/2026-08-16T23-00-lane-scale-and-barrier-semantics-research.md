# Research — Parallel Lane Scale and Barrier Semantics (Issue #479)

- **Issue:** #479
- **Branch:** `bug/parallel-lane-scale-and-barrier-semantics-479`
- **Date:** 2026-08-16T23-00
- **Scope:** Four approved defects (D1 barrier semantics, D2 `max_concurrency` ceiling, D3 lane-grouping assertion seam, D4 staged preparation intake). This document researches HOW, not whether.

---

## Premise Verification Summary — read this first

The operator's framing was verified on the two enforcement layers only. Every other premise was checked. Two premises are **partially wrong**:

1. **"Defect 1 is a documentation defect, not a code defect" — PARTIALLY WRONG.** Neither enforcement layer implements the global rule (confirmed), and no code path advances or gates on `current_cohort` (confirmed). However, the F6 mutation engine's **pinned-barrier offset is sound only under the global barrier**. `scripts/dev_tools/parallel_mutation_protocol.py:321-327` computes `cohort_offset = current_cohort + 1 if crosses_pinned else current_cohort`, and its docstring at lines 253-257 justifies this with the global rule verbatim: "This is the index the pinned items occupy for as long as they run, because the cohort barrier increments `current_cohort` only on durable confirmation that every cohort item is `merged` or `worktree_removed`". Under the per-edge barrier, in-flight items can legitimately occupy multiple cohort indices simultaneously, the "+1 above `current_cohort`" shift can place a newly deferred candidate at the same index as a pinned conflicting item, and that state is both a coloring violation and a Layer-2 structural violation. Details and remedy in section D1.6. D1 is therefore **prose plus one contained code change** (or an explicitly documented restriction, not recommended).

2. **"Audit every restatement... confirm no code path implements the global rule" — confirmed with one test-pin surprise.** No production code implements the global rule. But the exact global-barrier sentence is **pinned as a required text fragment** by `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:154-159` (`COHORT_BARRIER_FRAGMENTS`), consumed by `test_orchestrate_skill_section_states_its_required_obligations` in `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:290-297`. The prose fix fails CI unless that pin is updated in the same change.

All other premises held: invariant 14 bounds `current_cohort` and nothing gates on it; the bound `1..8` is enforced at exactly the three invariant sites plus parity ports; `/parallel-plan` fan-out is genuinely unbounded; the manifest validator tolerates unknown keys, so an optional assertion field is backward compatible.

---

## D1 — Documented barrier is stricter than the enforced barrier

### D1.1 (Q1a) Exhaustive inventory of global-barrier restatements and dependents

Runtime surfaces (must change or be reviewed):

| # | Location | Quoted text | Disposition |
|---|---|---|---|
| 1 | `.claude/skills/parallel-orchestrate/SKILL.md:118-123` | "**Cohort barrier.** Cohort `N+1` branches from `main` only after every cohort-`N` item is `merged` or `worktree_removed`. Increment `current_cohort` only on durable confirmation... A blocked item (`blocked_ci_loop_limit` or `blocked_drift`) is neither `merged` nor `worktree_removed`, so a blocked item holds the barrier and cohort `N+1` does not start." | Primary definition. Replace with per-edge wording (D1.3). |
| 2 | `.claude/skills/parallel-orchestrate/SKILL.md:156-158` | "Run one `git fetch origin main` immediately before each cohort launch, so every item in that cohort branches from the same current remote `main` tip" | Dependent: under per-edge, launches are per-batch, not per-cohort. Reword to "before each launch batch". |
| 3 | `.claude/skills/parallel-orchestrate/SKILL.md:311-314` | "A blocked item is neither `merged` nor `worktree_removed`, so it holds the cohort barrier defined in `## Cohort Barrier and Max-Concurrency Slot Filling`." | Dependent: still true, but scope narrows to the blocked item's conflicting later-cohort neighbours. Reword. |
| 4 | `.claude/skills/parallel-orchestrate/SKILL.md:505-510` | "...returned a deferred candidate to cohort 0, the current cohort, whenever the cohort barrier held `current_cohort` at 0." | Dependent narrative in `## Mutation Protocol (F6)` — assumes global increments. Review alongside D1.6. |
| 5 | `.claude/agents/parallel-orchestrator.md:190-193` | "**Cohort barrier.** Cohort `N+1` branches from `main` only after every cohort-`N` item is `merged` or `worktree_removed`. `current_cohort` increments only on durable confirmation... a blocked item holds the barrier." | Full restatement. Replace with per-edge wording. |
| 6 | `.claude/skills/parallel-add/SKILL.md:87-99` | ":87-89 — `current_cohort` "is F3's top-level field... and is the index the pinned items occupy"; :96-99 — "A conflict with an unstarted item OUTSIDE the current cohort does not defer: the cohort barrier keeps the two from running concurrently" | :96-99 remains valid under per-edge (conflicting cross-cohort pairs are still ordered). :87-89 carries the single-frontier assumption; review with D1.6. |
| 7 | `.claude/skills/parallel-remove/SKILL.md:87-90` | "`current_cohort` is F3's top-level field, read from the re-verified durable state, and is the index the pinned items occupy" | Same single-frontier phrase; review with D1.6. |
| 8 | `docs/features/templates/parallel/parallel-status.md:32` | "`current_cohort`: _(index of the cohort currently launched)_" | Reword to progress-indicator semantics (D1.4). |
| 9 | `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:154-159` | `COHORT_BARRIER_FRAGMENTS = ("Cohort \`N+1\` branches from \`main\` only after every cohort-\`N\` item is \`merged\` or \`worktree_removed\`", "max_concurrency", "ascending item-key order")` | Test pin of the exact global sentence. Must be updated to pin the new per-edge sentence. |
| 10 | `scripts/dev_tools/parallel_mutation_protocol.py:253-262, 321-327` and `scripts/dev_tools/_parallel_mutation_models.py:303-309` | Docstrings/comments: "The pinned items hold index `current_cohort` for as long as they run, so..." | Code whose soundness argument cites the global rule. See D1.6. |
| 11 | Mirrors: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md:118` (and :156-158, :311-314, :505-510), `.../agents/parallel-orchestrator.md:190`, `.../skills/parallel-add/SKILL.md`, `.../skills/parallel-remove/SKILL.md` | Byte-identical copies of rows 1-7. | Must be re-synced byte-identically. |

Already correct (no change): `.claude/skills/parallel-orchestrate/SKILL.md:146` and :637-639 (Layer-1 descriptions, already per-edge: "unless every conflicting item in a prior cohort is `merged` or `worktree_removed`" / "unless every `conflict_edges[]` neighbour in a strictly prior current-generation cohort has `merge_status` of `merged` or `worktree_removed`"); the hook's own docstring and deny-reason text (`.claude/hooks/enforce-parallel-cohort-barrier.ps1:25-29, 482`); `.claude/skills/parallel-run/SKILL.md:48` and `.claude/agents/parallel-orchestrator.md:64,154` (topic listings, not semantic restatements); `.claude/skills/parallel-close/SKILL.md` (no barrier statement); `.claude/rules/parallel-orchestration.md` (states no barrier rule; invariant 14 is bounds-only).

Historical records restating the global rule that must **not** be edited (they are evidence of past decisions, not runtime surfaces): `docs/research/2026-08-07-parallel-orchestration-design-research.md:124`, `docs/features/potential/promoted/2026-08-07-parallel-orchestrator-surface.md:38`, and the spec/plan/audit/research files under `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/`, `.../parallel-enforcement-hooks-440/`, `.../parallel-mutation-protocol-442/`.

### D1.2 (Q1b) Per-site verdict: per-edge, global, or neither

| Site | Verdict | Evidence |
|---|---|---|
| `compute_concurrency_batches` (`scripts/dev_tools/parallel_cohort_computation.py:419-468`) | **Neither.** Pure chunking of one cohort's keys into batches of `max_concurrency`. No barrier logic; module docstring (lines 33-36) states `generation` and `current_cohort` are "caller-owned execution state. This module never produces, increments, or accepts either value." | Read in full. |
| Bash port `.claude/lib/bash/compute-concurrency-batches.sh` + `parallel-cohorts.sh:281-293` | **Neither.** Same contract; the only validation is `max_concurrency >= 1`. | Read. |
| Anything advancing or gating on `current_cohort` | **Nothing in code.** The increment rule exists only as prose (skill :118-121, agent :191). Code consumers are the invariant-14 bound check and the F6 engine (see D1.4/D1.6). | Grep over `scripts/dev_tools`, hooks, TS ports. |
| Layer 1 `Test-ParallelCohortBarrierClear` (`.claude/hooks/enforce-parallel-cohort-barrier.ps1:335-395`) | **Per-edge.** Iterates only `Get-ParallelCohortBarrierConflictNeighborList` results (:372); `continue` on neighbours with index `>=` target (:378-381) and on neighbours with no current-generation assignment (:374-377). | Read in full. |
| Layer 2 `_violation_endpoints` (`scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py:282-328`) | **Per-edge.** Judges only `conflict_edges[]` pairs; non-conflicting overlap produces no violation. | Read in full. |
| Orchestrator validators, invariants 12-14 (`scripts/dev_tools/_parallel_state_structures.py`, `validate_current_cohort_bound` at :324-360) | **Neither.** Shape, uniqueness, coverage, and the `current_cohort <= max index` bound only. No ordering gate. | Read. |
| Planner P4 (`scripts/dev_tools/validate_parallel_planner_state.py:285-290`) | **Neither.** Reuses the same bound check, presence-gated. | Read. |
| F6 `recolor_unstarted` (`parallel_mutation_protocol.py:200-341`) | **Neither enforces the barrier — but its offset is derived FROM the global rule.** See D1.6. | Read in full. |

**No site implements the global rule.** The fix is prose plus the D1.6 code consideration plus the test pin.

### D1.3 (Q1c) Replacement wording and layer fidelity

Target sentence — confirmed faithful to Layer 1's decision procedure:

> An item may start only when every conflicting neighbour (`conflict_edges[]`) that sits in a strictly prior current-generation cohort has `merge_status` of `merged` or `worktree_removed`. `ci_green` does not satisfy the barrier. Same-cohort and later-cohort neighbours do not hold an item back, and items with no conflicting prior-cohort neighbour may start regardless of other cohorts' progress.

Fail-closed cases the prose must also state, because the two layers differ:

- **Layer 1 (prospective, per launch)** denies fail-closed on: missing/unparseable checkpoint, unresolved feature-folder token, missing `items[]` record, **target with no current-generation cohort assignment** (:367-370), missing neighbour record (:382-384), missing neighbour `merge_status` (:386-389). It **skips (allows past)** a neighbour that has no current-generation cohort assignment (:374-377 — "Not part of the current coloring, so not a strictly prior cohort neighbor").
- **Layer 2 (retrospective, per edge)** is deliberately silent on unjudgeable edges (unresolved endpoint, self-edge, endpoint outside the current coloring — `_parallel_orchestrator_state_cohort_barrier.py:308-311, 369-371`) because shape errors are invariant 15's to report. It adds a **structural reading** Layer 1 has no counterpart for: two conflicting items colored into the same current-generation cohort is a violation outright (:305-307). Its status reading (`_has_started(later) and not _satisfies_barrier(earlier)`, :325) is exactly the retrospective contrapositive of the per-edge launch rule; its temporal reading (`merged_at(earlier) > worktree_created_at(later)`, :256-279) catches overlaps the statuses have moved past, degrading to status-only when either timestamp is absent or non-string.

So the prose must describe: (a) the per-edge launch rule (Layer 1's exact predicate), (b) Layer 1's fail-closed target-side denials versus its neighbour-side skip, and (c) Layer 2's three readings including the structural same-cohort reading.

### D1.4 (Q1d) `current_cohort` status — confirmed a bound, not a gate, with one caveat

Invariant 14 (`.claude/rules/parallel-orchestration.md`): "`current_cohort` must be a non-negative integer. When any current-generation cohort exists, `current_cohort` must not exceed the maximum current-generation `index`." Bound only.

Exhaustive consumer list:

- `validate_current_cohort_bound` — `scripts/dev_tools/_parallel_state_structures.py:324-360`; invoked at `validate_parallel_orchestrator_state.py:189-192` and (presence-gated) `validate_parallel_planner_state.py:285-290`. TS parity in `parallel-state-structures.ts`. **Bound only.**
- Layer 1 hook: **does not read `current_cohort`** (verified — no reference anywhere in `enforce-parallel-cohort-barrier.ps1`; it reads the target's own cohort index from the coloring).
- Layer 2: **does not read `current_cohort`**.
- F6 engine: `decide_admission(..., current_cohort_members=...)` (`parallel_mutation_protocol.py:126-197`) and `recolor_unstarted(..., current_cohort=...)` (:200-341) — **consumes it as a scheduling input for mutations**, not as a launch gate. This is the caveat in D1.6.
- Prose/projection: skill :347 (status header), :367 (regeneration boundary — the sentence "Every cohort transition, meaning every `current_cohort` increment" is pinned by `BOUNDARIES_REGENERATION_FRAGMENTS` at `parallel_orchestrator_surface_expectations.py:184-192` and should be kept verbatim), agent :191-192 and :208, add skill :87-89, remove skill :87-90, template :32.

Recommended redefinition: `current_cohort` is a **progress indicator** — the lowest current-generation cohort index still containing a non-terminal, non-withdrawn item — updated only on durable confirmation (`git worktree list --porcelain`, `git branch`, `gh pr view --json state,mergedAt,headRefOid`), gating nothing. This keeps invariant 14 satisfied unchanged, keeps the pinned regeneration-boundary sentence true, and keeps the status-doc header meaningful.

### D1.5 (Q1e) The two arguments the prose must preserve — anchors verified

1. **Safety.** `.claude/skills/parallel-orchestrate/SKILL.md:100-103`: "Items within a cohort are non-conflicting by construction — a cohort is an independent set in the conflict graph — so they may branch from the same `main` tip and may merge in any order. After one same-cohort item merges, another same-cohort item's pull request, based on the older tip, remains mergeable, and GitHub produces a merge commit." An item launching under the per-edge rule while a non-conflicting prior-cohort item is still open is byte-for-byte this situation: it branches from a `main` that lacks only non-conflicting work. The skill already accepts it as safe. (Mirror: same lines under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`.)
2. **Availability.** Under the global sentence at :118-123, a single `blocked_ci_loop_limit` or `blocked_drift` item halts **every** later cohort — i.e., every lane, since a 13-lane transpose colors lanes across cohorts. Under the per-edge rule the blocked item holds only its conflicting later-cohort neighbours, and transitively their later conflicting neighbours — its own conflict component's tail — while the other twelve lanes advance. The current halting text to replace or scope is :122-123 ("a blocked item holds the barrier and cohort `N+1` does not start") and :311-314; the agent's copy is :192-193.

### D1.6 — PROMINENT FLAG: the F6 pinned-barrier offset assumes the global barrier

`recolor_unstarted` (`scripts/dev_tools/parallel_mutation_protocol.py:200-341`):

```python
cohort_offset = current_cohort + 1 if crosses_pinned else current_cohort   # :327
```

with the comment (:321-323): "The pinned items hold index `current_cohort` for as long as they run" — a statement that is only true under the global barrier (docstring :253-257 says so explicitly, citing the global increment rule).

Reachable failure under per-edge semantics: lanes L1 = {a0@c0, a1@c1, a2@c2}, L2 = {b0@c0, b1@c1}. a0 merges quickly; per-edge lets a1 launch while b0 still runs. In-flight now spans indices {0, 1}; `current_cohort` (lowest incomplete index) is 0. `/parallel-add` of a candidate X conflicting with pinned a1: `crosses_pinned` is true, offset = `current_cohort + 1` = 1, so X can land at index 1 — **the same index as its pinned conflicting neighbour a1**. That is a conflicting same-cohort pair: a coloring violation, an immediate Layer-2 structural violation (`PARALLEL_COHORT_BARRIER_VIOLATION`), and a state Layer 1 would then allow X to launch into (Layer 1 skips same-index neighbours at :378-381). This state was unreachable under the global barrier, which is why the landed F6 code is correct today.

Recommended remedy (minimal, backward-compatible in outcome): generalize the offset to shift above the **highest current-generation cohort index occupied by any pinned item** when `crosses_pinned` is true — e.g., a required keyword-only parameter (`highest_pinned_cohort: int`) on `recolor_unstarted`, with `cohort_offset = highest_pinned_cohort + 1 if crosses_pinned else current_cohort`. When all pinned items sit at `current_cohort` (every state reachable today), `highest_pinned_cohort == current_cohort` and behavior is identical, so existing tests describe a preserved special case. Callers (the `/parallel-add` and drift-requeue procedures) derive the value from the same re-verified durable state they already derive `current_cohort` from. The alternative — prose forbidding mutations while more than one cohort has in-flight items — reintroduces the global barrier through the back door and is not recommended. A conservative variant (`max` over pinned indices regardless of which pinned item conflicts) is acceptable; per-component precision is not required because the shift must stay uniform to preserve injectivity (docstring :233-236).

Scope decision for the planner: this remedy can ship inside D1 (it is what makes the per-edge prose safe to follow during mutations) or as an explicitly sequenced follow-up with an interim prose restriction. Shipping it inside D1 is recommended; without it the per-edge prose must carry a caveat that is itself a latent trap.

### D1.7 Prose-only vs prose-plus-code

**Prose plus code.** Prose: skill, agent, add/remove skills, template, mirrors. Code: `parallel_orchestrator_surface_expectations.py` pin update (test infrastructure), and the D1.6 offset generalization in `parallel_mutation_protocol.py` (+ docstring updates in `_parallel_mutation_models.py:303-309`) with its tests. No PowerShell, TypeScript, or bash change: the hook is already per-edge, and Layer 2 plus its TS port are already per-edge.

### D1 CHANGE INVENTORY

| File | Language | Kind |
|---|---|---|
| `.claude/skills/parallel-orchestrate/SKILL.md` (:118-123, :156-158, :311-314, :505-510) | Markdown | Prose |
| `.claude/agents/parallel-orchestrator.md` (:190-193) | Markdown | Prose |
| `.claude/skills/parallel-add/SKILL.md` (:87-89) | Markdown | Prose |
| `.claude/skills/parallel-remove/SKILL.md` (:87-90) | Markdown | Prose |
| `docs/features/templates/parallel/parallel-status.md` (:32) | Markdown | Prose (not mirrored) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` | Markdown | Mirror |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md` | Markdown | Mirror |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md` | Markdown | Mirror |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-remove/SKILL.md` | Markdown | Mirror |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (:154-159) | Python | Test |
| `scripts/dev_tools/parallel_mutation_protocol.py` (:200-341) | Python | Production (D1.6 offset) |
| `scripts/dev_tools/_parallel_mutation_models.py` (:303-309) | Python | Production (docstring) |
| `tests/scripts/dev_tools/test_parallel_mutation_recolor.py` (and siblings pinning offset behavior) | Python | Test |

---

## D2 — Raise the `max_concurrency` ceiling

### D2.1 (Q2a) Recommended ceiling: **32**

What actually bounds simultaneously in-flight items (each in-flight item = one git worktree + one background child orchestrator running Poetry/npm/Pester toolchains + one open PR with CI):

- **Disk (estimate, unverified — no measurement tool available in this research session).** Worktrees share the object store, so per-worktree cost is the working-tree checkout (text-dominated, order tens of MB) plus per-worktree toolchain state created when the child runs QA: a Poetry virtualenv is keyed to the project directory path, so each worktree gets its own (~hundreds of MB), and `extensions/drm-copilot` `node_modules` adds a comparable amount if the child runs the TS toolchain. Order-of-magnitude ~1 GB per active worktree. Hard failure (disk exhaustion on a typical workstation SSD) becomes plausible only in the low hundreds of concurrent worktrees.
- **Local CPU/RAM.** Child orchestrators are mostly model-bound (idle waiting), with bursty toolchain runs. Contention degrades gracefully (slower runs) from roughly 8-16 concurrent toolchain bursts on a workstation; there is no hard failure threshold below memory exhaustion at several dozen concurrent heavy test runs.
- **GitHub Actions concurrency.** Documented platform limits (as of knowledge cutoff): 20 concurrent standard-runner jobs on Free, 40 on Pro, 60 on Team. Each item's PR triggers a handful of jobs, so pure queuing begins around 5-20 concurrent items depending on plan and workflow fan-out. Degradation is queuing, not failure.
- **GitHub API.** 5000 authenticated requests/hour; the orchestrator's `gh` polling across even 30 items is far below it. Secondary rate limits on rapid mutation are avoided by the existing per-item pacing.

**Which constraint binds first:** GitHub Actions job concurrency, at roughly 10-20 concurrent items — and it binds by **queuing**, not by failing. Nothing fails hard until disk exhaustion at O(100) concurrent worktrees. Under the per-edge barrier (D1), mutual exclusion within a conflict component is automatic, so `max_concurrency` is a pure throughput throttle; the ceiling's only job is to reject nonsense values.

**Recommendation: 32.** It admits any plausible single-repository run (the motivating case needs 13; a run of 32 mutually independent in-flight items already saturates every graceful-degradation constraint above), while still rejecting order-of-magnitude operator errors (a typo like `130`, or a value near the disk-exhaustion regime). It is derived from the constraint analysis (well above the queuing knee, well below the first hard-failure regime), not from symmetry with any other surface. The A7 section text must be rewritten to record this derivation and to drop the epic-symmetry rationale. The epic surface's `max_parallel_features` `1..8` is **not** changed.

**Runner-up: 16 — rejected** because it re-encodes the current run's shape (13 lanes) with minimal headroom; a 17-lane run would reproduce this exact defect, and 16 has no stronger tie to a real constraint than 32 does. The default of 4 is unchanged everywhere.

### D2.2 (Q2b) Exhaustive change inventory for the bound

Boolean rejection status is noted per site (Python `True == 1` hazard).

**Python production (all three reject booleans via `in_bounded_range`, `scripts/dev_tools/_parallel_state_common.py:187-202`, which tests `isinstance(value, bool)` first; its docstring :196-197 also cites "1 through 8 (A7)" and needs the number updated):**

- `scripts/dev_tools/parallel_manifest_contract.py:65` (`MAX_CONCURRENCY = 8`), error string :264-267 (M4).
- `scripts/dev_tools/validate_parallel_orchestrator_state.py:71`, error :144-148 (invariant 4).
- `scripts/dev_tools/validate_parallel_planner_state.py:64`, error :168-172 (P2).
- `scripts/dev_tools/_parallel_state_common.py:197` (docstring only).

**TypeScript parity ports (booleans rejected — `Number.isInteger(true)` is false; the known `===` divergence at `parallel-state-structures.ts:228` is not on this path):**

- `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts:70` (`MAX_CONCURRENCY = 8`), error :144-147.
- `extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts:66`, error :192-195.
- There is **no** TypeScript manifest port (manifest validation is Python + bash only — verified by grep for "Parallel manifest" under `extensions/drm-copilot/src`: no files).

**Bash parity (booleans rejected — the YAML subset lexer types boolean words as `bool`, and `pc_in_bounded_range` requires type `int`; proven by fixture `manifest_m4_boolean_rejected.json`):**

- `.claude/lib/bash/parallel-manifest-validate.sh:44-46` (`PM_MAX_CONCURRENCY=8`), error :118-119.
- Mirror: `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-manifest-validate.sh` (byte-identical re-sync).

**Prose:**

- `.claude/rules/parallel-orchestration.md:29` (invariant 4 "from 1 through 8, and must not be a boolean"), :101 (M4), :138 (entire "Concurrency Bound (A7)" section — records "the upper bound of 8 is adopted here for symmetry with the epic surface"; rewrite the rationale per D2.1). P2 references invariant 4, no separate number.
- `.claude/skills/parallel-orchestrate/SKILL.md:67-68` ("an integer from 1 through 8, defaulting to 4").
- `.claude/skills/parallel-plan/SKILL.md:256` ("bounded 1 through 8 by the F3 schema") and :288 ("an integer from 1 through 8; defaults to 4").
- `docs/features/templates/parallel/parallel-status.md:31` ("integer 1 through 8; defaults to 4").
- Mirrors of the rule and both skills under `extensions/drm-copilot/resources/claude-customizations/.claude/`.

**Tests pinning the boundary (all error-string and boundary-value pins):**

- `tests/scripts/dev_tools/test_parallel_manifest_contract.py:252` (in-range `[1, 2, 4, 8]` → add new upper bound), :262-272 (out-of-range `[0, -1, 9, 100, ...]` — **`9` becomes valid and `100` stays invalid under ceiling 32; replace `9` with `33`**, keep `100`; error string :270).
- `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py:191` (in-range `[1, 4, 8]`), :201-213 (out-of-range `[0, 9, -1, True, "4", 4.0, None]` — replace `9` with `33`; error prefix :210).
- `tests/scripts/dev_tools/test_validate_parallel_planner_state.py:211-222` (out-of-range `[0, -1, 9, ...]` — same treatment; error string :220-221) plus its in-range accept test.
- `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-core.test.ts:111` (in-range `[1, 4, 8]`), :118-133 (`[9, "9"]` row → `[33, "33"]`; error template :131).
- `extensions/drm-copilot/test/lib/validate/parallel-planner-state-core.test.ts:194` (same pattern).
- `tests/shell/parallel_manifest_validate.bats:74` ("found: 12." — **12 becomes valid at ceiling 32; the fixture value must move above the new ceiling**), :92 (valid at 8 — stays valid), :119 (`True`), :125 (`'four'`), :130-131 (`9` → above-ceiling value).
- Shared parity fixtures (consumed by both `tests/shell/parallel_manifest_parity.bats` and `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py`): `tests/fixtures/parallel_manifest_bash/manifest_m4_above_upper_bound.json` (uses 9 — raise above ceiling and update expected string), `manifest_m4_below_lower_bound.json` (0 — unchanged except error text), `manifest_m4_boolean_rejected.json`, `manifest_m4_non_integer.json` (error text only), `manifest_multiple_identity_errors_in_field_order.json` (**uses 12 as out-of-range — must move above the ceiling**), `manifest_accessor_open_mode_max_cap.json` (valid at 8; optionally raise to the new ceiling to keep exercising the boundary).
- `tests/fixtures/parallel_cohorts/batches_cap_exceeds_cohort_size.json` (uses 8 as a cap larger than the cohort — remains valid; no change required).

**Not changed:** epic validators (`validate_epic_orchestrator_state.py:118-121`, `validate_epic_planner_state.py:309-313`, their TS ports and tests) — the epic bound stays `1..8`. The frozen-surface hash pins (`PINNED_FROZEN_SURFACE_HASHES`, `parallel_orchestrator_surface_expectations.py:108-117`) cover epic files only and are unaffected.

**Prose-only vs code:** prose plus code across Python, TypeScript, bash, plus fixtures and mirrors. No PowerShell.

---

## D3 — Assertion seam for expected lane grouping

### D3.1 (Q3a) Field name and shape

**Recommended name: `expected_conflict_components`** (manifest frontmatter, optional).

Why it cannot be read as a `depends_on` synonym: (1) it names the **derived artifact it is compared against** — the connected components of the conflict graph — not a schedule, an ordering, or a dependency; (2) "expected" marks it as a prediction to be verified, the same register as a test expectation; (3) its value carries no pairwise direction and no sequence semantics — components are unordered sets, and set membership cannot encode "A before B". Rejected candidates: `lanes` / `expected_lanes` (a "lane" connotes a sequence of items executed in order — precisely the ordering reading that must be impossible); `grouping` (ambiguous between input and assertion).

**Value shape — a block sequence of named component objects:**

```yaml
expected_conflict_components:
  - name: hooks-lane          # optional, diagnostic label only
    members:                  # required, non-empty, positive ints
      - 101
      - 102
```

Justification: (a) it matches the manifest's existing `items[]` pattern (block sequence of mappings), which the bash YAML-subset parser demonstrably handles (`parallel-yaml-scan.sh` node paths like `items[0].blast_radius.paths[1]`); (b) non-empty **flow** sequences (`members: [101, 102]`) are out-of-subset for the bash parser (`parallel-yaml-scan.sh:26-27` rejects non-empty flow collections), so block sequences are mandatory; (c) the optional `name` makes diagnostics legible ("lane `hooks-lane` split across 2 derived components") without the bare list-of-lists' positional references.

### D3.2 (Q3b) Where the comparison runs and where components come from

**Connected components are not computed anywhere today.** `scripts/dev_tools/parallel_cohort_computation.py` computes only the Welsh-Powell coloring (independent sets, i.e., the transpose); grep for "component" across `scripts/dev_tools` finds no graph-component code on the parallel surface. The planner derives edges pairwise (`parallel-plan/SKILL.md:249-252`) and never groups them.

**Smallest correct place:** a new pure Python module `scripts/dev_tools/parallel_lane_assertion.py` — connected components via BFS/union-find over the same normalized adjacency `parallel_cohort_computation.py` builds internally, plus the comparison and report construction. A new module rather than an extension of `parallel_cohort_computation.py` because that file is at 469 lines and the 500-line ceiling leaves no room, and because the assertion is a separate concern (diagnostic, never scheduling). A thin CLI wrapper (or a subcommand of an existing dev-tools CLI) provides invocation; the planner's existing `"Bash(poetry run *)"` grant (`.claude/agents/parallel-planner.md:16`) covers it in-repo.

**When:** in the `## Cohort Seeding` procedure of `.claude/skills/parallel-plan/SKILL.md`, immediately after the conflict-edge set is derived (step 1, :249-252) and before or alongside the recomputation-parity check (:263-279) — the edges are final there and the diagnostic can reach the completion report.

**Output surface:** the planner **completion report** (`parallel-plan/SKILL.md:448-461` already enumerates required report content; add one line-item), plus stdout of the CLI. The planner **may** record the result as a tolerated extra checkpoint field (P1 is a required-key floor; extra fields like `plan_home_branch` are already permitted per :333-334), but no validator change is made for it and it is not recommended as a requirement. Report classes: expected-together-but-derived-apart (grouping did not survive), expected-apart-but-derived-together (two expected components merged by real contention), member naming no manifest item, and manifest item covered by no expected component (informational). All findings are **Advisory-style diagnostics**: they never block, never modify an edge, never feed `compute_cohorts`, and never influence scheduling.

**Destination-runtime note:** the diagnostic is deliberately repository-local (Python) in its first delivery. It is advisory-only, so the destination-runtime (no-Python) path losing it degrades gracefully; if destination parity is later wanted, a bash entry point would be a new `.claude/lib/bash/` file with pack-manifest, shell-QC, and kcov obligations — out of minimal scope here and explicitly deferred.

### D3.3 (Q3c) Rule-file amendment (at spec review, per the Enum Ownership discipline)

Amend `.claude/rules/parallel-orchestration.md`:

- **Manifest invariants:** add **M8** — `expected_conflict_components`, when present, must be a list of objects each carrying a required `members` list of positive integers (non-empty, each resolving to an `items[].issue_num`, no duplicate membership across components) and an optional non-empty-string `name`. When absent it contributes zero errors. State explicitly: the field is an ASSERTION consumed by a planner diagnostic; it never overrides a derived edge, never feeds `compute_cohorts`, and never influences scheduling.
- **M7 wording:** unchanged — the new key is not prohibited; note in M8 that its name deliberately references the derived conflict graph.
- **Planner checkpoint (P1/P3): unchanged.** The field is manifest-only. Recording the diagnostic result in the planner checkpoint remains a tolerated extra field, not a validated one.
- **Orchestrator checkpoint: unchanged.** The orchestrator never reads the field (the manifest is read-only static input; the field is consumed at planning time only).

This is the **minimal surface**: manifest-only plus a diagnostic. Enforcement remains prose + validator logic; no JSON Schema is authored or imported.

Validation implementation: key-gated check in `scripts/dev_tools/parallel_manifest_contract.py` (313 lines; room under the 500 cap) with the `Parallel manifest` error prefix, mirrored in `.claude/lib/bash/parallel-manifest-validate.sh` / `parallel-items-validate.sh` (187 lines; room) for the parity corpus. New shared fixtures under `tests/fixtures/parallel_manifest_bash/`. No TypeScript work — there is no TS manifest port (verified in D2.2).

An acceptable narrower alternative — validators stay entirely silent on the key and the diagnostic module alone reports malformed shape — was considered and rejected: the repository convention is fail-fast validation, and the parity-corpus mechanism makes the bash mirror cheap.

### D3.4 (Q3d) No prohibited-key collision; strict optionality

- `scan_prohibited_keys` (`parallel_manifest_contract.py:301-308`) rejects only `depends_on` at any depth (:69) and top-level `integration_branch` (:74). `expected_conflict_components` and its `name`/`members` sub-keys collide with neither. The checkpoint validators' prohibited-key scans (invariants 10/11, P3) never see the manifest field because it is never copied into a checkpoint.
- Strict optionality holds by construction: `validate_parallel_manifest_text` validates named invariants and prohibited keys only — unknown keys are tolerated today — so every existing manifest validates byte-identically; the new M8 check is presence-gated. Existing checkpoints are untouched (no checkpoint schema change). Backward-compatibility test: a fixture-corpus assertion that all pre-existing manifest fixtures produce byte-identical error lists before and after.

**Prose-only vs code:** prose (rule M8, `parallel-plan` skill, mirrors) plus code (Python manifest contract + new lane-assertion module + bash parity + fixtures/tests). No TypeScript, no PowerShell.

### D3 CHANGE INVENTORY

| File | Language | Kind |
|---|---|---|
| `.claude/rules/parallel-orchestration.md` (new M8; Enum Ownership note) | Markdown | Prose |
| `.claude/skills/parallel-plan/SKILL.md` (cohort-seeding + completion-report additions) | Markdown | Prose |
| `extensions/.../claude-customizations/.claude/rules/parallel-orchestration.md` | Markdown | Mirror |
| `extensions/.../claude-customizations/.claude/skills/parallel-plan/SKILL.md` | Markdown | Mirror |
| `scripts/dev_tools/parallel_manifest_contract.py` (key-gated M8) | Python | Production |
| `scripts/dev_tools/parallel_lane_assertion.py` (new: components + comparison + report) | Python | Production |
| `tests/scripts/dev_tools/test_parallel_manifest_contract.py`, new `test_parallel_lane_assertion.py` | Python | Test |
| `.claude/lib/bash/parallel-manifest-validate.sh` (and/or `parallel-items-validate.sh`) | Bash | Production |
| `extensions/.../claude-customizations/.claude/lib/bash/` mirrors of the above | Bash | Mirror |
| `tests/fixtures/parallel_manifest_bash/` new M8 fixtures; `tests/shell/parallel_manifest_validate.bats`; `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py` corpus | Bash/Python/JSON | Test |

---

## D4 — Staged intake for large runs

### D4.1 (Q4a) Current behavior — genuinely unbounded

`.claude/skills/parallel-plan/SKILL.md:64-67`: "One preparation-mode `Agent(orchestrator)` run per item. Preparation produces documents and plans rather than code, and items carry no ordering constraint, so **launch ALL item preparations concurrently: one message, N `Agent` calls**, each `isolation: "worktree"` and `run_in_background: true`."

`.claude/agents/parallel-planner.md:4` (frontmatter description): "...drives per-item preparation ... through **concurrent preparation-mode Agent(orchestrator) delegations**...". No cap exists anywhere on the preparation path. (The execution path is capped by `max_concurrency`; the F7 barrier hook explicitly does not gate preparation — `parallel-plan/SKILL.md:90-94`.)

The planner-surface contract test (`tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`) does **not** pin the fan-out sentence (verified by grep — no "concurrently"/"launch ALL"/fan-out fragment), so the prose edit collides with no pin.

### D4.2 (Q4b) Recommended fix: (b) as prose — a bounded preparation fan-out reusing existing primitives; no new orchestration primitive

**The existing primitives suffice; no new orchestration primitive is needed.** Specifically:

- **Recommended:** amend `## Preparation Fan-Out` in `parallel-plan/SKILL.md` to launch preparations in **waves of at most `max_concurrency`**, computed with the already-granted batching entry point: `bash .claude/lib/bash/compute-concurrency-batches.sh --keys "<all item keys>" --max-concurrency <n>` (the planner's allowlist already carries this grant, `.claude/agents/parallel-planner.md:18`; `compute_concurrency_batches` is generic over any key list, `parallel_cohort_computation.py:419-468`). Launch wave *k+1* when wave *k*'s children have terminated. This is prose-only: no schema field, no validator change, no new knob.
- **Why reuse `max_concurrency` rather than a distinct cap:** a preparation child and an execution child are the same workload class (a background `Agent(orchestrator)` in its own worktree running the full document/plan/preflight toolchain), so the operator's declared appetite for concurrent children applies to both phases; one knob avoids a second bounded-integer invariant across four languages. If operational experience later shows preparation needs a different setting, a distinct optional manifest key (e.g., `max_preparation_concurrency`, same bounds and boolean rejection as M4, defaulting to `max_concurrency`) is the natural extension — **explicitly not recommended now**; record the deferral in the skill.
- **Supplement, not primary path — (a) open mode + `/parallel-add`:** `/parallel-add` admits exactly **one** item per invocation with a sequential preparation child (`parallel-add/SKILL.md:27-29, 48-57`), so 69 items via add would be 57+ operator invocations of sequential preparations — not viable as intake. Its correct role is incremental admission into an already-running open-mode queue after the initial `/parallel-plan` cohort, which the skill already documents. Document this division of labor in the D4 prose.

### D4.3 (Q4c) 69-item sanity check under the recommendation

Manifest `max_concurrency: 13` (valid under D2's ceiling of 32):

- Preparation: `ceil(69 / 13) = 6` waves of concurrent preparation children. At roughly 0.5-2 hours per preparation child (promotion, research, spec/user-story, atomic plan, preflight — model-bound, concurrent within a wave), preparation runs ~3-12 hours unattended under a single `/parallel-plan` invocation. Operator actions: one invocation; zero actions between waves (the planner drives wave succession); per-item V1/V2 re-plan loops proceed inside their wave as today.
- Seeding: one `compute-cohorts.sh` call over all 69 keys; with 13 lanes of ~5-6 mutually conflicting items each, the coloring yields ~6 cohorts, cohort *k* holding ≈ the *k*-th item of each lane; the D3 diagnostic confirms the 13 derived components match the operator's 13 expected components.
- Execution: `/parallel-run` with the per-edge barrier (D1) advances all 13 lanes independently at up to 13 in-flight items; a blocked item stalls only its own lane's tail.
- Operator touch points end-to-end: `/parallel-plan`, review of the completion report (including the lane-assertion diagnostic), `/parallel-run`. Optional `/parallel-add` for late arrivals in open mode.

**Prose-only vs code:** prose only (`parallel-plan/SKILL.md`, `parallel-planner.md` description sentence) plus mirrors. No code in any language.

### D4 CHANGE INVENTORY

| File | Language | Kind |
|---|---|---|
| `.claude/skills/parallel-plan/SKILL.md` (`## Preparation Fan-Out`) | Markdown | Prose |
| `.claude/agents/parallel-planner.md` (frontmatter description + `## Delegation Model` if worded per-wave) | Markdown | Prose |
| `extensions/.../claude-customizations/.claude/skills/parallel-plan/SKILL.md` | Markdown | Mirror |
| `extensions/.../claude-customizations/.claude/agents/parallel-planner.md` | Markdown | Mirror |

---

## Cross-Cutting Constraints

1. **Bundle mirror.** Enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (existence verified). Mirrored files touched by this work: `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-add/SKILL.md`, `.claude/skills/parallel-remove/SKILL.md`, `.claude/agents/parallel-orchestrator.md`, `.claude/agents/parallel-planner.md`, `.claude/rules/parallel-orchestration.md`, `.claude/lib/bash/parallel-manifest-validate.sh` (and `parallel-items-validate.sh` if D3's bash check lands there) — each must be re-copied byte-identically under `extensions/drm-copilot/resources/claude-customizations/.claude/`. `docs/features/templates/parallel/parallel-status.md` is **not** mirrored (verified: no `templates/parallel` under extensions resources).
2. **Pack manifest.** No new `.claude` file is created by the recommended designs (D3's new module lives in `scripts/dev_tools/`), so `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` is untouched. This flips only if the deferred D3 bash entry point is pulled into scope.
3. **Per-file coverage gates.** No new TS module is needed (D2 edits constants in `parallel-orchestrator-state-core.ts` and `parallel-planner-state-core.ts`, both already gated at `extensions/drm-copilot/jest.config.cjs:183-190`; D3/D4 have no TS surface). No `jest.config.cjs` change.
4. **Reserved-body pins.** The three reserved headings are all released from the one-line-body pin (`FILLED_RESERVED_HEADINGS` holds F6 and F8; `LANDED_WAVE_FOUR_FEATURES` holds F7 — `parallel_orchestrator_surface_expectations.py:84, 93-103`); heading identity/order/uniqueness pins are unaffected because no heading is added, removed, or moved. The pins actually at risk are: **`COHORT_BARRIER_FRAGMENTS` (:154-159, pins the global sentence — must change with D1)** and `BOUNDARIES_REGENERATION_FRAGMENTS` (:184-192, pins "Every cohort transition, meaning every `current_cohort` increment" — keep that sentence verbatim in the skill to avoid churn). `MERGE_CONFLICT_FRAGMENTS` does not pin the "holds the cohort barrier" sentence at skill :313, so that rewording is pin-safe.
5. **Known TS parity divergences — not entered.** D2's change is a symmetric constant/error-string edit in both runtimes (integer bounds; `pythonRepr` quoting, integral floats, and boolean `===` semantics are untouched). D3 and D4 have no TS surface. D1's TS surface is zero (Layer 2's TS port is already per-edge). **None of the four defects forces work inside the three divergence classes.**
6. **No JSON Schema.** All D2/D3 schema changes are prose invariants plus validator logic, per the existing pattern. Nothing references the disqualified `drmoisan.github.io/mix-calculator/` artifact.
7. **Backward compatibility.** D2 widens an accepted range (every previously valid document stays valid; only error strings and previously rejected values change — fixtures with out-of-range exemplars `9` and `12` must move above the new ceiling). D3 is presence-gated (M8 fires only when the key exists; add a corpus test that all pre-existing fixtures validate byte-identically). D1/D4 change no validated artifact. The D1.6 offset generalization preserves today's behavior whenever all pinned items occupy `current_cohort`, which is every state reachable before D1 lands.
8. **Languages per defect.** D1: Markdown + Python (test-pin module; F6 offset). D2: Markdown + Python + TypeScript + bash (+ JSON fixtures). D3: Markdown + Python + bash. D4: Markdown only. PowerShell is touched by **no** defect (the Layer-1 hook is already per-edge).

## Test Strategy (proposed, no test code)

- **D1:** update `COHORT_BARRIER_FRAGMENTS` to pin the per-edge sentence and the two preserved arguments (safety anchor, availability scoping); for the F6 offset, add recolor tests for the multi-cohort-pinned state (pinned items at indices {0,1}, candidate conflicting with the index-1 pinned item must land strictly above 1) and a regression asserting the single-frontier case is unchanged; run the existing Layer-1 Pester suite and Layer-2 pytest suite unmodified as proof the enforcement layers did not move.
- **D2:** shift boundary parametrizations (accept new ceiling, reject ceiling+1) symmetrically across pytest, Jest, and bats; regenerate the shared manifest parity fixtures; assert the epic bound tests still pin `1..8`.
- **D3:** unit tests for component derivation (isolated vertices, chains, the 13-lane transpose), the four report classes, M8 key-gated validation in both runtimes over shared fixtures, and the byte-identical backward-compatibility corpus check.
- **D4:** no automated surface; the planner contract test suite must keep passing (no pinned fragment collides), and the 13-lane transpose integration fixture from the issue's validation ideas exercises seeding plus scheduling.
