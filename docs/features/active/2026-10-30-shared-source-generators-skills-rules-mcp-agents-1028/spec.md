# 2026-10-30-shared-source-generators-skills-rules-mcp-agents — Spec

- **Issue:** #1028
- **Parent (optional):** epic #1018 (shared agent-harness layer across Claude Code, Codex and GitHub Copilot), child 3
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14
- **Status:** Draft
- **Version:** 0.4 (planning refresh 2026-11-14: autonomous-mode decisions D-1 to D-7, PQ-2 update)
- **Work Mode:** full-feature
- **Primary research input:** `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/research/research.2026-10-30T22-46.md`
- **Epic manifest:** `docs/features/epics/shared-agent-harness-layer/epic.md`
- **Confirmed design (not re-opened):** `docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md`
- **Upstream child 1 (#1025) spec:** feature `2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025`, `spec.md` (planned on the integration branch; its outputs are not yet delivered)
- **Upstream child 2 (#1035) spec:** feature `2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035`, `spec.md` (planned on the integration branch; its outputs are not yet delivered)

In this document `<FEATURE>` means `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028`. All paths are repository-relative POSIX paths.

## Overview

Shared skills, path-scoped rules, MCP servers, agents and top-level instructions are authored separately for each ecosystem (Claude Code, Codex, GitHub Copilot). The copies drift, and no check reports the drift. Epic #1018 settles one source per surface with generated native outputs. This child delivers PowerShell generators for the shared skill mirror, path-scoped rules, MCP server configuration and agents, each with a check mode that reports drift and exits non-zero on drift; makes `AGENTS.md` the instruction source with `CLAUDE.md` importing it; redirects the Codex native converter so it no longer writes `AGENTS.md` independently of the generators (owner decision H3); and wires every check mode into the existing required PowerShell CI check. The settled design is not re-opened here.

Inventory figures in the research record (skill, rule and agent counts) are planning context only. No acceptance criterion below asserts a count; each criterion is stated against the set produced by enumerating the trees and the parity matrix at execution time. The research record states in `## Numeric Derivation Evidence` that it proposes no numeric acceptance threshold.

## Owner Decisions

Each row carries the default that planning and execution use. A row has one of three statuses: `pending-owner-confirmation`; `decided by owner (<decision>, <date>)`, in which case the Default cell holds the owner's recorded answer; or `decided by coordinator under owner standing instruction (...)`, which the Phase 0 gate handles in the same way as `decided by owner`. OQ-6 is decided by the owner (H3, 2026-10-31). PQ-2 is decided by the coordinator under the owner's standing instruction (autonomous mode, 2026-11-14).

Autonomous mode (decision D-1, decided by coordinator under owner standing instruction (autonomous mode, 2026-11-14)): the run executes under the owner's standing autonomous-mode instruction, so the recorded default of every row that is still `pending-owner-confirmation` is the decision for this child. Rationale: the owner's standing instruction is to decide and continue rather than stop for owner input; each default was re-checked against the tree on 2026-11-14 and none is contradicted by it. The Phase 0 gate (see `## Behavior`) therefore does not stop on a `pending-owner-confirmation` row: it passes every row whose recorded default (or recorded decision) the plan follows, and it stops only when an owner answer recorded in this table differs from the row's default or when the plan departs from a row.

| ID | Question | Default | Status |
| --- | --- | --- | --- |
| OQ-1 | Are the generators pushed down to destination repositories (child 4), and does any skill instruct an agent to run them? A pushed-down or skill-invoked generator must live in a published folder. | Repository-internal under a new `scripts/harness-generation/` folder with a T4 entry in `quality-tiers.yml`; no skill text instructs an agent to run a generator; PowerShell under either answer; child 4 decides distribution. | pending-owner-confirmation |
| OQ-2 | Codex has no path-scoped rules, and Codex-only skills under `.agents/skills` restate rule content and already drift (`.agents/skills/python/SKILL.md` `## Toolchain` states a different coverage threshold from `.claude/rules/python.md`). Should the rules generator also emit the Codex rule-skills (`.agents/skills/<rule>/SKILL.md`) as a third target? | Yes, with per-target substitutions for the pinned precedence fragments checked by `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`. | pending-owner-confirmation |
| OQ-3 | Which body becomes the single rule source: the Claude rules (summaries, merged per language) or the Copilot instructions (full text, split into code-change and unit-test files, and named "the canonical policy source" with "Do not modify them" in `CLAUDE.md` `## Policy Compliance Reading Order`)? Is the per-language split kept? | One source per current Claude rule; Copilot instruction files generated from it with the Claude split; the current Copilot full text reviewed for positives during the rules phase; the `CLAUDE.md` "canonical policy source" statement and the reading-order file names are rewritten in the same change as the instructions work. | pending-owner-confirmation |
| OQ-4 | `.mcp.json` runs the MCP package unpinned; `.codex/config.toml` pins it to the published version. Keep the difference? | Keep it as explicit per-target data; derive the Codex pin from `packages/mcp-server/package.json` `version`, so `Set-CodexMcpVersionPin` in `scripts/dev-tools/Invoke-FullRelease.ps1` and the generator agree without editing the release script. | pending-owner-confirmation |
| OQ-5 | Child 1's default marks every Claude agent and every base Codex agent `generated` by child 3, but child 1 does not survey agent bodies, and agents present in both trees have different bodies. Who classifies agent body differences, and are single-ecosystem agents generated or `native`? | Agents present in both `.claude/agents` and `.codex/agents` are reconciled in the agents phase under child 1's positive, negative, neutral and mechanism-only rules; single-ecosystem agents are `native` (a child 1 disposition override recorded in child 1's approval artifact). | pending-owner-confirmation |
| OQ-6 | `scripts/dev-tools/sync-agents-from-instructions.ps1` (also an extension command and a VS Code task) and the Codex native converter (`scripts/dev_tools/codex_native_converter/pipeline.py`, `extensions/drm-copilot/src/lib/codex-native-converter/pipeline-render.ts`) both overwrite `AGENTS.md`. Once `AGENTS.md` is the source, retire, redirect or guard them? | Decided: child 3 makes `AGENTS.md` the source, adds the check that fails when `AGENTS.md` carries either writer's generated header, and redirects the Codex native converter so it no longer writes `AGENTS.md` independently of the generators (see `### Surface: Codex native converter (H3)`); retirement or redirection of `scripts/dev-tools/sync-agents-from-instructions.ps1` stays with child 6 (#1032). | decided by owner (H3, 2026-10-31) |
| OQ-7 | The feature-review coverage hooks (`.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/hooks/validate-feature-review-coverage-metrics.ps1`, `.claude/hooks/feature-review-coverage-thresholds.ps1` and the Codex twins) read only the root `CLAUDE.md` text and do not follow `@AGENTS.md`. Where do repository coverage-threshold statements live? | Any repository threshold statement stays in the Claude-only part of `CLAUDE.md`; `AGENTS.md` carries none; child 5 decides whether the hooks also read `AGENTS.md`. | pending-owner-confirmation |
| OQ-8 | Delivery shape: one feature with several plans, one feature with one plan, or several child issues? | Resolution taken by the orchestrator, subject to owner confirmation: one feature and one plan that carries a `## Size Justification`, phased by surface (Phase 0 gate; framework, MCP config and instructions; skill mirror; rules; agents; CI gate and matrix upkeep; QA). This supersedes the research default of four sequential plans. | pending-owner-confirmation |
| OQ-9 | How does the PowerShell agent generator consume the D-16 write-scope contract? Child 2's spec (`## Write-scope literal contract (D-16)`, `### Interface for epic child 3`) states that child 3's agent generator imports `WRITE_SCOPE_RULES`, `expandWriteScopeLiterals` and related exports from the TypeScript module `extensions/drm-copilot/src/lib/development-docs/write-scopes.ts`. Child 3's generators are PowerShell under the owner language rule and cannot import TypeScript. Child 2's PowerShell module `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` resolves the development-docs root only and carries no write-scope rules, and child 2 defines no checked-in literal list. Neither route satisfies D-16 without duplicating its single source. | The agent source files carry the write-scope literals verbatim; the agent generator passes them through unchanged and does not compute them; child 2's TypeScript three-direction checker remains the sole D-16 assertion over the generated agent files. Alternative: child 2 adds a generated, checked-in JSON literal list emitted from `write-scopes.ts` and verified by its Jest checker, which the PowerShell generator reads. Under either answer child 2's spec text ("Child 3's agent generator imports ...") must be amended by child 2's owner; child 3 does not edit child 2's files. | pending-owner-confirmation |
| PQ-1 | Raised during planning. Read literally, the OQ-3 default ("Copilot files generated with the Claude split") renames the `-code-change` and `-unit-test` instruction files under `.github/instructions/`, whose names are cited by many files outside this child (including `.github/copilot-instructions.md`, `.github/agents/`, templates and converter tests). Are existing Copilot instruction paths renamed? | Keep every existing Copilot instruction path; one rule source per Claude rule emits each Copilot file from a declared list of H2 sections; no instruction file is renamed or deleted. | pending-owner-confirmation |
| PQ-2 | Raised during planning. Several generator targets were inside the blast radius of the parallel run `bugs-1001-1002-1003-1006`, which this child was not to edit. How are those targets handled? | Updated 2026-11-14: that parallel run and item #1013 have merged and their issues are closed, so the reason for the protected-target list (the run's blast radius) no longer exists and the list is retired. Option (a) applies unconditionally: append-only `coverageThreshold` entries are added to `extensions/drm-copilot/jest.config.cjs`, with no existing line removed or changed. The files pinned in `PINNED_FROZEN_SURFACE_HASHES` (`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`) are still rendered byte-equal, so their pinned hashes are not re-baselined; the Phase 0 gate stops if an approved child 1 difference would change a pinned file. | decided by coordinator under owner standing instruction (autonomous mode, 2026-11-14) |

Conditional stop (not an owner question of this child): if child 1's E2 result shows that Codex rejects Claude-only skill frontmatter keys, the settled superset frontmatter in `.agents/skills` cannot be used as written, and the Phase 0 gate stops for an owner decision on a per-tool frontmatter source.

### Planning Refresh Decisions (2026-11-14)

Each decision below is `decided by coordinator under owner standing instruction (autonomous mode, 2026-11-14)`.

| ID | Decision | Rationale |
| --- | --- | --- |
| D-1 | Pending rows take their recorded defaults; the Phase 0 gate does not stop on a `pending-owner-confirmation` row (see the paragraph above). | Owner standing instruction: autonomous mode decides and continues. |
| D-2 | H3 (child 3 redirects the Codex native converter; child 6 #1032 retires `scripts/dev-tools/sync-agents-from-instructions.ps1`) and option (a) for `extensions/drm-copilot/jest.config.cjs` stand. | Re-checked against the tree: the converter still maps standing guidance to `AGENTS.md`, and the three changed converter files `engine-pipeline.ts`, `pipeline.ts` and `validation.ts` still have no per-file `coverageThreshold` entry. |
| D-3 | The generators are not registered with the regeneration framework of #1156 (`.claude/lib/regeneration/`, `config/orchestration-regeneration.json`). The generators are not hooks, so the PreToolUse dispatcher registry of #1159 (`.claude/hooks/pretooluse-dispatch.json`, `.codex/hooks/pretooluse-dispatch.json`) does not apply; this child adds no hook. | The framework reads one repository-wide `regeneration` object (one `command`), and #1156 ships it default-off: `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1` (`does not ship <Path>`) asserts that `config/orchestration-regeneration.json` exists neither in the repository nor in the bundle, and the execution-environment brief states that fact. Registering would turn on the regenerate path for every epic and parallel run in this repository and occupy its single command slot, which leaves the Python Codex variant generator's outputs outside the command. That is an orchestration-policy change outside this child; a later item may register a wrapper command that runs both generators. |
| D-4 | A rule source carries the Claude frontmatter and each Copilot frontmatter as ordered keys with raw value text, and a per-target ordered list of H2 sections drawn from the one source body; a section may be listed for one target only. Every heading and literal that an existing wording suite pins on a generated target is kept. | Refines OQ-3 and PQ-1 without changing them: several Copilot instruction files carry sections that the Claude rule lacks (for example `## 8. After Making Changes` in `general-code-change.instructions.md`, pinned by `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`), and launch-loaded Claude rules carry no `paths:` key (`test_launch_loaded_rules_carry_description_and_no_paths_key`). Rules added since 2026-10-31 (for example `bash-command-shape`) are selected only through the parity matrix. |
| D-5 | The execution-environment brief is updated in all six byte-identical copies to name the repository gate and the generate-from-source rule. | Resolves the conditional in `## Constraints & Risks`: once the gate lands, a hand edit to a generated target fails it, which is a fact about mirrored files that the brief's `## Contract Tests That Pin Mirrored Files` must state. |
| D-6 | The isolation criterion uses the parallel gates (one `Invoke-PoshQCParallelTest`, one `pytest -n auto`, Jest through its normal workers) and `Invoke-PoshQCLeakScan`; no seeded shuffled, reversed or single-process run is required. | Owner standing rule (2026-11-07): tests are parallel-only, and test-order dependence is a violation fixed on both sides, never worked around. |
| D-7 | The CI criterion names the required context `CI Required Gate`. | The ruleset now requires that single context, which aggregates `poshqc / PowerShell QC` and every `quality-checks7` leg. |
| D-8 | A selected generation target that does not exist at `HEAD` stops the Phase 0 gate. | A new target is a new bundled file that needs a pack-manifest entry; distribution belongs to child 4 (OQ-1, child 1 Q1). |
| D-9 | Superseded-work check: no merged work delivers any part of this scope. | No `scripts/harness-generation/` code exists, the converter still writes `AGENTS.md`, and children 1 and 2 have not delivered their outputs. |

## Behavior

### Phase 0 gate (execution-time requirement)

Execution of the plan begins with a gate. The gate is the only stop in this child; an owner stop cannot sit inside the executor plan, so a failing gate ends the executor run and returns control to the orchestrator for a plan revision or an owner decision. The gate proceeds only when every check passes; it does not proceed on partial matches. All results are recorded in `<FEATURE>/evidence/baseline/phase0-gate.<timestamp>.md`.

1. **Owner decisions.** Under D-1, every row passes when the plan follows its recorded default or recorded decision, including a row still marked `pending-owner-confirmation`. An owner answer recorded in the table that differs from the row's default, or a plan that departs from a row, stops execution.
2. **Child 1 merged.** Child 1's outputs are merged into the integration branch `epic/shared-agent-harness-layer-integration`: `config/harness-parity-matrix.json` and `config/harness-parity-matrix.schema.json` exist; `schema_version` has major version 1; entries exist for the kinds `skill`, `agent`, `path-scoped-rule`, `mcp-server` and `instructions` with the dispositions this spec assumes (see `### Matrix Consumption`); child 1's approval artifact has `Approval-Status` `approved` or `approved-with-overrides`; child 1's E2 result or an owner deferral is recorded; child 1's Q2 and Q4 answers are recorded; contracts exist for the shared set.
3. **Child 2 merged.** Child 2's outputs are merged into the integration branch: the `development_docs_root` key, `.claude/lib/development-docs/DevelopmentDocsRoot.psm1`, `extensions/drm-copilot/src/lib/development-docs/write-scopes.ts` and child 2's write-scope checker suite exist; child 2's spec text for `### Interface for epic child 3` matches the OQ-9 answer.
4. **Targets.** No approved child 1 difference would change a file pinned in `PINNED_FROZEN_SURFACE_HASHES`, and every selected generation target exists at `HEAD` (D-8). (The former parallel-run merge check is retired: that run has merged; see PQ-2.)
5. **Edit-set re-check.** Every file, symbol and heading named in this spec and in the plan is compared against the merge base of `origin/main` and `HEAD`. This includes `scripts/dev_tools/generate_codex_agent_variants.py` (`render_base_alias`, `--check`), `GENERATED_AGENT_FAMILIES` in `scripts/dev_tools/resolve_codex_deployment.py`, `Set-CodexMcpVersionPin` in `scripts/dev-tools/Invoke-FullRelease.ps1`, `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, `DELIBERATE_UNCONDITIONAL_RULES` in `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`, both `pack-manifests/core.json` bundle files, the copies of the execution-environment brief, the `poshqc-shard` job in `.github/workflows/_poshqc.yml`, and the Codex native converter symbols named in `### Surface: Codex native converter (H3)`. A moved, renamed or removed item stops execution.
6. **Measurements.** The gate records the largest current `.codex/agents/*.toml` file size in lines, for the file-size risk on generated TOML.

### Generation model (all surfaces)

- One PowerShell entry script, `scripts/harness-generation/Invoke-HarnessGeneration.ps1`, with parameters `-Surface` (`skills`, `rules`, `mcp`, `agents`, `instructions`, `all`) and `-Check`. `instructions` is check-only.
- Pure render functions take source content and return the expected file map (repository-relative POSIX path to text, including bundle copies). One comparer reports each drifted, missing or extra generated path. The writer is the only I/O and is injected; listing and reading are injected script blocks that default to the real file system.
- Write mode: every target equals its rendered form after the run.
- Check mode: no file is written. Exit code 0 when no target differs; non-zero otherwise, with one output line per drifted, missing or extra generated file, named by repository-relative POSIX path.
- Malformed source (missing frontmatter, unknown target, a glob that would make a non-deliberate Claude rule unconditional, an agent source without a required field): the run fails before any write and names the source path.
- Encoding: generated files are written with LF line endings and UTF-8 without BOM, consistent with `.gitattributes` (`* text=auto eol=lf`). Check mode compares exact text, so a CRLF or BOM target is reported as drift.
- No symlinks: generators write regular files; check mode reports a target that is a reparse point or symlink as drift.
- Ordering for `all`: instructions, MCP, skills, rules, agents (agents preload skills, checked by `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`). The PowerShell agent generator runs before the existing Python Codex variant generator.
- Bundle copies: each generator writes the bundle copy under `extensions/drm-copilot/resources/` of every target it writes, so `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` keep passing. Bundle-only variant subtrees (`.claude-variants/`, `.agents-variants/`, `.codex-variants/`) are not generated.

### Matrix Consumption

Child 3 selects parity-matrix entries by the `ecosystem`, `kind`, `disposition` and `owner_child` fields, and never parses the `id` string. Child 1 defines the `id` encoding in its spec section `### Parity Matrix: Identifier Encoding`; child 3 still selects by fields, treats `id` as an opaque string compared ordinally, and, where it cites a specific entry, uses the encoded form defined in that section (for example `codex:skill:orchestrate` or `claude:instructions:CLAUDE.md`). The generated set for each surface is:

| Surface | Matrix entries selected |
| --- | --- |
| Skill mirror | `kind` `skill`, `ecosystem` `claude`, `disposition` `generated`, `owner_child` 3, `generated_from` under `.agents/skills/` |
| Rules | `kind` `path-scoped-rule`, `disposition` `generated`, `owner_child` 3 |
| MCP | `kind` `mcp-server`, `disposition` `generated`, `owner_child` 3 |
| Agents | `kind` `agent`, `disposition` `generated`, `owner_child` 3 (base Claude and base Codex files; Codex variants with `owner_child` null stay with the Python generator) |
| Instructions | `kind` `instructions`: `AGENTS.md` (`shared`) and `CLAUDE.md` (`native`) with `owner_child` 3 |

Matrix upkeep: for each selected entry whose single source now exists, child 3 replaces the `pending-source:<kind>` placeholder in `generated_from` with the source path and fills `generator` with `harness-generation/<surface>`, keeping child 1's ordering and conditional rules; child 1's repository gate must pass after each change.

### Surface: instructions

- `AGENTS.md` becomes a hand-authored source. It carries no `# Converted standing guidance` header (Codex native converter) and no `> NOTE: This file is **generated** from:` line (`scripts/dev-tools/sync-agents-from-instructions.ps1`), and it embeds no copy of any `.claude/rules` file. Every `.agents/skills/<name>/SKILL.md` path it cites exists.
- `CLAUDE.md` keeps its YAML frontmatter; its first line after the frontmatter is `@AGENTS.md`; the rest is Claude-only text. No H2 section body of `CLAUDE.md` (whitespace-normalized) equals an H2 section body of `AGENTS.md`.
- Coverage-threshold statements follow OQ-7.
- The bundle copy `extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md` equals `AGENTS.md`.
- The instructions check is part of the repository gate; there is no instructions generator.

### Surface: Codex native converter (H3)

Today the converter maps every standing-guidance source record to `AGENTS.md` and writes a `# Converted standing guidance` merge there: `planTargetPaths` in `extensions/drm-copilot/src/lib/codex-native-converter/mapping.ts` sets the target path, `renderGeneratedOutput` in `engine-pipeline.ts` renders it, and `renderMergedStandingGuidance` in `pipeline-render.ts` produces the merged body; the Python twins are `plan_target_paths` in `scripts/dev_tools/codex_native_converter/mapping.py`, `_render_generated_output` in `engine.py` and `render_merged_standing_guidance` in `pipeline.py`. The converter is reachable as the MCP tool `run_codex_native_converter` (`extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`), and as the extension command `drmCopilotExtension.runCodexNativeConverter` (`extensions/drm-copilot/src/repo-automation-command-registration-admin.ts`), both of which call the in-process TypeScript port through `runCodexNativeConverter` in `extensions/drm-copilot/src/repo-automation-service.ts`; it is also reachable, and as the Poetry script `codex-native-converter` (`pyproject.toml`, documented in `README.md` `## Codex-native converter`).

Observable behavior after this child:

- When the converter runs in review or apply mode against a source set that contains standing-guidance sources, its generated output contains no `AGENTS.md` target and no `# Converted standing guidance` text; in apply mode it neither creates nor modifies a destination `AGENTS.md`.
- The converter report records each standing-guidance source as not emitted, with a reason stating that `AGENTS.md` is a hand-authored source maintained outside the converter. Reference rewrites that point other outputs at `AGENTS.md` are unchanged.
- Non-standing-guidance mappings (skills, agents, prompts, MCP, hooks) are unchanged.
- Parity: the Python package remains an active entry point (the `codex-native-converter` Poetry script in `pyproject.toml` and the `README.md` section), so the TypeScript port and the Python package change together and produce the same mapping, output and report disposition for the same input.
- The existing converter tests that assert the current `AGENTS.md` output change disposition; the plan names each one individually. Candidate files (each contains an `AGENTS.md` or `# Converted standing guidance` assertion on this branch) are the Jest suites under `extensions/drm-copilot/test/lib/codex-native-converter/` and the pytest suites under `tests/scripts/dev_tools/codex_native_converter/`.
- The `README.md` statement that repository-wide instruction files are merged into the generated `AGENTS.md` is updated in the same change. The mechanism (report-only disposition, target-role change or other) is left to the plan.
- No new MCP tool or extension command is added; the existing tool and command keep their names and inputs.

### Surface: MCP server configuration

- Source: `scripts/harness-generation/sources/mcp-servers.json`, carrying shared keys plus per-target keys (Codex-only `required`, `enabled_tools`, `default_tools_approval_mode` and per-tool approval tables).
- Outputs: the whole of `.mcp.json`; only the `[mcp_servers.*]` region of `.codex/config.toml`, located by an anchored line scan. Bytes outside that region (`default_permissions`, `[permissions.*]`, `[features]`, `[agents]`, `[[hooks.*]]`) are unchanged. Bundle copies: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` and `extensions/drm-copilot/resources/claude-dir-customizations/.mcp.json`.
- The Codex `args` line keeps the single-line `args = ["-y", "@danmoisan/drm-copilot-mcp@<version>"]` shape that `Set-CodexMcpVersionPin` matches; `<version>` follows OQ-4.
- PowerShell never parses general TOML; the generator owns a delimited region and writes it as text.

### Surface: skill mirror

- Source: `.agents/skills/<name>/` (settled). Target: `.claude/skills/<name>/` and its bundle copy under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/<name>/`.
- Frontmatter: the superset frontmatter in the source (settled design), subject to the child 1 E2 conditional stop. Per-target body differences are expressed as a declared per-target substitution list in source data; otherwise the mirror copies bytes.
- Excluded: Codex metadata `agents/openai.yaml`; skills with no selected matrix entry (tool-only skills), which are neither written nor deleted.
- An extra file in a generated `.claude/skills/<name>/` folder with no source counterpart is reported as drift.
- Content: approved positive differences from child 1's approval artifact are ported into the shared bodies (child 1 Q4); contract linking follows child 1 Q2.
- `.claude/skills/epic-orchestrate/SKILL.md` is pinned in `PINNED_FROZEN_SURFACE_HASHES` (PQ-2): the skill mirror renders it byte-equal to its post-merge content, so its pinned hash does not change and `PINNED_FROZEN_SURFACE_HASHES` is not re-baselined.

### Surface: path-scoped rules

- Source: one JSON-plus-Markdown pair per rule under `scripts/harness-generation/sources/rules/`, carrying per-target glob lists and per-target text substitutions, so PowerShell parses no YAML.
- Outputs: `.claude/rules/<name>.md` with a `paths:` YAML list; `.github/instructions/<name>.instructions.md` with an `applyTo:` string; under OQ-2's default, the Codex rule-skills `.agents/skills/<rule>/SKILL.md`; and the bundle copy of each.
- The Claude output preserves the deliberate unconditional set asserted by `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` (`DELIBERATE_UNCONDITIONAL_RULES`); a source whose Claude glob list would make another rule unconditional is rejected.
- Per-target precedence fragments pinned by `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` (`CLAUDE_PRECEDENCE_FRAGMENTS`, `CODEX_PRECEDENCE_FRAGMENTS`) are produced by per-target substitution.
- Generation repairs `.github/instructions/general-unit-test.instructions.md`, whose first line is currently `applyTo: "**"` with no opening `---`.

### Surface: agents

- Source: one JSON-plus-Markdown pair per logical agent under `scripts/harness-generation/sources/agents/`, carrying shared fields, per-target fields (Claude `tools`, `skills`, `memory`, `hooks`, `model`; Codex TOML keys) and the body.
- Outputs: `.claude/agents/<name>.md` (YAML frontmatter rendered as text) and base `.codex/agents/<name>.toml` (TOML rendered as text), with bundle copies.
- Codex variant families: for families the source marks as variant families (the set in `GENERATED_AGENT_FAMILIES`), the base is emitted in the alias form that `render_base_alias` produces, using the C3 values from `config/orchestration-routing.json` `codex_model_policy`. The existing Python generator then writes the variants unchanged (research section 2, option A); its `--check` remains the authority on alias form.
- `hooks:` frontmatter is reproduced exactly, so `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` passes.
- Write scopes (D-16): under OQ-9's default, the `Write(`/`Edit(` literals in the source are passed through unchanged, including each agent's existing leading-slash spelling; the generator computes no literal. Child 2's spec states that the base Codex files of `atomic-planner`, `prd-feature`, `feature-review`, `status-updater` and `epic-review` carry these literals as text; a search of `.codex/agents` on this branch confirms `Write(` text in Codex agent files. (Research section 1.4 states that Codex agents carry no write scopes; that statement does not match the tree.) Research section 7 proposed rendering docs-root scopes from child 2's PowerShell resolver; OQ-9 supersedes that proposal because the resolver carries no write-scope rules.
- `.claude/agents/epic-orchestrator.md` is pinned in `PINNED_FROZEN_SURFACE_HASHES` (PQ-2): the agent generator renders it byte-equal to its post-merge content, so, as for the skill mirror, `PINNED_FROZEN_SURFACE_HASHES` is not re-baselined.

### Edge cases

- A tool-only skill folder is untouched in write and check mode.
- A target missing from disk is reported as missing in check mode and created in write mode.
- A generated folder or file with no source is reported as extra; write mode does not delete files outside the selected set.
- A generated Codex TOML is subject to the 800-line hard limit (Markdown outputs are exempt).

## Inputs / Outputs

- Inputs: `.agents/skills/**` (skill source); `scripts/harness-generation/sources/**` (rule, agent and MCP sources); `config/harness-parity-matrix.json` (child 1); `config/orchestration-routing.json` (`codex_model_policy`); `packages/mcp-server/package.json` (`version`); `AGENTS.md`, `CLAUDE.md`.
- Outputs: `.claude/skills/<name>/**`, `.claude/rules/*.md`, `.github/instructions/*.instructions.md`, Codex rule-skills (OQ-2), `.mcp.json`, the `[mcp_servers.*]` region of `.codex/config.toml`, `.claude/agents/*.md`, base `.codex/agents/*.toml`, and the bundle copy of each under `extensions/drm-copilot/resources/`; updated `generated_from` and `generator` fields in `config/harness-parity-matrix.json`; edited Codex native converter sources and tests (H3), whose run output no longer includes `AGENTS.md`.
- Logs: check mode writes one line per drifted path to standard output and a summary line; the repository gate's failure message lists every drifted path.
- Config keys: none added to existing configuration files.
- Compatibility: generated files keep the paths and frontmatter keys their consumers read today; the Python Codex variant generator and its CI step are unchanged.

## API / CLI Surface

```text
pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface all
pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface skills -Check
```

- Write mode prints each written path and exits 0, or names the malformed source and exits non-zero before any write.
- Check mode prints `DRIFT: <path>` (or `MISSING: <path>` / `EXTRA: <path>`) per finding and exits 1 when any finding exists; it prints a no-drift summary and exits 0 otherwise.
- Developer sequence for agents: run the entry script with `-Surface agents`, then `poetry run python -m scripts.dev_tools.generate_codex_agent_variants`; CI runs both check modes independently.
- No MCP tool and no extension command is added (see `## Language Classification`). The existing `run_codex_native_converter` MCP tool and `drmCopilotExtension.runCodexNativeConverter` extension command keep their names and inputs; only their standing-guidance output changes (see `### Surface: Codex native converter (H3)`).

## Data & State

- Invariants: every selected target equals its rendered form; generated files are LF and UTF-8 without BOM; no generated target is a symlink; bytes of `.codex/config.toml` outside the MCP region are not changed by the MCP generator.
- Persistence: sources and outputs are committed files; no runtime state or cache.
- Migration: the first write-mode run converts hand-maintained copies to generated outputs; the plan reconciles source content before that run so the resulting diff is reviewed per surface.

## Language Classification

Owner rule (verbatim): "Avoid new Python (existing Python is tolerated: reuse, call or extend in place only). The language depends on where the new code runs: (1) anything pushed down to destination repos, meaning skills, skill helpers, hooks and libs, must be PowerShell or bash, never TypeScript and never Python; (2) TypeScript is ONLY for MCP commands (tools in the MCP server package) and extension commands." Owner exception E2: a language-native analyzer is allowed when it analyzes that same language and ships only with that language's pack; PowerShell remains the baseline.

A repository-internal generator is neither an MCP tool nor an extension command, so clause (2) excludes TypeScript; the first sentence excludes new Python; PowerShell is the baseline. If OQ-1 is answered so that generators are pushed down or skill-invoked, clause (1) also requires PowerShell or bash, so the language is PowerShell under either answer. E2 does not apply: no artifact is a language-native analyzer.

| Artifact | Runs where | Rule clause applied | Language |
| --- | --- | --- | --- |
| Common generation module (`scripts/harness-generation/HarnessGeneration.psm1`: enumerate, render map, compare, inject writer, drift report) | Repository: developer machine and CI; destinations only if OQ-1 changes | No-new-Python sentence; clause (2) excludes TypeScript; clause (1) if pushed down | PowerShell |
| Skill-mirror generator (`HarnessSkillMirror.psm1`) | Repository (OQ-1) | Same as above | PowerShell |
| Rules generator (`HarnessRuleGeneration.psm1`) | Repository (OQ-1) | Same as above | PowerShell |
| MCP-config generator (`HarnessMcpConfig.psm1`) | Repository (OQ-1) | Same as above | PowerShell |
| Agents generator (`HarnessAgentGeneration.psm1`) | Repository (OQ-1) | Same as above | PowerShell |
| Instructions / `AGENTS.md` and `CLAUDE.md` check (`HarnessInstructions.psm1`) | Repository and CI | Same as above | PowerShell |
| Entry script (`Invoke-HarnessGeneration.ps1`) | Repository (OQ-1) | Same as above | PowerShell |
| Each `-Check` mode (skills, rules, MCP, agents, instructions) | Repository and CI | Same module as its generator; same clauses | PowerShell |
| Pester repository gate (`tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1`) and unit suites | CI, inside the existing `poshqc / PowerShell QC` shards | Test code for PowerShell modules; no new Python | PowerShell (Pester) |
| Parity-matrix checks used by child 3 (matrix upkeep assertion that no selected entry with an existing source keeps `pending-source:`) | CI, inside the repository gate | Same as above; reads JSON with `ConvertFrom-Json`; child 1's PowerShell modules are reused, not duplicated | PowerShell |
| Survey tooling | None in child 3 (child 1 owns the survey); any session helper is PowerShell in the session scratch location and is not committed | No-new-Python sentence | PowerShell (uncommitted) or none |
| Codex agent-variant generation (`scripts/dev_tools/generate_codex_agent_variants.py`) | Repository and CI (`Verify Codex agent deployment profiles` in `.github/workflows/_quality-checks.yml`) | "Existing Python is tolerated: reuse, call": reused unchanged, called by its own CLI, not edited, not invoked from PowerShell | Existing Python (unchanged) |
| `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | CI | Not changed: both pinned files render byte-equal (PQ-2); no Python file is added | Existing Python (unchanged) |
| D-16 write-scope literal handling in the agent generator | Repository and CI | PowerShell cannot import child 2's TypeScript source; raised as OQ-9, not decided here | PowerShell pass-through (OQ-9 default); child 2's TypeScript checker remains the assertion |
| Source data (`scripts/harness-generation/sources/**`, `.agents/skills/**`) | Data | Not code | JSON and Markdown |
| MCP wrapper over a generator | MCP server package | Clause (2) | Not in child 3 scope; TypeScript if child 4 requests one |
| `scripts/dev-tools/sync-agents-from-instructions.ps1` (existing `AGENTS.md` writer) | Repository | Not edited by child 3; child 6 owns its retirement or redirection (OQ-6, H3) | Unchanged |
| Codex native converter, TypeScript port (`extensions/drm-copilot/src/lib/codex-native-converter/`) | Extension host and MCP server: exposed as the MCP tool `run_codex_native_converter` (`extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`) and the extension command `drmCopilotExtension.runCodexNativeConverter`, both through `extensions/drm-copilot/src/repo-automation-service.ts` | Clause (2): MCP and extension-command code, so TypeScript is permitted; edited in place (OQ-6, H3); no new pushed-down TypeScript | TypeScript (existing, edited in place) |
| Codex native converter, Python package (`scripts/dev_tools/codex_native_converter/`) and its tests under `tests/scripts/dev_tools/codex_native_converter/` | Repository: the `codex-native-converter` Poetry script | "Existing Python is tolerated: reuse, call or extend in place only": edited in place for parity; no new Python module | Existing Python (edited in place) |

No artifact of this child requires a language outside the rule; the D-16 consumption question is recorded as OQ-9.

## Constraints & Risks

- **Planning ahead of child 1 (owner decision E3).** Planned before child 1's contracts, dispositions and approvals exist; the Phase 0 gate re-checks them.
- **Execution precondition.** Retired 2026-11-14: the parallel run `bugs-1001-1002-1003-1006` has merged (PQ-2).
- **Blast-radius tooling.** Child 3 does not change `.claude/lib/blast-radius/**`, `config/blast-radius.json`, the blast-radius Python modules under `scripts/dev_tools/` (for example `push_down_claude_blast_radius_derive.py`) or their tests. No pack-manifest file is edited (D-8).
- **Child 2 files.** Child 3 does not edit `extensions/drm-copilot/src/lib/development-docs/**`, `.claude/lib/development-docs/**`, their bundle copies, child 2's tests or child 2's spec.
- **Excluded from edit.** `config/orchestration-regeneration.json` is not created (D-3); `scripts/dev_tools/generate_codex_agent_variants.py`, `scripts/dev-tools/Invoke-FullRelease.ps1`, `scripts/dev-tools/sync-agents-from-instructions.ps1` (child 6 owns it, H3), `.github/copilot-instructions.md` (child 6), `.github/workflows/**`, `config/poshqc-scan.json`, `config/poshqc-coverage.json`, `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, and every `tests/scripts/dev_tools/test_push_down_*` file (run, not edited).
- **Quality tier.** `quality-tiers.yml` exists, and `scripts/dev_tools/quality_tiers_contract.py` discovers every `scripts/<name>` folder that directly holds a code file as a project. `scripts/harness-generation/` therefore gets an entry in the same change: tier T4 with a rationale. T4 is chosen because the generators are repository-internal developer tooling that produce generated code, which `.claude/rules/quality-tiers.md` lists under T4 ("build scripts, dev tooling, generated code"), consistent with the existing T4 entries for `scripts/ci` and `scripts/dev-tools`. Coverage thresholds are uniform across tiers, so T4 does not lower the coverage gate. If OQ-1 is answered so that generators ship to destinations as libraries, child 4 re-evaluates the tier.
- **CI wiring.** One Pester repository gate inside the existing `poshqc / PowerShell QC` shards (`.github/workflows/_poshqc.yml` `poshqc-shard`), picked up through `config/poshqc-scan.json` (`scanFolders` includes `tests/scripts`). No new CI job, workflow step or required context. The Python `--check` step `Verify Codex agent deployment profiles` in `.github/workflows/_quality-checks.yml` is unchanged.
- **Execution-environment brief.** The plan adds the repository gate to the brief's `## Contract Tests That Pin Mirrored Files` (D-5), so all six copies (`.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md` and their bundle copies) change in the same task.
- **Batch budget.** The hand-written production files exceed the direct-mode budget of three new PowerShell production files per session, so execution uses the `large` route checkpoint.
- **File size.** One module per surface; each module and each generated TOML stays at or below 800 lines.
- **CI-only behavior.** CRLF writes on Windows, drive-letter paths on Linux and diffs against `origin/main` on a depth-one checkout are avoided: LF and UTF-8 without BOM, forward-slash relative paths built with `Join-Path`, and a repository gate that reads only the working tree.
- **Owner stop placement.** No executor task halts for owner input; owner decisions are consumed by the Phase 0 gate.

## Implementation Strategy

- One plan file carrying a `## Size Justification` (OQ-8), with phases:
  - Phase 0: gate and baseline evidence (static baselines and one `Phase 0 baseline` run of each parallel test gate).
  - Phase 1: framework (common module, entry script, unit tests), `quality-tiers.yml` entry, MCP source and generator, instructions check, `AGENTS.md` rewrite and `CLAUDE.md` import.
  - Phase 2: Codex native converter redirection (TypeScript port and Python package in parity, with their tests and documentation).
  - Phase 3: skill mirror (generator, tests, content reconciliation, first generation, `PINNED_FROZEN_SURFACE_HASHES` unchanged).
  - Phase 4: rules (sources, generator, per-target frontmatter, sections and substitutions, tests, first generation).
  - Phase 5: agents (sources, generator, alias form, Python variant run, D-16 pass-through, tests, first generation).
  - Phase 6: parity-matrix upkeep, repository gate, execution-environment brief update (D-5).
  - Phase 7: final QA (toolchain loop with the parallel gates, coverage against the `Phase 0 baseline`, scope evidence, self-review).
  - Every phase from 1 to 6 ends with a phase gate.
- New production files (planned names): `scripts/harness-generation/HarnessGeneration.psm1`, `HarnessSkillMirror.psm1`, `HarnessRuleGeneration.psm1`, `HarnessMcpConfig.psm1`, `HarnessAgentGeneration.psm1`, `HarnessInstructions.psm1`, `Invoke-HarnessGeneration.ps1`.
- New tests: one `tests/scripts/harness-generation/<Module>.Tests.ps1` per module and `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1`.
- Dependency changes: none. No YAML or TOML parser is added.
- Evidence locations: `<FEATURE>/evidence/baseline/` (Phase 0), `<FEATURE>/evidence/qa-gates/` (phase gates, toolchain, coverage, contract tests, language and edit-scope checks, self-review), `<FEATURE>/evidence/other/` (task checks). Each record carries `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:` and no absolute path.

## Acceptance Criteria

### Phase 0 gate

- [ ] `<FEATURE>/evidence/baseline/phase0-gate.<timestamp>.md` records, for every row of `## Owner Decisions`, its status, the default or decision the plan follows (D-1), and that the plan follows it, before any Phase 1 task runs; a recorded owner answer that differs from a default, or a plan that departs from a row, is recorded as a stop and no later phase runs.
- [ ] The Phase 0 record shows child 1's matrix, schema, approval artifact (`approved` or `approved-with-overrides`), E2 result or owner deferral, Q2 and Q4 answers, and child 2's `DevelopmentDocsRoot.psm1`, `write-scopes.ts` and write-scope checker suite present on the integration branch, with the matrix entries selected per `### Matrix Consumption` holding the dispositions this spec assumes.
- [ ] The Phase 0 record shows that no approved child 1 difference changes a file pinned in `PINNED_FROZEN_SURFACE_HASHES`, that every selected target exists at `HEAD` (D-8), and that every file, symbol and heading named in this spec and the plan was re-checked against the merge base of `origin/main` and `HEAD` with no moved, renamed or removed item.

### Framework

- [ ] `Invoke-HarnessGeneration.ps1 -Check` exits 0 on a tree with no drift and exits non-zero on drift, printing one line per drifted, missing or extra file by repository-relative POSIX path; Pester unit tests cover each outcome with injected in-memory listing and reading.
- [ ] A malformed source (missing frontmatter, unknown target, missing required agent field) fails the run before any write and names the source path; a unit test asserts that the injected writer was not called.
- [ ] Unit tests show that generated text is LF and UTF-8 without BOM, that check mode reports a CRLF or BOM target as drift, and that check mode reports a symlink or reparse-point target as drift.
- [ ] `quality-tiers.yml` has a `scripts/harness-generation` entry with tier T4 and a rationale, and `poetry run python -m scripts.dev_tools.check_quality_tiers` exits 0 with no QT007 or QT008 finding.

### Instructions

- [ ] `AGENTS.md` contains no `# Converted standing guidance` heading, no `> NOTE: This file is **generated** from:` line and no embedded copy of a `.claude/rules` file, and every `.agents/skills/<name>/SKILL.md` path it cites exists; the instructions check asserts each condition and has a failing unit test for each.
- [ ] The first line of `CLAUDE.md` after its YAML frontmatter is `@AGENTS.md`, and no whitespace-normalized H2 section body in `CLAUDE.md` equals one in `AGENTS.md`; the instructions check passes on the committed tree and fails in unit tests for a missing import and for a duplicated section.
- [ ] `AGENTS.md` carries no coverage-threshold statement, and the Pester tests for `.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/hooks/validate-feature-review-coverage-metrics.ps1` and `.claude/hooks/feature-review-coverage-thresholds.ps1` pass unchanged.
- [ ] `extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md` equals `AGENTS.md`.

### Codex native converter (H3)

- [ ] For a fixture source set that contains standing-guidance sources, the converter's generated output (TypeScript port and Python package) contains no `AGENTS.md` target and no `# Converted standing guidance` text, and an apply-mode run neither creates nor modifies a destination `AGENTS.md`; named Jest and pytest tests assert each condition.
- [ ] For the same fixture, the converter report records each standing-guidance source as not emitted, with a reason, and a named test in each implementation asserts the disposition and the reason.
- [ ] The converter tests updated for the new disposition, each named in the plan, pass under Jest for `extensions/drm-copilot/test/lib/codex-native-converter/` and under pytest for `tests/scripts/dev_tools/codex_native_converter/`, and the remaining tests in both directories pass unchanged.
- [ ] The converter change adds no Python module and no pushed-down TypeScript file; converter production code is changed only in existing files under `extensions/drm-copilot/src/lib/codex-native-converter/` and `scripts/dev_tools/codex_native_converter/`, recorded in `<FEATURE>/evidence/qa-gates/`.

### MCP server configuration

- [ ] `.mcp.json` and the `[mcp_servers.*]` region of `.codex/config.toml` are produced from `scripts/harness-generation/sources/mcp-servers.json`, and `-Surface mcp -Check` exits 0 on the committed tree.
- [ ] A unit test shows that the MCP generator leaves every byte of `.codex/config.toml` outside the `[mcp_servers.*]` region unchanged, including `default_permissions`, `[permissions.*]`, `[features]`, `[agents]` and `[[hooks.*]]`.
- [ ] The generated Codex `args` line has the single-line shape matched by `Set-CodexMcpVersionPin`, its version equals `packages/mcp-server/package.json` `version`, and `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` and `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` pass unchanged.

### Skill mirror

- [ ] For every matrix entry selected for the skill mirror in `### Matrix Consumption`, `.claude/skills/<name>/` and its bundle copy equal the rendered mirror of `.agents/skills/<name>/`, and `-Surface skills -Check` exits 0 on the committed tree.
- [ ] Unit tests show that a skill with no selected matrix entry is neither written nor deleted, that `agents/openai.yaml` is not mirrored, and that an extra file in a generated `.claude/skills/<name>/` folder is reported.
- [ ] Each approved positive difference in child 1's approval artifact that ports into a shared skill is applied in `.agents/skills/<name>/SKILL.md`, recorded per Diff ID in `<FEATURE>/evidence/qa-gates/`.
- [ ] `PINNED_FROZEN_SURFACE_HASHES` is unchanged, because both pinned files are protected targets that render byte-equal (PQ-2), and the tests that read `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` pass unchanged.

### Path-scoped rules

- [ ] Each selected `.claude/rules/*.md` (with a `paths:` list) and `.github/instructions/*.instructions.md` (with an `applyTo:` string), and, under OQ-2's default, each Codex rule-skill, is produced from `scripts/harness-generation/sources/rules/` with its bundle copy, and `-Surface rules -Check` exits 0 on the committed tree.
- [ ] `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`, `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` and `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py` pass unchanged, and a unit test shows that a source whose Claude glob list would make a non-deliberate rule unconditional is rejected.
- [ ] `.github/instructions/general-unit-test.instructions.md` begins with a `---` frontmatter delimiter after generation.

### Agents

- [ ] For every matrix entry selected for agents, `.claude/agents/<name>.md` and base `.codex/agents/<name>.toml` with their bundle copies equal the rendered output of the agent source, and `-Surface agents -Check` exits 0 on the committed tree.
- [ ] After the PowerShell agent generator runs, running `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` in write mode changes no file, its `--check` exits 0, and `scripts/dev_tools/generate_codex_agent_variants.py` is unchanged relative to the merge base.
- [ ] A unit test shows that each agent's `Write(`/`Edit(` literals in the generated Claude and Codex files equal the source literals exactly, including leading-slash spelling, and child 2's write-scope checker suite passes on the generated files.
- [ ] `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`, `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py`, `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py` and `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` pass after agent generation.

### CI gate and matrix upkeep

- [ ] `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1` runs every check mode (skills, rules, MCP, agents, instructions) against the committed working tree without starting a process or reading git history, passes on the committed tree, and a unit test shows that the gate fails and lists the path when an injected reader returns drifted content.
- [ ] No file under `.github/workflows/` changes relative to the merge base, recorded in `<FEATURE>/evidence/qa-gates/`.
- [ ] The required `CI Required Gate` check passes on the pull request head (D-7; CI-dependent; checked off at S9).
- [ ] No matrix entry selected in `### Matrix Consumption` whose source exists still holds a `pending-source:` value in `generated_from`, each such entry has `generator` set, and child 1's repository gate passes.
- [ ] The execution-environment brief names the repository gate in all six copies (D-5), and the six copies are byte-identical, recorded in `<FEATURE>/evidence/qa-gates/`.

### QA

- [ ] Each new module under `scripts/harness-generation/` has at least 85% line coverage, read from `artifacts/pester/powershell-coverage.xml` and recorded per file in `<FEATURE>/evidence/qa-gates/`.
- [ ] The final parallel gates (one `Invoke-PoshQCParallelTest`, one `pytest -n auto`, Jest through its normal workers) report zero failures and `Invoke-PoshQCLeakScan` passes (D-6), recorded in `<FEATURE>/evidence/qa-gates/`.
- [ ] The files added relative to the merge base include no `.py` file and no `.ts` file, and each added code file appears in `## Language Classification` with the language it is written in, recorded in `<FEATURE>/evidence/qa-gates/`.
- [ ] The files changed relative to the merge base include none of the paths in the `Blast-radius tooling`, `Child 2 files` and `Excluded from edit` items of `## Constraints & Risks`, recorded in `<FEATURE>/evidence/qa-gates/`.
- [ ] No file added or changed by this child exceeds 800 lines; `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` passes, recorded in `<FEATURE>/evidence/qa-gates/`.
- [ ] `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` and `tests/scripts/dev_tools/test_generate_codex_agent_variants.py` pass after all generation, recorded in `<FEATURE>/evidence/qa-gates/`.

## Definition of Done

- [ ] Every item in `## Acceptance Criteria` is checked off with its evidence.
- [ ] The full toolchain loop (format, lint, type check where applicable, architecture, unit, contract, integration) passes in a single pass, recorded in `<FEATURE>/evidence/qa-gates/`.
- [ ] `user-story.md` acceptance criteria are checked off consistently with this spec.
