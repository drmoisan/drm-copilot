# Objective (Source of Record)

> Provenance note: The full original `/epic-plan` invocation prompt is held in the
> parent (main) session as the authoritative source of record. This file reconstructs
> the objective from the structural outline supplied to `epic-planner` at delegation
> time. It is the durable decomposition input and the artifact against which
> feature-review traces acceptance criteria. Where the parent session's verbatim text
> and this reconstruction differ in wording, the parent session prompt governs; this
> file governs decomposition scope.

## Objective

Develop a reusable legacy-system discovery and parity-definition capability within the
`drm-copilot` repository ("legacy-discovery-and-parity").

The capability must support repositories migrating an existing application to a modern
architecture by enabling agentic discovery of:

- current system behavior;
- feature and workflow inventory;
- legacy implementation coverage;
- runtime characterization;
- undocumented and contradictory behavior;
- source-to-target parity;
- product decisions;
- executable acceptance scenarios.

The implementation must remain domain-neutral. It must not contain TaskMaster-, TMW-,
Outlook-, VSTO-, email-, or task-management-specific behavior in the core reusable
framework.

The immediate consumers will be:

- `drmoisan/TaskMaster`, which will provide legacy-system context, feature contracts,
  runtime evidence, characterization scenarios, and coverage information;
- `drmoisan/TMW`, which will provide the modern implementation, target architecture
  decisions, parity status, and verification tests.

The work in this repository must provide reusable workflow mechanics, schemas, agents,
skills, validators, hooks, templates, analyzers, CLI commands, MCP surfaces, publishing
support, and documentation.

## Required Operating Mode

The core framework is domain-neutral. All domain-specific behavior (which repository to
analyze, what technology stack, what artifact naming) is supplied at runtime through a
repository-local domain-profile configuration contract, never hardcoded in the framework.

## Scope

1. **Generic Agent Roles** — four reusable, domain-neutral agent personas:
   - Legacy Parity Analyst — reasons about source-to-target parity from feature contracts
     and parity-matrix evidence.
   - Runtime Characterization Analyst — reasons about observed runtime behavior and
     characterization scenarios.
   - Requirements Reconciler — reconciles undocumented, contradictory, or ambiguous
     behavior into product-decision records.
   - Migration Coverage Reviewer — reviews legacy implementation coverage against the
     coverage ledger.

2. **Generic Skills** — reusable workflow-mechanics skills that sequence the discovery and
   parity-definition workflow, invoke the analyzers, and produce the machine-readable
   artifacts. Skills must remain domain-neutral and drive behavior from the domain profile.

3. **Repository-Local Configuration Contract** — a domain-profile config that a consumer
   repository authors to declare its legacy source location, target location, technology
   stack, and artifact conventions. Must define the parser (real PyYAML vs the repo's
   existing hand-rolled frontmatter regex convention — an explicit specification decision).

4. **Machine-Readable Schemas** — seven versioned JSON schemas with an explicit
   schema-versioning convention (the repository has no existing versioning layout):
   - Feature Contract
   - Coverage Ledger
   - Runtime Characterization Scenario
   - Parity Matrix
   - Unspecified Behavior Record
   - Product Decision Record
   - Evidence Reference

5. **Validators** — deterministic validators for the domain-profile config and each schema,
   following the repository's canonical `validate_<artifact>_text(text) -> list[str]` pattern
   with an argparse subparser CLI surface.

6. **Completion Gates and Hooks** — PowerShell PreToolUse / SubagentStop hooks that enforce
   discovery-artifact completion gates by invoking the validators, following the repository's
   canonical hook conventions.

7. **Initialization and Templates** — an initialization command and artifact templates that
   scaffold a consumer repository's discovery workspace and instantiate each schema.

