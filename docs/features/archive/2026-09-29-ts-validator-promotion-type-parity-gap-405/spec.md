# 2026-09-29-ts-validator-promotion-type-parity-gap-405 (Spec)

- **Issue:** #405
- **Parent (optional):** Epic `orchestrator-state-contract-correctness` (#771). Also covers item 3 of issue #623.
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T14-45
- **Status:** Draft
- **Version:** 1.0

## Context

- Summary of the bug and its impact: The TypeScript routing-contract validator does not resolve the promotion-entry MCP tool from the checkpoint `promotion-type`. The Python validator (`_resolve_promotion_entry_tools`, PR #402) and the PowerShell validator (`Get-ResolvedRequiredMcpTool`) replace `new_potential_entry` with `new_potential_bug_entry` when `promotion-type` is exactly `"bug"`. TypeScript `validateRoutingContract` in `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` uses the raw matrix `required_mcp_tools` list. As a result, the `validate_orchestration_artifacts` MCP tool rejects bug-type checkpoints that the Python CLI and the PowerShell completion gate accept. Source record: `docs/features/potential/promoted/2026-07-24-ts-validator-promotion-type-parity-gap.md`. Investigation: `research/research.2026-09-29T14-30.md`.
- Observed environment(s): Surface-independent logic divergence. Observed on Windows 11 (10.0.26200) with the repository Poetry environment and the `drm-copilot` MCP server.
- Customer impact and severity: Medium. Any agent or extension command that self-checks completion through the MCP tool receives a false blocking error for bug-type checkpoints on the `small`, `large`, and `preparation` routes. The authoritative Python CLI and the SubagentStop hook path are not affected.
- First observed date and version(s) impacted: Recorded 2026-07-24 while closing issue #399 / PR #402. Impacts every extension version that ships the TypeScript validator without promotion-type resolution, up to and including 1.1.15.

## Repro & Evidence

- Steps to reproduce:
  1. Build a checkpoint with `route_id: large` (or `small`, `preparation`), `promotion-type: "bug"`, a declared `required_mcp_tools` list containing `new_potential_bug_entry` in place of `new_potential_entry`, and a successful `new_potential_bug_entry` receipt in `mcp_call_receipts`.
  2. Validate with the Python CLI using `--require-complete`. Result: no routing-contract error.
  3. Validate the same checkpoint through the TypeScript `validateRoutingContract` (MCP tool `validate_orchestration_artifacts` with `require_complete: true`).
- Expected vs actual behavior: Expected, the TypeScript validator returns the same ordered error list as Python and PowerShell (empty for a correct bug checkpoint). Actual, TypeScript emits `Checkpoint required_mcp_tools must match routing matrix for route <route>.` because the declared list differs from the raw matrix list, and emits `Checkpoint missing successful MCP receipt: new_potential_entry.` because the receipt loop requires the feature tool.
- Logs/screenshots/error snippets: The two error strings above. Both come from one unresolved variable at `orchestrator-state-routing.ts` line 408 (`const requiredMcpTools = routeList(rawRoute, "required_mcp_tools");`), used at the `stateList` equality check (line 420) and the receipt loop (line 441).
- Frequency / determinism: Deterministic for every checkpoint whose `promotion-type` is exactly `"bug"` on a route whose matrix list contains `new_potential_entry` (`small`, `large`, `preparation`).

## Scope & Non-Goals

- In scope:
  - A new pure TypeScript module that resolves the promotion-entry tool list from checkpoint state.
  - One-line wiring change in `validateRoutingContract` so the resolved list feeds both the declared-list equality check and the receipt loop.
  - Unit tests for the module and the routing contract, using the real routing matrix.
  - A shared cross-runtime parity corpus with Python, TypeScript, and Pester readers.
  - A per-file jest coverage threshold for the new module.
- Out of scope / non-goals:
  - Issue #343: `pr_gate`/`ci_gate` route-gating parity.
  - Issue #509: accepting pre-existing-issue evidence in place of a `potential_to_issue` receipt. The new module is kept separate so #509 can extend receipt resolution without editing the 451-line routing file.
  - Any file listed under issue #769.
  - Adding Python legs to enforcement hooks.
  - Production changes to the PowerShell or Python validators, and any change to the bundled PowerShell mirror under `extensions/drm-copilot/resources/`.
  - Reading the underscore key `promotion_type`. That name belongs to MCP tool inputs and is unrelated to the checkpoint key.
- Explicitly excluded systems, integrations, or datasets: `config/orchestration-routing.json` content, GitHub issue tooling, and orchestrator-state schema changes.

## Root Cause Analysis

- Current hypothesis or confirmed root cause: Confirmed by code reading. PR #402 fixed the Python validator and the PowerShell validator gained the same substitution, but the TypeScript port was deferred as out of scope and never updated.
- Signals/evidence supporting it:
  - No resolution exists anywhere under `extensions/drm-copilot/src/`. The only `promotion-type` occurrence under `src/lib/validate/` is the required-key list at `orchestrator-state-core.ts:62`.
  - Python computes the resolved list once (`_orchestrator_state_routing.py` lines 557-559) and uses it for both the equality check (line 571) and the receipt loop (lines 587-590). PowerShell does the same in `Get-OrchestratorStateRoutingContractError` (lines 379-394 and 412-417).
  - The existing TypeScript test file has no bug or promotion-type test and uses a stale in-file matrix that does not mirror `config/orchestration-routing.json`.
- Affected components/modules:
  - `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` (defect site; only caller is `orchestrator-state-core.ts:441`).
  - `extensions/drm-copilot/test/lib/validate/orchestrator-state-routing.test.ts` (no coverage of the behavior; stale matrix).

## Proposed Fix

### Design summary (what changes where):

Add `extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts`, a pure module with no import from `orchestrator-state-routing.ts`. It exports `resolvePromotionEntryTools(tools, state)`. In `validateRoutingContract`, replace the raw list with `resolvePromotionEntryTools(routeList(rawRoute, "required_mcp_tools"), state)`, computed once and used for both the `stateList` equality check and the receipt loop. This yields the same ordered error list as Python and PowerShell: agents, skills, and tools equality errors, then receipt errors in matrix order.

Semantics (mirror of Python and PowerShell):
- Substitution occurs only when `state["promotion-type"] === "bug"` (strict equality). No trim and no case folding.
- Only the hyphenated key `promotion-type` is read.
- Absent, `null`, non-string, `"Bug"`, `" bug"`, `"feature"`, and any other value return the list unchanged.
- Each element equal to `new_potential_entry` (exact, case-sensitive) becomes `new_potential_bug_entry`. Order and all other tools are preserved. The function returns a new array and does not mutate its input.

### Boundaries and invariants to preserve:

- Error strings and error ordering for all existing checkpoints are unchanged.
- The module is pure: no I/O, no clock, no randomness.
- Substitution is route-agnostic. It is a no-op on routes whose list lacks `new_potential_entry` (`remediation`, `parallel`, `epic`).
- `required_agents` and `required_skills` handling is unchanged.

### Dependencies or blocked work:

- Blocks #509 (wave 1), which extends receipt resolution in all three runtimes.
- No blocking dependency. Wave 0 in the epic.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

- New: `extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts`.
- Edit: `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` (single-line change plus one import).
- Edit: `extensions/drm-copilot/jest.config.cjs` (per-file threshold entry).
- New tests: `extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-tools.test.ts`, additions to a routing-contract test using the real matrix, `extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-type-parity.test.ts`, `tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1`.
- New fixtures: `tests/fixtures/orchestrator_state_promotion_type/*.json`.

#### Functions/classes/CLI commands impacted:

- `validateRoutingContract` (behavior change for `promotion-type: "bug"` only).
- New `resolvePromotionEntryTools` and exported constants `FEATURE_PROMOTION_ENTRY_TOOL`, `BUG_PROMOTION_ENTRY_TOOL`, `BUG_PROMOTION_TYPE`, `PROMOTION_TYPE_KEY`.

#### Data flow and validation changes:

Matrix list for the selected route, then `resolvePromotionEntryTools`, then the resolved list feeds `stateList(state, "required_mcp_tools", ...)` and the receipt-presence loop. The matrix source (injected `routingMatrix` or `loadRoutingMatrix`) is unchanged.

#### Error handling and logging updates:

None. No new error messages. Existing messages are emitted with the same text.

#### Rollback/feature-flag considerations (if applicable):

None. Revert the single-line change and the import to restore prior behavior.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

`resolvePromotionEntryTools(requiredMcpTools: string[], state: Record<string, unknown>): string[]`. Returns a new array.

Parity corpus: one JSON file per case in `tests/fixtures/orchestrator_state_promotion_type/`, shape `{ "name", "notes", "checkpoint", "expected_errors" }`. `expected_errors` is the full ordered routing-contract error list. Cases: bug with bug tool everywhere; feature; bug with only the feature tool declared and recorded; absent `promotion-type`; `"Bug"`; `" bug"`; non-string value; bug on `small`; bug on `preparation`; bug on `remediation`; bug on `epic`. Each reader asserts ordered equality with `expected_errors` and a minimum-corpus-size guard so an empty directory cannot pass vacuously. The corpus follows the design of `tests/fixtures/parallel_cohort_barrier/`.

#### Required configuration keys and defaults:

None new. `jest.config.cjs` gains a `coverageThreshold` entry of 85 lines and 75 branches for the new module.

#### Backward-compatibility expectations:

Checkpoints with no `promotion-type` or a non-`"bug"` value validate byte-identically to current behavior.

#### Performance constraints (latency/throughput/memory):

None. The function is a linear map over a list of fewer than ten elements.

## Assumptions, Constraints, Dependencies

- Assumptions: The real matrix in `config/orchestration-routing.json` lists `new_potential_entry` in exactly `small`, `large`, and `preparation`. Python (`_orchestrator_state_routing.py`) and PowerShell behavior are the parity authorities and are correct.
- Constraints: No file may exceed 500 lines. TypeScript tests live under `extensions/drm-copilot/test/`; Python and Pester tests live under `tests/`. Fixtures are committed files; no test creates temporary files. TypeScript tests must load the real `config/orchestration-routing.json` matrix and must not extend the stale in-test matrix. Coverage remains at or above 85% line and 75% branch (no branch gate for Pester).
- External dependencies: none new. A `fast-check` property test for the pure function is permitted only if `fast-check` is already an approved extension dependency; this was not verified in research.

## Data / API / Config Impact

- User-facing or API changes: The MCP tool `validate_orchestration_artifacts` returns the same result as the Python CLI for bug-type checkpoints.
- Data or migration considerations: None.
- Logging/telemetry updates (if any): None.
- Compatibility notes: No schema, CLI flag, or version change to the matrix. PowerShell and Python validators and the bundled PowerShell mirror are unchanged.

## Test Strategy

- Regression tests to add or update: TypeScript routing-contract tests mirroring the four PR #402 Python tests (bug with bug tool passes; feature no-regression; dead skill names `orchestrator-workflow` and `repo-automation-adapter` absent from the real `large.required_skills`; bug with only the feature tool is rejected).
- Unit tests for the fixed behavior and boundaries: `orchestrator-state-promotion-tools.test.ts` covering bug substitution, order preservation, feature/absent/`null`/non-string/`"Bug"`/`" bug"` unchanged, input not mutated, and a list without the feature tool unchanged.
- Edge cases and negative scenarios: exact-match variants above; routes where substitution is a no-op; bug-with-only-feature-tool asserts both `Checkpoint required_mcp_tools must match routing matrix for route large.` and `Checkpoint missing successful MCP receipt: new_potential_bug_entry.`, and asserts `Checkpoint missing successful MCP receipt: new_potential_entry.` is absent.
- Error handling and logging verification: exact error strings and ordering asserted through the parity corpus.
- Coverage impact and targets for changed lines/modules: per-file 85/75 on the new module; no regression on the changed lines of `orchestrator-state-routing.ts`.
- Toolchain commands to run (format, lint, type-check, test): TypeScript from `extensions/drm-copilot`: `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:coverage`. Python: `poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py` and the routing-contract test file. Pester: the PoshQC self-hosted module invocation for the new parity test and the existing routing-contract tests.
- Manual validation steps (if required): none.

## Acceptance Criteria

Note: the text of issue #405 was not retrievable in this session (`gh` and Bash were unavailable). Items 1 through 3 are taken from the "Proposed Fix / Validation Ideas" and "Expected Behavior" sections of the promoted record from which the issue body was generated. The implementer should confirm them against the issue body when `gh` is available.

- [x] A `promotion-type: "bug"` checkpoint on the `large` route that declares `new_potential_bug_entry` in `required_mcp_tools` and records a successful `new_potential_bug_entry` receipt (and no `new_potential_entry` receipt) produces no routing-contract error from the TypeScript validator, matching the Python CLI and the MCP tool result.
- [x] TypeScript unit tests mirror the four PR #402 Python tests: bug-type pass, feature-type no-regression, dead-skill-name absence (if still applicable; it is, per research), and bug-type-with-only-feature-tool rejection.
- [x] The same fixture checkpoint run through the Python validator and the TypeScript validator yields identical results, verified by a shared parity test.
- [x] `extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts` exists and exports pure `resolvePromotionEntryTools(tools, state)` with exact-match semantics: substitution only when `state["promotion-type"] === "bug"`, with no trimming, no case folding, and only the hyphenated key; absent, non-string, and other values leave the list unchanged; order is preserved and the input is not mutated.
- [x] `validateRoutingContract` computes the resolved tool list once and uses it for both the `required_mcp_tools` equality check and the receipt-presence loop.
- [x] Unit tests for `resolvePromotionEntryTools` cover bug substitution, order preservation, feature, absent, `null`, non-string, `"Bug"`, and `" bug"` inputs, non-mutation of the input, and a list that does not contain the feature tool.
- [x] A parity corpus exists at `tests/fixtures/orchestrator_state_promotion_type/*.json`, each file shaped `{name, notes, checkpoint, expected_errors}`, covering: bug with bug tool, feature, bug with only feature tool, absent key, `"Bug"`, `" bug"`, non-string value, and bug on each of `small`, `preparation`, `remediation`, and `epic`.
- [x] A Python test reads the corpus and asserts each `expected_errors` list equals the validator's ordered error list, with a minimum-corpus-size guard that fails on an empty or short corpus.
- [x] A TypeScript test reads the same corpus and asserts identical ordered error lists using the real `config/orchestration-routing.json` matrix, with a minimum-corpus-size guard.
- [x] A Pester test reads the same corpus and asserts identical ordered error lists through `Get-OrchestratorStateRoutingContractError` (which accepts a parsed state object), with a minimum-corpus-size guard. Decision: the Pester reader is included because research confirms the function is callable from Pester with a state object; it remains within the 500-line rule.
- [x] TypeScript tests load the real `config/orchestration-routing.json` matrix and do not rely on the stale in-file matrix of `orchestrator-state-routing.test.ts`.
- [x] `extensions/drm-copilot/jest.config.cjs` has a per-file coverage threshold entry of 85% lines and 75% branches for `src/lib/validate/orchestrator-state-promotion-tools.ts`, and the threshold passes.
- [x] Existing checkpoints with no `promotion-type` or a non-`"bug"` value validate byte-identically to the pre-change output.
- [x] No production or test file changed or added by this work exceeds 500 lines.
- [x] No production change is made to the PowerShell or Python validators or to the bundled PowerShell mirror, and no work is done on #343, #509, files in issue #769, or Python legs in enforcement hooks.
- [x] Full toolchain pass completed (format, lint, type-check, architecture-boundary tests, unit tests, contract checks, integration tests) with line coverage at or above 85% and branch coverage at or above 75% where measured.

## Risks & Mitigations

- Technical or operational risks: TypeScript could drift from the exact-match rule (for example through a later `toLowerCase` or `trim`); the pinned PowerShell matrix could drift from `config/orchestration-routing.json`; the parity corpus could pass vacuously.
- Mitigations and rollbacks: The shared corpus asserts exact-match cases (`"Bug"`, `" bug"`, non-string) in all three runtimes; minimum-corpus-size guards prevent vacuous passes; corpus checkpoints use only pinned route content (`small`, `large`, `preparation`, `remediation`, `epic`); rollback is a revert of the single-line wiring change.

## Rollout & Follow-up

- Release/rollout steps: Ships with the next extension release. No configuration or migration steps.
- Post-fix monitoring or clean-up tasks: #509 extends `resolvePromotionEntryTools` (or its signature) for pre-existing-issue evidence. Open items from research: confirm `fast-check` availability, and confirm the config-parity Pester test that keeps the pinned PowerShell matrix honest.
- Links: issue #405, issue #623 (item 3), epic #771, PR #402, issue #343, issue #509, `docs/features/epics/orchestrator-state-contract-correctness/epic.md`, `research/research.2026-09-29T14-30.md`.
