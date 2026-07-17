---
epic: legacy-discovery-and-parity
integration_branch: epic/legacy-discovery-and-parity-integration
created_at: 2026-07-17T10:10:00Z
# Resolved manifest. issue_num values are the real GitHub issue numbers from each
# child's promotion; feature_folder values are the concrete active-folder basenames
# (docs/features/active/<basename>); depends_on uses issue_num values (the canonical
# primary-key form). The DAG is cycle-free and every depends_on entry resolves.
intent:
  epic_type: enabler
  business_outcome_hypothesis: A domain-neutral discovery-and-parity capability lets migrating repositories (TaskMaster to TMW first) inventory legacy behavior, define source-to-target parity, and generate acceptance scenarios without bespoke per-repo tooling.
  leading_indicators:
    - TaskMaster authors a domain profile and produces a coverage ledger and parity matrix using only the reusable framework.
    - No domain-specific identifier appears in the core framework source.
  nfrs:
    - Core framework is domain-neutral; all domain specificity is runtime configuration.
    - Deterministic validators and schemas; line coverage >= 85%, branch coverage >= 75%.
features:
  - issue_num: 360
    feature_folder: 2026-07-17-legacy-discovery-config-contract-360
    depends_on: []
  - issue_num: 359
    feature_folder: 2026-07-17-legacy-discovery-schemas-359
    depends_on: []
  - issue_num: 361
    feature_folder: 2026-07-17-legacy-discovery-validators-361
    depends_on: [360, 359]
  - issue_num: 366
    feature_folder: 2026-07-17-legacy-discovery-hooks-366
    depends_on: [361]
  - issue_num: 362
    feature_folder: 2026-07-17-legacy-discovery-init-templates-362
    depends_on: [360, 359]
  - issue_num: 363
    feature_folder: 2026-07-17-legacy-discovery-analyzer-framework-363
    depends_on: [360, 359]
  - issue_num: 365
    feature_folder: 2026-07-17-legacy-discovery-agent-roles-365
    depends_on: [360, 359]
  - issue_num: 367
    feature_folder: 2026-07-17-legacy-discovery-skills-367
    depends_on: [363, 365]
  - issue_num: 364
    feature_folder: 2026-07-17-legacy-discovery-acceptance-scenarios-364
    depends_on: [359]
  - issue_num: 368
    feature_folder: 2026-07-17-legacy-discovery-reports-368
    depends_on: [359, 361]
  - issue_num: 369
    feature_folder: 2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369
    depends_on: [363]
  - issue_num: 370
    feature_folder: 2026-07-17-legacy-discovery-mcp-vscode-370
    depends_on: [361, 362, 363, 369, 364, 368]
  - issue_num: 372
    feature_folder: 2026-07-17-legacy-discovery-publishing-372
    depends_on: [359, 366, 362, 365, 367]
  - issue_num: 371
    feature_folder: 2026-07-17-legacy-discovery-documentation-371
    depends_on: [367, 370, 372]
---

# Legacy Discovery and Parity - Epic

- Issue: #<tracking-issue> (assigned when the epic tracking issue is created)
- Owner: dan@danmoisan.org
- Last Updated: 2026-07-17

## Goal

Build a reusable, domain-neutral legacy-system discovery and parity-definition capability
inside `drm-copilot`. The capability enables a repository migrating a legacy application to a
modern architecture to perform agentic discovery of current behavior, feature/workflow
inventory, legacy coverage, runtime characterization, undocumented/contradictory behavior,
source-to-target parity, product decisions, and executable acceptance scenarios. The first
consumers are `drmoisan/TaskMaster` (legacy source) and `drmoisan/TMW` (modern target). The
full objective is recorded in `objective-source.md` in this directory.

## Scope

