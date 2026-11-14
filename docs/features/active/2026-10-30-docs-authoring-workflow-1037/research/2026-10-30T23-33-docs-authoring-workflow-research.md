# docs-authoring-workflow (Issue #1037) - Research

- Feature: epic #1019 (documentation-estate-tooling) child 900009, promoted as issue #1037, wave 4, band C4, work mode full-feature
- Branch: `feature/docs-authoring-workflow-1037` (branched from `epic/documentation-estate-tooling-integration`)
- Mode: preparation research. No source, configuration or test file was changed.
- Environment brief: `.claude/skills/execution-environment/SKILL.md` (cited, not restated).
- Requirement origin: one consumer repository (epic `## Goal`). No identifier of that repository appears in this file.
- Tool limits: the task-researcher tool set has no Bash, PowerShell, `git` or `gh`. Facts that need them are marked "orchestrator to confirm". The filename stamp could not be read from a clock by this agent; it was set to a value after the newest sibling artifact and is listed under `## Items for the Orchestrator to Confirm`.

## 0. Decisions in One Line Each

1. The epic and spec name `scripts/dev_tools/agentic_sync.py` and `scripts/dev_tools/generate_codex_agent_variants.py` as the mirror generators. Verified: `agentic_sync.py` synchronizes files that already exist in two local repositories and produces no mirror; `generate_codex_agent_variants.py` only renders the `-c1`..`-c4` variants of families listed in the existing Python constant `GENERATED_AGENT_FAMILIES` and normalizes the Codex pack manifests. Every mirror of a new non-generated agent or skill is therefore hand-authored, following the `discovery-capability-sentinel` and `discovery-workflow` precedents (section 1).
2. A new agent has six files and a new skill has six `SKILL.md` copies (plus six copies of each skill-folder file). The epic list omits the Copilot bundle `extensions/drm-copilot/resources/customizations/.github/`, which `test_copilot_bundle_mirrors_every_scoped_github_file` requires.
3. The four docs roles are not added to `GENERATED_AGENT_FAMILIES` (that would extend existing Python and its PowerShell and TypeScript twins); each role gets one base `.codex/agents/<role>.toml` wrapper and no variants (owner question OQ-3).
4. Path-scoped `Write(...)` entries in agent `tools:` are inert, `disallowedTools: Edit(path)` removes the whole tool, and `memory:` enables Read, Write and Edit. Recommended design: three roles have no Write or Edit at all; `docs-author` has bare `Write` and `Edit`, and a new PowerShell PreToolUse hook `enforce-docs-role-write-scope.ps1` denies any docs-role write that is not a Markdown page or that targets a profile `artifact_paths` value (owner question OQ-1).
5. One SubagentStop hook `validate-docs-role-output.ps1` serves all four roles through the envelope's `agent_type`, registered once in `.claude/settings.json` with matcher `docs-architect|docs-author|docs-reconciler|docs-coverage-reviewer`. A dot-sourced helper `docs-role-contract.ps1` holds the role set and the required result tokens shared by both hooks.
6. The routing entry is a new top-level `docs_operations` block in `config/orchestration-routing.json` (skill to logical agent), mirrored byte-identically to `extensions/drm-copilot/resources/config/orchestration-routing.json`. No existing reader or validator rejects an added top-level block; no runtime reader consumes it (owner question OQ-5).
7. Q7 position: the docs lib stays in the Claude bundle only. Codex (`.agents/skills`, `.codex/agents`) and Copilot (`.github/skills`, `.github/agents`) copies are produced, name only the six MCP tools and the subcommand names, contain no `.claude/` path, and state that the docs helper library from the Claude customization push-down is a prerequisite. `.codex/config.toml` `enabled_tools` does not list the docs tools today (owner question OQ-2).
8. No new skill helper is needed. Skills call `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command <name> ...` (root-run steps) or the six MCP tools (role steps).
9. New PowerShell production files: three hook files plus three bundle copies (six). `.claude/hooks` is already T3 in `quality-tiers.yml`; no tier edit. Execution runs in the item worktree under the preparation or large route (batch budget).

## 1. Current State: Mirror Set for a New Agent and a New Skill (Research Question 1)

### 1.1 Agent locations (precedent `discovery-capability-sentinel`, verified by glob; the discovery roles add only the generated variants)

| # | Location | Authoring | Content rule |
|---|---|---|---|
| A1 | `.github/agents/<role>.agent.md` | hand-authored, canonical | Copilot tool form `drmcopilotextension/<tool>` |
| A2 | `extensions/drm-copilot/resources/customizations/.github/agents/<role>.agent.md` | byte copy of A1 | `test_copilot_bundle_mirrors_every_scoped_github_file` (every file, no extras) |
| A3 | `.claude/agents/<role>.md` | hand-authored rewrite of A1 | each `  - drmcopilotextension/<op>` becomes `  - "mcp__drm-copilot__<op>"`; no `.github/`, `drmcopilotextension` or `.agent.md` text (`test_role_has_exact_native_representation_on_every_host` pattern) |
| A4 | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/<role>.md` | byte copy of A3 | `test_push_down_claude_resource_contracts.py` |
| A5 | `.codex/agents/<role>.toml` | hand-authored wrapper | must contain the six `WRAPPER_REQUIRED_FRAGMENTS` and `.github/agents/` (`test_codex_full_migration_inventory.py::test_codex_agent_contracts_follow_expected_wrapper_or_native_patterns`); template: `.codex/agents/discovery-capability-sentinel.toml` (header, `Applied rewrites:`, `Canonical migration source:`, then the canonical text with Claude-form tool names); no `model` lines for a non-generated family |
| A6 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/<role>.toml` | byte copy of A5 | `test_push_down_codex_and_agents_resource_contracts.py`, `test_every_repo_codex_agent_has_a_bundled_target` |