8. **Generic Static Analyzers** — language-neutral repository/project inventory plus
   stack-specific analyzers that read a consumer repository's source (outside this repo, at
   the path the domain profile points at):
   - Repository / project inventory (language-neutral: solution/project enumeration, file
     inventory).
   - .NET / C# inventory (namespace/type enumeration, event-subscription detection).
   - VSTO / Office analyzer (Ribbon-XML, COM-interop pattern detection).
   Parsing strategy (regex/plain-text vs a heavy AST/Roslyn dependency) is an explicit
   specification decision; regex/plain-text is consistent with repository precedent.

9. **CLI and MCP Integration** — Python CLI commands under the `dev.discovery.*` namespace
   (Poetry console-script entries), TypeScript MCP tool exposure, and VS Code command
   exposure. CLI commands exist before the MCP tools that wrap them, which exist before the
   VS Code commands that surface them.

10. **Cross-Ecosystem Publishing** — mirror all new customization assets (agents, skills,
    hooks, schemas, templates) into the `resources/` mirror subtrees enforced by the push-down
    contract tests, register any new asset categories in the Codex-native converter if
    required, and select the appropriate push-down pack manifest so consumer repositories
    (TaskMaster, TMW) receive the capability via the existing push-down tooling.

11. **Acceptance-Scenario Generation** — generate executable acceptance scenarios from
    feature contracts and parity/characterization evidence.

12. **Reports** — coverage report, parity report, and completion report rendered
    deterministically from the machine-readable artifacts.

13. **Documentation** — capability-level documentation covering the end-to-end discovery and
    parity workflow, the domain-profile authoring contract, and consumer onboarding
    (TaskMaster / TMW).

14. **Testing** — tests at every layer per repository quality-tier policy (line >= 85%, branch
    >= 75%): Python pytest, PowerShell Pester, TypeScript Jest.

15. **Non-Goals** — no domain-specific behavior in the core framework; no execution of a
    migration; no integration with the unrelated installed `code-modernization` plugin; no
    duplication of that plugin's command names.

## Architectural Boundaries

- The core reusable framework must be domain-neutral: no TaskMaster/TMW/Outlook/VSTO/email/
  task-management-specific behavior.
- All domain specificity is supplied at runtime through the domain-profile configuration
  contract.
- Analyzers read consumer-repository source from an external path declared in the domain
  profile; this repository contains no C# source of its own.

## Required Research Questions (delegated to per-feature preparation research)

- Domain-profile parser: adopt PyYAML (declared but unused dependency) or continue the
  hand-rolled frontmatter regex convention.
- Schema-versioning convention: directory layout (`schemas/vN/`), version field, and
  `$schema` self-reference strategy reusing `validate_json.py`'s governed-glob machinery.
- Analyzer parsing strategy: regex/plain-text vs Roslyn/AST (no AST dependency exists today).
- Codex-native converter: whether new skill/agent categories require registration in
  `codex_native_converter/mapping.py` and `classifier.py` or whether mirroring is purely
  structural.
- Push-down pack-manifest placement: `core` (always pushed) vs a language-neutral pack.

## Required Acceptance Criteria (capability-level)

- The core framework contains no domain-specific identifiers.
- Each schema validates its conforming and rejects its non-conforming fixtures.
- Validators follow the canonical `validate_<artifact>_text` pattern and expose an argparse
  subparser CLI.
- Hooks enforce completion gates by invoking the validators and follow canonical hook I/O
  conventions.
- New customization assets are mirrored into `resources/` subtrees and pass the push-down
  contract tests.
- The CLI, MCP, and VS Code surfaces expose the discovery commands in lockstep.
- Documentation enables a consumer repository to author a domain profile and run the workflow.

## Prior-Art / Naming-Collision Note

An installed Claude Code plugin `code-modernization` ships `/modernize-*` commands and agents
(`legacy-analyst`, `business-rules-extractor`, `architecture-critic`, `scaffolder`,
`security-auditor`, `test-engineer`, `version-delta-analyst`). It is a separate,
non-integrated ecosystem. New skill and agent names introduced by this epic must not collide
with those names, and this epic does not integrate with or duplicate that plugin.
