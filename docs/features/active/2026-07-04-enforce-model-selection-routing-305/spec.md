# enforce-model-selection-routing (Spec)

- **Issue:** #305
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-04T13-40
- **Status:** Draft
- **Version:** 0.1

## Context
The orchestrator's Model Selection procedure (`.claude/skills/orchestrate/SKILL.md` `## Model Selection`, lines 68-86) is documented but mechanically unenforced end-to-end. Both `complexity_assessments[]` and `model_routing_receipts[]` are declared "additive and optional," so a checkpoint that never contains them passes at every validation stage; there is no gate that requires them to exist when delegations occur.

Environment:
- OS/version: Windows 11 Pro (repo also runs on `windows-latest` CI); enforcement logic is OS-neutral Python plus PowerShell hooks.
- Python version: repo-standard Python toolchain (Black/Ruff/Pyright/Pytest).
- Command/flags used: `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <path> --require-complete` (via `.claude/hooks/validate-orchestrator-output.ps1`); the new flag `--require-model-routing` is added by this fix.
- Data source or fixture: `artifacts/orchestration/orchestrator-state.json`; test fixtures via `build_valid_orchestrator_state()` in `tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py`.

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Rationale: a live session (#301) ran approximately 15 delegations with no model selection performed and no routing/assessment records written, yet the checkpoint validated clean including under `require_complete: true`. Delegations executed at an unintended model tier with no mechanical detection.

## Repro & Evidence
Steps to Reproduce:
1. Run an orchestration session that delegates to subagents (for example the small route: atomic-planner, atomic-executor, feature-review) without performing the documented Model Selection procedure.
2. Observe that no `model` is passed on delegations and that `complexity_assessments[]` and `model_routing_receipts[]` never appear in `artifacts/orchestration/orchestrator-state.json`.
3. Validate the resulting checkpoint, including with `require_complete: true` (the completion gate invoked by `.claude/hooks/validate-orchestrator-output.ps1`).

Expected:
Validation should refuse to accept a completed checkpoint in which delegations occurred but no matching `model_routing_receipts[]` / `complexity_assessments[]` entries exist, and a resuming orchestration should deterministically repair a missing model choice before delegating.

Actual:
The checkpoint validated clean at every stage, including under `require_complete: true`. Because both arrays are validated only when present (the key-gated `optional_key_validators` loop in `validate_orchestrator_state.py` lines 448-456), a checkpoint that never contains them passes; there is no existence-forcing gate.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: Session #301 checkpoint contained `delegation_receipts[]` for its `required_agents` but zero `model_routing_receipts[]` and zero `complexity_assessments[]`; `require_complete: true` returned no errors.

## Scope & Non-Goals
- In scope:
  - New `require_model_routing: bool = False` mode on `validate_orchestrator_state_text(...)`, implemented in a new sibling delegate module `scripts/dev_tools/_orchestrator_state_model_routing_gate.py`.
  - `--require-model-routing` CLI flag on the `orchestrator-state` subparser in `scripts/dev_tools/validate_orchestration_artifacts.py`.
  - Completion gate: `.claude/hooks/validate-orchestrator-output.ps1` passes `--require-model-routing` alongside `--require-complete`; DONE refused with block reason `MODEL_ROUTING_BLOCKED:`.
  - New PreToolUse deterrent hook `.claude/hooks/enforce-model-routing-receipt.ps1` under the `Agent` matcher; presence-only gating; wired in `.claude/settings.json`.
  - Resume reconciliation sub-procedure in `.claude/skills/orchestrate/SKILL.md` `## Checkpoint Handling`, mirrored into `.claude/agents/orchestrator.md` Startup Protocol.
  - `model:` frontmatter floor defaults on every `.claude/agents/*.md` lacking one (atomic-executor → opus explicitly).
  - Rule documentation in `.claude/rules/orchestrator-state.md` and `.claude/skills/orchestrate/SKILL.md`.
  - Byte-identical bundle mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/**` for every edited `.claude/**` file.
  - A `require_model_routing` parameter surfaced on the `validate_orchestration_artifacts` MCP tool, with the TypeScript side performing the existence check only (delegated-agent set ⊆ routing-receipt-agent set).
- Out of scope / non-goals:
  - Full per-receipt correctness parity in the TypeScript MCP validator (model equals `resolveDelegationModel(...)`, disabled-mode clamp). The authoritative enforcement stays on the Python path invoked by the PowerShell hooks; TS parity beyond the existence check is deferred as follow-up for #305.
  - Backfilling routing receipts for already-completed historical delegations on resume.
  - Correctness gating in the PreToolUse hook (the hook cannot read the delegate's chosen `model`, per the Hook-Input Visibility Decision); the hook enforces presence only.
  - Any change to `config/orchestration-routing.json` `model_policy` (it does not change); no routing-config mirror update is required.
  - Reimplementing `compute_complexity_floor` or `resolve_delegation_model` in the validator, hook, or skill.
  - Importing any foreign JSON schema (the `drmoisan.github.io/mix-calculator/` schema is prohibited); enforcement is repo-local Python/PowerShell logic and prose.
- Explicitly excluded systems, integrations, or datasets:
  - No third-party UI, portal, admin center, or human-in-the-loop step at any stage (see `## Automation Feasibility`).
  - Python `scripts/**` files have no bundle mirror obligation.
  - Codex mirror: a new Agent-matcher deterrent follows the precedent of the existing Agent-matcher hooks that are absent from `.codex/hooks/`, so no codex mirror is expected (planner to confirm against the codex pack-selection manifest).

## Root Cause Analysis
Both `complexity_assessments[]` and `model_routing_receipts[]` are validated only when their key is present in the checkpoint (the `optional_key_validators` loop, `validate_orchestrator_state.py` lines 448-456). The existing per-entry validators `_validate_model_routing_receipts` (`_orchestrator_state_model_routing.py`) and `_validate_complexity_assessments` (`_orchestrator_state_complexity.py`) check the shape of entries that are present but never require that any entry exist. The `require_complete` completion gate (lines 465-488) appends completion, PR, CI, phase-completeness, and routing-contract checks — none of which inspect model routing. Consequently a checkpoint that omits both arrays entirely passes at every stage, including `require_complete: true`. Files to inspect: `scripts/dev_tools/validate_orchestrator_state.py`, `_orchestrator_state_model_routing.py`, `_orchestrator_state_complexity.py`, `resolve_delegation_model.py`, `compute_complexity_floor.py`, and `.claude/hooks/validate-orchestrator-output.ps1`.

## Proposed Fix

### Design summary (what changes where):
Adopt the research-recommended composition: Option C (a validator-only `require_model_routing` flag) as the enforcement core, Option A (a PreToolUse `Agent`-matcher deterrent) as the pre-delegation block, and a resume-reconciliation sub-procedure for deterministic repair. Option B (a standalone SubagentStop gate) is rejected as redundant because Option C at the completion gate subsumes it. The two enforcement layers share one source of truth (the on-disk checkpoint plus the Python validator), so they cannot disagree. This mirrors the two-layer shape already used by the epic wave barrier (per-call deterrent plus validator backstop).

### Boundaries and invariants to preserve:
- Reuse the reference formulas; do not reimplement `compute_complexity_floor` (`scripts/dev_tools/compute_complexity_floor.py`) or `resolve_delegation_model` (`scripts/dev_tools/resolve_delegation_model.py`) in the validator, hook, or skill. Per-receipt correctness reuses the existing `_validate_model_routing_receipts` and `_validate_complexity_assessments`.
- No foreign schema; enforcement is repo-local Python/PowerShell logic plus prose in `.claude/rules/orchestrator-state.md`.
- Backward compatibility: plain, `require_complete`, and `require_pr_creation_ready` validator calls must return byte-identical results; old delegation-free checkpoints stay valid.
- The gate fires only when at least one well-formed `delegation_receipts[]` entry exists. A checkpoint with zero delegation receipts imposes no routing-receipt requirement under the flag.
- File-size limit is 500 lines. `validate_orchestrator_state.py` is at 496/500, so the new gate logic lives entirely in the new `_orchestrator_state_model_routing_gate.py` delegate.
- The orchestrator MUST NOT delegate at a delegating `next_step` while `model_routing_preflight` status is fail.
- Do not backfill receipts for already-completed historical delegations.
- The runtime per-delegation override remains authoritative; agent `model:` frontmatter is a static safety-net floor only (the validator never reads frontmatter).

### Dependencies or blocked work:
None external. All work is repo-local. The reference formula modules already exist and are consumed as-is.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `scripts/dev_tools/validate_orchestrator_state.py` — add `require_model_routing: bool = False` keyword; append the new gate under `if require_model_routing:`.
- `scripts/dev_tools/_orchestrator_state_model_routing_gate.py` — NEW delegate module hosting the existence gate.
- `scripts/dev_tools/validate_orchestration_artifacts.py` — add `--require-model-routing` to the `orchestrator-state` subparser and forward it in `_validate_from_args`.
- `.claude/hooks/validate-orchestrator-output.ps1` — pass `--require-model-routing` through the `$Invoker` seam; add `MODEL_ROUTING_BLOCKED:` block reason.
- `.claude/hooks/enforce-model-routing-receipt.ps1` — NEW PreToolUse `Agent`-matcher deterrent (presence-only).
- `.claude/settings.json` — register the new hook under the existing `Agent` PreToolUse matcher.
- `.claude/skills/orchestrate/SKILL.md` — add the Model-choice reconciliation-on-resume sub-procedure to `## Checkpoint Handling`; document the new mode/invariant.
- `.claude/agents/orchestrator.md` — mirror the resume reconciliation into the Startup Protocol.
- `.claude/rules/orchestrator-state.md` — document the `require_model_routing` mode, the required-once-delegated invariant, and the resume reconciliation procedure.
- `.claude/agents/*.md` — set a `model:` floor default on every agent lacking one, per the Agent Frontmatter Audit table (atomic-executor → opus).
- `extensions/drm-copilot/resources/claude-customizations/.claude/**` — byte-identical mirrors for every edited `.claude/**` file (settings.json, both hooks, the skill, the rule, each edited agent md, and any new `.claude/**` file).
- MCP tool surface (`extensions/drm-copilot/src/**`) — surface a `require_model_routing` parameter and implement the existence check only on the TS side.

#### Functions/classes/CLI commands impacted:
- `validate_orchestrator_state_text(...)` — new keyword `require_model_routing`.
- New gate entry point in `_orchestrator_state_model_routing_gate.py`, reusing `_validate_model_routing_receipts` and `_validate_complexity_assessments`.
- `build_parser()` / `_validate_from_args` in `validate_orchestration_artifacts.py` — new `--require-model-routing` flag threading.
- `Invoke-RoutingContractValidation` / `Invoke-OrchestratorOutputValidation` in `validate-orchestrator-output.ps1` — new argument and block reason.
- The `validate_orchestration_artifacts` MCP tool definition and TS validator — new `require_model_routing` parameter and existence check.

#### Data flow and validation changes:
When `require_model_routing == True` and at least one well-formed `delegation_receipts[]` entry exists, the gate: (a) derives the set of delegating agents from `delegation_receipts[].agent_name` plus the delegating step named by `next_step`; (b) requires, for each such delegating agent, a matching `model_routing_receipts[]` entry and its `complexity_assessments[]` phase entry; (c) reuses `_validate_model_routing_receipts` and `_validate_complexity_assessments` for per-entry correctness (model equals `resolve_delegation_model(...)`; disabled-mode clamp). The existence invariant correlates on `agent` (not on parsed phase) because `delegation_receipts[].agent_name` is the authoritative "a delegation happened" record; the gate requires the set of `model_routing_receipts[].agent` to be a superset of the set of delegated agents. The gate never reads `fable_policy` itself; each receipt records its own policy and correctness is recomputed from it.

#### Error handling and logging updates:
- The validator appends one error string per violated invariant, in the existing literal, checkpoint-context-prefixed message style; it returns a list of error strings and does not mutate input.
- The completion hook surfaces validator errors as the `MODEL_ROUTING_BLOCKED:` block reason, mirroring `ROUTING_CONTRACT_BLOCKED:`.
- The PreToolUse hook blocks a delegation to a delegating subagent whose agent has no `model_routing_receipts[]` entry, with malformed-JSON input handled gracefully (allow-through for non-delegating tool inputs).
- On resume, the orchestrator records a `model_routing_preflight` block `{status, checked_at, validator_command, output_summary}`.

#### Rollback/feature-flag considerations (if applicable):
The `require_model_routing` flag defaults to `False`; every existing caller path is unchanged and byte-identical. The gate is a strict addition activated only where a caller opts in (the completion hook and resume preflight). Disabling enforcement is a matter of not passing the flag; no data migration is involved.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `validate_orchestrator_state_text(text, *, require_complete=False, strict_route_membership=False, require_pr_creation_ready=False, require_model_routing=False) -> list[str]`.
- CLI: `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <path> [--require-complete] [--require-pr-creation-ready] [--require-model-routing]`.
- `model_routing_receipts[]` entry shape: `{ agent, phase, complexity_band, fable_policy, table_model, clamped_from | null, model }`.
- `complexity_assessments[]` entry shape: `{ phase, band, floor, signals_present[], rationale, assessed_at }`.
- `model_routing_preflight` block: `{ status, checked_at, validator_command, output_summary }`.

#### Required configuration keys and defaults:
- `model_budget.fable_policy` enum `disabled | available | preferred` (default `disabled`) from `config/orchestration-routing.json`; unchanged by this fix.
- `require_model_routing` default `False` at every layer (function keyword, CLI flag absent, MCP parameter absent).
- Agent `model:` frontmatter floor defaults per the Agent Frontmatter Audit table below.

#### Backward-compatibility expectations:
- Callers that do not pass `require_model_routing` traverse an unchanged code path and produce identical output (matching how `require_pr_creation_ready` was added without disturbing `require_complete`).
- The existing key-gated shape validators for `model_routing_receipts` / `complexity_assessments` continue to run only when the key is present; no unconditional requirement is added outside the `require_model_routing` branch.
- Under `require_model_routing == True`, a checkpoint with zero `delegation_receipts[]` entries imposes no routing-receipt requirement, so genuinely old, delegation-free checkpoints still pass.
- The gate keys on `delegation_receipts` presence, not on `route_id`/`path_selected`/`model_budget`; a checkpoint lacking route or model-budget markers is not newly rejected.

#### Performance constraints (latency/throughput/memory):
No new I/O beyond reading the already-loaded checkpoint. The gate performs set membership over in-memory receipt lists and reuses existing per-entry validators; no measurable latency or memory impact relative to the current validator. Reference formulas are pure functions.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - `delegation_receipts[]` entries carry `agent_name` and `step` (both in `REQUIRED_RECEIPT_KEYS`); `next_step` names the upcoming delegating step.
  - A resuming orchestrator can re-derive `complexity_band` for the upcoming phase; `complexity_assessments[]` is written alongside each routing receipt so resume repair is deterministic rather than a fresh judgment.
  - The `Agent`/`Task` PreToolUse input exposes `subagent_type` and `prompt` (confirmed from the two production Agent-matcher hooks) but not a `model` field (no repo evidence).
- Constraints (budget, performance, compatibility):
  - File-size limit 500 lines; new logic goes in the new `_orchestrator_state_model_routing_gate.py` delegate because `validate_orchestrator_state.py` is at 496/500.
  - Reuse reference formulas; do not reimplement `compute_complexity_floor` or `resolve_delegation_model`.
  - No foreign schema; enforcement is repo-local Python/PowerShell logic and prose.
  - Backward-compatible byte-identical results for plain, `require_complete`, and `require_pr_creation_ready` calls.
- External dependencies (services, libraries, releases):
  - None. All modules and tooling already exist in-repo.

## Data / API / Config Impact
- User-facing or API changes:
  - New CLI flag `--require-model-routing` on the `orchestrator-state` subparser.
  - New MCP tool parameter `require_model_routing` on `validate_orchestration_artifacts` (TS existence check only).
  - New PreToolUse hook `enforce-model-routing-receipt.ps1` registered under the `Agent` matcher in `.claude/settings.json`.
- Data or migration considerations:
  - No migration. New checkpoints written by a compliant orchestrator will contain `model_routing_receipts[]` and `complexity_assessments[]`; old delegation-free checkpoints remain valid. Historical delegations are not backfilled.
- Logging/telemetry updates (if any):
  - New block reason `MODEL_ROUTING_BLOCKED:` at the completion gate; new `model_routing_preflight` record on resume.
- Compatibility notes (CLI flags, config schemas, versioning):
  - The MCP TypeScript validator today implements neither model-routing validation nor `require_pr_creation_ready` and exposes only `require_complete`. Authoritative enforcement is the Python validator invoked by the PowerShell hooks. The MCP parity decision for #305: surface the flag/parameter and have the TS side perform the existence check (delegated-agent set ⊆ routing-receipt-agent set — pure set logic, no formula reimplementation); full per-receipt correctness parity in TS is out of scope for #305 and noted as follow-up.

### Agent Frontmatter Floor Defaults (safety-net only; runtime override authoritative)

| Agent file | Current `model:` | In overlay set? | Floor default to set |
|---|---|---|---|
| atomic-executor.md | none | no (C3 stays opus) | opus |
| atomic-planner.md | none | yes | opus |
| commit-message.md | haiku | no | haiku (keep) |
| csharp-typed-engineer.md | none | no | sonnet |
| epic-orchestrator.md | none | no | opus |
| epic-review.md | none | no | opus |
| feature-review.md | none | yes | opus |
| human-exception-runbook.md | sonnet | no | sonnet (keep) |
| orchestrator.md | none | no | opus |
| powershell-typed-engineer.md | none | no | sonnet |
| pr-author.md | sonnet | no (C3 stays opus) | sonnet (keep) |
| prd-feature.md | none | yes | opus |
| python-typed-engineer.md | none | no | sonnet |
| staged-review.md | none | no | opus |
| status-updater.md | none | no | haiku |
| task-researcher.md | sonnet | yes | sonnet (keep) |
| typescript-engineer.md | none | no | sonnet |

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas
- [x] Integration scenario to retest
- [x] Manual verification notes

- Regression tests to add or update:
  - Assert plain, `require_complete`, and `require_pr_creation_ready` calls return error lists identical to today, with and without the routing arrays present (backward-compatible no-delegation case, byte-identical equality).
- Unit tests (pytest) for the fixed behavior and boundaries (under `tests/scripts/dev_tools/`):
  - Strict-mode missing-entry: `delegation_receipts` for agents X, Y but `model_routing_receipts` missing Y is rejected under `require_model_routing=True`.
  - Strict-mode present-and-consistent: receipts present for every delegated agent and each self-consistent → zero errors under the flag.
  - Strict-mode present-but-model-mismatch: a receipt whose `model != resolve_delegation_model(...)` is caught under the flag (delegating to the reused `_validate_model_routing_receipts`).
  - Backward-compatible no-delegation: a delegation-free checkpoint under `require_model_routing=True` passes.
  - CLI forwarding: `--require-model-routing` reaches `validate_orchestrator_state_text(require_model_routing=True)` (mirror `test_validate_orchestration_artifacts_pr_creation_readiness.py`).
  - Flag independence: `--require-model-routing` alone does not trigger `require_complete`/`require_pr_creation_ready` checks, and vice versa.
  - Resume path: missing-choice resume exercises recompute → record → persist → delegate-with-override.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Zero delegation receipts (no requirement imposed); malformed JSON to the PreToolUse hook (allow-through for non-delegating tool inputs); out-of-enum band via the reused per-entry validator.
- Error handling and logging verification:
  - Completion hook surfaces validator errors as `MODEL_ROUTING_BLOCKED:`; PreToolUse hook denies a delegation whose `subagent_type` has no routing receipt and allows non-delegating tool inputs (Pester with a synthetic checkpoint, dot-source seams, injectable checkpoint-read/validator seams under `tests/scripts/powershell/**`).
- Coverage impact and targets for changed lines/modules:
  - Line coverage >= 85% and branch coverage >= 75% across changed modules; no regression on changed lines.
- Toolchain commands to run (format → lint → type-check → test):
  - Python: Black → Ruff → Pyright → Pytest (with coverage thresholds).
  - PowerShell: PoshQC format/analyze → Pester for the hooks.
  - Bundle parity: `test_push_down_claude_resource_contracts.py` byte-identity contract tests.
- Manual validation steps (if required):
  - None strictly required; all gates are exercised by the standard local toolchains and bundle-parity tests.

## Acceptance Criteria
- [x] `validate_orchestrator_state_text(..., require_model_routing=True)` fails a checkpoint whose delegating `next_step` (or whose `completed_steps`/`delegation_receipts`) include delegations with no matching `model_routing_receipts[]` / `complexity_assessments[]` entry, and passes once entries are present and consistent with the reference formulas.
- [x] Plain, `require_complete`, and `require_pr_creation_ready` calls return results identical to before (regression-covered, byte-identical error lists).
- [x] The PreToolUse hook `.claude/hooks/enforce-model-routing-receipt.ps1` blocks or flags a delegation lacking a routing receipt (Pester test with a synthetic checkpoint), and allows non-delegating tool inputs and malformed JSON gracefully.
- [x] The Completion Requirements gate refuses DONE when a delegation lacks a recorded model choice (`MODEL_ROUTING_BLOCKED:` via `.claude/hooks/validate-orchestrator-output.ps1`).
- [x] Every `.claude/agents/*.md` `model:` default is consistent with the Model-Budget Contract, with `atomic-executor` explicitly set to opus.
- [x] Resume reconciliation is documented in `.claude/skills/orchestrate/SKILL.md` `## Checkpoint Handling` and mirrored into the `.claude/agents/orchestrator.md` Startup Protocol; a test exercises the missing-choice resume path (recompute via `compute_complexity_floor` → record `complexity_assessments[]` → resolve via `resolve_delegation_model` → record `model_routing_receipts[]` → persist → delegate with `model` = receipt model).
- [x] The orchestrator does not delegate at a delegating `next_step` while `model_routing_preflight` status is fail; a `model_routing_preflight` `{status, checked_at, validator_command, output_summary}` record is written on resume.
- [x] New/updated tests under `tests/scripts/dev_tools/` cover strict-mode missing entry, strict-mode present-and-consistent, strict-mode present-but-model-mismatch, and backward-compatible no-delegation.
- [x] `--require-model-routing` CLI flag is added to the `orchestrator-state` subparser and forwarded to `validate_orchestrator_state_text(require_model_routing=True)`, with flag-independence covered.
- [x] The `validate_orchestration_artifacts` MCP tool surfaces a `require_model_routing` parameter; the TypeScript side performs the existence check (delegated-agent set ⊆ routing-receipt-agent set) only, with full per-receipt correctness parity noted as follow-up (non-goal for #305).
- [x] `.claude/rules/orchestrator-state.md` and `.claude/skills/orchestrate/SKILL.md` document the new `require_model_routing` mode, the required-once-delegated invariant, and the resume reconciliation procedure.
- [x] New logic lives in the new `scripts/dev_tools/_orchestrator_state_model_routing_gate.py` delegate; `validate_orchestrator_state.py` stays within the 500-line limit; the gate reuses `_validate_model_routing_receipts` and `_validate_complexity_assessments` and does not reimplement `compute_complexity_floor` or `resolve_delegation_model`.
- [x] All bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/**` match runtime sources byte-identically; bundle-parity contract tests pass.
- [x] Full toolchain green: format → lint → type-check → tests (Pytest with coverage thresholds >= 85% line / >= 75% branch, plus Pester for the hooks).

## Risks & Mitigations
- Technical or operational risks:
  - A flag is only as strong as its callers; if no caller passes `--require-model-routing`, it enforces nothing (the current failure mode for the optional arrays). Mitigation: the completion hook passes it by default via `$Invoker`, and the resume preflight and PreToolUse deterrent add earlier enforcement points.
  - Phase-correlation granularity: keying the existence invariant on `agent` (not parsed phase) means a checkpoint could satisfy the gate with one receipt per agent even if that agent was delegated in multiple phases at different bands. Mitigation: the agent-only rule is the backward-compatible minimum; per-(agent, step) correlation via the existing `step` key is available if the planner requires stricter granularity.
  - PreToolUse hook cannot verify model correctness (no `model` field visible in tool input). Mitigation: scope the hook to presence gating; correctness stays with the Python validator.
  - MCP TypeScript divergence: an orchestrator that calls the MCP tool rather than the local Python CLI would not see full model-routing correctness errors. Mitigation: authoritative enforcement is the Python path via the hooks; the TS side gains the existence check now, with full parity deferred as follow-up.
  - Resume repair authority: if the original `complexity_band` was not persisted, resume cannot faithfully reconstruct it. Mitigation: require `complexity_assessments[]` to be written alongside each routing receipt so resume repair is deterministic.
- Mitigations and rollbacks:
  - Default-off flag makes rollback trivial (do not pass the flag). No data migration is involved. Bundle-parity tests guard mirror drift.

## Rollout & Follow-up
- Release/rollout steps:
  - Land the Python validator core, CLI flag, new gate delegate, and tests; wire the completion hook and PreToolUse hook; update the skill, rule, and orchestrator agent; set agent frontmatter floors; add byte-identical bundle mirrors; run the full toolchain and bundle-parity tests.
- Post-fix monitoring or clean-up tasks:
  - Follow-up: full per-receipt correctness parity in the TypeScript MCP validator (port the receipt logic and `resolveDelegationModel`), tracked separately from #305.
  - Confirm the codex pack-selection manifest does not require a codex mirror for the new Agent-matcher hook.
- Links: issue, PRs, related docs
  - Issue: https://github.com/drmoisan/drm-copilot/issues/305
  - Research: `docs/features/active/2026-07-04-enforce-model-selection-routing-305/research/model-selection-enforcement.research.md`
  - Rule: `.claude/rules/orchestrator-state.md`; Skill: `.claude/skills/orchestrate/SKILL.md`

## Automation Feasibility
This change is entirely repo-local tooling: Python (validator core, new gate delegate, CLI flag), PowerShell (one new PreToolUse hook and one edit to the SubagentStop hook), Markdown (SKILL.md procedure, orchestrator agent, orchestrator-state rule), and JSON (settings.json hook wiring; the routing config only if `model_policy` changes, which it does not). There is no third-party UI, portal, admin center, or human-in-the-loop step at any stage. All gates are exercised by the standard local toolchains (Black/Ruff/Pyright/Pytest for Python; PoshQC format/analyze plus Pester for PowerShell) and the byte-identity bundle-parity tests. No unautomatable requirement was discovered. The autonomous-execution mandate is satisfied with **zero `human_interaction` entries**; the orchestrator records `human_interaction` as absent (the backward-compatible default).
