# `2026-10-30-shared-source-generators-skills-rules-mcp-agents` — User Story

- Issue: #1028
- Parent: epic #1018, child 3
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T23-10
- Work Mode: full-feature
- Spec: `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/spec.md`

In this document `<FEATURE>` means `docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028`.

## Story Statement

- As a repository maintainer, I want each shared skill, path-scoped rule, MCP server entry and agent to have one source from which the Claude Code, Codex and GitHub Copilot files are generated, so that an edit is made once and cannot drift between ecosystems.
- As a reviewer, I want a required CI check that fails and names each drifted generated file, so that a hand edit to a generated file, or a source edit without regeneration, is caught before merge.
- As the epic owner, I want execution to stop before any change when an owner decision is pending or an upstream child's output differs from what the plan assumes, so that the generators are never built on unconfirmed decisions.

## Problem / Why

Shared skills, path-scoped rules, MCP servers, agents and top-level instructions are authored separately for each ecosystem (Claude Code, Codex, GitHub Copilot). The copies drift, and no check reports the drift. Examples recorded in the research record: `.agents/skills/python/SKILL.md` and `.claude/rules/python.md` state different coverage thresholds; `.github/instructions/general-unit-test.instructions.md` has no opening frontmatter delimiter; `AGENTS.md` is converter output that cites skill files that do not exist and is overwritten by two separate writers. Epic #1018 settles one source per surface with generated native outputs; this child delivers the generators and their check modes. The settled design is in `docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md` and is not re-opened here.

## Personas & Scenarios

- Persona: repository maintainer
  - Maintains the agent harness for all three ecosystems in this repository and in destination repositories.
  - Cares that each tool loads each skill and instruction once and that the copies say the same thing.
  - Constraint: the owner language rule (no new Python; PowerShell or bash for anything pushed down; TypeScript only for MCP tools and extension commands); Windows development with Linux CI.
  - Frustration: a change to one copy is not reflected in the others, and the difference is found later by accident.
- Persona: reviewer or review agent
  - Checks pull requests that touch harness files.
  - Cares that generated files are never edited by hand and that bundled copies under `extensions/drm-copilot/resources/` match.
  - Constraint: relies on required CI checks rather than manual comparison.
- Scenario: updating a shared skill
  - Trigger: the maintainer changes the wording of a shared skill.
  - Steps: edit `.agents/skills/<name>/SKILL.md`; run `scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface skills`; commit the source and the regenerated `.claude/skills/<name>/SKILL.md` and bundle copy.
  - Obstacle: if the maintainer edits only `.claude/skills/<name>/SKILL.md`, the repository gate in `poshqc / PowerShell QC` fails and names that file.
  - Outcome: one edit reaches every ecosystem and its bundle copy.
- Scenario: changing an agent
  - Trigger: the maintainer adds a skill to an agent that exists in Claude Code and Codex.
  - Steps: edit the agent source under `scripts/harness-generation/sources/agents/`; run the entry script with `-Surface agents`; run `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` for the Codex variants; commit.
  - Decision: write-scope literals are copied from the source unchanged (owner decision OQ-9 default); child 2's checker verifies them.
  - Outcome: the Claude Markdown, the Codex base TOML, the Codex variants and the bundle copies agree, and both check modes pass.
- Scenario: execution start
  - Trigger: the orchestrator delegates the plan.
  - Steps: the Phase 0 gate checks owner decisions OQ-1 to OQ-9, the merge of child 1 and child 2 into the integration branch, the merge of the parallel run `bugs-1001-1002-1003-1006` to `main`, and every named file, symbol and heading against the merge base of `origin/main` and `HEAD`.
  - Outcome: execution proceeds only when every check passes; otherwise it stops and records the reason.

## Acceptance Criteria

### Phase 0 gate