Manifest lines: `.claude/agents/<role>.md` in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; `.codex/agents/<role>.toml` in `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`. The Copilot bundle has no pack manifest.

### 1.2 Skill locations (precedent `discovery-workflow`, verified by glob)

| # | Location | Authoring |
|---|---|---|
| S1 | `.github/skills/<skill>/SKILL.md` | hand-authored, canonical |
| S2 | `extensions/drm-copilot/resources/customizations/.github/skills/<skill>/SKILL.md` | byte copy of S1 |
| S3 | `.claude/skills/<skill>/SKILL.md` | hand-authored host copy (role links to `../../../.claude/agents/<role>.md`) |
| S4 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/<skill>/SKILL.md` | byte copy of S3 |
| S5 | `.agents/skills/<skill>/SKILL.md` | hand-authored host copy (role links to `../../../.codex/agents/<role>.toml`; no `.claude/` text) |
| S6 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<skill>/SKILL.md` | byte copy of S5 |

Precedent `review-discovery-coverage` shows the only per-host difference is the role link. An alias skill without role links (`discovery-workflow`) is identical on all three hosts.

Skill-folder files (the eight page templates) follow the `mermaid-diagram/references/*.md` precedent: each file is mirrored in the bundle and listed in the Claude `core.json` (`test_skill_bundle_contract_repo.py::test_every_skill_folder_file_is_carried_by_skill_packs`). If the templates are also published on the Copilot and Codex hosts, they need S1, S2, S5 and S6 copies; S2 is mandatory once an S1 copy exists. Manifest lines: `.claude/skills/<skill>/SKILL.md` and every skill-folder file in the Claude `core.json`; `.agents/skills/<skill>/SKILL.md` (and recommended, the template paths) in the Codex `core.json`.

### 1.3 Generators

