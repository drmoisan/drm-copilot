# [P6-T11] Property-test census (issue #1022)

Timestamp: 2026-11-04T03-24
Command: pwsh -NoProfile -File SCRATCH/issue-1022-p6t11-census.ps1 -WorktreeRoot <item worktree> (parses each new `.claude/lib/docs` module with the PowerShell parser, lists the function names of its `Export-ModuleMember` calls, and matches each pure function to an `It` whose name begins `property: <Function>` in the new suites); cross-checks: pwsh -NoProfile -File SCRATCH/issue-1022-p6t11-crosscheck.ps1 (sum of `ExportedFunctions.Count` after `Import-Module -PassThru` of each module) and sh SCRATCH/issue-1022-p6t11-seeds.sh (per suite: `It 'property: ` blocks, `System.Random]::new` constructions, `-Because` lines naming the seed)
EXIT_CODE: 0
Output Summary: 49 exported functions across the eighteen new modules (the import cross-check also reports 49); 1 non-pure (`Invoke-DocsInventoryCommand`); 48 pure, each matched to a `property: <Function>` test; 0 pure functions without one. Every suite with property tests constructs `[System.Random]::new(...)` at least once per property test and carries the seed in `-Because` text. The plan text names seventeen modules; the [P1-T3] split adds `DocsPythonBindings.psm1`, so eighteen are listed.

## Rows

