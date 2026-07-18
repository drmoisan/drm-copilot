# `legacy-discovery-init-templates` — User Story

- Issue: #362
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-17

## Story Statement

- As a maintainer of a repository migrating a legacy application to a modern
  architecture, I want a single command that scaffolds my repository's discovery
  workspace (directory layout, starter domain-profile config, and starter
  instances of each discovery artifact), so that I can begin agentic discovery
  without hand-authoring the workspace structure myself.
- As a maintainer of a repository migrating a legacy application, I want the
  scaffolding command to fail before writing anything when my target path or
  template set is invalid, so that I never end up with a partially initialized,
  inconsistent discovery workspace.

## Problem / Why

The `legacy-discovery-and-parity` capability (see
`docs/features/epics/legacy-discovery-and-parity/objective-source.md`) requires a
repeatable way to stand up a consumer repository's discovery workspace. Without an
initialization command and artifact templates, each consumer would hand-author the
directory layout, the domain-profile configuration, and instances of each of the
seven discovery schemas, which is error-prone and inconsistent across consumers.
This feature provides a domain-neutral scaffolding command,
`dev.discovery.init`, and a set of generic artifact templates, so a consumer
repository can initialize its discovery workspace deterministically in one
invocation.

## Personas & Scenarios

### Persona: Consumer-repository maintainer

- **Who they are:** a maintainer of a repository that is migrating a legacy
  application to a modern architecture (illustratively, a maintainer of
  `drmoisan/TaskMaster` preparing to migrate to `drmoisan/TMW`). This persona is
  named here only as an illustrative example; the framework itself never encodes
  TaskMaster/TMW-specific behavior.
- **What they care about:** getting a correct, consistent discovery workspace in
  place quickly, without having to learn the internal shape of the seven discovery
  schemas or the domain-profile config contract by hand.
- **Their constraints:** they work from their own repository checkout, which is a
  separate filesystem location from `drm-copilot`. They may run the scaffolding
  tool from a bundled/mirrored copy of the templates rather than from a full
  `drm-copilot` checkout.
- **Their goals and frustrations:** they want one deterministic command that
  produces the full expected file set in a single pass; they are frustrated by
  tools that partially write output and leave an inconsistent workspace when an
  input is invalid.
- **Their context and motivations:** they are at the very start of the discovery
  workflow — before any analyzer, agent, or skill in the epic can produce real
  discovery artifacts, their repository needs a domain-profile config and starter
  artifact files in place.

### Scenario: Initializing a new discovery workspace

- **Who is acting:** the consumer-repository maintainer described above.
- **What triggered the action:** they have decided to begin the discovery and
  parity workflow for their repository and need a discovery workspace before any
  other step (authoring the domain profile's real values, running analyzers,
  invoking discovery skills) can proceed.
- **What steps do they take:** they run
  `dev.discovery.init <target-directory>` (optionally with `--template-root` if
  they are invoking from a mirrored template set rather than a `drm-copilot`
  checkout), pointing at an empty or non-existent target directory inside their
  own repository.
- **What obstacles or decisions occur:** if the target path already exists and is
  not empty, or exists but is not a directory, or its parent directory does not
  exist, the command must fail immediately with a clear error and must not write
  any file. If they used `--template-root` and it points at a missing or
  incomplete template set, the command must likewise fail before writing
  anything, rather than scaffolding only the templates that happened to be
  present.
- **What outcome do they expect:** on success, their target directory contains
  the discovery-workspace directory layout, a starter domain-profile config file
  with placeholder tokens in place of real values, and starter instances of all
  seven discovery artifacts (Feature Contract, Coverage Ledger, Runtime
  Characterization Scenario, Parity Matrix, Unspecified Behavior Record, Product
  Decision Record, Evidence Reference), each referencing its schema so that later
  validation (feature 9003) and completion-gate hooks (feature 9004) can operate
  on the workspace once schemas (feature 9002) and the config-contract loader
  (feature 9001) are in place. They then edit the placeholder tokens with their
  own repository's real legacy-source path, target path, technology stack, and
  artifact conventions.

## Acceptance Criteria

- [x] `dev.discovery.init <target-dir>` scaffolds the discovery workspace directory
      layout at the given target consumer path in a single invocation.
- [x] `dev.discovery.init` accepts an explicit target-directory CLI argument (not
      the drm-copilot workspace root) and an optional `--template-root` override
      consistent with the `new_active_feature_folder`/`new_potential_bug_entry`
      precedent.
- [x] Initialization writes a starter domain-profile config, authored as a flat
      single-level `key: value` YAML document with placeholder tokens, of the
      shape anticipated for feature 9001 (with the nested-structure forward
      dependency explicitly recorded, not resolved, by this feature).
- [x] Initialization writes starter instances of each of the seven discovery
      artifacts (Feature Contract, Coverage Ledger, Runtime Characterization
      Scenario, Parity Matrix, Unspecified Behavior Record, Product Decision
      Record, Evidence Reference) from the templates under
      `docs/discovery/templates/artifacts/`, in the same invocation as the
      domain profile.
- [x] Each artifact template's `$schema` field is a relative, scheme-less path
      resolvable by `validate_json.py`'s existing no-scheme `_load_schema` branch,
      per feature 9002's planned schema-versioning convention; the open question
      about resolving `$schema` from inside an external consumer repository is
      recorded in the spec and left to feature 9002, not resolved here.
- [x] Templates and generated artifacts contain no domain-specific identifiers
      (verified by the domain-neutrality regression test).
- [x] `dev.discovery.init` fails fast, before writing any file, when: the target
      path exists and is not a directory; the target path's parent does not
      exist; or the resolved template root is missing or has a partial template
      set.
- [x] `dev.discovery.init` is registered and invocable as a Poetry console-script
      (`"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"` in root
      `pyproject.toml`).
- [x] Tests under `tests/scripts/dev_tools/discovery/` satisfy repository
      quality-tier policy (line coverage >= 85%, branch coverage >= 75%), use an
      injected fake `FileSystem` with no real filesystem/temp-file I/O, and
      include the schema-conformance test tracked as dependent on feature 9002.

## Non-Goals

- This feature does not author the seven JSON schema files (feature
  `legacy-discovery-schemas`, issue 9002) or the domain-profile config-contract
  loader/parser (feature `legacy-discovery-config-contract`, issue 9001); it
  consumes their planned contracts without redefining them.
- This feature does not implement any analyzer, validator, completion-gate hook,
  agent persona, skill, MCP tool, or VS Code command.
- This feature does not perform or simulate an actual migration of any consumer
  repository's code.
- This feature does not bake any TaskMaster/TMW/Outlook/VSTO/email/
  task-management-specific behavior into the scaffolding command or its
  templates; any such name appearing in this document is illustrative only.
