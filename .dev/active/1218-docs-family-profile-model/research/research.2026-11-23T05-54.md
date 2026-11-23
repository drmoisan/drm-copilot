# docs-family-profile-model (Issue #1218) - Research

- Issue: #1218
- Epic: #1217 (documentation-estate-families), wave 0, C3
- Branch: feature/docs-family-profile-model-1218
- Contract source: `.dev/epics/documentation-estate-families/epic.md`, `## Shared Design`
- Filename stamp note: the task-researcher has no shell or clock tool. The stamp in this file name is not a clock reading; it was chosen to sort after the epic manifest `created_at` (2026-11-23T05:33:36Z). This file is a research note, not an evidence artifact, so the evidence-filename clock rule does not govern it; the orchestrator may rename it with a clock-read stamp if a later step requires one.

## Scope Recap

This child owns the family record (`required_families[]`), the legacy exclusion list (`legacy_exclusions[]`), their schema, their validation, and the `docs-init` seeding of ten default families. It does not own the docs-complete family check or legacy reporting (docs-family-gate-and-ia), page templates (docs-family-page-templates), or `review_due` (docs-review-cadence).

## 1. Current Schema Structure and Parity

### Copies

| Copy | Role |
| --- | --- |
| `schemas/docs/v1/docs-profile.schema.json` | Canonical schema |
| `.claude/lib/docs/schemas/v1/docs-profile.schema.json` | Runtime copy read by `Get-DocsSchemaPath` in `.claude/lib/docs/DocsSchema.psm1` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/docs-profile.schema.json` | Bundle copy, listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` |

All three were read in full (or located by Glob) and the canonical and runtime copies have identical content. The schema is Draft 2020-12, `$id` `urn:drm-copilot:docs:1.0.0:docs-profile`, root `additionalProperties: false`, with 13 required top-level keys (`$schema`, `schema_version`, `artifact_kind`, `id`, `extensions`, `repository`, `audiences`, `documentation_roots`, `surface_selection`, `page_owners`, `diataxis_policy`, `completion_gates`, `artifact_paths`) and local `$defs` (`audience`, `documentation-root`, `surface-selection`, `page-owner`, `diataxis-policy`, `directory-mode`, `completion-gates`, `artifact-paths`). Shared definitions come from `urn:drm-copilot:docs:1.0.0:common#/$defs/<name>` (`common.schema.json`): `identifier`, `text`, `timestamp` (format `date-time` plus a UTC `Z` pattern), `relative-path` (rejects leading `/`, `.` and `..` segments, backslash, colon, control characters and `* ? < > |`), `audience-id`, `audience-ids`, `diataxis-mode` (enum `tutorial`, `how-to`, `reference`, `explanation`), `review-date`, and others.

Because the root has `additionalProperties: false`, the two new keys must be added to root `properties`; they must not be added to `required`, so existing profiles stay valid.

### Parity pins

