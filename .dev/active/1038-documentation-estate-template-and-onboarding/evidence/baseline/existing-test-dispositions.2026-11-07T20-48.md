# Existing test dispositions (re-derived on the execution base)

Timestamp: 2026-11-07T20-48
Command: git grep -l -e "feature-templates" -e "copyTemplate" -e "docs/engineering" -e "documentation-estate" -- tests extensions/drm-copilot/test ; git ls-files tests/scripts/claude-lib/docs
EXIT_CODE: 0
Output Summary: 52 hit files. 21 map to rows 1 to 6 of the plan's `## Existing Tests Asserting Changed Behavior (dispositions)`. 31 are unlisted; 30 of them do not enumerate template or page files (they hold in-memory artifact path strings or pin other files). One unlisted file, tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1, enumerates the `.md` files under extensions/drm-copilot/resources/feature-templates in its class sweep. Its only assertion over those files is that none contains one of twelve removed-run tokens, so it does not assert behavior that this change alters. Disposition: Unchanged, carried as a content constraint on TEMPLATE/epic.md and TEMPLATE/README.md and verified by the parallel Pester gate ([P4-T3], test `PGW-SWEEP-SURFACES finds no removed-class token in any surface`). No existing TDOCS file name equals a NEW-PS name.

## Mapped hits

- extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts | row 1
- tests/scripts/dev_tools/test_new_active_feature_folder_part2.py | row 2
- extensions/drm-copilot/test/extension.integration.test.ts | row 3
- extensions/drm-copilot/test/repo-automation-dispatch.test.ts | row 3
- extensions/drm-copilot/test/new-active-feature-folder-fs-harness.ts | row 3
- extensions/drm-copilot/test/extension.workflow-commands.test.ts | row 3
- extensions/drm-copilot/test/extension.new-active-feature-folder-inprocess.test.ts | row 3
- extensions/drm-copilot/test/extension.new-potential-bug-entry-inprocess.test.ts | row 3
- extensions/drm-copilot/test/lib/new-potential-bug-entry.test.ts | row 3
- extensions/drm-copilot/test/lib/new-potential-bug-entry-service-call.test.ts | row 3
- tests/scripts/dev_tools/test_single_pass_preflight_contracts.py | row 3
- tests/scripts/dev_tools/test_new_potential_bug_entry.py | row 3
- tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 | row 3
- tests/scripts/dev_tools/test_discovery_documentation_contracts.py | row 4
- tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 | row 4
- tests/scripts/dev_tools/test_execution_environment_brief_contracts.py | row 4
- tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | row 5
- tests/scripts/ci/CiChangeScope.Tests.ps1 | row 5
- tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json | row 6
- tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json | row 6
- tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json | row 6
- (row 3 lists `lib/new-potential-bug-entry*.test.ts`; both files above match it)

## Unlisted hits that do not enumerate template or page files

- tests/scripts/claude-lib/docs/ (19 files: DocsCompleteGate, DocsCompleteIntegration, DocsInventory, DocsLedgerCommands, DocsLedgerCommands.UpdateLedger, DocsLedgerCommands.Validate, DocsPageCheck, DocsPageCheck.LinkMap, DocsProfile, DocsProfileCommands, DocsReceipt, DocsReference.TestSupport.psm1, DocsReferenceIntegration, DocsReferenceWriter, DocsReferenceWriter.Errors, DocsReferenceWriter.Properties, DocsSurfaceDeltaCommands, DocsValidation, DocsValidation.Properties suites) | the token is the in-memory profile and artifact path `docs/documentation-estate/...` or the integration branch name; no file is enumerated | Unchanged
- tests/scripts/claude-hooks/docs-role-contract.Tests.ps1, enforce-docs-complete-gate.Tests.ps1, enforce-docs-complete-gate-compound.Tests.ps1, enforce-docs-role-write-scope.Tests.ps1, validate-docs-role-output.Tests.ps1 | in-memory profile, receipt and artifact path strings under `docs/documentation-estate/` | Unchanged
- tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1, EpicProgressReport.SkillContract.Tests.ps1 | forbidden-token lists applied to the skill's own output and files | Unchanged
- tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1, ProcessReductionLedger.Index.Tests.ps1, ProcessReductionLedger.Replay.Tests.ps1 | read only `docs/engineering/process-reductions/` | Unchanged
- tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1 | pins `docs/engineering/claude-code-architecture.md` and a wording phrase | Unchanged

## Unlisted hit that enumerates template files

- tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 | `Get-PgwSweepFile` enumerates every `.md` and `.toml` file under the sweep roots, including `extensions/drm-copilot/resources/feature-templates`, so TEMPLATE/epic.md and TEMPLATE/README.md enter the sweep | Unchanged: the test asserts only that no swept file contains one of the twelve `$script:SweepToken` entries (for example `targeted tests`, `relevant tests pass`, `smallest applicable subset`); the new template text carries none of them. Executor interpretation: the [P0-T8] BLOCKED clause exists to stop a plan whose change makes an existing test fail; this test asserts no behavior that the change alters, so no plan revision is needed. It is verified by the parallel gate of [P4-T3].

## NEW-PS name collision check

- Existing TDOCS files (git ls-files): 106 entries; none is named EpicManifest.TestSupport.psm1, DocumentationEstateEpicTemplate.Tests.ps1, DocumentationEstateOnboarding.Tests.ps1, DocumentationEstateFixture.TestSupport.psm1 or EndToEndDocumentationEstate.Tests.ps1 | match
