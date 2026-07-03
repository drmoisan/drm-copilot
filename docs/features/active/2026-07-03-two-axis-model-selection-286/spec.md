# two-axis-model-selection — Spec

- **Issue:** #286
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-03
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature

## Overview

The orchestration runtime selects a workflow `route` (small, large, remediation, epic) deterministically by file count. File count is a size measure, not a complexity measure: a one-file classifier-logic change can be harder to reason about than a fifteen-file rename. The runtime has no mechanism to select the delegation model tier as a function of judged task complexity, so model tier is either fixed by frontmatter pins or coupled implicitly to size. In addition, two low-complexity skill invocations (`commit-message` and `human-exception-runbook`) currently run inline on the orchestrator's model, which is more capable and costly than those situational tasks require.

This feature introduces a two-axis model-selection mechanism that keeps `route` (workflow governance) strictly separate from a new judgment-based `complexity_band` (model-tier governance).

## Two-Axis Design (Normative)

The two axes are kept strictly separate and are computed by different mechanisms:

- **`route`** — values `small | large | remediation | epic`. Remains deterministic and file-count driven. It governs `required_agents`, `required_skills`, and `required_mcp_tools` only. `route` is NOT an input to model selection anywhere.
- **`complexity_band`** — values `C1 | C2 | C3 | C4`. Judgment-based, anchored to measurable signals, guarded by deterministic floors. It is the sole feature-level input to the delegation model tier.

## Workstreams

- **WS1 — Model-selection machinery.** Add a `model_policy` block and a session `model_budget.fable_policy` switch to `config/orchestration-routing.json`; add two Python reference implementations (`scripts/dev_tools/compute_complexity_floor.py`, `scripts/dev_tools/resolve_delegation_model.py`); extend the checkpoint with `complexity_assessments[]` and `model_routing_receipts[]`; add two validator modules wired into the Python `validate_orchestration_artifacts` path; add "## Model Selection" sections to the `orchestrate` and `epic-orchestrate` skills.
- **WS2 — `commit-message` agent.** Add a read-only agent (`model: haiku`) and route the two commit-message invocations through it.
- **WS3 — `human-exception-runbook` agent.** Add an agent (`model: sonnet`) and route the exception-path runbook emission through it.

## Model Selection Contract (Normative)

The authoritative values live in `config/orchestration-routing.json`. The contract below is the reference expression the Python modules and validators implement.

### tier_order

Default: `["haiku", "sonnet", "opus", "fable"]` (least to most capable). Used to define "higher" and "lower" tiers and to express the disabled-mode clamp direction.

### Base `complexity_to_model` table

Maps a `complexity_band` to a model tier, applied uniformly across delegated agents:

| Band | Model |
|---|---|
| C1 | haiku |
| C2 | sonnet |
| C3 | opus |
| C4 | fable |

### `preferred_overlay`

An agent-scoped overlay applied only under `fable_policy == "preferred"`. It changes the C3 cell from `opus` to `fable` for these agents only:

- `atomic-planner`
- `prd-feature`
- `feature-review`
- `task-researcher`

No other agent and no other band is affected by the overlay. `atomic-executor` and `pr-author` C3 cells remain `opus` under every policy.

### `fable_policy` (three-way enum; session-level `model_budget.fable_policy`)

Default `disabled`. Semantics:

- **`disabled`** (default): remove `fable` from the consideration set. Any table cell whose value is `fable` clamps to `opus`; the receipt records `clamped_from: "fable"` and `clamp_reason: "fable_disabled"`. The overlay is not applied.
- **`available`**: apply the base table as-is. `fable` cells resolve to `fable` (no clamp). The overlay is not applied.
- **`preferred`**: apply the `preferred_overlay`, then the base table for all other cells. No clamp applied.

### `resolve_delegation_model(agent, band, fable_policy)` semantics

1. `table_model` = overlay value if (`fable_policy == "preferred"` and `agent` in overlay set and `band == "C3"`), else base `complexity_to_model[band]`.
2. If `fable_policy == "disabled"` and `table_model == "fable"`: `model = "opus"`, `clamped_from = "fable"`, `clamp_reason = "fable_disabled"`.
3. Otherwise: `model = table_model`, `clamped_from = null`.

The function is pure and deterministic: identical `(agent, band, fable_policy)` inputs yield identical output.

### `compute_complexity_floor(signals_present)` semantics

