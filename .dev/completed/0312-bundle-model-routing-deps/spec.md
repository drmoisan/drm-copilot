# bundle-model-routing-deps (Spec)

- **Issue:** #312
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-05T00-00
- **Status:** Draft
- **Version:** 1.0

## Context
- Summary of the bug and its impact (link to repro/playbook entry). The distributed `orchestrate` skill (`.claude/skills/orchestrate/SKILL.md`) instructs the orchestrator to run two model-routing reference implementations that live outside the `.claude/` tree: `scripts/dev_tools/compute_complexity_floor.py` and `scripts/dev_tools/resolve_delegation_model.py`. The `Push Down Claude Customizations` command is hard-scoped to the `.claude` tree (`scripts/dev_tools/push_down_claude_customizations.py:101`, `ROOT_FOLDERS = (Path(".claude"),)`), and no pack manifest references `scripts/dev_tools/**` or `config/orchestration-routing.json`. Consequently a destination that receives the pushed-down customizations gets a skill that cites files it does not have. Repro/design evidence: `research/2026-07-04T2240-bundle-model-routing-deps-research.md` and `research/2026-07-04T2300-bundle-model-routing-deps-powershell-research.md`.
- Observed environment(s): any workspace that receives a `.claude`-only push-down (both no-selection full-tree publish and `--packs core`) and does not also contain the repository's `scripts/` and Python toolchain.
- Customer impact and severity: a destination workspace's `orchestrate` skill references missing files, so the delivered model-selection reference is not runnable there. Severity: functional defect in the distributed skill bundle. Frequency: deterministic; every push-down to a `.claude`-only destination reproduces it.
- First observed date and version(s) impacted: captured 2026-07-04 (issue #312). Present in the current `.claude` distribution; no prior version delivered these dependencies under `.claude/`.

## Repro & Evidence
- Steps to reproduce (with data/flags/inputs):
  1. Run the `.claude`-only push-down against a destination that lacks the repo's `scripts/` tree (either `push_down_claude_customizations` with no `--packs` selection, which publishes the full `.claude` tree, or with `--packs core`, which publishes only manifest-listed `.claude/`-relative paths per `research/2026-07-04T2240-bundle-model-routing-deps-research.md` Section 1.4).
  2. In the destination, open the delivered `.claude/skills/orchestrate/SKILL.md` and follow the Model Selection instructions that name `scripts/dev_tools/compute_complexity_floor.py` (lines 32, 86) and `scripts/dev_tools/resolve_delegation_model.py` (lines 34, 87).
- Expected vs actual behavior: Expected — every model-routing reference the delivered skill instructs the orchestrator to run is present in the destination. Actual — the two `scripts/dev_tools/*.py` reference implementations are absent because push-down never leaves the `.claude` tree and no manifest lists `scripts/dev_tools/**`, so the skill cites files that do not exist in the destination.
- Logs/screenshots/error snippets: not applicable; the defect is a static dangling-reference condition in the delivered bundle, established by reading the push-down scope constant `ROOT_FOLDERS = (Path(".claude"),)` at `scripts/dev_tools/push_down_claude_customizations.py:101` and the absence of any `scripts/dev_tools/**` entry in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- Frequency / determinism: always. The push-down scope and manifest contents are static, so the missing-dependency condition is deterministic, not data-dependent.

## Scope & Non-Goals
- In scope:
  - Create PowerShell ports of the two self-contained pure formula scripts as `.claude/`-resident library functions so they travel with the `.claude`-only push-down:
    - `scripts/dev_tools/compute_complexity_floor.py` -> PowerShell function `Get-ComplexityFloor`.
    - `scripts/dev_tools/resolve_delegation_model.py` -> PowerShell function `Resolve-DelegationModel`.
  - Place both functions in a single module at `.claude/lib/model-routing/ModelRouting.psm1` (the location recommended by `research/2026-07-04T2300-bundle-model-routing-deps-powershell-research.md` Section 4.1, consistent with the `.psm1` reusable-module form used at `scripts/powershell/PoshQC/*.psm1`).
  - Add Pester tests at the mirrored test path `tests/scripts/claude-lib/model-routing/` (the `.claude/lib` -> `tests/scripts/claude-lib` mapping confirmed in `research/2026-07-04T2300-bundle-model-routing-deps-powershell-research.md` Section 1.6), translating the existing pytest cases for the two formulas.
  - Add a config-parity test that pins the PowerShell constants to the authoritative `config/orchestration-routing.json` (`model_policy` / `model_budget`), mirroring the existing Python-side parity pattern (`tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`).
  - Add the new `.claude/` PowerShell file to the `core` pack manifest (`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`) so push-down delivers it under `--packs core`.
  - Copy the new module into the byte-mirror `extensions/drm-copilot/resources/claude-customizations/.claude/lib/model-routing/ModelRouting.psm1` (mechanically required by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`).
  - Repoint the `orchestrate` (and `epic-orchestrate`) skill "orchestrator-runs-the-reference" citations for the two formulas to the new PowerShell module and function names.
- Out of scope / non-goals:
  - The three `_orchestrator_state_*` helpers (`_orchestrator_state_complexity.py`, `_orchestrator_state_model_routing.py`, `_orchestrator_state_model_routing_gate.py`), `scripts/dev_tools/validate_orchestrator_state.py`, and the TypeScript validator port (`extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`) are NOT changed. A `.claude`-only destination validates via the bundled MCP TypeScript surface (existence-only check per `research/2026-07-04T2300-bundle-model-routing-deps-powershell-research.md` Section 1.3), not the Python helpers.
  - `config/orchestration-routing.json` stays JSON in place. It is read by the Python validator, the TypeScript routing port (`orchestrator-state-routing.ts` `loadRoutingMatrix`), and `.claude/hooks/enforce-completion-helpers.ps1` (line 128). It is not moved, renamed, or converted to `.psd1`.
  - The Python modules are neither deleted nor rewritten. Deleting the Python `compute_complexity_floor.py` / `resolve_delegation_model.py` would break `_orchestrator_state_complexity.py` (imports `compute_complexity_floor` at line 36) and `_orchestrator_state_model_routing.py` (imports both at lines 36-37); the two languages coexist, pinned to the same authoritative config by the parity test.
  - Delivering a `.claude`-resident copy of `config/orchestration-routing.json` and repointing the `enforce-completion-helpers.ps1` `Join-Path` is a separate, explicitly-flagged sub-decision (see Assumptions/Constraints); it is not required by this issue's runtime deliverables and is excluded here.
  - No changes to `pyproject.toml` (`[tool.poetry].packages`, `[tool.coverage.run].source`, `[tool.pyright].include`) and no changes to any test under `tests/scripts/dev_tools/`.
- Explicitly excluded systems, integrations, or datasets: no third-party UI, portal, or external-service interaction (no Azure/Entra, Outlook, or M365 admin surface). No new third-party dependency.

## Root Cause Analysis
- Current hypothesis or confirmed root cause (confirmed by reading source): the push-down enumeration is hard-scoped to the `.claude` tree via `ROOT_FOLDERS = (Path(".claude"),)` at `scripts/dev_tools/push_down_claude_customizations.py:101`, and the `core` pack manifest lists only `.claude/`-relative paths. The two model-routing reference implementations the `orchestrate` skill cites live under `scripts/dev_tools/`, outside that scope, so they are never delivered to a `.claude`-only destination.
- Signals/evidence supporting it:
  - `ROOT_FOLDERS = (Path(".claude"),)` at `scripts/dev_tools/push_down_claude_customizations.py:101` (enumeration hard-scoped to `.claude`).
  - `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists only `.claude/`-relative paths; no entry references `scripts/dev_tools/**` or `config/**` (`research/2026-07-04T2240-bundle-model-routing-deps-research.md` Section 1.4).
  - `.claude/skills/orchestrate/SKILL.md` cites `compute_complexity_floor.py` (lines 32, 86) and `resolve_delegation_model.py` (lines 34, 87); `.claude/skills/epic-orchestrate/SKILL.md` cites both (lines 118-119).
  - `.claude` cannot be a Python package (leading dot is not a valid identifier), so a Python physical relocate under `.claude/` is non-precedented and high-cost (`research/2026-07-04T2240-bundle-model-routing-deps-research.md` Section 1.3). PowerShell has no leading-dot package constraint and is resolvable by path (`research/2026-07-04T2300-bundle-model-routing-deps-powershell-research.md` Section 2), which is why the ratified fix uses PowerShell ports.
- Affected components/modules (paths, services, pipelines): the `.claude` push-down bundle and its `core` manifest; the `orchestrate` and `epic-orchestrate` skills; the new `.claude/lib/model-routing/` PowerShell library; the Pester test tree under `tests/scripts/claude-lib/`. The Python validator stack and `config/orchestration-routing.json` are unaffected by design.

## Proposed Fix

### Design summary (what changes where):
Adopt Architecture B-mirror (`research/2026-07-04T2300-bundle-model-routing-deps-powershell-research.md` Sections 3 and 9). Add PowerShell implementations of the two pure formulas under `.claude/lib/model-routing/ModelRouting.psm1` for the destination runtime, keep the Python `compute_complexity_floor.py` and `resolve_delegation_model.py` as the validator's authoritative reference, and leave the three `_orchestrator_state_*` helpers and `validate_orchestrator_state.py` untouched. The two implementations of each pure formula are pinned to the same documented truth table by a static config-parity test. This is the code analog of the established `config/orchestration-routing.json` dual-copy plus parity-test precedent.

### Boundaries and invariants to preserve:
- The Python validator remains the sole authority for per-receipt correctness (floor equality and resolved-model equality), as stated in `.claude/rules/orchestrator-state.md` and `.claude/skills/orchestrate/SKILL.md` line 100.
- The dependency direction is one-way: the Python helpers import the two pure scripts, never the reverse. The two pure formulas import only `typing` / `collections.abc` and reference the helpers only in docstrings, so they are self-contained and run without the three `_orchestrator_state_*` helpers. The PowerShell ports must preserve this self-contained property (no import of validator logic, no file read at runtime).
- The PowerShell ports must be behaviorally identical to the Python references across the shared cases.
- `config/orchestration-routing.json` remains JSON in place and is read as JSON by three consumers (Python validator, TS routing port, `enforce-completion-helpers.ps1`).
- The `.claude` tree is byte-mirrored to `extensions/drm-copilot/resources/claude-customizations/.claude/`; any new `.claude/**` file must be copied there or `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` fails.

### Dependencies or blocked work:
None. The change is filesystem- and code-only and fully automatable. No human-interaction requirement was discovered (`research/2026-07-04T2300-bundle-model-routing-deps-powershell-research.md` Automation Feasibility).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- New: `.claude/lib/model-routing/ModelRouting.psm1` — module exporting `Get-ComplexityFloor` and `Resolve-DelegationModel`.
- New: `tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1`.
- New: `tests/scripts/claude-lib/model-routing/Resolve-DelegationModel.Tests.ps1` (includes the static config-parity assertion, or a sibling `ModelRouting.Parity.Tests.ps1` if the planner prefers a dedicated file; either is acceptable provided per-behavior isolation is preserved).
- New (byte-mirror copy): `extensions/drm-copilot/resources/claude-customizations/.claude/lib/model-routing/ModelRouting.psm1`.
- Edit: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — append `.claude/lib/model-routing/ModelRouting.psm1` to `paths[]`.
- Edit: `.claude/skills/orchestrate/SKILL.md` — repoint the "orchestrator-runs-the-reference" citations for the two formulas (lines 32, 34, 86, 87) to the PowerShell module and function names; mirror the edit in the bundle tree.
- Edit: `.claude/skills/epic-orchestrate/SKILL.md` — repoint the two formula citations (lines 118-119) to the PowerShell module and function names; mirror the edit in the bundle tree.
- Unchanged (validator-authority citations stay pointing at Python): `.claude/rules/orchestrator-state.md` (lines 47, 61, 81, 87-91) and `.claude/skills/orchestrate/SKILL.md` (lines 96, 100). Optionally add one sentence to `orchestrate/SKILL.md` clarifying that the destination runtime reference is the PowerShell module while the repo validator remains the Python authority.
- Unchanged: all Python modules (`compute_complexity_floor.py`, `resolve_delegation_model.py`, the three `_orchestrator_state_*` helpers, `validate_orchestrator_state.py`), `pyproject.toml`, `config/orchestration-routing.json`, the TypeScript validator port, and every test under `tests/scripts/dev_tools/`.

Note on line numbers: offsets shift as edits are applied; the executor must re-confirm exact citation offsets at edit time (`research/2026-07-04T2300-bundle-model-routing-deps-powershell-research.md` Section 4.4).

#### Functions/classes/CLI commands impacted:
- New `Get-ComplexityFloor` (advanced function): parameter `[string[]] $SignalsPresent`; returns a band string (`C1`..`C4`). Port of `compute_complexity_floor` (`scripts/dev_tools/compute_complexity_floor.py`). Embeds module-scope constants matching the Python module: `BAND_ORDER = ('C1','C2','C3','C4')`, `LOWEST_BAND = 'C1'`, `FLOOR_CANDIDATE_BAND = 'C3'`, `FLOOR_CEILING_BAND = 'C3'`. Reads no file.
- New `Resolve-DelegationModel` (advanced function): parameters `[string]$Agent`, `[string]$Band`, `[string]$FablePolicy`; returns a hashtable with keys `table_model`, `model`, `clamped_from`, `clamp_reason` (mirroring the Python dict shape). Port of `resolve_delegation_model` (`scripts/dev_tools/resolve_delegation_model.py`). Embeds constants matching the Python module: base table `@{ C1='haiku'; C2='sonnet'; C3='opus'; C4='fable' }`, `PREFERRED_OVERLAY_AGENTS = { atomic-planner, prd-feature, feature-review, task-researcher }`, `PREFERRED_OVERLAY_BAND = 'C3'`, `PREFERRED_OVERLAY_MODEL = 'fable'`, disabled clamp to `opus` with `clamped_from = 'fable'` and `clamp_reason = 'fable_disabled'`. Reads no file.
- No CLI command is added or changed. The Python CLI (`scripts.dev_tools.validate_orchestration_artifacts`) and its `.claude/hooks/validate-orchestrator-output.ps1` invoker are unchanged.

#### Data flow and validation changes:
- Runtime (destination): the orchestrator runs `Get-ComplexityFloor -SignalsPresent <names>` to obtain the deterministic lower-bound band, and `Resolve-DelegationModel -Agent <a> -Band <b> -FablePolicy <p>` to obtain the resolved delegation model. Both operate purely on their inputs and embedded constants; neither reads `config/orchestration-routing.json` at runtime, matching the current Python behavior.
- Repo-side validation is unchanged: `validate_orchestrator_state.py` continues to recompute floors via `compute_complexity_floor` and resolved models via `resolve_delegation_model` for `complexity_assessments[]` and `model_routing_receipts[]` receipts. No validation logic moves to PowerShell.
- Static parity: the new config-parity test reads `config/orchestration-routing.json` `model_policy` / `model_budget` and asserts the PowerShell module's embedded literals (base table, overlay agent set, overlay band/model, disabled default policy) equal the authoritative source. This is a file-read-only assertion; it does not invoke the Python runtime or any external process.

#### Error handling and logging updates:
- `Get-ComplexityFloor` is total over any `[string[]]` input (empty -> `C1`; any present floor signal -> `C3`; never `C4`). No error path is added.
- `Resolve-DelegationModel` treats a band outside `C1`..`C4` as the PowerShell analog of the Python `KeyError` (a base-table miss). Band-enum validity is the complexity validator's responsibility, consistent with the Python function's contract (`scripts/dev_tools/resolve_delegation_model.py` `Raises: KeyError`). The port should fail fast and explicitly on an out-of-table band rather than returning a silently wrong value.
- No new logging is introduced; both functions are pure and deterministic.

#### Rollback/feature-flag considerations (if applicable):
No feature flag. Rollback is removal of the new `.claude/lib/model-routing/` module, its byte-mirror copy, the `core.json` entry, and the skill citation repoints; the Python side is untouched, so rollback carries no Python regression risk.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `Get-ComplexityFloor`
  - Input: `-SignalsPresent [string[]]` — the names of present signals flagged `[floor]` in the `model_policy.complexity` catalog. Empty array means no floor signal present.
  - Output: `[string]` band, one of `C1`..`C4` (in practice `C1` or `C3`; `C4` is never returned).
- `Resolve-DelegationModel`
  - Input: `-Agent [string]`, `-Band [string]` (`C1`..`C4`), `-FablePolicy [string]` (`disabled` | `available` | `preferred`).
  - Output: `[hashtable]` with keys `table_model [string]`, `model [string]`, `clamped_from [string|$null]`, `clamp_reason [string|$null]`.

#### Required configuration keys and defaults:
- Authoritative source pinned by the parity test: `config/orchestration-routing.json` `model_policy.complexity_to_model` (`C1=haiku`, `C2=sonnet`, `C3=opus`, `C4=fable`), `model_policy.preferred_overlay` (agents `atomic-planner`, `prd-feature`, `feature-review`, `task-researcher`; band `C3`; model `fable`), and `model_budget.fable_policy` default `disabled`. No new configuration key is introduced.

#### Backward-compatibility expectations:
- Repo-side Python validator imports, the five pytest files under `tests/scripts/dev_tools/`, Pyright (`include = ["scripts","src","tests"]`), and coverage (`source = ["src","scripts/dev_tools"]`) continue to pass unchanged, because no Python module and no `pyproject.toml` setting is modified. New PowerShell files are measured by PoshQC/Pester, not by Python coverage.
- The `.claude`-only push-down contract is preserved: the fix stays inside the `.claude` tree and the `core` manifest; it does not broaden `ROOT_FOLDERS` or add `scripts/dev_tools/**` to any manifest.

#### Performance constraints (latency/throughput/memory):
Both functions are pure, in-memory, constant-work operations over a small input set; no meaningful latency, throughput, or memory constraint applies.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): PoshQC discovers `.ps1`/`.psm1`/`.psd1` recursively and does not exclude `.claude` (`scripts/powershell/PoshQC/PoshQC.psm1` `$script:DefaultExcludedDirs`, `research/2026-07-04T2300-bundle-model-routing-deps-powershell-research.md` Section 1.6), so new `.claude/lib/**` PowerShell is picked up by format/analyze/test the same way `.claude/hooks/**` already is. The `.claude/lib/` directory is permitted by the runtime-structure allowlist (`tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` is an allowlist of required files, not a subdirectory denylist).
- Constraints (budget, performance, compatibility): the 500-line file limit applies; both functions are small (each under approximately 120 lines including docstrings) and the combined module stays well under 500 lines. PowerShell code must pass PSScriptAnalyzer with approved verbs (`Get-`, `Resolve-`), `CmdletBinding()`, `[OutputType(...)]`, parameter validation attributes, no `Invoke-Expression`, and no hard-coded paths. Coverage thresholds are uniform across tiers (>= 85% line, >= 75% branch); these are dev-tooling/scaffolding analogs (T4) but the uniform thresholds still apply.
- External dependencies (services, libraries, releases): none. No new package. The change reuses the existing PoshQC/Pester toolchain and the existing byte-mirror and manifest mechanisms.
- Flagged sub-decision (not in scope, recorded for the planner): delivering a `.claude`-resident copy of `config/orchestration-routing.json` and updating `enforce-completion-helpers.ps1` (line 128) `Join-Path`. In a `.claude`-only destination there is no repo-root `config/`, so that hook's relative read returns `$null` and `Test-RouteRequiresPrGate` degrades to `$false`. This is a pre-existing coupling independent of #312 and is excluded from this change.

## Data / API / Config Impact
- User-facing or API changes: new PowerShell functions `Get-ComplexityFloor` and `Resolve-DelegationModel` under `.claude/lib/model-routing/ModelRouting.psm1`, delivered to destinations by push-down. No change to any Python CLI, MCP tool signature, or config schema.
- Data or migration considerations: none. No data migration; `config/orchestration-routing.json` is unchanged.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag change; no config-schema change; the `core.json` manifest gains one `paths[]` entry. The `.claude` byte-mirror gains one file.

## Test Strategy
- Regression tests to add or update:
  - New Pester tests at `tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1` and `tests/scripts/claude-lib/model-routing/Resolve-DelegationModel.Tests.ps1`, translating the existing pytest truth-table suites `tests/scripts/dev_tools/test_compute_complexity_floor.py` and `tests/scripts/dev_tools/test_resolve_delegation_model.py`.
  - A static config-parity Pester assertion reading `config/orchestration-routing.json` `model_policy` / `model_budget` and asserting the module's embedded literals match, modeled on `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`.
  - A manifest-membership test asserting `.claude/lib/model-routing/ModelRouting.psm1` appears in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` `paths[]` (extend an existing push-down pack test such as `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`; this is the one permitted touch to the push-down test suite and adds no assertion that changes existing behavior).
  - The existing byte-mirror parity is already enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`; no new mirror harness is needed.
- Unit tests for the fixed behavior and boundaries:
  - `Get-ComplexityFloor`: empty signals -> `C1`; any single present floor signal -> `C3`; many present signals still clamp to `C3` (C4 never floor-forced); order-independence. Use Pester `-ForEach`/parametrized cases for the matrix.
  - `Resolve-DelegationModel`: base table `C1->haiku`, `C2->sonnet`, `C3->opus`, `C4->fable`; preferred overlay redirects only the `C3` cell to `fable` and only for the four overlay agents; `atomic-executor` and `pr-author` `C3` stay `opus` under every policy; disabled-mode clamp of a `fable` cell to `opus` with `clamped_from='fable'` and `clamp_reason='fable_disabled'`; available-mode passes the base table through unchanged.
- Edge cases and negative scenarios: empty signal array; an overlay agent under `available` and `disabled` policies (no overlay applied); a non-overlay agent under `preferred` (no overlay); a `C4` cell under `disabled` (clamps to `opus`); an out-of-table band (fail fast, PowerShell analog of the Python `KeyError`).
- Error handling and logging verification: assert `Resolve-DelegationModel` fails fast on an out-of-table band rather than returning a silently wrong value; both functions produce no logging side effects.
- Coverage impact and targets for changed lines/modules: new PowerShell measured by Pester with line >= 85% and branch >= 75% (uniform thresholds). The exhaustive small input matrix for two pure functions reaches full coverage. No new Python production file is added, so there is no uncovered-Python-file finding; `pyproject.toml` coverage and Pyright settings are unchanged.
- Toolchain commands to run (format -> lint -> type-check -> test): PowerShell toolchain per `.claude/rules/powershell.md` — `run_poshqc_format` (Invoke-Formatter, 100% pass) -> `run_poshqc_analyze` (PSScriptAnalyzer, settings `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, 0 findings) -> `run_poshqc_test` (Pester 5.x, settings `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`). PowerShell has no separate type-check stage. Additionally run the Python suite (Black, Ruff, Pyright, Pytest with coverage) to confirm the untouched `tests/scripts/dev_tools/` suite stays green, and the TypeScript/Python contract tests that enforce the byte-mirror and manifest. Restart each toolchain from the top if any stage changes files, until a single clean pass.
- Manual validation steps (if required): none required; verification is fully automatable.

## Acceptance Criteria
- [x] `Get-ComplexityFloor` and `Resolve-DelegationModel` exist in `.claude/lib/model-routing/ModelRouting.psm1` and produce results identical to the Python references (`scripts/dev_tools/compute_complexity_floor.py`, `scripts/dev_tools/resolve_delegation_model.py`) across the shared cases (band floor matrix; base table; preferred overlay; disabled-mode clamp).
- [x] Pester tests exist at `tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1` and `tests/scripts/claude-lib/model-routing/Resolve-DelegationModel.Tests.ps1`, translate the existing pytest cases, and pass.
- [x] A config-parity test pins the PowerShell module constants to `config/orchestration-routing.json` (`model_policy` / `model_budget`) and passes.
- [x] `.claude/lib/model-routing/ModelRouting.psm1` is listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` `paths[]` and is present in the byte-mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/lib/model-routing/ModelRouting.psm1`, so push-down delivers it under both no-selection and `--packs core`.
- [x] The `orchestrate` skill references for the two formulas (`.claude/skills/orchestrate/SKILL.md` and `.claude/skills/epic-orchestrate/SKILL.md`) resolve to the PowerShell module and function names with no broken references, and the same edits are mirrored in the bundle tree.
- [x] The PowerShell toolchain passes clean in a single pass: `run_poshqc_format` (100%), `run_poshqc_analyze` (0 findings), `run_poshqc_test` (Pester line >= 85%, branch >= 75%).
- [x] No changes are made to the Python modules (`compute_complexity_floor.py`, `resolve_delegation_model.py`, the three `_orchestrator_state_*` helpers, `validate_orchestrator_state.py`), `validate_orchestrator_state.py`'s CLI, the TypeScript validator port, `pyproject.toml`, or `config/orchestration-routing.json`; the existing `tests/scripts/dev_tools/` suite passes unchanged.

## Risks & Mitigations
- Technical or operational risks:
  - Divergence between the PowerShell and Python implementations of the two formulas over time. Mitigation: the static config-parity test pins both implementations to the single authoritative source `config/orchestration-routing.json`; the existing Python parity test pins the Python side; both are deterministic and mechanically enforced.
  - Forgetting the byte-mirror copy under `extensions/drm-copilot/resources/claude-customizations/.claude/`. Mitigation: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` fails if the mirror is missing or drifts.
  - Omitting the `core.json` entry, leaving the skill delivered with a dangling reference under `--packs core`. Mitigation: the added manifest-membership test asserts the path is listed.
  - Skill citation split (orchestrator-runs citations repointed to PowerShell; validator-authority citations left pointing at Python) is a judgment call that could confuse a reader. Mitigation: optionally add one clarifying sentence to `orchestrate/SKILL.md` distinguishing destination runtime reference (PowerShell) from repo validator authority (Python).
  - Prohibited actions that would reintroduce breakage: deleting the Python `compute_complexity_floor.py` / `resolve_delegation_model.py` (breaks `_orchestrator_state_*` imports), converting `config/orchestration-routing.json` to `.psd1` or moving it (breaks three JSON readers), or adding a cross-process behavioral parity test (violates the no-external-process unit-test rule). Mitigation: these are explicit non-goals; the parity test is static (file-read only).
- Mitigations and rollbacks: rollback removes the new module, its mirror, the manifest entry, and the skill repoints. The Python side is untouched, so rollback has no Python regression surface.

## Rollout & Follow-up
- Release/rollout steps: land the new module, tests, manifest entry, byte-mirror copy, and skill repoints together; run the PowerShell, Python, and contract toolchains to a single clean pass each; deliver via the standard `.claude` push-down (no bundle-contract change beyond the added file and manifest entry).
- Post-fix monitoring or clean-up tasks: none required. If the flagged config sub-decision (delivering a `.claude`-resident `config/orchestration-routing.json` copy and repointing `enforce-completion-helpers.ps1`) is later ratified, track it as separate follow-up work.
- Links: issue #312 (https://github.com/drmoisan/drm-copilot/issues/312); research `research/2026-07-04T2240-bundle-model-routing-deps-research.md` and `research/2026-07-04T2300-bundle-model-routing-deps-powershell-research.md`.
