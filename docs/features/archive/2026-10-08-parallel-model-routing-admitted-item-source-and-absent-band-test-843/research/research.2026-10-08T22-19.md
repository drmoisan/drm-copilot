# Research: Parallel Model Routing Admitted-Item Source and Absent-Band Test (Issue #843)

- Issue: #843
- Branch: `bug/parallel-model-routing-admitted-item-source-and-absent-band-test-843`
- Work mode: minor-audit
- Requirements source: `docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/issue.md`
- Timestamp: 2026-10-08T22-19
- Method: every citation below was read with the Read/Grep tools against this worktree's checked-out tree. No shell was available to this researcher, so no command was executed and the worktree HEAD commit hash was not independently confirmed against `e7d3779b`.

## 1. Gap 1: Admitted-Item Band Source

### 1.1 Current state, `parallel-add`

- `.claude/skills/parallel-add/SKILL.md:53-62` (step 2, "Prepare the item"). Lines 59-62 read verbatim:

  > After the admitted item's preflight clearance, perform the `parallel-plan` skill's `## Complexity Assessment` procedure for it, and record the resulting `complexity_band` on the admitted orchestrator-checkpoint item so step 3's edge derivation and the parent's model routing read the same band.

- Checkpoint and key path: the skill's run state is `artifacts/orchestration/parallel-orchestrator-state.json` (`parallel-add/SKILL.md:26-27`), and step 1 adds the item to `items[]` keyed by `issue_num` (`:50-51`). The band therefore lands at `artifacts/orchestration/parallel-orchestrator-state.json` `items[<issue_num>].complexity_band`.
- `parallel-add/SKILL.md:174-175` (Constraints): "The `complexity_band` recorded in step 2 is not a new field: it is an existing scheduling field read by drift re-scheduling." `:169` states "No field and no enum member is added to `mutations[]`, `items[]`, ...".
- The field is consumed on the orchestrator checkpoint by drift scheduling: `scripts/dev_tools/_parallel_drift_scheduling.py:46-47` (`ITEM_BAND_FIELD = "complexity_band"`), `.claude/lib/parallel-drift/ParallelDrift.psm1:275`, and `.claude/rules/parallel-orchestration.md:460-463` ("using the items' complexity bands from the checkpoint (`default_band` when absent)").
- Grep of `parallel-add/SKILL.md` for `model_routing_receipt`, `parallel-planner-state`, `kickoff`, `Resolve-DelegationModel`, `complexity_to_model`: zero matches. The only band-related matches are lines 61 and 174. Confirmed.
- Ambiguity observed: step 2 directs the agent to "perform the `parallel-plan` skill's `## Complexity Assessment` procedure". That procedure (`.claude/skills/parallel-plan/SKILL.md:295-308`) also resolves a model and writes three fields (`complexity_band`, `complexity_assessment`, `model_routing_receipt`) on the planner item. `parallel-add` then says only the band is recorded on the orchestrator-checkpoint item. Whether an admitted item should carry a receipt is therefore not stated explicitly anywhere.
- The orchestrator-checkpoint validator does not reject unknown `items[]` keys (orchestrator invariants 1-21, `.claude/rules/parallel-orchestration.md:40-86`; the only "unexpected field" rejection in the parallel validators is for `mutations[]` entries, `scripts/dev_tools/_parallel_orchestrator_state_mutations.py:130-155`).

### 1.2 Current state, `parallel-orchestrate` (verbatim)

Section A, `## Parallel-Mode Kickoff Parameter`, `.claude/skills/parallel-orchestrate/SKILL.md:265-271` (line numbers unchanged from the issue):

```text
**Band and receipt source.** The parent reads each item's `complexity_band` and
`model_routing_receipt` from the planner checkpoint `artifacts/orchestration/parallel-planner-state.json`.
When the planner checkpoint is unavailable, the committed kickoff artifact's `## Item Summary`
`complexity` column is the fallback band source. The parent passes `model` equal to the receipt's
`model` when the run's `fable_policy` equals the receipt's `fable_policy`; otherwise it re-resolves
with `Resolve-DelegationModel -Agent orchestrator -Band <band> -FablePolicy <run fable_policy>` and
passes that result.
```

Section B, `## Model Selection` (heading at `:290`), `.claude/skills/parallel-orchestrate/SKILL.md:312-319`:

