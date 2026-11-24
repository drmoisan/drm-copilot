# Research: docs-family-page-templates (Issue #1222, epic #1217, wave 0, C2)

- Timestamp: 2026-11-23T05-45 (fallback stamp; this agent has no clock tool, so the stamp is the one the delegation prompt supplied)
- Scope: eight new `docs-author-page` templates, an extended `architecture-overview.md`, SKILL.md update, mirror parity. Out of scope: `review_due`, the family schema, the docs-complete family check.
- Method: file reads and searches only. No test, generator, or toolchain command was run (this agent has no Bash tool). Facts that need a run are marked "unverified".

## 1. Current State: Existing Templates

Location: `.claude/skills/docs-author-page/templates/`. Eight files, all hand-copied byte-identically to three more locations (see section 4).

Front matter (identical in all eight, five fields, one per line, every value a JSON value):

| Field | Template value | Rule source |
| --- | --- | --- |
| `owner` | `"<owner-id>"` | `common.schema.json` `identifier`: `^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$` |
| `last_reviewed` | `"<yyyy-mm-dd>"` | `review-date`: `^[0-9]{4}-[0-9]{2}-[0-9]{2}$`, plus a calendar-date check (`Test-DocsPageReviewDate`) |
| `audience` | `["<audience-id>"]` | `audience-id`: `^[a-z0-9][a-z0-9-]*$`; non-empty, unique; must be declared in the profile `audiences` |
| `diataxis_mode` | one of `tutorial`, `how-to`, `explanation`, `reference` | `common.schema.json` `diataxis-mode` enum |
| `surface_refs` | `["<element-id>"]` | `element-id`: `^(?:cli-command\|cli-option\|http-route\|config-key\|public-symbol\|architecture-component)-[0-9a-f]{64}$`; array, unique, no `minItems` |

`page-metadata.schema.json` has `additionalProperties: false` and properties `owner`, `last_reviewed`, `audience`, `diataxis_mode`, `surface_refs`, `title`, `extensions`. A new front-matter key such as `review_due` would be `DOCS_PAGE_FIELD_UNKNOWN` until docs-review-cadence extends the schema, so the new templates must carry exactly the five fields.

Placeholder conventions: four front-matter tokens, `<owner-id>`, `<yyyy-mm-dd>`, `<audience-id>`, `<element-id>`; body placeholders are angle-bracket phrases (`<Tutorial title>`, `<One paragraph that ...>`). Related sections use plain bullets (`- <Link to the reference page ...>`), never a Markdown link, so a rendered template has no broken link.

Heading structure (H1 title, then H2 sections):

| Template | Mode | Narrative or reference | H2 sections |
| --- | --- | --- | --- |
| `tutorial.md` | tutorial | narrative | Before You Start, Steps (ordered), What You Built |
| `how-to.md` | how-to | narrative | Prerequisites, Procedure (ordered), Verify, Related |
| `explanation.md` | explanation | narrative | Context, Design, Trade-offs |
| `architecture-overview.md` | explanation | narrative (27 lines) | Components (table), Interactions, Boundaries and Constraints |
| `cli-reference.md` | reference | reference | Synopsis and Options, Exit Codes and Notes |
| `http-reference.md` | reference | reference | Routes, Authentication and Errors |
| `config-reference.md` | reference | reference | Keys, Precedence and Defaults |
| `api-reference.md` | reference | reference | Members, Usage Notes |

The four reference templates each carry exactly one `<!-- docs:generated:start id=<element-id> -->` / `end` pair on their own lines and a sentence telling the author not to edit the block. The four narrative templates carry none.

## 2. Page Checker: What a Page Must Satisfy

Modules read: `.claude/lib/docs/DocsPageCheck.psm1`, `DocsPageFrontMatter.psm1`, `DocsPageMetadata.psm1`, `DocsPageDiataxis.psm1`, `DocsPageLinks.psm1`, `DocsPageMarkdown.psm1` (headers and the relevant functions), and `schemas/v1/page-metadata.schema.json` and `common.schema.json`.

Entry points. `Get-DocsPageCheckFinding` (pure, in-memory page map `path -> text`, profile, composed schema set, existing paths, optional selected paths) runs every rule; `Invoke-DocsCheckCommand` wraps it with the command context (`ReadText`, `ListFile`, `ReadBytes`, `TestFile`).

Rules a page must satisfy, in order of application inside `Get-DocsPageCheckFinding` and `Get-DocsPageFieldRuleFinding`:

