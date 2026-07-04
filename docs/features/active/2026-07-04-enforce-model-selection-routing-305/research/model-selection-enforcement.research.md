# Research: Enforce Model-Selection Routing (Issue #305)

Canonical issue number for this feature is 305. All artifact content, file paths, and cross-references use this number.

## Problem Restatement

The orchestrator's Model Selection procedure (`.claude/skills/orchestrate/SKILL.md:68-86`) is documented but mechanically unenforced. In the bug #301 session it was skipped across ~15 delegations: no `model` parameter was passed and neither `complexity_assessments[]` nor `model_routing_receipts[]` appeared in `artifacts/orchestration/orchestrator-state.json`, yet the checkpoint validated clean at every stage including `require_complete: true`. This research designs a fix that (a) closes the enforcement gap structurally and (b) makes a resuming orchestration deterministically repair a missing model choice before it delegates. No implementation edits are proposed.

---

## Current Contract

### Model Selection procedure (documented, unenforced end-to-end)
`.claude/skills/orchestrate/SKILL.md:68-86` defines the four-step procedure: parse `model_budget.fable_policy`; assess `complexity_band` and record a `complexity_assessments[]` entry `{ phase, band, floor, signals_present[], rationale, assessed_at }`; run per-delegation selection via `resolve_delegation_model(agent, complexity_band, fable_policy)`; emit a `model_routing_receipts[]` entry `{ agent, phase, complexity_band, fable_policy, table_model, clamped_from | null, model }`. Line 84 states both arrays are "additive and optional" and enforced "per `.claude/rules/orchestrator-state.md`." That optionality is the gap: nothing requires the arrays to exist when delegations occur.

### Reference formulas (must be reused, not reimplemented)
- `scripts/dev_tools/compute_complexity_floor.py:65` — `compute_complexity_floor(signals_present: Sequence[str]) -> ComplexityBand`. Pure; each `[floor]` signal contributes candidate `C3`; floor clamped to at most `C3` (`FLOOR_CEILING_BAND`, line 62). Exports `BAND_ORDER` (line 53), `LOWEST_BAND`, `FLOOR_CANDIDATE_BAND`.
- `scripts/dev_tools/resolve_delegation_model.py:79` — `resolve_delegation_model(agent: str, band: str, fable_policy: str) -> dict[str, str | None]`. Pure; returns `{table_model, model, clamped_from, clamp_reason}`. Constants: `DISABLED_POLICY`, `PREFERRED_POLICY`, `FABLE_MODEL="fable"`, `DISABLED_CLAMP_MODEL="opus"`, `BASE_COMPLEXITY_TO_MODEL` (C1 haiku, C2 sonnet, C3 opus, C4 fable), `PREFERRED_OVERLAY_AGENTS={atomic-planner, prd-feature, feature-review, task-researcher}`. Raises `KeyError` on an out-of-table band (line 106).

### Existing optional-array validators (shape-only, not existence-forcing)
- `scripts/dev_tools/_orchestrator_state_model_routing.py` — `MODEL_ROUTING_RECEIPTS_KEY = "model_routing_receipts"` (line 53); `_validate_model_routing_receipts(value)` (line 57). Per-receipt (`_validate_one_receipt`, line 107): band must be in `C1..C4`; `model == resolve_delegation_model(...)["model"]`; disabled-mode clamp invariants (`_validate_disabled_clamp`, line 170). It validates *entries that are present*; it never requires that an entry exist.
- `scripts/dev_tools/_orchestrator_state_complexity.py` — `COMPLEXITY_ASSESSMENTS_KEY = "complexity_assessments"` (line 50); `_validate_complexity_assessments(value)` (line 56). Same present-only shape semantics.

### Main validator wiring and the `require_*` flag pattern
`scripts/dev_tools/validate_orchestrator_state.py` (496 lines — 4 below the 500-line limit) exposes:

```
validate_orchestrator_state_text(
    text: str,
    *,
    require_complete: bool = False,
    strict_route_membership: bool = False,
    require_pr_creation_ready: bool = False,
) -> list[str]
```
(lines 357-363). Threading rules:
- Optional additive blocks are validated only when their key is present (lines 448-456): the tuple `optional_key_validators` maps each key to its shape validator and runs it only `if optional_key in state_map`. `model_routing_receipts` and `complexity_assessments` are already wired here.
- `require_complete` appends the completion gate (lines 465-488): completion-safe lifecycle statuses, `validate_completion_pr_gate`, `_validate_completion_ci_gate`, `validate_phase_completeness`, `validate_routing_contract`. None of these check model routing.
- `require_pr_creation_ready` (lines 490-493) appends `validate_orchestrator_state_pr_creation_readiness` — a narrower, independent gate.

This confirms the established extension shape: **a new opt-in boolean keyword that appends a delegated validator, default `False`, byte-identical for callers that do not pass it.**

### CLI surface
`scripts/dev_tools/validate_orchestration_artifacts.py`: `build_parser()` (line 139) defines the `orchestrator-state` subparser with `--require-complete` (line 171) and `--require-pr-creation-ready` (line 176). `_validate_from_args` (line 196) forwards both to `validate_orchestrator_state_text` (lines 226-231). A new flag `--require-model-routing` would be added to the subparser and forwarded here in the same shape.

### Hooks consuming the validator
- `.claude/hooks/validate-orchestrator-output.ps1` (SubagentStop `orchestrator`): `Invoke-RoutingContractValidation` (line 150) shells to `python -m scripts.dev_tools.validate_orchestration_artifacts <Type> <Path> --require-complete` through an injectable `$Invoker` seam (lines 180-189). `Invoke-OrchestratorOutputValidation` (line 207) parses `CLAUDE_HOOK_INPUT`, checks required fields, runs `Test-HumanInteractionShape` (line 66), then the routing validator; on error it blocks DONE with `ROUTING_CONTRACT_BLOCKED:` (line 296). This is the completion-time gate template.
- `.claude/hooks/enforce-pr-author-skill.ps1` (PreToolUse `Bash`): `Invoke-OrchestratorStatePreflight` (line 49) shells to the validator with `--require-pr-creation-ready` via `$Invoker` (lines 70-79) and blocks with `ORCHESTRATOR_STATE_PREFLIGHT_FAILED:` (line 369). This is the pre-delegation preflight template referenced by the objective.

### MCP-tool wrapper (critical divergence)
The MCP tool `mcp__drm-copilot__validate_orchestration_artifacts` does **not** shell out to the Python validator. It is backed by a separate TypeScript reimplementation: `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts:163` (`validateArtifact`) dispatches the `orchestrator-state` case to `validateOrchestratorStateText` in `orchestrator-state-core.ts`. That TS validator supports only `requireComplete` (`mcp-tool-inputs.ts:81,468`; `mcp-repo-automation-tool-definitions.ts:437`). A repo-wide grep for `model_routing_receipts`, `complexity_assessments`, `requirePrCreationReady`, and `resolveDelegationModel` under `extensions/drm-copilot/src` returned **no matches**. Consequences:
- The TS MCP validator does not validate `model_routing_receipts` or `complexity_assessments` at all today, and does not expose `--require-pr-creation-ready`.
- The **authoritative** model-routing enforcement is the Python validator invoked by the two PowerShell hooks. Any design must land on the Python path to be load-bearing. Extending the TS MCP tool is optional parity work, tracked as residual risk below.

### Rule contract
`.claude/rules/orchestrator-state.md` — Model-Routing-Receipt and Complexity-Assessment invariant sections state enforcement is "the Python validator, not an imported schema," and both blocks are "additive." The Model-Budget Contract section defines `fable_policy` as `disabled | available | preferred` (default `disabled`) from `config/orchestration-routing.json` and reiterates `route` is never a model-selection input. The "Foreign Schema Warning" prohibits copying the `drmoisan.github.io/mix-calculator/` schema; enforcement remains prose + Python logic. A new `require_model_routing` gate must be expressed the same way (prose in this rule + Python validator logic), never as an imported schema.

