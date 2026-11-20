# Research: parallel scheduling, balance speed against integration cost (Issue #1013)

- Issue: #1013
- Branch: feature/parallel-scheduling-integration-cost-1013
- Work mode: full-feature (preparation run)
- Requirements source: `issue.md` in this feature folder (Proposed Behavior items 1 to 5, nine acceptance criteria)
- Dependency: issue #1006, read from its exported documents (`SCRATCH/issue-1013-dep-1006-spec.md`, `-plan.md`, `-research.md`, `-issue.md`)
- Environment brief: `.claude/skills/execution-environment/SKILL.md` (referenced, not restated)
- Timestamp source: UTC read from a network time service at write time (the researcher has no shell clock): `2026-10-30T13-28`.

All findings were verified by reading the named files in this worktree, whose base is the current `main` (before #1006). Facts that need `git` or `gh` are marked **[orchestrator confirms]**.

## 0. Dependency on #1006

### 0.1 What #1006 changes that this item builds on

- Both truth tables: `quality-tiers.yml` moves from `shared_surfaces` to the end of `conflict_tolerance.append_only_paths`. `conflict_tolerance` stays byte-equal across the two copies (Class 1).
- New generic-contract predicates `is_generic_contract_token` (`scripts/dev_tools/_blast_radius_token_shapes.py`) and `Test-GenericContractToken` (`.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`).
- New overlay directive `shared_surfaces_demote` (`SHARED_SURFACES_DEMOTE_KEY` in `scripts/dev_tools/push_down_claude_blast_radius_overlay.py` and the new `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay-demote.ts`). The two corpus loaders also gain `expected_error` support.
- #1006 leaves these unchanged: `HARD_REASON_KINDS`, `decide_pair`, `conflicts`, `config_conflict_tolerance`, the facade `Export-ModuleMember` list (its plan P3-T2 keeps the facade export count at 14), the edge-reason enum, and the checkpoint schema.

This item changes none of #1006's symbols. It adds a reader member, a post-pass, and new modules beside them.

### 0.2 File overlap with #1006

Eight files are written by both items. They are marked `[#1006]` in the Complete File List:

- `config/blast-radius.json`
- `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`
- `.claude/rules/parallel-orchestration.md` and its bundle copy
- `.claude/lib/blast-radius/BlastRadius.psm1` and its bundle copy
- `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py`
- `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`

The edits do not touch the same lines or sections:

- #1006 changes the `append_only_paths` list, `Get-NormalizedDeclaredRadius`, and the read-by-mandate and overlay paragraphs of the rule.
- This item adds one `conflict_tolerance` member, two facade import lines and one export name, and edits the integration-cost section of the rule.

Because #1006 merges first, this item is a sequential edit on top of its result, not a concurrent one.

### 0.3 Phase 0 observable confirming #1006 merged [orchestrator confirms]

The planner's Phase 0 task should require all of the following on `origin/main`, and should then require that `git merge-base --is-ancestor origin/main HEAD` exits 0. Rebase first when it does not.

1. `git grep -n "def is_generic_contract_token" origin/main -- scripts/dev_tools/_blast_radius_token_shapes.py` prints one line.
2. `git grep -n "SHARED_SURFACES_DEMOTE_KEY" origin/main -- scripts/dev_tools/push_down_claude_blast_radius_overlay.py` prints at least one line.
3. `git show origin/main:config/blast-radius.json` lists `quality-tiers.yml` in `conflict_tolerance.append_only_paths` and not in `shared_surfaces`.

The current branch head is the pre-#1006 `main` tip (from the session's git status), so a rebase is expected **[orchestrator confirms]**.

## 1. Default Tolerance (research question 1)

### 1.1 Where the key is defined and read

**Definitions.** Both copies carry the same `conflict_tolerance` today:

- self-hosted `config/blast-radius.json`
- published `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`

The shared value is `tolerance_percent: 100`, weights `same_file 8, possible_overlap 2, append_only 1, module 2`, band durations `C1 1, C2 2, C3 4, C4 8`, `default_band C1`, and `append_only_paths [**/CHANGELOG.md, extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json]`.

**Python reader.** `config_conflict_tolerance` in `scripts/dev_tools/_blast_radius_scheduling.py`:

- It requires exactly the five member names in `_MEMBER_NAMES`, checked by `_require_names`, which reports missing and unknown names.
- `tolerance_percent` is read by `_require_int` with a minimum of 0; booleans are rejected.
- Weights and band durations are read by `_read_int_map`, each value an integer of at least 1.
- `default_band` must be in `BAND_NAMES`; `append_only_paths` is read by `require_str_tuple`.
- An absent key returns `STRICT_CONFLICT_TOLERANCE`.

**PowerShell reader.** `Get-ConfigConflictTolerance` in `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`, using `Assert-ExactMemberName`, `Get-RequiredInteger`, and `Get-RequiredIntegerMap`. It has the same rules, and an absent or null key returns the strict hashtable.

**TypeScript.** There is no reader and no scheduling code.

- `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` copies `conflict_tolerance` verbatim from the bundled source (`CARRIED_KEYS`, used by `deriveDestinationModuleMap`).
- The overlay composer (`composeBlastRadiusOverlay` in `claude-blast-radius-overlay.ts`) merges `conflict_tolerance` recursively, with nested scalars won by the overlay.
- The Python push-down mirrors this: `push_down_claude_blast_radius_derive_core.py` carries the key, and `compose_blast_radius_overlay` composes it.

**Bash.** `.claude/lib/bash/` contains no tolerance or scheduling code (grep for `tolerance` returned nothing). `compute-cohorts.sh` takes the edges it is given.

### 1.2 Finding: the published copy already ships a nonzero default

The published table already carries `tolerance_percent: 100`, and both push-down derivers carry it verbatim. A destination with no overlay therefore already gets cost-benefit scheduling after an extension rebuild and reinstall. Proposed Behavior item 1 and AC 1 hold on the current branch base.

The issue text ("a destination with no `conflict_tolerance` gets strict scheduling") describes a destination whose file lacks the key. The installed-extension lag is one plausible cause (execution-environment brief, MCP section), and #1006's destination report used a `tolerance_percent: 5000` overlay as a workaround on top of the default.

This item therefore adds a regression pin rather than a value change: an in-memory push with no overlay must produce `tolerance_percent` 100 (and `combination_threshold_percent` 400, section 5) in both runtimes.

Fail-before evidence is structurally impossible for this AC, so the plan needs a `fail-before-exception.<timestamp>.md` dossier under `evidence/regression-testing/` (evidence conventions skill).

### 1.3 Tests that pin these values

**Python:**

- `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py`: `COMMITTED_CONFLICT_TOLERANCE`, `test_committed_conflict_tolerance_values`, and `test_committed_conflict_tolerance_reads_cleanly`. #1006 edits this file.
- `tests/scripts/dev_tools/test_blast_radius_config_parity.py`: `test_class_one_keys_are_equal_across_both_committed_copies`, with `conflict_tolerance` in `BYTE_EQUAL_KEYS` of `blast_radius_parity_test_support.py`.

**Pester:** `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` (`$script:ClassOneKeys`).

**TypeScript:** `SOURCE_BLAST_RADIUS` in `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` is pinned to the bundled file by "keeps SOURCE_BLAST_RADIUS in step with the committed bundled blast-radius resource" in `claude-config-carriage.test.ts`. #1006 edits this helper.

**Local constants that are not compared to the committed file:**

- `CONFLICT_TOLERANCE` in `blast-radius-derive-tolerance-keys.test.ts`
- `conflict_tolerance: { tolerance_percent: 100 }` in `blast-radius-derive.test.ts` and `blast-radius-derive-mergeable.test.ts`
- `Get-CommittedToleranceMember` in `BlastRadiusScheduling.Tests.ps1`

These remain unchanged.

### 1.4 Class 1 interaction

Any change to `conflict_tolerance` must be byte-identical in both copies. The only value change this item makes is the new member `combination_threshold_percent: 400` (section 5), appended as the last member in both copies.

After #1006 and this item, the committed value is #1006's value plus that member. Three things are updated together, on top of #1006's versions:

- `COMMITTED_CONFLICT_TOLERANCE` and `test_committed_conflict_tolerance_reads_cleanly`
- `SOURCE_BLAST_RADIUS`

## 2. Aggregate Cost (research question 2)

### 2.1 Current per-pair decision (all runtimes that schedule)

**Python** (`scripts/dev_tools/_blast_radius_scheduling.py`, 495 physical lines):

- `decide_pair` reads the tolerance and calls the relation once (default `conflicts`).
- Hard is computed from `HARD_REASON_KINDS` (`shared_surface_overlap`, `contract_dependency`).
- Cost is `pair_cost`: per-entry-pair weights from `_path_pair_weight` (append-only first, then same_file, then possible_overlap), plus the module weight times the number of shared modules. Contracts add no cost.
- Benefit is `pair_benefit`, the minimum of the two band durations.
- The edge rule is `hard or tolerance_percent == 0 or cost*100 > benefit*tolerance_percent`.
- `schedule_conflict_edges` visits pairs in `(a, b)` key order and returns a `SchedulingResult` of `edges` (`ConflictEdge`) and `tolerated_overlaps` (`ToleratedOverlap`).

**PowerShell** (`.claude/lib/blast-radius/BlastRadiusScheduling.psm1`, 483 physical lines) has the same logic in `Get-BlastRadiusPairDecision`, `Get-BlastRadiusPairCost`, `Get-BlastRadiusPairBenefit`, `Get-PathPairWeight`, and `Get-BlastRadiusConflictEdge`. The relation is passed in as `-Relation`.

**Other runtimes:**

- TypeScript and bash implement no scheduling.
- `scripts/dev_tools/parallel_cohort_computation.py` (`compute_cohorts`) and `.claude/lib/bash/compute-cohorts.sh` color the edges they are given. They never evaluate contention, so they need no change.
- Drift re-scheduling (`scripts/dev_tools/_parallel_drift_scheduling.py`) uses `decide_pair` pairwise.

### 2.2 Where to insert the cap (recommended)

Run the cap as a post-pass inside `schedule_conflict_edges` and `Get-BlastRadiusConflictEdge`, so the one scheduling entry point that planners and `parallel-add` already call applies it. Put the logic in new leaf modules:

- **Python.** New `scripts/dev_tools/_blast_radius_aggregate.py` exporting `select_capped_pairs`.
  - Inputs: the tolerated overlaps (any object with `a`, `b`, `cost`, `benefit`; the module types this as a structural protocol, and `ConflictTolerance` appears only under `TYPE_CHECKING`), a key-to-band map, and the tolerance.
  - Output: the ordered tuple of `(a, b)` pairs to promote.
  - `_blast_radius_scheduling.py` imports it in one direction only, so there is no import cycle. `schedule_conflict_edges` keeps the result of its existing `config_conflict_tolerance(config)` call, calls `select_capped_pairs`, moves the promoted overlaps to `edges` as `ConflictEdge(a, b, reasons[0], False, cost, benefit)`, and re-sorts both lists by `(a, b)`.
- **PowerShell.** New `.claude/lib/blast-radius/BlastRadiusAggregate.psm1` exporting `Get-AggregateCappedPair`, imported by `BlastRadiusScheduling.psm1` (`Import-Module ... -Force -ErrorAction Stop`, the module convention). `Get-BlastRadiusConflictEdge` applies the same post-pass.

**Cap rule.** For an item `i`, `total(i)` is the sum of `cost` over the remaining tolerated overlaps that include `i`, and `cap(i)` is `band_duration(i) * tolerance_percent / 100`, where a missing band reads as `default_band`. The item is over the cap when `total(i) * 100 > band_duration(i) * tolerance_percent`, using integers only.

**Cheapest-to-serialize pair (deterministic).** Among the over-cap item's remaining tolerated overlaps, take the minimum by the key `(benefit ascending, cost descending, a ascending, b ascending)`:

- The smallest benefit gives up the least parallelism.
- The largest cost then removes the most integration cost.
- The pair keys make the choice total.

**Iteration.** Repeat: take the smallest-key item that is over its cap, promote its cheapest pair, and recompute the totals. Stop when no item is over its cap.

- Each round removes one tolerated overlap, so the loop terminates.
- Overlaps are visited in sorted order, so the result does not depend on input order and running it again changes nothing.

### 2.3 Properties and existing pins

**Strict identity.** At `tolerance_percent` 0, `decide_pair` makes every conflict an edge (the explicit zero short-circuit), so the tolerated list is empty and the post-pass is a no-op. With the key absent, the same holds through `STRICT_CONFLICT_TOLERANCE`.

These pins re-run unchanged:

- `test_property_tolerance_zero_equals_conflict` (`test_blast_radius_scheduling_properties.py`)
- `test_strict_identity_over_existing_conflict_fixtures` (`test_blast_radius_scheduling.py`)
- `test_before_strict_scheduling_equals_detection` (`test_blast_radius_historical_runs.py`)
- `test_tolerance_zero_output_equals_conflict_only_output` (`test_parallel_drift_scheduling.py`)
- Pester Context `'Strict identity'` in `BlastRadiusScheduling.Tests.ps1`
- `BlastRadius.HistoricalRuns.Tests.ps1`
- `test_strictest_tolerance_keeps_a_scheduling_edge_for_every_must_conflict_case` stays skipped by its unconditional marker.

**A single overlap never exceeds the cap.** A tolerated pair satisfies `cost*100 <= benefit*tolerance_percent`, and `benefit = min(band_a, band_b) <= band_i`. The cap can therefore only bind for an item with two or more tolerated overlaps.

**Existing pinned outputs stay identical.** Verified by reading each fixture:

- `scheduling-soft-pair-tolerated.json`: one overlap per item.
- `scheduling-452-directory-prefix-weighted.json` at tolerance 1000000: two overlaps per item, total 4 against a cap of 10000.
- `followups-2026-09-27.json`: one tolerated overlap. `epic-655-followups.json` and `backlog-2026-09-26.json`: none.
- `write-intent-shared-surface-read-citation.json`: none.
- `test_edges_and_tolerated_overlaps_are_sorted_by_pair`: tolerated `(1, 5)` only.

**Pairwise properties hold unchanged.** The edge-implies-conflict, monotonicity, and symmetry properties in `test_blast_radius_scheduling_properties.py` are properties of `decide_pair`, which is not modified.

**Set-level monotonicity is lost.** With the cap, raising `tolerance_percent` can add a promoted edge. For example, a pair that is a pairwise edge at a low tolerance becomes tolerated at a higher one, which raises an item's total, and the cap then promotes a different pair. The rule text "Raising tolerance_percent never adds an edge" must be narrowed to the pairwise decision. New property tests pin what does hold at the set level:

- the capped edges are a superset of the pairwise edges and a subset of the detected conflicts;
- the output at tolerance 0 is identical to the uncapped output;
- after the pass, every item is within its cap;
- the output is invariant to input order;
- running the pass again changes nothing.

**Drift detection stays pairwise.** `_parallel_drift_scheduling.py` is unchanged. This is recorded as a scope boundary: a cap-promoted pair is a recorded edge, so drift never reports it as newly conflicting.

## 3. Telemetry (research question 3)

### 3.1 Current records

- The parallel-orchestrator checkpoint `artifacts/orchestration/parallel-orchestrator-state.json` is gitignored and is a cache (rule, Cache Doctrine). It carries `tolerated_overlaps` as a tolerated-not-validated list. The rule states "the planner records it ... (and the orchestrator carries it)", and `test_validate_parallel_state_tolerated_edge_fields.py` and `parallel-state-tolerated-edge-fields.test.ts` pin that it is accepted.
- The durable run record is `docs/features/parallel/<slug>/parallel-status.md`. It is a generated projection, committed at Run Closing (`parallel-orchestrate` skill `### Run Closing` substep 3), and its template is `docs/features/templates/parallel/parallel-status.md`. The template has no tolerated-overlap section today.
- The precedent for a tolerated-not-validated record is `items[].mergeable_conflicts_resolved` (rule, issue #643 paragraph), which is projected under `## Mergeable Conflicts Resolved`.

### 3.2 Recommended placement (least invasive)

**Checkpoint field.** Add an optional object `observed_resolution` to each orchestrator-checkpoint `tolerated_overlaps[]` entry, as tolerated-not-validated data. Its shape:

```
{ later_item: int, conflicted: bool, conflict_detected_at: str|null, resolved_at: str|null, resolution_minutes: int, recorded_at: str }
```

**Who writes it.** `parallel-orchestrator`, inside the existing procedure:

- `## Per-Item Merge-Conflict Handling`, at step (a) or step 1: when the item whose merge conflicted is the later-merging item of a tolerated pair whose peer is already `merged` or `worktree_removed`, set `conflicted: true` and `conflict_detected_at` if they are not already set.
- `## Per-Item Merge to Main (Merge-on-Green)`, at the later item's confirmed merge: set `resolved_at` to the first `ci_green` confirmation that follows the detection, `resolution_minutes` to the whole minutes between detection and `resolved_at`, and `recorded_at`. When no conflict occurred, set `conflicted: false` and `resolution_minutes: 0`.

**Attribution is non-exclusive.** One conflict episode is attributed to every tolerated peer that merged before it. Because this is telemetry only, the imprecision is documented rather than resolved.

**Durable copy.** Add a `## Tolerated Overlaps` projection section to the template with the columns `a | b | reasons | cost | benefit | later_item | conflicted | resolution_minutes`. Prescribe it in the skill's `## Documentation Maintenance Boundaries`, and add "every write of an `observed_resolution`" to the regeneration boundaries. `test_seam_status_template_realises_projections_prescribed_by_skill` binds the prescribed heading to the template.

**No automatic tuning.** Nothing reads `observed_resolution`. A new contract test asserts that no file under `scripts/` or `.claude/lib/` (and the bundled `.claude/lib/`) contains the token, and that `config_conflict_tolerance` and `Get-ConfigConflictTolerance` read only the config mapping.

### 3.3 Schema and enum impact (called out explicitly)

- **The `conflict_edges[].reason` enum is unchanged** (four members). `same_file` stays a cost weight and is never a reason; `test_out_of_enum_reason_is_still_rejected` already pins its rejection.
- **No validated schema change.** Three tolerated-not-validated fields are added and declared in the rule:
  - `tolerated_overlaps[].observed_resolution` (orchestrator checkpoint)
  - `items[].combined_issue_nums` (manifest, planner checkpoint, orchestrator checkpoint)
  - a top-level `combinations` list (planner checkpoint)
- **No validator changes**, in Python (`validate_parallel_orchestrator_state.py`, `validate_parallel_planner_state.py`, `parallel_manifest_contract.py`), TypeScript (`extensions/drm-copilot/src/lib/validate/parallel-*`), or bash (`.claude/lib/bash/parallel-manifest-validate.sh`, `parallel-items-validate.sh`).
  - Verified: no unknown-key rejection exists for items (a grep of the `_parallel_*.py` helpers for unknown or additional key checks found only unrelated comments).
  - `combined_issue_nums` is a block sequence nested one level under an item, within the bash YAML subset that already parses `blast_radius.paths`.
- Acceptance tests are added: Python and TypeScript validator tests, and a bash/Python manifest parity fixture.

## 4. Issue Combination (research question 4)

### 4.1 Surfaces

- The parallel skills and agents exist only under `.claude/` and their bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/`:
  - skills `parallel-plan`, `parallel-add`, `parallel-orchestrate`, `parallel-run`, `parallel-close`, and `parallel-remove`
  - agents `parallel-planner` and `parallel-orchestrator`
- A glob of `.agents`, `.github`, `.codex`, and the codex-and-agents bundle for `*parallel*` returned no files. There are no Codex generated variants.
- Manifest validation: `.claude/lib/bash/validate-parallel-manifest.sh` (entry point), `parallel-manifest-validate.sh` and `parallel-items-validate.sh` (libraries), and the Python authority `scripts/dev_tools/parallel_manifest_contract.py`.
- Cohort computation consumes edges only.

### 4.2 Recommended mechanism

**New library.**

- Python `scripts/dev_tools/_blast_radius_combination.py`, exporting `find_combinations(items, config) -> CombinationResult` and `has_same_file_overlap(radius_a, radius_b, config, tolerance)`.
- PowerShell `.claude/lib/blast-radius/BlastRadiusCombination.psm1`, exporting `Get-BlastRadiusCombination -Item -Config -Relation`, which returns `@{ pairs; combinations }`. The facade `BlastRadius.psm1` re-exports it.

**Rules:**

1. Combination is disabled when `conflict_tolerance` is absent or `tolerance_percent` is 0. The strict identity then extends to the item set.
2. For each conflicting pair, `decide_pair` (or `Get-BlastRadiusPairDecision`) supplies `reasons`, `cost`, and `benefit`. Edges and tolerated pairs are both evaluated.
3. **Candidate:** `contract_dependency` is in the reasons, or `has_same_file_overlap` is true.
   - `has_same_file_overlap` means at least one overlapping entry pair, after the mergeable exclusion, has two equal concrete entries and neither matches `append_only_paths`. This mirrors the precedence in `_path_pair_weight`, so an append-only registry is never a same-file candidate.
   - `contract_dependency` is not first in canonical kind order (`CONFLICT_KINDS` in `_blast_radius_conflicts.py`), so the edge `reason` field cannot be used; the full reasons are required.
4. **Qualifies** when `cost * 100 >= benefit * combination_threshold_percent`. Benefit is the shorter item's band duration, which is the existing pair benefit.
5. **Components.** Qualifying pairs are grouped into connected components with union-find. Each component of two or more items becomes one combination: `members` ascending, `primary = min(members)`, `pairs` sorted by `(a, b)`, and `estimated_savings` equal to the sum of the qualifying pair costs (cost units). There is no size cap, per the issue. Combination runs once, before cohort seeding, and is not repeated on combined radii.

**Planner procedure.** Add a new `## Issue Combination` section to `.claude/skills/parallel-plan/SKILL.md`, after `## Complexity Assessment` and before `## Cohort Seeding`:

1. Once every item is prepared, its radius is declared, and it has a band, call `Get-BlastRadiusCombination`.
2. If applying all combinations would leave fewer than two items (ready-gate invariant P6), apply none and report each qualifying pair as not combined, with that reason.
3. For each combination, issue one follow-up preparation-mode delegation on the primary item's pushed branch. This follows the V1/V2 re-plan posture already in the skill. The delegation carries:
   - the unchanged preparation kickoff line, then
   - a combination line naming the other members by issue number (`Combined issues: #A #B`) and by branch name only.
4. The child imports each other member's committed feature folder by path from that member's pushed branch ref. This is a path checkout, not a branch merge, so the "no fan-in merge step" statement still holds. The child then authors one atomic plan in the primary feature folder covering every member's spec, re-runs preflight, commits, and pushes.
5. The planner re-derives the combined item's declared radius from the combined plan and runs a fresh `## Complexity Assessment` for it.
6. The planner removes the non-primary members from `items[]`, records `combined_issue_nums`, and records the combination in a `combinations` list.
7. Only then does it run the capped scheduling entry point over the post-combination item set.

The non-primary members' preparation branches stay in place and are reported. This is the same residual as risk 2 in `## Artifact Home`.

**Report.** The `## Completion Report` of `parallel-plan` and the planner agent's `## Completion Requirements` item 7 list each combination: members, primary, qualifying pairs with cost and benefit, threshold, and `estimated_savings`. Not-combined qualifying pairs are listed with the reason.

**Execution.**

- `parallel-orchestrate` `## Parallel-Mode Kickoff Parameter`, element 3: for a combined item, element 3 is followed by the line `Combined issues: #A #B`. The element count stays at five, because `test_parallel_orchestrate_kickoff_keeps_five_elements` pins "exactly these five elements" and forbids a "6." line.
- The child carries every member on its pr-author line: `Author-asserted autoclose issues: #A #B`.
- `## Per-Item Merge-Conflict Handling` states that a combined item remediates as one unit (one child, one `remediation_loop`, one PR) and is never split. Merge, block, and removal apply to it as a whole.

**Prompt-shape constraints** (verified against `HOOK_ISSUE_NUMBER_PATTERN` in `test_parallel_issue_adoption_skill_contracts.py`, `issue(?:[_-]?num(?:ber)?|\s+number)\s*[:=]\s*#?(\d+)`):

- `Combined issues:` and `Author-asserted autoclose issues:` do not match that pattern.
- A combination line must not carry a `docs/features/active/<basename>` path. Parallel-mode target resolution (F7 Layer 1) scans for exactly that shape (`parallel-orchestrate` kickoff element 2).

**`parallel-add`.** In step 3, after edges are computed, call `Get-BlastRadiusCombination` over the candidate plus the unstarted items. Report each qualifying pair that involves the candidate as "qualifies for combination; not combined (combination applies at planning time only)". No checkpoint field and no `mutations[]` change is made. Because the cap is inside `Get-BlastRadiusConflictEdge`, `parallel-add` edges are capped as well.

**pr-author autoclose (two issues).**

- The hook already accepts two numbers. `Get-ModelRoutingAuthorAssertedReason` in `.claude/hooks/enforce-model-routing-receipt.ps1` matches `(?m)^Author-asserted autoclose issues:[^\r\n]*#<issue-num>(?!\d)`, so a line `#A #B` passes for issue-num A. The hook is not changed. Two Pester rows pin that a two-number line is allowed with the checkpoint number in either position.
- `.claude/skills/pr-author/SKILL.md` (Issue/PR Reference Rules, source 3) is reworded to "each issue named on the line `Author-asserted autoclose issues: #NNN [#NNN ...]`". PC-03 fragments (`delegation prompt`, `no verified autoclose issues`, not `sourced only from`) stay satisfied.
- `.claude/skills/orchestrate/SKILL.md` `## PR Authoring (pr-author Handoff)` step 3: the line also lists every issue named on a `Combined issues:` line of a parallel kickoff. The PC-01 literal `Author-asserted autoclose issues: #<issue-num>` is kept.
- `## Issue Number Consistency` gains one sentence: numbers on a `Combined issues:` line are permitted cross-references, not discrepancies.
- The `.agents/` copies of `pr-author` and `orchestrate` already differ from the Claude copies (they predate issue #989), and the parallel surface is Claude-only, so they are not edited.
- A search of `.claude/hooks/*.ps1` found no mechanical issue-number mismatch check (searched for `ISSUE_NUM.*MISMATCH`, `different issue`, and `issue ... mismatch|does not match|differs`).

## 5. `combination_threshold_percent` (research question 5)

**Where keys are validated:**

- Python: `config_conflict_tolerance` (`_require_names`, `_require_int`).
- PowerShell: `Get-ConfigConflictTolerance` (`Assert-ExactMemberName`, `Get-RequiredInteger`).
- TypeScript: no validator. The derive and overlay code pass the member through verbatim or by recursive merge, so the TypeScript side is "not ported", and parity is proven by the overlay corpus fixture plus the carriage pin.

**Recommended rules:**

- An optional member of `conflict_tolerance`. The reader accepts the five required names plus this optional name; any other name is still rejected.
- When present, it must be a non-boolean integer of at least 0, read by the same `_require_int` / `Get-RequiredInteger` path with the same error-label style (`config["conflict_tolerance"]["combination_threshold_percent"]`).
- When absent inside a present key, it defaults to `COMBINATION_THRESHOLD_DEFAULT = 400`. The constant is defined in `_blast_radius_scheduling.py`, and a Pester row pins the PowerShell constant to the Python source.
- `ConflictTolerance` gains a field with default 400. `STRICT_CONFLICT_TOLERANCE` and the existing five-keyword constructor call in `test_absent_key_reads_as_strict` therefore still compare equal, so that test is unchanged.
- The PowerShell hashtable gains a `combination_threshold_percent` key. The strict-read assertions in `'reads an absent key as strict'` index named keys only and are unchanged.
- Optional rather than required keeps every existing fixture config (scheduling, historical-runs, write-intent, drift, overlay) valid without edits.
- Both committed tables carry `"combination_threshold_percent": 400` explicitly, so a destination sees and can override it through `config/blast-radius.local.json` (issue #508 recursive merge, overlay wins).

**Tests that enumerate the key set:**

- The top-level partition (`DECLARED_TOP_LEVEL_KEYS`, `test_every_top_level_key_is_classified_and_shared_by_both_copies`, and the Pester `'requires every top-level key in both copies to be classified and shared'`) enumerates top-level keys only. A nested member does not affect it.
- The member set is pinned by the reader's exact-name check and by `INVALID_SHAPES` / `$readerCase`. These existing cases stay valid.
- New reader cases go in new test files:
  - negative, float, string, boolean
  - absent, which defaults to 400
  - an unknown sibling name, which is still rejected

## 6. Mirrors and Contract Tests (research question 6)

**Bundle copies** (`extensions/drm-copilot/resources/claude-customizations/` + the same relative path). There are 11 of them:

- the rule `parallel-orchestration.md`
- the skills `parallel-plan`, `parallel-add`, `parallel-orchestrate`, `orchestrate`, and `pr-author`
- the agents `parallel-planner.md` and `parallel-orchestrator.md`
- the PowerShell modules `BlastRadiusScheduling.psm1`, `BlastRadiusAggregate.psm1` (new), `BlastRadiusCombination.psm1` (new), and `BlastRadius.psm1`

**Pack manifest.** `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` must list `.claude/lib/blast-radius/BlastRadiusAggregate.psm1` and `.claude/lib/blast-radius/BlastRadiusCombination.psm1`. The existing blast-radius entries are in the core list. Coverage is enforced by `test_push_down_claude_pack_manifest_completeness.py` and by `test_push_down_pack_manifest_dependency_closure.py`, since both modules are `$PSScriptRoot` dependencies.

**No mirrors in other runtimes.** None of the edited files has an `.agents/`, `.github/`, or `.codex/` mirror that must change: parallel files have none, and the `.agents/` `pr-author`/`orchestrate` copies are already divergent and out of scope. No Codex generated variant is affected; `generate_codex_agent_variants --check` is a re-run only.

**Pinned hashes.** `PINNED_FROZEN_SURFACE_HASHES` pins only `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`. Neither is edited.

**Heading pins on `parallel-orchestrate`** (`test_parallel_orchestrator_surface_contracts.py`): exactly sixteen `##` headings, the first thirteen fixed, and the last three reserved. All new text goes inside existing sections or under `###` subheadings.

**Other text pins to respect:**

- `test_parallel_planner_surface_contracts.py`: no `depends_on:`, no integration-branch creation phrasing, and the "There is no fan-in merge step" and "explicitly not an integration branch" statements kept.
- `test_parallel_issue_adoption_skill_contracts.py`: five kickoff elements; the kickoff line byte-identical.
- `test_parallel_complexity_routing_contracts.py`
- `test_push_down_issue_824_follow_ups.py`: pushed rules and skills name no consuming product, so no destination repository name appears in the new text.
- `test_claude_rules_frontmatter.py`: the rule's `paths:` already covers `scripts/dev_tools/*blast_radius*` and `.claude/lib/blast-radius/**`, so no frontmatter edit is needed.

**Execution-environment brief.** It is not affected. This change adds no CI job, required context, tool route, or batch-budget rule, and changes no listed contract test, so the six brief copies are not edited.

## 7. Batch Budget, Route, and File Size (research question 7)

**Python** distinct non-test production files: 3.

1. `scripts/dev_tools/_blast_radius_scheduling.py`
2. `scripts/dev_tools/_blast_radius_aggregate.py` (new)
3. `scripts/dev_tools/_blast_radius_combination.py` (new)

**PowerShell** distinct non-test production files: 4 sources plus 4 bundle copies, 8 in total, which exceeds the direct-mode cap of three.

1. `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`
2. `.claude/lib/blast-radius/BlastRadiusAggregate.psm1` (new)
3. `.claude/lib/blast-radius/BlastRadiusCombination.psm1` (new)
4. `.claude/lib/blast-radius/BlastRadius.psm1`

Execution therefore needs a non-terminal `large` route in the item worktree checkpoint (execution-environment brief, Batch Budget) **[orchestrator selects]**.

**File-size exposure** (physical lines at the pre-#1006 base; re-count after the rebase):

| File | Lines | Expected after | Tier note |
|---|---|---|---|
| `scripts/dev_tools/_blast_radius_scheduling.py` | 495 | about 515 | crosses the 500 guidance tier, stays well below 700 and 800 |
| `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` | 483 | about 500 | at the guidance tier |
| `.claude/lib/blast-radius/BlastRadius.psm1` | 475 | about 477 (+#1006 small) | below 500 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1` | 492 | 492 (count change only) | below 500 |
| `tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1` | 267 | about 295 | below 500 |
| `tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py` | 99 | about 150 | below 500 |
| `extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts` | 195 | about 250 | below 500 |
| `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` | 270 | 271 | below 500 |
| `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py` | 153 | about 156 | below 500 |

All new logic goes into the four new modules and all new cases into new test files. Each new file must stay at or below 500 lines. Markdown files are exempt.

## 8. Recommended Design Summary

1. **Default tolerance.** No value change; the published copy already ships 100. Add a two-runtime push-down pin and a fail-before exception dossier.
2. **Aggregate cap.** A deterministic post-pass inside the existing scheduling entry point, in new leaf modules. It is a no-op at tolerance 0 and leaves `decide_pair` untouched.
3. **Telemetry.** A tolerated-not-validated `observed_resolution` on orchestrator `tolerated_overlaps[]` entries, projected durably into `parallel-status.md`. Nothing reads it.
4. **Benefit currency.** Unchanged: band durations.
5. **Combination.** A new pure library (Python authority, PowerShell runtime port, facade re-export) plus a planner procedure:
   - re-plan on the primary branch, fresh assessment, then the capped scheduling over the combined item set;
   - one PR closing every member through a multi-number author-asserted line, which the existing hook already accepts;
   - `parallel-add` reports qualifying pairs only.

**Rejected alternatives (brief):**

- Folding the cap into `decide_pair`: it cannot see other pairs and would break the pairwise property pins.
- A separate capped entry point beside `schedule_conflict_edges`: two entry points let a caller skip the cap.
- Validated schema fields for combination or telemetry: these would change validators in three runtimes against the tolerated-not-validated precedent.
- A new `contract` cost weight: it would change the five-member weight map, every fixture config, and the Class 1 value.
- Merging the secondary preparation branch: this conflicts with the no-fan-in doctrine; a path import is used instead.
- Changing the author-asserted hook: it already accepts several numbers.

## 9. Behavior Semantics and Proposed Acceptance Criteria

**Success and failure conditions:**

- A malformed `combination_threshold_percent` raises in the reader, naming the key: `TypeError` or `ValueError` in Python, a throw in PowerShell.
- The cap and combination functions are total over valid input and pure: no I/O, and no input mutation.
- Ordering: detection, then pair decisions, then combination (planning only, once), then re-plan and fresh assessment, then capped scheduling, then cohort seeding.

**Proposed ACs** for `spec.md`. Each maps to an issue AC (I-n):

- **AC-01 (I-1).** An in-memory push with no overlay writes a destination `config/blast-radius.json` whose `conflict_tolerance.tolerance_percent` is 100 and `combination_threshold_percent` is 400. This is asserted in a new pytest module and a new Jest suite. A fail-before exception dossier is recorded.
- **AC-02 (I-2).** `select_capped_pairs` / `Get-AggregateCappedPair` promote the cheapest-to-serialize pair, by the tie-break key in section 2.2, of each over-cap item until none remains. Shared fixtures under `tests/fixtures/blast_radius/aggregate/` are asserted identically by pytest and Pester.
- **AC-03 (I-2).** Strict identity: every pin listed in section 2.3 passes unchanged, and the new property tests in section 2.3 pass. The rule text narrows the monotonicity statement to the pairwise decision.
- **AC-04 (I-3).** The rule, the `parallel-orchestrate` skill, and the template define `tolerated_overlaps[].observed_resolution` and the `## Tolerated Overlaps` projection. The Python and TypeScript validators accept the field with zero errors. The absence-of-reader test passes.
- **AC-05 (I-4, I-7).** `combination_threshold_percent` is validated as in section 5 in Python and PowerShell, with identical accept and reject cases. The default constant is pinned across the two runtimes. An overlay corpus fixture proves that a destination can change it in both composers (TypeScript and Python).
- **AC-06 (I-4).** `find_combinations` / `Get-BlastRadiusCombination` implement section 4.2 rules 1 to 5. The threshold boundary (one below, at, one above) and the candidate classes are asserted from shared fixtures under `tests/fixtures/blast_radius/combination/`: contract, same-file, append-only same file (not a candidate), glob overlap (not a candidate), and a chain component.
- **AC-07 (I-4, I-6).** The `parallel-plan` and `parallel-planner` text defines:
  - the re-plan delegation, the path import, and the fresh complexity assessment;
  - the P6 skip;
  - the `combinations` list and `combined_issue_nums`;
  - the statement that a combined item remediates as one unit and never splits;
  - the five-element kickoff with the `Combined issues:` line.
  The `Combined issues:` line carries no hook issue-number shape and no `docs/features/active/` path. All of this is pinned by a new contract test.
- **AC-08 (I-4).** A manifest item carrying `combined_issue_nums` validates with zero errors in Python and bash (a new parity fixture). Planner and orchestrator checkpoints carrying a combined item and a `combinations` list validate with zero errors, including under the ready gate.
- **AC-09 (I-4).** Two Pester rows show the author-asserted hook allowing a two-number line with the checkpoint number in either position. The `pr-author` and `orchestrate` skill text names every combined issue.
- **AC-10 (I-5).** The `parallel-add` step-3 text reports qualifying pairs with unstarted items and states that it never combines (contract test).
- **AC-11 (I-8).** The `parallel-plan` `## Completion Report` and the planner agent's completion item 7 list each combination with members, pairs, threshold, and `estimated_savings` (contract test).
- **AC-12 (I-9).** The 11 bundle copies are byte-identical to their sources. `core.json` lists both new modules. The contract tests named in the execution-environment brief pass.
- **AC-13.** The facade `Export-ModuleMember` set is the pre-change set plus `Get-BlastRadiusCombination`. The Pester row `'exports no function beyond the spec-fixed names'` is updated to 15 (see Numeric Derivation Evidence).
- **AC-14.** Coverage meets the policy thresholds on every changed or new production file, toolchain loop and isolation checks per the brief, and the scope boundary holds (`decide_pair`, `conflicts`, `HARD_REASON_KINDS`, the reason enum, validators, and drift detection are unchanged).

## Numeric Derivation Evidence

Numeric claim: the facade `BlastRadius.psm1` exports 14 functions before this change, and 15 after, once `Get-BlastRadiusCombination` is added (AC-13).

- **Complete Family:** every function name listed in the `Export-ModuleMember -Function` statement of `.claude/lib/blast-radius/BlastRadius.psm1`, which is the module's complete export surface.
- **Exhaustive Search Scope:** the whole `.claude/lib/blast-radius/BlastRadius.psm1` file (primary), and the whole bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1` (cross-check).
- **Inclusion Rules:** each name between `Export-ModuleMember -Function` and the end of that statement.
- **Exclusion Rules:** functions defined but not exported, and the export lists of sibling modules.
- **Primary Search Strategy or Query Expression:** grep `Import-Module|Export-ModuleMember|^\s+Get-|^\s+Test-` on the source file, then reading the `Export-ModuleMember` statement in full.
- **Primary Member Set:** Get-PlanPaths, Get-BlastRadius, Get-NormalizedDeclaredRadius, Get-BlastRadiusFromObservedPaths, Test-BlastRadius, Test-BlastRadiusConflict, Get-BlastRadiusConflictEdge, Get-BlastRadiusPairDecision, Test-WriteIntentExtractionEnabled, Get-ConfigPathRoot, Get-WriteIntentPlanPath, Get-WriteIntentSpecContract, Select-WriteIntentPathEntry, Get-PlanPathForConfig.
- **Primary Count:** 14.
- **Cross-check Search Strategy or Query Expression:** a line-anchored regex `^    (Get|Test|Select)-[A-Za-z]+(, \`)?$` over the bundle copy, which is a separate file and a distinct query. As a further check, the Pester pin `$exported.Count | Should -Be 14` in `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1`, and #1006 plan P3-T2 stating that the facade export list stays at 14.
- **Cross-check Member Set:** Get-PlanPaths, Get-BlastRadius, Get-NormalizedDeclaredRadius, Get-BlastRadiusFromObservedPaths, Test-BlastRadius, Test-BlastRadiusConflict, Get-BlastRadiusConflictEdge, Get-BlastRadiusPairDecision, Test-WriteIntentExtractionEnabled, Get-ConfigPathRoot, Get-WriteIntentPlanPath, Get-WriteIntentSpecContract, Select-WriteIntentPathEntry, Get-PlanPathForConfig.
- **Cross-check Count:** 14.
- **Member-set Comparison:** the normalized sets are identical, with 14 members each, the same names, and no duplicates. The Pester pin agrees. After this change the set is these 14 plus `Get-BlastRadiusCombination`, which gives 15.

## 10. Testing Implications (no test code)

New test files:

- **Python:**
  - `test_blast_radius_aggregate.py`: fixture parity, tie-breaks, cascade, and the no-op at tolerance 0.
  - `test_blast_radius_aggregate_properties.py`: exhaustive over a finite domain, following the existing no-`hypothesis` pattern in `test_blast_radius_scheduling_properties.py`; covers the section 2.3 properties.
  - `test_blast_radius_combination.py`: candidates, threshold boundary, components, disabled at tolerance 0 or with the key absent, and `estimated_savings`.
  - `test_blast_radius_combination_threshold.py`: reader cases, the default, and the committed value in both copies.
  - `test_push_down_claude_blast_radius_default_tolerance.py`: AC-01.
  - `test_parallel_issue_combination_contracts.py`: skill, agent, rule, and template fragments; hook-pattern and path absence on the new prompt lines; the absence-of-reader scan for `observed_resolution`.
- **Pester:**
  - `BlastRadiusAggregate.Tests.ps1`: through the facade and `Get-BlastRadiusConflictEdge`, against the shared fixtures.
  - `BlastRadiusCombination.Tests.ps1`: shared fixtures, reader cases, and a parity row that reads `COMBINATION_THRESHOLD_DEFAULT` from the Python source.
  - Both import the facade first and the module second, as `BlastRadiusScheduling.Tests.ps1` documents.
- **Jest:** `blast-radius-default-tolerance.test.ts` (AC-01).

Extended test files:

- `test_validate_parallel_state_tolerated_edge_fields.py` and `parallel-state-tolerated-edge-fields.test.ts`: `observed_resolution`, `combined_issue_nums`, and `combinations`, under the plain and ready gates.
- `enforce-model-routing-receipt.AuthorAsserted.Tests.ps1`: two allow rows.
- `BlastRadius.Tests.ps1`: the count changes to 15.
- The two #1006-overlap files listed in section 1.3.

New fixtures: three aggregate, three combination, one overlay corpus file, and one manifest parity file. All are LF JSON.

Re-run unchanged:

- `test_blast_radius_scheduling.py`, `test_blast_radius_scheduling_properties.py`, `test_blast_radius_historical_runs.py`, `test_blast_radius_write_intent.py`, and `test_parallel_drift_scheduling.py`
- the Pester scheduling, historical-runs, and write-intent suites
- `test_parallel_orchestrator_surface_contracts.py`, `test_parallel_planner_surface_contracts.py`, `test_parallel_issue_adoption_skill_contracts.py`, and `test_parallel_complexity_routing_contracts.py`
- `pr-author-issue-link-contract.Tests.ps1`
- the overlay parity tests (which auto-discover the new corpus file)
- `parallel_manifest_parity.bats` (which auto-discovers the new fixture)

Fail-before evidence:

- AC-02 and AC-06: the new test modules access the new module attributes inside each test, so collection succeeds and each row fails before implementation (the #1006 P1 pattern).
- AC-01: an exception dossier.

## Pre-Mortem

- Review checklists: a reviewer could flag the loss of set-level monotonicity, aggressive combination at committed weights (any two C1 items sharing one non-append-only file give 8*100 >= 1*400, and two C2 items give 800 >= 800), contract-only pairs never combining (cost 0), or an unbounded combined item. Mitigation: state each property, consequence, and residual in the rule text (AC-03, AC-06, decisions D3 to D6); keep `decide_pair`, `conflicts`, `HARD_REASON_KINDS`, the reason enum, the validators, and drift detection unedited, with a scope-check task against the merge base; run a self-review over the three audit templates.
- Coverage: the four new modules and the scheduling post-pass branches (over the cap, tie-breaks, cascade, disabled combination, P6-neutral library) could fall below 85 percent line or 75 percent branch (line only for PowerShell). Mitigation: shared fixtures exercise every branch in both runtimes; per-file baselines and post-change figures come from a dotted `--cov=` JSON report and `artifacts/pester/powershell-coverage.xml`; no production file is excluded.
- Mirror parity: 11 bundle copies, two new `core.json` entries, and the Class 1 `conflict_tolerance` value across two truth tables, three of which are also edited by #1006. Mitigation: copy every bundle file in one scripted task that records SHA-256 pairs; edit both truth tables in one task; run `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, the Class 1 parity tests, the `SOURCE_BLAST_RADIUS` pin, and the Codex generator `--check`. The execution-environment brief states no fact this change alters, so no brief-update task is needed; a scope check confirms the six brief copies are unchanged.
- File size: `_blast_radius_scheduling.py` (495) passes the 500-line guidance tier, and `BlastRadiusScheduling.psm1` (483) reaches it. Mitigation: these two files gain only the optional-member read and the post-pass call (about 20 lines each); all logic goes into the four new modules; line counts are recorded with `wc -l` before and after the change; every new file stays at or below 500 lines and every edited file below 700.
- Test isolation: the new Pester suites re-import the facade with `-Force` and read module script scope for the parity row; the new contract test scans tracked trees. Mitigation: facade-first import order; read script scope without mutating it; tests create no file and read only committed files; seeded shuffled Jest, reversed Python module order, and three-seed shuffled Pester runs plus a fresh single-process `tests/scripts` run, recorded under `evidence/regression-testing/`.
- CI-only behavior: the author-asserted rows run in `poshqc / PowerShell hook suites (Linux)` on a case-sensitive file system; the new manifest fixture runs under bats in `shell-coverage` at clone depth one; the blast-radius Pester suites run in the Windows shards. Mitigation: use `Join-Path` with forward-slash relative paths and exact-case names; no drive letters; LF JSON; no test reads gitignored `artifacts/` state or diffs against `origin/main`; CI dispatch and polling are orchestrator-owned.
- Evidence: AC-01 is already true at the branch base, so fail-before evidence cannot exist; and combination or telemetry behavior inside live agent runs cannot be exercised by an isolated subagent. Mitigation: record a schema-valid `fail-before-exception.<timestamp>.md` with alternative proof; prove the procedure by contract tests, library fixtures, and validator acceptance tests; write every artifact under `<FEATURE>/evidence/<kind>/` with a write-time UTC stamp and `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

## Risks and Open Design Decisions (each with a recommended resolution)

| ID | Decision or risk | Recommended resolution |
|---|---|---|
| D1 | Where the cap runs | Inside `schedule_conflict_edges` and `Get-BlastRadiusConflictEdge` as a post-pass; logic in `_blast_radius_aggregate.py` and `BlastRadiusAggregate.psm1` |
| D2 | Cheapest-to-serialize definition | Key `(benefit asc, cost desc, a asc, b asc)`; repeat on the smallest-key over-cap item until none remains |
| D3 | Set-level monotonicity | Accept the loss; narrow the rule statement to the pairwise decision; pin the five set-level properties of section 2.3 |
| D4 | Meaning of a `same_file` candidate | At least one equal concrete, non-append-only overlapping entry pair after the mergeable exclusion; not a reason member |
| D5 | Contract-only pairs (cost 0) | Keep `pair_cost` unchanged; such pairs do not combine unless the threshold is 0; document it |
| D6 | Chains and size | Union-find components over qualifying pairs; no size cap; one pass, not repeated on combined radii |
| D7 | Combination at tolerance 0 or with the key absent | Disabled, so the strict identity covers the item set |
| D8 | Threshold validation | Optional member, integer of at least 0, booleans rejected, default 400; committed explicitly in both tables |
| D9 | Combined-item realization | Re-plan delegation on the primary branch; path-import the other folders; one combined plan; fresh assessment; secondaries leave `items[]`; `combined_issue_nums` recorded |
| D10 | Run falls below two items | Apply no combination; report each qualifying pair with the P6 reason |
| D11 | Estimated savings | Sum of qualifying pair costs (cost units), reported beside benefit and threshold |
| D12 | Telemetry location | `tolerated_overlaps[].observed_resolution` (checkpoint) plus `## Tolerated Overlaps` in `parallel-status.md` (durable); non-exclusive attribution |
| D13 | Autoclose for two issues | No hook change; the skill wording lists several numbers; two pinning Pester rows |
| D14 | Stale "three token shapes" sentence in `parallel-plan` (noted by #1006) | Correct it in this item, since the file is edited anyway, to the post-#1006 count read from the merged rule |
| D15 | Drift detection | Unchanged and pairwise; recorded as a scope boundary |
| R1 | #1006 not merged or branch not rebased | Phase 0 gate on the section 0.3 observables and an ancestry check |
| R2 | Hook target resolution confused by combination prompts | No `docs/features/active/` path and no hook issue-number shape on new lines; pinned by contract test |
| R3 | Installed-extension lag | Destinations and MCP validators see the change only after release, rebuild, and reinstall; proven by in-memory tests only |
| R4 | Combined PR review size and a three-attempt remediation budget shared across both scopes | Documented as an accepted trade; the threshold is destination-tunable |

## Automation Feasibility

No step needs human interaction. Every step is automatable:

- the library code, fixtures, and tests
- the skill, agent, rule, and template text
- the bundle copies through a `SCRATCH` copy script
- the toolchain and isolation runs through the routes in the execution-environment brief

Orchestrator-owned, non-interactive steps:

- the Phase 0 check that #1006 merged, and the rebase
- selecting the `large` route
- CI dispatch and polling

No live push-down or destination run is needed, because destination behavior is proven by in-memory push tests.

## Complete File List

Every file this feature writes. (new) marks a new file; `[#1006]` marks a file also in #1006's list. Feature-folder documents and evidence files are excluded.

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

Files deliberately not written:

- `scripts/dev_tools/compute_blast_radius.py` (the combination library is cited directly, so this #1006 file is not touched)
- `_parallel_drift_scheduling.py`
- every validator module in Python, TypeScript, and bash
- `.claude/hooks/enforce-model-routing-receipt.ps1`
- the `.agents/` and `.github/` copies of `pr-author` and `orchestrate`
- the six execution-environment brief copies
- `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`
- `quality-tiers.yml`
