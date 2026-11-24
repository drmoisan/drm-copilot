# Parity and Scope (P4-T5)

Timestamp: 2026-11-24T17-24
Command: sh SCRATCH/issue-1220-parity-scope.sh (Invoke-HarnessGeneration.ps1 -Check; SHA-256 comparisons of the changed lib modules, schemas, SKILL.md and templates; core.json search; git diff --name-only against the merge base of origin/epic/documentation-estate-families-integration and HEAD; wc -l of every changed PowerShell file)
EXIT_CODE: 0
Output Summary: harness -Check "no drift" (exit 0); 6 of 6 changed lib modules byte-identical to their bundle copies; 3 of 3 changed schemas with one distinct hash across their three copies; .claude SKILL.md equal to its claude-customizations copy and .agents SKILL.md equal to its codex-and-agents-customizations copy; 16 of 16 templates with one distinct hash across the four roots; core.json lists DocsReviewCadence.psm1 once; 0 paths under extensions/drm-copilot/src/, 0 added .py files, no diff in DocsStaleness.psm1 or DocsCompleteGate.psm1; largest changed PowerShell file 696 lines (all at or below 800).

## Harness

- `scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check`: "harness-generation: no drift", EXIT_CODE 0.

## Lib module copies (.claude/lib/docs vs claude-customizations bundle)

| Module | Result | SHA-256 |
| --- | --- | --- |
| DocsPageFrontMatter.psm1 | EQUAL | 58843a84eb741309a63d38f0333769910a6b572bea06a50b763e860518329fe4 |
| DocsPageMetadata.psm1 | EQUAL | eca4fac5e4f6b0bc91e03210077d8939a1c9acf00a857ee527cbde02b904558b |
| DocsReferenceFrontMatter.psm1 | EQUAL | b5e877a502bba7b7c4e5c9af3b5743468eaf74fd4af27a2a8f2d800bf70c345e |
| DocsReviewCadence.psm1 | EQUAL | 2cd5da0c13d235639ad36f8b9fbb7732d1ec295ee20e36fb67a35114bf1fd475 |
| DocsValidateCommands.psm1 | EQUAL | c0c574298e585e8dea5052a8d1cfec141608a648ce5327e2b076f4576e957106 |
| DocsValidation.psm1 | EQUAL | 84e9d45996c55ef9d230de9b077b459d89cb4f8ec0d75922f0fcc2672e3ff9a0 |

## Schema copies (schemas/docs/v1, .claude/lib/docs/schemas/v1, bundle)

page-metadata.schema.json, common.schema.json, docs-profile.schema.json: distinct_hashes=1 each.

## docs-author-page

- `.claude/skills/docs-author-page/SKILL.md` = claude-customizations copy: 836b53ff2e500531eb913dd46c2b42ba09c81501bfb726da828a50751bcab07a (both).
- `.agents/skills/docs-author-page/SKILL.md` = codex-and-agents-customizations copy: 31aaee88f8d3571d07992c5d74a6958c454e7beda06f0b80072e23e1ef5600c5 (both). The `.claude` and `.agents` texts differ by the generator substitutions.
- Templates across `.agents/skills/`, `.claude/skills/`, the claude-customizations bundle and the codex-and-agents-customizations bundle: adr, alerts-catalog, api-reference, architecture-overview, cli-reference, config-reference, explanation, how-to, http-reference, onboarding, playbook, product-overview, runbook, security, service-management, tutorial: distinct_hashes=1 each. Edited `.agents` files with CR: 0; with BOM: 0.

## core.json

`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` contains `".claude/lib/docs/DocsReviewCadence.psm1"`: 1 match.

## Scope (diff from the merge base of origin/epic/documentation-estate-families-integration and HEAD)

- Paths under extensions/drm-copilot/src/: 0.
- Added .py files: 0.
- .claude/lib/docs/DocsStaleness.psm1 changed: 0. .claude/lib/docs/DocsCompleteGate.psm1 changed: 0.

## Physical line counts (wc -l) of changed or new PowerShell files

Production: DocsPageFrontMatter.psm1 427, DocsPageMetadata.psm1 348, DocsReferenceFrontMatter.psm1 294, DocsReviewCadence.psm1 273, DocsValidateCommands.psm1 265, DocsValidation.psm1 393 (bundle copies identical). Tests: DocsAuthorPageTemplates.Acceptance 114, DocsPageCheck 696, DocsPageMetadata.ReviewDate 124, DocsPageMetadataSchema 149, DocsProfile.ReviewCadence 80, DocsReferenceFrontMatter.Properties 210, DocsReferenceFrontMatter 393, DocsReviewCadence 383, DocsValidateCommands.Families 201, DocsValidateCommands.ReviewCadence 208, DocsValidation.ReviewCadence 219, docs-authoring-roles.FamilyTemplates 241, docs-authoring-roles.Templates 141. All at or below 800.