- [ ] Execution stops before any change, with the reason recorded in `<FEATURE>/evidence/baseline/phase0-gate.<timestamp>.md`, when any owner decision OQ-1 to OQ-9 in the spec is pending or answered differently from its default, when child 1's or child 2's outputs are not merged into the integration branch, when the parallel run `bugs-1001-1002-1003-1006` has not merged to `main`, or when a named file, symbol or heading has moved relative to the merge base of `origin/main` and `HEAD`.

### Generation and drift reporting

- [ ] Running `scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface <surface> -Check` for each of skills, rules, MCP, agents and instructions exits 0 on the committed tree and, when a generated file differs from its rendered form, exits non-zero and names each drifted, missing or extra file by repository-relative path.
- [ ] Generated files are written as regular LF, UTF-8-without-BOM files, never as symlinks, and each generated file's bundle copy under `extensions/drm-copilot/resources/` is written with it.
- [ ] A malformed source stops generation before any file is written, and the error names the source file.

### Instructions

- [ ] `AGENTS.md` is a hand-authored source with no generated-file header and no embedded rule copies, and `CLAUDE.md` imports it with `@AGENTS.md` and adds only Claude-only text.

### MCP server configuration

- [ ] `.mcp.json` and the MCP server tables of `.codex/config.toml` come from one server list, the rest of `.codex/config.toml` is untouched by generation, and the release script's version pin keeps working.

### Skill mirror

- [ ] Each shared skill in `.claude/skills` is generated from `.agents/skills`; tool-only skills and Codex metadata files are not mirrored.

### Path-scoped rules

- [ ] Each Claude rule and Copilot instruction file selected for generation is produced from one rule source with its native glob frontmatter (`paths:` or `applyTo:`), and the existing rule-frontmatter and tier-precedence tests pass unchanged.

### Agents

- [ ] Each agent selected for generation is produced as Claude Markdown and Codex base TOML from one definition, the existing Codex variant generator runs unchanged and reports no drift afterwards, and write-scope literals equal the source literals exactly and pass child 2's write-scope checker.

### CI

- [ ] Every check mode runs in the existing required `poshqc / PowerShell QC` check through one Pester repository gate, with no new CI job, and the check passes on the pull request head (CI-dependent; checked off at S9).
- [ ] The parity-matrix entries owned by this child record their single source in `generated_from` and their generator in `generator` once the source exists, and child 1's matrix gate passes.

### Quality and language

- [ ] No new Python or TypeScript file is added; every new code file is PowerShell and is listed with its language in the spec's `## Language Classification`.
- [ ] Each new PowerShell module has at least 85% line coverage, the isolation runs required by the execution-environment brief pass, and no added or changed file exceeds 800 lines.
- [ ] No file in the parallel run's blast radius, in child 2's files, or in the spec's excluded paths is changed by this child.

## Non-Goals

- Re-opening any settled design decision in the epic record.
- Symlinked mirrors.
- Generating hooks (child 5), pushing generators or generated layers down to destination repositories and per-ecosystem pack selection (child 4), and retiring `.github/skills`, `.github/agents`, `scripts/dev-tools/sync-agents-from-instructions.ps1` or the Codex native converter's `AGENTS.md` output (child 6, per OQ-6).
- Editing `.github/copilot-instructions.md` (child 6).
- Editing child 2's files or spec, including `extensions/drm-copilot/src/lib/development-docs/write-scopes.ts` and `.claude/lib/development-docs/DevelopmentDocsRoot.psm1`; the amendment that OQ-9 requires belongs to child 2's owner.
- Editing `scripts/dev_tools/generate_codex_agent_variants.py`, `scripts/dev-tools/Invoke-FullRelease.ps1` or any CI workflow file.
- Any change to `.claude/lib/blast-radius/**`, `config/blast-radius.json`, the blast-radius Python modules or their tests.
- Generating the bundle-only variant subtrees (`.claude-variants/`, `.agents-variants/`, `.codex-variants/`).
- An MCP tool or extension command that wraps a generator.