1. Root and entry. Each profile `documentation_roots[]` path must contain at least one page (`DOCS_PAGE_ROOT_EMPTY`) and a `README.md` or `index.md` (`DOCS_PAGE_ROOT_ENTRY_MISSING`).
2. Decode. At most 1 MiB (`DOCS_PAGE_TOO_LARGE`); strict UTF-8, BOM removed (`DOCS_PAGE_ENCODING_INVALID`). Either suppresses every rule of that page except orphan.
3. Front matter parse. The block starts on line 1 with exactly `---` and ends at the next exact `---` or `...` (`DOCS_PAGE_FRONT_MATTER_UNTERMINATED`). A page with no block gets `DOCS_PAGE_FRONT_MATTER_MISSING` when the profile `diataxis_policy.required_front_matter` is non-empty. Only a YAML subset is accepted: top-level `key: value` lines, block sequences of scalars, comments, blanks; values are JSON values, single-line flow sequences, single-quoted scalars, or plain scalars. Block scalars, anchors, aliases, tags, nested sequences, mappings in a sequence item, tab indentation, flow mappings, and duplicate keys are findings. A parse finding suppresses field and Diataxis rules for that page.
4. Fields. Each field named in `required_front_matter` must be present (`DOCS_PAGE_FIELD_MISSING`). The schema gate and the constraint evaluator (pattern, minLength, uniqueItems) map to `DOCS_PAGE_OWNER_INVALID`, `..._LAST_REVIEWED_INVALID`, `..._AUDIENCE_INVALID`, `..._MODE_INVALID`, `..._SURFACE_REFS_INVALID`, `..._TITLE_INVALID`, `..._EXTENSIONS_INVALID`, and an unknown key to `DOCS_PAGE_FIELD_UNKNOWN`. `last_reviewed` must be an existing calendar date (`DOCS_PAGE_LAST_REVIEWED_NOT_A_DATE`). Each audience must be declared in the profile `audiences[].id` (`DOCS_PAGE_AUDIENCE_UNDECLARED`).
5. Diataxis (`DocsPageDiataxis.psm1`, skipped when `DOCS_PAGE_MODE_INVALID` or `DOCS_PAGE_FRONT_MATTER_SCHEMA_INVALID` fired):
   - `DOCS_PAGE_MODE_NOT_IN_POLICY`: `diataxis_mode` must appear in `diataxis_policy.modes`.
   - `DOCS_PAGE_MODE_DIRECTORY_MISMATCH`: the first `diataxis_policy.directory_modes[]` entry (profile order) whose `path_or_glob` covers the page (exact, prefix plus `/`, or case-sensitive wildcard with `*` crossing `/`) must equal the declared mode.
   - `DOCS_PAGE_MODE_STEPS_MISSING`: `tutorial` and `how-to` need at least one ordered-list line matching `^ {0,3}[0-9]{1,9}[.)] +\S` outside fenced code and HTML comments.
   - `DOCS_PAGE_MODE_INSTRUCTION_HEADING`: `reference` and `explanation` must have no heading whose text starts with `how to ` (case-insensitive) or matches `^step\s+[0-9]+\b`.
   - `DOCS_PAGE_MODE_GENERATED_BLOCK`: `tutorial`, `how-to`, and `explanation` must have no line holding a `docs:generated:start` marker. A `reference` page may have one; the checker does not require one.
6. Links (`DocsPageLinks.psm1`): inline links and definitions outside fenced code, HTML comments, and code spans are resolved against the page directory; a missing page or file is `DOCS_PAGE_LINK_BROKEN`; an escape is `DOCS_PAGE_LINK_ESCAPES_REPOSITORY`; a missing fragment is `DOCS_PAGE_ANCHOR_MISSING` or `DOCS_PAGE_LINK_ANCHOR_MISSING`.
7. Orphans (`DocsPageOrphans.psm1`): every page must be reachable by links from a root entry page (`DOCS_PAGE_ORPHAN`).

Placeholder handling. The checker has no placeholder concept. A template file as committed does not pass: `"<owner-id>"` fails the `owner` pattern, `"<yyyy-mm-dd>"` fails the date pattern, `"<audience-id>"` fails the audience pattern, and `["<element-id>"]` fails the element-id pattern. The templates live in `templates/`, outside every documentation root, so `run_docs_check` never scans them. A template must be rendered into a page (placeholders substituted) before the checker is expected to accept it. Existing tests do exactly that in memory (section 3). Body placeholders such as `<Tutorial title>` need no substitution: none of the rules above inspect free prose, and no body link exists.

## 3. Existing Tests

