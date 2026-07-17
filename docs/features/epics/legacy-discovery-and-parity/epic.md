---
epic: legacy-discovery-and-parity
integration_branch: epic/legacy-discovery-and-parity-integration
created_at: 2026-07-17T10:10:00Z
# issue_num values below are PLACEHOLDERS (9001-9014) assigned at planning time.
# They are back-filled with real GitHub issue numbers from each child's promotion
# receipt as preparation completes. depends_on uses stable feature_folder basenames
# (resolved via the manifest union index), so it does not drift during back-fill.
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
  - issue_num: 9001
    feature_folder: legacy-discovery-config-contract
    depends_on: []
  - issue_num: 9002
    feature_folder: legacy-discovery-schemas
    depends_on: []
  - issue_num: 9003
    feature_folder: legacy-discovery-validators
    depends_on: [legacy-discovery-config-contract, legacy-discovery-schemas]
  - issue_num: 9004
    feature_folder: legacy-discovery-hooks
    depends_on: [legacy-discovery-validators]
  - issue_num: 9005
    feature_folder: legacy-discovery-init-templates
    depends_on: [legacy-discovery-config-contract, legacy-discovery-schemas]
  - issue_num: 9006
    feature_folder: legacy-discovery-analyzer-framework
    depends_on: [legacy-discovery-config-contract, legacy-discovery-schemas]
  - issue_num: 9007
    feature_folder: legacy-discovery-agent-roles
    depends_on: [legacy-discovery-config-contract, legacy-discovery-schemas]
  - issue_num: 9008
    feature_folder: legacy-discovery-skills
    depends_on: [legacy-discovery-analyzer-framework, legacy-discovery-agent-roles]
  - issue_num: 9009
    feature_folder: legacy-discovery-acceptance-scenarios
    depends_on: [legacy-discovery-schemas]
  - issue_num: 9010
    feature_folder: legacy-discovery-reports
    depends_on: [legacy-discovery-schemas, legacy-discovery-validators]
  - issue_num: 9014
    feature_folder: legacy-discovery-dotnet-vsto-analyzers
    depends_on: [legacy-discovery-analyzer-framework]
  - issue_num: 9011
    feature_folder: legacy-discovery-mcp-vscode
    depends_on: [legacy-discovery-validators, legacy-discovery-init-templates, legacy-discovery-analyzer-framework, legacy-discovery-dotnet-vsto-analyzers, legacy-discovery-acceptance-scenarios, legacy-discovery-reports]
  - issue_num: 9012
    feature_folder: legacy-discovery-publishing
    depends_on: [legacy-discovery-schemas, legacy-discovery-hooks, legacy-discovery-init-templates, legacy-discovery-agent-roles, legacy-discovery-skills]
  - issue_num: 9013
    feature_folder: legacy-discovery-documentation
    depends_on: [legacy-discovery-skills, legacy-discovery-mcp-vscode, legacy-discovery-publishing]
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
configuration contract (#9001), versioned JSON schemas (#9002), validators (#9003),
completion-gate hooks (#9004), initialization and templates (#9005), the analyzer framework
and repository inventory (#9006), generic agent roles (#9007), generic skills (#9008),
acceptance-scenario generation (#9009), reports (#9010), MCP and VS Code integration (#9011),
cross-ecosystem publishing (#9012), documentation (#9013), and the .NET/VSTO analyzers
(#9014). Python CLI (`dev.discovery.*`) commands are delivered inside each owning functional
feature (each command is a module plus one `pyproject.toml` script line), and the MCP/VS Code
exposure layer (#9011) wraps those commands.

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
  - **legacy-discovery-config-contract** (#9001, C3) — repository-local domain-profile
    configuration contract and its parser. Foundational cross-module contract.
  - **legacy-discovery-schemas** (#9002, C3) — seven versioned JSON schemas plus the
    schema-versioning convention. Foundational cross-module contract.
- Wave 1
  - **legacy-discovery-validators** (#9003, C2) — deterministic validators for the config and
    schemas. Depends on #9001, #9002.
  - **legacy-discovery-init-templates** (#9005, C2) — initialization command and artifact
    templates. Depends on #9001, #9002.
  - **legacy-discovery-analyzer-framework** (#9006, C3) — language-neutral analyzer framework
    and repository/project inventory. Depends on #9001, #9002.
  - **legacy-discovery-agent-roles** (#9007, C3) — four generic agent personas. Depends on
    #9001, #9002.
  - **legacy-discovery-acceptance-scenarios** (#9009, C3) — executable acceptance-scenario
    generation. Depends on #9002.
- Wave 2
  - **legacy-discovery-hooks** (#9004, C2) — completion-gate hooks invoking the validators.
    Depends on #9003.
  - **legacy-discovery-skills** (#9008, C3) — generic discovery/parity workflow skills.
    Depends on #9006, #9007.
  - **legacy-discovery-reports** (#9010, C2) — coverage, parity, and completion reports.
    Depends on #9002, #9003.
  - **legacy-discovery-dotnet-vsto-analyzers** (#9014, C4) — .NET/C# inventory and VSTO/Office
    analyzers. Research-heavy, novel; depends on #9006.
- Wave 3
  - **legacy-discovery-mcp-vscode** (#9011, C3) — MCP tool and VS Code command exposure of the
    discovery CLI commands. Depends on #9003, #9005, #9006, #9014, #9009, #9010.
  - **legacy-discovery-publishing** (#9012, C2) — cross-ecosystem publishing (resources/
    mirrors, Codex converter registration, pack-manifest selection). Depends on #9002, #9004,
    #9005, #9007, #9008.
- Wave 4
  - **legacy-discovery-documentation** (#9013, C2) — capability-level end-to-end documentation
    and consumer onboarding. Depends on #9008, #9011, #9012.

Each child keeps its own git branch/worktree and its own independent active/ -> completed/
lifecycle. `epic-status.md` in this directory is a generated projection of the epic checkpoint;
it is never the source of the DAG and is never hand-authored.
