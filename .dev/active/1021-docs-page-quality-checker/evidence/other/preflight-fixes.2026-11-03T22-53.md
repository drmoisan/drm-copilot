# Preflight Fixes - Issue #1021 (revision 2, Phases 3 to 6)

Timestamp: 2026-11-03T22-53
Plan: docs/features/active/2026-10-30-docs-page-quality-checker-1021/plan.2026-10-30T16-13.md
Scope: single-pass preflight of the unexecuted tasks [P3-T1] to [P6-T13] against the branch tree at the revision-2 commit.
Validator: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` exit 0 ("plan validation passed"), before and after the fix.

## Fixes

1. [P6-T6] | acceptance literal inconsistent with the recorded baseline | The acceptance demanded "0 errors in `artifacts/pester/pester-junit.xml`", while the [P0-T8] baseline of the same run shape on this host records `errors=6` (six pre-existing failed blocks, none under `tests/scripts/claude-lib/docs`), and the same acceptance already compares failing test names with [P0-T8]. The clause now reads "every error (failed block) ... is also listed as a failed block in the [P0-T8] artifact" and the parenthesis reads "no test or block under `T` may fail". The meaning of the condition (no new failure relative to the baseline; nothing under `T` fails) is unchanged.

## Checks with no defect found

- Phase 3 to 5 file sets, imports, and existing-test dispositions re-read against `.claude/lib/docs/*.psm1`, `Invoke-DocsCommand.ps1`, `DocsProfileCommands.psm1`, `T/DocsSchemaContract.Tests.ps1`, `T/DocsProfileCommands.Tests.ps1`, `T/Invoke-DocsCommand.Tests.ps1`, and `T/Docs.Manifest.Tests.ps1`.
- [P4-T7]: the exact count `$canonicalNames.Count | Should -Be 8` is present in `keeps the runtime schema file set equal to schemas/docs/v1 with byte-identical pairs`, and `DocsSchema.psm1` is imported by that suite, so `Get-DocsSchemaName` is available.
- [P5-T1]: the bundle folder holds none of the three Phase 2 modules and the old `DocsSchema.psm1`, so thirteen new and three modified files is the expected listing.
- [P6-T10]: none of the five temporary-file tokens occurs in the 1020 suites the plan edits or in the existing `DocsPage*` suites.
- [P6-T11]: the two bracket-class patterns match nothing in the current branch diff.
- [P6-T9]: the current `DocsSchema.psm1` diff holds two added lines and no removed line, consistent with the CR-2 fallback.
