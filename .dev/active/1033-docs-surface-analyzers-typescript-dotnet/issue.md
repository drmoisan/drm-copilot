# docs-surface-analyzers-typescript-dotnet (Issue #1033)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/docs-surface-analyzers-typescript-dotnet/ (Issue #1033)
- Parent epic: #1019 (documentation-estate-tooling), wave 1, band C4
- Depends on: #1020 (docs-profile-and-artifact-schemas)

- Issue: #1033
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1033
- Last Updated: 2026-10-30
- Work Mode: full-feature

## Problem / Why

The documentation-estate epic (#1019) inventories the documentable surface of a destination
repository so that a coverage ledger can prove that documentation stays in correspondence with
the code. Child #1020 defines the surface element model, the analyzer registry
(`.claude/lib/docs/DocsAnalyzerRegistry.psm1`) and the `Invoke-DocsCommand.ps1` entry script, and
child #1022 adds the PowerShell scanners for Python and configuration surfaces. Repositories whose
surface is written in TypeScript or C#/.NET have no analyzer, so their command-line commands, HTTP
routes, exported symbols, public types and configuration keys cannot be inventoried, and stacks
outside the built-in set have no import path for externally produced results.

Under the owner's implementation-language directive, pushed-down helpers are PowerShell. The
always-available baseline for TypeScript and .NET surfaces is therefore a PowerShell lexical text
scanner. Native TypeScript and C# analyzers are later, optional children and are out of scope here.

## Proposed Behavior

- Add PowerShell lexical scanners under `.claude/lib/docs/`, mirrored byte-identically to the
  push-down tree, for:
  - TypeScript tokens (`DocsTypeScriptTokens.psm1`), TypeScript CLI commands and options
    (Commander and yargs; `DocsAnalyzerTypeScriptCli.psm1`), TypeScript HTTP routes (Express and
    Fastify; `DocsAnalyzerTypeScriptHttp.psm1`) and TypeScript exports
    (`DocsAnalyzerTypeScriptExports.psm1`);
  - C# tokens (`DocsCSharpTokens.psm1`), .NET HTTP routes (attribute routes and minimal-API `Map*`
    calls; `DocsAnalyzerDotnetHttp.psm1`), .NET configuration keys (`appsettings*.json` keys only,
    never values; `DocsAnalyzerDotnetConfig.psm1`) and .NET public types and members
    (`DocsAnalyzerDotnetApi.psm1`);
  - other stacks through the discovery extension-result manifest JSON (`DocsExtensionImport.psm1`).
- Register every analyzer under the 900004 anchor of `DocsAnalyzerRegistry.psm1` with analyzer
  identifiers distinct from those of #1022 (`python-cli`, `python-http`, `python-public-api`,
  `config-files`, `python-architecture`).
- Every element records `analysis_method: scanner` and a digest over the declaration's source
  lines, not the whole file.
- Constructs the scanner cannot classify (dynamic registration, computed route templates,
  re-export chains it cannot resolve, and similar) are reported as diagnostics rather than guessed.
  This precision limit is documented, because the coverage ledger records it as a `deferred` entry
  with an owner.
- Extension-result manifest import validates captured-input digests: a manifest whose digest does
  not match the captured input is rejected with a diagnostic; a matching manifest is merged as
  inert data.

## Acceptance Criteria (early draft)

- [ ] Each analyzer emits the expected elements for in-memory TypeScript and C# fixtures.
- [ ] An extension-result manifest whose captured-input digest does not match is rejected with a diagnostic; a matching manifest is merged as inert data.
- [ ] Re-running over identical bytes produces byte-identical output, and an input above the size bound or a construct the scanner cannot classify yields a diagnostic, not a partial or guessed result.
- [ ] Every element records `analysis_method: scanner` and a declaration-lines digest.
- [ ] Analyzer identifiers are distinct from the #1022 identifiers and are registered under the 900004 anchor of `DocsAnalyzerRegistry.psm1` only.
- [ ] The scanner precision limit is documented for the coverage ledger's deferred entry.
- [ ] No new Python or TypeScript file is added; the plan carries an artifact classification table.
- [ ] Pester line coverage >= 85% for the new modules.

## Constraints & Risks

- Pushed-down code is PowerShell 7 built-ins only; no new third-party PowerShell modules.
- Analyzers are read-only, lexical, bounded and deterministic; they never execute, compile or
  install consumer code.
- Pure functions take strings and hashtables; tests create no temporary files.
- Lexical scanning is less precise than a parser; unclassified constructs surface as diagnostics.
- Append-only conflicts with #1022 in `DocsAnalyzerRegistry.psm1` and the push-down manifest.

## Test Conditions to Consider

- [ ] Unit coverage for each tokenizer and analyzer over in-memory fixtures
- [ ] Determinism over identical bytes; size-bound and unclassifiable-construct diagnostics
- [ ] Extension-result manifest import with matching and mismatching digests

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/docs-surface-analyzers-typescript-dotnet/` folder from the template
