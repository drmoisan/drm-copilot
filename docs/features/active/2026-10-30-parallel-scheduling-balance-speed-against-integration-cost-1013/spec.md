# parallel-scheduling-balance-speed-against-integration-cost — Spec

- **Issue:** #1013
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-31
- **Status:** Draft
- **Version:** 0.5 (staleness revision 2026-10-31: Complete File List entry 76 added for the post-#1006 overlay corpus file that restates the committed `weights` map; 0.4 preflight 2026-10-30: the "unchanged" wording of AC-04, AC-08, AC-26, D-6, D-7, and `## Test Strategy` aligned with D-7; 0.3 owner decision 2026-10-30: `conflict_tolerance.weights.contract`, see D-7)
- **Work Mode:** full-feature (acceptance criteria are tracked in this file and in `user-story.md`)
- **Branch:** `feature/parallel-scheduling-integration-cost-1013`
- **Research:** `research/research.2026-10-30T13-28.md` in this feature folder (authoritative for design decisions, symbols, and the complete file list)
- **Dependency:** issue #1006 (must merge first; see Dependency on #1006)
- **Execution environment:** `.claude/skills/execution-environment/SKILL.md` (tool routes, command-text restrictions, batch budget, CI shape, contract tests, evidence rules, coverage and file-size gates, and test-isolation checks are referenced there and not restated here)

## Overview

The parallel run should balance the speed gained by running items concurrently against the time spent integrating them at the end. Issue #722 introduced cost-benefit scheduling, but it is coarse:

- A destination with no `conflict_tolerance` gets strict scheduling (equivalent to `tolerance_percent` 0), so every detected conflict serializes.
- Each pair is judged alone, so one item with many tolerated overlaps never has its total integration cost counted.
- Cost uses static weights, and nothing measures real integration time.
- Hard classes (`shared_surface_overlap`, `contract_dependency`) serialize at every tolerance, even when the two items would be cheaper to deliver as one.
- Nothing combines two items whose overlap is heavy enough that one worktree, one PR, and one CI cycle would cost less than any merge.

This feature adds a default-tolerance regression pin, an aggregate per-item cost cap applied inside the existing scheduling entry point, telemetry-only recording of observed merge-conflict resolution time, planning-time issue combination governed by a new `conflict_tolerance.combination_threshold_percent` member, and a new required cost weight `conflict_tolerance.weights.contract` that is summed once per shared contract identifier, so a pair that shares only a contract has a nonzero cost and can qualify for combination.

## Context

Current state (research sections 1 to 4, verified against the pre-#1006 base):

- Both committed truth tables (`config/blast-radius.json` and the published `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`) carry the same `conflict_tolerance`, including `tolerance_percent: 100`. `conflict_tolerance` is a Class 1 (byte-equal) key.
- Python reads the key with `config_conflict_tolerance` in `scripts/dev_tools/_blast_radius_scheduling.py`; PowerShell reads it with `Get-ConfigConflictTolerance` in `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`. An absent key reads as strict (`STRICT_CONFLICT_TOLERANCE` / the strict hashtable).
- TypeScript has no reader and no scheduling code. The push-down derivers carry `conflict_tolerance` verbatim, and the overlay composers merge it recursively with the overlay winning nested scalars. Bash has no tolerance or scheduling code.
- Scheduling is pairwise: `decide_pair` / `Get-BlastRadiusPairDecision` produce an edge when the pair is hard, when `tolerance_percent` is 0, or when `cost*100 > benefit*tolerance_percent`. `schedule_conflict_edges` / `Get-BlastRadiusConflictEdge` return edges and tolerated overlaps sorted by `(a, b)`.
- Cohort computation (`compute_cohorts`, `compute-cohorts.sh`) colors the edges it is given and never evaluates contention.
- The orchestrator checkpoint carries `tolerated_overlaps` as tolerated-not-validated data. The durable run record `docs/features/parallel/<slug>/parallel-status.md` is generated from the template `docs/features/templates/parallel/parallel-status.md`, which has no tolerated-overlap section.

Finding on Proposed Behavior item 1: the published table already ships `tolerance_percent: 100`, and both push-down derivers carry it. A destination with no overlay already receives cost-benefit scheduling after an extension rebuild and reinstall. This feature therefore adds a regression pin, not a value change (research section 1.2).

## Scope and Non-Goals

In scope:

- Default tolerance: a two-runtime in-memory push-down pin that a destination with no overlay receives `tolerance_percent` 100 and `combination_threshold_percent` 400.
- Aggregate cap: a deterministic post-pass inside `schedule_conflict_edges` and `Get-BlastRadiusConflictEdge`, with logic in new leaf modules.
- Telemetry: a tolerated-not-validated `observed_resolution` object on orchestrator-checkpoint `tolerated_overlaps[]` entries and a durable `## Tolerated Overlaps` projection in the `parallel-status.md` template.
- Benefit currency: unchanged (band durations).
- Issue combination: a new pure library in Python (authority) and PowerShell (runtime port, re-exported by the facade), the `parallel-plan` / `parallel-planner` procedure, `parallel-orchestrate` kickoff and remediation text, `parallel-add` report-only text, and `pr-author` / `orchestrate` wording for multi-issue autoclose.
- `combination_threshold_percent`: an optional `conflict_tolerance` member validated in Python and PowerShell, committed explicitly in both truth tables.
- Contract weight (D-7): a required `conflict_tolerance.weights.contract` name validated exactly like `same_file`, `possible_overlap`, `append_only`, and `module` in Python and PowerShell; a contract term added to `pair_cost` and `Get-BlastRadiusPairCost`; the committed value in both truth tables; every existing fixture and test config that carries `conflict_tolerance.weights` updated to carry the new name; the rule text (Integration-cost scheduling: Configuration and Cost sections) in `.claude/rules/parallel-orchestration.md` and its bundle copy.
- Correction of the stale "three token shapes" sentence in `.claude/skills/parallel-plan/SKILL.md` to the post-#1006 count read from the merged rule (research decision D14).
- Bundle copies, the `core.json` pack manifest, and the tests and fixtures in the Complete File List.

Non-goals and explicit boundaries:

- **Edge-reason enum: no change.** The `conflict_edges[].reason` enum keeps its current members. `same_file` remains a cost weight and is never a reason; `test_out_of_enum_reason_is_still_rejected` continues to pin its rejection.
- **Parallel checkpoint schema: no validated schema change.** Three tolerated-not-validated fields are added and declared in the rule text:
  - `tolerated_overlaps[].observed_resolution` (orchestrator checkpoint);
  - `items[].combined_issue_nums` (manifest, planner checkpoint, orchestrator checkpoint);
  - a top-level `combinations` list (planner checkpoint).
- No validator module is edited in Python (`validate_parallel_orchestrator_state.py`, `validate_parallel_planner_state.py`, `parallel_manifest_contract.py`), TypeScript (`extensions/drm-copilot/src/lib/validate/parallel-*`), or bash (`parallel-manifest-validate.sh`, `parallel-items-validate.sh`, `validate-parallel-manifest.sh`).
- No change to `decide_pair`, `Get-BlastRadiusPairDecision`, `conflicts`, `HARD_REASON_KINDS`, or `pair_benefit`. `pair_cost` and `Get-BlastRadiusPairCost` change only by the D-7 contract term; their path-pair and module terms are unchanged. `contract_dependency` remains a hard reason kind.
- No change to drift detection (`scripts/dev_tools/_parallel_drift_scheduling.py`); it stays pairwise.
- No automatic tuning: nothing reads `observed_resolution`, and no existing weight value changes (the new `contract` weight is added once, by the owner decision, not by telemetry).
- No change to `.claude/hooks/enforce-model-routing-receipt.ps1`; it already accepts several issue numbers.
- No TypeScript or bash port of the reader, the cap, or the combination library.
- No umbrella GitHub issue; combined issues stay separate on GitHub.
- No size cap on a combined item; combination is not repeated on combined radii.
- No edit to `scripts/dev_tools/compute_blast_radius.py`, to the `.agents/` or `.github/` copies of `pr-author` and `orchestrate`, to the six execution-environment brief copies, to `.claude/agents/epic-orchestrator.md`, to `.claude/skills/epic-orchestrate/SKILL.md`, or to `quality-tiers.yml`.
- No live destination push-down and no live parallel run; destination and procedure behavior are proven by in-memory tests, library fixtures, validator acceptance tests, and contract tests.

## Dependency on #1006

Issue #1006 changes the shared-surface and `contract_dependency` inputs this feature builds on: it moves `quality-tiers.yml` from `shared_surfaces` to the end of `conflict_tolerance.append_only_paths` in both truth tables, adds `is_generic_contract_token` / `Test-GenericContractToken`, and adds the overlay directive `shared_surfaces_demote` (`SHARED_SURFACES_DEMOTE_KEY`) with `expected_error` support in both overlay corpus loaders. This design is stated against #1006's post-merge state and changes none of #1006's symbols.

Observable that proves #1006 merged (research section 0.3). Before any implementation task, all of the following hold on `origin/main`, and then `git merge-base --is-ancestor origin/main HEAD` exits 0 (rebase first when it does not):

1. `git grep -n "def is_generic_contract_token" origin/main -- scripts/dev_tools/_blast_radius_token_shapes.py` prints one line.
2. `git grep -n "SHARED_SURFACES_DEMOTE_KEY" origin/main -- scripts/dev_tools/push_down_claude_blast_radius_overlay.py` prints at least one line.
3. `git show origin/main:config/blast-radius.json` lists `quality-tiers.yml` in `conflict_tolerance.append_only_paths` and not in `shared_surfaces`.

Shared files: files written by both items are marked `[#1006]` in the Complete File List. The edits are sequential on top of #1006's result and do not touch the same sections: #1006 edits the `append_only_paths` list, `Get-NormalizedDeclaredRadius`, and the read-by-mandate and overlay paragraphs of the rule; this feature appends one `conflict_tolerance` member, adds facade import lines and one export name, and edits the integration-cost section of the rule. Line counts in the file-size table of research section 7 are re-counted after the rebase.

## Design

### D-1 Default tolerance

- No value change. The published truth table keeps `tolerance_percent: 100`.
- A new pytest module `tests/scripts/dev_tools/test_push_down_claude_blast_radius_default_tolerance.py` and a new Jest suite `extensions/drm-copilot/test/lib/push-down/blast-radius-default-tolerance.test.ts` perform an in-memory push with no overlay and assert that the destination `config/blast-radius.json` has `conflict_tolerance.tolerance_percent` 100 and `conflict_tolerance.combination_threshold_percent` 400.
- Fail-before evidence is structurally impossible for this behavior, because it holds at the branch base. A schema-valid `fail-before-exception.<timestamp>.md` dossier with alternative proof is recorded under `evidence/regression-testing/` in this feature folder.

### D-2 Aggregate cost cap

Placement (research decision D1): a post-pass inside the single scheduling entry point in each runtime, so planners and `parallel-add` cannot skip it.

- Python: new `scripts/dev_tools/_blast_radius_aggregate.py` exports `select_capped_pairs(tolerated_overlaps, bands, tolerance)`. Inputs are the tolerated overlaps (any object exposing `a`, `b`, `cost`, `benefit`, typed as a structural protocol; `ConflictTolerance` is imported only under `TYPE_CHECKING`), a key-to-band map, and the tolerance. Output is the ordered tuple of `(a, b)` pairs to promote. `_blast_radius_scheduling.py` imports it in one direction only. `schedule_conflict_edges` keeps the result of its existing `config_conflict_tolerance(config)` call, calls `select_capped_pairs`, moves each promoted overlap to `edges` as `ConflictEdge(a, b, reasons[0], False, cost, benefit)`, and re-sorts both lists by `(a, b)`.
- PowerShell: new `.claude/lib/blast-radius/BlastRadiusAggregate.psm1` exports `Get-AggregateCappedPair`, imported by `BlastRadiusScheduling.psm1` with `Import-Module ... -Force -ErrorAction Stop`. `Get-BlastRadiusConflictEdge` applies the same post-pass.

Cap rule:

- For item `i`, `total(i)` is the sum of `cost` over the remaining tolerated overlaps that include `i`.
- A missing band reads as `default_band`.
- Item `i` is over its cap when `total(i) * 100 > band_duration(i) * tolerance_percent`, evaluated in integers only.

Cheapest-to-serialize pair (research decision D2): among the over-cap item's remaining tolerated overlaps, select the minimum by the key `(benefit ascending, cost descending, a ascending, b ascending)`. The smallest benefit gives up the least parallelism, the largest cost removes the most integration cost, and the pair keys make the order total.

Iteration: repeatedly take the smallest-key item that is over its cap, promote its cheapest pair, and recompute totals; stop when no item is over its cap. Each round removes one tolerated overlap, so the loop terminates, and overlaps are visited in sorted order, so the result is independent of input order.

Strict identity at `tolerance_percent` 0: `decide_pair` makes every conflict an edge, so the tolerated list is empty and the post-pass is a no-op. An absent key behaves the same through `STRICT_CONFLICT_TOLERANCE`.

Set-level monotonicity (research decision D3): with the cap, raising `tolerance_percent` can add a promoted edge. The rule statement "Raising tolerance_percent never adds an edge" is narrowed to the pairwise decision. The following set-level properties are pinned instead:

- the capped edges are a superset of the pairwise edges and a subset of the detected conflicts;
- the output at tolerance 0 is identical to the uncapped output;
- after the pass, every item is within its cap;
- the output is invariant to input order;
- running the pass again changes nothing.

A single tolerated overlap never exceeds the cap (`cost*100 <= benefit*tolerance_percent` and `benefit <= band_i`), so the cap binds only for an item with two or more tolerated overlaps. Existing pinned fixture outputs are unchanged (research section 2.3).

Drift detection stays pairwise (research decision D15). A cap-promoted pair is a recorded edge, so drift never reports it as newly conflicting.

### D-3 Telemetry (recording only, no automatic tuning)

Checkpoint field (research decision D12): an optional object `observed_resolution` on each orchestrator-checkpoint `tolerated_overlaps[]` entry, tolerated and not validated:

```
{ later_item: int, conflicted: bool, conflict_detected_at: str|null, resolved_at: str|null, resolution_minutes: int, recorded_at: str }
```

Writer: the parallel orchestrator, inside the existing procedure in `.claude/skills/parallel-orchestrate/SKILL.md`:

- `## Per-Item Merge-Conflict Handling`: when the item whose merge conflicted is the later-merging item of a tolerated pair whose peer is already `merged` or `worktree_removed`, set `conflicted: true` and `conflict_detected_at` if they are not already set.
- `## Per-Item Merge to Main (Merge-on-Green)`: at the later item's confirmed merge, set `resolved_at` to the first `ci_green` confirmation that follows the detection, `resolution_minutes` to the whole minutes between detection and `resolved_at`, and `recorded_at`. When no conflict occurred, set `conflicted: false` and `resolution_minutes: 0`.

Attribution is non-exclusive: one conflict episode is attributed to every tolerated peer that merged before it. This imprecision is documented in the rule text, not resolved.

Durable copy: the template `docs/features/templates/parallel/parallel-status.md` gains a `## Tolerated Overlaps` section with columns `a | b | reasons | cost | benefit | later_item | conflicted | resolution_minutes`. The `parallel-orchestrate` skill prescribes it in `## Documentation Maintenance Boundaries` and adds "every write of an `observed_resolution`" to the regeneration boundaries. The existing `test_seam_status_template_realises_projections_prescribed_by_skill` binds the prescribed heading to the template.

No automatic tuning: nothing reads `observed_resolution`. A contract test asserts that no file under `scripts/`, `.claude/lib/`, or the bundled `.claude/lib/` contains the token, and that `config_conflict_tolerance` and `Get-ConfigConflictTolerance` read only the config mapping.

### D-4 Benefit currency

Unchanged. Benefit remains `pair_benefit`, the minimum of the two band durations (a cohort-step estimate).

### D-5 Issue combination

Library:

- Python: new `scripts/dev_tools/_blast_radius_combination.py` exports `find_combinations(items, config) -> CombinationResult` and `has_same_file_overlap(radius_a, radius_b, config, tolerance)`.
- PowerShell: new `.claude/lib/blast-radius/BlastRadiusCombination.psm1` exports `Get-BlastRadiusCombination -Item -Config -Relation`, returning `@{ pairs; combinations }`. The facade `BlastRadius.psm1` re-exports it.
- Both functions are pure and total over valid input: no I/O and no input mutation.

Rules:

1. Disabled when `conflict_tolerance` is absent or `tolerance_percent` is 0 (research decision D7), so the strict identity extends to the item set.
2. For each conflicting pair, `decide_pair` / `Get-BlastRadiusPairDecision` supplies `reasons`, `cost`, and `benefit`. Edges and tolerated pairs are both evaluated.
3. Candidate: `contract_dependency` is in the full `reasons`, or `has_same_file_overlap` is true. `has_same_file_overlap` (research decision D4) means at least one overlapping entry pair, after the mergeable exclusion, has two equal concrete entries and neither matches `append_only_paths`; this mirrors the precedence in `_path_pair_weight`, so an append-only registry is never a same-file candidate. The edge `reason` field is not used, because `contract_dependency` is not first in canonical kind order.
4. Qualifies when `cost * 100 >= benefit * combination_threshold_percent`, where benefit is the shorter item's band duration (the existing pair benefit).
5. Components (research decision D6): qualifying pairs are grouped into connected components with union-find. Each component of two or more items becomes one combination with `members` ascending, `primary = min(members)`, `pairs` sorted by `(a, b)`, and `estimated_savings` equal to the sum of the qualifying pair costs in cost units (research decision D11). No size cap. Combination runs once, before cohort seeding, and is not repeated on combined radii.

Contract-only pairs (owner decision 2026-10-30, superseding research decision D5): a pair that shares only contracts has cost `weights.contract` times the number of shared contract identifiers (D-7), so it is a candidate under rule 3 and qualifies under rule 4 when that cost meets the threshold. At the committed values (`contract` 8, `combination_threshold_percent` 400, `C1` 1, `C2` 2) a pair sharing one contract qualifies when the shorter item is C1 or C2 (`8*100 >= 2*400`). A contract-only pair that does not qualify still serializes as a hard `contract_dependency` edge.

Planner procedure (research decisions D9 and D10): a new `## Issue Combination` section in `.claude/skills/parallel-plan/SKILL.md`, after `## Complexity Assessment` and before `## Cohort Seeding`:

1. Once every item is prepared, its radius declared, and its band assigned, call `Get-BlastRadiusCombination`. Combination proceeds without operator approval.
2. If applying all combinations would leave fewer than two items (ready-gate invariant P6), apply none and report each qualifying pair as not combined, with that reason.
3. For each combination, issue one follow-up preparation-mode delegation on the primary item's pushed branch (the existing V1/V2 re-plan posture). The delegation carries the unchanged preparation kickoff line and then a combination line `Combined issues: #A #B` naming the other members by issue number and by branch name only.
4. The child imports each other member's committed feature folder by path from that member's pushed branch ref (a path checkout, not a branch merge, so "There is no fan-in merge step" still holds), authors one atomic plan in the primary feature folder covering every member's spec, re-runs preflight, commits, and pushes.
5. The planner re-derives the combined item's declared radius from the combined plan and runs a fresh `## Complexity Assessment` for it.
6. The planner removes the non-primary members from `items[]`, records `combined_issue_nums` on the primary item, and records the combination in the `combinations` list.
7. Only then does it run the capped scheduling entry point over the post-combination item set.

Non-primary members' preparation branches remain in place and are reported (the same residual as risk 2 in `## Artifact Home`).

Ordering: detection, pair decisions, combination (planning only, once), re-plan and fresh assessment, capped scheduling, cohort seeding.

Execution and one PR closing every member:

- `.claude/skills/parallel-orchestrate/SKILL.md` `## Parallel-Mode Kickoff Parameter`: for a combined item, element 3 is followed by the line `Combined issues: #A #B`. The kickoff keeps its existing element count, so `test_parallel_orchestrate_kickoff_keeps_five_elements` passes unchanged.
- The child carries every member on its pr-author line: `Author-asserted autoclose issues: #A #B`. Both issues stay separate on GitHub; no umbrella issue is created.
- `.claude/skills/pr-author/SKILL.md` (Issue/PR Reference Rules, source 3) is reworded to "each issue named on the line `Author-asserted autoclose issues: #NNN [#NNN ...]`". The existing PC-03 fragments remain satisfied.
- `.claude/skills/orchestrate/SKILL.md` `## PR Authoring (pr-author Handoff)` step 3 also lists every issue named on a `Combined issues:` line of a parallel kickoff, and keeps the PC-01 literal `Author-asserted autoclose issues: #<issue-num>`. `## Issue Number Consistency` gains one sentence: numbers on a `Combined issues:` line are permitted cross-references, not discrepancies.
- The author-asserted hook is unchanged (research decision D13). `Get-ModelRoutingAuthorAssertedReason` already matches a multi-number line; two Pester rows pin that a two-number line is allowed with the checkpoint number in either position.

Prompt-shape constraints (research risk R2): the `Combined issues:` and `Author-asserted autoclose issues:` lines do not match `HOOK_ISSUE_NUMBER_PATTERN`, and a combination line never carries a `docs/features/active/<basename>` path, because parallel-mode target resolution scans for that shape.

Remediation as one unit: `## Per-Item Merge-Conflict Handling` states that a combined item remediates as one unit (one child, one `remediation_loop`, one PR) and never splits back into separate PRs; merge, block, and removal apply to it as a whole. A combined item that fails review or CI is remediated within that one child and PR. Combined PR review size and the shared remediation budget are an accepted trade documented in the rule text (research risk R4); the threshold is destination-tunable.

`parallel-add` (report only): in `.claude/skills/parallel-add/SKILL.md` step 3, after edges are computed, call `Get-BlastRadiusCombination` over the candidate plus the unstarted items, and report each qualifying pair that involves the candidate as "qualifies for combination; not combined (combination applies at planning time only)". No checkpoint field and no `mutations[]` change is made. Because the cap is inside `Get-BlastRadiusConflictEdge`, `parallel-add` edges are also capped.

Plan report: the `parallel-plan` `## Completion Report` and the `parallel-planner` agent's `## Completion Requirements` item 7 list each combination with members, primary, qualifying pairs with cost and benefit, threshold, and `estimated_savings`. Not-combined qualifying pairs are listed with the reason.

Agent text: `.claude/agents/parallel-planner.md` and `.claude/agents/parallel-orchestrator.md` carry the combination, report, telemetry, and one-unit remediation duties consistent with the skills they execute.

### D-6 `combination_threshold_percent` validation and cross-runtime parity

Rules (research decision D8):

- An optional member of `conflict_tolerance`. The reader accepts the existing required member names plus this optional name; any other name is still rejected (`_require_names` / `Assert-ExactMemberName`).
- When present, it must be a non-boolean integer of at least 0, read through `_require_int` / `Get-RequiredInteger` with the same error-label style, `config["conflict_tolerance"]["combination_threshold_percent"]`.
- When absent inside a present key, it defaults to `COMBINATION_THRESHOLD_DEFAULT = 400`, defined in `_blast_radius_scheduling.py`. The PowerShell constant is pinned to the Python source by a Pester parity row.
- `ConflictTolerance` gains a field with default 400, so `STRICT_CONFLICT_TOLERANCE` and the existing constructor call in `test_absent_key_reads_as_strict` still compare equal on that field; this member adds no edit to that test (its only edit is the `"contract": 1` entry its `weights` literal gains under D-7). The PowerShell hashtable gains a `combination_threshold_percent` key; the strict-read assertions in `'reads an absent key as strict'` are unchanged.
- Both committed truth tables carry `"combination_threshold_percent": 400` explicitly as the last member of `conflict_tolerance`, byte-equal across the two copies (Class 1). A destination overrides it through `config/blast-radius.local.json` (issue #508 recursive merge; the overlay wins).
- Optional rather than required keeps every existing fixture config valid without edits.

Cross-runtime parity:

- Python and PowerShell: identical accept and reject cases (negative, float, string, boolean, absent defaulting to 400, unknown sibling name rejected), asserted in new test files.
- TypeScript: not ported (no reader). Parity is proven by the overlay corpus fixture `tests/fixtures/blast_radius_overlay/conflict-tolerance-combination-threshold.json`, which both composers (TypeScript and Python) compose to the same expected text, and by the `SOURCE_BLAST_RADIUS` carriage pin.
- Bash: not applicable (no tolerance code).

The top-level key partition enumerates top-level keys only, so the nested member does not affect `DECLARED_TOP_LEVEL_KEYS` or its tests.

### D-7 Contract weight (owner decision 2026-10-30)

Configuration:

- `WEIGHT_NAMES` in `_blast_radius_scheduling.py` and `$script:WeightName` in `BlastRadiusScheduling.psm1` gain `contract` as a fifth name, appended after `module`.
- Validation is identical to the other four weights: the name is required and exact (`_read_int_map` / `_require_names`, `Get-RequiredIntegerMap` / `Assert-ExactMemberName`), the value is a non-boolean integer of at least 1 (`_require_int(..., minimum=1)` / `Get-RequiredInteger`), and every failure is fail-fast with an error naming `config["conflict_tolerance"]["weights"]["contract"]` (or the `weights` label for a missing or unknown name). Booleans are rejected. Python and PowerShell accept and reject the same cases.
- `STRICT_CONFLICT_TOLERANCE` and the PowerShell strict hashtable carry `contract: 1` through their existing all-names construction. `test_absent_key_reads_as_strict` passes with only its `weights` literal gaining `"contract": 1`, because that literal names the four earlier weights and must equal the five-name `STRICT_CONFLICT_TOLERANCE`; the strict semantics it asserts are unchanged. `'reads an absent key as strict'` passes unchanged, because it indexes the four earlier names only.
- Both committed truth tables carry `"contract": 8` as the last member of `weights`, with `conflict_tolerance` byte-equal across both copies (Class 1). The value 8 equals `same_file`, so one shared contract is weighted like one same-file overlap. This value is an orchestrator assumption recorded for owner review; the owner decision fixes the name, the minimum, and the summation, not the committed value.
- TypeScript: the push-down derivers carry `conflict_tolerance` verbatim and the overlay composers merge it recursively; there is no TypeScript reader or validator of `conflict_tolerance` (`extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` carries it as an opaque value). Parity is proven by `SOURCE_BLAST_RADIUS` in `config-carriage.test-helpers.ts`, by every TypeScript test that literally restates the committed `weights` map (for example `blast-radius-derive-tolerance-keys.test.ts`), and by an overlay corpus fixture `tests/fixtures/blast_radius_overlay/conflict-tolerance-contract-weight.json` that both composers compose to the same expected text, proving a destination can override the weight.

Cost:

- `pair_cost` and `Get-BlastRadiusPairCost` add `weights.contract` times the number of shared contract identifiers, where the shared contract identifiers are exactly the set the relation intersects to report `contract_dependency` (the intersection of the two radii's `contracts`, after any filtering #1006 applies to that relation). Each identifier counts once, whatever the number of times it appears in either radius.
- The path-pair and module terms are unchanged, so the cost of any pair that shares no contract is unchanged.
- `contract_dependency` stays in `HARD_REASON_KINDS` and `decide_pair` is unchanged: a pair that shares a contract is an edge at every tolerance. The contract term therefore changes the recorded `cost` of such edges and their combination eligibility, and it does not change any edge set. The aggregate cap reads tolerated overlaps only; because a pair sharing a contract is never tolerated, no tolerated overlap carries a contract term, and every cap output over pairs without shared contracts is unchanged.

Invariant (stated in the rule text and pinned by tests): at `tolerance_percent` 0 the edge set is identical to strict scheduling (every detected conflict is an edge) for any `contract` weight; and at any tolerance the edge set produced with the contract term equals the edge set produced without it. Only the `cost` field of edges whose pair shares a contract differs.

Existing tests and fixtures that pin a `cost` value for a pair sharing a contract, or that construct a `conflict_tolerance.weights` map, are updated in the task that introduces the term; each is named with its disposition in the plan.

Rule text: `.claude/rules/parallel-orchestration.md` and its bundle copy, Integration-cost scheduling `Configuration` (the `weights` member list, the `contract` minimum, and the committed value) and `Cost` (the contract term, once per shared contract identifier; `contract_dependency` remains hard; the tolerance-0 identity), byte-identical across both copies.

## Interfaces and Error Texts

| Symbol | Runtime | Module | Signature or shape |
|---|---|---|---|
| `select_capped_pairs` | Python | `scripts/dev_tools/_blast_radius_aggregate.py` (new) | `(tolerated_overlaps, bands, tolerance) -> tuple[tuple[int, int], ...]` |
| `Get-AggregateCappedPair` | PowerShell | `.claude/lib/blast-radius/BlastRadiusAggregate.psm1` (new) | ordered `(a, b)` pairs to promote |
| `find_combinations` | Python | `scripts/dev_tools/_blast_radius_combination.py` (new) | `(items, config) -> CombinationResult` |
| `has_same_file_overlap` | Python | `scripts/dev_tools/_blast_radius_combination.py` (new) | `(radius_a, radius_b, config, tolerance) -> bool` |
| `Get-BlastRadiusCombination` | PowerShell | `.claude/lib/blast-radius/BlastRadiusCombination.psm1` (new), re-exported by `BlastRadius.psm1` | `-Item -Config -Relation`, returns `@{ pairs; combinations }` |
| `COMBINATION_THRESHOLD_DEFAULT` | Python | `scripts/dev_tools/_blast_radius_scheduling.py` | `400` |
| `ConflictTolerance.combination_threshold_percent` | Python | `scripts/dev_tools/_blast_radius_scheduling.py` | `int`, default `400` |
| `combination_threshold_percent` hashtable key | PowerShell | `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` | `int`, default `400` |
| `WEIGHT_NAMES` | Python | `scripts/dev_tools/_blast_radius_scheduling.py` | gains `"contract"` after `"module"` |
| `$script:WeightName` | PowerShell | `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` | gains `'contract'` after `'module'` |
| `pair_cost` | Python | `scripts/dev_tools/_blast_radius_scheduling.py` | unchanged signature; adds `weights["contract"] * len(shared contract identifiers)` |
| `Get-BlastRadiusPairCost` | PowerShell | `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` | unchanged parameters; adds the same contract term |

A combination record carries `members` (ascending issue numbers), `primary` (minimum member), `pairs` (sorted by `(a, b)`, each with cost and benefit), and `estimated_savings` (sum of qualifying pair costs, cost units).

Prompt and record lines:

- Kickoff combination line: `Combined issues: #A #B`
- pr-author line: `Author-asserted autoclose issues: #A #B`
- `parallel-add` report text: `qualifies for combination; not combined (combination applies at planning time only)`
- P6 report reason: a qualifying pair is reported as not combined because applying the combinations would leave fewer than two items.

Error texts: a malformed `combination_threshold_percent` raises in the reader and names the key with the existing label style `config["conflict_tolerance"]["combination_threshold_percent"]` — `TypeError` (non-integer or boolean) or `ValueError` (below 0) in Python, and a terminating error carrying the same label in PowerShell. An unknown sibling member continues to raise the existing unknown-name error from `_require_names` / `Assert-ExactMemberName`. A missing `weights.contract` name raises the existing missing-name error naming `config["conflict_tolerance"]["weights"]`; a non-integer or boolean `contract` value raises `TypeError`, and a value below 1 raises `ValueError`, each naming `config["conflict_tolerance"]["weights"]["contract"]`; PowerShell raises a terminating error carrying the same label. The cap and combination functions are total over valid input and do not raise.

## Complete File List

Every file this feature writes: entries 1 to 54 as recommended by the research, and entries 55 to 76 added by the D-7 contract weight (entry 76 after the #1006 rebase). (new) marks a new file; `[#1006]` marks a file also written by #1006. Feature-folder documents and evidence files are excluded.

Production, configuration, and documentation:

1. `scripts/dev_tools/_blast_radius_scheduling.py`
2. `scripts/dev_tools/_blast_radius_aggregate.py` (new)
3. `scripts/dev_tools/_blast_radius_combination.py` (new)
4. `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`
5. `.claude/lib/blast-radius/BlastRadiusAggregate.psm1` (new)
6. `.claude/lib/blast-radius/BlastRadiusCombination.psm1` (new)
7. `.claude/lib/blast-radius/BlastRadius.psm1` [#1006]
8. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1`
9. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusAggregate.psm1` (new)
10. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusCombination.psm1` (new)
11. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1` [#1006]
12. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
13. `config/blast-radius.json` [#1006]
14. `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` [#1006]
15. `.claude/rules/parallel-orchestration.md` [#1006]
16. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` [#1006]
17. `.claude/skills/parallel-plan/SKILL.md`
18. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`
19. `.claude/skills/parallel-add/SKILL.md`
20. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`
21. `.claude/skills/parallel-orchestrate/SKILL.md`
22. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`
23. `.claude/agents/parallel-planner.md`
24. `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md`
25. `.claude/agents/parallel-orchestrator.md`
26. `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md`
27. `.claude/skills/orchestrate/SKILL.md`
28. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
29. `.claude/skills/pr-author/SKILL.md`
30. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-author/SKILL.md`
31. `docs/features/templates/parallel/parallel-status.md`

Tests and fixtures:

32. `tests/scripts/dev_tools/test_blast_radius_aggregate.py` (new)
33. `tests/scripts/dev_tools/test_blast_radius_aggregate_properties.py` (new)
34. `tests/scripts/dev_tools/test_blast_radius_combination.py` (new)
35. `tests/scripts/dev_tools/test_blast_radius_combination_threshold.py` (new)
36. `tests/scripts/dev_tools/test_push_down_claude_blast_radius_default_tolerance.py` (new)
37. `tests/scripts/dev_tools/test_parallel_issue_combination_contracts.py` (new)
38. `tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py`
39. `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py` [#1006]
40. `tests/scripts/claude-lib/blast-radius/BlastRadiusAggregate.Tests.ps1` (new)
41. `tests/scripts/claude-lib/blast-radius/BlastRadiusCombination.Tests.ps1` (new)
42. `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1`
43. `tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1`
44. `extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts`
45. `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` [#1006]
46. `extensions/drm-copilot/test/lib/push-down/blast-radius-default-tolerance.test.ts` (new)
47. `tests/fixtures/blast_radius/aggregate/aggregate-cap-promotes-cheapest-pair.json` (new)
48. `tests/fixtures/blast_radius/aggregate/aggregate-cap-tie-break.json` (new)
49. `tests/fixtures/blast_radius/aggregate/aggregate-cap-cascade.json` (new)
50. `tests/fixtures/blast_radius/combination/combination-threshold-boundary.json` (new)
51. `tests/fixtures/blast_radius/combination/combination-candidate-classes.json` (new)
52. `tests/fixtures/blast_radius/combination/combination-component-chain.json` (new)
53. `tests/fixtures/blast_radius_overlay/conflict-tolerance-combination-threshold.json` (new)
54. `tests/fixtures/parallel_manifest_bash/manifest_valid_combined_item.json` (new)

Added by the D-7 contract weight (revision 0.3). Each file below constructs or restates a `conflict_tolerance.weights` map or pins a pair `cost`, as found by a repository search for `possible_overlap` on the pre-#1006 base; the plan re-derives this set after the #1006 rebase, names each file with its disposition (updated, with the reason, or unchanged because unaffected), and adds any further match.

55. `tests/fixtures/blast_radius_overlay/conflict-tolerance-contract-weight.json` (new)
56. `tests/scripts/dev_tools/test_blast_radius_contract_weight.py` (new)
57. `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.ContractWeight.Tests.ps1` (new)
58. `tests/fixtures/blast_radius/combination/combination-contract-only.json` (new)
59. `tests/fixtures/blast_radius/write-intent/write-intent-shared-surface-read-citation.json`
60. `tests/fixtures/blast_radius/scheduling/scheduling-soft-pair-tolerated.json`
61. `tests/fixtures/blast_radius/scheduling/scheduling-452-shared-surface-hard.json`
62. `tests/fixtures/blast_radius/scheduling/scheduling-452-negative-controls.json`
63. `tests/fixtures/blast_radius/scheduling/scheduling-452-directory-prefix-weighted.json`
64. `tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json`
65. `tests/fixtures/blast_radius/historical-runs/epic-655-followups.json`
66. `tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json`
67. `tests/fixtures/parallel_drift/tolerated-overlap-under-conflict-tolerance.json`
68. `tests/scripts/dev_tools/test_blast_radius_scheduling.py`
69. `tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py`
70. `tests/scripts/dev_tools/test_blast_radius_historical_runs.py`
71. `tests/scripts/dev_tools/test_parallel_drift_scheduling.py`
72. `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1`
73. `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1`
74. `tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1`
75. `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts`
76. `tests/fixtures/blast_radius_overlay/shared-surfaces-demote-already-append-only.json` [#1006] (added by the post-rebase re-derivation: its `base_text` and `expected_text` restate the committed `weights` map; the overlay composers do not read it, so the edit keeps the fixture mirroring the committed table and changes no test outcome)

Files 1, 4, 8, 13, 14, 15, 16, 39, and 45 above also carry D-7 edits.

Files deliberately not written: `scripts/dev_tools/compute_blast_radius.py`; `scripts/dev_tools/_parallel_drift_scheduling.py` (its fixture and test file, entries 67 and 71, may change only to carry the `contract` weight name); `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` (it carries `conflict_tolerance` verbatim); every parallel validator module in Python, TypeScript, and bash; `.claude/hooks/enforce-model-routing-receipt.ps1`; the `.agents/` and `.github/` copies of `pr-author` and `orchestrate`; the six execution-environment brief copies; `.claude/agents/epic-orchestrator.md`; `.claude/skills/epic-orchestrate/SKILL.md`; `quality-tiers.yml`.

## Test Strategy

New test files:

- `test_blast_radius_aggregate.py`: shared-fixture parity, tie-breaks, cascade, the no-op at tolerance 0, and the promoted `ConflictEdge` shape through `schedule_conflict_edges`.
- `test_blast_radius_aggregate_properties.py`: exhaustive over a finite domain (the existing no-`hypothesis` pattern in `test_blast_radius_scheduling_properties.py`); covers the set-level properties of D-2.
- `test_blast_radius_combination.py`: candidate classes, threshold boundary (one below, at, one above), components, disabled at tolerance 0 or with the key absent, and `estimated_savings`.
- `test_blast_radius_combination_threshold.py`: reader accept and reject cases, the default, and the committed value in both truth tables.
- `test_push_down_claude_blast_radius_default_tolerance.py` and `blast-radius-default-tolerance.test.ts`: D-1.
- `test_parallel_issue_combination_contracts.py`: skill, agent, rule, and template fragments; hook-pattern and `docs/features/active/` path absence on the new prompt lines; the absence-of-reader scan for `observed_resolution`; the corrected token-shape sentence.
- `BlastRadiusAggregate.Tests.ps1` and `BlastRadiusCombination.Tests.ps1`: the shared fixtures through the facade and `Get-BlastRadiusConflictEdge`; reader cases; a parity row that reads `COMBINATION_THRESHOLD_DEFAULT` from the Python source. Both import the facade first and the module second.

Extended test files:

- `test_validate_parallel_state_tolerated_edge_fields.py` and `parallel-state-tolerated-edge-fields.test.ts`: `observed_resolution`, `combined_issue_nums`, and `combinations`, under the plain and ready gates.
- `enforce-model-routing-receipt.AuthorAsserted.Tests.ps1`: two allow rows for a two-number line.
- `BlastRadius.Tests.ps1`: the facade export count.
- `test_blast_radius_config_tolerance_keys.py` (`COMMITTED_CONFLICT_TOLERANCE`, `test_committed_conflict_tolerance_reads_cleanly`) and `config-carriage.test-helpers.ts` (`SOURCE_BLAST_RADIUS`), on top of #1006's versions.

New fixtures: three aggregate, three combination, one overlay corpus file, and one manifest parity file, all LF JSON.

Updated for D-7 (entries 68 to 75; each gains the `contract` weight name, and a cost pin changes only for a contract-sharing pair; the AC-04 strict-identity pins keep their test bodies): `test_blast_radius_scheduling.py`, `test_blast_radius_scheduling_properties.py`, `test_blast_radius_historical_runs.py`, `test_parallel_drift_scheduling.py`, `BlastRadiusScheduling.Tests.ps1`, `BlastRadiusScheduling.PairCost.Tests.ps1`, `BlastRadius.HistoricalRuns.Tests.ps1`, and `blast-radius-derive-tolerance-keys.test.ts`.

Re-run unchanged: `test_blast_radius_write_intent.py`; the Pester write-intent suite; `test_parallel_orchestrator_surface_contracts.py`, `test_parallel_planner_surface_contracts.py`, `test_parallel_issue_adoption_skill_contracts.py`, `test_parallel_complexity_routing_contracts.py`, `test_push_down_issue_824_follow_ups.py`, `test_claude_rules_frontmatter.py`; `pr-author-issue-link-contract.Tests.ps1`; the overlay parity tests (auto-discovering the new corpus file); `parallel_manifest_parity.bats` (auto-discovering the new fixture).

Fail-before evidence: the new aggregate and combination test modules access the new module attributes inside each test, so collection succeeds and each case fails before implementation; that run is recorded under `evidence/regression-testing/`. D-1 uses the exception dossier.

Toolchain, coverage, file size, and isolation: the seven-stage loop per `.claude/rules/general-code-change.md` for Python, PowerShell, and TypeScript; coverage per `.claude/rules/general-unit-test.md` (line only for PowerShell); contract tests and isolation checks as listed in the execution-environment brief. Every new file stays at or below 500 lines; `_blast_radius_scheduling.py` and `BlastRadiusScheduling.psm1` gain only the D-7 `contract` weight name and cost term, the `combination_threshold_percent` default constant and optional-member read, and the post-pass call. Tests create no temporary files and read no gitignored `artifacts/` state.

Execution route: the distinct non-test PowerShell production files (sources plus bundle copies) exceed the direct-mode batch budget, so the orchestrator selects the `large` route (execution-environment brief, Batch Budget).

## Acceptance Criteria

Issue acceptance criteria map: issue AC 1 to AC-01; issue AC 2 to AC-02, AC-03, AC-04, AC-05; issue AC 3 to AC-06, AC-07; issue AC 4 to AC-10, AC-11, AC-12, AC-13, AC-14; issue AC 5 to AC-15; issue AC 6 to AC-16; issue AC 7 to AC-08, AC-09; issue AC 8 to AC-17; issue AC 9 to AC-18, AC-19; issue AC 10 (contract weight, added 2026-10-30) to AC-26, AC-27, AC-28, AC-29.

Default tolerance:

- [x] AC-01 Default tolerance pin: an in-memory push with no overlay writes a destination `config/blast-radius.json` whose `conflict_tolerance.tolerance_percent` is 100 and `conflict_tolerance.combination_threshold_percent` is 400, asserted in `test_push_down_claude_blast_radius_default_tolerance.py` and `blast-radius-default-tolerance.test.ts`; a `fail-before-exception.<timestamp>.md` dossier is recorded under `evidence/regression-testing/` in this feature folder.

Aggregate cost cap:

- [x] AC-02 Cap selection: `select_capped_pairs` and `Get-AggregateCappedPair` promote, for each over-cap item (integer test `total(i) * 100 > band_duration(i) * tolerance_percent`, missing band read as `default_band`), the pair with the minimum key `(benefit ascending, cost descending, a ascending, b ascending)`, repeating on the smallest-key over-cap item until none remains; `aggregate-cap-promotes-cheapest-pair.json`, `aggregate-cap-tie-break.json`, and `aggregate-cap-cascade.json` are asserted to identical results by `test_blast_radius_aggregate.py` and `BlastRadiusAggregate.Tests.ps1`.
- [x] AC-03 Single entry point: `schedule_conflict_edges` and `Get-BlastRadiusConflictEdge` apply the cap post-pass, move each promoted overlap to `edges` as `ConflictEdge(a, b, reasons[0], False, cost, benefit)` (and the PowerShell equivalent), and return both lists sorted by `(a, b)`; `_blast_radius_aggregate.py` does not import `_blast_radius_scheduling.py` at runtime.
- [x] AC-04 Strict identity: `test_property_tolerance_zero_equals_conflict`, `test_strict_identity_over_existing_conflict_fixtures`, `test_before_strict_scheduling_equals_detection`, `test_tolerance_zero_output_equals_conflict_only_output`, the Pester Context `'Strict identity'` in `BlastRadiusScheduling.Tests.ps1`, and `BlastRadius.HistoricalRuns.Tests.ps1` pass with test bodies unchanged (under D-7 only the module-level configs and helpers they read gain the `contract` weight name, and the AFTER cost pins of `BlastRadius.HistoricalRuns.Tests.ps1` come from its edited fixtures); `test_strictest_tolerance_keeps_a_scheduling_edge_for_every_must_conflict_case` remains skipped by its unconditional marker.
- [x] AC-05 Set-level properties: `test_blast_radius_aggregate_properties.py` asserts that the capped edges are a superset of the pairwise edges and a subset of the detected conflicts, that the output at tolerance 0 equals the uncapped output, that every item is within its cap after the pass, that the output is invariant to input order, and that a second pass changes nothing; `.claude/rules/parallel-orchestration.md` narrows "Raising tolerance_percent never adds an edge" to the pairwise decision.

Telemetry:

- [x] AC-06 Telemetry recorded: `.claude/rules/parallel-orchestration.md` declares `tolerated_overlaps[].observed_resolution` as tolerated-not-validated with the D-3 shape and non-exclusive attribution; `.claude/skills/parallel-orchestrate/SKILL.md` defines the writes in `## Per-Item Merge-Conflict Handling` and `## Per-Item Merge to Main (Merge-on-Green)` and prescribes `## Tolerated Overlaps` in `## Documentation Maintenance Boundaries`; `docs/features/templates/parallel/parallel-status.md` contains `## Tolerated Overlaps` with the D-3 columns; `test_seam_status_template_realises_projections_prescribed_by_skill` passes; `test_validate_parallel_state_tolerated_edge_fields.py` and `parallel-state-tolerated-edge-fields.test.ts` accept a checkpoint carrying `observed_resolution` with zero errors.
- [x] AC-07 No automatic tuning: a test in `test_parallel_issue_combination_contracts.py` asserts that no file under `scripts/`, `.claude/lib/`, or `extensions/drm-copilot/resources/claude-customizations/.claude/lib/` contains the token `observed_resolution`, and that `config_conflict_tolerance` and `Get-ConfigConflictTolerance` read only the config mapping; no existing weight value (`same_file`, `possible_overlap`, `append_only`, `module`) in either committed truth table changes.

Combination threshold:

- [x] AC-08 Threshold validation: `config_conflict_tolerance` and `Get-ConfigConflictTolerance` accept `combination_threshold_percent` as an optional non-boolean integer of at least 0, default it to 400 when absent, and reject negative, float, string, and boolean values with an error naming `config["conflict_tolerance"]["combination_threshold_percent"]`, while an unknown sibling name is still rejected; identical cases pass in `test_blast_radius_combination_threshold.py` and `BlastRadiusCombination.Tests.ps1`; a Pester row reads `COMBINATION_THRESHOLD_DEFAULT` from `_blast_radius_scheduling.py` and asserts it equals the PowerShell default; `test_absent_key_reads_as_strict` passes with only its `weights` literal gaining `"contract": 1` (D-7), and `'reads an absent key as strict'` passes unchanged.
- [x] AC-09 Committed value and destination override: both committed truth tables carry `"combination_threshold_percent": 400` as the last `conflict_tolerance` member and `"contract": 8` as the last `weights` member, with `conflict_tolerance` byte-equal across both committed copies (`test_class_one_keys_are_equal_across_both_committed_copies` passes); `COMMITTED_CONFLICT_TOLERANCE`, `test_committed_conflict_tolerance_reads_cleanly`, and `SOURCE_BLAST_RADIUS` reflect the member; `conflict-tolerance-combination-threshold.json` is composed to the same expected text by both the TypeScript and Python overlay composers, proving a destination can change the value.

Issue combination:

- [x] AC-10 Combination library: `find_combinations` and `Get-BlastRadiusCombination` implement D-5 rules 1 to 5 (disabled when the key is absent or `tolerance_percent` is 0; candidates by full `reasons` containing `contract_dependency` or `has_same_file_overlap`; qualification `cost * 100 >= benefit * combination_threshold_percent`; union-find components with ascending `members`, `primary = min(members)`, sorted `pairs`, and `estimated_savings` equal to the sum of qualifying pair costs); `combination-threshold-boundary.json` (one below, at, one above), `combination-candidate-classes.json` (contract, same file, append-only same file not a candidate, glob overlap not a candidate), `combination-component-chain.json`, and `combination-contract-only.json` (AC-28) are asserted to identical results by `test_blast_radius_combination.py` and `BlastRadiusCombination.Tests.ps1`.
- [x] AC-11 Planner procedure: `.claude/skills/parallel-plan/SKILL.md` contains `## Issue Combination` between `## Complexity Assessment` and `## Cohort Seeding`, stating no operator approval, the P6 skip with its report reason, the re-plan delegation on the primary branch with the `Combined issues:` line, the path import of each other member's feature folder, the fresh `## Complexity Assessment` of the combined item, removal of non-primary members from `items[]`, `combined_issue_nums`, the `combinations` list, and capped scheduling over the post-combination item set; `.claude/agents/parallel-planner.md` states the same duties; asserted by `test_parallel_issue_combination_contracts.py`, and `test_parallel_planner_surface_contracts.py` and `test_parallel_complexity_routing_contracts.py` pass unchanged.
- [x] AC-12 One branch, one PR, both issues closed: `.claude/skills/parallel-orchestrate/SKILL.md` places `Combined issues: #A #B` after kickoff element 3 for a combined item, and `test_parallel_orchestrate_kickoff_keeps_five_elements` and `test_parallel_orchestrator_surface_contracts.py` pass unchanged; `.claude/skills/pr-author/SKILL.md` names each issue on `Author-asserted autoclose issues: #NNN [#NNN ...]`; `.claude/skills/orchestrate/SKILL.md` lists every `Combined issues:` number on that line, keeps the literal `Author-asserted autoclose issues: #<issue-num>`, and states in `## Issue Number Consistency` that `Combined issues:` numbers are permitted cross-references; new allow rows in `enforce-model-routing-receipt.AuthorAsserted.Tests.ps1` show a line naming two issue numbers allowed with the checkpoint number in the first position and in the second position; the rule text states that no umbrella issue is created.
- [x] AC-13 Prompt-shape safety: `test_parallel_issue_combination_contracts.py` asserts that the `Combined issues:` and `Author-asserted autoclose issues:` example lines in the edited skills do not match `HOOK_ISSUE_NUMBER_PATTERN` and that no combination line carries a `docs/features/active/` path; `test_parallel_issue_adoption_skill_contracts.py` and `pr-author-issue-link-contract.Tests.ps1` pass unchanged.
- [ ] AC-14 Combined item records validate: `manifest_valid_combined_item.json` (an item carrying `combined_issue_nums`) validates with zero errors in both the Python manifest contract and the bash validator (`parallel_manifest_parity.bats`); planner and orchestrator checkpoints carrying a combined item and a `combinations` list validate with zero errors under the plain and ready gates in `test_validate_parallel_state_tolerated_edge_fields.py` and `parallel-state-tolerated-edge-fields.test.ts`.
- [x] AC-15 parallel-add reports only: `.claude/skills/parallel-add/SKILL.md` step 3 calls `Get-BlastRadiusCombination` over the candidate plus the unstarted items, reports each qualifying pair involving the candidate with the text `qualifies for combination; not combined (combination applies at planning time only)`, and states that it never combines and makes no checkpoint field or `mutations[]` change; asserted by `test_parallel_issue_combination_contracts.py`.
- [x] AC-16 Remediation as one unit: `.claude/skills/parallel-orchestrate/SKILL.md` `## Per-Item Merge-Conflict Handling` and `.claude/agents/parallel-orchestrator.md` state that a combined item that fails review or CI remediates as one unit (one child, one `remediation_loop`, one PR), never splits back into separate PRs, and is merged, blocked, or removed as a whole; asserted by `test_parallel_issue_combination_contracts.py`.
- [x] AC-17 Plan report: the `parallel-plan` `## Completion Report` and the `parallel-planner` agent's `## Completion Requirements` item 7 list each combination with members, primary, qualifying pairs with cost and benefit, threshold, and `estimated_savings`, and list not-combined qualifying pairs with the reason; asserted by `test_parallel_issue_combination_contracts.py`.

Mirrors, manifest, and facade:

- [x] AC-18 Bundle copies and pack manifest: each of the following sources is byte-identical to its copy under `extensions/drm-copilot/resources/claude-customizations/`: `.claude/rules/parallel-orchestration.md`, `.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-add/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/pr-author/SKILL.md`, `.claude/agents/parallel-planner.md`, `.claude/agents/parallel-orchestrator.md`, `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`, `.claude/lib/blast-radius/BlastRadiusAggregate.psm1`, `.claude/lib/blast-radius/BlastRadiusCombination.psm1`, and `.claude/lib/blast-radius/BlastRadius.psm1`; `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists `.claude/lib/blast-radius/BlastRadiusAggregate.psm1` and `.claude/lib/blast-radius/BlastRadiusCombination.psm1`; `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_issue_824_follow_ups.py`, and the remaining contract tests named in the execution-environment brief pass; `generate_codex_agent_variants --check` passes.
- [x] AC-19 Facade export set: the `Export-ModuleMember -Function` set of `.claude/lib/blast-radius/BlastRadius.psm1` equals the pre-change set plus `Get-BlastRadiusCombination`, and the Pester row `'exports no function beyond the spec-fixed names'` in `BlastRadius.Tests.ps1` is updated so that its expected export count equals the size of that post-change set.

Cross-cutting:

- [x] AC-20 Token-shape sentence corrected: the stale "three token shapes" sentence in `.claude/skills/parallel-plan/SKILL.md` and its bundle copy states the shape count read from the merged `.claude/rules/parallel-orchestration.md` token-shape rejection paragraph, asserted by `test_parallel_issue_combination_contracts.py`.
- [x] AC-21 Dependency gate: before implementation, each #1006 observable under Dependency on #1006 holds on `origin/main` and `git merge-base --is-ancestor origin/main HEAD` exits 0; the result is recorded under `evidence/` in this feature folder.
- [x] AC-22 Scope boundaries held: the diff against the merge base does not modify `decide_pair`, `Get-BlastRadiusPairDecision`, `conflicts`, `HARD_REASON_KINDS`, `pair_benefit`, or `pair_cost` and `Get-BlastRadiusPairCost` beyond the D-7 contract term, the `conflict_edges[].reason` enum, any parallel validator module, `_parallel_drift_scheduling.py`, `.claude/hooks/enforce-model-routing-receipt.ps1`, or any file listed under Files deliberately not written; the diff touches only files in the Complete File List and feature-folder documents and evidence.
- [x] AC-23 Fail-before evidence: the new tests in `test_blast_radius_aggregate.py`, `test_blast_radius_combination.py`, `test_blast_radius_combination_threshold.py`, and `test_blast_radius_contract_weight.py` were run against the pre-change code and failed, and the run is recorded under `evidence/regression-testing/` in this feature folder.
- [x] AC-24 Coverage: every changed or new production file meets the line and branch coverage thresholds of `.claude/rules/general-unit-test.md` (line only for PowerShell), measured per file as described in the execution-environment brief; no production file is excluded from measurement; coverage on changed lines does not regress.
- [x] AC-25 Toolchain, file size, and isolation: the seven-stage toolchain loop passes in a single pass for Python, PowerShell, and TypeScript; every new file is at or below 500 lines and every edited code file is below 700 lines; the test-isolation checks in the execution-environment brief pass and are recorded under `evidence/regression-testing/` in this feature folder.

Contract weight (owner decision 2026-10-30, D-7):

- [x] AC-26 Contract weight validation: `config_conflict_tolerance` and `Get-ConfigConflictTolerance` require `conflict_tolerance.weights.contract` exactly like `same_file`, `possible_overlap`, `append_only`, and `module`: a missing `contract` name and an unknown weight name are rejected with an error naming `config["conflict_tolerance"]["weights"]`; a boolean, float, or string value is rejected with `TypeError` (PowerShell: terminating error) and a value of 0 or below with `ValueError`, each naming `config["conflict_tolerance"]["weights"]["contract"]`; an integer of 1 or more is accepted; identical accept and reject cases pass in `test_blast_radius_contract_weight.py` and `BlastRadiusScheduling.ContractWeight.Tests.ps1`; `STRICT_CONFLICT_TOLERANCE` and the PowerShell strict hashtable carry `contract` 1, `test_absent_key_reads_as_strict` passes with only its `weights` literal gaining `"contract": 1`, and `'reads an absent key as strict'` passes unchanged; `SOURCE_BLAST_RADIUS` and every TypeScript test that restates the committed `weights` map carry `"contract": 8`, and `conflict-tolerance-contract-weight.json` is composed to the same expected text by both the TypeScript and Python overlay composers.
- [x] AC-27 Cost summed once per shared contract identifier: `pair_cost` and `Get-BlastRadiusPairCost` return the unchanged path-pair and module terms plus `weights.contract` times the number of distinct contract identifiers in the intersection the relation uses to report `contract_dependency`; asserted in both runtimes with identical results for a pair sharing zero, one, and two contract identifiers and for an identifier repeated within one radius (counted once); the cost of every pair that shares no contract is unchanged, and existing tests that pin a cost for a contract-sharing pair are updated with the reason recorded in the plan.
- [x] AC-28 Contract-only pair eligibility: a pair whose only overlap is shared contracts has cost `weights.contract * n` (not 0), is a combination candidate, and qualifies when `cost * 100 >= benefit * combination_threshold_percent`; `combination-contract-only.json` pins one contract-only pair that qualifies at the committed values and one that does not (shorter item band above the boundary), with identical results from `find_combinations` and `Get-BlastRadiusCombination`; the spec statement that contract-only pairs cannot combine is removed, and `.claude/rules/parallel-orchestration.md` (Integration-cost scheduling: Configuration and Cost) and its bundle copy state the `contract` weight, its minimum of 1, its committed value, its once-per-identifier summation, and that `contract_dependency` remains a hard edge class.
- [x] AC-29 Tolerance-0 strict identity with the contract term: at `tolerance_percent` 0 the edge set from `schedule_conflict_edges` and `Get-BlastRadiusConflictEdge` equals the detected conflict set for every `contract` weight in a tested range including 1 and the committed value; at every tested tolerance the edge set with the contract term equals the edge set with `contract` contributing 0 (only edge `cost` fields differ); asserted by a property test in `test_blast_radius_contract_weight.py` and an equivalent Pester Context in `BlastRadiusScheduling.ContractWeight.Tests.ps1`; the AC-04 strict-identity pins pass; the rule text states the invariant.

## Risks and Mitigations

- Loss of set-level monotonicity (D3): documented in the rule text and pinned by the AC-05 properties.
- Aggressive combination at committed weights: two C1 items sharing one non-append-only file give `8*100 >= 1*400`, and two C2 items give `800 >= 800`. The threshold is destination-tunable; the behavior is documented in the rule text.
- Contract-only pairs now combine at the committed values when the shorter item is C1 or C2 (D-7). The committed `contract` value 8 is an orchestrator assumption; a destination tunes it through `config/blast-radius.local.json`.
- Required `contract` weight name breaks any config that carries `weights` without it, including destination overlays that restate the full `weights` map: the overlay composers merge recursively, so an overlay that sets individual weights keeps the published `contract`; an overlay that is invalid after the merge fails fast with the key named. Every in-repository fixture carrying `weights` is updated in the same task (entries 59 to 76).
- Pinned cost values for contract-sharing edges change (historical-run and scheduling fixtures): each change is named with its reason in the plan; edge sets are pinned unchanged (AC-29).
- Unbounded combined item and larger review (R4): accepted trade, documented.
- Mirror drift across bundle copies and the Class 1 `conflict_tolerance` value: copy bundle files in one task with recorded SHA-256 pairs, edit both truth tables in one task, and run the AC-18 contract tests.
- File size: logic goes into the four new modules; line counts are recorded before and after.
- Installed-extension lag (R3): destinations and MCP validators observe the change only after release, rebuild, and reinstall; proven by in-memory tests only.
- #1006 not merged or branch not rebased (R1): AC-21 gate.

## Rollout and Follow-up

- Merge to `main`; destinations receive the cap, the combination library, and the explicit `combination_threshold_percent` at the next extension release after rebuild and reinstall.
- No feature flag. A destination disables combination by setting `tolerance_percent` 0 or raising `combination_threshold_percent` in `config/blast-radius.local.json`. Rollback is a revert.
- Links: issue #1013; issue #1006 (dependency); issue #722 (integration-cost scheduling); issue #508 (overlay); issue #643 (tolerated-not-validated precedent); research `research/research.2026-10-30T13-28.md`.
