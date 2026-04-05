# 2026-03-14-orchestrator-not-following-sequential-tasks (Spec)

- **Issue:** #101
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-14T18-08
- **Status:** Draft
- **Version:** 0.1

## Context
When `csharp-orchestrator` classifies a request as the small path, it skips the mandatory short-path promotion/folder lifecycle and delegates straight to `csharp-atomic-planning` (and then execution). This bypass leaves the orchestration variables unset, prevents potential/issue/folder artifacts from being created, and violates the repository’s shared `feature-promotion-lifecycle` contract for short-path work.

Environment:
- OS/version: Windows (user environment on 2026-03-14; exact version not captured in prompt transcript)
- Python version: N/A — failure occurs in C# orchestration workflow, not Python execution
- Command/flags used: `/orchestrate-csharp-work In the current add-in, when I click the Sort Email button, it automatically begins the form applying Dark Mode. This add-in should be able to detect whether the system is in Dark Mode or Light Mode and follow the system. Please create this functionality and orchestrate the work to completion`
- Data source or fixture: `.github/agents/csharp-orchestrator.agent.md`, `.github/prompts/orchestrate-csharp-work.prompt.md`, `.github/skills/feature-promotion-lifecycle/SKILL.md`, and `artifacts/orchestration/csharp-orchestrator-state.json`

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Invoke `csharp-orchestrator` through `.github/prompts/orchestrate-csharp-work.prompt.md` with a small, bounded C# request (for example, the Dark Mode detection request that was estimated at 2 production C# files and 1 test file).
2. Allow the orchestrator to complete budget estimation and route to the small path.
3. Observe the next action and the resulting checkpoint state.
4. Confirm that the orchestrator delegates directly to `csharp-atomic-planning`, then to `csharp-atomic-executor`, without first creating/filling a potential entry, promoting to issue, creating a branch, or creating an active feature folder.
5. Inspect `artifacts/orchestration/csharp-orchestrator-state.json` and confirm that `${promotion-type}`, `${short-name}`, `${relativeFile}`, `${long-name}`, `${issue-num}`, and `${feature-folder}` all remain `null` even though the workflow is marked complete.

Expected:
After choosing the small path, the orchestrator should still follow the mandatory short-path sequence defined by the shared lifecycle rules: establish classification variables, create/fill the potential entry, promote with `minor-audit` mode, create the branch and active feature folder, then hand off to planning/execution using the generated artifacts and persisted variables. At minimum, the orchestrator should not report completion while the required orchestration variables and feature artifacts were never created.

Actual:
The orchestrator routed directly from budget estimation to `csharp-atomic-planning`, followed by `csharp-atomic-executor`, and then marked the mission complete. The checkpoint shows:

- `"path_selected": "small"`
- `"completed_steps": ["phase-0-intake", "budget-estimate", "delegate-csharp-atomic-planning", "delegate-csharp-atomic-executor"]`
- all lifecycle variables still `null` (`promotion-type`, `short-name`, `relativeFile`, `long-name`, `issue-num`, `feature-folder`)

This means the orchestrator never performed the mandatory sequential lifecycle steps before planning/execution.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet:

	From `.github/agents/csharp-orchestrator.agent.md` small path:
	`1. Delegate to csharp-atomic-planning via handoff Build C# atomic plan (preflight all clear).`

	From `.github/skills/feature-promotion-lifecycle/SKILL.md` canonical short path:
	`When orchestrator routing selects short path, promotion/folder initialization still occurs and MUST use minor-audit mode.`

	From `artifacts/orchestration/csharp-orchestrator-state.json` after the run:
	`"promotion-type": null,`
	`"short-name": null,`
	`"relativeFile": null,`
	`"long-name": null,`
	`"issue-num": null,`
	`"feature-folder": null`


## Scope & Non-Goals
- In scope:
	- Align the root C# small-path orchestration contract with the repository’s canonical short-path lifecycle already used by the generic, Python, and PowerShell orchestrators.
	- Require the C# small path to perform promotion and active-folder initialization in `minor-audit` mode before any planning or execution handoff.
	- Extend the documented C# checkpoint/state contract so short-path runs persist `${plan-path}`, `work-mode`, and enough Phase 0 / bootstrap continuity to resume deterministically.
	- Restore root-to-bundled customization parity for every changed C# agent/prompt/skill file under `extensions/drm-copilot/resources/customizations/.github/...`.
	- Add deterministic regression coverage that fails if the C# small-path sequence, minor-audit invariants, or bundled-mirror parity regress.
