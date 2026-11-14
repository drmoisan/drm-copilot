# P4 Import Isolation - Issue #1021

Timestamp: 2026-11-03T23-20
Task: [P4-T6]
Command: `sh SCRATCH/issue-1021-failnames.sh tests/scripts/claude-lib/docs/DocsPageImportIsolation.Tests.ps1 issue-1021-p4-iso.txt` (PowerShell 7 `Invoke-Pester` with the repository run settings over the branch-current suite; `Run.PassThru`)
EXIT_CODE: 0
Output Summary: TOTAL=12 PASSED=12 FAILED=0 SKIPPED=0 NOTRUN=0 FAILED_BLOCKS=0 FAILED_CONTAINERS=0. The positive control (in-memory text importing `DocsLedger.psm1`) passes; a closure is reported for each of the seven page modules. CI: CI-PESTER.

## Scope

`tests/scripts/claude-lib/docs/DocsPageImportIsolation.Tests.ps1` parses each committed `DocsPage*.psm1` text (discovered from disk, so a further split is included) with `[System.Management.Automation.Language.Parser]::ParseInput`, follows literal `Join-Path -Path $PSScriptRoot -ChildPath` imports of `Import-Module` commands, and computes each transitive closure from the committed texts (read-only). It asserts direct imports within the allowlist (`DocsJson`, `DocsFinding`, `DocsSchema`, `DocsSchemaWalk`, `DocsSurface`, `DocsProfile`, `DocsPage*`), no denied name in the closure (`DocsLedger*`, `DocsParity*`, `DocsEvidencePins*`, `DocsStaleness*`, `DocsReceipt*`, `DocsValidation*`, `DocsInventory*`, `DocsReference*`, `DocsSurfaceDelta*`, `DocsExtensionImport*`, `Docs*Tokens*`, every `DocsAnalyzer*.psm1` other than `DocsAnalyzerRegistry.psm1`, the `docs/python/` subtree), that every closure member exists, and no `using module`, dot-sourcing or `Invoke-Expression`. Controls: an in-memory module text importing `DocsLedger.psm1` is reported; the denylist classifies an analyzer implementation, a python-subtree module and a reference module as denied and the registry as allowed; the shape parser detects `using module`, dot-sourcing and `Invoke-Expression` in an in-memory text. No `Get-Module` state is read and no module is imported.

## Closures reported (paths relative to `.claude/lib`)

- `DocsPageCheck.psm1`: discovery-validation/DiscoveryEncoding.psm1, docs/DocsAnalyzerRegistry.psm1, docs/DocsFinding.psm1, docs/DocsJson.psm1, docs/DocsPageDiataxis.psm1, docs/DocsPageFrontMatter.psm1, docs/DocsPageLinks.psm1, docs/DocsPageMarkdown.psm1, docs/DocsPageMetadata.psm1, docs/DocsPageOrphans.psm1, docs/DocsProfile.psm1, docs/DocsSchema.psm1, docs/DocsSchemaWalk.psm1, docs/DocsSurface.psm1
- `DocsPageDiataxis.psm1`: discovery-validation/DiscoveryEncoding.psm1, docs/DocsFinding.psm1, docs/DocsJson.psm1, docs/DocsPageMarkdown.psm1
- `DocsPageFrontMatter.psm1`: discovery-validation/DiscoveryEncoding.psm1, docs/DocsFinding.psm1, docs/DocsJson.psm1, docs/DocsPageMarkdown.psm1, docs/DocsPageMetadata.psm1, docs/DocsSchema.psm1, docs/DocsSchemaWalk.psm1
- `DocsPageLinks.psm1`: discovery-validation/DiscoveryEncoding.psm1, docs/DocsFinding.psm1, docs/DocsJson.psm1, docs/DocsPageMarkdown.psm1
- `DocsPageMarkdown.psm1`: (empty; no imports)
- `DocsPageMetadata.psm1`: discovery-validation/DiscoveryEncoding.psm1, docs/DocsFinding.psm1, docs/DocsJson.psm1
- `DocsPageOrphans.psm1`: discovery-validation/DiscoveryEncoding.psm1, docs/DocsFinding.psm1, docs/DocsJson.psm1

`DocsAnalyzerRegistry.psm1` is reached only transitively through `DocsProfile.psm1` (asserted), as the spec import graph states.

Correction during the task: the first run (11 of 12) read a `BeforeDiscovery` variable at run time; the coverage test now lists the folder itself.
