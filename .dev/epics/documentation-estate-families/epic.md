---
epic: documentation-estate-families
integration_branch: epic/documentation-estate-families-integration
created_at: 2026-11-23T05:33:36Z
# PLANNING MANIFEST. issue_num values 90001-90006 are placeholders and depends_on uses
# feature_folder short names; both are back-filled with real issue numbers and resolved
# folder basenames as each child preparation fans in.
intent:
  epic_type: enabler
  business_outcome_hypothesis: A consumer repository can plan, author, lint, review on a cadence, and prove completeness of a full production documentation estate (families such as onboarding, administration, security, operations, service management, architecture and ADRs, in addition to surface reference) through the drm-copilot documentation workflow, without bespoke per-repository tooling.
  leading_indicators:
    - A fixture repository with a required family that has no page and no recorded exclusion fails docs-complete naming the family, and passes after a page or an exclusion is recorded.
    - The init-written _docs-quality.yml runs markdown lint and a pinned, hash-verified Vale binary, and a page containing a hyperbole term fails the tonality rule.
    - A page whose review_due precedes the injected clock produces an overdue finding, and blocks docs-complete only when the profile option says so.
  nfrs:
    - No new Python; the docs library stays PowerShell 7.4 (or bash), and TypeScript is used only for MCP and extension command surfaces.
    - Framework code is domain-neutral; repository specificity is runtime configuration in the docs profile.
    - Tested code reads no wall clock; calendar checks take an injected clock.
    - Bundle copies under extensions/drm-copilot/resources/ and the Codex, Claude, and Copilot surfaces stay in parity per config/harness-parity-matrix.json and the harness generator.
    - Line coverage >= 85% on new PowerShell (no branch gate) and line >= 85% / branch >= 75% on new TypeScript; files stay within the 500/700/800 line tiers.
features:
  - issue_num: 90001
    feature_folder: docs-family-profile-model
    depends_on: []
  - issue_num: 90002
    feature_folder: docs-family-page-templates
    depends_on: []
  - issue_num: 90003
    feature_folder: docs-prose-markdown-lint
    depends_on: []
  - issue_num: 90004
    feature_folder: docs-family-gate-and-ia
    depends_on: [docs-family-profile-model]
  - issue_num: 90005
    feature_folder: docs-review-cadence
    depends_on: [docs-family-profile-model, docs-family-gate-and-ia, docs-family-page-templates]
  - issue_num: 90006
    feature_folder: docs-epic-scale-routing
    depends_on: [docs-family-profile-model, docs-family-gate-and-ia]
---

# documentation-estate-families - Epic

- Issue: #1217
- Owner: Dan Moisan
- Last Updated: 2026-11-23

## Goal

Extend the drm-copilot documentation workflow from a surface-driven reference generator into a
workflow that can plan and prove a full production documentation estate: documentation
families, review cadence, prose and Markdown lint in CI, and an epic-scale route for large
estates. The reference estate in the `rgf-forecast` repository
(`docs/production-documentation/`, its `_templates/`, `.github/workflows/_docs-quality.yml`,
`.docs-check.json`, `.vale.ini`, `styles/RgfTonality/`, and the comprehensive-documentation
epic) is read-only reference input.

## Scope

1. Documentation families in the docs profile (`required_families`), seeded by `docs-init`, with
   not-applicable exclusions, per-family review intervals, and a legacy-page exclusion list.
2. Page templates for the new families.
3. Markdown lint and pinned, hash-verified Vale in the init-written `_docs-quality.yml`,
   tonality Vale rules, and an `SME input required` placeholder token counted in coverage output.
4. A family check in the docs-complete gate, legacy exclusion reporting, and a family-planning
   step in `docs-plan-ia`.
5. Review cadence (`review_due`, overdue finding through an injected clock, docs-complete option).
6. Epic-scale routing guidance in `documentation-workflow`.

## Non-Goals

