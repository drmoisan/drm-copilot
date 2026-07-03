# two-axis-model-selection - Plan

- **Issue:** #286
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-03T16-19
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature

## Required References

- `.claude/rules/general-code-change.md` (cross-language code change policy)
- `.claude/rules/general-unit-test.md` (cross-language unit test policy)
- `.claude/rules/python.md`, `.claude/rules/python-suppressions.md` (Python toolchain)
- `.claude/rules/powershell.md` (PowerShell toolchain)
- `.claude/rules/orchestrator-state.md` (checkpoint invariant prose precedent)
- `.claude/rules/quality-tiers.md` (coverage thresholds: line >= 85%, branch >= 75%)

**All work must comply with these policies; do not duplicate their content here.**

## Scope Boundaries (from spec DD-1 / Out of Scope)

- No TypeScript/Vitest work. Do NOT modify `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` or `orchestrator-state-core.ts`. The TypeScript MCP-port parity gap is a documented follow-up (RISK), out of scope.
- No JSON Schema file for the routing config or checkpoint (DD-2).
- All new fields are additive and optional; existing routes and checkpoints must validate unchanged.
- Repo-root `.claude/` and `config/` are source of truth; bundled mirrors under `extensions/drm-copilot/resources/**` are updated in lockstep in the same phase as each runtime edit.

## Evidence Locations (canonical, non-overridable)

- Baseline: `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/baseline/`
- QA gates: `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/qa-gates/`
- Regression: `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/regression-testing/`
- Other: `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/other/`

Python toolchain per touched-file task (restart-on-fix loop): `poetry run black <files>` -> `poetry run ruff check <files>` -> `poetry run pyright` -> `poetry run pytest <test files> --cov --cov-branch --cov-report=term-missing`.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture & Policy Reads

- [x] [P0-T1] Read policy files in required order (`CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/powershell.md`, `.claude/rules/orchestrator-state.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`) and write `evidence/baseline/phase0-instructions-read.md`.
  - Acceptance: artifact contains `Timestamp:`, `Policy Order:`, and the explicit list of files read.
- [x] [P0-T2] Capture Python static-toolchain baseline by running `poetry run black --check .`, `poetry run ruff check .`, `poetry run pyright`; write `evidence/baseline/python-static-baseline.md`.
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each command.
- [x] [P0-T3] Capture Python test/coverage baseline by running `poetry run pytest --cov --cov-branch --cov-report=term-missing`; write `evidence/baseline/python-pytest-baseline.md`.
  - Acceptance: `Output Summary:` records numeric total line and branch coverage percentages plus pass/fail counts.
- [x] [P0-T4] Capture bundle-sync parity baseline by running `poetry run pytest tests/scripts/dev_tools/test_orchestration_routing_config_parity.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`; write `evidence/baseline/bundle-sync-parity-baseline.md`.
  - Acceptance: artifact records `Command:`, `EXIT_CODE:`, `Output Summary:` (baseline green state).
- [x] [P0-T5] Capture PowerShell Pester bundle-sync baseline via `mcp__drm-copilot__run_poshqc_test` for `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`; write `evidence/baseline/powershell-pester-baseline.md`.
  - Acceptance: artifact records `Command:`, `EXIT_CODE:`, `Output Summary:`. Note: no `.ps1` source files are edited by this feature; this run establishes the pre-change green state only.

### Phase 1 — Python Reference Implementations

- [x] [P1-T1] Create `scripts/dev_tools/compute_complexity_floor.py` mirroring the `epic_wave_computation.py` shape (module docstring with `Purpose`/`Responsibilities`/`Usage`; `from __future__ import annotations`; `TYPE_CHECKING`-gated `collections.abc` imports; a `Literal["C1","C2","C3","C4"]` band alias; one pure typed function `compute_complexity_floor(signals_present: Sequence[str]) -> str`; no I/O; `Side Effects: None. This function is pure.`).
  - Acceptance: each `[floor]` signal contributes candidate `C3`; `floor` is the max triggered band; floors never exceed `C3`; no floor signals present yields `C1`; C4 is never returned. File <= 500 lines.
