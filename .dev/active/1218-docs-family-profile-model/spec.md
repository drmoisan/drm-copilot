# docs-family-profile-model (Issue #1218) — Spec

- **Issue:** #1218
- **Parent (optional):** Epic #1217 (documentation-estate-families), wave 0, complexity C3
- **Owner:** drmoisan
- **Last Updated:** 2026-11-23
- **Status:** Ready for planning
- **Version:** 1.0
- **Research:** `.dev/active/1218-docs-family-profile-model/research/research.2026-11-23T05-54.md`
- **Contract source:** `.dev/epics/documentation-estate-families/epic.md`, `## Shared Design` (not altered by this spec)

## Overview

The docs profile (`docs-profile.json`) describes a documentation estate only through surface-driven reference pages. It cannot declare the documentation families a production estate needs, record that a family is not applicable, carry a per-family review interval, or list legacy pages that are tolerated while they are migrated. This feature adds the family record (`required_families[]`) and the legacy exclusion list (`legacy_exclusions[]`) to the profile schema, validates them in the PowerShell docs library, and has `docs-init` seed the default family set. Downstream epic children consume the record; this feature defines and validates it only.

## Behavior

- The docs profile schema gains the optional root properties `required_families` and `legacy_exclusions`. Neither is added to the root `required` list. A profile that omits both keys validates exactly as it does today.
- `required_families` is an array of family records. `legacy_exclusions` is an array of legacy exclusion records. An empty array is valid for each.
- Schema shape violations are reported by the existing schema layer with the existing `DOCS_SCHEMA_*` codes. Cross-field rules are reported by the semantic layer with `DOCS_PROFILE_*` codes, each with a JSON pointer, a message naming the field, and a next action.
- A family record with an `exclusion` object is accepted by validation whatever the value of `required`. Under the Shared Design, a family with `required: true` and an `exclusion` is not applicable and is reported, not failed; that reporting belongs to docs-family-gate-and-ia and is not implemented here.
- `New-DocsStarterProfile`, and therefore `docs-init`, writes the default family records listed in `## Data & State` and an empty `legacy_exclusions` array.
- The `docs-init` skill text documents the families, the `exclusion` object, and `legacy_exclusions`.

## Inputs / Outputs

- Inputs: profile JSON text passed to `ConvertFrom-DocsProfileText`; the `-DocumentationRoot`, `-RepositoryId`, and `-SourceRoot` parameters of `New-DocsStarterProfile` (unchanged signatures).
- Outputs: the `@{ Profile; Findings; Ok }` result of `ConvertFrom-DocsProfileText` (unchanged shape); the starter profile ordered dictionary, which gains `required_families` and `legacy_exclusions`; the `docs-profile.json` written by `docs-init`.
- Config keys and defaults: `required_families` (default when absent: no families declared); `legacy_exclusions` (default when absent: no legacy pages tolerated). The starter writes the default families of `## Data & State` and `legacy_exclusions: []`.
- Versioning and backward compatibility: `schema_version` stays `1.0.0` and `$id` stays `urn:drm-copilot:docs:1.0.0:docs-profile`, because the change is additive and optional. Every profile valid before this change stays valid, including `examples/docs/v1/docs-profile.example.json`, which is not edited.

## API / CLI Surface

### Schema additions (`docs-profile.schema.json`, every copy named in `## Constraints & Risks` byte-identical)

Root `properties` gain:

```json
"required_families": {"type": "array", "items": {"$ref": "#/$defs/documentation-family"}},
"legacy_exclusions": {"type": "array", "items": {"$ref": "#/$defs/legacy-exclusion"}}
```

New local `$defs` (`common.schema.json` is not edited; `common.` below means `urn:drm-copilot:docs:1.0.0:common#/$defs/<name>`):

| `$def` | `additionalProperties` | Required properties | Property definitions |
| --- | --- | --- | --- |
| `documentation-family` | `false` | `id`, `directory`, `diataxis_mode`, `template`, `audience`, `review_interval_days`, `required` | `id`: common `identifier`; `directory`: common `relative-path`; `diataxis_mode`: common `diataxis-mode`; `template`: common `identifier`; `audience`: `{"$ref": common audience-ids, "minItems": 1}`; `review_interval_days`: `{"type": "integer", "minimum": 1}`; `required`: `{"type": "boolean"}`; `exclusion` (optional): `#/$defs/family-exclusion` |
| `family-exclusion` | `false` | `reason`, `recorded_at` | `reason`: common `text`; `recorded_at`: common `timestamp` |
| `legacy-exclusion` | `false` | `path`, `reason` | `path`: common `relative-path`; `reason`: common `text` |

