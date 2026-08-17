# 2026-08-16-parallel-lane-scale-and-barrier-semantics (Spec)

- **Issue:** #479
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-16
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug — this file is the sole acceptance-criteria source; no `user-story.md` exists for this feature.

## Context

The `parallel` orchestration surface rejected a proposed work organization of 13 thematic lanes over 69 issues, executed as "lanes in parallel, items within a lane sequential". Four separate defects contribute: the documented cohort barrier is stricter than the barrier both enforcement layers actually implement, the `max_concurrency` ceiling of 8 cannot express 13 concurrent lanes, there is no way to assert an expected lane grouping against the derived conflict components, and there is no staged intake bounding preparation fan-out for a 69-item run.

Authoritative research: `research/2026-08-16T23-00-lane-scale-and-barrier-semantics-research.md` (per-defect change inventories with `file:line` citations, premise verification, test strategy). A second, narrower pass is retained at `research/2026-08-16T22-30-parallel-lane-scale-research.md`; where the two disagree (ceiling value, D3 value shape, D4 cap design), the authoritative artifact and the ratified decisions below win.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `/parallel-plan` over a 13-lane, 69-item proposal
- Data source or fixture: `.claude/rules/parallel-orchestration.md`, `.claude/skills/parallel-*/SKILL.md`, `scripts/dev_tools/validate_parallel_*.py`

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Blocker for lane-organized parallel runs: the surface cannot schedule a work organization it is structurally capable of expressing.

## Repro & Evidence

Steps to Reproduce:
1. Propose a parallel run of 13 thematic lanes covering 69 issues, where items within a lane mutually conflict and lanes are mutually disjoint.
2. Observe that the structure is the transpose of the existing cohort model: a cohort is an independent set in the conflict graph, so a lane whose items mutually conflict is naturally colored across cohorts `0..n-1`, and cohort `k` holds roughly the k-th item of each lane.
3. Attempt to set `max_concurrency` to 13 so that all lanes advance independently.
4. Attempt to confirm that the hand-authored lane grouping survived blast-radius derivation.
5. Attempt to prepare 69 items through `/parallel-plan`.

Expected: the cohort model already expresses the intent, so the run should schedule: 13 lanes should advance concurrently, the operator's expected grouping should be confirmable against the derived conflict components, and preparation should be bounded rather than fanning out 69 concurrent child orchestrators.

Actual: four defects prevent it (detail per defect below). The exact rejection text is no longer available, which is why all four contributing defects are addressed rather than only the one that fired.

## Scope & Non-Goals

- In scope: the four defects D1–D4 as specified below, their tests and fixtures, the required amendment to `.claude/rules/parallel-orchestration.md` (M8, A7 rewrite, invariant-4/M4 bound text), and byte-identical re-sync of the touched `.claude` mirror files under `extensions/drm-copilot/resources/claude-customizations/`.
- Out of scope / non-goals:
  - The epic surface. `max_parallel_features` stays `1..8`; no epic validator, TypeScript port, test, or frozen-surface hash pin changes.
  - Any change to the two barrier enforcement layers (`.claude/hooks/enforce-parallel-cohort-barrier.ps1`, `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` and its TypeScript port). Both already implement the target per-edge rule; D1 makes the prose match them, not the reverse.
  - A `max_preparation_concurrency` manifest key (D4 deferral — recorded as explicitly not-now).
  - A bash or destination-runtime port of the D3 lane-assertion diagnostic (explicitly deferred; the diagnostic is advisory-only and degrades gracefully on the no-Python path).
  - Any checkpoint (planner or orchestrator) schema change for D3 or D4.
  - Any JSON Schema file. Enforcement remains prose invariants plus validator logic, per the existing pattern.
  - Historical records restating the global barrier (`docs/research/2026-08-07-parallel-orchestration-design-research.md:124`, `docs/features/potential/promoted/2026-08-07-parallel-orchestrator-surface.md:38`, and the artifact sets under `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/`, `.../parallel-enforcement-hooks-440/`, `.../parallel-mutation-protocol-442/`) are evidence of past decisions, not runtime surfaces, and must not be edited.
- Explicitly excluded language: **PowerShell is touched by no defect.** The Layer-1 hook is already per-edge (`enforce-parallel-cohort-barrier.ps1:372-393`), so the absence of PowerShell changes in the delivery diff is correct, not a gap. Languages per defect: D1 Markdown + Python; D2 Markdown + Python + TypeScript + bash + JSON fixtures; D3 Markdown + Python + bash; D4 Markdown only.
- Note on rule-file edits: this spec describes the required amendments to `.claude/rules/parallel-orchestration.md`; the executor makes them. The spec author does not modify rule files.

## Root Cause Analysis

