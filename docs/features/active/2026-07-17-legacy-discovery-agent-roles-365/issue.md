# legacy-discovery-agent-roles (Potential)

- Date captured: 2026-07-17
- Author: Dan Moisan
- Status: Draft
- Parent: Epic `legacy-discovery-and-parity` (child feature #9007, Wave 1, complexity C3)

- Work Mode: full-feature

## Problem / Why

The legacy-discovery-and-parity epic requires four reusable, domain-neutral agent personas
that reason over the discovery schemas and the domain-profile contract to produce the
discovery artifacts. Without these personas, the downstream generic-skills feature (#9008,
which depends on #9007) has no reasoning agents to orchestrate. The personas must be generic:
no TaskMaster/TMW/Outlook/VSTO/email/task-management-specific behavior; all domain
specificity is supplied at runtime through the domain profile (#9001) and the schemas
(#9002).

## Proposed Behavior

Author four reusable, domain-neutral agent personas as `.claude/agents/*.md` definitions,
each following the repository's existing agent-definition conventions (YAML frontmatter:
`name`, `description`, `model`, `tools` allowlist, preloaded `skills`, `memory` scope,
optional `hooks`). Each persona consumes the discovery schemas and the domain profile and
produces the corresponding discovery artifacts:

- Legacy Parity Analyst — reasons about source-to-target parity from feature contracts and
  parity-matrix evidence.
- Runtime Characterization Analyst — reasons about observed runtime behavior and
  characterization scenarios.
- Requirements Reconciler — reconciles undocumented, contradictory, or ambiguous behavior
  into product-decision records.
- Migration Coverage Reviewer — reviews legacy implementation coverage against the coverage
  ledger.

## Acceptance Criteria (early draft)

- [ ] Four domain-neutral agent `.md` personas exist under `.claude/agents/`, each with valid
      YAML frontmatter following repository conventions (name, description, model, tools,
      skills, memory).
- [ ] Persona names do not collide with the installed `code-modernization` plugin agents
      (legacy-analyst, business-rules-extractor, architecture-critic, scaffolder,
      security-auditor, test-engineer, version-delta-analyst).
- [ ] Each persona is domain-neutral: no TaskMaster/TMW/Outlook/VSTO/email/task-management
      identifiers in the persona body or frontmatter.
- [ ] Each persona documents which discovery schemas (#9002) and the domain profile (#9001)
      it consumes and which discovery artifact it produces.
- [ ] Structural tests validate the four persona definitions per repository precedent.

## Constraints & Risks

- Domain neutrality is an epic-wide invariant.
- Naming-collision constraint against the `code-modernization` plugin agents is mandatory.
- Any new `.claude/` asset must later be mirrored into
  `extensions/drm-copilot/resources/claude-customizations/` by the downstream publishing
  feature (#9012); this feature authors only the `.claude/` assets.
- The personas depend on the contracts defined by #9001 (domain profile) and #9002 (seven
  schemas), both prepared in parallel within the epic.
- Skills implementation is out of scope (feature #9008).

## Test Conditions to Consider

- [ ] Structural/frontmatter checks for the four agent definitions (repo precedent).
- [ ] Domain-neutrality scan for banned substrings.
- [ ] Naming-collision guard against the code-modernization plugin agent names.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/legacy-discovery-agent-roles/` folder from the template
