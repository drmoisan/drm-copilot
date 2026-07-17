# `legacy-discovery-publishing` — User Story

- Issue: #372
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-17

## Story Statement

- As a TaskMaster or TMW maintainer, I want the legacy-discovery-and-parity framework's agent
  personas, skills, and hooks to arrive through my repository's existing push-down pull, so
  that I receive the discovery capability without writing bespoke wiring or a manual copy step.
- As the drm-copilot maintainer publishing the discovery framework, I want every new
  customization asset mirrored into the `resources/` subtrees and passing the push-down
  contract tests before merge, so that a consumer repository's push-down pull cannot silently
  omit part of the capability.

## Problem / Why

The `legacy-discovery-and-parity` epic adds new customization assets (agent personas, skills,
hooks, schemas, templates) under the repository-root native trees (`.claude/`, `.github/`,
`.codex/`+`.agents/`). The repository enforces byte-identical mirrors of the `.claude/**` and
`.codex/**`+`.agents/**` trees under `extensions/drm-copilot/resources/` via push-down contract
tests (`test_push_down_claude_resource_contracts.py` and
`test_push_down_codex_and_agents_resource_contracts.py`). A consumer repository such as
TaskMaster or TMW does not author or maintain these mirrors itself; it pulls the bundled
`resources/` tree through the existing push-down publishers (Python `push_down_*` scripts and
their MCP tool wrappers, or the TypeScript twins). If a new discovery asset is not mirrored, or
is mirrored but omitted from the `core` pack manifest, the consumer's push-down pull does not
deliver it — either failing the contract tests outright, or, in the manifest-omission case,
silently dropping the asset from a language-scoped pull with no test failure to signal the gap.

This feature makes the discovery assets shippable. It does not re-author the personas, skills,
hooks, schemas, or templates themselves (those are delivered by the upstream epic children); it
is the publishing step that lets an already-authored asset reach a consumer repository through
the tooling that repository already uses.

Research basis: `docs/features/active/2026-07-17-legacy-discovery-publishing-372/research/2026-07-17T1930-legacy-discovery-publishing-research.md`.

## Personas & Scenarios

- Persona: TaskMaster/TMW repository maintainer.
  - Who: the maintainer responsible for keeping their repository's `.claude`/`.codex`/`.agents`
    customization surface current with drm-copilot's published bundle.
  - What they care about: pulling updates through their existing push-down invocation
    (typically scoped to their own language pack, for example `csharp-modern` for TaskMaster or
    `typescript` for TMW) without having to learn a new mechanism, add a new pack argument, or
    manually copy files.
  - Their constraints: they do not read or modify drm-copilot's internal `.claude/**` source
    tree; they only consume the published `resources/` bundle through the push-down publisher
    or MCP tool.
  - Their goals and frustrations: they want new capability to appear automatically on the next
    pull; a capability that requires them to discover and add a new `--packs` argument, or that
    silently fails to appear with no error, defeats the purpose of the push-down tooling.
  - Their context and motivations: they are adopting the discovery-and-parity framework to run
    a legacy-migration-parity workflow in their own repository, using the domain-neutral
    personas and skills configured against their own domain profile.

- Scenario: consumer pulls a scoped push-down after the discovery framework is published.
  - Who is acting: the TaskMaster maintainer, running their repository's normal push-down pull
    (`--packs csharp-modern`, or the MCP tool equivalent).
  - What triggered the action: drm-copilot published a new release containing the
    legacy-discovery-and-parity epic's agent personas, skills, and hooks.
  - What steps they take: they run the existing push-down command exactly as before, with no
    new flags and no manual file copy.
  - What obstacles or decisions occur: because the discovery-framework assets are placed in the
    `core` pack (unconditionally unioned into every `--packs` selection), the maintainer's
    existing, unmodified invocation already receives them; there is no decision point requiring
    the maintainer to learn about or opt into a new pack.
  - What outcome they expect: the four discovery agent personas, the discovery skills, and the
    completion-gate hooks appear in their repository's `.claude/` (or converted `.codex`/
    `.agents/`) tree after the pull, ready to be configured against their own domain profile,
    with no bespoke wiring on their part.

## Acceptance Criteria

- [ ] A consumer repository's existing, unmodified push-down invocation (including a
      language-scoped `--packs` selection such as `csharp-modern` or `typescript`) receives
      every new discovery-framework agent persona, skill, and hook because those assets are
      placed in the `core` pack, which is unconditionally unioned into every `--packs`
      selection.
- [ ] No consumer repository is required to add a new pack name, flag, or manual file-copy step
      to receive the discovery capability.
- [ ] The push-down contract tests (`test_push_down_claude_resource_contracts.py`,
      `test_push_down_codex_and_agents_resource_contracts.py`, and their TypeScript twins) pass
      with the mirrored discovery assets present, so a maintainer pulling from a green
      drm-copilot build never observes a missing or corrupted mirrored file.
- [ ] A manifest-completeness check (existing on the Claude/TypeScript side; extended to the
      Python/Codex side by this feature) prevents a bundled discovery asset from being present
      in the mirror but silently absent from a scoped `--packs` pull.
- [ ] The Codex-native converter requires no per-consumer or per-asset registration step: a
      consumer relying on the Codex/`.agents` surface receives the same discovery capability
      through the existing path-prefix classification, with no additional configuration.

## Non-Goals

- This feature does not author, redesign, or modify the discovery agent personas, skills,
  hooks, schemas, or templates themselves — those are delivered by the upstream epic children
  (`legacy-discovery-agent-roles`, `legacy-discovery-schemas`, `legacy-discovery-skills`,
  `legacy-discovery-hooks`, `legacy-discovery-init-templates`).
- This feature does not introduce any TaskMaster/TMW/Outlook/VSTO/email/task-management-specific
  behavior, configuration, or identifier; the discovery framework remains domain-neutral and
  configured entirely through a consumer's own domain profile.
- This feature does not change the default (unfiltered) push-down behavior when `--packs` is
  omitted, and does not introduce a new pack.
- This feature does not add a `.github`-native mirror or parity test for the discovery assets;
  no upstream epic child is described as authoring a `.github/agents/*.agent.md` or
  `.github/skills/<name>/SKILL.md` counterpart for these assets.
- This feature does not execute a migration or characterize any consumer repository's legacy
  source; it only publishes the tooling that a consumer would later run against their own
  domain profile.