Patterns and minimums inherited from the common definitions (verified in `schemas/docs/v1/common.schema.json`):

- `identifier` (`id`, `template`): `^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$`. A `template` value is a template file basename without `.md`.
- `relative-path` (`directory`, `path`): non-empty; rejects a leading `/`, `.` and `..` segments, backslash, colon, control characters, and `* ? < > |`.
- `diataxis-mode`: enum `tutorial`, `how-to`, `reference`, `explanation`.
- `audience-ids`: array of `audience-id` (`^[a-z0-9][a-z0-9-]*$`) with `uniqueItems: true`; this feature adds `minItems: 1` at the use site.
- `text` (`reason`): `minLength: 1` and at least one non-whitespace character.
- `timestamp` (`recorded_at`): `format: date-time` and the UTC pattern `^YYYY-MM-DDTHH:MM:SS(.fraction)?Z$`.

### Schema-layer error codes (existing; no new schema code)

`Test-DocsArtifactText` returns structural-walk findings in preference to Test-Json findings. The expected code per violation is:

| Violation | Code |
| --- | --- |
| A required family, exclusion, or legacy field is missing | `DOCS_SCHEMA_REQUIRED_MISSING` at the pointer of the missing field (for example `/required_families/0/id` or `/required_families/0/exclusion/reason`), per decision D16 |
| An unknown key in a family, exclusion, or legacy record | `DOCS_SCHEMA_PROPERTY_UNKNOWN` |
| Wrong JSON type (for example `required: "yes"`, `review_interval_days: "90"`, `review_interval_days: 1.5`, `required_families: {}`) | `DOCS_SCHEMA_TYPE_MISMATCH` |
| `diataxis_mode` outside the enum | `DOCS_SCHEMA_VALUE_NOT_ALLOWED` |
| `audience: []` | `DOCS_SCHEMA_ITEM_COUNT` |
| `review_interval_days` of `0` or negative; malformed `id` or `template`; `directory` or `path` with `..`, a leading `/`, a backslash, or a glob character; `recorded_at` without the UTC `Z` form; empty or whitespace-only `reason`; duplicate entries inside `audience` | `DOCS_SCHEMA_INVALID` (keywords enforced by Test-Json only) |

In each case `ConvertFrom-DocsProfileText` returns `Profile = $null` and `Ok = $false`, and the semantic layer does not run.

### Semantic rules (new pure function, run only on schema-valid profiles)

Function `Test-DocsProfileFamilySemantic` in the new module `.claude/lib/docs/DocsProfileFamilies.psm1`, parameters `-Profile` (`IDictionary`, mandatory) and `-ArtifactPath` (nullable string). `Test-DocsProfileSemantic` calls it and appends its findings before `Get-DocsOrderedFinding`. All comparisons are ordinal (case-sensitive). Every finding has severity `error`.

| Rule | Condition | Code | Pointer |
| --- | --- | --- | --- |
| F1 | A family `id` equals the `id` of an earlier family | `DOCS_PROFILE_FAMILY_DUPLICATE` | `/required_families/<n>/id` of the later entry |
| F2 | A family `directory` equals the `directory` of an earlier family | `DOCS_PROFILE_FAMILY_DUPLICATE` | `/required_families/<n>/directory` of the later entry |
| F3 | An `audience` entry is not the `id` of any entry in `audiences` | `DOCS_PROFILE_AUDIENCE_UNKNOWN` (existing code) | `/required_families/<n>/audience/<m>` |
| F4 | `diataxis_mode` is not listed in `diataxis_policy.modes` | `DOCS_PROFILE_MODE_NOT_IN_POLICY` (existing code) | `/required_families/<n>/diataxis_mode` |
| F5 | `directory` is neither equal to some `documentation_roots[].path` nor begins with that path followed by `/` | `DOCS_PROFILE_FAMILY_DIRECTORY_OUTSIDE_ROOT` | `/required_families/<n>/directory` |
| L1 | A legacy `path` equals the `path` of an earlier legacy entry | `DOCS_PROFILE_LEGACY_DUPLICATE` | `/legacy_exclusions/<n>/path` of the later entry |

