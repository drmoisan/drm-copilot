# docs-reference-generator — Spec

- **Issue:** #1024
- **Parent (optional):** #1019 (epic `documentation-estate-tooling`, wave 2, complexity band C3)
- **Depends on:** 1020 (docs profile, schemas, element model, `Invoke-DocsCommand.ps1`, command context) and 1021 (page-metadata schema, front-matter parser, `check` command)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft
- **Version:** 0.3
- **Work Mode:** full-feature
- **Research:** `research/2026-10-30T23-00-powershell-design-addendum-research.md` (primary design source); `research/research.2026-10-30T20-59.md` (language-independent findings only: merge model, behavior semantics, page-plan and rendering rules)

## Revision Note

This revision replaces the withdrawn Python design in full. It is a new planning cycle under owner
decision D1 (epic `## Owner Decisions`): the earlier plan `plan.2026-10-30T16-54.md` and its
preflight records under `evidence/other/` are context only and are superseded. The halted preflight
(missing property tests for six pure functions) is remedied in `## Property-Test Harness and
Halted-Preflight Remedy`.

Governing inputs: epic `## Owner Directive: Implementation Language (2026-10-30, refined)` and its
`### Artifact classes for this epic` table, `## Owner Decisions`, `### Amendment of 1020 required by
D3 and D5`, `### PowerShell contracts from the re-preparation of 1020`, `### Command contract
decisions from the first preparation of 1023`, `### Generator decisions from the first preparation
of 1024`, `### 1024 - docs-reference-generator`, and 1020 `spec.md` `## Decisions Later Children Must
Honor`.