---

## Hook-Input Visibility Decision

**Decision: A PreToolUse hook on the delegation call can reliably see the target subagent type and the delegation prompt, but there is NO repo evidence that it can see a `model` parameter passed to the delegate.**

Evidence:
- The delegation tool surfaces to hooks under the matcher name **`Agent`**. `settings.json:145-161` registers three PreToolUse hooks under `"matcher": "Agent"`.
- Both existing Agent-matcher gating hooks parse `CLAUDE_TOOL_INPUT` as JSON and read exactly two fields:
  - `enforce-prd-feature-before-planner.ps1:172` reads `$toolInput.subagent_type`; line 177 reads `$toolInput.prompt`.
  - `enforce-epic-wave-barrier.ps1:257` reads `$toolInput.subagent_type`; line 262 reads `$toolInput.prompt`.
- A grep for `model` (case-insensitive) across all of `.claude/hooks` returned **no matches**. No hook in the repository reads a `model` field from tool input, and no vendored hook-input schema documents one.

Interpretation:
- **Confirmed visible:** `subagent_type` (the delegate agent name) and `prompt` (the full delegation prompt text).
- **Not confirmed visible:** the model tier the orchestrator selects for the delegate. There is no evidence the `Agent`/`Task` tool input JSON carries a `model` field, and the orchestrator's model choice is recorded in checkpoint state (`model_routing_receipts[]`), not necessarily surfaced as a tool parameter. Whether `Agent(...)` even accepts a per-call `model` argument at this Claude Code version is itself unconfirmed from repo evidence.

Therefore a PreToolUse Agent hook **cannot verify the correctness of a model choice** (it cannot read the chosen model). It can, however, verify *presence of a routing receipt for the delegate about to run*, because it can read `subagent_type` and can read the on-disk checkpoint (as `enforce-prd-feature-before-planner.ps1` and `enforce-epic-wave-barrier.ps1` already read `orchestrator-state.json` / `epic-orchestrator-state.json`). This makes a **presence-gating** PreToolUse hook feasible and a **correctness-gating** PreToolUse hook infeasible.

Residual uncertainty is stated honestly: the exact `Agent`/`Task` PreToolUse input schema is not vendored in-repo; the two conclusions above are inferred from what the two production Agent-matcher hooks actually parse.

---

## Design Options

### Option A — PreToolUse gate on the delegation call (block before the delegate runs)
Add a PreToolUse hook under the `Agent` matcher. On each delegation it reads `subagent_type`, reads `orchestrator-state.json`, and blocks unless a `model_routing_receipts[]` entry already exists for the delegate about to run (optionally correlated by the phase named in the prompt).

