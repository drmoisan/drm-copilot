# parallel-planner-time-based-edge-rule — Spec

- **Issue:** #1164
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-09
- **Status:** Draft
- **Version:** 0.2
- **Requirements source:** `docs/features/active/parallel-planner-time-based-edge-rule-1164/issue.md`
- **Research (adopted design):** `docs/features/active/parallel-planner-time-based-edge-rule-1164/research/research.2026-11-09T22-15.md`, section `## Recommendation` (orchestrator decision DEC-1164-1, autonomous mode)
- **Owner directive OD-1164-1:** "I want maximum parallelization. Therefore, features should be run sequentially if and only if the time lost to merge is greater than the time gained through parallel execution." The rule is wired into the parallel planner itself; changing the default scheduling behaviour is intended for this item.

## Overview

The parallel scheduler decides whether two detected-conflict items are separated by an edge (run sequentially) or tolerated (run in parallel). The rule shape already exists in both runtimes (`Get-BlastRadiusPairDecision` in `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`; `decide_pair` in `scripts/dev_tools/_blast_radius_scheduling.py`): edge iff conflict AND (hard OR `tolerance_percent == 0` OR `cost * 100 > benefit * tolerance_percent`). The committed weights and band durations are not in time units, so the rule at the default tolerance does not mean "merge time exceeds gain"; operator `--after` flags serialize items without any test; and the rule is not stated in the planning surfaces.

This feature:

1. Recalibrates the committed weights and band durations to integer minutes so that the committed `tolerance_percent` of 100 means exactly "edge iff merge time > gain", with a tie running in parallel.
2. Adds optional per-item access declarations (`read_paths`, `separable_paths`) and an optional `separable` weight that lower a pair's merge-time estimate without narrowing any declared radius.
3. Records the merge-time estimate, the gain estimate, and the verdict for every detected pair in the planner and orchestrator checkpoints, the run manifest (new invariant M9 `pair_decisions`), and `parallel-scheduling.json`, with validators that check the fields when present and accept records without them.
4. Gates operator `--after` flags and planner-proposed orderings through the same test, rejecting an unjustified flag with `precedence_not_justified` unless it is marked as a correctness ordering with `--reason`.
5. States the rule in one pinned sentence on every parallel planning surface named by the issue.

- Target users/personas and primary use cases: the repository owner, who sets scheduling policy and reviews merge cost; the `parallel-planner` and `parallel-orchestrator` agents and the `/parallel-plan`, `/parallel-add`, `/parallel-run` skills, which compute and apply cohorts; destination repositories that receive the push-down payload and may override configuration in `config/blast-radius.local.json`.
- Success metrics or expected impact: at the committed defaults, a pair whose only overlap is a path read on one side, an append-only path, or a separable section is tolerated for every band combination listed in `## Behavior`; a pair writing the same file on both sides is an edge only when 90 minutes exceeds the shorter band duration; no `--after` flag serializes a pair without either a passing cost test or a recorded correctness reason.

## Behavior

### B1. Units and the edge rule

- B1.1 Both estimates are integer minutes. Merge time is the pair's `cost`; gain is the pair's `benefit`.
- B1.2 Gain (`benefit`) is the minimum of the two items' band durations, a missing band reading as `default_band` (unchanged `Get-BlastRadiusPairBenefit` / `pair_benefit`).
- B1.3 Merge time (`cost`) is the sum, over overlapping path-entry pairs after the `mergeable_paths` exclusion, of the per-pair path weight (B2), plus `module` times the number of shared modules, plus `contract` times the number of distinct shared contract identifiers.
- B1.4 A detected pair is an edge iff it is hard, or `tolerance_percent` is 0, or `cost * 100 > benefit * tolerance_percent`. At the committed `tolerance_percent` of 100 the condition is exactly `cost > benefit`.
- B1.5 Tie behavior: when `cost * 100 == benefit * tolerance_percent` the pair is tolerated (runs in parallel). The comparison is strictly greater-than.
- B1.6 Hard classes: a pair whose reasons include `shared_surface_overlap` or `contract_dependency` is an edge at every tolerance, including tolerance values at which `cost <= benefit`. Its `cost` and `benefit` are still computed and recorded.
- B1.7 Detection (`Test-BlastRadiusConflict` / `conflicts`) and its four reason kinds (`path_overlap`, `module_overlap`, `shared_surface_overlap`, `contract_dependency`) are unchanged. A pair priced at cost 0 remains a detected conflict and is recorded as a tolerated overlap with its estimates.
- B1.8 When the `conflict_tolerance` key is absent from configuration, scheduling is strict (tolerance 0, unit weights), exactly as today.