```text
The band and receipt for each item come from the planner checkpoint
`artifacts/orchestration/parallel-planner-state.json`: the parent reads the item's `complexity_band`
and `model_routing_receipt` there. When the planner checkpoint is unavailable, the committed kickoff
artifact's `## Item Summary` `complexity` column is the fallback band source. The parent passes
`model` equal to the receipt's `model` when the run's `fable_policy` equals the receipt's
`fable_policy`; otherwise it re-resolves with
`Resolve-DelegationModel -Agent orchestrator -Band <band> -FablePolicy <run fable_policy>` and
passes that result.
```

Related text: `:261-263` (spawn parameter `model` "equal to that item's model routing receipt's resolved model"); `:301-302` (names `Get-ComplexityFloor` and `Resolve-DelegationModel` in `.claude/lib/model-routing/ModelRouting.psm1` as "canonical, tested reference implementations"); `:305-310` (MUST NOT omit `model`; omission falls back to frontmatter `opus`). Neither section A nor B mentions `parallel-orchestrator-state.json` or `/parallel-add`. Grep for "complexity" in the skill matches only lines 265, 268, 299, 313, 315.

### 1.3 Third location not named in the issue: the agent persona

`.claude/agents/parallel-orchestrator.md:179-185` (`## Delegation Model`, heading at `:169`) restates the same source:

```text
- `model` — read the item's `complexity_band` and `model_routing_receipt` from the planner
  checkpoint `artifacts/orchestration/parallel-planner-state.json`; when that checkpoint is
  unavailable, use the committed kickoff artifact's `## Item Summary` `complexity` column as the
  fallback band source. Pass the receipt's `model` when the run's `fable_policy` equals the
  receipt's `fable_policy`; otherwise re-resolve with
  `Resolve-DelegationModel -Agent orchestrator -Band <band> -FablePolicy <run fable_policy>` and
  pass that result, per the skill's `## Model Selection` section.
