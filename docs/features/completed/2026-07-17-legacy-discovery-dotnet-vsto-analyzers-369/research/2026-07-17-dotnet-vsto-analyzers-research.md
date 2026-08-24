# legacy-discovery-dotnet-vsto-analyzers (#369) — Research

- **Date:** 2026-07-17
- **Feature:** legacy-discovery-dotnet-vsto-analyzers (issue #369, epic child #9014, Wave 2, complexity C4)
- **Depends on:** legacy-discovery-analyzer-framework (#363), which depends on config contract (#360) and schemas (#359)
- **Researcher:** task-researcher agent
- **Status:** Complete

## Executive Summary

Two concrete stack-specific analyzers — a .NET/C# inventory analyzer and a VSTO/Office
analyzer — plug into the #363 `Analyzer` protocol (`parse -> classify -> map -> emit`) and
emit Evidence Reference v1 instances per detection.

Key recommendations:

1. **Parsing strategy: regex / plain-text, Python stdlib only** (`pathlib`, `re`, `fnmatch`,
   `json`, `hashlib`). No AST, Roslyn, or tree-sitter dependency. This is the epic's C4
   specification decision; the case is built in Section Q1 and includes an honest statement
   of regex limitations and a claim-scoping rule ("heuristic detection, not a compiler").
2. **Two distinct `Analyzer` implementations** (`DotnetInventoryAnalyzer`,
   `VstoOfficeAnalyzer`) in sibling modules `dotnet_inventory.py` and `vsto_office.py`
   under `scripts/dev_tools/discovery/analyzer/`, sharing a pure text-scanning helper
   module and reusing the #363 emitter, models, pipeline, and filesystem seam.
3. **Evidence mapping:** every detection maps to `kind: "file"`; all detection-specific
   data (`detection_kind`, `symbol`, `symbol_kind`, `line`) lives exclusively inside the
   free-form `metadata` object, which is the only extension point permitted by the
   schema's top-level `additionalProperties: false`.
4. **CLI:** two console scripts, `dev.discovery.dotnet` and `dev.discovery.vsto`, both
   mapping to one shared CLI module (`stack_cli.py`) with two entry functions, mirroring
   the `dev.discovery.inventory` argparse surface and the 0/1/2 exit-code contract.
5. **One cross-feature contract issue to reconcile with #363:** the framework's
   `ParseResult` is defined as a tuple of paths only; these analyzers need file text at
   the parse stage. Recommended resolution: frozen-dataclass subtypes carrying
   `(path, text)` pairs, with isinstance narrowing in `classify` (details in Q5 and Open
   Questions).

---

## Q1. Parsing Strategy (Specification Decision, C4)

**Recommendation: regex / plain-text scanning using the Python standard library only.
No new runtime dependency. No AST / Roslyn / tree-sitter / grammar library.**

### Verified findings

(a) **No AST/parser dependency exists in `pyproject.toml`.** Verified by reading
`pyproject.toml` `[tool.poetry.dependencies]` (lines 16–34) and
`[tool.poetry.group.dev.dependencies]` (lines 36–45): the runtime set is
typer/PyYAML/numpy/click/pandas/scikit-learn/scipy/requests/beautifulsoup4/lxml/pyarrow/
pdfplumber plus optional ML extras; the dev set is pytest/pytest-cov/black/ruff/pyright/
pyperclip/jsonschema/type stubs. A ripgrep for
`tree.sitter|roslyn|libcst|antlr|pygments|parso` over `pyproject.toml` returns no matches.
There is no C#/.NET toolchain in the repository; the repository contains no C# source of
its own (confirmed in the #369 issue and the #363 spec "Consumer-repository reality"
constraint).

(b) **Repository precedent is uniformly regex/plain-text or external-tool delegation.**
- `scripts/dev_tools/codex_native_converter/classifier.py` classifies artifacts entirely
  by path shape (`path_text.startswith(...)`) and compiled `re` patterns over file text
  (`_REPO_WIDE_APPLY_TO_PATTERN`, `_PROMPT_ENFORCEMENT_PATTERN`, etc.). No language
  parser.
- `scripts/dev_tools/codex_native_converter/parser.py` performs section-level "parsing"
  of Markdown with a heading regex (`_HEADING_PATTERN`) and hand-rolled frontmatter
  splitting — parsing-shaped work done with `re` and line iteration, never a grammar.
- Where the repository needs real language analysis (PowerShell), it does not parse the
  language in Python: `scripts/dev_tools/fix_all_branches.py` shells out via `pwsh` to
  PSScriptAnalyzer ("Running PowerShell linting (PSScriptAnalyzer)...", line 318). The
  analogous move for C# would be shelling out to Roslyn, which requires a .NET SDK the
  repository does not have and cannot assume on consumer analysis hosts.
- The #363 framework spec records the identical decision for the framework itself
  (spec.md `## Specification Decision: Parsing Strategy`, lines 68–94), explicitly
  reserving "richer text scanning" — not AST parsing — as the thing #9014 plugs into the
  `parse` stage.

(c) **Domain neutrality forbids an embedded grammar.** The epic invariant (epic.md
Non-Goals; #363 spec Constraints) is that the core framework is domain- and
language-neutral, with specificity supplied at runtime by the domain profile. A vendored
C# grammar (tree-sitter-c-sharp) or a Roslyn bridge would hard-couple one language's
compilation model into the analyzer package and its build/test environment. The
stack-specific knowledge this feature is chartered to hold is a *pattern catalog*
(Sections Q2/Q3), which is data-like, inspectable, and testable as pure functions — not
a grammar runtime.

(d) **Dependency policy.** `.claude/rules/python.md` `## Prohibited Behaviors` lists
"Adding new dependencies without explicit user instruction." `tree_sitter` +
`tree-sitter-c-sharp` would be two new runtime dependencies with native-extension build
requirements (wheels per platform; the repo supports Python >=3.10 on Windows dev hosts
and CI runners). Roslyn is not consumable from Python at all without a .NET process
boundary. Either path requires explicit approval and materially expands the supported
surface.

(e) **Simplicity-first.** `.claude/rules/general-code-change.md` design priority #1. The
acceptance criteria require *inventory and detection* — enumerate namespaces/types,
detect event subscriptions, Ribbon XML, COM interop — not semantic analysis (no symbol
resolution, no overload binding, no project-graph evaluation). Line-oriented regex over
comment/string-stripped text answers every acceptance criterion. An AST would add
fidelity the artifacts do not require, at the cost of a native dependency, a grammar
version treadmill (C# 11 raw strings, C# 12 primary constructors), and a much larger
test matrix.

### Honest limitations of regex parsing of C#

The spec must state these so expectations are correct. A regex scanner:

1. **Comments and string literals** can contain declaration-shaped text
   (`// namespace Fake`, `var s = "class Foo";`). Mitigated (not eliminated) by a
   pre-scan stripper — see mitigation below.
2. **Verbatim strings** (`@"..."` with `""` escaping), **interpolated strings**
   (`$"{expr}"`, nested braces, interpolated-verbatim `$@"..."`), and **raw string
   literals** (C# 11 `"""..."""`) defeat naive quote tracking. The stripper handles the
   common forms; pathological nesting can leak text into the scan.
3. **Preprocessor directives** (`#if !DEBUG ... #endif`) mean detected symbols may be
   conditionally compiled out. The scanner reports what is textually present; it does not
   evaluate symbols.
4. **Generics** — `class Cache<TKey, TValue> where TKey : notnull` — the scanner captures
   the base identifier and the raw generic arity text; it does not model constraints.
5. **Nested and file-scoped namespaces** — a nested block namespace
   (`namespace A { namespace B {` ) is detected as two independent namespace lines; the
   scanner does not compute the composed `A.B` scope for members, and it does not track
   which namespace a type belongs to across brace depth. Symbol records are
   file-and-line anchored, not scope-resolved.
6. **Partial types** produce one detection per declaration site (correct for evidence;
   the count of detections is not the count of distinct types).
7. **`+=` ambiguity** — arithmetic compound assignment is textually identical to event
   subscription; see Q2 mitigation.

**Claim-scoping rule for the spec:** the analyzers are *heuristic evidence scanners*, not
compilers. Every emitted artifact records observed textual patterns with file/line
anchors; the artifacts claim "this pattern occurs at this location," never "this program
declares exactly these symbols." Descriptions and docs must use detection language
("detected", "pattern match"), and the metadata should carry the analyzer name and
`detection_kind` so downstream consumers (#9003 validators, #9010 reports) can treat the
records as evidence, not as a symbol table.

**Mitigation (comment/string stripping):** recommend a small pure helper (shared module,
Q5) that performs a single line-by-line character scan tracking four states — code,
`//` line comment, `/* */` block comment, string literal (with `"`, `@"`, `$"` and `'`
forms) — and returns the text with non-code spans blanked (replaced by spaces so line and
column numbers are preserved). This is ~100 lines of stdlib code, deterministic, and
property-testable. It is more accurate than regex-only stripping (which cannot pair
quotes across escaped content) and vastly cheaper than a grammar. Raw strings (`"""`)
and deeply nested interpolation are documented as best-effort. All detection regexes run
over the stripped text.

### Rejected alternatives (brief)

- **tree-sitter + tree-sitter-c-sharp:** accurate CST, but two new native runtime
  dependencies requiring explicit approval, per-platform wheels, grammar-version drift,
  and a language runtime embedded in a domain-neutral framework. Rejected on (c), (d), (e).
- **Roslyn via a .NET subprocess:** authoritative semantics, but requires a .NET SDK on
  every analysis host, crosses a process/serialization boundary, and adds a second
  language toolchain to a Python-only feature. No repository precedent for requiring a
  .NET toolchain. Rejected.
- **Pygments tokenization:** lighter than a grammar but still a new dependency, and its
  token stream does not give declarations any more directly than regex over stripped
  text. Rejected.

---

## Q2. C# Inventory Detection Patterns (.NET/C# analyzer)

All patterns below are research recommendations (final regexes are implementation
concerns); they run over comment/string-stripped text with `re.MULTILINE`. Identifier
atom used throughout: `@?[A-Za-z_]\w*` (covers `@`-verbatim identifiers; full Unicode
identifiers are out of heuristic scope and documented as such).

### Namespace declarations

- **Block form** (`namespace A.B {` — brace may be on the same or next line) and
  **file-scoped form** (`namespace A.B;`, C# 10) in one pattern:

  ```
  (?m)^[ \t]*namespace[ \t]+(?P<name>@?[A-Za-z_]\w*(?:[ \t]*\.[ \t]*@?[A-Za-z_]\w*)*)[ \t]*(?P<form>[;{]|$)
  ```

  `form` distinguishes `;` (file-scoped) from `{`/end-of-line (block). Record
  `metadata.symbol = name`, `metadata.symbol_kind = "namespace"`,
  `metadata.declaration_form = "file_scoped" | "block"`.

### Type declarations

- One pattern for `class | struct | interface | enum | record | record class | record struct`,
  tolerating attributes-on-previous-lines, modifier stacks, generics, and nesting
  (nesting is free: the pattern is line-anchored anywhere in the file):

  ```
  (?m)^[ \t]*(?:\[[^\]\r\n]*\][ \t]*)*
      (?:(?:public|internal|protected|private|static|sealed|abstract|partial|readonly|unsafe|new|file)[ \t]+)*
      (?P<kw>class|struct|interface|enum|record(?:[ \t]+(?:class|struct))?)[ \t]+
      (?P<name>@?[A-Za-z_]\w*)
      (?P<generics>[ \t]*<[^<>{;=]{0,200}>)?
  ```

  (shown wrapped; compiled with `re.VERBOSE`). Record `metadata.symbol_kind` normalized
  from `kw` (`record class` -> `record`, `record struct` -> `record_struct`), and
  `metadata.generic = true/false`.
- **False-positive notes:** `record` is a contextual keyword; the pattern requires
  `record` + identifier at declaration position, so `var record = ...` (identifier
  followed by `=`) does not match. Positional records (`public record Person(string
  Name);`) match. A local variable line like `file class = ...` is not legal C#, so
  modifier-prefix collisions are negligible.

### Events and delegates

Three complementary detections, each a distinct `metadata.detection_kind`:

- **Event declaration** (field-like and custom-accessor):

  ```
  (?m)^[ \t]*(?:(?:public|internal|protected|private|static|virtual|override|sealed|abstract|new)[ \t]+)*
      event[ \t]+(?P<type>@?[A-Za-z_][\w.<>,\[\]? \t]*?)[ \t]+(?P<name>@?[A-Za-z_]\w*)[ \t]*(?:[;={]|$)
  ```

- **Delegate type declaration:**

  ```
  (?m)^[ \t]*(?:(?:public|internal|protected|private)[ \t]+)*
      delegate[ \t]+[\w.<>,\[\]? \t]+?[ \t](?P<name>@?[A-Za-z_]\w*)[ \t]*\(
  ```

- **Handler subscription / unsubscription** (`+=` / `-=`):

  ```
  (?P<target>@?[A-Za-z_][\w.\[\]()]*)[ \t]*(?P<op>\+=|-=)[ \t]*(?P<handler>[^;\r\n]+)
  ```

  **This is the highest false-positive-risk pattern** (`total += 3` is textually
  identical). Pragmatic mitigation consistent with a heuristic scanner:
  - reject matches whose `handler` begins with a numeric, string, or char literal
    (negative lookahead `(?!["'\d(])` refined to allow `(s, e) =>` lambdas — i.e.,
    accept when the handler contains `=>`, `new `, `delegate`, or is a bare
    dotted-identifier method group);
  - record surviving matches as `detection_kind = "event_subscription"` with
    `metadata.confidence = "heuristic"` so downstream consumers know the class of claim.
  Do not attempt type resolution; document the residual risk (a method-group-looking
  arithmetic accumulation such as `x += y.Count` survives the filter) in the spec.

### False-positive mitigation summary (Q2/Q3 shared)

1. Strip comments/strings first (state-machine helper, Q1 mitigation).
2. Line-anchor declaration patterns (`^\s*` + modifier stacks) so mid-expression text
   rarely matches.
3. Tag every record with `detection_kind` and heuristic confidence semantics in the spec.
4. Never emit aggregate claims (counts of "all types in the project"); emit one anchored
   evidence record per match.

---

## Q3. VSTO/Office Detection Patterns (VSTO/Office analyzer)

These detections span `.cs` files, `.xml` resource files, and project files
(`*.csproj`/`*.vbproj`). File routing: run XML patterns on files matching profile
include globs with `.xml` suffix; run C# patterns on `.cs`; run project-file patterns on
`*proj` XML. Stack literals (`customui`, `ComImport`, `Microsoft.Office.Interop`) are
legitimate here — this feature is stack-specific by charter; the neutrality invariant is
*consumer*-neutrality (no TaskMaster/TMW/consumer identifiers), see Open Questions.

### Ribbon-XML customization

- **customUI namespace URIs** (in `.xml`, also occasionally inline in `.cs` string
  resources — note stripped-text caveat; for ribbon detection the XML files are the
  primary signal and are scanned unstripped):

  ```
  schemas\.microsoft\.com/office/(?P<year>2006/01|2009/07)/customui
  ```

  Detects both the 2006 (`customUI`) and 2009 (`customUI14`) schemas. Record
  `metadata.detection_kind = "ribbon_xml"`, `metadata.customui_schema = <matched URI>`.
- **`<customUI` root element** as a corroborating pattern: `(?i)<\s*customUI\b`.
- **`IRibbonExtensibility` implementation** (in `.cs`):
  `\bIRibbonExtensibility\b` (matches both bare and
  `Microsoft.Office.Core.IRibbonExtensibility`-qualified usage).
- **`GetCustomUI` override** (in `.cs`): `\bGetCustomUI\s*\(` — the single method of
  `IRibbonExtensibility`; its presence is the strongest "custom ribbon at runtime"
  signal.
- **Ribbon designer model** (in `.cs`): `\bMicrosoft\.Office\.Tools\.Ribbon\b` — VSTO
  designer-generated ribbons (`RibbonBase`) do not go through `GetCustomUI`, so this
  pattern is required for coverage of designer-based customization.

### COM-interop patterns

- **Interop attributes** (in `.cs`, stripped text):
  - `\[\s*ComImport\b`
  - `\[\s*ComVisible\s*\(`
  - `\[\s*Guid\s*\(\s*"(?P<guid>[0-9A-Fa-f]{8}(-[0-9A-Fa-f]{4}){3}-[0-9A-Fa-f]{12})"` —
    capture the GUID into `metadata.com_guid`.
  - `\[\s*InterfaceType\s*\(`, `\[\s*DispId\s*\(`
- **Marshal calls:** `\bMarshal\.(?P<member>\w+)\s*\(` — capture the member
  (`ReleaseComObject`, `GetActiveObject`, `FinalReleaseComObject`, ...) into
  `metadata.symbol`; do not enumerate a fixed member list (stay generic).
- **ProgID activation:** `\bType\.GetTypeFromProgID\s*\(` and
  `\bActivator\.CreateInstance\s*\(` when adjacent to a `GetTypeFromProgID` result is
  out of heuristic scope — detect the `GetTypeFromProgID` call only.
- **Office interop usings** (in `.cs`):

  ```
  (?m)^[ \t]*using[ \t]+(?:static[ \t]+)?(?:\w+[ \t]*=[ \t]*)?(?P<ns>Microsoft\.Office\.Interop\.(?P<app>\w+))
  ```

  The Office application name (`app`) is *captured as data* into
  `metadata.interop_target`; it is never hardcoded or special-cased. This is the
  concrete mechanism that keeps the analyzer consumer-neutral while still being
  Office-stack-aware.
- **Project-file COM references** (in `*proj` XML, unstripped):
  - `(?i)<\s*COMReference\b` (capture the `Include=` attribute value when present into
    `metadata.symbol`).
  - `(?i)<\s*EmbedInteropTypes\s*>` and
    `(?i)Include\s*=\s*"(?P<asm>Microsoft\.Office\.Interop\.[\w.]+)"` for interop
    assembly references.

Note the #363 framework spec bans `.csproj`/`.sln` literals *in the framework's own
production code* (spec lines 291–296); that ban scopes to #363's language-neutral
modules. Stack-specific literals are precisely this feature's charter, and the #369
domain-neutrality contract test must be worded accordingly (see Open Questions).

---

## Q4. Evidence Reference v1 Mapping

Schema facts (from #359 spec, `### 1. Evidence Reference`): required `id`, `kind` (enum
`file | log | trace | test_run | screenshot | recording | document | dataset | url |
other`), `location`, `captured_at`, `description`; optional `content_hash
{algorithm, value}`, `tool`, `metadata`; top-level `additionalProperties: false`; every
instance also requires `$schema` and `schema_version` (suite-wide conventions, #359 spec
`## Per-Schema Field Design`).

### Recommended mapping

- **`kind`: `"file"` for every detection produced by both analyzers.** Each detection is
  anchored to a source file in the consumer repository; `file` is semantically accurate
  and consistent with the framework inventory analyzer, which emits `kind: "file"` for
  every enumerated unit (#363 spec, artifact emission contract). Reserve `"other"` for a
  future detection that genuinely has no file anchor; none of this feature's detections
  qualifies. The enum has no `namespace`/`type`/`event`/`ribbon`/`com` values and, per
  `additionalProperties: false`, no new top-level field may carry that distinction —
  therefore **all detection specifics go in `metadata`**:

  ```json
  "metadata": {
    "analyzer": "dotnet-inventory",
    "detection_kind": "namespace | type | event_declaration | delegate | event_subscription | ribbon_xml | ribbon_extensibility | com_attribute | marshal_call | progid_activation | interop_using | com_reference",
    "symbol": "The.Captured.Identifier",
    "symbol_kind": "namespace | class | struct | interface | enum | record | record_struct | event | delegate | method | element | assembly",
    "line": 42,
    "confidence": "heuristic"
  }
  ```

  This respects `additionalProperties: false` because `metadata` is the schema's single
  sanctioned free-form extension point ("`metadata` object (`type: object`, additional
  properties allowed) as the sanctioned extension point", #359 spec suite-wide
  conventions). Exact key names are an implementation choice; the invariant is:
  *nothing detection-specific outside `metadata`*.

- **`location`:** the consumer-relative POSIX path of the source file (relative to
  `profile.legacy_source.root`), identical to the framework convention (#363 spec:
  "expressed in the consumer repository's own terms, not the analyzer host's absolute
  path"). Line information goes in `metadata.line`, not appended to `location`, keeping
  `location` a plain path that downstream tooling can resolve.

- **`id`:** must match `^[a-z0-9][a-z0-9._-]*$` (#359 shared identifier grammar).
  Recommended slug scheme:
  `"<analyzer-prefix>-<detection_kind>-<slugified-symbol-or-path>-<hash8>"`, e.g.
  `dotnet-type-orderprocessor-3fa9c2d1`, where `hash8` is the first 8 hex chars of
  `sha256(location + ":" + line + ":" + detection_kind + ":" + symbol)`. The slugifier
  lowercases and replaces every character outside `[a-z0-9._-]` with `-` and strips a
  leading non-alphanumeric. The hash suffix guarantees uniqueness across identical
  symbol names in different files/lines while keeping ids stable across runs
  (deterministic inputs only — no clock, no counter).

- **`$schema`:** a scheme-less relative POSIX path from the emitted instance file to
  `schemas/discovery/v1/evidence-reference.schema.json`, computed exactly as #363's
  emitter does (`os.path.relpath(...).replace(os.sep, "/")`); never a drive letter,
  never a leading `/` (#359: `urlparse("C:/...")` treats the drive letter as a URI
  scheme and `validate_json.py::_load_schema` rejects it). **Reuse the #363 emitter**
  rather than reimplementing this Windows-sensitive computation (Open Questions).

- **`schema_version`:** `"1.0.0"` (pattern `^1\.\d+\.\d+$`).
- **`captured_at`:** from the injected clock (framework `AnalyzerContext.captured_at`).
- **`description`:** a generic sentence naming the detection kind, no consumer
  identifiers, e.g. "C# type declaration detected by the .NET inventory analyzer." The
  detected symbol itself belongs in `metadata.symbol`, not in `description`, to keep the
  neutrality contract test simple (descriptions are static strings).
- **`content_hash`:** optional; recommend `{algorithm: "sha256", value: <hex of file
  bytes>}` per source file, matching the framework recommendation (stdlib `hashlib`).
- **`tool`:** the invoking console-script name (`dev.discovery.dotnet` /
  `dev.discovery.vsto`).

**Granularity:** one Evidence Reference instance per *detection* (not per file),
consistent with the framework's adopted "N conforming instances, not one aggregate"
pattern (#363 spec, artifact emission contract and its documented cross-feature
assumption). A file with twelve type declarations yields twelve instances plus the
inventory analyzer's own file record; ids are disambiguated by the hash suffix.

---

## Q5. Framework Plug-in Mechanics and Module Layout

### How a concrete analyzer implements the four stages (#363 contract)

Per the #363 spec (`### Framework abstraction contract`): implement the
`Analyzer` protocol (structural — no registration, no base class) with `name: str` and
`parse/classify/map/emit`; the CLI constructs the concrete analyzer and hands it to
`run_analyzer(analyzer, ctx, fs)`, which threads
`ParseResult -> ClassifyResult -> tuple[EvidenceRecord, ...] -> written paths` and
returns `AnalyzerRunResult`. No global registry (explicitly prohibited by #363 citing
`.claude/rules/python.md`).

**Two distinct `Analyzer` implementations — recommended.** The .NET/C# analyzer and the
VSTO/Office analyzer have different pattern catalogs, different file routing
(`.cs` vs `.cs`+`.xml`+`*proj`), different `name` values, and different CLI entry
points. One combined analyzer with a mode switch would couple both catalogs into one
module and complicate the 500-line budget. Two implementations also match the issue's
framing ("two concrete analyzers").

Stage responsibilities for these analyzers:

- **`parse`** — the I/O stage: walk the consumer tree behind the `AnalyzerFileSystem`
  seam, apply `include`/`exclude` (`fnmatch` over consumer-relative POSIX paths,
  identical semantics to the framework), select candidate files by suffix, and read each
  candidate's text via the seam (`read_text`-equivalent seam method). The #363 spec says
  "#9014 is expected to plug richer text scanning into its own analyzers' parse stage"
  (spec line 92–94). No temp files; in tests the seam is exercised through the in-memory
  `mem_fs_path` fixture (verified present in `tests/conftest.py`, line 146).
- **`classify`** — pure: run the detection catalog (Q2/Q3) over the stripped text and
  produce typed detection units. All regex/pattern logic lives here or in the shared
  pure helper so it is unit-testable with inline strings and no filesystem.
- **`map`** — pure: one `EvidenceRecord` per detection, applying the Q4 mapping
  (id slug, location, metadata payload).
- **`emit`** — reuse the #363 emitter (`emitter.py`): serialize deterministically
  (`sort_keys=True, indent=2`), compute the relative `$schema`, write via the seam.

### Contract friction to resolve: `ParseResult` shape

The #363 spec defines `ParseResult` as "the ordered tuple of consumer-relative POSIX
file paths from the walk" (spec line 173) — paths only, no content. These analyzers need
file *text* to flow from the I/O stage (`parse`) into the pure stage (`classify`)
without `classify` doing I/O. Options:

1. **(Recommended)** Subclass the frozen dataclass:
   `@dataclass(frozen=True, slots=True) class TextParseResult(ParseResult)` adding
   `file_texts: tuple[tuple[str, str], ...]` (path, stripped-or-raw text pairs).
   Returning a subtype from `parse` satisfies the protocol (covariant return);
   `classify` is typed to accept `ParseResult` and isinstance-narrows to
   `TextParseResult`, raising `AnalyzerError` otherwise (fail-fast). Zero change to
   #363. Both analyzers can share one `TextParseResult`.
2. Ask #363 to genericize `ParseResult` with an optional payload field — cleaner but
   requires a cross-feature contract change before #363 freezes.
3. Read text in `classify` — rejected: violates the framework's pure-classify design and
   the I/O-boundaries rule.

Raise option 2 with #363 at integration; design and plan against option 1 so this
feature is not blocked (recorded in Open Questions).

### Module placement (all new modules < 500 lines)

Under `scripts/dev_tools/discovery/analyzer/` (siblings to the framework's
`models.py`, `pipeline.py`, `inventory.py`, `emitter.py`, `cli.py`):

| Module | Contents |
|---|---|
| `dotnet_inventory.py` | `DotnetInventoryAnalyzer` (`name = "dotnet-inventory"`): file routing, C# pattern catalog application, map stage. |
| `vsto_office.py` | `VstoOfficeAnalyzer` (`name = "vsto-office"`): ribbon + COM catalogs, XML/`*proj` routing, map stage. |
| `source_text.py` | Shared pure helpers: the comment/string stripper (state machine), line-number utilities, id slugifier + hash. No I/O. |
| `stack_cli.py` | argparse surface + `main_dotnet(argv) -> int` and `main_vsto(argv) -> int` delegating to one shared `_run(analyzer_factory, argv)` helper. |

If either pattern-catalog module approaches 500 lines, split the raw pattern tables into
a `dotnet_patterns.py` / `vsto_patterns.py` sibling (data-only modules of compiled
regexes and detection-kind mappings) — this mirrors the #360 spec's sanctioned
"models move to a sibling module" tactic. Reuse (do not duplicate): `models.py`
value objects, `pipeline.py` protocols/runner/`RealAnalyzerFileSystem`, `emitter.py`,
`inventory.AnalyzerError`, and the #360 loader `domain_profile.py`.

---

## Q6. CLI Surface

**Recommendation: two console scripts, one shared CLI module.**

```toml
"dev.discovery.dotnet" = "scripts.dev_tools.discovery.analyzer.stack_cli:main_dotnet"
"dev.discovery.vsto"   = "scripts.dev_tools.discovery.analyzer.stack_cli:main_vsto"
```

Rationale:

- **Two scripts, not one script with a subcommand:** mirrors the epic's one-command-per-
  capability convention (`dev.discovery.profile` #360, `dev.discovery.inventory` #363 —
  both flat parsers; #360 explicitly notes "a single verb needs no subparsers"), and the
  MCP/VS Code layer (#9011) wraps discrete commands. Two analyzers are two capabilities.
- **One module, two entry functions:** exact repository precedent is `shell_qc` with
  `shell-qc-check`/`shell-qc-format`/`shell-qc-test` all mapping to different `main_*`
  functions in one module (`pyproject.toml` lines 51–53). This avoids duplicating the
  argparse wiring while keeping the console-script names distinct.
- Names use stack identifiers (`dotnet`, `vsto`), which is correct: the commands are
  stack-specific by charter; consumer-neutrality is preserved because no consumer name
  appears anywhere.

**Argparse surface — identical to `dev.discovery.inventory` (#363 CLI contract):**

- positional `profile` (path), `nargs="?"`, default `DEFAULT_PROFILE_FILENAME`
  (`"discovery-profile.yaml"`, imported from `scripts.dev_tools.discovery.domain_profile`).
- `--output-dir` (path) — override `profile.artifacts.root`.
- `--json` — machine-readable run summary (written paths / record count) to stdout.
- `main_*(argv) -> int`; `__main__`-style execution delegated the same way the framework
  does.

**Exit-code contract — identical to the framework:** `0` success; `1` domain/analyzer
error (`DomainProfileError` or `AnalyzerError`, caught only at the CLI boundary); `2`
argparse usage error (argparse default). If #363's `cli.py` factors its
profile-load/context-build/run/emit-summary flow into a reusable helper, `stack_cli.py`
should call it; otherwise propose that refactor to #363 at integration rather than
copying the flow (Open Questions).

---

## Q7. Testing and Fixtures

- **Test tree (mirrors production; colocation prohibited):**
  - `tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py`
  - `tests/scripts/dev_tools/discovery/analyzer/test_vsto_office.py`
  - `tests/scripts/dev_tools/discovery/analyzer/test_source_text.py`
  - `tests/scripts/dev_tools/discovery/analyzer/test_stack_cli.py`
  - a domain-neutrality contract test module (or parametrized additions to the
    framework's, if #363 ships one that can take a module list).
- **No temporary files.** Pure detection tests feed inline C#/XML strings to the
  classify-stage functions (no filesystem at all). End-to-end and CLI tests build the
  consumer tree and profile on the in-memory `mem_fs_path` fixture from
  `tests/conftest.py` (verified at line 146; it monkeypatches `pathlib.Path` methods).
  pytest `tmp_path` is not used.
- **Injected clock.** `captured_at` flows from `AnalyzerContext`, produced by the
  injected clock callable; tests pin a constant ISO-8601 value and assert byte-identical
  emission across two runs (determinism requirement from
  `.claude/rules/general-unit-test.md` and the #363 data-flow invariant).
- **Schema validation in tests.** `jsonschema` is already a dev dependency
  (`pyproject.toml` line 43, `^4.25.1`). Validate every emitted instance against
  `schemas/discovery/v1/evidence-reference.schema.json` with `Draft202012Validator`
  (offline; relative `$schema`). Assert: exact top-level key set, `id` pattern,
  `schema_version` pattern, `$schema` has no scheme/drive-letter/leading-slash, and all
  detection extras are under `metadata`.
- **Raw source-snippet fixtures.** Location:
  `tests/fixtures/discovery_dotnet_vsto/` (precedent: `tests/fixtures/atomic_executor/`,
  `tests/fixtures/discovery_schemas/` per the #359 spec — `tests/**` is outside governed
  globs, and reading committed fixtures is not temporary-file usage). Raw text fixtures
  are exempt from the 500-line limit (general-code-change file-size exceptions).
  Recommended corpus, each fixture exercising named detection cases plus named
  false-positive traps:
  - `csharp_declarations.cs.txt` — block + file-scoped + nested namespaces; class/
    struct/interface/enum/record/record struct; partial, generic, nested types;
    attributes; a `// namespace Fake` comment trap and a `"class InString"` literal trap.
  - `csharp_events.cs.txt` — event declarations (field-like and accessor form), delegate
    declaration, `+=`/`-=` subscriptions (lambda, method group, `new EventHandler`),
    arithmetic `total += 3` trap, verbatim/interpolated string traps.
  - `ribbon_customui.xml.txt` — 2006 and 2009 customUI documents.
  - `vsto_ribbon.cs.txt` — `IRibbonExtensibility`, `GetCustomUI`, designer
    `Microsoft.Office.Tools.Ribbon` usage.
  - `com_interop.cs.txt` — `[ComImport]`, `[Guid]`, `Marshal.*`, `GetTypeFromProgID`,
    interop `using` (a non-consumer-specific Office app name as data).
  - `project_com_reference.xmlproj.txt` — `<COMReference>`, `EmbedInteropTypes`, interop
    assembly `Include`.
  Use a `.txt` suffix (or load via a helper) so no repository tooling treats fixtures as
  real C#/XML sources. Consumer identifiers (TaskMaster/TMW) must not appear even in
  fixtures; invent generic names (`Contoso.Sample`-style is acceptable and conventional).
- **Scenario matrix:** per-pattern positive/negative parametrized tests (pure);
  stripper unit tests (comments, verbatim/interpolated strings, preserved line numbers);
  include/exclude routing; id slug determinism and pattern conformance; `TextParseResult`
  narrowing failure (`AnalyzerError`); unreachable `legacy_source.root` -> `AnalyzerError`;
  CLI 0/1/2 for both entry points (patch the profile loader at its import location in
  `stack_cli`, per python.md patch-location rule); end-to-end run over `mem_fs_path`
  producing schema-valid instances; domain-neutrality contract test (see Open Questions
  for the banned-substring nuance).
- **Coverage:** `scripts/dev_tools` is in `[tool.coverage.run] source` (pyproject line
  103); no exclusion may be added for the new modules. Line >= 85%, branch >= 75%
  uniformly. `stack_cli.py` and any `__main__` wiring stay minimal to keep the uncovered
  boundary small. Note: `hypothesis` is **not** a dev dependency (verified by grep), so
  property-based tests would require a new dev dependency needing explicit approval;
  neither #360 nor #363 requires them, and parametrized boundary matrices are the
  consistent substitute. Note also that `quality-tiers.yml` does not exist at the repo
  root in this worktree despite `.claude/rules/quality-tiers.md` referencing it; the
  uniform coverage thresholds apply regardless.

---

## Open Questions / Assumptions to Reconcile with Siblings

1. **`ParseResult` payload (with #363).** The framework's `ParseResult` carries paths
   only; these analyzers need text at classify time. Recommended: frozen-dataclass
   subtype `TextParseResult` with isinstance narrowing (Q5). Preferred long-term: #363
   adds an optional generic payload field before its contract freezes. Must be settled
   at integration-branch time.
2. **Emitter and CLI-flow reuse (with #363).** These analyzers must reuse
   `emitter.py` (especially the Windows-sensitive relative-`$schema` computation) and
   ideally a factored profile->context->run CLI helper from `cli.py`. If #363 ships the
   CLI flow inline in `main`, propose the small refactor there rather than duplicating.
3. **Evidence `kind` enum (with #359).** No `namespace`/`type`/`event`/`ribbon`/`com`
   values exist; this research adopts `kind: "file"` + `metadata.detection_kind`.
   Confirm with #359 that this is the intended use of `metadata` (the #359 spec's
   suite-wide conventions say yes: metadata is "the sanctioned extension point"). If
   #359 ever adds detection kinds, that is an additive v1 minor change, not a blocker.
4. **Domain-neutrality banned-substring list for this feature.** The #360/#363 contract
   tests ban `vsto` and `outlook` as substrings in production modules. This feature's
   modules are legitimately named `vsto_office.py` and legitimately contain
   `Microsoft.Office.*` pattern literals. The #369 contract test must therefore ban
   *consumer* identifiers (`taskmaster`, `tmw`) and *consumer-specific Office
   hardcoding* (e.g., a literal `Microsoft.Office.Interop.Outlook` special case) while
   permitting generic stack literals; the interop pattern must capture the Office app
   name as data (Q3), never branch on it. The spec should state this scoping explicitly
   so feature review does not misapply the framework's stricter list.
5. **Upstream sequencing.** `scripts/dev_tools/discovery/` (loader, framework modules)
   and `schemas/discovery/v1/` do not exist in this worktree yet; #360/#359/#363 merge
   into `epic/legacy-discovery-and-parity-integration` before this feature executes.
   All designs here target their documented contracts (same assumption posture as the
   #363 spec's "Upstream sequencing" constraint).
6. **Detection-kind vocabulary stability.** The `metadata.detection_kind` strings
   proposed in Q4 become a de-facto contract for #9010 reports and #9011 MCP exposure;
   the spec should enumerate them normatively so downstream features do not guess.

---

## Recommended Layout Summary (for the spec's Implementation Strategy)

```
scripts/dev_tools/discovery/analyzer/
  dotnet_inventory.py      # DotnetInventoryAnalyzer (name="dotnet-inventory")
  vsto_office.py           # VstoOfficeAnalyzer (name="vsto-office")
  source_text.py           # pure: stripper, slugifier, line utilities (shared)
  stack_cli.py             # argparse + main_dotnet / main_vsto
  (reused from #363: models.py, pipeline.py, emitter.py, inventory.AnalyzerError)

pyproject.toml [tool.poetry.scripts]:
  "dev.discovery.dotnet" = "scripts.dev_tools.discovery.analyzer.stack_cli:main_dotnet"
  "dev.discovery.vsto"   = "scripts.dev_tools.discovery.analyzer.stack_cli:main_vsto"

tests/scripts/dev_tools/discovery/analyzer/
  test_dotnet_inventory.py, test_vsto_office.py, test_source_text.py, test_stack_cli.py
tests/fixtures/discovery_dotnet_vsto/
  csharp_declarations.cs.txt, csharp_events.cs.txt, ribbon_customui.xml.txt,
  vsto_ribbon.cs.txt, com_interop.cs.txt, project_com_reference.xmlproj.txt
```

## Citations

- `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/spec.md` —
  Analyzer protocol, value objects, ParseResult definition (line 173), parse-stage
  reservation for #9014 (lines 92–94), emission contract, CLI contract, no-registry rule.
- `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/spec.md` —
  profile fields, `DEFAULT_PROFILE_FILENAME`, `DomainProfileError`, flat-parser precedent.
- `docs/features/active/2026-07-17-legacy-discovery-schemas-359/spec.md` — Evidence
  Reference field set and kind enum, `additionalProperties: false` + metadata extension
  point, id grammar, `$schema` relative-path rule and Windows drive-letter hazard,
  fixture-placement precedent.
- `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/issue.md` —
  scope, acceptance draft, constraints.
- `docs/features/epics/legacy-discovery-and-parity/epic.md` — #9014 wave/complexity,
  CLI-inside-owning-feature convention, non-goals.
- `pyproject.toml` — dependency inventory (no parser/AST libs; grep verified), dev
  `jsonschema` (line 43), no `hypothesis`, coverage source set (line 103), multi-entry
  console-script precedent (`shell-qc-*`, lines 51–53).
- `scripts/dev_tools/codex_native_converter/classifier.py`, `parser.py` — regex/plain-text
  analyzer precedent.
- `scripts/dev_tools/fix_all_branches.py` (line 318) — external-tool delegation precedent
  (PSScriptAnalyzer via pwsh) rather than in-Python language parsing.
- `tests/conftest.py` (line 146) — `mem_fs_path` in-memory filesystem fixture.
- `.claude/rules/python.md` — prohibited dependency additions, seams, patch-location rule.
- `.claude/rules/general-code-change.md` — simplicity-first, 500-line limit and raw-text
  fixture exemption, I/O boundaries.
- `.claude/rules/general-unit-test.md` — no temp files, determinism, coverage exclusion
  policy.