### B2. Path-pair weight (access-aware)

For one overlapping path-entry pair between items A and B, the weight is selected in this order; the first matching row applies:

| Order | Condition | Weight |
| --- | --- | --- |
| 1 | The entry is in A's `read_paths` or in B's `read_paths` (read-only on at least one side) | 0 (fixed; not configurable) |
| 2 | A concrete entry matches `append_only_paths` | `weights.append_only` |
| 3 | The entry is in A's `separable_paths` and in B's `separable_paths` | `weights.separable` |
| 4 | Two equal concrete entries | `weights.same_file` |
| 5 | Otherwise (glob or directory-prefix overlap) | `weights.possible_overlap` |

- B2.1 A path listed in `separable_paths` on only one side falls through to row 4 or row 5.
- B2.2 When neither item carries `read_paths` or `separable_paths`, the weight equals today's `Get-PathPairWeight` result for every input (fail closed).
- B2.3 When `weights.separable` is absent from configuration and row 3 would apply, the weight falls through to row 4 or row 5.

### B3. Committed values (minutes)

Both `config/blast-radius.json` and `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` carry these values, and their `conflict_tolerance` members remain byte-equal:

| Member | Before | After |
| --- | --- | --- |
| `tolerance_percent` | 100 | 100 |
| `band_durations.C1` | 1 | 30 |
| `band_durations.C2` | 2 | 45 |
| `band_durations.C3` | 4 | 90 |
| `band_durations.C4` | 8 | 180 |
| `default_band` | C1 | C1 |
| `weights.same_file` | 8 | 90 |
| `weights.contract` | 8 | 90 |
| `weights.possible_overlap` | 2 | 20 |
| `weights.module` | 2 | 10 |
| `weights.append_only` | 1 | 10 |
| `weights.separable` (new, optional) | absent | 15 |
| Read-only on either side | n/a | 0 (fixed by B2 row 1) |
| `append_only_paths` | `**/CHANGELOG.md`, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `quality-tiers.yml` | the same three entries plus `extensions/drm-copilot/resources/**` |
| `combination_threshold_percent` | 400 | 400 |

### B4. Required verdicts at the committed defaults

Each row is a required unit-test case in both runtimes (PowerShell and Python) through the shared scheduling fixture corpus:

| Case | Bands | Cost | Benefit | Verdict |
| --- | --- | --- | --- | --- |
| Read-only on one side, same file | any (C1 with C1 and C4 with C4 at minimum) | 0 | min band | tolerated |
| Append-only path | C2 with C2 | 10 | 45 | tolerated |
| Separable same file, declared on both sides | C2 with C2 | 15 | 45 | tolerated |
| Same file written on both sides (same function or rule) | C2 with C2 | 90 | 45 | edge |
| Same file written on both sides | C3 with C3 | 90 | 90 | tolerated (tie) |
| Same file written on both sides | C1 with C4 | 90 | 30 | edge |
| Hard class (`shared_surface_overlap`) | C4 with C4 | recorded | 180 | edge |
| Hard class (`contract_dependency`) | C4 with C4 | recorded (includes 90 per contract) | 180 | edge |
| `conflict_tolerance` absent | any | unit weights | unit bands | strict edge for every conflict (B1.8) |

### B5. Access declarations