- `scripts/dev_tools/agentic_sync.py` (`AgenticSyncer.sync_repos`, `ROOT_FOLDERS`): compares only files present in both of two repository paths given on the command line and copies the newer one. It creates no file and produces none of the mirrors above. It is not a step of this feature.
- `scripts/dev_tools/codex_native_converter` (`python -m scripts.dev_tools.codex_native_converter review|apply`): its subagent wrapper (`_wrap_rendered_target_content`, `description = "Converted subagent"`, no `Canonical migration source:` fragment) and its skill wrapper (`# Converted skill`) do not match the committed precedents and would fail `test_codex_agent_contracts_follow_expected_wrapper_or_native_patterns`. Not used.
- `scripts/dev_tools/generate_codex_agent_variants.py`, module form: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` (write) and `... --check` (the CI form, run in `quality-checks7`). It renders variants only for `GENERATED_AGENT_FAMILIES` (`scripts/dev_tools/resolve_codex_deployment.py`) and rewrites each Codex pack manifest as `json.dumps(document, indent=2) + "\n"` after appending missing generated paths (`render_manifest`). Consequences: `.codex/agents` variants are generated only for listed families; the Codex `core.json` is hand-edited for every other path but its formatting is owned by the generator, so hand-added lines must match `json.dumps` indent-2 output; running the write form once after editing and then `--check` is the one generator task.

## 2. Tests That Pin Mirrored Agents and Skills (Research Question 2)

| Test | What it enumerates | Disposition for four agents and eight skills |
|---|---|---|
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | every distributable `.claude` file in the bundle with equal text (includes `.claude/settings.json`) | passes unchanged once A4, S4, template, hook and settings bundle copies exist |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` | every `.codex` and `.agents` file in the Codex bundle | passes unchanged once A6 and S6 exist |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` (and Jest twin `claude-pack-manifest-completeness.test.ts`) | bundled `.claude/agents/*.md`, `.claude/hooks/*`, `.claude/skills/*/SKILL.md` in some manifest | passes unchanged once Claude `core.json` lines are added |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` | bundled `.codex/agents/*.toml`, `.codex/hooks/*`, `.agents/skills/*/SKILL.md` | passes unchanged once Codex `core.json` lines are added |
| `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | `$PSScriptRoot` deps of manifested PowerShell; hooks named by `.claude/settings.json` and manifested agent frontmatter | passes unchanged if the three new hook files are in Claude `core.json` (their deps `hook-dependency-guard.ps1` and `subagentstop-envelope.ps1` are already core) |
| `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` | `.claude/skills` script references (`pwsh ... -File <path>`) and skill-folder files | passes unchanged: `.claude/lib/docs/Invoke-DocsCommand.ps1` is bundled and in core (1020); templates must be in core |
| `tests/scripts/dev_tools/test_codex_full_migration_inventory.py` | every `.agents/skills` dir bundled verbatim; every `.codex/agents/*.toml` bundled and wrapper-shaped | passes unchanged if A5 follows the wrapper fragments |
| `tests/scripts/dev_tools/test_discovery_publication_contracts.py` | `test_copilot_bundle_mirrors_every_scoped_github_file` scans all of `.github/agents`, `.github/hooks`, `.github/instructions`, `.github/prompts`, `.github/skills`; other tests are discovery-only | passes unchanged once A2 and S2 (and template copies) exist |
| `tests/scripts/dev_tools/test_discovery_agent_contracts.py`, `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1` | fixed discovery role sets | unaffected |
| `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` | consuming-name counts in every pushed rule and skill (`PINNED_NAME_OCCURRENCES` empty) | passes unchanged if no new skill names the consumer product |
| `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` | every preloaded agent skill exists; no unqualified `spec.md §` citation under `.claude/` | passes unchanged if preloaded skills exist and no such citation is written |
| `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py` | fixed orchestration agents and shared skill names | unaffected |
| `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` | patterns in `docs/engineering/claude-code-architecture.md`, `atomic-executor.md`, `feature-review.md`; no agent table enumeration | unaffected |
| `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` | every hook registered in `.claude/settings.json`, discovered from the file | covers the new hooks without edit; they must follow the guarded-load pattern (PreToolUse deny JSON at exit 0, SubagentStop exit 2) |
| `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` | guarded dot-source pattern in hooks | covers new hooks without edit if they use the pattern |
| `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`, `test_codex_topology_policy_config_parity.py::test_tracked_and_bundled_routing_configs_are_byte_identical` | canonical and bundled routing config byte identity | passes unchanged if both copies are edited identically |
| `test_codex_topology_policy_config_parity.py::test_discovery_operations_match_canonical_config`, `test_codex_discovery_routing.py` | `discovery_operations` only | unaffected by a separate `docs_operations` block |
| `test_codex_model_policy_config_parity.py::test_agent_families_and_contexts_match_routing_config`, `CodexDeployment.GeneratedFamilies.Parity.Tests.ps1` | `generated_agent_families` equals `GENERATED_AGENT_FAMILIES` | unaffected because docs roles are not added there (OQ-3) |
| `scripts/dev_tools/generate_codex_agent_variants.py --check` | Codex manifests as `json.dumps` output | passes if Codex `core.json` edits match the generator format |

No test counts agents or skills. No existing test needs an edit; every new pin is a new Pester suite (section 9).

## 3. Tool Allowlist Mechanics and the Write Boundary (Research Question 3)

### 3.1 Verified mechanics

- MCP form in `tools:`: server key `drm-copilot` in `.mcp.json`; existing agents list `"mcp__drm-copilot__<tool>"` as quoted YAML list items (`.claude/agents/legacy-parity-analyst.md`). The six forms are `mcp__drm-copilot__run_docs_check`, `mcp__drm-copilot__run_docs_inventory`, `mcp__drm-copilot__run_docs_coverage`, `mcp__drm-copilot__update_docs_ledger`, `mcp__drm-copilot__generate_docs_reference`, `mcp__drm-copilot__validate_docs_artifacts`. Copilot form: `drmcopilotextension/<tool>`.
- Path-scoped `Write(...)` in `tools:`: the execution-environment brief states that a `(pattern)` suffix admits the bare tool; the archived issue #964 research records that path suffixes in agent `tools:` entries are inert; the Claude Code subagent documentation (fetched 2026-10-30) documents no permission-rule pattern in `tools` other than `Agent(type)`. The discovery publication test asserts `"Write(" not in frontmatter` for roles that must not write.
- `disallowedTools`: per the same documentation, an entry with a specifier such as `Bash(git push *)` "still removes the whole tool", so path-scoped denial in frontmatter is not available.
- `memory:`: per the same documentation, when memory is enabled "Read, Write, and Edit tools are automatically enabled". The four roles therefore carry no `memory:` field (epic requirement).
- `.claude/settings.json` `permissions.allow` has `Edit(docs/**)` and `Edit(artifacts/**)` and `defaultPermissionMode: bypassPermissions`; settings rules do not restrict a tool a subagent already holds under bypass mode.
- PreToolUse payloads inside a subagent carry `agent_type` (Claude Code hooks reference, fetched 2026-10-30); `.claude/hooks/enforce-epic-invocation-origin.ps1` (`Get-EpicInvocationOriginCallerAgentType`) is the repository precedent that reads it, treating an absent field as a main-thread call.

### 3.2 Consumer artifact paths (1020 spec, docs-profile schema)

`artifact_paths.{inventory_snapshot, coverage_ledger, parity_matrix, evidence_pins, validation_receipt}`, each a profile-defined relative path; the profile itself defaults to `docs/documentation-estate/docs-profile.json` (`Get-DocsDefaultProfilePath`). Ledger, matrix and pin writes are owned by `update-ledger` (1023, the only mutating subcommand; 900007 `update_docs_ledger` the only mutating tool). The 1023 spec in this worktree still describes the withdrawn Python design; the write boundary is unchanged in the epic's `### Command contract decisions from the first preparation of 1023`.

### 3.3 Candidate designs

- D-A (recommended): `docs-architect`, `docs-reconciler`, `docs-coverage-reviewer` have Read, Grep, Glob and MCP tools only. `docs-author` has Read, Grep, Glob, Write, Edit, `generate_docs_reference` and `run_docs_check`. A PreToolUse hook `.claude/hooks/enforce-docs-role-write-scope.ps1`, matcher `Write|Edit|MultiEdit|NotebookEdit|Bash`, acts only when `agent_type` is one of the four roles: it denies every Write-class call by a role other than `docs-author`, denies a `docs-author` write whose path does not end in `.md`, whose path equals a profile `artifact_paths` value or the profile path, or whose path lies under `.claude/`, `.github/`, `.codex/` or `.agents/`, and denies Bash for all four roles. The profile is read from the default path through an injected read seam; an unreadable or absent profile leaves the extension and directory rules in force. Ledger and matrix writes then occur only through `update_docs_ledger`.
- D-B (fallback): `docs-author` has no Write or Edit and returns page text in its final message; the root writes the page. No new hook, but page edits that must preserve generated blocks round-trip through the root, and the role cannot run `run_docs_check` on its own output before stopping.
- Rejected: path-scoped `Write(...)` entries (inert); `disallowedTools` with specifiers (removes the whole tool); routing all page writes through `generate_docs_reference` (it renders only the four reference families from inventory data; narrative tutorial, how-to, explanation and architecture-overview pages have no writer).

D-A is selected: it is the only design in which `docs-author` writes narrative pages directly and the ledger and matrix stay unwritable by every docs role. It adds one PreToolUse hook to the child's scope, recorded as owner question OQ-1. The AC "Each role's tool list excludes Write and Edit on ledger and matrix paths; a test asserts it" is then proven by (i) the roles test asserting no Write-class or Bash entry in three tool lists and only bare Write and Edit in `docs-author`, and (ii) the hook suite asserting a deny for ledger, matrix, pin, receipt, snapshot and profile paths.

## 4. SubagentStop Output Check (Research Question 4)

### 4.1 Precedent

- `.claude/hooks/validate-task-researcher-output.ps1`: dot-sources `hook-dependency-guard.ps1`, `subagentstop-envelope.ps1` and a helper (`premortem-section.ps1`) inside the guarded pattern; `Invoke-TaskResearcherOutputValidation -InputText` takes the envelope text as an injected seam; filesystem checks go through seam functions (`Test-ResearchFile`, `Get-ResearchFileContent`) mocked in tests; the script body is skipped when dot-sourced (`$MyInvocation.InvocationName -eq '.'`); blocks call `Exit-SubagentStopBlock` (stderr, exit 2); an unhandled error blocks with a fixed fail-closed message (issue #928). Registered in agent frontmatter `hooks:`.
- `.claude/hooks/validate-required-artifact-output.ps1`: generic token-plus-path check, registered per agent in frontmatter with `-AgentName` and `-RequiredArtifact 'token|regex|description'`; honors `StopHookActive` for non-repairable blocks.
- `Read-SubagentStopEnvelope` returns `IsValid`, `Anomaly`, `Envelope`, `AssistantText`, `StopHookActive`, `AgentType`, `HookEventName`, so one hook can dispatch on the stopping role.
- Settings registration form: `"SubagentStop": [{ "matcher": "a|b|c", "hooks": [{ "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/<hook>.ps1" }] }]` (discovery roles entry). The spec requires registration in `.claude/settings.json`; that file has a byte-identical bundle copy.
- Codex: `.codex/hooks/validate-discovery-agent-output.ps1` is registered in `.codex/config.toml`; under the Q7 position no Codex docs hook is added.

### 4.2 Recommended split

| File | Role |
|---|---|
| `.claude/hooks/docs-role-contract.ps1` | dot-sourced helper, not registered: `Get-DocsRoleName` (the four roles), `Get-DocsRoleRequiredToken -Role`, `ConvertFrom-DocsRoleOutput -Text` (token parser, pure), `Test-DocsRoleOutput -Role -Text -TestFile <scriptblock>` (returns `@{ Ok; Message }`) |
| `.claude/hooks/validate-docs-role-output.ps1` | SubagentStop entry: reads the envelope (seam `-InputText`), resolves the role from `AgentType`, allows a non-docs agent, blocks per `Test-DocsRoleOutput` |
| `.claude/hooks/enforce-docs-role-write-scope.ps1` | PreToolUse entry (D-A) using `Get-DocsRoleName` |

Each file carries a byte-identical copy under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` and a Claude `core.json` line. Logic stays under the 500-line guidance.

### 4.3 Required result tokens (proposal; one token per line, `token: value`)

| Role | Required tokens | Checks |
|---|---|---|
| all four | `docs-role: <role>`; `docs-result: PASS\|FAIL\|BLOCKED`; `docs-findings: <n>` | `docs-role` equals `AgentType`; result in the enum; `n` a non-negative integer |
| `docs-architect` | `docs-profile: <relative path>`; `docs-snapshot: <relative path>`; `docs-pages-planned: <n>` and a `## Information Architecture` section | both paths relative and existing (seam); section present when result is PASS |
| `docs-author` | `docs-pages-written: <path>[, <path>...]`; `docs-check-exit-code: <0-3>` | every path relative, ends `.md`, exists (seam); PASS requires exit code 0 |
| `docs-reconciler` | `docs-ledger-operations: <n>`; `docs-update-ledger-exit-code: <0-3>`; `docs-elements-reconciled: <element id>[, ...]` or `none` | ids match the 1020 `element-id` pattern; PASS requires exit code 0 |
| `docs-coverage-reviewer` | `docs-validate-mode: profile\|ledger\|matrix\|docs-complete`; `docs-revision: <40 or 64 lowercase hex>`; `docs-validate-exit-code: <0-3>`; `docs-receipt-id: <id>` or `none` | mode in enum; revision grammar; a FAIL report with exit code 1 is a valid output |

A missing or invalid token blocks with a reason naming the token (repairable). When `StopHookActive` is set, the hook blocks only on missing tokens and allows a re-entered stop for non-repairable conditions, following `validate-required-artifact-output.ps1`.

### 4.4 Tests and CI

- `tests/scripts/claude-hooks/docs-role-contract.Tests.ps1`, `validate-docs-role-output.Tests.ps1`, `enforce-docs-role-write-scope.Tests.ps1`: in-memory envelope text and mocked file seams, no temporary files; pass and block cases per role; non-docs agent allowed; anomaly and dependency-failure cases.
- Runner: Pester through `Invoke-PoshQCTest` (branch-current, `sh`-launched PowerShell 7 per the brief). CI: `tests/scripts/claude-hooks` runs in both `poshqc / PowerShell QC` (shards; required, with coverage) and `poshqc / PowerShell hook suites (Linux)` (case-sensitive, no coverage).

## 5. `config/orchestration-routing.json` (Research Question 5)

- Blocks: `routes` (route to `required_agents`, `required_skills`, `required_mcp_tools`), `model_policy`, `model_budget`, `codex_topology_policy`, `discovery_operations` (skill to `logical_agent`, `output_contract_version`, `permissible_artifact_kinds`, `gate_mode`), `codex_model_policy` (`generated_agent_families`).
- Discovery precedent: a `discovery_operations` block pinned to the Python table `DISCOVERY_OPERATIONS` (`scripts/dev_tools/_codex_discovery_routing.py`) and to the PowerShell and TypeScript resolvers, plus four entries in `generated_agent_families`. Reusing either requires editing existing Python and its twins.
- Readers: `push_down_claude_routing_merge.py` (merges top-level blocks, appends source-only blocks), orchestrator-state route gates (read `routes` only), codex resolvers (read their blocks only). No reader rejects an unknown top-level key; no schema constrains the file.
- Recommendation: add a top-level `docs_operations` block keyed by the eight skills, each `{ "logical_agent": "<role or root>", "mcp_tools": [ ... ] }` (table in section 9), mirrored to the bundled copy, and pinned by the new roles Pester suite against the agent files and skills. No route, `generated_agent_families` or `discovery_operations` change.

## 6. Codex and Copilot Reach (Research Question 6, owner question Q7)

- Verified constraints: the docs lib is published only under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` (1020 OQ-2); a Codex lib would need a `VIRTUAL_RESOURCE_DIRECTORIES` entry in `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts` and the Python twin `scripts/dev_tools/push_down_codex_and_agents_customizations.py`. 900007's tools invoke `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1` in the workspace (1020 decision), so they fail in a workspace without the Claude push-down. `.codex/config.toml` `enabled_tools` lists no docs tool and pins the MCP package version.
- Position (consistent with the provisional default): produce the Codex and Copilot copies required by the spec; their steps use only the six MCP tools and the subcommand names, contain no `.claude/` path, and state the prerequisite "the docs helper library delivered by the Claude customization push-down and PowerShell 7.4". Root-only steps (`init`, `validate-profile`, receipt persistence) are marked unavailable without that library. No Codex hook and no `.codex/config.toml` edit in this child.
- Residual: OQ-2 (whether to enable the six tools in `.codex/config.toml` here or in 900007, and whether Codex and Copilot roles without stop and write hooks are acceptable).

## 7. Skill Helper (Research Question 7)

None is needed. Every operation maps to an existing subcommand or MCP tool; templates are data files in the skill folder. If a later need arises, the location is `.claude/lib/docs/Docs<Area>.psm1` under 1020's conventions (core manifest, bundle copy, T3).

## 8. Tiers, Batch Budget, File Size (Research Question 8)

- `quality-tiers.yml`: `.claude/hooks` is T3; no new `.claude/lib` directory is created; no edit.
- Batch budget: six non-test PowerShell production files (three hooks, three bundle copies) exceed the direct-mode cap of three; Markdown and JSON do not count. Execution runs in the item worktree under a non-terminal `preparation` or `large` checkpoint, per the epic and the brief `## Batch Budget`.
- Hook behavior on the branch is proven by Pester only (brief `## Hook Execution Context`); no acceptance item may depend on an isolated subagent exercising a branch hook.
- File size: hooks under 500 lines each; split the roles structural suite by concern (allowlists, mirrors, skills) if it approaches 500. Markdown is exempt.

## 9. Skill and Agent Content Contract (Research Question 9)

Option spellings for 1021-1024 and 1034 subcommands are not in this worktree in PowerShell form (their specs still describe the withdrawn Python CLIs); only 1020's options are verified (`init`: `-RepositoryId`, `-Profile`, `-Write`, `-Force`; `validate-profile`: `-Profile`; global `-Json`, `-Help`, `-RepositoryRoot`). Skills therefore name subcommands and MCP tools, give 1020 options exactly, and for other subcommands instruct `-Help` and the dispatch-table option names read at execution from the merged `Get-DocsCommandTable` rows (orchestrator to confirm).

| Skill | Runs as | Subcommands (root, `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1`) | MCP tools (role) |
|---|---|---|---|
| `documentation-workflow` | root alias | none; dispatches to the seven skills below | none |
| `docs-init` | root | `-Command init` (dry run), then `-Write` (and `-Force` only on request); `-Command validate-profile -Json` | none (no MCP tool wraps `init` or `validate-profile`) |
| `docs-inventory-surface` | `docs-architect` | `-Command inventory -Json` (root fallback) | `run_docs_inventory` |
| `docs-plan-ia` | `docs-architect` | none | `run_docs_inventory`, `run_docs_coverage`, `run_docs_check` |
| `docs-author-page` | `docs-author` | `-Command generate-reference` (root fallback; dry run unless the write switch) | `generate_docs_reference` (reference families), `run_docs_check` |
| `docs-reconcile-behavior` | `docs-reconciler` | `-Command update-ledger` (dry run unless the write switch) | `run_docs_coverage`, `update_docs_ledger` (operations `set-disposition`, `remove-entry`, `pin`, `unpin`, `set-dimension`, `sync-refs`), `validate_docs_artifacts` |
| `docs-review-coverage` | `docs-coverage-reviewer` | `-Command surface-delta` (root, 1034) | `run_docs_coverage`, `validate_docs_artifacts`, `run_docs_check` |
| `docs-validate` | root or `docs-coverage-reviewer` | `-Command validate` with mode `docs-complete` and the head revision; the write-receipt switch only from root or CI | `validate_docs_artifacts` (never persists a receipt), `run_docs_check` |

Role allowlists (all quoted `mcp__drm-copilot__` forms; no `memory:`, no `model:` override, no Bash):

| Role | Native tools | MCP tools |
|---|---|---|
| `docs-architect` | Read, Grep, Glob | `run_docs_inventory`, `run_docs_coverage`, `run_docs_check` |
| `docs-author` | Read, Grep, Glob, Write, Edit | `generate_docs_reference`, `run_docs_check` |
| `docs-reconciler` | Read, Grep, Glob | `run_docs_coverage`, `update_docs_ledger`, `validate_docs_artifacts` |
| `docs-coverage-reviewer` | Read, Grep, Glob | `run_docs_coverage`, `validate_docs_artifacts`, `run_docs_check` |

Every MCP tool is held by at least one role; `update_docs_ledger` only by `docs-reconciler`. The reviewer judges the `accurate` dimension and reports it; the reconciler records it with `set-dimension` (OQ-6).

Page templates (in `docs-author-page/templates/`): `tutorial.md` (`diataxis_mode: tutorial`), `how-to.md` (`how-to`), `explanation.md` (`explanation`), `architecture-overview.md` (`explanation`; 1024 does not render `architecture-component`), and `cli-reference.md`, `http-reference.md`, `config-reference.md`, `api-reference.md` (`reference`; prose around the 1024 generated blocks). Each carries the five front-matter fields `owner`, `last_reviewed`, `audience`, `diataxis_mode`, `surface_refs` with placeholders. Templates live outside documentation roots, so `run_docs_check` never scans them.

## 10. Artifact Classification (Research Question 10)

Rules: R1 = directive clause (1), pushed-down skills, helpers, hooks and libs are PowerShell or bash; R2 = clause (2), TypeScript only for MCP and extension commands (none here); D = epic `### Artifact classes for this epic` (skill, agent, schema/config/data, test rows); "avoid new Python" applies to every row.

| File (create unless noted) | Class | Language | Rule |
|---|---|---|---|
| `.github/agents/docs-{architect,author,reconciler,coverage-reviewer}.agent.md` and Copilot bundle copies | agent | Markdown | D |
| `.claude/agents/docs-*.md` and Claude bundle copies | agent | Markdown | D |
| `.codex/agents/docs-*.toml` and Codex bundle copies | agent | TOML | D |
| `.github/skills/<8 skills>/SKILL.md`, `.claude/skills/...`, `.agents/skills/...` and their three bundle copies | skill | Markdown | D |
| `<host>/skills/docs-author-page/templates/*.md` (eight, per host and bundle) | skill (data) | Markdown | D |
| `.claude/hooks/docs-role-contract.ps1`, `validate-docs-role-output.ps1`, `enforce-docs-role-write-scope.ps1` and bundle copies | hook | PowerShell | R1 |
| `.claude/settings.json` and bundle copy (edit: one SubagentStop and one PreToolUse entry) | schema/config/data | JSON | D |
| `config/orchestration-routing.json` and `extensions/drm-copilot/resources/config/orchestration-routing.json` (edit: `docs_operations`) | schema/config/data | JSON | D |
| Claude and Codex `pack-manifests/core.json` (edit) | schema/config/data | JSON | D |
| Codex generator run (write then `--check`) | generator task (existing Python, called) | n/a | owner directive (call existing tooling) |
| `tests/scripts/claude-hooks/{docs-role-contract,validate-docs-role-output,enforce-docs-role-write-scope}.Tests.ps1` | test | PowerShell (Pester) | D |
| `tests/scripts/claude-runtime/docs-authoring-roles.Tests.ps1` (allowlists, mirrors, manifests, registration, routing block, skill references against `repo-automation-tool-names.ts` and the dispatch table) | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-authoring-workflow-1037/**` | documentation | Markdown | D |

No MCP tool, extension command, Python file or TypeScript file is created or edited.

## Numeric Derivation Evidence

### Docs roles (4)

- Complete Family: docs-architect, docs-author, docs-reconciler, docs-coverage-reviewer
- Exhaustive Search Scope: the complete epic document and the complete feature spec in this worktree tree
- Inclusion Rules: role names assigned to 900009
- Exclusion Rules: discovery roles and existing agents
- Primary Search Strategy or Query Expression: epic `### Naming contract` Roles bullet listing docs-architect, docs-author, docs-reconciler, docs-coverage-reviewer
- Primary Member Set: docs-architect, docs-author, docs-reconciler, docs-coverage-reviewer
- Primary Count: 4
- Cross-check Search Strategy or Query Expression: spec `## Behavior` first bullet naming docs-architect, docs-author, docs-reconciler, docs-coverage-reviewer under `.claude/agents/`
- Cross-check Member Set: docs-architect, docs-author, docs-reconciler, docs-coverage-reviewer
- Cross-check Count: 4
- Member-set Comparison: the normalized sets are equal

### Skills (8)

- Complete Family: documentation-workflow, docs-init, docs-inventory-surface, docs-plan-ia, docs-author-page, docs-reconcile-behavior, docs-review-coverage, docs-validate
- Exhaustive Search Scope: the complete epic document and the complete feature spec in this worktree tree
- Inclusion Rules: skill names assigned to 900009
- Exclusion Rules: templates inside a skill folder
- Primary Search Strategy or Query Expression: epic `### 900009` Skills bullet naming documentation-workflow, docs-init, docs-inventory-surface, docs-plan-ia, docs-author-page, docs-reconcile-behavior, docs-review-coverage, docs-validate
- Primary Member Set: documentation-workflow, docs-init, docs-inventory-surface, docs-plan-ia, docs-author-page, docs-reconcile-behavior, docs-review-coverage, docs-validate
- Primary Count: 8
- Cross-check Search Strategy or Query Expression: spec `## Behavior` second bullet naming documentation-workflow, docs-init, docs-inventory-surface, docs-plan-ia, docs-author-page, docs-reconcile-behavior, docs-review-coverage, docs-validate
- Cross-check Member Set: documentation-workflow, docs-init, docs-inventory-surface, docs-plan-ia, docs-author-page, docs-reconcile-behavior, docs-review-coverage, docs-validate
- Cross-check Count: 8
- Member-set Comparison: the normalized sets are equal

### Page templates (8)

- Complete Family: tutorial, how-to, explanation, cli-reference, http-reference, config-reference, api-reference, architecture-overview
- Exhaustive Search Scope: the complete epic document and the complete feature spec in this worktree tree
- Inclusion Rules: template names under docs-author-page
- Exclusion Rules: Diataxis mode values
- Primary Search Strategy or Query Expression: epic `### 900009` parenthesis after docs-author-page listing tutorial, how-to, explanation, cli-reference, http-reference, config-reference, api-reference, architecture-overview
- Primary Member Set: tutorial, how-to, explanation, cli-reference, http-reference, config-reference, api-reference, architecture-overview
- Primary Count: 8
- Cross-check Search Strategy or Query Expression: spec `## Behavior` parenthesis listing tutorial, how-to, explanation, cli-reference, http-reference, config-reference, api-reference, architecture-overview
- Cross-check Member Set: tutorial, how-to, explanation, cli-reference, http-reference, config-reference, api-reference, architecture-overview
- Cross-check Count: 8
- Member-set Comparison: the normalized sets are equal

### Locations per new agent (6)

- Complete Family: github-agent, copilot-bundle-agent, claude-agent, claude-bundle-agent, codex-agent, codex-bundle-agent
- Exhaustive Search Scope: the entire worktree tree searched for one non-generated agent
- Inclusion Rules: files that carry one agent on any host or bundle
- Exclusion Rules: generated `-c*` variants (not applicable to docs roles, OQ-3)
- Primary Search Strategy or Query Expression: glob `**/discovery-capability-sentinel*` giving github-agent, copilot-bundle-agent, claude-agent, claude-bundle-agent, codex-agent, codex-bundle-agent
- Primary Member Set: github-agent, copilot-bundle-agent, claude-agent, claude-bundle-agent, codex-agent, codex-bundle-agent
- Primary Count: 6
- Cross-check Search Strategy or Query Expression: assertions of `test_role_has_exact_native_representation_on_every_host` (github-agent, copilot-bundle-agent, claude-agent, claude-bundle-agent, codex-agent, codex-bundle-agent base suffix)
- Cross-check Member Set: github-agent, copilot-bundle-agent, claude-agent, claude-bundle-agent, codex-agent, codex-bundle-agent
- Cross-check Count: 6
- Member-set Comparison: the normalized sets are equal

No numeric acceptance criterion is proposed beyond these counts.

## Testing Implications

- Pester only (no new Python or Jest). Suites in section 4.4 and the roles suite of section 10; every file read goes through a seam or reads committed files; no temporary files.
- Run the existing contract tests listed in the brief `## Contract Tests That Pin Mirrored Files` plus `test_codex_full_migration_inventory.py`, `test_discovery_publication_contracts.py`, `test_orchestration_routing_config_parity.py`, `test_codex_topology_policy_config_parity.py`, and the Codex generator `--check`.
- Coverage: Pester line coverage at least 85% per new hook file from `artifacts/pester/powershell-coverage.xml`; no branch gate for PowerShell.
- Isolation: seeded shuffled file-order runs (three seeds) of the four new suites in one process, and a fresh single-process run over `tests/scripts`, per the brief `## Test Isolation Checks`.