- [x] [P1-T2] Create `tests/scripts/dev_tools/test_compute_complexity_floor.py` covering: each floor guard contributes `C3`; max-of-multiple floor signals; no-signal `C1` case; never-exceed-`C3` invariant; determinism (identical `signals_present` yields identical output across repeated calls and across input ordering).
  - Acceptance: tests load the `[floor]` signal catalog from `load_routing_matrix()["model_policy"]` rather than hardcoding the signal names (deferred assertions permitted until Phase 2 lands the config; if run before Phase 2, tests use a local fixture and are re-pointed at the matrix in P2-T5).
- [x] [P1-T3] Run the Python toolchain on the two Phase 1 complexity-floor files (`poetry run black`, `ruff check`, `pyright`, `pytest tests/scripts/dev_tools/test_compute_complexity_floor.py --cov=scripts/dev_tools/compute_complexity_floor --cov-branch --cov-report=term-missing`); restart on any fix.
  - Acceptance: all four stages pass in a single pass; changed-file line coverage >= 85%, branch >= 75%.
- [x] [P1-T4] Create `scripts/dev_tools/resolve_delegation_model.py` implementing `resolve_delegation_model(agent: str, band: str, fable_policy: str) -> dict[str, str | None]` per the Model Selection Contract: overlay value when (`fable_policy == "preferred"` and `agent` in overlay set and `band == "C3"`) else base `complexity_to_model[band]`; `disabled` clamps a `fable` `table_model` to `model="opus"`, `clamped_from="fable"`, `clamp_reason="fable_disabled"`; otherwise `model=table_model`, `clamped_from=None`. Pure, deterministic, no I/O.
  - Acceptance: returns both `table_model` (pre-clamp) and `model` (post-clamp); overlay set is exactly `{atomic-planner, prd-feature, feature-review, task-researcher}`; `atomic-executor`/`pr-author` C3 stays `opus` under every policy. File <= 500 lines.
- [x] [P1-T5] Create `tests/scripts/dev_tools/test_resolve_delegation_model.py` covering: base table per band (C1->haiku, C2->sonnet, C3->opus, C4->fable); `available` leaves `fable` cells intact; `disabled` clamps every `fable` cell to `opus` with `clamped_from="fable"`; `preferred` resolves C3 to `fable` for the four overlay agents and leaves `atomic-executor`/`pr-author` C3 at `opus`; determinism across repeated calls.
  - Acceptance: table values are read from `load_routing_matrix()["model_policy"]`, not hardcoded (subject to same Phase 2 sequencing note as P1-T2).
- [x] [P1-T6] Run the Python toolchain on the two Phase 1 resolve-model files (`black`, `ruff check`, `pyright`, `pytest tests/scripts/dev_tools/test_resolve_delegation_model.py --cov=scripts/dev_tools/resolve_delegation_model --cov-branch --cov-report=term-missing`); restart on any fix.
  - Acceptance: all four stages pass in a single pass; changed-file line coverage >= 85%, branch >= 75%.
- [x] [P1-T7] Verify determinism and floor invariants explicitly: assert both reference implementations produce identical output for identical inputs (property/repeat-call test present) and that no test path allows `compute_complexity_floor` to return `C4` (C4 never floor-forced; band assessment is judgment-only). Write `evidence/regression-testing/determinism-and-floor-invariants.md`.
  - Acceptance: artifact records the specific test names asserting determinism, `band >= floor` lower-bound ordering (validator-level, cross-referenced to P3), and the never-exceed-`C3` invariant, with `Command:`/`EXIT_CODE:`/`Output Summary:`.

### Phase 2 — Config Additions (`model_policy`, `model_budget`)

- [x] [P2-T1] Add the `model_policy` block to `config/orchestration-routing.json` (`tier_order` = `["haiku","sonnet","opus","fable"]`; `complexity` sub-block with scale text, a signal catalog carrying `[floor]` flags and anchors; `complexity_to_model` table `{C1:haiku,C2:sonnet,C3:opus,C4:fable}`; `preferred_overlay` scoped to the four overlay agents changing only the C3 cell to `fable`). Additive top-level key; `routes` unchanged.
  - Acceptance: JSON parses; existing `routes` bytes are unmodified except for the additive key insertion; tone-policy compliant text.
