# 2026-11-23-docs-family-page-templates — Spec

- **Issue:** #1222
- **Parent (optional):** #1217 (epic documentation-estate-families, wave 0)
- **Owner:** drmoisan
- **Last Updated:** 2026-11-23T00-39
- **Status:** Draft
- **Version:** 0.2

## Overview

The `docs-author-page` skill ships page templates only for surface-driven reference pages and the four Diataxis narrative modes (`api-reference`, `architecture-overview`, `cli-reference`, `config-reference`, `explanation`, `how-to`, `http-reference`, `tutorial`). A production documentation estate also needs pages for documentation families such as product overview, onboarding, operations (runbooks, playbooks, alerts catalog), service management, security, and architecture decision records. Without templates for those families, every consumer repository authors the shape by hand, and the docs page checker has no tested guarantee that such pages are accepted.

This feature adds eight family templates, extends `architecture-overview.md`, updates the skill documentation, keeps every mirrored and bundled copy in parity, and proves acceptance of all templates by the full page checker. The design follows Approach A of `research/research.2026-11-23T05-45.md`: a separate family template set in the test helpers, so the existing pinned counts and body rules stay unchanged.

## Behavior

- Add eight templates under `.claude/skills/docs-author-page/templates/`, with these ids and Diataxis modes:

  | Template | `diataxis_mode` | H2 sections |
  | --- | --- | --- |
  | `product-overview.md` | explanation | Problem and Purpose; Supported Use Cases; Audience and Roles; Deployment Options and Interfaces; Support Boundaries and Non-Goals; Known Limitations; Where to Go Next |
  | `onboarding.md` | how-to | Before You Begin; Steps; Expected Result; Verify; If Something Does Not Work; Related Reference |
  | `runbook.md` | how-to | Purpose; Trigger; Severity and Ownership; Preconditions; Diagnostics; Decision Points; Remediation; Validation; Evidence and Follow-up |
  | `playbook.md` | how-to | Purpose; Scenario Scope; Roles and Responsibilities; Activation Criteria; Communication Channels and Cadence; Coordination Steps; Runbooks Coordinated; Handoff; Closure and Postmortem Handoff; Related |
  | `adr.md` | explanation | Status; Date; Context; Decision; Alternatives Considered; Consequences; Approvers |
  | `security.md` | explanation | Scope and Data Classification; Authentication and Authorization Model; Secrets Handling; Privileged Operations; Audit and Logging; Vulnerability Reporting; Control Mapping; Exceptions and Assumptions |
  | `service-management.md` | explanation | SLI, SLO and SLA; Change and Release Management; Incident Management (H3 subsections per part; a leading note tells the author to keep the covered part and delete the others) |
  | `alerts-catalog.md` | reference | Purpose; Catalog; Severity Scale; Related |

