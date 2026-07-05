# Research: Migrate model-routing dependencies to PowerShell under `.claude/` (Issue #312)

- Date: 2026-07-04
- Feature: `docs/features/active/2026-07-04-bundle-model-routing-deps-312`
- Canonical issue: #312
- Scope: research only; no production edits proposed.
- Builds on: `2026-07-04T2240-bundle-model-routing-deps-research.md` (same folder).

## 0. Directive under research (not re-litigated)

The user has directed: rewrite the affected Python model-routing scripts (and tests) as
PowerShell and relocate them under `.claude/`, so the `.claude`-only push-down delivers them.
This research produces the concrete migration design, the verified blast radius, and the
decision the planner must ratify. It does not challenge the PowerShell-and-relocate decision.

The one question this research must settle, because the evidence forces it: whether "all six"
can be migrated wholesale, or whether only the two runtime formulas are migratable without
either breaking the authoritative Python validator or introducing a banned subprocess seam.

## 1. Verified current state (read end-to-end)

### 1.1 The six, re-verified

| # | File | Nature | Internal imports |
|---|------|--------|------------------|
| 1 | `scripts/dev_tools/compute_complexity_floor.py` | Pure formula. Imports only `typing`, `collections.abc`. Encodes `BAND_ORDER`, `FLOOR_CANDIDATE_BAND=C3`, `FLOOR_CEILING_BAND=C3`. Reads no file. | none |
| 2 | `scripts/dev_tools/resolve_delegation_model.py` | Pure formula. Imports only `typing`. Encodes `BASE_COMPLEXITY_TO_MODEL`, `PREFERRED_OVERLAY_AGENTS`, disabled clamp. Reads no file. | none |
| 3 | `scripts/dev_tools/_orchestrator_state_complexity.py` | Validator helper. | `from scripts.dev_tools.compute_complexity_floor import BAND_ORDER, compute_complexity_floor` (line 36) |
| 4 | `scripts/dev_tools/_orchestrator_state_model_routing.py` | Validator helper. | `compute_complexity_floor.BAND_ORDER` (36); `resolve_delegation_model` symbols (37-42) |
| 5 | `scripts/dev_tools/_orchestrator_state_model_routing_gate.py` | Validator gate. | `_orchestrator_state_complexity` (40-43); `_orchestrator_state_model_routing` (44-47) |
| 6 | `config/orchestration-routing.json` | Authoritative-source JSON (`model_policy`/`model_budget`). Consumed by Python validator, TS port, and `enforce-completion-helpers.ps1`. | n/a |

Critical dependency fact (verified by reading imports): **#3 imports #1; #4 imports #1 and #2.**
Retiring the Python #1/#2 breaks the Python #3/#4 unless #3/#4 are also migrated. This chain is
the load-bearing constraint for architecture selection (Section 3).

### 1.2 The Python validator and its consumers (verified)

- `scripts/dev_tools/validate_orchestrator_state.py` imports #3 (line 29-32), #4 (37-40), #5 (41-43).
  It also imports human-interaction, pr-creation-readiness, and routing helpers (out of six-scope).
  It validates `complexity_assessments` and `model_routing_receipts` optionally (lines 456-464),
  and runs the `require_model_routing` gate when the flag is set (lines 496-498).
- The CLI (`scripts.dev_tools.validate_orchestration_artifacts`) is invoked by
  `.claude/hooks/validate-orchestrator-output.ps1`, whose `Invoke-RoutingContractValidation`
  default `Invoker` runs `python -m scripts.dev_tools.validate_orchestration_artifacts <type>
  <path> --require-complete --require-model-routing` (lines 180-188). A gate failure surfaces as
  `MODEL_ROUTING_BLOCKED:` (lines 301-303). This subprocess runs in the **full repo**, where
  `scripts/` and Python exist — not in a `.claude`-only destination.
