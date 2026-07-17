# legacy-discovery-dotnet-vsto-analyzers — Spec

- **Issue:** #369
- **Parent (optional):** Epic legacy-discovery-and-parity (child feature #9014, Wave 2, complexity C4)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature
- **Depends on:** legacy-discovery-analyzer-framework (#363)
- **Integration branch:** epic/legacy-discovery-and-parity-integration

## Overview

The analyzer framework (#363) provides a language-neutral `parse -> classify -> map -> emit`
pipeline and a language-neutral repository/project inventory analyzer; it intentionally
excludes stack-specific analysis. Without concrete stack-specific analyzers, a consumer
migrating a .NET/VSTO application cannot enumerate namespaces, types, event subscriptions,
Ribbon-XML customizations, or COM-interop usage into the discovery schemas.

This feature delivers two concrete analyzers that plug into the #363 `Analyzer` protocol: the
**.NET/C# inventory analyzer** (namespace/type enumeration and event-subscription detection
over C# source) and the **VSTO/Office analyzer** (Ribbon-XML customization and COM-interop
detection over C#, XML, and project files). Both emit one Evidence Reference v1 instance per
detection; both are stack-specific by charter but consumer-neutral by invariant (no hardcoded
consumer identifiers). Decisions in this spec are grounded in the feature research artifact
`research/2026-07-17-dotnet-vsto-analyzers-research.md`.

## Scope

### In scope

- `DotnetInventoryAnalyzer`: namespace enumeration (block and file-scoped forms), type
  enumeration (class/struct/interface/enum/record/record struct), event and delegate
  declaration detection, heuristic event-subscription (`+=`/`-=`) detection.
- `VstoOfficeAnalyzer`: Ribbon-XML detection and COM-interop detection, per the catalogs in
  Behavior.
- A shared pure text-scanning helper module (`source_text.py`): line-number-preserving
  comment/string stripper, line utilities, id slugifier/hash.
- A shared CLI module (`stack_cli.py`) and two Poetry console scripts, `dev.discovery.dotnet`
  and `dev.discovery.vsto`, mirroring the `dev.discovery.inventory` argparse surface and
  exit-code contract.
- Evidence Reference v1 emission (one conforming instance per detection) reusing the #363
  emitter; the parsing-strategy Specification Decision (below); a domain-neutrality contract
  test scoped to this feature's consumer-neutrality rule (see Constraints & Risks); unit and
  integration tests meeting quality-tier policy, including raw C#/VSTO snippet fixtures.

### Out of scope

- **The analyzer framework and language-neutral inventory analyzer** — owned by #363. This
  feature consumes the `Analyzer` protocol, value objects, filesystem seam, runner, and
  emitter; it does not reimplement them.
- **The domain-profile loader** — owned by #360; consumed via
  `scripts/dev_tools/discovery/domain_profile.py`.
- **The discovery JSON schemas** — owned by #359; this feature emits conforming instances of
  `schemas/discovery/v1/evidence-reference.schema.json`, it does not author schemas.
- **MCP-tool and VS Code exposure of the CLI** — owned by #9011.
- Semantic C# analysis (symbol resolution, overload binding, project-graph or preprocessor
  evaluation; see the Specification Decision); analyzers for any other stack; aggregate
  report generation (#9010).

## Specification Decision: Parsing Strategy

**Decision: regex / plain-text scanning using the Python standard library only (`pathlib`,
`re`, `fnmatch`, `json`, `hashlib`). No new runtime dependency. No AST / Roslyn / tree-sitter /
grammar library.** This is the epic's C4 specification decision for this feature.
Justification, grounded in `research/2026-07-17-dotnet-vsto-analyzers-research.md` (Q1):

1. **No AST or parser dependency exists in the repository.** Verified by the research by
   reading `pyproject.toml` (runtime and dev groups) and by ripgrep over `pyproject.toml` for
   `tree.sitter|roslyn|libcst|antlr|pygments|parso` (no matches). There is no C#/.NET
   toolchain in the repository and no C# source.
2. **Dependency policy prohibits silent addition.** `.claude/rules/python.md` lists "Adding
   new dependencies without explicit user instruction" as a Prohibited Behavior. `tree_sitter`
   plus `tree-sitter-c-sharp` would be two new native runtime dependencies; Roslyn is not
   consumable from Python without a .NET process boundary and a .NET SDK on every host.
3. **Repository precedent is uniformly regex/plain-text or external-tool delegation.**
   `scripts/dev_tools/codex_native_converter/classifier.py` and `parser.py` do all
   classification and parsing-shaped work with compiled `re` patterns and line iteration,
   never a grammar; where real language analysis is needed (PowerShell),
   `fix_all_branches.py` shells out to PSScriptAnalyzer via `pwsh`. The #363 spec records the
   identical decision for the framework and explicitly reserves richer text scanning — not
   AST parsing — as what #9014 plugs into the `parse` stage.
4. **Domain neutrality argues against an embedded grammar.** A vendored C# grammar or a Roslyn
   bridge would hard-couple one language's compilation model into the analyzer package and its
   build/test environment. The stack-specific knowledge this feature holds is a pattern
   catalog — data-like, inspectable, testable as pure functions — not a grammar runtime.
5. **Simplicity-first** (`.claude/rules/general-code-change.md`, design priority #1). The
   acceptance criteria require inventory and detection, not semantic analysis; line-oriented
   regex over comment/string-stripped text answers every criterion. An AST would add fidelity
   the artifacts do not require, at the cost of a native dependency, a grammar-version
   treadmill, and a larger test matrix.

**Rejected alternatives:** tree-sitter + tree-sitter-c-sharp (two new native runtime
dependencies, grammar-version drift, a language runtime embedded in a domain-neutral
framework); Roslyn via a .NET subprocess (a .NET SDK on every host, a second toolchain, a
process boundary, no precedent); Pygments tokenization (a new dependency whose token stream
yields declarations no more directly than regex).

### Limitations of regex scanning of C# (stated normatively)

1. **Comments and string literals** can contain declaration-shaped text (`// namespace Fake`,
   `var s = "class Foo";`). Mitigated — not eliminated — by the pre-scan stripper below.
2. **Verbatim strings** (`@"..."`), **interpolated strings** (`$"{expr}"`, nested braces,
   `$@"..."`), and **raw string literals** (C# 11 `"""..."""`) defeat naive quote tracking.
   The stripper handles the common forms; pathological nesting is best-effort.
3. **Preprocessor directives** (`#if !DEBUG ... #endif`): detected symbols may be
   conditionally compiled out; the scanner reports what is textually present and does not
   evaluate preprocessor symbols.
4. **Generics:** the base identifier and raw generic-arity text are captured; constraints are
   not modeled.
5. **Nested and file-scoped namespaces:** a nested block namespace is detected as independent
   namespace lines; composed scopes (`A.B`) are not computed and type-to-namespace membership
   is not tracked across brace depth. Symbol records are file-and-line anchored, not
   scope-resolved.
6. **Partial types** produce one detection per declaration site; detection count is not
   distinct-type count.
7. **`+=` ambiguity:** arithmetic compound assignment is textually identical to event
   subscription; see the mitigation in Behavior.

**Claim-scoping rule:** the analyzers are heuristic evidence scanners, not compilers. Every
emitted artifact records an observed textual pattern with a file/line anchor — the claim is
"this pattern occurs at this location", never "this program declares exactly these symbols".
Descriptions and documentation use detection language; metadata carries the analyzer name and
`detection_kind` so downstream consumers (#9003, #9010) treat the records as evidence, not a
symbol table.

**Mitigation — comment/string stripper:** a small pure helper (in `source_text.py`) performs
a single line-by-line character scan tracking four states — code, `//` line comment, `/* */`
block comment, string literal (`"`, `@"`, `$"`, `'` forms) — and returns the text with
non-code spans blanked (replaced by spaces) so line and column numbers are preserved.
Deterministic, stdlib-only, unit-testable with inline strings; raw strings and deeply nested
interpolation are best-effort. All C# regexes run over stripped text; XML is unstripped.

## Behavior

Both analyzers are distinct implementations of the #363 `Analyzer` protocol, driven by
`run_analyzer(analyzer, ctx, fs)` in the fixed order `parse -> classify -> map -> emit`. Both
read the consumer repository at `profile.legacy_source.root`, honoring `include`/`exclude`
globs applied with stdlib `fnmatch` against consumer-relative POSIX paths (identical semantics
to the #363 inventory analyzer). An unreachable or missing root fails fast with
`AnalyzerError`, distinct from a malformed-profile `DomainProfileError`.

### .NET/C# inventory analyzer (`DotnetInventoryAnalyzer`, `name = "dotnet-inventory"`)

- **parse** (I/O): walk the consumer tree behind the `AnalyzerFileSystem` seam, apply
  include/exclude filtering, select `.cs` candidates, read each candidate's text via the
  seam, and return a `TextParseResult` (see Contracts).
- **classify** (pure): strip comments/strings, then apply the C# detection catalog:
  - **Namespace declarations** — block form (`namespace A.B {`, brace on the same or next
    line) and file-scoped form (`namespace A.B;`, C# 10) in one line-anchored pattern;
    `metadata.declaration_form` records `"block"` or `"file_scoped"`.
  - **Type declarations** — one line-anchored pattern covering `class | struct | interface |
    enum | record | record class | record struct`, tolerating attribute lines, modifier
    stacks, generics, and nesting; `metadata.symbol_kind` is normalized (`record class` ->
    `record`, `record struct` -> `record_struct`); `metadata.generic` records generic arity.
  - **Event declarations** (field-like and custom-accessor forms) and **delegate type
    declarations**, each a distinct `detection_kind`.
  - **Handler subscription/unsubscription** (`+=` / `-=`) — the highest false-positive-risk
    pattern (`total += 3` is textually identical). Mitigation: reject matches whose handler
    begins with a numeric, string, or char literal; accept handlers containing `=>`, `new `,
    `delegate`, or a bare dotted-identifier method group. Every surviving match carries
    `metadata.confidence = "heuristic"`; residual risk (for example `x += y.Count`) is
    accepted and documented, and no type resolution is attempted.
- **map** (pure): one `EvidenceRecord` per detection, per the emission contract below.
- **emit**: reuse the #363 emitter.

### VSTO/Office analyzer (`VstoOfficeAnalyzer`, `name = "vsto-office"`)

File routing within the include/exclude-filtered set: C# patterns run on `.cs` (stripped
text); Ribbon-XML patterns run on `.xml` (unstripped); project-file patterns run on `*proj`
XML (unstripped).

- **Ribbon-XML detections:**
  - customUI namespace URIs for both generations —
    `schemas.microsoft.com/office/2006/01/customui` and `.../2009/07/customui`
    (`metadata.customui_schema` records the matched URI) — and the corroborating `<customUI`
    root element (`detection_kind = "ribbon_xml"`).
  - `IRibbonExtensibility` usage (bare or namespace-qualified), `GetCustomUI(` (the single
    method of `IRibbonExtensibility`; the strongest runtime-ribbon signal), and the designer
    model `Microsoft.Office.Tools.Ribbon` (designer-generated ribbons bypass `GetCustomUI`,
    so this pattern is required for coverage) (`detection_kind = "ribbon_extensibility"`).
- **COM-interop detections:**
  - Interop attributes `[ComImport]`, `[ComVisible(...)]`, `[Guid("...")]` (GUID captured
    into `metadata.com_guid`), `[InterfaceType(...)]`, `[DispId(...)]`
    (`detection_kind = "com_attribute"`).
  - `Marshal.<member>(` calls, member captured into `metadata.symbol`, no fixed member list
    (`detection_kind = "marshal_call"`); `Type.GetTypeFromProgID(`
    (`detection_kind = "progid_activation"`).
  - Office interop usings — `using [static] [alias =] Microsoft.Office.Interop.<App>` — with
    the application name captured as data into `metadata.interop_target`, never hardcoded or
    special-cased (`detection_kind = "interop_using"`). This capture-as-data rule is the
    concrete mechanism keeping the analyzer consumer-neutral while Office-stack-aware.
  - Project-file COM references: `<COMReference>` (the `Include=` value captured into
    `metadata.symbol` when present), `<EmbedInteropTypes>`, and interop assembly references
    (`Include="Microsoft.Office.Interop.*"`) (`detection_kind = "com_reference"`).

### Shared behavior

One Evidence Reference instance per detection (not per file), consistent with the #363
"N conforming instances, not one aggregate" pattern; ids are disambiguated by a hash suffix;
no aggregate claims are emitted. Declaration patterns are line-anchored so mid-expression
text rarely matches. The same tree, profile, and clock value produce byte-identical output.

## Contracts

### Framework plug-in contract (against #363)

Each analyzer implements the structural `Analyzer` protocol — `name: str` plus
`parse/classify/map/emit` — with no registration mechanism and no base class; the CLI
constructs the concrete analyzer and hands it to `run_analyzer(analyzer, ctx, fs)`, which
returns `AnalyzerRunResult`. No global registry or plugin discovery (prohibited by
`.claude/rules/python.md`; consistent with #363). Reused, not reimplemented, from #363:
`models.py` value objects, `pipeline.py` protocols / runner / `RealAnalyzerFileSystem`,
`emitter.py`, `AnalyzerError`. Reused from #360: `domain_profile.py` (loader,
`DomainProfileError`, `DEFAULT_PROFILE_FILENAME`).

### File-text acquisition (`TextParseResult`)

The #363 contract defines `ParseResult` as the ordered tuple of consumer-relative POSIX file
paths — paths only, no content. These analyzers need file text to flow from the I/O stage
(`parse`) into the pure stage (`classify`) without `classify` performing I/O (reading text in
`classify` would violate the framework's pure-classify design and the I/O-boundaries rule).
Adopted approach, requiring no change to #363: a frozen dataclass subtype
`TextParseResult(ParseResult)` adds `file_texts: tuple[tuple[str, str], ...]` — ordered
`(consumer-relative-path, text)` pairs. `parse` returns the subtype (covariant return
satisfies the protocol); `classify` accepts `ParseResult` and isinstance-narrows to
`TextParseResult`, raising `AnalyzerError` otherwise (fail-fast). Both analyzers share the one
subtype. **Open coordination item (recorded, not a blocker):** the preferred long-term
resolution is for #363 to genericize `ParseResult` with an optional payload field before its
contract freezes; this must be raised with #363 at integration-branch time. This feature
designs and plans against the subtype approach so it is not blocked.

### Evidence Reference emission contract (discovery v1)

Every detection from both analyzers is emitted as one Evidence Reference v1 instance:

- **`kind`:** `"file"` for every detection. Each detection is anchored to a source file; the
  schema enum has no `namespace`/`type`/`event`/`ribbon`/`com` values, and per top-level
  `additionalProperties: false` no new top-level field may carry that distinction. Therefore
  **all detection specifics live only inside `metadata`**, the schema's single sanctioned
  free-form extension point: `metadata.analyzer` (`"dotnet-inventory"` / `"vsto-office"`);
  `metadata.detection_kind`, one of the normative vocabulary
  `namespace | type | event_declaration | delegate | event_subscription | ribbon_xml |
  ribbon_extensibility | com_attribute | marshal_call | progid_activation | interop_using |
  com_reference` (a de-facto contract for #9010 reports and #9011 MCP exposure);
  `metadata.symbol`; `metadata.symbol_kind` (`namespace | class | struct | interface | enum |
  record | record_struct | event | delegate | method | element | assembly`); `metadata.line`
  (1-based); `metadata.confidence` (`"heuristic"` on event subscriptions); plus
  detection-specific keys (`declaration_form`, `generic`, `customui_schema`, `com_guid`,
  `interop_target`) as documented in Behavior.
- **`location`:** the consumer-relative POSIX path of the source file (relative to
  `profile.legacy_source.root`), in the consumer repository's own terms; line information
  goes in `metadata.line`, never appended to `location`.
- **`id`:** matches `^[a-z0-9][a-z0-9._-]*$` (the #359 shared identifier grammar). Slug
  scheme: `<analyzer-prefix>-<detection_kind>-<slugified-symbol-or-path>-<hash8>`, where
  `hash8` is the first 8 hex characters of
  `sha256(location + ":" + line + ":" + detection_kind + ":" + symbol)` and the slugifier
  lowercases and replaces characters outside `[a-z0-9._-]` with `-`. Ids are deterministic
  (no clock, no counter) and unique across identical symbols at different locations.
- **`$schema`:** a scheme-less relative POSIX path from the emitted instance file to
  `schemas/discovery/v1/evidence-reference.schema.json`, computed by the reused #363 emitter
  — never a drive letter, never a leading `/` (absolute Windows paths are rejected by
  `validate_json.py::_load_schema`).
- **`schema_version`:** `"1.0.0"` (pattern `^1\.\d+\.\d+$`). **`captured_at`:** the ISO-8601
  value from the injected clock via `AnalyzerContext`. **`description`:** a static, generic
  sentence naming the detection kind with no consumer identifiers (the detected symbol
  belongs in `metadata.symbol`, not `description`). **`content_hash`** (optional,
  recommended): `{algorithm: "sha256", value: <hex of file bytes>}` via stdlib `hashlib`.
  **`tool`:** the invoking console-script name. Serialization is deterministic
  (`json.dumps(..., sort_keys=True, indent=2)`), via the #363 emitter.

### CLI contract

- Two Poetry console scripts, one shared CLI module (precedent: the `shell-qc-*` multi-entry
  pattern in `pyproject.toml`):
  `"dev.discovery.dotnet" = "scripts.dev_tools.discovery.analyzer.stack_cli:main_dotnet"` and
  `"dev.discovery.vsto" = "scripts.dev_tools.discovery.analyzer.stack_cli:main_vsto"`.
  Two scripts rather than one script with a subcommand mirrors the epic's
  one-command-per-capability convention (`dev.discovery.profile` #360,
  `dev.discovery.inventory` #363), and #9011 wraps discrete commands.
- `argparse` surface identical to `dev.discovery.inventory`: positional `profile` (path,
  `nargs="?"`, default `DEFAULT_PROFILE_FILENAME` = `"discovery-profile.yaml"`, imported from
  `scripts.dev_tools.discovery.domain_profile`); `--output-dir` (path, overrides
  `profile.artifacts.root`); `--json` (machine-readable run summary — written paths / record
  count — to stdout). `main_dotnet(argv) -> int` and `main_vsto(argv) -> int` delegate to one
  shared `_run(analyzer_factory, argv)` helper.
- Exit-code contract identical to the framework: `0` success; `1` domain/analyzer error
  (`DomainProfileError` or `AnalyzerError`, caught only at the CLI boundary); `2` argparse
  usage error. If #363's `cli.py` factors its profile-load/context-build/run/summary flow
  into a reusable helper, `stack_cli.py` calls it; otherwise that refactor is proposed to
  #363 at integration rather than copying the flow (open coordination item).

## Inputs / Outputs

- **Inputs:** the CLI surface above; domain profile fields `legacy_source.root`, `.include`,
  `.exclude`, and `artifacts.root` read via the #360 loader; the consumer repository source
  tree at `legacy_source.root` (external to this repository) — `.cs`, `.xml`, and `*proj`
  files as routed per analyzer; an injected clock supplying `captured_at` via
  `AnalyzerContext` (wall-clock in production, pinned in tests).
- **Outputs:** Evidence Reference v1 JSON instances (one per detection) under the resolved
  output root; an optional stdout run summary with `--json`; exit codes 0/1/2.
- **Config keys and defaults:** `profile` defaults to `DEFAULT_PROFILE_FILENAME`; output root
  defaults to `profile.artifacts.root` unless overridden by `--output-dir`.
- **Versioning / backward compatibility:** emitted instances declare `schema_version`
  matching `^1\.\d+\.\d+$` (`"1.0.0"`) and reference the v1 schema via a relative `$schema`
  path. The `metadata.detection_kind` vocabulary is additive-only once consumed downstream.

## Data & State

- **Data flow:** domain profile -> `AnalyzerContext` -> seam walk + text read
  (`TextParseResult`) -> strip + pattern catalog (`ClassifyResult` of typed detections) ->
  `EvidenceRecord` tuple -> serialized Evidence Reference instances on disk.
- **Invariants:** enumeration is deterministic (POSIX-sorted); ids are pure functions of
  `(location, line, detection_kind, symbol)`; fixed inputs and clock produce byte-identical
  output; `location` is always consumer-relative POSIX text; `$schema` is always a
  scheme-less relative POSIX path; nothing detection-specific appears outside `metadata`.
- **Caching, persistence, migration, backfill:** none; the analyzers are stateless per run.

## Constraints & Risks

- **Consumer-neutrality (highest-risk failure mode) — with a scoping nuance.** These modules
  are stack-specific by charter, so the #360/#363 banned-substring lists (which ban `vsto`
  and `outlook` in framework production modules) must not be misapplied here. The #369
  domain-neutrality contract test bans **consumer identifiers** (`taskmaster`, `tmw`) and
  **consumer-specific or per-application hardcoding** (for example a literal
  `Microsoft.Office.Interop.Outlook` special case, or any branch on a specific Office
  application name), while it **permits generic stack literals** — `csharp`, `vsto`,
  `Microsoft.Office.*`, `.csproj`, `.sln`, and the customUI ribbon namespace URIs — which are
  the generic subject matter of these stack-specific analyzers. Feature review must apply
  this feature-scoped list, not the framework's stricter one (the #363 `.csproj`/`.sln` ban
  scopes to #363's language-neutral modules; those literals are legitimate pattern data
  here).
- **Accuracy claims.** The regex limitations and heuristic claim-scoping rule are normative;
  documentation and descriptions must not overstate detection as compilation-grade analysis.
- **Upstream sequencing (not a planning blocker).** `scripts/dev_tools/discovery/` and
  `schemas/discovery/v1/` do not exist in this worktree yet; #360/#359/#363 merge into the
  integration branch before this feature executes. Design against their documented contracts.
- **`ParseResult` contract friction.** The `TextParseResult` subtype requires no #363 change,
  but the payload question must be reconciled with #363 before its contract freezes (open
  coordination item in Contracts).
- **Consumer-repository reality.** The analyzers read an external consumer repository at the
  profile-declared path; this repository contains no C# source of its own, so all C#/VSTO
  test inputs are committed raw-text fixtures or inline strings.
- **Windows `$schema` relative-path risk.** Mitigated by reusing the #363 emitter.
- **File-size limit.** No production or test file exceeds 500 lines (raw text fixtures
  exempt). If either pattern-catalog module approaches the limit, the pattern tables split
  into data-only `dotnet_patterns.py` / `vsto_patterns.py` siblings.
- **Coverage measurement.** `scripts/dev_tools` is in the coverage denominator; no exclusion
  may be added for the new modules, so CLI and `__main__` wiring stay minimal.

## Implementation Strategy

- **Implementation scope:** four new modules under `scripts/dev_tools/discovery/analyzer/`
  (siblings to the #363 framework modules), a mirrored test tree, a raw-fixture directory,
  and two `pyproject.toml` console-script lines. Design against, do not reimplement, the #363
  framework, the #360 loader, and the #359 schemas.
- **New modules (each < 500 lines), under `scripts/dev_tools/discovery/analyzer/`:**
  `dotnet_inventory.py` (`DotnetInventoryAnalyzer`: file routing, C# pattern-catalog
  application, map stage); `vsto_office.py` (`VstoOfficeAnalyzer`: ribbon and COM catalogs,
  XML/`*proj` routing, map stage); `source_text.py` (shared pure helpers: stripper state
  machine, line utilities, id slugifier + hash; no I/O); `stack_cli.py` (argparse surface
  plus `main_dotnet` / `main_vsto` over one shared `_run` helper); contingent split modules
  `dotnet_patterns.py` / `vsto_patterns.py` (data-only pattern tables) only if the 500-line
  limit requires them.
- **Dependency changes:** none. Standard library only (`pathlib`, `re`, `fnmatch`, `json`,
  `hashlib`, `argparse`, `dataclasses`, `typing`). `jsonschema` remains a dev-only test
  dependency.
- **Logging/telemetry:** the repository's established logging pattern for analyzer errors;
  the `--json` summary is the machine-readable run output. No new telemetry system.
- **Rollout:** no feature flags; the console scripts are inert until invoked. The `analyzer/`
  subpackage placement follows #363; package `__init__.py` coordination happens on the
  integration branch.

## Testing Requirements

- Test tree mirrors production at `tests/scripts/dev_tools/discovery/analyzer/`
  (`test_dotnet_inventory.py`, `test_vsto_office.py`, `test_source_text.py`,
  `test_stack_cli.py`, plus a domain-neutrality contract test module or parametrized
  additions to the framework's). Colocation in the production source tree is prohibited.
- **No temporary files.** Pure detection tests feed inline C#/XML strings to classify-stage
  functions (no filesystem); end-to-end and CLI tests build the consumer tree and profile on
  the in-memory `mem_fs_path` fixture from `tests/conftest.py`. pytest `tmp_path` is unused.
- **Injected clock.** `captured_at` flows from `AnalyzerContext`; tests pin a constant
  ISO-8601 value and assert byte-identical emission across two runs.
- **Schema validation in tests.** `jsonschema` (dev dependency) validates every emitted
  instance against the v1 schema with `Draft202012Validator` (offline; relative `$schema`),
  asserting the exact top-level key set, `id` and `schema_version` patterns, `$schema` free
  of scheme/drive-letter/leading slash, and all detection extras under `metadata`.
- **Raw source-snippet fixtures** at `tests/fixtures/discovery_dotnet_vsto/` (`.txt` suffix
  so no tooling treats them as real C#/XML; exempt from the 500-line limit), each with named
  detection cases and false-positive traps: `csharp_declarations.cs.txt` (all namespace
  forms, all type kinds, partial/generic/nested types, attributes, `// namespace Fake` and
  `"class InString"` traps); `csharp_events.cs.txt` (event/delegate declarations; `+=`/`-=`
  lambda, method group, `new EventHandler`; arithmetic `total += 3` trap;
  verbatim/interpolated string traps); `ribbon_customui.xml.txt` (2006 and 2009 customUI);
  `vsto_ribbon.cs.txt` (`IRibbonExtensibility`, `GetCustomUI`, designer usage);
  `com_interop.cs.txt` (interop attributes, `Marshal.*`, `GetTypeFromProgID`, interop using
  with a generic Office app name as data); `project_com_reference.xmlproj.txt`
  (`<COMReference>`, `EmbedInteropTypes`, interop assembly `Include`). Consumer identifiers
  must not appear even in fixtures.
- **Scenario matrix:** per-pattern positive/negative parametrized tests (pure); stripper unit
  tests (comments, verbatim/interpolated strings, preserved line numbers); include/exclude
  routing; id slug determinism and conformance; `TextParseResult` narrowing failure;
  unreachable `legacy_source.root` -> `AnalyzerError`; CLI 0/1/2 for both entry points
  (patching the profile loader at its import location in `stack_cli`, per python.md);
  end-to-end runs over `mem_fs_path` producing schema-valid instances per analyzer; the
  domain-neutrality contract test with the feature-scoped lists.
- **Coverage:** line >= 85%, branch >= 75%; no exclusion is added for the new modules.
  `hypothesis` is not a dev dependency, so property-based tests would require a new dev
  dependency needing explicit approval; parametrized boundary matrices are the substitute
  (consistent with #360/#363).
- Feature QA evidence is written under
  `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/evidence/<kind>/`
  per the evidence-and-timestamp-conventions skill.

## Acceptance Criteria

- [ ] `DotnetInventoryAnalyzer` implements the #363 `Analyzer` protocol
      (`name = "dotnet-inventory"`) and enumerates namespace declarations (block and
      file-scoped, with `metadata.declaration_form`) and type declarations (class/struct/
      interface/enum/record/record struct, with normalized `metadata.symbol_kind`) over C#
      source, one file-and-line-anchored detection per match.
- [ ] The .NET/C# analyzer detects event declarations, delegate type declarations, and
      `+=`/`-=` handler subscriptions; subscription detections apply the documented
      literal-rejection filter and carry `metadata.confidence = "heuristic"`.
- [ ] `VstoOfficeAnalyzer` implements the #363 `Analyzer` protocol (`name = "vsto-office"`)
      and detects Ribbon-XML customization: 2006/2009 customUI namespace URIs and the
      `<customUI` root element in XML files; `IRibbonExtensibility`, `GetCustomUI`, and
      `Microsoft.Office.Tools.Ribbon` in C# files.
- [ ] The VSTO/Office analyzer detects COM-interop patterns: `[ComImport]`, `[ComVisible]`,
      `[Guid]` (captured to `metadata.com_guid`), `[InterfaceType]`, `[DispId]`, `Marshal.*`
      calls (member captured to `metadata.symbol`), `Type.GetTypeFromProgID`, Office interop
      usings (application name captured as data to `metadata.interop_target`, never branched
      on), and project-file `COMReference`/`EmbedInteropTypes`/interop assembly references.
- [ ] Both analyzers read the consumer repository at `profile.legacy_source.root`, honor
      `include`/`exclude` globs with `fnmatch` over consumer-relative POSIX paths, and fail
      fast with `AnalyzerError` on an unreachable root, distinct from `DomainProfileError`.
- [ ] The parsing-strategy decision (regex/plain-text, Python stdlib only, no
      AST/Roslyn/tree-sitter) is recorded and justified in this spec's Specification Decision
      section, including the stated regex limitations and the heuristic claim-scoping rule,
      citing the research artifact.
- [ ] A shared pure comment/string stripper in `source_text.py` blanks non-code spans while
      preserving line and column numbers; all C# detection patterns run over stripped text;
      Ribbon/project XML is scanned unstripped.
- [ ] `parse` acquires file text behind the `AnalyzerFileSystem` seam and returns a frozen
      `TextParseResult` of ordered `(path, text)` pairs; `classify` isinstance-narrows and
      raises `AnalyzerError` on a plain `ParseResult`; no #363 change is required, and the
      ParseResult-payload reconciliation with #363 is recorded as an open coordination item.
- [ ] Every emitted artifact is an Evidence Reference v1 instance with `kind` `"file"`,
      `location` a consumer-relative POSIX path (no line number appended), `id` matching
      `^[a-z0-9][a-z0-9._-]*$` and deterministic across runs, a scheme-less relative
      `$schema` path (no drive letter, no leading `/`) computed by the reused #363 emitter,
      `schema_version` matching `^1\.\d+\.\d+$`, and all detection specifics exclusively
      inside `metadata`; instances validate against the v1 schema via `jsonschema` in tests.
- [ ] `metadata.detection_kind` values are drawn only from the twelve-value normative
      vocabulary enumerated in the Evidence Reference emission contract of this spec.
- [ ] Console scripts `dev.discovery.dotnet` and `dev.discovery.vsto` exist as two
      `[tool.poetry.scripts]` lines targeting
      `scripts.dev_tools.discovery.analyzer.stack_cli:main_dotnet` / `:main_vsto`, expose the
      argparse surface (positional `profile` defaulting to `DEFAULT_PROFILE_FILENAME`,
      `--output-dir`, `--json`), and return exit codes `0`/`1`/`2` identical to
      `dev.discovery.inventory`.
- [ ] Production modules contain no consumer identifiers (`taskmaster`, `tmw`) and no
      consumer-specific or per-Office-application hardcoding, verified by a domain-neutrality
      contract test whose banned list is feature-scoped: generic stack literals (`csharp`,
      `vsto`, `Microsoft.Office.*`, `.csproj`, `.sln`, customUI namespace URIs) are permitted
      as pattern data.
- [ ] Tests satisfy repository quality-tier policy: pytest, line coverage >= 85%, branch
      coverage >= 75%, test tree mirroring production at
      `tests/scripts/dev_tools/discovery/analyzer/`, no temporary files (inline strings and
      the in-memory `mem_fs_path` fixture), `captured_at` from an injected clock with
      byte-identical repeat emission, raw C#/VSTO text-snippet fixtures with false-positive
      traps, and parametrized matrices in place of property-based tests (`hypothesis` is not
      a dev dependency).
- [ ] No production or test file exceeds 500 lines (raw text fixtures exempt), no new runtime
      dependency is added, and no coverage exclusion is added for the new analyzer modules.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit and integration as applicable)
- [ ] Edge cases and error handling covered by tests (false-positive traps, narrowing
      failure, unreachable root, malformed profile, usage error)
- [ ] Docs updated (this spec, user-story, and feature-folder links)
- [ ] Domain-neutrality contract test present and passing with the feature-scoped list
- [ ] Toolchain pass (Black -> Ruff -> Pyright strict -> pytest with coverage) in one clean
      pass

## Seeded Test Conditions (from potential)

- [ ] Unit coverage: namespace/type enumeration; event-subscription detection; Ribbon-XML
      detection; COM-interop detection; include/exclude glob handling; Evidence Reference
      emission conformance; CLI success and error exit codes.
- [ ] Integration scenarios: each analyzer end-to-end from a domain profile to a
      schema-conforming collection of artifacts over an in-memory fixture tree.
- [ ] CLI/API examples: `dev.discovery.dotnet` / `dev.discovery.vsto` load-and-emit;
      non-zero exit on malformed profile or unreachable source root; `--json` run summary.
