# parallel-scheduling-balance-speed-against-integration-cost (Issue #1013)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-scheduling-balance-speed-against-integration-cost/ (Issue #1013)

- Issue: #1013
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1013
- Last Updated: 2026-10-30
- Work Mode: full-feature

## Problem / Why

The parallel run should balance the speed gained by running items concurrently against the time spent integrating them at the end. When the speed is worth the integration cost, the scheduler should run overlapping items in parallel. Issue #722 introduced cost-benefit scheduling, but it is coarse:

- A destination with no `conflict_tolerance` gets strict scheduling (equivalent to `tolerance_percent` 0), so every detected conflict serializes.
- Each pair is judged alone, so one item with many tolerated overlaps never has its total integration cost counted.
- Cost uses static weights and nothing measures real integration time.
- Hard classes (`shared_surface_overlap`, `contract_dependency`) serialize at every tolerance, even when the two items would be cheaper to deliver as one.
- Nothing combines two items whose overlap is so heavy that one worktree, one PR and one CI cycle would be cheaper than any merge.

Related: #1006 covers shared-surface demotion, generic worksheet-name contracts, and the overlay key. This issue builds on it and must be sequenced after it, because both change the shared-surface and `contract_dependency` rules.

## Proposed Behavior

1. **Default tolerance.** The published `config/blast-radius.json` truth table ships a nonzero `conflict_tolerance.tolerance_percent` (100, as the self-hosted table uses), so a destination gets cost-benefit scheduling without writing an overlay.
2. **Aggregate cost.** Sum an item's tolerated-overlap costs and cap the total at its own band duration times the tolerance factor. An item over the cap has its cheapest-to-serialize pair turned into an edge. At `tolerance_percent` 0 the output stays identical to strict scheduling.
3. **Telemetry.** Record the observed merge-conflict resolution time for each tolerated pair, as telemetry only, in the run record. There is no automatic tuning of weights.
4. **Benefit currency.** Benefit stays as band durations (a cohort-step estimate).
5. **Issue combination.** At planning time the planner combines a pair on its own, with no operator approval:
   - Candidates are pairs whose reasons are hard `contract_dependency` or `same_file`.
   - A pair combines when its cost is at least the shorter item's benefit times `conflict_tolerance.combination_threshold_percent` (default 400, a destination can change it).
   - The combined item is one item with one branch and one PR that closes both issues. Both issues stay separate on GitHub, with no umbrella issue.
   - The combined item gets a fresh complexity assessment from its merged scope.
   - There is no size cap on a combined item.
   - Combination applies at planning time only. A later `parallel-add` that creates a qualifying overlap with an unstarted item is reported but not combined.
   - A combined item remediates as one unit and never splits back into two PRs.
   - The plan report lists each combination and its estimated savings.

## Acceptance Criteria (early draft)

- [ ] A destination with no overlay receives a nonzero default `tolerance_percent` from the published truth table.
- [ ] An item whose tolerated overlaps exceed its aggregate cap has its cheapest pair converted to an edge; at `tolerance_percent` 0 the edge set equals strict scheduling.
- [ ] Observed merge-resolution time per tolerated pair is recorded, and no weight changes automatically.
- [ ] A pair meeting the combination threshold becomes one item with one branch and one PR closing both issues; its complexity band comes from a fresh assessment.
- [ ] `parallel-add` reports a qualifying overlap with an unstarted item without combining it.
- [ ] A combined item that fails review or CI remediates as one unit.
- [ ] `combination_threshold_percent` is read from `conflict_tolerance`, validated like the other keys, and equal across Python, PowerShell, and TypeScript where ported.
- [ ] The plan report lists each combination and its estimated savings.
- [ ] Mirrored and bundled copies, pack manifest, and contract tests pass.

## Constraints & Risks

- Depends on #1006: sequence this item after it, since both change the shared-surface and `contract_dependency` rules.
- The edge-reason enum and the parallel checkpoint schema change only where a combined item or telemetry requires it; call out any such change explicitly.
- Combining changes issue boundaries and closing references. A combined PR is larger to review and merges or fails as a unit.
- Cost remains a heuristic. Telemetry measures it and does not tune it.
- Hard `contract_dependency` still serializes unless the pair combines.
- Enforcement hooks do not invoke Python.

## Test Conditions to Consider

- [x] Unit coverage areas: default tolerance in the published table; aggregate cap including the `tolerance_percent` 0 identity; combination threshold boundary (just below, at, above); complexity recomputation of a combined item; telemetry recording.
- [x] Integration scenarios: a planner run with a qualifying pair produces one item; `parallel-add` against an unstarted overlap reports without combining; a combined item fails CI and remediates as one unit.
- [ ] CLI/API examples

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/parallel-scheduling-balance-speed-against-integration-cost/` folder from the template