## Pre-Mortem

- Review checklists: a reviewer can flag a docs role holding Write, Edit or Bash beyond the design, a `memory:` field, a path-scoped `Write(` entry presented as enforcement, or a skill naming an option that no merged dispatch row defines. The plan must assert each in `docs-authoring-roles.Tests.ps1` and read option names from the merged dispatch table at execution.
- Coverage: the three hook files are production PowerShell under `.claude/hooks` (in `config/poshqc-coverage.json` roots); per-file line coverage below 85% fails review. The plan must give each token rule, the non-docs pass-through, the `StopHookActive` path, each deny rule and each dependency-failure path a test.
- Mirror parity: 4 agents x 6 locations, 8 skills x 6 copies, template copies, three hook bundle copies, the bundled `.claude/settings.json`, the bundled routing config and two `core.json` files must all agree; the Copilot bundle `customizations/.github/` is the copy most likely to be missed because the epic does not list it. The plan must run the contract tests of section 2 and the Codex generator write then `--check`. No execution-environment brief fact changes, so no brief-update task is needed.
- File size: hooks stay under 500 lines; the roles structural suite is split by concern before 500 lines. Markdown is exempt.
- Test isolation: suites dot-source hook scripts that define functions in script scope and may import modules; each suite removes what it adds in `AfterAll`, and the shuffled and single-process runs are recorded under `<FEATURE>/evidence/regression-testing/`.
- CI-only behavior: `tests/scripts/claude-hooks` also runs on Linux with a case-sensitive file system; tests use `Join-Path`, forward-slash relative paths and no drive letters. The settings and routing copies must be byte-identical after `eol=lf` normalization, so edits must not introduce CRLF.
- Evidence: every command step writes `Timestamp`, `Command`, `EXIT_CODE` and `Output Summary` under `<FEATURE>/evidence/<kind>/` with write-time UTC stamps and `SCRATCH` for scratch paths; PoshQC MCP results carry no output, so counts come from the JUnit and coverage files.