Boundaries:

- F5 is segment-wise: with root `docs/guide`, `docs/guide` and `docs/guide/security` pass; `docs/guidebook/security` and `docs/security` fail. No `Join-Path`, drive letter, or case folding is used.
- A family directory nested under another family directory is accepted.
- A legacy `path` is not required to lie under a documentation root and is not checked for existence.
- `template` is not checked against template files on disk (decision D6).
- `exclusion` is accepted whatever the value of `required` (decision D11).

### Default family set

Function `Get-DocsDefaultFamilySet` in `DocsProfileFamilies.psm1`, parameter `-DocumentationRoot` (mandatory, non-empty string), returns the family records of `## Data & State` in that order, each an ordered dictionary with keys in the order `id`, `directory`, `diataxis_mode`, `template`, `audience`, `review_interval_days`, `required`, and no `exclusion` key. The function is pure.

### Example

```powershell
$starter = New-DocsStarterProfile -RepositoryId 'sample'
$starter.required_families[0].directory   # docs/guide/product-overview
$starter.required_families[7].review_interval_days   # 180 (architecture)
```

## Data & State

### Seeded defaults (`D` is the `-DocumentationRoot` value, default `docs/guide`)

| Order | id | directory | diataxis_mode | template | audience | review_interval_days | required |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `product-overview` | `D/product-overview` | `explanation` | `product-overview` | `product-owners`, `end-users`, `maintainers` | 90 | true |
| 2 | `getting-started` | `D/getting-started` | `how-to` | `onboarding` | `end-users`, `maintainers`, `operators` | 90 | true |
| 3 | `user-guides` | `D/user-guides` | `how-to` | `how-to` | `end-users` | 90 | true |
| 4 | `administration` | `D/administration` | `how-to` | `how-to` | `operators` | 90 | true |
| 5 | `security` | `D/security` | `explanation` | `security` | `security-reviewers` | 90 | true |
| 6 | `operations` | `D/operations` | `how-to` | `runbook` | `operators` | 90 | true |
| 7 | `service-management` | `D/service-management` | `explanation` | `service-management` | `operators`, `product-owners` | 90 | true |
| 8 | `architecture` | `D/architecture` | `explanation` | `architecture-overview` | `maintainers`, `security-reviewers` | 180 | true |
| 9 | `adr` | `D/adr` | `explanation` | `adr` | `maintainers` | 180 | true |
| 10 | `reference` | `D/reference` | `reference` | `api-reference` | `maintainers`, `operators` | 90 | true |

Audience lists are written in the order shown.

### Starter audiences

`New-DocsStarterProfile` `audiences` becomes, in order:

| id | description |
| --- | --- |
| `maintainers` | `People who change and release this repository.` (unchanged) |
| `end-users` | `People who use the product to accomplish their tasks.` |
| `operators` | `People who deploy, configure, and run the product.` |
| `security-reviewers` | `People who assess the security posture of the product.` |
| `product-owners` | `People who decide the scope and direction of the product.` |

`documentation_roots[0].audience_ids` stays `@('maintainers')` (decision D4). `diataxis_policy.modes` already lists `tutorial`, `how-to`, `reference`, and `explanation`, so F4 passes for the seeded families.

### Invariants

- The seeded starter profile passes `ConvertFrom-DocsProfileText` with zero findings for any `-RepositoryId` and for any `-DocumentationRoot` that satisfies `relative-path`, because every seeded directory is `D/<id>` (F5), every seeded audience is declared (F3), ids and directories are distinct (F1, F2), and every mode is in policy (F4).
- `Invoke-DocsInitCommand` keeps its existing self-validation of the starter (exit 3 `DOCS_CLI_RUNTIME` on failure) and its file count of `1 + template count`.
- No caching, persistence, migration, or backfill is introduced. Existing committed profiles are not rewritten.

## Constraints & Risks

