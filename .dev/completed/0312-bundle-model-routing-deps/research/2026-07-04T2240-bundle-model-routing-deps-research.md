# Research: Bundle model-routing dependencies with the `.claude` push-down (Issue #312)

- Date: 2026-07-04
- Feature: `docs/features/active/2026-07-04-bundle-model-routing-deps-312`
- Scope: research only; no production changes proposed as edits.
- Canonical issue: #312

## 1. Current State Analysis

### 1.1 The six dependencies and their runtime nature

| # | File | Reads a file at runtime? | Internal imports |
|---|------|--------------------------|------------------|
| 1 | `scripts/dev_tools/compute_complexity_floor.py` | No. Verified: imports only `typing`, `collections.abc`. Pure; encodes band ordering as constants. | none |
| 2 | `scripts/dev_tools/resolve_delegation_model.py` | No. Verified: imports only `typing`. Pure; encodes the base table, overlay, clamp as constants. | none |
| 3 | `scripts/dev_tools/_orchestrator_state_complexity.py` | No (schema-free by design). | `from scripts.dev_tools.compute_complexity_floor import BAND_ORDER, compute_complexity_floor` (line 36) |
| 4 | `scripts/dev_tools/_orchestrator_state_model_routing.py` | No. | `from scripts.dev_tools.compute_complexity_floor import BAND_ORDER` (36); `from scripts.dev_tools.resolve_delegation_model import ...` (37) |
| 5 | `scripts/dev_tools/_orchestrator_state_model_routing_gate.py` | No. | `from scripts.dev_tools._orchestrator_state_complexity import ...` (40); `from scripts.dev_tools._orchestrator_state_model_routing import ...` (44) |
| 6 | `config/orchestration-routing.json` | N/A (data file). It is an authoritative-source document; the two pure scripts (1, 2) do **not** read it. Verified by reading their source: they encode constants that mirror `model_policy`. | n/a |

Key facts:
- Files 1 and 2 are self-contained and runnable standalone in any workspace.
- Files 3-5 are the Python validator internals. They are consumed only by `scripts/dev_tools/validate_orchestrator_state.py` (imports at lines 29, 37, 41) and by the repo test suite. They are **not** invoked by the orchestrator agent directly; the `orchestrate` skill instructs the orchestrator to run only the two pure reference implementations (files 1, 2).
- The config file is authoritative-source only, not a runtime dependency of the two pure scripts.

### 1.2 Python package / import mechanism

- `pyproject.toml` declares `packages = [{ include = "scripts" }]` (lines 12-14). The importable package root is `scripts`; all modules import each other as `from scripts.dev_tools.X import Y` (absolute imports, mandated by `.claude/rules/python.md` and ruff `TID`).
- Test collection puts the repo root on `sys.path` via `tests/conftest.py` `_ensure_repo_root_on_sys_path()` (lines 39-64), so `scripts.dev_tools.*` resolves during pytest.
- Pyright resolves the same tree via `include = ["scripts", "src", "tests"]` (`pyproject.toml` lines 130-134).
- Coverage source is `source = ["src", "scripts/dev_tools"]` (`pyproject.toml` line 103). Every file under `scripts/dev_tools/` is in the coverage denominator (`.claude/rules/general-unit-test.md` "no production file excluded").

### 1.3 How `.claude/` code is imported/executed — critical constraint

- There is **no** Python under `.claude/` today. `Glob .claude/**/*.py` returns nothing.
- Nothing places `.claude/` (or any subdirectory of it) on `sys.path`.
- `.claude` is **not a valid Python package name** (leading dot is not a valid identifier). A module physically stored at `.claude/<dir>/mod.py` cannot be imported by any dotted path that contains `.claude`. It is importable only if the directory that *contains* a valid-identifier package (for example `.claude/<validpkg>/`) is placed on `sys.path`, after which it imports as `<validpkg>.mod`.
- Concrete implication for a relocated module: to import `compute_complexity_floor` from under `.claude/`, a downstream planner would have to (i) create a valid-identifier package directory under `.claude/` (for example `.claude/orchestration_routing/` with `__init__.py`), (ii) add `str(repo_root / ".claude")` to `sys.path` in `tests/conftest.py` and any runtime entry point, (iii) rewrite every `from scripts.dev_tools.X` reference to the new package, and (iv) add the new path to `pyproject.toml` `[tool.pyright].include`, `[tool.coverage.run].source`, and `[tool.poetry].packages`. This is a Python package living inside a dot-directory, which has no precedent in this repository and fights the standard `scripts/dev_tools` layout.

