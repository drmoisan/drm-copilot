# Research: Enforcement Hooks Must Not Invoke Python (Issue #475)

- Timestamp: 2026-08-15T09-00
- Issue: #475
- Scope: Remove Python from the enforcement-hook surface, keep hooks in PowerShell, add a reappearance guard. Bash port explicitly out of scope.
- Method: Read-only file analysis. No Python was executed. Every claim below cites a file path and line number; claims verified only by code reading (not runtime) are marked as such.

## 1. Current State Analysis

### 1.1 Invocation inventory (re-verified)

The four-site inventory in `issue.md` is confirmed. A case-insensitive scan of `.claude/hooks/**` and `.claude/lib/**` for `python|poetry` found no additional invocation site.

| # | Site | Invocation |
| --- | --- | --- |
| 1 | `.claude/hooks/enforce-discovery-artifact-gate.ps1:50` | `& python -m scripts.dev_tools.validate_discovery_artifacts @ValidatorArgs 2>&1` |
| 2 | `.claude/hooks/validate-discovery-artifact-gate.ps1:53` | same invocation |
| 3 | `.claude/hooks/validate-orchestrator-output.ps1:196-197` | `& python -m scripts.dev_tools.validate_orchestration_artifacts $Type $Path --require-complete --require-model-routing 2>&1` |
| 4 | `.claude/lib/orchestrator-state/OrchestratorState.psm1:367` (probe `& python -c 'import ...'`) and `:451-452` (`& python -m ... orchestrator-state $Path --require-pr-creation-ready 2>&1`) |

The six incidental-mention hooks are confirmed as invocation-free: `check-python-test-purity.ps1`, `enforce-evidence-locations.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-python-batch-budget.ps1`, `validate-executor-output.ps1`, `validate-feature-review-coverage.ps1`. Additional invocation-free mention sites found (comments/docstrings only, no code change needed): `enforce-parallel-drift-gate.ps1:27-41`, `enforce-parallel-drift-gate-helpers.ps1` (comments), `enforce-model-routing-receipt.ps1:15` (comment). All `.claude/lib/blast-radius/*.psm1`, `ModelRouting.psm1`, and `.claude/lib/bash/*.sh` mention Python only in comments.

Guard-relevant detail: several hooks define PowerShell functions whose names contain the substring `Python` and which are invoked as commands — for example `Invoke-PythonTestPurityDecision` (`check-python-test-purity.ps1:61,144`) and `Invoke-PythonBatchBudgetHook` (`enforce-python-batch-budget.ps1:147,232`). A guard matching command names by substring would false-positive on these; exact-name matching is required (section 5).

### 1.2 Hook wiring (`.claude/settings.json`)

- `enforce-discovery-artifact-gate.ps1` — PreToolUse `Write|Edit` group (`settings.json:172`).
- `validate-discovery-artifact-gate.ps1` — SubagentStop broad matcher (`settings.json:220`).
- `validate-orchestrator-output.ps1` — SubagentStop three times: `orchestrator` (default params, `settings.json:256`), `epic-orchestrator` (`-ArtifactType epic-orchestrator-state`, `:265`), `parallel-orchestrator` (`-ArtifactType parallel-orchestrator-state`, `:274`).
- `enforce-pr-author-skill.ps1` (PreToolUse Bash, `settings.json:107`) reaches Python indirectly via `Invoke-OrchestratorStatePreflight` (`enforce-pr-author-skill.ps1:323`).

### 1.3 Defects discovered during research (pre-existing, code-reading evidence)

**D-1 — Epic/parallel wiring passes flags the Python CLI rejects.** The hook's default invoker passes `--require-complete --require-model-routing` for every `$Type` (`validate-orchestrator-output.ps1:196-197`). The `epic-orchestrator-state` subparser accepts only `--require-complete`, `--require-codex-model-routing`, `--require-codex-topology`; `parallel-orchestrator-state` accepts only `--require-complete` (`scripts/dev_tools/validate_orchestration_artifacts.py:231-270`). Neither defines `--require-model-routing`, so argparse exits 2 with a usage error whenever the Python branch runs with either of those artifact types, and the hook maps the usage text to `ROUTING_CONTRACT_BLOCKED` regardless of checkpoint content. The portable fallback is equally wrong for those types: `Test-OrchestratorStateCompletionReadiness` ignores `$Type` and applies the standard-checkpoint `REQUIRED_STATE_KEYS` (`OrchestratorStateCompletion.psm1:196-241`, `OrchestratorState.psm1:37-60`), which an epic or parallel checkpoint does not carry. Not runtime-verified; both code paths were read end to end. The replacement must dispatch on `$ArtifactType`, and the feature should decide the epic/parallel behavior explicitly instead of inheriting this.

