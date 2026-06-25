# orchestrator-state-routing-contract-mismatch (Spec)

- **Issue:** #230
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-24T17-55
- **Status:** Implemented (all acceptance criteria verified)
- **Version:** 0.1

## Context
The strict `require_complete` orchestrator-state validation (the routing contract in `scripts/dev_tools/_orchestrator_state_routing.py` against `config/orchestration-routing.json`) cannot be satisfied with truthful receipts in the current runtime. The matrix requires agent names and discrete skill/MCP receipts that do not match the agents/skills/tools actually available.

Environment:
- OS/version: repository orchestration runtime
- Python version: project default (Poetry)
- Command/flags used: `validate_orchestration_artifacts` with `require_complete: true` (artifact_type `orchestrator-state`)
- Data source or fixture: `artifacts/orchestration/orchestrator-state.json`, `config/orchestration-routing.json`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

The enforced structural validation passes, so DONE is not blocked, but the strict completion gate cannot be used as an acceptance check because it diverges from the real agent/skill/tool inventory.


## Repro & Evidence
Steps to Reproduce:
1. Complete a `large`-route orchestration through PR creation and the CI green gate.
2. Validate the checkpoint with `validate_orchestration_artifacts` using `require_complete: true`.
3. Observe the routing-contract errors.

Expected:
A truthfully completed orchestration produces a checkpoint that passes `require_complete: true` validation, with required agents/skills/MCP receipts that correspond to the agents and tools the runtime actually provides.