- Pros: Blocks *before* the wrong-tier subagent executes — the only option that prevents the delegation itself. Mirrors the established `enforce-prd-feature-before-planner.ps1` pattern (same matcher, same input fields, same checkpoint-read seam), so it is low-novelty and testable with the existing Pester mock conventions.
- Cons: Can only verify *presence* of a receipt, not that the recorded `model` is correct (correctness is the Python validator's job — Hook-Input Visibility Decision). Requires the orchestrator to write the receipt *before* it issues the delegation, which is a sequencing change to the documented procedure. Correlating a specific delegation to a specific receipt is heuristic: the hook must infer `(agent, phase)` from `subagent_type` + prompt text, and the same agent is delegated many times across phases, so a stale prior-phase receipt could satisfy a naive "any receipt for this agent" check. A strict per-phase correlation depends on parsing the phase out of free-text prompt content, which is brittle.

### Option B — SubagentStop / completion-time checkpoint gate (flag after the delegate returns)
Extend `validate-orchestrator-output.ps1` (or its Python validator) so DONE is refused when a delegation occurred without a recorded routing receipt. Mirrors `Test-HumanInteractionShape` (a completion-time shape gate already living in this hook).

- Pros: Reuses the exact enforcement channel that already blocks DONE (`ROUTING_CONTRACT_BLOCKED:`). Deterministic correlation: at completion, `delegation_receipts[]` is the authoritative record of which agents were delegated (validated under `require_complete` via `validate_routing_contract`), so "every delegated agent must have a routing receipt" is checkable without prompt parsing. No sequencing change to the delegation act itself.
- Cons: Detects the omission only at the end of the run — the ~15 mis-tiered delegations in #301 would still have executed. It closes the "DONE while unrouted" hole but not the "delegate ran at the wrong tier" hole. Does not by itself repair a missing choice on resume; that needs the resume sub-procedure.

### Option C — Validator-only enforcement via a new `require_model_routing` flag
Add `require_model_routing: bool = False` to `validate_orchestrator_state_text`, backed by a new delegate module, surfaced as `--require-model-routing` on the CLI, and invoked at the completion gate and at resume-preflight. No new hook.

- Pros: Single authoritative locus (the Python validator) that both hooks already consume; no new hook wiring; correctness *and* presence both enforced (the flag can require both that receipts exist for delegated agents and that each receipt is self-consistent, reusing the existing `_validate_model_routing_receipts`). Backward-compatible by construction — default `False` means existing plain / `require_complete` / `require_pr_creation_ready` calls are byte-identical. Keeps enforcement out of brittle prompt parsing.
- Cons: A flag is only as strong as its callers. If no hook passes `--require-model-routing`, it enforces nothing (this is exactly today's failure mode for the "optional" arrays). It cannot block an individual delegation before it runs; the earliest it can act is the next validator invocation (resume-preflight or completion).

---

## Recommended Design

**Adopt Option C as the enforcement core, combined with Option A as the pre-delegation deterrent and a resume-reconciliation sub-procedure. Reject Option B as a standalone (it is subsumed by C at the completion gate).**

Rationale: the acceptance criteria have three parts — (1) block-or-flag a delegation lacking a routing receipt, (2) refuse DONE when a delegation lacks a recorded model choice, (3) deterministically repair on resume. Option C alone satisfies (2) and, when invoked at resume-preflight, powers (3). Option A adds the only mechanism that can act *before* a delegation and satisfies (1) as a hard pre-block. The two share one source of truth (the checkpoint + the Python validator), so they cannot disagree.

Concrete composition:

1. **Validator core (Option C).** Add `require_model_routing: bool = False` to `validate_orchestrator_state_text`. When `True`, append the result of a new delegate `scripts/dev_tools/_orchestrator_state_model_routing_gate.py` (new file — the primary validator has only 4 lines of headroom under the 500-line cap, and every optional block already lives in its own `_orchestrator_state_*.py`). The gate:
   - Computes the set of *delegated agents* from `delegation_receipts[]` (the same source `validate_routing_contract` already trusts).
   - Requires, for each delegated agent, at least one `model_routing_receipts[]` entry naming that agent.
   - Reuses `_validate_model_routing_receipts` for per-receipt correctness (do not reimplement `resolve_delegation_model`).
   - Optionally requires a `complexity_assessments[]` entry for each distinct phase referenced by the receipts, reusing `_validate_complexity_assessments`.
2. **CLI (Option C).** Add `--require-model-routing` to the `orchestrator-state` subparser and forward it through `_validate_from_args`.
3. **Completion gate (Option C at DONE).** Have `validate-orchestrator-output.ps1` pass `--require-model-routing` (alongside `--require-complete`) in its default `$Invoker`, so DONE is refused when a delegated agent has no routing receipt. Block reason mirrors `ROUTING_CONTRACT_BLOCKED:` (for example `MODEL_ROUTING_BLOCKED:`).
4. **Resume-preflight reconciliation (Option C at resume) + Startup Protocol.** Add a model-choice reconciliation sub-procedure to `## Checkpoint Handling` and mirror it into the orchestrator agent Startup Protocol, so a resuming orchestration runs the validator with `--require-model-routing` before its first delegation and repairs a missing/inconsistent receipt deterministically (recompute via the two reference formulas and write the receipt) before delegating.
5. **Pre-delegation deterrent (Option A).** Add a PreToolUse `Agent`-matcher hook that, for delegating subagent types, reads the checkpoint and blocks a delegation whose agent has no `model_routing_receipts[]` entry. Scope it to *presence* only (per the Hook-Input Visibility Decision); correctness stays with the Python validator. This is the layer that prevents a mis-tiered delegation from running at all.

Layering note: this is the same two-layer shape the epic wave barrier uses (`enforce-epic-wave-barrier.ps1` Layer-1 per-call deterrent + validator Layer-2 backstop). The PreToolUse hook is the per-call deterrent; the `require_model_routing` validator is the retrospective backstop at DONE and the deterministic repair at resume.

---

## Delegating-Step → (agent, phase) Mapping

Checkpoint step vocabulary (observed in `_orchestrator_state_routing.py`, the base fixture `build_valid_orchestrator_state`, and SKILL.md):
- `completed_steps[]` / `next_step` use canonical phase tokens: `S3_promotion`, `S4_atomic_planning`, `S8_create_pr`, `S9_ci_green`, `done`, and remediation tokens `R1..R5` (SKILL.md:149-160). `MANDATORY_ROUTE_PHASES` (routing module, line 16) codifies `small` → `("S3_promotion", "S4_atomic_planning")`.
- `delegation_receipts[]` entries carry `agent_name` and a `step` field (fixture lines 58-68; `REQUIRED_RECEIPT_KEYS` includes both).
- `model_routing_receipts[]` entries carry `{ agent, phase, ... }` (SKILL.md:82).

Delegating agents per route (`config/orchestration-routing.json` `required_agents`):
- `small` (lines 6-11): atomic-planner, atomic-executor, feature-review.
- `large` (lines 31-38): task-researcher, prd-feature, atomic-planner, atomic-executor, feature-review, pr-author.
- `remediation` (lines 59-63): atomic-planner, atomic-executor, feature-review.
- `epic` (lines 78-81): orchestrator, pr-author (child orchestrators delegate their own inner agents).

Recommended mapping rule for the `require_model_routing` invariant: **correlate on `agent`, not on a parsed phase.** The authoritative "a delegation happened" record is `delegation_receipts[].agent_name`. The gate requires that the set of agents in `model_routing_receipts[].agent` be a superset of the set of agents in `delegation_receipts[].agent_name`. This avoids brittle phase parsing and reuses records the validator already trusts. The `phase` field on each routing receipt remains recorded for provenance and per-phase complexity correlation, but the existence invariant keys on agent identity. For the PreToolUse deterrent (Option A), the delegate's identity is read directly from `subagent_type`; the hook checks that some routing receipt already names that agent.

---

## Backward-Compatibility Analysis

Requirement: old checkpoints with no delegations and no route/model_budget markers stay valid, and existing plain / `require_complete` / `require_pr_creation_ready` calls return byte-identical results.

- **Default-off flag.** `require_model_routing` defaults `False`. The append happens only inside `if require_model_routing:`. Callers that do not pass it — including every current `require_complete` and `require_pr_creation_ready` invocation — traverse an unchanged code path and produce identical output. This matches how `require_pr_creation_ready` was added without disturbing `require_complete`.
- **Additive-key preservation.** The existing key-gated loop (validator lines 448-456) already runs the shape validators for `model_routing_receipts` / `complexity_assessments` only when the key is present. The new gate must not add an unconditional requirement outside the `require_model_routing` branch; a checkpoint that omits both arrays and is validated *without* the new flag stays clean.
- **Gating condition precisely.** Under `require_model_routing == True`, the gate requires a routing receipt per delegated agent **only when `delegation_receipts[]` contains at least one well-formed entry.** A checkpoint with zero delegation receipts (no delegation occurred) imposes no routing-receipt requirement, so genuinely old, delegation-free checkpoints validated under the flag still pass. This is the condition that keeps the flag safe to turn on at the completion gate: a completed run necessarily has delegation receipts for its `required_agents`, so it must also carry routing receipts; a pre-delegation or trivial checkpoint has none and is unaffected.
- **Route/model_budget independence.** The gate keys on `delegation_receipts` presence, not on `route_id`/`path_selected`/`model_budget`. A checkpoint lacking route or model-budget markers is not newly rejected by this gate (route membership remains the separate, already-opt-in `strict_route_membership` concern).
- **Model-budget note.** The gate never needs to read `fable_policy` itself; each `model_routing_receipts[]` entry already records its own `fable_policy`, and `_validate_model_routing_receipts` recomputes correctness from it. This keeps the gate independent of session config drift.

---

## Agent Frontmatter Audit

Every `.claude/agents/*.md` and its current `model:` frontmatter value (grep `^model:` across `.claude/agents`):

| Agent file | Current `model:` | In overlay set? | Recommended floor default |
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
| task-researcher.md | sonnet | yes | sonnet (keep) or opus |
| typescript-engineer.md | none | no | sonnet |

Notes and rationale:
- Only 4 of 17 agents declare a static `model:` today (task-researcher, human-exception-runbook, pr-author → sonnet; commit-message → haiku). `atomic-executor` is the specifically-called-out known-missing case; 12 others are also unset.
- The `model:` frontmatter is a *static safety-net default* (the tier the delegate runs at if the orchestrator passes no per-call model), which is a distinct mechanism from the orchestrator's *dynamic per-delegation* selection recorded in `model_routing_receipts[]`. Setting a floor default reduces the blast radius of a skipped Model Selection: even if a receipt is missing, the delegate still runs at a defensible tier rather than an inherited session default.
- Recommended floor defaults align with each agent's realistic complexity band under the default `fable_policy=disabled` (where C3→opus and C4 clamps to opus): substantive planning/review/orchestration agents default to `opus`; language engineers to `sonnet` (localized C2-class edits, escalated per-call when the orchestrator assesses higher); mechanical/reporting agents (commit-message, status-updater) to `haiku`. These are recommendations for the planner to confirm; the validator never reads frontmatter, so a wrong default is a safety-net quality issue, not a correctness break.
- The four overlay agents (atomic-planner, prd-feature, feature-review, task-researcher) are the only ones whose C3 cell can move to `fable` under `fable_policy=preferred`; under the default `disabled` policy that cell clamps to opus, so `opus` is the correct static floor for them.

---

## Bundle Mirror Map

The byte-identical mirror contract is enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 100-125): **every** repo `.claude/**` file (excluding `.claude/settings.local.json` and `.claude/agent-memory/**`) must exist byte-identically under `extensions/drm-copilot/resources/claude-customizations/.claude/**`. The routing config has a separate byte-identity test (`test_orchestration_routing_config_parity.py`) against `extensions/drm-copilot/resources/config/orchestration-routing.json`.

Source → mirror pairs for the files this feature will edit:

| Runtime source | Bundle mirror | Parity enforcer |
|---|---|---|
| `.claude/settings.json` | `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` | claude resource-contract byte-identity |
| `.claude/skills/orchestrate/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` | claude resource-contract byte-identity |
| `.claude/rules/orchestrator-state.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` | claude resource-contract byte-identity |
| `.claude/agents/<each edited>.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/<same>.md` | claude resource-contract byte-identity |
| new `.claude/hooks/<new-hook>.ps1` (Option A) | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/<new-hook>.ps1` | claude resource-contract byte-identity (any new `.claude/**` file is auto-required by the "all repo runtime contracts" test) |
| `.claude/hooks/validate-orchestrator-output.ps1` (if edited) | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1` | claude resource-contract byte-identity |
| `config/orchestration-routing.json` (only if `model_policy` changes) | `extensions/drm-copilot/resources/config/orchestration-routing.json` | routing-config byte-identity |

Files with **no** bundle mirror obligation (not under `.claude/**` and not under `resources/`):
- `scripts/dev_tools/validate_orchestrator_state.py` and all `_orchestrator_state_*.py` siblings, the new gate module, `resolve_delegation_model.py`, `compute_complexity_floor.py`, `validate_orchestration_artifacts.py`. No Python `scripts/**` file appears under `extensions/drm-copilot/resources/**` (glob for `resources/**/scripts/**/*.py` and for `resources/**/*orchestrator_state*.py` both returned nothing).

Codex mirror caveat: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` is a **curated, converted subset**, not a byte-identical copy of `.claude/hooks/`. Its contract test scopes only `.codex`/`.agents` roots (`test_push_down_codex_and_agents_resource_contracts.py:15`). The existing Agent-matcher gating hooks (`enforce-prd-feature-before-planner.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-epic-merge-gate.ps1`) are **absent** from `.codex/hooks/`, so a new Agent-matcher deterrent (Option A) follows that precedent and is not expected to require a codex mirror. The planner should confirm against the codex pack-selection manifest.

---

## Test Inventory & Gaps

Existing validator tests under `tests/scripts/dev_tools/`:
- `test_validate_orchestrator_state.py` — core/top-level validator.
- `test_validate_orchestrator_state_model_routing.py` — per-receipt shape (well-formed pass; model mismatch; disabled-mode fable; missing-clamp; band-enum; non-list; non-object; backward-compat "no key"; wired-through-public-validator present/malformed). Fixtures build receipts from `resolve_delegation_model` (the reuse-not-reimplement convention).
- `test_validate_orchestrator_state_complexity.py` — complexity-assessment shape.
- `test_validate_orchestrator_state_remediation_loop.py` — hosts the shared `build_valid_orchestrator_state()` fixture reused across the suite.
- `test_validate_orchestrator_state_pr_creation_readiness.py` and `test_validate_orchestration_artifacts_pr_creation_readiness.py` — the `require_pr_creation_ready` flag at both the unit and CLI/dispatch layers (the closest existing template for adding a new gate flag).
- `test_validate_orchestration_artifacts_dispatch.py` / `test_validate_orchestration_artifacts.py` / `test_validate_orchestration_artifacts_state_shape.py` — CLI dispatch and flag forwarding.
- `test_validate_orchestrator_state_routing_contract.py` — routing-contract completion checks (delegation/skill/mcp receipts).

Gaps to fill for issue #305 (new tests, mirroring the above conventions):
1. **Strict-mode missing-entry** — a checkpoint with `delegation_receipts` for agents X, Y but a `model_routing_receipts` set missing Y is rejected under `require_model_routing=True`.
2. **Strict-mode present-and-consistent** — receipts present for every delegated agent and each self-consistent → zero errors under the flag.
3. **Strict-mode present-but-model-mismatch** — a receipt whose `model != resolve_delegation_model(...)` is caught under the flag (delegating to the reused `_validate_model_routing_receipts`).
4. **Backward-compatible no-delegation** — a delegation-free checkpoint under `require_model_routing=True` passes; and a checkpoint validated *without* the flag is byte-identical to today (assert equality of error lists with/without the arrays present).
5. **CLI forwarding** — `--require-model-routing` reaches `validate_orchestrator_state_text(require_model_routing=True)` (mirror `test_validate_orchestration_artifacts_pr_creation_readiness.py`).
6. **Flag independence** — passing `--require-model-routing` alone does not trigger `require_complete`/`require_pr_creation_ready` checks, and vice versa.

Pester test-location convention for the chosen hook: PowerShell tests mirror source structure at `tests/scripts/powershell/**` per `.claude/rules/general-unit-test.md` ("the test for `scripts/powershell/Foo.ps1` belongs at `tests/scripts/powershell/Foo.Tests.ps1`"). Hook tests in this repo follow the `*.Tests.ps1` naming with dot-source seams (`if ($MyInvocation.InvocationName -eq '.') { return }`) and injectable checkpoint-read/validator seams, exactly as `enforce-prd-feature-before-planner.ps1` and `validate-orchestrator-output.ps1` are structured. New coverage needed: (a) for the Option A Agent hook — allow when a receipt exists for `subagent_type`, deny when absent, allow for non-delegating tool inputs, malformed-JSON handling; (b) for `validate-orchestrator-output.ps1` — the new `--require-model-routing` argument threads through the `$Invoker` seam and a validator error surfaces as the `MODEL_ROUTING_BLOCKED:` block reason.

---

## Automation Feasibility

This change is entirely repo-local tooling: Python (validator core, new gate delegate, CLI flag), PowerShell (one PreToolUse hook and one edit to the SubagentStop hook), Markdown (SKILL.md procedure, orchestrator agent, orchestrator-state rule), and JSON (settings.json hook wiring; routing config only if `model_policy` changes). There is no third-party UI, portal, admin center, or any human-in-the-loop step at any stage. All gates are exercised by the standard local toolchains (Black/Ruff/Pyright/Pytest for Python; PoshQC format/analyze + Pester for PowerShell) and the byte-identity bundle-parity tests. No unautomatable requirement was discovered. The autonomous-execution mandate is satisfied with **zero `human_interaction` entries**; the orchestrator should record `human_interaction` as absent (the backward-compatible default).

---

## Open Questions / Residual Risk

1. **`Agent`/`Task` PreToolUse input schema is not vendored in-repo.** The two production Agent-matcher hooks read only `subagent_type` and `prompt`; no hook reads a `model` field. Whether tool input carries the selected model — or whether `Agent(...)` accepts a per-call `model` at all in this Claude Code version — is unconfirmed. Option A is therefore scoped to *presence* gating, and correctness gating stays in the Python validator. If a future Claude Code version does expose the model in tool input, Option A could be upgraded to correctness gating; do not assume it today.
2. **TypeScript MCP validator divergence.** `mcp__drm-copilot__validate_orchestration_artifacts` is backed by `orchestration-artifacts.ts` / `orchestrator-state-core.ts`, which currently implement neither `model_routing_receipts`/`complexity_assessments` validation nor `require_pr_creation_ready`, and expose only `require_complete`. The load-bearing enforcement path for #305 is the **Python** validator invoked by the PowerShell hooks, so the feature is enforceable without touching the TS side. However, an orchestrator that calls the MCP tool (rather than the local Python CLI) for its own preflight would not see model-routing errors from the MCP tool. Achieving MCP parity (adding a TS `requireModelRouting` and porting the receipt logic) is a larger, separate scope; flag it explicitly so the planner decides whether #305 includes MCP parity or defers it.
3. **Phase correlation granularity.** The recommended existence invariant keys on `agent` (from `delegation_receipts`), not on a parsed phase, to avoid brittle prompt parsing. This means a checkpoint could satisfy the gate with one routing receipt per agent even if that agent was delegated in multiple phases with different complexity bands. If per-phase correctness (a receipt per (agent, phase) delegation) is a hard requirement, the orchestrator must record a `phase`/`step` on each `delegation_receipts` entry (the `step` key already exists in `REQUIRED_RECEIPT_KEYS`) and the gate must correlate on `(agent, step)`. Confirm the desired granularity with the planner; the agent-only rule is the backward-compatible minimum.
4. **Resume-repair authority.** The resume reconciliation writes a routing receipt by recomputing the two reference formulas. This assumes the resuming orchestrator can re-derive `complexity_band` for a past phase. If the original `complexity_band` judgment was not persisted (e.g., no `complexity_assessments[]` entry for that phase), the resume step cannot faithfully reconstruct it and must re-assess. The design should require that `complexity_assessments[]` be written alongside each routing receipt so resume repair is deterministic rather than a fresh judgment.
5. **New-file size headroom.** `validate_orchestrator_state.py` is at 496/500 lines. The new gate logic must live in a new `_orchestrator_state_*.py` delegate (consistent with the existing per-block split); adding more than a few lines inline to the primary validator would breach the 500-line limit.
