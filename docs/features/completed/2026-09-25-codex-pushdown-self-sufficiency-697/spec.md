# 2026-09-25-codex-pushdown-self-sufficiency (Spec)

- **Issue:** #697
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-25T10-15
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (acceptance-criteria source: this file only)
- **Research:** `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697/research/2026-09-25T09-40-codex-pushdown-self-sufficiency-research.md` (cited below as "research §N")
- **Issue comment incorporated:** https://github.com/drmoisan/drm-copilot/issues/697#issuecomment-5840837438 (scope additions A, B, C)

## Context

The Codex customization payload published by `push_down_codex_and_agents_customizations` is not self-sufficient in a destination repository. A destination checkout receives hooks that fire on every tool call, an agent role Codex refuses to load, and an orchestration skill whose canonical topology and deployment resolvers are not delivered, so `$orchestrate` cannot start.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (defect is in the published payload, not the interpreter)
- Command/flags used: `codex` v0.154.0 in a destination checkout; `$orchestrate <objective>`
- Data source or fixture: destination checkout `TaskMaster-wt/2026-09-17T18-33`, populated by an earlier `push_down_codex_and_agents_customizations` run

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

The Codex orchestration surface is currently only usable inside `drm-copilot` itself. In any destination repository it emits hook failures on every tool call and cannot begin orchestration.

## Problem Statement

A repository populated by `push_down_codex_and_agents_customizations` cannot run the Codex orchestration surface it was given. Four observable failures were reproduced in a destination checkout (see Repro & Evidence):

1. `.codex/hooks/enforce-epic-planning-only.ps1` exits 1 on every matched tool call because a file it requires at load time is not published.
2. Older published hooks emit the legacy `{"decision":"allow"}` shape that Codex v0.154.0 rejects. Current source hooks no longer do this; the leg is payload staleness, closed by republishing, and is guarded here only by the hook-probe evidence.
3. The `csharp-legacy` variant of `csharp-typed-engineer.toml` carries an unknown `variant` key, so Codex drops the role.
4. The `codex-model-routing` skill instructs Codex to run Python modules that are not published, so `$orchestrate` halts before delegation.

Research found that the publishing path and the packaging path contain further defects that would prevent any fix to item 4 from reaching destinations (research §1, §15). This spec covers the four reproduced defects, those findings, and the three scope additions from the issue comment.

## Repro & Evidence

Steps to Reproduce:
1. Run `push_down_codex_and_agents_customizations` into a destination repository that is not `drm-copilot`.
2. Start Codex v0.154.0 in that destination checkout.
3. Observe the startup banner and the per-tool-call hook results.
4. Issue any request that routes through `$orchestrate`.

Expected:
Every hook registered by the published `.codex/config.toml` loads and returns a valid PreToolUse result. Every agent role in the published `.codex/agents/` deserializes. `$orchestrate` resolves Codex topology and deployment and proceeds to delegation.

Actual:
Four distinct failures, all reproduced:

1. **`hook exited with code 1` on every tool call.** `.codex/hooks/enforce-epic-planning-only.ps1` calls `Get-EpicPlanningRegisteredMcpTool` at script scope (line 86), outside any `try`/`catch`. It throws `EPIC_PLANNING_ONLY_BLOCKED: semantic MCP registry '<root>/config/orchestration-handoff-registry.json' does not exist.` when that file is absent, and an uncaught throw makes `pwsh -File` exit 1. The hook is registered under the `^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$` matcher, so it fires on every tool call regardless of relevance.

2. **`hook returned invalid pre-tool-use JSON output`, 2-4 times per tool call.** Five hooks in an older published payload print `{"decision":"allow"}` on the allow path. Codex 0.154.0 accepts empty stdout or a `hookSpecificOutput` object and rejects the legacy shape. Current source hooks already emit nothing on allow, so this leg is staleness rather than a live source defect.

3. **`Ignoring malformed agent role definition: unknown field 'variant'`.** `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml` carries `variant = "legacy"` in place of the `model` / `model_reasoning_effort` pair the canonical agent file declares. Codex's role deserializer rejects the unknown key and drops the role entirely, so the legacy C# engineer persona is unavailable and its model pinning is lost. This is a live defect in the current bundle, not staleness.

4. **`$orchestrate` halts at `CODEX_TOPOLOGY_RESOLVER_UNAVAILABLE`.** `.agents/skills/codex-model-routing/SKILL.md` prescribes `poetry run python -m scripts.dev_tools.resolve_codex_topology` and `resolve_codex_deployment`. Those modules exist only under `drm-copilot/scripts/dev_tools/`; no `scripts/` tree and no `pyproject.toml` are published. No MCP substitute is exposed: `.codex/config.toml` `enabled_tools` omits `resolve_orchestration_topology`, `resolve_provider_routing`, and `transition_prepared_orchestration`, and those three resolve portable-handoff topology from a prepared envelope, which is a different contract from file-count-to-logical-agent topology. (The literal halt code does not appear in the repository; the Codex agent appears to have composed it — research §9, unverified.)

