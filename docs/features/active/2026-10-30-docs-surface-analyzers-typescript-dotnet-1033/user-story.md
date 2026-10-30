# `docs-surface-analyzers-typescript-dotnet` — User Story

- Issue: #1033
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T23-10
- Authoritative specification: `spec.md` in this folder

## Story Statement

- As a maintainer of a TypeScript or .NET consumer repository, I want the pushed-down documentation
  helpers to inventory my command-line commands and options, HTTP routes, exported symbols, public
  types and members, and configuration keys with PowerShell alone, so that my coverage ledger can
  prove which parts of that surface are documented without installing Node.js, the .NET SDK or
  Python for the documentation tooling.
- As a maintainer of a TypeScript or .NET consumer repository, I want every construct the scanner
  cannot classify to be reported with a stable code instead of being guessed, so that I can record
  the scanner's precision limit as a deferred ledger entry with an owner and trust that every
  inventoried element is real.
- As a maintainer of a repository whose stack has no built-in analyzer, I want to bring results from
  my own discovery adapter into the inventory through an extension-result manifest, so that the
  ledger covers that surface too, while a manifest that does not match my current sources is
  rejected rather than merged.
- As a downstream epic feature author, I want fixed analyzer identifiers, diagnostic codes,
  declaration forms and a declaration-lines digest rule, so that the ledger, the reference generator
  and a later native analyzer agree with these elements byte for byte.

## Problem / Why

The documentation-estate epic (#1019) inventories the documentable surface of a destination
repository so that a coverage ledger can prove that documentation stays in correspondence with the
code. Child 1020 defines the surface element model, the analyzer registry and the
`Invoke-DocsCommand.ps1` entry script, and child 1022 adds the PowerShell scanners for Python and
configuration surfaces. Repositories whose surface is written in TypeScript or C#/.NET have no
analyzer, so their command-line commands, HTTP routes, exported symbols, public types and
configuration keys cannot be inventoried, and stacks outside the built-in set have no import path
for externally produced results.

Under the owner's implementation-language rule, pushed-down helpers are PowerShell. The
always-available baseline for TypeScript and .NET surfaces is therefore a PowerShell lexical text
scanner with a documented precision limit. Native TypeScript and C# analyzers are later, optional
children and are out of scope here.

## Personas & Scenarios

- Persona: Maintainer of a TypeScript or .NET consumer repository
  - Maintains one consumer repository that receives this repository's Claude customizations and
    whose code is TypeScript (Commander or yargs command-line tools, Express or Fastify services) or
    C#/.NET (ASP.NET Core controllers or minimal APIs, `appsettings*.json` configuration, public
    libraries).
  - Cares that the inventory is complete for the constructs it claims, that nothing is invented,
    and that configuration values such as connection strings never appear in documentation
    artifacts.
  - Constraints: PowerShell 7.4 or later is available; the documentation tooling may not require
    Node.js, the .NET SDK or Python; sources may use CRLF line endings and a byte-order mark.
  - Goals: a deterministic inventory that changes only when the declared surface changes.
    Frustrations: ledger pins that go stale when an unrelated line in the same file changes, and
    silent omissions.
  - Context: adopting the documentation estate tooling after 1020 and 1022 are available.
- Persona: Maintainer of a repository with another stack
  - Runs a separately built discovery adapter that writes an extension-result manifest and
    inventory-snapshot result files.
  - Cares that imported results cannot override built-in results or leak configuration values, and
    that stale adapter output is refused.
  - Goals: one ledger over the whole surface. Frustration: an import that accepts output computed
    from older sources.
- Persona: Downstream epic feature author
  - Implements the coverage ledger (1023), the reference generator (1024) or a later native
    analyzer.
  - Cares that identifiers, codes and digests are stated once and stay stable.
  - Goals: consume these elements and diagnostics without special cases.

- Scenario: Maintainer inventories a TypeScript service
  - Actor: maintainer of a TypeScript consumer repository.
  - Trigger: the profile's `surface_selection` selects `http-route`, `cli-command`, `cli-option` and
    `public-symbol`.
  - Steps: runs the `inventory` subcommand (owned by 1022); the registry invokes `typescript-cli`,
    `typescript-http` and `typescript-exports` over the captured inputs; routes mounted from a
    router in another file appear with the composed prefix.
  - Obstacles and decisions: one route is registered with a path built at run time; the scanner
    emits `http-dynamic-route` with the file, count and first line, and no element. The maintainer
    records the precision limit as a deferred ledger entry with an owner.
  - Outcome: the snapshot lists every literal route once, each with `analysis_method: scanner` and a
    declaration-lines digest; re-running over the same sources yields identical bytes.
- Scenario: Maintainer inventories a .NET service
  - Actor: maintainer of a .NET consumer repository.
  - Trigger: the profile selects `http-route`, `config-key` and `public-symbol`.
  - Steps: `dotnet-http` resolves controller routes (including `[controller]` and `[action]`) and
    minimal-API groups; `dotnet-config` lists every key of `appsettings.json` and
    `appsettings.Production.json` with its type and colon-form configuration path;
    `dotnet-public-api` lists public types and members with overload-distinct declarations.
  - Obstacles and decisions: a file uses `#if`; both branches are scanned, a
    `csharp-conditional-compilation` warning is emitted, and duplicates are reported rather than
    doubled.
  - Outcome: no configuration value appears in the snapshot; editing a method body outside a
    member's declaration lines leaves that member's digest and ledger pin current.
