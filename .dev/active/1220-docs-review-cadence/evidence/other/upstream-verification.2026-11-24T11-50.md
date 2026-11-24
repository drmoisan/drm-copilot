# Upstream Verification (P0-T1)

Timestamp: 2026-11-24T11-50
Command: read schemas/docs/v1/docs-profile.schema.json; read .claude/lib/docs/DocsValidation.psm1 (Invoke-DocsValidation, Get-DocsCompletionGateFinding); read .claude/lib/docs/DocsProfileFamilies.psm1 and .claude/lib/docs/DocsFamilyCheck.psm1; ls .agents/skills/docs-author-page/templates/*.md; read Get-DocsAuthoringNamedSet in tests/scripts/claude-runtime/DocsAuthoringRoles.Helpers.ps1
EXIT_CODE: 0
Output Summary: upstream #1218, #1221, #1222 are merged on this branch; required_families and legacy_exclusions are declared; the family check is the Get-DocsFamilyFinding call in the docs-complete branch of Invoke-DocsValidation; 16 templates.

Branch head at verification: 5267cb829 (merge of origin/main into the documentation-estate-families integration branch).

## (a) Family directory base

DirectoryBase: repository-relative

Deciding text:
- `docs-profile.schema.json` `$defs/documentation-family/properties/directory` is `{"$ref": "urn:drm-copilot:docs:1.0.0:common#/$defs/relative-path"}`, the same definition used by `documentation_roots[].path`.
- `Test-DocsProfileFamilySemantic` (DocsProfileFamilies.psm1) rule F5 `DOCS_PROFILE_FAMILY_DIRECTORY_OUTSIDE_ROOT`: "the directory neither equals a documentation_roots path nor begins with it followed by '/'". A directory therefore starts with a documentation-root path, which is repository-relative.
- `New-DocsStarterFamily` builds `directory = "$DocumentationRoot/$($row[0])"`.
- `Read-DocsFamilyEvidence` (DocsFamilyCheck.psm1) passes the directory, with trailing '/' removed, to the repository listing seam; a family page is a listed path that begins with the directory followed by '/'.

## (b) Legacy-exclusion path key

`legacy_exclusions[].path` (`$defs/legacy-exclusion/properties/path`, `relative-path`).

## (c) Insertion point for the overdue call

The family check does not live in `Get-DocsCompletionGateFinding`; it is the block
`if ($Mode -ceq 'docs-complete') { foreach ($finding in (Get-DocsFamilyFinding ...)) { ... } }`
in `Invoke-DocsValidation`, after the matrix layer (which holds the `Get-DocsCompletionGateFinding` loop). Insertion point: inside that docs-complete block, directly after the `Get-DocsFamilyFinding` loop. It runs after the completion-gate findings and after the family check, and does not depend on the snapshot or ledger loading.

## (d) Template list

Folder `.agents/skills/docs-author-page/templates/` (16 files):
adr.md, alerts-catalog.md, api-reference.md, architecture-overview.md, cli-reference.md, config-reference.md, explanation.md, how-to.md, http-reference.md, onboarding.md, playbook.md, product-overview.md, runbook.md, security.md, service-management.md, tutorial.md

Count: 16

Named set comparison: `Get-DocsAuthoringNamedSet` `Templates` lists 8 (tutorial, how-to, explanation, architecture-overview, cli-reference, http-reference, config-reference, api-reference). Issue #1222 added a separate member `FamilyTemplateModes` with the other 8 (product-overview, onboarding, runbook, playbook, adr, security, service-management, alerts-catalog), "kept apart from the Templates key so its pinned counts hold". `Templates` alone does not equal the folder listing (8 of 16); `Templates` plus the keys of `FamilyTemplateModes` equals the folder listing (16 of 16, no extra, no missing).

Discrepancy noted for P3-T2 (recorded here, decided at P3-T2): two upstream test files outside the P3-T2 file set pin the family templates against a `review_due` line:
- `tests/scripts/claude-runtime/docs-authoring-roles.FamilyTemplates.Tests.ps1`: `$script:BannedToken` contains `review_due`, and the test `gives <Id> five JSON-valued front-matter keys, surface_refs [] and the mode <Mode>` asserts the five-key set.
- `tests/scripts/claude-lib/docs/DocsAuthorPageTemplates.Acceptance.Tests.ps1`: `$script:Substitution` has no `<review-due-yyyy-mm-dd>` entry, so an inserted placeholder stays unsubstituted when the page checker runs.

## (e) Required keys

- Family record (`$defs/documentation-family/required`): id, directory, diataxis_mode, template, audience, review_interval_days, required. `review_interval_days` is `{"type": "integer", "minimum": 1}`. Optional: exclusion. `additionalProperties: false`.
- Legacy-exclusion item (`$defs/legacy-exclusion/required`): path, reason. `additionalProperties: false`.
- Profile-semantic rules a test profile must satisfy (Test-DocsProfileFamilySemantic): audience ids declared in `audiences`, `diataxis_mode` listed in `diataxis_policy.modes`, directory under a `documentation_roots` path, unique ids, directories, and legacy paths.

## (f) State lines

FamiliesState: PRESENT
LegacyExclusionsState: PRESENT

Decided by the root `properties` of `schemas/docs/v1/docs-profile.schema.json`, which declares `required_families` (array of `#/$defs/documentation-family`) and `legacy_exclusions` (array of `#/$defs/legacy-exclusion`); the root has `additionalProperties: false`.
