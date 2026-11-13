# Research: Parallel planner time-based edge rule (Issue #1164)

- Issue: #1164
- Branch: feature/parallel-planner-time-based-edge-rule-1164
- Work Mode: full-feature
- Requirements source: `docs/features/active/parallel-planner-time-based-edge-rule-1164/issue.md`
- Owner directive OD-1164-1: "I want maximum parallelization. Therefore, features should be run sequentially if and only if the time lost to merge is greater than the time gained through parallel execution." Changing the default scheduling behaviour is intended.
- Timestamp note: the filename stamp `2026-11-09T22-15` was not read from a clock. The `task-researcher` route has no Bash or clock tool (execution-environment brief, `## Tool Routes by Agent`); the value is bounded below by the intake plan stamp `plan.2026-11-09T16-56.md` (America/New_York, 21:56Z). The orchestrator may rename the file to a clock-read stamp without content change.

All citations name files, symbols, headings, and test names. No line numbers or commit identifiers are used.

## 1. Current State: the edge rule and its implementations

### 1.1 Where the rule lives

The cost/benefit edge rule is implemented twice, with a shared fixture corpus binding them:

| Runtime | File | Symbols | Role |
| --- | --- | --- | --- |
| Python (repository reference) | `scripts/dev_tools/_blast_radius_scheduling.py` | `config_conflict_tolerance`, `pair_cost`, `pair_benefit`, `decide_pair`, `schedule_conflict_edges`, `_path_pair_weight`, `_read_int_map`, `STRICT_CONFLICT_TOLERANCE`, `COMBINATION_THRESHOLD_DEFAULT` | Reference implementation; re-exported by `scripts/dev_tools/compute_blast_radius.py` |
| Python | `scripts/dev_tools/_blast_radius_aggregate.py` | `select_capped_pairs` | Aggregate cap post-pass (issue #1013) |
| Python | `scripts/dev_tools/_blast_radius_combination.py` | `find_combinations`, `has_same_file_overlap` | Issue combination (planning time) |
| Python | `scripts/dev_tools/_parallel_drift_scheduling.py` | drift re-evaluation through the same rule | Drift path |
| PowerShell (destination runtime, pushed down) | `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` | `Get-ConfigConflictTolerance`, `Get-PathPairWeight`, `Get-BlastRadiusPairCost`, `Get-BlastRadiusPairBenefit`, `Get-BlastRadiusPairDecision`, `Get-BlastRadiusConflictEdge` | Port; the skills call this |
| PowerShell | `.claude/lib/blast-radius/BlastRadiusAggregate.psm1` | `Get-AggregateCappedPair` | Port of the cap |
| PowerShell | `.claude/lib/blast-radius/BlastRadiusCombination.psm1` | `Get-BlastRadiusCombination` | Port of combination |
| PowerShell | `.claude/lib/parallel-drift/ParallelDrift.psm1` | drift pair evaluation | Drift path |

The rule in both runtimes (`Get-BlastRadiusPairDecision` / `decide_pair`): edge iff conflict AND (hard OR `tolerance_percent == 0` OR `cost * 100 > benefit * tolerance_percent`). Hard means the relation's reasons include `shared_surface_overlap` or `contract_dependency` (`$script:HardReasonKind`). Cost (`Get-BlastRadiusPairCost`) sums, over the overlapping entry pairs enumerated by `Get-OverlappingPathPair` after the `mergeable_paths` exclusion, `append_only` (a concrete entry matching `append_only_paths`, checked first), else `same_file` (two equal concrete entries), else `possible_overlap`; then adds `module` times shared modules and `contract` times distinct shared contract identifiers. Benefit (`Get-BlastRadiusPairBenefit`) is the minimum of the two items' band durations, a missing band reading as `default_band`.

There is no bash, TypeScript, or MCP implementation of the rule. `.claude/lib/bash/compute-cohorts.sh` (`cc_main`, sourcing `parallel-cohorts.sh`) only colors a supplied edge list; it has no cost or benefit input. TypeScript touches the rule only through configuration carriage: `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` (`CARRIED_KEYS` includes `conflict_tolerance`, carried whole) and the overlay composer `claude-blast-radius-overlay.ts` / `claude-blast-radius-overlay-demote.ts`.

### 1.2 Parity binding

- Shared scheduling corpus: `tests/fixtures/blast_radius/scheduling/*.json` (5 stems), `tests/fixtures/blast_radius/aggregate/*.json` (3), `tests/fixtures/blast_radius/combination/*.json` (4), `tests/fixtures/blast_radius/historical-runs/*.json` (3). Each fixture embeds its own `config`, so the committed config values do not flow into the corpus.
- The scheduling stems are listed by name in both drivers: the tuple in `tests/scripts/dev_tools/test_blast_radius_scheduling.py` and the array in `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1`. A new fixture must be added to both lists.
- `test_blast_radius_scheduling.py` compares whole records: `[e.to_dict() for e in result.edges] == case["expected_edges"]`. Adding a key to the engine's edge or tolerated record breaks every fixture case. This constrains the design (section 4).

### 1.3 Configuration: definition, reading, override

- Definition: `config/blast-radius.json` `conflict_tolerance` = `tolerance_percent` 100; `weights` `same_file` 8, `possible_overlap` 2, `append_only` 1, `module` 2, `contract` 8; `band_durations` C1 1, C2 2, C3 4, C4 8; `default_band` C1; `append_only_paths` [`**/CHANGELOG.md`, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `quality-tiers.yml`]; `combination_threshold_percent` 400.
- Bundled copy: `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` carries a byte-equal `conflict_tolerance` (the rule `## Blast-Radius Contention Doctrine (issue #489)` lists `conflict_tolerance` among the byte-equal keys; `BlastRadius.KeyPartition.Tests.ps1` `$script:ClassOneKeys` and `tests/scripts/dev_tools/test_blast_radius_config_parity.py` enforce it). Both copies must change together.
- Reader validation: exact member names (`Assert-ExactMemberName`; Python `_require_names`), every weight and band an integer of at least 1 (`Get-RequiredIntegerMap` with `-Minimum 1`; Python `_read_int_map`), booleans rejected; `combination_threshold_percent` is the only optional member. Absent key = strict scheduling (tolerance 0, unit weights).
- Destination override: `config/blast-radius.local.json` composed at push time; `conflict_tolerance` merges recursively (nested objects per member, scalars overlay-wins), per the rule paragraph beginning "A destination records its own entries in `config/blast-radius.local.json` (issue #508)". An overlay that overrides an existing member keeps working after recalibration; a new optional member present only in the base passes through.
- No JSON Schema file exists for `conflict_tolerance` (the rule states enforcement is never an imported schema).

### 1.4 Tests that assert current values or current outcomes

Tests reading the committed values (must change with recalibration):

| Test | Asserted values |
| --- | --- |
| `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py` `COMMITTED_CONFLICT_TOLERANCE`, `test_committed_conflict_tolerance_values`, `test_committed_conflict_tolerance_reads_cleanly` (both copies) | tolerance 100; weights 8/2/1/2/8; bands 1/2/4/8; default C1; the three append-only paths; threshold 400 |
| `tests/scripts/dev_tools/test_parallel_issue_combination_contracts.py` `test_rule_documents_the_contract_weight` | rule text "module, and contract, each an integer of at least 1", "its committed value is 8" |
| `tests/scripts/dev_tools/test_parallel_issue_combination_contracts.py` `test_rule_declares_the_tolerated_telemetry_fields` | "tolerated and not validated" in the `### Integration-cost scheduling (issue #722)` subsection (affected only if that sentence is reworded) |

Tests that pin values that stay unchanged under the recommendation (no edit needed, re-run as regression): `tests/scripts/dev_tools/test_push_down_claude_blast_radius_default_tolerance.py` and `extensions/drm-copilot/test/lib/push-down/blast-radius-default-tolerance.test.ts` (tolerance 100, threshold 400); `test_blast_radius_config_parity.py` and `BlastRadius.KeyPartition.Tests.ps1` (byte equality, kept by editing both copies); `BlastRadius.TruthTable.Tests.ps1` (`quality-tiers.yml` in `append_only_paths`).

Tests that carry their own literal configs with the old numbers (unaffected; they do not read the committed file): `BlastRadiusScheduling.Tests.ps1`, `BlastRadiusScheduling.PairCost.Tests.ps1`, `BlastRadiusScheduling.ContractWeight.Tests.ps1`, `BlastRadiusCombination.Tests.ps1`, `BlastRadius.HistoricalRuns.Tests.ps1`, `test_blast_radius_contract_weight.py`, `test_blast_radius_historical_runs.py` (`ZERO_TOLERANCE`), `blast-radius-derive-tolerance-keys.test.ts`, and the fixture corpora above. They stay valid only if every new member is optional (section 4).

Tests affected by the recording change (section 4): `tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py` and `extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts`. Their last case places pair (444, 445) in both `conflict_edges` and `tolerated_overlaps` and expects exactly one error; a new "pair in both lists" check adds a second error. `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1` pins the `record` output byte-exactly against `tests/fixtures/parallel_admission/seed-scheduling-record.json`.

## 2. Overlap classes and detection

Detection (`Test-BlastRadiusConflict` / `conflicts`) reports four reason kinds (`conflict_edges[].reason` enum in the rule's `## Enum Ownership` table): `path_overlap`, `module_overlap`, `shared_surface_overlap`, `contract_dependency`. Scheduling sub-classifies `path_overlap` pairs into `append_only`, `same_file`, `possible_overlap` (`Get-PathPairWeight`). `mergeable_paths` matches are excluded before detection.

| Issue time class | Current mechanism | Can detection distinguish it today? |
| --- | --- | --- |
| Read-only on one side (0) | Only indirectly: write-intent rules W1-W6 and `mandate_reads` drop some read citations at derivation. Every surviving radius entry is treated as a write. | No. Run `bug-burndown-2026-10-11` (`docs/features/parallel/bug-burndown-2026-10-11/parallel.md`, `## Scheduling (generation 0)`) shows 21 of 25 derived edges were "read or run" on at least one side and had to be reclassified by hand. W3's read-verb set has no `Run`, so tests cited in run tasks survive. |
| Append-only / regenerated / separable docs-section writes (minutes) | `append_only_paths` (configured list) only | Partly: only for listed files. Bundled mirrors under `extensions/drm-copilot/resources/**` are counted as a second `same_file`. Separable sections of one file are indistinguishable from same-function edits. |
| Possible overlap (small) | `possible_overlap` (glob or directory-prefix overlap), `module` | Yes |
| Same function or rule on both sides (one remediation pass) | `same_file` | Only as the fail-closed default for equal concrete entries |
| Hard | `shared_surface_overlap`, `contract_dependency` | Yes |

Minimal host-neutral extension, without narrowing any radius: two optional per-item access declarations that sit beside the six-key `blast_radius` block (not inside it, because `BlastRadius.from_dict` rejects unexpected keys):

- `read_paths`: radius path entries the item only reads or runs. A path pair where either side's entry is in that side's `read_paths` contributes 0.
- `separable_paths`: radius path entries the item writes only by appending, regenerating, or editing a section the plan names. A pair where both sides list the entry contributes the new optional `separable` weight.

The radius stays complete, detection is unchanged (the pair is still a detected conflict and is recorded as a tolerated overlap with its estimates), and absence of both lists reproduces today's cost exactly (fail closed). The bundled mirror tree is handled by adding `extensions/drm-copilot/resources/**` to `append_only_paths` (regenerated from source; a conflict there is resolved by regeneration).

Safety net: drift detection must treat an observed write to a path the item declared in `read_paths` as an escape, so a wrong read-only declaration is caught the same way an undeclared write is (`ParallelDrift.psm1`, `scripts/dev_tools/parallel_drift_detection.py`, `_parallel_drift_scheduling.py`). Drift re-evaluation must also pass the peers' declared access lists, otherwise a pair tolerated at cost 0 at seeding is re-priced as a write and reported as newly conflicting.

Declaration source: a deterministic PowerShell helper derives `read_paths` from the approved plan (a radius path is read-only when every task window naming it has a first title word in {Read, Verify, Confirm, Inspect, Review, Baseline, Run, Execute} and no write verb, and the plan does not create it). `separable_paths` is planner-declared with a one-line rationale per path, because section separability is not statically decidable from plan text.

## 3. Recalibration in time units

### 3.1 Unit

Both estimates are expressed in minutes. The readers require integers, and the issue's "minutes" classes cannot be expressed as integer hours. Minutes keep the integer-only arithmetic (`cost * 100 > benefit * tolerance_percent`) and every existing validator unchanged. This is recorded for owner review (decision D1).

### 3.2 Measured data

Item execution-phase duration (execution start to merge), run `bug-burndown-2026-10-11` (`parallel-status.md` `worktree_created_at` to `merged_at`; bands from `parallel-kickoff.md`):

- C2 (n=8): 543 58 min, 884 50, 885 33, 886 43, 892 31, 894 34, 895 41, 898 30. Median 37.5, mean 40.0.
- C3 (n=6, excluding #901 and #903, which spanned multi-day pauses): 887 76, 889 73, 890 76, 899 186, 900 60, 902 44. Median 74.5, mean 85.8.

Full-feature stage timings (`docs/features/active/*/evidence/other/stage-timing.*.json`), execution start to CI end where recorded: #1105 205 min, #1153 215 min; open-ended lower bounds #1139 138+, #1130 114+, #1127 104+, #1136 72+, #1106 61+. Bands for these items are not committed (checkpoints are gitignored).

One remediation pass: #1105 113 min, #1139 40, #1153 53, #1130 5 (+3.5 re-review); median about 47 min. CI pass: #1105 17 min, #1153 63, #1009 about 25 (agent memory `parallel-run-facts-2026-10-30`). Run `bugs-1001-1002-1003-1006`: 33 edges, all `path_overlap`, simulated about 20 h at tolerance 100 versus 8-11 h at 1600-5000 (same memory note). Run `bug-burndown-2026-10-11` tolerated all 25 derived edges by hand and its `## Mergeable Conflicts Resolved` table is empty: no tolerated pair produced a recorded merge conflict.

### 3.3 Definition of gain

Gain for a pair is the shorter of the two band durations (unchanged `pair_benefit`). Justification against the scheduler: an edge separates the pair into different cohorts, and the per-edge barrier starts the later item only after the earlier one merges, so the pair's wall time is `dA + dB` serial versus `max(dA, dB)` concurrent; the difference is `min(dA, dB)`. The figure is an upper bound when `max_concurrency` is already saturated; this is accepted for simplicity and recorded (decision D4).

Merge time for a pair is the summed overlap-class weights (unchanged `pair_cost` shape). The later-merging item's routine merge of `origin/main` and CI re-pass, which the skills require for every tolerated pair, is treated as a per-item cost paid at most once, not as a per-pair weight (decision D3).

### 3.4 Proposed committed values (minutes)

| Member | Current | Proposed | Basis |
| --- | --- | --- | --- |
| `tolerance_percent` | 100 | 100 | 100 now means exactly "edge iff merge time > gain" |
| `band_durations.C1` | 1 | 30 | Below the C2 median |
| `band_durations.C2` | 2 | 45 | C2 median 37.5, mean 40 |
| `band_durations.C3` | 4 | 90 | C3 mean 85.8 |
| `band_durations.C4` | 8 | 180 | Twice C3; largest measured items 205-215 |
| `default_band` | C1 | C1 | Unchanged; smallest gain, so the fail-closed direction |
| `weights.same_file` | 8 | 90 | One remediation pass (median about 47) plus one CI pass (25-63) |
| `weights.contract` | 8 | 90 | Same order as a same-function edit; hard class, so it changes recorded cost and combination eligibility only |
| `weights.possible_overlap` | 2 | 20 | Small: glob or directory-prefix overlap |
| `weights.module` | 2 | 10 | Same module, no shared file |
| `weights.append_only` | 1 | 10 | Minutes: union merge or regeneration |
| `weights.separable` (new, optional) | absent | 15 | Section-separable writes on both sides |
| read-only on either side | n/a | 0 (fixed) | Owner class "read-only on one side: 0" |
| `append_only_paths` | 3 entries | add `extensions/drm-copilot/resources/**` | Regenerated bundle mirrors |
| `combination_threshold_percent` | 400 | 400 | Ratio semantics unchanged |

Resulting verdicts at the defaults (each is a required unit-test case): read-only one side, any bands: cost 0, tolerated. Append-only, C2 with C2: 10 against 45, tolerated. Separable same file, C2 with C2: 15 against 45, tolerated. Same file written by both (same function or rule), C2 with C2: 90 > 45, edge; C3 with C3: 90 against 90, tolerated (equality runs in parallel, since the rule is strictly greater); C1 with C4: 90 > 30, edge. Hard class: edge at every tolerance, with both estimates recorded. The two observed pairs of run `bug-burndown-2026-10-11` classified as separable writes (885:890 and 890:899) price at 25 (15 + 10 for the mirror) against gains of 45 and 90 and stay tolerated, matching the manual decision.

The aggregate cap (`Get-AggregateCappedPair` / `select_capped_pairs`) is kept: in minutes it promotes an item's cheapest-to-serialize overlap when the item's summed tolerated merge time exceeds its own duration, which is the per-item reading of the same rule (decision D5).

## 4. Recording of per-pair estimates and verdicts

Current writes and validation:

- Planner checkpoint `artifacts/orchestration/parallel-planner-state.json` and orchestrator checkpoint `artifacts/orchestration/parallel-orchestrator-state.json`: `conflict_edges[]` entries may carry `hard`, `cost`, `benefit`, and `tolerated_overlaps[]` entries carry `reasons`, `cost`, `benefit`. Both are declared tolerated-not-validated (rule `## Enum Ownership`, closing paragraph). Validators: `scripts/dev_tools/validate_parallel_planner_state.py`, `scripts/dev_tools/validate_parallel_orchestrator_state.py`, helpers `_parallel_state_structures.py` (`validate_conflict_edges`, `_validate_edge_endpoints`), `_parallel_state_records.py`, `_parallel_state_common.py`; TypeScript port `extensions/drm-copilot/src/lib/validate/parallel-state-structures.ts`, `parallel-state-records.ts`, `parallel-planner-state-core.ts`, `parallel-orchestrator-state-core.ts`, dispatched from `orchestration-artifacts.ts`. CLI: `scripts/dev_tools/validate_orchestration_artifacts.py` subcommands `parallel-planner-state` and `parallel-orchestrator-state`.
- Run manifest `docs/features/parallel/<slug>/parallel.md`: frontmatter M1-M8, validated by `scripts/dev_tools/parallel_manifest_contract.py` (authority) and `.claude/lib/bash/parallel-manifest-validate.sh` via `validate-parallel-manifest.sh`, with the shared corpus `tests/fixtures/parallel_manifest_bash/*.json`. Unknown keys are tolerated by both. M8 (`_validate_expected_conflict_components` / `pm_validate_expected_components`) is the key-gated precedent.
- Durable scheduling record `docs/features/parallel/<slug>/parallel-scheduling.json`: built by `New-ParallelSchedulingRecord` in `.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1`; edges are projected to `a`, `b`, `reason` only, so cost and benefit of edges are dropped today; tolerated overlaps keep `cost` and `benefit`.

Proposed record shape (all additions optional, so older checkpoints, manifests, and records stay valid):

1. Checkpoints: keep the engine's records unchanged (`conflict_edges[]` `{a, b, reason, hard, cost, benefit}`; `tolerated_overlaps[]` `{a, b, reasons, cost, benefit}`). The verdict is list membership. `cost` is the merge-time estimate and `benefit` the gain estimate, in minutes. Validators move these from tolerated to checked-when-present: `hard` boolean; `cost`, `benefit` non-negative integers (booleans rejected); `tolerated_overlaps` a list of objects with resolvable, distinct, normalized endpoints, `reasons` a non-empty list from the four-member enum, no hard reason, and no pair present in both lists. Items may carry `read_paths` and `separable_paths` (lists of non-empty strings, each a member of `blast_radius.paths`).
2. Manifest: new key-gated invariant M9 `pair_decisions[]`, a block sequence of `{a, b, reasons, hard, cost, benefit, verdict}` with `verdict` in {`edge`, `tolerated`}; checks: endpoints resolve to items with `a < b`, no duplicate pair, integers non-negative, `hard: true` requires `verdict: edge`. Written by the planner at seeding. The orchestrator keeps the manifest read-only, so admissions by `/parallel-add` are recorded in the checkpoint and the durable record only (decision D6).
3. Durable record: the edge projection gains `hard`, `cost`, `benefit`, and precedence gains `kind`, `reason`, each emitted only when present on the input, so an input without them produces byte-identical output (the `seed-scheduling-record.json` pin stays valid).

Engine output keys are not changed, because `test_blast_radius_scheduling.py` and the PowerShell driver compare whole records against the fixture corpus.

New validator rules apply through `mcp__drm-copilot__validate_orchestration_artifacts` only after the extension release that carries the TypeScript port; until then the installed MCP accepts the fields as tolerated, and branch-current validation runs the Python CLI (execution-environment brief, `## MCP Surfaces Run the Installed Extension`). The rule text and the PR must state this.

## 5. Precedence flags (`--after`)

Current handling:

- `/parallel-plan`: argument hint `--after <later>:<earlier>`; `## Item Intake` `**Precedence input.**` records each flag as `precedence[]` `{before, after, source: operator, recorded_at}`; `### Seeding procedure` step 1 adds each pair as a separating edge and calls `order-cohorts`.
- `/parallel-add`: argument hint `--after <earlier>`; `## Procedure` step 3 records the entry; steps 4 and 5 force `defer_and_recolor` and run `order-cohorts` / `test-cohorts`.
- Helper `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` (subcommands `guard-run`, `assess`, `order-cohorts`, `test-cohorts`, `record`, `reuse-edges`; rejection codes `$script:AdmissionRejectionCode` = `run_closed`, `precedence_cycle`, `precedence_unknown_item`, `precedence_violated`); pure functions in `ParallelAdmissionPrecedence.psm1` (`Get-ParallelPrecedencePair`, `Test-ParallelPrecedenceInput`, `ConvertTo-ParallelPrecedenceEdge`, `Invoke-ParallelPrecedenceLift`, `Get-ParallelActivePrecedence`, `Test-ParallelPrecedenceCohortTable`).
- `mutate-parallel-run.sh`, `compute-cohorts.sh`, and the agents have no `--after` parsing; precedence reaches them only as extra edges. No precedence entry is tested against cost and benefit today.

Proposal:

- Syntax: `--after <later>:<earlier> [--reason "<text>"]` for `/parallel-plan` and `--after <earlier> [--reason "<text>"]` for `/parallel-add`. A `--reason` binds to the immediately preceding `--after`. With a reason the entry records `kind: "correctness"` and `reason`; without one it records `kind: "cost"`. A planner-proposed ordering is recorded the same way with `source: "planner"`.
- Test: after the scheduling entry point returns, a new helper subcommand `test-precedence -Entry <json carrying precedence, edges, tolerated_overlaps>` checks each `kind: "cost"` entry: it is accepted only when its unordered pair is a returned edge (hard, or merge time > gain). Otherwise it exits 1 with `PARALLEL_ADMISSION_REJECTED: precedence_not_justified: --after <later>:<earlier> fails the parallel scheduling rule (merge time <cost> min does not exceed parallel gain <benefit> min); add --reason "<text>" to record a correctness ordering`. A `kind: "correctness"` entry requires a non-empty reason. The subcommand runs through the existing Bash grant `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1*` of `parallel-planner`, so no agent `tools:` change is needed.
- Back-compat: an entry without `kind` is a legacy entry; it is honoured unchanged by `order-cohorts`, `test-cohorts`, `Get-ParallelActivePrecedence`, and the cohort-barrier hook, and is not re-tested. Validators accept absent `kind` and `reason`.
- The new code `precedence_not_justified` joins the admission signal set in `$script:AdmissionRejectionCode`, the helper `.DESCRIPTION`, and the rule paragraph `**Admission output signal.**`; the mutation rejection code set of `## Mutation Rejection Signal (issue #1012)` is unchanged.

## 6. Surfaces to edit

Rule-text surfaces (AC1): see `## Numeric Derivation Evidence`. Six Claude source files plus six bundled mirrors; no Copilot (`.github/`), `.agents/`, or `.codex/` parallel surface exists (searches for `parallel-plan|parallel-planner` under those trees match only `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, which is not a planning surface). `.claude/skills/parallel-orchestrate/SKILL.md` and its mirror are also edited, because `/parallel-run` executes that procedure and it restates the tolerated-pair merge rule and precedence handling.

Placement:

- `.claude/rules/parallel-orchestration.md`: `### Integration-cost scheduling (issue #722)` (`**Configuration.**`, `**Edge rule.**`, `**Strict-identity proof.**` wording on weights of at least 1, `**Soft-overlap handling.**`), the tolerated-fields paragraph closing `## Enum Ownership`, `## Prepared-Item Admission (issue #1047)` (`**Precedence input.**`, `**Durable scheduling record.**`, `**Admission output signal.**`), and the manifest invariant list (M9).
- `.claude/skills/parallel-plan/SKILL.md`: `## Item Intake` `**Precedence input.**`, `## Radius Computation and Validation` `### Planner procedure` (access declarations), `### Seeding procedure` steps 1, 4, 7, `## Manifest Authoring` (M9), `## Checkpoint Persistence`.
- `.claude/skills/parallel-add/SKILL.md`: argument hint, `## Procedure` step 3, `## Constraints` (the sentence "A `conflict_edges[]` entry may carry only the three tolerated extra fields ... (tolerated-not-validated ...)" becomes false).
- `.claude/skills/parallel-run/SKILL.md`: `## Scope` (one statement of the rule).
- `.claude/agents/parallel-planner.md`: `## Delegation Model`, `## Checkpoint Persistence`, `## Completion Requirements`, `## Upstream Library Invocation`.
- `.claude/agents/parallel-orchestrator.md`: `## Cohort Scheduling`, `## Checkpoint Persistence`.

Code and configuration: `config/blast-radius.json` and its bundled copy; `BlastRadiusScheduling.psm1` (reader optional `separable`, item access lists) or a new sibling module; `_blast_radius_scheduling.py` extended in place; drift (`ParallelDrift.psm1`, `_parallel_drift_scheduling.py`, `parallel_drift_detection.py`); `ParallelAdmissionPrecedence.psm1` projection; `Invoke-ParallelAdmission.ps1` subcommand wiring; new PowerShell module(s) under `.claude/lib/parallel-admission/` and `.claude/lib/blast-radius/`; Python validators (`_parallel_state_records.py`, `parallel_manifest_contract.py`); bash `parallel-manifest-validate.sh` (or a new sourced file); TypeScript `parallel-state-records.ts` and callers. Every changed or new file under `.claude/` has a bundled copy under `extensions/drm-copilot/resources/claude-customizations/.claude/`, and every new file needs an entry in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (`test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py` for the `$PSScriptRoot` import).

Pins checked:

- `PINNED_FROZEN_SURFACE_HASHES` (`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`) pins only `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`; neither is edited.
- `scripts/dev_tools/generate_codex_agent_variants.py` contains no reference to the parallel agents; no Codex variant regeneration.
- Wording contract tests that read the edited files: `test_parallel_issue_combination_contracts.py` (pins listed in 1.4, plus section-heading order in the plan skill and agent sections), `test_parallel_planner_surface_contracts.py`, `test_parallel_planner_surface_contracts_landed.py`, `test_parallel_orchestrator_surface_contracts.py`, `test_parallel_issue_adoption_skill_contracts.py`, `test_parallel_complexity_routing_contracts.py`, `test_parallel_mutation_rejection_signal_contracts.py`, `test_parallel_planner_no_scratch_worktree_contracts.py`, `test_claude_rules_frontmatter.py`, `tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1`, plus the mirror contracts `test_push_down_claude_resource_contracts.py`. Each must be re-run; only the `test_parallel_issue_combination_contracts.py` assertions in 1.4 are known to need edits.
- A new wording contract test pins one shared sentence in all twelve rule-text files (recommended: `tests/scripts/claude-runtime/parallel-scheduling-rule-wording.Tests.ps1`).
- Execution-environment brief: it states no fact about blast-radius weights, bands, tolerance, or precedence flags, so no brief update is required. Adding the new wording test to its `## Contract Tests That Pin Mirrored Files` list is optional and would touch six byte-identical copies (decision D8).

## 7. Concurrency with run harness-learnings-2026-11-09

The run manifest and scheduling record for `harness-learnings-2026-11-09` are not present on this branch (`docs/features/parallel/` holds eleven older runs only), and the research route cannot run `git show`. The item branches, read from git worktree metadata, are: #1156 `feature/regenerate-after-integration-merge-1156`, #1157 `feature/owner-directive-pass-down-1157`, #1158 `feature/test-execution-policy-machine-lock-1158`, #1159 `feature/hook-dispatcher-process-cost-1159`, #1160 `bug/preimplementation-gate-false-positives-1160`, #1161 `feature/planner-worktree-removal-authorization-1161`, #1162 `feature/cross-epic-dependencies-1162`, #1163 `bug/hook-session-root-resolution-1163`.

ORCHESTRATOR TO CONFIRM: `git fetch origin parallel/harness-learnings-2026-11-09-plan` then `git show origin/parallel/harness-learnings-2026-11-09-plan:docs/features/parallel/harness-learnings-2026-11-09/parallel.md`, and intersect each item's `blast_radius.paths` with the file list in section 6.

Likely overlaps by title only (unverified): #1161 (planner worktree removal) is likely to edit `.claude/skills/parallel-plan/SKILL.md` (`## Artifact Home`), `.claude/agents/parallel-planner.md`, `.claude/rules/parallel-orchestration.md` (`## Enforcement`), and their mirrors; #1157 (owner-directive pass-down) is likely to edit delegation-prompt text in `parallel-plan`, `parallel-orchestrate`, and the parallel agents; #1162 (cross-epic dependencies) may touch ordering or precedence wording. The hook items (#1159, #1160, #1163) and #1158 are unlikely to touch the files above, but #1159 and #1163 may edit the execution-environment brief, which this item does not need to change. Mitigation: this item's Markdown edits are section-local additions (separable writes); merge `origin/main` with a plain merge before the PR; do not modify that run's run folder.

## 8. Language and module placement

- PowerShell (pushed down): put the new pure logic in new modules so the near-limit files do not grow: `.claude/lib/blast-radius/BlastRadiusAccess.psm1` (access-aware path-pair weight and read-only derivation from plan text; pure, injected text input) and `.claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1` (`Test-ParallelPrecedenceJustified`; pure, takes entries and engine records). `BlastRadiusScheduling.psm1` imports the access module and its reader gains the optional `separable` weight and the optional item lists. `Invoke-ParallelAdmission.ps1` gains thin `test-precedence` and `access-paths` subcommands that reuse its existing git and file seams.
- Python: extend `_blast_radius_scheduling.py`, `_parallel_drift_scheduling.py`, `_parallel_state_records.py`, and `parallel_manifest_contract.py` in place; no new Python file. The read-only derivation helper is PowerShell-only, like the existing admission modules, because the planner path is PowerShell and no Python caller exists.
- bash: M9 in a new sourced file (for example `.claude/lib/bash/parallel-manifest-pairs.sh`) keeps `parallel-manifest-validate.sh` small.
- TypeScript: validator port only (`parallel-state-records.ts`); a new TypeScript production file would need its own `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs`, so extend existing files.
- Binding tests: the scheduling corpus (new fixtures with `read_paths`, `separable_paths`, and the committed minute values for the five AC2 classes, added to both stem lists), the drift corpus `tests/fixtures/parallel_drift/*.json`, the manifest corpus `tests/fixtures/parallel_manifest_bash/*.json` (M9 cases), and the Python/TypeScript validator parity cases.

## 9. File-size risk

Logical line counts read on this branch (ripgrep line count; Markdown is exempt). No listed file appears in `config/file-size-baseline.json`.

| File | Lines | Tier status and guidance |
| --- | --- | --- |
| `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | 626 | Above 500. Keep additions to thin wiring (about 40 lines); stays below 700 |
| `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` | 530 | Above 500. New logic goes to `BlastRadiusAccess.psm1` |
| `.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1` | 508 | Above 500. Only the projection change here; gate logic in a new module |
| `.claude/lib/parallel-admission/ParallelAdmission.psm1` | 508 | Not edited |
| `scripts/dev_tools/_blast_radius_scheduling.py` | 561 | Above 500; in-place growth of about 50 lines expected; below 700 |
| `scripts/dev_tools/parallel_manifest_contract.py` | 469 | Reaches about 540 with M9; guidance tier only |
| `scripts/dev_tools/_parallel_state_structures.py` | 496 | Do not extend; put the new checks in `_parallel_state_records.py` (324) |
| `scripts/dev_tools/_parallel_state_common.py` | 495 | Do not extend beyond constants |
| `scripts/dev_tools/validate_parallel_planner_state.py` | 461 | One call site only |
| `.claude/lib/parallel-drift/ParallelDrift.psm1` | 467 | About 500 after access carriage; split the escape check into a helper if it crosses 500 |
| `.claude/lib/bash/parallel-manifest-validate.sh` | 299 | Keep M9 in a new sourced file |
| `extensions/drm-copilot/src/lib/validate/parallel-state-structures.ts` | 496 | Do not extend; use `parallel-state-records.ts` (347) |
| `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1` | 695 | Near 700. New cases go in a new test file |
| `tests/scripts/dev_tools/test_parallel_manifest_contract.py` | 497 | New M9 cases in a new test file or `test_parallel_manifest_contract_m8.py` (400) |
| `tests/scripts/dev_tools/test_validate_parallel_planner_state.py` | 462 | New cases in a new test file |
| `tests/scripts/dev_tools/test_blast_radius_scheduling.py` | 442 | Fixture-driven; stem list only |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1` | 372 | Stem list only |

## Numeric Derivation Evidence

### Claim N1: the rule text must appear in 6 Claude source files and 6 bundled mirrors (12 files); 0 Copilot, `.agents`, or `.codex` parallel surfaces exist

- Complete Family: the surfaces AC1 names (parallel-plan, parallel-add, and parallel-run skills; parallel-planner and parallel-orchestrator agents; the parallel-orchestration rule), on every runtime surface where they exist (Claude source, bundled mirror, Copilot, `.agents`, `.codex`).
- Exhaustive Search Scope: the whole worktree, all five surface roots (`.claude/`, `extensions/drm-copilot/resources/claude-customizations/.claude/`, `.github/`, `.agents/`, `.codex/`).
- Inclusion Rules: a file whose path is the skill, agent, or rule named by AC1 on any surface.
- Exclusion Rules: `parallel-orchestrate`, `parallel-close`, and `parallel-remove` skills (not named by AC1; `parallel-orchestrate` is edited as an addition and not counted); `docs/**`.
- Primary Search Strategy or Query Expression: Glob `**/parallel-*/SKILL.md`; Glob `extensions/drm-copilot/resources/claude-customizations/.claude/{agents/parallel-*.md,rules/parallel-orchestration.md}`; Glob `{.github,.agents,.codex,.claude}/**/*parallel*`.
- Primary Member Set: `.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-add/SKILL.md`, `.claude/skills/parallel-run/SKILL.md`, `.claude/agents/parallel-planner.md`, `.claude/agents/parallel-orchestrator.md`, `.claude/rules/parallel-orchestration.md`; mirrors of the same six under `extensions/drm-copilot/resources/claude-customizations/`; no file under `.github/`, `.agents/`, or `.codex/`.
- Primary Count: 6 source + 6 mirrors = 12; other surfaces 0.
- Cross-check Search Strategy or Query Expression: Grep of `extensions/drm-copilot/resources/claude-customizations/pack-manifests/` for `parallel-plan|parallel-planner|parallel-orchestration` and for `parallel-(add|run|orchestrator|orchestrate)\b`; Grep of `{.github/**,.agents/**,.codex/**}` for `parallel-plan|parallel-planner`.
- Cross-check Member Set: `core.json` entries `.claude/agents/parallel-planner.md`, `.claude/agents/parallel-orchestrator.md`, `.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-add/SKILL.md`, `.claude/skills/parallel-run/SKILL.md`, `.claude/rules/parallel-orchestration.md` (plus the excluded `parallel-orchestrate` skill); each manifested path is a bundled file, giving the 6 mirrors; the other-surface Grep matched only `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, a hook outside the family.
- Cross-check Count: 6 source (each with 1 manifested mirror) = 12; other surfaces 0.
- Member-set Comparison: the normalized primary and cross-check sets are identical (same six repository-relative paths, each with its mirror); no member is missing, duplicated, or extra after the stated exclusions. The assertion is supported.

### Claim N2: the scheduling fixture corpus has 5 stems, each listed in both drivers

- Complete Family: scheduling fixtures under `tests/fixtures/blast_radius/scheduling/`.
- Exhaustive Search Scope: that directory and the two driver files.
- Inclusion Rules: `*.json` files in the directory; stem strings in the driver lists.
- Exclusion Rules: aggregate, combination, write-intent, and historical-run fixtures.
- Primary Search Strategy or Query Expression: Glob `tests/fixtures/blast_radius/{scheduling,aggregate,combination}/*.json`, filtered to `scheduling/`.
- Primary Member Set: `scheduling-452-directory-prefix-weighted`, `scheduling-452-negative-controls`, `scheduling-452-shared-surface-hard`, `scheduling-absent-key-strict`, `scheduling-soft-pair-tolerated`.
- Primary Count: 5.
- Cross-check Search Strategy or Query Expression: Grep `fixtures/blast_radius/scheduling|scheduling-` over `tests/scripts`.
- Cross-check Member Set: the same five stems in `test_blast_radius_scheduling.py` and in `BlastRadiusScheduling.Tests.ps1`.
- Cross-check Count: 5 in each driver.
- Member-set Comparison: identical sets in the directory and both drivers. The assertion is supported.

## Testing Implications

- Parallel gates only: one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run with coverage, Jest through `node run-jest.cjs`; focused runs are debugging only. Tests create no temporary files; plan text and records are passed in memory.
- Pester (new files): access-aware pair weight (read-only either side 0, append-only, separable both sides, separable one side falls back to `same_file`, glob overlap), reader acceptance and rejection of the optional `separable` weight (absent, 0, negative, boolean), read-only derivation from plan text (read and run verbs, a write verb in the title overriding, a created file never read-only), `Test-ParallelPrecedenceJustified` (accepted edge pair, rejected tolerated pair, rejected non-conflicting pair, correctness entry with reason, correctness entry with empty reason, legacy entry without `kind`), `test-precedence` CLI exit codes and the exact rejection line, durable-record projection with and without the optional keys.
- Shared corpus: new scheduling fixtures at the committed minute values covering read-only, append-only, same-file separable, same-file write (same function), and hard pairs, with expected records in the unchanged engine shape, plus a strict-identity case (key absent) proving old behavior; drift fixtures for a read-declared path written (escape) and a peer read declaration honoured.
- Python validators and TypeScript port: byte-identical error strings for each new check, plus acceptance of checkpoints without the fields; update the two tolerated-edge-field tests for the both-lists check.
- Manifest: M9 cases added to `tests/fixtures/parallel_manifest_bash/` and driven by both the Python and bash drivers.
- Config: update `COMMITTED_CONFLICT_TOLERANCE` and the rule-text pins; re-run push-down overlay tests (`test_push_down_claude_blast_radius_overlay.py`, `claude-blast-radius-overlay.test.ts`) with an overlay overriding `same_file` to prove AC5.
- Wording: the new Pester wording test over the twelve files.

## Pre-Mortem

- Review checklists: a reviewer can flag the rule text as inconsistent across surfaces, or the skill sentence "tolerated-not-validated" left in `parallel-add` `## Constraints` and the rule after the validators begin checking the fields. Mitigation: one canonical sentence pinned by the new wording test in all twelve files, and a task that rewrites every "tolerated-not-validated" statement about `hard`, `cost`, `benefit`, and `tolerated_overlaps`.
- Coverage: new PowerShell modules, Python branches in `_blast_radius_scheduling.py`, `_parallel_state_records.py`, and `parallel_manifest_contract.py`, and TypeScript validator branches can fall below 85% line / 75% branch per changed file. Mitigation: per-file figures from the single gate runs compared with the Phase 0 baseline; every new branch (absent field, wrong type, boolean, negative, legacy precedence entry) has a named case; no new TypeScript production file.
- Mirror parity: every edited `.claude` file and new module needs a byte-equal bundle copy, new modules need `core.json` entries, and `conflict_tolerance` must stay byte-equal across the two config copies. Mitigation: a mirror-sync task after each surface edit, then `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_blast_radius_config_parity.py`, and `BlastRadius.KeyPartition.Tests.ps1`. No execution-environment brief update is required, because no fact it states changes; if the owner adopts D8, a brief task covering all six copies is added.
- File size: `Invoke-ParallelAdmission.ps1` (626), `BlastRadiusScheduling.psm1` (530), `ParallelAdmissionPrecedence.psm1` (508), `_blast_radius_scheduling.py` (561), and `Invoke-ParallelAdmission.Tests.ps1` (695) are past the guidance tier. Mitigation: new logic in new modules and new test files; the plan records a before and after line count for each and keeps every file at or below 700.
- Test isolation: Pester suites that import the blast-radius or admission modules with `-Force` can leak module state or script-scope variables across files in one shard; the CLI tests dot-source `Invoke-ParallelAdmission.ps1`. Mitigation: follow the existing `BeforeAll` import pattern, restore any changed environment or location, inject git and file seams, and run `Invoke-PoshQCLeakScan`.
- CI-only behavior: fixtures with drive-letter roots or backslashes fail in the Linux hook-suite job; CRLF fixtures normalize under `eol=lf`; `_shell-coverage.yml` has no `origin/main`. Mitigation: repository-relative forward-slash fixture paths, no `origin/main` diffs in tests, and bash M9 tests through the existing bats and kcov job.
- Evidence: the default-behaviour change can be under-evidenced, and recalibrated numbers can be asserted without their measured basis. Mitigation: an evidence artifact under `<FEATURE>/evidence/other/` recording the measured durations of section 3.2 and a before/after scheduling comparison over a committed historical-run fixture at both the old and new committed values; append-only evidence with clock-read UTC stamps; the PR body states the behaviour change (AC6) and the MCP-release lag of the new validator rules.

## Automation Feasibility

Fully automatable; no human interaction is required. Every step is a file edit, a deterministic test run, or a validator run available to the executor routes (PowerShell through the `sh` launcher or PoshQC MCP, pytest through Poetry, Jest through `node run-jest.cjs`, bash through `sh`). The only external read is the in-flight run's manifest (section 7), which the orchestrator performs with `git show`. The owner decisions below are recorded for review and do not block execution; the orchestrator adopts the recommended values.

## Recommendation

Adopt one design: keep detection and the edge-rule shape unchanged, recalibrate the committed values to minutes, add optional per-item access declarations that lower cost without narrowing radii, record both estimates and the verdict in the checkpoints, the manifest (M9), and the durable record, and gate `--after` flags through a new helper subcommand.

Recalibrated values (both config copies, byte-equal `conflict_tolerance`): `tolerance_percent` 100; `band_durations` C1 30, C2 45, C3 90, C4 180; `default_band` C1; `weights` `same_file` 90, `contract` 90, `possible_overlap` 20, `module` 10, `append_only` 10, new optional `separable` 15; read-only on either side 0 (fixed); `append_only_paths` plus `extensions/drm-copilot/resources/**`; `combination_threshold_percent` 400.

Rule text for every surface (the first sentence is the pinned sentence, verbatim in all twelve files):

> Two items run sequentially if and only if the expected merge time exceeds the expected time gained by running them in parallel. Both estimates are in minutes: the merge time is the pair's cost (the summed overlap-class weights, 0 for a path one side only reads), and the gain is the shorter of the two items' band durations. A detected pair is an edge when it is a hard class (`shared_surface_overlap` or `contract_dependency`) or `cost * 100 > benefit * tolerance_percent`; at the committed `tolerance_percent` of 100 this is exactly merge time greater than gain, and a tie runs in parallel. Operator `--after` flags and planner-proposed orderings pass the same test and are rejected with `precedence_not_justified` unless marked as a correctness ordering with `--reason`.

Implementation outline:

1. Config: both copies with the values above; reader accepts optional `weights.separable` (integer at least 1) in PowerShell and Python.
2. Engine: optional item `read_paths` and `separable_paths` in `Get-BlastRadiusConflictEdge` / `schedule_conflict_edges` and the drift path; access-aware path-pair weight in `BlastRadiusAccess.psm1` and in-place Python; engine output keys unchanged; drift treats an observed write to a read-declared path as an escape.
3. Planner: `access-paths` helper subcommand derives `read_paths`; the planner declares `separable_paths` with a rationale; both recorded on checkpoint and manifest items.
4. Recording: validators check `hard`, `cost`, `benefit`, `tolerated_overlaps`, and item access lists when present (Python and TypeScript, identical error strings); manifest M9 `pair_decisions[]` (Python and bash, shared corpus); durable record keeps edge `hard`, `cost`, `benefit` and precedence `kind`, `reason` when present.
5. Precedence: `--reason` syntax, `kind` and `reason` fields, `test-precedence` subcommand, `precedence_not_justified` code; legacy entries honoured.
6. Surfaces: rule text and the changed procedure text in the six AC1 files plus `parallel-orchestrate`, all mirrors, `core.json` entries, the new wording test, and the pinned-test updates listed in 1.4.
7. PR: state the default scheduling behaviour change (AC6) and that the new validator rules reach MCP only after the next extension release.

Decisions recorded for owner review:

- D1: unit is integer minutes, not hours, to keep the integer-only rule and existing validators.
- D2: the committed numbers in section 3.4, derived from a small sample (8 C2 and 6 C3 executions from one run; no measured C1 or C4 band).
- D3: the routine merge of `origin/main` and CI re-pass for a tolerated pair is a per-item cost and is not added to pair weights; read-only pairs therefore cost 0.
- D4: gain stays `min(band durations)`, an upper bound when `max_concurrency` is saturated.
- D5: the aggregate cap of issue #1013 is kept and reinterpreted in minutes.
- D6: "manifest" is realized as frontmatter invariant M9 written at seeding; admissions after seeding are recorded in the orchestrator checkpoint and `parallel-scheduling.json`, because the orchestrator keeps the manifest read-only.
- D7: `separable_paths` is planner-declared with a rationale (not statically derivable); `read_paths` is derived by a deterministic helper; a wrong read-only declaration is caught by drift detection as an escape.
- D8: the execution-environment brief is not changed; listing the new wording test in its contract-test list is optional.
- D9: legacy precedence entries without `kind` are honoured and not re-tested.
- D10: `extensions/drm-copilot/resources/**` is classed as append-only (regenerated), which lowers the cost of every mirror overlap.

Rejected alternatives (brief):

- Raise `tolerance_percent` only (for example to 1600) and keep relative weights: it changes all classes by one factor, cannot express read-only as 0 or same-function as a remediation pass, and leaves 100 meaning something other than the owner's rule.
- Add an `overlap_class` key to the engine's edge and tolerated records: it breaks every whole-record comparison in the shared scheduling corpus and the historical-run fixtures for information the AC does not require.
- Mark read-only paths by narrowing the radius or by adding `Run` to the W3 read-verb set: both remove entries from declared radii, which the issue's constraints prohibit.
- Decimal hour weights: requires changing integer validation in two runtimes and the carriage tests for no behavioural gain over minutes.
