# Codex push-down self-sufficiency (Issue #697) - Research

- Issue: #697
- Branch: `bug/codex-pushdown-self-sufficiency-697`
- Date: 2026-09-25T09-40
- Inputs: `issue.md`, `spec.md` (draft), settled decisions 1-5 supplied by the orchestrator.
- Method: static reading of source, tests, manifests, and packaging scripts. No commands were executed and no destination checkout was inspected. Claims derived from reading code rather than running it are marked "verified by reading". Claims that could not be checked are marked **unverified**.

## 1. Summary of Findings

1. The MCP tool `push_down_codex_and_agents_customizations` does not run the Python publisher. It runs an in-process TypeScript port. That port publishes only `config/orchestration-routing.json` and never publishes `config/orchestration-handoff-registry.json` or `config/orchestration-handoff.schema.json`. This is why a destination never receives the registry. The Python publisher does publish all three files. Item 4's virtual-path change therefore has to be made in both publishers.
2. `packages/mcp-server/prepack.cjs` drops every path that has a `scripts` path segment. As written, any `.codex/scripts/*.ps1` file, including the new `Resolve-Codex*.ps1` wrappers from item 4, cannot ship in the npm MCP package that `.codex/config.toml` launches through `npx`.
3. The PowerShell `Resolve-CodexDeployment` is not a complete port. Its agent-family list omits `commit-steward`, which the Python reference and the TypeScript validator both include. The existing parity suite does not catch this gap.
4. The resolver wrappers cannot load modules from `.codex/lib/codex-routing/` inside `drm-copilot` itself, because that directory exists only in published destinations. The wrappers need a second candidate path, `.claude/lib/codex-routing/`.
5. Codex does not require `model` and `model_reasoning_effort` in every role file. Many role files in the repo omit both. A guard that requires them in every file would fail on current, valid files.
6. The other items are consistent with the diagnosis. The virtual-path class needs generalization (Q1). The fail-soft fix should use lazy loading at the single consuming call site (Q5). Every hook that `config.toml` registers belongs in `core.json` (Q6). `render_manifest` preserves hand edits (Q6).

## 2. Q1 - Virtual-path publishing (item 4)

### 2.1 How the Python mechanism maps paths

