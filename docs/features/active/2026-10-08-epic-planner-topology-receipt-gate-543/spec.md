# 2026-10-08-epic-planner-topology-receipt-gate (Spec)

- **Issue:** #543 (residual scope; recorded in the issue comments dated 2026-09-30 and 2026-10-07)
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T14-10
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source; no `user-story.md` is created because no requirement in `issue.md` or the research needs a user-facing narrative)
- **Design source:** `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/research/research.2026-10-08T14-00.md` (recommended Approach A)
- **Precedent (context only, not edited):** `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md` (PR #829, merge commit 869c4fad)

## Context

`_validate_planner_topology_receipt` in `scripts/dev_tools/validate_epic_planner_state.py` runs unconditionally under `require_ready_for_execution`, so a Claude-prepared epic-planner checkpoint (which never writes a Codex `topology_receipt`) cannot pass the strict ready gate. PR #829 (merge commit 869c4fad) key-gated the launch-binding and launch-evidence checks but left this check, and its TypeScript parity port `validatePlannerTopologyReceipt` in `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`, unconditional.

The Claude epic-planner checkpoint contract (`.claude/agents/epic-planner.md:106-110`) lists no top-level `topology_receipt` key (research §1.3).

Environment:
- OS/version: any (observed on Windows 11)
- Python version: repository Poetry environment
- Command/flags used: epic-planner checkpoint validation with `require_ready_for_execution` (MCP `validate_orchestration_artifacts` with `artifact_type: epic-planner-state`, `require_ready_for_execution: true`)
- Data source or fixture: Claude-runtime epic-planner checkpoints for epics #770 and #771

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Repro & Evidence

Steps to Reproduce:
1. Prepare an epic with the Claude `epic-planner` agent, which writes no top-level `topology_receipt`.
2. Validate the planner checkpoint with `require_ready_for_execution: true` and without any Codex flag.
3. Observe the topology-receipt errors.

Expected:
Without `require_codex_model_routing` or `require_codex_topology`, the planner topology-receipt check is key-gated: a checkpoint that does not carry `topology_receipt` is not required to carry one. A checkpoint that does carry it is still validated in full, and the Codex flags keep the check unconditional.

Actual:
The ready gate reports `Epic planner topology_receipt must be an object.` for every Claude-prepared checkpoint, in both the Python validator and the TypeScript MCP port (research §1.1, §1.2).

Logs / Screenshots:
- Snippet: see issue #543 comments dated 2026-09-30 and 2026-10-07.

## Scope & Non-Goals

In scope:
- Python: condition the call at `scripts/dev_tools/validate_epic_planner_state.py:345` (inside `validate_epic_planner_state_text`, under `if require_ready_for_execution:`) on `not key_gated or "topology_receipt" in state`.
- TypeScript: condition the call at `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts:443` (inside `validateEpicPlannerStateText`, under `if (options.requireReadyForExecution === true)`) on `!requireLaunchPaths || "topology_receipt" in value`.
- Update the adjacent comments (Python line 328, TypeScript line 423) and the Python docstring (lines 289-291) so they state that the planner topology receipt is key-gated under the same rule.
- Update the defect-pinning test `test_readiness_requires_epic_preparation_topology_receipts` and add Python and TypeScript regression tests, plus an MCP service-call assertion.

Out of scope / non-goals:
- **Per-feature receipts.** The per-feature `model_routing_receipt` and `topology_receipt` checks in `_validate_ready_features` (`scripts/dev_tools/validate_epic_planner_state.py:222-276`) and `validateReadyFeatures` (`extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts:292-364`) remain unconditional. They are not changed by this fix (research §3.1).
- **Python CLI flag plumbing.** `scripts/dev_tools/validate_orchestration_artifacts.py` (495 lines) is not changed. The Python CLI continues to run the planner validator in key-gated mode only, as recorded by PR #829 (research §4).
- **Structural contract gap.** `REQUIRED_KEYS` includes `max_parallel_features` and `REQUIRED_FEATURE_KEYS` includes `research_path`; neither key appears in the Claude epic-planner field list. This is a follow-up observation only and is not changed here (research §3.2).
- Adding, removing, or rewording any error string in either runtime.
- Changing the signature of `_validate_planner_topology_receipt` / `validatePlannerTopologyReceipt` (rejected Approach C, research §5).
- Renaming `key_gated` / `requireLaunchPaths` (optional per research §5; not adopted, to keep the TypeScript diff minimal).

Explicitly excluded systems, integrations, or datasets:
- `.claude/**` and `.github/**`, including `.claude/rules/orchestrator-state.md`.
- Codex guidance and bundled mirrors (`.agents/**`, `.codex/**`, `extensions/drm-copilot/resources/**`). No mirror or guidance edit is required (research §8).
- MCP tool definitions and input mapping (`extensions/drm-copilot/src/mcp-tool-inputs.ts`, `mcp-tool-definitions.ts`, `mcp-repo-automation-tool-definitions.ts`), `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`, and `extensions/drm-copilot/jest.config.cjs`.

## Root Cause Analysis

The call site `errors.extend(_validate_planner_topology_receipt(state.get("topology_receipt")))` in `validate_epic_planner_state_text` is not conditioned on the `key_gated` value that PR #829 introduced at line 329. The TypeScript call `validatePlannerTopologyReceipt(value["topology_receipt"])` in `validateEpicPlannerStateText` is likewise not conditioned on `requireLaunchPaths` (lines 424-426). For an absent key, both runtimes pass `None` / `undefined` to the validator, which returns exactly one error: `Epic planner topology_receipt must be an object.` (research §1.1, §1.2).

## Proposed Fix

### Design summary (what changes where):

Reuse the PR #829 activation value and its key-membership predicate at the two call sites (research §2, Approach A):

- Python: `if not key_gated or "topology_receipt" in state:` then call `_validate_planner_topology_receipt(state.get("topology_receipt"))`.
- TypeScript: `if (!requireLaunchPaths || "topology_receipt" in value) { errors.push(...validatePlannerTopologyReceipt(value["topology_receipt"])); }`.

Target semantics under `require_ready_for_execution=True`:

| Codex flag | Top-level `topology_receipt` | Planner topology result |
|---|---|---|
| none | key absent | skipped; zero `Epic planner topology_receipt` errors |
| none | present, valid forced receipt | zero errors |
| none | present, `null` | `Epic planner topology_receipt must be an object.` |
| none | present, wrong field (for example `root_persona`) | existing field errors (unchanged) |
| either flag | key absent | `Epic planner topology_receipt must be an object.` (unchanged) |
| either flag | present | validated in full (unchanged) |

Without `require_ready_for_execution`, nothing changes, because the check never runs in that mode.

### Boundaries and invariants to preserve:

- **Key membership, not value truthiness.** A present key with a `null` value arms the check, consistent with `.claude/rules/orchestrator-state.md:197` and the PR #829 tests.
- **Codex behaviour unchanged.** When `require_codex_model_routing` or `require_codex_topology` is set, the check runs unconditionally, exactly as before.
- **Error strings unchanged** in both runtimes; Python and TypeScript strings remain byte-identical.
- **Source-text contract preserved.** The literals `validate_epic_planner_child_launch_bindings(` and `require_launch_paths=key_gated` asserted by `test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged` are not modified.
- **500-line limit.** `epic-planner-state-core.ts` is at 471 lines before the change; the change must keep it at or below 500.

### Dependencies or blocked work:

- None. The `key_gated` / `requireLaunchPaths` values and the Codex flag plumbing through the MCP route are already on `main` from PR #829 (research §4).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Production:
- `scripts/dev_tools/validate_epic_planner_state.py` (369 lines)
- `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` (471 lines)

Tests:
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py` (360 lines)
- `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` (413 lines)
- `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` (225 lines)

#### Functions/classes/CLI commands impacted:

- Python `validate_epic_planner_state_text` (call-site condition, comment, docstring only; signature unchanged).
- TypeScript `validateEpicPlannerStateText` (call-site condition and comment only; signature unchanged).
- MCP `validate_orchestration_artifacts` with `artifact_type: epic-planner-state`: behaviour changes for a checkpoint without a top-level `topology_receipt` when no Codex flag is supplied. The schema is unchanged.

#### Data flow and validation changes:

- No new keys are read or written. The only change is whether the existing planner topology check runs for a checkpoint that lacks the top-level key.

#### Error handling and logging updates:

- None. No error string is added, removed, or reworded. No logging changes.

#### Rollback/feature-flag considerations (if applicable):

- Rollback is a revert of the change set. Callers that need the previous behaviour can assert either Codex flag.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Inputs: checkpoint JSON text, `require_ready_for_execution`, readiness context, and the two Codex flags. Output: a list of error strings in the existing format.

#### Required configuration keys and defaults:

- No new keys. Existing defaults: `require_codex_model_routing=False`, `require_codex_topology=False` (Python); `undefined` (TypeScript).

#### Backward-compatibility expectations:

- Codex callers assert both flags (`.agents/skills/epic-plan/SKILL.md:183-185`, `.agents/skills/epic-run/SKILL.md:24-26`, `.codex/agents/epic-orchestrator.toml:42-44`, and their bundled mirrors) and are validated exactly as before.
- Any checkpoint carrying a top-level `topology_receipt` is validated exactly as before.

#### Performance constraints (latency/throughput/memory):

- No new constraints; the change adds one key-membership test per validation.

## Assumptions

The operator is not consulted; the following assumptions are recorded instead.

- Work mode is `full-bug` because the preparation route requires a spec and the change is a cross-language (Python and TypeScript) contract change.
- No new GitHub issue is created for this change; it is tracked against the existing issue #543.
- No bundled mirror, guidance, or rule-file edit is required, because all Codex ready-gate callers already assert both Codex flags and Codex behaviour is unchanged (research §8).
- No `user-story.md` is created; `spec.md` is the sole acceptance-criteria source.
- Key membership (not a value test) is the correct presence predicate, per the PR #829 precedent and `.claude/rules/orchestrator-state.md:197` (research §2).
- No automated Python-to-TypeScript execution parity test exists; parity is maintained by twin tests that assert byte-identical error strings.
- Research ran no shell commands; baseline pass/fail state was not observed. The executor must capture a baseline before making changes.
- `extensions/drm-copilot/jest.config.cjs` has no per-file threshold entry for `epic-planner-state-core.ts`; coverage for that file is verified from the full-run `text` reporter row rather than a configured threshold (research §10).

## Constraints and Dependencies

- Constraints: 500-line limit per production and test file; no `.claude/**`, `.github/**`, `.agents/**`, `.codex/**`, or `extensions/drm-copilot/resources/**` edits; `scripts/dev_tools/validate_orchestration_artifacts.py` unchanged.
- External dependencies: none.

## Data / API / Config Impact

- User-facing or API changes: the MCP and Python ready gates no longer reject a checkpoint for lacking a top-level `topology_receipt` when no Codex flag is asserted.
- Data or migration considerations: none.
- Logging/telemetry updates: none.
- Compatibility notes: Python CLI `epic-planner-state` subparser unchanged (key-gated mode only).

## Test Strategy

Seeded from issue:

- [ ] Unit coverage areas: Python and TypeScript tests for absent, present-valid, and present-invalid `topology_receipt` under key-gated and Codex-flagged modes
- [ ] Integration scenario to retest: MCP service call with `require_ready_for_execution` on a Claude-shaped checkpoint
- [ ] Manual verification notes: none

- Regression test (fail-before / pass-after): `test_ready_gate_skips_planner_topology_receipt_when_key_absent` in `tests/scripts/dev_tools/test_validate_epic_planner_state.py`.
- Defect-pinning test to update: `test_readiness_requires_epic_preparation_topology_receipts` (lines 213-234) asserts the top-level error with no Codex flag; it is updated to pass a Codex flag for that assertion. Its per-feature assertions remain valid.
- Positive scenarios: key absent with no flag; present valid receipt with and without a flag.
- Negative scenarios: key absent under each Codex flag; present `null` with no flag; present wrong field (already covered by `test_readiness_requires_forced_epic_planner_persona` and the TypeScript test `requires the forced epic-planner topology receipt`).
- Integration: extend `it("threads the Codex flags into epic-planner-state")` in `validate-orchestration-service-call.test.ts`. The substring `Epic planner topology_receipt` does not occur in the per-feature prefix `Epic planner checkpoint features[0].topology_receipt`, so a negative assertion on it is unambiguous.
- All tests are in-memory JSON fixtures with no temporary files, clock, or network, and follow Arrange-Act-Assert with descriptive names.

Commands (Python, from the worktree root):

```
poetry run black --check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py
poetry run ruff check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py
poetry run pyright scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py
poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_ready_gate_skips_planner_topology_receipt_when_key_absent" -vv
poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py --cov=scripts.dev_tools.validate_epic_planner_state --cov-branch --cov-report=term-missing
poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

`--cov` must use the dotted module name; a `.py` path measures nothing.

Commands (TypeScript, from `extensions/drm-copilot/`):

```
npx prettier --check src/lib/validate/epic-planner-state-core.ts test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/validate-orchestration-service-call.test.ts
npm run lint
npm run typecheck
node run-jest.cjs test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/validate-orchestration-service-call.test.ts test/lib/validate/epic-planner-state-launch-binding.test.ts test/lib/validate/epic-planner-readiness-integrity.test.ts
node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary
```

Evidence goes under `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/<kind>/` (`baseline/`, `regression-testing/`, `qa-gates/`).

## Acceptance Criteria

- [x] `test_ready_gate_skips_planner_topology_receipt_when_key_absent` in `tests/scripts/dev_tools/test_validate_epic_planner_state.py` removes the top-level `topology_receipt` key from a ready checkpoint, calls `validate_epic_planner_state_text` with `require_ready_for_execution=True` and no Codex flag, and asserts that no error contains `"Epic planner topology_receipt"`. The test is recorded failing on pre-fix code and passing after the fix, with evidence under `evidence/regression-testing/`.
- [x] `test_codex_flag_keeps_planner_topology_receipt_unconditional` in `tests/scripts/dev_tools/test_validate_epic_planner_state.py` is parametrized over `require_codex_model_routing=True` and `require_codex_topology=True`, removes the top-level `topology_receipt` key, and asserts that `"Epic planner topology_receipt must be an object."` is in the returned errors. The test passes for both parameters.
- [x] `test_ready_gate_validates_present_null_planner_topology_receipt` in `tests/scripts/dev_tools/test_validate_epic_planner_state.py` sets the top-level `topology_receipt` to `None` with no Codex flag and asserts that `"Epic planner topology_receipt must be an object."` is in the returned errors. The test passes.
- [x] A Python test in `tests/scripts/dev_tools/test_validate_epic_planner_state.py` validates a ready checkpoint carrying a valid forced planner `topology_receipt`, with no Codex flag and under `require_codex_topology=True`, and asserts that no error contains `"Epic planner topology_receipt"` in either mode. The test passes.
- [x] `test_readiness_requires_epic_preparation_topology_receipts` in `tests/scripts/dev_tools/test_validate_epic_planner_state.py` is updated so that its `"Epic planner topology_receipt must be an object"` assertion runs with a Codex flag (`require_codex_topology=True` or `require_codex_model_routing=True`) asserted. Its per-feature assertions are retained, and the test passes.
- [x] `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` contains passing TypeScript twins of the four new Python tests above: key absent with no Codex flag yields no error containing `Epic planner topology_receipt`; key absent under each of `requireCodexModelRouting: true` and `requireCodexTopology: true` (for example via `it.each`) yields `Epic planner topology_receipt must be an object.`; a present `null` with no Codex flag yields `Epic planner topology_receipt must be an object.`; a present valid receipt yields no `Epic planner topology_receipt` error with and without a Codex flag. Every asserted error string is byte-identical to the corresponding Python assertion.
- [x] `it("threads the Codex flags into epic-planner-state")` in `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` additionally asserts that the `requireCodexModelRouting` result and the `requireCodexTopology` result each contain `Epic planner topology_receipt must be an object.`, and that the key-gated (no Codex flag) result contains no error with the substring `Epic planner topology_receipt`. The test passes.
- [x] The Python call to `_validate_planner_topology_receipt` in `validate_epic_planner_state_text` and the TypeScript call to `validatePlannerTopologyReceipt` in `validateEpicPlannerStateText` are each conditioned on key membership of the top-level `topology_receipt` key (`"topology_receipt" in state` / `"topology_receipt" in value`) or an asserted Codex flag, verified by reading the source. No error string is added, removed, or reworded in either runtime, verified by `git diff main` on both production files showing no changed string literal containing `Epic planner`.
- [x] Pre-existing tests that supply a present top-level `topology_receipt` pass without modification, including `test_readiness_requires_forced_epic_planner_persona`, `it("requires the forced epic-planner topology receipt")`, `test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged`, and `test_cli_dispatches_planner_readiness_flag`. Verified by the targeted `poetry run pytest` and `node run-jest.cjs` commands in Test Strategy exiting 0.
- [x] `git diff main -- scripts/dev_tools/validate_orchestration_artifacts.py .claude .github .agents .codex extensions/drm-copilot/resources extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/src/mcp-tool-inputs.ts` produces no output, confirming that CLI plumbing, guidance, mirrors, rules, and Jest configuration are unchanged.
- [x] The full seven-stage toolchain loop (format, lint, type-check, architecture, unit, contract, integration) completes in a single clean pass for the changed Python files (black, ruff, pyright, pytest) and the changed TypeScript files (prettier, ESLint, tsc, Jest), with results recorded under `evidence/qa-gates/`.
- [x] `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing` (with the `--deselect` in Test Strategy) exits 0 and reports at least 85% line and 75% branch coverage for `scripts/dev_tools/validate_epic_planner_state.py`, with no coverage regression on changed lines relative to the recorded baseline.
- [x] `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` exits 0 from `extensions/drm-copilot/` and its `text` reporter row for `src/lib/validate/epic-planner-state-core.ts` shows at least 85% line and 75% branch coverage, with no coverage regression on changed lines relative to the recorded baseline. Both outcomes of the new conditional (check run and check skipped) are exercised.
- [x] Every production and test file named under "Files/modules to change" is at most 500 lines after the change, verified with `(Get-Content <path>).Count` for each file and recorded under `evidence/qa-gates/`.

## Risks & Mitigations

- Risk: a Codex caller that omits both flags would have an absent planner receipt skipped silently.
  - Mitigation: all Codex ready-gate callers and their mirrors already assert both flags, pinned by `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py:407-423`.
- Risk: a value test instead of key membership would accept `"topology_receipt": null`.
  - Mitigation: the present-`null` tests in both runtimes pin key-membership semantics.
- Risk: Python and TypeScript diverge.
  - Mitigation: twin tests assert byte-identical error strings.
- Risk: `epic-planner-state-core.ts` has 29 lines of headroom.
  - Mitigation: the change is confined to the call site and its comment; the line-count criterion verifies the limit.
- Rollback: revert the change set.

## Rollout & Follow-up

- Release/rollout steps: ship with the next extension release. No bundled mirror changes are required.
- **End-to-end status:** after this fix, a Claude-prepared checkpoint still cannot pass the strict ready gate end to end. The per-feature `model_routing_receipt` and `topology_receipt` checks in `_validate_ready_features` / `validateReadyFeatures` remain unconditional and emit errors for every feature that lacks them (research §3.1, §6).
- **PR wording:** because the issue's end-to-end outcome is not reached, the PR must state "Partially addresses #543" and must not close the issue, unless the operator decides otherwise.
- **Recommended follow-up issue (not created by this change):** key-gate or otherwise resolve the per-feature `model_routing_receipt` and `topology_receipt` ready-gate checks in both runtimes, and reconcile the structural contract gap where `REQUIRED_KEYS` / `REQUIRED_FEATURE_KEYS` require `max_parallel_features` and `research_path` that the Claude epic-planner field list (`.claude/agents/epic-planner.md:106-110`) omits (research §3.2).
- Follow-up (conditional, carried from PR #829): add Codex flags to the Python CLI `epic-planner-state` subparser if CLI parity is later required, paired with a line-neutral extraction from `scripts/dev_tools/validate_orchestration_artifacts.py`.
- Links:
  - Issue: https://github.com/drmoisan/drm-copilot/issues/543
  - Precedent: PR #829, `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/`
  - Research: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/research/research.2026-10-08T14-00.md`
