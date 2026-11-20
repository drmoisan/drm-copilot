<!-- markdownlint-disable-file -->

# Task Research Notes: Legacy Discovery and Parity Runtime and Publishing

## Research Executed

### File Analysis

- `.github/agents/task-researcher.agent.md`, `.agents/skills/research-issue/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, and `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`
  - The current canonical source requires tracked feature-associated research, a fixed template, verified findings, two candidate approaches, and seven Pre-Mortem dimensions.
- `.codex/agents/task-researcher-c4.toml` and `.codex/hooks/record-subagent-routing-attestation.ps1`
  - The native profile reads the Copilot agent as canonical; its embedded older research-root text conflicts with that source. This investigation follows the source and supplied feature path. Actual SubagentStart attestation was read before writing: `task-researcher-c4`, `gpt-6-astra`, `max`, `routing_valid=true`, `launch_authority_valid=true`.
- `extensions/drm-copilot/src/discovery-command-registration.ts`, `mcp-discovery-tool-definitions.ts`, `mcp-tool-inputs-discovery.ts`, and `repo-automation-execute-discovery.ts`
  - Traced existing command/MCP dispatch to Python and shared structured-result handling. The standalone package builds the same extension server implementation.
- `docs/engineering/claude-code-architecture.md`, translation skills, `scripts/dev_tools/codex_native_converter/{inventory,mapping,pipeline,rewrites,validation}.py`, publisher implementations, manifests, and routing generators
  - Established canonical authority, publication roots, conversion limitations, generated model selection, and packaged resource exclusions from actual implementation.
- Existing four `.claude/agents/` discovery personas, seven `.claude/skills/discovery-*/SKILL.md` files, `.claude/settings.json`, discovery hooks, and `.claude/lib/discovery-validation/DiscoveryValidation.psm1`
  - Read existing responsibilities, output grants, hook activation, dispatch, and stop behavior. Current enforcement is incomplete.
- Acceptance-criteria tracking, atomic-plan contract, orchestration workflow, current framework onboarding, and contract tests listed below
  - Verified workflow reuse, specification-versus-implementation criteria semantics, distribution gaps, and tests asserting current behavior.

### Code Search Results

- `discovery`
  - Existing Python discovery package, seven extension commands/tools, Claude discovery skills/hooks, and engineering documentation were found; this feature is an extension of existing foundations.
- `ProfileReader`, `Get-RequiredDiscoveryArtifactDeclaration`, `GENERATED_AGENT_FAMILIES`, and `enabled_tools`
  - Discovery activation is a stub. Codex routing families and MCP allowlists omit discovery; canonical Copilot/native Codex counterparts of the four agents and seven skills are absent.
- `ROOT_FOLDERS`, `VIRTUAL_RESOURCE_PAIRS`, `shouldCopy`, and `structuredContent`
  - Publication explicitly enumerates supported roots/resources. The standalone package excludes every Python file. The shared MCP server already supports structured results.

### External Research

- #githubRepo:"modelcontextprotocol/typescript-sdk server tools structuredContent"
  - Inspected the [official TypeScript SDK repository](https://github.com/modelcontextprotocol/typescript-sdk). The local shared-server implementation already supports the required integration; this feature does not require an SDK-major migration.
- #fetch:https://modelcontextprotocol.io/specification/2025-06-18/server/tools
  - The [versioned MCP specification](https://modelcontextprotocol.io/specification/2025-06-18/server/tools) defines structured results, optional output schemas, and tool errors. Retain serialized text JSON for compatible clients and structured findings for machine consumers. Tool descriptions are not authorization controls.
- #fetch:https://code.claude.com/docs/en/hooks
  - The [Claude hook reference](https://code.claude.com/docs/en/hooks) defines JSON event input and agent-type matching. SubagentStop supplies agent identity, transcript path, and final message; a filename in that message does not establish valid required outputs.
- #fetch:https://code.claude.com/docs/en/skills
  - The [skills reference](https://code.claude.com/docs/en/skills) distinguishes descriptions from full invocation-time content. Supporting files remain on-demand, while preloaded agent skills inject their full content. Keep large catalogs and schemas out of standing guidance.
- #fetch:https://code.visualstudio.com/docs/agent-customization/hooks
  - The [VS Code hook documentation](https://code.visualstudio.com/docs/agent-customization/hooks) distinguishes harness payloads and schemas. Local hooks discover `.github/hooks/*.json`; Claude settings require an additional setting off by default, and Local ignores Claude matcher values. Agent-scoped hooks require the Local harness, enabled hooks, and Workspace Trust. Native adapter fixtures and an explicit support matrix are required.
- #fetch:https://code.visualstudio.com/docs/agent-customization/custom-agents
  - The [custom-agent documentation](https://code.visualstudio.com/docs/agent-customization/custom-agents) defines native models/tools. Text describing a restriction does not replace native enforcement.

### Project Conventions

- Standards referenced: `AGENTS.md`, general code/test policies, execution-environment brief, research-issue skill, and evidence-and-timestamp conventions.
- Instructions followed: research only; no source, test, configuration, checkpoint, or consumer repository changes; canonical issue number `980`.
- Research timestamp: clock output `2026-10-18 02:40:37 UTC`. Actual attestation was recorded at `2026-10-17T22:39:31.5283994-04:00` for agent `01a14ce0-e5e9-73e0-a444-6cf9de13ce80`.
- Production quality gates were not run; no implementation-quality pass is claimed. Framework execution evidence belongs in this feature's `evidence/<kind>/`; consumer discovery evidence belongs to consumer profile roots.

## Key Discoveries

### Project Structure

This work extends an incomplete capability. Python lives under `scripts/dev_tools/discovery/`, with validator/acceptance entry modules beside it; existing schemas are in `schemas/discovery/v1/`, templates in `docs/discovery/templates/`, and docs in `docs/engineering/legacy-discovery-and-parity/`. The companion research assesses their semantics.

Canonical authority is established by section 3 of `docs/engineering/claude-code-architecture.md` and generated Codex source contracts. The architecture document identifies `.github/` as authoritative: instructions become Claude rules, workflows become skills, and agents synchronize with native metadata. `.claude/settings.json` is directly authored runtime configuration. Generated Codex profiles name `.github/agents/*.agent.md` as canonical and require reading that source first.

Current discovery personas/skills exist only in Claude source and bundles. Skills are `discovery-workflow`, `discovery-repo-inventory`, `discovery-coverage-ledger`, `discovery-runtime-characterization`, `discovery-parity-matrix`, `discovery-behavior-reconciliation`, and `discovery-validate-artifacts`.

| Surface | Verified behavior | Required implication |
| --- | --- | --- |
| Copilot | Python publisher, `agentic_sync.py`, and TypeScript `COPILOT_ROOT_FOLDERS` enumerate `.github/agents`, `instructions`, `prompts`, `skills` | Author canonical discovery assets; explicitly add native hooks/support-resource publication |
| Claude | Publisher enumerates `.claude` and controlled bundled `config`; core manifest contains existing discovery assets | Synchronize content, settings, helpers, manifest, and bundle copies |
| Codex | Publisher enumerates `.codex` and `.agents`; `VIRTUAL_RESOURCE_PAIRS` carries selected shared helpers/config | Add native profiles, shared skills, hooks/helpers, routing, MCP allowlists, and manifest entries |
| Extension | `push-down-service-call.ts` selects one of three `resources/*customizations` roots | Installed publishers use packaged resources, not current checkout edits |
| Standalone MCP | Builds extension `src/mcp-server.ts` with a VS Code shim | Maintain one wrapper implementation and test actual package contents |
| Python | Root Poetry package includes `scripts`, without installed schema/template package data | Consumers cannot rely on a framework checkout or working-directory-relative resources |

Current onboarding explicitly describes runtime schema/template distribution as incomplete. `packages/mcp-server/prepack.cjs::shouldCopy` excludes every `.py` and the resources-root `scripts/` subtree; `.vscodeignore` also excludes bundled scripts. Distribute Python separately rather than hiding it inside a JS customization archive.

### Implementation Patterns

**Agents and conversion.** Existing Claude personas use `model: sonnet`, project memory, Read/Grep/Glob, and `Write(discovery/**)`. That static path conflicts with configurable roots. They explicitly defer exact runtime output enforcement. None has the required agent-specific stop validator. The legacy analyst currently writes parity matrices; the reconciler resolves ambiguity into product decisions. Correct those responsibilities to preserve legacy facts, approved target decisions, and parity reconciliation separately.

`codex_native_converter.inventory::_SUPPORTED_ROOTS` recognizes Copilot instructions/skills/agents/prompts and Claude rules/skills/agents/hooks/settings, but not arbitrary libraries/templates/schema data. `mapping::plan_target_paths` selects shared skills and TOML profiles. `pipeline::_wrap_rendered_target_content` embeds rewritten instructions; embedded YAML is not a native tool grant. `validation::validate_conversion_plan` rejects unresolved hard-gate/handoff/MCP references and conflicting targets. Explicit native enforcement and resource mappings remain necessary.

Exact Codex routing uses `config/orchestration-routing.json`, `resolve_codex_deployment.py::GENERATED_AGENT_FAMILIES`, `generate_codex_agent_variants.py`, and the corresponding `CodexDeployment.psm1` family list. Generated C1–C4/elevated-C3 profiles have fixed model/effort pairs and synchronized bundles/manifests; `--check` detects drift. Discovery families are missing. Broad variant hook patterns need explicit logical-role coverage. Use this existing mechanism instead of independently chosen models.

**Hooks.** `enforce-discovery-artifact-gate.ps1` uses `.claude/lib/hook-payload/HookPayload.psm1::Resolve-ClaudeHookToolInput`. The default `Get-RequiredDiscoveryArtifactDeclaration` reader returns no declaration, so normal execution skips validation. Detection hard-codes `discovery/...` prefixes. Edits without `content` are allowed; Writes dispatch the existing disk file, not proposed bytes, validating old replacement content and mishandling first creation.

`validate-discovery-artifact-gate.ps1` tokenizes paths from `last_assistant_message`. Blank output, omitted references, and absent default declarations pass. Required outputs are not derived from the agent. The corresponding settings matcher omits all four discovery personas. Nonzero-exit handling is reusable, but activation and output identification are insufficient.

`DiscoveryValidation.psm1` independently validates schemas in PowerShell, trusts artifact-provided local schema locations, and checks obsolete `legacy_source_path` using shallow parsing. It is exactly 500 lines. Companion research identifies Python/profile divergence. Duplicating v2 business invariants here would create a second semantic authority.

**Wrappers.** `repo-automation-execute-discovery.ts::executeDiscoveryServiceCall` detects workspace Python and invokes a fixed import/function. Input resolvers validate strings/enums/booleans but do not enforce artifact containment. Inventory results parse `written_paths`; generation parses a human message; other operations lack consistent findings. Malformed inventory JSON can yield undefined artifacts while success remains. Use validated authoritative structured output.

`mcp-server.ts::createRepoAutomationMcpServer` and `toCallToolResult` already return text JSON, structured content, and failure state. Discovery handlers use the same service as VS Code commands. Standalone builds reuse this implementation.

**Workflow reuse.** Reuse promotion, orchestration, research, PRD/spec generation, atomic planning/preflight, QA, review, and acceptance tracking. Discovery adds structured prerequisites and configured planning gates. `acceptance-criteria-tracking` checks off only implemented and verified behavior and prohibits invented executor/reviewer criteria. Generated scenarios are specifications, not implementation evidence. Approved criteria enter feature docs through PRD/planning.

The existing umbrella still describes landed dependencies as future work. Replace stale assumptions with actual installed-version contracts. Preserve old skill names as thin aliases where justified, add the nine requested verb-first workflows, and load only relevant local profile/contracts on invocation. No large domain catalog belongs in standing guidance.

### Complete Examples

Verified current dispatch, not evidence that present semantics meet all requirements:

```text
VS Code: drmCopilotExtension.runDiscoveryRepoInventory
  -> discovery-command-registration.ts
  -> resolveRunDiscoveryRepoInventoryToolInput
  -> RepoAutomationService.runDiscoveryRepoInventory
  -> repo-automation-execute-discovery.ts
  -> scripts.dev_tools.discovery.analyzer.cli:main

MCP: run_discovery_repo_inventory
  -> mcp-handlers/discovery-handlers.ts
  -> the same input resolver, service, and Python implementation

Standalone build:
  packages/mcp-server/esbuild-mcp-server.cjs
  -> extension src/mcp-server.ts with VS Code shim
```

Verified `pyproject.toml` registrations:

```text
dev.discovery.init
dev.discovery.profile
dev.discovery.inventory
dev.discovery.dotnet
dev.discovery.vsto
dev.discovery.generate-acceptance-scenarios
dev.discovery.validate-all
dev.discovery.validate-profile
dev.discovery.validate-feature-contract
dev.discovery.validate-coverage-ledger
dev.discovery.validate-runtime-scenario
dev.discovery.validate-parity-matrix
dev.discovery.validate-unspecified-behavior
dev.discovery.validate-product-decision
dev.discovery.validate-evidence-reference
dev.discovery.coverage-report
dev.discovery.parity-report
dev.discovery.completion-report
```

Preserve these names as safe compatibility adapters. Add strict v2 workspace and creation/evidence-link operations through Python. Current generation wrappers require feature contract, parity matrix, and runtime characterization together; remove that constraint for consumers without runtime capability. Initialization exposes `force` and lacks wrapper dry-run; carry explicit no-overwrite/dry-run semantics through every layer.

Existing generation/build commands, inspected but not run:

```powershell
poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
poetry run codex-native-converter review --source-root . --source-ecosystem github-copilot --selected-path .github/agents/task-researcher.agent.md --emit-intermediate-state
npm --prefix extensions/drm-copilot run build
npm --prefix packages/mcp-server run build
npm --prefix packages/mcp-server run prepack
```

Agent publishing must use the established MCP route. These existing call forms require final version/path values in the delivery handoff; no consumer push was performed:

```json
{"tool":"push_down_copilot_customizations","arguments":{"workspace_root":"<absolute consumer repository root>"}}
{"tool":"push_down_claude_customizations","arguments":{"workspace_root":"<absolute consumer repository root>","packs":["core"],"memory_mode":"skip"}}
{"tool":"push_down_codex_and_agents_customizations","arguments":{"workspace_root":"<absolute consumer repository root>","packs":["core"],"memory_mode":"skip"}}
```

Equivalent human-operated Python modules are `scripts.dev_tools.push_down_copilot_customizations`, `scripts.dev_tools.push_down_claude_customizations`, and `scripts.dev_tools.push_down_codex_and_agents_customizations`, with required `--destination`; Claude/Codex also accept `--packs` and `--memory-mode`. They do not replace the required agent MCP route.

### API and Schema Documentation

Existing tools are `validate_discovery_artifacts`, `run_discovery_init`, `run_discovery_repo_inventory`, `run_discovery_dotnet_analyzer`, `run_discovery_vsto_analyzer`, `run_discovery_scenario_generation`, and `run_discovery_report`. Definitions are in `mcp-discovery-tool-definitions.ts`; command IDs use `drmCopilotExtension`. Preserve compatibility names, add explicit workspace/profile/mode/dry-run controls, and expose shared findings/artifacts. New artifact operations can use fixed enums; do not accept arbitrary executable/module input.

Companion research recommends an offline v2 catalog keyed by expected artifact kind and exact supported version, pure snapshot validation, and an I/O service returning `{ok, findings, artifacts, summary}`. Hook/wrapper contracts must consume that authority. Distinguish structural validity, discovery completion, parity completion, and planning authorization; initialized empty artifacts can be structurally valid while completion fails.

Native adapters should normalize host JSON into trusted workspace/agent identity, action, paths, and event. Identity must come from attested host context rather than caller arguments. Malformed context for an active discovery agent blocks; unrelated inactive workspaces remain unaffected.

Hooks cannot invoke Python under existing policy. Use authority receipts from normal validation operations with independently checked freshness:

| Required binding | Purpose |
| --- | --- |
| Receipt format, tool build, schema and policy versions | Reject unsupported/stale validation contracts |
| Canonical workspace identity and profile path | Prevent cross-workspace/profile reuse |
| Raw profile SHA-256 and persistent activation | Detect change/deletion/custom-profile switching |
| Complete sorted relevant input-path set and byte SHA-256 values | Detect additions, deletions, edits, and replacements |
| Source/target identities and immutable revisions | Prevent reuse for changed parity inputs |
| Gate, result, trusted agent/session identity, required-output manifest | Prevent structural or another agent's result authorizing completion |
| Protected-store allowed-writer provenance | Prevent authored reports creating authority |

A matching-hash report is not proof of validation. Hooks compare actual current complete inputs and profile, including missing/new files. Edits invalidate completion receipts; drafting cannot require an already-passing completion receipt.

### Configuration Examples

Existing persona metadata demonstrates static grants, not requested profile-based enforcement:

```yaml
model: sonnet
tools:
  - Read
  - Grep
  - Glob
  - "Write(discovery/**)"
memory: project
```

The exact v2 profile/activation paths are specification decisions. `docs/migration/discovery/domain-profile.yaml` matches the proposed lifecycle. Persist activation separately so deleting a profile cannot silently opt out. Initialization/configuration tooling owns this declaration; analysts cannot edit it. It identifies the profile and framework version, not a validation result.

Outputs must be workspace-relative, normalized, and resolved within the workspace. Deny drive/UNC roots, traversal, symlink/reparse escapes, and platform case aliases. Analysts write only permitted artifact types under validated roots; exclude production/test implementation, profile, activation, schema, hook, settings, policy, and authority changes. Separate configuration operations invalidate receipts.

Offline/mobile/client dimensions become obligations only through the validated profile. Once activated, missing/malformed declared configuration blocks. Explicit discovery calls without required configuration block. Absence of activation and a recognized/default profile leaves unrelated work unchanged.

### Technical Requirements

| Research question | Evidence-backed answer |
| --- | --- |
| 1. Author/publish | Existing Python/shared wrappers are reusable; discovery customization assets currently reach Claude only |
| 2. Canonical surface | `.github/` is documented authoritative and named by native source contracts; settings/hooks need adapters |
| 3. Conversion | Known kinds map and unresolved refs fail; helper/data publication requires explicit extension |
| 4. Feature/evidence | Framework work uses this active feature's research/evidence roots; consumers own configured discovery evidence |
| 5. Hook context | Native JSON helpers exist; discovery activation is a stub and paths are hard-coded |
| 8. MCP | Shared service supports creation/analysis/validation/report patterns; result/path/profile contracts need strengthening |
| 9. Validators | Stop validation trusts mentioned filenames and skips missing declarations; require agent-specific manifests/current authority |
| 10. Reuse | Reuse orchestration, promotion, PRD, planning, tracking, QA, review, publishing, and safe aliases |
| 11. AC/planning | Add prerequisites and links; generation must not check off implementation criteria |
| 12. Compatibility | Preserve explicit v1 adapters and inactive behavior; require safe explicit v2 migration |
| 16. Context | Load relevant profile/contracts/schema reference on invocation; avoid standing catalog injection |

**Mandatory unachievable objective callout**:

- **Universal runtime prevention in hosts with disabled or unsupported hooks cannot be guaranteed by customization files.** Official host documentation establishes these differences. Test named enabled harnesses and refuse discovery-agent execution or completion when required enforcement capabilities cannot be established. Manual validation alone does not prove production-write prevention for an unconstrained agent.
- No other scoped objective was proven unachievable. Cross-host receipt authority, installed packaging, and capability verification require explicit specification decisions and tests.

## Recommended Approach

Extend the existing capability behind one Python v2 API and shared service/wrappers. Retain v1 per-file behavior as explicit historical compatibility; new completion/planning authorization uses strict v2. The companion research defines schema/artifact semantics.

Use canonical `.github/agents` and `.github/skills` bodies, the existing Copilot-to-Claude workflow, Codex converter/exact-profile generator, and mirror/manifest tests. Native settings/hooks remain thin host-specific adapters. Keep assets in the existing core bundle with invocation-only activation initially. A separate discovery pack is possible but requires strict Codex pack-name validation changes and adds migration work; it is unnecessary for keeping large content out of context.

Make receipt authority concrete:

1. A fixed normal MCP/CLI validation gateway invokes the installed authoritative Python package and validates its structured result. It binds/rechecks the complete current input manifest. Hooks do not launch Python directly or indirectly.
2. Only that gateway writes receipts to external authority storage keyed by workspace/session, following the existing `codex-authority-store.ps1` precedent. The cross-host directory convention is a specification choice; it cannot be an analyst-editable report root.
3. Native analyst grants deny shell, terminal, arbitrary evaluation, arbitrary MCP dispatch, and general mutation. Prefer purpose-built artifact operations. Any retained Write/Edit must pass mandatory native PreToolUse checks for profile-authorized artifact roots/types. The same checks block authority/config/schema/hook writes and unknown mutation forms.
4. The writer accepts neither a caller-supplied success result nor a receipt destination. It writes only after the fixed installed validator succeeds. Protect that installation from analyst mutation. Unattributed identities cannot obtain these grants.
5. Stop/planning hooks independently compare current profile, complete input set/hashes, repository revisions, gate, identity, and required outputs. Missing/stale/malformed receipts, deleted profiles, new files, and replaced evidence fail closed.

This is an agent-capability boundary, not an OS security boundary against arbitrary same-user processes. A host that cannot mechanically restrict shell and authority-store mutation for a discovery role cannot enable that role with a production-write-prevention claim. Reuse existing generic command guards and authority/attestation helpers rather than another orchestration engine.

Publish a small separate Python wheel. One buildable approach stages an explicit source allowlist from canonical discovery modules into an ignored build tree, includes the complete import closure plus schemas/templates, and builds with the already-approved `poetry-core` backend. A conventional dedicated canonical package with legacy entry adapters is also viable; the specification must choose one source layout without independently maintained copies. Declare PyYAML and jsonschema at runtime, use installed package-resource lookup, avoid unrelated root ML dependencies, and prohibit arbitrary profile-triggered Python imports.

The specification must name the distribution/import package and build command. For a proposed `packages/discovery-runtime/` project after deterministic staging, the standard build form is `python -m pip wheel --no-deps --wheel-dir dist/discovery packages/discovery-runtime`, followed by `python -m pip install <exact-built-wheel>`. These are proposed forms, not existing commands. Verify package contents, independent local installation without checkout imports, entry points, resources, and both wrappers. Update the dedicated runtime's quality-tier classification through established mechanisms because existing `scripts/dev_tools` classification describes unpublished tooling.

Rejected alternatives: A separate discovery server/engine duplicates existing dispatch/service layers. Python inside current JS customization packs conflicts with tested packaging exclusions. Duplicated PowerShell v2 business validation would drift from Python authority. Writable success receipts are forgeable. None is needed; retain the no-Python enforcement-hook rule.

## Implementation Guidance

- **Objectives**: Provide evidence-backed discovery through existing wrappers; publish one canonical workflow across three ecosystems; separate facts, decisions, requirements, and implementation; leave inactive repositories unchanged.
- **Key Tasks**: These change targets inform the next specification and atomic plan; they are not an implementation sequence.

| Responsibility | Candidate files/symbols | Existing tests affected |
| --- | --- | --- |
| Agents/skills | Canonical `.github` sources, existing Claude discovery files, generated native counterparts | `test_legacy_discovery_skills_contracts.py` asserts seven names, routing, stale umbrella flags, neutrality, and mirrors; `legacy-discovery-agent-roles.Tests.ps1` asserts metadata/schema/profile refs |
| Codex routing | `GENERATED_AGENT_FAMILIES`, generator, routing config, `CodexDeployment.psm1`, attestation helper/config | `test_generate_codex_agent_variants.py`, `test_codex_model_policy_config_parity.py`, `test_codex_model_routing_skill.py`, `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py` |
| Gates | Discovery hooks, `HookPayload.psm1`, authority helpers, native settings/config | Discovery PreToolUse/SubagentStop Pester suites and validator-dispatch suites; replace skip assumptions with activated/malformed/current-state cases |
| Hook policy | Reuse generic command and authority guards | `enforcement-hooks-no-python-invocation.Tests.ps1` retains empty allowlist; add provenance and dependency completeness cases |
| Thin adapters | Execute/input/definitions/handlers/command-registration modules | `repo-automation-execute-discovery.test.ts`, `mcp-tool-inputs-discovery.test.ts`, `extension.discovery-commands.test.ts`, `mcp-tools.discovery.test.ts`, `mcp-server.discovery.test.ts`, `repo-automation-service.discovery.test.ts` |
| Structured results | Fixed Python gateway parser and `toCallToolResult` | Malformed stdout, nonzero exit, findings, dry-run, path escape, no terminal creation, and text/structured result parity |
| Publication | Python/TypeScript enumerators, converter mappings, bundles/core manifests, prepack | Claude/Codex resource contracts, pack completeness tests, `test_skill_bundle_contract_repo.py`, converter inventory/mapping/rewrites/validation/end-to-end tests |
| Installed Python | One canonical package/build manifest, resources, adapters | New in-memory manifest/import-closure checks and independent-install integration evidence; preserve no-Python VSIX/npm checks |
| Planning/criteria | Existing prerequisites and discovery input links | Configured planning block, inactive workspace, approved-criteria traceability, and no generated implementation check-off |
| Documentation | Existing onboarding/architecture plus final handoff | Installed resource/version checks, host capability matrix, migration, ownership, commands, and limitations |

- **Dependencies**: Agree Python snapshot/profile/result and gate modes before adapters. Native enforcement needs actual host payload fixtures, trusted attribution, protected writers/paths, and validator identity. Publication needs complete resources, routing regeneration, and matching installed bundle versions. Companion research owns analyzer details; optional Office analysis must remain separate and explicitly selected.
- **Success Criteria**: Prove role-specific outputs and write restrictions on each supported host; prove authoritative graph validation governs completion/planning; reject altered/deleted/added/profile-deleted inputs and forged reports; prove inactive compatibility, independently installed resources, both wrappers, and synchronized assets/models/tools.

Likely targets are near the 500-line cap: `repo-automation-service.ts` is 498 lines, `repo-automation-execute-discovery.ts` 454, `DiscoveryValidation.psm1` 500, agent-role Pester suite 485, and execute-discovery Jest suite 438. Extract cohesive modules/tests rather than exceeding the cap.

Final publication handoff must include the exact wheel/version/install command for each consumer interpreter, tested extension/MCP versions, and MCP push-down calls above. The legacy repository then owns its profile, scope, coverage, contracts, characterization/evidence, unresolved behavior, and decision proposals. The target owns its profile, immutable source-contract references/snapshots, architecture/product decisions, implementation references, parity, acceptance specifications, and verification tests/evidence. This feature must not inspect or populate those consumer catalogs.

## Pre-Mortem

- Review checklists: Named agents/commands could pass review without actual enforcement. Require role-output, production/config/authority-write denial, malformed-context, and activation tests; distinguish specifications from delivery completion.
- Coverage: Passing tests can miss changed-file thresholds and error paths. Measure repository/changed-file coverage and new-module targets; include malformed profile/path/provenance cases. Add explicit Jest per-file thresholds for new modules.
- Mirror parity: Canonical bodies, Claude copies, shared skills, Codex profiles/routing, MCP allowlists, helpers, and manifests can diverge. Carry converter validation, generator check mode, resource/pack/skill contracts, and package-content checks.
- File size: Existing production/test targets are near or at 500 lines. Plan cohesive extractions/splits and count physical lines across reusable scripts and tests.
- Test isolation: Real process/disk/authority dependencies can violate unit-test policy. Inject file systems, runners, clocks, contexts, and stores; use in-memory fixtures. Keep wheel-install verification a separate integration procedure with canonical evidence.
- CI-only behavior: Case, drive/UNC, reparse/symlink, POSIX paths, PowerShell versions, installed resources, and native hook fields vary. Carry platform fixtures and no-checkout install evidence; unsupported enforcement fails closed.
- Evidence: Self-authored reports can be mistaken for authority, and source tests for publication proof. Store QA canonically, protect authority records, record installed versions/hashes and bundle checks, and never authorize from writable reports.