In scope: the fourteen child features enumerated in `## Decomposition` — the domain-profile
configuration contract (#360), versioned JSON schemas (#359), validators (#361),
completion-gate hooks (#366), initialization and templates (#362), the analyzer framework
and repository inventory (#363), generic agent roles (#365), generic skills (#367),
acceptance-scenario generation (#364), reports (#368), MCP and VS Code integration (#370),
cross-ecosystem publishing (#372), documentation (#371), and the .NET/VSTO analyzers
(#369). Python CLI (`dev.discovery.*`) commands are delivered inside each owning functional
feature (each command is a module plus one `pyproject.toml` script line), and the MCP/VS Code
exposure layer (#370) wraps those commands.

## Non-Goals

- No domain-specific (TaskMaster/TMW/Outlook/VSTO/email/task-management) behavior in the core
  reusable framework; all domain specificity is supplied at runtime via the domain profile.
- No execution of an actual migration; this epic delivers the discovery/parity capability, not
  a migration.
- No integration with, or duplication of the command/agent names of, the unrelated installed
  `code-modernization` Claude Code plugin.
- No C# source in this repository; analyzers read consumer-repository source at an external
  path declared in the domain profile.

## Shared Design

- **Domain neutrality (invariant across all children).** The core framework must contain no
  domain-specific identifiers. Domain specificity is configuration, read from the domain
  profile (#9001) at runtime.
- **Schema-versioning convention.** #9002 defines the single versioning convention (directory
  layout, version field, `$schema` self-reference) reused by every schema consumer. It reuses
  `scripts/dev_tools/validate_json.py`'s governed-glob and `$schema` resolution machinery
  rather than introducing new schema-loading code.
- **Validator pattern.** #9003 and all validators follow the canonical
  `validate_<artifact>_text(text, ...) -> list[str]` contract with an argparse subparser CLI,
  mirroring `validate_orchestration_artifacts.py`.
- **Hook conventions.** #9004 hooks follow the repository's PowerShell PreToolUse/SubagentStop
  I/O conventions (`$env:CLAUDE_TOOL_INPUT` / `$env:CLAUDE_HOOK_INPUT`, JSON stdout decision
  payloads, dot-source guard) and register in `.claude/settings.json`.
- **CLI-before-MCP-before-VS-Code.** Each functional feature ships its own `dev.discovery.*`
  Python command; #9011 wraps those commands as MCP tools (tool-names, tool-definitions,
  dispatch switch, handler, service call in lockstep) and then as VS Code commands.
- **Mirror contract.** Every asset added under `.claude/`, `.github/`, `.codex/`+`.agents/`
  must be mirrored into the matching `resources/` subtree (#9012) or the push-down contract
  tests fail.
- **Quality gates.** Every child satisfies the repository quality-tier policy: format, lint,
  type-check, architecture, unit tests, line coverage >= 85%, branch coverage >= 75%, with
  tests co-located in the mirrored `tests/` tree.

## Decomposition

Waves are computed by longest-path layering over the `depends_on` DAG
(`scripts/dev_tools/epic_wave_computation.py`). Complexity bands use the `model_policy` scale
in `config/orchestration-routing.json`.

- Wave 0
  - **legacy-discovery-config-contract** (#360, C3) — repository-local domain-profile
    configuration contract and its parser. Foundational cross-module contract.
  - **legacy-discovery-schemas** (#359, C3) — seven versioned JSON schemas plus the
    schema-versioning convention. Foundational cross-module contract.
- Wave 1
  - **legacy-discovery-validators** (#361, C2) — deterministic validators for the config and
    schemas. Depends on #360, #359.
  - **legacy-discovery-init-templates** (#362, C2) — initialization command and artifact
    templates. Depends on #360, #359.
  - **legacy-discovery-analyzer-framework** (#363, C3) — language-neutral analyzer framework
    and repository/project inventory. Depends on #360, #359.
  - **legacy-discovery-agent-roles** (#365, C3) — four generic agent personas. Depends on
    #360, #359.
  - **legacy-discovery-acceptance-scenarios** (#364, C3) — executable acceptance-scenario
    generation. Depends on #359.
- Wave 2
  - **legacy-discovery-hooks** (#366, C2) — completion-gate hooks invoking the validators.
    Depends on #361.
  - **legacy-discovery-skills** (#367, C3) — generic discovery/parity workflow skills.
    Depends on #363, #365.
  - **legacy-discovery-reports** (#368, C2) — coverage, parity, and completion reports.
    Depends on #359, #361.
  - **legacy-discovery-dotnet-vsto-analyzers** (#369, C4) — .NET/C# inventory and VSTO/Office
    analyzers. Research-heavy, novel; depends on #363.
- Wave 3
  - **legacy-discovery-mcp-vscode** (#370, C3) — MCP tool and VS Code command exposure of the
    discovery CLI commands. Depends on #361, #362, #363, #369, #364, #368.
  - **legacy-discovery-publishing** (#372, C2) — cross-ecosystem publishing (resources/
    mirrors, Codex converter registration, pack-manifest selection). Depends on #359, #366,
    #362, #365, #367.
- Wave 4
  - **legacy-discovery-documentation** (#371, C2) — capability-level end-to-end documentation
    and consumer onboarding. Depends on #367, #370, #372.

Each child keeps its own git branch/worktree and its own independent active/ -> completed/
lifecycle. `epic-status.md` in this directory is a generated projection of the epic checkpoint;
it is never the source of the DAG and is never hand-authored.