- `SHARED_CONFIG_RELATIVE_PATHS` lists three destination-relative paths (`scripts/dev_tools/push_down_codex_and_agents_customizations.py:68-72`).
- `_RoutingConfigFileSystem.__init__` builds `{source_root / rel: bundle_root.parent / rel}` for each entry (`:113-116`). The key's position under `source_root` sets the destination path, because the engine computes `destination_root / source_path.relative_to(effective_source)` (`scripts/dev_tools/push_down_copilot_customizations.py:372-373`). The value sets where the bytes are read. Both key and value use the **same** relative path `rel`.
- The class has exactly one virtual root, `source_root / "config"` (`push_down_codex_and_agents_customizations.py:117`). For that root, `list_files` returns only virtual paths whose resource file exists and never calls the inner listing (`:119-128`). `is_file` and `read_text` redirect virtual paths to the resource (`:136-149`).
- `bundle_root` defaults to `<source>/extensions/drm-copilot/resources/codex-and-agents-customizations` (`:61-63`, `:229-233`). `bundle_root.parent` is therefore `extensions/drm-copilot/resources`, and the config bytes are read from `extensions/drm-copilot/resources/config/*`. Those files exist, and the Codex bundle has no `config/` directory. A test enforces both conditions (`tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:208-212`).
- `PUBLISHED_ROOT_FOLDERS = (.codex, .agents, config)` (`:73-76`) is the list the engine walks. `enumerate_source_files` calls `fs.list_files(source_root / root)` once per root, in that order (`push_down_copilot_customizations.py:168-178`). A root absent from this tuple is never walked, so its virtual files are never published.
- Wrapping order: `ExcludingFileSystem` (pack filter and legacy C# redirect) wraps the real filesystem, and `_RoutingConfigFileSystem` wraps `ExcludingFileSystem` (`push_down_codex_and_agents_customizations.py:240-251`).

### 2.2 Does the class support a source-to-destination rename?

No. The key and value share one relative path (`:114`), and there is a single virtual root (`:117`). Publishing `.codex/lib/codex-routing/X.psm1` from a resource at a different relative path requires two changes:

1. Replace the flat tuple with `(destination_relative, resource_relative)` pairs, so that the key is `source_root / destination_relative` and the value is `bundle_root.parent / resource_relative`.
2. Replace the single `_virtual_root` with a set of **virtual-only** roots (`config`, `.codex/lib/codex-routing`), and add `.codex/lib/codex-routing` to `PUBLISHED_ROOT_FOLDERS`.

Keep each virtual root virtual-only, as `config` is today. Do not merge virtual entries into the physical `.codex` listing. In CLI mode `source_root` is the repo root (`:338-350`), and the repo's physical `config/` directory holds unrelated files. A merge rule would start publishing them.

### 2.3 The TypeScript port (the path the MCP tool actually runs)

- The MCP handler routes to `runPushDownCodexAndAgentsCustomizations` (`extensions/drm-copilot/src/repo-automation-service-push-down.ts:119-137`). That function calls `pushDownCodexAndAgentsCustomizationsServiceCall`, which sets `sourceRoot = bundleRoot = <extensionRoot>/resources/codex-and-agents-customizations` (`extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts:120-145`). No Python runs.
- `RoutingConfigFileSystem` in TypeScript holds **one** virtual path, `config/orchestration-routing.json`, and its resource at `parent(bundleRoot)/config/orchestration-routing.json` (`extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts:37`, `:177-227`). The extension source and tests contain no reference to `orchestration-handoff-registry` (grep over `extensions/drm-copilot/src` and `test`: no matches). The only TypeScript test of this path expects the routing config and nothing else (`extensions/drm-copilot/test/lib/push-down/codex-agents-customizations.test.ts:29-64`).
- Consequence: an MCP-driven push never delivers the registry or schema, even though `core.json` lists both (`pack-manifests/core.json:100-101`). The Python-only test `test_every_selected_pack_generates_identical_handoff_runtime_files` (`tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py:310-365`) cannot detect this gap. This corrects the issue statement that "the push-down publishes ... three `config/` files". The statement holds for the Python CLI only.
- The TypeScript class needs the same generalization as Python (a pair map plus a set of virtual-only roots). Adding the registry and schema pairs to it closes the config drift at the same time.

### 2.4 Where the module bytes should come from

Three sources are available:

- **Repo `.claude/lib/codex-routing/`.** Not reachable in the MCP path, because `sourceRoot` is the packaged bundle (`push-down-service-call.ts:123-126`). Rejected.
- **`extensions/drm-copilot/resources/claude-customizations/.claude/lib/codex-routing/`.** This copy exists and a test keeps it byte-identical to the repo (`tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1:73-86`). However, neither publisher currently reads another bundle's tree. Both read only their own bundle plus `resources/config` (grep of `push-down/*.ts` and `push_down*.py` for sibling reads found only `bundle_root.parent`/`parentPosix(bundleRoot)` used for `config/`). Cross-bundle reads are not an established pattern. Rejected under the stated constraint.
- **Recommended: a shared sibling resource at `extensions/drm-copilot/resources/lib/codex-routing/{CodexTopology,CodexDeployment}.psm1`.** This matches the established `resources/config` precedent (a shared resource outside any bundle, read through `bundle_root.parent`). It needs a byte-identity test against `.claude/lib/codex-routing/`, modeled on `test_routing_config_remains_a_shared_resource_outside_codex_bundle` (`test_push_down_codex_and_agents_resource_contracts.py:208-212`). It ships in both distributions: the VSIX ignores only `resources/scripts/**` (`extensions/drm-copilot/.vscodeignore:19`), and npm `prepack` copies all of `resources/` except `.py` files and `scripts` segments (`packages/mcp-server/prepack.cjs:33-55`).
  - Pair entries: `(".codex/lib/codex-routing/CodexTopology.psm1", "lib/codex-routing/CodexTopology.psm1")` and the same pair for `CodexDeployment.psm1`.
  - Cost: a third byte copy of each module. "Authored once" still holds, because the copies are mirrors guarded by tests.

### 2.5 Pack mode and full-tree mode

- Full-tree mode (`packs=None`) returns `published_paths=None` (`push_down_codex_and_agents_customizations.py:171-173`), so nothing is filtered.
- Pack mode filters only inside `ExcludingFileSystem.list_files` (`scripts/dev_tools/push_down_codex_filesystem.py:57-65`, `:83-90`). A virtual-only root answers `list_files` itself and never reaches that filter (`push_down_codex_and_agents_customizations.py:122-127`). Virtual files therefore publish in both modes. This is how `config/orchestration-routing.json` publishes in pack mode today even though `core.json` does not list it (verified by reading `core.json:1-103`). The TypeScript side behaves the same way (`codex-agents-customizations.ts:197-202`).
- `compute_published_paths` only unions manifest `paths` (`scripts/dev_tools/push_down_codex_pack_selection.py:159-175`) and needs no change. List the **destination-relative** paths (`.codex/lib/codex-routing/*.psm1`, `.codex/scripts/Resolve-Codex*.ps1`) in `core.json`, following how the config entries are listed (`core.json:100-101`). The manifest guard (Q6) and the documentation then match the published set.
- Add a guard asserting that neither the repo nor the Codex bundle has a physical `.codex/lib/` directory, mirroring `assert not BUNDLE_ROUTING_CONFIG.exists()` (`test_push_down_codex_and_agents_resource_contracts.py:212`). A physical copy would be walked under `.codex` and would also trip `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` (`:215-228`). `.codex/lib` does not exist today (Glob `.codex/lib/**`: no files).

### 2.6 The wrappers inside drm-copilot itself

`.codex/lib/codex-routing/` exists only in destinations. Each wrapper must resolve its module from an ordered candidate list:

1. `$PSScriptRoot/../lib/codex-routing/<Module>.psm1` (destination layout).
2. `$PSScriptRoot/../../.claude/lib/codex-routing/<Module>.psm1` (drm-copilot self-hosting layout).

If neither exists, the wrapper must fail with an explicit stderr message and a non-zero exit. Without the second candidate, the repointed skill breaks `$orchestrate` inside drm-copilot.

### 2.7 The npm `prepack` filter removes `.codex/scripts/`

`shouldCopy` rejects any path that matches `/(^|\/)scripts(\/|$)/` (`packages/mcp-server/prepack.cjs:44`). The filter tests the full source path under `extensions/drm-copilot/resources/` (`:13-20`, `:51-55`). It therefore excludes `resources/codex-and-agents-customizations/.codex/scripts/*`, which covers the six `.codex/scripts` files already in `core.json` (`:47-52`) and the new wrappers.

This was verified by reading only. The generated `packages/mcp-server/resources/` directory is not present locally (Glob: no files), so it was not checked empirically.

The VSIX path is unaffected (`.vscodeignore:19` anchors on `resources/scripts/**`). Any destination populated through `npx @danmoisan/drm-copilot-mcp` receives no wrappers unless the filter is anchored, for example to `resources/scripts/` only. No test covers `prepack.cjs` (grep for `prepack` under `tests/` and `extensions/drm-copilot/test/`: no matches).

## 3. Q2 - Python CLI contract and PowerShell mapping (item 4)

### 3.1 `resolve_codex_topology` CLI (`scripts/dev_tools/resolve_codex_topology.py:257-287`)

| Flag | Type | Choices | Required | Default | Repeatable |
|---|---|---|---|---|---|
| `--language` | str | none | no | `[]` | yes (`action="append"`) |
| `--production-file-count` | `int()` | none | no | `0` | no |
| `--test-file-count` | `int()` | none | no | `0` | no |
| `--execution-context` | str | `epic_execution_child`, `epic_preparation_child`, `standalone` | **yes** | none | no |
| `--cross-cutting` | flag | none | no | `False` | no (`store_true`) |
| `--root-persona` | str | `epic-orchestrator`, `epic-planner` | no | `None` | no |

- Output: `print(json.dumps(receipt, indent=2, sort_keys=True))` (`:286`). Keys are sorted, the indent is 2, the separators are `", "` and `": "` with a trailing newline, and `ensure_ascii=True`. The receipt has twelve keys (`:52-66`). `languages` is a sorted, de-duplicated, lowercased list (`:108-116`). Exit code on success is `0` (`:287`).
- Error classes:
  - argparse errors (missing `--execution-context`, invalid choice, non-integer count): usage and message on **stderr**, exit **2** (standard argparse behavior; not executed here).
  - `ValueError` reachable from the CLI: `--language ""` produces "languages must contain non-empty strings." (`:113-114`). `--root-persona` with a non-standalone context produces "A forced root persona requires standalone context." (`:192-193`). `main` does not catch these, so a traceback goes to **stderr** and the exit code is **1** (standard CPython behavior; not executed here).
  - The integer and boolean guards (`:119-134`) cannot be reached from the CLI, because argparse already coerces `int` and `store_true`.
- argparse accepts `int()` forms such as `" 3 "`, `"+3"`, and `"1_0"`, and accepts abbreviated flags (`allow_abbrev` defaults to true). The parity corpus should avoid these forms, or the wrapper must reproduce them deliberately.

### 3.2 `resolve_codex_deployment` CLI (`scripts/dev_tools/resolve_codex_deployment.py:223-251`)

| Flag | Choices | Required |
|---|---|---|
| `--logical-agent` | free string | yes |
| `--complexity-band` | `C1`..`C4` (`BAND_ORDER`, `compute_complexity_floor.py:57`) | yes |
| `--execution-context` | the three contexts | yes |
| `--orchestration-complexity-ceiling` | `C1`..`C4` | yes |

- Output: `json.dumps(receipt, indent=2, sort_keys=True)` (`:250`) with nine keys (`:59-70`). Exit code on success is `0`.
- `ValueError` reachable from the CLI: ceiling below band (`:188-192`) and unsupported logical agent (`:201-202`). Both produce a traceback on stderr and exit 1. `ModelUnavailableError` (`:154-163`) is unreachable because the CLI has no availability flag.

### 3.3 Flag-to-parameter mapping

| CLI flag | PowerShell parameter | Hazard |
|---|---|---|
| `--language` (repeat) | `Resolve-CodexTopology -Language [object]` (`CodexTopology.psm1:261-263`) | Pass `[string[]]`. An empty `@()` is accepted (`CodexTopology.Parity.Tests.ps1:150-153`). |
| `--production-file-count` | `-ProductionFileCount [object]` (`:265-267`) | `Test-CodexIntegralValue` rejects anything that is not `[int]/[long]/[short]/[byte]`, including strings (`:79`, `:124-128`). The wrapper must convert the CLI string to `[int]` before the call. Otherwise every call fails with "production_file_count must be an integer." |
| `--test-file-count` | `-TestFileCount [object]` (`:269-271`) | Same as above. |
| `--execution-context` | `-ExecutionContext [string]` (`:273-276`) | The wrapper must enforce choices and exit 2 before calling. Otherwise the module's `ArgumentException` produces exit 1, where Python gives exit 2 for an invalid choice. |
| `--cross-cutting` | `-CrossCutting [object]` (`:278-280`) | The module requires an exact `[bool]` (`:303-305`). Pass `$true` or `$false`, never a string. |
| `--root-persona` | `-RootPersona [object]` (`:282-284`) | Pass `$null` when absent. Enforce choices in the wrapper. |
| `--logical-agent` | `Resolve-CodexDeployment -LogicalAgent [string]` (`CodexDeployment.psm1:229-232`) | **Parity gap:** the PowerShell family list (`:66-78`) omits `commit-steward`, which Python includes (`resolve_codex_deployment.py:41`). `--logical-agent commit-steward` succeeds in Python and throws in PowerShell. `CodexDeployment.Parity.Tests.ps1:104-115` lists the same 11 families and does not detect this. The TypeScript validator includes `commit-steward` (`extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts:44`). |
| `--complexity-band`, `--orchestration-complexity-ceiling`, `--execution-context` | `-ComplexityBand`, `-OrchestrationComplexityCeiling`, `-ExecutionContext` (`:234-247`) | Enforce choices in the wrapper (exit 2). |
| (none) | `-AvailableModel` (`:249-251`) | The Python CLI has no equivalent. Do not expose it, so parity is preserved. |

Other output-shape differences:

- **Key order.** Both modules return unordered `@{}` hashtables (`CodexTopology.psm1:214-227`, `:319-332`, `:375-388`; `CodexDeployment.psm1:299-309`). The wrapper must emit an `[ordered]` dictionary whose keys are sorted with `[System.StringComparer]::Ordinal`. All keys are lowercase ASCII with `_` and digits, so ordinal order matches Python's code-point sort.
- **Depth.** Output depth is at most 2 (`languages` array). Pass `-Depth 5` explicitly.
- **Non-ASCII.** Python escapes non-ASCII characters (`ensure_ascii`). PowerShell `ConvertTo-Json` leaves them literal by default. `languages` echoes user input on the `unsupported_language` path, so this difference is reachable. Use `ConvertTo-Json -EscapeHandling EscapeNonAscii` (**unverified** that the escape forms match Python byte for byte).
- **Error-message text.** Python uses `repr()`, which switches to double quotes when the value contains `'`. The PowerShell module always renders `'$Value'` (`CodexDeployment.psm1:279`). This affects stderr text only.
- **Argument syntax.** The wrapper must accept GNU-style `--flag` tokens, so it must parse them itself (for example from a `ValueFromRemainingArguments` string array). It is **unverified** whether `pwsh -File script.ps1 --language python` delivers `--language` to the script as a literal string. The wrapper test must prove this by process invocation.

### 3.4 Normalization for the parity test

1. Convert CRLF to LF. Python text-mode stdout on Windows and PowerShell console output both emit `\r\n` (standard runtime behavior; **unverified** here).
2. Strip trailing whitespace and newlines.
3. Compare the normalized strings byte for byte. Also assert that `json.loads`/`ConvertFrom-Json` produce equal objects, so that a formatting-only divergence reports clearly.
4. For error cases, compare the exit code (2 for argparse-class errors, 1 for ValueError-class errors) and assert that stdout is empty. Compare stderr only by message substring, because Python tracebacks are not reproducible byte for byte.

## 4. Q3 - Existing parity harness (item 4)

- `CodexTopology.Parity.Tests.ps1` and `CodexDeployment.Parity.Tests.ps1` do **not** obtain Python output at runtime. They import the module (`CodexDeployment.Parity.Tests.ps1:32-37`, `CodexTopology.Parity.Tests.ps1:35`) and assert hard-coded expectations inline. No subprocess, fixture file, or shared case table is involved (grep for `poetry|Start-Process|TestCases|-ForEach` in the topology suite: no runtime Python invocation). The CLI wrappers therefore have no case table to reuse.
- Precedent for a shared table: the blast-radius parity corpus `tests/fixtures/blast_radius/*.json` is consumed by both `tests/scripts/dev_tools/test_blast_radius_parity.py:3,50` and `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1:6-10,37-50`. Recommended: a committed corpus `tests/fixtures/codex_routing/*.json` with records `{argv, expected_exit, expected_stdout}`.
  - The Python side runs `main(argv)` in-process with `redirect_stdout`, so no subprocess is needed.
  - The PowerShell side invokes the wrapper through `pwsh -NoProfile -File`, reusing the `ProcessStartInfo` pattern already accepted in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:60-90`.
  - Include `commit-steward` in the corpus.
- `CodexRouting.Manifest.Tests.ps1` asserts four things:
  - Both module paths are in `claude-customizations/pack-manifests/core.json` (`:27-58`).
  - Every on-disk `.claude/lib/codex-routing/*.psm1` is registered (`:60-70`).
  - The Claude bundle mirror is byte-identical (`:73-86`).
  - It says nothing about the Codex manifest or `resources/lib`. Publishing into the Codex bundle does not break it, provided the Claude manifest and mirror stay unchanged. The new `resources/lib/codex-routing` mirror needs its own byte-identity assertion, which can live in this file or beside the routing-config test.
- The `commit-steward` fix changes `.claude/lib/codex-routing/CodexDeployment.psm1`. It therefore requires lockstep updates to the Claude bundle mirror (`CodexRouting.Manifest.Tests.ps1:73-86`) and the new shared mirror. It also changes the behavior of the Claude-side consumer `OrchestratorStateCodexModelReceipts.psm1` (`.claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1:14,35`), which will then accept `commit-steward` receipts.

## 5. Q4 - Codex agent-role schema (item 1)

- **Keys observed in role files that Codex loads.** `name`, `description`, `model`, `model_reasoning_effort`, `developer_instructions` (for example `.codex/agents/csharp-typed-engineer.toml:1-5`), `default_permissions` and a `[skills]` table (`.codex/agents/orchestrator.toml:5`, `:198`; `epic-planner.toml:5`, `:88`). Earlier repository research records Codex role files as: required `name`, `description`, `developer_instructions`; optional `model`, `model_reasoning_effort`, `sandbox_mode`, `mcp_servers`, `skills.config`, `nickname_candidates`; and "any `config.toml` key is valid" (`docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md:338-340`). The #306 spec lists `default_permissions` among the valid top-level identity fields (`docs/features/completed/2026-07-04-codex-agent-role-config-306/spec.md:67`). The complete v0.154.0 key set cannot be listed from repository evidence (**unverified**). `variant` is not a `config.toml` key, which is consistent with the reported deserializer rejection.
- **`model` and `model_reasoning_effort` are optional.** Many role files omit both, for example `.codex/agents/5.1-beast-adjusted.toml:1-4` (`name`, `description`, `developer_instructions` only). The converter emits only those three keys (`scripts/dev_tools/codex_native_converter/pipeline.py:116-122`). A per-file count of `^model = ` returns 74 files, while `.codex/agents/` contains more than 100 files (Grep count vs Glob). The reported banner shows only the `variant` warning. The issue's proposed test, "each declares `model` and `model_reasoning_effort`", would therefore fail on valid files. Scope that requirement as described below.
- **Existing validation of `.codex-variants/`.**
  - `generate_codex_agent_variants.py` reads only `REPO_ROOT/.codex/agents/<family>.toml` (`:186-192`). It checks the canonical alias pins C3 Terra/high through `tomllib` (`:239-247`) and never reads `.codex-variants/`.
  - `test_push_down_codex_and_agents_resource_contracts.py` checks only that the variant file exists (`:49-54`, `:197-205`). Its `.codex-variants/` content tests cover `.agents-variants` skill substrings (`:276-318`).
  - No test parses the variant TOML.
  - `CSHARP_CANONICAL_PATHS` redirects only the base alias (`scripts/dev_tools/push_down_codex_pack_selection.py:24-29`, `:178-194`; `push_down_codex_filesystem.py:73-81`). `csharp-typed-engineer-c1..c4` come from the canonical tree even under `csharp-legacy.json:9-14`.
  - Sampled lines and line counts suggest the variant's instruction body matches the canonical body (76 vs 77 lines, with matching `description`/`msbuild` lines). A full diff was not run.
- **Value to restore.** The base alias is pinned to C3 (`render_base_alias`, `generate_codex_agent_variants.py:173-179`). The canonical file declares `gpt-5.6-terra` / `high` (`.codex/agents/csharp-typed-engineer.toml:3-4`). The variant should carry the same pair.
- **Recommended guard location and rules.** Create a new file `tests/scripts/dev_tools/test_codex_agent_role_schema.py`. Parse with `tomllib`, which is already used in `test_push_down_codex_and_agents_resource_contracts.py:11-14`. Cover three file sets:
  1. `.codex/agents/*.toml` in the repo.
  2. `extensions/.../codex-and-agents-customizations/.codex/agents/*.toml`, which includes the generated `-c1..-c4` and `-c3-elevated` profiles.
  3. Every `extensions/.../.codex-variants/**/agents/*.toml`.

  Rules:
  - (a) Top-level keys must be a subset of an explicit allowlist: the observed keys plus the documented optional keys. `mcp_servers` stays prohibited, as `test_codex_role_files_do_not_retain_drm_copilot_transport` already asserts for the orchestrator (`:265-273`).
  - (b) `name`, `description`, and `developer_instructions` are required everywhere.
  - (c) `model` and `model_reasoning_effort` are required for every generated family base alias and profile (`GENERATED_AGENT_FAMILIES`, `resolve_codex_deployment.py:32-47`) and for both epic personas.
  - (d) Each `.codex-variants/<v>/agents/<name>.toml` must have the same top-level key set as its canonical `.codex/agents/<name>.toml`, and the same `model` and `model_reasoning_effort` values.

  Rule (d) catches this defect class directly without requiring a complete Codex schema.

## 6. Q5 - Fail-soft pattern (item 3)

### 6.1 Current behavior

- `$script:AllowedPreparationSemanticMcpTools` is computed at script scope (`.codex/hooks/enforce-epic-planning-only.ps1:85-88`), before the dot-source guard (`:315-317`) and outside the `try` (`:319-355`). When `config/orchestration-handoff-registry.json` is absent, `Get-EpicPlanningRegisteredMcpTool` throws (`:57-58`). The throw is uncaught, so `pwsh -File` exits 1 on every matched tool call. Dot-sourcing the hook in tests also runs the load (`tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1:19`). This works in drm-copilot only because the repo has the registry.
- The variable has exactly one consumer: `Invoke-EpicPlanningOnlyDecision` line 273. No test references the variable or the loader (grep under `tests/`: no matches).
- Line 273 runs only when all of the following hold:
  - a checkpoint exists or the preparation-child attestation is set (`:216-219`);
  - `route_id` equals `preparation` (`:225-230`);
  - the tool is neither `apply_patch` (`:233-262`) nor `Bash` (`:264-270`).

### 6.2 Which calls fail closed and which may fail open

| Path | Registry-dependent? | Behavior when the registry is absent |
|---|---|---|
| No checkpoint and not attested (`:217-219`) | No | Allow (return `$null`), which is the current intended result. |
| Non-preparation route (`:228-230`) | No | Allow. |
| Preparation `apply_patch` (`:233-262`) | No | Unchanged path rules. |
| Preparation `Bash` (`:264-270`) | No | Unchanged allowlist. |
| Preparation lifecycle MCP in `$script:AllowedPreparationMcpTools` (`:13-20`, `:272`) | No | Allow, subject to the unchanged `workspace_root` check (`:275-282`). |
| Preparation MCP tool not in the lifecycle list: the four semantic tools, or any other `mcp__*` (`:273-288`) | **Yes** | **Fail closed.** Emit a deny decision (exit 0 with JSON) whose reason names the missing registry. |
| Registry present but malformed or invalid (`:60-80`) | Yes | Fail closed. The throw propagates to the existing `catch`, which exits 2 (`:352-355`) for that call only. |

### 6.3 Loading choice

- Recommended: **lazy loading at the consuming call site.** Evaluate `$allowedRepositoryMcp` first. Resolve the semantic list only when that check is false and the tool matches `mcp__*`. Add a `-RegistryPath` parameter to `Invoke-EpicPlanningOnlyDecision`, defaulting to `Join-Path $script:EpicPlanningRepositoryRoot 'config/orchestration-handoff-registry.json'`. When `Test-Path` is false, return `Get-EpicPlanningDenyDecision` with a registry-specific reason. Remove the script-scope call at `:86-88`.
- Rejected: **loading inside the existing top-level try/catch.** The catch exits 2 (`:352-355`). In this hook family, exit 2 is the blocking-error convention, although Codex v0.154.0's exact semantics for exit 2 are **unverified**. Every matched tool call would then turn into a hook block rather than a hook error. The gate becomes stricter for unrelated calls, and the session is still unusable.
- Test seam: pass a non-existent `-RegistryPath` string. No file is created, so the prohibition on temporary files is respected. For the "registry present" case, use the committed `config/orchestration-handoff-registry.json`. For the malformed case, use a committed fixture under `tests/fixtures/codex-hooks/`.

### 6.4 Claude-side twin

None exists. No `.claude/hooks` file references the registry (grep of `.claude/` for `orchestration-handoff-registry`: no matches), and the only copies of the hook are the Codex root and bundle (Glob `**/enforce-epic-planning-only*`). No scope expansion is needed.

### 6.5 How the bundle mirror stays in sync

No sync script exists (grep of `scripts/` for bundle sync patterns: no matches). The copy is maintained by hand and enforced by three tests:

- `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:10-34,162-170`: SHA-256 byte identity. The hook is in `RuntimePaths` (`:25`).
- `test_push_down_codex_and_agents_resource_contracts.py:215-228`: text equality for every repo `.codex`/`.agents` file.
- `test_push_down_codex_and_agents_customizations.py:34-40,285-301`: normalized-text identity, plus core-manifest membership.

The hook is also in the Pester coverage list (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:147`).