```

A contract test pins this section (Section 1.7). Leaving it unchanged would leave the persona and the skill inconsistent for admitted items, so it should change with the skill.

### 1.4 Can `parallel-orchestrator` execute `Resolve-DelegationModel`?

- Tool allowlist, `.claude/agents/parallel-orchestrator.md:5-28`. Bash grants: `git *`, `gh *`, `poetry run python -c *`, `poetry run python -m *`, four `bash .claude/lib/bash/...sh*` scripts, `pwsh -NoProfile -File .claude/lib/project-file-merge/Resolve-MergeableConflict.ps1*`, `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1*`, and three `dotnet` patterns. There is no grant that imports `.claude/lib/model-routing/ModelRouting.psm1`. Verified by reading.
- `parallel-add` has `agent: parallel-orchestrator` (`parallel-add/SKILL.md:5-6`), so it runs under the same allowlist. Its own step 3 prescribes `pwsh` + `Import-Module ... BlastRadius.psm1` (`:64-70`), which this allowlist also does not literally grant. The #532 spec Follow-up 4 (`docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532/spec.md:209`) records the same `pwsh` grant question for `parallel-planner` only; it does not cover `parallel-orchestrator`.
- Python alternative: `scripts/dev_tools/resolve_delegation_model.py:79-140` is reachable under `Bash(poetry run python -c *)` in this repository (single-line `-c` only). Whether `scripts/dev_tools/` is present in push-down destination workspaces was not verified.
- Execution is not required for the `orchestrator` agent. `resolve_delegation_model` (`resolve_delegation_model.py:115-139`) applies the preferred overlay only when `agent in PREFERRED_OVERLAY_AGENTS` (`:71-73`: `atomic-planner`, `prd-feature`, `feature-review`, `task-researcher`); `orchestrator` is not in the set (also `config/orchestration-routing.json:199-209`). For `agent == "orchestrator"` the result is therefore exactly the base table `config/orchestration-routing.json:193-198` (`C1` haiku, `C2` sonnet, `C3` opus, `C4` fable) with the disabled clamp (`fable` becomes `opus` when `fable_policy == "disabled"`, `resolve_delegation_model.py:126-132`; `ModelRouting.psm1:211`). The run default is `model_budget.fable_policy: "available"` (`config/orchestration-routing.json:211-214`), and the kickoff marker default is `disabled` when absent (`parallel-orchestrate/SKILL.md:302-303`). The agent can perform this lookup with its `Read` grant.

### 1.5 Option evaluation

Option A: `parallel-orchestrate` names the orchestrator-checkpoint `items[].complexity_band` as the admitted-item band source and resolves `model` at spawn time.

- Advantages: the band is already recorded there by `parallel-add` step 2 and already consumed there by drift scheduling, so no field and no schema change is introduced. It is consistent with the `parallel-add` constraint at `:169` (no field added to `items[]`). Resolution at spawn time always uses the run's current `fable_policy`, so the receipt-equality branch never applies and no stale receipt can exist. The resolution is a table read plus a clamp that the agent can perform with `Read` alone (Section 1.4). Changes are confined to Markdown procedure text plus mirrors and contract tests.
- Limitations: an admitted item has no `model_routing_receipt` anywhere, so there is no durable record of the resolved model for that spawn. The #532 spec Follow-up 1 (spawn-receipt recording) already tracks that gap for all items, so this is not a regression introduced here.

Option B: `/parallel-add` records a `model_routing_receipt` on the orchestrator-checkpoint item at admission.

- Limitations: it adds a field to `items[]`, contradicting `parallel-add/SKILL.md:169` and requiring that constraint and the `:174-175` note to be rewritten. `parallel-orchestrate` sections A and B would still need to change, because they name only the planner checkpoint as the receipt source, so B is a superset of A's edits. Producing the receipt at admission requires the same resolution, so B gains no capability over A. The receipt can go stale if `fable_policy` differs at spawn time, which reintroduces the re-resolve branch.

Recommendation: Option A. It changes the smallest surface, adds no field, needs no tool grant the agent lacks, and B would require A's edits anyway.

### 1.6 Proposed design (Option A)

1. `.claude/skills/parallel-orchestrate/SKILL.md`, sections A (`:265-271`) and B (`:312-319`): add one rule to each. When an item is absent from the planner checkpoint's `items[]` (an item admitted through `/parallel-add`, which also has no `## Item Summary` row), the band source is that item's `complexity_band` on the orchestrator checkpoint `artifacts/orchestration/parallel-orchestrator-state.json` `items[]`. Such an item carries no `model_routing_receipt`, so the parent resolves `model` at spawn time as `model_policy.complexity_to_model[<band>]` from `config/orchestration-routing.json` under the run's `fable_policy`, with `fable` clamped to `opus` when `fable_policy` is `disabled`. The text should state that this equals `Resolve-DelegationModel -Agent orchestrator -Band <band> -FablePolicy <run fable_policy>` because `preferred_overlay.agents` does not include `orchestrator`. State the fail-closed case explicitly: if the admitted item has no `complexity_band` on the orchestrator checkpoint, the parent stops rather than spawning without `model`, consistent with `:305-310`.
2. `.claude/agents/parallel-orchestrator.md:179-185`: add the same admitted-item clause to the `model` bullet.
3. `.claude/skills/parallel-add/SKILL.md:59-62`: optional, recommended one-clause clarification. The admitted item records `complexity_band` only, no `model_routing_receipt`, and the parent resolves the model from that band at spawn time per `parallel-orchestrate` `## Model Selection`. This removes the ambiguity noted in Section 1.1.
4. Mirror each edited file byte-for-byte under `extensions/drm-copilot/resources/claude-customizations/` (Section 1.8).

