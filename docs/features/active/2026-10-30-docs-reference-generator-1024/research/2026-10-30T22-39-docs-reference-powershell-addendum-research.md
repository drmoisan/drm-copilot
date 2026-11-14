# docs-reference-generator (1024) - PowerShell Design Addendum Research

- Issue: #1024 (epic #1019, child 1024, wave 2, band C3; depends on 1020 and 1021)
- Branch: `feature/docs-reference-generator-1024`
- Timestamp: 2026-10-30T22-39
- Status: research for the re-preparation under owner decision D1 (new planning cycle)
- Supersedes for design purposes: `research/research.2026-10-30T20-59.md` (withdrawn Python design;
  not edited). Language-independent rules from that file and from `spec.md` v0.2 (marker grammar,
  merge algorithm, page-plan rules, front-matter field rules, rendering rules, finding catalog) are
  carried forward where this addendum does not change them; every Python mechanism is replaced.
- Requirement origin: one consumer repository. No identifier of that repository appears here.

## 1. Inputs and Binding Sources

Read in full: `docs/features/epics/documentation-estate-tooling/epic.md` (all sections, including
`## Owner Directive: Implementation Language (2026-10-30, refined)`, `### Artifact classes for this
epic`, `## Owner Decisions`, `### Amendment of 1020 required by D3 and D5`, `### PowerShell
contracts from the re-preparation of 1020`, `### Command contract decisions from the first
preparation of 1023`, `### Generator decisions from the first preparation of 1024`, `### Naming
contract (fixed for all children)`, `### 1024 - docs-reference-generator (wave 2, C3)`);
`docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md` (v0.3, including
`## Decisions Later Children Must Honor`); the 1020 addendum research
`research/2026-10-30T21-45-docs-profile-powershell-design-addendum-research.md` (sections 3.2 to
3.4); `docs/features/active/2026-10-30-docs-page-quality-checker-1021/spec.md` (v0.2); this
folder's `spec.md` v0.2, `plan.2026-10-30T16-54.md`, and both `evidence/other/preflight-fixes.*.md`
records.

Precedence applied in this document:

1. Owner decisions D1, D3, D4, D5 and the refined language directive.
2. D5 supersedes the epic sentence in `### PowerShell contracts from the re-preparation of 1020`
   that the envelope has no schema file: the envelope schema is
   `schemas/docs/v1/docs-command-envelope.schema.json` (planned by the 1020 amendment).
3. Epic `### Generator decisions from the first preparation of 1024` and `### Naming contract`.
4. 1020 spec v0.3 for every PowerShell contract (module conventions, command context, exit codes,
   dispatch table, finding model).
5. 1021 spec v0.2 for language-independent checker rules only (page-metadata schema fields and
   patterns, finding codes, Diataxis rules, orphan rule, fence rule). Its Python mechanisms
   (PyYAML, jsonschema, `dev.docs.check`, `run_check`) are withdrawn by the directive; 1021 is
   being re-prepared concurrently, so every 1021 PowerShell symbol below is "planned by 1021".

Discrepancies observed on this branch (recorded, not resolved here):

- 1020 spec v0.3 still names the later owners by placeholder numbers: dispatch anchor
  `# --- 900006: generate-reference ---`, analyzer anchors `900003`/`900004`, and AC text listing
  anchors "1021, 900003, 1023, 900006 and 900008". The epic manifest now uses 1022 and 1024. The
  1024 row goes under whichever anchor line the amended 1020 spec fixes for generate-reference
  (coordination item C1).
- 1021 spec v0.2 still describes the Python package. Only its language-independent contracts are
  cited.
- 1020 spec v0.3 states "The envelope has no schema file"; D5 overrides it.

## 2. Verified versus Planned Citations

Verification method: Glob and Grep against this worktree; files opened with Read where a symbol is
named. "Exists" means present on this branch now; "planned" means named by a prepared spec and
absent from the tree.