### 6.6 Related consequence

Because the TypeScript publisher never delivers the registry (§2.3), a destination under a preparation checkpoint will deny all four semantic tools, including `validate_orchestration_artifacts`, until the TypeScript config drift is fixed. That is the correct fail-closed result, but epic preparation in destinations stays blocked until item 4's TypeScript generalization also publishes the registry.

## 7. Q6 - Manifest completeness (item 5)

### 7.1 Hooks registered by `.codex/config.toml`

There are 22 `command =` registrations and 21 unique files. `enforce-orchestration-preimplementation-gate.ps1` is registered twice (`:136`, `:220`). Registration lines: `:104`, `:114`, `:124`, `:130`, `:136`, `:142`, `:148`, `:157`, `:163`, `:169`, `:175`, `:181`, `:190`, `:196`, `:202`, `:208`, `:214`, `:220`, `:226`, `:232`, `:241`, `:250`. The full member set and a cross-check are in §12.

### 7.2 Transitive dot-source dependencies (verified by grep of `^\s*\.\s+\S` and `Join-Path $PSScriptRoot`)

- `authorize-root-epic-invocation`, `enforce-epic-root-invocation`, `validate-codex-subagent-routing` → `codex-authority-store.ps1` (`authorize-root-epic-invocation.ps1:14`; `enforce-epic-root-invocation.ps1:12`; `validate-codex-subagent-routing.ps1:12`).
- `enforce-codex-model-routing` → `codex-authority-store`, `codex-agent-profile-attestation` (`:8-9`).
- `record-subagent-routing-attestation` → `codex-authority-store`, `codex-agent-profile-attestation`, `codex-epic-child-launch-attestation` (`:13-15`).
- `enforce-epic-wave-barrier` → `codex-epic-child-launch-attestation` (`:14`).
- `codex-epic-child-launch-attestation` and `enforce-epic-child-worktree-binding` → **conditional** dot-source of `.codex/scripts/epic-child-launch-contract.ps1` when present (`codex-epic-child-launch-attestation.ps1:3-6`; `enforce-epic-child-worktree-binding.ps1:14-17`).
- `validate-bash`, `enforce-promotion-mcp-only`, `enforce-epic-merge-gate`, `enforce-epic-worktree-removal-gate` → `hook-command-scanner`, `hook-command-invocation` (`validate-bash.ps1:21-22`; `enforce-promotion-mcp-only.ps1:35-36`; `enforce-epic-merge-gate.ps1:11-12`; `enforce-epic-worktree-removal-gate.ps1:11-12`). `hook-command-invocation` → `hook-command-scanner` (`:17`).
- `enforce-orchestration-preimplementation-gate` → `codex-pretooluse-file-mapping`, `-helpers`, `-modes`, `hook-command-scanner`, `hook-command-invocation` (`:11`, `:16`, `:22`, `:24-25`).
- `check-python-test-purity`, `check-powershell-test-purity`, `enforce-python-batch-budget`, `enforce-powershell-batch-budget`, `enforce-evidence-locations`, `enforce-checkpoint-monotonic` → `codex-pretooluse-file-mapping` (`:35`, `:38`, `:39`, `:41`, `:46`, `:49`).
- `enforce-completion-consistency` → `enforce-checkpoint-monotonic`, `codex-pretooluse-file-mapping`, `enforce-completion-helpers` (`:46`, `:52`, `:56-57`, the last one through a variable).
- Scripts chain (already in core, `core.json:47-52`): `launch-epic-child-wave`/`resume-epic-child` → `epic-child-launch-contract`, `epic-child-launch-runtime` (`launch-epic-child-wave.ps1:12-13`; `resume-epic-child.ps1:10-11`). `epic-child-launch-runtime` → `epic-child-persistence-runtime`, `epic-child-sandbox-preflight` (`:444-445`).
- Config reads, which fail soft: `enforce-completion-helpers.ps1:127-131` returns `$null` when `config/orchestration-routing.json` is missing. `enforce-epic-child-worktree-binding.ps1:106` reads the routing config under the worktree path.
- Item 4 additions, which must be in core: `.codex/scripts/Resolve-CodexTopology.ps1`, `.codex/scripts/Resolve-CodexDeployment.ps1`, `.codex/lib/codex-routing/CodexTopology.psm1`, `.codex/lib/codex-routing/CodexDeployment.psm1`. Neither module imports anything (`CodexTopology.psm1:1-394`, `CodexDeployment.psm1:1-314` contain no `Import-Module`).