**D-2 — Discovery hooks deny on the validator's success line.** Both discovery hooks treat non-empty output as failure: `if ($result.ExitCode -ne 0 -or $hasErrorOutput) { deny }` (`enforce-discovery-artifact-gate.ps1:183-184`, `validate-discovery-artifact-gate.ps1:217-218`). The Python CLI prints `"{type} validation passed: {path}"` to stdout on success (`validate_discovery_artifacts.py:213`), and the seam captures with `2>&1`, so a real passing validation would still produce a deny. `validate-orchestrator-output.ps1:228-232` documents and fixes exactly this hazard (exit code is the sole discriminator); the discovery hooks never received that fix. It is latent only because the gate is currently inert (section 2.3). The PowerShell replacement should adopt the exit-code-only discriminator or return empty output on success.

## 2. Q1 — Discovery-artifact validator surface

### 2.1 CLI contract as the hooks use it

Both hooks call `python -m scripts.dev_tools.validate_discovery_artifacts <artifact-type> <path>` with exactly two positional arguments (`enforce-discovery-artifact-gate.ps1:182`, `validate-discovery-artifact-gate.ps1:216`), where `<artifact-type>` is one of the eight tokens produced by `Get-DiscoveryArtifactType` (`profile`, `feature-contract`, `coverage-ledger`, `runtime-scenario`, `parity-matrix`, `unspecified-behavior`, `product-decision`, `evidence-reference`). The `all` subcommand and the eight `main_*` console-script entry points (`validate_discovery_artifacts.py:113,217-254`) are never reached from the hooks.

Exit-code contract: 0 with one stdout success line on pass; 1 with one error string per stderr line on fail (`validate_discovery_artifacts.py:206-214`). The hooks parse nothing from the text; they check `$LASTEXITCODE` and output emptiness (subject to defect D-2) and prefix the combined output with `DISCOVERY_ARTIFACT_GATE_BLOCKED:`.

### 2.2 Rule inventory

**`profile` → `validate_profile_text` (`scripts/dev_tools/validate_discovery_profile.py`, 119 lines):**
1. Empty/whitespace text → `["Profile document is empty."]` (:111-112).
2. `yaml.safe_load` failure → `["Profile document is not valid YAML: <exc>"]` (:48-51).
3. Non-mapping root → `["Profile document root must be a mapping."]` (:53-54).
4. Required-field check: exactly one placeholder field, `legacy_source_path`; each absence yields `"Missing required field: <field>."` (:24, :80-85). The module's docstring records this as a placeholder pending #9001's final contract.

**Seven schema types → `validate_<type>_text` (`scripts/dev_tools/validate_discovery_schema_artifacts.py`, 190 lines), all delegating to `_validate_against_schema` (:93-140):**
1. `json.loads` failure → `["invalid JSON (<exc>)"]`.
2. Non-object root → `["JSON root must be an object for validation"]`.
3. `$schema` extraction: absent or non-string/empty → `ValueError("missing $schema")` reported as `["schema resolution failed (<exc>)"]` (:66-90, :132-136). Because the text API passes no `base_path`, only `file://` and `http(s)://` URIs can resolve; a scheme-less URI fails resolution (:105-106 of `schema_loading.py` via `base_path=None` at :88-90).
4. `load_schema` (`scripts/dev_tools/schema_loading.py`, 118 lines): `file://` → local read with existence check; `http(s)://` → fetch once via `urllib.request.urlopen`, cached under `.cache/schemas/<sha256(uri)>.json`; other schemes → `ValueError`.
5. Draft 2020-12 validation via `jsonschema.Draft202012Validator.iter_errors`, errors sorted by path, formatted `"{list(err.path)}: {err.message}"` (:138-140).

The seven versioned schemas live locally at `schemas/discovery/v1/*.schema.json` (7 files).

### 2.3 The gate is currently inert in production

In both hooks, the validator is invoked only when `Get-RequiredDiscoveryArtifactDeclaration` reports `Present = $true`, and its default `$ProfileReader` is `{ $null }`, which always yields `Present = $false` → fail-open allow (`enforce-discovery-artifact-gate.ps1:115-129,176-180`; `validate-discovery-artifact-gate.ps1:118-132,208-212`; both marked `TODO(#9001)`). Consequently the Python invocation in the discovery hooks is unreachable outside tests, and every test reaches it only through a mock of `Invoke-DiscoveryValidatorExe`. The faithful-behavior bar for a replacement is therefore the seam contract — `Invoke-DiscoveryValidatorExe -ValidatorArgs <string[]>` returning `@{ ExitCode; Output }` — plus the CLI rule inventory above, not any live traffic.

### 2.4 Port sizing

