# `docs-authoring-workflow` — User Story

- Issue: #1037
- Parent: epic #1019 (documentation-estate-tooling), child 900009 (wave 4, band C4)
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30
- Specification: `spec.md` (this folder)

## Story Statement

- As a maintainer of a destination repository, I want documentation roles and skills that run
  inventory, information-architecture planning, page authoring, reconciliation and coverage review
  in a fixed sequence, so that I do not hand-orchestrate the documentation estate.
- As a maintainer of a destination repository, I want the coverage ledger, parity matrix, evidence
  pins and receipt to be changed only through the `update_docs_ledger` mutation boundary, so that no
  documentation role can rewrite correspondence evidence directly.
- As an orchestrator delegating to a documentation role, I want each role to stop only with a
  machine-checkable result block, so that I can act on its outcome without reading free-form text.
- As an operator on the Codex or Copilot host, I want the role and skill copies to state their
  prerequisites, so that I know which steps need the Claude customization push-down.
- As the implementer of the onboarding child (900010), I want fixed role names, skill names,
  template paths and result tokens, so that the epic template and onboarding guide can reference
  them.

## Problem / Why

The documentation-estate-tooling epic (#1019) delivers a docs profile, surface analyzers, a page
checker, a coverage ledger with a `docs-complete` receipt, a reference generator and the docs MCP
tools. Without constrained documentation roles and reusable skills, a consumer repository has to
hand-orchestrate inventory, information-architecture planning, page authoring, behavior
reconciliation and coverage review, and an unconstrained agent could edit the ledger or parity
matrix directly instead of going through the single mutation boundary (`update-ledger`). The need
was observed in one consumer repository.

## Personas & Scenarios

- Persona: destination-repository maintainer
  - Owns a repository that received the Claude customization push-down and PowerShell 7.4.
  - Cares that documentation tracks code changes and that the `docs-complete` gate is trustworthy.
  - Constraint: cannot review every agent edit by hand; relies on enforced boundaries.
  - Frustration: documentation drifts silently when code changes and the gap is measured by hand.
- Persona: orchestrating agent or session
  - Delegates documentation work to roles and decides the next step from their results.
  - Needs a stable result format and a guarantee that roles stay within their write scope.
- Persona: Codex or Copilot operator
  - Uses the same skills on another host; needs to know which steps depend on the docs library.

- Scenario: first documentation pass
  1. The maintainer invokes `documentation-workflow`.
  2. The root runs `docs-init` (`init` dry run, then `-Write`) and `validate-profile`.
  3. `docs-architect` runs `docs-inventory-surface` and `docs-plan-ia` with `run_docs_inventory`,
     `run_docs_coverage` and `run_docs_check`, and stops with its profile, snapshot and planned-page
     tokens and an `## Information Architecture` section.
  4. `docs-author` runs `docs-author-page`, starts from a template in
     `docs-author-page/templates/`, uses `generate_docs_reference` for reference families, writes
     Markdown pages, runs `run_docs_check`, and stops with the pages written and the check exit code.
  5. `docs-reconciler` runs `docs-reconcile-behavior` and records dispositions and pins through
     `update_docs_ledger`.
  6. `docs-coverage-reviewer` runs `docs-review-coverage` and `docs-validate`, reports the
     `docs-complete` result for the head revision, and leaves receipt persistence to the root or CI.
  - Expected outcome: pages exist, the ledger reflects them, and a `docs-complete` result is
    reported for the head revision.
- Scenario: a role attempts a forbidden write
  - `docs-author` attempts to write the coverage ledger path from the profile; the write-scope hook
    denies the call and names the rule. `docs-reconciler` attempts a direct `Edit`; the hook denies
    it. The ledger changes only through `update_docs_ledger`.
- Scenario: a role stops without its result block
  - `docs-reconciler` stops without `docs-update-ledger-exit-code`; the SubagentStop check blocks
    the stop and names the missing token, and the role repairs its output.
- Scenario: Codex operator
  - The operator opens `.agents/skills/docs-validate/SKILL.md`, reads the stated prerequisite
    (Claude push-down docs library and PowerShell 7.4), and uses the docs MCP tools; root-only steps
    are marked unavailable without that library.

## Acceptance Criteria

- [ ] `docs-architect`, `docs-reconciler` and `docs-coverage-reviewer` hold no `Write`, `Edit`, `MultiEdit`, `NotebookEdit` or `Bash` tool; `docs-author` holds bare `Write` and `Edit` and no `Bash`; no docs role carries a path-scoped `Write(` or `Edit(` entry, a `disallowedTools` field or a `memory:` field; a Pester test asserts each of these on the Claude, Copilot and Codex agent copies.
- [ ] `update_docs_ledger` is held only by `docs-reconciler`, and each role's MCP tools equal the role table in `spec.md` `## Role and Tool-Allowlist Contract`; a Pester test asserts it.
- [ ] The write-scope hook denies a `docs-author` write to the profile path, to any profile `artifact_paths` value, to a non-`.md` path, to a path under `.claude/`, `.github/`, `.codex/` or `.agents/`, and to a path outside the repository; denies every write by the other docs roles and every `Bash` call by any docs role; allows a `docs-author` Markdown page write and every call by a non-docs agent; a Pester suite with in-memory payloads proves each case.
- [ ] The SubagentStop check blocks a role output that lacks any of its required result fields or carries an invalid value, names the token in its reason, and allows a complete output, for each docs role; a Pester suite proves each case.
- [ ] Every skill references only MCP tools and subcommands defined in the epic's earlier children, checked against `extensions/drm-copilot/src/repo-automation-tool-names.ts` and the merged `Invoke-DocsCommand.ps1` dispatch table.
- [ ] Codex and Copilot skill copies contain no `.claude/` path and state the Claude push-down docs library and PowerShell 7.4 prerequisite.
- [ ] Mirror and push-down parity tests pass for all new agents, skills and templates, every bundle copy is byte-identical, every Claude and Codex file is listed in its pack manifest, and the existing contract tests and the Codex generator `--check` pass without modification.
- [ ] Each page template carries the front-matter fields `owner`, `last_reviewed`, `audience`, `diataxis_mode` and `surface_refs` with the `diataxis_mode` value of the `spec.md` mode mapping.
- [ ] The SubagentStop and PreToolUse hooks are registered in `.claude/settings.json` and its byte-identical bundle copy, and the `docs_operations` routing block is present in `config/orchestration-routing.json` and its two byte-identical bundle copies (the `extensions/drm-copilot/resources/config/` copy and the `extensions/drm-copilot/resources/claude-customizations/config/` push-down copy).
- [ ] No Python or TypeScript file is added or modified, `.codex/config.toml` is unchanged, and no test creates a temporary file.
- [ ] (CI-dependent) `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` pass on the pull request head.

## Non-Goals

- New or changed MCP tools, extension commands, Python or TypeScript files.
- Codex or Copilot stop and write hooks, and any `.codex/config.toml` change (owner question OQ-2).
- Generated Codex `-c1` to `-c4` variants for the docs roles (OQ-3).
- Granting `update_docs_ledger` to the coverage reviewer (OQ-6).
- Mechanical judgment of prose accuracy; the reviewer role reports it and the reconciler records it.
- A docs-site build, and changes to the docs library subcommands or schemas.