- B5.1 An item may carry two optional lists beside its six-key `blast_radius` block (not inside it): `read_paths` and `separable_paths`. Each is a list of non-empty strings, and each string must be a member of that item's `blast_radius.paths`.
- B5.2 `read_paths` is derived by a deterministic PowerShell helper subcommand `access-paths` of `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` from the approved plan text: a radius path is read-only when every task window naming it has a first title word in {Read, Verify, Confirm, Inspect, Review, Baseline, Run, Execute}, no task title naming it contains a write verb, and the plan does not create it. A path the plan creates is never read-only.
- B5.3 `separable_paths` is declared by the planner, with a one-line rationale per path recorded in the planner checkpoint.
- B5.4 Declaring a path in `read_paths` or `separable_paths` never removes it from `blast_radius.paths`. Narrowing a declared radius to suppress an edge remains prohibited.
- B5.5 Drift detection (`ParallelDrift.psm1`, `scripts/dev_tools/parallel_drift_detection.py`, `scripts/dev_tools/_parallel_drift_scheduling.py`) treats an observed write to a path the item declared in `read_paths` as an escape, reported the same way as an undeclared write.
- B5.6 Drift re-evaluation passes each peer's declared `read_paths` and `separable_paths` into the pair weight, so a pair tolerated at cost 0 at seeding is not re-priced as a write unless an escape is observed.

### B6. Precedence flags

- B6.1 Syntax: `/parallel-plan` accepts `--after <later>:<earlier> [--reason "<text>"]`; `/parallel-add` accepts `--after <earlier> [--reason "<text>"]`. A `--reason` binds to the immediately preceding `--after`.
- B6.2 Recording: each flag is recorded as a `precedence[]` entry `{before, after, source, recorded_at, kind[, reason]}`. With a `--reason`, `kind` is `"correctness"` and `reason` is the supplied text. Without one, `kind` is `"cost"` and `reason` is absent. A planner-proposed ordering is recorded the same way with `source: "planner"`; an operator flag has `source: "operator"`.
- B6.3 Test: after the scheduling entry point returns, the new helper subcommand `test-precedence -Entry <json carrying precedence, edges, tolerated_overlaps>` checks every `kind: "cost"` entry.
  - Accepted: the entry's unordered pair is a returned edge (hard, or merge time > gain). Exit code 0.
  - Rejected: the entry's unordered pair is a tolerated overlap or is not a detected conflict. Exit code 1 and exactly this line on output, with `<cost>` and `<benefit>` the recorded integer minutes (0 and the pair's gain when the pair is not a detected conflict):

    `PARALLEL_ADMISSION_REJECTED: precedence_not_justified: --after <later>:<earlier> fails the parallel scheduling rule (merge time <cost> min does not exceed parallel gain <benefit> min); add --reason "<text>" to record a correctness ordering`
  - Correctness-marked: a `kind: "correctness"` entry with a non-empty `reason` is accepted without a cost test. A `kind: "correctness"` entry with an empty or whitespace-only `reason` is rejected with exit code 1.
- B6.4 Legacy entries: a `precedence[]` entry without `kind` is honoured unchanged by `order-cohorts`, `test-cohorts`, `Get-ParallelActivePrecedence`, and the cohort-barrier hook, and is not re-tested by `test-precedence`.
- B6.5 The code `precedence_not_justified` is added to `$script:AdmissionRejectionCode` (alongside `run_closed`, `precedence_cycle`, `precedence_unknown_item`, `precedence_violated`), to the helper's `.DESCRIPTION`, and to the rule paragraph `**Admission output signal.**`. The mutation rejection code set of `## Mutation Rejection Signal (issue #1012)` is unchanged.
- B6.6 `test-precedence` and `access-paths` run through the existing `parallel-planner` Bash grant for `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1*`; no agent `tools:` frontmatter changes.

### B7. Recording of estimates and verdicts

- B7.1 Checkpoints (`artifacts/orchestration/parallel-planner-state.json`, `artifacts/orchestration/parallel-orchestrator-state.json`): `conflict_edges[]` entries carry `{a, b, reason, hard, cost, benefit}`; `tolerated_overlaps[]` entries carry `{a, b, reasons, cost, benefit}`. The verdict is list membership (`conflict_edges` = edge, `tolerated_overlaps` = tolerated). Engine output keys are unchanged.
- B7.2 Manifest (`docs/features/parallel/<slug>/parallel.md` frontmatter): new key-gated invariant M9 `pair_decisions[]`, written by the planner at seeding, one entry per detected pair `{a, b, reasons, hard, cost, benefit, verdict}`, `verdict` in {`edge`, `tolerated`}. Admissions by `/parallel-add` after seeding are recorded in the orchestrator checkpoint and `parallel-scheduling.json` only, because the orchestrator keeps the manifest read-only.
- B7.3 Durable record (`docs/features/parallel/<slug>/parallel-scheduling.json`, built by `New-ParallelSchedulingRecord`): the edge projection gains `hard`, `cost`, `benefit`, and the precedence projection gains `kind`, `reason`, each emitted only when present on the input. An input without them produces byte-identical output to today; the `tests/fixtures/parallel_admission/seed-scheduling-record.json` pin stays valid unchanged.
- B7.4 Hard edges carry both estimates in all three records (B1.6).

