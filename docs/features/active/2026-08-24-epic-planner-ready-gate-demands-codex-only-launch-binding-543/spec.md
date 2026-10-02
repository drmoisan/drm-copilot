# 2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding (Spec)

- **Issue:** #543
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T16-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source; no `user-story.md`)
- **Design source:** `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/research/research.2026-09-29T16-10.md` (recommended Approach A)

## Context

`scripts/dev_tools/validate_epic_planner_state.py` carries the same structural defect that issue #524 fixed on the epic-orchestrator side, one layer up. Under `require_ready_for_execution`, it demands Codex-only launch evidence that no Claude-runtime producer writes. As a result, the gate cannot pass on the Claude runtime. The defect is latent because no Claude surface passes that flag for the `epic-planner-state` artifact type today.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `validate_epic_planner_state_text(text, require_ready_for_execution=True)`, reachable through the `epic-planner-state` artifact type with `--require-ready-for-execution` (Python CLI) or `require_ready_for_execution: true` (MCP)
- Data source or fixture: any Claude-prepared epic planner checkpoint at `artifacts/orchestration/epic-planner-state.json`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

The defect is latent. A search of `.claude/**` and `.github/**` found no ready-gate caller for `epic-planner-state`. All `.claude/**` matches for `require_ready_for_execution` belong to the parallel planner (research §Q4). The only production callers of this gate are Codex guidance surfaces. None of them passes a Codex enforcement flag today.

## Repro & Evidence

Steps to Reproduce:
1. Prepare an epic on the Claude runtime so that `artifacts/orchestration/epic-planner-state.json` records a fully prepared feature set. The Claude contract (`.claude/agents/epic-planner.md:106-110`) writes no launch keys.
2. Validate that checkpoint with `require_ready_for_execution=True` and a readiness context.
3. Observe launch-binding errors for every feature. Observe also launch-evidence errors of the form `... must identify a launch artifact in this repository.` No Claude agent can satisfy either family.

Expected:
The ready gate validates the structural readiness properties it owns. It requires per-feature launch evidence only when the caller asserts a Codex enforcement flag, or when the feature carries launch path keys. This matches the correction landed for the epic-orchestrator gate in #524.

Actual:
Both launch-evidence checks inside the ready gate are unconditional:

1. `scripts/dev_tools/validate_epic_planner_state.py:331` calls `errors.extend(validate_epic_planner_child_launch_bindings(features))` with no activation condition. `validate_epic_planner_child_launch_bindings` (`scripts/dev_tools/_epic_orchestrator_state_launch_binding.py:259-271`) passes `require_generated_orchestrator=True`, `skip_not_started=False`, and `require_launch_paths=False`.
2. `scripts/dev_tools/validate_epic_planner_state.py:346` calls `validate_epic_readiness_integrity(state, text, readiness_context)`. That function calls `validate_epic_planner_launch_evidence(state, context)` at `scripts/dev_tools/epic_planner_readiness.py:354`. `validate_epic_planner_launch_evidence` (`scripts/dev_tools/epic_planner_launch_evidence.py:298-345`) checks `launch_receipt_path` and `launch_status_path` for every feature. The issue does not name this second path, but it runs under the same gate (research §1.2).

The TypeScript twins have the same shape:
- `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts:430-432`
- `extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts:341`
- `extensions/drm-copilot/src/lib/validate/epic-planner-launch-evidence.ts:393-455`

Logs / Screenshots:
- Error family: `Epic planner checkpoint features[N] launch binding.launch_receipt_path must be under artifacts/orchestration/epic-child-launches/.` and the launch-evidence `... must identify a launch artifact in this repository.` family.

## Scope & Non-Goals

In scope:
- Condition both launch-evidence call sites in the epic-planner ready gate on one activation predicate, in Python and TypeScript. The predicate is: either Codex flag is asserted, or the feature carries a launch path key.
- Add the `require_codex_model_routing` and `require_codex_topology` keyword options to the Python validator. Add the `requireCodexModelRouting` and `requireCodexTopology` options to the TypeScript validator.
- Forward both flags in the MCP `epic-planner-state` dispatch case.
- Update the three Codex guidance callers and their bundle mirrors so that they pass both Codex flags. This keeps Codex enforcement unconditional, and each pair stays byte-identical.
- Update the tests that lock in the defect and add regression tests.