Authoring constraints from existing contract tests:

- `tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py:86-110` with `parallel_orchestrator_permission_seam_support.py:457-496` treats every backticked span with a space whose first token matches `^[a-z][a-z0-9-]*$` as a command that needs a persona `Bash(...)` grant. Do not add a backticked lowercase-led command such as `pwsh ...` to `parallel-orchestrate/SKILL.md`. `Resolve-DelegationModel ...` is uppercase-led and is not matched.
- `:59-84` with `parallel_orchestrator_permission_seam_support.py:331-378` checks write targets. A path that follows a write verb or `to`/`into`/`under` must be covered by a `Write(...)` grant. `artifacts/orchestration/**` is granted (`parallel-orchestrator.md:12`), so naming the orchestrator checkpoint is safe either way.
- `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:208-224` pins the first thirteen skill headings (`parallel_orchestrator_surface_expectations.py:55-69`) and `:177-189` pins the nine agent headings (`:42-52`). Add no heading. The digest pin (`expectations.py:154-163`) covers only the epic files and is unaffected.

### 1.7 Existing tests that assert on these files' content

| File | Assertion relevant here |
| --- | --- |
| `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py:104-121` | `## Model Selection` of `parallel-orchestrate` contains `artifacts/orchestration/parallel-planner-state.json`, `model_routing_receipt`, `complexity_band`, `## Item Summary`, `` `complexity` column ``. |
| same file `:124-135` | Agent `## Delegation Model` contains the planner checkpoint, `model_routing_receipt`, `` `complexity` column ``. |
| same file `:138-154` | `parallel-add` step 2 (between `2. **Prepare the item.**` and `3. **Compute conflict edges`) contains `## Complexity Assessment` and `complexity_band`; `## Constraints` contains `complexity_band` and `existing scheduling field`. |
| `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` (with `parallel_orchestrator_surface_expectations.py`) | Heading layout, section fragments, kickoff markers (`:177-312`). |
| `tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py:59-150` | Write-target and command-invocation grant coverage for `parallel-orchestrate`. |
| Other files that reference these skills (grep hit; content relevance not inspected): `test_parallel_planner_surface_contracts.py`, `test_parallel_mutation_admission.py`, `test_completion_gate_documentation_contracts.py`, `test_orchestrator_state_remediation_docs.py`, `test_claude_rules_frontmatter.py`, `test_blast_radius_config_parity.py`, `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`. | Re-run them after the edit. |

No Pester, jest, or bats test was found that pins the band-source text. The new contract assertions belong in `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py`, using its `section`/`between`/`collapse` helpers:

- Extend or add a test asserting that `## Model Selection` contains `artifacts/orchestration/parallel-orchestrator-state.json`, `/parallel-add`, and `complexity_to_model`. Optionally apply the same assertion to the `**Band and receipt source.**` paragraph via `between(text, "**Band and receipt source.**", "\n\n")`.
- Add the same tokens to the agent `## Delegation Model` test.
- If the `parallel-add` clarification is made, assert that step 2 contains `parallel-orchestrate` and `## Model Selection` (or "spawn time").

The existing token assertions remain valid under Option A because the planner-checkpoint text is retained.

### 1.8 Mirrors and parity