Where the 1020 specification text and the epic amendment differ (the 1020 sentence "The envelope
has no schema file"), the amendment governs: the `-Json` envelope validates against
`schemas/docs/v1/docs-command-envelope.schema.json`.

## Overview

The documentation-estate-tooling epic inventories the documentable surface of a destination
repository (CLI commands and options, HTTP routes, configuration keys, public symbols and
architecture components) into a revision-pinned surface inventory snapshot. Reference pages for
that surface are still written by hand, so they drift from the code, and a regeneration step that
overwrote whole pages would destroy hand-written prose. One consumer repository measured the gap by
hand: a feature epic changed 138 `src/` files while only 4 of 79 documentation pages were edited.

This feature adds a deterministic reference-page generator, implemented as PowerShell modules under
`.claude/lib/docs/` behind the subcommand `generate-reference` of `Invoke-DocsCommand.ps1`. It
renders snapshot elements into marker-delimited generated blocks inside fixed family pages,
preserves every line of author prose outside those blocks, emits front matter that conforms to
`schemas/docs/v1/page-metadata.schema.json` and passes the 1021 checker, and writes nothing unless
`-Write` is given. The design is domain-neutral; no consumer identifier appears in framework source.

## Behavior

`Invoke-DocsCommand.ps1 -Command generate-reference [-Profile <path>] [-Snapshot <path>]
[-OutputDirectory <path>] [-Write] [-Json]` dispatches to `Invoke-DocsGenerateReferenceCommand` in
`DocsReferenceWriter.psm1`.

1. Read the profile through the command context (`-Profile`, default `Get-DocsDefaultProfilePath`)
   and validate it with `ConvertFrom-DocsProfileText`.
2. Read the snapshot (`-Snapshot`, default `artifact_paths.inventory_snapshot` of the profile),
   validate it with `Test-DocsArtifactText -ArtifactKind 'surface-inventory-snapshot'`, and rebuild
   each element with `ConvertFrom-DocsSurfaceElement`.
3. Resolve the output directory and the candidate family page paths; test and read existing pages
   through the command context.
4. Compute every page in memory with pure functions (`New-DocsReferenceChangeSet`): page plan,
   rendered block bodies, marker merge, front matter, action and region diff.
5. Without `-Write`: return the planned changes; no write occurs. With `-Write` and no `error`
   finding: write changed pages through `Context.WriteText` (backed by `Write-DocsFileText`) in
   ordinal path order, with a digest re-check before each overwrite.
6. Return `New-DocsCommandResult -Command 'generate-reference'`; the entry script prints the text
   report or the `-Json` envelope and exits with the code defined in `### Exit codes`.

A read failure other than absence propagates as an exception and becomes exit 3 `DOCS_CLI_RUNTIME`
at the entry boundary (1020 `#### Exit codes and the -Json envelope`).

### Upstream contracts consumed

None of these files exists on the integration branch at preparation time (addendum `### 2.5`).
Implementation confirms each symbol against the merged 1020 and 1021 code before use; this
specification does not re-design them.

| Symbol or file | Owner | Use |
|---|---|---|
| `DocsJson.psm1`: `ConvertFrom-DocsJsonText`, `ConvertTo-DocsCanonicalJson`, `Get-DocsSha256Hex`, `Get-DocsBytesSha256Hex` | 1020 | Parsing, canonical JSON for front-matter values and property values, page digests |
| `DocsFinding.psm1`: `New-DocsFinding`, `Get-DocsOrderedFinding`, `Test-DocsFindingHasError`, `New-DocsCommandResult`, `ConvertTo-DocsEnvelopeText`, `ConvertTo-DocsReportText` | 1020 | Findings, command result, envelope, text report |
| `DocsSchema.psm1`: `Read-DocsSchemaSet`, `Get-DocsComposedSchemaSet`, `Test-DocsArtifactText`, `Join-DocsSchemaText` | 1020 | Snapshot validation; schema composition in tests |
| `DocsSurface.psm1`: `Get-DocsElementKind`, `Test-DocsRelativePath`, `Test-DocsElementId`, `New-DocsSurfaceElement`, `ConvertFrom-DocsSurfaceElement` | 1020 | Element model, identifier grammar, path grammar |
| `DocsProfile.psm1`: `Get-DocsDefaultProfilePath`, `ConvertFrom-DocsProfileText` | 1020 | Profile load; fields read: `repository.id`, `documentation_roots`, `page_owners`, `diataxis_policy.modes`, `diataxis_policy.directory_modes`, `artifact_paths.inventory_snapshot` |
| `Invoke-DocsCommand.ps1`: dispatch table, `ConvertFrom-DocsCommandArgument`, command context (`ReadText`, `ReadBytes`, `TestFile`, `ListFile`, `WriteText`, `UtcNow`), `Write-DocsFileText` | 1020 | Registration, argument parsing, all I/O |
| `tests/scripts/claude-lib/docs/Docs.TestSupport.psm1` (in-memory command context with write log and fixed clock) | 1020 | Command and integration tests |
| `schemas/docs/v1/surface-inventory-snapshot.schema.json` (amended: `analysis_method` on elements, declaration-lines digest) | 1020 amendment | Snapshot contract |
| `schemas/docs/v1/docs-command-envelope.schema.json` | 1020 amendment | `-Json` envelope validation in tests |
| `schemas/docs/v1/page-metadata.schema.json` | 1021 | Front-matter contract; read by tests only |
| `DocsPageFrontMatter.psm1` (bounded front-matter parser) | 1021 | Grammar the emitted front matter must satisfy; called by `ConvertFrom-DocsReferenceExistingPage` if it exports pure split and parse functions (R-2) |
| `DocsPageCheck.psm1` (pure aggregate check function and the `check` command, expected `Invoke-DocsCheckCommand`) | 1021 | Integration test only; never imported by production code of this feature |

The dependency risks R-1 to R-7 in `## Dependency Risks` record which of these contracts are not
yet fixed.

## Inputs / Outputs

- Inputs:
  - Docs profile (JSON only; YAML is rejected by 1020).
  - Surface inventory snapshot (JSON). Each element may carry `analysis_method` (`native` or
    `scanner`); the generator accepts it and does not render it.
  - Existing reference pages at the planned page paths (strict UTF-8; a leading BOM is removed and
    CRLF and CR are normalized to LF before processing).
  - Command arguments listed in `### Options`.
  - No environment variable, no clock, no randomness and no network access in any function of this
    feature. `Context.UtcNow` is not read.
- Outputs:
  - Text report or one canonical JSON envelope on stdout (printed by the entry script).
  - With `-Write` only: created or updated family pages under the output directory, written
    through `Write-DocsFileText` (UTF-8 without BOM, LF).
- All paths are repository-relative POSIX paths resolved by the command context against the
  repository root. No absolute path, host name or environment value appears in any output.

## API / CLI Surface

### Dispatch row

One row in `.claude/lib/docs/Invoke-DocsCommand.ps1`, inserted directly under the 1024 anchor (the
anchor whose label contains the token `generate-reference`; see OQ-A). No other row or anchor line
is edited.

```powershell
[pscustomobject]@{ Name = 'generate-reference'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReferenceWriter.psm1'); Function = 'Invoke-DocsGenerateReferenceCommand'; Option = @{ Profile = 'value'; Snapshot = 'value'; OutputDirectory = 'value'; Write = 'switch' } }
```

### Options

| Option | Kind | Default | Meaning |
|---|---|---|---|
| `-Profile <path>` | value | `Get-DocsDefaultProfilePath` (`docs/documentation-estate/docs-profile.json`) | Profile file |
| `-Snapshot <path>` | value | `artifact_paths.inventory_snapshot` of the profile | Snapshot file |
| `-OutputDirectory <path>` | value | Derived from the profile (`### Output directory`) | Directory that holds the family pages |
| `-Write` | switch | absent | Absent: dry run, nothing written. Present: write changed pages |
| `-Json` (entry) | switch | absent | Emit the envelope instead of the text report |

- Dry run is the default; there is no dry-run switch.
- A path-valued option whose value fails `Test-DocsRelativePath` is a usage error (exit 2) detected
  before any read. If `ConvertFrom-DocsCommandArgument` does not validate path values, the command
  function returns the exit-2 result itself before its first context call.

### Exit codes

| Exit | Condition | Findings | `result` |
|---|---|---|---|
| 0 | No `error` finding; the dry run returned the plan or every write succeeded | `warning` and `info` findings allowed (`DOCS_REFERENCE_PARENT_MISSING`, `DOCS_REFERENCE_BLOCK_REMOVED`) | generation result |
| 1 | At least one `error` finding in loading or planning; nothing is written in either mode | ordered `error` findings (plus any warnings and infos) | generation result when planning ran, otherwise `null` |
| 2 | Usage error before any read | exactly one `DOCS_CLI_ARGUMENTS` | `null` |
| 3 | Write conflict, write failure, read failure other than absence, or unexpected exception | exactly one (`DOCS_REFERENCE_WRITE_CONFLICT`, `DOCS_REFERENCE_WRITE_FAILED` or `DOCS_CLI_RUNTIME`) | `null` |

An absent profile is exit 1 with the 1020 code `DOCS_PROFILE_MISSING`; an absent snapshot is exit 1
with `DOCS_REFERENCE_SNAPSHOT_MISSING`.

### `-Json` envelope and result

- The envelope is the 1020 envelope `{command, exit_code, findings, ok, result}` as canonical JSON
  produced by `ConvertTo-DocsEnvelopeText`, with `command` equal to `generate-reference` and `ok`
  `true` exactly when `exit_code` is 0. It validates against
  `schemas/docs/v1/docs-command-envelope.schema.json` for every exit code.
- `result` (exit 0 and 1): an object with exactly the keys `mode`, `pages`, `summary`, `unrendered`.
  - `mode`: `dry-run` or `write`.
  - `pages`: ordered by `path`; each page has exactly the keys `action`, `blocks`, `diff`, `path`,
    `sha256_after`, `sha256_before`, `status`.
    - `action`: `create` (page absent), `update` (new bytes differ), `none` (bytes equal),
      `blocked` (a page-scoped `error` finding prevented computation).
    - `blocks`: `added`, `removed`, `unchanged`, `updated`, each an ordinal-sorted array of element
      identifiers; all empty for `blocked`.
    - `diff`: array of region-diff lines in dry run for `create` and `update`; `null` for `none`,
      `blocked`, and in write mode.
    - `sha256_after`: lowercase hex SHA-256 of the computed page bytes, `null` for `blocked`;
      `sha256_before`: of the existing raw bytes, `null` when the page is absent.
    - `status`: `planned` (create or update not written), `skipped` (`none`), `blocked`, `created`,
      `updated`.
  - `summary`: integers `blocks_added`, `blocks_removed`, `blocks_unchanged`, `blocks_updated`,
    `page_count`, `pages_blocked`, `pages_changed` (`create` plus `update`), `pages_unchanged`.
  - `unrendered`: `{"architecture-component": <count>}` (0 when none).
- Whether the envelope schema constrains `result` per command is not yet fixed (R-6). If it does,
  this result shape is the shape the schema row must state.

### Text report

`ConvertTo-DocsReportText` prints the findings, then the `Line` array of the command result, then
the 1020 summary line `generate-reference: exit=<n> errors=<n> warnings=<n> infos=<n>`. The `Line`
array holds, in order:

1. One line per page in `path` order: `<action> <path> (+<added> ~<updated> -<removed>)`.
2. Dry run only: the region-diff lines of each page with a non-empty diff, in `path` order.
3. One line per page whose action is `create`:
   `note: <path> is new; link it from a documentation entry page`.

### Finding codes

Every code matches the 1020 grammar `^[A-Z][A-Z0-9_]*$` and is built with `New-DocsFinding`. Page
findings use pointer `''`, set `artifact_path` to the page, and carry `<path>:<line>` (1-based line
in the original page including front matter) in the message, because the 1020 finding shape has no
line field. Each code has a fixed `next_action` sentence held in the module.

| Code | Severity | Scope | Trigger |
|---|---|---|---|
| `DOCS_REFERENCE_SNAPSHOT_MISSING` | error | global | Snapshot path absent |
| `DOCS_REFERENCE_SNAPSHOT_INVALID` | error | global | Snapshot is schema-valid but an element cannot be rebuilt (identifier mismatch, parent rule, line range), an `element_id` repeats, a property `name` repeats within one element, or `captured_at` has no valid calendar date prefix |
| `DOCS_REFERENCE_REPOSITORY_MISMATCH` | error | global | Snapshot `repository` differs from profile `repository.id` |
| `DOCS_REFERENCE_OUTPUT_DIR_UNRESOLVED` | error | global | No `-OutputDirectory` and the profile has zero, or more than one, glob-free `directory_modes` entry with mode `reference` |
| `DOCS_REFERENCE_MODE_CONFLICT` | error | global or page | Global: `reference` absent from `diataxis_policy.modes` (pointer `/diataxis_policy/modes`). Page: the first covering `directory_modes` entry has another mode, or the existing page declares a valid `diataxis_mode` other than `reference` |
| `DOCS_REFERENCE_OUTPUT_OUTSIDE_ROOTS` | error | page | No `documentation_roots` entry covers the page path |
| `DOCS_REFERENCE_OWNER_UNRESOLVED` | error | page | No valid existing `owner` and no covering `page_owners` entry |
| `DOCS_REFERENCE_AUDIENCE_MISSING` | error | page | No valid existing `audience` and the covering root has empty `audience_ids` |
| `DOCS_REFERENCE_AUDIENCE_INVALID` | error | page | No valid existing `audience` and a covering-root audience identifier does not match `^[a-z0-9][a-z0-9-]*$` |
| `DOCS_REFERENCE_FRONT_MATTER_INVALID` | error | page | Existing front matter is unterminated, outside the accepted grammar, has a duplicate or unknown key, or has a value that violates the page-metadata constraint for its field |
| `DOCS_REFERENCE_MARKER_MALFORMED` | error | page | A line outside fenced code and outside an open block whose trimmed text starts with `<!-- docs:generated:` but is not an exact start or end marker |
| `DOCS_REFERENCE_MARKER_DUPLICATE` | error | page | A start marker repeats an identifier already opened in the page |
| `DOCS_REFERENCE_MARKER_UNBALANCED` | error | page | End marker without an open block, start marker while a block is open, or start marker never closed |
| `DOCS_REFERENCE_MARKER_MISMATCH` | error | page | End marker identifier differs from the open start identifier |
| `DOCS_REFERENCE_MARKER_IN_FRONT_MATTER` | error | page | A front-matter line whose trimmed text starts with `<!-- docs:generated:` |
| `DOCS_REFERENCE_FENCE_UNCLOSED` | error | page | A fenced code block outside generated blocks is not closed before the end of the page |
| `DOCS_REFERENCE_PARENT_MISSING` | warning | page | A `cli-option` whose `parent_id` is not in the snapshot (`related_ids`: the option identifier) |
| `DOCS_REFERENCE_BLOCK_REMOVED` | info | page | An existing block whose identifier is not among the page's planned elements was removed (`related_ids`: the removed identifier) |
| `DOCS_REFERENCE_WRITE_CONFLICT` | error | page (exit 3) | `-Write`: digest mismatch before overwrite, or an existing target on create |
| `DOCS_REFERENCE_WRITE_FAILED` | error | page (exit 3) | `-Write`: `WriteText` throws |

Error gating: global findings stop the run before the next stage (profile before snapshot, snapshot
and repository before planning, output directory before page reads). Page-scoped errors are
collected for every planned page; each affected page is `blocked`, and no page is written in
either mode.

## Generation Rules

### Family pages

| Family | Element kinds | File | Title |
|---|---|---|---|
| cli | `cli-command`, `cli-option` | `cli-reference.md` | `CLI reference` |
| http | `http-route` | `http-reference.md` | `HTTP reference` |
| config | `config-key` | `config-reference.md` | `Configuration reference` |
| api | `public-symbol` | `api-reference.md` | `API reference` |

- `architecture-component` elements are not rendered; their number is reported in
  `result.unrendered`.
- A family page is planned when its family has at least one element or the page already exists. An
  existing page whose family is empty loses every generated block and keeps its prose.
- No index page and no reserved block identifier are generated. The consumer links generated pages
  from an entry page.
- Page path: `<output directory>/<file>`.

### Output directory

`-OutputDirectory` when given; otherwise the single `diataxis_policy.directory_modes` entry with
`mode: reference` whose `path_or_glob` contains none of `*`, `?`, `[`. Zero or several such entries
yield `DOCS_REFERENCE_OUTPUT_DIR_UNRESOLVED`. `reference` absent from `diataxis_policy.modes`
yields `DOCS_REFERENCE_MODE_CONFLICT`.

### Path matching and precedence

- A `path_or_glob` value `E` covers a page path `P` when `P -ceq E`, when
  `P.StartsWith(E + '/', [StringComparison]::Ordinal)`, or when `P` matches `E` as a case-sensitive
  glob. Glob semantics: `*` matches any run of characters including `/`, `?` matches one character,
  `[...]` is a character class with `!` negation, every other character is literal. The glob is
  translated to an anchored .NET regular expression (`\A...\z`, `RegexOptions.CultureInvariant`, no
  `IgnoreCase`) without a cache. PowerShell `-clike`, `[WildcardPattern]` and
  `BlastRadiusGlob.psm1` `Test-GlobMatch` are not used (different semantics; module-scope cache).
- Directory mode: the first covering `directory_modes` entry in profile order decides; another mode
  gives `DOCS_REFERENCE_MODE_CONFLICT`; no covering entry is not a conflict.
- Owner: a valid existing `owner` is preserved; otherwise the `owner` of the first covering
  `page_owners` entry in profile order.
- Documentation root: the covering root with the longest `path`; ties go to the first in profile
  order.
- Audience: a valid existing `audience` is preserved; otherwise the ordinal-sorted `audience_ids`
  of the documentation root.
- The matcher is shared with 1023; its home is OQ-B.

### Element order within a page

- CLI page: commands by `(declaration, element_id)`; each command followed by its options by
  `(declaration, element_id)`; options whose parent is absent from the snapshot follow all commands
  by `(declaration, element_id)`, each with `DOCS_REFERENCE_PARENT_MISSING`.
- HTTP page: by `(route template, method, element_id)`, where the declaration is
  `<METHOD> <template>`.
- Configuration and API pages: by `(declaration, path, element_id)`.
- All comparisons are ordinal.

### Marker grammar

- Start line, exact full-line match: `<!-- docs:generated:start id=<element-id> -->`.
- End line, exact full-line match: `<!-- docs:generated:end id=<element-id> -->`.
- `<element-id>` passes `Test-DocsElementId` (1020 `element-id` pattern). No leading or trailing
  whitespace on a marker line.
- Each marker is a standalone line. Block layout written by the generator: start marker, blank
  line, body lines, blank line, end marker. One blank line separates a block from neighbouring
  content.
- Scanning skips the front-matter block and fenced code outside generated blocks (backtick or tilde
  fence of three or more characters, indented up to three spaces, closed by a fence of the same
  character at least as long). Inside an open block only marker lines are interpreted.
  `DocsReferenceMarkers.psm1` implements its own fence test and does not import the Mermaid lib.

### Merge algorithm

`Merge-DocsReferenceBlock -Line <string[]> -Desired <ordered (element id, body lines) list> -Path
-LineOffset`:

1. Parse the body; any marker or fence anomaly returns findings and no text.
2. Existing block whose identifier is in `Desired`: replace the lines between its markers with
   blank line, desired body, blank line; report `unchanged` when equal, otherwise `updated`. The
   block keeps its position.
3. Existing block whose identifier is not in `Desired`: delete from start marker through end marker
   inclusive, plus one following blank line when the line before the block is blank or the block
   starts the body; report `removed` and emit `DOCS_REFERENCE_BLOCK_REMOVED`.
4. New identifiers, in `Desired` order: insert after the end marker of the nearest preceding
   `Desired` member present in the page (including blocks inserted earlier in this step) as blank
   line plus block; otherwise before the start marker of the nearest following present member as
   block plus blank line; otherwise remove trailing blank lines, append one blank line when the
   body is non-empty, then the block. Report `added`.
5. Existing block order and all lines outside blocks are never rearranged or edited, except that
   trailing blank lines are reduced so the page ends with exactly one LF.
6. Merging the result again with the same `Desired` returns identical lines with every block
   `unchanged`.

### Front matter

- Fields and order: `owner`, `last_reviewed`, `audience`, `diataxis_mode`, `surface_refs`, then
  `title` and `extensions` when present; delimited by `---` lines.
- Line form: `<key>: <value>`, where the value is `ConvertTo-DocsCanonicalJson` output without its
  trailing LF, with U+0085, U+2028 and U+2029 escaped as `\uXXXX`. The exact grammar accepted by
  the 1021 bounded parser is not yet fixed (R-2); the emitted form must lie inside it.
- Generator-owned values: `diataxis_mode` is `reference`; `surface_refs` is the ordinal-sorted list
  of element identifiers rendered on the page (may be empty).
- Preserved when present and valid: `owner`, `audience`, `last_reviewed`, `title`, `extensions`.
- Deterministic sourcing of missing values (no clock in any function):
  - `owner` and `audience` per `### Path matching and precedence`.
  - `last_reviewed`: the first ten characters of the snapshot `captured_at`, checked for calendar
    validity with `[datetime]::TryParseExact(..., 'yyyy-MM-dd',
    [Globalization.CultureInfo]::InvariantCulture, 'None', [ref]$x)`. `Context.UtcNow` is not used,
    because it would change a new page's bytes from day to day for the same snapshot.
  - `title`: the family title, only for a new page.
- Existing front matter is read when line 1 is exactly `---` and ends at the next line that is
  exactly `---` (or `...` if the 1021 grammar admits it); it is re-rendered in canonical form, and
  comments inside it are not preserved. A page without front matter receives a rendered block and
  one blank line before the unchanged body.
- The generator's pattern constants (owner, `last_reviewed`, audience item
  `^[a-z0-9][a-z0-9-]*$`, `surface_refs` item) equal the `pattern` values in the committed
  `page-metadata.schema.json`; a test pins them.

