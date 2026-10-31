# Research: Shared-Source Generators for Skills, Rules, MCP and Agents (Issue #1028)

- Issue: #1028 (epic #1018, child 3)
- Mode: preparation research; no source file was changed
- Feature folder (`<FEATURE>`): `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028`
- Inputs read: `<FEATURE>/issue.md`, `<FEATURE>/spec.md` (template state), `docs/features/epics/shared-agent-harness-layer/epic.md`, `docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md` (settled, not re-opened), `.claude/skills/execution-environment/SKILL.md`, and the upstream extracts in `SCRATCH` (`issue-1028-child1-spec.md`, `issue-1028-child1-research.2026-10-30T21-08.md`, `issue-1028-child1-plan.2026-10-30T17-06.md`, `issue-1028-child1-owner-decision-plan.md`, `issue-1028-child2-design-1016.md`, `issue-1028-parallel-manifest.md`).
- Tree state: the working tree equals `origin/main` plus the epic documents (caller statement). Every repository fact below was read from this tree with Read, Grep and Glob. Facts that need `git` or `gh` are marked UNVERIFIED.
- Timestamp note: this agent had no clock tool and wrote a placeholder stamp. The orchestrator renamed the file to `2026-10-30T22-46`, the UTC write time read from the host clock when the file appeared.

---

## 1. Current Inventory and Divergence

All counts in this section are informational planning context. None is proposed as a `spec.md` acceptance threshold (see `## Numeric Derivation Evidence`).

### 1.1 `.agents/skills` versus `.claude/skills`

Enumerated with Glob over `<tree>/*/SKILL.md`:

- `.claude/skills`: 66 skill folders. `.agents/skills`: 79 skill folders. Names in both: 55.
- Claude-only (11): `cleanup-merged-worktrees`, `identify-session-id`, `mermaid-diagram`, `parallel-add`, `parallel-close`, `parallel-orchestrate`, `parallel-plan`, `parallel-remove`, `parallel-run`, `quota-throttling`, `show-my-agent-tree`.
- Codex-only (24): `architecture-boundaries`, `atomic-executor`, `atomic-planner`, `benchmark-baselines`, `ci-workflows`, `codex-model-routing`, `commit-message-conventions`, `csharp`, `feature-review`, `general-code-change`, `general-unit-test`, `orchestrator-state`, `orchestrator-workflow`, `powershell`, `pr-authoring`, `python`, `python-suppressions`, `quality-tiers`, `repo-automation-adapter`, `self-explanatory-code-commenting`, `tonality`, `translate-claude-to-codex`, `typescript`, `typescript-suppressions`.
- These figures agree with the child 1 research (55 shared, 11 Claude-only, 24 Codex-only).
- Byte identity of the 55 shared copies: not verified here (no hashing tool). The epic record states 12 byte-identical, 27 wording-only and 16 material; child 1 research section 1.3 reports equal non-empty line counts for 31 names and large deltas for, among others, `epic-orchestrate` (Claude 308 / Codex 144 non-empty lines), `orchestrate` (322 / 393), `remediation-handoff-atomic-planner` (93 / 36) and `pr-author` (98 / 35). UNVERIFIED until child 1's identity evidence (`skill-identity.<timestamp>.md`) exists.

Frontmatter (verified by Grep for frontmatter keys):

- Claude-only keys in `.claude/skills`: `allowed-tools` (`cleanup-merged-worktrees`, `commit-message`, `execute-hard-lock`, `identify-session-id`, `pr-author`, `research-issue`, `show-my-agent-tree`); `argument-hint` plus `context: fork` plus `agent:` (`epic-orchestrate`, `epic-plan`, `epic-run`, and the six `parallel-*` skills); `argument-hint` only (`orchestrate`).
- Of these, the shared names carrying Claude-only keys are `commit-message`, `execute-hard-lock`, `pr-author`, `research-issue` (`allowed-tools`), `epic-orchestrate`, `epic-plan`, `epic-run` (`argument-hint`, `context`, `agent`) and `orchestrate` (`argument-hint`).
- Every `.agents/skills/*/SKILL.md` frontmatter holds only `name` and `description` (the extra key matches in `make-skill-template`, `orchestrate` and `epic-orchestrate` are YAML inside fenced body examples, verified by reading `.agents/skills/epic-orchestrate/SKILL.md`).
- Consequence: the mirror generator needs a source for the Claude-only keys. The settled design puts them in a superset frontmatter in `.agents/skills`; whether Codex tolerates them is child 1 experiment E2 (unresolved). VS Code Copilot reads `.agents/skills` and honors `argument-hint`, `context: fork` and related keys (child 1 research, E2), so a superset frontmatter also changes Copilot behavior.

Supporting files: `.agents/skills/codex-model-routing/agents/openai.yaml` and `.agents/skills/repo-automation-adapter/agents/openai.yaml` are Codex metadata and must not be mirrored into `.claude/skills`; `.agents/skills/human-exception-runbook/example.runbook.md` has a Claude counterpart. No `.agents/skills/*/references/` folder exists yet (child 1 creates `references/standard.md`).

Body content is ecosystem-specific in places: Claude copies cite `.claude/rules`, `.claude/agents` and Claude tool names; Codex copies cite `.agents/skills/...` and `.codex/...`. A neutral body therefore needs either tool-neutral wording or a per-tool substitution mechanism (see 1.2 for a test that pins per-target wording).

### 1.2 `.claude/rules` versus `.github/instructions` (and the Codex rule-skills)

