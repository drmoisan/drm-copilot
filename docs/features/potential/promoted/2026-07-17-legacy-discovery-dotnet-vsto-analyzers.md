# legacy-discovery-dotnet-vsto-analyzers (Issue #369)

- Date captured: 2026-07-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/ (Issue #369)
- Epic: legacy-discovery-and-parity (child feature #9014, Wave 2, complexity C4)
- Depends on: legacy-discovery-analyzer-framework (#363)

- Issue: #369
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/369
- Last Updated: 2026-07-17

## Problem / Why

The legacy-discovery-and-parity epic delivers a domain-neutral capability for discovering a
legacy system's behavior and defining source-to-target parity. The analyzer framework
(#363) provides a language-neutral `parse -> classify -> map -> emit` pipeline and a
language-neutral repository/project inventory analyzer. It intentionally excludes any
stack-specific analysis. To inventory a consumer repository whose legacy stack is .NET/C#
and VSTO/Office, two concrete stack-specific analyzers are required. Without them, a
consumer migrating a .NET/VSTO application cannot enumerate namespaces, types,
event subscriptions, Ribbon-XML customizations, or COM-interop usage into the discovery
schemas.

## Proposed Behavior

Deliver two concrete analyzers that plug into the framework `Analyzer` protocol (#363):

1. .NET / C# inventory analyzer — enumerate namespaces and types and detect event
   subscriptions over a consumer repository's C# source, emitting Evidence Reference v1
   instances.
2. VSTO / Office analyzer — detect Ribbon-XML customization patterns and COM-interop
   patterns over a consumer repository's source, emitting Evidence Reference v1 instances.

Both analyzers read the consumer repository at the external path the domain profile
declares (`legacy_source.root`). They must be generic over any consumer .NET/VSTO
repository: no TaskMaster/TMW/Outlook-specific hardcoding. They ship `dev.discovery.*`
Poetry console-script CLI entry point(s) mirroring the framework's `dev.discovery.inventory`
conventions and exit-code contract.

The parsing strategy (regex/plain-text stdlib only versus a heavy AST/Roslyn dependency) is
the epic's most research-heavy specification decision; regex/plain-text is the expected
choice consistent with repository precedent and the framework's own decision, and must be
justified rigorously in the spec.

## Acceptance Criteria (early draft)

- [ ] A .NET/C# inventory analyzer implements the framework `Analyzer` protocol and
      enumerates namespaces and types and detects event subscriptions over C# source.
- [ ] A VSTO/Office analyzer implements the framework `Analyzer` protocol and detects
      Ribbon-XML and COM-interop patterns.
- [ ] Both analyzers emit Evidence Reference v1 instances conforming to
      `schemas/discovery/v1/evidence-reference.schema.json`.
- [ ] The parsing-strategy decision (regex/plain-text stdlib only, no AST/Roslyn/tree-sitter)
      is recorded and justified in the spec.
- [ ] `dev.discovery.*` console-script CLI entry point(s) are shipped for the analyzers.
- [ ] Production modules contain no domain-specific (TaskMaster/TMW/Outlook) identifiers,
      verified by a domain-neutrality contract test.
- [ ] Tests satisfy quality-tier policy (line >= 85%, branch >= 75%) with representative
      C#/VSTO source-snippet raw-text fixtures.

## Constraints & Risks

- Domain-neutrality is the highest-risk failure mode: the analyzers detect .NET/C#/VSTO
  patterns but must not hardcode any specific consumer's identifiers.
- No C#/.NET source, Roslyn, or tree-sitter/AST dependency exists in this repository; this
  repository has no C# source of its own.
- File-size limit: no production or test file exceeds 500 lines (raw text fixtures exempt).
- Coverage: `scripts/dev_tools` is in the coverage denominator; no exclusions for new
  analyzer modules.

## Test Conditions to Consider

- [ ] Unit coverage: namespace/type enumeration; event-subscription detection; Ribbon-XML
      detection; COM-interop detection; include/exclude glob handling; Evidence Reference
      emission conformance; CLI success and error exit codes.
- [ ] Integration scenarios: each analyzer end-to-end from a domain profile to a
      schema-conforming collection of artifacts over an in-memory fixture tree.
- [ ] CLI/API examples: `dev.discovery.*` load-and-emit; non-zero exit on malformed profile
      or unreachable source root.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [x] Create `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/` folder from the template