| Path or symbol | State | Evidence |
|---|---|---|
| `.claude/lib/docs/` (any file) | planned by 1020 | Glob `.claude/lib/docs/*` returned no file |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` | planned by 1020 | Glob returned no file |
| `schemas/docs/**`, `examples/docs/**`, `tests/scripts/claude-lib/docs/**` | planned by 1020 | Glob returned no file |
| `.claude/lib/discovery-validation/DiscoveryEncoding.psm1` exporting `Get-DiscoverySha256Hex`, `Get-DiscoveryBytesSha256Hex`, `ConvertTo-DiscoveryCanonicalJson` | exists | `Export-ModuleMember` block read; canonical JSON sorts keys with `[StringComparer]::Ordinal` and appends one LF; throws `AUTHORIZATION_INPUT_INVALID` for non-JSON values |
| `.claude/lib/discovery-validation/DiscoveryValidation.psm1` `Get-DiscoveryRuntimeVersionError` | exists | Grep `^function` |
| `.claude/lib/mermaid/` (`MermaidGrammar.psm1`, `MermaidLineScanner.psm1`, `MermaidMarkdownFences.psm1`, `MermaidValidation.psm1`) | exists | Glob |
| `MermaidMarkdownFences.psm1` exporting `Split-MermaidTextLine`, `Get-MermaidFenceLine`, `Test-MermaidFenceClose`, `Get-MermaidFenceBlock` | exists | `Export-ModuleMember` read; fence pattern allows blockquote prefixes and requires an empty info string to close |
| `tests/scripts/claude-lib/mermaid/` (five suites including `MermaidMarkdownFences.Tests.ps1`) | exists | Glob; suite header states here-string fixtures, no file reads, no temporary files |
| `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` | exists | token `imports its siblings with -ErrorAction Stop`; file-size test for every library module |
| `config/poshqc-coverage.json` | exists | `roots` contains `.claude/lib` (new modules are measured without an edit) |
| `config/poshqc-scan.json` | exists | `test.scanFolders` contains `tests/scripts` (new suites are discovered and sharded without an edit) |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | exists | lists `.claude/lib/discovery-validation/*.psm1` and `.claude/lib/mermaid/*.psm1`; no `.claude/lib/docs/` entry yet |
| `quality-tiers.yml` | exists | every `.claude/lib/<area>` entry is T3 (for example `.claude/lib/mermaid`); no `.claude/lib/docs` entry yet (planned by 1020, T3) |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` and `EnforcementHooksNoPythonInvocation.Helpers.ps1`, `EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` | exists | scan roots include `.claude/lib`; detection class 3 flags any `CommandAst` whose command position is a variable that is not a `[scriptblock]`-typed parameter, or any non-constant expression (member access included); method calls such as `.Invoke()` are not `CommandAst` nodes |
| `.claude/hooks/check-powershell-test-purity.ps1` | exists | forbids `New-TemporaryFile`, `[System.IO.Path]::GetTempFileName`, `[System.IO.Path]::GetTempPath`, `$env:TEMP`, `$env:TMP`, `Start-Process` in Pester tests |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | exists | Glob |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` | exists | Glob |
| `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` (`test_every_psscriptroot_occurrence_is_recognized`) | exists | Grep line 355 |
| `.claude/skills/execution-environment/SKILL.md` (push-down contract tests, CI shape, isolation checks) | exists | Glob |
| `.github/workflows/_poshqc.yml` jobs `PowerShell QC static`, `PowerShell QC shard ${{ matrix.shard }}` (`shard: [1, 2, 3]`), `PowerShell QC`, `PowerShell hook suites (Linux)` | exists | Grep and Read; static and shard jobs and the aggregator run on `windows-latest`; `ci.yml` calls the workflow as job `poshqc` |
| `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`, `config/file-size-baseline.json`, `.claude/hooks/enforce-file-size-limit.ps1` | exists | Glob |
| `scripts/powershell/PoshQC/PoshQC.psd1`, `scripts/powershell/PoshQC/settings/pssa.settings.psd1` | exists | Glob |
| Seeded `[System.Random]` property tests in any Pester suite | absent (no precedent) | Grep `System\.Random` over `tests/scripts/*.ps1` returned no match; 1020's identity AC introduces the first one |
| `DocsJson.psm1` (`ConvertFrom-DocsJsonText`, `ConvertTo-DocsJsonText`, `ConvertTo-DocsCanonicalJson`, `Get-DocsSha256Hex`, `Get-DocsBytesSha256Hex`) | planned by 1020 | 1020 spec `### DocsJson.psm1 (pure)` |
| `DocsFinding.psm1` (`New-DocsFinding`, `Get-DocsOrderedFinding`, `Test-DocsFindingHasError`, `New-DocsCommandResult`, `ConvertTo-DocsEnvelopeText`, `ConvertTo-DocsReportText`) | planned by 1020 | 1020 spec `### DocsFinding.psm1 (pure)` |
| `DocsSchema.psm1` (`Read-DocsSchemaSet`, `Get-DocsComposedSchemaSet`, `Join-DocsSchemaText`, `Test-DocsArtifactText`) | planned by 1020 | 1020 spec `### DocsSchema.psm1` |
| `DocsSurface.psm1` (`Get-DocsElementKind`, `Test-DocsRelativePath`, `Get-DocsElementId`, `Test-DocsElementId`, `ConvertFrom-DocsSurfaceElement`, `New-DocsSurfaceElement`) | planned by 1020 | 1020 spec `### DocsSurface.psm1 (pure)` |
| `DocsProfile.psm1` (`ConvertFrom-DocsProfileText`, `Get-DocsDefaultProfilePath`) | planned by 1020 | 1020 spec `### DocsProfile.psm1` |
| `Invoke-DocsCommand.ps1` (`Get-DocsCommandTable`, `Test-DocsCommandTable`, `ConvertFrom-DocsCommandArgument`, `New-DocsCommandContext`, `Write-DocsFileText`, `Invoke-DocsCommandCli`) and the command context members `ReadText`, `ReadBytes`, `TestFile`, `ListFile`, `WriteText`, `UtcNow` | planned by 1020 | 1020 spec `### Entry script` |
| `tests/scripts/claude-lib/docs/Docs.TestSupport.psm1`, `Docs.Manifest.Tests.ps1` | planned by 1020 | 1020 spec `## Implementation Strategy` |
| `schemas/docs/v1/docs-command-envelope.schema.json`; `analysis_method` on snapshot elements | planned by the 1020 amendment (D3, D5) | epic `### Amendment of 1020 required by D3 and D5` |
| `.claude/lib/docs/DocsPageFrontMatter.psm1`, `DocsPageLinks.psm1`, `DocsPageDiataxis.psm1`, `DocsPageOrphans.psm1`, `DocsPageCheck.psm1`; `check` subcommand; `schemas/docs/v1/page-metadata.schema.json` and its runtime copy | planned by 1021 | epic `### 1021 - docs-page-quality-checker`; exact PowerShell function names are fixed by 1021's re-prepared spec |

## 3. Current State Analysis

- No docs lib, schema, example or test exists. Every upstream symbol is a prepared contract, so the
  1024 plan needs a precondition task that confirms each consumed symbol against the merged 1020
  and 1021 code on the integration branch before any 1024 task uses it (the old plan's [P0-T3]
  pattern, now against PowerShell exports).
- Reusable existing code:
  - Canonical JSON and SHA-256: reached through 1020 `DocsJson.psm1`, which delegates to
    `DiscoveryEncoding.psm1`. 1024 imports the docs wrappers, not the discovery module directly.
  - Fence detection: `Get-MermaidFenceLine` and `Test-MermaidFenceClose` exist, but their rule
    accepts blockquote-prefixed fences and quote-depth matching, which the 1021 fence rule
    (backtick or tilde, three or more, indent up to three, close by the same character with at
    least the same length) does not state. The generator's fence rule must equal the checker's, so
    1024 consumes the 1021 classifier (coordination item C6) rather than the Mermaid one.
  - Ordinal sorting precedent: `ConvertTo-DiscoveryCanonicalFragment` uses `[Array]::Sort($keys,
    [System.StringComparer]::Ordinal)`. PowerShell's `Sort-Object`, `-match`, `-like`, `-eq`,
    `-split` and `@{}` are case-insensitive and, for sorting, culture-aware by default. Every 1024
    ordering uses `[Array]::Sort` or `[System.Collections.Generic.List[string]]::Sort` with
    `[StringComparer]::Ordinal`, case-sensitive operators (`-cmatch`, `-ceq`, `-csplit`), and
    ordinal dictionaries (`[System.Collections.Generic.Dictionary[string,object]]::new([StringComparer]::Ordinal)`
    or the 1020 ordinal hashtables).
- Toolchain constraints:
  - The Python-invocation guard scans `.claude/lib`. `& $Context.WriteText ...` is a `CommandAst`
    whose command position is a member expression, which detection class 3 reports as
    `DynamicInvocation`. Context members are therefore called through a private helper whose
    parameters are `[scriptblock]`-typed (the approved carve-out (a)), for example
    `param([scriptblock] $WriteText) & $WriteText $path $text $mode`.
  - Page paths are repository-relative POSIX strings built by concatenation with `/`. `Join-Path`
    is used only for `$PSScriptRoot` sibling imports (the literal form the dependency-closure test
    recognizes); on Windows it would introduce backslashes into page paths.
  - `.gitattributes` `* text=auto eol=lf` normalizes committed text, so BOM and CRLF inputs are
    built in memory.

## 4. Candidate Approaches and Selection

Four design decisions had more than one viable approach.

### 4.1 Reading existing front matter

- A. 1024 owns a bounded parser for the five page-metadata fields. Advantage: no dependency on an
  unmerged 1021 function name. Limitation: two parsers for the same block; a page the generator
  accepts could be rejected by the checker, which breaks the zero-findings acceptance criterion.
- B. 1024 owns only the delimiter split (line 1 exactly `---`, end at the next `---` or `...`) and
  the canonical renderer, and parses field values with the 1021 bounded front-matter parser from
  `DocsPageFrontMatter.psm1`. Advantage: one parser, so generator and checker agree by
  construction; the dependency direction (reference imports page-check) is allowed, because the
  1021 acceptance criterion forbids only the reverse. Limitation: the exact function name is fixed
  by 1021's re-prepared spec.
- Selected: B. The rendered form is one line per field, `<key>: <JSON value>`, which is valid YAML
  flow syntax; 1021's parser must accept double-quoted JSON strings (with `\u` escapes) and flow
  sequences of double-quoted strings (coordination item C6). A8 (no new PowerShell module) is
  satisfied: no YAML library is needed because the generator never parses arbitrary YAML.

### 4.2 Dry-run diff

- A. General line diff (LCS or Myers) over before and after lines. Limitation: quadratic time and
  memory in PowerShell for long pages, and a substantial new algorithm to test.
- B. Structural diff from the merge: the merge already knows every edited region (front-matter
  block replaced, each added, updated or removed generated block, trailing-blank-line
  normalization). Each region becomes an edit record `@{ BeforeStart; BeforeCount; AfterStart;
  AfterCount }`, and a pure renderer prints unified-diff hunks (`--- a/<path>` or `--- /dev/null`,
  `+++ b/<path>`, `@@ -a,b +c,d @@`) with up to three context lines, merging overlapping hunks.
  Linear in page length; prose outside blocks is never an edit, which matches the merge invariant.
- Selected: B. A page whose bytes differ only by a BOM or CRLF has action `update` and an empty
  diff, as in spec v0.2.

### 4.3 Path coverage for `path_or_glob`

- A. PowerShell `-clike`. Limitation: the backtick is an escape character in `WildcardPattern`,
  and `[!...]` negation is not supported, so results diverge from the epic rule as written for
  consumers that copy glob syntax from other tools.
- B. A small pure translator: exact match, or prefix plus `/`, or an anchored case-sensitive regex
  built from the glob (`*` to `.*`, which crosses `/` as the old fnmatch-based rule did; `?` to
  `.`; `[...]` to a character class with a leading `!` mapped to `^`; every other character through
  `[regex]::Escape`). First match in profile order wins.
- Selected: B. 1023 uses the same rule (epic `### Generator decisions`), so one implementation
  should serve both; its home is owner question OQ-2.

### 4.4 Calling command-context members

- A. `$Context.WriteText.Invoke(...)`. Not reported by the guard, but it is not a documented
  carve-out, wraps exceptions in `MethodInvocationException`, and returns a collection.
- B. A private helper with `[scriptblock]`-typed parameters, invoked with `&`. This is the guard's
  documented carve-out (a) and keeps exception types unwrapped.
- Selected: B.

## 5. Recommended Design

### 5.1 Modules

Five production modules under `.claude/lib/docs/`, each with a byte-identical bundle copy and a
`core.json` entry. The epic lists four and allows research to refine module names without changing
the naming contract; the fifth module (`DocsReferenceFrontMatter.psm1`) is a split of the writer,
which would otherwise exceed the 500-line guidance (estimate below).

| Module | Role | Pure | Imports (literal `Join-Path -Path $PSScriptRoot -ChildPath '<file>'`) | Size estimate (logical lines) |
|---|---|---|---|---|
| `DocsReferencePlan.psm1` | Snapshot conversion, path coverage, output directory, candidate paths, page plan, unrendered count | yes | `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSchema.psm1`, `DocsSurface.psm1` | 350 to 420 |
| `DocsReferenceRender.psm1` | Single-line and code-span escaping, source and property lines, block body per element kind | yes | `DocsJson.psm1` | 200 to 260 |
| `DocsReferenceMarkers.psm1` | Marker lines, body parse (fence-aware), block merge with edit records | yes | `DocsSurface.psm1`, `DocsFinding.psm1`, the 1021 module that exports the fence classifier | 380 to 450 |
| `DocsReferenceFrontMatter.psm1` | Delimiter split, existing-page conversion, value resolution, canonical rendering | yes | `DocsJson.psm1`, `DocsFinding.psm1`, `DocsPageFrontMatter.psm1` (1021) | 260 to 330 |
| `DocsReferenceWriter.psm1` | Pure composition, diff rendering, result and report lines; the `generate-reference` command function (context I/O only) | mixed | the four modules above, `DocsFinding.psm1`, `DocsJson.psm1`, `DocsProfile.psm1`, `DocsSchema.psm1`, `DocsSurface.psm1` | 380 to 470 |

Contingency: if `DocsReferenceWriter.psm1` reaches 500 logical lines, `Format-DocsReferenceDiff`,
`ConvertTo-DocsReferenceResult` and `Get-DocsReferenceReportLine` move to
`DocsReferenceReport.psm1` with its own suite, bundle copy and core entry. If
`DocsReferenceRender.psm1` grows past guidance (it should not with one table-driven block function),
split per family as the epic allows.

Each module follows the 1020 conventions: help block containing `imports its siblings with
-ErrorAction Stop`; `Set-StrictMode -Version Latest` followed by `$ErrorActionPreference = 'Stop'`;
`-ErrorAction Stop` on every column-0 `Import-Module`; advanced functions with `[CmdletBinding()]`;
no module-scope mutable state; command modules neither write output nor call `exit`.

### 5.2 Public functions and signatures

"Pure" follows 1020: no filesystem, clock, process, environment or module-scope mutable state;
inputs are strings, arrays and dictionaries and are not mutated.

`DocsReferencePlan.psm1` (all pure):

- `ConvertFrom-DocsReferenceSnapshotText -Text <string> -ArtifactPath <string> -ComposedSchemaSet
  <IDictionary>` returns `@{ Snapshot; Element; Finding }`. Parses with `ConvertFrom-DocsJsonText`,
  validates with `Test-DocsArtifactText -ArtifactKind 'surface-inventory-snapshot'`, rebuilds every
  element with `ConvertFrom-DocsSurfaceElement` (identifier re-verification), sorts elements by
  `element_id` (ordinal), and reports `REFERENCE_SNAPSHOT_INVALID` for a repeated `element_id`, a
  repeated property `name` within one element, or a rebuild failure. `analysis_method` and the
  element digest are read but never rendered.
- `Test-DocsReferencePathCovered -Path <string> -Pattern <string>` returns `[bool]` per section
  4.3 (location subject to OQ-2).
- `Resolve-DocsReferenceOutputDirectory -Profile <IDictionary> -ProfilePath <string>
  [-OutputDirectory <string>]` returns `@{ OutputDirectory; Finding }`. Override wins when given;
  otherwise the single `diataxis_policy.directory_modes` entry with `mode: reference` whose
  `path_or_glob` contains none of `*`, `?`, `[`; otherwise `REFERENCE_OUTPUT_DIR_UNRESOLVED`.
  `reference` absent from `diataxis_policy.modes` gives `REFERENCE_MODE_CONFLICT` at
  `/diataxis_policy/modes`.
- `Get-DocsReferenceCandidatePagePath -OutputDirectory <string>` returns the four family page paths
  `<dir>/api-reference.md`, `<dir>/cli-reference.md`, `<dir>/config-reference.md`,
  `<dir>/http-reference.md` in ordinal order.
- `Get-DocsReferencePagePlan -Profile <IDictionary> -Element <object[]> -OutputDirectory <string>
  -ExistingPagePath <string[]> -ProfilePath <string>` returns `@{ Page; Unrendered; Finding }`.
  Each page record: `Path`, `Title`, `Element` (ordered per spec v0.2 `#### Element order within a
  page`), `Owner` (first covering `page_owners` entry or `$null`), `RootId` and `Audience` (longest
  covering `documentation_roots` path, ties to profile order; sorted `audience_ids`), and page-scoped
  findings (`REFERENCE_MODE_CONFLICT` from the first covering `directory_modes` entry,
  `REFERENCE_OUTPUT_OUTSIDE_ROOTS`, `REFERENCE_PARENT_MISSING` warning). A family page is planned
  when it has an element or already exists. `Unrendered` is
  `@{ 'architecture-component' = <count> }`.

`DocsReferenceRender.psm1` (all pure):

- `ConvertTo-DocsReferenceSingleLine -Text <string>` returns the text with every `\p{Cc}`,
  `\p{Zl}`, `\p{Zp}` character replaced by a space, space runs collapsed, both ends trimmed.
- `ConvertTo-DocsReferenceCodeSpan -Text <string>` returns a code span whose delimiter is one
  backtick longer than the longest backtick run in the text, padded with one space on both sides
  when the text starts or ends with a backtick, or starts and ends with a space.
- `Format-DocsReferenceSourceLine -Path <string> [-LineRange <IDictionary>]` returns
  ``- Source: `<path>` (lines <start>-<end>)``, without the parenthesis when `LineRange` is null.
- `Format-DocsReferencePropertyLine -Property <object[]>` returns one
  ``- Property `<name>`: `<json value>` `` line per property, ordinal by name; the JSON value is
  `ConvertTo-DocsCanonicalJson` without its trailing LF.
- `Get-DocsReferenceBlockLine -Element <IDictionary>` returns the body lines of one block: heading
  (`## Command`, `### Option`, `## Route`, `## Key`, `## Symbol` followed by a code span of the
  declaration), blank line, `- Name:` line, source line, property lines. One table-driven function
  replaces the five per-family renderers of the Python design. `architecture-component` throws
  (never planned onto a page).

`DocsReferenceMarkers.psm1` (all pure):

- `Get-DocsReferenceMarkerLine -ElementId <string> -Position <start|end>` returns
  `<!-- docs:generated:start id=<id> -->` or the end form; throws for an identifier that fails
  `Test-DocsElementId`.
- `ConvertFrom-DocsReferenceMarkerLine -Line <string>` returns `$null` when the line does not start
  (after trimming) with `<!-- docs:generated:`, otherwise `@{ Position; ElementId; Malformed }`.
- `ConvertFrom-DocsReferenceBody -Line <string[]> -PagePath <string> -LineOffset <int>` returns
  `@{ Segment; Finding }`; segments are `prose` or `block` records with 0-based start and end
  indices and the block identifier; fenced code outside open blocks is skipped with the 1021 fence
  rule; findings are the spec v0.2 marker codes (`REFERENCE_MARKER_MALFORMED`, `_DUPLICATE`,
  `_UNBALANCED`, `_MISMATCH`, `REFERENCE_FENCE_UNCLOSED`) with page line numbers
  (`LineOffset` plus index plus one).
- `Merge-DocsReferenceBlock -Line <string[]> -Desired <object[]> -PagePath <string> -LineOffset
  <int>` (desired items `@{ ElementId; Line }` in page order) returns `@{ Line; Added; Updated;
  Unchanged; Removed; Edit; Finding }` following spec v0.2 `### Merge algorithm` steps 1 to 6;
  `REFERENCE_BLOCK_REMOVED` (info, `related_ids` the removed identifier) per removed block; `Edit`
  holds the structural diff records of section 4.2 in body coordinates.

`DocsReferenceFrontMatter.psm1` (all pure):

- `Split-DocsReferenceFrontMatter -Text <string>` returns `@{ HasFrontMatter; Terminated;
  FrontMatterLine; BodyLine; BodyLineOffset }` after removing a leading BOM and normalizing CRLF to
  LF.
- `ConvertFrom-DocsReferencePageText -Text <string> -PagePath <string>` returns `@{ Value;
  HasFrontMatter; BodyLine; BodyLineOffset; Finding }`. Values come from the 1021 parser;
  1021 parse findings and any unknown key or pattern violation map to
  `REFERENCE_FRONT_MATTER_INVALID` (line and reason preserved); a front-matter line starting with
  `<!-- docs:generated:` gives `REFERENCE_MARKER_IN_FRONT_MATTER`. The caller has already read the
  text through the context; the function performs no read (the Python name `read_existing` is not
  reused, because the PowerShell `Read` verb implies I/O).
- `Resolve-DocsReferenceFrontMatterValue -Existing <IDictionary> -PagePlan <IDictionary>
  -SurfaceRef <string[]> -CapturedAt <string> -IsNewPage <bool>` returns `@{ Value; Finding }`:
  `diataxis_mode` is `reference`; `surface_refs` is the ordinal-sorted identifier list of the
  page; valid existing `owner`, `audience`, `last_reviewed`, `title`, `extensions` are kept;
  otherwise `owner` from the plan (`REFERENCE_OWNER_UNRESOLVED` when none), `audience` from the
  root (`REFERENCE_AUDIENCE_MISSING` when empty), `last_reviewed` from the first ten characters of
  `captured_at`, `title` only for a new page. An existing `diataxis_mode` other than `reference`
  gives `REFERENCE_MODE_CONFLICT`.
- `ConvertTo-DocsReferenceFrontMatterText -Value <IDictionary>` returns `---`, one
  `<key>: <JSON>` line per field in the order `owner`, `last_reviewed`, `audience`,
  `diataxis_mode`, `surface_refs`, `title`, `extensions`, then `---`, LF-terminated. JSON values
  come from `ConvertTo-DocsCanonicalJson` without its trailing LF, with U+0085, U+2028 and U+2029
  re-escaped as `\u` sequences (canonical JSON keeps non-ASCII literal, and YAML treats those code
  points as line breaks).

`DocsReferenceWriter.psm1`:

- `Get-DocsReferenceGeneration -Profile <IDictionary> -Snapshot <IDictionary> -Element <object[]>
  -ExistingPage <IDictionary> -OutputDirectory <string> -ProfilePath <string>` (pure) composes plan,
  render, merge and front matter. `ExistingPage` maps each candidate path to `$null` (absent) or
  `@{ Text; Sha256 }`. Returns `@{ Page; Unrendered; Finding }`; each page change carries `Path`,
  `Action` (`create`, `update`, `none`, `blocked`), `BeforeLine`, `AfterText`, `Sha256Before`,
  `Sha256After`, the four block lists, `Edit` (page coordinates, front matter included) and
  findings.
- `Format-DocsReferenceDiff -PagePath <string> -BeforeLine <string[]> -AfterLine <string[]> -Edit
  <object[]> [-IsNewPage <bool>]` (pure) returns the hunk text, LF-terminated, or `''`.
- `ConvertTo-DocsReferenceResult -Generation <IDictionary> -Mode <dry-run|write> [-WriteStatus
  <IDictionary>] [-OutputDirectory <string>]` (pure) returns the ordered `result` object of section
  6.4.
- `Get-DocsReferenceReportLine -Result <IDictionary>` (pure) returns the command-specific text
  lines passed to `New-DocsCommandResult -Line`; `ConvertTo-DocsReportText` (1020) prints findings
  before them and the summary line after them.
- `Invoke-DocsGenerateReferenceCommand -Argument <IDictionary> -Context <object>` (I/O through the
  context only) returns `New-DocsCommandResult`.
- Private `Invoke-DocsReferencePageWrite -Change <IDictionary> -ReadBytes <scriptblock> -TestFile
  <scriptblock> -WriteText <scriptblock>` performs one guarded write (section 6.3).

### 5.3 Dispatch row

One line under the generate-reference anchor of `Invoke-DocsCommand.ps1` (anchor text per C1):

```powershell
[pscustomobject]@{ Name = 'generate-reference'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReferenceWriter.psm1'); Function = 'Invoke-DocsGenerateReferenceCommand'; Option = @{ Profile = 'value'; Snapshot = 'value'; OutputDirectory = 'value'; Write = 'switch' } }
```

`Invoke-DocsGenerateReferenceCommand` matches `^Invoke-Docs[A-Za-z]+Command$`; no option name is
reserved; the row passes `Test-DocsCommandTable`. Both copies of `Invoke-DocsCommand.ps1` (source
and bundle) are edited.

## 6. Behavior Semantics

### 6.1 Invocation

```text
pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command generate-reference
    [-Profile <path>] [-Snapshot <path>] [-OutputDirectory <path>] [-Write] [-Json]
```

- `-Profile` default `Get-DocsDefaultProfilePath`; `-Snapshot` default
  `artifact_paths.inventory_snapshot` of the loaded profile; `-OutputDirectory` default per
  `Resolve-DocsReferenceOutputDirectory`. A value that fails `Test-DocsRelativePath`, or an
  `-OutputDirectory` with a trailing `/`, is a usage error (exit 2, one `DOCS_CLI_ARGUMENTS`).
- Dry run is the default; `-Write` performs writes.

### 6.2 Stages and error gating

1. Read the schema set (`Read-DocsSchemaSet`, `Get-DocsComposedSchemaSet`); a composition failure
   is exit 3.
2. Profile: absent gives `DOCS_PROFILE_MISSING` (exit 1, as in 1020 `validate-profile`); otherwise
   `ConvertFrom-DocsProfileText` findings pass through unchanged.
3. Snapshot: absent gives `REFERENCE_SNAPSHOT_MISSING` (new code, exit 1, same treatment as an
   absent profile); otherwise `ConvertFrom-DocsReferenceSnapshotText`; repository mismatch gives
   `REFERENCE_REPOSITORY_MISMATCH`.
4. Output directory and page plan; global findings stop before page reads.
5. Existing pages: for each candidate path, `TestFile`, then `ReadBytes` for `Sha256Before` and
   `ReadText` for the text. A read failure other than absence propagates and becomes exit 3
   (`DOCS_CLI_RUNTIME` at the entry boundary).
6. Generation (pure). Page-scoped errors block only that page.
7. Dry run: no context write. Write mode: section 6.3, only when no `error` finding exists.

Change from spec v0.2: an absent profile or snapshot is exit 1 (1020 convention) rather than exit
3; a read failure other than absence stays exit 3.

### 6.3 Write semantics

- Pages are processed in ordinal path order. `none` gets `skipped`.
- `create`: `TestFile` immediately before writing; an existing target gives `conflict`; otherwise
  `WriteText` with mode `create`.
- `update`: `ReadBytes` immediately before writing; a SHA-256 different from `Sha256Before` gives
  `conflict`; otherwise `WriteText` with mode `overwrite`.
- The check-then-write sequence is not atomic; it detects concurrent edits between planning and
  writing, which is the purpose of the Python design's digest-guarded port, but it cannot close
  the window between the check and the write. This is stated as a documented limit, not a
  guarantee.
- First `conflict`: stop; later pages get `not-attempted`; exit 1 with one
  `REFERENCE_WRITE_CONFLICT` finding and the full result (analogous to 1020
  `DOCS_INIT_TARGET_EXISTS`).
- An exception from `WriteText`: exit 3. Under the 1020 exit-3 rule `findings` holds exactly one
  finding and `result` is `null`; the proposal is one `REFERENCE_WRITE_FAILED` finding whose
  `related_paths` holds the failed path and whose message states how many pages were written before
  it (OQ-3). The Python design's `failed` status and `uncertain_paths` key are dropped, because a
  null result cannot carry them.
- All writes go through `Context.WriteText`, which 1020 implements with `Write-DocsFileText`, the
  only filesystem write primitive. No 1024 module calls a filesystem cmdlet or .NET file API.

### 6.4 `-Json` envelope and `result`

The envelope is 1020's `{command, exit_code, findings, ok, result}` (canonical JSON, sorted keys,
compact, trailing LF) and validates against `schemas/docs/v1/docs-command-envelope.schema.json`.
The Python report keys `tool`, `report_version`, `ok` and `findings` are carried by the envelope;
`result` (non-null on exit 0 and 1 after the profile loads) is:

| Key | Content |
|---|---|
| `mode` | `dry-run` or `write` |
| `output_directory` | resolved directory or `null` |
| `pages` | ordinal by `path`; each `{action, blocks: {added, removed, unchanged, updated}, diff, path, sha256_after, sha256_before, status}` with spec v0.2 meanings; `diff` is a string in dry run for `create` and `update`, otherwise `null`; statuses `planned`, `skipped`, `created`, `updated`, `conflict`, `not-attempted`, `blocked` |
| `summary` | `blocks_added`, `blocks_removed`, `blocks_unchanged`, `blocks_updated`, `page_count`, `pages_blocked`, `pages_changed`, `pages_unchanged` (finding counts are in the 1020 summary line, not repeated) |
| `unrendered` | `{"architecture-component": <count>}` |

### 6.5 Text output

`Get-DocsReferenceReportLine` returns, in order: one `<action> <path> (+<added> ~<updated>
-<removed>)` line per page; in dry run the diff lines of each changed page; one
`note: <path> is new; link it from a documentation entry page so that the check command does not
report PAGE_ORPHANED` line per created page; then a mode line (`dry run, nothing written`, `wrote
<n> page(s)`, or `nothing written`). 1020's `ConvertTo-DocsReportText` prints finding lines before
these and the `generate-reference: exit=<n> errors=<n> warnings=<n> infos=<n>` summary after them.

### 6.6 Rules carried from spec v0.2 unchanged

Marker grammar, standalone marker lines with blank lines inside and outside each block, the merge
algorithm and its idempotence, page-plan family names and titles, element order within a page,
front-matter field order and preservation rules, rendering rules (lists only, fixed heading words,
every consumer string through single-line then code-span, no links, no HTML other than markers),
and determinism rules (LF only, one trailing LF, no trailing spaces, UTF-8 without BOM, no clock,
no randomness, no environment value). The audience pattern `^[a-z0-9][a-z0-9-]*$` is adopted by
1020 and 1021 per the epic; if the amended 1020 profile schema enforces it on audience
identifiers, `REFERENCE_AUDIENCE_INVALID` becomes unreachable on a schema-valid profile and is
removed rather than kept as untestable code (C4).

## 7. Halted Preflight: Six Pure Functions Mapped

The first preparation halted on missing property tests for six pure functions (epic `### Generator
decisions from the first preparation of 1024`). All six are named in spec v0.2 `## Module
Boundaries` (`reference/page_plan.py`, `reference/markdown_text.py`, `reference/front_matter.py`,
`reference/report.py`).

| Python function (withdrawn) | PowerShell equivalent | Module | Seeded property (fixed-seed `[System.Random]`, seed printed on failure) |
|---|---|---|---|
| `resolve_output_dir` | `Resolve-DocsReferenceOutputDirectory` | Plan | For drawn profiles with drawn `directory_modes` lists: an override is returned unchanged with no finding regardless of the profile; without an override, a directory is returned exactly when one non-glob `reference` entry exists, and it equals that entry; the result is invariant under permutation of the non-reference entries; every finding code is `REFERENCE_OUTPUT_DIR_UNRESOLVED` or `REFERENCE_MODE_CONFLICT` |
| `candidate_page_paths` | `Get-DocsReferenceCandidatePagePath` | Plan | For drawn valid relative directories: four paths, each `<dir>/` plus a family file name, the leaf set equals the family set, each passes `Test-DocsRelativePath`, the list is ordinal-sorted, and two calls return equal arrays |
| `source_line` | `Format-DocsReferenceSourceLine` | Render | For drawn paths (including backticks, control characters, U+2028) and drawn nullable line ranges: one line with no LF, starting `- Source: `; decoding the code span with a test-local CommonMark code-span decoder yields `ConvertTo-DocsReferenceSingleLine` of the path; the parenthesis is present exactly when a range is given and carries both bounds |
| `split_front_matter` | `Split-DocsReferenceFrontMatter` | FrontMatter | For drawn front-matter line sets and bodies: rejoining delimiters, front-matter lines and body lines reproduces the LF-normalized input; `BodyLineOffset` equals the front-matter line count including delimiters; an input whose first line is not exactly `---` yields `HasFrontMatter` false and the whole text as body; BOM and CRLF variants give identical output |
| `read_existing` | `ConvertFrom-DocsReferencePageText` | FrontMatter | For drawn valid value sets rendered with `ConvertTo-DocsReferenceFrontMatterText` and drawn bodies: the parsed values equal the drawn values (round trip), the body is unchanged, BOM and CRLF variants agree, and inserting a marker line into the block yields `REFERENCE_MARKER_IN_FRONT_MATTER` with the correct line |
| `render_text` | `Get-DocsReferenceReportLine` | Writer | For drawn results: page lines appear in ordinal path order for every permutation of the input page array; no line contains CR or LF; the note-line count equals the number of `create` pages; two calls return equal arrays |

## 8. Property Tests for Every Public Pure Function

Mechanism (no repository precedent exists; 1020 introduces the same mechanism for identifiers):

- Seeds `11, 23, 47, 101, 211` (the old plan's set), one Pester case per seed through
  `It '<property> (seed <Seed>)' -ForEach @(@{ Seed = 11 }, ...)`, so the seed is in the test name
  of every failure; assertions also pass `-Because "seed $Seed"`.
- Each case builds `$random = [System.Random]::new($Seed)` and draws a bounded number of inputs
  (for example 40 per seed) through generators in a test-support module. The properties assert
  relations, not specific drawn values, so they do not depend on the exact sequence a runtime
  produces for a seed. That `[System.Random]` with an explicit seed yields the same sequence across
  .NET releases was not verified in this research.
- Generators live in `tests/scripts/claude-lib/docs/DocsReference.TestSupport.psm1` (or extend
  1020's planned `Docs.TestSupport.psm1` if its re-prepared spec exposes a generator hook):
  `Get-DocsReferenceRandomText` (includes backtick runs, `\p{Cc}`, U+2028, leading `how to` and
  `step 1`, leading `<`), `New-DocsReferenceRandomElement` (valid elements built with
  `New-DocsSurfaceElement`, every rendered kind, options with and without parents),
  `New-DocsReferenceRandomProse` (paragraphs, headings, fenced blocks containing marker-like
  lines), `New-DocsReferenceRandomProfile`, and `Get-DocsReferenceShuffled` (Fisher-Yates with the
  supplied `[System.Random]`).

| Public pure function | Property |
|---|---|
| `ConvertFrom-DocsReferenceSnapshotText` | Drawn elements serialized in drawn order with `ConvertTo-DocsJsonText` parse back to the same identifiers in ordinal order; duplicating a drawn element yields `REFERENCE_SNAPSHOT_INVALID` |
| `Test-DocsReferencePathCovered` | Agrees with the oracle: the path itself and every proper directory prefix cover it; a case-flipped variant that differs does not; a glob built by replacing drawn segments with `*` or characters with `?` covers it; a non-prefix sibling does not |
| `Resolve-DocsReferenceOutputDirectory` | Section 7 |
| `Get-DocsReferenceCandidatePagePath` | Section 7 |
| `Get-DocsReferencePagePlan` | Every rendered element appears on exactly one page and `architecture-component` on none; options follow their parent command; the planned page set equals families with elements plus existing paths; the plan is invariant under element permutation; `Unrendered` equals the drawn architecture count |
| `ConvertTo-DocsReferenceSingleLine` | Output contains no `\p{Cc}`, `\p{Zl}`, `\p{Zp}`, no double space and no edge space; applying it twice equals applying it once |
| `ConvertTo-DocsReferenceCodeSpan` | The test-local decoder returns the input for drawn single-line texts; the delimiter run is longer than every internal backtick run |
| `Format-DocsReferenceSourceLine` | Section 7 |
| `Format-DocsReferencePropertyLine` | One line per property, ordinal by name, each starting `- Property `; invariant under property permutation |
| `Get-DocsReferenceBlockLine` | The heading word matches the kind; no heading text matches `(?i)^how to ` or `(?i)^step\s+[0-9]+\b` after the `#` run, including for declarations drawn to start with those words; no line starts with `<`; no line starts with a marker prefix; no trailing spaces |
| `Get-DocsReferenceMarkerLine` and `ConvertFrom-DocsReferenceMarkerLine` | Round trip for every element kind and position; drawn mutations (leading space, trailing text, identifier outside the element-id grammar) parse as `Malformed` |
| `ConvertFrom-DocsReferenceBody` | For drawn well-formed bodies, the block segments equal the drawn blocks in order and prose segments reconstruct the drawn prose; marker-like lines inside fences are never blocks |
| `Merge-DocsReferenceBlock` | Prose preservation (every non-blank line outside blocks keeps its relative order; prose segments are byte-identical when desired and existing identifier sets are equal); idempotence (a second merge returns identical lines with every block unchanged); removal reporting (each removed identifier appears once in `Removed` and in one `REFERENCE_BLOCK_REMOVED` info finding); applying `Edit` to the input reproduces the output |
| `Split-DocsReferenceFrontMatter` | Section 7 |
| `ConvertFrom-DocsReferencePageText` | Section 7 |
| `Resolve-DocsReferenceFrontMatterValue` | `diataxis_mode` is always `reference`; `surface_refs` equals the sorted page identifiers; drawn valid existing values are preserved; missing `last_reviewed` equals the first ten characters of the drawn `captured_at` |
| `ConvertTo-DocsReferenceFrontMatterText` | Field order is fixed; every value line is a single line; parsing the output with `ConvertFrom-DocsReferencePageText` returns the input values |
| `Get-DocsReferenceGeneration` | Byte identity across two runs and across a shuffled element order; regenerating over the first run's output gives action `none` for every page |
| `Format-DocsReferenceDiff` | A test-local hunk applier reconstructs the after lines from the before lines and the rendered hunks; an empty edit list gives `''` |
| `ConvertTo-DocsReferenceResult` | Summary counts equal counts derived from `pages`; the key sets equal section 6.4; invariant under input page permutation |
| `Get-DocsReferenceReportLine` | Section 7 |

Example-based tests complement the properties: every finding trigger in the catalog, each marker
error class blocking only its page, each exit-2 usage case, absent profile and snapshot (exit 1),
an injected read exception (exit 3), write conflict on create and on update (exit 1, later pages
`not-attempted`), and an injected `WriteText` exception (exit 3, one `REFERENCE_WRITE_FAILED`).

## 9. Command-Level and Integration Tests (all in memory)

All command tests run through 1020's `Invoke-DocsCommandCli` (dot-sourced from
`Invoke-DocsCommand.ps1`) with `-Context` set to an in-memory context: `ReadText`, `ReadBytes`,
`TestFile` and `ListFile` read a hashtable of path to text; `WriteText` appends
`@{ RelativePath; Text; Mode }` to a recording list and updates the hashtable; `UtcNow` returns a
fixed instant. The real context and `Write-DocsFileText` are never called. Profiles and snapshots
are built in memory; the only committed files read are schema files (read-only), as in 1020's
suites. No test creates a temporary file.

| Test | Assertion |
|---|---|
| Checker integration (`DocsReferenceIntegration.Tests.ps1`) | Generate with `-Write` into the in-memory context, add an entry page (`docs/README.md` with conforming front matter linking each generated page), then run `Invoke-DocsCommandCli -Command check -Json` against the same context with the arguments fixed by 1021's re-prepared spec; exit 0 and zero findings. Second case: insert seeded prose around and between the blocks, regenerate, check again; exit 0, zero findings, prose unchanged |
| Front-matter schema conformance | For every generated page: split the block, parse it with the 1021 parser, serialize with `ConvertTo-DocsJsonText`, and `Test-Json -Schema` against the committed `schemas/docs/v1/page-metadata.schema.json` (self-contained per 1021) returns `True`; the 1024 pattern constants equal the schema patterns read from the same file |
| `-Json` envelope schema | Stdout of a dry run, a write run and an exit-1 run each validate with `Test-Json` against `docs-command-envelope.schema.json` (composed through `Join-DocsSchemaText` when it references docs common, else self-contained per D5); keys are exactly `command`, `exit_code`, `findings`, `ok`, `result`; `command` is `generate-reference` |
| Byte-identical re-render | For each seed: two runs over the same inputs, and one over a shuffled snapshot element order, produce identical written page texts and identical envelope bytes |
| Prose preservation and removed-block reporting | Regenerate after removing one element from the snapshot: its block is gone, its identifier is in `pages[].blocks.removed`, one `REFERENCE_BLOCK_REMOVED` info finding names it in `related_ids`, exit 0, all other lines unchanged |
| Dry run writes nothing | Without `-Write`: the recording list is empty, exit 0, text output contains each page line and the hunk headers (`--- /dev/null`, `+++ b/<path>` for a new page); `-Json` result has `mode` `dry-run`, status `planned` and a non-null `diff`. With `-Write`: the list holds one entry per changed page in ordinal path order with modes `create` and `overwrite`; an immediate second run records nothing and reports `skipped` everywhere |
| Module boundaries (`DocsReferenceBoundary.Tests.ps1`) | AST scan of the five modules: no `CommandAst` named `Set-Content`, `Add-Content`, `Out-File`, `New-Item`, `Remove-Item`, `Copy-Item`, `Move-Item`, `Get-Content`, `Test-Path`, `Get-Date`, `Get-Random`, `Invoke-Expression`; no `[System.IO.File]` or `[System.IO.Directory]` type expression; no `$Context` reference outside `DocsReferenceWriter.psm1`; no import of `DocsLedger*`, `DocsAnalyzer*` or `DocsInventory*` |

The existing Python-invocation guard and `ClaudeLibModuleConvention.Tests.ps1` cover the new
modules without edits.

## 10. Runner and CI Jobs for Pester Acceptance Criteria

- Local, branch-current: `Invoke-PoshQCTest` from `scripts/powershell/PoshQC/PoshQC.psd1`, launched
  through a `sh` script under `SCRATCH` that runs PowerShell 7 (execution-environment brief
  `## PowerShell Route and PoshQC MCP Limits`); pass and fail counts from
  `artifacts/pester/pester-junit.xml`; per-file line coverage from
  `artifacts/pester/powershell-coverage.xml`.
- CI: the new suites under `tests/scripts/claude-lib/docs/` are discovered through
  `config/poshqc-scan.json` and assigned automatically to `poshqc / PowerShell QC shard 1`,
  `shard 2` or `shard 3` (`windows-latest`); the required aggregate context is
  `poshqc / PowerShell QC` (`windows-latest`), which verifies shard completeness and merges
  coverage. Formatting and PSScriptAnalyzer run in `poshqc / PowerShell QC static`
  (`windows-latest`). `poshqc / PowerShell hook suites (Linux)` does not run these suites.
- The Python push-down contract tests run in `quality-checks7 / Code Quality & Tests
  (<python-version>)`; they are run unchanged, not edited.
- The pull request targets `epic/documentation-estate-tooling-integration`; `ci.yml` triggers on
  `epic/**`, and the change set includes code, so the change-scope decision is a full run.

## 11. Artifact Classification

Rules: R1 = directive clause (1) (pushed-down skills, helpers, hooks and libs are PowerShell or
bash); R2 = clause (2) (TypeScript only for MCP and extension commands); D = epic `### Artifact
classes for this epic`. "Avoid new Python" applies to every row.

| File (create unless noted) | Class | Language | Permitting rule |
|---|---|---|---|
| `.claude/lib/docs/DocsReferencePlan.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceRender.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceMarkers.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceFrontMatter.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceWriter.psm1` | pushed-down helper/lib (command module) | PowerShell | R1 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` (edit: one row) | pushed-down helper/lib (entry) | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` copies of the six files above | pushed-down helper/lib (mirror) | PowerShell | R1, D |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit: five paths) | schema/config/data | JSON | D |
| `tests/scripts/claude-lib/docs/DocsReferencePlan.Tests.ps1`, `DocsReferenceRender.Tests.ps1`, `DocsReferenceMarkers.Tests.ps1`, `DocsReferenceMarkers.Properties.Tests.ps1`, `DocsReferenceFrontMatter.Tests.ps1`, `DocsReferenceWriter.Tests.ps1`, `DocsReferenceWriter.Properties.Tests.ps1`, `DocsReferenceIntegration.Tests.ps1`, `DocsReferenceBoundary.Tests.ps1`, `DocsReference.TestSupport.psm1` | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-reference-generator-1024/**` (spec, user story, plan, research, evidence) | documentation | Markdown | D |

No schema, example, hook, skill, agent, MCP tool, extension command, Python file or TypeScript file
is created or edited. `quality-tiers.yml`, `config/poshqc-coverage.json` and
`config/poshqc-scan.json` need no edit (1020 adds `.claude/lib/docs` as T3; the coverage root and
scan folder already include the new paths). Every artifact follows the language rule; no case was
found that requires an owner question on language.

## 12. Proposed Acceptance Criteria Shape

Epic criteria restated for the PowerShell design (names, not counts, are asserted):

- Rendering the same snapshot twice is byte-identical, including under a shuffled element order
  (seeded property, section 9).
- Prose outside generated markers is preserved across regeneration (seeded property on
  `Merge-DocsReferenceBlock`); a removed element's block is removed and reported
  (`REFERENCE_BLOCK_REMOVED`, `blocks.removed`).
- Every generated page passes the 1021 `check` subcommand with zero findings (Pester integration,
  new pages and pages with prose).
- Without `-Write` the command writes nothing (empty recording list) and prints the planned
  changes; with `-Write` it writes only through `Context.WriteText`.
- Pester line coverage at least 85% for each new file under `.claude/lib/docs/`, read from the
  PoshQC coverage report, no file excluded (no branch gate for Pester).

Added for this design: a seeded property test for each public pure function in section 8;
emitted front matter validates against `page-metadata.schema.json`; `-Json` output validates
against `docs-command-envelope.schema.json`; the module-boundary AST test; the dispatch row passes
`Test-DocsCommandTable`; every new `.claude/lib/docs/` file is in `core.json` and byte-identical to
its bundle copy (1020's `Docs.Manifest.Tests.ps1`), and the push-down contract tests pass
unmodified; no production or test file exceeds 500 logical lines (guidance target; 800 is the hard
limit); `git diff --name-only <merge-base>..HEAD` lists no `.py`, `.ts`, `.tsx`, `.js`, `.mjs`
or `.cjs` path; no test contains a construct forbidden by `check-powershell-test-purity.ps1` or
`TestDrive`.

## Numeric Derivation Evidence

The proposed criteria assert names, not counts. One count used in the design (the family page set)
is derived here because a plan may quote it.

- Numeric spec.md acceptance criterion: the generator plans at most 4 family pages per output directory.
- Complete Family: cli-reference.md, http-reference.md, config-reference.md, api-reference.md
- Exhaustive Search Scope: the entire worktree tree under docs/features (Grep with regex `[a-z]+-reference\.md`, output-only matches), which holds every specification of this epic.
- Inclusion Rules: file names that the epic or the 1024 specification assign to a rendered element family.
- Exclusion Rules: `command-reference.md` (a 900010 onboarding document, not a generated family page) and matches in the closed 980 feature folder, which belong to another feature.
- Primary Search Strategy or Query Expression: read the epic heading `### Generator decisions from the first preparation of 1024`, lines 369 to 370, which list cli-reference.md, http-reference.md, config-reference.md, api-reference.md.
- Primary Member Set: cli-reference.md, http-reference.md, config-reference.md, api-reference.md
- Primary Count: 4
- Cross-check Search Strategy or Query Expression: regex `[a-z]+-reference\.md` over docs/features with only-matching output, filtered to this feature's `spec.md` `#### Page-plan rules` (lines 342 to 344), which map kinds to cli-reference.md, http-reference.md, config-reference.md, api-reference.md.
- Cross-check Member Set: cli-reference.md, http-reference.md, config-reference.md, api-reference.md
- Cross-check Count: 4
- Member-set Comparison: the normalized primary and cross-check member sets are equal.

## 13. Contracts Later Children Must Honor

- 900007 (`generate_docs_reference`): invokes `pwsh -NoProfile -File
  .claude/lib/docs/Invoke-DocsCommand.ps1 -Command generate-reference -Json` with optional
  `-Profile`, `-Snapshot`, `-OutputDirectory` (and `-Write` only if OQ-1 allows it), with the
  workspace root as working directory; parses the envelope; adds no logic. Its Jest tests pin the
  `result` key set of section 6.4. Exit 1 on a write conflict carries a full result; exit 3 carries
  a null result.
- 900008: may detect page drift in CI by running the dry run with `-Json` and reading
  `result.summary.pages_changed`; no separate check mode exists (spec v0.2 D5). The feature-review
  surface-change check treats generated blocks as generator-owned.
- 900009: page templates for `cli-reference`, `http-reference`, `config-reference` and
  `api-reference` use the fixed family file names, front matter with `diataxis_mode: reference`
  and conforming `owner`, `audience`, `last_reviewed`, and contain no generated-block markers;
  roles author prose only outside markers and never edit inside a generated block; the reconciler
  calls `generate-reference` (or the MCP tool) to refresh blocks; consumer entry pages link each
  generated page (orphan rule).
- 900010: the end-to-end fixture drives `generate-reference -Write` through an in-memory context
  and runs `check` over the result.
- 1023 (already earlier in the wave order): the `path_or_glob` coverage rule of section 4.3 is
  shared (OQ-2); generated pages list their element identifiers in `surface_refs`, which page
  bindings may reference.

## 14. Coordination Requests to the Concurrent 1020 and 1021 Re-preparations

These are contract confirmations, not language questions; the coordinator routes them.

- C1 (1020): the anchor line for generate-reference in the dispatch table (`900006` on this
  branch's spec v0.3; 1024 under the current manifest).
- C2 (1020): `WriteText` mode `create` behavior on an existing target and whether it creates parent
  directories; `ReadBytes` availability; whether `ReadText` decodes strictly (invalid UTF-8).
- C3 (1020): the envelope schema keeps `result` open (any JSON value); the function the envelope
  test uses (`Test-Json` over a composed or self-contained schema).
- C4 (1020): whether the amended profile schema enforces `^[a-z0-9][a-z0-9-]*$` on audience
  identifiers; if so, `REFERENCE_AUDIENCE_INVALID` is dropped.
- C5 (1020): `analysis_method` and the declaration-lines digest on snapshot elements; the generator
  ignores both, so a method change between scanner and native analysis causes no page churn.
- C6 (1021): export a front-matter parse function and a fence-aware line classifier from
  `DocsPageFrontMatter.psm1` or a shared page-scan module; the parser accepts `<key>: <JSON>` lines
  (double-quoted strings with `\u` escapes, flow sequences of double-quoted strings).
- C7 (1021): the `check` subcommand options for root and entry pages, and continuation of the
  `DX-NO-INSTRUCTION` heading prefixes (`how to `, `step <n>`).
- C8 (1021): `page-metadata` in `Get-DocsSchemaName` under the 1021 anchor and a byte-identical
  runtime copy under `.claude/lib/docs/schemas/v1/`.

## 15. Owner Questions

No artifact of this child conflicts with the language rule (all production code is PowerShell, no
new module, no YAML library, no Python or TypeScript). The following are owner questions because
they change another child's acceptance criteria or a shared contract.

- OQ-1 - MCP mutation scope. Epic 900007 states `update_docs_ledger` is the only mutating tool, yet
  `generate_docs_reference` maps to a command whose `-Write` switch writes pages. Options: (a) the
  MCP tool exposes dry run only, and writes happen through a skill calling `Invoke-DocsCommand.ps1
  -Write`; (b) the tool exposes `-Write` and the 900007 criterion is narrowed to ledger, matrix and
  pin artifacts. Provisional default: (a).
- OQ-2 - Home of the shared path-coverage function. Options: (a) the 1020 amendment adds
  `Test-DocsPathCovered` to `DocsSurface.psm1` and both 1023 and 1024 import it; (b) 1023 owns it
  and 1024 imports a ledger-area module; (c) each child keeps a copy with a parity test.
  Provisional default: (a), because 1020 is being re-planned now and already owns the path grammar.
- OQ-3 - Write failure under the 1020 exit-3 rule. Exit 3 carries one finding and a null result, so
  pages written before a failure appear only in the finding message. Options: (a) accept, with one
  `REFERENCE_WRITE_FAILED` finding naming the failed path; (b) allow `generate-reference` to return
  exit 1 with a full result for a write failure. Provisional default: (a), which keeps the 1020
  contract uniform.

## 16. Rejected Alternatives (summary)

- A 1024-owned front-matter parser: rejected because generator and checker could disagree.
- A general LCS or Myers line diff: rejected for quadratic cost and size; the merge already knows
  every edit.
- `-clike` for globs: rejected for backtick escaping and missing `[!...]` negation.
- `.Invoke()` on context members: rejected in favor of the guard's documented `[scriptblock]`
  carve-out.
- Reusing `Get-MermaidFenceLine`: rejected because its blockquote and quote-depth rules differ from
  the 1021 fence rule the checker applies.
- Five per-family render functions (Python layout): replaced by one table-driven
  `Get-DocsReferenceBlockLine`, which keeps the render module small and needs one property test.

## Pre-Mortem

- Review checklists: A reviewer can fail the work on a missing property test for a public pure
  function, a filesystem cmdlet in a 1024 module, a `&` call through a context member (the
  Python-invocation guard reports it), a coverage exclusion, a consumer identifier in source, or a
  test that uses `TestDrive` or a temporary path. The plan must carry the per-function property
  table of section 8, the boundary AST test, the `[scriptblock]`-parameter write helper, the 1020
  neutrality suite run, and a purity scan of every new test file.
- Coverage: Pester measures lines only; the command function's write and error branches can fall
  below 85% when tests exercise only the happy path. The plan must drive every exit path (0, 1
  conflict, 1 findings, 2, 3 read, 3 write) through the in-memory context and read per-file
  figures from `artifacts/pester/powershell-coverage.xml`; unreachable defensive code (for example
  `REFERENCE_AUDIENCE_INVALID` after C4) is removed rather than left uncovered.
- Mirror parity: Each of the five modules and the edited `Invoke-DocsCommand.ps1` has a bundle
  copy, and each new module needs a `core.json` entry; a missed copy fails 1020's
  `Docs.Manifest.Tests.ps1` and the Python push-down contract tests. The plan must copy after the
  final edit of each file and run the manifest suite and the three Python contract tests last. The
  plan changes no CI job, required context, tool route or batch-budget rule, so no
  execution-environment brief update task is needed.
- File size: `DocsReferenceWriter.psm1` and `DocsReferenceMarkers.psm1` are estimated at 380 to
  470 logical lines, and the property suites can exceed 500. The plan must record logical line
  counts, apply the `DocsReferenceReport.psm1` contingency at 500, and keep property tests in
  separate `*.Properties.Tests.ps1` files.
- Test isolation: Dot-sourcing `Invoke-DocsCommand.ps1` and importing the docs modules leaves
  functions and modules in the session; a suite that relies on a module another suite imported
  passes locally and fails in a shard. Every suite imports what it uses with `-Force` in
  `BeforeAll` and removes `Docs*` modules in `AfterAll`; the plan must record three seeded shuffled
  file-order runs and one fresh single-process run over `tests/scripts` under
  `<FEATURE>/evidence/regression-testing/`.
- CI-only behavior: `Test-Json` behavior on the `windows-latest` runner depends on its PowerShell
  release; ordering that uses `Sort-Object` or default `-match` is culture- and case-dependent and
  can differ from a local run; `Join-Path` would put backslashes into page paths on Windows. The
  plan must assert finding codes and pointers rather than `Test-Json` message text, use ordinal
  sorts and case-sensitive operators throughout, build page paths with `/`, and build BOM and CRLF
  fixtures in memory because of the `eol=lf` attribute.
- Evidence: Upstream symbols are planned, not merged; a plan task that consumes a 1020 or 1021
  function before confirming its exported name and signature fails at run time. The plan must open
  with a confirmation task against the integration branch that records each consumed symbol, stop
  with a recorded blocker when one is absent, and run in the item worktree under an exempt-route
  checkpoint (ten production PowerShell files plus two edited copies exceed the direct-mode batch
  budget). Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output
  Summary:` and no absolute path.
