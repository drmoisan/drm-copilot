# `docs-surface-analyzers-typescript-dotnet` — User Story

- Issue: #1033
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T18-39

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

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


## Personas & Scenarios

- Persona: ...
  - who the user is
  - what they care about
  - their constraints
  - their goals and frustrations
  - their context and motivations
- Scenario: ...
  - A concrete, step-by-step narrative that describes how a user accomplishes a goal in a real-world context using the system.
  - who is acting?
  - what triggered the action?
  - what steps do they take?
  - what obstacles or decisions occur?
  - what outcome do they expect?


## Acceptance Criteria

- [ ] Each analyzer emits the expected elements for in-memory TypeScript and C# fixtures.
- [ ] An extension-result manifest whose captured-input digest does not match is rejected with a diagnostic; a matching manifest is merged as inert data.
- [ ] Re-running over identical bytes produces byte-identical output, and an input above the size bound or a construct the scanner cannot classify yields a diagnostic, not a partial or guessed result.
- [ ] Every element records `analysis_method: scanner` and a declaration-lines digest.
- [ ] Analyzer identifiers are distinct from the #1022 identifiers and are registered under the 900004 anchor of `DocsAnalyzerRegistry.psm1` only.
- [ ] The scanner precision limit is documented for the coverage ledger's deferred entry.
- [ ] No new Python or TypeScript file is added; the plan carries an artifact classification table.
- [ ] Pester line coverage >= 85% for the new modules.


## Non-Goals

Call out what is explicitly excluded from this feature.
