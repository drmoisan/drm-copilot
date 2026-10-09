# parallel-model-routing-admitted-item-source-and-absent-band-test (Issue #843)

- Date captured: 2026-10-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-model-routing-admitted-item-source-and-absent-band-test/ (Issue #843)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #843
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/843
- Last Updated: 2026-10-08
- Work Mode: minor-audit

## Summary

Two gaps remain after #532 (merged in the bug-burndown-2026-09-29 parallel run). First, an item admitted mid-run through `/parallel-add` has no defined source for its model routing: `parallel-add` records `complexity_band` on the orchestrator checkpoint, but `parallel-orchestrate` names only the planner checkpoint and the kickoff `## Item Summary` `complexity` column as band sources, and an admitted item appears in neither and carries no `model_routing_receipt`. Second, no test in either runtime covers an item whose `complexity_band` is absent while `complexity_assessment` and `model_routing_receipt` are present.

## Environment

- OS/version: Windows 11 Pro; any
- Python version: repository Poetry environment (Python validator); TypeScript validator under `extensions/drm-copilot`
- Command/flags used: `/parallel-add` during a running parallel run; `poetry run pytest tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py`; `npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/parallel-planner-state-routing.test.ts`
- Data source or fixture: origin/main at fb413fce; #532 code review `docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532/code-review.2026-10-02T05-30.md` lines 42-43

## Steps to Reproduce

1. Read `.claude/skills/parallel-add/SKILL.md` lines 59-62: step 2 records the admitted item's `complexity_band` on the orchestrator-checkpoint item "so step 3's edge derivation and the parent's model routing read the same band".
2. Read `.claude/skills/parallel-orchestrate/SKILL.md` lines 265-271 and 312-319: the parent reads `complexity_band` and `model_routing_receipt` from `artifacts/orchestration/parallel-planner-state.json`, with the kickoff `## Item Summary` `complexity` column as the only fallback. Neither section names the orchestrator checkpoint.
3. Search `.claude/skills/parallel-add/SKILL.md` for `model_routing_receipt`, `parallel-planner-state`, and `kickoff`: no match.
4. Read the absent-band tests: `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py:135-152` and `:358-375`, and `extensions/drm-copilot/test/lib/validate/parallel-planner-state-routing.test.ts:91-106`. Each deletes all three routing fields together.

## Expected Behavior

- `parallel-orchestrate` names a band source for an item admitted through `/parallel-add` (for example the orchestrator-checkpoint `items[].complexity_band`, with spawn-time `Resolve-DelegationModel` re-resolution), or `/parallel-add` records a `model_routing_receipt` at admission.
- Both runtimes have a shared-literal case for an item whose `complexity_band` is absent while `complexity_assessment` and `model_routing_receipt` are present, pinning check 1 (`found: None.`) and the `complexity_band None.` rendering of checks 5 and 9.

## Acceptance Criteria

- [ ] AC-1: `.claude/skills/parallel-orchestrate/SKILL.md` states, in the `**Band and receipt source.**` paragraph of `## Parallel-Mode Kickoff Parameter` and in the band/receipt paragraph of `## Model Selection`, that for an item admitted through `/parallel-add` (absent from the planner checkpoint `artifacts/orchestration/parallel-planner-state.json` `items[]` and from the kickoff `## Item Summary`), the band source is that item's `complexity_band` on the orchestrator checkpoint `artifacts/orchestration/parallel-orchestrator-state.json` `items[]`; that such an item carries no `model_routing_receipt`, so the parent resolves `model` at spawn time as `model_policy.complexity_to_model[<band>]` from `config/orchestration-routing.json` under the run's `fable_policy`, with `fable` clamped to `opus` when `fable_policy` is `disabled` (equivalent to `Resolve-DelegationModel -Agent orchestrator -Band <band> -FablePolicy <run fable_policy>` because `preferred_overlay.agents` does not include `orchestrator`); that the spawn passes this explicit `model` rather than relying on the frontmatter default; and that the parent stops rather than spawning without `model` when the admitted item has no `complexity_band` on the orchestrator checkpoint. The existing planner-checkpoint and `## Item Summary` `complexity` column text is retained, no heading is added, and no backticked lowercase-led command (for example `pwsh ...`) is introduced.
- [ ] AC-2: `.claude/agents/parallel-orchestrator.md` `## Delegation Model` `model` bullet carries the same admitted-item rule as AC-1: orchestrator-checkpoint `artifacts/orchestration/parallel-orchestrator-state.json` `items[].complexity_band` as the band source for an item admitted through `/parallel-add`, spawn-time resolution from `complexity_to_model` in `config/orchestration-routing.json` with the `fable_policy: disabled` clamp to `opus`, and an explicit `model` on the spawn. The existing planner-checkpoint text is retained and no heading is added.
- [ ] AC-3: If `.claude/skills/parallel-add/SKILL.md` is edited, the edit is confined to step 2 (`2. **Prepare the item.**`) and adds only a clarifying clause stating that the admitted item records `complexity_band` and no `model_routing_receipt`, and that the parent resolves the model from that band at spawn time per `parallel-orchestrate` `## Model Selection`. No field is added to `items[]`, and the `## Constraints` statements that no `items[]` field is added and that `complexity_band` is an `existing scheduling field` remain unchanged.
- [ ] AC-4: Each edited `.claude/` file has a mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/` whose text equals its source, and `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes, including `test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- [ ] AC-5: `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py` contains assertions that pin the admitted-item source text in each edited surface: `## Model Selection` of `parallel-orchestrate` and the agent `## Delegation Model` each contain `artifacts/orchestration/parallel-orchestrator-state.json`, `/parallel-add`, and `complexity_to_model`; the `**Band and receipt source.**` paragraph of `parallel-orchestrate` contains the same tokens; and, if the AC-3 clarification is made, `parallel-add` step 2 contains `parallel-orchestrate` and `## Model Selection`. The existing assertions in that file continue to pass unmodified.
- [ ] AC-6: `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py` and `extensions/drm-copilot/test/lib/validate/parallel-planner-state-routing.test.ts` each contain a case that starts from the valid builder routing fields (`build_routing_fields()` / `buildPlannerRoutingFields()`) and deletes only the item's `complexity_band` key (Python `del`, TypeScript `delete`), leaving `complexity_assessment` and `model_routing_receipt` present, and asserts exact ordered list equality of the validator errors against the following literals, defined as identical module constants in both test files:
  - `Parallel planner checkpoint items[0] complexity_band must be one of C1, C2, C3, C4; found: None.`
  - `Parallel planner checkpoint items[0] complexity_assessment.band 'C3' does not equal complexity_band None.`
  - `Parallel planner checkpoint items[0] model_routing_receipt.complexity_band 'C3' does not equal complexity_band None.`
- [ ] AC-7: Both test files named in AC-6 each contain a second case that starts from the valid builder routing fields, keeps the item's `complexity_band`, deletes only the `model_routing_receipt`'s `complexity_band` key, and asserts that the validator errors include each of the following literals, defined as identical module constants in both test files:
  - `Parallel planner checkpoint items[0] model_routing_receipt complexity_band must be one of C1, C2, C3, C4; got: None.`
  - `Parallel planner checkpoint items[0] model_routing_receipt.complexity_band None does not equal complexity_band 'C3'.`
- [ ] AC-8: The affected suites pass: `poetry run pytest tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py tests/scripts/dev_tools/test_parallel_mutation_admission.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` and the full-suite `npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text --coverageReporters=json-summary` run. Line coverage is >= 85% and branch coverage is >= 75% for `scripts/dev_tools/_parallel_planner_state_routing.py` (measured with `--cov=scripts.dev_tools._parallel_planner_state_routing --cov-branch`) and for `extensions/drm-copilot/src/lib/validate/parallel-planner-state-routing.ts` (read from `extensions/drm-copilot/coverage/coverage-summary.json`), with no regression from the pre-change baseline for either module. The permission-contract test (backticked lowercase-command rule) passes.

### Assumptions

- Option A from `research/research.2026-10-08T22-19.md` Section 1.5 (orchestrator-checkpoint `complexity_band` with spawn-time resolution) was selected over Option B (`/parallel-add` records a `model_routing_receipt`) on the research recommendation. The operator was not consulted on this choice.
- The AC-7 case is included because the issue's stated goal is parity pinning of these rendering paths; the research left it as a planner scope decision.
- All expected literals in AC-6 and AC-7 were derived by the research from reading the validator code, not from execution. AC-6 asserts exact ordered equality because the research states the error list is fully determined for that input. AC-7 asserts inclusion only, because the research did not establish that its listed literals are the complete error list for that input.
- The `parallel-add` clarification (AC-3) is optional; AC-3 and the corresponding AC-5 clause apply only if that file is edited.
- The issue's integration scenario (admitting an item in a live run and observing the spawn `model`) remains a manual verification and is not an acceptance criterion, because no automated harness for live `Agent` spawns exists.
- No production validator code change is expected for gap 2.

## Actual Behavior

- No band or receipt source is named for an admitted item. The parent may fall back to the `opus` frontmatter default for such items, which is the defect class #532 addressed for planned items. This was established by reading both skills; it was not reproduced in a live run.
- The absent-band case is only tested with all three fields deleted. The TypeScript code review recorded the two uncovered branch arms of `sameValue` (`extensions/drm-copilot/src/lib/validate/parallel-planner-state-routing.ts:59-61` on main; line 60 in the review) as corresponding to this input shape (`evidence/qa-gates/ts-jest-coverage.2026-10-02T05-19.md` in the #532 folder). Branch coverage is 92.59%, so this is a parity-pinning gap, not a threshold gap.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `parallel-add/SKILL.md:61-62`: "record the resulting `complexity_band` on the admitted orchestrator-checkpoint item so step 3's edge derivation and the parent's model routing read the same band." `parallel-orchestrate/SKILL.md:265-266`: "The parent reads each item's `complexity_band` and `model_routing_receipt` from the planner checkpoint `artifacts/orchestration/parallel-planner-state.json`." Verified by reading main at fb413fce.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

An item admitted mid-run can be routed on the default model rather than its assessed band. The test gap does not affect current behavior; it leaves the `None` rendering of checks 5 and 9 unpinned across runtimes.

## Suspected Cause / Notes

- Originating item: #532 (bug-burndown-2026-09-29 parallel run). Both findings are the two Minor (Non-blocking) rows of `code-review.2026-10-02T05-30.md` (lines 42-43), which states they "are suitable for follow-up and do not block this issue's acceptance criteria" (line 137). The run notes record the same two follow-ups for item 532.
- `issue.md` line 149 in the #532 folder left "Consider whether `/parallel-add` needs the same treatment" unchecked.
- Related but separate: spec Follow-ups 1-5 in the #532 `spec.md` (spawn-receipt recording, TypeScript port of floor/model resolution, re-assessment after plan amendment, `pwsh` grant, epic surface). Those are not part of this entry.
- No open issue covers either gap (checked `gh issue list --state open` on 2026-10-08).

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: add one shared-literal case per runtime (Python `test_validate_parallel_planner_state_routing.py`, TypeScript `parallel-planner-state-routing.test.ts`) for absent band with assessment and receipt present.
- [ ] Integration scenario to retest: admit an item through `/parallel-add` in a running parallel run and confirm the model passed on its `Agent(orchestrator)` spawn matches its assessed band.
- [ ] Manual verification notes: amend `parallel-orchestrate/SKILL.md` (both sections) and its mirrors under `extensions/drm-copilot/resources/claude-customizations/`, and the `parallel-add` contract tests, to name the admitted-item source.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