| Module | Exported function | Class | Property test (suite :: It) |
|---|---|---|---|
| DocsSourceText | Add-DocsDiagnosticOccurrence | pure | DocsSourceText.Tests.ps1 :: property: Add-DocsDiagnosticOccurrence reports the minimum line and the number of calls regardless of order |
| DocsSourceText | ConvertTo-DocsKeyPathDeclaration | pure | DocsSourceText.Tests.ps1 :: property: ConvertTo-DocsKeyPathDeclaration is injective |
| DocsSourceText | ConvertTo-DocsLineRange | pure | DocsSourceText.Tests.ps1 :: property: ConvertTo-DocsLineRange returns the first start and the last end |
| DocsSourceText | ConvertTo-DocsSourceLine | pure | DocsSourceText.Tests.ps1 :: property: ConvertTo-DocsSourceLine line i plus LF equals ConvertTo-DocsDeclarationText with range i to i |
| DocsSourceText | Find-DocsPathOrGlobMatch | pure | DocsSourceText.Tests.ps1 :: property: Find-DocsPathOrGlobMatch matches a path against its own ** prefix glob and not against a sibling |
| DocsSourceText | Get-DocsModuleDottedName | pure | DocsSourceText.Tests.ps1 :: property: Get-DocsModuleDottedName splits the relative path on slashes only |
| DocsSourceText | New-DocsDiagnosticAggregate | pure | DocsSourceText.Tests.ps1 :: property: New-DocsDiagnosticAggregate starts empty and independent of earlier aggregates |
| DocsSourceText | Select-DocsUniqueElement | pure | DocsSourceText.Tests.ps1 :: property: Select-DocsUniqueElement keeps one element per distinct declaration and never a later duplicate |
| DocsPythonTokens | Get-DocsPythonToken | pure | DocsPythonTokens.Tests.ps1 :: property: Get-DocsPythonToken spans reconstruct the input text |
| DocsPythonSyntax | ConvertFrom-DocsPythonStringToken | pure | DocsPythonSyntax.Tests.ps1 :: property: ConvertFrom-DocsPythonStringToken returns the body of a quoted escape-free string |
| DocsPythonSyntax | Get-DocsPythonEnclosingBlock | pure | DocsPythonSyntax.Tests.ps1 :: property: Get-DocsPythonEnclosingBlock reports the nesting chain of generated blocks |
| DocsPythonSyntax | Get-DocsPythonLogicalLine | pure | DocsPythonSyntax.Tests.ps1 :: property: Get-DocsPythonLogicalLine yields one logical line per non-blank statement with the written indent |
| DocsPythonSyntax | Read-DocsPythonCall | pure | DocsPythonSyntax.Tests.ps1 :: property: Read-DocsPythonCall recovers the generated positional and keyword arguments |
| DocsPythonSyntax | Read-DocsPythonDottedChain | pure | DocsPythonSyntax.Tests.ps1 :: property: Read-DocsPythonDottedChain joins the generated parts with dots |
| DocsPythonSyntax | Split-DocsPythonTokenList | pure | DocsPythonSyntax.Tests.ps1 :: property: Split-DocsPythonTokenList returns one slice per generated argument |
| DocsPythonBindings | Get-DocsPythonDefinitionHeader | pure | DocsPythonBindings.Tests.ps1 :: property: Get-DocsPythonDefinitionHeader recovers the generated decorators and parameter names |
| DocsPythonBindings | Get-DocsPythonFrontEnd | pure | DocsPythonBindings.Tests.ps1 :: property: Get-DocsPythonFrontEnd yields one logical line and one receiver per generated binding |
| DocsPythonBindings | Get-DocsPythonImportTable | pure | DocsPythonBindings.Tests.ps1 :: property: Get-DocsPythonImportTable binds each generated alias to its module and member |
| DocsPythonBindings | Get-DocsPythonReceiverTable | pure | DocsPythonBindings.Tests.ps1 :: property: Get-DocsPythonReceiverTable tracks each generated distinct receiver once |
| DocsPythonBindings | Resolve-DocsPythonQualifiedName | pure | DocsPythonBindings.Tests.ps1 :: property: Resolve-DocsPythonQualifiedName replaces exactly the bound first segment |
| DocsTomlKeys | Get-DocsTomlKey | pure | DocsTomlKeys.Tests.ps1 :: property: Get-DocsTomlKey emits one key per generated entry with the generated value type and never the value |
| DocsTomlKeys | Get-DocsTomlScriptEntry | pure | DocsTomlKeys.Tests.ps1 :: property: Get-DocsTomlScriptEntry returns the generated name and target of every entry |
| DocsYamlKeys | Get-DocsYamlKey | pure | DocsYamlKeys.Tests.ps1 :: property: Get-DocsYamlKey is invariant under comment insertion |
| DocsJsonSchemaKeys | Get-DocsJsonMemberSpan | pure | DocsJsonSchemaKeys.Tests.ps1 :: property: Get-DocsJsonMemberSpan places each generated member on its written lines |
| DocsJsonSchemaKeys | Get-DocsJsonSchemaKey | pure | DocsJsonSchemaKeys.Tests.ps1 :: property: Get-DocsJsonSchemaKey emits every generated property path once with its type and required flag |
| DocsPythonCliArgparse | Get-DocsArgparseCommandSite | pure | DocsPythonCliArgparse.Tests.ps1 :: property: Get-DocsArgparseCommandSite is deterministic under unrelated statement insertion |
| DocsPythonCliClick | Get-DocsClickCommandSite | pure | DocsPythonCliClick.Tests.ps1 :: property: Get-DocsClickCommandSite default names follow the suffix rule |
| DocsPythonCliTyper | Get-DocsTyperCommandSite | pure | DocsPythonCliTyper.Tests.ps1 :: property: Get-DocsTyperCommandSite default names are lower-cased and hyphenated |
| DocsAnalyzerPythonCli | ConvertTo-DocsCliElement | pure | DocsAnalyzerPythonCli.Tests.ps1 :: property: ConvertTo-DocsCliElement line range equals the site span and the name is the last declaration segment |
| DocsAnalyzerPythonCli | Invoke-DocsAnalyzerPythonCli | pure | DocsAnalyzerPythonCli.Tests.ps1 :: property: Invoke-DocsAnalyzerPythonCli output is byte-identical under permuted input order |
| DocsAnalyzerPythonCli | Resolve-DocsCliRootName | pure | DocsAnalyzerPythonCli.Tests.ps1 :: property: Resolve-DocsCliRootName picks the first present name in the fixed order |
| DocsPythonHttpSites | Get-DocsFastApiRouteSite | pure | DocsPythonHttpSites.Tests.ps1 :: property: Get-DocsFastApiRouteSite yields one site per generated decorator with its method and path |
| DocsPythonHttpSites | Get-DocsFlaskRouteSite | pure | DocsPythonHttpSites.Tests.ps1 :: property: Get-DocsFlaskRouteSite yields one site per generated route with its methods |
| DocsPythonHttpSites | Get-DocsHttpMountSite | pure | DocsPythonHttpSites.Tests.ps1 :: property: Get-DocsHttpMountSite records every generated include with its prefix in order |
| DocsAnalyzerPythonHttp | Invoke-DocsAnalyzerPythonHttp | pure | DocsAnalyzerPythonHttp.Tests.ps1 :: property: Invoke-DocsAnalyzerPythonHttp output is byte-identical under permuted input order |
| DocsAnalyzerPythonHttp | Resolve-DocsHttpTemplate | pure | DocsAnalyzerPythonHttp.Tests.ps1 :: property: Resolve-DocsHttpTemplate FastAPI templates equal the joined prefixes plus the path and Flask templates carry no double slash |
| DocsAnalyzerPythonApi | Get-DocsPublicApiAllName | pure | DocsAnalyzerPythonApi.Tests.ps1 :: property: Get-DocsPublicApiAllName final list equals the replayed literal operations |
| DocsAnalyzerPythonApi | Get-DocsPublicApiBinding | pure | DocsAnalyzerPythonApi.Tests.ps1 :: property: Get-DocsPublicApiBinding binds every generated top-level name once with its kind |
| DocsAnalyzerPythonApi | Invoke-DocsAnalyzerPythonApi | pure | DocsAnalyzerPythonApi.Tests.ps1 :: property: Invoke-DocsAnalyzerPythonApi output is byte-identical under permuted input order |
| DocsAnalyzerArchitecture | Get-DocsPythonImportEdge | pure | DocsAnalyzerArchitecture.Tests.ps1 :: property: Get-DocsPythonImportEdge edges equal the longest-prefix resolution of generated imports |
| DocsAnalyzerArchitecture | Invoke-DocsAnalyzerPythonArchitecture | pure | DocsAnalyzerArchitecture.Tests.ps1 :: property: Invoke-DocsAnalyzerPythonArchitecture output is byte-identical under permuted input order |
| DocsAnalyzerConfigFiles | Get-DocsConfigFileFormat | pure | DocsAnalyzerConfigFiles.Tests.ps1 :: property: Get-DocsConfigFileFormat depends on the basename and the root $schema only |
| DocsAnalyzerConfigFiles | Get-DocsEnvTemplateKey | pure | DocsAnalyzerConfigFiles.Tests.ps1 :: property: Get-DocsEnvTemplateKey returns every generated key once in order with its span and no value |
| DocsAnalyzerConfigFiles | Invoke-DocsAnalyzerConfigFiles | pure | DocsAnalyzerConfigFiles.Tests.ps1 :: property: Invoke-DocsAnalyzerConfigFiles output is byte-identical under permuted input order |
| DocsAnalyzerConfigFiles | Test-DocsEnvTemplatePath | pure | DocsAnalyzerConfigFiles.Tests.ps1 :: property: Test-DocsEnvTemplatePath accepts exactly the four template names under any directory |
| DocsInventorySnapshot | Get-DocsInventoryBoundFinding | pure | DocsInventorySnapshot.Tests.ps1 :: property: Get-DocsInventoryBoundFinding returns a finding exactly when a bound is exceeded |
| DocsInventorySnapshot | Get-DocsInventorySelection | pure | DocsInventorySnapshot.Tests.ps1 :: property: Get-DocsInventorySelection selects exactly the paths that pass the root, exclusion and env predicates in any order |
| DocsInventorySnapshot | New-DocsInventorySnapshot | pure | DocsInventorySnapshot.Tests.ps1 :: property: New-DocsInventorySnapshot is byte-identical under permuted inputs and analyzer outputs |
| DocsInventory | Invoke-DocsInventoryCommand | non-pure (command I/O through the command context) | n/a |

