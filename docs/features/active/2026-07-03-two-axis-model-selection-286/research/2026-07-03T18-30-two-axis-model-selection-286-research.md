# two-axis-model-selection (Issue #286) — Research

- Issue: #286
- Research date: 2026-07-03
- Scope: de-risk implementation of `model_policy`/`model_budget` in `config/orchestration-routing.json`, two Python reference implementations, two validators wired into `validate_orchestration_artifacts`, `orchestrate`/`epic-orchestrate` SKILL.md documentation, and two new agents (`commit-message`, `human-exception-runbook`).

Canonical issue number for this feature is 286. All artifact content, file paths, and cross-references must use this number.

## 1. `config/orchestration-routing.json` — current structure and schema governance

Current file (`config/orchestration-routing.json`, 99 lines) has exactly two top-level keys besides `$schema`/`version`: `routes` (an object keyed by `small`/`large`/`remediation`/`epic`, each entry carrying `description`, optional `requires_pr_gate`, `required_agents[]`, `required_skills[]`, `required_mcp_tools[]`). There is no `model_policy` or `model_budget` key today.

**`$schema` field**: `"https://json-schema.org/draft/2020-12/schema"`. This is the generic JSON Schema **meta-schema** URI (the spec itself), not a link to a repository-authored schema document that defines this file's shape. It is boilerplate, not enforcement.

**No dedicated schema file governs this config anywhere in the repo.** Verified by:
- `Glob schemas/**` — no matches; no `schemas/` directory exists in this repository at all.
- `Grep` for `orchestration-routing.*schema` / `schema.*orchestration-routing` across the repo — the only hits are inside `docs/features/active/2026-07-03-two-axis-model-selection-286/**` (this feature's own docs) and one unrelated historical plan file that does not define a schema.
- The orchestrator-state contract-provenance rule (`.claude/rules/orchestrator-state.md`) explicitly documents that a foreign JSON Schema (`$id` referencing `drmoisan.github.io/mix-calculator/`) must **not** be copied verbatim, and that this repository's enforcement mechanism is prose-plus-validator-logic, not an imported schema file. `_orchestrator_state_human_interaction.py`'s docstring states the same: "The validator never imports `schemas/orchestrator-state.schema.json`."

**Conclusion for downstream planning**: `orchestration-routing.json`'s shape is governed entirely by (a) this prose research/spec, (b) the Python loader/validators in `scripts/dev_tools/_orchestrator_state_routing.py` (which reads `matrix["routes"]` structurally but does not validate the whole file against a schema), and (c) whatever new validator functions this feature adds. Adding `model_policy`/`model_budget` requires **no schema-file update** because none exists; it only requires updating the prose contract (this feature's own spec/rules) and any new validator functions that read the new keys. `_orchestrator_state_routing.py::load_routing_matrix()` (`scripts/dev_tools/_orchestrator_state_routing.py:21`) is the single load point; it returns the parsed JSON as an opaque `dict[str, Any]` with no shape assertion beyond `matrix.get("routes")`, so an additive `model_policy` key is safe by construction.

**Bundled mirror (parity requirement, ties to research question 10 below):** `config/orchestration-routing.json` **is** bundled and **is** covered by a dedicated byte-identity test: `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`. It asserts `config/orchestration-routing.json` and `extensions/drm-copilot/resources/config/orchestration-routing.json` are byte-for-byte identical (`_CANONICAL_CONFIG.read_bytes() == _BUNDLED_CONFIG.read_bytes()`). Any edit adding `model_policy`/`model_budget` to the canonical file **must** be mirrored into the bundled copy at `extensions/drm-copilot/resources/config/orchestration-routing.json` in the same change, or this test fails.

## 2. Reference-implementation pattern — `scripts/dev_tools/epic_wave_computation.py`

Full file read (154 lines). Structure to mirror exactly for `compute_complexity_floor` and `resolve_delegation_model`:

- **Module docstring** with `Purpose:`, `Responsibilities:`, `Usage:` sections (Google-style, per `.claude/rules/self-explanatory-code-commenting.md`). States that the module is "the canonical, tested reference implementation" of a formula documented in a named SKILL.md/agent.md section, and that the module is pure (no file I/O).
- **`from __future__ import annotations`**, then `TYPE_CHECKING`-gated imports of `Mapping`/`Sequence` from `collections.abc` (avoids runtime import of typing-only names).
- **A dedicated exception class** for the one failure mode, subclassing a concrete stdlib exception (`EpicWaveCycleError(ValueError)`), with a full docstring (`Purpose`, `Attributes`) and an `__init__` that builds a descriptive message embedding the offending key.
- **One public function**, fully typed: `def compute_wave_numbers(manifest: Mapping[str, Sequence[str]]) -> dict[str, int]`. Google-style docstring with `Args/Returns/Raises/Side Effects` — `Side Effects: None. This function is pure.`
- **Internal memoized recursion** via a nested closure (`resolve`), using two local mutable structures (`wave_numbers: dict[str, int]` memo, `in_progress: set[str]` cycle guard) — no module-level mutable state, no classes needed (matches `.claude/rules/python.md` "create a standalone function when the operation is pure, stateless, and simple").
- **No dataclasses/enums** in this module — the domain is simple enough that a plain `dict[str, int]` return and a mapping input suffice. (For the two new reference implementations, a `Literal["C1","C2","C3","C4"]` type alias or a small `Enum` may be justified since the complexity band has a fixed textual enum — see §4 below.)
- **Determinism**: expressed by (a) pure function with no I/O, (b) deterministic result independent of dict iteration order because the memo/in-progress guard resolves recursively rather than relying on insertion order, (c) explicit test coverage of diamond-DAG, linear-chain, disconnected, self-cycle, and 3-node-cycle cases (see `tests/scripts/dev_tools/test_epic_wave_computation.py`, 112 lines, 8 tests).
- **Import/consumption**: `compute_wave_numbers` is imported **only by its test module** (`tests/scripts/dev_tools/test_epic_wave_computation.py`) — it is **not** imported by any production script or CLI. It is referenced only in prose inside `.claude/skills/epic-orchestrate/SKILL.md` ("## Wave Assignment") and `.claude/agents/epic-orchestrator.md` ("## Wave Scheduling") as "the canonical, tested reference implementation of this formula" that the agent applies by hand per the documented algorithm. Verified via repo-wide grep: the only non-test, non-doc hits for `epic_wave_computation`/`compute_wave_numbers` are the module itself and the two SKILL/agent doc files.

**Implication for `compute_complexity_floor` / `resolve_delegation_model`**: precedent is that these are **pure, exhaustively unit-tested formula modules that document the algorithm the orchestrator/atomic-planner apply by hand** at judgment time, not modules wired into a runtime call path. Unless the spec explicitly decides otherwise, plan for the same shape: two pure functions in (likely) `scripts/dev_tools/compute_complexity_floor.py` and `scripts/dev_tools/resolve_delegation_model.py`, each with a full test file at `tests/scripts/dev_tools/test_compute_complexity_floor.py` / `test_resolve_delegation_model.py`, referenced by name from `.claude/skills/orchestrate/SKILL.md` (new "## Model Selection" section) as the canonical formula.

## 3. Validator wiring — `validate_orchestrator_state.py` / `_orchestrator_state_routing.py` / `validate_orchestration_artifacts.py`

**Message style**: every validator function returns `list[str]`, never raises for validation failures, and appends literal, checkpoint-context-prefixed strings, e.g. `f"Checkpoint remediation cycle #{index} plan_path must be a non-empty string."` or `f"Checkpoint human_interaction.requirements #{index} response must be one of scope_change, exception, halt; got: {response}"`. No exceptions are raised for malformed *content*; only structurally required top-level keys and JSON parse failures raise/short-circuit early.