### 7.3 Differences from `core.json`

`core.json` hook entries are at `:29-46`. Missing:

- 11 registered hooks: `validate-bash`, `enforce-promotion-mcp-only`, `enforce-orchestration-preimplementation-gate`, `check-python-test-purity`, `enforce-python-batch-budget`, `check-powershell-test-purity`, `enforce-powershell-batch-budget`, `enforce-evidence-locations`, `enforce-checkpoint-monotonic`, `enforce-completion-consistency`, `validate-feature-review-coverage`.
- 1 transitive dependency: `enforce-completion-helpers`.
- The 4 item-4 files.

Every other transitive dependency is already listed.

### 7.4 Core or language packs

Put everything in **core**. `config.toml` is a core path (`core.json:23`) and registers the Python and PowerShell hooks unconditionally (`config.toml:185-210`). If the Python purity and budget hooks moved to `python.json`, a `--packs typescript` push would register hooks it never delivered, which is the failure this item is meant to prevent. Language packs would be correct only if `config.toml` were split per pack, which is out of scope.

### 7.5 Does `render_manifest` overwrite hand edits?

No. It loads the existing `paths`, appends only missing generated-agent paths, and re-serializes with `json.dumps(document, indent=2) + "\n"` (`scripts/dev_tools/generate_codex_agent_variants.py:195-218`). `--check` compares that text exactly (`:259-267`). `test_generator_check_mode_reports_no_drift` runs this check on the real tree (`tests/scripts/dev_tools/test_generate_codex_agent_variants.py:181-184`). Hand-added entries survive, but the file must stay in `json.dumps(indent=2)` form, with no key sorting, `": "` separators, and a trailing LF.