### Rendering

- New page skeleton: front matter, blank line, `# <title>`, blank line, blocks separated by one
  blank line, single trailing LF.
- Block body per element (lists, never tables); a blank line separates the heading from the list:

```text
## Command `<declaration>`            (cli-command)
### Option `<declaration>`            (cli-option)
## Route `<declaration>`              (http-route)
## Key `<declaration>`                (config-key)
## Symbol `<declaration>`             (public-symbol)

- Name: `<name>`
- Source: `<path>` (lines <start>-<end>)     (suffix omitted when line_range is null)
- Property `<property name>`: `<json value>` (one line per property, ordinal-sorted by name)
```

- Every consumer-derived string passes through `ConvertTo-DocsReferenceSingleLine` (characters in
  Unicode categories `Cc`, `Zl`, `Zp` become a space, space runs collapse, ends are trimmed) and then
  `ConvertTo-DocsReferenceCodeSpan` (backtick delimiter one longer than the longest internal run,
  one space of padding when the text starts or ends with a backtick, or starts and ends with a
  space). Property values are `ConvertTo-DocsCanonicalJson` output without the trailing LF.
- No consumer text starts a line, so no rendered line can open an HTML block, form a marker or form
  a link. Every heading begins with a fixed English word, so no heading text begins with `how to `
  or matches `^step\s+[0-9]+\b`. The generator emits no Markdown links and no HTML other than
  markers. `analysis_method` is not rendered.
- Renderer selection by kind uses `switch -CaseSensitive` with literal function names; no
  scriptblock table and no `&` on a variable (`## Module Boundaries`).

### Dry-run diff

A region diff derived from the merge result. Because the merge never edits prose, the only changed
regions are the front-matter block and the generated blocks. `Get-DocsReferenceDiffLine` emits
`--- a/<path>` (or `--- /dev/null` for `create`) and `+++ b/<path>`, then per changed region a hunk
header `@@ -<old start>,<old count> +<new start>,<new count> @@ <region>` followed by `-` and `+`
lines, in page order. A BOM-only or line-ending-only change gives action `update` with no hunk. A
general line-LCS diff and `Compare-Object` are not used.