- `profile`: small. YAML-mapping parse plus one key check. PowerShell has no built-in YAML parser; given the placeholder contract, a top-level-key presence check (line-anchored `legacy_source_path:` scan plus basic YAML-failure handling) is defensible if documented against `TODO(#9001)`; a full YAML parser is not warranted.
- Seven schema types: the rule set itself is thin (five steps), but step 5 is a full JSON Schema Draft 2020-12 validation via the `jsonschema` library. A hand-written PowerShell port of Draft 2020-12 is not feasible within repo constraints. The viable native mechanism is `Test-Json -SchemaFile`, which in PowerShell 7.4+ is backed by JsonSchema.Net with Draft 2020-12 support; earlier 7.x releases do not support 2020-12. This is a hard implementation dependency to verify against the repo's minimum supported PowerShell version before planning (unverified in this research; the repo policy states "PowerShell 7+" without a minor floor, `.claude/rules/powershell.md`).
- `$schema` resolution: `file://` handling is trivial; the `http(s)://` fetch-and-cache path would need `Invoke-WebRequest` plus a SHA-256 cache. Given the local `schemas/discovery/v1/` files and the inert gate, restricting the PowerShell replacement to `file://` (and reporting other schemes as `schema resolution failed (...)`, matching the Python error family) is a reasonable scope cut to record as a documented divergence.
- Error-string parity: not contractually required. The hooks never parse validator text; they embed it verbatim after `DISCOVERY_ARTIFACT_GATE_BLOCKED:`. Exact byte parity with `jsonschema` messages is unattainable via `Test-Json` and should be explicitly declared a non-goal.

## 3. Q2 — Orchestration validator: hook call vs PowerShell mirror gap list

### 3.1 Verified hook call

`Invoke-RoutingContractValidation`'s default invoker runs `python -m scripts.dev_tools.validate_orchestration_artifacts $Type $Path --require-complete --require-model-routing` with `$Type` defaulting to `orchestrator-state` (`validate-orchestrator-output.ps1:185-197`). The belief stated in the delegation prompt is confirmed, with the addition that `$Type` is parameterized and takes the values `epic-orchestrator-state` and `parallel-orchestrator-state` from `settings.json` (see defect D-1). The `enforce-pr-author-skill` path runs `orchestrator-state $Path --require-pr-creation-ready` (`OrchestratorState.psm1:451-452`).

### 3.2 Python check inventory for `orchestrator-state --require-complete --require-model-routing`

From `scripts/dev_tools/validate_orchestrator_state.py:387-507` and its helpers:

Unconditional block:
- U1. JSON parse; object root (:405-412).
- U2. 22 `REQUIRED_STATE_KEYS` presence (:69-92, :416-418).
- U3. Step-status vocabulary incl. per-key extras (`_orchestrator_state_step_status.py::collect_step_status_errors`, :112).
- U4. `blocked_reason` enum (:426-428).
- U5. `delegation_receipts` shape: list form (8 `REQUIRED_RECEIPT_KEYS` per receipt, `artifact_paths` list, :277-318), namespaced form (`agents`/`promotion` keys only, promotion sub-keys, :321-384), or type error.
- U6. Optional-key validators when present (:447-463): `remediation_loop` cycles (:142-228), `human_interaction`, `complexity_assessments` (`_orchestrator_state_complexity.py`), `model_routing_receipts` (`_orchestrator_state_model_routing.py`), `codex_model_routing_receipts`, `codex_topology_receipts`.

`--require-complete` block (:472-491):
- C1. Completion-blocking step statuses (`collect_completion_blocking_step_errors`, `_orchestrator_state_step_status.py:151`).
- C2. `blocked_reason` must be absent/`none` (:478-481).
- C3. PR gate (`validate_completion_pr_gate`, `_orchestrator_state_routing.py:293`; `PR_GATE_KEYS = pr_number, pr_url, head_branch, head_sha`; route-gated via the routing matrix).
- C4. CI gate when the route requires it (`route_requires_ci_gate` reads `config/orchestration-routing.json`, `_orchestrator_state_routing.py:107`; `_validate_completion_ci_gate` requires object with `conclusion == success` and `head_sha` matching `pr_gate.head_sha`, `validate_orchestrator_state.py:243-274`).
- C5. Phase completeness per route (`validate_phase_completeness`, `_orchestrator_state_routing.py:202`, `MANDATORY_ROUTE_PHASES`).
- C6. Routing contract (`validate_routing_contract`, `_orchestrator_state_routing.py:530`: receipt agents/skills/MCP tools versus route requirements, lifecycle operations, empty-list fields).
- C7. Preparation-terminal contract (`_orchestrator_state_preparation_terminal.py:18`).