Out of scope / non-goals:
- **Python CLI flag addition.** `scripts/dev_tools/validate_orchestration_artifacts.py` is 495 lines long. Adding two argparse flags plus threading would exceed the 500-line limit. No production caller uses the Python CLI for `epic-planner-state`; all Codex callers use the MCP (TypeScript) route. Python CLI callers therefore get the key-gated mode, which is the correct behaviour for the Claude runtime. This asymmetry is a deliberate, recorded deviation. CLI parity, if later required, needs a line-neutral extraction in a separate scoped change.
- **Remaining Codex-only receipts in the ready gate (follow-up).** After this fix, the ready gate still requires the following Codex-only items:
  - per-feature `model_routing_receipt` and `topology_receipt` (`_validate_ready_features`, `scripts/dev_tools/validate_epic_planner_state.py:241-275`)
  - the top-level forced planner `topology_receipt` (`validate_epic_planner_state.py:332`)

  The Claude epic planner writes none of these. The Claude-runtime ready gate therefore remains unsatisfiable end to end. This is recorded as an out-of-scope follow-up issue (see Rollout & Follow-up) and is not addressed here.
- Changing `require_generated_orchestrator` (see Boundaries and invariants).
- Adding, removing, or rewording any error string in either runtime.

Explicitly excluded systems, integrations, or datasets:
- `.claude/**` and `.github/**`, including `.claude/rules/orchestrator-state.md`. The existing "Epic Launch-Binding Activation Scope" section covers the epic-orchestrator gate only and does not become inaccurate. A policy rule edit would need explicit authorization, and #543 has none.
- MCP tool definitions (`extensions/drm-copilot/src/mcp-tool-definitions.ts`, `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`) and `extensions/drm-copilot/src/mcp-tool-inputs.ts`. They already declare and map both flags.
- `extensions/drm-copilot/jest.config.cjs` and `pack-manifests/core.json`. No new files need thresholds, and the manifest carries no hashes.

## Root Cause Analysis

The planner gate was written for the Codex runtime. On that runtime, `.codex/scripts/launch-epic-child-wave.ps1` writes the launch evidence and the generated orchestrator personas exist. The generic readiness flag was then admitted into an activation set that is Codex-specific in practice. This is the same category of error as #524, where the generic `require_complete` flag was admitted into a Codex-specific activation set. The #524 fix (`scripts/dev_tools/_epic_orchestrator_state_launch_binding.py:283-298`) left the planner wrapper at `require_launch_paths=False` on purpose and scoped it out to this issue.

Two call sites carry the defect, not one:
1. The launch-binding call at `validate_epic_planner_state.py:331`.
2. The launch-evidence call at `epic_planner_readiness.py:354`.

A fix limited to the first would still leave Claude checkpoints with launch-evidence errors.

## Proposed Fix

### Design summary (what changes where):

This fix mirrors #524. Under `require_ready_for_execution=True`, the ready gate computes one activation value in each runtime:

- Python: `key_gated = not (require_codex_model_routing or require_codex_topology)`
- TypeScript: `requireLaunchPaths = options.requireCodexModelRouting !== true && options.requireCodexTopology !== true`

The same value is passed as `require_launch_paths` / `requireLaunchPaths` to both the launch-binding validator and, through the readiness-integrity validator, the launch-evidence validator. When the value is true, a feature that carries neither `launch_receipt_path` nor `launch_status_path` is skipped inside the existing per-feature loop.

Target semantics under `require_ready_for_execution=True`:

| Case | Codex flag asserted | Feature launch keys | Launch-binding and launch-evidence result |
|---|---|---|---|
| Claude-prepared feature | no | neither key | skipped; zero launch errors from either call site |
| Codex-prepared feature | no | both keys | validated as today, including the generated-agent check |
| Partial binding | no | one key only | validated; the absent key yields its existing error |
| Key present, empty or null value | no | key present | validated (key membership arms the gate) |
| Any feature | yes (either flag) | any | validated for every feature (current behaviour) |

Without `require_ready_for_execution`, nothing changes.

### Boundaries and invariants to preserve:

- **`require_generated_orchestrator` stays `True`** for every feature that is validated. This answers the policy question raised in the issue. A feature is validated only when a Codex flag is asserted or it carries a launch key. Launch keys have one production writer, the Codex launcher, so every validated feature has Codex provenance and the generated-agent restriction is correct for it. The planner launch-binding surface is Codex-only by provenance. This fix scopes activation; it does not change the agent-name rule.
- **Per-feature skip, not list filtering.** The skip is applied inside the existing loops, so `Epic planner checkpoint features[{index}] ...` keeps the original index. The code must not filter the features list before the call.
- **Key-membership predicate.** Use `"launch_receipt_path" in feature or "launch_status_path" in feature`, the same test as #524's `_carries_launch_path`. A partial binding still fails, and a present key with an empty or null value still arms the gate.
- **Shared status path.** A skipped feature contributes no status path. The "must share one launch_status_path" rule (`epic_planner_launch_evidence.py:320-327`) compares only among validated features.
- **Error strings are unchanged** in both runtimes, and the Python and TypeScript strings stay byte-identical.
- **Guidance mirrors stay byte-identical** to their root copies. This is enforced by `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` (`keeps root and tracked bundle runtime copies byte-identical`).
- **500-line limit.** No production or test file exceeds 500 lines after the change.

### Dependencies or blocked work:

- There are no blocking dependencies. The #524 seam (`require_launch_paths` on `_validate_launch_bindings`) is already on `main`.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Production, Python:
- `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`
- `scripts/dev_tools/epic_planner_launch_evidence.py`
- `scripts/dev_tools/epic_planner_readiness.py`
- `scripts/dev_tools/validate_epic_planner_state.py`

Production, TypeScript:
- `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts`
- `extensions/drm-copilot/src/lib/validate/epic-planner-launch-evidence.ts`
- `extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts`
- `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`
- `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`

Codex guidance (byte-identical root and bundle pairs):
- `.agents/skills/epic-plan/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md`
- `.agents/skills/epic-run/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-run/SKILL.md`
- `.codex/agents/epic-orchestrator.toml` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml`

Tests, Python:
- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` (224 lines; room for the new tests)
- `tests/scripts/dev_tools/test_epic_planner_launch_evidence.py` (271 lines; room for the new tests)
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` (in-place literal and docstring edit)

Tests, TypeScript:
- `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts` (220 lines)
- `extensions/drm-copilot/test/lib/validate/epic-planner-launch-evidence.test.ts` (223 lines)
- `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` (166 lines; home for the dispatch-threading test)

Files that must not receive new tests because of the 500-line limit:
- `tests/scripts/dev_tools/test_epic_planner_readiness.py` (491 lines)
- `extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts` (495 lines)
- `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` (508 lines; already over the limit)

If further tests are needed beyond the files named above, put them in new test files that mirror the source layout.

Files not changed:
- `scripts/dev_tools/validate_orchestration_artifacts.py` (CLI flags deferred)
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py` (its CLI dispatch stub stays valid while the CLI is unchanged)

#### Functions/classes/CLI commands impacted:

Python:
- `validate_epic_planner_child_launch_bindings(features, *, require_launch_paths: bool = False)`: forwards `require_launch_paths` and keeps `require_generated_orchestrator=True`.
- A public predicate `feature_carries_launch_path(feature)` in `_epic_orchestrator_state_launch_binding.py`. The existing `_carries_launch_path` delegates to it or is replaced by it, with its callers updated.
- `validate_epic_planner_launch_evidence(state, context, *, require_launch_paths: bool = False)`: after the `_is_record` check, `continue` when `require_launch_paths and not feature_carries_launch_path(item)`.
- `validate_epic_readiness_integrity(state, text, context, *, require_launch_paths: bool = False)`: forwards the value to `validate_epic_planner_launch_evidence`.
- `validate_epic_planner_state_text(text, *, require_ready_for_execution=False, readiness_context=None, require_codex_model_routing=False, require_codex_topology=False)`: computes `key_gated` and passes it at both call sites.

TypeScript:
- `featureCarriesLaunchPath` becomes exported from `epic-orchestrator-state-launch-binding.ts`.
- `validateEpicPlannerChildLaunchBindings(features, options?: { requireLaunchPaths?: boolean })`
- `validateEpicPlannerLaunchEvidence(state, context, options?: { requireLaunchPaths?: boolean })`
- `validateEpicReadinessIntegrity(..., options?: { requireLaunchPaths?: boolean })`
- `ValidateEpicPlannerStateOptions` gains `requireCodexModelRouting?: boolean` and `requireCodexTopology?: boolean`.
- `dispatchValidatorErrors`, `epic-planner-state` case: forwards `requireCodexModelRouting` and `requireCodexTopology`, using the conditional-spread pattern of the adjacent `epic-orchestrator-state` case.

MCP: the `validate_orchestration_artifacts` tool with `artifact_type: epic-planner-state` now honours `require_codex_model_routing` and `require_codex_topology`. The schema is unchanged.

#### Data flow and validation changes:

- The caller's flags reach `validate_epic_planner_state_text` / `validateEpicPlannerState`.
- The validator computes one activation value.
- Both launch validators read that value per feature.
- No checkpoint schema changes. No new keys are read or written.

#### Error handling and logging updates:

- No error string is added, removed, or reworded. No logging changes.

#### Rollback/feature-flag considerations (if applicable):

- Every new parameter defaults to the pre-fix behaviour. Callers that do not use the new parameters see the pre-fix result, except for the key-gated skip at the planner ready gate itself. Rollback is a revert of the change set.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Inputs: the epic planner checkpoint JSON text, the ready flag, the readiness context, and the two Codex flags.
- Output: a list of error strings. The format is unchanged.

#### Required configuration keys and defaults:

- `require_codex_model_routing` / `requireCodexModelRouting`: default `False` / `undefined`.
- `require_codex_topology` / `requireCodexTopology`: default `False` / `undefined`.
- `require_launch_paths` / `requireLaunchPaths` on the helper validators: default `False` (validate every feature).

#### Backward-compatibility expectations:

- Codex callers that pass both flags (after the guidance update) are validated exactly as before.
- Codex checkpoints that carry launch keys are validated exactly as before, even without the flags.
- The only behaviour change is that a feature with neither launch key is no longer rejected for launch evidence when no Codex flag is asserted.

#### Performance constraints (latency/throughput/memory):

- There are no new constraints. The change adds one key-membership test per feature.

## Assumptions, Constraints, Dependencies

- Assumptions: Launch keys have exactly one production writer, the Codex launcher (`.claude/rules/orchestrator-state.md:113`). No automated Python-to-TypeScript execution parity test exists for the epic planner. Parity is maintained by twin tests that assert byte-identical error strings (research §Q5).
- Constraints:
  - 500-line limit per production and test file.
  - Guidance mirrors must remain byte-identical.
  - No `.claude/**` or `.github/**` edits.
- External dependencies: none.
- Research limitation: the research session did not run pytest or jest, so baseline pass/fail state was not observed. The executor must capture a baseline before making changes.

## Data / API / Config Impact

- User-facing or API changes:
  - New optional keyword arguments on the Python validator.
  - New optional fields on `ValidateEpicPlannerStateOptions`.
  - The MCP `epic-planner-state` route now honours both Codex flags.
- Data or migration considerations: none.
- Logging/telemetry updates: none.
- Compatibility notes: the Python CLI `epic-planner-state` subparser gains no flags in this change (recorded deviation; see Non-goals).

## Test Strategy

- Regression tests: the new Python test `test_ready_gate_skips_launch_binding_for_feature_without_launch_paths` must be observed failing on pre-fix code and passing after the fix. Its TypeScript twin follows the same pattern.
- Defect-pinning tests to rewrite:
  - `test_launch_evidence_is_required_only_for_execution_readiness` in `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py`
  - `it("activates only for execution readiness")` in `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts`

  Keep their error assertions and run them under a Codex flag.
- Source-text contract test to update: `test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged` in `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`.
  - Line 403 asserts the literal `"validate_epic_planner_child_launch_bindings(features)"`. Update it to the new call text.
  - The docstring at line 369 claims #543 behaviour is unchanged. Update it.
- Positive scenario: a Claude-shaped feature (no launch keys) produces zero launch errors from both call sites.
- Negative scenarios:
  - a partial binding (one key)
  - a keyless feature under either Codex flag
  - the existing invalid-field tests, which keep both keys and are expected to pass unchanged
- Boundary scenarios:
  - a present key with an empty string or `null` value arms the gate
  - index preservation when an earlier feature is skipped
- Coverage: at least 85% line and 75% branch coverage on each changed Python module and TypeScript file. Changed lines must not lose coverage.
- Toolchain: the full seven-stage loop per `.claude/rules/general-code-change.md` for Python and TypeScript, plus Pester for the guidance mirrors.

Commands:

```
poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_launch_evidence.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py --cov=scripts.dev_tools.validate_epic_planner_state --cov=scripts.dev_tools._epic_orchestrator_state_launch_binding --cov=scripts.dev_tools.epic_planner_launch_evidence --cov=scripts.dev_tools.epic_planner_readiness --cov-branch --cov-report=term-missing
poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing
```

From `extensions/drm-copilot/`:

```
node run-jest.cjs test/lib/validate/epic-planner-state-launch-binding.test.ts test/lib/validate/epic-planner-launch-evidence.test.ts test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/epic-planner-readiness-integrity.test.ts test/lib/validate/epic-orchestrator-state-launch-binding.test.ts test/lib/validate/validate-orchestration-service-call.test.ts test/lib/validate/orchestration-artifacts.test.ts
node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary
```

```
Invoke-Pester tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
```

Evidence goes under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/<kind>/`.

## Acceptance Criteria

- [x] `test_ready_gate_skips_launch_binding_for_feature_without_launch_paths` in `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` validates a ready checkpoint whose feature has `branch_name`, `worktree_path`, `delegation_receipt`, `launch_receipt_path`, and `launch_status_path` removed. It passes `require_ready_for_execution=True` and a readiness context, and asserts that no error contains `" launch binding"` or `"must identify a launch artifact"`. The test is recorded failing on pre-fix code and passing after the fix, with evidence under `evidence/regression/`.
- [x] `test_ready_gate_rejects_partial_launch_binding` in `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` removes only `launch_status_path`. It asserts that the launch-binding errors equal exactly `["Epic planner checkpoint features[0] launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/."]`, and the test passes.
- [x] `test_codex_flag_keeps_launch_binding_unconditional` in `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` is parametrized over `require_codex_model_routing=True` and `require_codex_topology=True`. It asserts that a keyless feature still yields its launch-binding errors, and it passes for both parameters.
- [x] `test_launch_evidence_is_required_only_for_execution_readiness` in `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` is rewritten so that its existing `launch binding.branch_name` and `delegation_receipt must be an object` assertions run with `require_codex_topology=True`, and it passes.
- [x] `test_ready_gate_preserves_feature_index_when_earlier_feature_is_skipped` in `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` makes `features[0]` keyless and gives `features[1]` a partial binding. It asserts that the resulting launch-binding error is prefixed `Epic planner checkpoint features[1]`, and the test passes.
- [x] `test_ready_gate_validates_feature_with_empty_launch_path_value` in `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` sets `launch_status_path` to `""` or `None` with no Codex flag. It asserts that the feature is still validated and yields its existing launch-binding error, and the test passes.
- [x] `tests/scripts/dev_tools/test_epic_planner_launch_evidence.py` contains two passing tests:
  - `test_require_launch_paths_skips_feature_without_launch_keys` asserts that `validate_epic_planner_launch_evidence(state, context, require_launch_paths=True)` returns no errors for a feature whose two launch keys are removed.
  - `test_require_launch_paths_still_rejects_partial_launch_keys` asserts that removing only `launch_status_path` still yields the existing `launch status path must identify a launch artifact in this repository.` error.
- [x] `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts` contains passing TypeScript twins of the Python planner tests above:
  - `it("skips launch binding for a feature without launch paths")`
  - `it("rejects a partial launch binding")`
  - `it("keeps launch binding unconditional under a Codex flag")`, covering `requireCodexModelRouting` and `requireCodexTopology`
  - `it("preserves the feature index when an earlier feature is skipped")`
  - `it("validates a feature with an empty launch path value")`

  The pre-existing `it("activates only for execution readiness")` is rewritten to assert its errors under `requireCodexTopology: true`. Every asserted error string is byte-identical to the corresponding Python assertion.
- [x] `extensions/drm-copilot/test/lib/validate/epic-planner-launch-evidence.test.ts` contains passing twins of the two Python launch-evidence tests:
  - `it("skips a feature without launch keys when requireLaunchPaths is set")`
  - `it("still rejects a partial launch key when requireLaunchPaths is set")`
- [x] `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` contains a passing test, `it("threads the Codex flags into epic-planner-state")`. It proves that `requireCodexModelRouting` and `requireCodexTopology` supplied to `validateOrchestrationServiceCall` for `epic-planner-state` restore unconditional launch-binding validation for a keyless feature.
- [x] `validate_epic_planner_child_launch_bindings` in `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` still passes `require_generated_orchestrator=True`. `validateEpicPlannerChildLaunchBindings` in `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts` still passes `requireGeneratedOrchestrator: true`. Both are verified by reading the source and by the existing `agent_name` test (`must name a generated orchestrator agent.`) passing unchanged in both runtimes.
- [x] `test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged` in `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` asserts the new ready-gate call text in place of the literal `"validate_epic_planner_child_launch_bindings(features)"`. Its docstring no longer states that #543 behaviour is unchanged, and the test passes.
- [x] Each of these guidance files passes `require_codex_topology: true` and `require_codex_model_routing: true` in its `epic-planner-state` ready-gate invocation:
  - `.agents/skills/epic-plan/SKILL.md`
  - `.agents/skills/epic-run/SKILL.md`
  - `.codex/agents/epic-orchestrator.toml`
  - `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md`
  - `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-run/SKILL.md`
  - `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml`

  `Invoke-Pester tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` passes, including `keeps root and tracked bundle runtime copies byte-identical`.
- [x] Existing tests that keep both launch keys present pass without modification:
  - `test_rejects_invalid_branch_or_launch_path`, `test_rejects_invalid_delegation_binding`, `test_rejects_invalid_model_receipt_binding`, `test_requires_unique_branch_and_delegation_identifiers`, and `test_complete_launch_evidence_reaches_repository_context_gate`
  - `tests/scripts/dev_tools/test_validate_epic_planner_state.py`
  - `tests/scripts/dev_tools/test_epic_planner_readiness.py`
  - `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py`

  Verified by the targeted `poetry run pytest` command in Test Strategy exiting 0.
- [x] The targeted `node run-jest.cjs` command in Test Strategy exits 0 from `extensions/drm-copilot/`. It covers `epic-planner-state-core.test.ts`, `epic-planner-readiness-integrity.test.ts`, `epic-orchestrator-state-launch-binding.test.ts`, and `orchestration-artifacts.test.ts` unchanged.
- [ ] `git diff main -- scripts/dev_tools/validate_orchestration_artifacts.py .claude .github` produces no output. This confirms that the Python CLI deferral and the exclusion of `.claude/**` and `.github/**` were respected.
- [ ] Every production and test file named under "Files/modules to change" is at most 500 lines long after the change, verified with `(Get-Content <path>).Count` for each file. No new test is added to `tests/scripts/dev_tools/test_epic_planner_readiness.py`, `extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts`, or `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts`.
- [ ] `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing` exits 0. It reports at least 85% line and 75% branch coverage for `scripts/dev_tools/validate_epic_planner_state.py`, `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`, `scripts/dev_tools/epic_planner_launch_evidence.py`, and `scripts/dev_tools/epic_planner_readiness.py`.
- [ ] `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` exits 0 from `extensions/drm-copilot/` with all `coverageThreshold` entries satisfied. It reports at least 85% line and 75% branch coverage for each changed TypeScript file under `extensions/drm-copilot/src/lib/validate/`.
- [ ] The full seven-stage toolchain loop (format, lint, type-check, architecture, unit, contract, integration) completes in a single clean pass for the changed Python and TypeScript files, with results recorded under `evidence/qa-gates/`.

## Risks & Mitigations

- Risk: a Codex caller that omits both flags could have a keyless feature skipped silently.
  - Mitigation: all three Codex guidance callers and their mirrors are updated to pass both flags.
  - Mitigation: Codex checkpoints carry both launch keys by contract (`.codex/agents/epic-planner.toml:51-54`), so they are still validated even without the flags.
- Risk: filtering the feature list would renumber error indices.
  - Mitigation: the design uses an in-loop skip, and the index-preservation test covers it in both runtimes.
- Risk: Python and TypeScript diverge.
  - Mitigation: the twin tests assert byte-identical error strings.
- Risk: the Python CLI and MCP route behave differently under Codex flags.
  - Mitigation: the deviation is recorded here. No production caller uses the Python CLI for this artifact type.
- Rollback: revert the change set. All new parameters default to the pre-fix behaviour.

## Rollout & Follow-up

- Release/rollout steps: ship with the next extension release. The bundle mirrors are updated in the same change.
- Follow-up (out of scope, to be filed as a separate issue): after this fix, the epic-planner ready gate still demands Codex-only artifacts that the Claude epic planner (`.claude/agents/epic-planner.md:106-110`) does not write:
  - per-feature `model_routing_receipt` and `topology_receipt` (`scripts/dev_tools/validate_epic_planner_state.py:241-275`)
  - the top-level forced planner `topology_receipt` (`validate_epic_planner_state.py:332`)

  The Claude-runtime ready gate is therefore not yet passable end to end.
- Follow-up (conditional): add `--require-codex-model-routing` and `--require-codex-topology` to the Python CLI `epic-planner-state` subparser if CLI parity is later required. This must be paired with a line-neutral extraction from `scripts/dev_tools/validate_orchestration_artifacts.py`.
- Links:
  - Issue: https://github.com/drmoisan/drm-copilot/issues/543
  - Precedent: #524, `docs/features/completed/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/`
  - Research: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/research/research.2026-09-29T16-10.md`