Logs / Screenshots:
- [x] Attached minimal logs or snippet
- Snippet (Codex, destination checkout):

```
⚠ Ignoring malformed agent role definition: failed to deserialize agent role file at
  .codex\agents\csharp-typed-engineer.toml: unknown field `variant`

• Hook failed
  └ hook returned invalid pre-tool-use JSON output
• Hook failed
  └ hook returned invalid pre-tool-use JSON output
• Hook failed
  └ hook exited with code 1
```

- Probe of the published hooks under a synthetic `PreToolUse` payload, destination vs. current source:

```
EXIT-1         enforce-epic-planning-only.ps1
   STDERR: EPIC_PLANNING_ONLY_BLOCKED: semantic MCP registry '...' does not exist.
OUTPUT         enforce-promotion-mcp-only.ps1              STDOUT: {"decision":"allow"}
OUTPUT         enforce-orchestration-preimplementation-gate.ps1  STDOUT: {"decision":"allow"}
OUTPUT         enforce-evidence-locations.ps1             STDOUT: {"decision":"allow"}
OUTPUT         enforce-checkpoint-monotonic.ps1           STDOUT: {"decision":"allow"}
OUTPUT         enforce-completion-consistency.ps1         STDOUT: {"decision":"allow"}
```

For a shell command, matcher group 1 contributes 2 invalid-JSON hooks and matcher group 2 contributes the 1 exit-1, giving 3 failures. For an `apply_patch`, matcher group 2 contributes the exit-1 and matcher group 3 contributes 4 invalid-JSON hooks, giving 1 + 4.

## Root Cause Analysis

### Defects reproduced in the destination

- **D1 — Load-time dependency on an optional artifact.** `$script:AllowedPreparationSemanticMcpTools` is computed at script scope (`.codex/hooks/enforce-epic-planning-only.ps1:85-88`), before the dot-source guard (`:315-317`) and outside the `try` block (`:319-355`). `Get-EpicPlanningRegisteredMcpTool` throws when the registry is absent (`:57-58`). The variable has one consumer, `Invoke-EpicPlanningOnlyDecision` at `:273`, which runs only for a preparation-route MCP call that is not in the lifecycle list (`:216-230`, `:233-270`). The hook therefore converts a file needed by one narrow authorization path into a failure of every matched tool call (research §6.1).
- **D2 — Unvalidated variant role file.** `.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml` line 3 carries `variant = "legacy"` in place of `model = "gpt-5.6-terra"` and `model_reasoning_effort = "high"` declared by the canonical file (`.codex/agents/csharp-typed-engineer.toml:3-4`). `generate_codex_agent_variants.py` reads only `.codex/agents/` (`:186-192`); `test_push_down_codex_and_agents_resource_contracts.py` checks only that the variant file exists (`:49-54`, `:197-205`); no test parses variant TOML. `CSHARP_CANONICAL_PATHS` redirects only the base alias to the variant tree (`scripts/dev_tools/push_down_codex_pack_selection.py:24-29`, `:178-194`) (research §5).
- **D3 — Resolvers not delivered.** The skill prescribes Python CLIs (`.agents/skills/codex-model-routing/SKILL.md:19`, `:56`, `:102-106`) that are not published. A PowerShell port exists at `.claude/lib/codex-routing/CodexTopology.psm1` and `.claude/lib/codex-routing/CodexDeployment.psm1`, but it ships only in the Claude pack manifest and no CLI wrapper exposes it (research §3, §4).
- **D4 — Incomplete core manifest.** `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` hook entries (`:29-46`) omit 11 hooks that `.codex/config.toml` registers unconditionally and the transitive dependency `enforce-completion-helpers.ps1`. The defect is latent in full-tree mode (`packs=None` yields `published_paths=None`, `push_down_codex_and_agents_customizations.py:171-173`) and active in any pack-scoped push (research §7.3, §12 N2).

### Research findings that extend the fix