### 7.6 Existing guards to update and the new guard

- `test_push_down_codex_and_agents_pack_manifest_completeness.py:90-105`: remove the 12 entries from `PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS`. The test tolerates stale entries only as long as the files still exist (`:255-275`), so removing them is required for the scope note to stay accurate, not for the test to pass.
- `legacy-codex-hook-contracts.Tests.ps1:30,134-139` asserts that its shared modules are in core and needs no change.
- New guard in Python. `tomllib` can parse `config.toml`, and no PowerShell TOML parser is in use.
  - (a) Parse `.codex/config.toml` from the bundle and collect every `hooks.*[].hooks[].command` path under `.codex/hooks/`.
  - (b) Compute the dot-source closure with the three observed forms: `. (Join-Path $PSScriptRoot '<f>')`, `$v = Join-Path $PSScriptRoot '<f>'` followed by `. $v`, and `Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts/<f>'`.
  - (c) Add the explicit skill-referenced roots `.codex/scripts/Resolve-Codex*.ps1` and their `../lib/codex-routing/*.psm1` imports.
  - (d) Assert that the closure is a subset of `core.json` `paths` (core alone, not the union of all manifests), and that each file exists in the bundle or as a virtual resource.

## 8. Q7 - Bundle-parity and sync obligations

| Guard | Asserts | Location |
|---|---|---|
| All repo `.codex`/`.agents` files present in the bundle with equal text | Every repo runtime file | `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:215-228` |
| Shared routing config equals canonical; no bundle `config/` | `resources/config/orchestration-routing.json` | same file `:208-212` |
| Handoff runtime identity (normalized) and core membership | skills, planning-only hook, registry, schema | `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py:34-40,285-307` |
| Hook SHA-256 identity (10 hooks + 4 shared modules) | `.codex/hooks` | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:10-31,111-117` |
| Epic runtime SHA-256 identity and core membership | hooks, scripts, skills, agents | `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:10-34,134-170` |
| Claude-bundle mirror of `.claude/lib/codex-routing` | byte identity | `tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1:73-86` |
| Canonical alias, generated profiles, and manifests in repo and bundle | generator drift | `generate_codex_agent_variants.py:221-268`; `test_generate_codex_agent_variants.py:181-184` |
| PoshQC settings mirror (includes `pester.runsettings.psd1`) | byte identity | `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:16,63` |

- Regenerate or verify agents and manifests: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` (write) or `... --check` (verify) (`generate_codex_agent_variants.py:271-294`). No other sync command exists. Hooks, skills, scripts, and `resources/config` mirrors are copied by hand and enforced by the tests above.
- New lockstep obligations from this fix:
  - `.codex/scripts/Resolve-Codex*.ps1` must exist in both the repo and the bundle (the §8 row 1 test).
  - `.claude/lib/codex-routing/*.psm1` must match both the Claude bundle mirror and the new `resources/lib/codex-routing/` mirror.
  - `.agents/skills/codex-model-routing/SKILL.md` must match in repo and bundle.
  - `pester.runsettings.psd1` must gain the two wrappers in both the repo copy and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. The existing codex-routing entries are at `:108-109` in both. Registration keeps the new production files in the coverage denominator.