- [x] [P2-T2] Add the session `model_budget` block with `fable_policy` defaulting to `disabled` (three-way enum `disabled|available|preferred`) to `config/orchestration-routing.json`.
  - Acceptance: `model_budget.fable_policy == "disabled"` by default; additive top-level key.
- [x] [P2-T3] Mirror the edited `config/orchestration-routing.json` byte-for-byte to `extensions/drm-copilot/resources/config/orchestration-routing.json`.
  - Acceptance: `config/orchestration-routing.json` and the bundled copy are byte-identical.
- [x] [P2-T4] Run the config parity contract `poetry run pytest tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` (asserts `test_canonical_and_bundled_routing_config_are_byte_identical`); write `evidence/qa-gates/config-parity.md`.
  - Acceptance: test passes; `EXIT_CODE: 0`.
- [x] [P2-T5] Re-point the Phase 1 tests (P1-T2, P1-T5) at `load_routing_matrix()["model_policy"]` now that the config exists, and rerun `poetry run pytest tests/scripts/dev_tools/test_compute_complexity_floor.py tests/scripts/dev_tools/test_resolve_delegation_model.py --cov --cov-branch`.
  - Acceptance: tests read signal catalog and table from the live matrix; all pass.

### Phase 3 — Validator Modules & Wiring

- [x] [P3-T1] Create `scripts/dev_tools/_orchestrator_state_complexity.py` mirroring `_orchestrator_state_human_interaction.py` (module-level `COMPLEXITY_ASSESSMENTS_KEY = "complexity_assessments"`; `__all__` re-exporting the key and `_validate_complexity_assessments`; one function `_validate_complexity_assessments(value: object) -> list[str]` returning literal, checkpoint-context-prefixed error strings, never raising).
  - Acceptance: checks `band` in `{C1,C2,C3,C4}`; `band >= floor`; `floor == compute_complexity_floor(signals_present)`; `rationale` is a non-empty string; never judges band merit. File <= 500 lines.
- [x] [P3-T2] Create `tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py` covering: well-formed receipts pass; band-enum violation; `band < floor` violation; `floor != compute_complexity_floor(...)` violation; empty/whitespace `rationale` violation; each asserts the literal checkpoint-context-prefixed message.
  - Acceptance: synthetic checkpoints built by loading `model_policy` from `load_routing_matrix()`, not hardcoded.
- [x] [P3-T3] Create `scripts/dev_tools/_orchestrator_state_model_routing.py` mirroring the same precedent (`MODEL_ROUTING_RECEIPTS_KEY = "model_routing_receipts"`; `__all__`; `_validate_model_routing_receipts(value: object) -> list[str]`).
  - Acceptance: checks `model == resolve_delegation_model(agent, complexity_band, fable_policy)["model"]`; under `fable_policy == "disabled"` no receipt `model` equals `fable` and any receipt with `table_model == "fable"` records `clamped_from == "fable"` and `model == "opus"`. File <= 500 lines.
- [x] [P3-T4] Create `tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing.py` covering: well-formed receipts pass; `model != resolve_delegation_model(...)` fails; a `disabled`-mode receipt recording `model == fable` fails; a `disabled`-mode `fable` cell that does not record `clamped_from == "fable"` with `model == "opus"` fails.
  - Acceptance: each failure asserts the literal, checkpoint-context-prefixed message.
- [x] [P3-T5] Wire both validators into `scripts/dev_tools/validate_orchestrator_state.py` inside `validate_orchestrator_state_text(...)`, adding two key-gated blocks (`if COMPLEXITY_ASSESSMENTS_KEY in state_map:` and `if MODEL_ROUTING_RECEIPTS_KEY in state_map:`) alongside the existing `HUMAN_INTERACTION_KEY` block, importing each new module. Do NOT add the keys to `REQUIRED_STATE_KEYS`.
  - Acceptance: absent keys contribute zero errors; the two blocks each `errors.extend(...)` only when their key is present.
- [x] [P3-T6] Add a backward-compatibility test to `tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py` and `..._model_routing.py` asserting a checkpoint lacking each new array validates exactly as before (zero new errors); write `evidence/regression-testing/backward-compat-checkpoints.md`.
  - Acceptance: artifact records `Command:`/`EXIT_CODE:`/`Output Summary:` confirming existing checkpoint fixtures pass unchanged.
