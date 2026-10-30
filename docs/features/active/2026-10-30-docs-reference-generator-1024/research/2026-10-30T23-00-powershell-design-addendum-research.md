# docs-reference-generator (Issue #1024) - PowerShell Design Addendum

- Feature: child 1024 of epic #1019 (documentation-estate-tooling), wave 2, band C3; depends on 1020
  and 1021.
- Branch: `feature/docs-reference-generator-1024`
- Mode: preparation research (new planning cycle under owner decision D1). No source,
  configuration or test file was changed.
- Relationship to earlier research: `research/research.2026-10-30T20-59.md` (the "earlier
  research") and the current `spec.md`, `user-story.md` and `plan.2026-10-30T16-54.md` describe the
  withdrawn Python design (`drm_copilot_docs.reference`, `dev.docs.generate-reference`, `pyproject.toml`
  edits, pytest, `difflib`, PyYAML). This addendum supersedes every part of them that names Python
  modules, Poetry, pytest, `jsonschema`, PyYAML, `difflib`, `fnmatch` or `pyproject.toml`. Section 1
  lists the language-independent findings that are kept.
- Filename note: the delegation named
  `research/research.2026-10-30T23-00-powershell-design-addendum.md`. The SubagentStop hook
  `.claude/hooks/validate-task-researcher-output.ps1` (`Test-IsValidResearchFileName`) accepts only
  `<timestamp>-<name>-research.md`, `<timestamp>-<name>.research.md` or
  `research(-addendum).<timestamp>.md`; the delegated name matches none of them. This file therefore
  carries the name `2026-10-30T23-00-powershell-design-addendum-research.md` in the same folder, the
  same adjustment the 1020 addendum recorded.
- Tool limits: the task-researcher tool set cannot run PowerShell, `git show` or `gh`. Facts that
  need them are listed under `## Items for the Orchestrator to Confirm`.
- Requirement origin: one consumer repository (epic `## Goal`). No identifier of that repository
  appears in this file.

## 0. Decisions in One Line Each

1. Four owner-fixed modules under `.claude/lib/docs/`: `DocsReferencePlan.psm1` (pure planning),
   `DocsReferenceRender.psm1` (pure block rendering), `DocsReferenceMarkers.psm1` (pure marker parse
   and merge), `DocsReferenceWriter.psm1` (front matter, generation composition, dry-run diff,
   report lines, and the `generate-reference` command, the only function that touches the command
   context).
2. One dispatch row in `.claude/lib/docs/Invoke-DocsCommand.ps1` under the 1024 anchor (the 1020
   spec text currently labels it `# --- 900006: generate-reference ---`; see OQ-A):
   `Name = 'generate-reference'`, `Module = (Join-Path -Path $PSScriptRoot -ChildPath
   'DocsReferenceWriter.psm1')`, `Function = 'Invoke-DocsGenerateReferenceCommand'`, `Option = @{
   Profile = 'value'; Snapshot = 'value'; OutputDirectory = 'value'; Write = 'switch' }`.
3. Every pure function takes strings, string arrays and hashtables; file access goes only through
   the 1020 command context, whose members are passed to `[scriptblock]`-typed parameters and
   invoked through those parameter variables (section 4).
4. `last_reviewed` for a page without a valid existing value is the calendar date prefix of the
   snapshot `captured_at`; no function reads the clock, so re-rendering the same snapshot is
   byte-identical on any day.
5. Dry run is the default; `-Write` writes through `Context.WriteText` (backed by
   `Write-DocsFileText`) in path order with a digest re-check before each overwrite.
6. The dry-run diff is a region diff (front-matter region and each generated block) derived from the
   merge result, not a general line-LCS diff (section 5.9).
7. Finding codes use the `DOCS_REFERENCE_` prefix and `New-DocsFinding`; exit codes 0/1/2/3 follow
   1020, with `DOCS_CLI_ARGUMENTS` (exit 2) and `DOCS_CLI_RUNTIME` (exit 3) at the entry boundary.
8. `-Json` emits the 1020 envelope with `command = 'generate-reference'`; a Pester test validates the
   envelope text against `schemas/docs/v1/docs-command-envelope.schema.json` (created by the 1020
   amendment).
9. The 1021 checker integration test runs both commands over one in-memory command context: the
   generator's write log becomes the page set the checker lists and reads, so no file is created.
10. Property tests use a seeded `[System.Random]` draw helper in a new test-support module (seeds
    11, 23, 47, 101, 211, seed printed on failure), one property test per pure public function,
    including the six functions the halted preflight named (section 7.1).
11. No edit to `quality-tiers.yml`, `config/poshqc-coverage.json` or `config/poshqc-scan.json`; new
    files are registered in the Claude `pack-manifests/core.json` and mirrored byte-identically.

## 1. Reuse of the Earlier Research and Current Spec

Kept (language-independent), with the substitutions in this addendum:

- Earlier research `### 2.1 Merge model for generated content` (line-oriented marker blocks keyed
  by element identifier, strict full-line grammar, fence-aware scanning, error on anomaly,
  in-place replacement).
- Earlier research `## 3. Behavior Semantics` (determinism, dry run, write ordering, removal
  reporting, failure conditions, ordering).
- `spec.md` `### Marker grammar`, `### Merge algorithm` (steps 1-6), `### Page-plan rules`
  (family pages, `#### Output directory`, `#### Coverage and precedence`, `#### Element order within
  a page`), `### Front-matter rules` (field order, generator-owned and preserved fields),
  `### Rendering rules` (block body shapes, `single_line`, `code_span`, no links, no HTML other than
  markers), `### Determinism rules`, and the triggers in `### Finding-code catalog` (renamed per
  section 5.10).
- `spec.md` `## Decisions` D2 (path coverage rule and first-match precedence), D3 (no index page),
  D5 (no `--check` mode) and D8 (marker layout). D1 is superseded by the epic audience-pattern
  decision (section 5.7); D4, D6 and D7 are withdrawn with the Python design.

Superseded and not reused: `spec.md` `### Command synopsis`, `### Arguments`, `### Exit codes`,
`### Stdout and stderr per exit code`, `### Python seams`, `### JSON report`, `### Text report`,
`### Dry-run diff`, `### Write semantics`, `## Module Boundaries`, `## Implementation Strategy`,
`### Tests`, `### Coverage gate`; earlier research `### 1.3` to `### 1.7`, `### 2.2`, `## 5`,
`## 6`, `## 7`; the whole of `plan.2026-10-30T16-54.md`.

## 2. Existing Repository Patterns (Question 1)

### 2.1 Library module plus Pester suite layout

- `.claude/lib/mermaid/` holds four modules (`MermaidGrammar.psm1`, `MermaidLineScanner.psm1`,
  `MermaidMarkdownFences.psm1`, `MermaidValidation.psm1`) with suites under
  `tests/scripts/claude-lib/mermaid/` (`MermaidGrammar.Tests.ps1`, `MermaidLineScanner.Tests.ps1`,
  `MermaidMarkdownFences.Tests.ps1`, `MermaidValidation.Tests.ps1`,
  `MermaidValidationAcceptMatrix.Tests.ps1`). Each suite imports the module in `BeforeAll`
  (`MermaidMarkdownFences.Tests.ps1`: `Import-Module $script:FenceModulePath -Force`).
- Additional aspect suites use `<Module>.<Aspect>.Tests.ps1` (for example
  `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1`,
  `BlastRadiusConflict.PathOverlap.Tests.ps1`). 1024 follows this for property, command and
  integration suites.
- Module conventions pinned by `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`
  (discovers every `*.psm1` under `.claude/lib` recursively): the help block carries the sentence
  `imports its siblings with -ErrorAction Stop`; `Set-StrictMode -Version Latest` is followed by
  `$ErrorActionPreference = 'Stop'`; every column-0 `Import-Module` carries `-ErrorAction Stop`; the
  caller's error preference is unchanged after import; the 800-line hard limit applies. Precedent
  text: `.claude/lib/mermaid/MermaidMarkdownFences.psm1` help block ("CONVENTION: this module fails
  fast at module scope and imports its siblings with -ErrorAction Stop.").

### 2.2 Pure functions over strings

- `MermaidMarkdownFences.psm1` is the closest precedent: every function is pure ("no filesystem,
  subprocess, network, or wall-clock access, and no input is mutated"), parameters are `[string]`
  with `[AllowEmptyString()]`/`[AllowNull()]`, and `Split-MermaidTextLine` normalizes CRLF, CR and
  LF once (`$Text -split '\r\n|\n|\r'`). `Get-MermaidFenceLine` implements the same fence rule the
  1024 marker scanner needs (three or more backticks or tildes, up to three spaces of indentation,
  same-character close at least as long).
- Decision: 1024 does not import the Mermaid module. Its fence regex allows blockquote prefixes and
  carries an `IsMermaid` field, and coupling the docs lib to the Mermaid lib adds a cross-area
  dependency for about twenty lines of logic. `DocsReferenceMarkers.psm1` implements its own fence
  test with the 1021 fence rule (`spec.md` `### Marker grammar`) and cites the Mermaid function as
  precedent.
- The 1020 contract (`spec.md` of 1020, `### Module conventions (all files under .claude/lib/docs/)`):
  "Pure means no filesystem, clock, process, environment or module-scope mutable state. Pure functions
  take in-memory strings and hashtables. No module keeps a schema or composition cache."

### 2.3 Seeded property-style tests in Pester

- Verified absence: a search of `tests/scripts` (`*.ps1`) for `System.Random`, `Get-Random`,
  `SetSeed`, "property-based" and "property test" returns no match; the `seed` matches found
  (`DiscoveryCapability.Tests.ps1`, `DiscoveryGate.TestSupport.ps1`, `BlastRadius.Tests.ps1`) mean
  "pre-populate a store", not a random seed. No Pester precedent exists for seeded property tests.
- Repository precedent in Python: `tests/discovery_runtime/test_t2_properties.py` defines
  `SEEDS = (11, 23, 47, 101, 211)` and a digest-driven `Draw` class, used with
  `@pytest.mark.parametrize("seed", SEEDS)`.
- Sibling precedent in the epic: the 1020 spec acceptance criterion on element identifiers uses "a
  seeded `[System.Random]` input set (seed printed on failure)", and the 1020 plan task [P2-T3]
  ("determinism over a `[System.Random]` input set with a fixed seed that is printed in the failure
  message").
- Selected harness (section 10.2): a test-support module with a `[System.Random]`-backed draw
  helper, the Python seed list, and Pester 5 data-driven `It ... -ForEach` cases defined in
  `BeforeDiscovery`, with `-Because "seed $Seed"` on every assertion. Pester 5 `-ForEach` is already
  used in the tree (for example `tests/scripts/claude-lib/discovery-validation/DiscoveryCapability.Tests.ps1`).

### 2.4 Canonical JSON helper

- `ConvertTo-DiscoveryCanonicalJson` exists in
  `.claude/lib/discovery-validation/DiscoveryEncoding.psm1`, exported together with
  `Get-DiscoverySha256Hex`, `Get-DiscoveryBytesSha256Hex`, `ConvertTo-DiscoveryJsonString` and
  `ConvertTo-DiscoveryCanonicalFragment`. `DiscoveryEncoding.psm1` is listed in
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- 1024 does not import it directly: 1020 wraps it as `ConvertTo-DocsCanonicalJson`,
  `Get-DocsSha256Hex` and `Get-DocsBytesSha256Hex` in `DocsJson.psm1` (1020 `spec.md`
  `### DocsJson.psm1 (pure)`), and 1024 uses those wrappers.

### 2.5 Status of upstream files on the integration branch

Verified by Glob in this worktree (HEAD equals the integration branch): no file exists under
`.claude/lib/docs/`, `schemas/docs/`, `examples/docs/` or `tests/scripts/claude-lib/docs/`. Every
1020 and 1021 symbol cited below is therefore "created by 1020/1021, not yet on the integration
branch", including `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSchema.psm1`, `DocsSurface.psm1`,
`DocsProfile.psm1`, `Invoke-DocsCommand.ps1`, `Write-DocsFileText`, `Docs.TestSupport.psm1`,
`Docs.Manifest.Tests.ps1`, `DocsNeutrality.Tests.ps1`, `schemas/docs/v1/page-metadata.schema.json`,
`schemas/docs/v1/docs-command-envelope.schema.json`, `DocsPageFrontMatter.psm1` and
`DocsPageCheck.psm1`. The 1021 folder in this worktree (`spec.md`, `plan.2026-10-30T16-13.md`,
`research/research.2026-10-30T20-35.md`) still describes the withdrawn Python package
`packages/docs-page-check`.

## 3. Coverage, Scan, Tier, Pack Manifest and Push-Down Contracts (Question 2)

- `config/poshqc-coverage.json` `roots` contains `.claude/lib`, so every new
  `.claude/lib/docs/*.psm1` is in the coverage denominator without an edit.
- `config/poshqc-scan.json` `test.scanFolders` contains `tests/scripts`, so every new suite under
  `tests/scripts/claude-lib/docs/` is discovered without an edit.
- CI: `.github/workflows/_poshqc.yml` runs `poshqc / PowerShell QC static` (format and analyze),
  the shard matrix `poshqc / PowerShell QC shard 1`, `shard 2`, `shard 3` (`Invoke-PoshQCTest
  -ShardIndex -ShardCount`, with coverage), and the aggregator `poshqc / PowerShell QC` (required
  context), all on `windows-latest`. The aggregator verifies shard completeness and merges coverage
  (`Merge-PoshQCCoverageReport`, `Get-PoshQCCoverageLineSummary`); it prints the merged line total
  and enforces no per-file threshold. The per-file 85% line figure is therefore local evidence read
  from `artifacts/pester/powershell-coverage.xml`, not a CI gate. `poshqc / PowerShell hook suites
  (Linux)` runs only `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, so the docs
  suites run on Windows only.
- `quality-tiers.yml`: every existing `.claude/lib/<name>` entry is T3 (`.claude/lib/mermaid`,
  `.claude/lib/discovery-validation`, and the others). `.claude/lib/docs` is not yet listed; 1020
  adds it at T3 (1020 `spec.md` `## Implementation Strategy`). 1024 adds files inside that folder
  and no new project, so it makes no tier edit. At T3 the property-test density row of
  `.claude/rules/quality-tiers.md` does not apply; the property tests here are required by owner
  decision D1 and the epic `### Generator decisions from the first preparation of 1024`.
- Pack manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
  (`paths`) already lists `.claude/lib/mermaid/*.psm1` and
  `.claude/lib/discovery-validation/DiscoveryEncoding.psm1`. 1024 appends one entry per new file.
- Contract tests a new lib file must satisfy (`tests/scripts/dev_tools/`):
  - `test_push_down_claude_resource_contracts.py`
    (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`): every distributable file
    under `.claude/` exists in the bundle with equal text (filter `filter_distributable_claude_paths`
    in `claude_payload_scope_test_support.py` removes only local runtime state).
  - `test_push_down_pack_manifest_dependency_closure.py`: `test_claude_manifest_powershell_dependency_closure`
    (every `$PSScriptRoot` target of a manifested PowerShell file is in core plus the owning pack),
    `test_every_psscriptroot_occurrence_is_recognized` (only recognized literal forms), and
    `test_scanned_source_floor`. The 1024 modules use only the literal
    `Join-Path -Path $PSScriptRoot -ChildPath '<sibling>.psm1'` form (1020 `## Decisions Later
    Children Must Honor`), and every target (1020 modules, 1021 `DocsPageFrontMatter.psm1`, 1024
    siblings) is in core.
  - `test_push_down_claude_pack_manifest_completeness.py`
    (`test_bundled_claude_files_are_listed_in_some_pack_manifest`): verified that
    `enumerate_bundled_claude_relative_paths` walks only `agents/*.md`, `hooks/*` and
    `skills/<name>/SKILL.md`, so it does not check lib files; the 1020 suite
    `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` is the lib-level guard.

## 4. Dynamic Invocation Restriction (Question 3)

- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` scans
  `.claude/lib` (scan roots in `EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1`, which
  exclude `.claude/lib/bash/*` and the bundle mirror) through `Get-PythonInvocationFinding` in
  `EnforcementHooksNoPythonInvocation.Helpers.ps1`. Detection class 3 reports, fail-closed, any
  command whose first element is a variable that is not a `[scriptblock]`-typed parameter declared
  anywhere in the same file, and any other non-constant command position (an expression such as
  `& (Get-X)` or a member such as `& $Context.ReadText`). Class 4 reports any `Invoke-Expression`
  or `iex`. The allowlist is empty and may grow only by owner decision (`ships an empty allowlist`).
- Carve-out (a) matches by parameter name within the file, case-insensitively.
- Consequences for 1024 (consistent with the 1020 plan `## Design Constraints From Existing Tests`
  and preflight fix 1 in `evidence/other/preflight-fixes.2026-10-30T22-23.md` of 1020):
  - Renderer selection by element kind uses a `switch -CaseSensitive` statement that calls literal
    function names (`Get-DocsReferenceCliCommandBody`, and so on). No table of scriptblocks invoked
    with `&`, and no `& $functionName`.
  - Command-context members are never invoked as `& $Context.<Member>`. The command function passes
    them to private I/O helpers in `DocsReferenceWriter.psm1` whose parameters are typed
    `[scriptblock]` (`-ReadText`, `-ReadBytes`, `-TestFile`, `-WriteText`) and invokes them as
    `& $ReadText $path`.
  - No `Invoke-Expression`, no `.Invoke()` workaround on members (it would hide the seam from the
    reviewer even though the AST guard does not flag method calls).
  - Acceptance evidence: the existing suite reports no `DynamicInvocation` or `InvokeExpression`
    finding for any `.claude/lib/docs/DocsReference*.psm1` file.

## 5. Generator Design Under the Fixed Decisions (Question 4)

### 5.1 Inputs and flow

1. Read the profile (`-Profile`, default `Get-DocsDefaultProfilePath`) through `Context.ReadText`;
   absent profile yields exit 1 `DOCS_PROFILE_MISSING` (reuse of the 1020 code). Parse and validate
   with `ConvertFrom-DocsProfileText`.
2. Read the snapshot (`-Snapshot`, default `artifact_paths.inventory_snapshot` of the profile);
   absent snapshot yields exit 1 `DOCS_REFERENCE_SNAPSHOT_MISSING`. Validate with
   `Test-DocsArtifactText -ArtifactKind 'surface-inventory-snapshot'` and rebuild each element with
   `ConvertFrom-DocsSurfaceElement` (re-verifies `element_id`).
3. Resolve the output directory and the candidate page paths; test each with `Context.TestFile`;
   read existing pages through `Context.ReadBytes` (digest) and decode with a strict UTF-8 decoder in
   a pure function (BOM removed, CRLF and CR normalized to LF).
4. Compute every page in memory (`New-DocsReferenceChangeSet`, pure).
5. Without `-Write`: return the result with planned actions and region diffs; no `WriteText` call.
   With `-Write` and no `error` finding: write changed pages in ordinal path order.
6. Return `New-DocsCommandResult -Command 'generate-reference'`; the entry script renders the
   envelope or the text report and exits.

A read failure other than absence propagates as an exception and becomes exit 3 `DOCS_CLI_RUNTIME`
at the entry boundary (1020 `#### Exit codes and the -Json envelope`).

### 5.2 Family pages and unrendered elements

| Family | Element kinds | File | Title |
|---|---|---|---|
| cli | `cli-command`, `cli-option` | `cli-reference.md` | `CLI reference` |
| http | `http-route` | `http-reference.md` | `HTTP reference` |
| config | `config-key` | `config-reference.md` | `Configuration reference` |
| api | `public-symbol` | `api-reference.md` | `API reference` |

- `architecture-component` elements are not rendered; `result.unrendered` carries
  `{"architecture-component": <count>}` (0 when none).
- A family page is planned when the family has at least one element or the page already exists; an
  existing page whose family is empty keeps its prose and loses every generated block.
- No index page and no reserved block identifier (epic `### Generator decisions from the first
  preparation of 1024`).

### 5.3 Output directory rule

`-OutputDirectory` when given; otherwise the single `diataxis_policy.directory_modes` entry with
`mode: reference` whose `path_or_glob` contains none of `*`, `?`, `[`. Zero or several such entries
yield `DOCS_REFERENCE_OUTPUT_DIR_UNRESOLVED`; `reference` absent from `diataxis_policy.modes` yields
`DOCS_REFERENCE_MODE_CONFLICT` at pointer `/diataxis_policy/modes`. Page path is
`<output directory>/<file>`.

### 5.4 Path matching rule

`E` covers `P` when `P -ceq E`, when `P.StartsWith(E + '/', [StringComparison]::Ordinal)`, or when
`P` matches `E` as a case-sensitive glob; the first entry in profile order wins for `page_owners`
and `directory_modes`. The documentation root is the covering root with the longest `path`, ties to
the first in profile order.

- Glob semantics must reproduce Python `fnmatch.fnmatchcase`, which the first preparation used and
  1023 is required to share (epic `### Generator decisions from the first preparation of 1024`):
  `*` matches any run including `/`, `?` one character, `[...]` a class with `!` negation, every
  other character literal. Proposed pure implementation: translate to an anchored .NET regex
  (`\A...\z`, `RegexOptions.CultureInvariant`, no `IgnoreCase`).
- Rejected: PowerShell `-clike` / `[WildcardPattern]` (bracket negation and escaping differ from
  `fnmatch`; unverified, see Items to Confirm); `Test-GlobMatch` in
  `.claude/lib/blast-radius/BlastRadiusGlob.psm1` (its `*` does not cross `/`, it escapes `[` as a
  literal, and it keeps a module-scope regex cache, which the 1020 purity rule forbids).
- Home of the function: the same rule is needed by 1023 (wave 1, merged before 1024), but 1024 does
  not depend on 1023 and must not import a 1023 module. This is OQ-B.

### 5.5 Marker form

- Start line `<!-- docs:generated:start id=<element-id> -->`, end line
  `<!-- docs:generated:end id=<element-id> -->`, exact full-line match, no surrounding whitespace,
  `<element-id>` matching the 1020 `element-id` pattern (checked with `Test-DocsElementId`).
- Layout: start marker, blank line, body, blank line, end marker; one blank line separates a block
  from neighbouring content (`spec.md` D8).
- Scanning skips front matter and fenced code outside blocks; inside an open block only marker lines
  are interpreted. Anomalies (malformed, duplicate, unbalanced, mismatched, inside front matter,
  unclosed fence) block only the affected page.
- 1021 interaction: the Diataxis signal "generated block" is a line containing
  `<!-- docs:generated:start id=` and rule `DX-GENERATED-REFERENCE` fails only for `tutorial`,
  `how-to` and `explanation` (1021 `spec.md` `## Diataxis Mode Rules`), so generated reference pages
  pass. This rule is stated in the withdrawn Python 1021 spec and must be confirmed in the
  PowerShell 1021 (dependency risk R-3).

### 5.6 Rendering

- Block bodies per `spec.md` `### Rendering rules`: heading `## Command`, `### Option`, `## Route`,
  `## Key`, `## Symbol`, each followed by a code span; then `- Name:`, `- Source:` (with
  `(lines <start>-<end>)` when `line_range` is not null) and one `- Property` line per property
  sorted by name. Lists, not tables.
- Every consumer-derived string passes through `ConvertTo-DocsReferenceSingleLine` (Unicode
  categories `Cc`, `Zl`, `Zp` replaced by a space, space runs collapsed, ends trimmed) and then
  `ConvertTo-DocsReferenceCodeSpan` (backtick delimiter one longer than the longest internal run,
  padding per CommonMark). Property values are rendered as `ConvertTo-DocsCanonicalJson` output
  without the trailing LF.
- No line begins with consumer text, so no rendered line can open an HTML block, form a marker or a
  link; every heading begins with a fixed English word, so 1021 `DX-NO-INSTRUCTION` cannot fire.
- `analysis_method` (added to elements by the 1020 amendment for D3) is not rendered; the loader
  must accept it (dependency risk R-5).

### 5.7 Front matter

- Fields and order: `owner`, `last_reviewed`, `audience`, `diataxis_mode`, `surface_refs`, then
  `title` and `extensions` when present. Delimited by `---` lines.
- Line form: `<key>: <value>`, where the value is a JSON scalar or JSON flow collection produced
  by `ConvertTo-DocsCanonicalJson` without its trailing LF; U+0085, U+2028 and U+2029 are escaped as
  `\uXXXX`. JSON flow values are valid YAML, and a bounded parser can decode each value with
  `ConvertFrom-DocsJsonText`. The exact grammar the 1021 bounded parser accepts is not yet fixed
  (dependency risk R-2).
- Generator-owned values: `diataxis_mode` is `reference`; `surface_refs` is the ordinal-sorted list
  of element identifiers rendered on the page (may be empty; page-metadata sets no `minItems`).
- Preserved when present and valid: `owner`, `audience`, `last_reviewed`, `title`, `extensions`.
- Deterministic sourcing of missing values (no clock in any function):
  - `owner`: the `owner` of the first `page_owners` entry covering the page path; none yields
    `DOCS_REFERENCE_OWNER_UNRESOLVED`.
  - `audience`: the ordinal-sorted `audience_ids` of the covering documentation root (longest path);
    an empty list yields `DOCS_REFERENCE_AUDIENCE_MISSING`; an identifier outside
    `^[a-z0-9][a-z0-9-]*$` yields `DOCS_REFERENCE_AUDIENCE_INVALID`. The epic fixes this pattern for
    both schemas, but the current 1020 spec still types `audiences[].id` and `audience_ids` as the
    discovery `identifier` (`^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$`, which admits `.` and `_`). The
    guard stays until the amended 1020 schema is confirmed (dependency risk R-4).
  - `last_reviewed`: the first ten characters of the snapshot `captured_at` (required by the 1020
    `surface-inventory-snapshot` schema with the docs-common timestamp pattern), checked for
    calendar validity with `[datetime]::TryParseExact(..., 'yyyy-MM-dd',
    [Globalization.CultureInfo]::InvariantCulture, 'None', [ref]$x)`; an invalid date yields
    `DOCS_REFERENCE_SNAPSHOT_INVALID`. Rationale: `Context.UtcNow` would change a new page's bytes
    from one day to the next for the same snapshot, which breaks the byte-identity criterion, and
    the snapshot date is the date the rendered content was derived.
  - `title`: the family title, only for a new page.
- Existing front matter is read when line 1 is exactly `---` and ends at the next line that is
  exactly `---` or `...`; it is re-rendered in canonical form (comments are not preserved). A page
  without front matter receives a rendered block and one blank line before the unchanged body.
- Conformance to `schemas/docs/v1/page-metadata.schema.json`: a Pester test validates the
  front-matter values of every generated page as JSON with `Test-Json -Schema` against the
  committed schema text (composed through `Join-DocsSchemaText` if the schema references docs
  common), and pins the generator's pattern constants against the schema's `pattern` values.

### 5.8 Dry run, write switch and write order

- Without `-Write`: no `WriteText` call; page statuses `planned` (create, update), `skipped` (none)
  or `blocked`.
- With `-Write`: if any `error` finding exists, nothing is written and exit is 1. Otherwise, in
  ordinal path order: `none` is skipped; `create` calls `WriteText` with mode `create`; `update`
  first re-reads the page bytes and compares `Get-DocsBytesSha256Hex` with the planned
  `sha256_before`, then calls `WriteText` with mode `overwrite`. A digest mismatch, an existing
  target on `create`, or a write exception stops the run: exit 3 with exactly one finding
  (`DOCS_REFERENCE_WRITE_CONFLICT` or `DOCS_REFERENCE_WRITE_FAILED`, `artifact_path` the failing
  page, `related_paths` the pages written before the stop) and `result` null, which follows the 1020
  exit-3 rule ("findings holds exactly one finding; result is null"). The re-check narrows but does
  not close the read-to-write window; the 1020 context has no compare-and-write primitive.
- The only write path is `Context.WriteText`, which the real context implements with
  `Write-DocsFileText` (1020 `### Entry script (Invoke-DocsCommand.ps1)`).

### 5.9 Dry-run diff (selected: region diff)

- Because the merge never edits prose, the only changed regions are the front-matter block and the
  generated blocks. `Merge-DocsReferenceBlock` returns, per changed region, the old lines and the
  new lines with their 1-based start lines. `Get-DocsReferenceDiffLine` renders a header
  `--- a/<path>` (or `--- /dev/null` for `create`) and `+++ b/<path>`, then per region a hunk
  header `@@ -<old start>,<old count> +<new start>,<new count> @@ <region>` followed by `-` and `+`
  lines, in page order. A BOM-only or line-ending-only change gives action `update` with no hunk.
- Rejected: a general LCS unified diff (a new O(n·m) algorithm in PowerShell, file-size pressure on
  `DocsReferenceWriter.psm1`, and no repository precedent); `Compare-Object` (not positional unless
  `-SyncWindow` is tuned, no hunk format, output order not guaranteed to be stable).

### 5.10 Exit codes, findings and `-Json`

| Exit | Condition | Findings | `result` |
|---|---|---|---|
| 0 | No `error` finding; dry run printed the plan or every write succeeded | warnings and infos allowed (`DOCS_REFERENCE_PARENT_MISSING`, `DOCS_REFERENCE_BLOCK_REMOVED`) | generation result |
| 1 | Any `error` finding in loading or planning; nothing written in either mode | ordered `error` findings | generation result when planning ran, otherwise `null` |
| 2 | Usage error before any read | exactly one `DOCS_CLI_ARGUMENTS` | `null` |
| 3 | Write conflict or failure, read failure other than absence, unexpected exception | exactly one (`DOCS_REFERENCE_WRITE_CONFLICT`, `DOCS_REFERENCE_WRITE_FAILED`, or `DOCS_CLI_RUNTIME`) | `null` |

- Finding codes (renamed from `spec.md` `### Finding-code catalog`, same triggers):
  `DOCS_REFERENCE_SNAPSHOT_MISSING`, `DOCS_REFERENCE_SNAPSHOT_INVALID`,
  `DOCS_REFERENCE_REPOSITORY_MISMATCH`, `DOCS_REFERENCE_OUTPUT_DIR_UNRESOLVED`,
  `DOCS_REFERENCE_MODE_CONFLICT`, `DOCS_REFERENCE_OUTPUT_OUTSIDE_ROOTS`,
  `DOCS_REFERENCE_OWNER_UNRESOLVED`, `DOCS_REFERENCE_AUDIENCE_MISSING`,
  `DOCS_REFERENCE_AUDIENCE_INVALID`, `DOCS_REFERENCE_FRONT_MATTER_INVALID`,
  `DOCS_REFERENCE_MARKER_MALFORMED`, `DOCS_REFERENCE_MARKER_DUPLICATE`,
  `DOCS_REFERENCE_MARKER_UNBALANCED`, `DOCS_REFERENCE_MARKER_MISMATCH`,
  `DOCS_REFERENCE_MARKER_IN_FRONT_MATTER`, `DOCS_REFERENCE_FENCE_UNCLOSED` (all `error`),
  `DOCS_REFERENCE_PARENT_MISSING` (`warning`), `DOCS_REFERENCE_BLOCK_REMOVED` (`info`,
  `related_ids` the removed identifier), `DOCS_REFERENCE_WRITE_CONFLICT`,
  `DOCS_REFERENCE_WRITE_FAILED` (exit 3). Every code matches the 1020 grammar `^[A-Z][A-Z0-9_]*$`.
  Page findings use pointer `''` and carry `<path>:<line>` in the message (the 1020 `finding` shape
  has no line field).
- Path-valued options (`-Profile`, `-Snapshot`, `-OutputDirectory`) that fail
  `Test-DocsRelativePath` are exit 2 before any read. Whether `ConvertFrom-DocsCommandArgument`
  validates paths or the command function returns the exit-2 result itself is not fixed by the 1020
  option kinds (`value`, `multi`, `switch`); see Items to Confirm.
- `result` (exit 0 and 1): `{mode, pages, summary, unrendered}`; `pages[]` ordered by path, each
  `{action, blocks{added, removed, unchanged, updated}, diff, path, sha256_after, sha256_before,
  status}`; `summary` with the integer counts of `spec.md` `### JSON report` less the finding counts
  (the envelope carries findings). Key order is irrelevant because the envelope is canonical JSON.
- `-Json` output: the 1020 envelope `{command, exit_code, findings, ok, result}` as canonical JSON.
  Under the 1020 amendment (epic `### Amendment of 1020 required by D3 and D5`) the envelope has
  `schemas/docs/v1/docs-command-envelope.schema.json`; this supersedes the 1020 spec sentence "The
  envelope has no schema file". A Pester test validates the generate-reference envelope for exit 0,
  1, 2 and 3 against that schema. Whether the envelope schema constrains `result` per command is
  unknown (dependency risk R-6).
- Text mode: `ConvertTo-DocsReportText` prints findings, then the `Line` array of the command
  result (per-page lines `<action> <path> (+<added> ~<updated> -<removed>)`, then, in dry run, the
  diff lines, then one note per created page that it must be linked from an entry page), then the
  1020 summary line `generate-reference: exit=<n> errors=<n> warnings=<n> infos=<n>`.

### 5.11 Prose preservation, removal reporting and byte identity

- Merge steps 1-6 of `spec.md` `### Merge algorithm` apply unchanged. Lines outside blocks are never
  edited except that trailing blank lines are reduced so the page ends with exactly one LF.
- A block whose identifier is not among the page's planned elements is deleted and reported in
  `blocks.removed` and by one `DOCS_REFERENCE_BLOCK_REMOVED` finding.
- Byte identity: identical profile, snapshot and existing-page text produce identical page text
  and identical envelope bytes, independent of snapshot element order and of the order of the
  existing-page map; LF only; UTF-8 without BOM (written by `Write-DocsFileText`); no trailing
  spaces on generated lines.

## 6. Checker Integration Without Temporary Files (Question 5)

Two suites, both in memory:

1. Pure level (`DocsReferenceWriter.CheckerIntegration.Tests.ps1`, first `Describe`): build a
   profile and snapshot as hashtables (elements through `New-DocsSurfaceElement`), call
   `New-DocsReferenceChangeSet`, collect `path -> text` for the generated pages, add an entry page
   (for example `docs/README.md`) with conforming front matter that links each generated page, and
   pass the map to the 1021 pure aggregate check function with an in-memory path-existence predicate
   and the composed schema set built from committed schema text. Assert zero findings. Repeat after
   inserting author prose (paragraphs, a fenced block containing a marker-like line, headings that
   are not instructional) around and between blocks and regenerating.
2. Command level (second `Describe`): seed the 1020 in-memory context from
   `tests/scripts/claude-lib/docs/Docs.TestSupport.psm1` (scriptblocks over a hashtable of relative
   path to text, with a write log and a fixed clock) with the profile JSON, the snapshot JSON and the
   entry page; run `Invoke-DocsGenerateReferenceCommand -Argument @{ Write = $true } -Context $ctx`;
   then run the 1021 command function (expected `Invoke-DocsCheckCommand`, not yet fixed) with
   arguments that select the docs root and the entry page, against the same context. Assert exit 0
   and an empty `Findings`. The write log of the first command is the page set the second command
   lists and reads, so the two commands are exercised end to end with no file.

Constraints: committed schema files are read once with `Get-Content -Raw` (read-only, permitted;
the 1020 plan [P3-T2] reader does this); no `TestDrive`, `New-TemporaryFile`, `GetTempPath` or
`$env:TEMP`. The 1021 pure function name, its parameters (page map, configuration, path-existence
predicate, schema set) and the 1021 command function name are not fixed (dependency risk R-1).

## 7. Public Function Inventory (Question 6)

Notation: P = pure (strings, string arrays, hashtables; no file, clock, process, environment or
module-scope state); IO = touches the command context. Every function is an advanced function with
`[CmdletBinding()]` and an approved verb.

### 7.1 Mapping of the six functions named by the halted preflight

| Halted Python function (`spec.md` `## Module Boundaries`) | PowerShell function | Module | Property tested over the seeded set |
|---|---|---|---|
| `page_plan.resolve_output_dir` | `Resolve-DocsReferenceOutputDirectory -Profile <IDictionary> [-OutputDirectory <string>] -ProfilePath <string>` returns `@{ OutputDirectory; Findings }` | `DocsReferencePlan.psm1` | With a valid override the result equals the override for every drawn profile; without one the result is defined exactly when the drawn profile has one glob-free `reference` entry, equals that entry's path, and is invariant under permutation of the other `directory_modes` entries; otherwise exactly one `DOCS_REFERENCE_OUTPUT_DIR_UNRESOLVED` finding. |
| `page_plan.candidate_page_paths` | `Get-DocsReferenceCandidatePagePath -OutputDirectory <string>` returns `[string[]]` | `DocsReferencePlan.psm1` | For every drawn relative directory: one path per family row, ordinal-sorted, each equal to `<dir>/<file>`, each passing `Test-DocsRelativePath`, no duplicates, and the same output on a second call. |
| `markdown_text.source_line` | `Get-DocsReferenceSourceLine -Path <string> [-LineRange <int[]>]` returns `[string]` | `DocsReferenceRender.psm1` | For drawn paths (including backticks, control characters and leading or trailing spaces) and drawn ranges: a single line beginning `- Source: `; the code span decodes to `ConvertTo-DocsReferenceSingleLine` of the path; the `(lines a-b)` suffix is present exactly when a range is given and carries its start and end. |
| `front_matter.split_front_matter` | `Split-DocsReferenceFrontMatter -Line <string[]>` returns `@{ FrontMatterLine; BodyLine; LineOffset; Terminated }` | `DocsReferenceWriter.psm1` | For drawn field sets and drawn bodies: splitting `render + body` returns the rendered lines and the body unchanged with `LineOffset` equal to the front-matter line count; a body whose first line is not `---` returns no front matter and the body unchanged; concatenating the parts reproduces the input. |
| `front_matter.read_existing` | `ConvertFrom-DocsReferenceExistingPage -Text <string> -Path <string>` returns `@{ Value; BodyLine; LineOffset; Findings }` | `DocsReferenceWriter.psm1` | Round trip: for drawn valid values, rendering with `ConvertTo-DocsReferenceFrontMatterText` and reading back returns the same values with no finding; a drawn single-field corruption yields exactly one `DOCS_REFERENCE_FRONT_MATTER_INVALID` naming that field; the function never throws for any drawn text (including CRLF, BOM and unterminated blocks). |
| `report.render_text` | `Get-DocsReferenceReportLine -ChangeSet <IDictionary> -Mode <dry-run\|write>` returns `[string[]]` | `DocsReferenceWriter.psm1` | For drawn change sets: one page line per page in ordinal path order whose `+`, `~` and `-` counts equal the block list lengths; diff lines present only in dry run; one entry-page note per `create`; output identical under permutation of the page input order. |

### 7.2 `DocsReferencePlan.psm1`

| Function | Kind | Property (pure functions) |
|---|---|---|
| `Get-DocsReferenceFamily` (family table of section 5.2) | P | Kinds across rows are disjoint, exclude `architecture-component`, and their union with it equals `Get-DocsElementKind`. |
| `Test-DocsReferencePathCovered -Path -Pattern` (section 5.4; home is OQ-B) | P | Agrees with its definition for drawn paths and patterns: equality and `E/` prefix always cover; a glob-free pattern covers exactly by equality or prefix; flipping the case of one letter in a glob-free pattern removes coverage; `*` crosses `/`. |
| `Resolve-DocsReferenceOutputDirectory` | P | Section 7.1. |
| `Get-DocsReferenceCandidatePagePath` | P | Section 7.1. |
| `ConvertFrom-DocsReferenceSnapshotText -Text -ArtifactPath -ComposedSchemaSet` (validate, rebuild elements, detect duplicate identifiers and duplicate property names) | P (calls built-in `Test-Json`) | Snapshot text serialized from drawn `New-DocsSurfaceElement` records returns the same elements sorted by `element_id`; a drawn duplicated element yields `DOCS_REFERENCE_SNAPSHOT_INVALID`. |
| `Get-DocsReferenceElementOrder -Family -Element` (per-family sort keys of `spec.md` `#### Element order within a page`) | P | Output invariant under permutation of the input; each `cli-option` follows its parent command; orphan options follow all commands. |
| `Get-DocsReferencePagePlan -Profile -Element -OutputDirectory -ExistingPath` (pages, ordered elements, owner, root, audience, page findings, unrendered count) | P | Invariant under element permutation and `ExistingPath` order; every rendered element is on exactly one page; no `architecture-component` is placed and the unrendered count equals their number; a page is planned exactly when its family is non-empty or the page exists. |

### 7.3 `DocsReferenceRender.psm1`

| Function | Kind | Property |
|---|---|---|
| `ConvertTo-DocsReferenceSingleLine -Text` | P | Output has no `Cc`, `Zl`, `Zp` character, no leading, trailing or double space; idempotent. |
| `ConvertTo-DocsReferenceCodeSpan -Text` | P | A CommonMark code-span decoder written in the test returns the input; the delimiter is longer than every internal backtick run. |
| `Get-DocsReferenceSourceLine` | P | Section 7.1. |
| `Get-DocsReferencePropertyLine -Property` | P | One line per property, ordinal-sorted by name; output invariant under input permutation; values equal canonical JSON. |
| `Get-DocsReferenceCliCommandBody`, `Get-DocsReferenceCliOptionBody`, `Get-DocsReferenceHttpRouteBody`, `Get-DocsReferenceConfigKeyBody`, `Get-DocsReferencePublicSymbolBody` | P | For drawn elements of the kind (declarations including ones beginning `how to` or `Step 1`): the heading begins with the fixed word and level, so no heading text matches `(?i)^how to ` or `(?i)^step\s+[0-9]+\b`; no line begins with `<`; no line matches a marker. |
| `Get-DocsReferenceBlockBody -Element` (`switch -CaseSensitive` dispatch; throws for `architecture-component` or an unknown kind) | P | Equals the matching per-kind function for every drawn element; deterministic. |

Size: estimated 300 to 450 logical lines with help blocks. If the estimate or the result reaches
500, the text helpers (`ConvertTo-DocsReferenceSingleLine`, `ConvertTo-DocsReferenceCodeSpan`,
`Get-DocsReferenceSourceLine`, `Get-DocsReferencePropertyLine`) move to
`DocsReferenceRenderText.psm1`, which the owner-fixed set permits for the renderer.

### 7.4 `DocsReferenceMarkers.psm1`

| Function | Kind | Property |
|---|---|---|
| `Get-DocsReferenceStartMarker -ElementId`, `Get-DocsReferenceEndMarker -ElementId` | P | For every drawn identifier of every kind, `ConvertFrom-DocsReferenceMarkerLine` of the output returns the same kind of marker and identifier. |
| `ConvertFrom-DocsReferenceMarkerLine -Line` (start, end, malformed, or not a marker) | P | Total over drawn lines; any line whose trimmed text starts with `<!-- docs:generated:` and is not exact is malformed. |
| `Split-DocsReferenceTextLine -Text` | P | Joining with LF reproduces the LF-normalized input; CRLF and LF variants of a drawn text give equal arrays. |
| `Get-DocsReferenceBlockStructure -Line -Path -LineOffset` (fence-aware parse) | P | For drawn well-formed pages: the blocks found equal the blocks inserted; a drawn single anomaly yields exactly its finding code; marker-like lines inside fenced code are ignored. |
| `Merge-DocsReferenceBlock -Line -Desired -Path -LineOffset` | P | Idempotence (second merge with the same `Desired` returns identical lines, all `unchanged`); prose preservation (non-blank lines outside blocks keep their order; each prose segment is byte-identical when identifier sets are equal); removal (identifiers absent from `Desired` are in `Removed` and absent from the output); additions are placed per `spec.md` merge step 4. |

### 7.5 `DocsReferenceWriter.psm1`

| Function | Kind | Property |
|---|---|---|
| `Split-DocsReferenceFrontMatter` | P | Section 7.1. |
| `ConvertFrom-DocsReferenceExistingPage` | P | Section 7.1. |
| `ConvertTo-DocsReferenceFrontMatterText -Value <IDictionary>` | P | Fixed field order; the 1021 parser (or `ConvertFrom-DocsReferenceExistingPage` until R-2 is settled) returns the input; drawn valid values pass `Test-Json` against the committed page-metadata schema. |
| `Get-DocsReferenceFrontMatterValue -Existing -PagePlan -CapturedAt` | P | Valid existing `owner`, `audience`, `last_reviewed`, `title`, `extensions` are preserved; `diataxis_mode` is always `reference`; `surface_refs` equals the sorted identifiers rendered; `last_reviewed` for a new page equals the `captured_at` date prefix. |
| `ConvertFrom-DocsReferencePageByte -Bytes` (strict UTF-8 decode, BOM removal, line-ending normalization) | P | Decoding UTF-8 bytes of drawn text with and without BOM and with CRLF returns the LF form; invalid bytes throw a typed error. |
| `New-DocsReferencePage -PagePlan -ExistingText -CapturedAt` (front matter plus merge plus action) | P | Applying it to its own output yields action `none`. |
| `New-DocsReferenceChangeSet -Profile -Snapshot -ExistingPage <IDictionary> -OutputDirectory -ProfilePath` | P | Two runs and a run over a permuted element order and a re-ordered `ExistingPage` map give identical page text and identical canonical JSON of the result; regeneration over its own output gives `none` for every page. |
| `Get-DocsReferenceDiffLine -Change` | P | Applying the hunks to the old lines reproduces the new lines; `none` gives no lines; `create` gives only `+` lines equal to the new text. |
| `Get-DocsReferenceReportLine` | P | Section 7.1. |
| `ConvertTo-DocsReferenceResult -ChangeSet -Mode -Status` | P | Key sets equal the section 5.10 contract; canonical JSON identical under page input permutation. |
| `Read-DocsReferenceInput -ReadText <scriptblock> -ReadBytes <scriptblock> -TestFile <scriptblock> ...` (private) | IO | Not a property target; covered by in-memory context tests. |
| `Write-DocsReferenceChange -WriteText <scriptblock> -ReadBytes <scriptblock> -ChangeSet` (private; digest re-check, ordered writes, stop on first failure) | IO | Covered by in-memory context tests (conflict, failure, success order). |
| `Invoke-DocsGenerateReferenceCommand -Argument <IDictionary> -Context <object>` | IO (through the context only) | Covered by command tests; never prints and never calls `exit`. |

Imports (literal `Join-Path -Path $PSScriptRoot -ChildPath '<leaf>'`): `DocsReferencePlan.psm1` ->
`DocsJson.psm1`, `DocsFinding.psm1`, `DocsSurface.psm1`, `DocsSchema.psm1`; `DocsReferenceRender.psm1`
-> `DocsJson.psm1`; `DocsReferenceMarkers.psm1` -> `DocsFinding.psm1`, `DocsSurface.psm1`;
`DocsReferenceWriter.psm1` -> the three 1024 siblings, `DocsProfile.psm1`, `DocsSchema.psm1`,
`DocsFinding.psm1`, `DocsJson.psm1`, and (if R-2 resolves to reuse) `DocsPageFrontMatter.psm1`. The
epic 1021 criterion forbids page-check modules from importing reference modules; the reverse
direction is not forbidden.

Size: `DocsReferenceWriter.psm1` holds front matter, composition, diff, report, result and the
command. The estimate is 550 to 700 logical lines, above the 500-line guidance and below the
800-line hard limit. The owner-fixed set permits a split only for the renderer (OQ-C).

## 8. Artifact Classification (Question 7)

Rule references: R1 = language rule clause (1) (pushed-down skills, helpers, hooks and libs are
PowerShell or bash); R2 = clause (2) (TypeScript only for MCP and extension commands; no row uses
it); D = epic `### Artifact classes for this epic` (schema, configuration, data, test and
documentation rows). "Avoid new Python" applies to every row. B =
`extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`.

| File | Change | Class | Language | Permitting rule |
|---|---|---|---|---|
| `.claude/lib/docs/DocsReferencePlan.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceRender.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceRenderText.psm1` | create only if the renderer reaches 500 lines | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceMarkers.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceWriter.psm1` | create | pushed-down helper/lib (command module) | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceFrontMatter.psm1` | create only if the owner approves OQ-C | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | edit: one row under the 1024 anchor | pushed-down helper/lib (entry) | PowerShell | R1 |
| B`DocsReference*.psm1` (one copy per created module) | create | pushed-down helper/lib (mirror) | PowerShell | R1 |
| B`Invoke-DocsCommand.ps1` | edit (byte-identical to the source) | pushed-down helper/lib (mirror) | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | edit: one `paths` entry per created module | schema/config/data | JSON | D |
| `tests/scripts/claude-lib/docs/DocsReferencePlan.Tests.ps1`, `DocsReferencePlan.Properties.Tests.ps1` | create | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/DocsReferenceRender.Tests.ps1`, `DocsReferenceRender.Properties.Tests.ps1` | create | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/DocsReferenceMarkers.Tests.ps1`, `DocsReferenceMarkers.Properties.Tests.ps1` | create | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/DocsReferenceWriter.Tests.ps1`, `DocsReferenceWriter.Properties.Tests.ps1`, `DocsReferenceWriter.Command.Tests.ps1`, `DocsReferenceWriter.CheckerIntegration.Tests.ps1` | create | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/DocsReferenceRenderText.Tests.ps1` (and `DocsReferenceFrontMatter.Tests.ps1`) | create only with the matching split | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/DocsReference.TestSupport.psm1` (seeded draw helper and drawn profiles, snapshots, prose and front matter) | create | test (support module) | PowerShell (Pester) | D |
| The 1023 single-write-boundary suite (path fixed by 1023) | edit only if section 9 finds it flags `Context.WriteText` in `DocsReferenceWriter.psm1` | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-reference-generator-1024/**` (spec, user story, plan, evidence) | edit/create | documentation | Markdown | D |

Not created or edited: any Python or TypeScript file, `pyproject.toml`, `poetry.lock`,
`quality-tiers.yml`, `config/poshqc-coverage.json`, `config/poshqc-scan.json`, any schema (1024
reads `page-metadata.schema.json` and `docs-command-envelope.schema.json` in tests only), any hook,
skill, agent, MCP tool or extension command. Every artifact follows the language rule; no language
exception is needed.

## 9. Existing Tests Needing a Disposition (Question 8)

| Test | What it enumerates | Disposition for 1024 |
|---|---|---|
| `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` | Every `*.psm1` under `.claude/lib` (recursive) | Unchanged; new modules must comply. |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | Every PowerShell file under its scan roots, including `.claude/lib` | Unchanged; section 4 design; no allowlist entry. |
| `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | `.claude/hooks` and `.claude/lib` | Unchanged; 1024 calls no checkpoint reader. |
| `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` | Repository files against the 800-line limit and `config/file-size-baseline.json` | Unchanged; no new file may exceed 800 logical lines. |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | Every distributable `.claude` file versus the bundle | Unchanged; satisfied by the mirror copies and the mirrored entry script. |
| `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | `$PSScriptRoot` targets of manifested PowerShell files | Unchanged; satisfied by core entries and literal joins. |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` and its TypeScript twin `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` | Bundled agents, hooks and skills only | Not affected. |
| `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` (`SOLUTION_SCAN_ROOTS` includes `.claude/lib`) | Text under the roots for solution-file names | Unchanged; no new file names a solution file. |
| `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` (`SPEC_TIER_ASSIGNMENTS`) | Fixed spec table of projects | Not affected; 1024 adds no project folder. |
| `tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1` | Modules imported by registered hooks | Not affected unless a hook imports a 1024 module (none planned). |
| 1020 `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` (not yet on the branch) | `Test-DocsCommandTable` over the committed table; anchor order read from the script text | Unchanged if it asserts membership and anchor order (epic `### Analyzer decisions from the first preparation of 1022` requires membership); the planner confirms against the merged 1020 suite. |
| 1020 `Docs.Manifest.Tests.ps1` (not yet on the branch) | Every file under `.claude/lib/docs/` recursively: core membership and bundle SHA-256 | Unchanged; new files are covered once listed and mirrored. |
| 1020 `DocsNeutrality.Tests.ps1` (not yet on the branch) | One case per file under `.claude/lib/docs/`, `schemas/docs/`, `examples/docs/` | Unchanged; new files are scanned automatically. |
| 1021 suites (not yet on the branch) | Unknown in the PowerShell redesign | Planner checks for any enumeration of `.claude/lib/docs/` files or command rows. |
| 1023 single-write-boundary test (not yet on the branch; the 1020 spec requires it to allowlist `Write-DocsFileText` in `Invoke-DocsCommand.ps1`) | Write primitives under `.claude/lib/docs/` | Risk: if it flags any `WriteText` use outside `DocsLedgerMutation.psm1`, 1024 adds one allowlist entry for `DocsReferenceWriter.psm1` with the reason "reference pages, only with -Write"; otherwise unchanged. The planner records which. |

## 10. Testing Implications

### 10.1 Pester rule and CI

- Runner and jobs: the suites run under `Invoke-PoshQCTest` in `poshqc / PowerShell QC shard 1`,
  `shard 2` or `shard 3` and are aggregated by the required context `poshqc / PowerShell QC`, all on
  `windows-latest`; formatting and analysis run in `poshqc / PowerShell QC static`. The Python
  contract tests of section 3 run in `quality-checks7 / Code Quality & Tests (3.10)` to `(3.13)`.
- Branch-current local runs import `scripts/powershell/PoshQC/PoshQC.psd1` and call
  `Invoke-PoshQCTest` from a `sh`-launched PowerShell 7 (execution-environment brief); counts come
  from `artifacts/pester/pester-junit.xml` and per-file line coverage from
  `artifacts/pester/powershell-coverage.xml`, because PoshQC MCP results carry no output.
- Coverage: line coverage of at least 85% for each 1024 production file; no branch gate for Pester;
  no production file excluded. Evidence goes to `<FEATURE>/evidence/qa-gates/`, not the
  non-canonical `evidence/coverage/` named in the current `spec.md` `### Coverage gate`
  (`EVIDENCE_LOCATION_OVERRIDE_REJECTED: <FEATURE>/evidence/coverage/ replaced with
  <FEATURE>/evidence/qa-gates/`).

### 10.2 Property harness

- `DocsReference.TestSupport.psm1` exports `New-DocsReferenceDraw -Seed <int>` (returns a hashtable
  holding a `[System.Random]` built with the seed) and drawing helpers (`Get-DocsReferenceDrawInt`,
  `Get-DocsReferenceDrawText -Alphabet -MaxLength`, `Get-DocsReferenceDrawElement -Kind`,
  `Get-DocsReferenceDrawProfile`, `Get-DocsReferenceDrawProse`, `Get-DocsReferenceDrawFrontMatter`).
  It keeps no module-scope state between calls; each `It` builds its own draw.
- Seeds `@(11, 23, 47, 101, 211)` defined in `BeforeDiscovery`; each property `It` uses
  `-ForEach` over the seeds and draws a fixed number of cases per seed; every `Should` carries
  `-Because "seed $Seed case $i"`.
- Drawn alphabets include backticks, `<`, `#`, `---`, marker-like text, U+2028, tabs, CR and
  non-ASCII letters, so the escaping and splitting properties are exercised.

### 10.3 Example-based suites

- Each finding code with its trigger; each marker anomaly blocks only its page.
- Command tests with the 1020 in-memory context: dry run makes no `WriteText` call and returns
  status `planned`; `-Write` writes in path order with modes `create` and `overwrite`; a second run
  writes nothing and reports `none`; digest mismatch, existing create target and a throwing
  `WriteText` each exit 3 with one finding and `result` null; any `error` finding exits 1 with no
  write; exit 2 for each usage error; `-Json` envelope validates against the envelope schema and two
  runs give identical bytes.
- Front-matter conformance and pattern pinning against the committed page-metadata schema text.
- CRLF and BOM inputs are built in memory (`"a`r`nb"`, `[byte[]](0xEF,0xBB,0xBF) + ...`), never as
  committed fixtures, because `.gitattributes` `* text=auto eol=lf` normalizes committed text.

### 10.4 Isolation

- Every suite removes the `Docs*` modules (1020, 1021 and 1024) in `AfterAll`; dot-sourcing
  `Invoke-DocsCommand.ps1` imports modules into the session (1020 `## Constraints & Risks`).
- Three seeded shuffled file-order runs of the docs suites in one process and one fresh
  single-process run over `tests/scripts`, recorded under `<FEATURE>/evidence/regression-testing/`.

### 10.5 Batch budget

Four to six production PowerShell files plus their bundle copies, and the edited entry script plus
its copy, exceed the direct-mode cap of three. Execution runs in the item worktree under a
`large`, `remediation` or `preparation` checkpoint route (execution-environment `## Batch Budget`),
not in an isolated executor worktree.

## Numeric Derivation Evidence

These counts support the function mapping and file statements in this addendum; the planner
restates them in `spec.md` only after re-deriving them.

### Claim N1: pure functions the halted preflight named

- Complete Family: resolve_output_dir, candidate_page_paths, source_line, split_front_matter, read_existing, render_text
- Exhaustive Search Scope: the delegation list of pure functions lacking property tests, and every public function in `spec.md` `## Module Boundaries` of 1024 (all modules) together with earlier research `### 4.2 Proposed module responsibilities`
- Inclusion Rules: pure public functions named as lacking a property test by the halted preflight
- Exclusion Rules: functions that already had a named property test in `plan.2026-10-30T16-54.md` (for example `merge_blocks`, `code_span`, `render_front_matter`, `path_covered`, `load_snapshot`, `generate_reference`)
- Primary Search Strategy or Query Expression: enumerate the six names in the delegation prompt (resolve-output-directory, candidate page paths, source line, split front matter, read existing page, render text) and resolve each to its Python identifier in `spec.md` `## Module Boundaries`
- Primary Member Set: resolve_output_dir, candidate_page_paths, source_line, split_front_matter, read_existing, render_text
- Primary Count: 6
- Cross-check Search Strategy or Query Expression: Grep over `docs/features` for `resolve_output_dir|candidate_page_paths|source_line|split_front_matter|read_existing|render_text`, keeping matches in the 1024 folder (`spec.md` module table rows for `page_plan.py`, `markdown_text.py`, `front_matter.py`, `report.py`; earlier research `### 4.2` lines for `front_matter.py` and `report.py`)
- Cross-check Member Set: resolve_output_dir, candidate_page_paths, source_line, split_front_matter, read_existing, render_text
- Cross-check Count: 6
- Member-set Comparison: the normalized sets are equal; each maps to one PowerShell function in section 7.1 (two in `DocsReferencePlan.psm1`, one in `DocsReferenceRender.psm1`, three in `DocsReferenceWriter.psm1`)

### Claim N2: production PowerShell modules created by 1024 (before contingent splits)

- Complete Family: DocsReferencePlan.psm1, DocsReferenceRender.psm1, DocsReferenceMarkers.psm1, DocsReferenceWriter.psm1
- Exhaustive Search Scope: epic `### 1024 - docs-reference-generator (wave 2, C3)` Files (create) and the section 8 classification table of this addendum
- Inclusion Rules: `.psm1` files under `.claude/lib/docs/` created unconditionally by 1024
- Exclusion Rules: contingent split modules (`DocsReferenceRenderText.psm1`, `DocsReferenceFrontMatter.psm1`), the edited `Invoke-DocsCommand.ps1`, bundle copies, test files
- Primary Search Strategy or Query Expression: read the epic 1024 Files (create) list
- Primary Member Set: DocsReferencePlan.psm1, DocsReferenceRender.psm1, DocsReferenceMarkers.psm1, DocsReferenceWriter.psm1
- Primary Count: 4
- Cross-check Search Strategy or Query Expression: filter the section 8 table to rows with change `create` (unconditional) and class `pushed-down helper/lib` under `.claude/lib/docs/`
- Cross-check Member Set: DocsReferencePlan.psm1, DocsReferenceRender.psm1, DocsReferenceMarkers.psm1, DocsReferenceWriter.psm1
- Cross-check Count: 4
- Member-set Comparison: equal; with the contingent splits the total is five or six, and each has a bundle copy and a core entry

### Claim N3: rendered family pages

- Complete Family: cli-reference.md, http-reference.md, config-reference.md, api-reference.md
- Exhaustive Search Scope: epic `### Generator decisions from the first preparation of 1024` and `spec.md` `### Page-plan rules`
- Inclusion Rules: fixed family page file names
- Exclusion Rules: entry or index pages (none generated)
- Primary Search Strategy or Query Expression: read the epic bullet "Fixed family pages"
- Primary Member Set: cli-reference.md, http-reference.md, config-reference.md, api-reference.md
- Primary Count: 4
- Cross-check Search Strategy or Query Expression: map each non-architecture element kind in the 1020 `element-kind` enum to its page in `spec.md` `### Page-plan rules` and take the distinct pages
- Cross-check Member Set: cli-reference.md (cli-command, cli-option), http-reference.md (http-route), config-reference.md (config-key), api-reference.md (public-symbol)
- Cross-check Count: 4
- Member-set Comparison: equal

## Pre-Mortem

- Review checklists: a reviewer can flag a command module that prints or exits, an `&` on a member or a non-scriptblock variable, a pure function that reads the clock, a non-literal `$PSScriptRoot` use, an unapproved verb, or a property test missing for one of the six named functions; the plan must carry one property test per pure public function (section 7), run the existing dynamic-invocation and convention suites, and include a self-review row per acceptance criterion.
- Coverage: the command function and the private I/O helpers can fall below 85% line coverage if only the pure layer is tested; the plan must drive every exit path (0, 1, 2, 3; conflict, failure, success) through the 1020 in-memory context and read per-file figures from `artifacts/pester/powershell-coverage.xml`, because the `poshqc / PowerShell QC` aggregator enforces no per-file threshold; no file is excluded and no branch gate applies.
- Mirror parity: each new module and the edited `Invoke-DocsCommand.ps1` must be byte-identical in the bundle and listed in Claude `core.json`; the plan must run `Docs.Manifest.Tests.ps1`, `test_push_down_claude_resource_contracts.py` and `test_push_down_pack_manifest_dependency_closure.py` after the last edit, and re-copy the entry script if a concurrent sibling changed it; no execution-environment brief fact changes, so no brief-update task is needed.
- File size: `DocsReferenceWriter.psm1` is estimated at 550 to 700 logical lines and the renderer near 500; the plan must record logical line counts, apply the permitted renderer split, and carry the owner answer to OQ-C before the writer passes 500 (700 draws a review warning, 801 fails `FileSizePolicy.RepoGate.Tests.ps1` and the PreToolUse hook).
- Test isolation: property suites and the checker integration suite import 1020, 1021 and 1024 modules into one process, and shard runs expose leaked modules; the plan must remove every `Docs*` module in `AfterAll`, keep the draw helper free of module-scope state, and record three seeded shuffled file-order runs plus one fresh single-process run over `tests/scripts`.
- CI-only behavior: the `windows-latest` PowerShell and its bundled JsonSchema.Net decide `Test-Json` results for the page-metadata and envelope schemas, and `.gitattributes` `eol=lf` strips committed CRLF fixtures; the plan must build CRLF and BOM inputs in memory, assert codes and pointers rather than validator wording, use forward-slash relative paths, and read no gitignored `artifacts/` state in tests.
- Evidence: the current `spec.md` names `evidence/coverage/`, which is non-canonical; the plan must write coverage and gate evidence under `<FEATURE>/evidence/qa-gates/`, isolation runs under `<FEATURE>/evidence/regression-testing/`, use write-time UTC stamps, record `SCRATCH` for scratch paths, and scan every changed file for the restricted consumer tokens with bracket-class patterns.

## Rejected Alternatives (summary)

- Importing `.claude/lib/mermaid/MermaidMarkdownFences.psm1` for fence detection (different
  blockquote rule, cross-area coupling; section 2.2).
- PowerShell wildcard matching and `BlastRadiusGlob.psm1` for `path_or_glob` (semantics differ from
  `fnmatchcase`; module cache; section 5.4).
- `Context.UtcNow` for `last_reviewed` (breaks byte identity across days; section 5.7).
- A general LCS unified diff or `Compare-Object` for the dry run (section 5.9).
- A scriptblock table for renderer dispatch (fails the dynamic-invocation guard; section 4).
- A per-command result schema file owned by 1024 (the envelope schema is a 1020 artifact; section
  5.10).

## Owner Questions and Dependency Risks (Question 9)

No artifact needs a language exception. The items below are contract gaps the planner must not
decide.

Owner or coordinator questions:

1. **OQ-A - Dispatch anchor label.** The 1020 spec `#### Dispatch table` and plan [P4-T4] write
   the anchor as `# --- 900006: generate-reference ---` (the pre-promotion placeholder), while the
   epic calls it the 1024 anchor. The 1020 amendment decides the label; 1024 inserts its row under
   whichever label is committed and never edits the anchor line. Provisional default: use the
   committed label verbatim.
2. **OQ-B - Home of the path-coverage function.** 1023 (wave 1) and 1024 (wave 2) must share one
   `path_or_glob` matcher, but 1024 does not depend on 1023. Options: (a) the 1020 amendment adds
   `Test-DocsPathCovered` to `DocsSurface.psm1` or `DocsProfile.psm1` and both children call it;
   (b) 1024 defines `Test-DocsReferencePathCovered` in `DocsReferencePlan.psm1` and a parity test
   pins it to the 1023 function; (c) 1024 imports the 1023 module (adds a 1023 edge to the manifest).
   Provisional default: (a), because 1020 is being re-planned now.
3. **OQ-C - Split of `DocsReferenceWriter.psm1`.** The owner-fixed module set permits a split only
   for the renderer. The writer is estimated above the 500-line guidance. Provisional default: allow
   one additional module `DocsReferenceFrontMatter.psm1` (split, read, render and value rules of
   front matter) with its own suite, bundle copy and core entry.

Dependency risks (contracts not yet fixed by 1021 or the 1020 amendment):

- **R-1 - 1021 check entry points.** The PowerShell 1021 has no committed pure aggregate check
  function or command function name; the integration test (section 6) needs a function that takes a
  page map, configuration, a path-existence predicate and a schema set, and a command function
  (expected `Invoke-DocsCheckCommand`) that lists pages through `Context.ListFile`.
- **R-2 - Front-matter grammar.** The 1021 bounded parser (`DocsPageFrontMatter.psm1`) defines which
  YAML subset passes; 1024 must emit inside it. The JSON-flow line form of section 5.7 is a proposal;
  support for `extensions` (an open object) and for `...` as a terminator is unconfirmed. If 1021
  exports pure split and parse functions, 1024 should call them inside
  `ConvertFrom-DocsReferenceExistingPage` instead of duplicating the grammar.
- **R-3 - 1021 rules and codes.** The finding codes (`FRONT_MATTER_*`, `LINK_*`,
  `DIATAXIS_MODE_MISMATCH`, `PAGE_ORPHANED`), the Diataxis signals (`DX-NO-INSTRUCTION`,
  `DX-GENERATED-REFERENCE`), the fence rule, the default root and entry pages, and the
  page-metadata schema (self-contained or referencing docs common) are stated only in the withdrawn
  Python 1021 spec.
- **R-4 - Audience pattern.** The epic fixes `^[a-z0-9][a-z0-9-]*$` for profile audience
  identifiers and page-metadata `audience`; the current 1020 spec still uses the discovery
  `identifier` grammar for profile audiences.
- **R-5 - Element shape after the amendment.** `analysis_method` and the declaration-lines digest
  change the snapshot `element` definition; `ConvertFrom-DocsSurfaceElement` must accept the amended
  shape.
- **R-6 - Envelope schema scope.** Whether `docs-command-envelope.schema.json` constrains `result`
  per command (requiring a 1024 row or anchor in that schema) or leaves it open is not stated.
- **R-7 - 1023 write-boundary test scope.** See section 9.

## Items for the Orchestrator to Confirm

- Whether the 1020 amendment and the 1021 PowerShell re-preparation exist on other branches, and
  their committed function names (needs `git show` or `gh`); this worktree holds neither.
- The anchor label committed in `Invoke-DocsCommand.ps1` by the amended 1020 (OQ-A).
- Whether `ConvertFrom-DocsCommandArgument` validates path-valued options (exit 2) or leaves that to
  the command function, given the option kinds `value`, `multi` and `switch`.
- Whether the real `Context.WriteText` mode `create` fails when the target exists (needed for the
  conflict rule in section 5.8).
- That `[System.Random]::new(<seed>)` yields the same sequence on the `windows-latest` PowerShell as
  locally (the 1020 acceptance criterion relies on the same property).
- That a regex translation reproduces `fnmatch.fnmatchcase` for the patterns the profile schema
  admits, including `[!...]` classes, and that PowerShell `-clike` does not (section 5.4).
- The PowerShell version on the `windows-latest` runner and its `Test-Json` behavior for the
  page-metadata and envelope schemas.
- Owner answers to OQ-A, OQ-B and OQ-C.
- The adjusted research filename (header note) for later references.