- No new Python. Implementation is PowerShell 7.4 in `.claude/lib/docs`. No TypeScript change: the MCP docs tools expose only a `profile` path parameter and run the workspace `.claude/lib/docs/Invoke-DocsCommand.ps1`, so the new validation reaches MCP through the library with no TypeScript edit, and no TypeScript file reads profile keys.
- No hook change: `hook-docs-estate-context.ps1` reads only `artifact_kind`, `documentation_roots`, and `artifact_paths`.
- Parity: the schema copies (`schemas/docs/v1/docs-profile.schema.json`, `.claude/lib/docs/schemas/v1/docs-profile.schema.json`, `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/docs-profile.schema.json`) are byte-identical. `DocsProfile.psm1` and `DocsProfileFamilies.psm1` are mirrored to the Claude bundle, and `DocsProfileFamilies.psm1` is listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- Skill surfaces: `.agents/skills/docs-init/SKILL.md` and `references/standard.md` are the edited sources; `.claude/skills/docs-init/SKILL.md` is regenerated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` and not edited by hand; the `.agents` and `.claude` copies are mirrored to their bundles. Copilot reads `.agents/skills` natively (`copilot:skill:docs-init` is `dropped` in `config/harness-parity-matrix.json`), so no Copilot-specific file is added. The substitution `find` lines in `scripts/harness-generation/sources/skills/docs-init.substitutions.json` must keep matching, and the `## Linter Configuration` section (edited by the sibling docs-prose-markdown-lint) is not touched.
- Neutrality: no new library, schema, or example text names a consumer repository (`DocsNeutrality.Tests.ps1`).
- File-size limit 800 lines hard; the new module is expected at 180 to 260 lines. Tests create no temporary files; profiles are built in memory. Test gates are parallel only. PowerShell line coverage at least 85% per changed file.
- Out of scope, explicitly:
  - The docs-complete family check, not-applicable reporting, and legacy exclusion reporting (docs-family-gate-and-ia).
  - The page template files named by `template` (docs-family-page-templates).
  - `review_due`, overdue findings, and any use of `review_interval_days` beyond schema validation (docs-review-cadence).
  - Changes to `docs-plan-ia`, `DocsCompleteGate`, receipts, coverage reports, MCP tool parameters, and `common.schema.json`.

## Implementation Strategy

- Schema: edit `schemas/docs/v1/docs-profile.schema.json`, then copy it byte-identically to the runtime and bundle paths.
- New module `.claude/lib/docs/DocsProfileFamilies.psm1` exporting `Get-DocsDefaultFamilySet` and `Test-DocsProfileFamilySemantic`; it imports `DocsFinding.psm1` with `-ErrorAction Stop`; help text uses the term "documentation family" (decision D10).
- `.claude/lib/docs/DocsProfile.psm1`: import the new module with `-ErrorAction Stop`; append the family findings in `Test-DocsProfileSemantic` and list the new codes in its `.DESCRIPTION`; in `New-DocsStarterProfile` add the `end-users`, `operators`, `security-reviewers`, and `product-owners` audiences, `required_families = Get-DocsDefaultFamilySet -DocumentationRoot $DocumentationRoot`, and `legacy_exclusions = @()`.
- `DocsProfileCommands.psm1`, `DocsSchema.psm1`, `DocsSchemaWalk.psm1`, and `common.schema.json` are unchanged.
- Tests: new `tests/scripts/claude-lib/docs/DocsProfileFamilies.Tests.ps1`; added cases in `DocsProfile.Tests.ps1`, `DocsProfileCommands.Tests.ps1`, and the schema-rejection rows of `DocsSchemaContract.Tests.ps1` or the new file; the `Remove-Module` lists of the touched test files include `DocsProfileFamilies`.
- Skill text per decision D9, then a generator run and bundle copies.
- Dependencies: none added. Logging: none added. Rollout: no flag; the change is additive.

## Acceptance Criteria