- **F1 — The MCP tool runs the TypeScript publisher, which publishes only one config file.** The MCP handler routes to `runPushDownCodexAndAgentsCustomizations` (`extensions/drm-copilot/src/repo-automation-service-push-down.ts:119-137`), which sets `sourceRoot = bundleRoot = <extensionRoot>/resources/codex-and-agents-customizations` (`extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts:120-145`). Its `RoutingConfigFileSystem` maps only `config/orchestration-routing.json` (`extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts:37`, `:177-227`). MCP-fed destinations never receive `config/orchestration-handoff-registry.json` or `config/orchestration-handoff.schema.json`, although `core.json:100-101` lists both. The Python CLI's `SHARED_CONFIG_RELATIVE_PATHS` does publish all three (`scripts/dev_tools/push_down_codex_and_agents_customizations.py:68-72`). Neither publisher's virtual-path class supports a source-to-destination rename, and each has a single virtual root (`:113-128`; research §2.2, §2.3).
- **F2 — The npm `prepack` filter drops every nested `scripts` segment.** `shouldCopy` rejects any path matching `/(^|\/)scripts(\/|$)/` (`packages/mcp-server/prepack.cjs:44`), which excludes `resources/codex-and-agents-customizations/.codex/scripts/*`, including the epic-child scripts already listed in `core.json:47-52` and the new wrappers. The VSIX path is unaffected (`extensions/drm-copilot/.vscodeignore:19`). No test covers `prepack.cjs` (research §2.7).
- **F3 — The PowerShell deployment port omits `commit-steward`.** `CodexDeployment.psm1:66-78` omits `commit-steward`, which `scripts/dev_tools/resolve_codex_deployment.py:41` and the TypeScript validator (`extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts:44`) include. `CodexDeployment.Parity.Tests.ps1:104-115` ('accepts every generated agent family') lists the same incomplete set and does not detect the gap (research §3.3, §4).

Two further research observations constrain the design: the wrappers need a `.claude/lib/codex-routing/` fallback because `.codex/lib/` does not exist inside drm-copilot (research §2.6), and a requirement that every role file declare `model` and `model_reasoning_effort` would fail on valid files such as `.codex/agents/5.1-beast-adjusted.toml:1-4` (research §5).

## Scope & Non-Goals

- In scope:
  - Item 1: correct the `csharp-legacy` variant role file and add an agent-role schema guard.
  - Item 2: in-PR integration and probe evidence in place of live destination verification (scope change; see Rollout & Follow-up).
  - Item 3: fail-soft registry loading in `.codex/hooks/enforce-epic-planning-only.ps1` and its bundle copy.
  - Item 4: publish the resolver modules and CLI wrappers through both publishers, including scope additions A (TypeScript publisher), B (`prepack.cjs` anchoring), and C (`commit-steward` port fix); repoint the `codex-model-routing` skill.
  - Item 5: reconcile `core.json` with every registered hook and its dot-source closure, and add a mechanical guard.
- Out of scope / non-goals:
  - No `@danmoisan/drm-copilot-mcp` package release and no change to `packages/mcp-server/package.json` `version`.
  - No bump of the MCP version pin in `.codex/config.toml` or in the bundle copy of `.codex/config.toml`.
  - No live re-push into a destination as a completion criterion (recorded as a follow-up).
  - No change to Claude-side hook behavior (`.claude/hooks/**`). The only Claude-side change is the `commit-steward` addition to `.claude/lib/codex-routing/CodexDeployment.psm1` and its mirrors; the resulting acceptance of `commit-steward` receipts by `.claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1` (`:14`, `:35`) is an intended consequence (research §4).
  - No change to the portable-handoff tools `resolve_orchestration_topology`, `resolve_provider_routing`, `transition_prepared_orchestration`, and no change to `enabled_tools` in `.codex/config.toml`.
  - No split of `.codex/config.toml` into per-pack hook registrations; language packs gain no hooks.
  - No change to the epic-planning Bash allowlist entry for `python -m scripts.dev_tools.validate_*` (`enforce-epic-planning-only.ps1:162`).
- Explicitly excluded systems, integrations, or datasets: the destination checkout `TaskMaster-wt/2026-09-17T18-33`; the Codex CLI itself.

## Proposed Fix

### Design summary (what changes where):

1. **Item 1.** Replace `variant = "legacy"` in `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml` with `model = "gpt-5.6-terra"` and `model_reasoning_effort = "high"`. Add `tests/scripts/dev_tools/test_codex_agent_role_schema.py` with the four rules of research §5.
2. **Item 3.** Remove the script-scope registry load (`:86-88`). Resolve the semantic MCP list lazily inside `Invoke-EpicPlanningOnlyDecision`, only after the lifecycle-list check is false and the tool matches `mcp__*`. Add a `-RegistryPath` parameter defaulting to `Join-Path $script:EpicPlanningRepositoryRoot 'config/orchestration-handoff-registry.json'`. When the path does not exist, return `Get-EpicPlanningDenyDecision` with a reason that names the missing registry. A present but malformed registry continues to throw into the existing `catch` (exit 2). Apply identically to the bundle copy (research §6.3).
3. **Item 4.**
   - Generalize Python `_RoutingConfigFileSystem` and TypeScript `RoutingConfigFileSystem` to `(destination_relative, resource_relative)` pairs with a set of virtual-only roots (`config`, `.codex/lib/codex-routing`); add `.codex/lib/codex-routing` to both publishers' published-root lists; add the registry and schema pairs to TypeScript.
   - Add the shared mirror `extensions/drm-copilot/resources/lib/codex-routing/{CodexTopology,CodexDeployment}.psm1`, read through the bundle parent in the same way as `resources/config` (research §2.4, recommended option).
   - Add `.codex/scripts/Resolve-CodexTopology.ps1` and `.codex/scripts/Resolve-CodexDeployment.ps1` (root and bundle copies) with GNU-flag parsing, argparse-equivalent validation, ordinal-sorted JSON output, and a two-candidate module lookup.
   - Add `commit-steward` to `CodexDeployment.psm1` and all mirrors.
   - Anchor the `prepack.cjs` `scripts` exclusion to the resources root and export `shouldCopy` for testing.
   - Repoint `.agents/skills/codex-model-routing/SKILL.md` (root and bundle).
