# 2026-10-30-shared-source-generators-skills-rules-mcp-agents — Spec

- **Issue:** #1028
- **Parent (optional):** epic #1018 (shared agent-harness layer across Claude Code, Codex and GitHub Copilot), child 3
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T23-10
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Primary research input:** `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/research/research.2026-10-30T22-46.md`
- **Epic manifest:** `docs/features/epics/shared-agent-harness-layer/epic.md`
- **Confirmed design (not re-opened):** `docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md`
- **Upstream child 1 (#1025) spec:** `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/spec.md` on branch `origin/feature/harness-survey-gold-standard-contracts-parity-matrix-1025` (not present on this branch)
- **Upstream child 2 (#1035) spec:** `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/spec.md`

In this document `<FEATURE>` means `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028`. All paths are repository-relative POSIX paths.

## Overview

Shared skills, path-scoped rules, MCP servers, agents and top-level instructions are authored separately for each ecosystem (Claude Code, Codex, GitHub Copilot). The copies drift, and no check reports the drift. Epic #1018 settles one source per surface with generated native outputs. This child delivers PowerShell generators for the shared skill mirror, path-scoped rules, MCP server configuration and agents, each with a check mode that reports drift and exits non-zero on drift; makes `AGENTS.md` the instruction source with `CLAUDE.md` importing it; and wires every check mode into the existing required PowerShell CI check. The settled design is not re-opened here.

Inventory figures in the research record (skill, rule and agent counts) are planning context only. No acceptance criterion below asserts a count; each criterion is stated against the set produced by enumerating the trees and the parity matrix at execution time. The research record states in `## Numeric Derivation Evidence` that it proposes no numeric acceptance threshold.

## Owner Decisions

Each row carries the default that planning and execution use. Every row is `pending-owner-confirmation`. The Phase 0 gate (see `## Behavior`) stops execution if any row is still pending at execution time or was answered differently from its default.

| ID | Question | Default | Status |
| --- | --- | --- | --- |
| OQ-1 | Are the generators pushed down to destination repositories (child 4), and does any skill instruct an agent to run them? A pushed-down or skill-invoked generator must live in a published folder. | Repository-internal under a new `scripts/harness-generation/` folder with a T4 entry in `quality-tiers.yml`; no skill text instructs an agent to run a generator; PowerShell under either answer; child 4 decides distribution. | pending-owner-confirmation |
| OQ-2 | Codex has no path-scoped rules, and Codex-only skills under `.agents/skills` restate rule content and already drift (`.agents/skills/python/SKILL.md` `## Toolchain` states a different coverage threshold from `.claude/rules/python.md`). Should the rules generator also emit the Codex rule-skills (`.agents/skills/<rule>/SKILL.md`) as a third target? | Yes, with per-target substitutions for the pinned precedence fragments checked by `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`. | pending-owner-confirmation |
| OQ-3 | Which body becomes the single rule source: the Claude rules (summaries, merged per language) or the Copilot instructions (full text, split into code-change and unit-test files, and named "the canonical policy source" with "Do not modify them" in `CLAUDE.md` `## Policy Compliance Reading Order`)? Is the per-language split kept? | One source per current Claude rule; Copilot instruction files generated from it with the Claude split; the current Copilot full text reviewed for positives during the rules phase; the `CLAUDE.md` "canonical policy source" statement and the reading-order file names are rewritten in the same change as the instructions work. | pending-owner-confirmation |
| OQ-4 | `.mcp.json` runs the MCP package unpinned; `.codex/config.toml` pins it to the published version. Keep the difference? | Keep it as explicit per-target data; derive the Codex pin from `packages/mcp-server/package.json` `version`, so `Set-CodexMcpVersionPin` in `scripts/dev-tools/Invoke-FullRelease.ps1` and the generator agree without editing the release script. | pending-owner-confirmation |
| OQ-5 | Child 1's default marks every Claude agent and every base Codex agent `generated` by child 3, but child 1 does not survey agent bodies, and agents present in both trees have different bodies. Who classifies agent body differences, and are single-ecosystem agents generated or `native`? | Agents present in both `.claude/agents` and `.codex/agents` are reconciled in the agents phase under child 1's positive, negative, neutral and mechanism-only rules; single-ecosystem agents are `native` (a child 1 disposition override recorded in child 1's approval artifact). | pending-owner-confirmation |
| OQ-6 | `scripts/dev-tools/sync-agents-from-instructions.ps1` (also an extension command and a VS Code task) and the Codex native converter (`scripts/dev_tools/codex_native_converter/pipeline.py`, `extensions/drm-copilot/src/lib/codex-native-converter/pipeline-render.ts`) both overwrite `AGENTS.md`. Once `AGENTS.md` is the source, retire, redirect or guard them? | Child 3 makes `AGENTS.md` the source and adds a check that fails when `AGENTS.md` carries either writer's generated header; retirement or redirection of both writers is assigned to child 6. | pending-owner-confirmation |
| OQ-7 | The feature-review coverage hooks (`.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/hooks/validate-feature-review-coverage-metrics.ps1`, `.claude/hooks/feature-review-coverage-thresholds.ps1` and the Codex twins) read only the root `CLAUDE.md` text and do not follow `@AGENTS.md`. Where do repository coverage-threshold statements live? | Any repository threshold statement stays in the Claude-only part of `CLAUDE.md`; `AGENTS.md` carries none; child 5 decides whether the hooks also read `AGENTS.md`. | pending-owner-confirmation |
| OQ-8 | Delivery shape: one feature with several plans, one feature with one plan, or several child issues? | Resolution taken by the orchestrator, subject to owner confirmation: one feature and one plan that carries a `## Size Justification`, phased by surface (Phase 0 gate; framework, MCP config and instructions; skill mirror; rules; agents; CI gate and matrix upkeep; QA). This supersedes the research default of four sequential plans. | pending-owner-confirmation |
| OQ-9 | How does the PowerShell agent generator consume the D-16 write-scope contract? Child 2's spec (`## Write-scope literal contract (D-16)`, `### Interface for epic child 3`) states that child 3's agent generator imports `WRITE_SCOPE_RULES`, `expandWriteScopeLiterals` and related exports from the TypeScript module `extensions/drm-copilot/src/lib/development-docs/write-scopes.ts`. Child 3's generators are PowerShell under the owner language rule and cannot import TypeScript. Child 2's PowerShell module `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` resolves the development-docs root only and carries no write-scope rules, and child 2 defines no checked-in literal list. Neither route satisfies D-16 without duplicating its single source. | The agent source files carry the write-scope literals verbatim; the agent generator passes them through unchanged and does not compute them; child 2's TypeScript three-direction checker remains the sole D-16 assertion over the generated agent files. Alternative: child 2 adds a generated, checked-in JSON literal list emitted from `write-scopes.ts` and verified by its Jest checker, which the PowerShell generator reads. Under either answer child 2's spec text ("Child 3's agent generator imports ...") must be amended by child 2's owner; child 3 does not edit child 2's files. | pending-owner-confirmation |
| PQ-1 | Raised during planning. Read literally, the OQ-3 default ("Copilot files generated with the Claude split") renames the `-code-change` and `-unit-test` instruction files under `.github/instructions/`, whose names are cited by many files outside this child (including `.github/copilot-instructions.md`, `.github/agents/`, templates and converter tests). Are existing Copilot instruction paths renamed? | Keep every existing Copilot instruction path; one rule source per Claude rule emits each Copilot file from a declared list of H2 sections; no instruction file is renamed or deleted. | pending-owner-confirmation |
| PQ-2 | Raised during planning. Several generator targets are inside the blast radius of the parallel run `bugs-1001-1002-1003-1006` (for example `.codex/config.toml`, the execution-environment brief copies, the `orchestrate`, `epic-orchestrate`, `pr-author` and `parallel-*` skills and agents, the `parallel-orchestration` and `orchestrator-state` rules, and both pack-manifest `core.json` files), which this child must not edit. How are those targets handled? | Zero-diff rule: each protected target is rendered byte-equal to its post-merge content, so the generators manage it without changing it; the Phase 0 gate stops if an approved child 1 difference would change a protected path or a selected target would be a new bundled file. Consequence: `PINNED_FROZEN_SURFACE_HASHES` is not re-baselined, because the pinned files do not change. | pending-owner-confirmation |

Conditional stop (not an owner question of this child): if child 1's E2 result shows that Codex rejects Claude-only skill frontmatter keys, the settled superset frontmatter in `.agents/skills` cannot be used as written, and the Phase 0 gate stops for an owner decision on a per-tool frontmatter source.

## Behavior

### Phase 0 gate (execution-time requirement)

Execution of the plan begins with a gate. The gate is the only stop in this child; an owner stop cannot sit inside the executor plan, so a failing gate ends the executor run and returns control to the orchestrator for a plan revision or an owner decision. The gate proceeds only when every check passes; it does not proceed on partial matches. All results are recorded in `<FEATURE>/evidence/baseline/phase0-gate.<timestamp>.md`.

1. **Owner decisions.** Every row of `## Owner Decisions` has an owner answer, and every answer equals the row's default. A pending row, or an answer that differs from the default, stops execution.
2. **Child 1 merged.** Child 1's outputs are merged into the integration branch `epic/shared-agent-harness-layer-integration`: `config/harness-parity-matrix.json` and `config/harness-parity-matrix.schema.json` exist; `schema_version` has major version 1; entries exist for the kinds `skill`, `agent`, `path-scoped-rule`, `mcp-server` and `instructions` with the dispositions this spec assumes (see `### Matrix Consumption`); child 1's approval artifact has `Approval-Status` `approved` or `approved-with-overrides`; child 1's E2 result or an owner deferral is recorded; child 1's Q2 and Q4 answers are recorded; contracts exist for the shared set.
3. **Child 2 merged.** Child 2's outputs are merged into the integration branch: the `development_docs_root` key, `.claude/lib/development-docs/DevelopmentDocsRoot.psm1`, `extensions/drm-copilot/src/lib/development-docs/write-scopes.ts` and child 2's write-scope checker suite exist; child 2's spec text for `### Interface for epic child 3` matches the OQ-9 answer.
4. **Parallel run merged.** Every item of the parallel run `bugs-1001-1002-1003-1006` has merged to `main`.
5. **Edit-set re-check.** Every file, symbol and heading named in this spec and in the plan is compared against the merge base of `origin/main` and `HEAD`. This includes `scripts/dev_tools/generate_codex_agent_variants.py` (`render_base_alias`, `--check`), `GENERATED_AGENT_FAMILIES` in `scripts/dev_tools/resolve_codex_deployment.py`, `Set-CodexMcpVersionPin` in `scripts/dev-tools/Invoke-FullRelease.ps1`, `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, `DELIBERATE_UNCONDITIONAL_RULES` in `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`, both `pack-manifests/core.json` bundle files, the copies of the execution-environment brief, and the `poshqc-shard` job in `.github/workflows/_poshqc.yml`. A moved, renamed or removed item stops execution.
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

Child 3 selects parity-matrix entries by the `ecosystem`, `kind`, `disposition` and `owner_child` fields, and never parses the `id` string; child 1's `id` grammar is an open child 1 preflight defect and may change. The generated set for each surface is:

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
- `.claude/skills/epic-orchestrate/SKILL.md` is a protected target (PQ-2): the skill mirror renders it byte-equal to its post-merge content, so its pinned hash does not change and `PINNED_FROZEN_SURFACE_HASHES` is not re-baselined.

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
- `.claude/agents/epic-orchestrator.md` is a protected target (PQ-2): the agent generator renders it byte-equal to its post-merge content, so, as for the skill mirror, `PINNED_FROZEN_SURFACE_HASHES` is not re-baselined.

### Edge cases

- A tool-only skill folder is untouched in write and check mode.
- A target missing from disk is reported as missing in check mode and created in write mode.
- A generated folder or file with no source is reported as extra; write mode does not delete files outside the selected set.
- A generated Codex TOML is subject to the 800-line hard limit (Markdown outputs are exempt).

## Inputs / Outputs

- Inputs: `.agents/skills/**` (skill source); `scripts/harness-generation/sources/**` (rule, agent and MCP sources); `config/harness-parity-matrix.json` (child 1); `config/orchestration-routing.json` (`codex_model_policy`); `packages/mcp-server/package.json` (`version`); `AGENTS.md`, `CLAUDE.md`.
- Outputs: `.claude/skills/<name>/**`, `.claude/rules/*.md`, `.github/instructions/*.instructions.md`, Codex rule-skills (OQ-2), `.mcp.json`, the `[mcp_servers.*]` region of `.codex/config.toml`, `.claude/agents/*.md`, base `.codex/agents/*.toml`, and the bundle copy of each under `extensions/drm-copilot/resources/`; updated `generated_from` and `generator` fields in `config/harness-parity-matrix.json`.
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
- No MCP tool and no extension command is added (see `## Language Classification`).

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
| `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | CI | Not changed: both pinned files are protected targets that render byte-equal (PQ-2); no Python file is edited | Existing Python (unchanged) |
| D-16 write-scope literal handling in the agent generator | Repository and CI | PowerShell cannot import child 2's TypeScript source; raised as OQ-9, not decided here | PowerShell pass-through (OQ-9 default); child 2's TypeScript checker remains the assertion |
| Source data (`scripts/harness-generation/sources/**`, `.agents/skills/**`) | Data | Not code | JSON and Markdown |
| MCP wrapper over a generator | MCP server package | Clause (2) | Not in child 3 scope; TypeScript if child 4 requests one |
| Existing `AGENTS.md` writers (`sync-agents-from-instructions.ps1`, Codex native converter) | Repository | Not edited by child 3 (OQ-6) | Unchanged |

No artifact of this child requires a language outside the rule; the D-16 consumption question is recorded as OQ-9.

## Constraints & Risks

- **Planning ahead of child 1 (owner decision E3).** Planned before child 1's contracts, dispositions and approvals exist; the Phase 0 gate re-checks them.
- **Execution precondition.** Execution starts only after the parallel run `bugs-1001-1002-1003-1006` merges to `main`.
- **Parallel-run blast radius.** Child 3 does not change `.claude/lib/blast-radius/**`, `config/blast-radius.json`, the blast-radius Python modules under `scripts/dev_tools/` (for example `push_down_claude_blast_radius_derive.py`) or their tests. Files that the parallel run changes and child 3 later edits (`pack-manifests/core.json` bundle files, the execution-environment brief copies) are edited only after the Phase 0 gate confirms the merge.
- **Child 2 files.** Child 3 does not edit `extensions/drm-copilot/src/lib/development-docs/**`, `.claude/lib/development-docs/**`, their bundle copies, child 2's tests or child 2's spec.
- **Excluded from edit.** `scripts/dev_tools/generate_codex_agent_variants.py`, `scripts/dev-tools/Invoke-FullRelease.ps1`, `scripts/dev-tools/sync-agents-from-instructions.ps1`, the Codex native converter, `.github/copilot-instructions.md` (child 6), `.github/workflows/**`, `config/poshqc-scan.json`, `config/poshqc-coverage.json`, `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, and every `tests/scripts/dev_tools/test_push_down_*` file (run, not edited).
- **Quality tier.** `quality-tiers.yml` exists, and `scripts/dev_tools/quality_tiers_contract.py` discovers every `scripts/<name>` folder that directly holds a code file as a project. `scripts/harness-generation/` therefore gets an entry in the same change: tier T4 with a rationale. T4 is chosen because the generators are repository-internal developer tooling that produce generated code, which `.claude/rules/quality-tiers.md` lists under T4 ("build scripts, dev tooling, generated code"), consistent with the existing T4 entries for `scripts/ci` and `scripts/dev-tools`. Coverage thresholds are uniform across tiers, so T4 does not lower the coverage gate. If OQ-1 is answered so that generators ship to destinations as libraries, child 4 re-evaluates the tier.
- **CI wiring.** One Pester repository gate inside the existing `poshqc / PowerShell QC` shards (`.github/workflows/_poshqc.yml` `poshqc-shard`), picked up through `config/poshqc-scan.json` (`scanFolders` includes `tests/scripts`). No new CI job, workflow step or required context. The Python `--check` step `Verify Codex agent deployment profiles` in `.github/workflows/_quality-checks.yml` is unchanged.
- **Execution-environment brief.** If the plan adds the repository gate to the brief's `## Contract Tests That Pin Mirrored Files`, all six copies (`.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md` and their bundle copies) change in the same task.
- **Batch budget.** The hand-written production files exceed the direct-mode budget of three new PowerShell production files per session, so execution uses the `large` route checkpoint.
- **File size.** One module per surface; each module and each generated TOML stays at or below 800 lines.
- **CI-only behavior.** CRLF writes on Windows, drive-letter paths on Linux and diffs against `origin/main` on a depth-one checkout are avoided: LF and UTF-8 without BOM, forward-slash relative paths built with `Join-Path`, and a repository gate that reads only the working tree.
- **Owner stop placement.** No executor task halts for owner input; owner decisions are consumed by the Phase 0 gate.

## Implementation Strategy

- One plan file carrying a `## Size Justification` (OQ-8), with phases:
  - Phase 0: gate and baseline evidence.
  - Phase 1: framework (common module, entry script, unit tests), `quality-tiers.yml` entry, MCP source and generator, `AGENTS.md` rewrite and `CLAUDE.md` import, instructions check.
  - Phase 2: skill mirror (generator, tests, content reconciliation in child 1's batches, first generation, pinned-hash contract tests with `PINNED_FROZEN_SURFACE_HASHES` unchanged).
  - Phase 3: rules (sources, generator, per-target substitutions, tests, first generation).
  - Phase 4: agents (sources, generator, alias form, Python variant run, D-16 pass-through, tests, first generation, pinned-hash contract tests with `PINNED_FROZEN_SURFACE_HASHES` unchanged).
  - Phase 5: repository gate and parity-matrix upkeep.
  - Phase 6: QA (toolchain loop, coverage, isolation, contract-test sweep, language and edit-scope evidence).
- New production files (planned names): `scripts/harness-generation/HarnessGeneration.psm1`, `HarnessSkillMirror.psm1`, `HarnessRuleGeneration.psm1`, `HarnessMcpConfig.psm1`, `HarnessAgentGeneration.psm1`, `HarnessInstructions.psm1`, `Invoke-HarnessGeneration.ps1`.
- New tests: one `tests/scripts/harness-generation/<Module>.Tests.ps1` per module and `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1`.
- Dependency changes: none. No YAML or TOML parser is added.
- Evidence locations: `<FEATURE>/evidence/baseline/` (Phase 0), `<FEATURE>/evidence/qa-gates/` (toolchain, coverage, contract tests, language and edit-scope checks), `<FEATURE>/evidence/regression-testing/` (isolation runs). Each record carries `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:` and no absolute path.

## Acceptance Criteria

### Phase 0 gate

- [ ] `<FEATURE>/evidence/baseline/phase0-gate.<timestamp>.md` records an owner answer for every row of `## Owner Decisions`, each equal to the row's default, before any Phase 1 task runs; a pending or differing answer is recorded as a stop and no later phase runs.
- [ ] The Phase 0 record shows child 1's matrix, schema, approval artifact (`approved` or `approved-with-overrides`), E2 result or owner deferral, Q2 and Q4 answers, and child 2's `DevelopmentDocsRoot.psm1`, `write-scopes.ts` and write-scope checker suite present on the integration branch, with the matrix entries selected per `### Matrix Consumption` holding the dispositions this spec assumes.
- [ ] The Phase 0 record shows that the parallel run `bugs-1001-1002-1003-1006` has merged to `main` and that every file, symbol and heading named in this spec and the plan was re-checked against the merge base of `origin/main` and `HEAD` with no moved, renamed or removed item.

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
- [ ] The `poshqc / PowerShell QC` check and every `quality-checks7 / Code Quality & Tests (<version>)` leg pass on the pull request head (CI-dependent; checked off at S9).
- [ ] No matrix entry selected in `### Matrix Consumption` whose source exists still holds a `pending-source:` value in `generated_from`, each such entry has `generator` set, and child 1's repository gate passes.
- [ ] If the execution-environment brief changes, all six copies are byte-identical, recorded in `<FEATURE>/evidence/qa-gates/`.

### QA

- [ ] Each new module under `scripts/harness-generation/` has at least 85% line coverage, read from `artifacts/pester/powershell-coverage.xml` and recorded per file in `<FEATURE>/evidence/qa-gates/`.
- [ ] The seeded shuffled file-order runs of `tests/scripts/harness-generation` and the fresh single-process run over `tests/scripts` required by the execution-environment brief pass, recorded in `<FEATURE>/evidence/regression-testing/`.
- [ ] The files added relative to the merge base include no `.py` file and no `.ts` file, and each added code file appears in `## Language Classification` with the language it is written in, recorded in `<FEATURE>/evidence/qa-gates/`.
- [ ] The files changed relative to the merge base include none of the paths in the `Parallel-run blast radius`, `Child 2 files` and `Excluded from edit` items of `## Constraints & Risks`, recorded in `<FEATURE>/evidence/qa-gates/`.
- [ ] No file added or changed by this child exceeds 800 lines; `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` passes, recorded in `<FEATURE>/evidence/qa-gates/`.
- [ ] `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` and `tests/scripts/dev_tools/test_generate_codex_agent_variants.py` pass after all generation, recorded in `<FEATURE>/evidence/qa-gates/`.

## Definition of Done

- [ ] Every item in `## Acceptance Criteria` is checked off with its evidence.
- [ ] The full toolchain loop (format, lint, type check where applicable, architecture, unit, contract, integration) passes in a single pass, recorded in `<FEATURE>/evidence/qa-gates/`.
- [ ] `user-story.md` acceptance criteria are checked off consistently with this spec.