- Each signal flagged `[floor]` in the `model_policy.complexity` signal catalog contributes a candidate band of `C3`.
- `floor` = the maximum triggered candidate band across all present floor signals.
- Floors never exceed `C3`. C4 is never floor-forced: a C4 band is reachable only by judgment, never by a floor.
- With no floor signals present, `floor` is the lowest band (`C1`).
- The function is pure and deterministic.

The assessed `band` is a judgment output and must satisfy `band >= floor`. The floor constrains the lower bound only; it never raises a judgment or evaluates its merit.

### Receipt shapes (checkpoint arrays)

`complexity_assessments[]` — one entry per assessed phase:

```
{ phase, band, floor, signals_present[], rationale, assessed_at }
```

`model_routing_receipts[]` — one entry per delegation:

```
{ agent, phase, complexity_band, fable_policy, table_model, clamped_from | null, model }
```

`table_model` records the pre-clamp table lookup (including any overlay). `model` records the post-clamp result. `clamped_from` is `"fable"` when a clamp occurred, otherwise `null`.

### Validator obligations

**Complexity-assessment validator** (`complexity_assessments[]`):

- `band` must be in `{C1, C2, C3, C4}`.
- `band >= floor`.
- `floor == compute_complexity_floor(signals_present)`.
- `rationale` must be a non-empty string.
- The validator never judges the merit of the assessed band; it checks shape, floor equality, and lower-bound ordering only.

**Model-routing validator** (`model_routing_receipts[]`):

- `model == resolve_delegation_model(agent, complexity_band, fable_policy)`.
- Under `fable_policy == "disabled"`: no receipt `model` may equal `fable`; any receipt whose `table_model == "fable"` must record `clamped_from == "fable"` and `model == "opus"`.

Both validators return `list[str]` of literal, checkpoint-context-prefixed error strings and never raise for malformed content. They are additive: a checkpoint lacking `complexity_assessments` or `model_routing_receipts` validates unchanged.

## Acceptance Criteria

### WS1 — Model-selection machinery

- [x] `route` is not a model-selection input anywhere in config, reference implementations, validators, or skill documentation; `complexity_band` is the sole feature-level input to model tier. A reviewer can verify by confirming no model-selection code path or documented rule reads `route`.
- [x] `config/orchestration-routing.json` contains a `model_policy` block (`complexity` sub-block with scale text, a signal catalog carrying `[floor]` flags, and anchors; `tier_order`; `complexity_to_model`; `preferred_overlay`) and a `model_budget.fable_policy` switch defaulting to `disabled`. The bundled mirror is byte-identical.
- [x] `compute_complexity_floor` is deterministic: each `[floor]` guard contributes `C3`, `floor` is the maximum triggered band, floors never exceed `C3`, and C4 is never floor-forced. Unit tests cover each floor guard, the max-of-multiple case, the no-signal (`C1`) case, and the never-exceed-`C3` invariant.
- [x] `resolve_delegation_model` is deterministic and implements base table, `preferred` overlay, and `disabled` clamp. Unit tests cover: base table per band; `available` leaves `fable` cells intact; `disabled` clamps every `fable` cell to `opus` with `clamped_from: "fable"`; `preferred` resolves C3 to `fable` for the four overlay agents and leaves `atomic-executor`/`pr-author` C3 at `opus`.
- [x] The complexity-assessment validator passes well-formed receipts and fails closed on band-enum, `band >= floor`, `floor == compute`, and non-empty-`rationale` violations, each with a literal, checkpoint-context-prefixed message.
- [x] The model-routing validator passes well-formed receipts and fails closed when `model != resolve_delegation_model(...)`, when any `disabled`-mode receipt records `model == fable`, or when a `disabled`-mode `fable` cell does not record `clamped_from == "fable"` with `model == opus`.
- [x] Both validators are wired into the Python `validate_orchestration_artifacts` path via key-gated blocks inside `validate_orchestrator_state_text`, following the existing `human_interaction` precedent; a checkpoint without the new arrays validates unchanged.
- [x] The `orchestrate` and `epic-orchestrate` skills each carry a "## Model Selection" section that names the two reference implementations as the canonical formulas and documents the `model_budget.fable_policy` kickoff marker.

### WS2 — `commit-message` agent

- [x] `.claude/agents/commit-message.md` exists with `model: haiku`, `skills: [commit-message]`, `memory: project`, and read-only `tools` (`Read`, `Bash(git log *)`, `Bash(git diff *)`); the frontmatter is valid.
- [x] `.claude/settings.json` authorizes `Agent(commit-message)` in the orchestrator allowlist.
- [x] Both commit points in `orchestrate/SKILL.md` (the Pre-Feature-Review Commit step and the Pre-R4 commit bullet) delegate commit-message generation to `Agent(commit-message)`; the `git commit` step remains on the orchestrator.