**Smallest reusable unit — `_orchestrator_state_human_interaction.py`** (128 lines) is the closest existing precedent for an *additive, optional* checkpoint block and should be mirrored exactly for the two new validators:
- Module-level constants: `HUMAN_INTERACTION_KEY = "human_interaction"`, an enum set, and a nested-field key constant.
- `__all__` list explicitly re-exporting the constants and the `_validate_human_interaction` helper (this repo's convention for marking a "private-looking" `_`-prefixed helper as a deliberate cross-module re-export, avoiding false "unused/private" lint flags).
- One function `_validate_<name>(value: object) -> list[str]`, called **only when the caller has already confirmed the key is present** (docstring: "Callers invoke this helper only when the key is present, so a non-object value is itself a malformed block."). Returns one error string per violated invariant, short-circuiting only where a further check is meaningless (e.g., no `requirements` list means no per-item checks can run).

**Wiring into `validate_orchestrator_state.py`** (`scripts/dev_tools/validate_orchestrator_state.py`, 485 lines): the exact 3-line pattern to replicate for `complexity_assessments` and `model_routing_receipts`:

```python
from scripts.dev_tools._orchestrator_state_human_interaction import (
    HUMAN_INTERACTION_KEY,
    _validate_human_interaction,
)
...
# Apply the additive human_interaction invariants only when the checkpoint
# carries a human_interaction key; absent the key, behavior is unchanged.
if HUMAN_INTERACTION_KEY in state_map:
    errors.extend(_validate_human_interaction(state_map.get(HUMAN_INTERACTION_KEY)))
```

This block sits inside `validate_orchestrator_state_text(...)` (lines 442-445 currently), alongside the equivalent `REMEDIATION_LOOP_KEY` block (lines 439-440) for `remediation_loop`/`cycles[]`. Two new blocks of the same shape — gated on `"complexity_assessments" in state_map` and `"model_routing_receipts" in state_map` respectively — are the correct insertion point, each importing its own new `_orchestrator_state_<name>.py` module. This preserves the file's existing backward-compatibility guarantee: a checkpoint without either key validates unchanged.

**`validate_orchestration_artifacts.py`** (273 lines) is the **stable CLI/dispatch entrypoint**, not where per-field logic lives. It only:
1. Imports `validate_orchestrator_state_text` (and the epic/review/policy-audit equivalents) — no code change needed here for additive checkpoint fields, since `validate_orchestrator_state_text` already owns the full checkpoint contract and the two new validators plug in underneath it.
2. `_validate_from_args()` dispatches on `args.artifact_type` (`plan | policy-audit | code-review | feature-audit | orchestrator-state | epic-orchestrator-state`) — there is **no new `artifact_type` needed** for complexity/model-routing receipts, because they live *inside* the existing `orchestrator-state` artifact, not as a standalone artifact type.

**Conclusion**: the two new validators are two new small modules (`_orchestrator_state_complexity.py`, `_orchestrator_state_model_routing.py` — following the existing `_orchestrator_state_<topic>.py` naming convention used by `_orchestrator_state_human_interaction.py`, `_orchestrator_state_pr_creation_readiness.py`, `_orchestrator_state_routing.py`), each exporting a `<TOPIC>_KEY` constant and a `_validate_<topic>` function, imported and gated in `validate_orchestrator_state.py` exactly like `human_interaction`. No change to `validate_orchestration_artifacts.py`'s CLI surface is required.

## 4. Checkpoint schema/validator — backward compatibility mechanism

There is no schema file (confirmed in §1); backward compatibility is achieved entirely by the **"gate on key presence" pattern** used uniformly across `validate_orchestrator_state.py`:

- `REQUIRED_STATE_KEYS` (lines 43-66) is the only *mandatory* top-level key list, and it is unchanged by this feature — `complexity_assessments`, `model_routing_receipts`, and `model_budget` must **not** be added to it.
- Every additive block (`remediation_loop`, `human_interaction`) is checked with `if <KEY> in state_map:` before its validator runs; an absent key contributes zero errors. The docstring of `validate_orchestrator_state_text` documents this explicitly per parameter (e.g., `require_pr_creation_ready` "independent of `require_complete`").
- `.claude/rules/orchestrator-state.md` documents each additive block's "Scope and Backward Compatibility" as its own subsection ("These invariants apply only when the checkpoint contains a top-level X... A checkpoint with no X... is unaffected... The invariants are additive."). The same two-paragraph structure (scope statement + enforcement statement) should be added for `complexity_assessments[]` and `model_routing_receipts[]` in that same rule file (or a sibling rule file, per spec decision), mirroring the existing "Invariants (per remediation cycle)" / "Invariants (human_interaction block)" sections.

This confirms the mechanism proposed in the issue ("all new fields are additive and optional; existing routes and checkpoints validate unchanged") maps directly onto an existing, already-tested pattern; no new backward-compatibility machinery needs to be invented.

**Important cross-cutting finding — MCP tool is a TypeScript port, not the Python CLI**: The `mcp__drm-copilot__validate_orchestration_artifacts` MCP tool that `orchestrator.md`/`epic-orchestrator.md` actually call at runtime is implemented **in TypeScript**, independently of `scripts/dev_tools/validate_orchestration_artifacts.py`. Trace: `extensions/drm-copilot/src/mcp-tools.ts` (`case "validate_orchestration_artifacts"`) → `extensions/drm-copilot/src/mcp-handlers/template-validation-handlers.ts::handleValidateOrchestrationArtifacts` → `RepoAutomationService.validateOrchestrationArtifacts` → `extensions/drm-copilot/src/lib/validate/validate-orchestration-service-call.ts` → `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`, which imports `validateOrchestratorStateText` from `orchestrator-state-core.ts` — a full independent TypeScript reimplementation (routing logic already ported at `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts`, verified to mirror `_orchestrator_state_routing.py` function-for-function with identical error strings). This TypeScript layer has its own `human_interaction`/`remediation` ports (`orchestrator-state-human-interaction.ts`, `orchestrator-state-remediation.ts`) alongside the Python modules.

This feature's own `issue.md`/`spec.md` scope explicitly limits touched languages to "JSON, Markdown, Python (reference impls/validators/tests), and PowerShell (bundle-sync contract tests)" — **no TypeScript**. This means: if only the Python validators are added, the **live MCP tool the orchestrator actually invokes will not enforce the new `complexity_assessments[]`/`model_routing_receipts[]` invariants**, even though `pytest` against the Python CLI will pass. This is a real scope gap, not a research artifact of this document; it must be resolved explicitly by the spec/planning phase (either: (a) accept that these two new validators are pytest/CI-only enforcement — not enforced through the live MCP call path — and document that limitation, or (b) add the TypeScript port as in-scope work, which would touch `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` plus two new `.ts` modules plus Vitest tests, expanding the stated language scope). Flagging this explicitly rather than silently assuming Python-only enforcement is sufficient.

## 5. Python toolchain and test layout

Confirmed from `pyproject.toml` (repo root) and `.claude/rules/python.md`:

- **Format**: `poetry run black .` (`[tool.black]` `line-length = 88`, `target-version = ["py310"]`).
- **Lint**: `poetry run ruff check .` (`[tool.ruff]` `line-length = 88`, `target-version = "py310"`, `fix = true`; `[tool.ruff.lint] select = ["E","F","I","B","UP","S","TID","TCH"]`; `tests/**/*` is exempted from `S101` (assert-use) via `[tool.ruff.lint.per-file-ignores]`).
- **Type check**: `poetry run pyright` (`[tool.pyright] typeCheckingMode = "strict"`, `pythonVersion = "3.12"`, includes `scripts`, `src`, `tests`).
- **Test**: `poetry run pytest --cov --cov-branch --cov-report=term-missing` (`[tool.pytest.ini_options] testpaths = ["tests"]`, `addopts` already emits `--cov-report=lcov:artifacts/python/lcov.info`; `[tool.coverage.run] source = ["src", "scripts/dev_tools"]`, `data_file = "artifacts/.coverage"`, standard `omit`/`exclude_lines` bands).
- Run order is format → lint → type-check → test, restart from the top on any failure or auto-fix, per `.claude/rules/general-code-change.md` and `.claude/rules/python.md`.

**Test layout convention** (mirrors production 1:1): `scripts/dev_tools/<module>.py` → `tests/scripts/dev_tools/test_<module>.py`. Verified concretely:
- `scripts/dev_tools/epic_wave_computation.py` → `tests/scripts/dev_tools/test_epic_wave_computation.py`.
- `scripts/dev_tools/validate_orchestrator_state.py` → `tests/scripts/dev_tools/test_validate_orchestrator_state.py`, plus **topic-scoped sibling test files** for each additive block: `test_validate_orchestrator_state_human_interaction.py`, `test_validate_orchestrator_state_remediation_loop.py`, `test_validate_orchestrator_state_routing_contract.py`, `test_validate_orchestrator_state_pr_creation_readiness.py`. This is the pattern to follow for the two new validators: `tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py` and `tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing.py` (exact names subject to spec's chosen module names), rather than cramming new cases into the existing top-level test file.
- `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` shows the convention for building a synthetic checkpoint: pull `required_agents`/`required_skills`/`required_mcp_tools` live from `load_routing_matrix()` (not hardcoded), so the test tracks the routing matrix automatically — the new tests for `complexity_assessments`/`model_routing_receipts` should similarly load `model_policy` from the same matrix rather than hardcoding the table.

**Coverage**: per `.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md`, thresholds are **uniform across tiers**: line coverage ≥ 85%, branch coverage ≥ 75%, and "no regression on changed lines" is itself a uniform gate — there is no tier-specific lower floor. Note: `quality-tiers.yml` is referenced by `.claude/rules/quality-tiers.md` and `.claude/rules/general-code-change.md` as the repo-root source of truth mapping every project to a tier, but **no such file exists in this repository** (`Glob quality-tiers.yml` — no matches). This is a pre-existing repo gap, not something introduced by this feature; note it for awareness but it is out of this feature's scope to fix.

## 6. Agent definition frontmatter schema

Read `pr-author.md`, `task-researcher.md`, `feature-review.md`, `atomic-planner.md`, `orchestrator.md`, plus a grep of every `.claude/agents/*.md` frontmatter block. Observed schema (YAML frontmatter, `---`-delimited, followed by an H1 + Markdown body):

| Key | Cardinality | Observed values / shape |
|---|---|---|
| `name` | required, every agent | kebab-case, matches filename stem |
| `description` | required, every agent | one-paragraph capability summary; pr-author's is long and cites exact write paths and hook names |
| `tools` | required, every agent (list) | mixture of bare tool names (`Read`, `Grep`, `Glob`, `Write`, `Edit`) and scoped patterns: `"Bash(git log *)"`, `"Bash(git rev-parse *)"`, `"Bash(gh pr create *)"`, `"Write(/artifacts/**)"`, `"Write(/docs/features/**/research/**)"`, `"Agent(name1,name2,...)"` (comma-joined, no spaces, only on `orchestrator.md`), `"mcp__drm-copilot__<tool_name>"` (literal or `.*` wildcard) |
| `model` | **optional**, only 2 of 15 agent files set it | `task-researcher.md: model: sonnet`; `pr-author.md: model: sonnet`. No agent file currently uses `haiku`, `opus`, or `fable`. Every other agent (`atomic-planner`, `atomic-executor`, `feature-review`, `orchestrator`, `prd-feature`, `epic-orchestrator`, `staged-review`, `epic-review`, `status-updater`, the four `*-typed-engineer`/`typescript-engineer` files) has **no `model:` key at all**, i.e., relies on whatever default Claude Code applies. `.claude/settings.json` has no top-level `model` key either (only `"agent": "orchestrator"`). |
| `skills` | optional (list) | e.g. `feature-review.md: skills: [policy-compliance-order, acceptance-criteria-tracking]`; `pr-author.md: skills: [pr-author]`. **Anomaly**: `task-researcher.md` has **no separate `skills:` key** — instead it lists `evidence-and-timestamp-conventions` as an entry inside `tools:`. This is inconsistent with the `pr-author.md`/`feature-review.md` convention; new agents should follow the `pr-author.md` pattern (dedicated `skills:` list), not the `task-researcher.md` anomaly. |
| `memory` | required, every agent | literal `project` in every observed file (no other value seen) |
| `hooks` | optional | `SubagentStop` block with `matcher: "<agent-name>"` and one or more `hooks: [{type: command, command: "pwsh -NoProfile -File .claude/hooks/<validate-name>.ps1"}]` entries. Every agent with a hook has exactly one matcher keyed to its own name (except `orchestrator`/`epic-orchestrator`, which share `validate-orchestrator-output.ps1` via a `-CheckpointPath`/`-ArtifactType` parameterization, per `.claude/settings.json` lines 198-215). |
| `argument-hint` | SKILL.md only, not agents | seen on `orchestrate`/`epic-orchestrate` SKILL.md frontmatter, not on any agent file |
| `allowed-tools` | SKILL.md only, not agents | `commit-message/SKILL.md` uses `allowed-tools:` (not `tools:`) — this is the **skill** frontmatter key name, distinct from the **agent** frontmatter key name `tools:`. When authoring `.claude/agents/commit-message.md`, use `tools:` (agent convention), reusing the exact same three entries already declared in the skill (`Read`, `"Bash(git log *)"`, `"Bash(git diff *)"`). |

**Exact model values requested by the handoff (`haiku`, `opus`, `fable`) have zero precedent anywhere in the current `.claude/agents/*.md` corpus.** This is the first feature to introduce non-`sonnet` model tiers into agent frontmatter. There is nothing to contradict the handoff's assumption that `model:` accepts these literal strings, but there is also no existing agent proving Claude Code accepts `opus`/`haiku`/`fable` as valid frontmatter values — this is a runtime-acceptance risk worth a smoke check during implementation (create the agent file, confirm Claude Code does not reject the frontmatter), not something this repo's text corpus can independently verify.

**`commit-message` and `human-exception-runbook` SKILL.md files already exist** (`.claude/skills/commit-message/SKILL.md`, `.claude/skills/human-exception-runbook/SKILL.md`, each already bundled byte-for-byte at `extensions/drm-copilot/resources/claude-customizations/.claude/skills/<name>/SKILL.md`, confirmed present). No new skill content needs to be authored; only two new **agent** wrapper files need to be created, following the `pr-author.md` shape:

```
---
name: commit-message
description: <capability summary — read-only, generates commit message text from staged diff, does not commit>
model: haiku
skills:
  - commit-message
memory: project
tools:
  - Read
  - "Bash(git log *)"
  - "Bash(git diff *)"
---
```

```
---
name: human-exception-runbook
description: <capability summary — authors a runbook at <FEATURE>/runbooks/<name>.runbook.md per the human-exception-runbook skill contract, MCP-first/web-second sourcing>
model: sonnet
skills:
  - human-exception-runbook
memory: project
tools:
  - Read
  - Grep
  - Glob
  - WebFetch
  - "Write(<FEATURE>/runbooks/**)"
  - <MCP documentation tool name(s) — none currently exist in this repo; no `mcp__*learn*`/`mcp__*docs*` tool was found in a repo-wide grep, so an MCP-first source is not yet wired as a callable tool. WebFetch is the only currently available "web-second" tool. This is a gap the spec/plan must resolve explicitly: either name a specific MCP documentation tool to add as a dependency, or document that until such a tool exists, the sourcing rule's "MCP-first" clause is aspirational and WebFetch is the sole available mechanism.>
---
```

## 7. Bundle-sync mechanism — mirror locations and contract tests

Two independent bundle trees, each with byte-identical parity enforced by a dedicated pytest contract test:

**A. `.claude/` → `extensions/drm-copilot/resources/claude-customizations/.claude/`** (Claude Code runtime mirror).
- Contract test: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
- `test_bundled_claude_payload_contains_all_repo_runtime_contracts()` enumerates **every file** under repo-root `.claude/**` (excluding `.claude/settings.local.json` and the `.claude/agent-memory/**` subtree, which is distributed by content-scope filter, not byte mirror) and asserts each exists **and is byte-identical** in the bundle. This means:
  - New file `.claude/agents/commit-message.md` → must be copied verbatim to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/commit-message.md`.
  - New file `.claude/agents/human-exception-runbook.md` → must be copied verbatim to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/human-exception-runbook.md`.
  - Edited `.claude/skills/orchestrate/SKILL.md` → must be re-copied verbatim to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`.
  - Edited `.claude/skills/epic-orchestrate/SKILL.md` → must be re-copied verbatim to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`.
  - Edited `.claude/agents/orchestrator.md` (adding the two new agent names to its `Agent(...)` tool pattern and, if applicable, a `## Model Selection` section) → must be re-copied verbatim to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`.
  - Edited `.claude/settings.json` (new `Agent(commit-message)` / `Agent(human-exception-runbook)` permission entries) → must be re-copied verbatim to `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` (this file is in the required-anchor list `REQUIRED_BUNDLED_FILES` and is fully enumerated by the all-files parity check).
  - New/edited `.claude/rules/*.md` files (if the spec adds a dedicated model-policy rule file) → same mirror requirement.
- `test_bundled_claude_payload_excludes_settings_local_json` and the variant-subtree tests are unaffected by this feature (no `.claude-variants` interaction expected for these two agents, unless a C#-legacy variant equivalent is deemed necessary, which nothing in the handoff suggests).

**B. `.codex/` + `.agents/` → `extensions/drm-copilot/resources/codex-and-agents-customizations/`** (Codex/OpenAI-agents runtime mirror).
- Contract test: `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, plus content-parity regression tests in `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py` (the latter `pytest.mark.skipif`s when `.codex/agents` does not exist locally, since `.codex/` is repo-root-gitignored; the **bundled** copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml` is committed and is what ships).
- `orchestrator.toml`, `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrator-workflow/SKILL.md` all exist in this bundle tree as **Codex-native re-expressions** of the same orchestrator/orchestrate content (not byte-identical to the `.claude` Markdown source — they are TOML/Codex-flavored translations maintained by the `translate-claude-to-codex` skill, per `.agents/skills/translate-claude-to-codex/SKILL.md`). This means editing `.claude/agents/orchestrator.md` and `.claude/skills/orchestrate/SKILL.md` for issue #286 also requires a **content-equivalent** (not byte-identical) update to `.codex/agents/orchestrator.toml` and `.agents/skills/orchestrate/SKILL.md` (bundled at `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml` and `.../.agents/skills/orchestrate/SKILL.md`), verified by the fragment-presence assertions in `test_codex_agent_wrapper_contracts.py` (e.g. `test_orchestrator_wrapper_preserves_codex_mandatory_delegation_contract`).
- There is **no existing `.codex`/`.agents` counterpart named `commit-message`/`human-exception-runbook`** yet (repo-wide glob under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/` shows `commit-message/SKILL.md` and `human-exception-runbook/SKILL.md` **already exist** as skill mirrors — see full listing captured during research — but there is **no** `.codex/agents/commit-message.toml` or `.codex/agents/human-exception-runbook.toml` agent-wrapper file). This feature's `issue.md`/`spec.md` scope statement ("Touches JSON, Markdown, Python..., and PowerShell...") does not mention `.codex`/`.agents`/TOML changes; the same scope-gap caveat as §4 applies here: either accept that the Codex ecosystem does not gain equivalent agent-routing for these two skills in this feature (documented limitation), or add `.codex/agents/*.toml` wrapper authoring to the plan.

**C. Bundle-sync Pester test**: `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` — this test governs `AGENTS.md`/Copilot-instruction synchronization (a **different** mechanism: it regenerates `AGENTS.md` from `.github/copilot-instructions.md` + `.github/instructions/*.instructions.md`, and separately asserts the bundled template `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1` matches the repo-root script `scripts/dev-tools/sync-agents-from-instructions.ps1` byte-for-byte). This Pester file is **not** the mechanism that enforces `.claude/agents/*.md` parity (that is the Python pytest contracts in §7A/§7B). It is unaffected by this feature unless the two new agents also need `AGENTS.md`/Copilot-instruction representation, which the handoff does not request.

**Summary list of concrete mirror paths requiring updates for this feature:**
1. `extensions/drm-copilot/resources/claude-customizations/.claude/agents/commit-message.md` (new)
2. `extensions/drm-copilot/resources/claude-customizations/.claude/agents/human-exception-runbook.md` (new)
3. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` (edit, byte-identical)
4. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` (edit, byte-identical)
5. `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md` (edit, byte-identical)
6. `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` (edit, byte-identical, if permissions.allow changes)
7. `extensions/drm-copilot/resources/config/orchestration-routing.json` (edit, byte-identical, per §1/§10)
8. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/*.md` (new/edit, byte-identical, if a dedicated model-policy rule file is added)
9. Codex-ecosystem equivalents for items 3/5 (content-equivalent, not byte-identical) — `.codex/agents/orchestrator.toml` and `.agents/skills/orchestrate/SKILL.md` under `extensions/drm-copilot/resources/codex-and-agents-customizations/` — **conditionally required**, pending the spec's explicit scope decision (see the caveat above).

## 8. PowerShell toolchain and bundle-sync Pester location

Confirmed from `.claude/rules/powershell.md`:
- **Format**: PoshQC via MCP `mcp__drm-copilot__run_poshqc_format` (wraps `Invoke-Formatter`).
- **Lint**: PoshQC analyzer via `mcp__drm-copilot__run_poshqc_analyze` (PSScriptAnalyzer with repo settings); optional autofix `mcp__drm-copilot__run_poshqc_analyze_autofix`.
- **No type-check stage** for PowerShell (skipped by design).
- **Test**: Pester v5.x via `mcp__drm-copilot__run_poshqc_test`, config at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.
- Order: format → analyze → test; restart on any failure/auto-fix, per the same rule file.

**Bundle-sync Pester tests relevant to this feature** are the two contract suites already inventoried in §7:
- `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` (AGENTS.md generation + bundled-template parity — see §7C; likely **not** touched by this feature unless AGENTS.md needs new content).
- No dedicated Pester test was found that specifically asserts `.claude/agents/*.md` parity (that enforcement is Python/pytest, per §7A). If the plan intends "Pester bundle-sync contract tests for the two new agent files" (per the issue's "Test Conditions to Consider"), the two existing **pytest** contracts (`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`) already provide this coverage generically (they enumerate the whole tree, so a new file added to `.claude/agents/` is automatically covered without any test-file edit). A **new** Pester-specific test would only be needed if the plan chooses to add Pester-level assertions distinct from the existing pytest contracts; nothing in the current repo requires duplicating that coverage in Pester. This should be called out precisely in planning so effort is not spent re-implementing existing pytest coverage in PowerShell.

## 9. `orchestrate`/`epic-orchestrate` SKILL.md — insertion points

**`.claude/skills/orchestrate/SKILL.md`** (309 lines). Confirmed exact locations:
- **Delegation Model** section (lines 57-66) lists the four current delegates (`atomic-planner`, `atomic-executor`, `feature-review`, `task-researcher`). This is the natural location to add the two new agents to the delegate roster, and the natural anchor immediately **after** which to insert a new `## Model Selection` section (i.e., insert between the existing `## Delegation Model` (ends line 66) and `## PR Authoring (pr-author Handoff)` (starts line 68)), since Model Selection is a property of how delegation happens for every one of these delegates, not just PR authoring.
- **Exception-runbook requirement** (lines 45-47, inside `## Autonomous-Execution Mandate` → `### Exception-runbook requirement`): currently states "the orchestrator emits a human-readable runbook at `<FEATURE>/runbooks/<name>.runbook.md`" — this sentence must change from "the orchestrator emits" to "the orchestrator delegates runbook authoring to `Agent(human-exception-runbook)`, which emits the runbook... the orchestrator records the returned `runbook_path`", per the acceptance criterion "runbook authoring is delegated while the orchestrator still records `runbook_path`."
- **Pre-Feature-Review Commit** section (lines 110-119), step 2: `"Invoke the `commit-message` skill to generate a conventional commit message from the staged diff."` — must change to delegate to `Agent(commit-message)` instead of invoking the skill inline, while step 3 (`git commit -m "<generated message>"`) **stays on the orchestrator**, per the acceptance criterion "the two commit steps delegate message text while the commit stays on the orchestrator."
- **Pre-R4 commit** bullet (line 136, inside `## Remediation Loop (R1–R5)`): identical pattern — `"invoke the `commit-message` skill to generate a commit message from the staged diff, commit with the generated message"` — same split applies: delegate message generation, keep `git commit` on the orchestrator.
- These are the **only two commit points** in the file (`git commit` appears exactly twice, both already located above); confirmed via a full read of the file (no other `git commit` occurrence).

**`.claude/skills/epic-orchestrate/SKILL.md`** (~230 lines, section headings enumerated). No existing references to `commit-message`, `human-exception-runbook`, `model_budget`, `fable_policy`, or `complexity_band` (confirmed via targeted grep — zero matches). The child-feature delegation flow in this file always routes through `Agent(orchestrator, ...)` per child feature (`## Epic Integration Branch Lifecycle` step 3), so the two commit points and the exception-runbook path are inherited from `orchestrate/SKILL.md` unmodified inside each child's own orchestrator instance — no separate commit-point edit is needed inside `epic-orchestrate/SKILL.md` itself.

**Model Selection section placement in `epic-orchestrate/SKILL.md`**: the handoff's "session `model_budget.fable_policy` kickoff marker line contract" should mirror the existing, already-established kickoff-line pattern demonstrated by `## Merge-on-Green Kickoff Parameter` (lines 94-106): a literal blockquoted marker string appended to the delegation prompt when `epic-orchestrator` kicks off `Agent(orchestrator)` for a child feature, e.g. following the existing `Epic mode: true. epic_feature_folder: ...` line with a sibling `model_budget.fable_policy: <disabled|available|preferred>.` marker. The best insertion point is a **new `## Model Selection` section placed immediately after `## Merge-on-Green Kickoff Parameter` (ends line 106) and before `## Context Handoff to Dependent Features` (starts line 107)**, since that is exactly where the file already documents "what literal line gets appended to the child's kickoff prompt." An alternative, weaker placement is after `## Epic-Level Checkpoint` (ends line 221) if the spec prefers to treat this purely as a checkpoint-schema extension rather than a kickoff-prompt concern — the former is recommended because the handoff explicitly calls out a "kickoff marker line contract," which is a prompt-construction concern, matching the existing section's own framing.

## 10. Is `config/orchestration-routing.json` mirrored/bundled? Bundle-sync coverage?

Yes — confirmed and already detailed in §1/§7. `extensions/drm-copilot/resources/config/orchestration-routing.json` is the bundled mirror, and `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py::test_canonical_and_bundled_routing_config_are_byte_identical` is the dedicated byte-identity contract test for this specific file (separate from, and narrower than, the whole-tree `.claude/**` parity tests in §7, since `config/` is a sibling of `.claude/`, not inside it). Any edit adding `model_policy`/`model_budget` must update both copies in the same change or this test fails immediately.

## Rejected alternatives

- **Adding a new JSON Schema file for `orchestration-routing.json`** was considered as a way to formally govern the new `model_policy` shape, but rejected as unnecessary scope: no schema file exists today for this config (§1), the repo's established pattern for checkpoint/config contracts is prose-plus-validator-code (§3/§4), and `.claude/rules/orchestrator-state.md` explicitly warns against introducing an imported/foreign schema file as the enforcement mechanism. Recommendation: continue the existing prose+validator pattern; do not introduce a schema file.
- **Wiring the two new validators as a new `artifact_type` in `validate_orchestration_artifacts.py`** was considered and rejected: `complexity_assessments[]`/`model_routing_receipts[]` are sub-fields of the existing `orchestrator-state` artifact, not a new artifact kind, so they belong inside `validate_orchestrator_state_text` via the additive-key-gate pattern (§3), matching `remediation_loop`/`human_interaction`.
- **A single combined `_orchestrator_state_model_policy.py` module** covering both complexity assessments and model-routing receipts was considered, but the existing convention favors one focused module per checkpoint sub-block (`_orchestrator_state_human_interaction.py`, `_orchestrator_state_pr_creation_readiness.py`, `_orchestrator_state_routing.py` are each single-topic). Recommendation: two separate modules, `_orchestrator_state_complexity.py` and `_orchestrator_state_model_routing.py`, matching the two named receipt arrays.

## Automation Feasibility

This research does not touch any third-party UI (no Azure portal, Entra, Outlook, or Microsoft 365 admin center surface is involved anywhere in this feature). All work items identified — JSON config edits, two Python reference-implementation modules, two Python validator modules, `pytest` coverage, `.claude/agents/*.md` authoring, `.claude/skills/*/SKILL.md` edits, and the bundle-mirror copies enumerated in §7 — are fully automatable within the repository's existing toolchain (Black/Ruff/Pyright/Pytest, PoshQC/Pester, and the existing pytest bundle-sync contract tests). No human-interaction requirement is present in this feature's scope, so the autonomous-execution mandate's "Automation Feasibility" applicability condition is satisfied by "not applicable," and no human-exception runbook is required for the implementation of this feature itself (the feature's *subject matter* is a runbook-authoring agent, but authoring that agent is itself fully automatable).