## 9. Q8 - Documentation surfaces

- The only Codex surfaces that tell Codex to run `poetry run python -m scripts.dev_tools.resolve_codex_*` or `validate_orchestration_artifacts` are `.agents/skills/codex-model-routing/SKILL.md:19`, `:56`, `:102-106` and the bundle mirror at the same lines (grep over `.codex/**`, `.agents/**`, `AGENTS.md`, and the bundle). `.codex/prompts/` and `AGENTS.md` contain no such references.
- The literal `CODEX_TOPOLOGY_RESOLVER_UNAVAILABLE` from the issue does not appear anywhere in the repository. Only `HANDOFF_TOPOLOGY_RESOLVER_UNAVAILABLE` exists (`config/orchestration-handoff-registry.json:134`). The Codex agent appears to have composed the halt code itself (**unverified**).
- **Validation line (`:102-106`).** Repoint it to the MCP tool. `validate_orchestration_artifacts` is in `enabled_tools` (`.codex/config.toml:27`) and is auto-approved (`:76-77`). Its schema accepts `artifact_type: "orchestrator-state"` / `"epic-orchestrator-state"`, `artifact_path`, `workspace_root`, `require_codex_topology`, and `require_codex_model_routing` (`extensions/drm-copilot/src/mcp-tool-definitions.ts:405-449`). The TypeScript validator applies both gates (`extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts:441-450`). The skill already names the MCP surface as authoritative (`SKILL.md:108-110`). In a destination the Python line cannot run at all, so it should become the MCP call, with the Python form kept only as an optional drm-copilot-internal note or removed.
- The epic-planning Bash allowlist still permits `python -m scripts.dev_tools.validate_*` (`enforce-epic-planning-only.ps1:162`). That entry is harmless in destinations and is out of scope.

## 10. Recommended Approach (per item)

1. **Item 1.** In `.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml`, replace line 3 `variant = "legacy"` with `model = "gpt-5.6-terra"` and `model_reasoning_effort = "high"`, matching the canonical file. Add `test_codex_agent_role_schema.py` (§5).
2. **Item 2.** Post-merge verification only (§13).
3. **Item 3.** Lazy, call-site registry resolution with a `-RegistryPath` seam, fail-closed deny for registry-dependent authorization, and removal of the script-scope load. Apply the same edit to the root and bundle copies.
4. **Item 4.**
   - (a) Generalize Python `_RoutingConfigFileSystem` and TypeScript `RoutingConfigFileSystem` to `(destination, resource)` pairs with virtual-only roots. Add `.codex/lib/codex-routing` to both `PUBLISHED_ROOT_FOLDERS`. Add the registry and schema to the TypeScript pairs.
   - (b) Add the shared mirror `extensions/drm-copilot/resources/lib/codex-routing/*.psm1` with a byte-identity test.
   - (c) Add `.codex/scripts/Resolve-CodexTopology.ps1` and `Resolve-CodexDeployment.ps1`: GNU-flag parsing, argparse-equivalent choice and integer validation (exit 2), `ArgumentException` → exit 1, sorted `[ordered]` output with `ConvertTo-Json -Depth 5`, and a two-candidate module lookup (§2.6). Add root and bundle copies.
   - (d) Add `commit-steward` to `CodexDeployment.psm1` `GENERATED_AGENT_FAMILIES` and to its parity test.
   - (e) Anchor `packages/mcp-server/prepack.cjs` so that only `resources/scripts/` and `.py` files are excluded, or record an explicit decision that npm-distributed destinations do not receive `.codex/scripts`.
   - (f) Repoint `SKILL.md` (repo and bundle).