- An external documentation portal or site generator.
- Event or AsyncAPI reference pages.
- Changes to the `rgf-forecast` repository.

## Shared Design

These contracts are fixed here so the wave-0 children can be prepared and executed in parallel.

- **Family record (owned by docs-family-profile-model).** `required_families[]` entries carry
  `id`, `directory`, `diataxis_mode`, `template`, `audience`, `review_interval_days`,
  `required` (boolean), and an optional `exclusion` object (`reason`, `recorded_at`). A family
  with `required: true` and an `exclusion` is not applicable and is reported, not failed.
- **Default family ids.** `product-overview`, `getting-started` (quickstart, developer
  onboarding, operator onboarding), `user-guides`, `administration` (topology, configuration,
  storage and scaling, upgrades, backup/restore/DR, maintenance, authentication), `security`
  (overview, access control, audit and logging, control map, vulnerability reporting; plus
  repository-root `SECURITY.md` and `CODEOWNERS`), `operations` (runbooks, playbooks, alerts
  catalog), `service-management` (SLI/SLO/SLA, change and release, incident management),
  `architecture` (overview, components, data flow, trust boundaries and failure domains),
  `adr`, and `reference` (the existing surface-driven pages).
- **Template ids (owned by docs-family-page-templates).** New template files under
  `.claude/skills/docs-author-page/templates/`: `product-overview.md`, `onboarding.md`,
  `runbook.md`, `playbook.md`, `adr.md`, `security.md`, `service-management.md`,
  `alerts-catalog.md`; `architecture-overview.md` gains data-flow and trust-boundary sections.
  The family record's `template` value is the template file basename without `.md`.
- **Legacy exclusion list (owned by docs-family-profile-model; reported by
  docs-family-gate-and-ia).** A profile `legacy_exclusions[]` of repository-relative page paths,
  each with a `reason`; it is reported on every docs-complete run and expected to shrink to empty.
- **Placeholder token (owned by docs-prose-markdown-lint).** The literal `SME input required` in
  a page body is a placeholder; its count is reported in docs coverage output.
- **Review cadence (owned by docs-review-cadence).** `review_due` joins the front-matter field
  enum; `review_due` must be later than `last_reviewed`; the default `review_due` is
  `last_reviewed` plus the family `review_interval_days`. The pin-based `DOCS_STALE_PAGE` finding
  is kept unchanged.

## Decomposition and Waves

| Wave | Feature | Depends on | Complexity | Rationale |
| --- | --- | --- | --- | --- |
| 0 | docs-family-profile-model | none | C3 | Schema plus profile loader, docs-init seeding, MCP parameter shape, bundle and parity copies. |
| 0 | docs-family-page-templates | none | C2 | Markdown templates and docs-author-page skill text across surfaces; no library logic. |
| 0 | docs-prose-markdown-lint | none | C3 | CI template steps with pinned download verification, Vale styles, placeholder counter in PowerShell. |
| 1 | docs-family-gate-and-ia | docs-family-profile-model | C3 | Consumes the family record and legacy list in DocsCompleteGate, receipt, coverage report, docs-plan-ia, MCP tools. |
| 2 | docs-review-cadence | docs-family-profile-model, docs-family-gate-and-ia, docs-family-page-templates | C3 | Reads review_interval_days, adds a docs-complete option after the family check lands, and edits the new templates' front matter. |
| 2 | docs-epic-scale-routing | docs-family-profile-model, docs-family-gate-and-ia | C2 | Skill guidance that cites family ids and docs-complete family semantics. |

Edges follow consumed contracts only. docs-review-cadence depends on docs-family-gate-and-ia
because both edit `DocsCompleteGate.psm1`, and on docs-family-page-templates because it adds
`review_due` to the new templates. docs-prose-markdown-lint and docs-family-gate-and-ia may both
touch `DocsCoverageReport.psm1` in different sections; that overlap is accepted rather than
serialized.