- `.claude/hooks/enforce-model-routing-receipt.ps1` is presence-only PowerShell; it never calls
  Python and never imports #1-#5. It hard-codes the gated agent list (lines 71-78).
- `.claude/hooks/enforce-completion-helpers.ps1` reads `config/orchestration-routing.json` via a
  relative `Join-Path $PSScriptRoot '../../config/orchestration-routing.json'` (line 128) for the
  route -> `requires_pr_gate` lookup. This is the only hook that reads #6 at runtime.

### 1.3 TypeScript MCP port — authority relationship (verified by reading source)

- `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` implements
  `validateModelRoutingExistence` (lines 321-357): an **existence-only** check (delegated-agent
  set must be subset of routing-receipt-agent set). Its own docstring states (lines 314-316):
  "Full per-receipt correctness parity (model equals `resolveDelegationModel`, disabled-mode
  clamp) is out of scope for #305." The TS surface does **not** reimplement #1, #2, or the
  per-entry validators #3/#4.
- `orchestrator-state-routing.ts` ports `_orchestrator_state_routing.py` (route contract), which
  is not in the six.
- The other two grep hits (`mcp-tool-definitions.ts`, `mcp-repo-automation-tool-definitions.ts`)
  are parameter descriptions, not logic.
- Conclusion: **The Python validator remains the sole authority for per-receipt correctness**
  (floor equality and resolved-model equality). This is also stated verbatim in
  `.claude/rules/orchestrator-state.md` and `.claude/skills/orchestrate/SKILL.md` line 100. The
  destination's validation is the MCP TS existence-only check; the destination never runs #3/#4/#5.

### 1.4 How the orchestrate skill actually uses #1/#2 (verified)

`.claude/skills/orchestrate/SKILL.md` (lines 84-96, and resume steps 32/34) describes #1/#2 as
"the two canonical, tested reference implementations [that] express the formulas the orchestrator
applies by judgment." The orchestrator applies the formula and records receipts; enforcement is
the validator. So in the destination the deliverable is a **runnable, tested reference** of the
two pure formulas — exactly what a PowerShell module provides. #3/#4/#5 are not run there.

### 1.5 Push-down delivery mechanics (verified, incl. new evidence)

- The `.claude` tree is mirrored byte-for-byte to
  `extensions/drm-copilot/resources/claude-customizations/.claude/` and enforced by
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (byte-identical mirror
  assertion, exempting only `.claude/agent-memory/**`). Any new `.claude/**` file is therefore
  **mechanically required** to be copied into the bundle mirror; the contract test fails otherwise.
- `--packs core` publishes only manifest-listed `.claude/`-relative paths; no-selection publishes
  the full `.claude` tree (established in the prior artifact, Section 1.4). To be delivered under
  `--packs core`, a new path must be appended to
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- `core.json` currently lists `.claude/hooks/*.ps1` individually but does **not** list
  `.claude/hooks/enforce-completion-helpers.ps1` (the dot-sourced helper). That helper is present
  in the byte-mirror and shipped only by no-selection full-tree publish. This is a pre-existing
  manifest gap the planner should note when adding new lib paths (list them explicitly in core.json).

### 1.6 PowerShell toolchain reach over `.claude/` (verified)

- `scripts/powershell/PoshQC/PoshQC.psm1` `$script:DefaultExcludedDirs` (lines 5-9) does **not**
  exclude `.claude`. `Get-PoshQCFileList` discovers `.ps1`/`.psm1`/`.psd1` recursively. New
  `.claude/lib/**` PowerShell will be picked up by PoshQC format/analyze/test the same way
  `.claude/hooks/**` already is.
- Hook tests live at `tests/scripts/claude-hooks/*.Tests.ps1` (source `.claude/hooks/` maps to
  test dir `tests/scripts/claude-hooks/`). By the same convention `.claude/lib/` maps to
  `tests/scripts/claude-lib/`.
- `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` is a required-file allowlist,
  not a subdirectory denylist; adding `.claude/lib/` does not violate it.