`--require-model-routing` block (:498-500):
- M1. Existence gate once delegated: routing-receipt agent set ⊇ delegated-agent set (`_orchestrator_state_model_routing_gate.py:85-223`).
- M2. Complexity assessment required per phase matched by a routing receipt (:132-223).
- M3. Per-entry consistency by reuse of `_validate_complexity_assessments` (band enum, band >= floor, floor == `compute_complexity_floor`, non-empty rationale) and `_validate_model_routing_receipts` (model == `resolve_delegation_model`, disabled-mode clamp).

### 3.3 What PowerShell already mirrors

- U1, U2, U3, U4 — `Get-OrchestratorStateCheckpoint` + `Get-OrchestratorStateBasePresenceError` (`OrchestratorState.psm1:126-288`), constants pinned to the Python names.
- M1 only — `Get-OrchestratorStateModelRoutingGateError` (`OrchestratorStateCompletion.psm1:149-194`), presence-level by documented design (its header names deep per-receipt correctness a Non-Goal).
- The pr-author path: `Test-OrchestratorStatePrCreationReadiness` mirrors `--require-pr-creation-ready` (steps 5-8 not pending/blocked, `blocked_reason` clear, empty override lists; `OrchestratorState.psm1:290-344,374-416`).
- Human interaction — implemented directly in the hook (`Test-HumanInteractionShape`, `validate-orchestrator-output.ps1:68-150`), and it is stricter than the Python shape check: it blocks `halt` and verifies runbook file existence.
- The model formulas `Get-ComplexityFloor` and `Resolve-DelegationModel` exist as tested PowerShell ports (`.claude/lib/model-routing/ModelRouting.psm1`, exported at :229; parity tests at `tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1`). They are available but not wired into any PowerShell validation.

### 3.4 Gap list (Python-only checks with no PowerShell equivalent, for the hook's call)

| Gap | Python source | Size/complexity notes |
| --- | --- | --- |
| U5 delegation_receipts shape (list + namespaced) | `validate_orchestrator_state.py:277-384` | Small-medium; pure structure |
| U6 remediation_loop cycle invariants | `validate_orchestrator_state.py:142-228` | Small; three invariants |
| U6 complexity_assessments per-entry | `_orchestrator_state_complexity.py` (~200 lines) | Medium; floor recompute available via `Get-ComplexityFloor` |
| U6 model_routing_receipts per-entry | `_orchestrator_state_model_routing.py` (~200 lines) | Medium; model recompute available via `Resolve-DelegationModel` |
| U6 codex receipts + codex topology | `_orchestrator_state_codex_model_routing.py`, `_orchestrator_state_codex_topology.py` | Optional-key only; fires only when keys present |
| C1 completion-blocking step statuses | `_orchestrator_state_step_status.py:151` | Small |
| C2 blocked_reason none at completion | `validate_orchestrator_state.py:478-481` | Trivial (PR-readiness analogue already exists) |
| C3 pr_gate completeness | `_orchestrator_state_routing.py:259-338` | Medium; reads routing matrix |
| C4 ci_gate object + head_sha match | `validate_orchestrator_state.py:243-274` + `routing.py:107` | Medium; route-gated via `config/orchestration-routing.json` |
| C5 phase completeness | `_orchestrator_state_routing.py:202` | Medium |
| C6 routing contract | `_orchestrator_state_routing.py:339-560` | Largest single gap; receipt/skill/MCP-tool set logic |
| C7 preparation-terminal contract | `_orchestrator_state_preparation_terminal.py` (~60 lines) | Small |
| M2 assessment-per-matched-phase | `_orchestrator_state_model_routing_gate.py:132-223` | Small once U6 complexity port exists |
| M3 per-entry reuse in the gate | same | Follows from U6 ports |

Aggregate faithful-parity port size: `validate_orchestrator_state.py` (508 lines) + `_orchestrator_state_routing.py` (~560) + step-status (~190) + complexity (~200) + model-routing (~200) + gate (~260) + preparation-terminal (~60), roughly 1,900 Python lines of validation logic. Under the 500-line file cap this is four to six new PowerShell library files plus tests — a large port. The C4/C6 checks additionally read `config/orchestration-routing.json` at validation time, which the portable modules deliberately avoid (they hard-code pinned constants; see `ModelRouting.psm1:33-39` rationale), so a full port must also decide how a destination repository without that config behaves.

## 4. Q3 — OrchestratorState.psm1 deference removal

### 4.1 Deletion is safe and leaves a self-sufficient readiness path

`Test-PythonOrchestratorValidatorAvailable` (`OrchestratorState.psm1:346-372`) has exactly two production callers: `OrchestratorState.psm1:450` (inside `Invoke-OrchestratorStatePreflight`'s default `$Invoker`) and `validate-orchestrator-output.ps1:195` (inside `Invoke-RoutingContractValidation`'s default `$Invoker`). It is exported at :496. `Invoke-OrchestratorStatePreflight` has one production caller: `enforce-pr-author-skill.ps1:323`.

