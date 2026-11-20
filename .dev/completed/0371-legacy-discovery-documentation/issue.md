# legacy-discovery-documentation (Issue #371)

- Date captured: 2026-07-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-07-17-legacy-discovery-documentation-371/ (Issue #371)

- Issue: #371
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/371
- Last Updated: 2026-07-17
- Work Mode: full-feature
- Epic: legacy-discovery-and-parity
- Integration branch: epic/legacy-discovery-and-parity-integration
- Depends on: legacy-discovery-skills (#9008), legacy-discovery-mcp-vscode (#9011), legacy-discovery-publishing (#9012)

## Problem / Why

The legacy-discovery-and-parity epic delivers a reusable, domain-neutral capability for
agentic discovery of legacy-system behavior and source-to-target parity definition. The
capability spans a domain-profile configuration contract, versioned JSON schemas,
validators, completion-gate hooks, initialization templates, analyzer framework, generic
agent roles, generic skills, acceptance-scenario generation, reports, CLI/MCP/VS Code
surfaces, and cross-ecosystem publishing. Without capability-level, end-to-end
documentation, a consumer repository cannot author its domain profile, run the workflow
across the CLI/MCP/VS Code surfaces, or receive the capability through the push-down
tooling. Per-feature reference docs are delivered inside each functional feature's own PR;
this feature supplies only the capability-level documentation that ties the surfaces
together.

## Proposed Behavior

Author capability-level, end-to-end Markdown documentation for the legacy-discovery-and-parity
capability under the repository documentation tree (`docs/`), consistent with existing docs
conventions. The documentation describes the generic capability and domain-neutral authoring
of the domain profile. Consumer specifics (TaskMaster, TMW) appear only as onboarding
examples, never as framework behavior.

The documentation set covers:

1. The overall discovery/parity workflow (end to end): what the capability does, the
   sequence of discovery and parity-definition activities, and the artifacts produced.
2. How a consumer repository authors its domain-profile configuration (the configuration
   contract and domain-neutral authoring guidance).
3. The artifact/schema lifecycle: the seven versioned JSON schemas, the schema-versioning
   convention, validation, and completion-gate enforcement.
4. How to run the workflow via the CLI (`dev.discovery.*`), MCP tools, and VS Code commands
   (the three surfaces in lockstep).
5. How consumer repositories (TaskMaster, TMW) receive the capability via the push-down
   tooling (`scripts/dev_tools/push_down_*_customizations.py` + MCP `push_down_*` tools),
   framed as onboarding examples.

## Scope

- Capability-level, end-to-end documentation ONLY. Do NOT duplicate per-feature reference
  docs; each functional feature documents its own surface within its own PR.
- Markdown documentation (exempt from the 500-line file-size limit); placed under `docs/`
  consistent with existing conventions.
- Tests where applicable: link/section structural checks if the repository has a docs-lint
  convention; otherwise none.

## Shared Invariant

The core framework is domain-neutral. Documentation describes the generic capability and
domain-neutral authoring of the domain profile. Consumer specifics (TaskMaster, TMW) appear
only as onboarding examples, never as framework behavior.

## Acceptance Criteria (early draft; authoritative AC in spec.md and user-story.md)

- [ ] Capability-level end-to-end workflow documentation exists under `docs/` and describes
      the discovery/parity workflow without duplicating per-feature reference docs.
- [ ] Documentation explains domain-neutral authoring of the domain-profile configuration.
- [ ] Documentation covers the artifact/schema lifecycle (schemas, versioning, validation,
      completion gates).
- [ ] Documentation covers running the workflow via CLI, MCP, and VS Code surfaces.
- [ ] Documentation covers consumer onboarding (TaskMaster, TMW) via the push-down tooling,
      framed as examples only.
- [ ] The core capability is described as domain-neutral; no domain-specific behavior is
      presented as framework behavior.

## Constraints & Risks

- Domain neutrality invariant must hold throughout: no TaskMaster/TMW/Outlook/VSTO/email/
  task-management behavior described as framework behavior.
- Upstream feature specs may not all be present on the integration branch at documentation
  authoring time; document against planned scope from the epic objective when a spec is
  absent, and against the delivered spec when present.
- Must not collide with the installed `code-modernization` plugin command/agent names.

## Test Conditions to Consider

- [ ] Structural link/section checks if a docs-lint convention exists.
- [ ] Cross-references to schema, CLI, MCP, and VS Code surfaces resolve correctly.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [x] Create active feature folder from the template