- Scenario: Maintainer imports results for another stack
  - Actor: maintainer of a repository with another stack.
  - Trigger: an adapter wrote an extension-result manifest and its result files into a source root.
  - Steps: `extension-import` validates the manifest, its digest, repository and revision, adapter
    identity, every source-input and result-file digest, and every finding's source.
  - Obstacles and decisions: after a source file was edited, its captured digest no longer matches
    the manifest; the whole manifest is rejected with one blocking
    `extension-input-digest-mismatch` diagnostic and contributes nothing. The maintainer re-runs the
    adapter.
  - Outcome: the regenerated manifest is accepted and its findings appear as elements under
    `extension-import`, with identifiers and digests computed by the docs lib.

## Acceptance Criteria

- [ ] Each of `typescript-cli`, `typescript-http`, `typescript-exports`, `dotnet-http`, `dotnet-config` and `dotnet-public-api` emits the expected elements for in-memory TypeScript and C# (or `appsettings*.json`) fixtures covering the constructs listed in the specification's `## Recognition Rules` (the analyzer suites under `tests/scripts/claude-lib/docs/`, run by `poshqc / PowerShell QC`).
- [ ] An extension-result manifest whose captured-input digest does not match is rejected with one blocking diagnostic and contributes no element, each validation step has its own rejection code, and a matching manifest is merged as inert data with recomputed identifiers and digests (`DocsAnalyzerExtensionImport.Tests.ps1`, run by `poshqc / PowerShell QC`).
- [ ] Re-running any analyzer over identical bytes, in any input order, produces byte-identical output (`DocsScannerContract.Tests.ps1`, run by `poshqc / PowerShell QC`).
- [ ] An input above the 1 MiB size bound, an undecodable input, or a construct the scanner cannot classify yields a diagnostic, not a partial or guessed result; a lexical error in one file does not remove other files' elements (`DocsScannerContract.Tests.ps1`, run by `poshqc / PowerShell QC`).
- [ ] Every element from the built-in scanners records `analysis_method: scanner` and a declaration-lines digest that ignores edits outside the declaration's lines and line-ending conversions (`DocsScannerContract.Tests.ps1`, run by `poshqc / PowerShell QC`).
- [ ] No configuration value appears in analyzer output or in a `config-key` digest input; only keys and shapes are emitted, including for imported `config-key` findings (`DocsAnalyzerDotnetConfig.Tests.ps1`, `DocsAnalyzerExtensionImport.Tests.ps1`, run by `poshqc / PowerShell QC`).
- [ ] The analyzer identifiers `typescript-cli`, `typescript-http`, `typescript-exports`, `dotnet-http`, `dotnet-config`, `dotnet-public-api` and `extension-import` are distinct from 1022's identifiers and are registered under the 900004 anchor of `DocsAnalyzerRegistry.psm1` only; 1020's registry suite asserts membership rather than an empty registry (`DocsAnalyzerRegistry.TypeScriptDotnet.Tests.ps1`, `DocsAnalyzerRegistry.Tests.ps1`, run by `poshqc / PowerShell QC`).
- [ ] The scanner precision limit is documented in the specification's `## Scanner Precision Limit` for the coverage ledger's deferred entry, is returned by `Get-DocsScannerPrecisionLimit`, and every listed code is emitted by a fixture (`DocsScannerCommon.Tests.ps1`, `DocsScannerContract.Tests.ps1`, run by `poshqc / PowerShell QC`).
- [ ] The push-down copy of every new or edited `.claude/lib/docs/` file is byte-identical to its source and listed in the Claude `core.json` (`Docs.Manifest.Tests.ps1`, run by `poshqc / PowerShell QC`, and the existing push-down contract tests passing unmodified).
- [ ] No new Python or TypeScript file is added, and the plan carries the artifact classification table.
- [ ] Pester line coverage is at least 85% for each new module, and no test creates a temporary file.
- [ ] (CI-dependent) The required check `poshqc / PowerShell QC` (Windows shards, coverage) passes on the pull request head.

## Owner Questions

Carried from `spec.md` `## Owner Questions` with their provisional defaults (none decided): OQ-1
analysis method of imported elements (default: manifest extensions key `docs.analysis-method`,
`scanner` when absent), OQ-2 ledger representation of the precision limit (default: a ledger section
keyed by `(analyzer_id, code)`, decided by 1023), OQ-3 JavaScript sources (default: out of scope),
OQ-4 digest of a configuration key line (default: the line with values replaced by their type
names), OQ-5 anchor numbering (default: the `900004` placeholder text stays as committed).

## Non-Goals

- Native TypeScript and C# analyzers (later, optional children under D3).
- The `inventory` subcommand, snapshot assembly and inventory merge (1022).
- The ledger representation of the precision limit (1023).
- JavaScript inputs (OQ-3), Razor, Blazor, gRPC, SignalR, OpenAPI documents and project files.
- Calling the Python discovery runtime, the TypeScript compiler, Roslyn, Node.js or `dotnet`.
- Any Python or TypeScript code, and any change to discovery schemas or runtime.