Deleting the probe and both Python legs leaves:
- Preflight path (pr-author): default invoker collapses to `Test-OrchestratorStatePrCreationReadiness -CheckpointPath $Path`, which is complete for the `--require-pr-creation-ready` semantics (base presence + readiness; fail-closed on missing/invalid checkpoint). Delta to document: the Python plain-call layer also runs U5/U6 (receipt shape and optional-key validators) before the readiness gate; the PowerShell mirror runs only base presence + readiness, so those error classes disappear from the preflight verdict unless ported (section 3.4).
- Completion path (validate-orchestrator-output): default invoker collapses to the portable `Test-OrchestratorStateCompletionReadiness`, with the section 3.4 gap list applying and defect D-1 needing an explicit dispatch decision.

### 4.2 Seam disposition

`Invoke-OrchestratorStatePreflight`'s `[scriptblock] $Invoker` seam (`OrchestratorState.psm1:443-465`) does not become dead: four direct seam tests inject it (`tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1:250-273`), and the `{ExitCode,Output} → {HasErrors,ErrorText}` translation plus the strict-mode property guard (:467-481) remain load-bearing. Recommendation: retain the seam, simplify the default body. The same holds for `Invoke-RoutingContractValidation`'s `$Invoker` (`validate-orchestrator-output.ps1:188-216`); the guarded `Import-Module` of the completion module (:206-208) stays.

### 4.3 Tests that mock or assert the Python branch (must change)

- `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1:289-325` — Context `capability detection (portable-path routing)`: probe mocked `$false` (:295, :321) and `$true` (:309). The `$true` test asserts the Python-CLI branch is selected; both `$true`-branch tests must be deleted or rewritten; the `$false`-branch tests become the default behavior with the mocks removed.
- `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1:448-485` — probe mock at :468; and the test at :476-484 asserts the literal source text `python -m scripts\.dev_tools\.validate_orchestration_artifacts` plus both flags inside the default invoker. That test pins the exact string being removed and must be replaced (its natural successor is an assertion that the default invoker contains no `python` CommandAst, or that it calls the portable function).
- `tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1:123-152` — probe mocked `$false` at :127 and :143 to force the portable path; after removal the mocks are deleted (Pester `Mock` of a no-longer-existing command fails at mock-registration time, so leaving them in place breaks the suite).
- `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:54-90` — the end-to-end test runs the real default `$Invoker` against a deliberately nonexistent checkpoint; both the Python leg and the portable leg report the missing checkpoint fail-closed, so the verdict is unchanged. Only the comment at :72-75 (naming the "Python validator subprocess") needs updating. This test is the closest existing thing to the acceptance criterion's "same verdict" property.
- Unaffected: the eleven `Mock -CommandName Invoke-OrchestratorStatePreflight` sites across `enforce-pr-author-skill.Tests.ps1` (:128-352), `enforce-pr-author-skill.epic-base-branch.Tests.ps1:91`, and `.OrchestratorStatePreflight.Tests.ps1:30,43`; `OrchestratorStateCompletion.Tests.ps1`; `OrchestratorState.Manifest.Tests.ps1`.

## 5. Q4 — Guard design

### 5.1 Invocation syntaxes to detect

Detection should be AST-based (`[System.Management.Automation.Language.Parser]::ParseInput`), classifying every `CommandAst`:

1. Bare or `&`/`.`-invoked constant command whose `GetCommandName()` is exactly one of `python`, `python3`, `py`, `poetry` (case-insensitive). This covers `& python`, `python -m`, `&'python'`, `& "python"` (quoted constants still yield the name), and `poetry run ...`.
2. `Start-Process` whose `-FilePath` argument (or first positional) is a constant matching the same name set.
3. Indeterminate dynamic invocation: a `CommandAst` whose command element is a variable or expression (`& $pythonExe`, `. $tool`). Statically undecidable; the guard should fail these in `.claude/hooks/**`/`.claude/lib/**` PowerShell files outright (fail-closed), because no current hook uses the pattern — verified: the only dynamic invocations in the hooks are `& $ProfileReader`/`& $RequiredArtifactReader`/`& $Invoker`/`& $FileExistsCheck` scriptblock-parameter calls, which are `ScriptBlock`-typed parameters, distinguishable in the AST (the invoked element is a `VariableExpressionAst` bound to a `[scriptblock]` parameter within the same file). If distinguishing proves noisy, a pragmatic v1 is: flag dynamic invocation only when the variable name matches `(?i)python|poetry|py\b`, and document the residual gap.
4. `Invoke-Expression` in any form. Already prohibited repo-wide by `.claude/rules/powershell.md`; zero occurrences exist in the hooks today, so flagging every `Invoke-Expression` under the guard scope costs nothing and closes the string-assembly loophole.