### B8. Rule text on the planning surfaces

- B8.1 The following sentence appears verbatim in each of the twelve files listed in B8.2 (pinned sentence):

  > Two items run sequentially if and only if the expected merge time exceeds the expected time gained by running them in parallel.

- B8.2 The twelve files are the six Claude source files `.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-add/SKILL.md`, `.claude/skills/parallel-run/SKILL.md`, `.claude/agents/parallel-planner.md`, `.claude/agents/parallel-orchestrator.md`, `.claude/rules/parallel-orchestration.md`, and their six bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/`. No Copilot (`.github/`), `.agents/`, or `.codex/` parallel planning surface exists (research `## Numeric Derivation Evidence`, claim N1); if one is added before merge, it carries the sentence.
- B8.3 The rule text that follows the pinned sentence states: both estimates in minutes; merge time is the summed overlap-class weights with 0 for a path one side only reads; gain is the shorter of the two band durations; hard classes are always edges; at `tolerance_percent` 100 the rule is exactly merge time greater than gain and a tie runs in parallel; `--after` flags and planner-proposed orderings pass the same test and are rejected with `precedence_not_justified` unless marked as a correctness ordering with `--reason`.
- B8.4 `.claude/skills/parallel-orchestrate/SKILL.md` and its mirror are also updated where they restate the tolerated-pair merge rule or precedence handling; they are not part of the twelve-file pin.
- B8.5 Every statement that `hard`, `cost`, `benefit`, or `tolerated_overlaps` are "tolerated-not-validated" (including `## Enum Ownership` in the rule and `## Constraints` in `parallel-add`) is rewritten to state that they are checked when present.

### Alternate and edge flows

