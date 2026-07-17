# `legacy-discovery-documentation` — User Story

- Issue: #371
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-17

## Story Statement

- As a consumer-repository engineer preparing a legacy-to-modern migration, I want
  capability-level documentation that explains how to author my repository's domain
  profile and run the discovery/parity workflow end to end, so that I can produce
  validated discovery artifacts using any of the CLI, MCP, or VS Code surfaces without
  reverse-engineering the framework from its source.
- As a maintainer onboarding a consumer repository (for example TaskMaster or TMW), I
  want a documented onboarding path that explains how the push-down tooling delivers the
  discovery capability to a consumer workspace, so that I can onboard a repository
  predictably instead of hand-copying assets.

## Problem / Why

The legacy-discovery-and-parity capability is delivered across thirteen functional
features, each with its own per-feature reference docs. No document ties them together.
A consumer-repository engineer today has no single place that explains what the workflow
does end to end, how to author the domain-profile configuration, what the seven
artifacts and their gates are, how to invoke the workflow, or how the capability arrives
in a consumer repository. This feature supplies that capability-level documentation set.
It describes the generic, domain-neutral capability; consumer specifics appear only as
onboarding examples.

## Personas & Scenarios

- Persona: Consumer-repository engineer
  - Who: an engineer in a repository migrating a legacy application to a modern
    architecture (the generic consumer role; TaskMaster's engineer is one instance).
  - Cares about: producing trustworthy discovery artifacts (coverage ledger, parity
    matrix, characterization scenarios) with minimal framework internals knowledge.
  - Constraints: works in the consumer repository, not in `drm-copilot`; interacts with
    the capability only through the pushed-down assets and the documented surfaces.
  - Goals and frustrations: wants a clear authoring contract and runnable commands;
    frustrated by documentation that assumes a specific domain or restates internals
    without saying what to do.
  - Context and motivation: must inventory legacy behavior and define source-to-target
    parity before migration work can be planned.
- Scenario: Authoring a domain profile and running discovery end to end
  - Who is acting: the consumer-repository engineer.
  - Trigger: the capability has been pushed down into the consumer repository and the
    migration effort is starting.
  - Steps: the engineer opens the capability README index; reads the workflow page to
    understand the activity sequence and artifacts; follows the domain-profile page to
    author the repository's profile (legacy source location, target location, technology
    stack, artifact conventions); initializes the discovery workspace; runs the workflow
    through one surface — for example `poetry run dev.discovery.<command>` — knowing from
    the running-the-workflow page that the MCP tools and VS Code commands are lockstep
    equivalents; validates the produced artifacts and observes the completion gates as
    described in the artifacts-and-schemas page.
  - Obstacles or decisions: choosing which invocation surface fits their environment;
    understanding why a completion gate blocks progression until validators pass.
  - Expected outcome: validated discovery artifacts, rendered reports, and generated
    acceptance scenarios, achieved from the doc set plus the per-feature reference docs
    it links to.
- Persona: drm-copilot maintainer onboarding a consumer repository
  - Who: a maintainer of `drm-copilot` responsible for delivering the capability to
    consumer repositories.
  - Cares about: repeatable onboarding through the existing push-down tooling; not
    leaking domain assumptions into the framework.
  - Constraints: assets flow only through the bundled `resources/` mirrors and the
    push-down contract; onboarding must not require bespoke per-repository steps.
  - Goals: onboard TaskMaster (legacy source provider) and TMW (modern target provider)
    as the first consumers, using them as worked examples for future consumers.
- Scenario: Onboarding TaskMaster/TMW via push-down (example only)
  - Who is acting: the maintainer.
  - Trigger: a consumer repository is ready to adopt the discovery capability.
  - Steps: the maintainer opens the consumer-onboarding page; runs the appropriate
    push-down tool (CLI `scripts/dev_tools/push_down_*_customizations.py`, MCP
    `push_down_*` tool, or the VS Code command) against the consumer workspace; the
    consumer receives the discovery agents, skills, hooks, schemas, and templates from
    the bundled mirrors; the maintainer points the consumer engineer at the
    domain-profile page to begin authoring.
  - Obstacles or decisions: selecting the correct push-down variant and pack for the
    consumer's surface; the onboarding page documents the generic decision, with
    TaskMaster and TMW as examples only.
  - Expected outcome: the consumer repository holds the capability assets and its
    engineers can proceed using the same documentation set.

## Acceptance Criteria

- [ ] From the documentation set (plus the per-feature reference docs it links to), a
      consumer-repository engineer can author a domain profile: the doc set explains the
      contract fields (legacy source location, target location, technology stack,
      artifact conventions) and domain-neutral authoring guidance.
- [ ] From the documentation set, a consumer-repository engineer can run the discovery/
      parity workflow end to end via any one of the three documented surfaces (CLI
      `dev.discovery.*`, MCP tools, VS Code commands), and the docs state that the three
      surfaces are lockstep equivalents.
- [ ] From the documentation set, a reader can identify the seven discovery artifacts by
      name, how each is validated, and how completion gates block progression until
      validation passes.
- [ ] The consumer-onboarding path is documented: a maintainer can follow the doc set to
      deliver the capability to a consumer repository via the push-down tooling, with
      TaskMaster and TMW presented strictly as onboarding examples.
- [ ] The documentation presents the capability as domain-neutral throughout: no
      domain-specific (TaskMaster/TMW/Outlook/VSTO/email/task-management) behavior is
      described as framework behavior.

## Non-Goals

- No domain-specific behavior in the core framework, and none described as framework
  behavior in the documentation; all domain specificity is runtime configuration via the
  domain profile.
- No duplication of per-feature reference docs; each functional feature documents its
  own surface in its own PR, and this doc set links to that content.
- No execution of an actual migration; the capability and its documentation cover
  discovery and parity definition only.
- No production code, commands, tools, or APIs delivered by this feature.
- No integration with, and no collision with the command or agent names of, the
  installed `code-modernization` plugin.