4. **Item 5.** Add the missing hook, dependency, and item-4 paths to `core.json`; prune `PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS`; add a closure guard.

### Boundaries and invariants to preserve:

- Virtual roots stay virtual-only; the physical `config/` directory of the repository is never walked by the publisher (research §2.2).
- No physical `.codex/lib/` directory exists in the repository or in the Codex bundle (research §2.5).
- The `.claude/lib/codex-routing/` modules remain the single authored source; every other copy is a test-guarded byte mirror.
- Python files remain excluded from the npm package at every depth.
- `core.json` stays in `json.dumps(indent=2)` form with a trailing LF so `generate_codex_agent_variants.py --check` reports no drift (research §7.5).
- Registry-dependent authorization in preparation mode fails closed.

### Dependencies or blocked work:

- Destinations fed by the MCP tool receive the fix only after a package release (see Rollout & Follow-up). Until item 4's TypeScript change ships, a destination under a preparation checkpoint denies registry-dependent semantic MCP calls; this is the intended fail-closed result (research §6.6).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

See research §11. Additionally: `tests/fixtures/codex_routing/*.json` (parity corpus), the new tests listed in the acceptance criteria, and both copies of `pester.runsettings.psd1`.

#### Functions/classes/CLI commands impacted:

`Invoke-EpicPlanningOnlyDecision`; `_RoutingConfigFileSystem`, `PUBLISHED_ROOT_FOLDERS`, `SHARED_CONFIG_RELATIVE_PATHS` (Python); `RoutingConfigFileSystem` and its published-root list (TypeScript); `Resolve-CodexDeployment` family list; `shouldCopy` (`prepack.cjs`); new wrapper CLIs.

#### Data flow and validation changes:

Wrapper arguments are validated in the wrapper before the module call: choice and integer violations exit 2; module `ArgumentException` exits 1 (research §3.3).

#### Error handling and logging updates:

A missing registry yields a deny decision naming the registry, not an uncaught throw. A wrapper that finds neither module candidate writes an explicit stderr message and exits non-zero.

#### Rollback/feature-flag considerations (if applicable):

None. Each change is a file-level revert.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Wrapper argument contracts equal the Python CLIs (research §3.1, §3.2). `-AvailableModel` is not exposed.
- Wrapper stdout is JSON with keys sorted by `[System.StringComparer]::Ordinal`, indent-2, non-ASCII escaped, produced with explicit depth.
- **Parity normalization:** convert CRLF to LF, strip trailing whitespace and newlines, then compare byte for byte; additionally compare parsed objects. For error cases compare exit code, require empty stdout, and compare stderr by message substring only (research §3.4).

#### Required configuration keys and defaults:

`-RegistryPath` default as stated in the design summary.

#### Backward-compatibility expectations:

Hook allow behavior for all registry-independent paths is unchanged. Python CLIs are unchanged. The `.claude/lib/codex-routing` public functions keep their signatures.

#### Performance constraints (latency/throughput/memory):

No new constraint. The registry is now read only on the registry-dependent path, which reduces work on other calls.

## Assumptions, Constraints, Dependencies

- Assumptions: invoking the bundle copy of a hook in place gives a repository root of `extensions/drm-copilot/resources/codex-and-agents-customizations` (`enforce-epic-planning-only.ps1:85`), which has no `config/` directory (`test_push_down_codex_and_agents_resource_contracts.py:208-212`). This provides a registry-absent environment without creating files.
- Constraints: temporary files in tests are prohibited; the destination filesystem in the TypeScript integration test is in memory. File size limit of 500 lines applies to all production and test files.
- Unverified items that the tests must settle (research §16): whether `pwsh -File <script> --flag value` delivers `--flag` literally; whether `ConvertTo-Json -EscapeHandling EscapeNonAscii` matches Python `ensure_ascii` byte for byte.
- External dependencies: none new.

## Data / API / Config Impact

- User-facing or API changes: two new PowerShell CLIs in published destinations; the `codex-model-routing` skill text changes.
- Data or migration considerations: none.
- Logging/telemetry updates: new deny reason text for a missing registry.
- Compatibility notes: the npm package will contain `.codex/scripts/*.ps1` after the next release; it continues to exclude every `.py` file.

## Test Strategy

Seeded from issue, then revised by research:

- The issue's proposed rule that every role file declare `model` and `model_reasoning_effort` is replaced by the scoped rules in AC-1.4 and AC-1.5, because the unscoped rule fails on valid files (research §5).
- The issue's live re-push integration scenario is replaced by AC-2.1 to AC-2.4 (settled decision, item 2).
- Toolchains: Python (black, ruff, pyright, pytest), TypeScript (prettier, eslint, tsc, jest), PowerShell (PoshQC format, analyze, test).

## Acceptance Criteria

### Item 1 — `csharp-legacy` role file and role-schema guard

- [x] **AC-1.1** `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml` contains no `variant` key and declares `model = "gpt-5.6-terra"` and `model_reasoning_effort = "high"`. Proven by the AC-1.5 test case for this file, which fails against the current file.
- [x] **AC-1.2** New `tests/scripts/dev_tools/test_codex_agent_role_schema.py` parses, with `tomllib`, every `.codex/agents/*.toml` in the repository, every `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/*.toml`, and every `.codex-variants/**/agents/*.toml` in that bundle, and asserts each file's top-level keys are a subset of an explicit allowlist that excludes `variant` and `mcp_servers`. The test contains an in-memory negative case (a TOML string with `variant = "legacy"`) asserting the rule reports `variant`.
- [x] **AC-1.3** The same test file asserts `name`, `description`, and `developer_instructions` are present in every file of the three sets.
- [x] **AC-1.4** The same test file asserts `model` and `model_reasoning_effort` are present for every base alias and profile of each family in `GENERATED_AGENT_FAMILIES` (`scripts/dev_tools/resolve_codex_deployment.py:32-47`) and for both epic personas, and does not require them for other role files (for example `.codex/agents/5.1-beast-adjusted.toml` passes).
- [x] **AC-1.5** The same test file asserts that each `.codex-variants/<variant>/agents/<name>.toml` has the same top-level key set, `model` value, and `model_reasoning_effort` value as the canonical `.codex/agents/<name>.toml` in the bundle, parametrized per variant file.

### Item 2 — In-PR evidence in place of live destination verification

- [x] **AC-2.1** A new Jest integration test under `extensions/drm-copilot/test/lib/push-down/` drives the real TypeScript publisher (`pushDownCodexAndAgentsCustomizationsServiceCall` or `pushDownCustomizations` with the production filesystem wrappers) over the real `extensions/drm-copilot/resources/codex-and-agents-customizations` bundle with an in-memory destination filesystem, in full-tree mode, and asserts the destination contains `config/orchestration-routing.json`, `config/orchestration-handoff-registry.json`, `config/orchestration-handoff.schema.json`, `.codex/lib/codex-routing/CodexTopology.psm1`, `.codex/lib/codex-routing/CodexDeployment.psm1`, `.codex/scripts/Resolve-CodexTopology.ps1`, and `.codex/scripts/Resolve-CodexDeployment.ps1`, with module bytes equal to `.claude/lib/codex-routing/*.psm1`. No temporary file is created.
- [x] **AC-2.2** The same integration test file runs the publisher in pack mode with the `typescript` pack selected and asserts that every hook file registered by the bundle `.codex/config.toml`, together with its transitive dot-source closure, is present in the in-memory destination.
- [x] **AC-2.3** The same integration test file runs the publisher with the `csharp-legacy` pack selected and asserts the published `.codex/agents/csharp-typed-engineer.toml` contains `model = "gpt-5.6-terra"` and no `variant` key.
- [x] **AC-2.4** A new Pester hook-probe test invokes, through `pwsh -NoProfile -File` and the `ProcessStartInfo` pattern of `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:60-90`, every hook registered by the bundle `.codex/config.toml` from its bundle location (where `config/orchestration-handoff-registry.json` is absent) with synthetic `Bash`, `apply_patch`, `Edit`, and `mcp__` PreToolUse payloads that no gate should deny, and asserts for each invocation exit code 0 and stdout that is either empty or a JSON object containing `hookSpecificOutput`. Stdout equal to the legacy `{"decision":"allow"}` shape fails the test. Before the item 3 fix, this test fails for `enforce-epic-planning-only.ps1`.
- [x] **AC-2.5** A follow-up is recorded as a potential item under `docs/features/potential/` that specifies: after the next `@danmoisan/drm-copilot-mcp` release, bump the MCP version pin in both `.codex/config.toml` copies (repository and bundle) and re-run `push_down_codex_and_agents_customizations` into a destination, confirming zero hook failures, no malformed-role warning, and successful topology and deployment resolution. The spec's Rollout & Follow-up section links it.

### Item 3 — Fail-soft registry loading in `enforce-epic-planning-only.ps1`

