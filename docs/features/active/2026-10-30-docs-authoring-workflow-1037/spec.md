# docs-authoring-workflow — Spec

- **Issue:** #1037
- **Parent (optional):** epic #1019 (documentation-estate-tooling), child 900009 (wave 4, band C4)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Primary design source:** `research/2026-10-30T23-33-docs-authoring-workflow-research.md` (this folder)
- **Environment brief:** `.claude/skills/execution-environment/SKILL.md` (cited by heading; not restated)

## Overview

### Problem

The documentation-estate-tooling epic (#1019) delivers a docs profile, surface analyzers, a page
checker, a coverage ledger with a `docs-complete` receipt, a reference generator, and the docs MCP
tools. Without constrained documentation roles and reusable skills, a consumer repository has to
hand-orchestrate inventory, information-architecture planning, page authoring, behavior
reconciliation and coverage review. An unconstrained agent could also edit the coverage ledger or
parity matrix directly instead of going through the single mutation boundary (`update-ledger`,
exposed as the MCP tool `update_docs_ledger`). The requirement originates from one consumer
repository (epic `## Goal`).

### Outcome

This child adds four documentation roles, eight skills with page templates, their mirrors on the
Claude, Codex and Copilot surfaces and push-down bundles, one SubagentStop output check, one
PreToolUse write-scope hook, routing and settings registrations, and Pester suites that prove the
role contracts. It adds no MCP tool, extension command, Python file or TypeScript file.

## Owner Decisions (2026-10-30, propagated verbatim)

> "(1) A1 to A8 are CONFIRMED as written (separate Python/config and TypeScript/.NET analyzer
> features with 900004 later; no docs-site build; epic separate from issue #5; integration branch
> from origin/main; pushed-down logic is PowerShell under .claude/lib/docs/ behind
> Invoke-DocsCommand.ps1; TypeScript MCP wrappers call it; reuse discovery schemas and existing
> PowerShell discovery libs and do not call the Python discovery runtime; no new third-party
> PowerShell modules). (2) D1: the PowerShell rewrite counts as a NEW planning cycle for 1022 and
> 1024 (and for every superseded child); each gets a fresh allowance of one planner revision and the
> single-pass preflight; 1024's halted preflight must be addressed in the new plan (property tests
> for the six pure functions). (3) D3, language exception approved by the owner: a language-native
> analyzer is allowed when it analyzes that same language and is pushed down only with that
> language's pack (python pack for Python). The PowerShell text scanner stays the always-available
> baseline and keeps its documented precision limit, recorded as deferred-with-owner in the coverage
> ledger. The Python-native analyzer (Python ast, written in Python, shipped in the python pack
> manifest, tested under the Python gates) is IN THE FIRST RELEASE: keep 1022 as the PowerShell
> baseline scanner for Python/config surfaces and add a new child for the Python-native analyzer
> depending on 1022, in the earliest wave its dependencies allow; the planner decides the exact
> split and records it. C# and TypeScript native analyzers are LATER, optional children (900004
> stays the baseline TypeScript/.NET scanner). The ledger must record the analysis method (native
> or scanner) per finding. (4) D4: linting stays optional by default (config only, no required Node
> or Python linter). (5) D5: docs-complete fails closed when the inventory snapshot has no
> revision; an element digest covers the declaration's lines, not the whole file; the JSON output
> envelope gets its own schema; test PowerShell Test-Json cross-file $ref first and use
> self-contained schemas as the fallback. Language rule otherwise unchanged: pushed-down skills,
> hooks and libs are PowerShell or bash; TypeScript only for MCP and extension commands."

Consequences for this child: the language rule governs every artifact below (hooks are
PowerShell; skills and agents are Markdown or TOML; no new Python or TypeScript). D1 to D5 change
no artifact of this child directly; the reconciler skill records `analysis_method` only through
`update_docs_ledger`, which owns that field (1023).

## Scope

In scope:

- Four roles: `docs-architect`, `docs-author`, `docs-reconciler`, `docs-coverage-reviewer`.
- Eight skills: `documentation-workflow`, `docs-init`, `docs-inventory-surface`, `docs-plan-ia`,
  `docs-author-page`, `docs-reconcile-behavior`, `docs-review-coverage`, `docs-validate`.
- Page templates in `docs-author-page/templates/`: `tutorial.md`, `how-to.md`, `explanation.md`,
  `cli-reference.md`, `http-reference.md`, `config-reference.md`, `api-reference.md`,
  `architecture-overview.md`.
