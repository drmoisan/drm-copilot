# Final QC - PowerShell Static, loop restart (P3-T1 re-run)

Timestamp: 2026-11-24T07-40
Command: sh SCRATCH/issue-1221-static-ps.sh check .claude/lib/docs tests/scripts/claude-lib/docs extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1; sh SCRATCH/issue-1221-pssa-each.sh <same scope> (Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, one fresh pwsh per file); retries of the files whose analyzer run threw
EXIT_CODE: 0
Output Summary: Loop restart after the P3-T2 test fix. Format: 303 files, 0 needing format (check mode, no file changed). Analyzer: 303 files, 0 findings. Seventeen files threw an analyzer start-up exception (NullReferenceException, or "more than one dynamic module in each dynamic assembly") in 0.1 s without analyzing; each was re-analyzed in a fresh process and returned FINDINGS=0 (16 on the first or second retry, DocsPagePlaceholder.psm1 on a later retry). TypeScript static (the 2026-11-24T06-36 pass of the same restart): Prettier "All matched files use Prettier code style!", ESLint 0 problems, tsc 0 errors. This file supersedes `final-static-powershell.2026-11-24T05-17.md` for the final pass; that file is kept unchanged.

| Step | Command | EXIT_CODE | Finding count |
|---|---|---|---|
| Format | Invoke-PoshQCFormat in check mode over the scope | 0 | 0 files needing format (303 scanned) |
| Lint | Invoke-ScriptAnalyzer per file, fresh process each, errored files retried | 0 | 0 findings over 303 files; 0 unresolved analyzer errors |
| Type check | not applicable (PowerShell) | N/A | N/A |

## Analyzer Start-up Exceptions

The in-process batch route (one pwsh for all files) reported one analyzer exception on `tests/scripts/claude-lib/docs/DocsLedger.TestSupport.psm1` in two passes (2026-11-24T06-36 and 06-54), with a different message each time; that file analyzes clean alone. The per-file route showed the exceptions are start-up failures of PSScriptAnalyzer on this host (each 0.1 s, before any rule runs) and not properties of the files: every affected file analyzed clean on retry. Files: DocsAnalyzerPythonCli, DocsExtensionShape, DocsFamilyCheck, DocsJsonSchemaKeys, DocsPageMetadata, DocsPageOrphans, DocsPagePlaceholder, DocsReferenceRender, DocsReferenceSplit, DocsTomlKeys, DocsTypeScriptSyntax (under `.claude/lib/docs/`); DocsInventory, DocsJsonSchemaKeys, DocsPageFrontMatter, DocsSurfaceDeltaCommands, DocsTomlKeys (bundle copies); DocsLedger.TestSupport.psm1 (tests).