- [x] [P3-T7] Run the Python toolchain on all Phase 3 files (`black`, `ruff check`, `pyright`, `pytest tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing.py --cov=scripts/dev_tools/_orchestrator_state_complexity --cov=scripts/dev_tools/_orchestrator_state_model_routing --cov-branch --cov-report=term-missing`); restart on any fix.
  - Acceptance: all four stages pass in a single pass; changed-file line coverage >= 85%, branch >= 75%.

### Phase 4 — Checkpoint-Shape Prose

- [x] [P4-T1] Add three additive, key-gated invariant subsections to `.claude/rules/orchestrator-state.md` following the `human_interaction` prose precedent: `complexity_assessments[]` (scope + backward-compat + invariants: band enum, `band >= floor`, `floor == compute_complexity_floor`, non-empty rationale), `model_routing_receipts[]` (scope + backward-compat + invariants: `model == resolve_delegation_model`, `disabled`-mode clamp), and the `model_budget` contract. State enforcement is the Python validator, not an imported schema.
  - Acceptance: each subsection opens with the "applies only when the checkpoint contains..." scope statement; tone-policy compliant.
- [x] [P4-T2] Mirror the edited `.claude/rules/orchestrator-state.md` byte-for-byte to `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`.
  - Acceptance: repo-root and bundled copies are byte-identical.
- [x] [P4-T3] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`; write `evidence/qa-gates/rules-parity.md`.
  - Acceptance: test passes; `EXIT_CODE: 0`.

### Phase 5 — New Agents

- [x] [P5-T1] Create `.claude/agents/commit-message.md` with frontmatter `name: commit-message`, `description:` (read-only; generates a conventional commit message from the staged diff; does not commit), `model: haiku`, `skills: [commit-message]`, `memory: project`, `tools: [Read, "Bash(git log *)", "Bash(git diff *)"]`, followed by an H1 + body. Match the `pr-author.md` frontmatter schema (dedicated `skills:` list, not the `task-researcher` anomaly).
  - Acceptance: valid YAML frontmatter; `tools` are read-only.
- [x] [P5-T2] Mirror `.claude/agents/commit-message.md` byte-for-byte to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/commit-message.md`.
  - Acceptance: byte-identical.
- [x] [P5-T3] Create `.claude/agents/human-exception-runbook.md` with frontmatter `name: human-exception-runbook`, `description:` (authors a runbook under `<FEATURE>/runbooks/**` per the `human-exception-runbook` skill; MCP-first/web-second sourcing), `model: sonnet`, `skills: [human-exception-runbook]`, `memory: project`, `tools: [Read, Grep, Glob, WebFetch, "Write(<FEATURE>/runbooks/**)"]`. Document in the body that no MCP documentation tool currently exists (MCP-first clause aspirational; WebFetch is the sole web mechanism), per spec Out of Scope.
  - Acceptance: valid YAML frontmatter; `Write` scoped to `<FEATURE>/runbooks/**`.
- [x] [P5-T4] Mirror `.claude/agents/human-exception-runbook.md` byte-for-byte to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/human-exception-runbook.md`.
  - Acceptance: byte-identical.
- [x] [P5-T5] Perform a frontmatter smoke check: confirm Claude Code loads both new agent files without rejecting the `model: haiku` / `model: sonnet` values (RISK from spec §Risks). Write `evidence/other/agent-frontmatter-smoke-check.md`.
  - Acceptance: artifact records whether the frontmatter is accepted; if rejected, records the exact error for remediation.
- [x] [P5-T6] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`; write `evidence/qa-gates/agents-parity.md`.
  - Acceptance: the two new agent files are enumerated and byte-identical in the bundle; `EXIT_CODE: 0`.

### Phase 6 — Orchestrator Allowlist

- [x] [P6-T1] Add `commit-message` and `human-exception-runbook` to the comma-joined `Agent(...)` tool pattern in `.claude/agents/orchestrator.md` (line 5 delegation allowlist).
  - Acceptance: both names present in the `Agent(...)` list; no spaces introduced in the comma-join.