### Write semantics

- Planning completes before any write. If any `error` finding exists, `WriteText` is not called in
  either mode and the exit code is 1.
- Dry run: no `WriteText` call; statuses `planned`, `skipped` or `blocked`.
- `-Write`, in ordinal path order: `none` is `skipped`; `create` calls `WriteText` with mode
  `create`; `update` re-reads the page bytes, compares `Get-DocsBytesSha256Hex` with the planned
  `sha256_before`, then calls `WriteText` with mode `overwrite`. Success gives `created` or
  `updated`.
- A digest mismatch, an existing target on `create`, or a `WriteText` exception stops the run:
  exit 3 with exactly one finding (`DOCS_REFERENCE_WRITE_CONFLICT` or
  `DOCS_REFERENCE_WRITE_FAILED`, `artifact_path` the failing page, `related_paths` the pages written
  before the stop) and `result` `null`. Earlier writes are not rolled back. The re-check narrows but
  does not close the read-to-write window; the 1020 context has no compare-and-write primitive.
- The only write path is `Context.WriteText`, implemented by the real context with
  `Write-DocsFileText`.

### Determinism

- Identical profile, snapshot and existing-page bytes produce identical page bytes and identical
  envelope bytes, independent of snapshot element order, of existing-page map order, and of the
  context clock value.
- LF only; every written page ends with exactly one LF; no trailing spaces on generated lines;
  UTF-8 without BOM.
- Ordering: pages by `path`; blocks per `### Element order within a page`; findings by
  `Get-DocsOrderedFinding`; identifier lists ordinal-sorted.

## Module Boundaries

All production files are under `.claude/lib/docs/`. Notation: P = pure (strings, string arrays and
hashtables in; no filesystem, clock, process, environment or module-scope mutable state; inputs not
mutated); IO = touches the command context only through `[scriptblock]`-typed parameters. Every
function is an advanced function with `[CmdletBinding()]` and an approved verb. Every module follows
the conventions pinned by `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` and uses
only literal `Join-Path -Path $PSScriptRoot -ChildPath '<leaf>'` imports.

