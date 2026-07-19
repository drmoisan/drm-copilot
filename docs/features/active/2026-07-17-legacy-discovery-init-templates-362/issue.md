# legacy-discovery-init-templates (Potential)

- Date captured: 2026-07-17
- Author: Dan Moisan
- Status: Draft
- Epic: legacy-discovery-and-parity (child feature, epic manifest issue placeholder 9005)

- Work Mode: full-feature

## Problem / Why

The legacy-discovery-and-parity capability requires a repeatable way to stand up a
consumer repository's discovery workspace. Without an initialization command and
artifact templates, each consumer would hand-author the directory layout, the
domain-profile configuration, and instances of each of the seven discovery schemas,
which is error-prone and inconsistent. This feature provides a domain-neutral
scaffolding command and a set of generic artifact templates so a consumer repository
(TaskMaster first, then TMW) can initialize its discovery workspace deterministically.

## Proposed Behavior

- Provide an initialization command that scaffolds a consumer repository's discovery
  workspace: the directory layout, a starter domain-profile configuration, and
  empty/starter instances of each discovery artifact.
- Provide artifact templates that instantiate each of the seven discovery schemas with
  placeholder content (generic scaffolds with placeholder tokens, not
  TaskMaster/TMW/Outlook/VSTO-specific instances).
- Expose the initialization command as a `dev.discovery.init` Python CLI entry point
  (Poetry console-script in root `pyproject.toml` `[tool.poetry.scripts]`).
- Templates reference the seven schemas per the versioning convention defined by
  feature legacy-discovery-schemas (issue 9002), and the starter profile matches the
  domain-profile config contract defined by feature legacy-discovery-config-contract
  (issue 9001).

## Acceptance Criteria (early draft)

- [ ] `dev.discovery.init` scaffolds the discovery workspace directory layout in a
      target consumer path.
- [ ] Initialization writes a starter domain-profile config of the shape defined by
      feature 9001 with placeholder tokens.
- [ ] Initialization writes starter instances of each of the seven discovery artifacts
      from the templates.
- [ ] Artifact templates instantiate each of the seven schemas with placeholder content
      and reference the schema versioning convention defined by feature 9002.
- [ ] Templates and generated artifacts contain no domain-specific identifiers.
- [ ] Tests satisfy repository quality-tier policy (line >= 85%, branch >= 75%).

## Constraints & Risks

- Domain neutrality invariant: templates must be generic scaffolds with placeholder
  tokens, never domain-specific instances.
- Upstream dependency: consumes (does not redefine) the config contract (feature 9001)
  and the seven schemas plus versioning convention (feature 9002). During preparation
  these contracts are planned in parallel; the plan must design against their planned
  shapes and cite them.
- Out of scope: authoring the schema files themselves (feature 9002) and the
  config-contract loader (feature 9001).

## Test Conditions to Consider

- [ ] Unit coverage for the initialization command's pure scaffolding logic.
- [ ] Scenario: initialization into an empty target path produces the full layout.
- [ ] Scenario: generated starter artifacts are well-formed against their schemas.
- [ ] Negative: initialization into a non-empty or invalid target path fails fast.
- [ ] CLI: `dev.discovery.init` entry point is invocable via Poetry console-script.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/legacy-discovery-init-templates/` folder from the template
