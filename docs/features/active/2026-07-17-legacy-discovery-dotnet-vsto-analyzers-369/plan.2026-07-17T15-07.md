# 2026-07-17-legacy-discovery-dotnet-vsto-analyzers — Plan

- **Issue:** #369
- **Parent (optional):** Epic legacy-discovery-and-parity (child feature #9014, Wave 2, complexity C4)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17T15-07
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature
- **Depends on:** legacy-discovery-analyzer-framework (#363)

## Required References

- Repository tone/communication policy: `.github/copilot-instructions.md`
- General Coding Standards: `.github/instructions/general-code-change.instructions.md`
- General Unit Test Policy: `.github/instructions/general-unit-test.instructions.md`
- Python policies: `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`
- Rule mirrors: `.claude/rules/python.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`

All work must comply with these policies; this plan does not duplicate their content.

## Requirements Sources (full-feature)

- Spec (authoritative contract, 14 acceptance criteria, referenced below as S-AC1..S-AC14 in document order): `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/spec.md`
- User story (8 acceptance criteria, referenced below as U-AC1..U-AC8 in document order): `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/user-story.md`
- Issue: `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/issue.md` (Work Mode: full-feature)
- Research: `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/research/2026-07-17-dotnet-vsto-analyzers-research.md`
- Upstream framework contract (#363): `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/spec.md`

## Path Conventions

- `<FEATURE>` = `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369`
- All evidence artifacts produced by this plan MUST resolve under `<FEATURE>/evidence/<kind>/` (`baseline`, `qa-gates`, `regression-testing`, `other`). No `artifacts/` evidence path is permitted (non-overridable per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`).
- `<ts>` = the ISO-8601 `yyyy-MM-ddTHH-mm` timestamp captured at execution time of the task that writes the artifact.
- Production modules: `scripts/dev_tools/discovery/analyzer/` (siblings to the #363 framework modules).
- Test tree (mirrored; colocation prohibited): `tests/scripts/dev_tools/discovery/analyzer/`.
- Raw fixtures: `tests/fixtures/discovery_dotnet_vsto/` (raw text fixtures exempt from the 500-line limit).

## Sequencing Assumption (recorded, not a planning blocker)

This feature depends on legacy-discovery-analyzer-framework (#363), which depends on the config contract (#360) and schemas (#359). The framework production modules under `scripts/dev_tools/discovery/analyzer/` (`models.py`, `pipeline.py`, `inventory.py`, `emitter.py`, `cli.py`), the loader `scripts/dev_tools/discovery/domain_profile.py`, and `schemas/discovery/v1/evidence-reference.schema.json` do not exist in the current worktree; #363/#360/#359 merge into `epic/legacy-discovery-and-parity-integration` before this feature executes. All tasks below design against the documented #363/#360/#359 contracts; their presence at execution time is verified by [P0-T6] and recorded as a sequencing assumption, mirroring how the #363 spec treated #360/#359.

## Coordination Items (recorded per spec Contracts)

- `TextParseResult` is a frozen-dataclass subtype of the #363 `ParseResult` carrying `file_texts: tuple[tuple[str, str], ...]`; `classify` isinstance-narrows and raises `AnalyzerError` on a plain `ParseResult`. This requires no #363 change; the preferred long-term ParseResult-payload genericization is an open coordination item to raise with #363 at integration-branch time.
- If #363's `cli.py` ships a reusable profile-load/context-build/run/summary helper, `stack_cli.py` calls it; otherwise `stack_cli.py` implements a local `_run` helper and the refactor proposal to #363 is recorded as an open coordination item (no flow copying into duplicated modules).

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reads and Python Baseline Capture

- [x] [P0-T1] Read the repository policy files in the required order and record the read evidence artifact
  - Read, in this exact order: (1) `.github/copilot-instructions.md`, (2) `.github/instructions/general-code-change.instructions.md`, (3) `.github/instructions/general-unit-test.instructions.md`, (4) `.github/instructions/python-code-change.instructions.md`, (5) `.github/instructions/python-unit-test.instructions.md`, plus rule mirrors `.claude/rules/python.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-instructions-read.md` exists and contains `Timestamp:`, `Policy Order:` (the numbered order above), and the explicit list of files read.
- [x] [P0-T2] Capture the baseline Black formatting state
  - Command: `poetry run black --check .`
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-black.<ts>.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (pass/fail and file counts).
- [x] [P0-T3] Capture the baseline Ruff lint state
  - Command: `poetry run ruff check .`
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-ruff.<ts>.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (violation count or all-clear).
- [x] [P0-T4] Capture the baseline Pyright type-check state
  - Command: `poetry run pyright`
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-pyright.<ts>.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (error/warning counts).
- [x] [P0-T5] Capture the baseline pytest and coverage state
  - Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-pytest.<ts>.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with pass/fail counts and the numeric baseline line-coverage percent and branch-coverage percent headline values (no placeholders).
- [x] [P0-T6] Verify the upstream #363/#360/#359 modules are present and record the sequencing-assumption evidence artifact
  - Check existence of `scripts/dev_tools/discovery/analyzer/models.py`, `scripts/dev_tools/discovery/analyzer/pipeline.py`, `scripts/dev_tools/discovery/analyzer/inventory.py`, `scripts/dev_tools/discovery/analyzer/emitter.py`, `scripts/dev_tools/discovery/analyzer/cli.py`, `scripts/dev_tools/discovery/domain_profile.py`, and `schemas/discovery/v1/evidence-reference.schema.json`.
  - Acceptance: `<FEATURE>/evidence/other/phase0-sequencing-assumptions.<ts>.md` exists listing each checked path with a present/absent result and `Timestamp:`. If any path is absent, execution halts and reports BLOCKED-UPSTREAM (sequencing dependency on #363/#360/#359), and no Phase 1+ task starts.
  - Maps to: spec Constraints & Risks "Upstream sequencing".

### Phase 1 — Shared Pure Text Helpers (`source_text.py`)

- [x] [P1-T1] Create `scripts/dev_tools/discovery/analyzer/source_text.py` with the line-number-preserving C# comment/string stripper
  - Implement a pure single-pass line-by-line character-scan state machine tracking code, `//` line comment, `/* */` block comment, and string-literal states (`"`, `@"`, `$"`, `'` forms), returning text with non-code spans blanked by spaces so line and column numbers are preserved; raw strings (`"""`) and deeply nested interpolation documented as best-effort in the docstring; stdlib only; no I/O; module docstring uses heuristic detection language per the spec claim-scoping rule.
  - Acceptance: module exists, exposes a typed pure strip function, contains no filesystem/network access, and is under 500 lines.
  - Maps to: S-AC7, U-AC8.
- [x] [P1-T2] Add the id slugifier, hash-suffix id builder, and line utilities to `scripts/dev_tools/discovery/analyzer/source_text.py`
  - Implement `slugify` (lowercase, replace characters outside `[a-z0-9._-]` with `-`, strip leading non-alphanumeric) and an evidence-id builder producing `<analyzer-prefix>-<detection_kind>-<slugified-symbol-or-path>-<hash8>` where `hash8` is the first 8 hex characters of `sha256(location + ":" + line + ":" + detection_kind + ":" + symbol)` (stdlib `hashlib`); ids are pure functions of their inputs (no clock, no counter) and match `^[a-z0-9][a-z0-9._-]*$`.
  - Acceptance: functions exist with full type hints; module remains under 500 lines.
  - Maps to: S-AC9, U-AC4, U-AC6.
- [x] [P1-T3] Add the shared `TextParseResult` frozen dataclass to `scripts/dev_tools/discovery/analyzer/source_text.py`
  - Implement `@dataclass(frozen=True, slots=True) class TextParseResult(ParseResult)` (importing `ParseResult` from `scripts.dev_tools.discovery.analyzer.models`) adding `file_texts: tuple[tuple[str, str], ...]` of ordered `(consumer-relative POSIX path, text)` pairs, shared by both analyzers; document in the docstring that this is the recorded no-#363-change coordination approach and that ParseResult-payload genericization is an open coordination item with #363.
  - Acceptance: dataclass exists, is frozen, subclasses the #363 `ParseResult`, and the coordination note is present in the module.
  - Maps to: S-AC8.
- [x] [P1-T4] Create `tests/scripts/dev_tools/discovery/analyzer/test_source_text.py` with parametrized stripper tests
  - Cover with inline strings (no filesystem): `//` line comments, `/* */` block comments (single- and multi-line), plain/verbatim/interpolated/char string literals, declaration-shaped text inside comments and strings (`// namespace Fake`, `"class InString"`), and assertions that stripped output preserves line count and column offsets.
  - Acceptance: tests exist, follow Arrange-Act-Assert, use `pytest.mark.parametrize`, and pass; file under 500 lines.
  - Maps to: S-AC7, S-AC13, U-AC8.
- [x] [P1-T5] Add slug/id and `TextParseResult` tests to `tests/scripts/dev_tools/discovery/analyzer/test_source_text.py`
  - Assert id determinism across repeated calls, conformance to `^[a-z0-9][a-z0-9._-]*$`, uniqueness for identical symbols at different locations/lines, slugifier edge cases (uppercase, spaces, non-ASCII replacement, leading non-alphanumeric), and `TextParseResult` frozen immutability and field ordering.
  - Acceptance: tests exist and pass; file remains under 500 lines.
  - Maps to: S-AC8, S-AC9, S-AC13.

### Phase 2 — .NET/C# Inventory Analyzer (`dotnet_inventory.py`)

- [x] [P2-T1] Create the raw fixture `tests/fixtures/discovery_dotnet_vsto/csharp_declarations.cs.txt`
  - Include named cases: block, file-scoped, and nested namespaces; class/struct/interface/enum/record/record class/record struct; partial, generic, and nested types; attribute lines and modifier stacks; false-positive traps `// namespace Fake` and a `"class InString"` string literal. No consumer identifiers (use generic invented names).
  - Acceptance: fixture file exists with all named cases and traps present (raw text fixture; 500-line limit exempt).
  - Maps to: S-AC1, S-AC13, U-AC8.
- [x] [P2-T2] Create the raw fixture `tests/fixtures/discovery_dotnet_vsto/csharp_events.cs.txt`
  - Include named cases: field-like and custom-accessor event declarations; a delegate type declaration; `+=`/`-=` subscriptions using a lambda, a method group, and `new EventHandler`; false-positive traps: arithmetic `total += 3`, and verbatim/interpolated string traps containing `+=`-shaped text. No consumer identifiers.
  - Acceptance: fixture file exists with all named cases and traps present.
  - Maps to: S-AC2, S-AC13, U-AC8.
- [x] [P2-T3] Create `scripts/dev_tools/discovery/analyzer/dotnet_inventory.py` with the `DotnetInventoryAnalyzer` skeleton and `parse` stage
  - Implement the #363 `Analyzer` protocol structurally (no base class, no registry) with `name = "dotnet-inventory"`; `parse(ctx)` verifies the resolved `profile.legacy_source.root` exists and is a directory (raising the #363 `AnalyzerError` naming the unreachable path otherwise, distinct from `DomainProfileError`), walks the tree behind the `AnalyzerFileSystem` seam, applies `include`/`exclude` with stdlib `fnmatch` over consumer-relative POSIX paths (match at least one include or empty-include = all, and no exclude), selects `.cs` candidates in deterministic POSIX-sorted order, reads each candidate's text via the seam, and returns a `TextParseResult`.
  - Acceptance: module exists, imports only #363/#360 contract surfaces plus stdlib and `source_text`, and is under 500 lines.
  - Maps to: S-AC1, S-AC5, S-AC8, U-AC1, U-AC3.
- [x] [P2-T4] Implement the `classify` namespace and type detection catalog in `scripts/dev_tools/discovery/analyzer/dotnet_inventory.py`
  - `classify` accepts `ParseResult`, isinstance-narrows to `TextParseResult` (raising `AnalyzerError` otherwise), strips each file's text via `source_text`, and applies line-anchored patterns: namespace declarations in block and file-scoped forms (recording `declaration_form` of `"block"`/`"file_scoped"`), and type declarations for class/struct/interface/enum/record/record class/record struct tolerating attribute lines, modifier stacks, generics, and nesting, with `symbol_kind` normalized (`record class` -> `record`, `record struct` -> `record_struct`) and a `generic` arity flag; detections are pure typed units carrying path, 1-based line, detection kind, symbol, and detection-specific keys.
  - Acceptance: classify logic is pure (no I/O), narrowing failure raises `AnalyzerError`, and the module remains under 500 lines (if the catalog pushes it over, move pattern tables to a data-only `scripts/dev_tools/discovery/analyzer/dotnet_patterns.py` within this task and keep both files under 500 lines).
  - Maps to: S-AC1, S-AC8, U-AC1.
- [x] [P2-T5] Implement the `classify` event, delegate, and subscription detection catalog in `scripts/dev_tools/discovery/analyzer/dotnet_inventory.py`
  - Add distinct detection kinds for event declarations (field-like and custom-accessor forms), delegate type declarations, and `+=`/`-=` handler subscription/unsubscription; apply the documented literal-rejection filter (reject handlers beginning with a numeric, string, or char literal; accept handlers containing `=>`, `new `, `delegate`, or a bare dotted-identifier method group); tag every surviving subscription detection with `confidence = "heuristic"`; document the residual risk (for example `x += y.Count`) in the docstring; attempt no type resolution.
  - Acceptance: filter behavior and heuristic tagging implemented as specified; module (plus contingent `dotnet_patterns.py`) remains under 500 lines each.
  - Maps to: S-AC2, U-AC1, U-AC5.
- [x] [P2-T6] Implement the `map` and `emit` stages in `scripts/dev_tools/discovery/analyzer/dotnet_inventory.py`
  - `map` builds one #363 `EvidenceRecord` per detection with: `kind` `"file"`; `location` the consumer-relative POSIX path (no line number appended); `id` from the `source_text` id builder; `schema_version` `"1.0.0"`; `captured_at` from the injected clock via `AnalyzerContext`; a static generic `description` naming the detection kind with no consumer identifiers and using detection language; optional `content_hash` `{algorithm: "sha256", value: <hex of file bytes>}`; `tool` = `dev.discovery.dotnet`; and all detection specifics only inside `metadata` (`analyzer`, `detection_kind` from the twelve-value normative vocabulary, `symbol`, `symbol_kind`, `line`, `confidence`, `declaration_form`, `generic` as applicable). `emit` reuses the #363 emitter (deterministic serialization, scheme-less relative `$schema`).
  - Acceptance: no field outside the schema set is emitted except inside `metadata`; the #363 emitter is reused, not reimplemented; module under 500 lines.
  - Maps to: S-AC1, S-AC9, S-AC10, U-AC4.
- [x] [P2-T7] Create `tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py` with the parametrized namespace/type detection matrix
  - Feed inline C# strings and the `csharp_declarations.cs.txt` fixture text to the pure classify-stage functions (no filesystem): positive cases for every namespace form and type kind, `declaration_form` and normalized `symbol_kind` assertions, generic-arity flag, and negative cases proving the comment and string traps do not match.
  - Acceptance: tests exist, are parametrized, and pass; file under 500 lines.
  - Maps to: S-AC1, S-AC13, U-AC8.
- [x] [P2-T8] Add the parametrized event/delegate/subscription detection matrix to `tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py`
  - Cover event declarations (both forms), delegate declarations, `+=`/`-=` subscriptions (lambda, method group, `new EventHandler`), assert `confidence == "heuristic"` on every subscription detection, and negative cases proving the arithmetic `total += 3` trap and string traps are rejected.
  - Acceptance: tests exist and pass; file remains under 500 lines.
  - Maps to: S-AC2, S-AC13, U-AC5, U-AC8.
- [x] [P2-T9] Add narrowing-failure, unreachable-root, and include/exclude routing tests to `tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py`
  - Assert `classify` raises `AnalyzerError` on a plain `ParseResult`; assert `parse` raises `AnalyzerError` naming the path for an unreachable/missing `legacy_source.root` (distinct exception type from `DomainProfileError`); parametrize include-only, exclude-only, both, and empty-include (= all) glob cases over consumer-relative POSIX paths using the in-memory `mem_fs_path` fixture from `tests/conftest.py` (no temporary files, no `tmp_path`).
  - Acceptance: tests exist and pass.
  - Maps to: S-AC5, S-AC8, S-AC13, U-AC3.
- [x] [P2-T10] Add the end-to-end emission and determinism test for the .NET analyzer to `tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py`
  - Run `run_analyzer(DotnetInventoryAnalyzer(), ctx, fs)` over a consumer tree built on `mem_fs_path` with a pinned injected-clock ISO-8601 `captured_at`; validate every emitted instance against `schemas/discovery/v1/evidence-reference.schema.json` with `jsonschema` `Draft202012Validator` (offline); assert the exact top-level key set, `id` pattern `^[a-z0-9][a-z0-9._-]*$`, `schema_version` pattern `^1\.\d+\.\d+$`, `$schema` free of scheme/drive-letter/leading slash, all detection extras only under `metadata`, `metadata.detection_kind` membership in the twelve-value normative vocabulary, and byte-identical output across two runs with the same tree, profile, and clock.
  - Acceptance: tests exist and pass; no temporary files used.
  - Maps to: S-AC9, S-AC10, S-AC13, U-AC1, U-AC4, U-AC6.

### Phase 3 — VSTO/Office Analyzer (`vsto_office.py`)

- [x] [P3-T1] Create the raw fixture `tests/fixtures/discovery_dotnet_vsto/ribbon_customui.xml.txt`
  - Include one 2006/01 customUI document and one 2009/07 customUI document, each with a `<customUI` root element. No consumer identifiers.
  - Acceptance: fixture file exists with both schema generations present.
  - Maps to: S-AC3, S-AC13, U-AC8.
- [x] [P3-T2] Create the raw fixture `tests/fixtures/discovery_dotnet_vsto/vsto_ribbon.cs.txt`
  - Include named cases: `IRibbonExtensibility` (bare and namespace-qualified), a `GetCustomUI(` method, and `Microsoft.Office.Tools.Ribbon` designer usage, plus a comment trap containing ribbon-shaped text. No consumer identifiers.
  - Acceptance: fixture file exists with all named cases and the trap present.
  - Maps to: S-AC3, S-AC13, U-AC8.
- [x] [P3-T3] Create the raw fixture `tests/fixtures/discovery_dotnet_vsto/com_interop.cs.txt`
  - Include named cases: `[ComImport]`, `[ComVisible(...)]`, `[Guid("...")]` with a valid GUID, `[InterfaceType(...)]`, `[DispId(...)]`, `Marshal.<member>(` calls, `Type.GetTypeFromProgID(`, and an Office interop using with a generic Office application name captured as data; include a string-literal trap containing attribute-shaped text. No consumer identifiers and no per-application special-casing.
  - Acceptance: fixture file exists with all named cases and the trap present.
  - Maps to: S-AC4, S-AC13, U-AC8.
- [x] [P3-T4] Create the raw fixture `tests/fixtures/discovery_dotnet_vsto/project_com_reference.xmlproj.txt`
  - Include named cases: `<COMReference Include="...">`, `<EmbedInteropTypes>`, and an interop assembly reference `Include="Microsoft.Office.Interop.<App>"` with a generic application name. No consumer identifiers.
  - Acceptance: fixture file exists with all named cases present.
  - Maps to: S-AC4, S-AC13, U-AC8.
- [x] [P3-T5] Create `scripts/dev_tools/discovery/analyzer/vsto_office.py` with the `VstoOfficeAnalyzer` skeleton, `parse` stage, and file routing
  - Implement the #363 `Analyzer` protocol structurally with `name = "vsto-office"`; `parse(ctx)` performs the same seam walk, root fail-fast (`AnalyzerError`), include/exclude `fnmatch` filtering, deterministic POSIX ordering, and text reading as the .NET analyzer, selecting `.cs`, `.xml`, and `*proj` candidates and returning the shared `TextParseResult`; `classify` isinstance-narrows (raising `AnalyzerError` on a plain `ParseResult`) and routes: C# patterns on stripped `.cs` text, Ribbon-XML patterns on unstripped `.xml`, project-file patterns on unstripped `*proj` XML.
  - Acceptance: module exists with routing implemented and is under 500 lines.
  - Maps to: S-AC3, S-AC5, S-AC8, U-AC2, U-AC3.
- [x] [P3-T6] Implement the Ribbon-XML detection catalog in `scripts/dev_tools/discovery/analyzer/vsto_office.py`
  - Detect: customUI namespace URIs for both generations (`schemas.microsoft.com/office/2006/01/customui` and `.../2009/07/customui`) recording the matched URI in `customui_schema`, and the corroborating `<customUI` root element (detection kind `ribbon_xml`); `IRibbonExtensibility` (bare or namespace-qualified), `GetCustomUI(`, and `Microsoft.Office.Tools.Ribbon` in C# files (detection kind `ribbon_extensibility`).
  - Acceptance: all ribbon detections implemented as pure classify logic; module remains under 500 lines (if the catalog pushes it over, move pattern tables to a data-only `scripts/dev_tools/discovery/analyzer/vsto_patterns.py` within this task and keep both files under 500 lines).
  - Maps to: S-AC3, U-AC2.
- [x] [P3-T7] Implement the COM-interop detection catalog in `scripts/dev_tools/discovery/analyzer/vsto_office.py`
  - Detect: interop attributes `[ComImport]`, `[ComVisible(...)]`, `[Guid("...")]` (GUID captured into `com_guid`), `[InterfaceType(...)]`, `[DispId(...)]` (detection kind `com_attribute`); `Marshal.<member>(` calls with the member captured into `symbol` and no fixed member list (detection kind `marshal_call`); `Type.GetTypeFromProgID(` (detection kind `progid_activation`); Office interop usings `using [static] [alias =] Microsoft.Office.Interop.<App>` with the application name captured as data into `interop_target` and never branched on (detection kind `interop_using`); project-file `<COMReference>` (the `Include=` value captured into `symbol` when present), `<EmbedInteropTypes>`, and interop assembly references `Include="Microsoft.Office.Interop.*"` (detection kind `com_reference`).
  - Acceptance: all COM detections implemented as pure classify logic with capture-as-data (no per-application hardcoding); module (plus contingent `vsto_patterns.py`) remains under 500 lines each.
  - Maps to: S-AC4, U-AC2, U-AC7.
- [x] [P3-T8] Implement the `map` and `emit` stages in `scripts/dev_tools/discovery/analyzer/vsto_office.py`
  - `map` builds one #363 `EvidenceRecord` per detection under the identical emission contract as [P2-T6] (`kind` `"file"`, consumer-relative POSIX `location`, deterministic id, `schema_version` `"1.0.0"`, injected-clock `captured_at`, static generic detection-language `description`, optional `content_hash`, `tool` = `dev.discovery.vsto`, all specifics only under `metadata` including `customui_schema`/`com_guid`/`interop_target` as applicable). `emit` reuses the #363 emitter.
  - Acceptance: emission contract identical to the spec; #363 emitter reused; module under 500 lines.
  - Maps to: S-AC9, S-AC10, U-AC4.
- [x] [P3-T9] Create `tests/scripts/dev_tools/discovery/analyzer/test_vsto_office.py` with the parametrized Ribbon detection matrix
  - Feed inline XML/C# strings and the `ribbon_customui.xml.txt`/`vsto_ribbon.cs.txt` fixture texts to the pure classify functions: positive cases for both customUI URI generations (asserting the captured `customui_schema`), `<customUI` root, `IRibbonExtensibility`, `GetCustomUI`, and `Microsoft.Office.Tools.Ribbon`; negative cases proving the C# comment trap does not match (stripped) while XML is scanned unstripped.
  - Acceptance: tests exist, are parametrized, and pass; file under 500 lines.
  - Maps to: S-AC3, S-AC7, S-AC13, U-AC8.
- [x] [P3-T10] Add the parametrized COM-interop detection matrix to `tests/scripts/dev_tools/discovery/analyzer/test_vsto_office.py`
  - Cover every `com_attribute` form (asserting the captured `com_guid`), `Marshal.*` member capture into `symbol`, `GetTypeFromProgID`, interop usings with `interop_target` captured as data (including static and alias forms), and project-file `COMReference`/`EmbedInteropTypes`/interop assembly `Include` cases from `com_interop.cs.txt` and `project_com_reference.xmlproj.txt`; negative cases proving the string-literal trap is rejected on stripped C# text.
  - Acceptance: tests exist and pass; file remains under 500 lines.
  - Maps to: S-AC4, S-AC13, U-AC8.
- [x] [P3-T11] Add routing, error-path, and end-to-end emission/determinism tests for the VSTO analyzer to `tests/scripts/dev_tools/discovery/analyzer/test_vsto_office.py`
  - Assert file routing (`.cs` stripped / `.xml` unstripped / `*proj` unstripped), `AnalyzerError` on plain-`ParseResult` narrowing failure and on an unreachable root, include/exclude glob handling; run `run_analyzer(VstoOfficeAnalyzer(), ctx, fs)` over a `mem_fs_path` consumer tree with a pinned injected clock; validate every emitted instance with `jsonschema` `Draft202012Validator` against the v1 schema, assert `metadata.detection_kind` vocabulary membership, id/`schema_version`/`$schema` conformance, all specifics only under `metadata`, and byte-identical output across two runs.
  - Acceptance: tests exist and pass; no temporary files used.
  - Maps to: S-AC5, S-AC8, S-AC9, S-AC10, S-AC13, U-AC2, U-AC4, U-AC6.

### Phase 4 — CLI Surface and Console Scripts (`stack_cli.py`)

- [x] [P4-T1] Create `scripts/dev_tools/discovery/analyzer/stack_cli.py` with the shared `_run` helper and both entry functions
  - Implement `main_dotnet(argv) -> int` and `main_vsto(argv) -> int` delegating to one shared `_run(analyzer_factory, argv)` helper; argparse surface identical to `dev.discovery.inventory`: positional `profile` (path, `nargs="?"`, default `DEFAULT_PROFILE_FILENAME` imported from `scripts.dev_tools.discovery.domain_profile`), `--output-dir` (path, overrides `profile.artifacts.root`), `--json` (machine-readable run summary of written paths and record count to stdout); exit codes `0` success, `1` for `DomainProfileError`/`AnalyzerError` caught only at the CLI boundary, `2` argparse usage error; if #363's `cli.py` exposes a reusable profile-load/context-build/run/summary helper, call it, otherwise implement the flow locally and record the refactor proposal as an open coordination item in the module docstring; keep wiring minimal for coverage.
  - Acceptance: module exists, both entry functions return `int`, and the file is under 500 lines.
  - Maps to: S-AC11, U-AC1, U-AC2, U-AC3.
- [x] [P4-T2] Add the two console-script lines to `pyproject.toml`
  - Add exactly: `"dev.discovery.dotnet" = "scripts.dev_tools.discovery.analyzer.stack_cli:main_dotnet"` and `"dev.discovery.vsto" = "scripts.dev_tools.discovery.analyzer.stack_cli:main_vsto"` under `[tool.poetry.scripts]`; change nothing else in `pyproject.toml` (no dependency changes, no coverage-configuration changes).
  - Acceptance: both lines present verbatim; the `pyproject.toml` diff touches only `[tool.poetry.scripts]`.
  - Maps to: S-AC11, S-AC14.
- [x] [P4-T3] Create `tests/scripts/dev_tools/discovery/analyzer/test_stack_cli.py` with success-path CLI tests for both entry points
  - Exercise `main_dotnet` and `main_vsto` over a consumer tree and profile built on the in-memory `mem_fs_path` fixture, patching the profile loader at its import location in `stack_cli` (per the python.md patch-location rule); assert exit code `0`, expected written artifact paths, the `--json` run summary content, and the `--output-dir` override; pinned injected clock; no temporary files.
  - Acceptance: tests exist and pass; file under 500 lines.
  - Maps to: S-AC11, S-AC13, U-AC1, U-AC2, U-AC3.
- [x] [P4-T4] Add error-path and usage-error CLI tests to `tests/scripts/dev_tools/discovery/analyzer/test_stack_cli.py`
  - Assert exit code `1` for a malformed profile (`DomainProfileError`) and for an unreachable `legacy_source.root` (`AnalyzerError`) on both entry points, and exit code `2` for argparse usage errors on both entry points; assert error output names the specific failure.
  - Acceptance: tests exist and pass; file remains under 500 lines.
  - Maps to: S-AC11, S-AC13, U-AC3.

### Phase 5 — Domain-Neutrality Contract Test and Structural Verification

- [x] [P5-T1] Create the feature-scoped domain-neutrality contract test `tests/scripts/dev_tools/discovery/analyzer/test_stack_neutrality.py`
  - Scan the production modules `scripts/dev_tools/discovery/analyzer/source_text.py`, `dotnet_inventory.py`, `vsto_office.py`, `stack_cli.py` (plus `dotnet_patterns.py`/`vsto_patterns.py` when present): BAN consumer identifiers (`taskmaster`, `tmw`, case-insensitive) and consumer-specific or per-Office-application hardcoding (for example a literal `Microsoft.Office.Interop.Outlook` special case or any branch on a specific Office application name); PERMIT generic stack literals (`csharp`, `vsto`, `Microsoft.Office.*` pattern text, `.csproj`, `.sln`, and the customUI namespace URIs), which are this feature's stack subject matter; also assert the fixture files under `tests/fixtures/discovery_dotnet_vsto/` contain no consumer identifiers; document in the test docstring that this feature-scoped list intentionally differs from the stricter #363 framework list.
  - Acceptance: contract test exists and passes against the delivered modules and fixtures; file under 500 lines.
  - Maps to: S-AC12, U-AC7.
- [x] [P5-T2] Verify the 500-line limit for all new production and test modules and record the evidence artifact
  - Count lines for `scripts/dev_tools/discovery/analyzer/source_text.py`, `dotnet_inventory.py`, `vsto_office.py`, `stack_cli.py`, any contingent `dotnet_patterns.py`/`vsto_patterns.py`, and the five new test modules; raw text fixtures under `tests/fixtures/discovery_dotnet_vsto/` are exempt.
  - Acceptance: `<FEATURE>/evidence/other/file-size-verification.<ts>.md` exists with `Timestamp:` and a per-file line-count table showing every counted file under 500 lines; any file at or over 500 lines blocks completion until split.
  - Maps to: S-AC14.
- [x] [P5-T3] Verify no new runtime dependency and no coverage exclusion were added and record the evidence artifact
  - Diff `pyproject.toml` against the pre-change state: `[tool.poetry.dependencies]` unchanged, dev group unchanged (`jsonschema` remains dev-only, `hypothesis` NOT added — property-based tests are intentionally replaced by parametrized matrices because adding `hypothesis` would require explicit approval), and `[tool.coverage.*]` configuration unchanged (no exclusion for any new analyzer module).
  - Acceptance: `<FEATURE>/evidence/other/dependency-and-coverage-config-verification.<ts>.md` exists with `Timestamp:`, the relevant diff excerpt (only the two `[tool.poetry.scripts]` lines added), and an explicit no-new-dependency / no-new-exclusion statement.
  - Maps to: S-AC14, S-AC13.
- [x] [P5-T4] Record the acceptance-criteria-to-test traceability artifact
  - Map each of S-AC1..S-AC14 and U-AC1..U-AC8 to the implementing tasks and the concrete test functions/files delivered in Phases 1-4; record that S-AC6 (parsing-strategy Specification Decision with limitations and claim-scoping rule, citing the research artifact) is satisfied by the spec document itself and verify the section is present in `<FEATURE>/spec.md`.
  - Acceptance: `<FEATURE>/evidence/other/ac-test-mapping.<ts>.md` exists with `Timestamp:` and one row per acceptance criterion with its verifying test or document reference; no criterion row is empty.
  - Maps to: S-AC6, spec Definition of Done (criteria mapped to tests).

### Phase 6 — Final QA Loop (Python, full toolchain)

Rerun-on-change behavior (mandatory): if any step in this phase fails or modifies any file, fix the cause and restart the toolchain loop from [P6-T1]; the loop is complete only when [P6-T1] through [P6-T4] pass in one clean sequential pass. Every command task below is unconditional; `EXIT_CODE: SKIPPED` is not a valid outcome for any task in this phase.

- [x] [P6-T1] Run the final Black formatting gate and record the evidence artifact
  - Command: `poetry run black .`
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-qc-black.<ts>.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; if files were reformatted, the loop restarts from [P6-T1] after the change is reviewed.
- [x] [P6-T2] Run the final Ruff lint gate and record the evidence artifact
  - Command: `poetry run ruff check .`
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-qc-ruff.<ts>.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with zero violations; any failure restarts the loop from [P6-T1].
- [x] [P6-T3] Run the final Pyright type-check gate and record the evidence artifact
  - Command: `poetry run pyright`
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-qc-pyright.<ts>.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with zero errors; any failure restarts the loop from [P6-T1].
- [x] [P6-T4] Run the final pytest coverage gate and record the evidence artifact
  - Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
  - Acceptance: `<FEATURE>/evidence/qa-gates/final-qc-pytest.<ts>.md` exists and contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with pass/fail counts and the numeric post-change line-coverage percent and branch-coverage percent headline values (no placeholders); any failure restarts the loop from [P6-T1].
  - Maps to: S-AC13, U-AC8.
- [x] [P6-T5] Verify coverage thresholds and no-regression against the baseline and record the evidence artifact
  - Compare the numeric values recorded in `<FEATURE>/evidence/baseline/phase0-pytest.<ts>.md` and `<FEATURE>/evidence/qa-gates/final-qc-pytest.<ts>.md`: post-change line coverage >= 85% and branch coverage >= 75%; no coverage regression attributable to changed lines; per-module coverage for `scripts/dev_tools/discovery/analyzer/source_text.py`, `dotnet_inventory.py`, `vsto_office.py`, `stack_cli.py` (and contingent pattern modules) reported explicitly as the new-code coverage figures.
  - Acceptance: `<FEATURE>/evidence/qa-gates/coverage-delta.<ts>.md` exists with `Timestamp:`, baseline coverage, post-change coverage, and new-module coverage values, and an explicit PASS/FAIL threshold verdict; a FAIL verdict means the plan outcome is remediation-required, never PASS.
  - Maps to: S-AC13, U-AC8.

## Acceptance Criteria Mapping

Spec ACs (S-AC#, in `spec.md` document order) and user-story ACs (U-AC#, in `user-story.md` document order):

| Criterion | Summary | Covered by |
| --- | --- | --- |
| S-AC1 | Dotnet analyzer protocol + namespace/type enumeration | P2-T1, P2-T3, P2-T4, P2-T6, P2-T7 |
| S-AC2 | Event/delegate/subscription detection with heuristic tagging | P2-T2, P2-T5, P2-T8 |
| S-AC3 | VSTO Ribbon-XML detection | P3-T1, P3-T2, P3-T5, P3-T6, P3-T9 |
| S-AC4 | VSTO COM-interop detection | P3-T3, P3-T4, P3-T7, P3-T10 |
| S-AC5 | Root reading, include/exclude globs, AnalyzerError fail-fast | P2-T3, P2-T9, P3-T5, P3-T11 |
| S-AC6 | Parsing-strategy decision recorded in spec | Satisfied by spec.md; verified in P5-T4 |
| S-AC7 | Shared line-preserving stripper; XML unstripped | P1-T1, P1-T4, P3-T9 |
| S-AC8 | TextParseResult with isinstance narrowing; no #363 change | P1-T3, P1-T5, P2-T4, P2-T9, P3-T5, P3-T11 |
| S-AC9 | Evidence Reference v1 emission contract | P1-T2, P2-T6, P2-T10, P3-T8, P3-T11 |
| S-AC10 | Twelve-value detection_kind vocabulary | P2-T6, P2-T10, P3-T8, P3-T11 |
| S-AC11 | Two console scripts, argparse surface, exit codes 0/1/2 | P4-T1, P4-T2, P4-T3, P4-T4 |
| S-AC12 | Consumer-neutrality with feature-scoped banned list | P5-T1 |
| S-AC13 | Test quality policy (coverage, mirrored tree, no temp files, injected clock, fixtures, parametrized matrices) | P1-T4, P1-T5, P2-T7..P2-T10, P3-T9..P3-T11, P4-T3, P4-T4, P5-T3, P6-T4, P6-T5 |
| S-AC14 | 500-line limit, no new runtime dependency, no coverage exclusion | P4-T2, P5-T2, P5-T3 |
| U-AC1 | dev.discovery.dotnet emits anchored C# detections | P2-T3..P2-T10, P4-T1, P4-T3 |
| U-AC2 | dev.discovery.vsto emits ribbon/COM detections | P3-T5..P3-T11, P4-T1, P4-T3 |
| U-AC3 | Globs honored; exit codes 0/1/2; --json | P2-T9, P3-T5, P4-T1, P4-T3, P4-T4 |
| U-AC4 | Schema-valid instances; specifics only in metadata | P1-T2, P2-T6, P2-T10, P3-T8, P3-T11 |
| U-AC5 | Heuristic marking and detection language | P2-T5, P2-T8 |
| U-AC6 | Byte-identical reruns with pinned clock | P1-T2, P2-T10, P3-T11 |
| U-AC7 | Consumer-neutrality / capture-as-data | P3-T7, P5-T1 |
| U-AC8 | Quality policy + false-positive-trap fixtures | P1-T1, P1-T4, P2-T1, P2-T2, P3-T1..P3-T4, P6-T4, P6-T5 |

## Test Plan

- Unit: pure classify-stage detection matrices (inline strings + fixture texts), stripper state-machine tests, slug/id determinism, TextParseResult narrowing failure, include/exclude glob handling, unreachable-root error path.
- Integration: end-to-end `run_analyzer` runs for both analyzers over `mem_fs_path` consumer trees with a pinned injected clock; jsonschema validation of every emitted instance; byte-identical repeat emission; CLI 0/1/2 for both entry points.
- Contract: feature-scoped domain-neutrality test (P5-T1); detection_kind vocabulary membership assertions (P2-T10, P3-T11).
- Coverage evidence: baseline `<FEATURE>/evidence/baseline/phase0-pytest.<ts>.md`; post-change `<FEATURE>/evidence/qa-gates/final-qc-pytest.<ts>.md`; comparison `<FEATURE>/evidence/qa-gates/coverage-delta.<ts>.md`. Property-based tests are intentionally not required: `hypothesis` is not a dev dependency and adding it would require explicit approval; parametrized boundary matrices are the approved substitute per the spec Testing Requirements.

## Open Questions / Notes

- ParseResult-payload genericization and CLI-flow helper reuse are open coordination items with #363 at integration-branch time (recorded in the Coordination Items section; not blockers).
- Upstream #363/#360/#359 presence is an execution-time sequencing assumption gated by [P0-T6]; absence yields BLOCKED-UPSTREAM, not a planning failure.
- Contingent modules `dotnet_patterns.py`/`vsto_patterns.py` are created only if the 500-line limit requires the split (handled inside P2-T4/P3-T6 acceptance criteria).
