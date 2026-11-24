# Preflight Fixes - Issue #1218

Timestamp: 2026-11-23T06-14
Plan: .dev/active/1218-docs-family-profile-model/plan.2026-11-23T00-38.md
Signal: PREFLIGHT: REVISIONS REQUIRED (substantive defects returned to the planner; trivial fixes below applied in task text only; no task added, removed, or reordered)

## Fixes

1. [P1-T1] | citation correction | The vague citation "`DocsSchema.Tests.ps1` composed-profile cases" now names `Describe 'Join-DocsSchemaText'` Its over the composed docs-profile schema.
2. [P2-T3] | changed-behavior test disposition (citation completeness) | Added the existing tests that run `Invoke-DocsInitCommand` or build on `New-DocsStarterProfile` and were not named: every other It of `Describe 'Invoke-DocsInitCommand'`, `DocsInitTemplate.DocsWorkflow.Tests.ps1`, `DocsPageTemplates.Tests.ps1`, and the `New-DocsLedgerTestProfile` consumers `DocsCompleteIntegration.Tests.ps1`, `DocsHashLineEnding.Tests.ps1`, `DocsLedgerCommands.Tests.ps1`, `DocsLedgerCommands.UpdateLedger.Tests.ps1`, `DocsLedgerBatch.TestSupport.psm1`, `DocsValidateCommands.Tests.ps1`, `DocsValidation.Tests.ps1`, `DocsValidation.Properties.Tests.ps1`, each with disposition unchanged and passing. Verified: no test pins a hash of the serialized starter-based profile.
3. [P2-T5] | citation completeness | Added `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` It `lists every filtered docs file exactly once in core.json paths`, which asserts the core.json entry the task adds.
4. [P3-T1] | citation correction | Gave the two docs-authoring-roles suites their full paths under `tests/scripts/claude-runtime/` and named It `keeps <Path> free of .claude/ text and states the push-down prerequisite`, which constrains the new `.agents` section text.
5. [P3-T2] | citation completeness | Added `tests/scripts/claude-runtime/docs-authoring-roles.Mirrors.Tests.ps1` It `places <Skill> at all four skill locations with byte-identical bundle copies`, which asserts the bundle copies the task makes.