## Automation Feasibility

No human interaction is expected during execution. All work is file authoring, Pester suites, existing pytest contract tests and one existing generator run, executable by the executor and orchestrator under the routes in the brief. The live use of the roles depends on the docs MCP tools from 900007 being released and installed (brief `## MCP Surfaces Run the Installed Extension`); execution and acceptance do not depend on a live role run, because the hooks are proven by Pester.

## Contracts Later Children Must Honor (900010)

- Role names and allowlists of section 9; `update_docs_ledger` held only by `docs-reconciler`; no docs role carries `memory:`.
- Skill names, the `documentation-workflow` dispatch table, the skill-to-role map of `docs_operations`, and the rule that `docs-init` and receipt persistence are root-only steps.
- Template paths `.claude/skills/docs-author-page/templates/<name>.md` (and host copies) with the five front-matter fields and the mode mapping of section 9; the epic template's wave 0 references them by these paths.
- SubagentStop result tokens of section 4.3, which the end-to-end onboarding text and any orchestration of the roles must request in delegation prompts.
- The write-scope rule of section 3.3 (D-A) and the prerequisite statement for Codex and Copilot hosts (section 6), which the onboarding guide states.

## Owner Questions

- OQ-1 - Write-scope enforcement. Approve adding the PreToolUse hook `enforce-docs-role-write-scope.ps1` (design D-A) to this child, and the AC reading "no Write or Edit for three roles; bare Write and Edit for `docs-author` restricted by the hook". Fallback D-B: `docs-author` has no Write and returns page text to the root. Provisional default: D-A.
- OQ-2 - Codex and Copilot reach (epic Q7). Docs lib in the Claude bundle only; Codex and Copilot copies are produced with an explicit prerequisite and no host hooks. Decide whether the six tools are added to `.codex/config.toml` `enabled_tools` (here or in 900007). Provisional default: no `.codex/config.toml` change in this child.
- OQ-3 - Codex variants. Docs roles get one base Codex wrapper each and no `-c*` variants, because adding them to `GENERATED_AGENT_FAMILIES` extends existing Python and its PowerShell and TypeScript twins. Provisional default: base wrappers only.
- OQ-4 - Epic text correction. The epic and spec name `agentic_sync.py` as a mirror generator and omit the Copilot bundle; the mirrors are hand-authored and the Copilot bundle is required. The orchestrator should correct the epic `### 900009` Files bullet.
- OQ-5 - Routing entry shape. `docs_operations` has no runtime reader; it documents the skill-to-role map and is pinned by Pester. Confirm, or drop the routing edit from scope.
- OQ-6 - Accuracy recording. The reviewer is read-only and reports the `accurate` judgment; the reconciler records it with `set-dimension`. Alternative: grant `update_docs_ledger` to the reviewer, which makes two mutating roles. Provisional default: reviewer read-only.