- [x] **AC-3.1** A Pester test parses `.codex/hooks/enforce-epic-planning-only.ps1` with the PowerShell AST and asserts no top-level statement (outside any function definition) invokes `Get-EpicPlanningRegisteredMcpTool`. The test fails against the current file (`:86-88`).
- [x] **AC-3.2** `Invoke-EpicPlanningOnlyDecision` accepts a `-RegistryPath` parameter. A Pester test passing a non-existent `-RegistryPath` and no checkpoint or preparation attestation asserts the function returns `$null` (allow).
- [x] **AC-3.3** With a non-existent `-RegistryPath` and a non-preparation route, a Pester test asserts the function returns `$null` for an `mcp__` tool call.
- [x] **AC-3.4** With a non-existent `-RegistryPath` in preparation mode, Pester tests assert the `apply_patch` planning-path decisions and the `Bash` allowlist decisions equal the decisions produced with the committed `config/orchestration-handoff-registry.json` for the same inputs.
- [x] **AC-3.5** With a non-existent `-RegistryPath` in preparation mode, a Pester test asserts each tool in `$script:AllowedPreparationMcpTools` is allowed, subject to the unchanged `workspace_root` check.
- [x] **AC-3.6** (Negative, fail closed.) With a non-existent `-RegistryPath` in preparation mode, a Pester test parametrized over each semantic MCP tool resolved from the committed registry, plus one unregistered `mcp__` tool, asserts the function returns the `Get-EpicPlanningDenyDecision` shape with a reason that contains the registry path and states that it does not exist.
- [x] **AC-3.7** With `-RegistryPath` set to the committed `config/orchestration-handoff-registry.json` in preparation mode, a Pester test asserts each semantic MCP tool is allowed.
- [x] **AC-3.8** (Negative, fail closed.) With `-RegistryPath` set to a committed malformed fixture under `tests/fixtures/codex-hooks/`, a Pester test asserts a semantic MCP call in preparation mode throws (so the hook's top-level `catch` exits 2) rather than allowing.
- [x] **AC-3.9** The bundle copy `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1` is byte-identical to the repository copy, proven by `codex-epic-runtime-contracts.Tests.ps1` 'keeps root and tracked bundle runtime copies byte-identical', `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`, and `test_handoff_runtime_has_root_bundle_resource_and_effective_pack_parity` passing.

### Item 4 — Resolver delivery, both publishers, packaging, and the port fix

Python publisher:

- [x] **AC-4.1** A pytest test using the in-memory doubles in `tests/scripts/dev_tools/push_down_customizations_test_support.py` asserts that `_RoutingConfigFileSystem` publishes destination `.codex/lib/codex-routing/CodexTopology.psm1` and `.codex/lib/codex-routing/CodexDeployment.psm1` with bytes read from `lib/codex-routing/<Module>.psm1` under the bundle parent (a different relative path, proving rename support), in both full-tree mode and pack mode.
- [x] **AC-4.2** A pytest test asserts that a file present in the source root's physical `config/` directory but not in the pair map is not published, and that `.codex/lib/codex-routing` is walked as a published root.

TypeScript publisher (scope addition A):

- [x] **AC-4.3** A Jest unit test in `extensions/drm-copilot/test/lib/push-down/codex-agents-customizations.test.ts` asserts that `RoutingConfigFileSystem` publishes `config/orchestration-routing.json`, `config/orchestration-handoff-registry.json`, `config/orchestration-handoff.schema.json`, and both `.codex/lib/codex-routing/*.psm1` destinations from their resource paths, in both full-tree mode and pack mode, and does not publish an unmapped file placed under a virtual root. The existing test 'copies the .codex and .agents trees in deterministic root then path order' is updated to the new expected path set and passes.

Shared module mirror:

- [x] **AC-4.4** `extensions/drm-copilot/resources/lib/codex-routing/CodexTopology.psm1` and `CodexDeployment.psm1` exist, and a new pytest test modeled on `test_routing_config_remains_a_shared_resource_outside_codex_bundle` asserts each is byte-identical to `.claude/lib/codex-routing/<Module>.psm1`.
- [x] **AC-4.5** A pytest test asserts that neither `.codex/lib/` in the repository nor `.codex/lib/` in the Codex bundle exists as a physical directory.

CLI wrappers:

- [x] **AC-4.6** A committed parity corpus `tests/fixtures/codex_routing/*.json` holds records `{argv, expected_exit, expected_stdout}` for both resolvers. A pytest test runs each record through the Python CLI `main(argv)` in-process and asserts the recorded exit code and stdout, so the corpus is proven to reflect Python behavior.
- [x] **AC-4.7** A new Pester test under `tests/scripts/codex-scripts/` invokes `.codex/scripts/Resolve-CodexTopology.ps1` and `.codex/scripts/Resolve-CodexDeployment.ps1` through `pwsh -NoProfile -File` with each corpus `argv` (GNU `--flag value` tokens) and asserts, under the parity normalization stated in Technical specifications, byte-equal stdout, equal parsed objects, and equal exit codes.
- [x] **AC-4.8** The corpus includes success cases covering every `--execution-context` choice, `--cross-cutting`, each `--root-persona` choice, repeated `--language`, a non-ASCII `--language` value, and `--logical-agent commit-steward`; and error cases covering a missing required flag, an invalid choice, and a non-integer count (expected exit 2, empty stdout) and an empty `--language`, `--root-persona` with a non-standalone context, a ceiling below the band, and an unsupported logical agent (expected exit 1, empty stdout, stderr containing the Python message substring). AC-4.6 and AC-4.7 pass over this corpus.
- [x] **AC-4.9** Each wrapper resolves its module from `$PSScriptRoot/../lib/codex-routing/<Module>.psm1`, then `$PSScriptRoot/../../.claude/lib/codex-routing/<Module>.psm1`. A Pester test of the resolution function asserts the first existing candidate wins when both exist, the second is used when the first does not exist, and a candidate list with no existing path produces a non-zero exit and an stderr message naming the candidates. The AC-4.7 run inside drm-copilot, where `.codex/lib/` does not exist, proves the fallback end to end.
- [x] **AC-4.10** The bundle copies of both wrappers are text-equal to the repository copies, proven by `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` passing.

`commit-steward` port fix (scope addition C):

- [x] **AC-4.11** `.claude/lib/codex-routing/CodexDeployment.psm1` accepts `commit-steward`. The 'accepts every generated agent family' case in `tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1` includes `commit-steward` and fails against the current module; a new case asserts `Resolve-CodexDeployment -LogicalAgent commit-steward` returns the same receipt values as the Python resolver for the same band, context, and ceiling.
- [x] **AC-4.12** The Claude bundle mirror `extensions/drm-copilot/resources/claude-customizations/.claude/lib/codex-routing/CodexDeployment.psm1` is updated in lockstep, proven by `CodexRouting.Manifest.Tests.ps1` 'mirrors every codex-routing module byte-identically into the bundle' passing, and the shared mirror is proven by AC-4.4.

npm packaging (scope addition B):

- [x] **AC-4.13** `packages/mcp-server/prepack.cjs` exports `shouldCopy` and runs `cpSync` only when executed as the main module, so requiring it in a test performs no copy.
- [x] **AC-4.14** A new unit test asserts `shouldCopy` returns true for `<resources>/codex-and-agents-customizations/.codex/scripts/Resolve-CodexTopology.ps1` and for the existing `.codex/scripts/*.ps1` epic-child scripts, and false for `<resources>/scripts` and any path beneath it. The test runs under a runner that CI executes and uses path strings only (no filesystem access).
- [x] **AC-4.15** (Negative.) The same test asserts `shouldCopy` returns false for `.py` paths at the resources root, under `<resources>/scripts/`, under `.codex/scripts/`, and at a nested depth of at least three directories.

Skill repointing:

- [x] **AC-4.16** A named pytest test asserts that `.agents/skills/codex-model-routing/SKILL.md` and its bundle copy contain no `poetry run python -m scripts.dev_tools.resolve_codex_` invocation, instruct invocation of `.codex/scripts/Resolve-CodexTopology.ps1` and `.codex/scripts/Resolve-CodexDeployment.ps1`, and direct validation to the MCP tool `validate_orchestration_artifacts` with `require_codex_topology` and `require_codex_model_routing` set. The test fails against the current file (`SKILL.md:19`, `:56`, `:102-106`). The bundle copy's text equality is proven by `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`.

### Item 5 — `core.json` completeness and closure guard

- [x] **AC-5.1** `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` lists all 21 hooks registered by `.codex/config.toml` (research §12 N1), the 12 previously missing hook and dependency paths (research §12 N2), every other transitive dot-source dependency, and the 4 item-4 paths `.codex/scripts/Resolve-CodexTopology.ps1`, `.codex/scripts/Resolve-CodexDeployment.ps1`, `.codex/lib/codex-routing/CodexTopology.psm1`, `.codex/lib/codex-routing/CodexDeployment.psm1`. Proven by AC-5.2.
- [x] **AC-5.2** A new pytest guard parses the bundle `.codex/config.toml` with `tomllib`, collects every hook `command` path, computes the transitive dot-source closure, adds the two wrappers and their module imports, and asserts the result is a subset of `core.json` `paths` (core alone, not the union of manifests) and that each path exists in the bundle or is a virtual resource. The guard fails against the current `core.json`.
- [x] **AC-5.3** The guard's closure computation is unit-tested on in-memory script text for each of the three dot-source forms (`. (Join-Path $PSScriptRoot '<f>')`; `$v = Join-Path $PSScriptRoot '<f>'` followed by `. $v`; `Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts/<f>'`), and a negative case asserts that an in-memory config registering a hook absent from an in-memory manifest is reported.
- [x] **AC-5.4** The 12 entries of research §12 N2 are removed from `PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS` in `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, and `test_bundled_codex_files_are_listed_in_some_pack_manifest` and `test_no_bundled_codex_file_is_absent_from_disk_and_exception_list` pass.
- [x] **AC-5.5** `test_generator_check_mode_reports_no_drift` passes after the `core.json` edit, proving the manifest remains in generator-canonical form.

### Cross-cutting — mirrors, coverage, toolchain, and non-goals

- [x] **AC-6.1** Every changed file with a mirror under `extensions/drm-copilot/resources/` is updated in lockstep, and these existing parity tests pass: `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`, `test_handoff_runtime_has_root_bundle_resource_and_effective_pack_parity`, `test_every_selected_pack_generates_identical_handoff_runtime_files`, `codex-epic-runtime-contracts.Tests.ps1` 'keeps root and tracked bundle runtime copies byte-identical' and 'includes every epic runtime surface in the core pack manifest', `CodexRouting.Manifest.Tests.ps1` 'mirrors every codex-routing module byte-identically into the bundle', and `test_poshqc_bundled_module_files_match_repo_root_sources`.
- [x] **AC-6.2** `.codex/scripts/Resolve-CodexTopology.ps1` and `.codex/scripts/Resolve-CodexDeployment.ps1` are registered for coverage in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and in `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
- [x] **AC-6.3** Coverage evidence recorded under `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697/evidence/coverage/` shows line coverage >= 85% and branch coverage >= 75% for the changed Python and TypeScript production files, line coverage >= 85% for the changed PowerShell production files (Pester, line-only), and no coverage regression on changed lines. No production path is added to any coverage `exclude` list.
- [x] **AC-6.4** The Python, TypeScript, and PowerShell toolchains each complete format, lint, type-check (where applicable), and test in a single clean pass, with results recorded under the feature `evidence/` folder.
- [x] **AC-6.5** No new or changed production or test file exceeds 500 lines.
- [x] **AC-6.6** (Non-goals.) `git diff main...HEAD --name-only` lists no change to `packages/mcp-server/package.json`, `.claude/hooks/**`, or the portable-handoff tool implementations, and `git diff main...HEAD` shows no change to the MCP version pin line or the `enabled_tools` list in either copy of `.codex/config.toml`.

## Traceability

| AC ID | Item closed | Defect / finding |
|---|---|---|
| AC-1.1 – AC-1.5 | Item 1 | D2 |
| AC-2.1 | Item 2 | F1, D3 (MCP publishing evidence) |
| AC-2.2 | Item 2 | D4 (pack-mode evidence) |
| AC-2.3 | Item 2 | D2 (published-role evidence) |
| AC-2.4 | Item 2 | D1, reproduced failure 2 (legacy allow JSON) |
| AC-2.5 | Item 2 | Deferred live verification |
| AC-3.1 – AC-3.9 | Item 3 | D1 |
| AC-4.1 – AC-4.2 | Item 4 | D3 (Python publisher) |
| AC-4.3 | Item 4 (scope addition A) | F1 |
| AC-4.4 – AC-4.5 | Item 4 | D3 (module byte source) |
| AC-4.6 – AC-4.10 | Item 4 | D3 (wrappers, self-hosting fallback) |
| AC-4.11 – AC-4.12 | Item 4 (scope addition C) | F3 |
| AC-4.13 – AC-4.15 | Item 4 (scope addition B) | F2 |
| AC-4.16 | Item 4 | D3 (skill instructions) |
| AC-5.1 – AC-5.5 | Item 5 | D4 |
| AC-6.1 – AC-6.6 | Cross-cutting | Mirrors, coverage, toolchain, non-goals |

## Risks & Mitigations

- Anchoring the `prepack.cjs` exclusion also ships any other nested `scripts/` directory under `resources/` that contains non-Python files. Mitigation: AC-4.14 and AC-4.15 fix the intended behavior; the plan should enumerate the nested `scripts/` directories affected and record them in evidence.
- Adding `commit-steward` changes Claude-side receipt validation. Mitigation: this is the intended parity with the Python and TypeScript authorities (F3); AC-4.11 asserts receipt equality.
- `ConvertTo-Json` non-ASCII escaping and `pwsh -File` flag delivery are unverified (research §16). Mitigation: AC-4.7 and AC-4.8 exercise both by process invocation; the wrapper may escape manually if the built-in option does not match.
- A third byte copy of each routing module adds maintenance cost. Mitigation: AC-4.4 and AC-4.12 fail on any divergence.

## Rollout & Follow-up

- Release/rollout steps: merge only; no package release in this change.
- Post-fix follow-up (out of scope, AC-2.5): after the next `@danmoisan/drm-copilot-mcp` release, bump the MCP version pin in both `.codex/config.toml` copies and re-run the push-down into a destination for live confirmation. Tracked as [`docs/features/potential/2026-09-25-codex-pushdown-live-verification.md`](../../potential/2026-09-25-codex-pushdown-live-verification.md).
- Links: issue https://github.com/drmoisan/drm-copilot/issues/697; issue comment https://github.com/drmoisan/drm-copilot/issues/697#issuecomment-5840837438; research artifact listed in the header.