- `tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1`, `Describe 'Runtime copies, parity and references'`, `It 'keeps the runtime schema file set equal to schemas/docs/v1 with byte-identical pairs'`: SHA-256 equality of every `schemas/docs/v1` file with its `.claude/lib/docs/schemas/v1` twin, and equality of the file set with `Get-DocsSchemaName`.
- Same file, `It 'references only docs common definitions or local definitions from every docs schema'`: every `$ref` must start with the docs common URN or `#`.
- Same file, `It 'keeps each copied common definition equal to discovery v2 common, timestamp excluded'`: pins 13 copied common definitions against `schemas/discovery/v2/common.schema.json`; it is unaffected as long as `common.schema.json` is not edited.
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`: the bundle copy must equal the `.claude` copy (from the execution-environment brief, `## Contract Tests That Pin Mirrored Files`).
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py`: every bundled file is in a pack manifest, and every `$PSScriptRoot` import of a manifested PowerShell module is manifested.
- `tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1`, `Describe 'Committed examples'`: `examples/docs/v1/docs-profile.example.json` must validate with Test-Json and with `Test-DocsArtifactText`.

## 2. Profile Validation Design Today

- Two layers. `ConvertFrom-DocsProfileText` (`DocsProfile.psm1`) calls `Test-DocsArtifactText -ArtifactKind 'docs-profile'` (`DocsSchema.psm1`), and only when that returns no finding does it parse the text and call `Test-DocsProfileSemantic`. It returns `@{ Profile; Findings; Ok }`.
- The schema layer is JSON-schema-driven. `Join-DocsSchemaText` composes the profile schema with docs common in memory (`common.<name>` definitions, `$ref` rewriting, no fetch). `Test-DocsArtifactText` runs the built-in `Test-Json` and the structural walk `Get-DocsSchemaWalkFinding` (`DocsSchemaWalk.psm1`). The walk evaluates `$ref`, `type`, `required`, `properties`, `patternProperties`, `additionalProperties: false`, `enum`, `const`, `items`, `minItems`, `maxItems`, `allOf`, `if/then/else` and `anyOf`, and emits `DOCS_SCHEMA_TYPE_MISMATCH`, `DOCS_SCHEMA_VALUE_NOT_ALLOWED`, `DOCS_SCHEMA_REQUIRED_MISSING`, `DOCS_SCHEMA_PROPERTY_UNKNOWN`, `DOCS_SCHEMA_ITEM_COUNT`, `DOCS_SCHEMA_NO_BRANCH_MATCH`, `DOCS_SCHEMA_TOO_DEEP`. Keywords the walk does not evaluate (`pattern`, `minimum`, `uniqueItems`, `minLength`, `format`) are enforced by `Test-Json` only and surface as `DOCS_SCHEMA_INVALID` with the pointer parsed from the Test-Json message by `ConvertFrom-DocsSchemaErrorRecord`.
- The semantic layer is hand-coded and pure. `Test-DocsProfileSemantic` emits error findings through the private `New-DocsProfileFinding` (wrapping `New-DocsFinding` from `DocsFinding.psm1`) with codes `DOCS_PROFILE_AUDIENCE_DUPLICATE`, `DOCS_PROFILE_ROOT_DUPLICATE`, `DOCS_PROFILE_AUDIENCE_UNKNOWN`, `DOCS_PROFILE_MODE_NOT_IN_POLICY`, `DOCS_ANALYZER_UNKNOWN`. Each finding carries a JSON pointer, a message naming the field, and a next action; the result is ordered by `Get-DocsOrderedFinding`. Uniqueness of identifiers is a semantic check (schema `uniqueItems` compares whole objects only).
- `Invoke-DocsValidateProfileCommand` (`DocsProfileCommands.psm1`) adds `DOCS_PROFILE_SOURCE_ROOT_MISSING` from `DocsProfileSourceRoot.psm1` outside the pure semantic function.
- Where the new rules belong: schema shape in `docs-profile.schema.json` (new local `$defs`), cross-field rules in a new pure function called from `Test-DocsProfileSemantic` (see section 7).

### Existing tests that the change could affect

| Test | Assertion | Expected disposition |
| --- | --- | --- |
| `tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1` `Describe 'New-DocsStarterProfile'` (four cases) | Starter validates with zero findings; one documentation root `docs/guide`; `-DocumentationRoot 'handbook/user'` still validates | Unchanged and still pass, provided the seeded family directories are derived from `-DocumentationRoot` (section 10 rule F5). Add new cases. |
| `DocsProfile.Tests.ps1` `Describe 'ConvertFrom-DocsProfileText'` | Example profile accepted; semantic codes at pointers | Unchanged when the example profile is not edited (decision D8). |
| `tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1` | Init dry run and `-Write` write `1 + template count` files; result `profile` validates with zero findings; source-root defaults | Unchanged; the profile is still one write. Add a seeding case. |
| `tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1` | Byte parity, example validation, mutation pointers | Unchanged and still pass after the schema edit is mirrored. |
| `tests/scripts/claude-lib/docs/DocsSchema.Tests.ps1` | Composed profile properties (`audiences` `$ref`), no `$id`, no common URN left | Unchanged; new local `$defs` compose the same way. |
| `DocsInventory.Tests.ps1`, `DocsInventory.PythonNative.Tests.ps1`, `DocsInventoryProperties.Tests.ps1`, `DocsInventorySnapshot.Tests.ps1`, `Invoke-DocsCommand.InventoryParity.Tests.ps1`, `DocsLedger.TestSupport.psm1` | Use `New-DocsStarterProfile` as a base and mutate `surface_selection` or `documentation_roots` | `DocsLedger.TestSupport.psm1` replaces the root with `docs`; seeded directories under `docs/guide/` stay inside `docs`, so rule F5 still passes. The others do not touch roots. Executor confirms with one task check over these files. |
| `tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1` | No configured consumer identifier appears in any file under `.claude/lib/docs`, `schemas/docs`, `examples/docs` | New module and schema text must not name the reference repository. |
| `tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1` | Tokens in the `Steps` and `Result` sections of every `docs-init/SKILL.md` copy | Do not remove existing tokens; add text in a new section. |
| Hook tests that build docs profiles inline (`tests/scripts/claude-hooks/*DocsEstate*.Tests.ps1`, `hook-docs-estate-context.Tests.ps1`) | Structural profile check in `hook-docs-estate-context.ps1` reads `artifact_kind`, `documentation_roots`, `artifact_paths` only | Unaffected by new optional keys; no hook change. |

No test asserts the exact set of top-level profile keys of a starter profile or rejects an unknown top-level key through the starter.

## 3. docs-init Default Profile Construction

- `Invoke-DocsInitCommand` (`DocsProfileCommands.psm1`) builds the profile with `New-DocsStarterProfile -RepositoryId <id> -SourceRoot <detected>` (`DocsProfile.psm1`), serializes it with `ConvertTo-DocsJsonText -Indented`, self-validates it through `ConvertFrom-DocsProfileText` (exit 3 `DOCS_CLI_RUNTIME` if the starter fails its own validation), and writes it with the `Get-DocsInitTemplate` rows. `Get-DocsInitTemplate` lists only page-check linter files and `_docs-quality.yml`; it does not build the profile.
- Consequence: seeding the families inside `New-DocsStarterProfile` makes `docs-init` write them with no change to `DocsProfileCommands.psm1`, and the existing self-validation step proves the seeded profile passes the new rules on every init.
- Tests of init output: `DocsProfileCommands.Tests.ps1` (`Invoke-DocsInitCommand` describe blocks, including the result-profile validation and the write count), `DocsInitTemplate.DocsWorkflow.Tests.ps1`, and `tests/scripts/claude-hooks/hook-docs-only-diff.InitWorkflowParity.Tests.ps1` (workflow destination only).
- docs-init skill copies and dispositions (`config/harness-parity-matrix.json` entries `codex:skill:docs-init` `shared`, `claude:skill:docs-init` `generated` from `.agents/skills/docs-init/SKILL.md` by `harness-generation/skills`, `copilot:skill:docs-init` `dropped` because Copilot reads `.agents/skills` natively):
  - Source: `.agents/skills/docs-init/SKILL.md` (and `.agents/skills/docs-init/references/standard.md`).
  - Generated: `.claude/skills/docs-init/SKILL.md`, produced by `scripts/harness-generation/Invoke-HarnessGeneration.ps1` with the substitutions in `scripts/harness-generation/sources/skills/docs-init.substitutions.json`.
  - Bundles: `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-init/SKILL.md` and `references/standard.md`; `extensions/drm-copilot/resources/claude-customizations/.claude/skills/docs-init/SKILL.md`.
  - No `.github/skills/docs-init` copy exists.
- The three substitution `find` strings match the Prerequisites paragraph and the step 1, step 2 and step 4 command lines exactly; new text must not alter those lines, or the generator `-Check` and `HarnessGeneration.RepoGate.Tests.ps1` fail.

## 4. TypeScript MCP Docs Tools

- `extensions/drm-copilot/src` has no reference to `documentation_roots`, `diataxis_policy`, or `docs-profile` keys. `mcp-tool-inputs-docs.ts` exposes only a `profile` path parameter (`PROFILE_ROW`), validated by the `relative-path` grammar mirrored in `mcp-tool-inputs-docs-grammar.ts`.
- `packages/` matches are the discovery `domain-profile` (a different artifact) only.
- `DocumentationEstateOnboarding.Tests.ps1` pins the statement that `init`, `validate-profile` and `surface-delta` have no MCP tool.
- Finding: no TypeScript change is required. The MCP docs tools run the workspace `.claude/lib/docs/Invoke-DocsCommand.ps1`, so the new validation applies through MCP as soon as the branch lib changes.

## 5. Template Ids

Existing templates under `.claude/skills/docs-author-page/templates/` (and the `.agents` source and both bundles): `api-reference`, `architecture-overview`, `cli-reference`, `config-reference`, `explanation`, `how-to`, `http-reference`, `tutorial`.

Templates the sibling docs-family-page-templates adds (Shared Design): `product-overview`, `onboarding`, `runbook`, `playbook`, `adr`, `security`, `service-management`, `alerts-catalog`.

Recommended `template` per default family:

| Family | `template` | Exists today |
| --- | --- | --- |
| product-overview | `product-overview` | no (sibling) |
| getting-started | `onboarding` | no (sibling) |
| user-guides | `how-to` | yes |
| administration | `how-to` | yes |
| security | `security` | no (sibling) |
| operations | `runbook` | no (sibling) |
| service-management | `service-management` | no (sibling) |
| architecture | `architecture-overview` | yes |
| adr | `adr` | no (sibling) |
| reference | `api-reference` | yes |

`reference` uses `api-reference` because the reference family's pages are produced by `generate-reference` (`DocsReferencePlan.psm1` page table: `api-reference.md`, `cli-reference.md`, `config-reference.md`, `http-reference.md`), and the template value only governs a hand-authored page; `api-reference` covers the `public-symbol` kind, the most general surface. `playbook` and `alerts-catalog` are page templates within the operations family and are not family defaults.

Profile validation does not check that a template file exists. Reasons: the template files land in a sibling child of the same wave, so a check would fail until that child merges; `ConvertFrom-DocsProfileText` is pure and has no file seam, and adding one would change its contract; the template folder location differs between runtimes (`.claude/skills/...` and `.agents/skills/...`) and destinations; and consumers may name their own templates. The schema constrains `template` to the common `identifier` pattern, which every existing and planned basename satisfies.

## 6. Reference Estate (read-only)

Read: `docs/production-documentation/` (page tree and front matter), `docs/production-documentation/_templates/` (file list), `.docs-check.json`, `src/dev_tools/docs_check/frontmatter.py`, `src/dev_tools/docs_check/diataxis.py`, and `docs/features/epics/comprehensive-documentation/epic.md` (keyword search). Nothing was modified.

- Families are top-level directories under `docs/production-documentation/`: `product`, `getting-started`, `user-guides`, `admin`, `operations` (with `runbooks/`, `playbooks/`, `alerts-catalog.md`), `architecture` (with `adr/`), `security`, `service-management`, `reference` (with `api/`, `cli/`, `config/`). `.docs-check.json` lists these nine trees as `governed_trees`; ADRs are nested under `architecture/adr`.
- Diataxis mode is a per-page front-matter field `diataxis`, one of the same four modes. `diataxis.py` `DEFAULT_MODE_BY_TEMPLATE` maps `product-overview`, `architecture`, `adr`, `security` to `explanation`, `guide` and `runbook` to `how-to`, `reference` and `index` to `reference`. Family README index pages use `reference`.
- Audience is a per-page bracketed list over a fixed enum `end-user`, `developer`, `operator`, `security`, `product` (`frontmatter.py` `AUDIENCE_ENUM`).
- Review cadence is per page: `last_reviewed` and `review_due`, with `review_due` strictly later; an overdue page is a report-level finding against an injected `today`. Observed intervals: three months for product, getting-started, user-guides, admin, operations, security, service-management and reference pages; six months for architecture pages and ADRs.
- Exclusions: `.docs-check.json` `excluded` mixes templates, engineering trees and legacy pages, using globs (`docs/runbooks/**`) and page paths (`docs/cli-help.md`, `docs/debugging.md`). There is no per-family not-applicable record.

Recommended defaults (directory relative to the starter documentation root `D`, default `docs/guide`):

| id | directory | diataxis_mode | template | audience | review_interval_days | required |
| --- | --- | --- | --- | --- | --- | --- |
| product-overview | `D/product-overview` | explanation | product-overview | product-owners, end-users, maintainers | 90 | true |
| getting-started | `D/getting-started` | how-to | onboarding | end-users, maintainers, operators | 90 | true |
| user-guides | `D/user-guides` | how-to | how-to | end-users | 90 | true |
| administration | `D/administration` | how-to | how-to | operators | 90 | true |
| security | `D/security` | explanation | security | security-reviewers | 90 | true |
| operations | `D/operations` | how-to | runbook | operators | 90 | true |
| service-management | `D/service-management` | explanation | service-management | operators, product-owners | 90 | true |
| architecture | `D/architecture` | explanation | architecture-overview | maintainers, security-reviewers | 180 | true |
| adr | `D/adr` | explanation | adr | maintainers | 180 | true |
| reference | `D/reference` | reference | api-reference | maintainers, operators | 90 | true |

The directory basename equals the family id so the default layout is predictable; `adr` is a sibling of `architecture` rather than nested, so default directories are disjoint. Audience ids are mapped from the reference enum to the `audience-id` pattern (`developer` becomes the existing starter audience `maintainers`).

## 7. File Sizes and Module Placement

Physical line counts from full reads or line-anchored Grep counts (no trailing terminator line):

| File | Lines | Tier status | Planned change |
| --- | --- | --- | --- |
| `.claude/lib/docs/DocsProfile.psm1` | 237 | below 500 | Import the new module; call the family checks from `Test-DocsProfileSemantic`; seed families and audiences in `New-DocsStarterProfile`; update `.DESCRIPTION` text. Expected below 280. |
| `.claude/lib/docs/DocsProfileCommands.psm1` | 270 | below 500 | No change (decision D3). |
| `.claude/lib/docs/DocsSchema.psm1` | 406 | below 500 | No change. |
| `docs-profile.schema.json` (each copy) | 113 | JSON, below 500 | Add two properties and three or four local `$defs`. Expected near 150. |
| `tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1` | 184 | below 500 | Add starter seeding cases. |
| `tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1` | 351 | below 500 | Add one init seeding case. |
| `tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1` | 315 | below 500 | Optional schema-rejection rows for the new defs. |
| `.agents/skills/docs-init/SKILL.md` and copies | 57 | Markdown, exempt | Add a section. |

New logic goes into a new module `.claude/lib/docs/DocsProfileFamilies.psm1` with its own test file `tests/scripts/claude-lib/docs/DocsProfileFamilies.Tests.ps1`. Reason: it is one cohesive concern (default family table plus family and legacy validation), it keeps `DocsProfile.psm1` small, and it gives the wave-1 child docs-family-gate-and-ia one import for the family reader. Expected size 180 to 260 lines.

Naming note: `DocsReferencePlan.psm1` already uses "family" for the four reference page stems (`Get-DocsReferenceCandidatePagePath`). New function names use `DocsFamily`/`DocsProfileFamily` nouns and the help text says "documentation family" to keep the two concepts distinct.

## 8. Coverage Configuration

`config/poshqc-coverage.json` lists roots (`.claude/hooks`, `.claude/lib`, `.claude/skills`, `.codex/hooks`, `.github/hooks`, `.codex/scripts`, `scripts`), and the execution-environment brief states that `Invoke-PoshQCTest` derives the coverage population from that file with no hand-maintained list. A new `.psm1` under `.claude/lib/docs` is therefore measured automatically. `quality-tiers.yml` classifies `.claude/lib/docs` as T3, so no property-test or mutation obligation applies; the 85% line threshold applies per changed file.

## 9. Contract Tests That Apply

From `## Contract Tests That Pin Mirrored Files` of the execution-environment brief, filtered to the touched files:

- `test_push_down_claude_resource_contracts.py` (bundle copies of `DocsProfile.psm1`, `DocsProfileFamilies.psm1`, the schema, and the `.claude` docs-init skill).
- `test_push_down_codex_and_agents_resource_contracts.py` (bundle copies of `.agents/skills/docs-init/SKILL.md` and `references/standard.md`).
- `test_push_down_claude_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py` (the new module must be added to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` next to `.claude/lib/docs/DocsProfile.psm1`, because `DocsProfile.psm1` imports it through `$PSScriptRoot`).
- `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1` and the generator `-Check` (generated `.claude/skills/docs-init/SKILL.md`).
- `tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1` (schema byte parity).
- `tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1` and `docs-authoring-roles.Skills.Tests.ps1` (docs-init text tokens in every copy).
- `tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1` (no consumer identifier in docs lib, schema or examples).

The Codex generator check (`generate_codex_agent_variants.py --check`) is not affected: no `.codex/agents` file embeds the docs-init skill (Grep of `.codex` for `docs-init` matched only two hook scripts).

## 10. Schema Shape and Validation Rules

### Schema additions (local `$defs` in `docs-profile.schema.json`; `common.schema.json` unchanged)

- Root `properties` gain `"required_families": {"type": "array", "items": {"$ref": "#/$defs/documentation-family"}}` and `"legacy_exclusions": {"type": "array", "items": {"$ref": "#/$defs/legacy-exclusion"}}`. Neither is added to `required`. Empty arrays are valid.
- `documentation-family`: `additionalProperties: false`; required `id`, `directory`, `diataxis_mode`, `template`, `audience`, `review_interval_days`, `required`; properties `id` (common `identifier`), `directory` (common `relative-path`), `diataxis_mode` (common `diataxis-mode`), `template` (common `identifier`), `audience` (`{"$ref": common audience-ids, "minItems": 1}`, matching the page front-matter `audience` shape in `page-metadata.schema.json`), `review_interval_days` (`{"type": "integer", "minimum": 1}`), `required` (`{"type": "boolean"}`), `exclusion` (`#/$defs/family-exclusion`).
- `family-exclusion`: `additionalProperties: false`; required `reason` (common `text`) and `recorded_at` (common `timestamp`, which carries `format: date-time` and a UTC pattern, so the check does not depend on Test-Json format assertion).
- `legacy-exclusion`: `additionalProperties: false`; required `path` (common `relative-path`, which already rejects a leading `/`, `..` and `.` segments, backslashes and glob characters) and `reason` (common `text`).

`diataxis_mode` enum: reuse common `diataxis-mode` (`tutorial`, `how-to`, `reference`, `explanation`), the same set the page front matter and `diataxis_policy.modes` use; no new enum.

### Semantic rules (new pure function in `DocsProfileFamilies.psm1`, called by `Test-DocsProfileSemantic`)

| Rule | Code | Pointer |
| --- | --- | --- |
| F1 duplicate family id (ordinal) | `DOCS_PROFILE_FAMILY_DUPLICATE` | `/required_families/<n>/id` |
| F2 duplicate family directory (ordinal) | `DOCS_PROFILE_FAMILY_DUPLICATE` | `/required_families/<n>/directory` |
| F3 audience not declared in `audiences` | `DOCS_PROFILE_AUDIENCE_UNKNOWN` (existing code) | `/required_families/<n>/audience/<m>` |
| F4 mode not in `diataxis_policy.modes` | `DOCS_PROFILE_MODE_NOT_IN_POLICY` (existing code) | `/required_families/<n>/diataxis_mode` |
| F5 directory not equal to or beneath a `documentation_roots[].path` (segment-wise, ordinal) | `DOCS_PROFILE_FAMILY_DIRECTORY_OUTSIDE_ROOT` | `/required_families/<n>/directory` |
| L1 duplicate legacy path (ordinal) | `DOCS_PROFILE_LEGACY_DUPLICATE` | `/legacy_exclusions/<n>/path` |

Schema-level failures (missing field, wrong type, unknown key, non-positive interval, malformed `recorded_at`, `..` in a path) come from the existing schema layer with the existing `DOCS_SCHEMA_*` codes. F5 exists because the page checker and the docs-estate hook path set (`hook-docs-estate-context.ps1`) only see paths under documentation roots; a family outside every root could never have a page found by the gate. Nested family directories (one beneath another) are allowed; membership resolution for nested directories is the gate child's decision.

## Automation Feasibility

No human interaction is required. Every change is a file edit, a generator run (`scripts/harness-generation/Invoke-HarnessGeneration.ps1`), a bundle copy, and the PowerShell and pytest gates through the test-execution launcher. The batch budget is the one routing constraint: the production PowerShell files are `DocsProfile.psm1`, `DocsProfileFamilies.psm1` and their two bundle copies (four distinct files), which exceeds the direct-mode cap of three, so the item runs on the orchestrated large path with a non-terminal `large` checkpoint in the item worktree. No GitHub, network, or reference-repository write is needed.

## Recommendations

Decisions (autonomous mode; recorded here as the decision record for the feature folder):

- D1. Add `required_families` and `legacy_exclusions` as optional root properties with new local `$defs` in all three schema copies, byte-identical; do not edit `common.schema.json` (keeps discovery-common parity and the TypeScript grammar mirror untouched).
- D2. Create `.claude/lib/docs/DocsProfileFamilies.psm1` exporting `Get-DocsDefaultFamilySet` (pure; parameter `DocumentationRoot`, returns the ten ordered family records of section 6) and `Test-DocsProfileFamilySemantic` (pure; rules F1-F5 and L1; parameters `Profile`, `ArtifactPath`). `DocsProfile.psm1` imports it with `-ErrorAction Stop` and appends its findings inside `Test-DocsProfileSemantic` before ordering. Mirror both files to the Claude bundle and add the new module to `pack-manifests/core.json`.
- D3. Seed in `New-DocsStarterProfile`: `required_families = Get-DocsDefaultFamilySet -DocumentationRoot $DocumentationRoot` and `legacy_exclusions = @()`. `DocsProfileCommands.psm1` stays unchanged; init writes the families through the starter and its existing self-validation proves they pass.
- D4. Add audiences `end-users`, `operators`, `security-reviewers`, `product-owners` to the starter `audiences` (keeping `maintainers` first). Do not change `documentation_roots[0].audience_ids` (`@('maintainers')`), because `DocsReferencePlan.psm1` uses root `audience_ids` as the default audience of generated reference pages.
- D5. Defaults per section 6: all ten families `required: true`, no `exclusion`; intervals 90 days, 180 for `architecture` and `adr`; modes and audiences as tabulated. A consumer records an `exclusion` to mark a family not applicable.
- D6. Template values per section 5; no template-file existence check.
- D7. No TypeScript change; no hook change; no Copilot-specific file (Copilot reads `.agents/skills`).
- D8. Do not edit `examples/docs/v1/docs-profile.example.json`; test family and legacy cases with in-memory mutations of the example and starter (several suites replace the example's audiences or roots, and an example with families would then fail rules F3 or F5 in those suites).
- D9. Edit `.agents/skills/docs-init/SKILL.md` by adding a new `## Documentation Families` section after `## Steps` (list the ten ids, the template ids, `exclusion` for not-applicable, and `legacy_exclusions`), without touching the substitution `find` lines or the `## Linter Configuration` section that the sibling docs-prose-markdown-lint edits. Add a matching OB item to `.agents/skills/docs-init/references/standard.md`. Regenerate `.claude/skills/docs-init/SKILL.md`, then copy both `.agents` files and the generated `.claude` file to their bundles.
- D10. Use the term "documentation family" in help text to distinguish it from the reference page "family" stems in `DocsReferencePlan.psm1`.

Test strategy (no test code written here):

- `DocsProfileFamilies.Tests.ps1`: default set (ten ids in order, template ids, directories derived from `-DocumentationRoot`, intervals, all `required`), each of F1-F5 and L1 at its pointer, a profile with an exclusion on a required family accepted, a profile without either key accepted.
- `DocsProfile.Tests.ps1`: starter carries the families and validates for each repository id; `-DocumentationRoot 'handbook/user'` moves the family directories and still validates.
- `DocsSchemaContract.Tests.ps1` or the new test: schema rejections through `Test-DocsArtifactText` for a missing family field, an unknown family key, `review_interval_days` 0, a malformed `recorded_at`, a legacy path with `..`, and a non-boolean `required`.
- `DocsProfileCommands.Tests.ps1`: init result profile holds the ten families and the written profile text validates.
- All gates are the parallel Pester gate and the pytest gate through the launcher; no temporary files (in-memory profiles and the existing context seams).

## Numeric Derivation Evidence

### N1: ten default family ids

- Complete Family: default documentation family ids that docs-init seeds.
- Exhaustive Search Scope: `.dev/epics/documentation-estate-families/epic.md` `## Shared Design`; `.dev/active/1218-docs-family-profile-model/issue.md` and `spec.md`.
- Inclusion Rules: backticked ids in the "Default family ids" bullet.
- Exclusion Rules: parenthetical page-kind descriptions (quickstart, runbooks, and so on) are pages within a family, not ids.
- Primary Search Strategy or Query Expression: read of the Shared Design "Default family ids" bullet.
- Primary Member Set: product-overview, getting-started, user-guides, administration, security, operations, service-management, architecture, adr, reference.
- Primary Count: 10.
- Cross-check Search Strategy or Query Expression: read of the `issue.md` `## Proposed Behavior` docs-init bullet (independent document; `spec.md` Behavior bullet carries the same list).
- Cross-check Member Set: product-overview, getting-started, user-guides, administration, security, operations, service-management, architecture, adr, reference.
- Cross-check Count: 10.
- Member-set Comparison: identical after ordinal normalization; no member missing or extra.

### N2: three schema copies

- Complete Family: files named `docs-profile.schema.json` in the repository.
- Exhaustive Search Scope: whole worktree.
- Inclusion Rules: exact file name.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: Glob `**/docs-profile.schema.json`.
- Primary Member Set: `.claude/lib/docs/schemas/v1/docs-profile.schema.json`, `schemas/docs/v1/docs-profile.schema.json`, `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/docs-profile.schema.json`.
- Primary Count: 3.
- Cross-check Search Strategy or Query Expression: references in `pack-manifests/core.json` (bundled `.claude` path), `DocsSchemaContract.Tests.ps1` (canonical and runtime directories), and `Get-DocsSchemaPath` (runtime path).
- Cross-check Member Set: the same three paths (bundle via the manifest entry `.claude/lib/docs/schemas/v1/docs-profile.schema.json`, canonical `schemas/docs/v1`, runtime `.claude/lib/docs/schemas/v1`).
- Cross-check Count: 3.
- Member-set Comparison: identical.

### N3: eight existing and eight sibling template ids

- Complete Family: template basenames under `docs-author-page/templates/` today, and those the sibling adds.
- Exhaustive Search Scope: `.claude/skills/docs-author-page/templates/`, `.agents/skills/docs-author-page/templates/`, both bundles; Shared Design "Template ids" bullet.
- Inclusion Rules: `.md` file basenames.
- Exclusion Rules: `architecture-overview` is existing and only gains sections, so it is not a new id.
- Primary Search Strategy or Query Expression: Glob `**/skills/docs-author-page/templates/*`.
- Primary Member Set (existing): api-reference, architecture-overview, cli-reference, config-reference, explanation, how-to, http-reference, tutorial.
- Primary Count: 8 existing.
- Cross-check Search Strategy or Query Expression: Grep of `template` in `.agents/skills/docs-author-page/SKILL.md` (`## Templates` table); and a read of the Shared Design bullet for the new set.
- Cross-check Member Set (existing): tutorial, how-to, explanation, architecture-overview, cli-reference, http-reference, config-reference, api-reference. New set: product-overview, onboarding, runbook, playbook, adr, security, service-management, alerts-catalog.
- Cross-check Count: 8 existing; 8 new.
- Member-set Comparison: existing sets identical; new set disjoint from the existing set.

## Pre-Mortem

- Review checklists: a reviewer may flag a schema edit not mirrored to all three copies, a generated `.claude` skill edited by hand, or a hard-coded consumer identifier. Mitigation: the plan edits the canonical schema then copies to runtime and bundle, edits only `.agents/skills/docs-init` and runs the generator, and carries a task that runs `DocsNeutrality.Tests.ps1` over the new module.
- Coverage: `DocsProfileFamilies.psm1` is new and judged against the 85% line threshold; `DocsProfile.psm1` changed lines must not regress. Mitigation: the new test file drives every rule branch and the default-set builder; per-file figures are read from `artifacts/pester/powershell-coverage.xml` of the single gate run and compared with the Phase 0 baseline.
- Mirror parity: failures would come from a missing bundle copy, a missing `core.json` entry for the new module (dependency-closure test), a stale generated `.claude/skills/docs-init/SKILL.md`, or a substitution `find` string broken by the skill edit. Mitigation: one task copies `DocsProfile.psm1`, `DocsProfileFamilies.psm1`, the schema, both `.agents` docs-init files and the generated `.claude` docs-init file to their bundles and adds the manifest entry; the generator `-Check`, `HarnessGeneration.RepoGate.Tests.ps1`, and the four push-down contract tests run in the gate. No execution-environment brief fact changes, so no brief-update task is needed.
- File size: all touched files are well below 500 lines (largest `DocsProfileCommands.Tests.ps1` at 351, unchanged in structure). Mitigation: new logic lives in `DocsProfileFamilies.psm1` with its own test file; the plan states the expected sizes.
- Test isolation: tests must not write files or leave modules imported. Mitigation: in-memory profiles and the existing context seams only; the new test file's `AfterAll` removes `DocsProfileFamilies` and every module it imports, matching the `Remove-Module` list pattern of `DocsProfile.Tests.ps1`, and also extends the `Remove-Module` lists of `DocsProfile.Tests.ps1` and `DocsProfileCommands.Tests.ps1` with `DocsProfileFamilies`; `Invoke-PoshQCLeakScan` runs in the static job.
- CI-only behavior: Linux runners and LF normalization could expose path comparison or case issues in rule F5. Mitigation: F5 compares forward-slash relative paths ordinally by segment with no `Join-Path` or drive letters; no test reads gitignored `artifacts/` state; no test diffs against `origin/main`.
- Evidence: Phase 0 baselines, task-check selections, and final gate artifacts go under `.dev/active/1218-docs-family-profile-model/evidence/<kind>/` with clock-read UTC stamps, append-only; PoshQC MCP results are not used as evidence because they carry no output.
