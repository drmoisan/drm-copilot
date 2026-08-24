# legacy-discovery-skills (Issue #367)

- Date captured: 2026-07-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/legacy-discovery-skills/ (Issue #367)
- Parent: Epic `legacy-discovery-and-parity` (child feature #9008, Wave 2, complexity C3)

- Issue: #367
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/367
- Last Updated: 2026-07-17
- Work Mode: full-feature

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

## Proposed Behavior

Author reusable `.claude/skills/<name>/SKILL.md` workflow-mechanics skills that
sequence the discovery and parity-definition workflow:

- Drive the analyzer CLI commands (`dev.discovery.*`) delivered by the analyzer
  framework (#9006) and the .NET/VSTO analyzers (#9014).
- Invoke the four generic agent roles (#9007): Legacy Parity Analyst, Runtime
  Characterization Analyst, Requirements Reconciler, Migration Coverage
  Reviewer, by name.
- Produce and validate the machine-readable discovery artifacts governed by the
  schemas (#9002) and validators (#9003), reading domain specificity from the
  domain profile (#9001) at runtime.

Skills follow the repository's SKILL.md conventions (YAML frontmatter:
`allowed-tools`, `context`, `agent` routing) and reference the discovery agents,
schemas, validators, and analyzer CLI commands by name. Skills remain
domain-neutral: no TaskMaster/TMW/Outlook/VSTO/email/task-management-specific
behavior; all domain specificity is runtime configuration from the domain
profile.

## Acceptance Criteria (early draft)

- [ ] Reusable `.claude/skills/<name>/SKILL.md` workflow-mechanics skills sequence
      the discovery and parity-definition workflow (analyzer invocation, agent-role
      routing, artifact production/validation).
- [ ] Each skill follows the repository SKILL.md conventions (YAML frontmatter with
      `allowed-tools`, `context`, and `agent` routing) and references discovery
      agents, schemas, validators, and analyzer CLI commands by name.
- [ ] Skill names do not collide with or duplicate the installed `code-modernization`
      plugin's `/modernize-*` command names (modernize-assess, modernize-brief,
      modernize-extract-rules, modernize-harden, modernize-map, modernize-preflight,
      modernize-reimagine, modernize-status, modernize-transform, modernize-uplift)
      or its agent names (legacy-analyst, business-rules-extractor, architecture-critic,
      scaffolder, security-auditor, test-engineer, version-delta-analyst).
- [ ] Skills are domain-neutral: no TaskMaster/TMW/Outlook/VSTO/email/task-management
      identifiers; domain specificity is read from the domain profile at runtime.
- [ ] References to upstream dependencies (analyzer framework #9006, agent roles #9007)
      are isolated behind stable names so the skills remain correct as those
      dependencies land.
- [ ] Structural skill checks per repository precedent pass for the new skills.

## Constraints & Risks

- Domain neutrality is a hard epic invariant.
- Depends on the analyzer framework (#9006, in preparation) for the `dev.discovery.*`
  analyzer CLI, and on the generic agent roles (#9007, in preparation) for the four
  agent personas. Both are prepared in parallel and may not be merged; design against
  planned scope and isolate references behind names.
- Naming-collision risk with the installed `code-modernization` plugin. New skill
  names must not collide with its `/modernize-*` commands or its agents.
- Any new `.claude/` asset is mirrored to the `resources/` subtree later by the
  publishing feature (#9012); mirroring is out of scope here.
- Evidence output belongs under `<FEATURE>/evidence/<kind>/` only.

## Test Conditions to Consider

- [ ] Skill structural checks: each new SKILL.md has valid YAML frontmatter with the
      required fields per repository precedent.
- [ ] Skill names do not collide with the `code-modernization` plugin command/agent names.
- [ ] Domain-neutrality: no banned domain substrings in skill sources.
- [ ] Referenced agent, schema, validator, and analyzer CLI names resolve to the
      planned upstream contracts.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/legacy-discovery-skills/` folder from the template