- [x] [P6-T2] Add `"Agent(commit-message)"` and `"Agent(human-exception-runbook)"` entries to the `permissions.allow` array in `.claude/settings.json`.
  - Acceptance: both entries present; valid JSON.
- [x] [P6-T3] Mirror the edited `.claude/agents/orchestrator.md` byte-for-byte to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`.
  - Acceptance: byte-identical.
- [x] [P6-T4] Mirror the edited `.claude/settings.json` byte-for-byte to `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`.
  - Acceptance: byte-identical.
- [x] [P6-T5] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`; write `evidence/qa-gates/orchestrator-allowlist-parity.md`.
  - Acceptance: `orchestrator.md` and `settings.json` parity assertions pass; `EXIT_CODE: 0`.

### Phase 7 — Skill Edits

- [x] [P7-T1] Add a `## Model Selection` section to `.claude/skills/orchestrate/SKILL.md` inserted between `## Delegation Model` (ends line 66) and `## PR Authoring` (line 68), documenting end-to-end: parse the `model_budget.fable_policy` kickoff marker; assess `complexity_band` and record a `complexity_assessments[]` entry; run the per-delegation selection order; emit a `model_routing_receipts[]` entry; name `compute_complexity_floor` and `resolve_delegation_model` as the canonical formulas; state that `route` is not a model-selection input; state the `fork` caveat (a fork-routed skill inherits the parent model and ignores an override).
  - Acceptance: section names both reference implementations and the `fable_policy` marker; tone-policy compliant.
- [x] [P7-T2] Update the Pre-Feature-Review Commit step (lines 110-119) in `.claude/skills/orchestrate/SKILL.md` to delegate message generation to `Agent(commit-message)` while `git add`/`git commit -m "<generated message>"` stays on the orchestrator.
  - Acceptance: message generation is delegated; the commit action remains on the orchestrator.
- [x] [P7-T3] Update the Pre-R4 commit bullet (line 136, `## Remediation Loop`) in `.claude/skills/orchestrate/SKILL.md` to delegate message generation to `Agent(commit-message)` while `git commit` stays on the orchestrator.
  - Acceptance: identical delegate/commit split as P7-T2; these are the only two `git commit` points in the file.
- [x] [P7-T4] Update the Exception-runbook requirement (lines 45-47) in `.claude/skills/orchestrate/SKILL.md` so the orchestrator delegates runbook authoring to `Agent(human-exception-runbook)` and records the returned `runbook_path` at `<FEATURE>/runbooks/<name>.runbook.md`.
  - Acceptance: authoring is delegated; the orchestrator still records `runbook_path`.
- [x] [P7-T5] Add a `## Model Selection` section to `.claude/skills/epic-orchestrate/SKILL.md` immediately after `## Merge-on-Green Kickoff Parameter` (ends line 106), documenting the `model_budget.fable_policy: <disabled|available|preferred>.` kickoff marker appended to each child `Agent(orchestrator)` delegation, the two reference implementations, and the same `route`-is-not-a-model-input and `fork` caveats.
  - Acceptance: section mirrors the existing kickoff-marker pattern; names both reference implementations.
- [x] [P7-T6] Mirror the edited `.claude/skills/orchestrate/SKILL.md` byte-for-byte to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`.
  - Acceptance: byte-identical.
- [x] [P7-T7] Mirror the edited `.claude/skills/epic-orchestrate/SKILL.md` byte-for-byte to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`.
  - Acceptance: byte-identical.
- [x] [P7-T8] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`; write `evidence/qa-gates/skills-parity.md`.
  - Acceptance: both edited skill files pass byte-identity; `EXIT_CODE: 0`.

### Phase 8 — Final QA, Bundle-Sync Verification & Acceptance Cross-Check

- [x] [P8-T1] Run `poetry run black .`; write `evidence/qa-gates/final-black.md`.
  - Acceptance: `EXIT_CODE: 0`; if files change, restart the loop from this step.
- [x] [P8-T2] Run `poetry run ruff check .`; write `evidence/qa-gates/final-ruff.md`.
  - Acceptance: `EXIT_CODE: 0`; zero lint errors.
- [x] [P8-T3] Run `poetry run pyright`; write `evidence/qa-gates/final-pyright.md`.
  - Acceptance: `EXIT_CODE: 0`; zero type errors.
- [x] [P8-T4] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing`; write `evidence/qa-gates/final-pytest-coverage.md` and record baseline coverage (from P0-T3), post-change coverage, and new/changed-code coverage.
  - Acceptance: all tests pass; total line >= 85%, branch >= 75%; no regression on changed lines; new module coverage recorded numerically.
