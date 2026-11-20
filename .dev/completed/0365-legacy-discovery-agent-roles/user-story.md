# `legacy-discovery-agent-roles` — User Story

- Issue: #365
- Parent: Epic `legacy-discovery-and-parity` (child feature #9007, Wave 1, complexity C3)
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-17T15-45
- Work Mode: full-feature

## Story Statement

- As an epic implementer building the legacy-discovery-and-parity capability, I want four
  reusable, domain-neutral agent personas defined under `.claude/agents/`, so that the
  downstream discovery-workflow skills (#9008) have reasoning agents to orchestrate over the
  discovery schemas and the domain profile.
- As a consumer-repository maintainer (for example TaskMaster or TMW) adopting the discovery
  capability, I want each persona to be free of any domain-specific identifiers and to derive
  all domain specificity from my runtime domain profile, so that the personas function against
  my repository without embedding another project's assumptions.
- As a maintainer of the drm-copilot runtime, I want a structural test that verifies the four
  persona definitions against repository conventions and the naming-collision and
  domain-neutrality constraints, so that regressions in these invariants are detected
  automatically.

## Problem / Why

The legacy-discovery-and-parity epic requires four reusable, domain-neutral agent personas
that reason over the discovery schemas and the domain-profile contract to produce the
discovery artifacts. Without these personas, the downstream generic-skills feature (#9008,
which depends on #9007) has no reasoning agents to orchestrate. The personas must be generic:
no TaskMaster/TMW/Outlook/VSTO/email/task-management-specific behavior; all domain
specificity is supplied at runtime through the domain profile (#9001) and the schemas
(#9002).

## Personas & Scenarios

- Persona: Epic implementer (drm-copilot contributor)
  - Who: an engineer delivering the epic's Wave 1 agent-roles feature.
  - What they care about: persona definitions that follow existing agent conventions, are
    discoverable from `.claude/agents/`, and correctly document their schema and domain-profile
    consumption.
  - Constraints: domain neutrality is an epic-wide invariant; names must not collide with the
    installed `code-modernization` plugin agents; skills (#9008), validators (#9003), hooks
    (#9004), and the `resources/` mirror (#9012) are out of scope.
  - Goals and frustrations: unblock #9008 without pre-empting downstream features; avoid
    referencing files or skills that do not yet exist.
  - Context and motivations: the dependency folders for #9001 and #9002 are not present on the
    integration tip, so the personas reference the schema and domain-profile contracts as
    summarized in the epic objective and research.

- Scenario: Authoring and verifying the four personas
  - Who is acting: the epic implementer during the execution phase.
  - Trigger: the prepared feature is promoted for delivery.
  - Steps: author `legacy-parity-analyst.md`, `runtime-characterization-analyst.md`,
    `requirements-reconciler.md`, and `migration-coverage-reviewer.md` under `.claude/agents/`,
    each with `name`, `description`, `model: sonnet`, `tools` (`Read`, `Grep`, `Glob`,
    `"Write(discovery/**)"`), and `memory: project`, and a body that names the consumed and
    produced schemas and the domain profile; then add the Pester structural test at
    `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1`.
  - Obstacles or decisions: the Write-tool glob, model tier, and the omission of `skills` and
    `hooks` are resolved in the spec's Resolved Specification Decisions section; the artifact
    root is runtime-configured and exact-path enforcement is deferred to #9004.
  - Expected outcome: the four personas exist, are domain-neutral and non-colliding, document
    their schema and domain-profile consumption, and the structural test passes.

- Scenario: Consumer-repository reuse
  - Who is acting: a consumer-repository maintainer adopting the discovery capability
    downstream.
  - Trigger: the maintainer authors a `discovery-profile.yaml` and runs the discovery workflow.
  - Steps: the personas reason over the consumer's discovery artifacts and domain profile;
    domain specificity (legacy source, target, technology stack, artifacts root) comes entirely
    from the runtime profile.
  - Expected outcome: the personas operate against the consumer repository without any
    hardcoded domain identifiers.

## Acceptance Criteria

For full-feature work mode, `spec.md` and `user-story.md` are both acceptance-criteria sources.
Checkboxes remain unchecked; delivery occurs in the execution phase, which is out of scope for
this preparation run.

- [x] Four domain-neutral agent `.md` personas exist under `.claude/agents/`
      (`legacy-parity-analyst.md`, `runtime-characterization-analyst.md`,
      `requirements-reconciler.md`, `migration-coverage-reviewer.md`), each with valid YAML
      frontmatter containing `name`, `description`, `model`, `tools`, and `memory`.
- [x] Each persona uses `model: sonnet`, `tools` of exactly `Read`, `Grep`, `Glob`, and
      `"Write(discovery/**)"`, `memory: project`, and carries no `skills:` field and no
      `hooks:` field.
- [x] Persona names do not collide with the installed `code-modernization` plugin agents
      (`legacy-analyst`, `business-rules-extractor`, `architecture-critic`, `scaffolder`,
      `security-auditor`, `test-engineer`, `version-delta-analyst`) or with existing
      `.claude/agents/` basenames.
- [x] Each persona is domain-neutral: no `taskmaster`, `tmw`, `outlook`, `vsto`, `email`,
      `task-management`, or `task management` identifiers appear in the persona body or
      frontmatter (case-insensitive).
- [x] Each persona documents which discovery schemas (#9002) and which domain-profile fields
      (#9001) it consumes and which discovery artifact it produces, per the confirmed mapping;
      this is machine-checked by the AC4 body-content assertion in the structural test.
- [x] A PowerShell Pester structural test at
      `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1` validates the four
      persona definitions (existence, frontmatter validity, name-equals-slug, model membership,
      naming non-collision, banned-substring domain-neutrality scan, and the AC4 body-content
      assertion) using in-memory positive and negative fixtures, and passes.

## Non-Goals

- Discovery-workflow skills are out of scope (feature #9008); no `skills:` field is added to
  the personas.
- Completion-gate validators (#9003) and `SubagentStop`/PreToolUse hooks (#9004) are out of
  scope; no `hooks:` field is added, and no `settings.json` worker-matcher entry is created for
  these personas.
- Mirroring the new `.claude/` assets into
  `extensions/drm-copilot/resources/claude-customizations/` is out of scope (feature #9012).
- No new executable production code, CLI command, MCP tool, or VS Code command is introduced.