- **D1** is a documentation defect with one contained code consequence. Both mechanical layers already implement the per-edge predicate; only the prose overstates it. However, the F6 mutation engine's pinned-barrier offset (`scripts/dev_tools/parallel_mutation_protocol.py:321-327`) is sound only under the global rule its docstring (:253-257) cites: under per-edge semantics, in-flight items can occupy multiple cohort indices, and the `current_cohort + 1` shift can place a deferred candidate at the same index as a pinned conflicting item — a coloring violation and a Layer-2 structural violation. Additionally, the exact global-barrier sentence is pinned as a required text fragment by `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:154-159` (`COHORT_BARRIER_FRAGMENTS`), so the prose fix fails CI unless the pin changes in the same commit.
- **D2**: the bound `1..8` was adopted "for symmetry with the epic surface" (rule file, section "Concurrency Bound (A7)"), not derived from any constraint. The honest constraint analysis (research D2.1): no constraint binds hard below O(100) concurrent worktrees; the first-binding constraint is GitHub Actions job concurrency at roughly 10-20 concurrent items, and it binds by queuing, not by failing.
- **D3**: the planner derives grouping from blast radii with no confirmation seam. The fix must add an ASSERTION seam, never a DECLARATION seam: the field must never override a derived edge, never feed `compute_cohorts`, and never influence scheduling, preserving the fail-closed derivation, the prohibition on narrowing a radius to suppress an edge (`.claude/skills/parallel-plan/SKILL.md:190-192`), and the `depends_on` prohibition (invariant 10, P3, M7). Because it adds a manifest key, the rule file must be amended at spec time per its own "Enum Ownership" discipline.
- **D4**: `.claude/skills/parallel-plan/SKILL.md:64-67` instructs "launch ALL item preparations concurrently: one message, N `Agent` calls". No cap exists anywhere on the preparation path (the execution path is capped by `max_concurrency`; the F7 barrier hook explicitly does not gate preparation). The planner-surface contract tests pin no fan-out sentence, so the prose edit collides with no pin.

## Proposed Fix

### D1 — Replace the documented global barrier with the enforced per-edge rule

**Defect.** `.claude/skills/parallel-orchestrate/SKILL.md:118-123` specifies a GLOBAL barrier: cohort `N+1` branches from `main` only after every cohort-`N` item is `merged` or `worktree_removed`. Neither enforcement layer implements it; both implement a strictly weaker PER-EDGE predicate (Layer 1: `enforce-parallel-cohort-barrier.ps1:372-393`; Layer 2: `_parallel_orchestrator_state_cohort_barrier.py:282-328`). Under the documented global rule a single `blocked_ci_loop_limit` item halts every lane.

**Fix — target barrier rule.** Replace the global rule, at every runtime restatement, with the per-edge rule both layers already implement:

> An item may start only when every conflicting neighbour (`conflict_edges[]`) that sits in a strictly prior current-generation cohort has `merge_status` of `merged` or `worktree_removed`. `ci_green` does not satisfy the barrier. Same-cohort and later-cohort neighbours do not hold an item back, and items with no conflicting prior-cohort neighbour may start regardless of other cohorts' progress.

**Fix — `current_cohort` redefinition.** `current_cohort` is redefined as a PROGRESS INDICATOR — the lowest current-generation cohort index still containing a non-terminal, non-withdrawn item — updated only on durable confirmation (`git worktree list --porcelain`, `git branch`, `gh pr view --json state,mergedAt,headRefOid`), gating nothing. Invariant 14 (a bound) is unchanged. The pinned sentence "Every cohort transition, meaning every `current_cohort` increment" (`BOUNDARIES_REGENERATION_FRAGMENTS`, `parallel_orchestrator_surface_expectations.py:184-192`) is kept verbatim in the skill.

**Fix — arguments the prose must preserve** (anchors verified in research D1.5):
- *Safety.* An item launching under the per-edge rule while a non-conflicting prior-cohort item is still open branches from a `main` that lacks only non-conflicting merged work — byte-for-byte the situation `.claude/skills/parallel-orchestrate/SKILL.md:100-103` already accepts as safe for two same-cohort items.
- *Availability.* Under the global barrier a single `blocked_ci_loop_limit` or `blocked_drift` item halts every lane; under the per-edge rule it holds only its conflicting later-cohort neighbours and, transitively, its own conflict component's tail, while other lanes advance.

