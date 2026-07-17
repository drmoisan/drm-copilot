# `legacy-discovery-analyzer-framework` — User Story

- Issue: #363
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-17
- Work Mode: full-feature
- Epic: legacy-discovery-and-parity (child feature #9006, Wave 1)

## Story Statement

- As a **migration engineer in a consumer repository** moving a legacy application to a modern
  architecture, I want to **author a domain profile and run a single inventory command** that
  reads my legacy source tree, so that I get a **machine-readable inventory of my
  solutions/projects and files** as discovery artifacts without writing bespoke tooling.
- As a **migration engineer**, I want the inventory command to **fail immediately with a clear
  message when my configured source location cannot be reached**, so that I do not receive a
  silent or partial inventory.
- As a **tool author building a stack-specific analyzer**, I want a **stable
  parse -> classify -> map -> emit framework contract** to plug into, so that my analyzer reuses
  the shared pipeline, artifact emission, and CLI conventions instead of re-implementing them.

## Problem / Why

A repository migrating a legacy application needs an inventory of its current source before it
can reason about behavior, coverage, and source-to-target parity. Producing that inventory by
hand, or building one-off scripts per repository, is slow and yields inconsistent artifact
shapes that downstream discovery tooling cannot consume. This feature gives migration engineers
a reusable, domain-neutral inventory command driven entirely by a repository-local domain
profile, and gives analyzer authors a shared framework contract so future stack-specific
analyzers produce artifacts of the same shape.

## Personas & Scenarios

- **Persona: Consumer-repository migration engineer.**
  - Who they are: an engineer in a repository (external to drm-copilot) that is migrating a
    legacy application to a modern target.
  - What they care about: producing a complete, deterministic inventory of their legacy source
    tree in a machine-readable form that downstream discovery and parity tooling can consume.
  - Their constraints: they must not edit the framework's source; all repository-specific detail
    (where the legacy source lives, which files to include or exclude, where artifacts go) is
    supplied through their own domain profile. Their legacy source lives outside drm-copilot at
    a path they declare.
  - Their goals and frustrations: they want one command that "just runs" from their profile;
    they are frustrated by tools that silently produce partial output when a path is wrong, or
    that emit artifacts in an ad hoc shape.
  - Their context and motivations: they are early in a migration and need a trustworthy baseline
    inventory before deeper analysis.

- **Scenario: Producing a first inventory.**
  - Who is acting: the migration engineer.
  - What triggered the action: they have authored a domain profile declaring
    `legacy_source.root`, `include`/`exclude` globs, and an artifacts location, and want a
    baseline inventory.
  - Steps: they run the `dev.discovery.inventory` command, optionally passing their profile path
    and `--output-dir`. The analyzer resolves the source root from the profile, walks the tree,
    filters by their include/exclude globs, classifies each unit (file, project, or solution),
    and writes one Evidence Reference artifact per unit under the output location.
  - Obstacles or decisions: if the configured source root does not exist or is not a directory,
    the command stops immediately and reports the unreachable path rather than emitting a partial
    inventory. If the profile itself is malformed, the command reports that distinct error.
  - Outcome they expect: exit code `0`, a collection of schema-conforming artifacts describing
    their source tree, and (with `--json`) a summary of what was written. The same tree and
    profile produce the same artifacts on re-run.

- **Scenario: Plugging in a stack-specific analyzer (framework consumer).**
  - Who is acting: a tool author building the .NET/VSTO analyzers (sibling feature #9014).
  - What triggered the action: they need their analyzer to emit the same artifact shape and use
    the same pipeline as the inventory analyzer.
  - Steps: they implement the `Analyzer` protocol's four stages, construct their analyzer, and
    hand it to `run_analyzer`; the runner drives the stages and their `emit` stage reuses the
    Evidence Reference emission conventions.
  - Outcome they expect: their analyzer reuses the shared contract with no re-implementation of
    pipeline sequencing, artifact emission, or CLI wiring, and produces artifacts consistent
    with the inventory analyzer's.

## Acceptance Criteria

- [ ] A migration engineer can run the `dev.discovery.inventory` command with a domain profile
      and produce a machine-readable inventory of their legacy source tree.
- [ ] The command reads the legacy source location and include/exclude rules from the engineer's
      domain profile (`legacy_source.root`, `legacy_source.include`, `legacy_source.exclude`);
      no repository-specific detail is hardcoded in the tool.
- [ ] The inventory enumerates the engineer's solutions/projects and files, honoring their
      include/exclude globs, with deterministic (repeatable) results for the same source tree and
      profile.
- [ ] When the configured source location cannot be reached (missing or not a directory), the
      command stops immediately and reports the unreachable path, distinct from a
      malformed-profile error, and does not emit a partial inventory.
- [ ] Each produced artifact is a discovery Evidence Reference (v1) instance whose `location` is
      expressed in the engineer's own repository-relative terms, with a schema version, a
      relative schema reference, and the required identifying fields, so downstream discovery
      tooling can consume it.
- [ ] The command returns predictable exit codes: `0` on success, `1` on a configuration or
      source-location error, and `2` on a command-usage error; with `--json` it prints a summary
      of what was written.
- [ ] The command and its artifacts are domain-neutral: they contain no application- or
      stack-specific identifiers, so any migrating repository can use them unchanged.
- [ ] An analyzer author can implement the shared framework contract and plug a new analyzer into
      the same pipeline and artifact-emission conventions without re-implementing them.

## Non-Goals

- The .NET/C# inventory analyzer and the VSTO/Office analyzer are out of scope (sibling feature
  #9014); this feature delivers the framework and the language-neutral inventory analyzer only.
- Authoring the domain-profile configuration contract or its loader is out of scope (upstream
  feature #360); this feature consumes it.
- Authoring the discovery JSON schemas is out of scope (upstream feature #359); this feature
  emits instances that conform to the v1 Evidence Reference schema.
- Deep content parsing or AST analysis of the consumer's source files is out of scope; the
  inventory is filename/extension recognition and a filesystem walk.
- MCP-tool and VS Code exposure of the command is out of scope (feature #9011).
