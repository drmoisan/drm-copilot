# `parallel-planner-time-based-edge-rule` — User Story

- Issue: #1164
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-09
- Spec: `docs/features/active/parallel-planner-time-based-edge-rule-1164/spec.md`

## Story Statement

- As the repository owner, I want two parallel items to run sequentially if and only if the expected merge time exceeds the expected time gained by running them in parallel, so that parallel runs reach maximum parallelization without serializing pairs whose merge costs minutes.
- As the parallel planner, I want the merge-time and gain estimates expressed in the same unit and recorded with the verdict for every detected pair, so that each edge and each tolerated overlap is auditable after the run.
- As an operator issuing `--after` precedence flags, I want an unjustified flag rejected with a message naming the rule, and a way to record a genuine dependency with a reason, so that convenience orderings do not serialize items without a cost/benefit test.
- As a destination repository maintainer, I want the recalibrated rule delivered through the push-down payload while my `config/blast-radius.local.json` overrides keep working, so that I can tune the weights to my own merge costs.

## Problem / Why

Owner directive OD-1164-1 (2026-11-09): "I want maximum parallelization. Therefore, features should be run sequentially if and only if the time lost to merge is greater than the time gained through parallel execution."

The scheduler's rule (`cost * 100 > benefit * tolerance_percent`) has the right shape, but the committed weights are not in time units: `same_file` is 8 while a C3 item's benefit is 4, so one shared file serializes two half-day items even when the merge takes minutes. Run `bugs-1001-1002-1003-1006` took about 20 h at tolerance 100 versus about 8-11 h at higher tolerances, with every edge a `path_overlap`. Operator `--after` flags serialize items without any test, and the rule exists only in coordinator memory and per-run instructions rather than in the planning surfaces, so each run is corrected by hand.

## Personas & Scenarios

- Persona: Repository owner
  - Sets scheduling policy and reviews the cost of parallel runs.
  - Cares about total wall-clock time of a run and about avoiding avoidable merge remediation.
  - Constraint: cannot inspect every pair by hand on each run.
  - Goal: the planner applies the directive by default; frustration: runs serialized by overlaps that would merge in minutes.
  - Context: issued OD-1164-1 after measuring the `bugs-1001-1002-1003-1006` run.
- Persona: Parallel planner and orchestrator agents
  - Compute cohorts through `/parallel-plan`, `/parallel-add`, `/parallel-run`.
  - Care about deterministic, validator-clean checkpoints and manifests.
  - Constraint: may not narrow a declared blast radius to suppress an edge.
  - Goal: a single stated rule with committed values that implement it.
- Persona: Destination maintainer
  - Receives the push-down payload and may keep `config/blast-radius.local.json` overrides.
  - Goal: overrides continue to apply after recalibration.

- Scenario: Planning a run with mixed overlaps
  - The owner asks the planner to plan five C2 and C3 items. Two C2 items cite the same test file, which one of them only runs; two C3 items edit the same rule section; a C2 pair both write the same function.
  - The planner computes radii, derives `read_paths` with the `access-paths` helper, declares `separable_paths` with rationale, and schedules.
  - The read-only pair is tolerated at cost 0; the C3 same-file pair is tolerated at 90 against 90 (tie); the C2 same-function pair is an edge at 90 against 45.
  - The checkpoint, the manifest `pair_decisions`, and `parallel-scheduling.json` record each pair's cost, benefit, and verdict.
- Scenario: Operator precedence flag
  - The operator runs `/parallel-plan` with `--after 4:3` for two items the scheduler tolerates.
  - `test-precedence` rejects the flag with `precedence_not_justified`, naming the merge time and gain.
  - The operator re-issues `--after 4:3 --reason "item 4 consumes the schema item 3 adds"`; the entry is recorded as `kind: "correctness"` and accepted.
- Scenario: Destination override
  - A destination's `config/blast-radius.local.json` sets `weights.same_file` to 30. After push-down the composed configuration uses 30 for `same_file`, the recalibrated values for the other members, and the new `separable` weight from the base.

## Acceptance Criteria