- Pester config: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; PSSA settings:
  `scripts/powershell/PoshQC/settings/pssa.settings.psd1`. MCP commands per `.claude/rules/powershell.md`:
  `run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`.

### 1.7 Python packaging/coverage/type-check config (verified, `pyproject.toml`)

- `[tool.poetry].packages = [{ include = "scripts" }]` (lines 12-14).
- `[tool.coverage.run].source = ["src", "scripts/dev_tools"]` (line 103) — every
  `scripts/dev_tools/*.py` is in the coverage denominator; `.claude/**` is not.
- `[tool.pyright].include = ["scripts", "src", "tests"]` (lines 130-134); `.claude/**` is not.
- Consequence: leaving the Python #1-#5 in place requires zero packaging/coverage/pyright churn.
  New PowerShell files are measured by PoshQC/Pester, not by Python coverage.

## 2. The `.claude`-cannot-be-a-Python-package constraint is moot here

The prior artifact's central obstacle to a physical Python relocate (a dot-directory cannot be a
Python package) does not apply to PowerShell: `Import-Module ./.claude/lib/model-routing/*.psm1`
resolves by path with no package-identifier rule. This is the technical basis the directive relies
on, and it is verified: PowerShell has no leading-dot package constraint, and PoshQC already
operates over `.claude/`.

## 3. Architectures — enumerated and costed

The #3->#1 and #4->#1/#2 import chain (Section 1.1) plus the Python-validator-is-authority fact
(Section 1.3) determine the outcome.

### Architecture A — Full migration of #1-#5 to PowerShell, retire the Python versions

To retire Python #1/#2, the Python #3/#4/#5 must stop importing them. That forces one of:

- **A1 — rewrite the validator's complexity/model-routing portions in PowerShell and have the
  Python validator shell out to `pwsh`.** Rejected: `validate_orchestrator_state.py` and its
  helpers are pure Python unit-tested modules; introducing a `pwsh` subprocess into them violates
  `.claude/rules/general-code-change.md` ("core domain logic must be testable without touching the
  network or filesystem") and `.claude/rules/general-unit-test.md` ("Unit tests must not depend on
  external processes"). Every existing test for #3/#4/#5 would need a process seam.
- **A2 — rewrite the entire orchestrator-state validator (not just the model-routing parts) as
  PowerShell, delete the Python validator, and repoint `validate-orchestrator-output.ps1` to the
  PowerShell validator.** This is far larger than "the model-routing scripts": the validator also
  owns remediation-cycle, human-interaction, completion CI/PR gate, promotion-receipt, routing-
  contract, and pr-creation-readiness logic (Section 1.2). It would also invert the TS port's
  parity relationship (the TS port mirrors the Python source; it would have to mirror PowerShell
  instead) and rewrite the full Python validator test suite. Blast radius: the whole validator,
  the CLI, the hook invoker, the TS parity story, `pyproject` coverage of `scripts/dev_tools`,
  `.claude/rules/orchestrator-state.md`'s repeated "enforcement is the Python validator" prose, and
  every validator test. This exceeds issue #312's scope (bundling model-routing deps for push-down)
  by a wide margin.

Cost: A delivers literal "all five scripts as PowerShell" only by dragging in a full-validator
rewrite (A2) or a policy-violating subprocess seam (A1). Not recommended.

### Architecture B — Migrate the two runtime formulas (#1, #2); leave the validator stack intact

Two sub-variants, distinguished by whether the Python #1/#2 are deleted:

- **B-retire** (delete Python #1/#2): breaks Python #3/#4 imports -> collapses into Architecture A.
  Not viable on its own.
- **B-mirror** (recommended): **add** PowerShell implementations of #1 and #2 under `.claude/`
  for the destination runtime, **keep** the Python #1/#2 as the validator's authoritative
  reference, and leave #3/#4/#5 and the validator untouched. The two implementations of each pure
  formula are pinned to the same documented truth table by parity tests. This is the code analog of
  the already-established `config/orchestration-routing.json` dual-copy + parity-test precedent
  (`tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`).

Cost: two new PowerShell files + Pester tests; one `core.json` edit; byte-mirror copy (auto-forced
by the contract test); skill/agent citation repoints for the two formulas; zero Python module
edits; zero `pyproject` churn; zero validator/TS-port change. This delivers exactly what the
destination orchestrator executes (the two reference formulas) and what the pushed-down
`orchestrate` skill cites, with the smallest regression surface.

### Architecture C — Hybrid (PowerShell formulas that Python shells out to, or dual + behavioral cross-language parity)

Any variant that makes the Python validator invoke PowerShell at runtime, or that adds a
cross-process behavioral parity test (Pester invoking `python`, or pytest invoking `pwsh`),
violates the no-external-process unit-test rule. The only compliant "hybrid" is B-mirror's static
parity (compare embedded constants against the shared authoritative source `config/orchestration-
routing.json` `model_policy`, file-reads only). C therefore collapses into B-mirror for the
compliant case. Not recommended as a distinct path.

### Recommendation

**Architecture B-mirror.** It honors the directive (PowerShell implementations are created and live
under `.claude/`, delivered by the `.claude`-only push-down) while respecting the verified
constraints (the #3->#1/#4->#1/#2 import chain and the Python-validator-is-authority fact). It
delivers the two formulas the destination orchestrator runs and the pushed-down skill cites.

**Residual scope decision the planner/user must ratify (do not settle unilaterally):** the directive
names all six. B-mirror migrates only #1 and #2 to PowerShell; #3/#4/#5 remain Python. The evidence
shows #3/#4/#5 are validator internals that (a) are never run in a `.claude`-only destination, whose
validation is the bundled MCP TS existence-only surface, and (b) cannot be retired from Python
without either a full-validator PowerShell rewrite (Architecture A2) or a banned subprocess seam
(A1/C). If "all five scripts as PowerShell" is a hard literal requirement, the only compliant route
is Architecture A2 with the full-validator blast radius enumerated above; if the intent is "deliver
the model-routing runtime dependencies the pushed-down skill needs," B-mirror satisfies it.

## 4. Concrete change map for Architecture B-mirror

### 4.1 New PowerShell files (proposed paths, names, decomposition)

Proposed location: `.claude/lib/model-routing/` (new directory; justified below).

- `.claude/lib/model-routing/ModelRouting.psm1` — one cohesive module exporting two advanced
  functions:
  - `Get-ComplexityFloor` — port of #1 `compute_complexity_floor`. Parameter
    `[string[]] $SignalsPresent`; returns a band string (`C1`..`C4`). Embeds `BAND_ORDER`,
    `FLOOR_CANDIDATE_BAND='C3'`, `FLOOR_CEILING_BAND='C3'` as module-scope constants (matching the
    Python module's embedded constants; reads no file).
  - `Resolve-DelegationModel` — port of #2 `resolve_delegation_model`. Parameters `[string]$Agent`,
    `[string]$Band`, `[string]$FablePolicy`; returns a hashtable `@{ table_model; model;
    clamped_from; clamp_reason }` (mirrors the Python dict keys/shape). Embeds
    `BASE_COMPLEXITY_TO_MODEL`, `PREFERRED_OVERLAY_AGENTS={atomic-planner,prd-feature,feature-review,
    task-researcher}`, `PREFERRED_OVERLAY_BAND='C3'`, `PREFERRED_OVERLAY_MODEL='fable'`, disabled
    clamp to `opus` with `clamped_from='fable'`, `clamp_reason='fable_disabled'`.

Naming: `Get-` and `Resolve-` are PSScriptAnalyzer-approved verbs; nouns are descriptive. Both
functions are small (each < ~120 lines including docstrings); the combined module is well under the
500-line limit.

Location justification: `.claude/hooks/**` is the only existing `.claude/` PowerShell precedent, but
hooks are entrypoints, not reusable library functions. The idiomatic reusable-module form in this
repo is a `.psm1` (see `scripts/powershell/PoshQC/*.psm1`). A new `.claude/lib/` groups delivered,
non-hook PowerShell libraries; it is permitted by the runtime-structure allowlist (Section 1.6) and
is discovered by PoshQC. A single `.psm1` yields one manifest entry and one mirror file.

Acceptable alternative (planner's discretion): two `.ps1` files, each defining one advanced function
plus the hook-style dot-source guard `if ($MyInvocation.InvocationName -eq '.') { return }`, matching
the `.claude/hooks/enforce-completion-helpers.ps1` dot-sourced-helper precedent. State the choice
explicitly; `.psm1` is the primary recommendation.

### 4.2 Pester tests (mirrored location; translation of existing pytest cases)

- `tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1`
- `tests/scripts/claude-lib/model-routing/Resolve-DelegationModel.Tests.ps1`

Both `Import-Module` the single `ModelRouting.psm1`. Test-location rule (`general-unit-test.md`)
requires `tests/` to mirror source; the `.claude/hooks` -> `tests/scripts/claude-hooks` convention
extends to `.claude/lib` -> `tests/scripts/claude-lib`. One Tests file per function (per-behavior
isolation) is preferred; a single combined Tests file mirroring the one module is also allowed.

Case translation (deterministic, no temp files, no external processes):
- From `tests/scripts/dev_tools/test_compute_complexity_floor.py`: empty signals -> `C1`; any
  present floor signal -> `C3`; many signals still clamp to `C3` (C4 never floor-forced); ordering
  independence. Reproduce each as a `Describe/It` (use `-ForEach`/parametrized cases for the matrix).
- From `tests/scripts/dev_tools/test_resolve_delegation_model.py`: base-table cells C1->haiku,
  C2->sonnet, C3->opus, C4->fable; preferred overlay redirects only the C3 cell to fable and only
  for the four overlay agents; `atomic-executor`/`pr-author` C3 stay opus under every policy;
  disabled-mode clamp of a fable cell to opus with `clamped_from='fable'`,
  `clamp_reason='fable_disabled'`; available-mode passes the base table through.

Parity tests (compliant, file-read only — no cross-process behavioral parity):
- A static parity assertion that the PowerShell module's embedded literals equal the authoritative
  source: read `config/orchestration-routing.json` `model_policy` and assert the base table, overlay
  agent set, overlay band/model, and disabled clamp match the module constants. This mirrors the
  existing config-parity test pattern and pins both language implementations to the same source
  without invoking the other runtime. The existing pytest suites already pin the Python side.

### 4.3 `config/orchestration-routing.json` handling (#6)

- **Do not** convert #6 to `.psd1` and **do not** move it: it is read as JSON by the Python
  validator, the TS routing port (`orchestrator-state-routing.ts` `loadRoutingMatrix`), and
  `enforce-completion-helpers.ps1`. A `.psd1` or a move breaks all three JSON readers.
- The two PowerShell formulas **embed constants** (matching current Python behavior) and read no
  config at runtime, so the destination's model-selection runtime does not need #6 present.
- The only destination coupling to #6 is `enforce-completion-helpers.ps1` line 128
  (`../../config/orchestration-routing.json`, i.e. repo-root `config/`), used by
  `Test-RouteRequiresPrGate`. In a `.claude`-only destination there is no repo-root `config/`, so
  that reader returns `$null` and `Test-RouteRequiresPrGate` degrades to `$false` (no PR-gate route
  match). This is a **pre-existing** coupling independent of #312, not introduced by this change.
- Recommendation: keep #6 as JSON in place. Treat "deliver a `.claude`-resident config copy and
  repoint the hook's `Join-Path`" as a separable, explicitly-flagged sub-decision (it also touches
  the existing `extensions/drm-copilot/resources/config/orchestration-routing.json` mirror parity
  test). #312's runtime deliverables (the two formulas) do not require it.

### 4.4 Skill / rule / agent / hook reference repoints

Under B-mirror, split the citations by role:

- **Repoint (orchestrator-runs-the-reference citations) to the PowerShell path/functions** so the
  delivered skill is coherent in the destination (where no `scripts/*.py` exists):
  - `.claude/skills/orchestrate/SKILL.md`: line 32 (`compute_complexity_floor.py`), line 34
    (`resolve_delegation_model.py`), line 86 (`compute_complexity_floor.py`), line 87
    (`resolve_delegation_model.py`).
  - `.claude/skills/epic-orchestrate/SKILL.md`: lines 118-119 (both formulas).
  - Each repoint targets `.claude/lib/model-routing/ModelRouting.psm1` and the function name
    (`Get-ComplexityFloor` / `Resolve-DelegationModel`).
- **Leave pointing at Python (validator-authority citations)** because under B-mirror the Python
  validator remains authoritative and repo-side:
  - `.claude/rules/orchestrator-state.md`: line 47 (floor "reference implementation in
    `scripts/dev_tools/compute_complexity_floor.py`"), line 61 (resolved-model reference in
    `resolve_delegation_model.py`), lines 81/87-91 (validator/helper enforcement prose).
  - `.claude/skills/orchestrate/SKILL.md`: line 96 (validator enforcement), line 100 (gate
    `_orchestrator_state_model_routing_gate.py`, "Python validator is authoritative").
  - These are delivered to the destination too (all in `core.json`), where they describe repo-side
    authority; the destination's own validation is the MCP TS surface. This split is coherent but is
    a judgment call — flag it for the planner. Optionally add one sentence to `orchestrate/SKILL.md`
    noting the destination runtime reference is the PowerShell module while the repo validator
    remains the Python authority.
- **Config citation:** `.claude/agents/epic-orchestrator.md` line 108 references
  `config/orchestration-routing.json`; unchanged unless the config sub-decision (4.3) moves it.
- **Bundle mirror:** every edit above must be duplicated in the byte-mirror under
  `extensions/drm-copilot/resources/claude-customizations/.claude/...`; the resource-contract test
  (Section 1.5) fails otherwise. This is mechanical, not discretionary.

(Line numbers cross-checked against the prior artifact Section 2.3 and re-verified where read in this
pass; the planner should re-confirm exact offsets at edit time since edits shift lines.)

### 4.5 Push-down / `core` manifest

- Append to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
  `paths[]`: `.claude/lib/model-routing/ModelRouting.psm1` (or the two `.ps1` paths if the alternate
  decomposition is chosen). This makes `--packs core` deliver them; no-selection already delivers
  the full tree.
- Copy the new file(s) into the byte-mirror
  `extensions/drm-copilot/resources/claude-customizations/.claude/lib/model-routing/...` (enforced by
  `test_push_down_claude_resource_contracts.py`).

### 4.6 Python-side disposition

| Item | Disposition | Edits required |
|------|-------------|----------------|
| #1 `compute_complexity_floor.py` | KEPT (validator authority) | none |
| #2 `resolve_delegation_model.py` | KEPT (validator authority) | none |
| #3 `_orchestrator_state_complexity.py` | KEPT | none |
| #4 `_orchestrator_state_model_routing.py` | KEPT | none |
| #5 `_orchestrator_state_model_routing_gate.py` | KEPT | none |
| `validate_orchestrator_state.py` | KEPT | none |
| `pyproject.toml` (`poetry.packages`, `coverage.run.source`, `pyright.include`) | KEPT | none |

No Python import is repointed; no `scripts.dev_tools.*` reference changes; the existing five pytest
files under `tests/scripts/dev_tools/` are untouched. This is the strongest backward-compatibility
guarantee among the architectures.

### 4.7 PowerShell toolchain the new files must pass

- Format: `run_poshqc_format` (Invoke-Formatter) — 100% pass.
- Analyze: `run_poshqc_analyze` (PSScriptAnalyzer, `pssa.settings.psd1`) — 0 findings; approved
  verbs, `CmdletBinding()`, `[OutputType(...)]`, parameter validation attributes, no
  `Invoke-Expression`, no hard-coded paths.
- Test: `run_poshqc_test` (Pester 5.x, `pester.runsettings.psd1`) — line >= 85%, branch >= 75%.
  Pure functions with an exhaustive small input matrix reach full coverage easily. Both functions
  are deterministic (no clock/RNG/IO), satisfying the determinism-infrastructure rule trivially.
- Tier: these are dev-tooling/scaffolding analogs (T4), but coverage thresholds are uniform across
  tiers.

## 5. Behavior semantics (success / failure / edges)

- Success: after the change, both the no-selection and `--packs core` `.claude`-only push-down
  deliver `.claude/lib/model-routing/ModelRouting.psm1`; the delivered `orchestrate` skill cites a
  path that exists in the destination; the repo Python validator, its five pytest files, Pyright,
  and coverage remain green in a single pass; PoshQC format/analyze/Pester pass in a single pass;
  the byte-mirror and manifest-membership contract tests pass.
- `Get-ComplexityFloor` semantics: no floor signal -> `C1`; >=1 floor signal -> `C3`; never `C4`;
  order-independent; reads no file.
- `Resolve-DelegationModel` semantics: base table C1/C2/C3/C4 -> haiku/sonnet/opus/fable; preferred
  overlay flips only C3, only for the four overlay agents; disabled clamp turns a fable table cell
  into opus with recorded provenance; available passes base through; an out-of-table band is a
  `KeyError` analog (the caller/validator owns band-enum validity).
- Failure modes to avoid: deleting the Python #1/#2 (breaks #3/#4 — do not); converting #6 to
  `.psd1` (breaks JSON readers — do not); forgetting the byte-mirror copy (contract-test failure);
  omitting the `core.json` entry (skill delivered with a dangling reference under `--packs core`);
  a cross-process parity test (unit-test-purity violation).

## 6. Requirements mapping (acceptance criteria -> design)

- "Model-routing dependency reachable under `.claude/` and delivered by push-down" -> 4.1 + 4.5
  (PowerShell module under `.claude/lib/`, mirror copy, `core.json` entry).
- "Skill references and validator import paths resolve with no broken references" -> 4.4 (repoint
  the orchestrator-runs citations to the PowerShell module; validator-authority citations stay
  Python) + 4.6 (Python imports unchanged, so validator resolves).
- "`core` pack manifest lists the relocated dependencies" -> 4.5.
- "All existing `tests/scripts/dev_tools/` tests pass and full toolchain passes single-pass" -> 4.6
  (Python untouched) + 4.7 (new PowerShell passes PoshQC/Pester); the two toolchains (Python and
  PowerShell) both run.

## 7. Testing implications (no test code authored here)

- New Pester tests per 4.2 (behavioral matrices translated from the two pytest files; static
  config-parity assertion).
- Manifest-membership test: assert `.claude/lib/model-routing/ModelRouting.psm1` appears in
  `core.json` `paths[]` (small JSON-membership assertion; extend an existing push-down pack test
  such as `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`).
- Byte-mirror coverage is already enforced by `test_push_down_claude_resource_contracts.py`; no new
  parity harness is needed for the mirror.
- Existing `tests/scripts/dev_tools/` suite remains green unchanged (Python untouched).
- Coverage: new PowerShell measured by Pester; no new Python production file, so no
  uncovered-Python-file finding; `pyproject` coverage/pyright unchanged.

## 8. Rejected alternatives (brief)

- Architecture A1 (Python validator shells out to `pwsh`): rejected — subprocess in pure unit-tested
  Python violates `general-unit-test.md`/`general-code-change.md`.
- Architecture A2 (rewrite the entire Python validator as PowerShell): rejected as the default —
  scope far exceeds "model-routing scripts"; inverts the TS-port parity relationship; rewrites the
  whole validator test suite and `orchestrator-state.md` enforcement prose. Retained only as the
  sole compliant route **if** the user makes "all five scripts as PowerShell" a hard literal
  requirement.
- B-retire (delete Python #1/#2): rejected — breaks #3->#1 and #4->#1/#2 imports; collapses to A.
- Convert #6 to `.psd1` or relocate it: rejected — breaks the Python validator, the TS routing port,
  and the completion-helper hook, all of which read it as JSON.

## Automation Feasibility

This change is filesystem- and code-only and fully automatable by an autonomous agent: create the
PowerShell module under `.claude/lib/model-routing/`, add Pester tests under
`tests/scripts/claude-lib/model-routing/`, edit Markdown skill/agent citations (source and byte-
mirror), append one path to `core.json`, copy the module into the bundle mirror, and run the two
local toolchains (PowerShell: PoshQC format/analyze + Pester; Python: Black/Ruff/Pyright/Pytest for
the untouched suite; TypeScript: the bundle contract tests). There is no third-party UI, portal, or
external-service interaction (no Azure/Entra, Outlook, or M365 admin surface). No human-interaction
requirement was discovered; there are no mandatory-unachievable requirements to record under
`human_interaction.requirements[]`. Verification is automatable: Pester behavioral + static parity
tests, the manifest-membership test, the pre-existing byte-mirror contract test, and the standard
per-language toolchain loops confirm success without manual intervention.

## 9. Execution-ready change list (Architecture B-mirror, recommended)

1. Create `.claude/lib/model-routing/ModelRouting.psm1` exporting `Get-ComplexityFloor` (port of #1)
   and `Resolve-DelegationModel` (port of #2), embedding the same constants the Python modules
   embed; reads no file; PSSA-clean advanced functions with docstrings.
2. Create `tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1` and
   `Resolve-DelegationModel.Tests.ps1` translating the two existing pytest truth-table suites, plus
   a static parity assertion reading `config/orchestration-routing.json` `model_policy`.
3. Append `.claude/lib/model-routing/ModelRouting.psm1` to
   `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` `paths[]`.
4. Copy the new module into the byte-mirror
   `extensions/drm-copilot/resources/claude-customizations/.claude/lib/model-routing/ModelRouting.psm1`.
5. Repoint the orchestrator-runs-the-reference citations for the two formulas to the PowerShell
   module in `.claude/skills/orchestrate/SKILL.md` (lines 32, 34, 86, 87) and
   `.claude/skills/epic-orchestrate/SKILL.md` (lines 118-119); mirror these edits in the bundle tree.
   Leave validator-authority citations (`.claude/rules/orchestrator-state.md` lines 47, 61, 81,
   87-91; `.claude/skills/orchestrate/SKILL.md` lines 96, 100) pointing at Python; optionally add one
   sentence distinguishing destination runtime reference (PowerShell) from repo validator authority
   (Python).
6. Leave all Python (#1-#5, the validator) and `pyproject.toml` unchanged.
7. Treat the `config/orchestration-routing.json` destination-delivery and the
   `enforce-completion-helpers.ps1` `Join-Path` as a separate, explicitly-flagged sub-decision (not
   required by #312's runtime deliverables); keep #6 as JSON in place.
8. Add a manifest-membership test asserting the new path is in `core.json`; rely on the existing
   byte-mirror contract test for mirror parity.
9. Run PoshQC (format -> analyze -> Pester) and the Python + TypeScript contract toolchains until a
   single clean pass each.
10. Ratify the residual scope decision with the user/planner before merge: B-mirror migrates #1/#2
    only; migrating #3/#4/#5 to PowerShell requires Architecture A2 (full-validator rewrite) with the
    blast radius in Section 3.