- Hand-authored mirrors of every agent, skill and template on the Copilot, Claude and Codex hosts
  and their bundles (section `## Mirror Set`).
- PowerShell hooks: `.claude/hooks/docs-role-contract.ps1` (dot-sourced helper),
  `.claude/hooks/validate-docs-role-output.ps1` (SubagentStop), and
  `.claude/hooks/enforce-docs-role-write-scope.ps1` (PreToolUse), each with a bundle copy.
- Edits: `.claude/settings.json` and its bundle copy; `config/orchestration-routing.json` and its
  bundle copy; the Claude and Codex `pack-manifests/core.json` files.
- Pester suites for the hooks and for the structural role, skill, mirror and routing contracts.

## Non-Goals

- No new or edited MCP tool, extension command, TypeScript file or Python file.
- No edit to `.codex/config.toml` (owner question OQ-2) and no Codex or Copilot stop or write hook.
- No addition of the docs roles to `GENERATED_AGENT_FAMILIES` or `generated_agent_families`, and no
  `-c1` to `-c4` Codex variants (OQ-3).
- No extension of existing Python generators; `scripts/dev_tools/generate_codex_agent_variants.py`
  is run in its write form once after Codex manifest edits and then in `--check` form only.
- No new skill helper module; if one becomes necessary it is PowerShell under `.claude/lib/docs/`
  following 1020's conventions and is raised in the plan first.
- No `.claude/lib/docs/` subcommand, dispatch row or schema change.
- No docs-site build (A2), no mechanical judgment of prose accuracy, no runtime characterization.
- No change to `routes`, `generated_agent_families` or `discovery_operations` in the routing config.
- No acceptance item depends on a live role run or an isolated subagent exercising a branch hook
  (execution-environment brief `## Hook Execution Context`).

## Artifact Classification

Rules: R1 = language rule clause (1), pushed-down skills, helpers, hooks and libs are PowerShell or
bash; R2 = clause (2), TypeScript only for MCP and extension commands (none here); D = epic
`### Artifact classes for this epic` (skill, agent, schema/config/data and test rows); G = owner
directive permission to call existing tooling. "Avoid new Python" applies to every row.