### 1.4 Push-down bundle mechanics (verified)

- `scripts/dev_tools/push_down_claude_customizations.py`:
  - `ROOT_FOLDERS = (Path(".claude"),)` (line 101) — enumeration is hard-scoped to the `.claude` tree.
  - `BUNDLE_ROOT_RELATIVE_DIR = extensions/drm-copilot/resources/claude-customizations` (lines 67-69), which holds `pack-manifests/` (`PACK_MANIFEST_SUBDIR`, line 71).
  - `push_down_customizations(...)` copies `root_folders` (`.claude`) from `repo_root`/`source_root`. The repo CLI (`main`, lines 369-399) uses `source_root = repo_root`, so it copies the repo's own `.claude/` tree.
- Pack selection (`_resolve_published_paths`, lines 137-185):
  - No `--packs` selection -> returns `None` -> publish the full `.claude` tree with no manifest read.
  - A `--packs core` selection -> only manifest-listed `.claude/`-relative paths are published (`core` always included via `compute_published_paths`).
- The extension also ships a TypeScript push-down/validator path (`extensions/drm-copilot/src/repo-automation-service.ts`, `mcp-handlers/push-down-handlers.ts`, `src/lib/validate/orchestrator-state-routing.ts`). The consumer-facing validation is served by this TS reimplementation, not by the Python validator. No Python is bundled under `extensions/drm-copilot/resources/` (`Glob extensions/drm-copilot/resources/**/*.py` returns nothing).
- Pack manifest file for `core`: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`. It lists only `.claude/`-relative paths (agents, hooks, rules, skills). No entry references `scripts/dev_tools/**` or `config/**`. For any relocated/mirrored dependency to be delivered under `--packs core`, it must be appended to this `paths` array (and physically present in both the repo `.claude/` tree and the bundle mirror `extensions/drm-copilot/resources/claude-customizations/.claude/`).

### 1.5 Existing mirror precedent

- `config/orchestration-routing.json` is already mirrored to `extensions/drm-copilot/resources/config/orchestration-routing.json` and guarded by a byte-identity test: `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`. This mirror is under `resources/config/`, **not** under `claude-customizations/`, and is **not** in any pack manifest; the extension reads it from its own resources. This confirms mirroring-with-a-parity-test is an established, mechanically enforced pattern in this repository.

## 2. Complete Dependency and Import Map

### 2.1 Production imports of the six deps (all `from scripts.dev_tools...`)

- `scripts/dev_tools/validate_orchestrator_state.py`: imports `_orchestrator_state_complexity` (29), `_orchestrator_state_model_routing` (37), `_orchestrator_state_model_routing_gate` (41). (Also imports human-interaction, pr-creation-readiness, routing helpers — out of the six-dep scope but same package.)
- `scripts/dev_tools/_orchestrator_state_complexity.py`: imports `compute_complexity_floor` (36).
- `scripts/dev_tools/_orchestrator_state_model_routing.py`: imports `compute_complexity_floor` (36), `resolve_delegation_model` (37).
- `scripts/dev_tools/_orchestrator_state_model_routing_gate.py`: imports `_orchestrator_state_complexity` (40), `_orchestrator_state_model_routing` (44).

### 2.2 Test imports (files under `tests/scripts/dev_tools/`)

- `test_compute_complexity_floor.py`: `from scripts.dev_tools.compute_complexity_floor import compute_complexity_floor` (21).
- `test_resolve_delegation_model.py`: `from scripts.dev_tools.resolve_delegation_model import resolve_delegation_model` (23).
- `test_validate_orchestrator_state_complexity.py`: imports `_orchestrator_state_complexity` (15) and `compute_complexity_floor` (20).
- `test_validate_orchestrator_state_model_routing.py`: imports `_orchestrator_state_model_routing` (14) and `resolve_delegation_model` (18).
- `test_validate_orchestrator_state_model_routing_gate.py`: `import scripts.dev_tools.validate_orchestrator_state as state_validator` (17) (reaches the gate transitively).

That is five test files that import the deps directly or transitively (issue's "roughly five" is accurate). `test_orchestration_routing_config_parity.py` imports only `pathlib` and reads the two config files by path; it does not import the six deps.

### 2.3 Skill / rule / doc references to the six deps (source `.claude/` tree)

- `.claude/skills/orchestrate/SKILL.md`: `compute_complexity_floor.py` at lines 32, 86; `resolve_delegation_model.py` at lines 34, 87; `validate_orchestrator_state.py` at line 96; `_orchestrator_state_model_routing_gate.py` at line 100; `config/orchestration-routing.json` at line 82. Human-interaction reference to `validate_orchestrator_state.py` at line 65.
- `.claude/skills/epic-orchestrate/SKILL.md`: `compute_complexity_floor.py` (118) and `resolve_delegation_model.py` (119).
- `.claude/rules/orchestrator-state.md`: `compute_complexity_floor.py` (47), `resolve_delegation_model.py` (61), `_orchestrator_state_model_routing_gate.py` (81), `validate_orchestrator_state.py` (87-91), `_orchestrator_state_complexity.py` (89), `_orchestrator_state_model_routing.py` (90).
- `.claude/agents/epic-orchestrator.md`: `config/orchestration-routing.json` (108).
- `.claude/hooks/enforce-completion-helpers.ps1`: reads `../../config/orchestration-routing.json` (128).
- `.claude/hooks/validate-orchestrator-output.ps1`: prose reference to `validate_orchestrator_state.py` (71).

Every reference above is duplicated in the bundle mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/...` (same relative files) and would need the same treatment there to keep the two trees consistent. The byte-parity of the bundle is a separate, pre-existing maintenance requirement independent of this change.

## 3. Behavior Semantics (intended outcome)

- Success: after the change, a `.claude`-only push-down (both no-selection and `--packs core`) delivers to the destination workspace every model-routing dependency the delivered `orchestrate` skill cites, so no skill reference is dangling in the destination.
- The two pure reference implementations (`compute_complexity_floor`, `resolve_delegation_model`) must be runnable in the destination, because the skill instructs the orchestrator to run them and to not reimplement the formulas.
- Backward compatibility: repo-side validator imports, the Python test suite, Pyright, and coverage must continue to pass in a single toolchain pass (issue acceptance criterion).
- Failure modes to avoid: broken `scripts.dev_tools.*` imports in the repo; a Python package under a dot-directory that Pyright/coverage cannot resolve; a mirror copy that silently drifts from its source; a manifest that omits the delivered paths so `--packs core` still ships a skill with missing files.

## 4. The `config/orchestration-routing.json` question

- Verified: neither pure script reads the config at runtime; both encode constants mirroring `model_policy`. The config is an authoritative-source document, not a runtime dependency.
- Because the two pure scripts run without it, the destination does **not** strictly need the config file to execute the reference implementations. However, the `orchestrate` skill (line 82) and `epic-orchestrator.md` (line 108) cite `config/orchestration-routing.json` as the authoritative values source, and `.claude/hooks/enforce-completion-helpers.ps1` (line 128) reads it by relative path (`../../config/orchestration-routing.json` from the hook location, i.e., repo-root `config/`). That hook path resolves only when the destination has a repo-root `config/orchestration-routing.json`.
- Recommendation for the config file: deliver a copy alongside the other mirrored deps under `.claude/` and update the two skill/agent references to the delivered `.claude/`-relative path, OR keep the citation repo-relative and accept that the hook's relative read (`../../config/...`) is a separate, pre-existing coupling. The lowest-risk option consistent with the existing config-mirror precedent is to add a `.claude/`-delivered copy of the config and point the skill/agent citations at it; note that `enforce-completion-helpers.ps1` computes its own relative path and would need its `Join-Path` updated if the config's delivered location changes. This should be treated as an explicit sub-decision for the planner, because it also touches the existing `resources/config` mirror parity test.

## 5. Candidate Approaches and Impact Matrix

### Option (a) — Physically relocate under `.claude/` and rewrite imports

Concrete change points:
- Create a valid-identifier package under `.claude/` (dot-directories cannot be a package; a child package is required), move files 1-5 there.
- Rewrite every `from scripts.dev_tools.{compute_complexity_floor,resolve_delegation_model,_orchestrator_state_complexity,_orchestrator_state_model_routing,_orchestrator_state_model_routing_gate}` in: `validate_orchestrator_state.py`, the three `_orchestrator_state_*` helpers, and five test files.
- Add `str(repo_root / ".claude")` (or the new package parent) to `sys.path` in `tests/conftest.py` and any runtime entry point that imports the validator.
- Update `pyproject.toml` `[tool.poetry].packages`, `[tool.pyright].include`, `[tool.coverage.run].source` to cover the new `.claude/`-rooted package.
- Update the bundle mirror to relocate the same files and the `core.json` manifest to list them.
- Update all skill/rule/agent references (Section 2.3) in both the source and mirror `.claude/` trees.

Failure modes / cost:
- Introduces a Python package inside a dot-directory (no repo precedent), with elevated risk in Pyright import resolution, ruff `TID` (tidy-imports) evaluation, and coverage path mapping.
- Largest blast radius: packaging config, `sys.path` bootstrap, 4 production modules, 5 test files, mirror, manifest, and multiple doc references.
- Conflicts with `general-code-change` "Simplicity first" and the repo's established `scripts/dev_tools` layout.

### Option (b) — Mirror copies under `.claude/`, originals stay put

Concrete change points:
- Add copies of the delivered deps into the source `.claude/` tree (for example under a skill-scoped reference directory such as `.claude/skills/orchestrate/reference/`) and the identical files into the bundle mirror `extensions/drm-copilot/resources/claude-customizations/.claude/...`.
- Append the mirrored `.claude/`-relative paths to `core.json`.
- Add byte-identity parity test(s) modeled on `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` (source vs `.claude` copy, and `.claude` source vs bundle mirror).
- Update the skill/rule/agent references (Section 2.3) to cite the delivered `.claude/`-relative copy for the destination context.

Failure modes / cost:
- Parity-maintenance burden between the canonical file and the `.claude` copy — mechanically enforced by a deterministic parity test (no manual vigilance), matching the existing config-mirror pattern.
- Verbatim-mirrored helpers 3-5 would carry `from scripts.dev_tools...` imports that do not resolve in a destination lacking `scripts/`. This is acceptable because the destination's validation path is the TypeScript MCP reimplementation, and the skill instructs the orchestrator to run only the two self-contained pure scripts (1, 2). If strict standalone-executability of the helpers in the destination is required, that is an argument to deliver only files 1, 2 (and the config doc) and to treat 3-5 as repo-internal validator plumbing already covered by the TS surface.

Cost comparison (touch counts):
- Production Python module edits: (a) 4 modules rewritten + packaging config; (b) 0.
- Test edits: (a) 5 files rewritten + conftest sys.path; (b) add 1-2 parity tests, 0 rewrites.
- Manifest: both add entries to `core.json`.
- Bundle mirror: both must update the mirror tree.
- Doc references: both update Section 2.3 references.
- New non-standard pattern introduced: (a) Python package under a dot-directory; (b) none (reuses config-mirror precedent).

### Recommendation

Recommend **Option (b), scoped mirror with byte-identity parity tests**, delivering at minimum the two pure reference scripts and the config authoritative-source document under `.claude/`, following the existing `config/orchestration-routing.json` mirror pattern.

Rationale grounded in `.claude/rules/general-code-change.md`:
- Simplicity first: Option (b) requires zero Python import rewrites, zero `sys.path`/`pyright`/`coverage`/`poetry.packages` churn, and leaves the validator and all five test files untouched, minimizing regression surface.
- Reusability / avoid copy-paste burden: the "parity burden" objection to mirroring is already resolved in this repo by the deterministic parity test precedent; the cost is mechanical, not manual.
- Avoids introducing a Python package under a dot-directory, which is the hard constraint (Section 1.3) that makes a literal "physical move + rewrite `scripts.dev_tools` imports" (Option a) both non-standard and higher-risk than the issue's constraint note assumes.

Explicit tension to surface to the planner: the issue text and this delegation name Option 1 (relocate) as the "chosen direction." The verified `.claude`-cannot-be-a-Python-package constraint materially raises Option (a)'s cost and risk relative to the issue's framing. If the orchestrator still elects Option (a) for architectural reasons, the Section 5(a) change points are the complete list; if it accepts the evidence, Option (b) is lower-risk and precedented. This is a design decision the planner/orchestrator should make explicitly, not a fact the researcher can settle unilaterally.

## 6. Requirements Mapping (acceptance criteria to design)

- AC "dependency files reachable under `.claude/` and delivered by push-down": add mirrored copies to source `.claude/` and bundle `.claude/` mirror (both options); ensure no-selection and `--packs core` both deliver them.
- AC "skill references and validator import paths resolve with no broken references": Option (b) keeps validator imports at `scripts.dev_tools.*` (no change) and updates skill citations to the delivered copy; Option (a) rewrites both.
- AC "`core` pack manifest lists the relocated dependencies": append `.claude/`-relative paths to `core.json` (both options).
- AC "all existing `tests/scripts/dev_tools/` tests pass and full toolchain passes single-pass": Option (b) leaves those tests unchanged (strongest guarantee); Option (a) requires rewriting five test files plus conftest.

## 7. Testing Implications (no test code written here)

- Parity tests: add byte-identity tests (source canonical vs `.claude` delivered copy; source `.claude` vs bundle mirror), modeled on `test_orchestration_routing_config_parity.py` (deterministic, no temp files, no network — compliant with `.claude/rules/general-unit-test.md`).
- Push-down delivery test: assert that a `.claude`-only push-down (both selection modes) yields the delivered dependency paths in the destination enumeration. The push-down engine already has TS and Python test suites (`extensions/drm-copilot/test/*push-down*`, `tests/scripts/...`); extend the appropriate one rather than adding a new harness.
- Manifest coverage test: assert the mirrored `.claude/`-relative paths appear in `core.json` (a small JSON-membership assertion).
- Existing suite: `tests/scripts/dev_tools/` must remain green. Under Option (b) no rewrites are needed; under Option (a) each rewritten import and the sys.path bootstrap must be re-verified.
- Coverage/type-check: any new `.claude`-delivered `.py` copies become production files in the coverage denominator unless they are byte-identical mirrors of already-covered files. Under Option (b), if the `.claude` copies are literal mirrors of covered `scripts/dev_tools` files, confirm the coverage config does not double-count or, conversely, leave the copy uncovered — a copy under `.claude/` is not in `source = ["src", "scripts/dev_tools"]` today, so it would be outside coverage measurement (acceptable only if treated as a delivered data mirror, not new logic). The planner must state explicitly how the `.claude` copies relate to `[tool.coverage.run].source` and `[tool.pyright].include` to avoid an uncovered-production-file finding.

## 8. Toolchain / Tier Considerations

- Affected Python modules are dev tooling under `scripts/dev_tools/` (T4 scaffolding per `.claude/rules/quality-tiers.md`), but coverage thresholds are uniform (>= 85% line, >= 75% branch) across all tiers.
- Pyright (`typeCheckingMode = "strict"`, `include = ["scripts","src","tests"]`): Option (a) requires adding the new `.claude`-rooted package to `include` and confirming strict-mode resolution; Option (b) requires no Pyright change if the `.claude` copies are treated as delivered mirrors outside `include`.
- Coverage (`source = ["src", "scripts/dev_tools"]`): Option (a) must add the new source path; Option (b) keeps source unchanged. Either way, reconcile the "no production file excluded from coverage" policy against any new executable `.py` placed under `.claude/`.
- Ruff `TID` (tidy-imports) forbids relative imports beyond top-level; any rewritten imports in Option (a) must stay absolute.
- File-size limit (500 lines) is not at risk; all six files are well under.

## Automation Feasibility

This change is filesystem- and code-only: relocating or mirroring Python/JSON files, editing Markdown skill/rule references, editing `core.json`, editing `pyproject.toml` (Option a only), and adding pytest tests. There is no third-party UI, portal, or external-service interaction (no Azure/Entra, Outlook, or M365 admin surfaces). Every step is achievable by an autonomous agent through file edits and local toolchain runs (Black, Ruff, Pyright, Pytest; and, for the bundle mirror, the TypeScript toolchain). No human-interaction requirement was discovered. There are no mandatory-unachievable requirements to record under `human_interaction.requirements[]`. Verification is fully automatable: parity tests, manifest-membership tests, push-down delivery tests, and the standard format/lint/type-check/test loop confirm success without manual intervention.

## Rejected Alternatives (brief)

- Option (a) physical relocation with `scripts.dev_tools` import rewrites: viable but higher-risk and non-precedented because `.claude` cannot be a Python package, forcing a package inside a dot-directory plus `sys.path`/packaging/pyright/coverage changes and rewrites across four modules and five tests. Retained as a fully-specified fallback in Section 5(a) in case the orchestrator elects it for architectural reasons.
- Adding `scripts/dev_tools/**` and `config/**` to `ROOT_FOLDERS` / the manifest without relocation: rejected because it would broaden the push-down beyond `.claude` and change the bundle contract for all consumers, contrary to the issue's chosen direction and the existing `.claude`-only scope.

## Concrete change points for the downstream planner (Option b, recommended)

1. Add delivered copies of `compute_complexity_floor.py` and `resolve_delegation_model.py` (and a copy of `config/orchestration-routing.json`) into the source `.claude/` tree at a chosen skill-scoped location; decide whether helpers 3-5 are in scope (recommended: out of scope, served by the TS MCP surface).
2. Add the identical files to the bundle mirror `extensions/drm-copilot/resources/claude-customizations/.claude/...`.
3. Append the new `.claude/`-relative paths to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
4. Update the `.claude/`-relative citations in `.claude/skills/orchestrate/SKILL.md` (32, 34, 82, 86, 87, 96, 100), `.claude/skills/epic-orchestrate/SKILL.md` (118-119), `.claude/rules/orchestrator-state.md` (47, 61, 81, 87-91), and `.claude/agents/epic-orchestrator.md` (108) to the delivered copies, and mirror those edits in the bundle tree.
5. Decide and document the config delivery location and, if it moves, update `.claude/hooks/enforce-completion-helpers.ps1` (128) `Join-Path` and reconcile with the existing `resources/config` mirror parity test.
6. Add byte-identity parity tests (source vs `.claude` copy; `.claude` source vs bundle mirror) and a `core.json` membership test; extend the existing push-down delivery test suite to assert destination delivery.
7. State explicitly how the delivered `.claude` copies relate to `[tool.coverage.run].source` and `[tool.pyright].include` so no uncovered-production-file finding arises.
8. Run the full Python toolchain (Black, Ruff, Pyright, Pytest with coverage) and the TypeScript toolchain (for the bundle) until a single clean pass.