- [ ] AC1. `schemas/docs/v1/docs-profile.schema.json`, `.claude/lib/docs/schemas/v1/docs-profile.schema.json`, and `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/docs-profile.schema.json` declare `required_families` and `legacy_exclusions` in root `properties` with the `documentation-family`, `family-exclusion`, and `legacy-exclusion` `$defs` stated in `## API / CLI Surface`, neither key appears in root `required`, and the named schema files have equal SHA-256 hashes (`DocsSchemaContract.Tests.ps1` parity case and `test_push_down_claude_resource_contracts.py` pass).
- [ ] AC2. `schemas/docs/v1/common.schema.json` is unchanged, `schema_version` remains `1.0.0`, and every schema `$ref` still starts with the docs common URN or `#`.
- [ ] AC3. `examples/docs/v1/docs-profile.example.json` is unchanged and still validates with zero findings, and a profile that omits both new keys validates with zero findings through `ConvertFrom-DocsProfileText`.
- [ ] AC4. A profile with `required_families: []` and `legacy_exclusions: []` validates with zero findings.
- [ ] AC5. A family record missing any one of `id`, `directory`, `diataxis_mode`, `template`, `audience`, `review_interval_days`, or `required` yields `DOCS_SCHEMA_REQUIRED_MISSING`, and a family, exclusion, or legacy record with an unknown key yields `DOCS_SCHEMA_PROPERTY_UNKNOWN`; in each case `Ok` is `$false` and `Profile` is `$null`.
- [ ] AC6. `required` with a non-boolean value and `review_interval_days` with a string or non-integer number value yield `DOCS_SCHEMA_TYPE_MISMATCH`; `diataxis_mode` outside `tutorial`, `how-to`, `reference`, `explanation` yields `DOCS_SCHEMA_VALUE_NOT_ALLOWED`; `audience: []` yields `DOCS_SCHEMA_ITEM_COUNT`.
- [ ] AC7. `review_interval_days` of `0`, a `recorded_at` without the UTC `Z` form, an empty `reason`, a legacy `path` containing a `..` segment, and a family `directory` with a leading `/` each yield `DOCS_SCHEMA_INVALID` with `Ok` `$false`; `review_interval_days` of `1` is accepted.
- [ ] AC8. An `exclusion` missing `reason` or `recorded_at` yields `DOCS_SCHEMA_REQUIRED_MISSING`; a well-formed `exclusion` (`reason` non-empty, `recorded_at` such as `2026-11-23T00:00:00Z`) is accepted with `required: true` and with `required: false`.
- [ ] AC9. A repeated family `id` yields `DOCS_PROFILE_FAMILY_DUPLICATE` at `/required_families/<n>/id`, and a repeated family `directory` yields `DOCS_PROFILE_FAMILY_DUPLICATE` at `/required_families/<n>/directory`, where `<n>` is the index of the later entry; ids differing only in case are not duplicates.
- [ ] AC10. A family `audience` entry not declared in `audiences` yields `DOCS_PROFILE_AUDIENCE_UNKNOWN` at `/required_families/<n>/audience/<m>`.
- [ ] AC11. A family `diataxis_mode` not in `diataxis_policy.modes` yields `DOCS_PROFILE_MODE_NOT_IN_POLICY` at `/required_families/<n>/diataxis_mode`.
- [ ] AC12. With a documentation root `docs/guide`, family directories `docs/guide` and `docs/guide/security` produce no finding, and `docs/guidebook/security` and `docs/security` each yield `DOCS_PROFILE_FAMILY_DIRECTORY_OUTSIDE_ROOT` at `/required_families/<n>/directory`.
- [ ] AC13. A repeated legacy `path` yields `DOCS_PROFILE_LEGACY_DUPLICATE` at `/legacy_exclusions/<n>/path` of the later entry; a legacy path outside every documentation root produces no finding.
- [ ] AC14. Every semantic finding of AC9 through AC13 has severity `error`, a message naming the field, and a non-empty next action, and `Test-DocsProfileSemantic` returns the family findings together with its existing findings in `Get-DocsOrderedFinding` order.
- [ ] AC15. `Get-DocsDefaultFamilySet -DocumentationRoot 'docs/guide'` returns exactly the records of the `## Data & State` table, whose `id`, `directory`, `diataxis_mode`, `template`, `audience`, `review_interval_days`, and `required` values equal the `## Data & State` table in order, with no `exclusion` key on any record.
- [ ] AC16. `New-DocsStarterProfile` returns `required_families` equal to `Get-DocsDefaultFamilySet` for its `-DocumentationRoot`, `legacy_exclusions` as an empty array, and `audiences` with ids `maintainers`, `end-users`, `operators`, `security-reviewers`, `product-owners` in that order, while `documentation_roots[0].audience_ids` stays `maintainers` only.
- [ ] AC17. The starter profile serialized with `ConvertTo-DocsJsonText -Indented` validates with zero findings for the default arguments, for `-DocumentationRoot 'handbook/user'` (every family directory then begins with `handbook/user/`), and for the `-RepositoryId` values `sample` and `other-repo`.
- [ ] AC18. `Invoke-DocsInitCommand` dry run and `-Write` produce a profile whose `required_families` ids are `product-overview`, `getting-started`, `user-guides`, `administration`, `security`, `operations`, `service-management`, `architecture`, `adr`, `reference` with the template ids `product-overview`, `onboarding`, `how-to`, `how-to`, `security`, `runbook`, `service-management`, `architecture-overview`, `adr`, `api-reference` in the same order; the set of written file paths is unchanged from before this feature; `DocsProfileCommands.psm1` is unchanged.
- [ ] AC19. `.agents/skills/docs-init/SKILL.md` contains a `## Documentation Families` section after `## Steps` naming each default family id of the `## Data & State` table, their template ids, the `exclusion` object for a not-applicable family, and `legacy_exclusions`; `.agents/skills/docs-init/references/standard.md` contains a matching item; the `## Steps`, `## Linter Configuration`, and `## Result` sections keep their existing text.
- [ ] AC20. `.claude/skills/docs-init/SKILL.md` equals the generator rendering of its source (`Invoke-HarnessGeneration.ps1 -Check` exits 0 and `HarnessGeneration.RepoGate.Tests.ps1` passes), and the bundle copies of both `.agents` docs-init files and the generated `.claude` file are equal to their sources (`test_push_down_codex_and_agents_resource_contracts.py` and `test_push_down_claude_resource_contracts.py` pass).
- [ ] AC21. `DocsProfileFamilies.psm1` and `DocsProfile.psm1` have byte-equal bundle copies, `DocsProfileFamilies.psm1` is listed in the Claude `pack-manifests/core.json`, and `test_push_down_claude_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py` pass.
- [ ] AC22. No TypeScript, Python, hook, or `common.schema.json` file is changed by the branch diff from its merge base with `origin/main`.
- [ ] AC23. `DocsNeutrality.Tests.ps1`, `docs-authoring-roles.WorkflowText.Tests.ps1`, `docs-authoring-roles.Skills.Tests.ps1`, and the existing docs-lib suites that build on `New-DocsStarterProfile` pass in the parallel Pester gate, and `Invoke-PoshQCLeakScan` reports no new finding.
- [ ] AC24. `DocsProfileFamilies.psm1` has at least 85% line coverage, `DocsProfile.psm1` changed lines show no coverage regression against the Phase 0 baseline, and every touched file is at or below 800 lines.