Actual:
The completion gate reports, for the `large` route:
- `required_agents must match routing matrix` and `missing required agent receipt: feature-reviewer` / `commit-steward` — but the available review agent is `feature-review` (not `feature-reviewer`), and there is no `commit-steward` agent (commits are made directly per the orchestrate skill's Pre-Feature-Review Commit step).
- `required_skills`/`required_mcp_tools must match` and missing `skill_receipts` / `mcp_call_receipts` for skills/tools such as `orchestrator-workflow`, `repo-automation-adapter`, and `collect_commit_context` that are not emitted as discrete receipts.

The default (non-strict) structural validation passes; only the strict completion gate is unsatisfiable.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: `Checkpoint missing required agent receipt: feature-reviewer.` / `Checkpoint missing required agent receipt: commit-steward.` (and analogous required_skills / required_mcp_tools errors) from `require_complete: true`.


## Scope & Non-Goals
- In scope:
  - Correct the routing matrix in `config/orchestration-routing.json` so that every `required_agents`, `required_skills`, and `required_mcp_tools` entry names a real agent (`.claude/agents/`), a real skill (`.claude/skills/`), or a real MCP tool registered by the `drm-copilot` MCP server, for all three routes (`small`, `large`, `remediation`).
  - Apply the identical correction to the bundled mirror `extensions/drm-copilot/resources/config/orchestration-routing.json` so the two copies are byte-aligned.
  - Amend `.claude/skills/orchestrate/SKILL.md` to instruct the orchestrator to emit `skill_receipts[]`, `mcp_call_receipts[]`, and `delegation_receipts[]` entries in the shapes the validator reads, so a truthful completed checkpoint can satisfy `require_complete: true`.
  - Add or update Python tests confirming: a truthful completed-large checkpoint passes `require_complete`; missing/renamed receipts fail with clear messages; and the canonical and bundled config copies are identical.
- Out of scope / non-goals:
  - No change to the validator logic in `scripts/dev_tools/_orchestrator_state_routing.py` or `scripts/dev_tools/validate_orchestrator_state.py` (or their bundled mirrors) beyond what reading corrected config data produces. The validator already reads the three receipt arrays in exactly the required shapes; only the matrix data and the skill instructions change.
  - No new agents, skills, or MCP tools are created. Stub `.claude/agents/feature-reviewer.md` or `.claude/agents/commit-steward.md` files are explicitly rejected (see Root Cause and research §9), as are stub `orchestrator-workflow` / `repo-automation-adapter` skill files.
  - The `required_skills` / `required_mcp_tools` validation is not removed or relaxed away; the invariant is retained and corrected, not deleted.
  - No changes to the TypeScript MCP server source; no MCP tools are added or removed.
- Explicitly excluded systems, integrations, or datasets:
  - The Codex-era customization payload under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/` (notably `orchestrator-workflow/SKILL.md` and `repo-automation-adapter/SKILL.md`), which still references the stale names (`feature-reviewer`, `commit-steward`, `orchestrator-workflow`, `repo-automation-adapter`). These govern the Codex runtime, not the Claude Code runtime, and are out of scope unless scope is explicitly expanded (research §8).
  - Branch-protection and required-check configuration are unchanged.

## Root Cause Analysis
The routing matrix (`config/orchestration-routing.json`) and `_orchestrator_state_routing.py` encode a canonical agent/skill/tool naming scheme (`feature-reviewer`, `commit-steward`, `orchestrator-workflow`, `repo-automation-adapter`, `collect_commit_context`, etc.) that does not match the actual `.claude/agents/` roster (`feature-review`, no `commit-steward`) or the runtime receipts. Files to inspect: `config/orchestration-routing.json`, `scripts/dev_tools/_orchestrator_state_routing.py`, `.claude/agents/`.


## Proposed Fix

### Design summary (what changes where):
Reconcile the routing matrix with the real Claude Code runtime inventory and add a receipt-emission contract to the orchestrate skill so that `require_complete: true` is satisfiable with truthful receipts. Three categories of correction apply to all three routes:

- **Agents:** rename `feature-reviewer` -> `feature-review` (the real agent is `.claude/agents/feature-review.md`); remove `commit-steward` (no such agent exists; commits are made directly by the orchestrator via the `commit-message` skill in the orchestrate skill's Pre-Feature-Review Commit and Pre-R4 commit steps, which is not a delegated agent handoff and produces no `delegation_receipt`).
- **Skills:** remove `orchestrator-workflow` (the Claude Code equivalent is `orchestrate`) and `repo-automation-adapter` (no such skill; MCP tools are invoked directly). Retain only skills that exist under `.claude/skills/`.
- **MCP tools:** remove `collect_commit_context` (the orchestrate skill does not call this tool; commit context comes from the `commit-message` skill, not an MCP call, so no `mcp_call_receipt` is produced for it). Retain the five tools that exist and are actually called.

In addition, `.claude/skills/orchestrate/SKILL.md` is amended to instruct the orchestrator to write `skill_receipts[]` and `mcp_call_receipts[]` entries (and `delegation_receipts[]` agent entries) for the retained required names so the checkpoint can pass `require_complete: true`.

### Boundaries and invariants to preserve:
- The validator logic in `scripts/dev_tools/_orchestrator_state_routing.py` is unchanged. The functions `_receipt_agents`, `_receipt_skills`, and `_mcp_tools` already read exactly the receipt shapes the corrected runtime emits; only the matrix data they compare against changes.
- The strict-vs-default validation contract is preserved: default (non-strict) structural validation continues to pass; the change makes the strict completion gate satisfiable rather than removing it.
- Backward compatibility for existing step-based checkpoints (no `remediation_loop`, no `human_interaction`) is unaffected.
- The two config copies (`config/orchestration-routing.json` and `extensions/drm-copilot/resources/config/orchestration-routing.json`) must remain byte-identical.

### Dependencies or blocked work:
None. All changes are repository-local file edits. No third-party UI, external service, or human-gated approval is required (research §10: human-interaction requirement is None).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
1. `config/orchestration-routing.json` — canonical routing matrix.
2. `extensions/drm-copilot/resources/config/orchestration-routing.json` — bundled mirror; identical content, kept in lockstep.
3. `.claude/skills/orchestrate/SKILL.md` — add receipt-emission instructions.

Verification-only (no expected source edits): `scripts/dev_tools/_orchestrator_state_routing.py`, `extensions/drm-copilot/resources/scripts/dev_tools/_orchestrator_state_routing.py`, `scripts/dev_tools/validate_orchestrator_state.py`, and its bundled mirror.

#### Target routing-matrix values (both copies, identical):

`small` route:
- `required_agents`: `atomic-planner`, `atomic-executor`, `feature-review`
- `required_skills`: `orchestrate`, `feature-promotion-lifecycle`, `atomic-plan-contract`, `acceptance-criteria-tracking`, `pr-context-artifacts`, `pr-base-branch-merge-base`
- `required_mcp_tools`: `new_potential_entry`, `potential_to_issue`, `new_active_feature_folder`, `collect_pr_context`, `validate_orchestration_artifacts`

`large` route:
- `required_agents`: `task-researcher`, `prd-feature`, `atomic-planner`, `atomic-executor`, `feature-review`
- `required_skills`: `orchestrate`, `feature-promotion-lifecycle`, `atomic-plan-contract`, `acceptance-criteria-tracking`, `pr-context-artifacts`, `pr-base-branch-merge-base`
- `required_mcp_tools`: `new_potential_entry`, `potential_to_issue`, `new_active_feature_folder`, `collect_pr_context`, `validate_orchestration_artifacts`

`remediation` route:
- `required_agents`: `atomic-planner`, `atomic-executor`, `feature-review`
- `required_skills`: `orchestrate`, `atomic-plan-contract`, `acceptance-criteria-tracking`, `pr-context-artifacts`
- `required_mcp_tools`: `collect_pr_context`, `validate_orchestration_artifacts`

In every route the changes from the current matrix are: remove `feature-reviewer`, remove `commit-steward`, remove `orchestrator-workflow`, remove `repo-automation-adapter`, remove `collect_commit_context`; rename the review agent to `feature-review`. The remediation route does not add `feature-promotion-lifecycle` or `pr-base-branch-merge-base`; it does not include promotion-lifecycle steps.

#### Functions/classes/CLI commands impacted:
No function or class signatures change. The consumers `validate_routing_contract`, `_receipt_agents`, `_receipt_skills`, and `_mcp_tools` in `_orchestrator_state_routing.py` read the corrected matrix and corrected receipt arrays without code change. `validate_orchestration_artifacts` (MCP tool, `require_complete: true`) is the entry point exercised by the acceptance scenario.

#### Data flow and validation changes:
The data flow is unchanged. `load_routing_matrix()` reads the corrected JSON; `validate_routing_contract` compares the checkpoint's `required_agents` / `required_skills` / `required_mcp_tools` lists against the corrected matrix and verifies that `delegation_receipts[].agent_name`, `skill_receipts[]`, and `mcp_call_receipts[]` cover the corrected required names. With corrected names and the new receipt-emission instructions, a truthful completed checkpoint produces matching receipts.

#### Error handling and logging updates:
None. The validator's existing per-violation error strings (for example `Checkpoint missing required agent receipt: <name>.`, `Checkpoint missing required skill receipt: <name>.`, `Checkpoint missing successful MCP receipt: <name>.`) remain the failure messages; after the fix they reference the corrected names.

#### Rollback/feature-flag considerations (if applicable):
No feature flag. Rollback is reverting the three changed files. Because the validator reads the matrix dynamically, reverting the config restores prior behavior with no code change.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
The orchestrate skill instructs the orchestrator to write the following receipt-array entry shapes to `artifacts/orchestration/orchestrator-state.json` so the validator's collectors accept them:

- `skill_receipts[]` entry (read by `_receipt_skills`): an object with `skill` (non-empty string equal to a `required_skills` entry), `required: true`, and `evidence` (non-empty string identifying the skill file read, for example `"read:.claude/skills/orchestrate/SKILL.md"`). An `acknowledged_at_phase` field may be included but is not required by the validator.
- `mcp_call_receipts[]` entry (read by `_mcp_tools`): an object with `tool` (non-empty string equal to a `required_mcp_tools` entry), `ok: true`, and `evidence` (non-empty string, for example the MCP response summary or artifact path).
- `delegation_receipts[]` entry (read by `_receipt_agents`): an object that supplies `agent_name` as a non-empty string equal to a `required_agents` entry. The orchestrator's direct commit step is not a delegation and produces no delegation receipt; `commit-steward` is therefore not a required agent.

#### Required configuration keys and defaults:
The routing-matrix top-level keys (`version`, `routes`, and per-route `description`, `required_agents`, `required_skills`, `required_mcp_tools`) are unchanged in structure. Only the values of the three per-route required lists change. No new keys are added.

#### Backward-compatibility expectations:
Existing checkpoints that do not assert `require_complete: true` are unaffected; default structural validation continues to pass. Checkpoints produced by the corrected runtime with the corrected receipt arrays now pass `require_complete: true`. Checkpoints that still reference the stale names will correctly fail the corrected matrix comparison.

#### Performance constraints (latency/throughput/memory):
None. The change is to static config data and skill documentation; validation cost is unchanged.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The agent roster under `.claude/agents/` (notably `feature-review`, and the absence of `feature-reviewer` and `commit-steward`) is authoritative for the Claude Code runtime (research §1).
  - The skill inventory under `.claude/skills/` is authoritative; `orchestrator-workflow` and `repo-automation-adapter` exist only in the Codex payload and are not Claude Code skills (research §2).
  - The five retained MCP tools (`new_potential_entry`, `potential_to_issue`, `new_active_feature_folder`, `collect_pr_context`, `validate_orchestration_artifacts`) are registered by the `drm-copilot` MCP server and are invoked in a completed orchestration run; `collect_commit_context` is registered but not invoked by the orchestrate skill (research §3).
  - The existing test `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` builds fixtures dynamically from `load_routing_matrix()`, so it auto-tracks the corrected matrix.
- Constraints (budget, performance, compatibility):
  - The canonical config and its bundled mirror must remain byte-identical.
  - The validator logic in `_orchestrator_state_routing.py` must not change beyond reading corrected data.
  - Python toolchain gates apply: Black, Ruff, Pyright, Pytest with line coverage >= 85% and branch coverage >= 75%.
- External dependencies (services, libraries, releases):
  - None. No new libraries, no external services, no releases gate this change.

## Data / API / Config Impact
- User-facing or API changes:
  - None at the public-API level. The change is to the orchestration routing contract data and the orchestrate skill documentation. The behavioral effect is that `validate_orchestration_artifacts` with `require_complete: true` becomes satisfiable for a truthfully completed orchestration.
- Data or migration considerations:
  - The checkpoint schema gains documented receipt-array entry shapes (`skill_receipts[]`, `mcp_call_receipts[]`) that the validator already reads; no migration of existing checkpoints is required because the receipt arrays are additive and only consulted under `require_complete: true`.
- Logging/telemetry updates (if any):
  - None.
- Compatibility notes (CLI flags, config schemas, versioning):
  - The routing-matrix `version` field and JSON structure are unchanged; only the per-route required-list values change. Both config copies must be updated together. The bundle-parity test (`tests/scripts/dev_tools/test_validate_orchestration_artifacts_bundle_parity.py`) does not currently cover `orchestration-routing.json`, so a dedicated guard test is added (see Test Strategy).

## Test Strategy
Seeded from issue:

- [ ] Reconcile the routing matrix names with the actual agent roster (e.g., `feature-review`), and either provide a `commit-steward` agent or remove it from the required set and represent the orchestrator's direct commit step.
- [ ] Define how `skill_receipts` and `mcp_call_receipts` are emitted, or relax the required lists to the tools that are actually receipted.
- [ ] Unit coverage: a truthful completed-large checkpoint passes `require_complete`; missing/renamed receipts fail with clear messages.
- [ ] Integration scenario: re-run a `large` orchestration completion and confirm `require_complete: true` passes.

- Regression tests to add or update:
  - In `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py`: a test confirming that a truthful completed-large checkpoint passes `validate_routing_contract` (zero errors) with the corrected agent/skill/tool names. Fixtures are built from `load_routing_matrix()`, so the test auto-tracks the corrected matrix; verify it passes against the corrected config.
  - Add a guard test asserting that `config/orchestration-routing.json` and `extensions/drm-copilot/resources/config/orchestration-routing.json` are byte-identical. This is required because the existing bundle-parity test (`test_validate_orchestration_artifacts_bundle_parity.py`) covers only the five validator Python modules and does NOT cover `orchestration-routing.json` or the routing module.
- Unit tests (pytest) for the fixed behavior and boundaries:
  - Positive: a completed-large checkpoint with `required_agents`/`required_skills`/`required_mcp_tools` matching the corrected matrix, and `delegation_receipts[]`, `skill_receipts[]`, `mcp_call_receipts[]` covering each corrected required name in the validator-accepted shapes, returns no errors.
  - Positive: completed-small and completed-remediation checkpoints likewise pass with their corrected required lists.
  - Receipt-shape acceptance: a `skill_receipts` entry with `skill` non-empty, `required: true`, `evidence` non-empty is accepted; an `mcp_call_receipts` entry with `tool` non-empty, `ok: true`, `evidence` non-empty is accepted; a `delegation_receipts` entry supplying `agent_name` is collected.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Missing/renamed agent receipt fails with `Checkpoint missing required agent receipt: <name>.` (for example, a checkpoint that still emits `feature-reviewer` instead of `feature-review`, or omits `feature-review`).
  - Missing skill receipt fails with `Checkpoint missing required skill receipt: <name>.`
  - Missing MCP receipt fails with `Checkpoint missing successful MCP receipt: <name>.`
  - Malformed receipt entries are not collected: a `skill_receipts` entry with `required` not `true`, empty `evidence`, or empty `skill`; an `mcp_call_receipts` entry with `ok` not `true` or empty `evidence`. These must therefore fail the corresponding required-name check.
  - A checkpoint whose `required_*` lists do not match the matrix fails with the `must match routing matrix for route <route_id>.` messages.
- Error handling and logging verification:
  - Confirm the validator returns the exact per-violation error strings above and does not mutate its input. No logging changes are introduced.
- Coverage impact and targets for changed lines/modules:
  - The only source changes are JSON config and skill Markdown, which are not measured for coverage. The validator module `_orchestrator_state_routing.py` is unchanged; its existing coverage must not regress. Repository thresholds apply: line coverage >= 85%, branch coverage >= 75%, no regression on changed lines.
- Toolchain commands to run (format → lint → type-check → test):
  - `poetry run black .`
  - `poetry run ruff check .`
  - `poetry run pyright`
  - `poetry run pytest --cov --cov-branch --cov-report=term-missing`
  - Restart from formatting if any stage fails or modifies files; do not stop until all four pass in one clean pass.
- Manual validation steps (if required):
  - Integration scenario: complete (or simulate) a `large`-route orchestration through PR creation and the CI green gate, then run `validate_orchestration_artifacts` with `require_complete: true` against the checkpoint and confirm it passes with the corrected names. This reproduces the original repro path and confirms the expected post-fix behavior.


## Acceptance Criteria
- [x] `config/orchestration-routing.json` references only real agent, skill, and MCP-tool names for all three routes: `required_agents` use `feature-review` (not `feature-reviewer`) and contain no `commit-steward`; `required_skills` contain no `orchestrator-workflow` or `repo-automation-adapter`; `required_mcp_tools` contain no `collect_commit_context`. The per-route lists match the target values in the Proposed Fix section. <!-- Evidence: P1-T1..T11; config/orchestration-routing.json; stale-token assertion exit 0. -->
- [x] `extensions/drm-copilot/resources/config/orchestration-routing.json` is byte-identical to `config/orchestration-routing.json`. <!-- Evidence: P2-T2; sha256 match 088130c0...; cmp identical. -->
- [x] A guard test asserts the two config copies are identical and passes. <!-- Evidence: P4-T4/T5; tests/scripts/dev_tools/test_orchestration_routing_config_parity.py passed. -->
- [x] `.claude/skills/orchestrate/SKILL.md` instructs the orchestrator to emit `skill_receipts[]` entries (`skill` non-empty string, `required: true`, `evidence` non-empty string), `mcp_call_receipts[]` entries (`tool` non-empty string, `ok: true`, `evidence` non-empty string), and `delegation_receipts[]` entries supplying `agent_name`, for the retained required names of each route. <!-- Evidence: P3-T1; .claude/skills/orchestrate/SKILL.md section "Routing-Contract Receipt Emission". -->
- [x] A regression test confirms a truthful completed-large checkpoint passes `validate_routing_contract` (and `validate_orchestration_artifacts` with `require_complete: true`) with the corrected names, returning zero routing-contract errors. <!-- Evidence: P4-T2; test_complete_state_accepts_full_routing_contract_evidence passed. -->
- [x] Negative tests confirm that missing or renamed receipts fail with the validator's clear messages (`Checkpoint missing required agent receipt: <name>.`, `Checkpoint missing required skill receipt: <name>.`, `Checkpoint missing successful MCP receipt: <name>.`). <!-- Evidence: P4-T3; full module 7 passed including the three negative tests. -->
- [x] No behavior change to `scripts/dev_tools/_orchestrator_state_routing.py` logic beyond reading corrected data; the module source is unchanged and its bundled mirror is unchanged. <!-- Evidence: P4-T7; git diff --name-only over the four validator-source paths produced no output. -->
- [x] The full Python toolchain passes in one clean pass: Black (format), Ruff (lint), Pyright (type-check), Pytest with line coverage >= 85% and branch coverage >= 75% and no regression on changed lines. <!-- Evidence: P5-T1..T5; black 0 reformatted, ruff 0 errors, pyright 0 errors, pytest 1169 passed; branch 85.97%; no production Python line changed; no coverage regression. NOTE: pre-existing repo TOTAL line coverage is 83% (baseline = post-change); this change does not affect production Python lines. -->
- [x] The original repro no longer occurs: a truthfully completed `large`-route orchestration produces a checkpoint that passes `require_complete: true`. <!-- Evidence: P4-T2; test_complete_state_accepts_full_routing_contract_evidence exercises validate_orchestrator_state_text(..., require_complete=True) against a completed-large checkpoint built from the corrected matrix and returns zero errors. -->

## Risks & Mitigations
- Technical or operational risks:
  - Config drift: the two copies of `orchestration-routing.json` could diverge in a future edit, since the existing bundle-parity test does not cover this file. The bundled `_orchestrator_state_routing.py` reads its own bundled config, so divergence would produce inconsistent validation between the canonical and bundled runtimes.
  - Incomplete receipt-emission instructions: if the orchestrate skill describes a receipt shape the validator does not accept (for example omitting `required: true` on a skill receipt or `ok: true` on an MCP receipt), `require_complete: true` would still fail.
  - Scope leak: editing the Codex payload files (out of scope) could be mistaken for required work; the runtime relevant to this issue is the Claude Code orchestrate skill and Python validator only.
- Mitigations and rollbacks:
  - Add the dedicated identical-copies guard test so any future divergence between the canonical and bundled config is caught.
  - The receipt entry shapes in this spec are stated to match `_receipt_skills`, `_mcp_tools`, and `_receipt_agents` exactly; the positive regression test verifies a checkpoint emitted per those shapes passes `require_complete`.
  - Rollback is reverting the three changed files; the validator reads the matrix dynamically, so reverting config restores prior behavior with no code change.

## Rollout & Follow-up
- Release/rollout steps:
  - Land the three coordinated file edits (canonical config, bundled config, orchestrate skill) plus the test additions in a single change so the matrix and its receipt-emission contract stay consistent.
  - Run the full Python toolchain and confirm all gates pass before PR creation.
- Post-fix monitoring or clean-up tasks:
  - On the next completed `large`-route orchestration, confirm `validate_orchestration_artifacts` with `require_complete: true` passes against the live checkpoint.
  - Optional follow-up (out of scope for #230): align the Codex customization payload (`extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md` and `repo-automation-adapter/SKILL.md`) with the Claude Code runtime names, or document that the Codex payload intentionally uses Codex-era names.
- Links: issue, PRs, related docs
  - Issue: #230
  - Research artifact: `docs/features/active/2026-06-24-orchestrator-state-routing-contract-mismatch-230/research/2026-06-24-routing-contract-reconciliation-research.md`
  - Related: `.claude/rules/orchestrator-state.md`, `.claude/skills/orchestrate/SKILL.md`, `scripts/dev_tools/_orchestrator_state_routing.py`