- Every new template carries exactly the five front-matter fields `owner`, `last_reviewed`, `audience`, `diataxis_mode`, and `surface_refs`, one per line, every value a JSON value. `surface_refs` is `[]` because a family page covers no surface element. The placeholder tokens for the other fields are `"<owner-id>"`, `"<yyyy-mm-dd>"`, and `["<audience-id>"]`.
- The `how-to` templates (`onboarding`, `runbook`, `playbook`) carry literal ordered-list lines (`1.`, `2.`) in their step sections so the checker rule `DOCS_PAGE_MODE_STEPS_MISSING` is satisfied.
- No heading in an `explanation` or `reference` template starts with `How to ` or matches `Step <n>`.
- `alerts-catalog.md` is hand-authored reference content and carries no `docs:generated` marker.
- The `adr.md` leading note gives the `NNNN-short-slug.md` naming. It has no Review Date section. It names no repository directory.
- Extend `architecture-overview.md` (mode stays `explanation`) with `## Data Flow`, `## Trust Boundaries`, and `## Failure Domains`, placed after `## Interactions` and before `## Boundaries and Constraints`. Each new section carries a table skeleton as defined in research section 6.
- Templates are domain-neutral. Nothing from the reference estate that research section 5 lists as non-portable is carried over: product or repository names, the `diataxis:` key, `review_due`, non-JSON `audience` placeholders, the "SME input required" owner text, `ALR-NN` identifiers and concrete alert conditions, named endpoints, exit codes, stores, ingress components, file-system zones, a fixed `Sev1`-`Sev3` ladder, the ADR directory path, and `src/` or test paths.
- Update `.agents/skills/docs-author-page/SKILL.md` (the source): replace the template table with columns `Template`, `diataxis_mode`, and `Use when`, listing every template; add to Steps item 1, after its first sentence, that the author chooses by family from the table, that a family page without a surface element uses `surface_refs: []`, and that `alerts-catalog` pages are `reference` and may need their own `directory_modes` entry. Step 6 and the `substitutions.json` `find` strings stay unchanged. Regenerate `.claude/skills/docs-author-page/SKILL.md` through `scripts/harness-generation/Invoke-HarnessGeneration.ps1`, and bring both bundle copies into byte parity.
- Copy each template, new and extended, byte-identically (LF line endings) to four roots: `.claude/skills/docs-author-page/templates/`, `.agents/skills/docs-author-page/templates/`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/docs-author-page/templates/`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-author-page/templates/`.
- List each new template path once in each of three pack manifests: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/shared.json`. The Codex `core.json` skill and template lines are edited by hand because `render_manifest` does not add them.
- Add a `FamilyTemplateModes` key to `Get-DocsAuthoringNamedSet` in `tests/scripts/claude-runtime/DocsAuthoringRoles.Helpers.ps1` (additive; existing keys unchanged).

## Inputs / Outputs

- Inputs: the committed template files, read as text by tests; the docs profile example `examples/docs/v1/docs-profile.example.json` for the acceptance test profile.
- Outputs: eight new template files at four roots, one extended template at four roots, an updated SKILL.md at four locations, three updated pack manifests, one helper key, and two new Pester files.
- Config keys and defaults: none added.
- Versioning or backward-compatibility constraints: no change to the page-metadata schema, so no new front-matter key is permitted in any template. Existing templates keep their ids and their front matter.

## API / CLI Surface

No command, flag, or request shape changes. The consumer-visible surface is the template set that `docs-author-page` offers.

- Contract: a template, after in-memory substitution of its placeholder tokens, is accepted by `Get-DocsPageCheckFinding` with zero error findings. Substitution values: a valid identifier for `<owner-id>`, a valid calendar date for `<yyyy-mm-dd>`, an audience declared in the test profile for `<audience-id>`. Reference templates that carry a generated block also substitute an element id of the form `cli-command-` plus 64 hexadecimal characters.
- Validation rules: the checker rules in `DocsPageCheck.psm1`, `DocsPageFrontMatter.psm1`, `DocsPageMetadata.psm1`, `DocsPageDiataxis.psm1`, and `DocsPageLinks.psm1`, unchanged.

## Data & State

No runtime data or state changes. Template text is static Markdown.

- Invariants: the five-field front matter; LF line endings; byte identity across the four roots; one manifest entry per template per manifest.
- Placeholder convention: angle-bracket phrases in the body, plain bullets (not Markdown links) in Related sections so that a rendered template has no broken link.

## Constraints & Risks

- No new Python; any test or tooling is PowerShell 7.4 (Pester) or bash. Tests run in parallel only.
- Templates are domain-neutral; repository specificity belongs in the docs profile.
- Files stay within the 800-line hard limit; new test files stay well below 500 lines; `tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1` (696 lines) is not extended. Tests create no temporary files.
- Risk: a missed mirror copy or manifest entry fails the mirror, push-down, or harness repo-gate tests. Mitigation: copy from one source text and run the contract tests listed in the acceptance criteria.
- Risk: CRLF in any copy breaks byte identity. Mitigation: write all copies with LF.
- Risk: the generator may not write both bundle copies of SKILL.md. Mitigation: run the generator, inspect `git status`, and copy any bundle copy it did not write; the mirror test proves identity.

## Implementation Strategy

- Implementation scope: template and SKILL.md content, copies, manifest edits, one helper key, two Pester files.
- New tests:
  - `tests/scripts/claude-lib/docs/DocsAuthorPageTemplates.Acceptance.Tests.ps1`: enumerates the committed template directory at discovery, substitutes placeholders in memory, builds an in-memory page set with a `docs/README.md` that links the page (page placed under `docs/guide/`, not under a directory-mode path), runs `Get-DocsPageCheckFinding`, and asserts zero error findings; plus two negative cases.
  - `tests/scripts/claude-runtime/docs-authoring-roles.FamilyTemplates.Tests.ps1`: byte identity at four roots, manifest membership exactly once in three manifests, front-matter shape, and body rules by mode, with the reference rule relaxed to allow zero generated blocks for `alerts-catalog`.
- New classes, functions, or commands: none in production code. No docs lib production module changes.
- Dependency changes: none.
- Logging or telemetry: none.
- Rollout plan: ordinary merge; consumer repositories receive the templates through push-down.

## Acceptance Criteria

Template content

- [x] The new template files named `product-overview.md`, `onboarding.md`, `runbook.md`, `playbook.md`, `adr.md`, `security.md`, `service-management.md`, and `alerts-catalog.md` exist under `.claude/skills/docs-author-page/templates/`. Proved by `tests/scripts/claude-runtime/docs-authoring-roles.FamilyTemplates.Tests.ps1`.
- [x] Each new template declares the `diataxis_mode` in the Behavior table (`product-overview`, `adr`, `security`, `service-management`: explanation; `onboarding`, `runbook`, `playbook`: how-to; `alerts-catalog`: reference) and contains the H2 sections listed for it in the Behavior table, in that order. Proved by `docs-authoring-roles.FamilyTemplates.Tests.ps1` using the `FamilyTemplateModes` helper key.
- [x] Each new template has front matter with exactly the keys `owner`, `last_reviewed`, `audience`, `diataxis_mode`, and `surface_refs`, one per line, each value a JSON value, and `surface_refs: []`. Proved by `docs-authoring-roles.FamilyTemplates.Tests.ps1` (parsed with `ConvertFrom-DocsPageFrontMatter`).
- [x] `onboarding.md`, `runbook.md`, and `playbook.md` each contain at least one literal ordered-list line (`^ {0,3}[0-9]{1,9}[.)] +\S`) outside fenced code and HTML comments. Proved by `docs-authoring-roles.FamilyTemplates.Tests.ps1`.
- [x] No heading in any `explanation` or `reference` family template starts with `How to ` (case-insensitive) or matches `^Step\s+[0-9]+\b`. Proved by `docs-authoring-roles.FamilyTemplates.Tests.ps1`.
- [x] `alerts-catalog.md` contains no `docs:generated:start` or `docs:generated:end` marker. Proved by `docs-authoring-roles.FamilyTemplates.Tests.ps1`.
- [x] `architecture-overview.md` contains `## Data Flow`, `## Trust Boundaries`, and `## Failure Domains` between `## Interactions` and `## Boundaries and Constraints`, and its `diataxis_mode` remains `explanation`. Proved by `docs-authoring-roles.FamilyTemplates.Tests.ps1`.
- [x] No template carries a `review_due` key, the token `SME input required`, or the `diataxis:` key name. Proved by `docs-authoring-roles.FamilyTemplates.Tests.ps1`.