## Rejected Alternatives (summary)

- Path-scoped `Write(...)` or `disallowedTools` specifiers: inert or whole-tool removal.
- Writing narrative pages through `generate_docs_reference`: it renders only reference families.
- Generated Codex variants for docs roles: requires extending existing Python.
- One SubagentStop hook per role: four registrations and four near-identical scripts; `AgentType` dispatch covers all four.
- A new `.claude/lib/docs-roles/` module: needs a new `quality-tiers.yml` entry; a dot-sourced hook helper follows the `premortem-section.ps1` precedent.
- Using `codex_native_converter` for Codex copies: its wrapper fails the committed wrapper contract.

## Items for the Orchestrator to Confirm

1. The filename stamp was not read from a clock by this agent; the orchestrator renamed the file to the clock-read stamp `2026-10-30T23-33` (confirmed).
2. PowerShell option names for `check`, `inventory`, `coverage`, `update-ledger`, `validate`, `generate-reference` and `surface-delta`, and 900007 tool input schemas, from the merged branches before skill text is written.
3. That the installed Claude Code version supplies `agent_type` in PreToolUse payloads for project subagents (precedent hook relies on it).
4. Branch head and whether `main` or the integration branch gained any test enumerating agents, skills or routing keys since this worktree was created (needs `git`).