5. **Item 5.** Add the 11 hooks, `enforce-completion-helpers.ps1`, and the 4 item-4 paths to `core.json` in `json.dumps(indent=2)` form. Prune the exception set. Add the closure guard (§7.6).

### Rejected alternatives

- A new physical root `.codex/lib` in the bundle. It duplicates the source and conflicts with the "authored once" decision and the repo/bundle equality test.
- Reading the Claude bundle's `.claude/lib`. This would be a new cross-bundle coupling.
- Loading the registry inside the top-level try/catch. A missing registry would then block every matched tool call through exit 2.
- Moving language hooks into language packs. `config.toml` registration is unconditional, so a pack-scoped push would register hooks it never delivered.

## 11. Requirements Mapping (proposed changes)

| File | Change |
|---|---|
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml` | Restore `model` and `model_reasoning_effort`; remove `variant`. |
| `.codex/hooks/enforce-epic-planning-only.ps1` and bundle copy | Lazy registry resolution; `-RegistryPath` parameter; registry-missing deny reason. |
| `scripts/dev_tools/push_down_codex_and_agents_customizations.py` | Pair map, virtual-only root set, new published root. |
| `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts` | Same generalization; add registry and schema pairs. |
| `extensions/drm-copilot/resources/lib/codex-routing/{CodexTopology,CodexDeployment}.psm1` | New shared mirror. |
| `.claude/lib/codex-routing/CodexDeployment.psm1` and the Claude bundle mirror | Add `commit-steward`. |
| `.codex/scripts/Resolve-CodexTopology.ps1`, `.codex/scripts/Resolve-CodexDeployment.ps1` and bundle copies | New CLI wrappers. |
| `.agents/skills/codex-model-routing/SKILL.md` and bundle copy | Repoint the resolver and validation instructions. |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | Add 16 paths (§7.3). |
| `packages/mcp-server/prepack.cjs` | Anchor the `scripts` exclusion (decision required). |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and bundled mirror | Register the wrappers for coverage. |
| Tests | See §14. |

## 12. Numeric Derivation Evidence

### N1 - Hooks registered by `.codex/config.toml`

- **Complete Family:** every PowerShell hook file that a `command`/`command_windows` entry in `.codex/config.toml` invokes, across all event tables (`UserPromptSubmit`, `SubagentStart`, `PreToolUse` ×3 matcher groups, `SubagentStop` ×2).
- **Exhaustive Search Scope:** `.codex/config.toml`, lines 1-253 (whole file).
- **Inclusion Rules:** the file name under `.codex/hooks/` appears in a `command =` value.
- **Exclusion Rules:** duplicate registrations of the same file count once. Dot-sourced dependencies are counted in N2, not here.
- **Primary Search Strategy or Query Expression:** Grep `^command = .*hooks/([a-z-]+\.ps1)` (count mode: 22 lines), then de-duplicate file names.
- **Primary Member Set:** authorize-root-epic-invocation, record-subagent-routing-attestation, validate-bash, enforce-promotion-mcp-only, enforce-orchestration-preimplementation-gate, enforce-epic-merge-gate, enforce-epic-worktree-removal-gate, enforce-epic-root-invocation, enforce-codex-model-routing, enforce-epic-planning-only, enforce-epic-wave-barrier, enforce-epic-child-worktree-binding, check-python-test-purity, enforce-python-batch-budget, check-powershell-test-purity, enforce-powershell-batch-budget, enforce-evidence-locations, enforce-checkpoint-monotonic, enforce-completion-consistency, validate-codex-subagent-routing, validate-feature-review-coverage.
- **Primary Count:** 21 unique (22 registrations).
- **Cross-check Search Strategy or Query Expression:** Glob `.codex/hooks/*` (30 files) minus the set of files that appear only as dot-source targets. That set comes from Grep `^\s*\.\s+\S` over `.codex/` plus the variable form at `enforce-completion-consistency.ps1:56-57`: codex-agent-profile-attestation, codex-authority-store, codex-epic-child-launch-attestation, codex-pretooluse-file-mapping, enforce-completion-helpers, enforce-orchestration-preimplementation-gate-helpers, enforce-orchestration-preimplementation-gate-modes, hook-command-invocation, hook-command-scanner (9).
- **Cross-check Member Set:** the 30 directory files minus those 9, which gives the same 21 names as the primary set.
- **Cross-check Count:** 21.
- **Member-set Comparison:** identical after normalizing to bare file names. `enforce-checkpoint-monotonic` is both registered and dot-sourced, so it appears in both sets.

### N2 - Required `core.json` additions for existing hooks (item 5)

- **Complete Family:** files in the N1 set plus their transitive dot-source closure (§7.2) that are absent from `core.json` `paths`.
- **Exhaustive Search Scope:** `pack-manifests/core.json:1-103`, the N1 set, and the §7.2 closure.
- **Inclusion Rules:** the file is in N1 or its closure, and it is not in `core.json`.
- **Exclusion Rules:** item-4 files (counted separately: 4) and `.codex/scripts/*` files already listed at `core.json:47-52`.
- **Primary Search Strategy or Query Expression:** set difference (N1 ∪ closure) − `core.json` hook entries `:29-46`.
- **Primary Member Set:** validate-bash, enforce-promotion-mcp-only, enforce-orchestration-preimplementation-gate, check-python-test-purity, enforce-python-batch-budget, check-powershell-test-purity, enforce-powershell-batch-budget, enforce-evidence-locations, enforce-checkpoint-monotonic, enforce-completion-consistency, validate-feature-review-coverage, enforce-completion-helpers.
- **Primary Count:** 12 (11 registered + 1 transitive).
- **Cross-check Search Strategy or Query Expression:** read the independently maintained `PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS` literal (`tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py:90-105`). It was built from the on-disk bundle hooks directory against the union of all manifests.
- **Cross-check Member Set:** check-powershell-test-purity, check-python-test-purity, enforce-checkpoint-monotonic, enforce-completion-consistency, enforce-completion-helpers, enforce-evidence-locations, enforce-orchestration-preimplementation-gate, enforce-powershell-batch-budget, enforce-promotion-mcp-only, enforce-python-batch-budget, validate-bash, validate-feature-review-coverage.
- **Cross-check Count:** 12.
- **Member-set Comparison:** identical. This matches the issue's "11 hooks ... plus `enforce-completion-helpers.ps1`".

A proposed acceptance criterion may therefore state: "`core.json` lists all 21 hooks registered by `.codex/config.toml`, every transitive dot-source dependency, and the 4 item-4 resolver files; the closure guard enforces this." No other numeric assertion is supported by this research.

## 13. Automation Feasibility

| Verification step | Unattended? | Evidence and constraints | Unattended substitute when a human is needed |
|---|---|---|---|
| Push-down into a destination | Yes, with a release caveat | The MCP tool exists (`config.toml:12`), but it copies the **installed** extension or npm payload (`push-down-service-call.ts:123-126`; npm root `mcp-server.ts:29-31`). A merged repo change does not reach a destination until the VSIX is rebuilt and installed or the npm package is published. The destination's `config.toml` pins `@danmoisan/drm-copilot-mcp@1.1.11` (`:5`). The Python CLI reads repo sources but is not the MCP code path (§2.3), so it is not equivalent evidence. | Before release: a Jest integration test that runs `pushDownCustomizations` (TypeScript) against the real `extensions/drm-copilot/resources` tree with an in-memory destination, asserting the §7.3 paths and the three config files. After release: invoke the MCP tool once. |
| Hook probe (synthetic PreToolUse per hook) | Yes | The `ProcessStartInfo` harness already exists (`legacy-codex-hook-contracts.Tests.ps1:34-90`). A script can run every hook registered in the destination's `config.toml` with synthetic Bash, `apply_patch`, `Edit`, and `mcp__` payloads, then assert exit 0 and empty stdout, or valid `hookSpecificOutput` JSON. It needs only `pwsh` and `git` in the destination. | Not needed. |
| Role-schema check | Yes | Static TOML check (§5) over `.codex/agents/*.toml` in the destination. The authoritative check is Codex's deserializer. `codex doctor --json` is recorded as reporting malformed-role warnings (`docs/features/completed/2026-07-04-codex-agent-role-config-306/spec.md:35,203`). Whether v0.154.0 still reports them there is **unverified**. | Run `codex doctor --json` non-interactively and assert no role-definition warnings. |
| Live Codex session start (banner, per-call hook results, `$orchestrate`) | **Needs a human** in interactive mode | The TUI banner and "Hook failed" lines are interactive output. `codex exec` exists and is used headlessly by the epic-child launcher (`tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1:285`). It requires an authenticated Codex CLI. Whether startup warnings and hook failures appear on `codex exec` stderr is **unverified**. | `codex exec` in the destination with a prompt that runs one shell command, one `apply_patch`, and the two resolver wrappers. Capture stderr and grep for `Hook failed` and `Ignoring malformed agent role`. Assert that the wrapper JSON matches the parity corpus. If stderr does not carry those lines, combine the hook probe, `codex doctor --json`, and direct wrapper invocation as equivalent evidence, and keep one human-observed session as the final confirmation. |

## 14. Testing Implications

**Python (pytest):**
- `test_codex_agent_role_schema.py` (§5).
- Closure guard (§7.6).
- `resources/lib/codex-routing` byte-identity test and a no-physical-`.codex/lib` test.
- Virtual pair-mapping tests for `_RoutingConfigFileSystem`: rename resolution, virtual-only roots, pack mode, and full-tree mode, using `RecordingFileSystem` in-memory doubles (`tests/scripts/dev_tools/push_down_customizations_test_support.py`).
- In-process `main(argv)` corpus tests for both resolvers.

**TypeScript (Jest):**
- `RoutingConfigFileSystem` pair map, including publication of the registry and schema.
- Real-bundle integration test (§13, row 1).

**PowerShell (Pester):**
- Planning-only hook cases (§6.3):
  - absent registry with no checkpoint allows;
  - absent registry in preparation allows lifecycle MCP;
  - absent registry in preparation allows `apply_patch` planning paths;
  - absent registry in preparation denies semantic MCP;
  - present registry in preparation allows semantic MCP;
  - malformed registry fails closed.
- An AST assertion that no top-level statement invokes `Get-EpicPlanningRegisteredMcpTool`.
- Wrapper corpus tests through `pwsh -File`, including GNU-flag parsing and exit codes 0, 1, and 2.
- `commit-steward` added to `CodexDeployment.Parity.Tests.ps1:104-115`.
- New wrapper tests under `tests/scripts/codex-scripts/`, following the mirroring rule. Existing `.codex/scripts` tests sit in `tests/scripts/codex-hooks/`.

**Coverage:** register the two wrappers in both copies of `pester.runsettings.psd1`.

**Toolchains:** Python (black → ruff → pyright → pytest), TypeScript (prettier → eslint → tsc → jest), PowerShell (PoshQC format → analyze → test).

## 15. Findings That Bear on the Settled Decisions

None of the findings contradicts decisions 1-5. The following findings change what implementing them requires.

1. **Decision 4, TypeScript publisher.** The MCP tool runs the TypeScript port, which publishes one config file and has a single-path virtual class (`codex-agents-customizations.ts:177-227`). The virtual-path change must be made in TypeScript as well as Python, or destinations fed by the MCP tool will not receive the modules or the registry.
2. **Decision 4, npm distribution.** `prepack.cjs:44` drops every `.codex/scripts/` file from the npm package. The wrappers at `.codex/scripts/` reach VSIX-fed destinations but not `npx`-fed ones unless the filter is anchored. This needs a decision, because it also affects the six epic-child scripts already in `core.json`.
3. **Decision 4, port completeness.** `CodexDeployment.psm1:66-78` omits `commit-steward`, so the "faithful port" premise holds for 11 of the 12 families. Byte-comparable wrapper output requires adding it, which also changes Claude-side receipt validation behavior.
4. **Decision 4, self-hosting.** Inside drm-copilot, `.codex/lib` does not exist, so the wrappers need a `.claude/lib` fallback (§2.6).
5. **Issue test proposal (not a settled decision).** Requiring `model` and `model_reasoning_effort` in every role file would fail on files Codex loads today (§5). Scope the requirement to routed families, epic personas, and variant/canonical key parity.
6. **Byte source for decision 4.** The closest existing precedent is a new shared mirror at `resources/lib/codex-routing/`. It adds a third byte copy of each module, which is consistent with "authored once" but still a maintenance cost.

## 16. Unverified Items

- The complete Codex v0.154.0 role-file key set, and Codex's semantics for hook exit code 2.
- Whether `pwsh -File <script> --flag value` passes `--flag` to the script as a literal string.
- Whether `ConvertTo-Json -EscapeHandling EscapeNonAscii` output matches Python `ensure_ascii` byte for byte, and the default newline and indent format of `ConvertTo-Json` on Windows.
- Empirical contents of the npm package `resources/` (not built locally).
- Whether `codex doctor --json` and `codex exec` stderr report role and hook failures in v0.154.0.
- The origin of the literal `CODEX_TOPOLOGY_RESOLVER_UNAVAILABLE`.
- The full body diff between the `csharp-legacy` variant and the canonical agent file (only sampled).