Dynamic-invocation rule (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`):
command-context members are never invoked as `& $Context.<Member>`. The command function passes them
to private I/O helpers whose parameters are typed `[scriptblock]` (`-ReadText`, `-ReadBytes`,
`-TestFile`, `-WriteText`) and invokes them as `& $ReadText $path`. No `Invoke-Expression`, no
`.Invoke()` workaround, no allowlist entry.

### `DocsReferencePlan.psm1`

Imports: `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSurface.psm1`, `DocsSchema.psm1`.

| Function | Kind | Property tested over the seeded set |
|---|---|---|
| `Get-DocsReferenceFamily` | P | Kinds across rows are disjoint, exclude `architecture-component`, and their union with it equals `Get-DocsElementKind`. |
| `Test-DocsReferencePathCovered -Path -Pattern` (home per OQ-B) | P | Equality and `E/` prefix always cover; a glob-free pattern covers exactly by equality or prefix; flipping the case of one letter in a glob-free pattern removes coverage; `*` crosses `/`. |
| `Resolve-DocsReferenceOutputDirectory -Profile [-OutputDirectory] -ProfilePath` returns `@{ OutputDirectory; Findings }` | P | With a valid override the result equals the override; without one the result is defined exactly when the profile has one glob-free `reference` entry, equals that entry's path, and is invariant under permutation of the other `directory_modes` entries; otherwise exactly one `DOCS_REFERENCE_OUTPUT_DIR_UNRESOLVED`. |
| `Get-DocsReferenceCandidatePagePath -OutputDirectory` returns `[string[]]` | P | One path per family row, ordinal-sorted, each equal to `<dir>/<file>`, each passing `Test-DocsRelativePath`, no duplicates, identical on a second call. |
| `ConvertFrom-DocsReferenceSnapshotText -Text -ArtifactPath -ComposedSchemaSet` | P (calls built-in `Test-Json`) | Snapshot text serialized from drawn `New-DocsSurfaceElement` records (with and without `analysis_method`) returns the same elements sorted by `element_id`; a drawn duplicated element or duplicated property name yields `DOCS_REFERENCE_SNAPSHOT_INVALID`. |
| `Get-DocsReferenceElementOrder -Family -Element` | P | Invariant under input permutation; each `cli-option` follows its parent command; orphan options follow all commands. |
| `Get-DocsReferencePagePlan -Profile -Element -OutputDirectory -ExistingPath` | P | Invariant under element and `ExistingPath` permutation; every rendered element is on exactly one page; no `architecture-component` is placed and the unrendered count equals their number; a page is planned exactly when its family is non-empty or the page exists. |

### `DocsReferenceRender.psm1`

Imports: `DocsJson.psm1`. If the module reaches 500 logical lines, the text helpers
(`ConvertTo-DocsReferenceSingleLine`, `ConvertTo-DocsReferenceCodeSpan`,
`Get-DocsReferenceSourceLine`, `Get-DocsReferencePropertyLine`) move to
`DocsReferenceRenderText.psm1`, which the epic permits for the renderer.

| Function | Kind | Property tested over the seeded set |
|---|---|---|
| `ConvertTo-DocsReferenceSingleLine -Text` | P | Output has no `Cc`, `Zl` or `Zp` character and no leading, trailing or double space; idempotent. |
| `ConvertTo-DocsReferenceCodeSpan -Text` | P | A CommonMark code-span decoder written in the test returns the input; the delimiter is longer than every internal backtick run. |
| `Get-DocsReferenceSourceLine -Path [-LineRange <int[]>]` returns `[string]` | P | A single line beginning `- Source: `; the code span decodes to `ConvertTo-DocsReferenceSingleLine` of the path; the `(lines a-b)` suffix is present exactly when a range is given and carries its start and end. |
| `Get-DocsReferencePropertyLine -Property` | P | One line per property, ordinal-sorted by name; invariant under input permutation; values equal canonical JSON. |
| `Get-DocsReferenceCliCommandBody`, `Get-DocsReferenceCliOptionBody`, `Get-DocsReferenceHttpRouteBody`, `Get-DocsReferenceConfigKeyBody`, `Get-DocsReferencePublicSymbolBody` | P | For drawn elements of the kind (declarations including ones beginning `how to` or `Step 1`): the heading begins with the fixed word and level; no heading text matches `(?i)^how to ` or `(?i)^step\s+[0-9]+\b`; no line begins with `<`; no line matches a marker. |
| `Get-DocsReferenceBlockBody -Element` (`switch -CaseSensitive`; throws for `architecture-component` or an unknown kind) | P | Equals the matching per-kind function for every drawn element; deterministic. |

### `DocsReferenceMarkers.psm1`

Imports: `DocsFinding.psm1`, `DocsSurface.psm1`.

| Function | Kind | Property tested over the seeded set |
|---|---|---|
| `Get-DocsReferenceStartMarker -ElementId`, `Get-DocsReferenceEndMarker -ElementId` | P | For every drawn identifier of every kind, `ConvertFrom-DocsReferenceMarkerLine` of the output returns the same marker kind and identifier. |
| `ConvertFrom-DocsReferenceMarkerLine -Line` | P | Total over drawn lines; any line whose trimmed text starts with `<!-- docs:generated:` and is not exact is malformed. |
| `Split-DocsReferenceTextLine -Text` | P | Joining with LF reproduces the LF-normalized input; CRLF and LF variants of a drawn text give equal arrays. |
| `Get-DocsReferenceBlockStructure -Line -Path -LineOffset` | P | For drawn well-formed pages the blocks found equal the blocks inserted; a drawn single anomaly yields exactly its finding code; marker-like lines inside fenced code are ignored. |
| `Merge-DocsReferenceBlock -Line -Desired -Path -LineOffset` | P | Idempotence; prose preservation (non-blank lines outside blocks keep their order; each prose segment is byte-identical when identifier sets are equal); removal (identifiers absent from `Desired` are reported removed and absent from the output); additions placed per merge step 4. |

### `DocsReferenceWriter.psm1`

Imports: the 1024 siblings, `DocsProfile.psm1`, `DocsSchema.psm1`, `DocsFinding.psm1`,
`DocsJson.psm1`, and `DocsPageFrontMatter.psm1` if R-2 resolves to reuse. 1021 forbids page-check
modules from importing reference modules; the reverse direction is permitted. If this module would
exceed 500 logical lines, the front-matter functions (`Split-DocsReferenceFrontMatter`,
`ConvertFrom-DocsReferenceExistingPage`, `ConvertTo-DocsReferenceFrontMatterText`,
`Get-DocsReferenceFrontMatterValue`) move to `DocsReferenceFrontMatter.psm1` (OQ-C).

| Function | Kind | Property tested over the seeded set |
|---|---|---|
| `Split-DocsReferenceFrontMatter -Line` returns `@{ FrontMatterLine; BodyLine; LineOffset; Terminated }` | P | Splitting `render + body` returns the rendered lines and the body unchanged with `LineOffset` equal to the front-matter line count; a body whose first line is not `---` returns no front matter and the body unchanged; concatenating the parts reproduces the input. |
| `ConvertFrom-DocsReferenceExistingPage -Text -Path` returns `@{ Value; BodyLine; LineOffset; Findings }` | P | Round trip: drawn valid values rendered with `ConvertTo-DocsReferenceFrontMatterText` read back equal with no finding; a drawn single-field corruption yields exactly one `DOCS_REFERENCE_FRONT_MATTER_INVALID` naming that field; never throws for any drawn text (including CRLF, BOM and unterminated blocks). |
| `ConvertTo-DocsReferenceFrontMatterText -Value` | P | Fixed field order; the reader returns the input; drawn valid values pass `Test-Json` against the committed page-metadata schema. |
| `Get-DocsReferenceFrontMatterValue -Existing -PagePlan -CapturedAt` | P | Valid existing `owner`, `audience`, `last_reviewed`, `title`, `extensions` preserved; `diataxis_mode` always `reference`; `surface_refs` equals the sorted rendered identifiers; `last_reviewed` for a new page equals the `captured_at` date prefix. |
| `ConvertFrom-DocsReferencePageByte -Bytes` | P | UTF-8 bytes of drawn text with and without BOM and with CRLF decode to the LF form; invalid bytes throw a typed error. |
| `New-DocsReferencePage -PagePlan -ExistingText -CapturedAt` | P | Applying it to its own output yields action `none`. |
| `New-DocsReferenceChangeSet -Profile -Snapshot -ExistingPage -OutputDirectory -ProfilePath` | P | Two runs, a run over a permuted element order and a run over a re-ordered `ExistingPage` map give identical page text and identical canonical JSON of the result; regeneration over its own output gives `none` for every page. |
| `Get-DocsReferenceDiffLine -Change` | P | Applying the hunks to the old lines reproduces the new lines; `none` gives no lines; `create` gives only `+` lines equal to the new text. |
| `Get-DocsReferenceReportLine -ChangeSet -Mode` returns `[string[]]` | P | One page line per page in ordinal path order whose `+`, `~` and `-` counts equal the block list lengths; diff lines only in dry run; one entry-page note per `create`; output identical under permutation of the page input order. |
| `ConvertTo-DocsReferenceResult -ChangeSet -Mode -Status` | P | Key sets equal `### -Json envelope and result`; canonical JSON identical under page input permutation. |
| `Read-DocsReferenceInput -ReadText -ReadBytes -TestFile ...` (private) | IO | Covered by in-memory context tests. |
| `Write-DocsReferenceChange -WriteText -ReadBytes -ChangeSet` (private) | IO | Covered by in-memory context tests (conflict, failure, success order). |
| `Invoke-DocsGenerateReferenceCommand -Argument -Context` | IO (context only) | Covered by command tests; never prints and never calls `exit`. |

## Property-Test Harness and Halted-Preflight Remedy

- Every public function marked P in `## Module Boundaries` has at least one property-style Pester
  test asserting the property listed in its row (owner decision D1; epic `### Generator decisions
  from the first preparation of 1024`). At T3 the tier matrix does not require property tests; the
  requirement here comes from the owner decision.
- The six functions named by the halted preflight map as follows; each property is the one stated
  in its module table above:

| Halted pure function (withdrawn design) | PowerShell function | Module |
|---|---|---|
| `resolve_output_dir` | `Resolve-DocsReferenceOutputDirectory` | `DocsReferencePlan.psm1` |
| `candidate_page_paths` | `Get-DocsReferenceCandidatePagePath` | `DocsReferencePlan.psm1` |
| `source_line` | `Get-DocsReferenceSourceLine` | `DocsReferenceRender.psm1` |
| `split_front_matter` | `Split-DocsReferenceFrontMatter` | `DocsReferenceWriter.psm1` (or `DocsReferenceFrontMatter.psm1` under OQ-C) |
| `read_existing` | `ConvertFrom-DocsReferenceExistingPage` | `DocsReferenceWriter.psm1` (or `DocsReferenceFrontMatter.psm1` under OQ-C) |
| `render_text` | `Get-DocsReferenceReportLine` | `DocsReferenceWriter.psm1` |

- Harness: `tests/scripts/claude-lib/docs/DocsReference.TestSupport.psm1` exports
  `New-DocsReferenceDraw -Seed <int>` (a hashtable holding a `[System.Random]` built with the seed)
  and drawing helpers (`Get-DocsReferenceDrawInt`, `Get-DocsReferenceDrawText -Alphabet
  -MaxLength`, `Get-DocsReferenceDrawElement -Kind`, `Get-DocsReferenceDrawProfile`,
  `Get-DocsReferenceDrawProse`, `Get-DocsReferenceDrawFrontMatter`). It keeps no module-scope state;
  each `It` builds its own draw.
- Fixed seed list `@(11, 23, 47, 101, 211)`, defined once in `BeforeDiscovery` of each property
  suite and recorded in the plan. Each property `It` runs with `-ForEach` over the seeds and draws a
  fixed number of cases per seed; every `Should` carries `-Because "seed $Seed case $i"`, so a
  failure message prints the seed and case.
- Drawn alphabets include backticks, `<`, `#`, `---`, marker-like text, U+2028, tabs, CR and
  non-ASCII letters.
- Property suites: `DocsReferencePlan.Properties.Tests.ps1`, `DocsReferenceRender.Properties.Tests.ps1`,
  `DocsReferenceMarkers.Properties.Tests.ps1`, `DocsReferenceWriter.Properties.Tests.ps1` (and the
  matching suite for any split module).

## Checker Integration Without Temporary Files

`tests/scripts/claude-lib/docs/DocsReferenceWriter.CheckerIntegration.Tests.ps1`:

1. Pure level: build a profile and snapshot as hashtables (elements through
   `New-DocsSurfaceElement`), call `New-DocsReferenceChangeSet`, collect `path -> text` for the
   generated pages, add an entry page (for example `docs/README.md`) with conforming front matter
   that links each generated page, and pass the map to the 1021 pure aggregate check function with
   an in-memory path-existence predicate and the composed schema set built from committed schema
   text. Assert zero findings. Repeat after inserting author prose (paragraphs, a fenced block that
   contains a marker-like line, non-instructional headings) around and between blocks and
   regenerating.
2. Command level: seed the 1020 in-memory context from `Docs.TestSupport.psm1` with the profile
   JSON, the snapshot JSON and the entry page; run `Invoke-DocsGenerateReferenceCommand -Argument
   @{ Write = $true } -Context $ctx`; then run the 1021 `check` command function against the same
   context. Assert exit 0 and an empty `Findings`. The first command's write log is the page set the
   second command lists and reads.

Committed schema files are read with `Get-Content -Raw` (read-only). No `TestDrive`,
`New-TemporaryFile`, `GetTempPath`, `GetTempFileName` or `$env:TEMP` is used. The 1021 function
names and parameters are confirmed against the merged 1021 code (R-1).

## Data & State

- Pure transformations: profile, snapshot and existing page bytes map to page texts and a result.
  Generated-block identity is the element identifier.
- The generator keeps no state between runs, keeps no module-scope cache, and writes no artifact
  other than the reference pages (only with `-Write`).
- No migration or backfill.

## Artifact Classification

Rule references: R1 = language rule clause (1) (pushed-down skills, helpers, hooks and libs are
PowerShell or bash); R2 = clause (2) (TypeScript only for MCP and extension commands; no row uses
it); D = epic `### Artifact classes for this epic` (schema, configuration, data, test and
documentation rows). "Avoid new Python" applies to every row. B =
`extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`.

| File | Change | Class | Language | Permitting rule |
|---|---|---|---|---|
| `.claude/lib/docs/DocsReferencePlan.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceRender.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceRenderText.psm1` | create only if the renderer reaches 500 logical lines | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceMarkers.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceWriter.psm1` | create | pushed-down helper/lib (command module) | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceFrontMatter.psm1` | create only if the writer would exceed 500 logical lines (OQ-C) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | edit: one row under the 1024 anchor | pushed-down helper/lib (entry) | PowerShell | R1 |
| B`DocsReference*.psm1` (one copy per created module) | create | pushed-down helper/lib (mirror) | PowerShell | R1 |
| B`Invoke-DocsCommand.ps1` | edit (byte-identical to the source) | pushed-down helper/lib (mirror) | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | edit: one `paths` entry per created module | schema/config/data | JSON | D |
| `tests/scripts/claude-lib/docs/DocsReferencePlan.Tests.ps1`, `DocsReferencePlan.Properties.Tests.ps1` | create | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/DocsReferenceRender.Tests.ps1`, `DocsReferenceRender.Properties.Tests.ps1` | create | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/DocsReferenceMarkers.Tests.ps1`, `DocsReferenceMarkers.Properties.Tests.ps1` | create | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/DocsReferenceWriter.Tests.ps1`, `DocsReferenceWriter.Properties.Tests.ps1`, `DocsReferenceWriter.Command.Tests.ps1`, `DocsReferenceWriter.CheckerIntegration.Tests.ps1` | create | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/DocsReferenceRenderText.Tests.ps1`, `DocsReferenceFrontMatter.Tests.ps1` (and their property suites) | create only with the matching split | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/DocsReference.TestSupport.psm1` | create | test (support module) | PowerShell (Pester) | D |
| The 1023 single-write-boundary suite (path fixed by 1023) | edit only if it flags `WriteText` use in `DocsReferenceWriter.psm1` (R-7) | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-reference-generator-1024/**` (spec, user story, plan, evidence) | edit/create | documentation | Markdown | D |

Not created or edited: any Python, TypeScript or JavaScript file, `pyproject.toml`, `poetry.lock`,
`quality-tiers.yml` (1020 classifies `.claude/lib/docs` as T3), `config/poshqc-coverage.json` and
`config/poshqc-scan.json` (their roots already cover the new files), any schema, hook, skill,
agent, MCP tool or extension command. No new third-party PowerShell module is used (epic A8).
Every artifact follows the language rule; no language exception is needed. An artifact found
during planning or execution that cannot follow the rule is raised as an owner question, not
decided.

## Implementation Strategy

- Create the four modules (plus a permitted split if triggered), their bundle copies, their
  `core.json` entries, the dispatch row and its mirrored entry script.
- Re-copy `Invoke-DocsCommand.ps1` to the bundle after the last edit, and again if a concurrent
  sibling changed it before merge.
- Tests (Pester, `tests/scripts/claude-lib/docs/`): example-based suites per module (each finding
  code with its trigger; each marker anomaly blocks only its page; front-matter conformance and
  pattern pinning), property suites per `## Property-Test Harness and Halted-Preflight Remedy`, the
  command suite (every exit path through the 1020 in-memory context), and the checker integration
  suite. CRLF and BOM inputs are built in memory, never committed as fixtures (`.gitattributes`
  normalizes committed text to LF).
- Isolation: every suite removes the `Docs*` modules (1020, 1021 and 1024) in `AfterAll`. Three
  seeded shuffled file-order runs of the docs suites in one process and one fresh single-process
  run over `tests/scripts` are recorded under `<FEATURE>/evidence/regression-testing/`.
- Dependency changes: none. Logging: none added. Rollout: additive; destination repositories obtain
  the command through the existing Claude push-down.
- Batch budget: four to six production PowerShell files plus their bundle copies and the edited
  entry script exceed the direct-mode cap, so execution runs in the item worktree under an
  exempt-route checkpoint, not in an isolated executor worktree.

### Coverage and CI

- Pester line coverage is at least 85% for each new production file under `.claude/lib/docs/`; no
  branch-coverage gate applies to Pester; no production file is excluded from measurement.
- CI: the suites run with coverage under `Invoke-PoshQCTest` in the shard jobs
  `poshqc / PowerShell QC shard 1`, `poshqc / PowerShell QC shard 2` and
  `poshqc / PowerShell QC shard 3` on `windows-latest`, aggregated by the required check
  `poshqc / PowerShell QC`. The aggregator merges coverage and enforces no per-file threshold, so
  the per-file 85% figure is local evidence read from `artifacts/pester/powershell-coverage.xml` and
  recorded under `<FEATURE>/evidence/qa-gates/` (the canonical evidence path; the earlier
  `evidence/coverage/` location is not used).
- The Python push-down contract tests named in `## Existing Tests Needing a Disposition` run in the
  existing `quality-checks7 / Code Quality & Tests` jobs and are not modified.

### File size

Logical-line tiers apply to every new production and test file: 500 lines is guidance (split when
logically separable; the renderer and writer splits above are the permitted ones), 700 lines draws
a non-blocking review warning, and a file above 800 lines is blocked by
`tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` and the PreToolUse hook. Logical line counts of
every new file are recorded in the plan evidence.

## Existing Tests Needing a Disposition

| Test | Disposition |
|---|---|
| `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` | Unchanged; new modules comply. |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | Unchanged; no allowlist entry; reports no finding for `DocsReference*.psm1`. |
| `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | Unchanged. |
| `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` | Unchanged. |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | Unchanged; satisfied by the mirror copies. |
| `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | Unchanged; satisfied by core entries and literal joins. |
| 1020 `Invoke-DocsCommand.Tests.ps1` | Unchanged if it asserts membership and anchor order; confirmed against the merged 1020 suite. |
| 1020 `Docs.Manifest.Tests.ps1`, `DocsNeutrality.Tests.ps1` | Unchanged; new files are covered automatically once listed and mirrored. |
| 1021 suites | Checked for any enumeration of `.claude/lib/docs/` files or command rows. |
| 1023 single-write-boundary test | Edited only under R-7. |

## Decisions

- **D-1 (path coverage and precedence).** `### Path matching and precedence`: exact, prefix plus
  `/`, or case-sensitive glob; first match wins for `page_owners` and `directory_modes`; longest
  covering root decides the audience.
- **D-2 (no index page).** No index page and no reserved block identifier; the text report reminds
  the consumer to link each created page from an entry page.
- **D-3 (no drift-check mode).** A separate check mode is out of scope; a dry run whose pages all
  report `none` is the side-effect-free drift signal later children may use.
- **D-4 (marker layout).** Each marker is a standalone line with blank lines inside and outside the
  block.
- **D-5 (`last_reviewed` source).** The snapshot `captured_at` date prefix; no clock read.
- **D-6 (dry-run diff).** Region diff derived from the merge result.
- **D-7 (audience guard).** `DOCS_REFERENCE_AUDIENCE_INVALID` remains until the amended 1020 profile
  schema is confirmed to use `^[a-z0-9][a-z0-9-]*$` for audience identifiers (R-4).

## Contracts Later Children Must Honor

For 900007 (MCP tools), 900009 (authoring workflow), 900010 (template and onboarding) and 1034
(enforcement and CI):

- Command: `Invoke-DocsCommand.ps1 -Command generate-reference [-Profile <path>] [-Snapshot <path>]
  [-OutputDirectory <path>] [-Write] [-Json]`. Path options are repository-relative POSIX paths.
  900007 maps `generate_docs_reference` to exactly these options and adds no logic.
- Exit codes: 0 success, 1 `error` findings (nothing written), 2 usage error (`DOCS_CLI_ARGUMENTS`),
  3 write conflict, write failure or runtime error (`DOCS_REFERENCE_WRITE_CONFLICT`,
  `DOCS_REFERENCE_WRITE_FAILED`, `DOCS_CLI_RUNTIME`).
- Envelope: `{command, exit_code, findings, ok, result}` with `command` `generate-reference`,
  validating against `schemas/docs/v1/docs-command-envelope.schema.json`; `result` is
  `{mode, pages, summary, unrendered}` with the page and summary keys in `### -Json envelope and
  result`, or `null` for exit 2 and 3.
- Finding codes use the `DOCS_REFERENCE_` prefix listed in `### Finding codes`; renaming or
  removing a code, result key, option or exit-code meaning is a breaking change that requires an
  epic-level update.
- Page family names: `cli-reference.md`, `http-reference.md`, `config-reference.md`,
  `api-reference.md`, under the profile's single glob-free `reference` directory or
  `-OutputDirectory`; no index page; `architecture-component` is not rendered.
- Marker grammar: `<!-- docs:generated:start id=<element-id> -->` and
  `<!-- docs:generated:end id=<element-id> -->`, standalone lines, blank lines inside and outside
  the block. Content between markers is generator-owned and replaced on regeneration; author prose
  belongs outside markers. 900009 authoring templates for the four reference families must keep
  this layout and must not instruct authors to edit inside a block.
- Front matter on generated pages: `diataxis_mode: reference` and `surface_refs` equal to the
  ordinal-sorted identifiers rendered on the page; `owner`, `audience`, `last_reviewed`, `title`
  and `extensions` are preserved when valid.
- Side-effect guarantee: running `generate-reference` without `-Write` performs no write through
  any path (no `WriteText` call) and is safe to run in CI or from a read-only tool; a page whose
  `action` is not `none` signals drift between the snapshot and the page. 1034 and 900010 may rely
  on this.
- Determinism: identical inputs give identical page bytes and identical envelope bytes regardless
  of the clock.

## Owner Questions

None of these is decided beyond its provisional default. Owner answers may change the affected
criteria through a specification revision.

1. **OQ-A - Dispatch anchor label.** The 1020 specification labels the 1024 anchor
   `# --- 900006: generate-reference ---` (a pre-promotion placeholder), while the epic calls it the
   1024 anchor; the 1020 amendment decides the committed label. Provisional default: insert the row
   directly under whichever anchor the amended 1020 `Invoke-DocsCommand.ps1` labels for
   `generate-reference`, located by that token, and never edit the anchor line.
2. **OQ-B - Home of the shared `path_or_glob` matcher.** 1023 and 1024 must use one rule, but 1024
   does not depend on 1023. Options: (a) the 1020 amendment adds `Test-DocsPathCovered` to
   `DocsSurface.psm1` or `DocsProfile.psm1` and both children call it; (b) 1024 defines
   `Test-DocsReferencePathCovered` in `DocsReferencePlan.psm1` and a parity test pins it to the 1023
   function; (c) 1024 imports the 1023 module. Provisional default: (a), because 1020 is being
   re-planned now; if the merged 1020 does not provide it, (b) applies and the property row for
   `Test-DocsReferencePathCovered` stays in this feature.
3. **OQ-C - Split of `DocsReferenceWriter.psm1`.** The epic permits a split only for the renderer;
   the writer is estimated at 550 to 700 logical lines. Provisional default: split out
   `DocsReferenceFrontMatter.psm1` (front-matter split, read, render and value rules) with its own
   suites, bundle copy and core entry if the writer would exceed 500 logical lines, consistent with
   the file-size policy.

## Dependency Risks

Contracts not yet fixed by the 1021 re-preparation or the 1020 amendment; each is confirmed against
merged code before the dependent task runs:

- **R-1 - 1021 check entry points.** No committed name or parameter list for the pure aggregate
  check function in `DocsPageCheck.psm1` (page map, configuration, path-existence predicate, schema
  set) or for the `check` command function (expected `Invoke-DocsCheckCommand`).
- **R-2 - Front-matter grammar.** `DocsPageFrontMatter.psm1` defines the accepted YAML subset; the
  JSON-flow line form, the open `extensions` object and `...` as a terminator are unconfirmed. If
  1021 exports pure split and parse functions, 1024 calls them instead of duplicating the grammar.
- **R-3 - 1021 rules and codes.** The distinct finding codes, the Diataxis signals (an instruction
  heading rule and a generated-block rule that fails only for non-reference modes), the fence rule,
  default entry pages and the self-contained or composed form of `page-metadata.schema.json` are
  stated only in the withdrawn Python 1021 design.
- **R-4 - Audience pattern.** The epic fixes `^[a-z0-9][a-z0-9-]*$` for both schemas; the current
  1020 specification still types profile audiences with the discovery identifier grammar.
- **R-5 - Element shape after the amendment.** `analysis_method` and the declaration-lines digest
  change the snapshot element definition; `ConvertFrom-DocsSurfaceElement` must accept the amended
  shape.
- **R-6 - Envelope schema scope.** Whether `docs-command-envelope.schema.json` constrains `result`
  per command or leaves it open.
- **R-7 - 1023 write-boundary test scope.** If the 1023 single-write-boundary test flags any
  `WriteText` use outside its boundary module, 1024 adds one allowlist entry for
  `DocsReferenceWriter.psm1` with the reason "reference pages, only with -Write"; otherwise no edit.

Further items to confirm during planning: whether `ConvertFrom-DocsCommandArgument` validates path
values, whether the real `WriteText` mode `create` fails on an existing target, that
`[System.Random]` with a fixed seed yields the same sequence on the `windows-latest` runner, and that
the regex glob translation reproduces the case-sensitive glob semantics above.

## Non-Goals

- A separate drift-check mode (D-3).
- A generated index page or reserved block identifier (D-2).
- Rendering `architecture-component` elements (narrative architecture pages belong to 900009).
- Any change to 1020 or 1021 schemas or modules.
- Emitting Markdown links between pages or from entry pages.
- The MCP tool `generate_docs_reference` (900007).
- Running an external Markdown linter or Vale.
- Preserving comments or formatting inside an existing front-matter block.

## Constraints & Risks

- Language rule: PowerShell modules, JSON data and Markdown only; no Python, TypeScript or new
  third-party module. PowerShell 7.4 floor per 1020.
- Neutrality: the 1020 `DocsNeutrality.Tests.ps1` scans every file under `.claude/lib/docs/`; no
  consumer identifier appears in framework source.
- Tests create no temporary files; pure functions receive in-memory values and command tests use the
  1020 in-memory context.
- CI-only behavior: the `windows-latest` PowerShell and its bundled JsonSchema.Net decide `Test-Json`
  results; tests assert codes and pointers, not validator wording, use forward-slash relative paths,
  and read no gitignored `artifacts/` state.
- Shared append-only edit points: `Invoke-DocsCommand.ps1` dispatch table and Claude `core.json`;
  conflicts are resolved in this child's remediation loop.
- A consumer must link generated pages from an entry page; otherwise the 1021 orphan rule reports
  them.

## Numeric Derivation Reference

Counts and enumerations in the acceptance criteria are supported by complete `## Numeric Derivation
Evidence` records in `research/2026-10-30T23-00-powershell-design-addendum-research.md`: Claim N1
(the six pure functions named by the halted preflight), Claim N2 (the four production modules
created before contingent splits) and Claim N3 (the four family pages). Each record carries two
independently constructed derivations with distinct strategies and an explicit member-set
comparison. The seed list is a fixed constant, not a derived count.

## Acceptance Criteria

- [ ] AC-01 Byte-identical rendering (property test): for each seed in `@(11, 23, 47, 101, 211)`, `New-DocsReferenceChangeSet` over a drawn profile and snapshot, run twice, run over a permuted element order and run over a re-ordered existing-page map, yields identical page text for every page and identical canonical JSON of the result; and two `Invoke-DocsGenerateReferenceCommand -Json` runs over in-memory contexts with identical files but different `UtcNow` values produce identical envelope bytes, with `last_reviewed` of each new page equal to the first ten characters of the snapshot `captured_at` (`DocsReferenceWriter.Properties.Tests.ps1`, `DocsReferenceWriter.Command.Tests.ps1`).
- [ ] AC-02 Prose preservation (property test): for each seed, `Merge-DocsReferenceBlock` over drawn prose segments and drawn existing and desired block sets keeps every non-blank line outside generated blocks in its original order, keeps every prose segment byte-identical when the desired identifier set equals the existing one, and returns identical lines with every block `unchanged` when applied a second time (`DocsReferenceMarkers.Properties.Tests.ps1`).
- [ ] AC-03 Removed block reported: regenerating a page after an element leaves the snapshot deletes that element's block, lists its identifier in the page's `blocks.removed`, emits exactly one `DOCS_REFERENCE_BLOCK_REMOVED` finding with severity `info` whose `related_ids` contains the identifier, and exits 0 (`DocsReferenceWriter.Tests.ps1`).
- [ ] AC-04 Generated pages pass the 1021 checker with zero findings: in `DocsReferenceWriter.CheckerIntegration.Tests.ps1`, the 1021 pure aggregate check function over the in-memory generated page set plus an entry page linking each page returns zero findings, both for newly created pages and after regeneration over pages containing author prose; and the 1021 `check` command run after `generate-reference -Write` against the same in-memory context exits 0 with an empty `Findings` list.
- [ ] AC-05 Dry run is the default and writes nothing: a command test without `-Write` records an empty write log on the in-memory context, exits 0, returns `mode` `dry-run` with statuses `planned`, `skipped` or `blocked`, and its text output contains the per-page line `<action> <path> (+<added> ~<updated> -<removed>)` and, for a new page, the region-diff lines `--- /dev/null` and `+++ b/<path>`; the `-Json` result carries the same lines in `pages[].diff` (`DocsReferenceWriter.Command.Tests.ps1`).
- [ ] AC-06 Write switch: with `-Write`, changed pages are written only through `Context.WriteText` in ordinal path order with mode `create` for new pages and `overwrite` for updated pages, statuses `created` or `updated`; an immediate second run writes nothing and reports action `none` and status `skipped` for every page (`DocsReferenceWriter.Command.Tests.ps1`).
- [ ] AC-07 Write stop: a digest mismatch before overwrite, an existing target on create, and a throwing `WriteText` each stop writing at that page and exit 3 with exactly one finding (`DOCS_REFERENCE_WRITE_CONFLICT`, `DOCS_REFERENCE_WRITE_CONFLICT` and `DOCS_REFERENCE_WRITE_FAILED` respectively) whose `related_paths` lists the pages written before the stop, `result` `null`, and no later page written (`DocsReferenceWriter.Command.Tests.ps1`).
- [ ] AC-08 Exit codes 1, 2 and 3: any `error` finding exits 1 in both modes with no `WriteText` call; an unknown option, a missing value, a repeated `-Profile`, and a non-relative `-Profile`, `-Snapshot` or `-OutputDirectory` each exit 2 with exactly one `DOCS_CLI_ARGUMENTS` finding, `result` `null` and no context read; a read failure other than absence exits 3 with exactly one `DOCS_CLI_RUNTIME` finding (`DocsReferenceWriter.Command.Tests.ps1`).
- [ ] AC-09 Envelope schema: the `-Json` output for an exit-0, exit-1, exit-2 and exit-3 run each validates with `Test-Json` against the committed `schemas/docs/v1/docs-command-envelope.schema.json` (composed through `Join-DocsSchemaText` if it references docs common), has `command` `generate-reference` and `ok` `true` exactly when `exit_code` is 0, and for exits 0 and 1 its `result`, page and summary key sets equal those in `### -Json envelope and result` (`DocsReferenceWriter.Command.Tests.ps1`).
- [ ] AC-10 Front-matter conformance: the front-matter values of every generated page validate with `Test-Json` against the committed `schemas/docs/v1/page-metadata.schema.json`; fields appear in the order `owner`, `last_reviewed`, `audience`, `diataxis_mode`, `surface_refs`, then `title` and `extensions` when present; `diataxis_mode` is `reference`; `surface_refs` equals the ordinal-sorted rendered identifiers; valid existing `owner`, `audience`, `last_reviewed`, `title` and `extensions` values are preserved; and the generator's pattern constants, including the audience item pattern `^[a-z0-9][a-z0-9-]*$`, equal the schema `pattern` values (`DocsReferenceWriter.Tests.ps1`).
- [ ] AC-11 Page-plan rules: tests show the family files `cli-reference.md`, `http-reference.md`, `config-reference.md` and `api-reference.md` with their element kinds; `architecture-component` elements are not rendered and are counted in `result.unrendered`; no index page is planned; the output directory comes from `-OutputDirectory` or the single glob-free `reference` directory entry, with `DOCS_REFERENCE_OUTPUT_DIR_UNRESOLVED` for zero or several entries and `DOCS_REFERENCE_MODE_CONFLICT` when `reference` is absent from `diataxis_policy.modes`; path coverage is exact, prefix plus `/`, or case-sensitive glob with first-match precedence (`DocsReferencePlan.Tests.ps1`).
- [ ] AC-12 Markers and finding codes: generated blocks use exactly `<!-- docs:generated:start id=<element-id> -->` and `<!-- docs:generated:end id=<element-id> -->` as standalone lines with a blank line inside and outside each block; marker-like lines inside fenced code are ignored; each trigger in `### Finding codes` produces its code and severity in a unit test; and each marker or fence anomaly blocks only the affected page (`action` and `status` `blocked`) while other pages are still computed and nothing is written (`DocsReferenceMarkers.Tests.ps1`, `DocsReferenceWriter.Tests.ps1`).
- [ ] AC-13 Halted-preflight remedy: `Resolve-DocsReferenceOutputDirectory`, `Get-DocsReferenceCandidatePagePath`, `Get-DocsReferenceSourceLine`, `Split-DocsReferenceFrontMatter`, `ConvertFrom-DocsReferenceExistingPage` and `Get-DocsReferenceReportLine` each have a property test over the seeded input set asserting the property stated in its row of `## Module Boundaries`.
- [ ] AC-14 Property test per pure function: every public function marked P in `## Module Boundaries` (including any function moved by a permitted split) has at least one property test in a `*.Properties.Tests.ps1` suite asserting the property in its row, including the rendering-safety property that no rendered heading begins, case-insensitively, with `how to ` or matches `^step\s+[0-9]+\b` and no rendered line other than a marker begins with `<`; the seed list `@(11, 23, 47, 101, 211)` is defined in `BeforeDiscovery`, every assertion carries `-Because "seed $Seed case $i"`, and `DocsReference.TestSupport.psm1` holds no module-scope mutable state.
- [ ] AC-15 Dispatch row under its own anchor: the committed dispatch table contains exactly one row with `Name = 'generate-reference'`, `Function = 'Invoke-DocsGenerateReferenceCommand'` and options `Profile`, `Snapshot`, `OutputDirectory` (value) and `Write` (switch), placed directly under the anchor whose label contains `generate-reference`; `Test-DocsCommandTable` returns no finding; and the feature diff of `Invoke-DocsCommand.ps1` adds that one line and changes no other line.
- [ ] AC-16 Mirror and manifest: every created `.claude/lib/docs/DocsReference*.psm1` and the edited `Invoke-DocsCommand.ps1` are SHA-256 identical to their copies under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`, each created module is listed exactly once in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, and `Docs.Manifest.Tests.ps1`, `test_push_down_claude_resource_contracts.py` and `test_push_down_pack_manifest_dependency_closure.py` pass without modification.
- [ ] AC-17 Module conventions and purity: every new module passes `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`; `enforcement-hooks-no-python-invocation.Tests.ps1` reports no `DynamicInvocation` or `InvokeExpression` finding for any `DocsReference*.psm1`; and a static test finds no `Get-Date`, `[datetime]::Now`, `[datetime]::UtcNow`, `UtcNow`, `Get-Content`, `Set-Content`, `Out-File`, `New-Item` or `[System.IO.File]` use in any `DocsReference*.psm1`, so all file and clock access goes through the command context.
- [ ] AC-18 No temporary files: no file under `tests/scripts/claude-lib/docs/` created by this feature contains `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName` or `$env:TEMP`; CRLF and BOM inputs are built in memory; every command test uses an in-memory command context.
- [ ] AC-19 Neutrality and language: `DocsNeutrality.Tests.ps1` passes with the new files present; `git diff --name-only <merge-base>..HEAD` lists no path ending in `.py`, `.ts`, `.tsx`, `.js`, `.mjs` or `.cjs`; no new module imports or `#Requires -Modules` a module outside the repository; and the plan's artifact classification table lists every created or edited file with its class, language and permitting rule.
- [ ] AC-20 File size: no new production or test file exceeds 800 logical lines (`FileSizePolicy.RepoGate.Tests.ps1` passes); the logical line count of every new file is recorded in the plan evidence; and any production module at or above 500 logical lines is split as permitted (renderer text helpers, or the front-matter module under OQ-C) or its retained size is justified in that evidence.
- [ ] AC-21 Coverage: Pester line coverage is at least 85% for each new production file under `.claude/lib/docs/` created by this feature, read from `artifacts/pester/powershell-coverage.xml` produced by `Invoke-PoshQCTest`, with no production file excluded from measurement; the per-file figures are recorded under `<FEATURE>/evidence/qa-gates/`.
- [ ] AC-22 (CI-dependent) The shard jobs `poshqc / PowerShell QC shard 1`, `poshqc / PowerShell QC shard 2` and `poshqc / PowerShell QC shard 3` and the required aggregate check `poshqc / PowerShell QC` on `windows-latest`, and the `quality-checks7 / Code Quality & Tests` jobs, pass on the pull request head.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to Pester suites or commands
- [ ] Behavior matches acceptance criteria on PowerShell 7.4 or later and on the CI `windows-latest` runner
- [ ] Every exit path (0, 1, 2, 3; conflict, failure, success) driven through the 1020 in-memory context
- [ ] Docs suites pass in three seeded shuffled file-order runs in one process and in a fresh single-process run over `tests/scripts`, with evidence under `<FEATURE>/evidence/regression-testing/`
- [ ] Toolchain pass completed (format, PSScriptAnalyzer, architecture and contract tests, Pester) in a single clean pass
- [ ] Dependency risks R-1 to R-7 each recorded as confirmed or resolved against merged 1020 and 1021 code
- [ ] Forbidden-token scan with bracket-class patterns over every changed file reports no match
- [ ] Evidence written under `docs/features/active/2026-10-30-docs-reference-generator-1024/evidence/<kind>/`

## Seeded Test Conditions (from potential)

- [ ] Unit coverage areas: page plan, each renderer, marker parse and merge, front matter, dry-run diff, write ordering
- [ ] Integration scenarios: generated pages checked with the 1021 `check` command over one in-memory context
- [ ] CLI/API examples: `Invoke-DocsCommand.ps1 -Command generate-reference` with and without `-Write`, with and without `-Json`