- Out of scope / non-goals:
	- Redesigning the large-path C# orchestration flow; large-path promotion, research, spec, planning, execution, and review remain as currently defined unless directly needed for shared checkpoint compatibility.
	- Changing the change-budget thresholds (`1-3` production files = small path, `>3` = large path).
	- Broadly remediating similar prompt drift in Python or PowerShell orchestration files during this fix; those are follow-up candidates, not part of issue #101.
	- Introducing new runtime services, network calls, telemetry backends, or feature flags.
- Explicitly excluded systems, integrations, or datasets:
	- GitHub issue content beyond the already-promoted local feature docs for issue #101.
	- Unrelated extension command surfaces or VS Code activation behavior.
	- Any repository data migration unrelated to the C# orchestration checkpoint JSON and markdown customization contracts.

## Root Cause Analysis
There appear to be contradictory orchestration contracts for small-path work:

- `.github/agents/csharp-orchestrator.agent.md` defines the small path as direct planning/execution only.
- `.github/prompts/orchestrate-csharp-work.prompt.md` defines the small path differently again, as a direct delegation to `csharp-typed-engineer`.
- `.github/skills/feature-promotion-lifecycle/SKILL.md` explicitly says short-path workflows still require promotion/folder initialization in `minor-audit` mode.

Because the orchestrator agent’s embedded small-path workflow omits those lifecycle steps entirely, the agent followed its local sequence and never set the persisted variables required by its own checkpoint schema. The failure is therefore an instruction-precedence and contract-drift bug rather than a one-off execution mistake.

Additional evidence from the research makes the defect broader than a single paragraph mismatch:

- `.github/skills/csharp-orchestration-state-machine/SKILL.md` still documents the pre-`minor-audit` checkpoint shape and does not include `${plan-path}` or short-path resume metadata, so the persisted-state contract cannot fully represent the required small-path lifecycle.
- `.github/skills/csharp-change-budget-router/SKILL.md` still summarizes small path as “atomic plan + execution route,” which reinforces the incorrect shortcut after budget selection.
- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-orchestrator.agent.md` and `extensions/drm-copilot/resources/customizations/.github/prompts/orchestrate-csharp-work.prompt.md` mirror the stale root behavior, so packaged customizations would continue to distribute the broken contract even if only the root copy were updated.
- The bundled customization mirror also lacks `extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/`, even though the root C# orchestrator already references that shared skill.
- No existing deterministic regression test currently pins the required C# small-path sequence or root↔mirror parity, so the drift was free to persist across root files, bundled copies, and state-machine documentation.


## Proposed Fix

### Design summary (what changes where):
- Update the root C# orchestrator contract so the `small` route follows the canonical short-path sequence instead of jumping directly to planning or engineering. The required sequence is: classify and persist `${promotion-type}` / `${short-name}` / `${relativeFile}` → promote with `--work-mode minor-audit` → create the active feature folder with `--work-mode minor-audit` → verify `issue.md` integrity and absence of `spec.md` / `user-story.md` → resolve and persist `${plan-path}` → delegate minimal-audit planning until `PREFLIGHT: ALL CLEAR` → execute Phase 0 only → branch by bootstrap mode → continue constrained small-path implementation → validate against `issue.md` → run reduced audit/remediation.
- Bring the root C# prompt, C# router skill, and C# state-machine skill into the same contract so the agent, prompt, and shared skills all describe one small-path lifecycle.
- Mirror every changed root customization file into `extensions/drm-copilot/resources/customizations/.github/...`, and add the missing bundled `acceptance-criteria-tracking` skill if the mirrored C# orchestrator continues to reference it.
- Add deterministic content-based tests over the markdown customization files and publisher helpers so future drift is caught without relying on live orchestration runs or temporary files.

### Boundaries and invariants to preserve:
- The large path remains the full promotion → research → spec/story → atomic planning → atomic execution → feature review workflow; this bug fix must not collapse the distinction between large and small path.
- The small-path budget threshold remains `1-3` production C# files plus corresponding tests.
- Short-path work must use `minor-audit` mode and therefore treat `issue.md` as the sole authoritative requirements file. `spec.md` and `user-story.md` must not appear in a valid minor-audit folder.
- `${plan-path}` continuity is mandatory: once a plan file is chosen for a short-path run, planning and preflight must update that same file in place rather than creating sibling `plan.*.md` variants opportunistically.
- Completion must fail closed if required orchestration variables remain `null`, if `issue.md` lacks `- Work Mode: minor-audit`, if Phase 0 evidence is missing, or if reduced-audit inputs contradict artifact state.
- Existing branch/folder reuse behavior must be preserved: if the branch or feature folder already exists, the workflow should reuse and record that fact instead of treating it as a new-path failure.

### Dependencies or blocked work:
- Primary references already exist in `.github/agents/orchestrator.agent.md`, `.github/agents/python-orchestrator.agent.md`, and `.github/agents/powershell-orchestrator.agent.md`; the C# fix should mirror those established contracts instead of inventing a new C#-only flow.
- The downstream C# delegates (`csharp-atomic-planning`, `csharp-atomic-executor`, and `csharp-typed-engineer`) already exist, so this bug is primarily orchestration wiring/documentation/state continuity rather than missing implementation infrastructure.
- Existing regression seams already exist in `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`, `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py`, and the `minor-audit` feature-doc tests. No additional research is required to complete this spec.

### Implementation strategy (what changes, not sequencing):
	- Normalize the C# small-path contract across root agent, root prompt, root router skill, and root state-machine skill.
	- Add the missing short-path lifecycle details: `minor-audit` promotion, active-folder creation, folder-integrity checks, `${plan-path}` resolution/reuse, Phase 0 only execution, bootstrap branching, and reduced audit gates.
	- Update the bundled extension customization mirror to match the root copies for all changed files and supply any mirrored shared skill dependency that becomes required by the mirrored C# orchestrator.
	- Add regression tests that assert required lifecycle strings, required checkpoint fields, and root↔mirror parity for the changed customization set.
	
#### Files/modules to change:
- Root C# customization contracts:
	- `.github/agents/csharp-orchestrator.agent.md`
	- `.github/prompts/orchestrate-csharp-work.prompt.md`
	- `.github/skills/csharp-orchestration-state-machine/SKILL.md`
	- `.github/skills/csharp-change-budget-router/SKILL.md`
- Bundled extension customization mirror:
	- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-orchestrator.agent.md`
	- `extensions/drm-copilot/resources/customizations/.github/prompts/orchestrate-csharp-work.prompt.md`
	- `extensions/drm-copilot/resources/customizations/.github/skills/csharp-orchestration-state-machine/SKILL.md`
	- `extensions/drm-copilot/resources/customizations/.github/skills/csharp-change-budget-router/SKILL.md`
	- `extensions/drm-copilot/resources/customizations/.github/skills/feature-promotion-lifecycle/SKILL.md` (refresh to current root parity if referenced lifecycle language is stale)
	- `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md` (refresh to current root parity if referenced minimal-plan language is stale)
	- `extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md` (add bundled mirror because the C# orchestrator references the shared skill and the mirror currently lacks it)
- Likely regression test touch points:
	- `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`
	- `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py`
	- `tests/scripts/dev_tools/test_feature_docs.py` only if plan-path / minor-audit parsing assertions need an additional deterministic guard.

#### Functions/classes/CLI commands impacted:
- Prompt/agent entrypoints and contracts:
	- `/orchestrate-csharp-work`
	- `csharp-orchestrator`
	- `csharp-atomic-planning`
	- `csharp-atomic-executor`
	- `csharp-typed-engineer` (small-path implementation delegate after Phase 0, not direct initial route)
- Lifecycle-related CLI/tooling surfaces that must remain consistently referenced by the C# orchestrator contract:
	- `scripts/dev-tools/new-potential-entry.ps1`
	- `scripts.dev_tools.new_potential_bug_entry`
	- `scripts.dev_tools.potential_to_issue --work-mode minor-audit`
	- `scripts.dev_tools.new_active_feature_folder --work-mode minor-audit`
- Checkpoint/state schema described by `artifacts/orchestration/csharp-orchestrator-state.json`.

#### Data flow and validation changes:
- Small-path data flow must no longer be `budget-estimate -> planning -> execution -> done`. It must become:
	1. budget estimate selects `small`
	2. lifecycle variables are derived and persisted
	3. potential item is promoted with `minor-audit`
	4. active feature folder is created/reused and validated
	5. `${plan-path}` is resolved and persisted before planning
	6. minimal-audit planning updates the single chosen plan file in place until `PREFLIGHT: ALL CLEAR`
	7. Phase 0 only execution writes evidence-backed checklist state
	8. bootstrap branching determines whether to stop for manual resume or continue to constrained implementation
	9. validation and reduced audit gate completion
- Validation must explicitly check:
	- non-null `${promotion-type}`, `${short-name}`, `${relativeFile}`, `${long-name}`, `${issue-num}`, `${feature-folder}`, and `${plan-path}` before completion;
	- `issue.md` contains `- Work Mode: minor-audit`;
	- `spec.md` and `user-story.md` are absent from the minor-audit folder;
	- Phase 0 artifacts and checklist state are evidence-backed;
	- reduced-audit outputs exist before final completion is recorded.

#### Error handling and logging updates:
- The C# state-machine contract should document fail-closed behavior when required fields are missing for the next step. In particular, a run marked `small` must not be allowed to set `next_step` to planning/execution completion while lifecycle variables remain unset.
- Checkpoint `completed_steps` and `next_step` values should reflect the sequential short-path lifecycle rather than the current coarse shortcut, so interruptions can resume after promotion, after folder creation, after Phase 0, or at bootstrap branching without recomputing earlier state.
- Logging/output should make the selected short-path stage visible enough to diagnose contract drift: promotion in `minor-audit`, `${plan-path}` reuse/selection, Phase 0-only execution, and reduced-audit gating should all be evident in delegated outputs or checkpoint summaries.
- No separate telemetry pipeline is required; the checkpoint JSON and generated markdown artifacts are the observability surface for this fix.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag is warranted because this is a correctness fix for a broken orchestration contract.
- Rollback is a straight reversion of the changed markdown customization files and associated regression tests if the new contract proves incompatible.
- Checkpoint schema expansion should remain additive/backward-compatible where possible so older in-progress state files can still be resumed or safely re-derived rather than discarded.

### Technical specifications (interfaces/contracts):
- The authoritative short-path contract for C# must match the shared repository lifecycle, not a C#-local shortcut. Specifically, the C# small path should mirror the generic short-path steps S1-S8 already documented in `.github/agents/orchestrator.agent.md`.
- The authoritative acceptance-criteria source for this bug fix remains `spec.md` only because issue #101 is `full-bug`; however, the resulting orchestrator behavior must create `minor-audit` feature folders whose downstream execution and validation use `issue.md` as the only short-path requirements source.
- Root and bundled copies of any changed `.github` customization file are a parity contract. If the root file changes, the bundled mirror must change in the same patch unless there is an explicit packaging exception documented in the file content or tests.

#### Inputs/outputs and formats:
- Inputs:
	- natural-language C# objective provided through `/orchestrate-csharp-work`
	- optional file hints and classification hints already supported by the prompt
	- existing checkpoint state from `artifacts/orchestration/csharp-orchestrator-state.json`
	- existing feature-folder artifacts if the workflow is resuming or reusing a previously created branch/folder
- Outputs:
	- updated checkpoint JSON with populated lifecycle variables and short-path continuity fields
	- promoted `minor-audit` feature folder containing `issue.md`, a single canonical `plan*.md`, Phase 0 evidence artifacts, and reduced-audit artifacts
	- no `spec.md` or `user-story.md` in a valid minor-audit folder
	- synchronized bundled customization markdown under `extensions/drm-copilot/resources/customizations/.github/...`
- Formats:
	- checkpoint remains JSON
	- orchestration contracts remain markdown agent/prompt/skill files
	- tests remain deterministic Python `pytest` suites with no temp-file dependency beyond existing in-memory or committed fixture patterns

#### Required configuration keys and defaults:
- Existing required checkpoint keys remain required: `objective`, `change_budget_estimate`, `path_selected`, `promotion-type`, `short-name`, `relativeFile`, `long-name`, `issue-num`, `feature-folder`, `completed_steps`, `next_step`, `last_updated`.
- The C# checkpoint contract must be extended to include at minimum:
	- `${plan-path}` / `plan-path`: the single plan file reused across planning and preflight iterations
	- `work-mode`: expected to be `minor-audit` for the small path after promotion
	- bootstrap/resume metadata sufficient to distinguish “manual bootstrap stop after Phase 0” from “continue to implementation”
	- Phase 0 evidence summary fields or equivalent documented state needed to prove Phase 0 was actually executed before resume
- Defaulting behavior should be fail-closed for small-path completion: missing new fields may be tolerated only before the lifecycle reaches the step where that field must exist.

#### Backward-compatibility expectations:
- Existing large-path behavior and command surfaces remain unchanged.
- Existing small-path invocations continue to use the same prompt entrypoint and budget threshold, but the resulting behavior changes from shortcut routing to full short-path lifecycle compliance.
- Resume logic should tolerate older checkpoint files that lack newly documented fields by deriving or initializing them before advancing; it must not silently skip required lifecycle steps just because an older checkpoint omitted those fields.
- Bundled extension customizations must remain consumable by the extension packaging flow; parity updates should not introduce repo-only paths that cannot exist in the bundled tree.

#### Performance constraints (latency/throughput/memory):
- The fix is documentation/contract/test heavy, so runtime cost should remain dominated by the existing orchestration commands rather than the added checks.
- Additional validation is limited to markdown contract checks and checkpoint field presence checks; no material latency or memory regression is expected beyond negligible text parsing overhead.
- Regression coverage should remain deterministic and fast by operating on in-memory or checked-in text fixtures rather than invoking live orchestration delegates.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
	- The provided issue and research artifacts are sufficient to complete this spec; no additional task research is required before planning.
	- The generic, Python, and PowerShell orchestrator files are the authoritative references for the intended small-path lifecycle.
	- The extension’s `resources/customizations/.github` tree is a deliberate bundled mirror of root `.github` customizations and must be kept aligned when root contracts change.
	- This fix is implemented in repository markdown customization files and Python regression tests rather than in C# runtime code.
- Constraints (budget, performance, compatibility):
	- Only files explicitly grounded in the issue/research should be changed.
	- The fix must preserve small-vs-large routing thresholds and avoid widening into a cross-language orchestration refactor.
	- Tests must remain deterministic and comply with the repository ban on ad hoc temporary-file workflows for new regression coverage.
- External dependencies (services, libraries, releases):
	- No new external libraries or services are required.
	- Existing repository tooling for promotion, feature-folder creation, and customization publishing remains the dependency surface.

## Data / API / Config Impact
- User-facing or API changes:
	- Users invoking `/orchestrate-csharp-work` for a small-scope request will no longer see a direct planner/engineer shortcut. They should see the same promoted short-path lifecycle artifacts that other orchestrators already require: issue promotion, branch creation, active feature folder, single plan file, Phase 0 artifacts, and reduced audit.
	- No new end-user flags are introduced; the change is behavioral alignment of existing command contracts.
- Data or migration considerations:
	- `artifacts/orchestration/csharp-orchestrator-state.json` gains additional documented continuity fields. This is an additive schema evolution, not a repository-wide data migration.
	- Existing incomplete checkpoints may need normalization on resume so missing `${plan-path}` / `work-mode` fields are backfilled before advancing.
- Logging/telemetry updates (if any):
	- Expected updates are limited to checkpoint step names / persisted fields and more explicit markdown contract language around short-path gating.
	- No centralized telemetry system is added; validation relies on checkpoint content, created artifact paths, and regression tests.
- Compatibility notes (CLI flags, config schemas, versioning):
	- The spec requires explicit use of `--work-mode minor-audit` for short-path promotion and feature-folder creation.
	- Root and bundled copies of the changed customization files must stay version-compatible and textually aligned enough for push-down publishing and extension packaging.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas
	- Add workflow-contract coverage for `csharp-orchestrator` small-path routing so a small-scope request must produce non-null lifecycle variables or explicitly documented short-path artifacts.
	- Add a consistency check that the agent file, orchestration prompt, and shared lifecycle skill do not define conflicting small-path sequences.
- [x] Integration scenario to retest
	- Re-run `/orchestrate-csharp-work` with a known small-scope request and verify the resulting flow includes potential entry creation/fill, promotion in `minor-audit` mode, branch creation, active feature folder creation, then planning/execution.
	- Verify `artifacts/orchestration/csharp-orchestrator-state.json` contains populated values for `${promotion-type}`, `${short-name}`, `${relativeFile}`, `${long-name}`, `${issue-num}`, and `${feature-folder}` before the workflow can complete.
- [x] Manual verification notes
	- Inspect the created feature folder and confirm that `issue.md` exists with the persisted work-mode marker before the plan handoff occurs.
	- Confirm the orchestrator does not mark completion if the lifecycle variables are still `null`.

- Regression tests to add or update:
	- Extend `tests/scripts/dev_tools/test_push_down_copilot_customizations.py` and/or `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py` with content-based assertions that the root and bundled C# orchestrator/prompt/skill files contain the required small-path signals (`minor-audit`, `${plan-path}`, Phase 0-only execution, reduced audit, and mirror parity).
	- Add a deterministic regression that fails if the bundled mirror omits `acceptance-criteria-tracking` after the mirrored C# orchestrator references it.
	- Reuse `tests/scripts/dev_tools/test_feature_docs.py` only if an additional guard is needed for `minor-audit` issue-only semantics or canonical `plan*.md` continuity.
- Unit tests (pytest) for the fixed behavior and boundaries:
	- Assert the C# orchestrator agent no longer describes `small` as direct planning/execution completion.
	- Assert the C# prompt no longer describes `small` as direct delegation to `csharp-typed-engineer`.
	- Assert the C# state-machine skill documents `${plan-path}` and short-path resume metadata.
	- Assert the C# change-budget router still uses the same thresholds but now preserves the short-path lifecycle rather than bypassing it.
	- Assert each changed root file matches its bundled mirror counterpart or the specific rewritten output expected by the customization publisher.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
	- Resume from a checkpoint created after promotion but before plan generation.
	- Resume when the feature folder already exists and must be reused.
	- Resume when an existing `plan*.md` already exists and must become `${plan-path}` rather than generating a new sibling.
	- Fail validation when `issue.md` lacks `- Work Mode: minor-audit`.
	- Fail validation when `spec.md` or `user-story.md` exists in a supposed minor-audit folder.
	- Fail completion when lifecycle variables remain `null` or when Phase 0 evidence is missing.
- Error handling and logging verification:
	- Verify tests or fixture assertions cover the required checkpoint fields and step names for short-path continuity.
	- Verify the documented contract forbids marking completion without reduced-audit artifacts and evidence-backed checklist state.
- Coverage impact and targets for changed lines/modules:
	- Changed Python regression tests should cover the new text-contract assertions for every changed customization class (agent, prompt, skill, mirror parity).
	- Coverage should remain within the existing repo-root Python coverage workflow; no separate C# runtime coverage is expected because the fix is not changing compiled C# sources.
- Toolchain commands to run (format → lint → type-check → test):
	- `poetry run black .`
	- `poetry run ruff check`
	- `poetry run pyright`
	- `poetry run pytest`
- Manual validation steps (if required):
	- Re-run `/orchestrate-csharp-work` with the documented small-scope Dark Mode request and inspect the resulting checkpoint plus created feature folder.
	- Confirm the checkpoint includes populated lifecycle variables and `${plan-path}` before planning/execution is reported complete.
	- Confirm the resulting feature folder is `minor-audit` shaped: `issue.md` present with work-mode marker, no `spec.md`, no `user-story.md`, single canonical plan path reused, and reduced-audit artifacts present before completion.


## Acceptance Criteria
- [x] For the issue #101 repro, the documented C# small path now requires the sequential short-path lifecycle before planning/execution: potential entry resolution, promotion with `--work-mode minor-audit`, branch creation, active feature folder creation, folder-integrity validation, `${plan-path}` resolution, Phase 0-only execution, validation, and reduced audit.
- [x] `artifacts/orchestration/csharp-orchestrator-state.json` is documented and validated to carry the lifecycle variables needed for small-path continuity, including non-null `${promotion-type}`, `${short-name}`, `${relativeFile}`, `${long-name}`, `${issue-num}`, `${feature-folder}`, and `${plan-path}` before completion is allowed.
- [x] Minor-audit invariants are explicit and testable: a valid short-path folder contains `issue.md` with `- Work Mode: minor-audit`, does not contain `spec.md` or `user-story.md`, and cannot pass completion if Phase 0 evidence or reduced-audit artifacts are missing.
- [x] The root C# orchestrator agent, root C# prompt, root C# state/router skills, and their bundled extension mirrors are updated together so the small-path contract is no longer contradictory across root and packaged customization sources.
- [x] Regression tests are added or updated in the existing Python test suite to fail on: direct-to-planning/direct-to-engineer shortcut wording, missing `${plan-path}` continuity, missing bundled `acceptance-criteria-tracking` mirror when referenced, or root↔mirror drift.
- [x] The fix does not change large-path routing thresholds or large-path lifecycle behavior beyond additive checkpoint compatibility needed to share the updated state contract.
- [x] Final validation for the implementation pass includes a clean repo-root toolchain pass (`poetry run black .`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest`).
- [x] Documentation and bundled customization references match the final behavior closely enough that a future reader cannot derive a shortcut small path from the C# agent/prompt/skill set.

## Risks & Mitigations
- Technical or operational risks:
	- Updating only the root `.github` files would leave the extension-bundled customization pack stale and reintroduce the bug for downstream consumers.
	- Updating only the agent without the prompt/router/state-machine skills would leave contradictory instructions in place and make future drift likely.
	- Older incomplete checkpoint files may not contain `${plan-path}` or `work-mode`, creating resume ambiguity unless the implementation defines how to backfill them.
	- There is a broader repository pattern of prompt drift in other language orchestrators; that increases the risk of copy/paste regressions if tests are too C#-specific or too narrow.
- Mitigations and rollbacks:
	- Require same-change parity for root and bundled C# customizations and add regression tests that compare or otherwise validate both sides.
	- Make the generic/Python/PowerShell short-path flow the source template for the C# fix so only one lifecycle model is being copied.
	- Treat new checkpoint fields as additive and fail closed only once the workflow reaches the step where the field is mandatory.
	- If the contract update creates unexpected downstream packaging issues, revert the markdown/test changes as a unit rather than partially rolling back one layer.

## Rollout & Follow-up
- Release/rollout steps:
	- Land the root customization updates, bundled mirror updates, and regression tests in the same change.
	- Run the repo-root Python quality loop and verify the changed markdown contracts are exercised by the added tests.
	- Re-run the documented small-path repro through `/orchestrate-csharp-work` to confirm the lifecycle now produces the expected artifacts.
- Post-fix monitoring or clean-up tasks:
	- Watch for any follow-up defects involving resume from pre-fix checkpoints that lack `${plan-path}` or `work-mode`.
	- Open separate follow-up work, if desired, to audit Python and PowerShell orchestration prompts for the same prompt-drift pattern identified in research; that work is intentionally not bundled into issue #101.
	- If the implementation relies on the push-down publisher to refresh the bundled mirror, verify the published extension resources remain in sync after the update.
- Links: issue, PRs, related docs
	- Issue: `docs/features/active/2026-03-14-orchestrator-not-following-sequential-tasks-101/issue.md`
	- Spec: `docs/features/active/2026-03-14-orchestrator-not-following-sequential-tasks-101/spec.md`
	- Research: `artifacts/research/20260314-csharp-orchestrator-small-path-lifecycle-research.md`
	- Canonical short-path reference: `.github/agents/orchestrator.agent.md`