- `.claude/rules`: 19 files, each with YAML frontmatter `paths:` (a YAML list) and `description:`. `.github/instructions`: 17 files with `applyTo:` (one comma-separated string), usually `name:` and `description:`.
- Correspondence is not one-to-one:
  - Claude merges code-change and unit-test policy per language into one file (`python.md`, `powershell.md`, `typescript.md`, `csharp.md`); Copilot has two files per language (`python-code-change.instructions.md` and `python-unit-test.instructions.md`, and so on).
  - Claude-only rules: `architecture-boundaries.md`, `benchmark-baselines.md`, `ci-workflows.md`, `orchestrator-state.md`, `parallel-orchestration.md`, `plan-acceptance-gates.md`, `quality-tiers.md`, `shell.md`.
  - Copilot-only instructions: `github-actions.instructions.md`, `github-actions-ci-cd-best-practices.instructions.md`.
  - Bodies differ in kind: each `.claude/rules` file states "This rule file summarizes ...", while `CLAUDE.md` (`## Policy Compliance Reading Order`) names the `.github/instructions` files as "the canonical policy source".
  - Globs differ: `mermaid.instructions.md` has `applyTo: "**"`; `.claude/rules/mermaid.md` has `paths: ["**/*.mmd", "**/*.mermaid"]`. `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` (`DELIBERATE_UNCONDITIONAL_RULES`, `test_unconditional_rule_set_is_exactly_the_four_deliberate_files`) allows exactly four unconditional Claude rules, so a single source cannot carry the Copilot `**` glob into the Claude output.
  - Defect observed: `.github/instructions/general-unit-test.instructions.md` has no opening `---` line (its first line is `applyTo: "**"`). A generator that parses frontmatter must handle or report this file; generating the file fixes it.
- Third copy: Codex has no path-scoped rules, so the rule content is expressed again as Codex-only skills (`.agents/skills/python`, `powershell`, `typescript`, `csharp`, `general-code-change`, `general-unit-test`, `tonality`, `quality-tiers`, `ci-workflows`, `architecture-boundaries`, `benchmark-baselines`, `orchestrator-state`, `python-suppressions`, `typescript-suppressions`, `self-explanatory-code-commenting`). These already drift: `.agents/skills/python/SKILL.md` (`## Toolchain`) states coverage ">= 90%" and omits `--cov-branch`, while `.claude/rules/python.md` states ">= 85% line, >= 75% branch" with `--cov-branch`. The settled design names only `.claude/rules` and `.github/instructions` as targets (Owner Question OQ-2).
- Per-target wording is pinned: `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` requires `CLAUDE_PRECEDENCE_FRAGMENTS` ("root `CLAUDE.md`") in `.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md` and `CODEX_PRECEDENCE_FRAGMENTS` ("root `AGENTS.md` ... then root `CLAUDE.md`") in `.agents/skills/quality-tiers/SKILL.md` and `.agents/skills/general-unit-test/SKILL.md`, each with its bundle copy. A single rule source therefore needs per-target substitutions or per-target fragments.

### 1.3 `.mcp.json` versus `[mcp_servers]` in `.codex/config.toml`