- [x] US-AC1 (issue AC1; spec B8.1, B8.2, B8.3): The pinned sentence "Two items run sequentially if and only if the expected merge time exceeds the expected time gained by running them in parallel." appears verbatim in `.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-add/SKILL.md`, `.claude/skills/parallel-run/SKILL.md`, `.claude/agents/parallel-planner.md`, `.claude/agents/parallel-orchestrator.md`, `.claude/rules/parallel-orchestration.md`, and each of their bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/`, followed by rule text stating minutes, read-only cost 0, gain as the shorter band duration, hard classes always edges, tie runs in parallel, and `precedence_not_justified` for unjustified flags; a new wording contract test pins the sentence in all of these files and passes.
- [x] US-AC2 (issue AC1; spec B8.4, B8.5): `.claude/skills/parallel-orchestrate/SKILL.md` and its mirror are consistent with the rule, and no surface still states that `hard`, `cost`, `benefit`, or `tolerated_overlaps` are tolerated-not-validated.
- [x] US-AC3 (issue AC2; spec B3, B9): Both `config/blast-radius.json` and its bundled copy carry `tolerance_percent` 100, `band_durations` C1 30, C2 45, C3 90, C4 180, `default_band` C1, weights `same_file` 90, `contract` 90, `possible_overlap` 20, `module` 10, `append_only` 10, `separable` 15, `append_only_paths` including `extensions/drm-copilot/resources/**`, and `combination_threshold_percent` 400, with byte-equal `conflict_tolerance` members; the PowerShell and Python readers accept `weights.separable` when absent or an integer of at least 1 and reject it when zero, negative, boolean, or non-integer.
- [x] US-AC4 (issue AC2; spec B1, B2, B4): At the committed defaults the scheduler makes an edge iff `cost > benefit` in both runtimes, and shared-corpus unit tests assert every row of spec B4: read-only on one side tolerated at cost 0; append-only C2/C2 tolerated at 10 against 45; separable C2/C2 tolerated at 15 against 45; same-function C2/C2 edge at 90 against 45; same-file C3/C3 tolerated at 90 against 90 (tie); same-file C1/C4 edge at 90 against 30; `shared_surface_overlap` and `contract_dependency` pairs edges with both estimates recorded; `conflict_tolerance` absent gives strict scheduling.
- [x] US-AC5 (issue AC2; spec B5): Items may carry optional `read_paths` and `separable_paths`; `access-paths` derives `read_paths` from plan text per spec B5.2; no declaration removes a path from `blast_radius.paths`; drift detection reports an observed write to a read-declared path as an escape and re-prices peers using their declarations; items without the lists price exactly as before.
- [x] US-AC6 (issue AC3; spec B7.1, B7.4, B10.1): Planner and orchestrator checkpoints record `cost`, `benefit`, and `hard` on `conflict_edges[]` and `cost`, `benefit`, `reasons` on `tolerated_overlaps[]` for every detected pair including hard pairs; the Python validators and the TypeScript port check these fields and the item access lists and precedence `kind`/`reason` when present, with byte-identical error strings, and reject a pair present in both lists.
- [ ] US-AC7 (issue AC3; spec B7.2, B7.3, B10.3): The manifest carries M9 `pair_decisions[]` `{a, b, reasons, hard, cost, benefit, verdict}` written at seeding and validated identically by `parallel_manifest_contract.py` and the bash manifest validator over the shared corpus, including `hard: true` requiring `verdict: edge`; `parallel-scheduling.json` emits edge `hard`, `cost`, `benefit` and precedence `kind`, `reason` when present.
- [x] US-AC8 (issue AC3; spec B7.3, B10.2, B10.3): Checkpoints, manifests, and durable-record inputs without any of the new fields remain valid, and `tests/fixtures/parallel_admission/seed-scheduling-record.json` matches without edits.
- [x] US-AC9 (issue AC4; spec B6.1, B6.2, B6.3, B6.5): `test-precedence` accepts a `kind: "cost"` entry whose pair is a returned edge (exit 0), rejects a `kind: "cost"` entry whose pair is tolerated or not a detected conflict with exit 1 and the exact line `PARALLEL_ADMISSION_REJECTED: precedence_not_justified: --after <later>:<earlier> fails the parallel scheduling rule (merge time <cost> min does not exceed parallel gain <benefit> min); add --reason "<text>" to record a correctness ordering`, accepts a `kind: "correctness"` entry with a non-empty reason, and rejects one with an empty reason; tests cover each of these cases.
- [x] US-AC10 (issue AC4; spec B6.4, B6.6): Legacy precedence entries without `kind` are honoured unchanged and not re-tested, `precedence_not_justified` is listed in `$script:AdmissionRejectionCode`, the helper description, and the rule's admission output signal paragraph, and no agent `tools:` frontmatter changes.
- [x] US-AC11 (issue AC5; spec B9): A push-down overlay test with `config/blast-radius.local.json` overriding `weights.same_file` composes the overridden value over the recalibrated base, and the base-only `weights.separable` passes through.
- [x] US-AC12 (issue AC5; spec Implementation Strategy, rollout): Every changed or new file under `.claude/` has a byte-equal bundled copy under `extensions/drm-copilot/resources/claude-customizations/.claude/`, every new file has a `core.json` pack-manifest entry, and the push-down resource, pack-manifest completeness, dependency-closure, and config-parity contract tests pass.
- [ ] US-AC13 (issue AC6; spec B3, B10.4, rollout): The PR body states that the default scheduling behaviour changes as directed by the owner (OD-1164-1), and that the new validator rules apply through MCP only after the next extension release.

## Non-Goals

- Changing conflict detection or its four reason kinds.
- Changing the edge-rule shape, the engine's output record keys, or the existing shared fixture corpora.
- Narrowing any declared blast radius, or adding `Run` to the W3 read-verb set.
- Making hard classes (`shared_surface_overlap`, `contract_dependency`) tolerable.
- Modifying the in-flight run `harness-learnings-2026-11-09` (#1156-#1163) or its run folder, or migrating existing runs.
- Updating the execution-environment brief (decision D8).
- Re-testing legacy precedence entries.
- Recording post-seeding admissions in the run manifest (decision D6).