**Fix — differing fail-closed behavior the prose must describe** (research D1.3):
- *Layer 1 (prospective, per launch)* denies fail-closed on: missing/unparseable checkpoint, unresolved feature-folder token, missing `items[]` record, target with no current-generation cohort assignment, missing neighbour record, missing neighbour `merge_status`. It *skips* (allows past) a neighbour that has no current-generation cohort assignment.
- *Layer 2 (retrospective, per edge)* is deliberately silent on unjudgeable edges (shape errors are invariant 15's to report) and applies three readings: a *structural* reading — two conflicting items colored into the same current-generation cohort is a violation outright, a reading Layer 1 has no counterpart for; a *status* reading — the retrospective contrapositive of the per-edge launch rule; and a *temporal* reading — `merged_at(earlier) > worktree_created_at(later)`, degrading to status-only when either timestamp is absent or non-string.

**Fix — code obligations (D1 is prose PLUS code):**
1. *F6 pinned-barrier offset generalization.* `recolor_unstarted` (`scripts/dev_tools/parallel_mutation_protocol.py:200-341`) currently computes `cohort_offset = current_cohort + 1 if crosses_pinned else current_cohort` (:327), justified by the global rule (docstring :253-257). Generalize the offset to shift above the HIGHEST current-generation cohort index occupied by any pinned item when `crosses_pinned` is true (e.g., a required keyword-only `highest_pinned_cohort: int` parameter; `cohort_offset = highest_pinned_cohort + 1 if crosses_pinned else current_cohort`). When all pinned items sit at `current_cohort` — every state reachable today — behavior is identical. The shift stays uniform to preserve injectivity (docstring :233-236); per-component precision is not required. Update the docstrings in `parallel_mutation_protocol.py:253-262` and `_parallel_mutation_models.py:303-309` so they no longer cite the global rule.
2. *Test-pin update.* `COHORT_BARRIER_FRAGMENTS` (`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:154-159`) pins the exact global sentence and MUST be updated in the same commit to pin the new per-edge sentence, or CI fails.

**Surfaces touched** (research D1 change inventory):

| File | Kind |
|---|---|
| `.claude/skills/parallel-orchestrate/SKILL.md` (:118-123 primary definition; :156-158 fetch per launch batch, not per cohort; :311-314 blocked-item scope narrowed to conflicting later-cohort neighbours; :505-510 F6 narrative) | Prose |
| `.claude/agents/parallel-orchestrator.md` (:190-193 full restatement) | Prose |
| `.claude/skills/parallel-add/SKILL.md` (:87-89 single-frontier phrase) | Prose |
| `.claude/skills/parallel-remove/SKILL.md` (:87-90 single-frontier phrase) | Prose |
| `docs/features/templates/parallel/parallel-status.md` (:32 progress-indicator semantics; not mirrored) | Prose |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (:154-159) | Test pin |
| `scripts/dev_tools/parallel_mutation_protocol.py`, `scripts/dev_tools/_parallel_mutation_models.py` | Production |
| `tests/scripts/dev_tools/test_parallel_mutation_recolor.py` (and siblings pinning offset behavior) | Test |
| Mirrors of the four `.claude` prose files under `extensions/drm-copilot/resources/claude-customizations/.claude/` | Mirror |

Already correct, no change: `.claude/skills/parallel-orchestrate/SKILL.md:146` and :637-639 (already per-edge), the Layer-1 hook docstring and deny-reason text, `.claude/skills/parallel-run/SKILL.md:48`, `.claude/agents/parallel-orchestrator.md:64,154` (topic listings), `.claude/skills/parallel-close/SKILL.md`, and `.claude/rules/parallel-orchestration.md` (states no barrier rule). No PowerShell, TypeScript, or bash change: Layer 1 and Layer 2 (plus its TS port) are already per-edge.

### D2 — Raise the `max_concurrency` ceiling to 32

**Defect.** The bound `1..8` (orchestrator invariant 4, planner P2, manifest M4) cannot express 13 concurrent lanes. The recorded rationale for 8 is epic-surface symmetry, not a real constraint.

**Fix.** The bound becomes `1..32`. The default stays `4` everywhere. Booleans remain rejected in all three runtimes. The epic surface's `max_parallel_features` stays `1..8` and does not change.

**A7 rationale rewrite.** The "Concurrency Bound (A7)" section of `.claude/rules/parallel-orchestration.md` is rewritten to record the real derivation and to DROP the epic-symmetry rationale that caused the defect. The honest finding to record: no constraint binds hard below O(100) concurrent worktrees; the first-binding constraint is GitHub Actions job concurrency at roughly 10-20 concurrent items, which degrades by queuing, not failure. The ceiling of 32 is therefore explicitly a SANITY limit (rejecting order-of-magnitude operator errors), not a capacity limit. Under the per-edge barrier (D1), mutual exclusion within a conflict component is automatic, so `max_concurrency` is a pure throughput throttle.

**Surfaces touched** (research D2.2 inventory):

- Python production: `scripts/dev_tools/parallel_manifest_contract.py:65` (`MAX_CONCURRENCY`), `validate_parallel_orchestrator_state.py:71`, `validate_parallel_planner_state.py:64`, plus their error strings, plus the `_parallel_state_common.py:196-197` docstring ("1 through 8 (A7)").
- TypeScript parity ports: `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts:70`, `parallel-planner-state-core.ts:66`, plus error strings. There is no TypeScript manifest port.
- Bash parity: `.claude/lib/bash/parallel-manifest-validate.sh:44-46` (`PM_MAX_CONCURRENCY`), error :118-119, plus its byte-identical mirror.
- Prose: `.claude/rules/parallel-orchestration.md` (invariant 4, M4, A7 section), `.claude/skills/parallel-orchestrate/SKILL.md:67-68`, `.claude/skills/parallel-plan/SKILL.md:256, 288`, `docs/features/templates/parallel/parallel-status.md:31`, plus mirrors.
- Tests and fixtures pinning the boundary — with the out-of-range exemplar migration: fixtures using `9` and `12` as out-of-range exemplars become VALID at ceiling 32 and must move above the new ceiling:
  - `tests/scripts/dev_tools/test_parallel_manifest_contract.py:252` (in-range set gains 32), :262-272 (`9` → `33`; `100` stays invalid).
  - `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py:191, 201-213` (`9` → `33`).
  - `tests/scripts/dev_tools/test_validate_parallel_planner_state.py:211-222` plus its in-range accept test.
  - `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-core.test.ts:111, 118-133` (`[9, "9"]` → `[33, "33"]`); `parallel-planner-state-core.test.ts:194` (same pattern).
  - `tests/shell/parallel_manifest_validate.bats:74` (`12` becomes valid — the fixture value must move above 32), :92, :119, :125, :130-131 (`9` → above-ceiling value).
  - Shared parity fixtures under `tests/fixtures/parallel_manifest_bash/`: `manifest_m4_above_upper_bound.json` (`9` → above-ceiling, expected string updated), `manifest_m4_below_lower_bound.json` (error text only), `manifest_m4_boolean_rejected.json`, `manifest_m4_non_integer.json` (error text only), `manifest_multiple_identity_errors_in_field_order.json` (`12` → above-ceiling).
  - `tests/fixtures/parallel_cohorts/batches_cap_exceeds_cohort_size.json` remains valid; no change required.

**Not changed:** epic validators (`validate_epic_orchestrator_state.py:118-121`, `validate_epic_planner_state.py:309-313`), their TS ports and tests, and the frozen-surface hash pins (`PINNED_FROZEN_SURFACE_HASHES`, epic files only).

### D3 — Manifest assertion seam `expected_conflict_components` (new invariant M8)

**Defect.** The planner derives grouping from blast radii; there is no confirmation that a hand-authored lane grouping survived derivation and no diagnostic when it does not.

**Fix — field.** A new OPTIONAL, manifest-only frontmatter key `expected_conflict_components`, validated key-gated as new rule invariant **M8**. Planner and orchestrator checkpoints are UNCHANGED. Value shape — a BLOCK sequence of objects, each with a required non-empty `members` list of positive `issue_num` integers and an optional diagnostic `name` string:

```yaml
expected_conflict_components:
  - name: hooks-lane          # optional, diagnostic label only
    members:                  # required, non-empty, positive ints
      - 101
      - 102
```

Block sequences are mandatory because the bash YAML subset parser rejects non-empty flow collections (`parallel-yaml-scan.sh:26-27`).

**Fix — M8 rule amendment** (described here; the executor amends `.claude/rules/parallel-orchestration.md`): `expected_conflict_components`, when present, must be a list of objects each carrying a required `members` list of positive integers (non-empty, each resolving to an `items[].issue_num`, no duplicate membership across components) and an optional non-empty-string `name`. When absent it contributes zero errors. The rule text states explicitly: the field is an ASSERTION consumed by a planner diagnostic; it never overrides a derived edge, never feeds `compute_cohorts`, and never influences scheduling; its name deliberately references the derived conflict graph. M7 wording is unchanged (the new key is not prohibited).

**Fix — validators.** Key-gated M8 check in `scripts/dev_tools/parallel_manifest_contract.py` (`Parallel manifest` error prefix), mirrored in the bash parity layer (`.claude/lib/bash/parallel-manifest-validate.sh` and/or `parallel-items-validate.sh`) over new shared fixtures in `tests/fixtures/parallel_manifest_bash/`. No TypeScript work: there is no TS manifest port. The prohibited-key scans are unaffected: `scan_prohibited_keys` rejects only `depends_on` (any depth) and top-level `integration_branch`; the new key and its sub-keys collide with neither.

**Fix — diagnostic.** A new pure Python module `scripts/dev_tools/parallel_lane_assertion.py`: connected components via BFS/union-find over the same normalized adjacency `parallel_cohort_computation.py` builds internally (components are not computed anywhere today), plus the comparison and report construction. A new module rather than an extension because `parallel_cohort_computation.py` is at 469 lines against the 500-line ceiling and the assertion is a separate concern. Invocation via a thin CLI wrapper covered by the planner's existing `Bash(poetry run *)` grant. It runs in the `## Cohort Seeding` procedure of `.claude/skills/parallel-plan/SKILL.md`, immediately after the conflict-edge set is derived (:249-252), and its result is added as a line-item to the planner completion report (:448-461). Report classes: expected-together-but-derived-apart; expected-apart-but-derived-together; member naming no manifest item; manifest item covered by no expected component (informational). All findings are Advisory-style diagnostics: they never block, never modify an edge, never feed `compute_cohorts`, and never influence scheduling. Recording the result in the planner checkpoint remains a tolerated extra field, not a validated one; no validator change is made for it.

**Surfaces touched:** `.claude/rules/parallel-orchestration.md` (M8), `.claude/skills/parallel-plan/SKILL.md` (cohort-seeding + completion-report additions), their mirrors, `scripts/dev_tools/parallel_manifest_contract.py`, new `scripts/dev_tools/parallel_lane_assertion.py`, `.claude/lib/bash/parallel-manifest-validate.sh` (and/or `parallel-items-validate.sh`) plus mirror, new M8 fixtures, `tests/shell/parallel_manifest_validate.bats`, `tests/scripts/dev_tools/test_parallel_manifest_contract.py`, new `test_parallel_lane_assertion.py`, and the parity corpus (`tests/shell/parallel_manifest_parity.bats`, `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py`). No TypeScript, no PowerShell.

### D4 — Bounded preparation fan-out (prose only)

**Defect.** `/parallel-plan` launches ALL item preparations concurrently (`.claude/skills/parallel-plan/SKILL.md:64-67`); 69 concurrent preparation-mode child orchestrators is not viable.

**Fix.** Prose-only bounded fan-out. Amend `## Preparation Fan-Out` in `.claude/skills/parallel-plan/SKILL.md` to launch preparations in waves of at most `max_concurrency`, batched with the already-granted entry point `bash .claude/lib/bash/compute-concurrency-batches.sh --keys "<all item keys>" --max-concurrency <n>` (planner allowlist grant at `.claude/agents/parallel-planner.md:18`; the function is a generic deterministic chunker with no barrier logic). Wave *k+1* launches when wave *k*'s children have terminated. No new orchestration primitive, no new schema field, no validator change, no new knob: a preparation child and an execution child are the same workload class, so the operator's declared appetite for concurrent children applies to both phases.

Document `/parallel-add`'s role as incremental admission into an already-running open-mode queue, NOT as the intake path: it admits exactly one item per invocation with a sequential preparation child, so 69 items via add would be 57+ operator invocations. Record the deferred `max_preparation_concurrency` manifest extension (same bounds and boolean rejection as M4, defaulting to `max_concurrency`) as explicitly not-now.

Sanity check at the motivating scale (research D4.3): with `max_concurrency: 13` (valid under the new ceiling), preparation runs `ceil(69/13) = 6` waves under a single `/parallel-plan` invocation with zero operator actions between waves; the D3 diagnostic then confirms the 13 derived components; `/parallel-run` under the per-edge barrier advances all 13 lanes independently.

**Surfaces touched:** `.claude/skills/parallel-plan/SKILL.md` (`## Preparation Fan-Out`), `.claude/agents/parallel-planner.md` (frontmatter description, and `## Delegation Model` if worded per-wave), plus their mirrors. Markdown only; no code in any language. The planner-surface contract tests pin no fan-out fragment, so no test change is forced.

### Cross-Cutting

1. **Mirror re-sync.** Eight mirrored `.claude` files are touched and must be re-copied byte-identically under `extensions/drm-copilot/resources/claude-customizations/.claude/`: `skills/parallel-orchestrate/SKILL.md`, `skills/parallel-plan/SKILL.md`, `skills/parallel-add/SKILL.md`, `skills/parallel-remove/SKILL.md`, `agents/parallel-orchestrator.md`, `agents/parallel-planner.md`, `rules/parallel-orchestration.md`, `lib/bash/parallel-manifest-validate.sh` (plus `lib/bash/parallel-items-validate.sh` if D3's bash check lands there). Enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. `docs/features/templates/parallel/parallel-status.md` is not mirrored and no mirror is created for it.
2. **Pack manifest.** No new `.claude` file is created (D3's new module lives in `scripts/dev_tools/`), so `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` is untouched.
3. **Per-file coverage gates.** No new TS module; no `jest.config.cjs` change. New Python modules meet the uniform coverage thresholds.
4. **Test pins.** `COHORT_BARRIER_FRAGMENTS` changes with D1 (same commit). `BOUNDARIES_REGENERATION_FRAGMENTS` is kept satisfied by preserving its pinned sentence verbatim. Heading identity/order/uniqueness pins are unaffected (no heading added, removed, or moved). `MERGE_CONFLICT_FRAGMENTS` does not pin the reworded sentence at skill :313.
5. **Known TS parity divergences — not entered.** D2's change is a symmetric constant/error-string edit; the three known divergence classes (`pythonRepr` quote selection at `parallel-state-shared.ts:112-132`, integral floats, boolean `===` at `parallel-state-structures.ts:228`) are neither entered nor "fixed". D1's TS surface is zero; D3 and D4 have no TS surface.
6. **No JSON Schema.** All schema changes are prose invariants plus validator logic. Nothing references the disqualified `drmoisan.github.io/mix-calculator/` artifact.
7. **Backward compatibility.** D2 widens an accepted range (every previously valid document stays valid; only error strings and previously rejected exemplars change). D3 is presence-gated. D1/D4 change no validated artifact. The D1 offset generalization preserves today's behavior whenever all pinned items occupy `current_cohort`, which is every state reachable before D1 lands.

## Assumptions, Constraints, Dependencies

- Assumptions: the two research artifacts' `file:line` citations are current as of branch creation; the executor re-verifies anchors before editing.
- Constraints: 500-line file ceiling (motivates the new `parallel_lane_assertion.py` module); the bash YAML subset parser rejects non-empty flow collections (motivates M8's block-sequence mandate); uniform coverage thresholds (line >= 85%; branch >= 75% where measured; PowerShell/bash exempt from the branch threshold only).
- External dependencies: none. No new libraries.

## Data / API / Config Impact

- User-facing changes: `max_concurrency` accepts `1..32` (default `4` unchanged) across manifest, planner checkpoint, and orchestrator checkpoint; new optional manifest key `expected_conflict_components`; planner completion report gains a lane-assertion line-item; preparation fan-out becomes wave-bounded.
- Data or migration considerations: none. No existing valid artifact becomes invalid; no checkpoint schema changes.
- Compatibility notes: validator error strings that embed the bound change from `8` to `32` in all three runtimes in the same commit to preserve byte-parity.

## Test Strategy

- **D1:** update `COHORT_BARRIER_FRAGMENTS` to pin the per-edge sentence; add recolor tests for the multi-cohort-pinned state (pinned items at indices {0,1}, a candidate conflicting with the index-1 pinned item must land strictly above 1) and a regression asserting the single-frontier case is unchanged; run the existing Layer-1 Pester suite and Layer-2 pytest suite unmodified as proof the enforcement layers did not move.
- **D2:** shift boundary parametrizations (accept 32, reject 33) symmetrically across pytest, Jest, and bats; migrate out-of-range exemplars `9` and `12` above the ceiling; regenerate the shared manifest parity fixtures; assert the epic bound tests still pin `1..8`; keep boolean-rejection cases in all three runtimes.
- **D3:** unit tests for component derivation (isolated vertices, chains, the 13-lane transpose), the four report classes, M8 key-gated validation in Python and bash over shared fixtures with identical error lists, and the byte-identical backward-compatibility corpus check.
- **D4:** no automated surface; the planner contract test suite must keep passing, and the 13-lane transpose integration fixture exercises seeding plus scheduling.
- Toolchain: full seven-stage loop (format, lint, type check, architecture, unit, contract, integration) repeated until a single clean pass.

## Acceptance Criteria

### D1 — Barrier semantics

- [x] AC1: `.claude/skills/parallel-orchestrate/SKILL.md` (the `## Cohort Barrier and Max-Concurrency Slot Filling` section, replacing :118-123) states the per-edge rule containing verbatim: "An item may start only when every conflicting neighbour (`conflict_edges[]`) that sits in a strictly prior current-generation cohort has `merge_status` of `merged` or `worktree_removed`", plus the `ci_green` exclusion and the same-cohort/later-cohort/no-neighbour non-blocking clauses. Verified by file inspection.
- [x] AC2: `.claude/agents/parallel-orchestrator.md` (:190-193 restatement) carries the same per-edge rule and no global-barrier wording. Verified by file inspection.
- [x] AC3: The dependent restatements are reworded consistently with the per-edge rule: `parallel-orchestrate/SKILL.md` :156-158 (fetch before each launch batch, not each cohort launch), :311-314 (a blocked item holds only its conflicting later-cohort neighbours), :505-510 (F6 narrative consistent with D1's offset generalization); `parallel-add/SKILL.md` :87-89 and `parallel-remove/SKILL.md` :87-90 (single-frontier "index the pinned items occupy" phrasing removed or corrected). Verified by file inspection of each site.
- [x] AC4: `grep -r "only after every cohort" .claude/ docs/features/templates/` returns zero matches (the global sentence survives nowhere on a runtime surface; historical records under `docs/research/` and `docs/features/active|potential/` are untouched and out of grep scope). Verified by command.
- [x] AC5: `current_cohort` is documented as a progress indicator — the lowest current-generation cohort index still containing a non-terminal, non-withdrawn item, updated only on durable confirmation, gating nothing — in `parallel-orchestrate/SKILL.md`, `parallel-orchestrator.md`, and `docs/features/templates/parallel/parallel-status.md:32`. Rule-file invariant 14 text is unchanged. Verified by file inspection and `git diff` showing no invariant-14 edit.
- [x] AC6: The skill prose describes the two layers' differing fail-closed behavior: Layer 1's target-side denials (missing/unparseable checkpoint, unresolved token, missing item record, target without current-generation assignment, missing neighbour record, missing neighbour `merge_status`) versus its neighbour-side skip (neighbour without current-generation assignment), and Layer 2's three readings (structural same-cohort — which Layer 1 has no counterpart for — status, and temporal with status-only degradation). Verified by file inspection.
- [x] AC7: The safety argument is preserved and anchored: the prose states that an item branching from a `main` lacking only non-conflicting merged work is the same situation the skill's same-cohort merge-order text (currently :100-103) accepts as safe, and that same-cohort text itself is unchanged. Verified by file inspection.
- [x] AC8: The availability argument is preserved: the prose states that under the per-edge rule a `blocked_ci_loop_limit`/`blocked_drift` item holds only its own conflict component's tail while unrelated lanes advance. Verified by file inspection.
- [x] AC9: The sentence "Every cohort transition, meaning every `current_cohort` increment" is present verbatim in `parallel-orchestrate/SKILL.md`, and the `BOUNDARIES_REGENERATION_FRAGMENTS` expectations pass without modification. Verified by `grep` and by the surface-contract pytest suite.
- [x] AC10: `COHORT_BARRIER_FRAGMENTS` (`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:154-159`) pins the new per-edge sentence (global sentence removed), and `test_orchestrate_skill_section_states_its_required_obligations` passes. Verified by test run.
- [x] AC11: `recolor_unstarted` in `scripts/dev_tools/parallel_mutation_protocol.py` computes the pinned-crossing offset from the highest current-generation cohort index occupied by any pinned item (not `current_cohort + 1`), with a uniform shift preserving injectivity; the docstrings at `parallel_mutation_protocol.py:253-262` and `_parallel_mutation_models.py:303-309` no longer justify the offset by the global increment rule. Verified by file inspection and unit tests.
- [x] AC12: A new regression test covers the multi-cohort-pinned state: with pinned items occupying current-generation indices {0, 1} and `current_cohort == 0`, a deferred candidate conflicting with the index-1 pinned item lands at an index strictly greater than 1. Verified by pytest.
- [x] AC13: A new regression test asserts the single-frontier case is unchanged: when every pinned item occupies `current_cohort`, the generalized offset produces the same recoloring as the previous behavior; all pre-existing recolor tests pass with no behavioral edits (signature-only updates permitted). Verified by pytest.
- [ ] AC14: No enforcement-layer file is modified: `git diff --name-only` against the merge base contains no `.ps1` file at all (PowerShell is touched by no defect) and does not contain `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` or its TypeScript port; the existing Layer-1 Pester suite and Layer-2 barrier pytest suite pass unmodified. Verified by command and test runs.

### D2 — Concurrency ceiling

- [x] AC15: All six code constants change from 8 to 32: `scripts/dev_tools/parallel_manifest_contract.py:65`, `scripts/dev_tools/validate_parallel_orchestrator_state.py:71`, `scripts/dev_tools/validate_parallel_planner_state.py:64`, `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts:70`, `extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts:66`, `.claude/lib/bash/parallel-manifest-validate.sh:44-46`. Verified by file inspection.
- [ ] AC16: Every validator error string embedding the bound reports 32 in all three runtimes, and the Python/bash and Python/TS parity suites pass over the updated strings. Verified by test runs (parity corpus and TS core tests).
- [x] AC17: All prose bound statements report `1..32` with default 4: rule invariant 4 and M4 (P2 references invariant 4), `parallel-orchestrate/SKILL.md:67-68`, `parallel-plan/SKILL.md:256, 288`, `docs/features/templates/parallel/parallel-status.md:31`, and the `_parallel_state_common.py:196-197` docstring. Verified by `grep -rn "1 through 8"` over `.claude/ docs/features/templates/ scripts/dev_tools/` returning zero matches on parallel-surface files.
- [x] AC18: The "Concurrency Bound (A7)" section of `.claude/rules/parallel-orchestration.md` is rewritten to: state the `1..32` bound and default 4; record that no constraint binds hard below O(100) concurrent worktrees; identify GitHub Actions job concurrency (~10-20 concurrent items, degrading by queuing, not failure) as the first-binding constraint; declare the ceiling a sanity limit, not a capacity limit; and contain no epic-symmetry rationale. Verified by file inspection and `grep -n "symmetry" .claude/rules/parallel-orchestration.md` returning zero matches.
- [x] AC19: The epic surface is unchanged: `git diff --name-only` contains none of `validate_epic_orchestrator_state.py`, `validate_epic_planner_state.py`, their TypeScript ports, or their tests; the epic bound tests still pin `1..8` and pass. Verified by command and test run.
- [x] AC20: The default of 4 is unchanged: `manifest_max_concurrency` returns 4 when the key is absent, and its existing default tests pass unmodified. Verified by pytest.
- [ ] AC21: Boundary parametrizations accept 32 and reject 33 symmetrically in pytest (`test_parallel_manifest_contract.py`, `test_validate_parallel_orchestrator_state.py`, `test_validate_parallel_planner_state.py`), Jest (`parallel-orchestrator-state-core.test.ts`, `parallel-planner-state-core.test.ts`), and bats (`parallel_manifest_validate.bats`). Verified by test runs.
- [x] AC22: Every out-of-range exemplar that becomes valid at ceiling 32 is migrated above the ceiling: `9` in `test_parallel_manifest_contract.py:262-272`, `test_validate_parallel_orchestrator_state.py:201-213`, `test_validate_parallel_planner_state.py:211-222`, the TS `[9, "9"]` rows, `parallel_manifest_validate.bats:130-131`, and `tests/fixtures/parallel_manifest_bash/manifest_m4_above_upper_bound.json`; `12` in `parallel_manifest_validate.bats:74` and `tests/fixtures/parallel_manifest_bash/manifest_multiple_identity_errors_in_field_order.json`. `100` remains an invalid exemplar. Verified by grep over the named files showing no in-range value used as an out-of-range exemplar, and by the suites passing.
- [ ] AC23: Boolean values remain rejected for `max_concurrency` in Python, TypeScript, and bash (existing boolean-rejection tests and the `manifest_m4_boolean_rejected.json` fixture pass unmodified except for error-text bound updates). Verified by test runs.

### D3 — Lane-grouping assertion seam

- [x] AC24: `.claude/rules/parallel-orchestration.md` carries a new manifest invariant M8 for `expected_conflict_components` specifying: optional, key-gated (absent contributes zero errors); a list of objects each with required non-empty `members` of positive integers, each resolving to an `items[].issue_num`, no duplicate membership across components; optional non-empty-string `name`; and the explicit assertion-only statement (never overrides a derived edge, never feeds `compute_cohorts`, never influences scheduling). M7 text is unchanged. Verified by file inspection.
- [x] AC25: `scripts/dev_tools/parallel_manifest_contract.py` implements the key-gated M8 check with the `Parallel manifest` error prefix; a manifest without the key produces a byte-identical error list to before the change. Verified by pytest, including a key-absent test.
- [x] AC26: M8 negative-path unit tests cover: non-list value, non-object entry, missing/empty `members`, non-positive or non-integer member, member resolving to no `items[].issue_num`, duplicate membership across components, and empty-string `name`; positive-path tests cover a named and an unnamed component in block-sequence form. Verified by pytest.
- [ ] AC27: The bash parity layer (`.claude/lib/bash/parallel-manifest-validate.sh` and/or `parallel-items-validate.sh`) implements the same M8 check; new shared fixtures under `tests/fixtures/parallel_manifest_bash/` are consumed by both `tests/shell/parallel_manifest_parity.bats` and `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py` with identical error lists in both runtimes, and a block-sequence M8 fixture is accepted by the bash YAML subset parser. Verified by bats and pytest parity runs.
- [x] AC28: A new module `scripts/dev_tools/parallel_lane_assertion.py` (<= 500 lines, pure logic, no I/O beyond its CLI wrapper) derives connected components of the conflict graph and compares them to the asserted components, producing the four report classes (expected-together-but-derived-apart, expected-apart-but-derived-together, member naming no manifest item, manifest item covered by no expected component). Unit tests in `tests/scripts/dev_tools/test_parallel_lane_assertion.py` cover isolated vertices, chains, the 13-lane transpose, and all four report classes. Verified by pytest and line count.
- [x] AC29: `.claude/skills/parallel-plan/SKILL.md` runs the lane-assertion diagnostic in `## Cohort Seeding` immediately after conflict-edge derivation and adds its result as a required line-item of the planner completion report, with explicit advisory-only wording. Verified by file inspection.
- [x] AC30: The diagnostic has no scheduling influence: `scripts/dev_tools/parallel_cohort_computation.py` is unmodified (`git diff --name-only`), and `grep -rn "parallel_lane_assertion" scripts/dev_tools/` shows it imported by no cohort-computation, validation, or mutation module. Verified by command.
- [x] AC31: No TypeScript manifest port is created and no checkpoint validator (Python, TypeScript) changes for D3: the planner and orchestrator checkpoint validators' diffs contain no M8 or `expected_conflict_components` logic. Verified by `git diff` inspection and `grep -rn "expected_conflict_components" extensions/drm-copilot/src/` returning zero matches.

### D4 — Bounded preparation fan-out

- [x] AC32: `## Preparation Fan-Out` in `.claude/skills/parallel-plan/SKILL.md` instructs launching preparations in waves of at most `max_concurrency`, computed with `bash .claude/lib/bash/compute-concurrency-batches.sh`, launching wave k+1 only after wave k's children have terminated; the "launch ALL item preparations concurrently" instruction is removed. Verified by file inspection and `grep -n "launch ALL" .claude/skills/parallel-plan/SKILL.md` returning zero matches.
- [x] AC33: The `.claude/agents/parallel-planner.md` frontmatter description (and `## Delegation Model` if it restates fan-out) is reworded to bounded-wave preparation. Verified by file inspection.
- [x] AC34: The skill documents `/parallel-add` as incremental admission into an already-running open-mode queue and explicitly not the intake path, and records the deferred `max_preparation_concurrency` extension as considered and not adopted now. Verified by file inspection.
- [x] AC35: D4 introduces no code change: no validator, schema, library, or hook file is modified attributable to D4 (Markdown-only diff for `parallel-plan/SKILL.md` fan-out and `parallel-planner.md` plus mirrors), and the planner-surface contract test suite passes unmodified. Verified by `git diff` inspection and pytest.

### Cross-cutting

- [x] AC36: The eight touched `.claude` files are re-synced byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/` (`skills/parallel-orchestrate/SKILL.md`, `skills/parallel-plan/SKILL.md`, `skills/parallel-add/SKILL.md`, `skills/parallel-remove/SKILL.md`, `agents/parallel-orchestrator.md`, `agents/parallel-planner.md`, `rules/parallel-orchestration.md`, `lib/bash/parallel-manifest-validate.sh`, plus `lib/bash/parallel-items-validate.sh` if edited), and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes. Verified by hash comparison per pair and by the contract test.
- [x] AC37: `docs/features/templates/parallel/parallel-status.md` remains unmirrored (no `templates/parallel` path is created under extensions resources), and `pack-manifests/core.json` is unmodified. Verified by `git diff --name-only` and directory inspection.
- [ ] AC38: **Backward compatibility:** every pre-existing manifest and checkpoint fixture validates byte-identically — the same error list, element for element — before and after this change, demonstrated by a corpus test that runs the pre-existing fixture set through the updated validators and compares against recorded expectations (only fixtures deliberately migrated under AC22 differ, and each such difference is itemized). Verified by pytest and the bats parity suite.
- [x] AC39: The three known TypeScript parity divergence classes are neither entered nor "fixed": `parallel-state-shared.ts:112-132` (`pythonRepr` quote selection) and `parallel-state-structures.ts:228` (boolean `===`) are unmodified, and no new test or fixture exercises integral-float, quote-divergent, or boolean-equality values across runtimes. Verified by `git diff` inspection of the two files and review of new fixtures.
- [x] AC40: No JSON Schema file is authored or imported: `git diff --name-only` adds no `*.schema.json` (or equivalent schema file), and no touched Python/TypeScript module imports a JSON-Schema library; nothing references the disqualified `drmoisan.github.io/mix-calculator/` artifact. Verified by command and grep.
- [ ] AC41: The full seven-stage toolchain (format, lint, type check, architecture, unit, contract, integration) completes in a single clean pass, and coverage on changed/new modules meets the uniform thresholds (line >= 85%; branch >= 75% for measured languages; PowerShell/bash exempt from the branch threshold only). Verified by toolchain run output and coverage report.

## Risks & Mitigations

- **Risk:** a missed global-barrier restatement survives on a runtime surface. Mitigation: AC4's grep gate plus the D1.1 inventory's already-correct list.
- **Risk:** the F6 offset generalization changes behavior in a reachable pre-D1 state. Mitigation: AC13's single-frontier regression proves identity when all pinned items occupy `current_cohort` — every state reachable today.
- **Risk:** error-string drift between runtimes after the bound change. Mitigation: AC16's parity suites over the shared fixture corpus.
- **Risk:** M8 shape drift between Python and bash. Mitigation: AC27's shared-fixture parity corpus; block sequences keep the field inside the bash YAML subset.
- **Risk:** the lane-assertion diagnostic is misread as a scheduling input. Mitigation: assertion-only language in M8 and the skill (AC24, AC29) plus the no-import check (AC30).
- Rollback: all changes are additive or range-widening; reverting the delivery commit restores prior behavior with no data migration.

## Rollout & Follow-up

- Release: single PR against `main`; mirror re-sync and test-pin updates land in the same commit as their sources (AC10, AC36).
- Post-fix follow-ups (explicitly deferred, not in scope): `max_preparation_concurrency` manifest key; bash/destination-runtime port of the lane-assertion diagnostic.
- Links: issue #479 (https://github.com/drmoisan/drm-copilot/issues/479); research artifacts under `docs/features/active/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/research/`.
