# parallel-scheduling-balance-speed-against-integration-cost — User Story

- Issue: #1013
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T13-28
- Work Mode: full-feature (acceptance criteria are tracked in this file and in `spec.md`)
- Spec: `spec.md` in this feature folder (AC IDs referenced below are the spec's `AC-NN` identifiers)

## Story Statement

- As a parallel-run operator, I want the scheduler to weigh the speed of running overlapping items concurrently against the cost of integrating them, including the total integration cost an item accumulates, so that overlapping items run in parallel when that is worth it and serialize when it is not.
- As a parallel-run operator, I want heavily overlapping items combined at planning time into one item with one branch and one PR that closes every member issue, so that I pay for one worktree, one PR, and one CI cycle instead of a costly merge.
- As a parallel-run operator, I want observed merge-conflict resolution time recorded for each tolerated pair, so that I can measure the cost heuristic without the system changing weights on its own.
- As a destination maintainer, I want the published truth table to provide cost-benefit scheduling and a combination threshold by default, and to override the threshold through my local overlay, so that I get the behavior without writing configuration and can tune it when needed.

## Problem / Why

The parallel run should balance the speed gained by running items concurrently against the time spent integrating them at the end. Issue #722 introduced cost-benefit scheduling, but it is coarse:

- A destination with no `conflict_tolerance` gets strict scheduling (equivalent to `tolerance_percent` 0), so every detected conflict serializes.
- Each pair is judged alone, so one item with many tolerated overlaps never has its total integration cost counted.
- Cost uses static weights, and nothing measures real integration time.
- Hard classes (`shared_surface_overlap`, `contract_dependency`) serialize at every tolerance, even when the two items would be cheaper to deliver as one.
- Nothing combines two items whose overlap is heavy enough that one worktree, one PR, and one CI cycle would cost less than any merge.

This item depends on #1006 and is sequenced after it (see `spec.md`, Dependency on #1006).

## Personas & Scenarios

- Persona: parallel-run operator
  - Runs `/parallel-plan`, `/parallel-run`, and `/parallel-add` over a backlog of issues in this repository or a destination repository.
  - Cares about total wall-clock time to deliver the batch and about avoiding repeated merge-conflict remediation.
  - Constrained by CI cycle time, review load, and the remediation budget per item.
  - Frustrated when unrelated or lightly overlapping items serialize, and when one item with many small overlaps produces repeated conflicts at the end of a run.
- Persona: destination maintainer
  - Maintains a repository that receives the bundled customizations through push-down.
  - Cares about receiving sensible defaults without hand-written configuration, and about overriding them durably in `config/blast-radius.local.json`.
  - Constrained by the installed-extension payload: changes arrive only after an extension release, rebuild, and reinstall.

- Scenario: aggregate cap during planning
  - The operator runs `/parallel-plan` over five items. Item #10 has tolerated overlaps with items #11, #12, and #13, each individually within tolerance.
  - The scheduling entry point sums #10's tolerated costs and finds the total above #10's cap. It promotes #10's cheapest-to-serialize pair to an edge and repeats until every item is within its cap.
  - The operator sees fewer late merge conflicts. With `tolerance_percent` 0 the output is identical to strict scheduling.

- Scenario: planning-time combination
  - Items #20 and #21 both edit the same non-append-only file heavily. Their pair cost meets the shorter item's benefit times `combination_threshold_percent`.
  - Without operator approval, the planner re-plans #20's branch to cover both specs, runs a fresh complexity assessment, removes #21 from `items[]`, records `combined_issue_nums`, and lists the combination and its estimated savings in the plan report.
  - The run executes one child that opens one PR with `Author-asserted autoclose issues: #20 #21`. When CI fails, the child remediates the combined item as one unit; it never splits into two PRs. Both issues remain separate on GitHub.

- Scenario: late addition
  - The operator runs `/parallel-add` for item #30, which would qualify for combination with an unstarted item #22.
  - `parallel-add` reports that the pair qualifies for combination but is not combined, because combination applies at planning time only.

- Scenario: telemetry
  - Item #12 merges after its tolerated peer #11 and hits a merge conflict. The orchestrator records `observed_resolution` on that tolerated pair, and the run's `parallel-status.md` lists it under `## Tolerated Overlaps`. No weight changes as a result.

- Scenario: destination defaults and override
  - A destination with no overlay pushes down and receives `tolerance_percent` 100 and `combination_threshold_percent` 400.
  - The maintainer sets a different `combination_threshold_percent` in `config/blast-radius.local.json`; the composed `config/blast-radius.json` carries the overlay value.

## Acceptance Criteria

Story criteria use stable IDs `US-NN`; each names the spec AC IDs that verify it.

### Story 1 — Aggregate integration cost (parallel-run operator)

As a parallel-run operator, I want each item's total tolerated integration cost capped, so that one item cannot accumulate many tolerated overlaps that together cost more than running it serially.

Acceptance Criteria:

- [ ] US-01 An item whose tolerated overlaps exceed its aggregate cap has its cheapest-to-serialize pair converted to an edge, deterministically, in both Python and PowerShell (spec AC-02, AC-03).
- [ ] US-02 At `tolerance_percent` 0 the edge set equals strict scheduling, and the existing strict-identity pins pass unchanged (spec AC-04).
- [ ] US-03 The set-level scheduling properties are pinned and the rule text narrows the monotonicity statement to the pairwise decision (spec AC-05).

### Story 2 — Planning-time issue combination (parallel-run operator)

As a parallel-run operator, I want qualifying pairs combined into one item at planning time, so that heavy overlaps are delivered through one branch, one PR, and one CI cycle.

Acceptance Criteria:

- [ ] US-04 A pair meeting the combination threshold, with candidates limited to `contract_dependency` or same-file overlap, is combined by the library with deterministic members, primary, pairs, and estimated savings (spec AC-10).
- [ ] US-05 The planner combines without operator approval, re-plans on the primary branch, assigns the combined item a band from a fresh complexity assessment, and records `combined_issue_nums` and the `combinations` list (spec AC-11, AC-14).
- [ ] US-06 The combined item runs as one child with one branch and one PR whose autoclose line names every member issue; no umbrella issue is created (spec AC-12, AC-13).
- [ ] US-07 A combined item that fails review or CI remediates as one unit and never splits back into separate PRs (spec AC-16).
- [ ] US-08 The plan report lists each combination with its members, pairs, threshold, and estimated savings, and lists not-combined qualifying pairs with the reason (spec AC-17).
- [ ] US-09 `parallel-add` reports a qualifying overlap with an unstarted item without combining it (spec AC-15).

### Story 3 — Telemetry without tuning (parallel-run operator)

As a parallel-run operator, I want observed merge-conflict resolution time recorded per tolerated pair, so that the cost heuristic can be measured.

Acceptance Criteria:

- [ ] US-10 Observed resolution time per tolerated pair is recorded in the orchestrator checkpoint and projected into the run's `parallel-status.md` (spec AC-06).
- [ ] US-11 No code reads the recorded telemetry, and no weight changes automatically (spec AC-07).

### Story 4 — Defaults and threshold override (destination maintainer)

As a destination maintainer, I want nonzero default scheduling tolerance and a default combination threshold from the published truth table, with a validated override, so that I receive the behavior without configuration and can tune it.

Acceptance Criteria:

- [ ] US-12 A destination with no overlay receives `tolerance_percent` 100 and `combination_threshold_percent` 400 from the published truth table (spec AC-01).
- [ ] US-13 `combination_threshold_percent` is read from `conflict_tolerance`, validated like the other members, and its accept, reject, and default behavior is equal across Python and PowerShell (spec AC-08).
- [ ] US-14 The committed value is equal in both truth tables, and a destination overlay value is composed identically by the TypeScript and Python composers (spec AC-09).

### Story 5 — Delivered consistently to destinations (destination maintainer)

As a destination maintainer, I want the bundled copies and pack manifest to match their sources, so that a push-down delivers the same behavior this repository runs.

Acceptance Criteria:

- [ ] US-15 Mirrored and bundled copies are byte-identical to their sources, the pack manifest lists the new modules, and the contract tests pass (spec AC-18, AC-19, AC-20).
- [ ] US-16 The change stays within its declared scope: no edge-reason enum change, no validated checkpoint schema change, no validator, drift, or hook change (spec AC-22), and it is delivered on top of merged #1006 (spec AC-21).
- [ ] US-17 Fail-before evidence, coverage, toolchain, file-size, and isolation gates pass and are recorded (spec AC-23, AC-24, AC-25).

### Issue Acceptance Criteria Traceability

Issue acceptance criteria, restated from `issue.md`, with their story and spec traceability:

- [ ] A destination with no overlay receives a nonzero default `tolerance_percent` from the published truth table (US-12; spec AC-01).
- [ ] An item whose tolerated overlaps exceed its aggregate cap has its cheapest pair converted to an edge; at `tolerance_percent` 0 the edge set equals strict scheduling (US-01, US-02, US-03; spec AC-02 to AC-05).
- [ ] Observed merge-resolution time per tolerated pair is recorded, and no weight changes automatically (US-10, US-11; spec AC-06, AC-07).
- [ ] A pair meeting the combination threshold becomes one item with one branch and one PR closing both issues; its complexity band comes from a fresh assessment (US-04, US-05, US-06; spec AC-10 to AC-14).
- [ ] `parallel-add` reports a qualifying overlap with an unstarted item without combining it (US-09; spec AC-15).
- [ ] A combined item that fails review or CI remediates as one unit (US-07; spec AC-16).
- [ ] `combination_threshold_percent` is read from `conflict_tolerance`, validated like the other keys, and equal across Python, PowerShell, and TypeScript where ported (US-13, US-14; spec AC-08, AC-09).
- [ ] The plan report lists each combination and its estimated savings (US-08; spec AC-17).
- [ ] Mirrored and bundled copies, pack manifest, and contract tests pass (US-15; spec AC-18, AC-19).

## Non-Goals

- No change to the `conflict_edges[].reason` enum; `same_file` remains a cost weight, not a reason.
- No validated parallel checkpoint schema change; `observed_resolution`, `combined_issue_nums`, and `combinations` are tolerated-not-validated fields declared in the rule text.
- No automatic tuning of weights from telemetry.
- No change to benefit currency (band durations), `decide_pair`, `conflicts`, `HARD_REASON_KINDS`, drift detection, the parallel validators, or the author-asserted hook.
- No TypeScript or bash port of the tolerance reader, the cap, or the combination library.
- No umbrella GitHub issue and no size cap on a combined item; combination is not applied by `parallel-add` or after planning.
- No live destination push-down or live parallel run as verification; behavior is proven by in-memory, fixture, validator, and contract tests.