Why AST rather than regex: the six incidental hooks carry `python`/`poetry run` only inside string literals (violation messages, regex literals such as `enforce-orchestration-preimplementation-gate.ps1:65`, artifact paths) and comments — none of which produce a `CommandAst`. Exact-name matching additionally protects the `Invoke-Python*` function calls (section 1.1). This makes the no-false-positive requirement structural instead of pattern-tuned.

### 5.2 Closest existing precedent

`tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` is the house pattern for a repository-wide policy guard: `BeforeAll` resolves the scan root by walking up from `$PSScriptRoot` (CWD-independent, :20-31), a helper function performs AST analysis (`Get-AdapterIdCollision`, :295-396), in-memory fixture `It`s prove the detection logic (:400-471), and one repository-scan `It` enumerates files with `Get-ChildItem -Recurse` and asserts zero findings with the finding list in `-Because` (:474-494). A second, lighter precedent for asserting a pinned textual contract over `.claude` files is `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1`. The new guard should mirror the first file's structure, in the same `tests/scripts/claude-runtime/` directory.

### 5.3 Where the guard should live — recommendation

A single Pester test under `tests/scripts/claude-runtime/` (suggested name: `enforcement-hooks-no-python-invocation.Tests.ps1`), with fixture `It`s for each detected syntax class and each non-detection class (string literal, comment, `Invoke-Python*` function call, scriptblock-parameter `&` call), plus one repository-scan `It`.