| File group (create unless noted) | Class | Language | Permitting rule |
|---|---|---|---|
| `.github/agents/docs-{architect,author,reconciler,coverage-reviewer}.agent.md` and copies under `extensions/drm-copilot/resources/customizations/.github/agents/` | agent | Markdown | D |
| `.claude/agents/docs-*.md` and copies under `extensions/drm-copilot/resources/claude-customizations/.claude/agents/` | agent | Markdown | D |
| `.codex/agents/docs-*.toml` and copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/` | agent | TOML | D |
| `SKILL.md` for each of the eight skills under `.github/skills/`, `.claude/skills/`, `.agents/skills/` and the three bundle copies | skill | Markdown | D |
| `docs-author-page/templates/*.md` on each host and bundle | skill (data) | Markdown | D |
| `.claude/hooks/docs-role-contract.ps1`, `validate-docs-role-output.ps1`, `enforce-docs-role-write-scope.ps1` and bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` | hook | PowerShell | R1 |
| `.claude/settings.json` and bundle copy (edit) | schema/config/data | JSON | D |
| `config/orchestration-routing.json` and `extensions/drm-copilot/resources/config/orchestration-routing.json` (edit) | schema/config/data | JSON | D |
| Claude and Codex `pack-manifests/core.json` (edit) | schema/config/data | JSON | D |
| Codex generator run (write once, then `--check`) | generator task (existing Python, called) | n/a | G |
| `tests/scripts/claude-hooks/docs-role-contract.Tests.ps1`, `validate-docs-role-output.Tests.ps1`, `enforce-docs-role-write-scope.Tests.ps1` | test | PowerShell (Pester) | D |
| `tests/scripts/claude-runtime/docs-authoring-roles.Tests.ps1` (split by concern before 500 lines) | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-authoring-workflow-1037/**` | documentation | Markdown | D |

The plan carries this table, extended to one row per created or edited file.

## Role and Tool-Allowlist Contract

Common rules for all four roles (Claude form in `.claude/agents/<role>.md`):

- MCP tools are listed as quoted YAML items `"mcp__drm-copilot__<tool>"`; the Copilot copy uses
  `drmcopilotextension/<tool>`; the Codex wrapper uses the Claude-form names in its canonical text.
- No `memory:` field (it enables Read, Write and Edit). No `model:` override. No Bash.
- No path-scoped `Write(...)` or `Edit(...)` entry and no `disallowedTools` specifier: path
  suffixes in `tools:` are inert and a `disallowedTools` specifier removes the whole tool
  (research section 3.1). Path restriction is enforced only by the write-scope hook.
- Each role preloads the skills it executes (`skills:` frontmatter), and every preloaded skill exists
  (`test_claude_rules_frontmatter.py`).
- Each role's final message carries the SubagentStop result tokens defined below.

| Role | Purpose | Native tools | MCP tools | Preloaded skills |
|---|---|---|---|---|
| `docs-architect` | Inventory the surface and plan the information architecture | Read, Grep, Glob | `run_docs_inventory`, `run_docs_coverage`, `run_docs_check` | `docs-inventory-surface`, `docs-plan-ia` |
| `docs-author` | Write and revise narrative and reference pages | Read, Grep, Glob, Write, Edit | `generate_docs_reference`, `run_docs_check` | `docs-author-page` |
| `docs-reconciler` | Record dispositions, pins and dimensions through the mutation boundary | Read, Grep, Glob | `run_docs_coverage`, `update_docs_ledger`, `validate_docs_artifacts` | `docs-reconcile-behavior` |
| `docs-coverage-reviewer` | Review coverage and accuracy; validate `docs-complete` (read-only) | Read, Grep, Glob | `run_docs_coverage`, `validate_docs_artifacts`, `run_docs_check` | `docs-review-coverage`, `docs-validate` |

Invariants: every docs MCP tool (`run_docs_check`, `run_docs_inventory`, `run_docs_coverage`,
`update_docs_ledger`, `generate_docs_reference`, `validate_docs_artifacts`) is held by at least one
role; `update_docs_ledger` is held only by `docs-reconciler` (OQ-6); only `docs-author` holds Write
and Edit, and only as bare entries restricted by the write-scope hook (OQ-1). The reviewer reports
the `accurate` judgment; the reconciler records it with `set-dimension`.

## Per-Skill Contract

Root steps run `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command <name> ...`.
Only the options verified by 1020 are named here (`init`: `-RepositoryId`, `-Profile`, `-Write`,
`-Force`; `validate-profile`: `-Profile`; global `-Json`, `-Help`, `-RepositoryRoot`). Option
spellings for every other subcommand are taken at execution from the merged
`Invoke-DocsCommand.ps1` dispatch table (`Get-DocsCommandTable` rows); skill text instructs `-Help`
where an option is not yet fixed.

| Skill | Runs as | Subcommands | MCP tools |
|---|---|---|---|
| `documentation-workflow` | root (alias) | none; dispatches to the seven skills below in order inventory, plan, author, reconcile, review, validate | none |
| `docs-init` | root only | `init` (dry run first, then `-Write`; `-Force` only on explicit request), `validate-profile` | none |
| `docs-inventory-surface` | `docs-architect` | `inventory` (root fallback) | `run_docs_inventory` |
| `docs-plan-ia` | `docs-architect` | none | `run_docs_inventory`, `run_docs_coverage`, `run_docs_check` |
| `docs-author-page` | `docs-author` | `generate-reference` (root fallback; dry run unless the write switch) | `generate_docs_reference` (reference families only), `run_docs_check` |
| `docs-reconcile-behavior` | `docs-reconciler` | `update-ledger` (root fallback; dry run unless the write switch) | `run_docs_coverage`, `update_docs_ledger` (operations `set-disposition`, `remove-entry`, `pin`, `unpin`, `set-dimension`, `sync-refs`), `validate_docs_artifacts` |
| `docs-review-coverage` | `docs-coverage-reviewer` | `surface-delta` (root step) | `run_docs_coverage`, `validate_docs_artifacts`, `run_docs_check` |
| `docs-validate` | `docs-coverage-reviewer` or root | `validate` with mode `docs-complete` and the head revision; receipt persistence (write-receipt switch) only from root or CI | `validate_docs_artifacts` (never persists a receipt), `run_docs_check` |

Rules for all skills:

- A skill names only the docs MCP tools listed above and only subcommands owned by earlier-wave
  children: `init`, `validate-profile` (1020); `check` (1021); `inventory` (1022, with 900004 and
  900011 adding analyzers only); `coverage`, `update-ledger`, `validate` (1023);
  `generate-reference` (1024); `surface-delta` (1034).
- Templates live in `docs-author-page/templates/`, outside documentation roots, so `run_docs_check`
  does not scan them. Each carries the five front-matter fields `owner`, `last_reviewed`,
  `audience`, `diataxis_mode`, `surface_refs` with placeholders. Mode mapping: `tutorial.md` ->
  `tutorial`; `how-to.md` -> `how-to`; `explanation.md` and `architecture-overview.md` ->
  `explanation`; `cli-reference.md`, `http-reference.md`, `config-reference.md`, `api-reference.md`
  -> `reference` (prose around the 1024 generated-block markers; `architecture-component` elements
  are not rendered by 1024).
- Codex (`.agents/skills/`) and Copilot (`.github/skills/`) copies name only the docs MCP tools and
  subcommand names, contain no `.claude/` path, and state the prerequisite: the docs helper library
  delivered by the Claude customization push-down and PowerShell 7.4. Root-only steps (`init`,
  `validate-profile`, receipt persistence) are marked unavailable without that library (Q7).
- No skill text names a consuming product (`test_push_down_issue_824_follow_ups.py`) or carries an
  unqualified `spec.md §` citation.

## SubagentStop Output Check

- Entry: `.claude/hooks/validate-docs-role-output.ps1`. It reads the envelope through
  `Read-SubagentStopEnvelope` with the envelope text supplied through an `-InputText` seam, resolves
  the role from `AgentType`, allows any non-docs agent, and blocks through `Exit-SubagentStopBlock`
  (stderr, exit 2) when `Test-DocsRoleOutput` fails. An unhandled error blocks with a fixed
  fail-closed message. The script body is skipped when dot-sourced.
- Helper: `.claude/hooks/docs-role-contract.ps1` (dot-sourced, not registered) with
  `Get-DocsRoleName`, `Get-DocsRoleRequiredToken -Role`, `ConvertFrom-DocsRoleOutput -Text` (pure
  token parser) and `Test-DocsRoleOutput -Role -Text -TestFile <scriptblock>` returning
  `@{ Ok; Message }`. File-existence checks go through the injected `-TestFile` seam.
- Dependencies are loaded through the guarded dot-source pattern (`hook-dependency-guard.ps1`,
  `subagentstop-envelope.ps1`); a dependency failure blocks with exit 2.
- Tokens are one per line in the form `token: value`.

| Role | Required tokens | Validation |
|---|---|---|
| all four | `docs-role`, `docs-result`, `docs-findings` | `docs-role` equals `AgentType`; `docs-result` is `PASS`, `FAIL` or `BLOCKED`; `docs-findings` is a non-negative integer |
| `docs-architect` | `docs-profile`, `docs-snapshot`, `docs-pages-planned`, and a `## Information Architecture` section when the result is `PASS` | both paths repository-relative and existing (seam); count a non-negative integer |
| `docs-author` | `docs-pages-written` (comma-separated list), `docs-check-exit-code` | each path repository-relative, ends `.md`, exists (seam); exit code 0 to 3; `PASS` requires 0 |
| `docs-reconciler` | `docs-ledger-operations`, `docs-update-ledger-exit-code`, `docs-elements-reconciled` (comma-separated element ids or `none`) | count a non-negative integer; exit code 0 to 3; ids match the 1020 element-id pattern; `PASS` requires exit code 0 |
| `docs-coverage-reviewer` | `docs-validate-mode`, `docs-revision`, `docs-validate-exit-code`, `docs-receipt-id` (id or `none`) | mode is `profile`, `ledger`, `matrix` or `docs-complete`; revision is 40 or 64 lowercase hex; exit code 0 to 3; a `FAIL` report with exit code 1 is valid |

- A missing or invalid token blocks with a reason that names the token (repairable).
- When `StopHookActive` is set, the hook blocks only on missing tokens and allows a re-entered stop
  for non-repairable conditions, following `validate-required-artifact-output.ps1`.
- Registration: `.claude/settings.json` `SubagentStop` entry with matcher
  `docs-architect|docs-author|docs-reconciler|docs-coverage-reviewer` and command
  `pwsh -NoProfile -File .claude/hooks/validate-docs-role-output.ps1`.

## Write-Scope Hook Contract

- Entry: `.claude/hooks/enforce-docs-role-write-scope.ps1`, PreToolUse, matcher
  `Write|Edit|MultiEdit|NotebookEdit|Bash`, registered in `.claude/settings.json` with command
  `pwsh -NoProfile -File .claude/hooks/enforce-docs-role-write-scope.ps1`. It uses
  `Get-DocsRoleName` from `docs-role-contract.ps1`.
- Scope: the hook acts only when the payload `agent_type` is one of the four docs roles. An absent
  `agent_type` (main thread) or any other agent is allowed with no output and exit 0, following
  `enforce-epic-invocation-origin.ps1`.
- Deny rules (PreToolUse deny JSON at exit 0, reason naming the rule):
  1. any Write-class call (`Write`, `Edit`, `MultiEdit`, `NotebookEdit`) by `docs-architect`,
     `docs-reconciler` or `docs-coverage-reviewer`;
  2. any `Bash` call by any docs role;
  3. a `docs-author` write whose target, normalized to a repository-relative forward-slash path,
     lies outside the repository root;
  4. a `docs-author` write whose target does not end in `.md`;
  5. a `docs-author` write whose target equals the profile path or any profile `artifact_paths`
     value (`inventory_snapshot`, `coverage_ledger`, `parity_matrix`, `evidence_pins`,
     `validation_receipt`);
  6. a `docs-author` write whose target lies under `.claude/`, `.github/`, `.codex/` or `.agents/`.
- Allow: a `docs-author` write of a `.md` page that matches no deny rule.
- Profile access: the profile is read from the default path `docs/documentation-estate/docs-profile.json`
  through an injected read seam. An absent, unreadable or unparseable profile leaves rules 1 to 4
  and 6 in force. The plan records how `artifact_paths` is parsed and confirms that the choice keeps
  `test_push_down_pack_manifest_dependency_closure.py` passing.
- Dependency failure follows the guarded-load pattern and returns a deny.
- Ledger, matrix, pin and receipt writes therefore occur only through `update_docs_ledger` (and the
  root or CI receipt switch).

## Mirror Set

All copies are hand-authored; the generators named in the epic do not produce them (OQ-4). Bundle
copies are byte-identical to their source.

| Artifact | Locations |
|---|---|
| Agent (per role) | `.github/agents/<role>.agent.md` (canonical); `extensions/drm-copilot/resources/customizations/.github/agents/<role>.agent.md`; `.claude/agents/<role>.md` (host rewrite: Claude tool forms, no `.github/`, `drmcopilotextension` or `.agent.md` text); `extensions/drm-copilot/resources/claude-customizations/.claude/agents/<role>.md`; `.codex/agents/<role>.toml` (base wrapper with the required wrapper fragments, after the `discovery-capability-sentinel` precedent, no `model` lines); `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/<role>.toml` |
| Skill (per skill) | `.github/skills/<skill>/SKILL.md` (canonical); `extensions/drm-copilot/resources/customizations/.github/skills/<skill>/SKILL.md`; `.claude/skills/<skill>/SKILL.md` (role links to `.claude/agents/`); `extensions/drm-copilot/resources/claude-customizations/.claude/skills/<skill>/SKILL.md`; `.agents/skills/<skill>/SKILL.md` (role links to `.codex/agents/`, no `.claude/` text); `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<skill>/SKILL.md` |
| Page template | `docs-author-page/templates/<name>.md` under each of the six skill locations above |
| Hook | `.claude/hooks/<hook>.ps1` and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/<hook>.ps1` |

Manifests: Claude `pack-manifests/core.json` lists each `.claude/agents/<role>.md`, each
`.claude/skills/<skill>/SKILL.md`, each template file and each hook file. Codex
`pack-manifests/core.json` lists each `.codex/agents/<role>.toml`, each
`.agents/skills/<skill>/SKILL.md` and each template file, in the formatting the Codex generator
emits. The Copilot bundle has no manifest.

## Routing and Settings Edits

- `config/orchestration-routing.json`: a new top-level `docs_operations` block keyed by skill name,
  each entry `{ "logical_agent": "<role or root>", "mcp_tools": [ ... ] }`, with the values of the
  per-skill table (`documentation-workflow` and `docs-init` map to `root`; `docs-validate` maps to
  `docs-coverage-reviewer`). The bundled copy
  `extensions/drm-copilot/resources/config/orchestration-routing.json` is edited identically. No
  runtime reader consumes the block; the roles suite pins it (OQ-5).
- `.claude/settings.json`: one `SubagentStop` entry and one `PreToolUse` entry as defined above; the
  bundled copy `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` is
  edited identically. Edits introduce no CRLF.
- No `.codex/config.toml` edit (OQ-2).

## Tests

Runner: Pester through `Invoke-PoshQCTest` from a `sh`-launched PowerShell 7 on the branch
(execution-environment brief `## PowerShell Route and PoshQC MCP Limits`). Counts and coverage come
from the JUnit and coverage files, not from PoshQC MCP summaries.

| Suite | Location | CI jobs |
|---|---|---|
| `docs-role-contract.Tests.ps1` | `tests/scripts/claude-hooks/` | `poshqc / PowerShell QC` (shards, with coverage) and `poshqc / PowerShell hook suites (Linux)` |
| `validate-docs-role-output.Tests.ps1` | `tests/scripts/claude-hooks/` | same as above |
| `enforce-docs-role-write-scope.Tests.ps1` | `tests/scripts/claude-hooks/` | same as above |
| `docs-authoring-roles.Tests.ps1` (allowlists, mirrors and manifests, registration, routing block, skill references, templates) | `tests/scripts/claude-runtime/` | `poshqc / PowerShell QC` |

Test rules:

- Tests create no temporary files: envelope and payload text is in memory, file existence and
  profile reads go through mocked seams, and structural tests read committed files only.
- Hook suites cover each token rule, each deny rule, the non-docs pass-through, the
  `StopHookActive` path, envelope anomalies and dependency failure.
- Linux job compatibility: `Join-Path`, forward-slash relative paths, exact file-name case, no drive
  letters (brief `## CI-Only Failure Classes`).
- Each suite removes in `AfterAll` what it adds to the session.
- Skill-reference checks assert membership against `extensions/drm-copilot/src/repo-automation-tool-names.ts`
  (900007) and the merged dispatch table, not set equality.
- Existing contract tests run unmodified: those listed in brief
  `## Contract Tests That Pin Mirrored Files`, plus `test_codex_full_migration_inventory.py`,
  `test_discovery_publication_contracts.py`, `test_orchestration_routing_config_parity.py`,
  `test_codex_topology_policy_config_parity.py`, `test_skill_bundle_contract_repo.py`,
  `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, and the Codex generator
  `--check`.
- Isolation runs follow brief `## Test Isolation Checks`.

## Constraints & Risks

- Language rule: hooks are PowerShell; no new Python or TypeScript.
- Dependencies: the docs MCP tool names in `repo-automation-tool-names.ts` (900007) and the
  dispatch rows of 1021, 1022, 1023, 1024 and 1034 must be merged into the integration branch
  before skill text and the skill-reference test are finalized.
- Batch budget: six non-test PowerShell production files (three hooks and three bundle copies)
  exceed the direct-mode cap; execution runs in the item worktree under a non-terminal exempt route
  (brief `## Batch Budget`).
- Hook behavior on the branch is proven by Pester only (brief `## Hook Execution Context`).
- The PreToolUse payload must carry `agent_type` for project subagents in the installed Claude Code
  version; the orchestrator confirms this (research item 3). If it does not, OQ-1 falls back to D-B.
- The Copilot bundle `customizations/.github/` copy is not in the epic file list and is the copy
  most likely to be missed; `test_copilot_bundle_mirrors_every_scoped_github_file` requires it.
- File size: each hook below 500 logical lines; the roles suite is split by concern before 500.
- Codex and Copilot roles run without stop and write hooks (OQ-2).

## Acceptance Criteria

- [ ] In `.claude/agents/`, the tool lists of `docs-architect`, `docs-reconciler` and `docs-coverage-reviewer` contain no `Write`, `Edit`, `MultiEdit`, `NotebookEdit` or `Bash` entry; the tool list of `docs-author` contains bare `Write` and `Edit` and no `Bash`; no docs role contains a path-scoped `Write(` or `Edit(` entry, a `disallowedTools` field or a `memory:` field; `docs-authoring-roles.Tests.ps1` asserts each of these, and asserts the same exclusions on the `.github/agents/` and `.codex/agents/` copies.
- [ ] Each role's MCP tool list equals the role table in `## Role and Tool-Allowlist Contract`, `update_docs_ledger` appears only in `docs-reconciler`, and each of `run_docs_check`, `run_docs_inventory`, `run_docs_coverage`, `update_docs_ledger`, `generate_docs_reference`, `validate_docs_artifacts` is held by at least one role (`docs-authoring-roles.Tests.ps1`).
- [ ] `enforce-docs-role-write-scope.Tests.ps1` proves, with in-memory payloads and a mocked profile seam, that the hook denies a `docs-author` write to the profile path and to each `artifact_paths` value (`inventory_snapshot`, `coverage_ledger`, `parity_matrix`, `evidence_pins`, `validation_receipt`), to a non-`.md` path, to a path under `.claude/`, `.github/`, `.codex/` or `.agents/`, and to a path outside the repository root; denies every Write-class call by `docs-architect`, `docs-reconciler` and `docs-coverage-reviewer` and every `Bash` call by any docs role; allows a `docs-author` write of a `.md` page under a documentation root; allows every call with no `agent_type` or a non-docs `agent_type`; and that each deny reason names its rule.
- [ ] With an absent or unparseable profile, the write-scope hook still denies non-`.md` and protected-directory writes by `docs-author`, and a dependency-load failure returns a deny (`enforce-docs-role-write-scope.Tests.ps1`).
- [ ] The SubagentStop check blocks a role output that lacks its required result fields: for each role, `validate-docs-role-output.Tests.ps1` shows exit 2 with a stderr reason naming the missing token for each common and role-specific token removed in turn, and exit 0 for a complete valid output.
- [ ] The SubagentStop check blocks invalid token values (result outside `PASS|FAIL|BLOCKED`, non-integer counts, exit codes outside 0 to 3, `PASS` with a non-zero exit code, a non-relative or absent path through the seam, a revision outside 40 or 64 lowercase hex, an element id outside the 1020 pattern, a `docs-role` value different from `AgentType`), allows a non-docs agent, applies the `StopHookActive` rule, and blocks fail-closed on an envelope anomaly, a dependency failure and an unhandled error (`validate-docs-role-output.Tests.ps1`, `docs-role-contract.Tests.ps1`).
- [ ] Every skill references only MCP tools and subcommands defined in the epic's earlier children: in every host and bundle copy of each skill listed in `## Scope`, each MCP tool name is one of the docs MCP tools and is defined in `extensions/drm-copilot/src/repo-automation-tool-names.ts`, and each `-Command <name>` is a row of the merged `Invoke-DocsCommand.ps1` dispatch table (`docs-authoring-roles.Tests.ps1`).
- [ ] The `.agents/skills/` and `.github/skills/` copies of each skill listed in `## Scope` contain no `.claude/` text and state the Claude push-down docs library and PowerShell 7.4 prerequisite (`docs-authoring-roles.Tests.ps1`).
- [ ] Mirror and push-down parity tests pass for all new agents and skills: each role exists at every agent location and each skill and template at every skill location listed in `## Mirror Set`, every bundle copy is byte-identical to its source, every Claude and Codex file is listed in its `pack-manifests/core.json` (`docs-authoring-roles.Tests.ps1`), and the existing contract tests named in `## Tests` pass without modification, including the Codex generator `--check`.
- [ ] Each of the templates `tutorial.md`, `how-to.md`, `explanation.md`, `cli-reference.md`, `http-reference.md`, `config-reference.md`, `api-reference.md` and `architecture-overview.md` exists under `docs-author-page/templates/` with the fields `owner`, `last_reviewed`, `audience`, `diataxis_mode` and `surface_refs` and the `diataxis_mode` value of the mode mapping (`docs-authoring-roles.Tests.ps1`).
- [ ] `.claude/settings.json` contains the `SubagentStop` entry for `validate-docs-role-output.ps1` with matcher `docs-architect|docs-author|docs-reconciler|docs-coverage-reviewer` and the `PreToolUse` entry for `enforce-docs-role-write-scope.ps1` with matcher `Write|Edit|MultiEdit|NotebookEdit|Bash`; the bundled copy is byte-identical; `hook-dependency-failure.Claude.Tests.ps1` and `hook-dependency-guard-completeness.Tests.ps1` pass without modification.
- [ ] `config/orchestration-routing.json` contains a `docs_operations` block whose entries map each skill listed in `## Scope` to the logical agent and MCP tools of `## Per-Skill Contract`, each listed tool is held by that role, the bundled copy is byte-identical, `routes`, `generated_agent_families` and `discovery_operations` are unchanged, and `test_orchestration_routing_config_parity.py` and `test_codex_topology_policy_config_parity.py` pass.
- [ ] No Python or TypeScript file is added or modified and `.codex/config.toml` is unchanged: `git diff --name-only` from the merge base of the integration branch lists no path ending in `.py`, `.ts`, `.tsx`, `.js`, `.mjs` or `.cjs` and no `.codex/config.toml`; the plan's artifact classification table lists every created or edited file with class, language and permitting rule.
- [ ] No test creates a temporary file: no new suite contains `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName` or `$env:TEMP`.
- [ ] Pester line coverage is at least 85% for each new production file under `.claude/hooks/`, read from `artifacts/pester/powershell-coverage.xml`, with no production file excluded; figures are recorded under `<FEATURE>/evidence/qa-gates/`.
- [ ] The new suites pass in seeded shuffled file-order runs in one process, with the seed count and recording rules of the execution-environment brief `## Test Isolation Checks`, and in a fresh single-process run over `tests/scripts`, recorded under `<FEATURE>/evidence/regression-testing/`.
- [ ] (CI-dependent) `poshqc / PowerShell QC`, `poshqc / PowerShell hook suites (Linux)` and the `quality-checks7 / Code Quality & Tests` jobs pass on the pull request head.

## Decisions Later Children Must Honor

For 900010 (documentation-estate template and onboarding):

- Role names, native and MCP allowlists of `## Role and Tool-Allowlist Contract`; `update_docs_ledger`
  is held only by `docs-reconciler`; no docs role carries `memory:`.
- Skill names, the `documentation-workflow` dispatch order, the `docs_operations` skill-to-role map,
  and the rule that `docs-init` and receipt persistence are root-only steps.
- Template paths `.claude/skills/docs-author-page/templates/<name>.md` (and host copies) with the five
  front-matter fields and the mode mapping; the epic template's wave 0 references them by these
  paths.
- The SubagentStop result tokens of `## SubagentStop Output Check`, which onboarding text and any
  orchestration of the roles must request in delegation prompts.
- The write-scope rules of `## Write-Scope Hook Contract` and the Codex and Copilot prerequisite
  statement, which the onboarding guide states.
- Any later child that adds a docs role extends `Get-DocsRoleName`, the SubagentStop matcher and the
  `docs_operations` block together.

## Owner Questions

Each item below is adopted as a provisional default by orchestrator ruling. None is decided beyond
that default; an owner answer may change the affected criteria through a specification revision.

1. **OQ-1 - Write-scope enforcement.** Provisional default: include the PreToolUse hook
   `enforce-docs-role-write-scope.ps1` as the enforcement of the no-Write/Edit-on-ledger/matrix rule
   for `docs-author`; the other three roles get no Write or Edit. Fallback recorded: `docs-author`
   without Write (design D-B), returning page text to the root.
2. **OQ-2 - Codex and Copilot hooks and tool enablement.** Provisional default: this child does not
   edit `.codex/config.toml`; Codex and Copilot role copies carry no stop or write hook. Open:
   whether the docs tools are enabled in `.codex/config.toml` and whether unhooked Codex and Copilot
   roles are acceptable; this may belong to 900007.
3. **OQ-3 - Codex variants.** Provisional default: one base Codex wrapper per docs role, no `-c1` to
   `-c4` variants; existing Python generators run in `--check` form only and are never extended.
4. **OQ-4 - Mirror authorship and epic correction.** Provisional default: mirrors are hand-authored
   byte-identical copies (the named generators do not produce them), and the Copilot bundle
   `extensions/drm-copilot/resources/customizations/.github/` is included. Open: correct the epic
   `### 900009` Files bullet, which names the generators as producers and omits the Copilot bundle.
5. **OQ-5 - Routing entry.** Provisional default: keep a `docs_operations` block in
   `config/orchestration-routing.json` and its bundled copy (skill-to-role routing entries, as the
   epic requires). It has no runtime reader and is pinned by Pester.
6. **OQ-6 - Accuracy recording.** Provisional default: `docs-coverage-reviewer` stays read-only; only
   `docs-reconciler` holds `update_docs_ledger`.
7. **Q7 - Codex reach of the docs lib.** Provisional default: the docs lib ships in the Claude bundle
   only; Codex and Copilot copies name only the docs MCP tools and subcommands, contain no `.claude/`
   path, and state the Claude push-down prerequisite.
8. **Subcommand option spellings.** Provisional default: option names beyond those 1020 verifies are
   taken from the merged `Invoke-DocsCommand.ps1` dispatch table at execution; this specification
   names subcommands and MCP tools, not unverified option names.

## Definition of Done

- [ ] Acceptance criteria mapped to Pester suites, existing contract tests or commands
- [ ] Toolchain pass completed (format, PSScriptAnalyzer lint, contract tests, Pester) in a single clean pass
- [ ] Forbidden-token scan over every changed file reports no consumer-repository identifier, absolute path or host name
- [ ] Evidence written under `docs/features/active/2026-10-30-docs-authoring-workflow-1037/evidence/<kind>/`

## Seeded Test Conditions (from potential)

- [ ] Pester suite for the SubagentStop output check (pass and block cases per role)
- [ ] Tool-allowlist test over the four agent files
- [ ] Mirror and push-down parity tests for agents and skills
