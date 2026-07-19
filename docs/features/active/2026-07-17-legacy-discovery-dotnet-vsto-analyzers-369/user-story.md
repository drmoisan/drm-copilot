# legacy-discovery-dotnet-vsto-analyzers — User Story

- Issue: #369
- Parent epic: legacy-discovery-and-parity (child feature #9014, Wave 2, complexity C4)
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-17
- Work Mode: full-feature

## Story Statement

- As a maintainer of a consumer repository migrating a .NET/VSTO application to a modern
  architecture, I want to author a domain profile and run stack-specific discovery analyzers
  over my legacy C#/VSTO source, so that namespaces, types, event subscriptions, Ribbon-XML
  customizations, and COM-interop usage are captured as schema-conforming Evidence Reference
  artifacts that the rest of the discovery-and-parity workflow can consume.
- As the same maintainer, I want the analyzers to be generic over any .NET/VSTO repository
  and honest about their heuristic accuracy, so that I can trust the artifacts as anchored
  evidence without mistaking them for a compiler-grade symbol table.

## Problem / Why

The analyzer framework (#363) provides a language-neutral `parse -> classify -> map -> emit`
pipeline and a language-neutral repository/project inventory analyzer, but it intentionally
excludes stack-specific analysis. A maintainer whose legacy stack is .NET/C# and VSTO/Office
therefore has no way to enumerate namespaces, types, event subscriptions, Ribbon-XML
customizations, or COM-interop usage into the discovery schemas. Without those detections, the
coverage ledger, parity matrix, and downstream reports (#9010) have no stack-level evidence to
reference, and the migration effort cannot systematically account for the legacy behavior that
lives in event wiring, ribbon customization, and COM boundaries.

## Personas & Scenarios

- **Persona: consumer-repository maintainer (legacy .NET/VSTO application).**
  - Owns a repository containing a C# solution with VSTO/Office customization (ribbon XML,
    COM interop) that is being migrated to a modern target.
  - Cares about a complete, evidence-anchored inventory of the legacy surface; needs the
    output machine-readable so validators, reports, and agents can consume it.
  - Constraints: cannot assume a .NET SDK or Roslyn on the analysis host; runs the discovery
    tooling from the reusable framework, not bespoke per-repo scripts; the legacy repository
    is external to the tooling repository.
  - Frustrations: hand-built inventories drift and miss event wiring and COM boundaries;
    generic file inventories (#363) do not say what the C# source declares or how Office is
    customized.

- **Scenario: run the stack analyzers from a domain profile.**
  1. The maintainer authors `discovery-profile.yaml` at the consumer repository root,
     declaring `legacy_source.root` (the path to the legacy checkout), `include`/`exclude`
     globs, `technology_stack.legacy` (for example `["csharp", "vsto"]`), and
     `artifacts.root`.
  2. The maintainer runs `dev.discovery.dotnet`. The analyzer walks the legacy tree honoring
     the globs, scans comment/string-stripped C# text, and writes one Evidence Reference v1
     instance per detected namespace, type, event declaration, delegate, and event
     subscription under the artifacts root. Subscription detections are tagged
     `confidence: "heuristic"`.
  3. The maintainer runs `dev.discovery.vsto`. The analyzer routes files by kind — C#, ribbon
     XML, and project XML — and writes one instance per detected customUI document,
     `IRibbonExtensibility`/`GetCustomUI`/designer-ribbon usage, interop attribute,
     `Marshal.*` call, `GetTypeFromProgID` call, Office interop using, and project-file COM
     reference.
  4. The maintainer inspects the run summary (`--json`) and the emitted artifacts; each
     artifact carries the file path, line number, detected symbol, and detection kind in
     `metadata`, so downstream validators (#9003) and reports (#9010) can reference it.
  5. If the profile is malformed or the legacy root is unreachable, the command exits `1`
     with a specific error; a usage error exits `2`. Nothing is partially fabricated.
  - Expected outcome: a deterministic, schema-conforming evidence corpus of the legacy
    .NET/VSTO surface, produced by reusable tooling with no consumer-specific code anywhere
    in the analyzers.

## Acceptance Criteria

- [x] Given a valid domain profile whose `legacy_source.root` points at a .NET/C# repository,
      when the maintainer runs `dev.discovery.dotnet`, then namespace declarations (block and
      file-scoped), type declarations (class/struct/interface/enum/record/record struct),
      event and delegate declarations, and `+=`/`-=` event subscriptions are each emitted as
      Evidence Reference v1 instances anchored to a consumer-relative file path and line.
- [x] Given the same profile over a VSTO/Office repository, when the maintainer runs
      `dev.discovery.vsto`, then Ribbon-XML customization (2006/2009 customUI URIs,
      `<customUI` root, `IRibbonExtensibility`, `GetCustomUI`,
      `Microsoft.Office.Tools.Ribbon`) and COM-interop usage (`[ComImport]`/`[Guid]` and
      related attributes, `Marshal.*`, `GetTypeFromProgID`, Office interop usings, project
      `COMReference`/`EmbedInteropTypes`) are each emitted as Evidence Reference v1
      instances.
- [x] Both analyzers honor the profile's `include`/`exclude` globs and fail fast with a clear
      error and exit code `1` when the profile is malformed or `legacy_source.root` is
      unreachable; usage errors exit `2`; successful runs exit `0` and support `--json`.
- [x] Every emitted artifact validates against
      `schemas/discovery/v1/evidence-reference.schema.json`: `kind` is `"file"`, the id is a
      stable slug, `$schema` is a scheme-less relative path, and all detection specifics
      (`detection_kind`, `symbol`, `symbol_kind`, `line`, `confidence`) appear only inside
      `metadata`.
- [x] Event-subscription detections are explicitly marked heuristic
      (`metadata.confidence = "heuristic"`), and analyzer output and documentation describe
      detections as textual pattern evidence, not compiler-verified symbols.
- [x] Re-running an analyzer over an unchanged tree with a pinned clock produces
      byte-identical artifacts, so the maintainer can diff discovery runs meaningfully.
- [x] The analyzers work unmodified for any consumer .NET/VSTO repository: production modules
      contain no consumer identifiers and no per-Office-application special-casing (the
      interop application name is captured as data), verified by a domain-neutrality contract
      test that permits generic stack literals (`csharp`, `vsto`, `Microsoft.Office.*`,
      `.csproj`, `.sln`, customUI URIs).
- [x] The delivered tests satisfy repository quality-tier policy (line >= 85%, branch >= 75%,
      mirrored test tree, no temporary files, injected clock) and include raw C#/VSTO
      text-snippet fixtures with false-positive traps (comment/string declaration look-alikes,
      arithmetic `+=`), demonstrating the maintainer-facing accuracy claims.

## Non-Goals

- No reimplementation of the analyzer framework, runner, emitter, or inventory analyzer
  (#363); no domain-profile loader changes (#360); no schema authoring (#359).
- No MCP-tool or VS Code exposure of the commands (#9011).
- No semantic C# analysis (symbol resolution, preprocessor evaluation, project-graph
  binding); the analyzers are heuristic evidence scanners.
- No analyzers for stacks other than .NET/C# and VSTO/Office, and no aggregate reports
  (#9010).