Reasoning:
- CI coverage is automatic: `ci.yml:24` → `_poshqc.yml` runs `Invoke-PoshQCTest -Root <workspace>` (:42), which executes the whole `tests/` tree. No new workflow step is needed.
- A PreToolUse hook variant would only fire inside Claude Code sessions, cannot protect edits made outside sessions, and would itself be a hook needing the same guarantee. Not recommended as the primary mechanism.
- The bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/**` needs no second scan: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:107-123` already asserts the bundle is text-identical to the repo root files, so the root-tree guard covers the bundle transitively.

### 5.4 Scope — include `.claude/lib/**`

Yes. `OrchestratorState.psm1` is the indirect Python path behind `enforce-pr-author-skill.ps1`; guarding only `.claude/hooks/**` leaves the defect reproducible one `Import-Module` away. Recommended glob: `.claude/hooks/**/*.ps1` plus `.claude/lib/**/*.ps1` and `.claude/lib/**/*.psm1`. Exclude `.claude/lib/bash/**` (`*.sh` — a PowerShell AST parse does not apply, and those files mention Python only in comments; the bash surface is out of scope per the directive).

## 6. Q5 — Test approach for the Python-absence acceptance criterion

### 6.1 Seam patterns actually used in this repo (verified examples)

- Wrapper-function seam, mocked by name: `Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = ...; Output = ... } }` — `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1:26,38,...` and ten sites in `validate-discovery-artifact-gate.Tests.ps1`. Both hooks document "production code must never mock `python`" (`enforce-discovery-artifact-gate.ps1:41`).
- Injectable `[scriptblock] $Invoker` seam with direct injection: `OrchestratorState.Tests.ps1:250-273`.
- Module-scoped probe mock: `Mock -ModuleName OrchestratorState -CommandName Test-PythonOrchestratorValidatorAvailable` (`OrchestratorState.Tests.ps1:295,309,321`) with the import-order workaround documented at `validate-orchestrator-output.model-routing.Tests.ps1:100-109`.
- No shadow-executable precedent exists: a repo-wide search for `function (python|git|gh|node|poetry)` in `tests/` returned zero matches. Defining a poison `function python { throw }` would be novel and sits against the "never mock executables directly" rule; do not introduce it.

### 6.2 Recommended formulation of the criterion

After removal, "same verdict with and without Python on PATH" is a structural property — no code path resolves `python` at all — so it should be asserted structurally plus behaviorally, without simulating PATH states:

1. **Structural leg (the guard, section 5):** zero Python `CommandAst`s in the guarded tree. This is the deterministic, host-independent equivalent of "verdict is PATH-independent": a script that never names the executable cannot behave differently when the executable is absent.
2. **Behavioral leg:** for each migrated hook, verdict tests drive the decision function (`Invoke-DiscoveryArtifactGateDecision`, `Invoke-DiscoveryArtifactGateValidation`, `Invoke-OrchestratorOutputValidation`, `Invoke-OrchestratorStatePreflight`) over fixture inputs through the existing filesystem seams (`Get-CheckpointFileContent` mock; `$Invoker` injection where retained) and assert the allow/deny outcome and message prefix. Because no external process is spawned, Terminal/Test Explorer parity follows from the existing conventions (no PATH, CWD resolved from `$PSScriptRoot`).
3. **Negative-invocation leg (optional, cheap):** where a seam function's body is replaced by pure PowerShell, an AST assertion over `${function:...}.Ast.Extent.Text` that it contains no `python`/`poetry` CommandAst — the inverse of the current test at `validate-orchestrator-output.Tests.ps1:476-484`, reusing its established source-inspection technique.

PATH mutation, `$env:PATH` save/restore, or live `python` probes should not appear anywhere in the tests; `.claude/rules/powershell.md` prohibits reliance on mutable machine PATH state and live executables.

## 7. Q6 — Blast radius

### 7.1 Test files exercising the four invocation sites

| Test file | Relationship | Expected impact |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1` | Mocks `Invoke-DiscoveryValidatorExe` (8 sites) | Survives if the seam name and `@{ExitCode;Output}` contract are kept and only the body is replaced; fixture message at :107 references `ModuleNotFoundError` (cosmetic only) |
| `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` | Mocks the same seam (10 references) | Same |
| `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` | Probe mock :468; source-text assertion :476-484 | Two tests rewritten/deleted (section 4.3) |
| `tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1` | Probe mocks :127, :143 | Mocks deleted; import-order `BeforeAll` (:97-109) simplifies |
| `tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1` | Hook-internal function only | Unaffected |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` | Direct seam tests :250-273; capability-detection context :289-325 | Capability context rewritten; seam tests survive |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1` | Portable module | Unaffected |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, `.epic-base-branch.Tests.ps1`, `.OrchestratorStatePreflight.Tests.ps1` | Mock `Invoke-OrchestratorStatePreflight` (11 sites); one end-to-end real-invoker test | Mocks unaffected; end-to-end verdict unchanged, comment update at `.OrchestratorStatePreflight.Tests.ps1:72-75` |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` | Pins module paths in `core.json` | Unaffected unless new lib files are added — then extend both `core.json` and, per house pattern, a manifest test |

Python-side pytest suites (`tests/scripts/dev_tools/test_validate_discovery_*`, `test_validate_orchestration_artifacts*`) are unaffected: the Python validators are not being removed, only the hooks' use of them.

### 7.2 CI and cross-cutting assertions

- `ci.yml:24` → `_poshqc.yml`: format gate (`Invoke-PoshQCFormat`, fails on reformat), PSScriptAnalyzer, and the full Pester suite with coverage artifacts. All four modified files are named coverage targets in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (:48 `validate-orchestrator-output.ps1`, :70 `OrchestratorState.psm1`, :91-92 both discovery hooks), so the >=85%/75% coverage floors apply to every replacement body. New library files must be added to this coverage list.
- **Byte-parity mirror (largest non-obvious item):** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:107-123` asserts every repo `.claude/**` file is text-identical to its copy under `extensions/drm-copilot/resources/claude-customizations/.claude/**`. All four production files exist in that bundle (verified for both discovery hooks, `validate-orchestrator-output.ps1`, `OrchestratorState.psm1`, `OrchestratorStateCompletion.psm1`). Every edit must be mirrored, and any new `.claude/lib` file must be added to the bundle and to `pack-manifests/core.json`.
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:119-123` asserts only the `settings.json` command fragments for the parallel wiring of `validate-orchestrator-output.ps1` (path, `-CheckpointPath`, `-ArtifactType`); the hook body is not hash-pinned (the pinned SHA-256 list at :108-117 covers two unrelated files). Keep the wiring strings unchanged.
- No GitHub Actions workflow executes any of these hooks directly; the hooks run only inside Claude Code sessions via `.claude/settings.json`. CI exposure is entirely through the Pester/pytest suites above.

## 8. Recommended approach

### 8.1 Selected

Four work packages, ordered:

1. **Guard first** (section 5): AST-based Pester guard over `.claude/hooks/**` + `.claude/lib/**` PowerShell files, modeled on `test-name-uniqueness.Tests.ps1`. Landing it first requires it to carry a temporary known-violations allowlist for the four sites, emptied by the later packages — or land it in the same change after the removals, which the issue's single-change directive permits. Prefer the latter (no allowlist machinery).
2. **OrchestratorState.psm1 deference removal** (section 4): delete `Test-PythonOrchestratorValidatorAvailable`, collapse both default invokers to the portable functions, keep the `$Invoker` seams, update the export list and the five test regions listed in 4.3, mirror to the bundle.
3. **Discovery hooks** (section 2): replace the body of `Invoke-DiscoveryValidatorExe` in both hooks with a shared PowerShell implementation (new `.claude/lib` module so the two hooks stop duplicating it): `profile` → placeholder-field check documented against TODO(#9001); seven schema types → `Test-Json -SchemaFile` against the local `file://`-resolved schema, non-`file` schemes reported as `schema resolution failed (...)`. Preserve the seam name and `@{ExitCode;Output}` contract so the existing 18 mock sites survive. Fix defect D-2 as part of the rewrite (exit-code-only discriminator or empty success output). Verify the `Test-Json` Draft 2020-12 / PowerShell 7.4 constraint before planning; if the constraint fails, the fallback is to scope the PowerShell validation to structural checks (JSON parse, object root, `$schema` presence/scheme) and record schema-conformance as enforced by the Python CLI outside the hook surface.
4. **validate-orchestrator-output completion gate** (section 3): make the portable path the only path, dispatch on `$ArtifactType` (resolving defect D-1 explicitly — minimum viable: run the standard portable gate only for `orchestrator-state` and a documented, type-appropriate check for the epic/parallel types), and port the highest-value gap items into the portable modules in this priority order: C1, C2 (trivial), U5, U6-remediation, M2+M3 (wiring the already-ported `Get-ComplexityFloor`/`Resolve-DelegationModel`), then C3/C4/C7. C5/C6 (phase completeness, routing contract) are the largest and most config-coupled; recommend explicitly deferring them with a recorded scope decision rather than silently dropping them — the feature owner must accept that the completion gate in drm-copilot weakens by exactly the unported rows of the section 3.4 table.

### 8.2 Rejected alternatives

- **Full-parity PowerShell port of the orchestration validator (~1,900 lines):** rejected for this change's scope; four-to-six new modules plus tests dwarfs the migration itself, and the C4/C6 config-read behavior conflicts with the portable modules' no-file-read design. The gap table preserves the roadmap.
- **Regex/substring guard:** rejected; produces false positives on the six incidental hooks and on `Invoke-Python*` function names, and misses quoted/dynamic forms. The issue itself predicts this guard would be disabled on first contact.
- **PreToolUse hook as the guard mechanism:** rejected as primary; no CI coverage, no protection for out-of-session edits (kept possible as a later additive layer).
- **Shadow `function python { throw }` PATH-absence simulation:** rejected; no repo precedent, conflicts with the executable-mocking rule, and unnecessary once no code path names the executable.

## 9. Behavior semantics and requirements mapping

- Success condition per migrated hook: identical allow/deny (or ok/block) verdicts and message prefixes (`DISCOVERY_ARTIFACT_GATE_BLOCKED:`, `ROUTING_CONTRACT_BLOCKED:`, `MODEL_ROUTING_BLOCKED:`, `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`) for every fixture in the existing suites, with the Python branch gone. Exact validator-error-text parity is a non-goal (section 2.4); the `MODEL_ROUTING_BLOCKED` routing depends only on the literal token `model_routing_receipts|complexity_assessments` appearing in error text (`validate-orchestrator-output.ps1:330`), which the portable module already guarantees (`OrchestratorStateCompletion.psm1:190`).
- Fail-closed direction preserved: missing checkpoint, invalid JSON, invalid base shape all yield non-zero/deny in the portable implementations (verified in `OrchestratorState.psm1:126-196` and both `Test-*Readiness` functions).
- Ordering: guard must be green in the same change that removes the last invocation; bundle mirror and `core.json` updates must land atomically with the `.claude` edits or `test_push_down_claude_resource_contracts.py` fails.
- State model: no new runtime state. The only new artifacts are the guard test, replacement seam bodies, optional new `.claude/lib` module(s), and their bundle mirrors.

## 10. Testing implications

- Extend, do not rewrite, the existing hook suites: the seam contracts were designed for this replacement and 29 existing mock sites survive if seam names and result shapes are preserved.
- New tests needed: guard fixtures + repository scan (section 5.3); discovery-validator PowerShell implementation unit tests (valid/invalid JSON, missing `$schema`, non-file scheme, schema pass/fail against `schemas/discovery/v1` fixtures as in-memory strings — no temp files, so the schema files themselves are read-only inputs, which is permitted as repository fixtures); dispatch tests for the `$ArtifactType` decision replacing defect D-1's behavior; negative-invocation AST assertions per section 6.2.
- Tests to delete/rewrite are enumerated in section 4.3; the byte-for-byte Python-invocation assertion at `validate-orchestrator-output.Tests.ps1:476-484` is the single test that directly contradicts the objective.
- Coverage: all replacement bodies fall inside pinned coverage targets (`pester.runsettings.psd1:48,70,91,92`); plan for the 85%/75% floors on the new code, and add any new module to both the coverage list and `core.json`.

## Automation Feasibility

Not applicable. This work touches no third-party UI; all changes are repository-local PowerShell, tests, and bundled resources.
