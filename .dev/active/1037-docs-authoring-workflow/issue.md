# docs-authoring-workflow (Issue #1037)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/docs-authoring-workflow/ (Issue #1037)
- Parent epic: #1019 (documentation-estate-tooling), child 900009 (wave 4, C4)

- Issue: #1037
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1037
- Last Updated: 2026-10-30
- Work Mode: full-feature

## Problem / Why

The documentation-estate-tooling epic (#1019) delivers a docs profile, surface analyzers, a page
checker, a coverage ledger with a `docs-complete` receipt, a reference generator and six docs MCP
tools. Without constrained documentation roles and reusable skills, a consumer repository still has
to hand-orchestrate inventory, information-architecture planning, page authoring, behavior
reconciliation and coverage review, and an unconstrained agent could edit the ledger or parity
matrix directly instead of going through the single mutation boundary (`update-ledger`).

## Proposed Behavior

- Four documentation roles under `.claude/agents/`: `docs-architect`, `docs-author`,
  `docs-reconciler`, `docs-coverage-reviewer`. Tool allowlists use the docs MCP tools
  (`run_docs_check`, `run_docs_inventory`, `run_docs_coverage`, `update_docs_ledger`,
  `generate_docs_reference`, `validate_docs_artifacts`) and grant no direct Write or Edit on ledger
  or matrix artifacts; no `memory:` frontmatter (it grants Write and Edit).
- Eight skills under `.claude/skills/`: `documentation-workflow`, `docs-init`,
  `docs-inventory-surface`, `docs-plan-ia`, `docs-author-page` (with page templates: tutorial,
  how-to, explanation, cli-reference, http-reference, config-reference, api-reference,
  architecture-overview), `docs-reconcile-behavior`, `docs-review-coverage`, `docs-validate`.
  Skills call `.claude/lib/docs/Invoke-DocsCommand.ps1` subcommands or the six docs MCP tools; any
  new skill helper is PowerShell.
- Mirrors produced by the existing repository generators (existing Python tooling, called, not
  extended): `.github/agents/`, `.github/skills/`, `.codex/agents/` variants, `.agents/skills/`,
  and the push-down trees under `extensions/drm-copilot/resources/claude-customizations/` and
  `extensions/drm-copilot/resources/codex-and-agents-customizations/`.
- A PowerShell SubagentStop output check for the four roles with a Pester suite, registered in
  `.claude/settings.json`, and role routing entries in `config/orchestration-routing.json`.

## Acceptance Criteria (early draft)

- [ ] Each role's tool list excludes Write and Edit on ledger and matrix paths; a test asserts it.
- [ ] Every skill references only MCP tools and subcommands defined in the epic's earlier children (1020 through the docs MCP tools child).
- [ ] Mirror and push-down parity tests pass for all new agents and skills.
- [ ] The SubagentStop check blocks a role output that lacks its required result fields.

## Constraints & Risks

- Language rule (owner directive 2026-10-30, refined): pushed-down skills, skill helpers, hooks and
  libs are PowerShell or bash; TypeScript only for MCP and extension commands; no new Python.
- Depends on the docs MCP tools child (900007), prepared concurrently; tool names are fixed in the
  epic naming contract.
- Codex reach of the docs lib is owner question Q7 (provisional default: Claude bundle only).

## Test Conditions to Consider

- [ ] Pester suite for the SubagentStop output check (pass and block cases per role)
- [ ] Tool-allowlist test over the four agent files
- [ ] Mirror and push-down parity tests for agents and skills

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/docs-authoring-workflow/` folder from the template