- [x] [P8-T5] Run the named bundle-sync parity contracts `poetry run pytest tests/scripts/dev_tools/test_orchestration_routing_config_parity.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py`; write `evidence/qa-gates/final-bundle-sync-parity.md`.
  - Acceptance: byte-identity contracts (config, `.claude/**`) pass; Codex/`.agents` content-parity tests pass or are documented as skipped per their `skipif` when `.codex/agents` is absent locally.
- [x] [P8-T6] Run the PowerShell Pester bundle-sync suite via `mcp__drm-copilot__run_poshqc_test` for `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`; write `evidence/qa-gates/final-pester.md`.
  - Acceptance: `EXIT_CODE: 0`; suite green (no `.ps1` source edited, so PoshQC format/analyze on touched files is not applicable).
- [x] [P8-T7] Verify no production/test/script file added or edited by this feature exceeds 500 lines (`compute_complexity_floor.py`, `resolve_delegation_model.py`, `_orchestrator_state_complexity.py`, `_orchestrator_state_model_routing.py`, all four test files). Write `evidence/qa-gates/file-size-limit.md`.
  - Acceptance: each file line count recorded and <= 500.
- [x] [P8-T8] Verify `route` is not a model-selection input anywhere: grep the new config keys, both reference implementations, both validators, and the two skill `## Model Selection` sections for any read of `route` in a model-selection path. Write `evidence/regression-testing/route-not-model-input.md` with `SearchScope:`, `SearchPatterns:`, `SearchResult:`.
  - Acceptance: no model-selection code path or documented rule reads `route`; `SearchResult: none`.
- [x] [P8-T9] Cross-check every acceptance criterion in `spec.md` (WS1, WS2, WS3, Cross-cutting) and `issue.md` against the tasks that satisfy it. Write `evidence/other/acceptance-criteria-crosscheck.md` mapping each AC to task IDs and its verification artifact.
  - Acceptance: every AC maps to at least one completed task with a named evidence artifact; any unmapped AC blocks completion.

## Acceptance Criteria Traceability (summary)

- Route-not-model-input AC: P1-T1/P1-T4 (impls), P7-T1/P7-T5 (docs), P8-T8 (verification).
- `model_policy` + `model_budget` config + byte-identical mirror: P2-T1..P2-T4.
- `compute_complexity_floor` determinism + never-exceed-C3: P1-T1/P1-T2/P1-T7.
- `resolve_delegation_model` base/overlay/disabled clamp: P1-T4/P1-T5/P1-T6.
- Complexity validator: P3-T1/P3-T2. Model-routing validator: P3-T3/P3-T4.
- Key-gated wiring + backward-compat: P3-T5/P3-T6.
- Skill `## Model Selection` sections: P7-T1/P7-T5.
- `commit-message` agent + allowlist + commit-point delegation: P5-T1/P5-T2, P6-T1/P6-T2, P7-T2/P7-T3.
- `human-exception-runbook` agent + allowlist + runbook delegation: P5-T3/P5-T4, P6-T1/P6-T2, P7-T4.
- Additive/optional + parity + green toolchains: P3-T6, P8-T4/P8-T5/P8-T6.
- Checkpoint-shape prose additions: P4-T1/P4-T2.

## Open Questions / Notes

- RISK (parity gap): the live MCP tool is a TypeScript port not updated here; Python pytest/CLI enforce the new invariants. Recommend a separate follow-up issue to port both validators to `orchestrator-state-core.ts`. Out of scope (DD-1).
- RISK (frontmatter acceptance): `haiku`/`sonnet` `model:` values have no precedent in the agent corpus; P5-T5 smoke check gates this.
- Codex/`.agents` `.toml` wrappers for the two new agents are deferred per spec Out of Scope; content-equivalent Codex updates for orchestrator/orchestrate are conditional and covered only if `test_codex_agent_wrapper_contracts.py` fails in P8-T5.
