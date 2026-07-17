# `legacy-discovery-skills` — User Story

- Issue: #367
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-17
- Work Mode: full-feature
- Spec: `docs/features/active/2026-07-17-legacy-discovery-skills-367/spec.md`

## Story Statement

- As a repository author onboarding the legacy-discovery workflow in a consumer
  repository, I want reusable `discovery-*` skills that sequence the analyzers,
  agent roles, and artifact production/validation end to end, so that I do not
  have to hand-orchestrate the discovery and parity-definition workflow and
  reintroduce domain coupling.
- As a repository author, I want every skill to read domain specifics
  (source/target roots, technology stack, artifact conventions) from my
  repository's domain profile at runtime, so that the same skills work
  unchanged for any consumer repository and technology stack.
- As a drm-copilot maintainer integrating the epic's parallel features, I want
  all upstream names (#9006 analyzer CLI, #9007 agent slugs) isolated in one
  canonical registry, so that reconciling a renamed upstream contract at epic
  fan-in is a one-line edit rather than a sweep across many files.

## Problem / Why

The legacy-discovery-and-parity epic delivers a domain-neutral discovery and
parity-definition capability. The analyzer framework (#9006), the generic agent
roles (#9007), the schemas (#9002), the domain-profile config contract (#9001),
and the validators (#9003) provide the building blocks, but there is no reusable
workflow-mechanics layer that sequences them into an end-to-end discovery and
parity-definition workflow. Without generic skills, every consumer repository
would have to hand-orchestrate the analyzers, agent roles, and artifact
production/validation ad hoc, reintroducing domain coupling and duplicating
sequencing logic.

## Personas & Scenarios

- Persona: **Consumer-repository author.** An engineer in a repository that is
  migrating a legacy application to a modern architecture. They have authored a
  `discovery-profile.yaml` domain profile (#9001) declaring the legacy source
  root, target root, technology stack, and artifact conventions. They care
  about producing complete, schema-valid discovery artifacts without learning
  the internals of each analyzer or agent role. Their constraint is that their
  domain specifics must stay in configuration, not in shared tooling.
- Scenario: **Onboarding the discovery workflow.**
  1. The author invokes the umbrella skill `discovery-workflow`, which loads the
     domain profile via `dev.discovery.profile` and presents the stage order:
     profile -> inventory -> coverage -> runtime -> parity -> reconciliation ->
     validation gate.
  2. They run `discovery-repo-inventory`, which drives the language-neutral
     repository/project inventory analyzer against the profile's
     `legacy_source.root` and `target.root`, records outputs under the profile's
     `artifacts.root`, and then runs any stack-specific analyzer commands
     applicable to the profile's `technology_stack` as documented by the
     analyzer framework.
  3. They run `discovery-coverage-ledger`, which produces feature contracts and
     the coverage ledger from the inventory output and routes review to the
     Migration Coverage Reviewer role by name.
  4. They run `discovery-runtime-characterization`, which produces runtime
     characterization scenarios and evidence references and routes analysis to
     the Runtime Characterization Analyst role.
  5. They run `discovery-parity-matrix`, which produces the parity matrix from
     the feature contracts and characterization evidence and routes parity
     reasoning to the Legacy Parity Analyst role.
  6. They run `discovery-behavior-reconciliation`, which captures unspecified or
     contradictory behavior and reconciles it into product-decision records via
     the Requirements Reconciler role.
  7. After each stage, and finally via `discovery-validate-artifacts`, they
     validate the artifacts with the `dev.discovery.validate-*` console scripts;
     `dev.discovery.validate-all` is the completion gate. An empty error list
     means the workflow is complete; a non-empty list points them to the exact
     artifact and stage to fix.
  - Obstacle handled: if a validator reports errors mid-workflow, the
    validation-gate skill directs the author back to the owning stage skill
    rather than requiring ad hoc debugging.
  - Expected outcome: seven schema-valid discovery artifacts under the profile's
    `artifacts.root`, produced without any hand-orchestration and without any
    domain-specific identifier in the shared skills.

- Persona: **drm-copilot maintainer / epic integrator.** Maintains the epic's
  integration branch while #9006 and #9007 are prepared in parallel. They care
  about the repository test suite staying green on this feature branch and
  about cheap fan-in reconciliation when upstream names land.
- Scenario: **Fan-in reconciliation.**
  1. The #9006 feature merges with an inventory command name different from the
     assumed `dev.discovery.inventory`.
  2. The maintainer opens the `## Referenced Contracts` registry in
     `discovery-workflow/SKILL.md`, updates the one registry line, and updates
     the matching fragment in `discovery-repo-inventory/SKILL.md`.
  3. They re-run `test_legacy_discovery_skills_contracts.py`; because the tests
     assert only on this feature's own files (never on #9006/#9007 artifact
     existence), the suite is green before and after the reconciliation.
  4. The byte-identical bundle copies are refreshed in the same change so the
     push-down parity gate stays green.

## Acceptance Criteria

Traceability: these criteria restate the issue #367 acceptance criteria from
the consumer perspective and align with spec.md AC-1 through AC-9.

- [ ] A repository author can sequence the full discovery and parity-definition
      workflow (analyzer invocation, agent-role routing, artifact
      production/validation) using only the seven `discovery-*` skills, in the
      documented stage order, with no hand-orchestration.
- [ ] Each skill follows the repository SKILL.md conventions: `name` and
      `description` frontmatter on every skill; `allowed-tools` only on the two
      CLI-driving skills; `context`/`agent` are optional keys per the repository
      SKILL.md contract and are not used; agent routing appears in body-level
      `## Worker Routing` sections naming the four roles (Legacy Parity Analyst,
      Runtime Characterization Analyst, Requirements Reconciler, Migration
      Coverage Reviewer) by slug; schemas, validators, and analyzer CLI
      commands are referenced by name.
- [ ] Skill names do not collide with or duplicate the installed
      `code-modernization` plugin's `/modernize-*` command names
      (modernize-assess, modernize-brief, modernize-extract-rules,
      modernize-harden, modernize-map, modernize-preflight, modernize-reimagine,
      modernize-status, modernize-transform, modernize-uplift) or its agent
      names (legacy-analyst, business-rules-extractor, architecture-critic,
      scaffolder, security-auditor, test-engineer, version-delta-analyst), nor
      with any existing `.claude/skills/` name.
- [ ] The skills are domain-neutral: none of the banned domain substrings
      appears in any new skill file or bundle mirror (case-insensitive), no
      stack-specific analyzer is named literally, and all domain specificity is
      read from the domain profile at runtime.
- [ ] Upstream references to #9006 and #9007 are isolated behind stable string
      names in the `discovery-workflow` registry, with the two assumed names
      (the #9006 inventory command; the four #9007 agent slugs) flagged as
      fan-in reconciliation assumptions, so the skills remain correct as those
      dependencies land.
- [ ] Structural skill checks per repository precedent pass:
      `tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py`
      verifies existence, frontmatter, required fragments, banned-substring
      absence, name non-collision, and bundle byte-parity, asserting only on
      this feature's own files.
- [ ] The always-on push-down parity gate passes: every new skill exists
      byte-identically under
      `extensions/drm-copilot/resources/claude-customizations/`.

## Non-Goals

- Authoring the four agent personas (#9007) or any `.claude/agents/*.md` file.
- Authoring the analyzer framework (#9006) or any stack-specific analyzer
  (#9014); these are referenced by name or generically via the profile's
  `technology_stack`.
- Broader `resources/` publishing (#9012): pack-manifest selection, Codex-native
  converter registration, and `.github`/`.agents` mirroring. Only the
  byte-identical bundle copy of this feature's skills is delivered here, to
  keep the always-on parity gate green.
- Executing a migration, or integrating with the `code-modernization` plugin.
- Adding CLI commands, MCP tools, hooks, schemas, validators, or production
  Python code.