- Mirrors exist at `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`, `.../parallel-orchestrate/SKILL.md`, and `.../.claude/agents/parallel-orchestrator.md`. Grep shows the same line numbers for the cited passages (orchestrate 266/313, agent 180, add 61/174), which suggests they are currently identical. A full byte diff was not run.
- Enforcement: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`). For every distributable repo `.claude/**` file, it asserts presence in the bundle and `read_text(..., encoding="utf-8")` equality. This is text equality with universal-newline translation, not strict bytes. Copy verbatim. Local-only paths (`.claude/agent-memory/**`, `.claude/state/**`, `.claude/worktrees/**`, `.claude/settings.local.json`) are exempt through `filter_distributable_claude_paths` (`:8`, `:101`). Per project memory (issue #510), this test can fail locally on gitignored state while passing in CI. Check any local failure against the file named in the assertion message.
- `.github/`: grep for `parallel-add|parallel-orchestrate` under `.github` returns zero files. No Copilot-native mirror exists. Glob found no `parallel*` path under `.agents/` or `.codex/`. No Codex mirror needs to change.
- `config/orchestration-routing.json` is not edited under Option A, so its push-down carriage is unaffected.

## 2. Gap 2: Absent-Band Test

### 2.1 Existing absent-band tests (all three routing fields deleted together)

- Python `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py:137-152`, `test_ready_gate_rejects_item_without_band_assessment_or_receipt`: deletes each of `ROUTING_FIELDS` (`:107`) from item 0, validates with `ready=True`, asserts `BAND_ABSENT`, `ASSESSMENT_NOT_OBJECT`, `RECEIPT_NOT_OBJECT` in errors. The issue cited `:135-152`; the current start is `:137`.
- Python `:357-378`, `test_p10_errors_follow_p7_errors_for_same_item`: deletes all three plus sets P7 failures and asserts ordering. The issue cited `:358-375`.
- TypeScript `extensions/drm-copilot/test/lib/validate/parallel-planner-state-routing.test.ts:92-108`: `it("rejects an item without band, assessment, or receipt under the ready gate (fail-before)")`. It deletes the three keys and expects `arrayContaining([BAND_ABSENT, ASSESSMENT_NOT_OBJECT, RECEIPT_NOT_OBJECT])`. TS `:161-187` is the P7-ordering analogue.

### 2.2 Checks 1, 5, 9 and their messages

The authority is `.claude/rules/parallel-orchestration.md:110` (P10 check order).

Python `scripts/dev_tools/_parallel_planner_state_routing.py`:

- Check 1, `:230-232`: `enum_error(entry_context, "complexity_band", BAND_ORDER, band)`. `enum_error` (`scripts/dev_tools/_parallel_state_common.py:205-227`) renders `f"{context} {field} must be one of {', '.join(members)}; found: {value!r}."`, and `repr(None)` is `None`.
- Check 5, `:144-151`: `f"{context}.band {assessed_band!r} does not equal complexity_band {band!r}."` with `context = f"{entry_context} complexity_assessment"`.
- Check 9, `:188-193`: `f"{context}.complexity_band {receipt_band!r} does not equal complexity_band {band!r}."` with `context = f"{entry_context} model_routing_receipt"`.

TypeScript `extensions/drm-copilot/src/lib/validate/parallel-planner-state-routing.ts`:

- Check 1, `:206-209`: `enumError(entryContext, "complexity_band", BAND_ORDER, band)`. `enumError` (`parallel-state-shared.ts:212-219`) uses `pythonRepr(value)`, and `pythonRepr` (`:112-115`) returns `"None"` for both `null` and `undefined`.
- Check 5, `:135-140`: guarded by `!sameValue(assessedBand, band)`, rendered with `pythonRepr`.
- Check 9, `:172-176`: guarded by `!sameValue(receiptBand, band)`, rendered with `pythonRepr`.

`None` rendering parity: an absent key is `None` via `dict.get` in Python and `undefined` in TS, and both render `None`. Parity holds by reading. It was not confirmed by execution.

P3 does not double-report an absent band. Python `validate_parallel_planner_state.py:243-252` and TS `parallel-planner-state-core.ts:258-273` both gate the P3 enum check on key presence (`"complexity_band" in record`). The existing C9 test at `:336-354` / TS `:132-145` counts check 1 twice only because the key is present.

### 2.3 Fixture and exact expected literals

There is no shared JSON corpus. Grep for `model_routing_receipt` in `tests/**/*.json` and `extensions/drm-copilot/test/**/*.json` finds only orchestrator-state and blast-radius fixtures. "Shared literal" here means the same constant strings duplicated in both test files (Python docstring `:7-8`; TS header `:6-9`). The builders are `tests/scripts/dev_tools/parallel_planner_state_builders.py:23-51` (`build_routing_fields`, `build_valid_planner_state`) and `extensions/drm-copilot/test/lib/validate/parallel-state-test-support.ts:46-62` (`buildPlannerRoutingFields`). In both, item band is `C3`, assessment band is `C3`, the receipt is `{agent: orchestrator, phase: execution, complexity_band: C3, fable_policy: available, table_model: opus, clamped_from: null, model: opus}`, and it validates with zero errors.

Minimal modification: start from the builder state (or `build_routing_fields()` / `buildPlannerRoutingFields()` for the direct call) and delete only `complexity_band` (Python `del item["complexity_band"]`; TS `delete item["complexity_band"]`). Use `delete` rather than assigning `undefined` in TS, so the key is absent in both the direct-call and the serialized full-state paths and the input shape matches Python's `del` exactly.

The derived expected errors are exactly these three, in this order. They come from both the direct `validate_ready_item_routing(record, CTX)` / `validateReadyItemRouting(record, CTX)` call and the full ready-gate validation, because the rest of the builder state is valid and checks 3, 4, 7, 8, and 10 pass:

```text
Parallel planner checkpoint items[0] complexity_band must be one of C1, C2, C3, C4; found: None.
Parallel planner checkpoint items[0] complexity_assessment.band 'C3' does not equal complexity_band None.
Parallel planner checkpoint items[0] model_routing_receipt.complexity_band 'C3' does not equal complexity_band None.
```

The first is the existing `BAND_ABSENT` constant in both files (Python `:38-41`, TS `:22-23`). Because the list is fully determined, the new case can assert exact list equality rather than membership, which also pins order and the absence of a P3 duplicate. These literals were derived by reading the code and were not produced by execution.

### 2.4 `sameValue` branch arms

`sameValue` is at `parallel-planner-state-routing.ts:59-61`; the body line is `:60`: `return JSON.stringify(left ?? null) === JSON.stringify(right ?? null);`. The #532 evidence (`.../532/evidence/qa-gates/ts-jest-coverage.2026-10-02T05-19.md:11-13`) records branches 92.59% (25/27) with uncovered line 60. The two `??` operators contribute the uncovered nullish-fallback arms.

- The absent-band shape makes `right` (`band`) `undefined` in both check 5 and check 9 calls. It exercises the `right ?? null` fallback arm.
- It does not exercise the `left ?? null` fallback arm, because `assessedBand` and `receiptBand` remain `'C3'`. The issue's statement that both uncovered arms correspond to this input shape is not supported by reading the code. This is an inference, not verified by a coverage run.
- To cover the left arm as well, a second shared-literal case is needed. It would keep the item band and delete the receipt's `complexity_band` (or the assessment's `band`). The derived literals for deleting the receipt `complexity_band` from `build_routing_fields()` (direct call):
  - Check 7. Python goes through the helper (`_orchestrator_state_model_routing.py:140-145`, `got: {band}` with `str(None)`) and the prefix rewrite. TS uses `:161-165` with `pythonStr(undefined)`. Both give `Parallel planner checkpoint items[0] model_routing_receipt complexity_band must be one of C1, C2, C3, C4; got: None.`
  - Check 9 gives `Parallel planner checkpoint items[0] model_routing_receipt.complexity_band None does not equal complexity_band 'C3'.`
  - Whether to include this second case is a scope decision for the planner. Without it, branch coverage is expected to move from 25/27 to 26/27 (unverified).

## 3. Toolchain Commands and Baselines

None of these commands was run by this researcher (no shell tool was available). They are listed for the plan.

- Python unit, with branch coverage on the dotted module (path-form `--cov` measures nothing, per project memory):
  `poetry run pytest tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py --cov=scripts.dev_tools._parallel_planner_state_routing --cov-branch --cov-report=term-missing`
  The `pyproject.toml:116` addopts adds `--cov-report=lcov:artifacts/python/lcov.info`, and `[tool.coverage.run]` (`:119-127`) has no `branch = true`, so `--cov-branch` is required for a branch figure.
- Skill contract and permission tests:
  `poetry run pytest tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py tests/scripts/dev_tools/test_parallel_mutation_admission.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`
- Bundle parity:
  `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
  (the parity case is `test_bundled_claude_payload_contains_all_repo_runtime_contracts`; add `-k all_repo_runtime_contracts` to isolate it).