- `.mcp.json`: one server `drm-copilot`, `command: "npx"`, `args: ["-y", "@danmoisan/drm-copilot-mcp"]` (unpinned).
- `.codex/config.toml` `[mcp_servers.drm-copilot]`: `command = "npx"`, `args = ["-y", "@danmoisan/drm-copilot-mcp@1.1.23"]` (pinned), plus Codex-only keys `required`, `enabled_tools` (20 names), `default_tools_approval_mode`, and 15 `[mcp_servers.drm-copilot.tools.<tool>]` tables with `approval_mode = "approve"`. The rest of the file (`default_permissions`, `[permissions.*]`, `[features]`, `[agents]`, `[[hooks.*]]`) is not MCP.
- The pin is written by `scripts/dev-tools/Invoke-FullRelease.ps1` (`Set-CodexMcpVersionPin`, called from `Invoke-FullReleaseGuarded` for `.codex/config.toml` and the bundled copy) with an anchored regular expression that requires exactly one `args = ["-y", "@danmoisan/drm-copilot-mcp[@<v>]"]` line. The pinned value equals `packages/mcp-server/package.json` `version` (`1.1.23`). Tests that pin this: `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1`, `Invoke-ReleaseVerification*.Tests.ps1`, `Invoke-ReleaseTagPush.Tests.ps1`, `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` pins the MCP section: `EXPECTED_DRM_COPILOT_TOOLS`, `APPROVED_DRM_COPILOT_TOOLS`, `test_codex_config_files_retain_full_drm_copilot_transport`, `test_codex_role_files_do_not_retain_drm_copilot_transport`, and root/bundle equality of `.codex/config.toml`.
- Bundle copies: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`; `extensions/drm-copilot/resources/claude-dir-customizations/.mcp.json`. No file outside `docs/` references `claude-dir-customizations` (Grep for `claude-dir`), so the bundled `.mcp.json` appears unused; UNVERIFIED whether a build step consumes it.

### 1.4 `.claude/agents/*.md` versus `.codex/agents/*.toml`

- `.claude/agents`: 25 Markdown files with YAML frontmatter (`name`, `description`, `model`, `tools`, `skills`, `memory`, `hooks`) and a Markdown body.
- `.codex/agents`: 130 TOML files = 50 base files plus 80 generated variants (16 families times five profiles `-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4`). The epic record's "about 98 unique" does not match the 50 base files observed (UNVERIFIED which count the epic meant).
- Name overlap: 21 names exist in both (`atomic-executor`, `atomic-planner`, `csharp-typed-engineer`, `discovery-capability-sentinel`, `epic-orchestrator`, `epic-planner`, `epic-review`, `feature-review`, `legacy-parity-analyst`, `migration-coverage-reviewer`, `orchestrator`, `powershell-typed-engineer`, `pr-author`, `prd-feature`, `python-typed-engineer`, `requirements-reconciler`, `runtime-characterization-analyst`, `staged-review`, `status-updater`, `task-researcher`, `typescript-engineer`). Claude-only: `commit-message`, `human-exception-runbook`, `parallel-orchestrator`, `parallel-planner`. The remaining 29 Codex base files are Codex-only (for example `commit-steward`, `feature-reviewer`, `hlbpa`, `mentor`, `tdd-red`).
- Bodies are not equivalent: `.codex/agents/task-researcher.toml` has `description = "Converted subagent"` and `developer_instructions` in converted text; `.claude/agents/task-researcher.md` has a different description and body. Child 1 surveys skill content only; it does not survey agent bodies (Owner Question OQ-5).
- Write-scope literals that D-16 concerns live only in Claude agent `tools:` entries (Grep for `Write(` / `Edit(`): `atomic-planner` (`Edit(docs/**)`, `Write(docs/**)`), `epic-orchestrator` and `epic-planner` (`docs/features/epics/**`, `docs/features/potential/**`), `parallel-orchestrator` and `parallel-planner` (`docs/features/parallel/**`), `feature-review` and `prd-feature` (`/docs/features/active/**`), `epic-review` and `status-updater` (`/docs/features/**`), `task-researcher` (`/docs/features/**/research/**`, `/docs/research/**`), `human-exception-runbook` (`<FEATURE>/runbooks/**`), plus `artifacts/**` scopes. `.claude/settings.json` `permissions` carries `Edit(docs/**)`. Codex agents carry no write scopes; Codex filesystem scope is the `[permissions.orchestrator-workspace]` profile in `.codex/config.toml`. Note: the mixed leading-slash forms are pre-existing; their matcher semantics are not verified here.
- How Codex variants are generated today: see section 2.

### 1.5 `AGENTS.md` versus `CLAUDE.md`

- `AGENTS.md` is converter output, not an authored source. It begins `# Converted standing guidance`, embeds converted copies of `.claude/rules/general-code-change.md`, `general-unit-test.md`, `tonality.md` and a path-rewritten copy of `CLAUDE.md` (`## Source: \`AGENTS.md\``), and ends with a Codex-only `## Codex Epic Planning and Model Routing`. The header text matches `scripts/dev_tools/codex_native_converter/pipeline.py` and `extensions/drm-copilot/src/lib/codex-native-converter/pipeline-render.ts` (Grep for `Converted standing guidance`). The bundled copy is `extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md`.
- `AGENTS.md` cites files that do not exist (`.agents/skills/python-code-change/SKILL.md`, `.agents/skills/github-actions/SKILL.md`, and others in its `## Policy Compliance Reading Order`).
- A second generator also targets `AGENTS.md`: `scripts/dev-tools/sync-agents-from-instructions.ps1` (`Get-AgentContent`, `Invoke-SyncAgentInstruction`) rewrites `AGENTS.md` from `.github/copilot-instructions.md` and `.github/instructions/*.instructions.md`. It is wired into `.vscode/tasks.json`, the extension command registration (`extensions/drm-copilot/src/repo-automation-command-registration-admin.ts`), a bundled template copy, and tests `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`. Once `AGENTS.md` is the hand-authored source, either generator would overwrite it (Owner Question OQ-6).
- `CLAUDE.md` has YAML frontmatter (`description:`), names `.github/` as authoritative, and is not `@AGENTS.md`. Making it `@AGENTS.md` while `AGENTS.md` still embeds the three rule copies would load those rules twice in Claude (once as `.claude/rules`, once through the import), which contradicts the epic goal; `AGENTS.md` must be rewritten without embedded rule copies.
- Hooks that read the root `CLAUDE.md` text and do not follow `@` imports: `.claude/hooks/validate-feature-review-coverage-metrics.ps1`, `.claude/hooks/validate-feature-review-coverage.ps1` (`Get-FeatureReviewClaudeMdText`), `.claude/hooks/feature-review-coverage-thresholds.ps1`, and the Codex twins under `.codex/hooks/`. Today `CLAUDE.md` states no thresholds, so behavior is unchanged as long as no threshold statement moves into `AGENTS.md` (Owner Question OQ-7).
- `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py` and `parallel_orchestrator_surface_expectations.py` describe the runtime injecting `CLAUDE.md`; they assert skill and agent text, not `CLAUDE.md` content.

---

## 2. The Existing Codex Agent-Variant Generator

`scripts/dev_tools/generate_codex_agent_variants.py`:

- Inputs: the base TOML `.codex/agents/<family>.toml` for each family in `GENERATED_AGENT_FAMILIES` (`scripts/dev_tools/resolve_codex_deployment.py`, 16 families including the four in `DISCOVERY_GENERATED_AGENT_FAMILIES` from `scripts/dev_tools/_codex_discovery_routing.py`); profiles from `BASE_PROFILES` and `C3_ELEVATED_PROFILE` (the same values are recorded under `codex_model_policy` in `config/orchestration-routing.json`); the six Codex pack manifests.
- Outputs (`_synchronize`): it rewrites each base file as a C3-pinned alias (`render_base_alias`: drops `model =` and `model_reasoning_effort =` lines before `developer_instructions`, requires `name = "<family>"` and a `description = ` line, inserts the C3 model lines after the description) in both the repository and `extensions/drm-copilot/resources/codex-and-agents-customizations/`; writes the five variants per family to both roots (`render_agent_variant`); adds missing base and variant paths to `pack-manifests/core.json`, `python.json`, `powershell.json`, `typescript.json`, `csharp-modern.json`, `csharp-legacy.json` (`PACK_FAMILIES`, `render_manifest`). Newlines of the base are preserved.
- `--check`: no writes; reports a stale or root/bundle-differing base alias, a base not pinned to the C3 profile, each stale variant in either root, and each stale manifest, then exits 1 with one stderr line per error.
- CI: `.github/workflows/_quality-checks.yml` step `Verify Codex agent deployment profiles` runs `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` on all four Python legs, gated by `inputs.run-heavy`.
- Tests: `tests/scripts/dev_tools/test_generate_codex_agent_variants.py` (`test_checked_in_variants_match_generator_output_in_both_surfaces`, `test_generator_check_mode_reports_no_drift`, `test_affected_pack_manifests_include_each_generated_profile`, and others).
- Parallel-run overlap: the generator is in the blast radius of items 1002, 1010, 1012 and 1013, so its interface may change before child 3 executes.

Options for reuse without adding Python to it:

| Option | Description | Assessment |
| --- | --- | --- |
| A. Chain at the CI and documentation level (recommended) | The new PowerShell agent generator writes the base `.codex/agents/<name>.toml` files (and the Claude `.md` files). For the 16 variant families it emits the base already in the alias form that `render_base_alias` produces (model and reasoning lines after `description`, values from `config/orchestration-routing.json` `codex_model_policy`). Developers run the PowerShell generator, then the Python generator in write mode; CI runs both `--check` modes independently. | No Python edit; no Python invoked from PowerShell, so the PowerShell generator stays runnable where Python is absent; the Python check proves the bases are in alias form. Cost: two commands for a developer, and the C3 values are read from JSON rather than imported. |
| B. PowerShell generator calls the Python generator | The PowerShell generator shells out to `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` after writing bases. | Allowed by "call", but makes the PowerShell generator depend on Poetry; unusable in a destination without Python if child 4 pushes generators down. Rejected unless OQ-1 confirms generators stay repository-internal. |
| C. Port the variant logic to PowerShell | Re-implement variants in PowerShell. | Duplicates existing Python and creates two implementations that drift; the rule says existing Python is reused. Rejected. |

Generated Codex base files for families outside `GENERATED_AGENT_FAMILIES` are written directly by the PowerShell generator; the Python generator ignores them.

---

## 3. PowerShell Module Conventions for a New Generator

- Layout precedent: `scripts/ci/` holds a thin entry script plus a pure module (`Invoke-CiChangeScope.ps1` with `CiChangeScope.psm1`; `New-FileSizeBaseline.ps1` with `FileSizeBaseline.psm1`), with tests mirrored under `tests/scripts/ci/` (`CiChangeScope.Tests.ps1`, `Invoke-CiChangeScope.Tests.ps1`, `FileSizePolicy.RepoGate.Tests.ps1`). Shipped pure logic lives in `.claude/lib/<name>/` (for example `.claude/lib/file-size-policy/FileSizePolicy.psm1`, consumed by both a hook and the repository gate). Repository-internal PowerShell developer scripts live in `scripts/dev-tools/` (T4).
- Repository gate precedent: `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` imports the modules, walks the tree read-only, starts no process, needs no git history, and runs in the existing PowerShell shards on a depth-one checkout.
- PoshQC: `config/poshqc-scan.json` `scanFolders` is `scripts`, `tests/powershell`, `tests/scripts`; `config/poshqc-coverage.json` `roots` is `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.github/hooks`, `.codex/scripts`, `scripts`. A module under `scripts/<name>/` or `.claude/lib/<name>/` is already a coverage root and its tests under `tests/scripts/...` are already scanned; neither JSON file needs an edit. Analyzer settings: `scripts/powershell/PoshQC/settings/pssa.settings.psd1` (in the parallel run's blast radius; child 3 does not need to edit it).
- Quality tiers: `quality-tiers.yml` exists, so classification applies. `scripts/dev_tools/quality_tiers_contract.py` discovery rule R3 makes every `scripts/<name>` folder that directly holds a code file a project, R4 every `.claude/lib/<name>` folder, and R2 every folder with a same-stem `.psd1`/`.psm1` pair; QT008 fails for a discovered project with no entry. A new `scripts/<name>/` or `.claude/lib/<name>/` folder therefore needs a `quality-tiers.yml` entry in the same change. Placing the generator in the existing `scripts/dev-tools/` needs no entry (already T4).
- Cross-child observation: child 1's spec places modules in `scripts/harness/` but its excluded-paths and edit-set lists do not include `quality-tiers.yml`; under R3 that folder is a new project and QT008 would fail. This is a child 1 preflight item for the orchestrator, recorded here because child 3 may reuse that folder.
- File size: three tiers (500 guidance, 700 advisory, above 800 hard block) per `.claude/rules/general-code-change.md`; enforced by `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` and `.claude/hooks/enforce-file-size-limit.ps1`. Markdown is exempt, so generated `SKILL.md`, rule and agent Markdown files are exempt; generated TOML is not exempt (the largest Codex base agent should be measured at planning time).
- Parsing: PowerShell has no TOML or YAML parser in this repository without a new dependency (Grep for `ConvertFrom-Toml`, `PSToml`, `ConvertFrom-Yaml`, `powershell-yaml` finds only a negative assertion in `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1`). JSON is read with `ConvertFrom-Json`. Precedents for anchored regular-expression handling of `.codex/config.toml`: `Set-CodexMcpVersionPin` in `scripts/dev-tools/Invoke-FullRelease.ps1` and `.codex/hooks/discovery-capability-probe.ps1`.
- Writing: `.gitattributes` is `* text=auto eol=lf`, so generated files must be written with LF and UTF-8 without BOM (for example `[System.IO.File]::WriteAllText` with a `UTF8Encoding($false)`), and `--check` compares exact text. `Invoke-FullRelease.ps1` uses `Set-Content -Encoding utf8NoBOM -NoNewline` with pre-joined LF text, which is also acceptable.
- Batch budget: generated outputs written by a script are not seen by the batch-budget hooks (brief, `## Batch Budget`), but the hand-written modules and the hand-edited sources are. More than three new PowerShell production files in one worktree session require the `large` route checkpoint in the item worktree; an isolated subagent worktree has no checkpoint and is capped at three.

---

## 4. Mirrored and Bundled Copies and the Contract Tests They Touch

Bundle roots under `extensions/drm-copilot/resources/`: `claude-customizations/` (`.claude/**`, `config/**`, `pack-manifests/*.json`, `.claude-variants/csharp-legacy/**`), `codex-and-agents-customizations/` (`.agents/**`, `.codex/**`, `AGENTS.md`, `pack-manifests/*.json`, `.agents-variants/csharp-legacy/**`, `.codex-variants/csharp-legacy/**`), `customizations/` (`.github/**`), `claude-dir-customizations/.mcp.json`.

Contract tests named in the brief (`## Contract Tests That Pin Mirrored Files`) and how each generator affects them:

| Test | Affected by | Effect |
| --- | --- | --- |
| `test_push_down_claude_resource_contracts.py` | skill mirror, rules, agents | every `.claude` runtime file needs an equal bundle copy; the generators must write bundle copies (as the Codex generator does) |
| `test_push_down_codex_and_agents_resource_contracts.py` | skill sources, Codex rule-skills, agents, MCP, `AGENTS.md` | equal bundle copies; pins the MCP tool lists and `.codex/config.toml` root/bundle equality |
| `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py` | any new bundled agent, skill or rule file | each bundled `SKILL.md`/agent must be listed; new files touch `pack-manifests/core.json` (in the parallel run's blast radius) |
| `test_push_down_pack_manifest_dependency_closure.py` | agent generator | hook scripts named in agent frontmatter must stay in core plus the owning pack; the generator must reproduce `hooks:` exactly |
| Codex generator `--check` | agent generator | base TOML must be in alias form (section 2) |
| `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py` | agent generator | pinned Codex agent fragments must survive generation |
| `test_claude_rules_frontmatter.py` | rules generator, agent generator | `paths:` scoping and exactly four unconditional rules; every agent `skills:` entry resolves |
| `parallel_orchestrator_surface_expectations.py` (`PINNED_FROZEN_SURFACE_HASHES`) | skill mirror, agent generator | pins byte hashes of `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`; the first generated write of either changes the hash and requires a re-baseline with a dated comment in the same change |
| `test_quality_checks_workflow_contracts.py` | only if `_quality-checks.yml` is edited | step lookups by name or `run` token (`step_named`, `step_running`) |
| `test_push_down_issue_824_follow_ups.py` | all | no consuming-product names in pushed rules and skills |
| `test_typescript_toolchain_instruction_contracts.py` | rules generator | backticked npm script tokens in pinned rule mirrors must exist in the root `package.json` |
| `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` | agent generator | agent tool names in the architecture document |

Not in the brief list but affected: `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` (per-target precedence fragments, section 1.2), `tests/scripts/dev_tools/test_generate_codex_agent_variants.py`, `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` (if OQ-6 changes that script), and the release tests in 1.3 (MCP generator). `scripts/dev_tools/skill_bundle_contract.py` (`PUBLISHED_ROOT_FOLDERS` = `.claude`, `config`) fails when a skill invokes a script that the bundle does not carry, so any skill text that tells the agent to run a generator requires the generator in a published folder.

Variant subtrees (`.claude-variants/`, `.agents-variants/`, `.codex-variants/` for `csharp-legacy`) are bundle-only and hand-maintained; child 1 excludes bundle copies from the parity matrix. Recommendation: out of child 3 scope, recorded as a non-goal.

---

## 5. CI Wiring

Options:

| Option | Mechanism | Brief impact |
| --- | --- | --- |
| A. Pester repository gate (recommended) | `tests/scripts/<generator-folder>/HarnessGeneration.RepoGate.Tests.ps1` imports the generator modules and runs every generator in check mode against the tree, failing with the list of drifted files. It runs in the required `poshqc / PowerShell QC` check through the existing shards; `config/poshqc-scan.json` already scans `tests/scripts`. | No job, matrix entry or required context changes; no stated brief fact changes. |
| B. Explicit `-Check` step | A step in `poshqc-static` (`_poshqc.yml`) runs the entry script with `-Check`. | Changes the brief's description of `poshqc / PowerShell QC static` ("format and analyze"); requires a same-change update of all six brief copies. |
| C. New job | A new job in `ci.yml` or a reusable workflow. | Adds a check name, which is not required until ruleset 15241672 changes; requires a brief update and a ruleset decision. Rejected. |

The Python check stays in `_quality-checks.yml` (`Verify Codex agent deployment profiles`); no edit there is needed under section 2 option A.

Required contexts (brief, ruleset 15241672, confirmed by the orchestrator on 2026-10-16) include `poshqc / PowerShell QC` and all four `quality-checks7 / Code Quality & Tests (<version>)` legs, so option A plus the existing Python step make every `--check` a required gate. Re-confirm the contexts with a read-only `gh api repos/drmoisan/drm-copilot/rulesets/15241672` call at execution time (UNVERIFIED for this session).

Brief maintenance: option A changes no stated fact. Adding the new generator check to the brief's `## Contract Tests That Pin Mirrored Files` list is advisable, because executors consult that list after editing mirrored files; if the plan adds that line, it must update all six byte-identical copies in the same change (`.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md` and their three bundle copies). After child 3, the `.claude` copy becomes a generated mirror of the `.agents` copy, so the brief's maintenance paragraph should also say which copy is the source. All six copies are in the parallel run's blast radius; edit only after that run merges.

---

## 6. Language Classification

Owner rule (verbatim): "Avoid new Python (existing Python is tolerated: reuse, call or extend in place only). The language depends on where the new code runs: (1) anything pushed down to destination repos, meaning skills, skill helpers, hooks and libs, must be PowerShell or bash, never TypeScript and never Python; (2) TypeScript is ONLY for MCP commands (tools in the MCP server package) and extension commands." Owner exception E2: a language-native analyzer is allowed when it analyzes that same language and ships only with that language's pack; PowerShell remains the baseline.

Reasoning that applies to every generator: a repository-internal generator CLI is neither an MCP tool nor an extension command, so TypeScript is excluded by clause (2); new Python is excluded by the first sentence; PowerShell is the baseline. If child 4 pushes generators down, or if a skill instructs the agent to run one, clause (1) also requires PowerShell or bash. The classification is PowerShell under every reading, so only the folder depends on OQ-1.

| Artifact | Runs where | Classification | Notes |
| --- | --- | --- | --- |
| Common generation module (enumerate, render, compare, write, drift report) | repository; possibly destinations (OQ-1) | PowerShell module | file I/O through injected script blocks |
| Skill-mirror generator and its `-Check` | same | PowerShell | copies `.agents/skills/<name>` to `.claude/skills/<name>` and the bundle, applies Claude frontmatter, excludes `agents/openai.yaml` |
| Rules generator and its `-Check` | same | PowerShell | renders `paths:` list and `applyTo:` string as text; no YAML parser needed if the source frontmatter is JSON or a fixed simple form |
| MCP-config generator and its `-Check` | same | PowerShell | reads a JSON source with `ConvertFrom-Json`; writes `.mcp.json`; replaces only the `[mcp_servers.*]` region of `.codex/config.toml` by an anchored line scan; must keep the single-line `args` shape that `Set-CodexMcpVersionPin` matches |
| Agent generator and its `-Check` | same | PowerShell | renders Claude YAML frontmatter and Codex TOML as text from a JSON source; reads C3 values from `config/orchestration-routing.json` |
| Codex variant generation | repository CI | existing Python, reused unchanged | `generate_codex_agent_variants.py` (no edit) |
| `CLAUDE.md` import check | repository CI | PowerShell (part of the repository gate) | asserts `CLAUDE.md` starts with `@AGENTS.md` and contains no copy of shared text |
| Entry script (`Invoke-HarnessGeneration.ps1 -Surface <name> [-Check]`) | repository; possibly destinations | PowerShell | thin wiring only |
| CI step | GitHub Actions | none new (Pester repository gate in existing shards) | section 5 option A |
| Tests | CI | Pester | unit tests plus one repository gate |
| Source data (rule sources, MCP list, agent definitions) | data | JSON and Markdown | not code |
| MCP wrapper over a generator | MCP server | TypeScript, only if requested | not in child 3 scope; child 4 decides whether the push-down pipeline needs one |

TOML in PowerShell: not available without a new dependency (section 3). The recommended approach writes TOML as text and never parses general TOML: the MCP generator owns a delimited region, and the agent generator owns whole files. No case found that cannot follow the rule.

E2 exception: not applicable; no generator is a language-native analyzer.

---

## 7. Sequencing Risk and the Phase 0 Gate

Dependencies on outputs that do not exist on this tree (verified absent: no `config/harness-parity-matrix.json`, no `development_docs_root` anywhere outside `docs/`, no child 1 or child 2 active feature folder):

| Child 3 surface | Depends on | What is missing |
| --- | --- | --- |
| Skill mirror (which names) | child 1 matrix: `codex:skill:<name>` `shared` and `claude:skill:<name>` `generated` with `owner_child` 3; approval artifact | the matrix, approvals of single-ecosystem dispositions (child 1 Q3) |
| Skill bodies (neutral text, ported positives) | child 1 survey records and `survey/difference-approval.md` (`Approval-Status` approved); Q4 (porting in child 3) | classifications and approvals |
| Skill frontmatter | child 1 E2 result (Codex tolerance of Claude-only keys) | owner-run result |
| Contract linking | child 1 Q2 | owner answer |
| Rules | child 1 matrix entries `path-scoped-rule` `generated`; content decision (OQ-2, OQ-3) | no content survey of rules in child 1 |
| MCP | child 1 matrix `mcp-server` `generated` | matrix only |
| Agents | child 1 matrix `agent` dispositions (child 1 default: all `claude:agent:*` and base `codex:agent:*` `generated`, owner child 3); child 2 D-16 | the matrix; the D-16 literal form, key and coverage test |
| Matrix upkeep | child 1 schema `generated_from` (`pending-source:<kind>` placeholder) and `generator` fields | child 3 fills them when sources exist |

Child 1 states that children 3 to 6 consume the matrix location and schema (`config/harness-parity-matrix.json`, `config/harness-parity-matrix.schema.json`, Draft 2020-12, `schema_version` 1.0.0, `features` sorted by `id`), the contract format (`.agents/skills/<name>/references/standard.md`), the survey records and the approval artifact (child 1 spec, `## Interface Contracts`). The `id` grammar (`<ecosystem>:<kind>:<name>`) is an open child 1 preflight defect and may change; child 3 should select matrix entries by the `ecosystem`, `kind` and `name` fields, not by parsing `id`.

Child 2 (`#1016` Phase 1, design D-16): "Agent and hook write scopes use a generated or checked literal, with a coverage test." The literal form, the PowerShell resolver name, and the coverage test name do not exist yet. The agent generator can satisfy D-16 by the "generated" branch: resolve `development_docs_root` with child 2's PowerShell resolver at generation time and render each docs-root write scope from it, so the checked literal always equals the configured root; child 2's coverage test then passes by construction. Hook write scopes are not generated by child 3 (hooks stay native; child 5).

Proposed Phase 0 gate (execution time; all checks recorded in `<FEATURE>/evidence/baseline/phase0-gate.<timestamp>.md`):

1. Parallel run: every item of `bugs-1001-1002-1003-1006` (1001, 1002, 1003, 1006, 1009, 1010, 1011, 1012, 1013) is merged to `main` (`gh`; item 1009 appears merged per the recent commit list, the others are UNVERIFIED).
2. Child 1 merged: the matrix and schema exist; `schema_version` major is 1; entries exist for kinds `skill`, `agent`, `path-scoped-rule`, `mcp-server`, `instructions` with the dispositions the plan assumes; `survey/difference-approval.md` has `Approval-Status` `approved` or `approved-with-overrides`; the E2 result (or an owner deferral) and answers to Q2 and Q4 are recorded; contracts exist for the shared set.
3. Child 2 merged: the `development_docs_root` key, the PowerShell resolver (file and function name), the D-16 literal form and coverage test exist as the plan names them.
4. Edit-set re-check: every file, symbol and heading the plan names (including `generate_codex_agent_variants.py` `--check` and `render_base_alias` behavior, `Set-CodexMcpVersionPin`'s pattern, `PINNED_FROZEN_SURFACE_HASHES`, both `pack-manifests/core.json`, the six brief copies, `test_claude_rules_frontmatter.py` constants) is compared against the merge base of `origin/main` and `HEAD`.

Stop condition: any check fails, or any child 1 disposition or child 2 interface differs from the plan's assumption, stops execution for one plan revision (owner decision E3); the gate does not proceed on partial matches.

---

## 8. Scope Sizing and Phase Breakdown

Hand-written production code (PowerShell): about six to eight files: a common module, four surface modules (skills, rules, MCP, agents), an entry script, and possibly an instructions-check module or a split of the agent module for size. Each exceeds the direct-mode batch budget of three, so execution needs the `large` route.

Other hand-edited files: `quality-tiers.yml` (if a new folder), `AGENTS.md`, `CLAUDE.md`, the rule sources (up to about 36 rule bodies to reconcile), the MCP source (one JSON file), agent sources (21 overlapping agents at minimum; up to 75 if every base agent is generated per child 1's default), the 55 shared `.agents/skills/*/SKILL.md` (superset frontmatter and ported positives), `config/harness-parity-matrix.json` (`generated_from`, `generator`), `parallel_orchestrator_surface_expectations.py` (re-baseline), possibly the six brief copies, and Pester tests (about six unit suites plus one repository gate). Generated outputs number in the hundreds (mirrors plus bundle copies) but are produced by the generators.

This does not fit one plan within 40 tasks and 400 lines. The content work (55 skill bodies, rule bodies, agent bodies) dominates and is independent of the generator code. Proposed breakdown, each its own plan file in the same feature (the plan A / plan B precedent in child 1), executed in order:

| Plan | Phases | Approximate size |
| --- | --- | --- |
| 1. Framework, MCP and instructions | Phase 0 gate; common module and entry script with tests; MCP source and generator; `AGENTS.md` rewritten as source, `CLAUDE.md` as `@AGENTS.md` plus Claude-only text, import check; repository gate; `quality-tiers.yml` entry; matrix updates for `mcp-server` and `instructions` | within 40 tasks |
| 2. Skill mirror | generator and tests; per-tool frontmatter source; content reconciliation in child 1's batches A to F (one task per batch, bundle copies paired); first generation; `PINNED_FROZEN_SURFACE_HASHES` re-baseline; matrix updates | likely needs a size justification because of six content batches |
| 3. Rules | source format and generator (two or three targets per OQ-2); per-target substitution for pinned fragments; content consolidation per OQ-3; tests | within 40 tasks if OQ-3 is decided |
| 4. Agents | source format; generator for Claude Markdown and Codex TOML; D-16 rendering; chain with the Python variant generator; tests; matrix updates | within 40 tasks for the 21 overlapping agents; more if single-ecosystem agents are generated (OQ-5) |

Alternative: split child 3 into four child issues. Recommended: keep one feature (the epic manifest has one child 3) with four sequential plans, unless the owner prefers separate issues (OQ-8).

---

## Recommended Approach

- One PowerShell generation library with four surface modules and one entry script (`-Surface skills|rules|mcp|agents|all`, `-Check`). Pure render functions take source content and return the expected file map (repository path to text, including bundle paths); a single comparer reports each differing or missing target path and exits non-zero in check mode; the writer is the only I/O and is injected.
- Sources: `.agents/skills/<name>/` for shared skills (settled); a JSON-plus-Markdown source per rule and per agent, so PowerShell never parses YAML or TOML (folder location is a child 3 design choice to record in the spec; OQ-1 affects it); one JSON MCP list carrying shared keys plus per-target keys, with the Codex pin derived from `packages/mcp-server/package.json` `version` so that the release script and the generator agree without editing `Invoke-FullRelease.ps1`.
- Per-target differences are explicit data: per-target frontmatter keys, per-target glob lists, and per-target text substitutions for the pinned fragments in section 1.2.
- CI: one Pester repository gate in the existing shards; the Python Codex check unchanged.
- Rejected alternatives: TypeScript generators (excluded by the language rule; also not a required check without new configuration); extending `generate_codex_agent_variants.py` (adds Python); symlinked mirrors (settled non-goal); a new CI job (changes required-context facts).

---

## Behavior Semantics (for the spec)

- Success: in write mode every target equals its rendered form; in check mode no target differs and the exit code is 0.
- Failure: check mode exits non-zero and lists every drifted, missing or extra generated file by repository-relative POSIX path; a malformed source (missing frontmatter, unknown target, glob that would make a non-deliberate rule unconditional) fails with the source path named, before any write.
- Ordering: skills before agents (agents preload skills, checked by `test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file`); the PowerShell agent generator before the Python variant generator.
- Edge cases: tool-only skills (not in the matrix shared set) are neither written nor deleted; Codex-only supporting files are not mirrored; an extra file in a generated `.claude/skills/<name>/` folder that has no source is reported; LF and UTF-8 without BOM are enforced; symlinks are never created (the generator writes files and a check fails on a reparse point).

---

## Testing Implications

- Unit (Pester) per module with injected listing, reading and writing script blocks and in-memory content; no temporary files: with-drift and without-drift cases per generator, tool-only exclusion, `openai.yaml` exclusion, frontmatter rendering per target, `applyTo` versus `paths:` rendering, the four-unconditional-rules guard, MCP region replacement that leaves `[permissions.*]`, `[features]`, `[agents]` and `[[hooks.*]]` byte-identical, the release-script `args` shape, Codex base alias form, D-16 literal rendering for `docs/features` and `.dev`, and malformed-source failures.
- Repository gate: every generator in check mode against the committed tree.
- Existing Python and Pester contract tests in section 4 run unchanged (run, not edited, except the hash re-baseline).
- Coverage: each new PowerShell module at or above 85% line from `artifacts/pester/powershell-coverage.xml`; no branch gate for PowerShell.
- Isolation: three seeded shuffled file-order Pester runs of the new suites and one fresh single-process run over `tests/scripts`.

---

## Pre-Mortem

- Review checklists: a reviewer can find generated files edited by hand, or a matrix entry still holding `pending-source:<kind>` after its source exists. Mitigation: the plan's final QA task runs every check mode and a matrix scan for `pending-source:` entries owned by child 3, and records both in `<FEATURE>/evidence/qa-gates/`.
- Coverage: new PowerShell modules can fall below 85% line coverage if render logic is exercised only by the repository gate. Mitigation: unit suites per module with in-memory inputs, and a per-file coverage read from `artifacts/pester/powershell-coverage.xml` recorded in `<FEATURE>/evidence/qa-gates/`.
- Mirror parity: generated `.claude`, `.agents`, `.codex` and `.github` files without bundle copies fail `test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py`; new bundled files fail the pack-manifest completeness tests; the first write of `epic-orchestrator.md` or `epic-orchestrate/SKILL.md` fails `PINNED_FROZEN_SURFACE_HASHES`; any brief edit must reach all six copies. Mitigation: generators write bundle copies; a task re-baselines the pinned hashes; a named brief-update task covers all six copies if the brief changes; all section 4 tests run after each generation.
- File size: an agent or skill module that renders many formats can pass 500 lines; a generated Codex TOML is not Markdown and is subject to the 800-line hard limit. Mitigation: one module per surface, measured with `@(Get-Content -LiteralPath <path>).Count`; the largest generated TOML is measured in the Phase 0 baseline.
- Test isolation: suites that import the generator modules or set script-scope state can leak across shards. Mitigation: injected script blocks, `Remove-Module` in `AfterAll`, no temporary files, and the four isolation runs in the brief.
- CI-only behavior: CRLF writes on Windows produce text that differs from the LF checkout in CI; drive-letter paths fail on case-sensitive Linux if any suite lands under `tests/scripts/claude-hooks` or `tests/scripts/codex-hooks`; a gate that diffs against `origin/main` fails on a depth-one checkout. Mitigation: LF and UTF-8 without BOM, forward-slash relative paths with `Join-Path`, and a repository gate that reads only the working tree.
- Evidence: evidence written outside `<FEATURE>/evidence/<kind>/`, or without `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`, or with an absolute path, fails review. Mitigation: plan tasks name `<FEATURE>/evidence/<kind>/<name>.<timestamp>.md`, record scratch locations as `SCRATCH`, and take counts from files rather than from PoshQC MCP summaries.

---

## Automation Feasibility

| Step | Needs a human? | Notes |
| --- | --- | --- |
| Generators, check modes, repository gate, unit tests | no | fully automatable PowerShell and Pester |
| Python variant generator write and check | no | existing CLI through Poetry |
| Content reconciliation of skill, rule and agent bodies | no, given approvals | mechanical application of child 1's approved classifications; an agent can do it |
| Child 1 approvals, E2 result, Q2 and Q4 answers | yes, but owned by child 1 | consumed at the Phase 0 gate; child 3 adds no owner stop for them |
| Owner Questions OQ-1 to OQ-8 below | yes, before planning or at preflight | design decisions outside the settled design |
| Ruleset re-confirmation and parallel-run merge status | no (orchestrator `gh` calls) | read-only |

Child 3 execution itself needs no human step once the owner questions are answered and child 1's approvals exist.

---

## Owner Questions

Each carries a recommended default for planning.

- **OQ-1 Generator location and push-down.** Are the generators pushed down to destination repositories (child 4), and does any skill instruct the agent to run them? If yes, they belong in a published folder (`.claude/lib/<name>/` is published by the Claude push-down per `PUBLISHED_ROOT_FOLDERS`; there is no shared-layer folder for Codex-only destinations yet). Default: repository-internal under a new `scripts/harness-generation/` folder (T4 entry in `quality-tiers.yml`), PowerShell either way; child 4 decides distribution.
- **OQ-2 Codex rule-skills as a third rules target.** Codex has no path-scoped rules, and 15 Codex-only skills restate the rules and already drift (`.agents/skills/python/SKILL.md` states 90% coverage). Should the rules generator also emit `.agents/skills/<rule>/SKILL.md`? Default: yes, with per-target substitutions for the pinned precedence fragments.
- **OQ-3 Rule source content.** The Claude rules are summaries and merge code-change and unit-test policy per language; the Copilot instructions are full text and named canonical in `CLAUDE.md`. Which body becomes the single source, and is the per-language split kept? Child 1 does not survey rule content. Default: one source per current Claude rule (the maintained, test-pinned form); Copilot instruction files generated from it with the same split as Claude; the current Copilot full text reviewed for positives in plan 3.
- **OQ-4 MCP pin.** `.mcp.json` is unpinned and `.codex/config.toml` is pinned to the published MCP version. Keep the difference? Default: keep it as explicit per-target data; derive the Codex pin from `packages/mcp-server/package.json`.
- **OQ-5 Agent scope.** Child 1's default marks every Claude agent and every base Codex agent `generated` by child 3, but child 1 does not survey agent bodies, and the 21 overlapping agents have different bodies. Who classifies agent body differences, and are the 4 Claude-only and 29 Codex-only agents generated or `native`? Default: the 21 overlapping agents are reconciled in plan 4 under the same positive/negative/neutral/mechanism-only rules; single-ecosystem agents are `native` (a child 1 disposition override).
- **OQ-6 Competing `AGENTS.md` writers.** `scripts/dev-tools/sync-agents-from-instructions.ps1` (also an extension command and a VS Code task) and the Codex native converter both overwrite `AGENTS.md`. Once `AGENTS.md` is the source, retire them, redirect them, or guard them? Default: child 3 makes `AGENTS.md` the source and adds a check that fails if `AGENTS.md` carries a generated-file header; retirement of the sync command is assigned to child 6.
- **OQ-7 Coverage-threshold statements.** The feature-review coverage hooks read only the root `CLAUDE.md` text and do not follow `@AGENTS.md`. Default: any repository threshold statement stays in the Claude-only part of `CLAUDE.md`; child 5 decides whether hooks also read `AGENTS.md`.
- **OQ-8 Delivery shape.** One feature with four sequential plans, or four child issues? Default: one feature, four plans (section 8).

Conditional stop (not a new question): if child 1's E2 result shows that Codex rejects Claude-only frontmatter keys, the settled "superset frontmatter" cannot be used as written, and the plan stops for an owner decision on a per-tool frontmatter file instead.

---

## Numeric Derivation Evidence

No numeric count, enumeration or population is proposed for a `spec.md` acceptance criterion in this research. The counts in sections 1 and 8 are planning context only. Any acceptance criterion should be stated against the set produced by enumerating the trees and the parity matrix at execution time.

---

## UNVERIFIED Items for the Orchestrator

- The file-name timestamp of this artifact (no clock tool).
- Merge status of each parallel-run item (1009 appears merged; 1001, 1002, 1003, 1006, 1010, 1011, 1012, 1013 not confirmed) and of children 1 and 2.
- Byte identity of the 55 shared skills (needs `git hash-object`; child 1 produces it).
- The epic record's "about 98 unique" Codex agents versus 50 base files observed.
- Whether `extensions/drm-copilot/resources/claude-dir-customizations/.mcp.json` is consumed by any build or packaging step.
- Required contexts of ruleset 15241672 at execution time.
- Child 1 `scripts/harness/` versus `quality-tiers.yml` rule R3/QT008 (child 1 preflight item).
- Whether the PowerShell version on `windows-latest` matters for any generator feature (none planned depends on 7.4).