| File | Describe / It (abbreviated) | How content is fed |
| --- | --- | --- |
| `tests/scripts/claude-runtime/docs-authoring-roles.Templates.Tests.ps1` | Describe `docs-author-page templates`: `covers 32 template files`; `gives <Path> the five front-matter fields with JSON values and diataxis_mode <Mode>`; `passes the page front-matter checker with no DOCS_PAGE_AUDIENCE_INVALID after placeholder substitution in <Path> (issue #1173)`; `gives <Path> the body rules of the <Mode> mode` | `-ForEach` rows from `Get-DocsAuthoringNamedSet` x `Get-DocsAuthoringSkillRoot`; `Read-DocsAuthoringText` reads the committed file; the four placeholders are substituted in memory; only `ConvertFrom-DocsPageFrontMatter` and `Test-DocsPageFrontMatter` run. The body-rule test requires, for `reference`, exactly one generated start and one end marker. |
| `tests/scripts/claude-runtime/docs-authoring-roles.Mirrors.Tests.ps1` | `keeps the <Template> template byte-identical at all four skill locations`; `lists every Claude file of the feature exactly once in the Claude core manifest` (asserts `$expected.Count | Should -Be 23`); `lists every Codex and .agents file ... Codex core manifest` (asserts 20) | SHA-256 of committed files; manifests read through `Get-DocsPackManifestPath` |
| `tests/scripts/claude-runtime/DocsAuthoringRoles.Helpers.ps1` | helper (not a test): `Get-DocsAuthoringNamedSet` holds `$templateModes`, an ordered map of the eight template ids to modes; `Get-DocsAuthoringSkillRoot` returns the four skill roots | in-memory data |
| `tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1` | page-name rows read the `## Steps` section of every `docs-author-page/SKILL.md` copy and assert the tokens `` `report`, `summary`, `findings` or `analysis` ``, `may be refused by the runtime`, `the root writes it` | committed text |
| `tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1` (696 lines) | pure-function and command contexts of the checker | `New-TestProfile` from `examples/docs/v1/docs-profile.example.json`; `New-TestPage`; `New-TestPageSet` (README linking pages); `Get-DocsPageCheckFinding` over in-memory maps; `Get-DocsTestSchemaText` from `Docs.TestSupport.psm1`; `New-DocsTestContext` for the command |
| `tests/scripts/claude-lib/docs/DocsPageDiataxis.Tests.ps1`, `DocsPageFrontMatter.Tests.ps1`, `DocsPageLinks.Tests.ps1`, `DocsPageMetadata*.Tests.ps1` | unit tests of each module | in-memory |
| `tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1` | page-check configuration templates (markdownlint, Vale); unrelated to `docs-author-page` templates despite the name | committed files read read-only |

No existing test runs the full page checker (`Get-DocsPageCheckFinding`) over a rendered `docs-author-page` template. The existing front-matter test covers only front matter.

Recommended placement for the new acceptance tests:

- New file `tests/scripts/claude-lib/docs/DocsAuthorPageTemplates.Acceptance.Tests.ps1` (mirrors the `.claude/lib/docs` checker under test). Pattern: copy the `BeforeAll` of `DocsPageCheck.Tests.ps1` (import `DocsPageCheck.psm1`, import `DocsSchema.psm1` and `DocsJson.psm1` without `-Force`, import `Docs.TestSupport.psm1`; `$script:Composed = (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas`; profile from the example file with `audiences` set to `developers`). Per template: read the committed text with `[System.IO.File]::ReadAllText`, substitute the four tokens in memory (element id of the form `cli-command-` plus 64 hex characters for the four reference templates), place it under `docs/guide/<template>.md` (not under `docs/reference`, to avoid the example profile's directory mode), add a `docs/README.md` that links it, call `Get-DocsPageCheckFinding`, and assert that no finding has `severity` `error`. Enumerate templates with `Get-ChildItem` over the template directory at discovery so a future template is covered automatically. Reading committed files is the established pattern (`docs-authoring-roles.Templates.Tests.ps1`); no temp file is created.
- Additional negative cases in the same file: a how-to-mode template body with its ordered list removed yields `DOCS_PAGE_MODE_STEPS_MISSING`; an explanation-mode template with a `## How to ...` heading added yields `DOCS_PAGE_MODE_INSTRUCTION_HEADING` (proves the test can fail).
- New file `tests/scripts/claude-runtime/docs-authoring-roles.FamilyTemplates.Tests.ps1`: byte identity at four locations, manifest membership exactly once in the Claude core, Codex core, and Codex shared manifests, front-matter shape (five keys, JSON values), and body rules by mode with a relaxed reference rule (section 6). Add a `FamilyTemplateModes` key to `Get-DocsAuthoringNamedSet` in `DocsAuthoringRoles.Helpers.ps1`.
- Do not extend `DocsPageCheck.Tests.ps1` (696 lines, just under the 700 advisory tier).

## 4. Mirror and Parity

Sources read: `config/harness-parity-matrix.json`, `scripts/harness-generation/sources/skills/docs-author-page.substitutions.json`, `scripts/harness-generation/HarnessGeneration.psm1` (bundle path mapping), pack manifests, the Mirrors tests.

| Artifact | Class | Evidence |
| --- | --- | --- |
| `.agents/skills/docs-author-page/SKILL.md` | source, disposition `shared` (id `codex:skill:docs-author-page`), consumed by Codex and Copilot | parity matrix entry with `target_paths: [".claude/skills/docs-author-page/SKILL.md"]` |
| `.claude/skills/docs-author-page/SKILL.md` | `generated` from `.agents/skills/docs-author-page/SKILL.md` through `harness-generation/skills` with `docs-author-page.substitutions.json` (three `find`/`replace` pairs: the docs-author link on line 10 of the source, the Prerequisites sentence, the Step 2 root-step line) | parity matrix entry `claude:skill:docs-author-page` |
| `.github/skills/docs-author-page/SKILL.md` | `dropped` ("Superseded by the shared .agents/skills/docs-author-page, which Copilot reads natively") | parity matrix entry `copilot:skill:docs-author-page`; no `docs-author-page` path exists under `extensions/drm-copilot/resources/customizations/` |
| `.agents/skills/docs-author-page/references/standard.md` | hand-authored Codex gold standard; no Claude copy | `HarnessSkillContract.psm1` checks only structure (H2 order, OB and AC numbering). Its OB-2 and OB-3 do not enumerate templates, so no edit is required if Steps item 1 keeps its first sentence |
| Template files, all 8 existing and all new | not in the parity matrix, not generated; hand-copied byte-identically | no matrix hit for `templates/`; `Grep` of `scripts/harness-generation` finds no template handling; pinned by `docs-authoring-roles.Mirrors.Tests.ps1` |

Mirror copies that must change:

- SKILL.md: `.agents/skills/docs-author-page/SKILL.md` (edit by hand, this is the source); regenerate `.claude/skills/docs-author-page/SKILL.md` with `scripts/harness-generation/Invoke-HarnessGeneration.ps1`; bundle copies `extensions/drm-copilot/resources/claude-customizations/.claude/skills/docs-author-page/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-author-page/SKILL.md` (the generator maps `.claude/` targets and `.agents/` targets to those bundle roots in `HarnessGeneration.psm1`; whether it writes both bundle copies for this skill is unverified, so the executor runs the generator, inspects `git status`, and copies by hand any bundle copy it did not write; `docs-authoring-roles.Mirrors.Tests.ps1` proves byte identity).
- Templates (16 files after the change, each at four locations): `.claude/skills/docs-author-page/templates/`, `.agents/skills/docs-author-page/templates/`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/docs-author-page/templates/`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-author-page/templates/`.
- Pack manifests listing each template path (alphabetical, one line per file; all three currently list the eight existing templates): `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/shared.json`. The Codex `core.json` is only partly generated: `scripts/dev_tools/generate_codex_agent_variants.py` `render_manifest` appends agent paths and never adds skill or template paths, so the template lines are edited by hand.
- Copilot: no surface copy exists (skills are `dropped`; Copilot reads `.agents/skills`), so no Copilot file changes.

Contract tests that pin these copies (execution-environment brief `## Contract Tests That Pin Mirrored Files`): `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py` (bundle text equality), `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py` (every bundled file listed in a manifest), the Codex generator check `generate_codex_agent_variants.py --check` (module form; existing Python, not new), `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1` (generated skill equals its rendering), and `docs-authoring-roles.Mirrors.Tests.ps1`. The dependency-closure test is not affected (Markdown only). Bundle changes also trigger the push-down bundle-parity checks; those are the same contract tests.

## 5. Reference Input Summary (read-only; no names, hosts, or personal data carried)

Reference templates under the reference estate's `_templates/` directory. All seven use front matter `owner`, `last_reviewed`, `review_due`, `audience: [<tags>]`, and `diataxis:` (not `diataxis_mode`), with unquoted angle-bracket placeholders, so none passes this repository's checker as written (key name, `review_due`, non-JSON values).

| Reference template | Mode there | Section structure |
| --- | --- | --- |
| `product-overview.md` | explanation | Problem and purpose; Supported use cases; User roles and audience map; Deployment options and supported interfaces; Support boundaries and non-goals; Known limitations; Where to go next |
| `guide.md` | how-to | Before you begin; Steps (ordered); Expected result; Verify; If something does not work; Related reference |
| `runbook.md` | how-to | Purpose; Trigger; Severity guidance; Ownership and escalation; Preconditions; Diagnostics; Decision tree; Remediation (with rollback); Validation; Evidence and follow-up. The template has no ordered list, so it would fail `DOCS_PAGE_MODE_STEPS_MISSING` here |
| `adr.md` | explanation | Status (proposed, accepted, superseded, deprecated); Date; Context; Decision; Alternatives considered; Consequences; Approvers; Review date. Includes a file-naming note (`NNNN-short-slug.md`) |
| `security.md` | explanation | Scope and data classification; Authentication and authorization model; Secrets handling; Privileged operations; Audit and logging; Vulnerability reporting; Control mapping; Exceptions and assumptions to confirm |
| `architecture.md` | explanation | Context; Component inventory; Data flow; Trust boundaries; Failure domains; Operational dependencies; Key decisions; Diagrams (fenced diagram block); Assumptions to confirm |
| `reference.md` | reference | Scope; Canonical source; Entries (usage, parameters, errors, example); Versioning notes |

Pages that supply the shape of templates that have no `_templates/` file:

- Alerts catalog (`operations/alerts-catalog.md`, reference): Purpose; a table with columns alert id, condition, detection signal, severity, owner, responding runbook; per-alert notes; Severity scale; Related.
- Playbooks (`operations/playbooks/*.md`, how-to): Purpose; Scenario scope; Severity and lifecycle (cited, not restated); Roles and responsibilities; Activation criteria; Evidence to bring or Communication channels and cadence; Coordination steps (by phase); Runbooks coordinated; Handoff procedure; Decision tracking; Closure and postmortem handoff; Related.
- Onboarding (`getting-started/onboarding-*.md`, how-to): the `guide.md` structure, one page per audience (developer, operator).
- Service management: `sli-slo-sla.md` (explanation): Purpose; Service and user journey; SLI specifications; Measurement sources and instrumentation gaps; SLO targets; Error-budget policy; SLA; Review cadence; Related. `change-release-management.md` (explanation): Purpose; Change classes; Required review per class; Release procedure; Rollback per class; Change record; Freeze and exception handling; Related. `incident-management.md` (explanation): Purpose; Severity definitions; Incident lifecycle; Roles; Communication expectations; Blameless postmortem practice; Linkage chain; Related.
- Architecture: `data-flow.md` (explanation): Context; Data flow (one subsection per stage, marking where untrusted input enters); Diagrams; Key decisions; Assumptions. `trust-boundaries-and-failure-domains.md` (explanation): Context; Trust boundaries (one subsection per boundary); Operational dependencies; Failure domains (one subsection per domain); Key decisions.

Content that must not be carried over: the product and repository name in titles and examples; the `diataxis:` key name, the `review_due` field, and bracketed non-JSON `audience` placeholders; the owner text that reads "placeholder, manual SME input required" (the placeholder token belongs to docs-prose-markdown-lint); alert identifiers of the form `ALR-NN` and every concrete alert condition; named endpoints, CLI exit codes, database and store names, tunnel and ingress components, and file-system zone names; the `Sev1`, `Sev2`, `Sev3` ladder as fixed content (templates carry a severity-table skeleton with placeholder rows); the ADR directory path (`docs/architecture/adr/`), which is a repository layout choice that the docs profile owns; and any `src/` or test path used as a "sync test" precedent.

## 6. Diataxis Mode Mapping and Section Lists

All modes below are in the checker enum. Front matter of every new template: the five fields, `diataxis_mode` per the table, and `surface_refs: []` (a family page covers no surface element; `[]` is accepted by the schema (`element-ids` has no `minItems`) and is the value `DocsPageCheck.Tests.ps1` uses).

| Template | Mode | Required body shape | H2 sections (H3 where noted) |
| --- | --- | --- | --- |
| `product-overview.md` | explanation | no ordered steps needed; no `How to` or `Step N` heading | Problem and Purpose; Supported Use Cases; Audience and Roles (table); Deployment Options and Interfaces; Support Boundaries and Non-Goals; Known Limitations; Where to Go Next |
| `onboarding.md` | how-to | ordered list in Steps | Before You Begin; Steps (ordered); Expected Result; Verify; If Something Does Not Work; Related Reference. Title phrased "Onboard as `<audience role>`" (one template, audience chosen by the author) |
| `runbook.md` | how-to | ordered lists in Diagnostics and Remediation | Purpose; Trigger; Severity and Ownership; Preconditions; Diagnostics (ordered); Decision Points (bullets of condition and next action); Remediation (ordered, ends with rollback); Validation; Evidence and Follow-up |
| `playbook.md` | how-to | ordered list in Coordination Steps | Purpose; Scenario Scope; Roles and Responsibilities (table); Activation Criteria; Communication Channels and Cadence; Coordination Steps (ordered, grouped by phase); Runbooks Coordinated; Handoff; Closure and Postmortem Handoff; Related |
| `adr.md` | explanation | none | Status (one of proposed, accepted, superseded, deprecated; supersession link as plain text); Date; Context; Decision; Alternatives Considered; Consequences; Approvers. A leading note gives the `NNNN-short-slug.md` naming. No Review Date section (see Q5) |
| `security.md` | explanation | none | Scope and Data Classification; Authentication and Authorization Model; Secrets Handling; Privileged Operations; Audit and Logging; Vulnerability Reporting; Control Mapping (table: control, requirement, evidence); Exceptions and Assumptions |
| `service-management.md` | explanation | none | three part groups as H2: SLI, SLO and SLA (H3: Service and User Journey; SLI Specifications table; Measurement Sources; SLO Targets; Error-Budget Policy; SLA; Review Cadence); Change and Release Management (H3: Change Classes; Review per Class; Release Procedure; Rollback per Class; Change Record; Freeze and Exceptions); Incident Management (H3: Severity Definitions table; Incident Lifecycle; Roles; Communication Expectations; Postmortem Practice). A leading note tells the author to keep the part that the page covers and delete the others |
| `alerts-catalog.md` | reference | no generated block required by the checker | Purpose; Catalog (table: Alert ID, Condition, Detection Signal, Severity, Owner, Responding Runbook); Severity Scale (table); Related |
| `architecture-overview.md` (extended) | explanation (unchanged) | none | existing Components, Interactions; new Data Flow (table: stage, input, processing, output, trust level; one sentence naming where untrusted input enters); new Trust Boundaries (table: boundary, what crosses, controls); new Failure Domains (table: domain, blast radius, degraded behavior, recovery pointer); existing Boundaries and Constraints last. Interactions stays: it describes call order, Data Flow describes data movement and stores |

Conflicts between proposed sections and checker rules:

1. Mode versus sections. None of the proposed sections conflicts with the checker. Constraints to keep: no heading in an `explanation` or `reference` template may start with `How to ` or `Step <n>` (the headings above comply; `Release Procedure` and `Coordination Steps` are acceptable because neither matches `^step\s+[0-9]+\b`); each `how-to` template needs a real ordered-list line outside a fence or comment, so the placeholder step list must be literal `1.` lines.
2. Test rule versus `alerts-catalog` (not a checker conflict). The existing body-rule test in `docs-authoring-roles.Templates.Tests.ps1` requires every `reference` template to hold exactly one generated start and end marker. `alerts-catalog` is hand-authored reference with no surface element, so it must not carry a generated block, and a generated block with an element id would contradict `surface_refs: []`. Resolution: keep the eight new ids out of the existing `Templates` set and test them in a separate family set (Q3).
3. Directory-mode interaction (cross-feature, not a checker defect). A family record carries one `diataxis_mode`, but the `operations` family holds how-to pages (runbooks, playbooks) and a reference page (alerts catalog), and `getting-started` and `reference` may mix modes. If docs-family-profile-model seeds `diataxis_policy.directory_modes` from the family mode, an alerts-catalog page under the operations directory raises `DOCS_PAGE_MODE_DIRECTORY_MISMATCH`, because the first covering entry in profile order decides. Mitigation recorded for the epic: SKILL.md states that `alerts-catalog` pages are `reference`, and the seeding feature lists a more specific `directory_modes` entry (for example the catalog path) before the family directory. This feature changes nothing outside the templates; it carries the note in SKILL.md and flags it to the epic-planner.

## 7. Other Consumers of the Template List

Searched `extensions/drm-copilot/src/`, `packages/`, `.claude/lib/`, `.claude/hooks/`, `scripts/`, `tests/`, `.claude/agents/`, and the docs skills for the template names, `architecture-overview`, `explanation.md`, and count phrases ("eight templates", 8, 32). Result:

- Hard-coded list: only `tests/scripts/claude-runtime/DocsAuthoringRoles.Helpers.ps1` (`$templateModes`, the `Templates` and `TemplateModes` keys). No TypeScript, no docs lib module, no hook, and no docs-init code enumerates templates.
- Hard-coded counts: `docs-authoring-roles.Templates.Tests.ps1` (`covers 32 template files`, 8 templates x 4 roots) and `docs-authoring-roles.Mirrors.Tests.ps1` (23 Claude files, 20 Codex files). These stay valid when the new templates go in a separate named set (Q3). If the executor instead folded them into the existing set, the counts would change to 31, 28, and 64.
- Pack manifests: three manifests list the template paths (section 4).
- Prose that enumerates templates: `docs-plan-ia` SKILL.md Steps item 4 ("Choose the Diataxis mode from the templates of `docs-author-page`: tutorial, how-to, explanation or one of the four reference families") in `.claude`, `.agents`, and both bundles. It remains true for mode choice, so it is not edited here; the family-planning step of `docs-plan-ia` belongs to docs-family-gate-and-ia (wave 1). `.claude/agents/docs-author.md` and its mirrors name the skill without enumerating templates. `.claude/skills/docs-author-page/SKILL.md` is the only prose file that lists templates.
- Tests that read SKILL.md: `docs-authoring-roles.WorkflowText.Tests.ps1` asserts tokens in the `## Steps` section of every SKILL.md copy (page-name restriction, `may be refused by the runtime`, `the root writes it`); the Steps edit must keep Step 6 verbatim. `docs-authoring-roles.Skills.Tests.ps1` and `DocumentationEstateOnboarding.Tests.ps1` reference the skill by name only.

## 8. File Sizes (physical lines, from `Grep` count)

| File | Lines now | Tier note |
| --- | --- | --- |
| `.claude/skills/docs-author-page/SKILL.md` (and `.agents` copy) | 68 | far under 500; the table gains a column and 8 rows, about 95 lines expected |
| `.claude/skills/docs-author-page/templates/architecture-overview.md` | 27 | about 60 lines expected |
| each new template | 0 (new) | each expected 30 to 75 lines; Markdown is exempt from the file-size tiers regardless |
| `tests/scripts/claude-runtime/docs-authoring-roles.Templates.Tests.ps1` | 106 | not extended |
| `tests/scripts/claude-runtime/docs-authoring-roles.Mirrors.Tests.ps1` | 121 | not extended |
| `tests/scripts/claude-runtime/DocsAuthoringRoles.Helpers.ps1` | 135 | additive key only |
| `tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1` | 696 | do not extend (700 advisory tier is 4 lines away) |

New test files are expected well below 300 lines each.

## Candidate Approaches

### A. Recommended: separate family template set, templates and tests added beside the existing ones

Add the eight templates with `surface_refs: []` and the four-placeholder substitution contract, add a `FamilyTemplateModes` key to the helper, add two new Pester files (acceptance over the full checker; mirror, manifest, shape), leave the existing pinned counts untouched.

- Advantages: no existing assertion changes; `alerts-catalog` avoids the generated-block rule without weakening it for surface templates; the full-checker acceptance test also covers the eight existing templates for free; fits the repo convention of one test file per concern and in-memory fixtures.
- Limitations: a second named set in the helper file; manifest and mirror assertions are duplicated in shape.

### B. Rejected: fold the new ids into the existing `Templates` set

Changes three hard-coded counts (32 to 64, 23 to 31, 20 to 28) and requires a branch in the shared body-rule test so that `alerts-catalog` is exempt from the generated-block requirement, which weakens the rule for the surface templates. Rejected for that coupling.

### C. Rejected: three separate service-management templates

Fixes nothing the epic asks for: the epic Shared Design fixes the single id `service-management` ("SLI/SLO/SLA, change and release, incident management"). Rejected as a contract change.

## Requirements Mapping (issue acceptance criteria to design)

| Acceptance criterion | Design |
| --- | --- |
| Eight new files exist under `templates/` with the fixed ids | `product-overview.md`, `onboarding.md`, `runbook.md`, `playbook.md`, `adr.md`, `security.md`, `service-management.md`, `alerts-catalog.md` per section 6; four-location copies; three manifests updated |
| `architecture-overview.md` carries data-flow and trust-boundary/failure-domain sections | Add `## Data Flow`, `## Trust Boundaries`, `## Failure Domains` between Interactions and Boundaries and Constraints |
| Each new and extended template accepted by the page checker modules, proven by Pester | `DocsAuthorPageTemplates.Acceptance.Tests.ps1` renders each template in memory and runs `Get-DocsPageCheckFinding`; asserts zero error findings; plus two negative cases |
| SKILL.md lists every template and when it applies | Replace the two-column table with `Template`, `diataxis_mode`, `Use when` for 16 rows; add a sentence to Steps item 1 after its first sentence: choose by family from the table; a family page with no surface element uses `surface_refs: []` (JSON empty list); note that `alerts-catalog` is `reference` and may need its own `directory_modes` entry |
| Parity and generator check clean | Edit `.agents/skills/docs-author-page/SKILL.md`; run `scripts/harness-generation/Invoke-HarnessGeneration.ps1`, then `-Check`; copy the templates to the four locations; update three manifests; run the contract tests in section 4 |

## Testing Implications

- Task checks (per the `atomic-plan-contract` cadence): the new and touched Pester files through the launcher `pester` suite with `-TestPath` (task-check evidence only).
- Phase gate and final loop: full Pester gate via the launcher; plus `test_push_down_*` contract tests, the harness generation repo gate, the Codex generator `--check`, and PSScriptAnalyzer and the formatter on the new `.ps1` test files, in the fixed toolchain order. Integration runs in CI.
- Parallel-only runs; no temp files (acceptance tests read committed files with `[System.IO.File]::ReadAllText`, as the existing Templates test does); no clock or random use.
- Coverage: only test files and Markdown change, so no production PowerShell file enters the coverage denominator; the helper change is test infrastructure.

## Numeric Derivation Evidence

Claim 1: the number of existing templates is 8 (basis for "32 template files" and the manifest counts).

- Complete Family: all files directly under `.claude/skills/docs-author-page/templates/`.
- Exhaustive Search Scope: that directory only; the three mirror roots are compared separately in claim 2.
- Inclusion Rules: any file in the directory.
- Exclusion Rules: none (no subdirectories exist).
- Primary Search Strategy or Query Expression: `Glob **/*` under `.claude/skills/docs-author-page`.
- Primary Member Set: api-reference, architecture-overview, cli-reference, config-reference, explanation, how-to, http-reference, tutorial.
- Primary Count: 8.
- Cross-check Search Strategy or Query Expression: `Grep docs-author-page` with line numbers over the `claude-customizations` `pack-manifests/core.json`, counting lines under `templates/`; and the key list of `$templateModes` in `DocsAuthoringRoles.Helpers.ps1`.
- Cross-check Member Set: the same eight names (manifest lines 187 to 194 name them; the helper map lists them).
- Cross-check Count: 8.
- Member-set Comparison: equal after normalization (basename without `.md`); no member differs.

Claim 2: the number of new templates is 8.

- Complete Family: template ids named as new by the epic and the issue.
- Exhaustive Search Scope: `epic.md` `## Shared Design` (`Template ids`) and `issue.md` `## Proposed Behavior`.
- Inclusion Rules: ids named as new files. Exclusion Rules: `architecture-overview.md` (extended, not new).
- Primary Search Strategy or Query Expression: read of `.dev/epics/documentation-estate-families/epic.md` Shared Design.
- Primary Member Set: product-overview, onboarding, runbook, playbook, adr, security, service-management, alerts-catalog. Primary Count: 8.
- Cross-check Search Strategy or Query Expression: read of `issue.md` Proposed Behavior first bullet.
- Cross-check Member Set: the same eight. Cross-check Count: 8.
- Member-set Comparison: equal; none of the eight collides with an existing file name (Glob of the directory).

Derived, not asserted as a spec criterion: after the change each of the four roots holds 16 template files (8 + 8), so 64 template files in total, and each of the three manifests gains 8 lines.

## Pre-Mortem

- Review checklists: a reviewer could fail the change for a template that does not follow tonality (humor, hype, metaphor in the placeholder text), for a rule file edited by hand, or for a generated file hand-edited. Mitigation: placeholder text is neutral and literal; SKILL.md is changed only in the `.agents` source and regenerated; the plan lists `-Check` as a task.
- Coverage: no production PowerShell or TypeScript file changes, so the coverage denominator is unchanged; the risk is a reviewer reading the new test files as unproven. Mitigation: negative cases prove the acceptance test can fail (a how-to without an ordered list, an explanation with a `How to` heading), and the test enumerates the template directory so no template escapes it.
- Mirror parity: four template locations, three manifests, SKILL.md source plus two generated copies plus two bundle copies. A missed copy fails `docs-authoring-roles.Mirrors.Tests.ps1`, the `test_push_down_*` completeness tests, or the harness repo gate. Mitigation: one task copies all 16 templates to four roots and one task updates all three manifests; a final task runs the contract tests; the plan names the `execution-environment` brief as unaffected (no environment fact changes).
- File size: all Markdown (exempt); new test files stay under 300 lines; `DocsPageCheck.Tests.ps1` (696 lines) is not touched. Mitigation: do not append to it.
- Test isolation: acceptance tests import modules and define functions; leaked functions or modules could fail another file in the same shard, and the leak scan flags unrestored state. Mitigation: `AfterAll` removes imported modules and helper functions exactly as `DocsPageCheck.Tests.ps1` and the Templates test do; no environment variable, location change, or temp file.
- CI-only behavior: templates are read through `$PSScriptRoot`-relative paths with `Join-Path`; Linux hook suites do not run these folders, but the Pester shards on Windows and the Python contract tests on Linux read the bundle files. Line-ending risk: `.gitattributes` `* text=auto eol=lf` means templates must be LF (write them with LF; the byte-identity tests compare hashes, so a CRLF copy in one root would fail). Mitigation: no CRLF fixtures; the executor creates all copies from one source text.
- Evidence: evidence goes under `.dev/active/1222-docs-family-page-templates/evidence/<kind>/` with clock-read UTC stamps and append-only writes; the research stamp here is a fallback because this agent has no clock tool, and the plan must not reuse it as an evidence stamp. Counts or percentages from PoshQC MCP results are unusable (the results carry no output); read `artifacts/pester/pester-junit.xml` instead.

## Automation Feasibility

No human interaction is required. Every step is a file edit, a copy, a generator run, or a test run by an agent: template authoring, SKILL.md source edit, `Invoke-HarnessGeneration.ps1` and its `-Check`, manifest edits, Pester through the launcher, and the pytest contract tests through the launcher. The only unverified item (which bundle copies the generator writes) is resolved by one generator run and `git status`. No decision needs the owner (all open questions below have a recommended option).

## Open Questions and Recommended Decisions

| # | Question | Options | Recommended (taken in autonomous mode) |
| --- | --- | --- | --- |
| Q1 | Mode of `runbook`, `playbook`, `onboarding` | how-to; explanation | how-to. The reference estate uses how-to; the checker then requires an ordered list, so each template carries a literal ordered step list |
| Q2 | `surface_refs` value in the eight new templates | `["<element-id>"]` as in the existing templates; `[]` | `[]`. A family page covers no surface element; the schema allows the empty list; the existing front-matter test accepts it |
| Q3 | Where the new templates are enumerated in tests | fold into `Templates`; separate `FamilyTemplateModes` | separate key and new test files (Approach A) |
| Q4 | Use the `SME input required` token in templates | yes; no | no. The token and its coverage count belong to docs-prose-markdown-lint; templates use angle-bracket placeholders |
| Q5 | ADR `Review date` section | keep as in the reference; omit | omit. `review_due` front matter (docs-review-cadence, wave 2) will carry review timing; a body date would duplicate it |
| Q6 | One `service-management` template or three | single; three | single, with three H2 part groups and a leading note to keep only the covered part (epic-fixed id) |
| Q7 | Edit `docs-plan-ia` Steps item 4 prose | edit now; leave | leave. It stays true for mode choice; family planning is docs-family-gate-and-ia |
| Q8 | `alerts-catalog` generated block | include; omit | omit; relax only the family-set body rule |
| Q9 | Reference-estate diagram block in `architecture-overview` | include a fenced diagram; omit | omit; keep the existing sentence that a diagram may be added |
| Q10 | Directory-mode interaction for `alerts-catalog` (section 6, conflict 3) | edit profile seeding here; note in SKILL.md and flag to the epic-planner | note in SKILL.md and flag; no change outside this feature |
| Q11 | Regenerate or hand-edit the Claude SKILL.md | hand-edit generated file; edit `.agents` source and regenerate | edit `.agents/skills/docs-author-page/SKILL.md`, leave the three `substitutions.json` `find` strings untouched, regenerate, then run `-Check` |