Checker acceptance

- [x] For every template file in the template directory (the existing templates, the new templates named in Behavior, and the extended `architecture-overview.md`), a page rendered by in-memory placeholder substitution yields zero findings of severity `error` from `Get-DocsPageCheckFinding` in `.claude/lib/docs/DocsPageCheck.psm1`. The test enumerates the directory at discovery, so a later template is covered automatically. Proved by `tests/scripts/claude-lib/docs/DocsAuthorPageTemplates.Acceptance.Tests.ps1`.
- [x] Negative case 1: a `how-to` template rendered with its ordered-list lines removed yields `DOCS_PAGE_MODE_STEPS_MISSING`. Proved by `DocsAuthorPageTemplates.Acceptance.Tests.ps1`.
- [x] Negative case 2: an `explanation` template rendered with an added `## How to ...` heading yields `DOCS_PAGE_MODE_INSTRUCTION_HEADING`. Proved by `DocsAuthorPageTemplates.Acceptance.Tests.ps1`.

Skill documentation and generation

- [x] `.agents/skills/docs-author-page/SKILL.md` lists every template in the template directory with its `diataxis_mode` and a `Use when` statement, states that a family page without a surface element uses `surface_refs: []`, and states that `alerts-catalog` pages are `reference` and may need their own `directory_modes` entry. Proved by `docs-authoring-roles.FamilyTemplates.Tests.ps1` (every template id appears in a table row of each SKILL.md copy with its mode).
- [x] `.claude/skills/docs-author-page/SKILL.md` is produced by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` from the `.agents` source (no hand edit), and `Invoke-HarnessGeneration.ps1 -Check` reports no drift. Proved by running `-Check` and by `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1`.
- [x] The bundle copies of SKILL.md under `extensions/drm-copilot/resources/` are byte-identical to their source copies. Proved by `tests/scripts/claude-runtime/docs-authoring-roles.Mirrors.Tests.ps1` and the push-down resource contract tests.

Parity and manifests

- [x] Each new and extended template is byte-identical at `.claude/skills/docs-author-page/templates/`, `.agents/skills/docs-author-page/templates/`, and the `extensions/drm-copilot/resources/` bundle roots named in Behavior. Proved by `docs-authoring-roles.FamilyTemplates.Tests.ps1` (SHA-256 comparison).
- [x] Each new template path is listed exactly once in each pack manifest named in Behavior. Proved by `docs-authoring-roles.FamilyTemplates.Tests.ps1` and the pack-manifest completeness tests.

Regression and contract tests

- [x] `docs-authoring-roles.Templates.Tests.ps1`, `docs-authoring-roles.Mirrors.Tests.ps1`, and `docs-authoring-roles.WorkflowText.Tests.ps1` pass with no edit to their assertions or counts.
- [x] The push-down contract tests pass: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, and `test_push_down_codex_and_agents_pack_manifest_completeness.py`, together with `generate_codex_agent_variants.py --check`.
- [x] No file under `.claude/lib/docs/` changes (production modules untouched). Proved by the branch diff in the feature review.
- [x] Each new test file is under 500 lines, creates no temporary file, and passes in a parallel Pester run. Proved by the launcher `pester` suite run and the file-size check.

## Decisions

Autonomous mode: the recommended option was taken for each question and recorded here.

- Q1, mode of `runbook`, `playbook`, `onboarding`: how-to. The reference estate uses how-to, and the checker then requires a literal ordered step list, which each template carries.
- Q2, `surface_refs` value: `[]`. A family page covers no surface element, and the schema allows the empty list.
- Q3, test enumeration: a separate `FamilyTemplateModes` key and new test files (Approach A). Existing pinned counts and the reference body rule stay unchanged.
- Q4, `SME input required` token: not used. The token belongs to docs-prose-markdown-lint; templates use angle-bracket placeholders.
- Q5, ADR Review Date section: omitted. `review_due` front matter (docs-review-cadence) will carry review timing, and a body date would duplicate it.
- Q6, service-management: one template with three H2 part groups. The epic fixes the single id.
- Q7, `docs-plan-ia` Steps item 4 prose: left unchanged. It remains true for mode choice; family planning belongs to docs-family-gate-and-ia.
- Q8, `alerts-catalog` generated block: omitted. The relaxed rule applies only to the family-set body test.
- Q9, diagram block in `architecture-overview`: omitted. The existing sentence that a diagram may be added stays.
- Q10, `alerts-catalog` directory-mode interaction: note in SKILL.md and flag to the epic (see Cross-Feature Notes); no change outside this feature.
- Q11 (process, from research), SKILL.md regeneration: edit the `.agents` source, leave the `substitutions.json` `find` strings unchanged, regenerate, then run `-Check`.

## Non-Goals

- The `review_due` front-matter field and review-cadence checks (docs-review-cadence). Templates carry no key outside the existing schema.
- The documentation family schema and `diataxis_policy.directory_modes` seeding (docs-family-profile-model).
- The docs-complete family check and `docs-plan-ia` edits (docs-family-gate-and-ia).
- The `SME input required` token and its coverage count (docs-prose-markdown-lint).
- Any change to a docs lib production module under `.claude/lib/docs/`, to the page-metadata schema, or to the docs profile example.
- Reference-estate content that is repository-specific (see Behavior).

## Cross-Feature Notes

- Flag for the epic (research conflict 3, directory-mode interaction): a family record carries one `diataxis_mode`, but the operations family holds how-to pages (runbooks, playbooks) and a reference page (alerts catalog), and `getting-started` and `reference` may also mix modes. If docs-family-profile-model seeds `diataxis_policy.directory_modes` from the family mode, an `alerts-catalog` page under the operations directory raises `DOCS_PAGE_MODE_DIRECTORY_MISMATCH`, because the first covering entry in profile order decides. Recommended mitigation for docs-family-profile-model: list a more specific `directory_modes` entry (for example the catalog path) before the family directory. This feature records the note in SKILL.md and changes nothing else.
- `docs-plan-ia` Steps item 4 still names the pre-existing templates for mode choice; the family-planning step belongs to docs-family-gate-and-ia.
- The `review_due` field, when added by docs-review-cadence, requires a schema extension and a template update by that feature.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, .dev/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Pester tests that run the page checker over each template rendered as a page
- [ ] Parity and bundle contract tests for the mirrored template files
- [ ] Harness generator check for generated skill copies