- An item with no band uses `default_band` C1 (30 minutes), the smallest gain, so the fail-closed direction is toward an edge.
- A `blast-radius.local.json` override applies (B9) before any pair is priced.
- The aggregate cap (`Get-AggregateCappedPair` / `select_capped_pairs`, issue #1013) is kept unchanged in code; with minute values it promotes an item's cheapest-to-serialize tolerated overlap to an edge when the item's summed tolerated merge time exceeds its own band duration.

### Error handling and recovery

- Configuration reader: `weights.separable`, when present, must be an integer of at least 1; a boolean, zero, negative, or non-integer value is rejected by both readers (`Get-RequiredIntegerMap` path in PowerShell, `_read_int_map` path in Python) with the same failure class as an invalid existing weight. All other existing reader checks are unchanged.
- Item access lists: a non-list value, an empty string, or a string not present in `blast_radius.paths` is a validator error (B10).
- A rejected precedence flag stops the scheduling step; the operator either removes the flag or re-issues it with `--reason`.

### B9. Destination override

- B9.1 `config/blast-radius.local.json` composed at push time continues to merge `conflict_tolerance` recursively (nested objects per member, scalars overlay-wins).
- B9.2 An overlay that overrides an existing member (for example `weights.same_file`) takes effect over the recalibrated base value.
- B9.3 A new optional member present only in the base (`weights.separable`) passes through to the composed configuration unchanged.

### B10. Validators

- B10.1 Python (`scripts/dev_tools/_parallel_state_records.py`, called from `validate_parallel_planner_state.py` and `validate_parallel_orchestrator_state.py`) and the TypeScript port (`extensions/drm-copilot/src/lib/validate/parallel-state-records.ts` and callers) check, when present, with byte-identical error strings in both runtimes:
  - `conflict_edges[].hard` is a boolean.
  - `conflict_edges[].cost`, `conflict_edges[].benefit`, `tolerated_overlaps[].cost`, `tolerated_overlaps[].benefit` are non-negative integers; booleans are rejected.
  - `tolerated_overlaps` is a list of objects with resolvable, distinct, normalized endpoints; `reasons` is a non-empty list drawn from the four-member reason enum and contains no hard reason.
  - No unordered pair is present in both `conflict_edges` and `tolerated_overlaps`.
  - Item `read_paths` and `separable_paths` are lists of non-empty strings, each a member of the item's `blast_radius.paths`.
  - `precedence[].kind`, when present, is `"cost"` or `"correctness"`; `"correctness"` requires a non-empty `reason`.
- B10.2 A checkpoint that omits every new field validates exactly as before.
- B10.3 Manifest M9 is checked by `scripts/dev_tools/parallel_manifest_contract.py` (authority) and by bash (new sourced file, for example `.claude/lib/bash/parallel-manifest-pairs.sh`, used by `parallel-manifest-validate.sh`), against the shared corpus `tests/fixtures/parallel_manifest_bash/*.json`. M9 is key-gated: a manifest without `pair_decisions` passes. When present: each endpoint resolves to a manifest item; `a < b`; no duplicate pair; `cost` and `benefit` are non-negative integers; `verdict` is `edge` or `tolerated`; `hard: true` requires `verdict: edge`.
- B10.4 New validator rules apply through `mcp__drm-copilot__validate_orchestration_artifacts` only after the extension release that carries the TypeScript port is installed. Until then installed MCP accepts the fields as tolerated, and branch-current validation runs `scripts/dev_tools/validate_orchestration_artifacts.py` (`parallel-planner-state`, `parallel-orchestrator-state` subcommands). The rule text and the PR body state this.

## Inputs / Outputs

- Inputs:
  - `config/blast-radius.json` and its bundled copy (B3); optional destination `config/blast-radius.local.json` (B9).
  - Item records with optional `read_paths`, `separable_paths` (B5).
  - `/parallel-plan` and `/parallel-add` arguments `--after` and `--reason` (B6.1).
  - Approved plan text, passed in memory to the `access-paths` derivation (B5.2).
- Outputs:
  - Checkpoint `conflict_edges[]` and `tolerated_overlaps[]` with estimates (B7.1).
  - Manifest `pair_decisions[]` (B7.2).
  - `parallel-scheduling.json` with edge estimates and precedence `kind`/`reason` when present (B7.3).
  - Admission signal line `PARALLEL_ADMISSION_REJECTED: precedence_not_justified: ...` and exit code 1 on rejection (B6.3).
  - Evidence artifact under `docs/features/active/parallel-planner-time-based-edge-rule-1164/evidence/other/` recording the measured durations behind B3 and a before/after scheduling comparison over a committed historical-run fixture at the old and the new committed values.
- Config keys and defaults: as in B3. `weights.separable` is optional; `combination_threshold_percent` remains optional.
- Versioning or backward-compatibility constraints:
  - Every new field is optional. Older checkpoints, manifests, and durable records without the fields remain valid (B10.2, B10.3, B7.3).
  - Engine output keys are unchanged, so the existing shared fixture corpora (`tests/fixtures/blast_radius/{scheduling,aggregate,combination,historical-runs}/*.json`) remain valid without edits.
  - Legacy precedence entries without `kind` are honoured (B6.4).
  - The default scheduling behaviour changes (B3); this is intended (OD-1164-1) and is called out in the PR body.

## API / CLI Surface

- `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 test-precedence -Entry <json>`
  - Exit 0 when every `kind: "cost"` entry names a returned edge and every `kind: "correctness"` entry has a non-empty reason.
  - Exit 1 with the B6.3 line for the first failing `kind: "cost"` entry.
- `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 access-paths ...` returns the derived `read_paths` per item (B5.2).
- Example: two C2 items both writing `.claude/rules/parallel-orchestration.md` without separable declarations; cost 90 > gain 45; the pair is an edge; `--after 2:1` (kind `cost`) is accepted.
- Example: two C3 items with the same overlap; cost 90 = gain 90; tolerated; `--after 2:1` without `--reason` exits 1 with `... (merge time 90 min does not exceed parallel gain 90 min) ...`; `--after 2:1 --reason "item 2 consumes the schema item 1 adds"` is recorded with `kind: "correctness"` and accepted.
- Contracts and validation rules: B1-B10.

## Data & State

- Data transformations and invariants:
  - The rule shape, detection, and engine record keys are unchanged; only committed values, the access-aware path weight, and recording change.
  - Merge time and gain are non-negative integers in minutes.
  - A pair is in exactly one of `conflict_edges` or `tolerated_overlaps`.
  - A hard pair is always an edge.
  - Declared radii are never narrowed.
- Caching or persistence details: checkpoints under `artifacts/orchestration/` (gitignored); manifest and `parallel-scheduling.json` under `docs/features/parallel/<slug>/` (committed).
- Migration or backfill requirements: none. Existing runs, including the in-flight run `harness-learnings-2026-11-09` (#1156-#1163), are not migrated or edited.

## Constraints & Risks

- Language placement:
  - Pushed-down code is PowerShell or bash. New pure logic goes into new host-neutral PowerShell modules with injected seams, recommended `.claude/lib/blast-radius/BlastRadiusAccess.psm1` (access-aware path weight, read-only derivation from injected plan text) and `.claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1` (`Test-ParallelPrecedenceJustified`). `Invoke-ParallelAdmission.ps1` gains only thin subcommand wiring.
  - No new Python files. `_blast_radius_scheduling.py`, `_parallel_drift_scheduling.py`, `_parallel_state_records.py`, and `parallel_manifest_contract.py` are extended in place. `_parallel_state_structures.py` and `_parallel_state_common.py` are not extended (beyond constants in the latter).
  - TypeScript only for the validator port, in existing files; no new TypeScript production file.
- File size: no file may exceed 800 logical lines, and each file listed in research section 9 stays at or below 700. New tests go in new test files where the existing file is near 700 (`Invoke-ParallelAdmission.Tests.ps1`).
- Tests: no temporary files; no wall-clock waits; plan text and records passed in memory; parallel-only runs (`Invoke-PoshQCParallelTest`, `pytest -n auto`, Jest through `node run-jest.cjs`); fixtures use repository-relative forward-slash paths and LF line endings; no test diffs against `origin/main`.
- Coverage: per changed production file, line at least 85% and branch at least 75% for Python and TypeScript; line at least 85% for PowerShell.
- Consistency: Claude surface, bundled mirrors, `core.json` entries for every new file, both config copies, Python and TypeScript validators, Python and PowerShell engines, and Python and bash manifest validators stay consistent.
- Evidence is append-only, with clock-read UTC stamps.
- Concurrency (DEC-1164-3): the in-flight parallel run `harness-learnings-2026-11-09` (#1156-#1163) and its run folder are not modified. Its planner checkpoint records empty derived radii. Title-level overlap risk with #1157, #1161, and #1162 on the planning surfaces is mitigated by merging `origin/main` into this branch with a plain merge (never a rebase) before the PR. This item is not batched into a parallel run whose radii it changes.
- Security/privacy: no artifact records an absolute path or host name.
- Operational/rollout risk: the default scheduling behaviour changes for every subsequent run. Mitigation: recorded estimates make each verdict auditable; destinations can override any weight in `blast-radius.local.json`; the before/after evidence comparison documents the effect.
- Risk: the committed numbers rest on a small sample (8 C2 and 6 C3 executions from one run; no measured C1 or C4). Recorded for owner review (D2).

## Implementation Strategy

- Implementation scope:
  1. Config: both copies per B3; PowerShell and Python readers accept optional `weights.separable`.
  2. Engine: optional `read_paths` and `separable_paths` in `Get-BlastRadiusConflictEdge` / `schedule_conflict_edges` and the drift path; access-aware path weight per B2; engine output keys unchanged; drift escape per B5.5.
  3. Planner: `access-paths` subcommand; planner-declared `separable_paths` with rationale; both recorded on checkpoint and manifest items.
  4. Recording: validators per B10 (Python and TypeScript); M9 (Python and bash); durable-record projection per B7.3.
  5. Precedence: `--reason` syntax, `kind`/`reason` fields, `test-precedence` subcommand, `precedence_not_justified` code; legacy entries honoured.
  6. Surfaces: rule text and procedure text per B8 in the six source files, `parallel-orchestrate`, all mirrors; `core.json` entries for new files; a new wording contract test (recommended `tests/scripts/claude-runtime/parallel-scheduling-rule-wording.Tests.ps1`) pinning the B8.1 sentence in the twelve files.
  7. Pinned-test updates: `COMMITTED_CONFLICT_TOLERANCE` and related tests in `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py`; `test_rule_documents_the_contract_weight` in `tests/scripts/dev_tools/test_parallel_issue_combination_contracts.py` (the weight-minimum wording and "its committed value is 8"); the both-lists case in `test_validate_parallel_state_tolerated_edge_fields.py` and `parallel-state-tolerated-edge-fields.test.ts`.
- New classes/functions/commands: `BlastRadiusAccess.psm1`, `ParallelAdmissionPrecedenceGate.psm1` (`Test-ParallelPrecedenceJustified`), subcommands `test-precedence` and `access-paths`, rejection code `precedence_not_justified`, manifest invariant M9, bash M9 sourced file.
- Dependency changes: none.
- Logging/telemetry: the admission signal line (B6.3); recorded estimates (B7).
- Rollout plan: the change takes effect for runs planned after merge. Destinations receive it through the push-down payload; every changed or new file under `.claude/` has a byte-equal bundled copy under `extensions/drm-copilot/resources/claude-customizations/.claude/`, and every new file has an entry in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`. The push-down serves the installed extension payload, so destinations receive the change after the extension release. The PR body states (a) the default scheduling behaviour change, owner-directed under OD-1164-1, and (b) that the new validator rules reach MCP only after the next extension release.

## Decisions for Owner Review

These decisions were adopted by the orchestrator (DEC-1164-1, autonomous mode) from research `## Recommendation` and do not block execution.

- D1: The unit is integer minutes, not hours, to keep the integer-only rule and existing validators.
- D2: The committed numbers in B3 derive from a small sample (8 C2 and 6 C3 executions from one run; no measured C1 or C4 band).
- D3: The routine merge of `origin/main` and CI re-pass for a tolerated pair is a per-item cost and is not added to pair weights; read-only pairs therefore cost 0.
- D4: Gain stays `min(band durations)`, an upper bound when `max_concurrency` is saturated.
- D5: The aggregate cap of issue #1013 is kept and reinterpreted in minutes.
- D6: "Manifest" is realized as frontmatter invariant M9 written at seeding; admissions after seeding are recorded in the orchestrator checkpoint and `parallel-scheduling.json`, because the orchestrator keeps the manifest read-only.
- D7: `separable_paths` is planner-declared with a rationale (not statically derivable); `read_paths` is derived by a deterministic helper; a wrong read-only declaration is caught by drift detection as an escape.
- D8: The execution-environment brief is not changed; listing the new wording test in its contract-test list is optional.
- D9: Legacy precedence entries without `kind` are honoured and not re-tested.
- D10: `extensions/drm-copilot/resources/**` is classed as append-only (regenerated), which lowers the cost of every mirror overlap.

## Acceptance Criteria Traceability

| Issue AC | Spec sections | User-story AC |
| --- | --- | --- |
| AC1 rule text consistent on all surfaces | B8 | US-AC1, US-AC2 |
| AC2 recalibration and rule at default tolerance, with unit tests | B1, B2, B3, B4, B5 | US-AC3, US-AC4, US-AC5 |
| AC3 per-pair estimates and verdicts recorded and validated; older records valid | B7, B10 | US-AC6, US-AC7, US-AC8 |
| AC4 precedence flags gated; tests for accepted, rejected, correctness-marked | B6 | US-AC9, US-AC10 |
| AC5 local override works; push-down payload carries every changed file | B9, Implementation Strategy (rollout) | US-AC11, US-AC12 |
| AC6 default behaviour change intended and called out in the PR | B3, B10.4, Implementation Strategy (rollout) | US-AC13 |

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)