## Seed usage per suite

| Suite | `property:` tests | `System.Random]::new` | `-Because` lines naming the seed |
|---|---|---|---|
| DocsSourceText | 8 | 8 | 12 |
| DocsPythonTokens | 1 | 1 | 1 |
| DocsPythonSyntax | 6 | 6 | 12 |
| DocsPythonBindings | 5 | 5 | 16 |
| DocsTomlKeys | 2 | 2 | 5 |
| DocsYamlKeys | 1 | 1 | 2 |
| DocsJsonSchemaKeys | 2 | 2 | 4 |
| DocsPythonCliArgparse | 1 | 1 | 2 |
| DocsPythonCliClick | 1 | 1 | 3 |
| DocsPythonCliTyper | 1 | 1 | 3 |
| DocsAnalyzerPythonCli | 3 | 3 | 5 |
| DocsPythonHttpSites | 3 | 3 | 6 |
| DocsAnalyzerPythonHttp | 2 | 2 | 4 |
| DocsAnalyzerPythonApi | 3 | 3 | 6 |
| DocsAnalyzerArchitecture | 2 | 2 | 4 |
| DocsAnalyzerConfigFiles | 4 | 4 | 7 |
| DocsInventorySnapshot | 3 | 3 | 5 |
| DocsInventoryProperties | 7 | 8 | 19 |