- TypeScript unit, pass/fail:
  `npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/parallel-planner-state-routing.test.ts`
  (`run-jest.cjs` forwards arguments and rejects `--passWithNoTests`/`--onlyChanged`/`--lastCommit`, `:9-19`).
- TypeScript coverage: `jest.config.cjs:17` collects coverage from all `src/**/*.ts`, and `:25` onward defines per-file `coverageThreshold` entries, including `./src/lib/validate/parallel-planner-state-routing.ts` at lines 85 / branches 75 (`:286-289`). A coverage run scoped to one test file is therefore expected to fail other files' per-file thresholds (inferred; consistent with the project-memory "jest thresholds" preflight defect class). Use the full-suite form recorded in the #532 evidence:
  `npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text --coverageReporters=json-summary`
  Then read `src/lib/validate/parallel-planner-state-routing.ts` from `extensions/drm-copilot/coverage/coverage-summary.json`.
- Baseline from prior evidence (not re-run): routing module lines 100% (225/225), branches 92.59% (25/27), uncovered line 60 (#532 evidence file cited in 2.4).
- No Pester or bats test pins the edited skill text, so no Pester/bats command is required for the contract assertions. `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1` references the parallel skills; its relevance to the edited sections was not inspected.

## 4. Requirements Mapping

| Issue expectation | Design | Files |
| --- | --- | --- |
| `parallel-orchestrate` names a band source for an admitted item | Option A rule in sections A and B; agent `## Delegation Model` aligned; optional `parallel-add` step 2 clarification | `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/agents/parallel-orchestrator.md`, optionally `.claude/skills/parallel-add/SKILL.md`, plus three mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/` |
| Contract test pins the admitted-item source | New tokens in `test_parallel_complexity_routing_contracts.py` (Section 1.7) | `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py` |
| Shared-literal absent-band case in both runtimes | Delete only `complexity_band`; assert the exact three-string list (Section 2.3) | `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py`, `extensions/drm-copilot/test/lib/validate/parallel-planner-state-routing.test.ts` |
| (Optional) cover the remaining `sameValue` arm | Second case deleting the receipt `complexity_band` (Section 2.4) | same two test files |

No production code changes are required for gap 2. Both validators already emit the expected strings by reading.

## 5. Testing Implications

- Test-only additions for gap 2. Follow the Arrange-Act-Assert layout and the existing naming style in each file. Add each new literal as a module constant mirrored in both files.
- Contract assertions for gap 1 are text-fragment tests over whitespace-collapsed sections, matching the existing convention of `test_parallel_complexity_routing_contracts.py:1-10`.
- After editing the mirrors, run the bundle-parity test and the permission-contract test (Section 3).
- The integration scenario in the issue (admit an item mid-run and confirm the spawn `model`) is a manual verification. No automated harness for live `Agent` spawns was found.

## Numeric Derivation Evidence

This research proposes no numeric count, enumeration, or population for a `spec.md` acceptance criterion. The figures above (25/27 branches, three expected error strings, three mirror files) are either prior-evidence citations or descriptive design notes, not proposed numeric acceptance criteria. If the spec turns any of them into a numeric criterion, it needs a primary and cross-check derivation first.

## Rejected Alternatives

- Option B (receipt recorded by `/parallel-add`): it adds an `items[]` field against `parallel-add/SKILL.md:169`, still requires Option A's `parallel-orchestrate` edits, and the receipt can go stale under a `fable_policy` change.
- Adding a `pwsh` `ModelRouting.psm1` grant to `parallel-orchestrator`: not needed for `agent == "orchestrator"` (no overlay applies), and it widens the tool surface. This remains within the scope of #532 Follow-up 4.