### WS3 — `human-exception-runbook` agent

- [x] `.claude/agents/human-exception-runbook.md` exists with `model: sonnet`, `skills: [human-exception-runbook]`, `memory: project`, and `tools` scoped to `Write(<FEATURE>/runbooks/**)` plus read/sourcing tools; the frontmatter is valid.
- [x] `.claude/settings.json` authorizes `Agent(human-exception-runbook)` in the orchestrator allowlist.
- [x] The `orchestrate/SKILL.md` exception-runbook requirement delegates runbook authoring to `Agent(human-exception-runbook)`; the orchestrator still records the returned `runbook_path`.

### Cross-cutting

- [x] All new fields are additive and optional; existing routes and checkpoints validate unchanged; validators fail closed only on present-but-malformed data.
- [x] Bundle sync is complete for every mirror path listed in the Bundle Sync section; the byte-identity and content-parity pytest contracts pass. The Python toolchain (Black, Ruff, Pyright, Pytest) and the PowerShell toolchain (PoshQC, Pester) are green.

## Design Decisions

### DD-1: Enforcement stays within the handoff's stated language scope (Python), not the TypeScript MCP port

Research finding #2 established that the live MCP tool `mcp__drm-copilot__validate_orchestration_artifacts` traces to a TypeScript port (`extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`, via `orchestrator-state-core.ts`), which is a separate implementation from the Python `scripts/dev_tools/validate_orchestration_artifacts.py`. The handoff enumerates scope as JSON, Markdown, Python, and PowerShell only; it does not list TypeScript.

**Decision:** Keep this change within the handoff's stated language scope. Wire the two new validators into the Python `validate_orchestration_artifacts` path and enforce the two invariants via prose in `.claude/rules/orchestrator-state.md`, following the existing `human_interaction` precedent (an `_orchestrator_state_<topic>.py` module gated by `if <KEY> in state_map:` inside `validate_orchestrator_state_text`). Do not expand this change into TypeScript.

**Rationale (default vs. alternative):** The alternative — also updating the TypeScript port, its Vitest tests, its toolchain, and its bundle mirrors — would expand the stated language scope by an entire runtime surface (`orchestrator-state-core.ts` plus two new `.ts` modules plus tests) and increase blast radius and review cost. The handoff scoped the work to Python/JSON/Markdown/PowerShell deliberately. The Python-first path reuses an already-tested additive-key-gate pattern with no new backward-compatibility machinery.

**Concrete consequence (accepted):** The new invariants are enforced by pytest and the Python CLI/validator. This feature's own well-formed checkpoint passes the MCP tool because the MCP tool ignores unknown additive keys. However, the MCP tool will not reject malformed `complexity_assessments[]`/`model_routing_receipts[]` data until the TypeScript port is updated. This parity gap is recorded as a RISK and a recommended follow-up (see Risks); it should be tracked as a separate issue.

### DD-2: No governing JSON Schema exists; additive fields require prose plus validator code only

Research finding #1 confirmed that no dedicated JSON Schema file governs `config/orchestration-routing.json` anywhere in the repository, and that `.claude/rules/orchestrator-state.md` explicitly prohibits importing a foreign schema as the enforcement mechanism. Handoff open-decision #6 is therefore resolved: adding `model_policy`/`model_budget` requires no schema-file update. Enforcement is prose (this spec and the rule file) plus the new validator functions. A schema file is explicitly not introduced (see Rejected Alternatives in the research).

## Backward Compatibility

- All new fields are additive and optional. `model_policy` and `model_budget` are new top-level keys in `config/orchestration-routing.json`; the single load point `_orchestrator_state_routing.py::load_routing_matrix()` returns the parsed JSON as an opaque dict and asserts no shape beyond `routes`, so the additive keys are safe by construction.
- `complexity_assessments` and `model_routing_receipts` are NOT added to `REQUIRED_STATE_KEYS`. Each is checked with an `if <KEY> in state_map:` gate before its validator runs; an absent key contributes zero errors.
- A route entry lacking model-policy fields validates exactly as before. A checkpoint lacking the two new arrays validates exactly as before.
- Validators fail closed only on present-but-malformed data. Presence of a key triggers full invariant checks for that key; absence is unconditionally valid.

## Bundle Sync

Repo-root `.claude/` and `config/` are the source of truth. Bundled mirrors under `extensions/drm-copilot/resources/**` must be updated in lockstep in the same change. The following mirror paths require updates:

1. `extensions/drm-copilot/resources/claude-customizations/.claude/agents/commit-message.md` (new, byte-identical).
2. `extensions/drm-copilot/resources/claude-customizations/.claude/agents/human-exception-runbook.md` (new, byte-identical).
3. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` (edit, byte-identical).
4. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` (edit, byte-identical).
5. `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md` (edit, byte-identical).
6. `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` (edit, byte-identical, if `permissions.allow` changes).
7. `extensions/drm-copilot/resources/config/orchestration-routing.json` (edit, byte-identical).
8. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/*.md` (edit or new, byte-identical, for the `orchestrator-state.md` prose additions or any dedicated model-policy rule file).

Enforcing pytest contracts:

- `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` — asserts `config/orchestration-routing.json` is byte-identical to its bundled mirror (item 7).
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` — `test_bundled_claude_payload_contains_all_repo_runtime_contracts()` enumerates every file under `.claude/**` and asserts byte-identity in the bundle (items 1–6, 8). New agent files are covered automatically without a test edit.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` and `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py` — govern the Codex/`.agents` mirror; content-equivalent (not byte-identical) updates for orchestrator/orchestrate content are conditional and deferred per Out of Scope.

Test files for the new modules follow the 1:1 layout: `tests/scripts/dev_tools/test_compute_complexity_floor.py`, `tests/scripts/dev_tools/test_resolve_delegation_model.py`, and topic-scoped validator test files `tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py` and `tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing.py`.

## Out of Scope

- Introducing a JSON Schema file for `config/orchestration-routing.json` (DD-2; enforcement is prose plus validator code).
- Wiring the reference implementations into a runtime call path. Per the `epic_wave_computation` precedent, both functions are pure, tested reference formulas that the orchestrator/planner apply by judgment; they are imported only by their test modules and referenced by name in skill documentation.
- Adding a new `artifact_type` to `validate_orchestration_artifacts.py`. The new arrays live inside the existing `orchestrator-state` artifact.
- Making `route` model-aware in any way. `route` remains file-count driven and governs only agents/skills/MCP tools.
- Updating the TypeScript MCP port (`extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` plus new `.ts` modules and Vitest tests) to enforce the two new invariants. Deferred to a follow-up per DD-1; tracked as a separate issue.
- Authoring `.codex/agents/*.toml` wrappers for `commit-message`/`human-exception-runbook` and content-equivalent Codex/`.agents` updates for orchestrator/orchestrate. Not requested by the handoff; deferred.
- Adding a callable MCP documentation tool for the `human-exception-runbook` "MCP-first" sourcing clause. No such tool exists in the repository; until one is added, WebFetch is the sole available "web-second" mechanism and the MCP-first clause is aspirational. Documented, not resolved here.
- Creating `quality-tiers.yml`. Its absence is a pre-existing repo gap noted in research §5, out of this feature's scope.
- `AGENTS.md`/Copilot-instruction representation for the two new agents. Not requested by the handoff.

## Risks

- **RISK (parity gap, prominent):** Per DD-1, the live MCP tool `mcp__drm-copilot__validate_orchestration_artifacts` is a TypeScript port that this feature does not update. Consequence: pytest and the Python CLI enforce the new complexity/routing invariants, and this feature's well-formed checkpoint passes the MCP tool, but the MCP tool will not reject malformed `complexity_assessments[]`/`model_routing_receipts[]` data until a follow-up ports the two validators to TypeScript. Recommended action: open a separate issue to port `_orchestrator_state_complexity` and `_orchestrator_state_model_routing` to `orchestrator-state-core.ts` with Vitest coverage.
- **RISK (frontmatter acceptance):** `haiku`, `opus`, and `fable` have no precedent in the current `.claude/agents/*.md` corpus (research §6). Runtime acceptance of these `model:` values is unverified by the repo text; a smoke check during implementation (create the agent file, confirm Claude Code does not reject the frontmatter) is required.

## Definition of Done

- [x] Acceptance criteria above documented and mapped to tests.
- [x] Behavior matches acceptance criteria.
- [x] Unit tests added for both reference implementations and both validators; edge and error cases covered.
- [x] Backward-compatibility tests confirm routes and checkpoints without the new fields validate unchanged.
- [x] Bundle-sync mirrors updated; parity pytest contracts pass.
- [x] `.claude/rules/orchestrator-state.md` extended with additive scope/enforcement subsections for the two new arrays.
- [x] Python toolchain (Black, Ruff, Pyright, Pytest with coverage) and PowerShell toolchain (PoshQC, Pester) pass in a single clean run.