## Decisions

Decisions D1 to D10 are adopted from the research record without change; D11 to D14 are added by this spec. Autonomous mode applies: each takes the recommended option.

- D1. Add both keys as optional root properties with new local `$defs` in every schema copy, byte-identical; do not edit `common.schema.json`. Rationale: keeps discovery-common parity and the TypeScript grammar mirror untouched, and keeps existing profiles valid.
- D2. Put the default family table and the family and legacy rules in a new module `DocsProfileFamilies.psm1` exporting `Get-DocsDefaultFamilySet` and `Test-DocsProfileFamilySemantic`, called from `Test-DocsProfileSemantic`. Rationale: one cohesive concern, keeps `DocsProfile.psm1` small, and gives docs-family-gate-and-ia one import.
- D3. Seed in `New-DocsStarterProfile`; leave `DocsProfileCommands.psm1` unchanged. Rationale: init already builds the profile through the starter and self-validates it, so every init proves the seeded families pass.
- D4. Add `end-users`, `operators`, `security-reviewers`, `product-owners` to the starter audiences after `maintainers`; keep `documentation_roots[0].audience_ids` as `maintainers`. Rationale: F3 requires declared audiences, and `DocsReferencePlan.psm1` uses root `audience_ids` as the default audience of generated reference pages, which must not change.
- D5. Every default family `required: true` with no `exclusion`; intervals 90 days, 180 for `architecture` and `adr`; modes and audiences as tabulated. Rationale: matches the cadence and modes observed in the reference estate; a consumer records an `exclusion` to mark a family not applicable.
- D6. Template values per the Shared Design and the research table; no template-file existence check. Rationale: the sibling template child lands in the same wave, the validation function is pure, template locations differ by runtime, and consumers may name their own templates.
- D7. No TypeScript, hook, or Copilot-specific change. Rationale: no TypeScript or hook code reads profile keys, and Copilot reads `.agents/skills`.
- D8. Do not edit `examples/docs/v1/docs-profile.example.json`; test with in-memory mutations. Rationale: several suites replace the example's audiences or roots, and families in the example would then fail F3 or F5 there.
- D9. Add `## Documentation Families` after `## Steps` in `.agents/skills/docs-init/SKILL.md` and a matching item in `references/standard.md`, regenerate the `.claude` copy, and mirror to bundles. Rationale: leaves the substitution `find` lines and the sibling-owned `## Linter Configuration` section untouched.
- D10. Use the term "documentation family" in help text. Rationale: distinguishes it from the reference page "family" stems in `DocsReferencePlan.psm1`.
- D11. Accept `exclusion` whatever the value of `required`, with no semantic rule tying them. Rationale: the Shared Design defines only the `required: true` plus `exclusion` meaning, reporting belongs to docs-family-gate-and-ia, and rejecting `required: false` plus `exclusion` would constrain that child without a stated contract.
- D12. Duplicate findings (F1, F2, L1) point at the later entry, and comparisons are ordinal. Rationale: matches the existing `DOCS_PROFILE_AUDIENCE_DUPLICATE` and `DOCS_PROFILE_ROOT_DUPLICATE` behavior.
- D13. Reuse the existing codes `DOCS_PROFILE_AUDIENCE_UNKNOWN` and `DOCS_PROFILE_MODE_NOT_IN_POLICY` for F3 and F4, and add only `DOCS_PROFILE_FAMILY_DUPLICATE`, `DOCS_PROFILE_FAMILY_DIRECTORY_OUTSIDE_ROOT`, and `DOCS_PROFILE_LEGACY_DUPLICATE`. Rationale: the condition is the same as the existing checks; the pointer distinguishes the location.
- D14. Fix the starter audience descriptions to the text in `## Data & State`. Rationale: the `text` definition requires a non-empty description, and fixed text makes the starter output testable.
- D15. State the default families, schema copies, and audiences as explicit enumerations, with no count asserted. Rationale: the research numeric derivation for the default family ids (N1) searched only the epic manifest, `issue.md`, and `spec.md` rather than the whole repository, so it is not exhaustive. A complete enumeration is equally testable (an extra or missing member fails the exact-set comparison) and needs no count evidence.
- D16. Correction recorded at plan revision (2026-11-23): `DOCS_SCHEMA_REQUIRED_MISSING` is reported at the pointer of the missing field, not at the containing object pointer as the `### Schema-layer error codes` table first stated. Evidence: `Get-DocsSchemaWalkFinding` in `.claude/lib/docs/DocsSchemaWalk.psm1` builds the pointer with `Get-DocsChildPointer -Pointer $Pointer -Part $name` for each missing required name, and the existing It `exits 1 with DOCS_SCHEMA_REQUIRED_MISSING at /audiences for a profile without audiences` in `tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1` asserts that pointer form. The table row now states the field pointer; no behavior changes.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests
- [ ] Behavior matches acceptance criteria on Windows and the Linux CI runners
- [ ] Tests added and updated as listed in `## Implementation Strategy`
- [ ] Edge cases and error handling covered by tests
- [ ] Skill text and bundle copies updated
- [ ] Toolchain pass completed (format, analyze, test) with parallel gates

## Seeded Test Conditions (from potential)

- [ ] Unit coverage of family and legacy-exclusion validation (valid, missing field, wrong type, duplicate id, exclusion shape)
- [ ] docs-init seeding output
- [ ] Schema parity across copies
