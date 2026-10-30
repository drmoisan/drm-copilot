# docs-reference-generator — Spec

- **Issue:** #1024
- **Parent (optional):** #1019 (epic `documentation-estate-tooling`, wave 2, complexity band C3; depends on 1020 and 1021)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft
- **Version:** 0.3
- **Work Mode:** full-feature
- **Research:** `research/2026-10-30T22-39-docs-reference-powershell-addendum-research.md` (authoritative for the PowerShell module design, public functions, property-test table, test strategy, artifact classification and owner questions adopted below). `research/research.2026-10-30T20-59.md` describes the withdrawn Python design and is superseded for every mechanism; its language-independent rules are carried forward only where this specification restates them.

## Revision Note

Version 0.3 replaces the withdrawn Python design of version 0.2 (`packages/docs-runtime`,
`drm_copilot_docs.reference`, the `dev.docs.generate-reference` console command, `pyproject.toml`
script entries, pytest suites). This revision is a new planning cycle under owner decision D1
(2026-10-30). The generator is now a set of PowerShell modules under `.claude/lib/docs/`, reached
through `Invoke-DocsCommand.ps1 -Command generate-reference`.

`issue.md` `## Proposed Behavior` and its early-draft acceptance criteria still name the withdrawn
Python design. This specification supersedes them; `issue.md` is not edited.

Binding sources, in precedence order:

1. Owner decisions D1, D3, D4, D5 and the refined implementation-language directive (epic
   `## Owner Directive: Implementation Language (2026-10-30, refined)`, `## Owner Decisions`).
2. D5 supersedes the epic sentence that the `-Json` envelope has no schema file: the envelope
   schema is `schemas/docs/v1/docs-command-envelope.schema.json` (planned by the 1020 amendment).
3. Epic `### Generator decisions from the first preparation of 1024` and `### Naming contract`.
4. The 1020 PowerShell contracts (epic `### PowerShell contracts from the re-preparation of 1020`
   and 1020 spec `## Decisions Later Children Must Honor`).
5. 1021 language-independent checker rules (page-metadata fields and patterns, Diataxis rules,
   orphan rule, fence rule).

## Overview

The documentation-estate-tooling epic inventories the documentable surface of a destination
repository (CLI commands and options, HTTP routes, configuration keys, public symbols and
architecture components) into a revision-pinned surface inventory snapshot. Reference pages for
that surface are still written by hand, so they drift from the code, and a regeneration step that
overwrote whole pages would destroy hand-written prose. One consumer repository measured the gap by
hand: a feature epic changed 138 `src/` files while only 4 of 79 documentation pages were edited.

This feature adds a deterministic reference-page generator, written in PowerShell and pushed down
to destination repositories with the Claude core pack. It renders snapshot elements into
marker-delimited generated blocks inside fixed family reference pages, preserves every line of
author prose outside those blocks, emits front matter that conforms to the page-metadata schema and
passes the 1021 `check` subcommand, and writes nothing unless `-Write` is given. The design is
framework-native and domain-neutral; no consumer identifier appears in framework source.

## Behavior

`pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command generate-reference` runs
these stages:

1. Read and compose the docs schema set (`Read-DocsSchemaSet`, `Get-DocsComposedSchemaSet`).
2. Read and validate the docs profile (`ConvertFrom-DocsProfileText`).
3. Read and validate the surface inventory snapshot (`ConvertFrom-DocsReferenceSnapshotText`).
4. Resolve the reference output directory and plan the family pages (`Get-DocsReferencePagePlan`).
5. Read each existing candidate page through the command context.
6. Compute every page change in memory (`Get-DocsReferenceGeneration`): render one generated block
   per element, merge the blocks into the existing page or a new page skeleton without moving
   author prose, and compute the page front matter.
7. Without `-Write`: return the planned changes (per-page summary and unified-diff hunks) and write
   nothing. With `-Write`: write changed pages through `Context.WriteText` in ordinal path order,
   stopping at the first conflict or failure.
8. Return a command result; `Invoke-DocsCommand.ps1` prints the text report or the `-Json`
   envelope and sets the exit code.

### Upstream symbols consumed

Every symbol below is planned by 1020 (including its D3/D5 amendment) or 1021 and is not yet
implemented on this branch. The first plan task confirms each exported name and signature against
the merged code on `epic/documentation-estate-tooling-integration` and stops with a recorded
blocker when one is absent. This specification does not re-design them.

| Symbol | Source | Use |
|---|---|---|
| `ConvertFrom-DocsJsonText`, `ConvertTo-DocsJsonText`, `ConvertTo-DocsCanonicalJson`, `Get-DocsSha256Hex`, `Get-DocsBytesSha256Hex` (`DocsJson.psm1`) | planned by 1020 | Parsing, canonical JSON values, page digests |
| `New-DocsFinding`, `Get-DocsOrderedFinding`, `Test-DocsFindingHasError`, `New-DocsCommandResult`, `ConvertTo-DocsEnvelopeText`, `ConvertTo-DocsReportText` (`DocsFinding.psm1`) | planned by 1020 | Findings, command result, envelope and text report |
| `Read-DocsSchemaSet`, `Get-DocsComposedSchemaSet`, `Join-DocsSchemaText`, `Test-DocsArtifactText` (`DocsSchema.psm1`) | planned by 1020 | Schema set and snapshot validation as `surface-inventory-snapshot` |
| `Get-DocsElementKind`, `Test-DocsRelativePath`, `Get-DocsElementId`, `Test-DocsElementId`, `ConvertFrom-DocsSurfaceElement`, `New-DocsSurfaceElement` (`DocsSurface.psm1`) | planned by 1020 | Element model, identifier grammar, path grammar |
| `ConvertFrom-DocsProfileText`, `Get-DocsDefaultProfilePath` (`DocsProfile.psm1`) | planned by 1020 | Profile load and default path |
| `Get-DocsCommandTable`, `Test-DocsCommandTable`, `ConvertFrom-DocsCommandArgument`, `New-DocsCommandContext`, `Write-DocsFileText`, `Invoke-DocsCommandCli`; context members `ReadText`, `ReadBytes`, `TestFile`, `ListFile`, `WriteText`, `UtcNow` (`Invoke-DocsCommand.ps1`) | planned by 1020 | Entry, dispatch, argument parsing, I/O |
| `schemas/docs/v1/docs-command-envelope.schema.json`; `analysis_method` and the declaration-lines digest on snapshot elements | planned by the 1020 amendment (D3, D5) | Envelope validation; fields read and ignored by the generator |
| `tests/scripts/claude-lib/docs/Docs.TestSupport.psm1`, `Docs.Manifest.Tests.ps1`, the 1020 neutrality suite | planned by 1020 | Test support, manifest parity, neutrality |
| Front-matter parse function and fence-aware line classifier (`DocsPageFrontMatter.psm1` or a shared page-scan module) | planned by 1021 (coordination item C6) | Parse existing front-matter values; skip fenced code identically to the checker |
| `check` subcommand and its root and entry-page options | planned by 1021 (C7) | Integration test only; never called by production code |
| `schemas/docs/v1/page-metadata.schema.json` and its runtime copy under `.claude/lib/docs/schemas/v1/` | planned by 1021 (C8) | Front-matter contract; read by tests only |
| Diataxis rule `DX-NO-INSTRUCTION` (heading prefixes `how to `, `step <n>`), orphan rule `PAGE_ORPHANED` | 1021 (language-independent rules) | Constraints on emitted Markdown |

Existing code reused indirectly: `.claude/lib/discovery-validation/DiscoveryEncoding.psm1`
(canonical JSON and SHA-256), reached only through 1020 `DocsJson.psm1`. The Mermaid fence helpers
are not reused, because their blockquote and quote-depth rules differ from the 1021 fence rule.

## Inputs / Outputs

- Inputs:
  - Docs profile (JSON only; default `docs/documentation-estate/docs-profile.json` from
    `Get-DocsDefaultProfilePath`). Fields read: `repository.id`, `documentation_roots`,
    `page_owners`, `diataxis_policy.modes`, `diataxis_policy.directory_modes`,
    `artifact_paths.inventory_snapshot`.
  - Surface inventory snapshot (JSON; default `artifact_paths.inventory_snapshot` of the profile).
  - Existing reference pages at the candidate page paths (UTF-8; a leading BOM is removed and CRLF
    is normalized to LF before processing).
  - Command options listed in `## API / CLI Surface`.
  - No environment variable, no clock (the context `UtcNow` member is never called), no randomness,
    no network.
- Outputs:
  - Text report or one `-Json` envelope on stdout; one fixed stderr line on exit 3 (1020 entry
    behavior).
  - With `-Write` only: created or updated family pages under the output directory, written
    through `Context.WriteText`.
- All paths are repository-relative POSIX strings built by concatenation with `/`. `Join-Path` is
  used only for literal `$PSScriptRoot` sibling imports. No absolute path, host name, timestamp
  from the clock or environment value appears in any output.
- Versioning: removing or renaming a `result` key, finding code, exit-code meaning or option is a
  breaking change that requires an epic-level update, because 900007 wraps this contract.

## API / CLI Surface

### Invocation

```text
pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command generate-reference
    [-Profile <path>] [-Snapshot <path>] [-OutputDirectory <path>] [-Write] [-Json]
```

| Option | Kind | Default | Validation |
|---|---|---|---|
| `-Profile` | value | `Get-DocsDefaultProfilePath` | `Test-DocsRelativePath`; failure exits 2 |
| `-Snapshot` | value | `artifact_paths.inventory_snapshot` of the loaded profile | `Test-DocsRelativePath`; failure exits 2 |
| `-OutputDirectory` | value | `Resolve-DocsReferenceOutputDirectory` | `Test-DocsRelativePath` and no trailing `/`; failure exits 2 |
| `-Write` | switch | absent | Absent: dry run, nothing written. Present: write changed pages |
| `-Json` | entry switch (1020) | absent | Emits the envelope |

`-Help` and `-RepositoryRoot` are 1020 entry parameters. Unknown options, missing values and
repeated value options are usage errors detected by `ConvertFrom-DocsCommandArgument` (exit 2).
There is no `-DryRun` option; dry run is the default.

### Dispatch row

One line under the generate-reference anchor of the dispatch table in `Invoke-DocsCommand.ps1`
(anchor text fixed by the amended 1020 spec; coordination item C1; the 1020 spec v0.3 text is
`# --- 900006: generate-reference ---`, and the current manifest numbering is 1024):

```powershell
[pscustomobject]@{ Name = 'generate-reference'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReferenceWriter.psm1'); Function = 'Invoke-DocsGenerateReferenceCommand'; Option = @{ Profile = 'value'; Snapshot = 'value'; OutputDirectory = 'value'; Write = 'switch' } }
```

No other row or anchor is edited. The row passes `Test-DocsCommandTable`. Both the source and the
bundle copy of `Invoke-DocsCommand.ps1` carry the row.

### Exit codes

| Code | Condition | Findings | `result` |
|---|---|---|---|
| 0 | No `error` finding. Dry run computed the plan, or write mode completed every required write | `warning` and `info` findings only | Non-null |
| 1 | At least one `error` finding during loading or planning (nothing written in either mode); `DOCS_PROFILE_MISSING`; `REFERENCE_SNAPSHOT_MISSING`; a write conflict (`REFERENCE_WRITE_CONFLICT`) | Ordered findings | `null` when the profile did not load; otherwise non-null |
| 2 | Usage or input error detected before any read | Only `DOCS_CLI_ARGUMENTS` | `null` |
| 3 | Uncomposable schema set; a read failure other than absence or any unexpected exception (`DOCS_CLI_RUNTIME` at the entry boundary); an exception from `WriteText` (`REFERENCE_WRITE_FAILED`, OQ-3) | Exactly one finding | `null` |

Change from version 0.2: an absent profile or snapshot is exit 1 (the 1020 `validate-profile`
convention) rather than exit 3; a write conflict is exit 1 with a full result.

### `-Json` envelope and `result`

The envelope is the 1020 canonical JSON `{command, exit_code, findings, ok, result}` (sorted keys,
compact, one trailing LF), with `command` equal to `generate-reference`. It validates against
`schemas/docs/v1/docs-command-envelope.schema.json` (D5; composed through `Join-DocsSchemaText` when
it references docs common, otherwise self-contained). `result`:

| Key | Content |
|---|---|
| `mode` | `dry-run` or `write` |
| `output_directory` | Resolved directory or `null` |
| `pages` | Ordinal by `path`; each `{action, blocks: {added, removed, unchanged, updated}, diff, path, sha256_after, sha256_before, status}`. Empty when a global error stopped planning |
| `summary` | `blocks_added`, `blocks_removed`, `blocks_unchanged`, `blocks_updated`, `page_count`, `pages_blocked`, `pages_changed` (`create` plus `update`), `pages_unchanged` (`none`); finding counts are in the 1020 summary line and are not repeated |
| `unrendered` | `{"architecture-component": <count of snapshot elements of that kind>}` |

Page fields:

| Key | Content |
|---|---|
| `action` | `create` (page absent), `update` (new bytes differ from existing bytes), `none` (bytes equal), `blocked` (a page-scoped `error` finding prevented computation) |
| `blocks` | Each list ordinal-sorted element identifiers; all empty for `blocked` |
| `diff` | Hunk text in dry run for `create` and `update`; `null` for `none`, `blocked` and in write mode |
| `sha256_after` | Lowercase hex SHA-256 of the computed page bytes; `null` for `blocked` |
| `sha256_before` | Lowercase hex SHA-256 of the existing raw page bytes; `null` when the page is absent |
| `status` | `planned`, `skipped`, `created`, `updated`, `conflict`, `not-attempted`, `blocked` |

The version 0.2 keys `tool`, `report_version` and `uncertain_paths`, and the status `failed`, are
dropped: the envelope carries the command name, and an exit-3 result is `null`.

### Text output

`Get-DocsReferenceReportLine` returns, in order: one `<action> <path> (+<added> ~<updated>
-<removed>)` line per page in ordinal path order; in dry run, the diff lines of each changed page;
one `note: <path> is new; link it from a documentation entry page so that the check command does
not report PAGE_ORPHANED` line per created page; then one mode line (`dry run, nothing written`,
`wrote <n> page(s)`, or `nothing written`). 1020 `ConvertTo-DocsReportText` prints the finding lines
before these and the `generate-reference: exit=<n> errors=<n> warnings=<n> infos=<n>` summary line
after them.

### Dry-run diff

A structural diff, not a general line diff. The merge records every edited region (front-matter
block replaced, each added, updated or removed generated block, trailing-blank-line normalization)
as `@{ BeforeStart; BeforeCount; AfterStart; AfterCount }` in page coordinates.
`Format-DocsReferenceDiff` prints unified-diff hunks: `--- a/<path>` (or `--- /dev/null` for a new
page), `+++ b/<path>`, `@@ -a,b +c,d @@`, up to three context lines, overlapping hunks merged,
LF-terminated. Prose outside generated blocks is never an edit. A page whose bytes differ only by a
BOM or CRLF line endings has action `update` and an empty diff.

### Write semantics

- Planning completes before any write. When any `error` finding exists, `WriteText` is never
  called in either mode; computed pages get `not-attempted` in write mode and `planned` in dry run,
  and blocked pages get `blocked`.
- Dry run: status `planned` for `create` and `update`, `skipped` for `none`, `blocked` for
  `blocked`.
- Write mode, pages in ordinal path order: `none` gets `skipped`. `create`: `TestFile` immediately
  before writing; an existing target gives `conflict`; otherwise `WriteText` with mode `create`
  gives `created`. `update`: `ReadBytes` immediately before writing; a SHA-256 different from
  `sha256_before` gives `conflict`; otherwise `WriteText` with mode `overwrite` gives `updated`.
- First `conflict`: processing stops, later pages get `not-attempted`, and the command exits 1 with
  one `REFERENCE_WRITE_CONFLICT` finding and the full result. Earlier writes are not rolled back
  and are reported.
- An exception from `WriteText`: exit 3 with exactly one `REFERENCE_WRITE_FAILED` finding whose
  `related_paths` holds the failed path and whose message states how many pages were written before
  it; `result` is `null` (OQ-3).
- The check-then-write sequence is not atomic. It detects concurrent edits between planning and
  writing; it cannot close the window between the check and the write. This is a documented limit.
- All writes go through `Context.WriteText`, which the real 1020 context implements with
  `Write-DocsFileText`, the only filesystem write primitive. No 1024 module calls a filesystem
  cmdlet or a .NET file API. Context members are invoked only through a private helper whose
  parameters are `[scriptblock]`-typed (the Python-invocation guard's carve-out (a)); `&` is never
  applied to a member expression and `.Invoke()` is not used.

### Finding-code catalog

Findings are built with `New-DocsFinding`. `artifact_path` is the profile, snapshot or page path;
`pointer` is an RFC 6901 pointer into the profile or snapshot, or `''` for page findings
(front-matter field findings use `/<field>`). Page line numbers are 1-based in the original page,
including front matter, and appear in the message. `next_action` is a fixed sentence per code.

| Code | Severity | Scope | Trigger |
|---|---|---|---|
| `DOCS_JSON_*`, `DOCS_SCHEMA_*`, `DOCS_PROFILE_*` | error | global | Passed through unchanged from `ConvertFrom-DocsProfileText` and `Test-DocsArtifactText` |
| `DOCS_PROFILE_MISSING` | error | global | The profile path does not exist (exit 1) |
| `REFERENCE_SNAPSHOT_MISSING` | error | global | The snapshot path does not exist (exit 1) |
| `REFERENCE_SNAPSHOT_INVALID` | error | global | The snapshot is schema-valid but an element fails `ConvertFrom-DocsSurfaceElement`, an `element_id` repeats, or a property `name` repeats within one element |
| `REFERENCE_REPOSITORY_MISMATCH` | error | global | Snapshot `repository` differs from profile `repository.id` |
| `REFERENCE_OUTPUT_DIR_UNRESOLVED` | error | global | No `-OutputDirectory` and the profile has zero, or more than one, `directory_modes` entry with mode `reference` whose `path_or_glob` contains none of `*`, `?`, `[` |
| `REFERENCE_MODE_CONFLICT` | error | global or page | Global: `reference` is absent from `diataxis_policy.modes` (pointer `/diataxis_policy/modes`). Page: the first `directory_modes` entry covering the page has another mode, or the existing page declares a valid `diataxis_mode` other than `reference` |
| `REFERENCE_OUTPUT_OUTSIDE_ROOTS` | error | page | No `documentation_roots` entry covers the page path |
| `REFERENCE_OWNER_UNRESOLVED` | error | page | No valid existing `owner` and no `page_owners` entry covers the path |
| `REFERENCE_AUDIENCE_MISSING` | error | page | No valid existing `audience` and the covering root has empty `audience_ids` |
| `REFERENCE_FRONT_MATTER_INVALID` | error | page | Existing front matter is unterminated, rejected by the 1021 parser (including a duplicate key or a non-mapping value), has a key outside the page-metadata properties, or has a value that violates the page-metadata constraint for its field |
| `REFERENCE_MARKER_MALFORMED` | error | page | A line outside fenced code and outside an open block whose trimmed text starts with `<!-- docs:generated:` but is not an exact start or end marker (indentation, trailing text, identifier outside the element-id grammar) |
| `REFERENCE_MARKER_DUPLICATE` | error | page | A start marker repeats an identifier already opened in the page |
| `REFERENCE_MARKER_UNBALANCED` | error | page | An end marker without an open block, a start marker while a block is open, or a start marker never closed |
| `REFERENCE_MARKER_MISMATCH` | error | page | An end marker identifier differs from the open start identifier |
| `REFERENCE_MARKER_IN_FRONT_MATTER` | error | page | A front-matter line whose trimmed text starts with `<!-- docs:generated:` |
| `REFERENCE_FENCE_UNCLOSED` | error | page | A fenced code block outside generated blocks is not closed before the end of the page |
| `REFERENCE_PARENT_MISSING` | warning | page | A `cli-option` whose `parent_id` is not in the snapshot (rendered after all commands); `related_ids` holds the option identifier |
| `REFERENCE_BLOCK_REMOVED` | info | page | An existing block whose identifier is not among the page's planned elements was removed; `related_ids` holds the removed identifier |
| `REFERENCE_WRITE_CONFLICT` | error | page | Write mode: existing target on create, or digest mismatch on update (exit 1) |
| `REFERENCE_WRITE_FAILED` | error | page | Write mode: exception from `WriteText` (exit 3) |
| `DOCS_CLI_ARGUMENTS` | error | invocation | Exit 2 (1020) |
| `DOCS_CLI_RUNTIME` | error | runtime | Exit 3 at the entry boundary (1020) |

`REFERENCE_AUDIENCE_INVALID` (version 0.2) is removed: the epic fixes one audience pattern,
`^[a-z0-9][a-z0-9-]*$`, for profile audience identifiers and the page-metadata `audience` item, so
the condition is unreachable on a schema-valid profile and would be untestable code. If
coordination item C4 reports that the amended 1020 profile schema does not enforce the pattern, the
code is reinstated through a specification revision.

Error gating: global findings stop the run before the next stage (profile errors before the
snapshot read; snapshot or repository errors before planning; output-directory errors before page
reads), and `pages` is empty. Page-scoped errors are collected for every planned page; each
affected page is `blocked` and other pages are computed.

## Generation Rules

### Page-plan rules

- Fixed family pages: `cli-command` and `cli-option` render to `cli-reference.md` (title
  `CLI reference`); `http-route` to `http-reference.md` (`HTTP reference`); `config-key` to
  `config-reference.md` (`Configuration reference`); `public-symbol` to `api-reference.md`
  (`API reference`). Page path: `<output-directory>/<file name>`.
- `architecture-component` elements are not rendered; they are counted in
  `result.unrendered.architecture-component`. Narrative architecture pages belong to 900009.
- No index page and no reserved block identifier are generated. The consumer links generated pages
  from an entry page; the text report prints a reminder for each created page.
- A family page is planned when its family has at least one snapshot element or the page already
  exists. An existing page whose family has no elements has all its blocks removed and its prose
  kept.

### Output directory

`-OutputDirectory` when given; otherwise the single `diataxis_policy.directory_modes` entry with
mode `reference` whose `path_or_glob` contains none of `*`, `?`, `[`; otherwise
`REFERENCE_OUTPUT_DIR_UNRESOLVED`. `reference` must be a member of `diataxis_policy.modes`.

### Path matching and precedence

- A profile `path_or_glob` value `E` covers a page path `P` when `P` equals `E`, when `P` starts
  with `E` followed by `/`, or when `P` matches `E` as a case-sensitive glob. The glob is translated
  to an anchored regular expression: `*` becomes `.*` (it crosses `/`), `?` becomes `.`, `[...]`
  becomes a character class with a leading `!` mapped to `^`, and every other character passes
  through `[regex]::Escape`. `-like` and `-clike` are not used. The same rule serves 1023; the home
  of the shared function is OQ-2.
- Directory mode: the first `directory_modes` entry in profile order covering `P` decides; a mode
  other than `reference` gives `REFERENCE_MODE_CONFLICT`. No covering entry is not a conflict.
- Owner: a valid existing `owner` is preserved; otherwise the `owner` of the first `page_owners`
  entry in profile order covering `P`; none gives `REFERENCE_OWNER_UNRESOLVED`.
- Documentation root: the covering root with the longest `path`; ties go to the first in profile
  order; none gives `REFERENCE_OUTPUT_OUTSIDE_ROOTS`.
- Audience: a valid existing `audience` is preserved; otherwise the ordinal-sorted `audience_ids`
  of the documentation root; empty gives `REFERENCE_AUDIENCE_MISSING`. Audience identifiers follow
  `^[a-z0-9][a-z0-9-]*$`, the pattern 1020 and 1021 adopt in both schemas.

### Element order within a page

- CLI page: commands by `(declaration, element_id)`; each command is followed by its options by
  `(declaration, element_id)`; options whose parent is absent from the snapshot follow all
  commands, ordered by `(declaration, element_id)`, each with `REFERENCE_PARENT_MISSING`.
- HTTP page: by `(route template, method, element_id)`, where the declaration is
  `<METHOD> <template>`.
- Configuration and API pages: by `(declaration, path, element_id)`.
- Every comparison is ordinal (`[System.StringComparer]::Ordinal`); `Sort-Object` and the
  case-insensitive operators are not used for ordering or matching.

### Marker grammar and layout

- Start line, exact full-line match: `<!-- docs:generated:start id=<element-id> -->`.
- End line, exact full-line match: `<!-- docs:generated:end id=<element-id> -->`.
- `<element-id>` passes `Test-DocsElementId` (the 1020 `element-id` pattern).
- Each marker is a standalone line with no leading or trailing whitespace. The generator writes a
  block as: start marker, blank line, body lines, blank line, end marker; and separates each block
  from surrounding content by a blank line, so each comment forms its own HTML block and headings
  keep blank-line separation.
- Scanning skips the front-matter block and fenced code outside generated blocks, using the 1021
  fence classifier (backtick or tilde fence of three or more characters, indented up to three
  spaces, closed by the same character with at least the same length; C6). Inside an open generated
  block only marker lines are interpreted.

### Merge algorithm

`Merge-DocsReferenceBlock` over the body lines and the ordered desired items `@{ ElementId; Line }`:

1. Parse the body (`ConvertFrom-DocsReferenceBody`); any marker or fence error returns findings and
   no lines.
2. An existing block whose identifier is desired: replace the lines between its markers with blank
   line, desired body lines, blank line. Report `unchanged` when the replaced lines are equal,
   otherwise `updated`. The block keeps its position.
3. An existing block whose identifier is not desired: delete from start marker through end marker
   inclusive, plus one following blank line when the line before the block is blank or the block
   starts the body. Report `removed` and emit `REFERENCE_BLOCK_REMOVED`.
4. New identifiers, in desired order: insert after the end marker of the nearest preceding desired
   member present in the page (including blocks inserted earlier in this step) as blank line plus
   block; otherwise before the start marker of the nearest following present member as block plus
   blank line; otherwise remove trailing blank lines from the body, append one blank line when the
   body is non-empty, then the block. Report `added`.
5. Existing block order and all lines outside blocks are never rearranged or edited, except that
   trailing blank lines at the end of the page are reduced so the page ends with exactly one LF.
6. Merging the result again with the same desired items returns identical lines with every block
   `unchanged`.

### Front-matter rules

- Existing front matter is recognized only when line 1 (after BOM removal and CRLF normalization)
  is exactly `---`; it ends at the next line that is exactly `---` or `...`
  (`Split-DocsReferenceFrontMatter`). Field values are parsed by the 1021 front-matter parser, so
  generator and checker read the block identically (C6). No YAML library is used (A8).
- Rendered form (`ConvertTo-DocsReferenceFrontMatterText`): `---`, one `<key>: <JSON value>` line
  per field in the order `owner`, `last_reviewed`, `audience`, `diataxis_mode`, `surface_refs`,
  `title` (when present), `extensions` (when present), then `---`, LF-terminated. JSON values come
  from `ConvertTo-DocsCanonicalJson` without its trailing LF, with U+0085, U+2028 and U+2029
  re-escaped as `\u` sequences. Each line is valid YAML flow syntax; quoting keeps `last_reviewed` a
  string.
- Generator-owned values: `diataxis_mode` is `reference`; `surface_refs` is the ordinal-sorted list
  of identifiers rendered on the page (possibly empty).
- Preserved when present and valid: `owner`, `audience`, `last_reviewed`, `title`, `extensions`. A
  missing field is filled: `owner` and `audience` per `### Path matching and precedence`;
  `last_reviewed` as the first ten characters of the snapshot `captured_at`; `title` only for a new
  page.
- Existing page without front matter: a rendered block and one blank line are inserted before the
  unchanged body. YAML comments inside an existing block are not preserved.
- Pattern constants equal the page-metadata schema patterns (`owner` `^\S(.*\S)?$`,
  `last_reviewed` `^[0-9]{4}-[0-9]{2}-[0-9]{2}$` plus calendar validity, audience item
  `^[a-z0-9][a-z0-9-]*$`, `surface_refs` item `^\S+$`); a test pins them against the committed
  schema file.

### Rendering rules

- New page skeleton: front matter, blank line, `# <title>`, blank line, blocks separated by one
  blank line, single trailing LF.
- Block body per element (lists, never tables), produced by one table-driven
  `Get-DocsReferenceBlockLine`:

```text
## Command `<declaration>`            (cli-command)
### Option `<declaration>`            (cli-option)
## Route `<declaration>`              (http-route)
## Key `<declaration>`                (config-key)
## Symbol `<declaration>`             (public-symbol)

- Name: `<name>`
- Source: `<path>` (lines <start>-<end>)     (parenthesis omitted when line_range is null)
- Property `<property name>`: `<json value>` (one line per property, ordinal by name)
```

- Every heading starts with a fixed English word followed by a code span, so no heading text
  begins with `how to ` or matches `^step\s+[0-9]+\b` (1021 `DX-NO-INSTRUCTION`).
- Every consumer-derived string (declaration, name, path, property name, property value as
  canonical JSON) passes through `ConvertTo-DocsReferenceSingleLine` and then
  `ConvertTo-DocsReferenceCodeSpan`. No consumer text starts a line, so no rendered line can open an
  HTML block, form a marker or form a link.
- `ConvertTo-DocsReferenceSingleLine`: replace every `\p{Cc}`, `\p{Zl}`, `\p{Zp}` character with a
  space, collapse space runs, trim both ends.
- `ConvertTo-DocsReferenceCodeSpan`: delimiter is a backtick run one longer than the longest
  backtick run in the text; one space of padding on both sides when the text starts or ends with a
  backtick, or starts and ends with a space.
- `analysis_method` and the element digest are read but never rendered, so a change of analysis
  method (scanner to native, D3) or of digest causes no page change (C5).
- The generator emits no Markdown links and no HTML other than marker comments.

### Determinism rules

- Identical profile, snapshot and existing page bytes produce identical page bytes and identical
  envelope bytes, independent of element order in the snapshot and of the order of the existing
  page map.
- LF only; every written page ends with exactly one LF; no trailing spaces on generated lines;
  UTF-8 without BOM (enforced by `Write-DocsFileText`).
- No clock, randomness, environment variable, host name or absolute path is read into output.
- Ordering: pages by ordinal path; blocks per `### Element order within a page`; findings by
  `Get-DocsOrderedFinding`; identifier lists ordinal-sorted.

## Module Design

Five production modules under `.claude/lib/docs/`, each with a byte-identical copy under
`extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` and an entry in the
Claude `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`. The epic
lists four modules and allows research to refine names; `DocsReferenceFrontMatter.psm1` is split
from the writer to stay within the 500-line guidance.

| Module | Role | Purity | Imports (literal `Join-Path -Path $PSScriptRoot -ChildPath '<file>'`) |
|---|---|---|---|
| `DocsReferencePlan.psm1` | Snapshot conversion, path coverage, output directory, candidate paths, page plan, unrendered count | pure | `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSchema.psm1`, `DocsSurface.psm1` |
| `DocsReferenceRender.psm1` | Single-line and code-span escaping, source and property lines, block body per element kind | pure | `DocsJson.psm1` |
| `DocsReferenceMarkers.psm1` | Marker lines, fence-aware body parse, block merge with edit records | pure | `DocsSurface.psm1`, `DocsFinding.psm1`, the 1021 module exporting the fence classifier |
| `DocsReferenceFrontMatter.psm1` | Delimiter split, existing-page conversion, value resolution, canonical rendering | pure | `DocsJson.psm1`, `DocsFinding.psm1`, `DocsPageFrontMatter.psm1` (1021) |
| `DocsReferenceWriter.psm1` | Pure composition, diff rendering, result and report lines; the `generate-reference` command function | mixed (I/O through the command context only) | the four modules above, `DocsFinding.psm1`, `DocsJson.psm1`, `DocsProfile.psm1`, `DocsSchema.psm1`, `DocsSurface.psm1` |

Contingency: when `DocsReferenceWriter.psm1` reaches 500 logical lines, `Format-DocsReferenceDiff`,
`ConvertTo-DocsReferenceResult` and `Get-DocsReferenceReportLine` move to
`DocsReferenceReport.psm1` with its own suite, bundle copy and `core.json` entry; every criterion
below that names the new modules then also applies to it.

Module conventions (1020): help block containing `imports its siblings with -ErrorAction Stop`;
`Set-StrictMode -Version Latest` followed by `$ErrorActionPreference = 'Stop'`; `-ErrorAction Stop`
on every column-0 `Import-Module`; advanced functions with `[CmdletBinding()]`; no module-scope
mutable state; command modules neither write output nor call `exit`. The reference modules import
no `DocsLedger*`, `DocsAnalyzer*` or `DocsInventory*` module.

### Public functions

"Pure" follows 1020: no filesystem, clock, process, environment or module-scope mutable state;
inputs are strings, arrays and dictionaries (hashtables) and are not mutated.

| Function | Module | Class | Contract |
|---|---|---|---|
| `ConvertFrom-DocsReferenceSnapshotText -Text -ArtifactPath -ComposedSchemaSet` | Plan | pure | Returns `@{ Snapshot; Element; Finding }`; validates as `surface-inventory-snapshot`, rebuilds each element with `ConvertFrom-DocsSurfaceElement`, sorts by `element_id`, reports `REFERENCE_SNAPSHOT_INVALID` |
| `Test-DocsReferencePathCovered -Path -Pattern` | Plan | pure | Returns `[bool]` per `### Path matching and precedence`; not created if OQ-2 resolves to a shared 1020 function, in which case that function carries the same property test |
| `Resolve-DocsReferenceOutputDirectory -Profile -ProfilePath [-OutputDirectory]` | Plan | pure | Returns `@{ OutputDirectory; Finding }` per `### Output directory` |
| `Get-DocsReferenceCandidatePagePath -OutputDirectory` | Plan | pure | Returns the family page paths under the directory in ordinal order |
| `Get-DocsReferencePagePlan -Profile -Element -OutputDirectory -ExistingPagePath -ProfilePath` | Plan | pure | Returns `@{ Page; Unrendered; Finding }`; page records carry `Path`, `Title`, ordered `Element`, `Owner`, `RootId`, `Audience` and page-scoped findings |
| `ConvertTo-DocsReferenceSingleLine -Text` | Render | pure | Single-line normalization |
| `ConvertTo-DocsReferenceCodeSpan -Text` | Render | pure | CommonMark code span |
| `Format-DocsReferenceSourceLine -Path [-LineRange]` | Render | pure | ``- Source: `<path>` (lines <start>-<end>)``, parenthesis omitted when `LineRange` is null |
| `Format-DocsReferencePropertyLine -Property` | Render | pure | One property line per property, ordinal by name |
| `Get-DocsReferenceBlockLine -Element` | Render | pure | Block body lines per kind; throws for `architecture-component` |
| `Get-DocsReferenceMarkerLine -ElementId -Position` | Markers | pure | Start or end marker; throws for an identifier failing `Test-DocsElementId` |
| `ConvertFrom-DocsReferenceMarkerLine -Line` | Markers | pure | `$null` for a non-marker line, otherwise `@{ Position; ElementId; Malformed }` |
| `ConvertFrom-DocsReferenceBody -Line -PagePath -LineOffset` | Markers | pure | Returns `@{ Segment; Finding }` (prose and block segments, marker and fence findings with page line numbers) |
| `Merge-DocsReferenceBlock -Line -Desired -PagePath -LineOffset` | Markers | pure | Returns `@{ Line; Added; Updated; Unchanged; Removed; Edit; Finding }` per `### Merge algorithm` |
| `Split-DocsReferenceFrontMatter -Text` | FrontMatter | pure | Returns `@{ HasFrontMatter; Terminated; FrontMatterLine; BodyLine; BodyLineOffset }` after BOM removal and CRLF normalization |
| `ConvertFrom-DocsReferencePageText -Text -PagePath` | FrontMatter | pure | Returns `@{ Value; HasFrontMatter; BodyLine; BodyLineOffset; Finding }`; performs no read |
| `Resolve-DocsReferenceFrontMatterValue -Existing -PagePlan -SurfaceRef -CapturedAt -IsNewPage` | FrontMatter | pure | Returns `@{ Value; Finding }` per `### Front-matter rules` |
| `ConvertTo-DocsReferenceFrontMatterText -Value` | FrontMatter | pure | Canonical front-matter block |
| `Get-DocsReferenceGeneration -Profile -Snapshot -Element -ExistingPage -OutputDirectory -ProfilePath` | Writer | pure | Composes plan, render, merge and front matter; `ExistingPage` maps each candidate path to `$null` or `@{ Text; Sha256 }`; returns `@{ Page; Unrendered; Finding }` |
| `Format-DocsReferenceDiff -PagePath -BeforeLine -AfterLine -Edit [-IsNewPage]` | Writer | pure | Hunk text or `''` |
| `ConvertTo-DocsReferenceResult -Generation -Mode [-WriteStatus] [-OutputDirectory]` | Writer | pure | The ordered `result` object |
| `Get-DocsReferenceReportLine -Result` | Writer | pure | Command-specific text lines |
| `Invoke-DocsGenerateReferenceCommand -Argument -Context` | Writer | I/O through the command context only | Returns `New-DocsCommandResult` |
| `Invoke-DocsReferencePageWrite -Change -ReadBytes -TestFile -WriteText` (private) | Writer | I/O through `[scriptblock]` parameters | One guarded write per `### Write semantics` |

## Data & State

- Pure transformations: profile, snapshot and existing page texts map to page contents and a
  result. Generated-block identity is the element identifier.
- The generator keeps no state between runs and writes no artifact other than the family pages.
- No caching, migration or backfill.

## Implementation Strategy

- Files (create): the five modules; their bundle copies; the Pester suites and test-support module
  listed in `## Artifact Classification`.
- Files (edit): `.claude/lib/docs/Invoke-DocsCommand.ps1` and its bundle copy (one dispatch row);
  `core.json` (five paths).
- No edit to `quality-tiers.yml` (1020 adds `.claude/lib/docs` as T3), `config/poshqc-coverage.json`
  (`roots` already contains `.claude/lib`) or `config/poshqc-scan.json` (`test.scanFolders`
  already contains `tests/scripts`).
- The plan opens with an upstream-symbol confirmation task against the integration branch and
  records each consumed 1020 and 1021 symbol under `<FEATURE>/evidence/other/`.
- Execution runs in the item worktree under an exempt-route checkpoint, because the production file
  count exceeds the direct-mode batch budget.
- Dependency changes: none (PowerShell 7.4 built-ins only, A8). Logging: none. Rollout: additive;
  destination repositories receive the modules through the existing Claude push-down.

### Tests

Location: `tests/scripts/claude-lib/docs/`, mirroring `.claude/lib/docs/`. Suites:
`DocsReferencePlan.Tests.ps1`, `DocsReferenceRender.Tests.ps1`, `DocsReferenceMarkers.Tests.ps1`,
`DocsReferenceMarkers.Properties.Tests.ps1`, `DocsReferenceFrontMatter.Tests.ps1`,
`DocsReferenceWriter.Tests.ps1`, `DocsReferenceWriter.Properties.Tests.ps1`,
`DocsReferenceIntegration.Tests.ps1`, `DocsReferenceBoundary.Tests.ps1`, and the test-support
module `DocsReference.TestSupport.psm1` (or an extension of 1020 `Docs.TestSupport.psm1` when its
re-prepared spec exposes a generator hook). Property tests may also be split into further
`*.Properties.Tests.ps1` files to stay within file-size guidance.

Rules:

- No test creates a temporary file. No test uses `TestDrive`, `New-TemporaryFile`,
  `[System.IO.Path]::GetTempFileName`, `[System.IO.Path]::GetTempPath`, `$env:TEMP`, `$env:TMP` or
  `Start-Process` (`.claude/hooks/check-powershell-test-purity.ps1`).
- Pure functions receive in-memory strings and hashtables. Command tests run through 1020
  `Invoke-DocsCommandCli` (dot-sourced) with an in-memory context: `ReadText`, `ReadBytes`,
  `TestFile` and `ListFile` read a hashtable of path to text; `WriteText` appends
  `@{ RelativePath; Text; Mode }` to a recording list and updates the hashtable; `UtcNow` throws.
  The real context and `Write-DocsFileText` are never called. The only committed files read are
  schema files (read-only).
- BOM and CRLF fixtures are built in memory, because `.gitattributes` normalizes committed text to
  LF.
- Every suite imports what it uses with `-Force` in `BeforeAll` and removes `Docs*` modules in
  `AfterAll`.

### Property tests

Mechanism: seeds `11, 23, 47, 101, 211`, one Pester case per seed through
`It '<property> (seed <Seed>)' -ForEach @(@{ Seed = 11 }, ...)`, so the seed is in the name of
every failing test; assertions also pass `-Because "seed $Seed"`. Each case builds
`[System.Random]::new($Seed)` and draws a bounded number of inputs through generators in the test
support module (`Get-DocsReferenceRandomText`, `New-DocsReferenceRandomElement`,
`New-DocsReferenceRandomProse`, `New-DocsReferenceRandomProfile`, `Get-DocsReferenceShuffled`).
Properties assert relations, not drawn values. That a seeded `[System.Random]` yields the same
sequence across .NET releases is not verified; the properties do not depend on it.

Every public pure function in `### Public functions` has at least one seeded property test:

| Public pure function | Property |
|---|---|
| `ConvertFrom-DocsReferenceSnapshotText` | Drawn elements serialized in drawn order parse back to the same identifiers in ordinal order; duplicating a drawn element yields `REFERENCE_SNAPSHOT_INVALID` |
| `Test-DocsReferencePathCovered` | Agrees with the oracle: the path and every proper directory prefix cover it; a differing case-flipped variant does not; a glob built by replacing drawn segments with `*` or characters with `?` covers it; a non-prefix sibling does not |
| `Resolve-DocsReferenceOutputDirectory` | An override is returned unchanged with no finding for any drawn profile; without an override, a directory is returned exactly when one non-glob `reference` entry exists and equals that entry; invariant under permutation of the non-reference entries; every finding code is `REFERENCE_OUTPUT_DIR_UNRESOLVED` or `REFERENCE_MODE_CONFLICT` |
| `Get-DocsReferenceCandidatePagePath` | For drawn valid relative directories: each path is `<dir>/` plus a family file name, the leaf set equals the family file set, each path passes `Test-DocsRelativePath`, the list is ordinal-sorted, and two calls return equal arrays |
| `Get-DocsReferencePagePlan` | Every rendered element appears on exactly one page and `architecture-component` on none; options follow their parent command; the planned page set equals families with elements plus existing paths; invariant under element permutation; `Unrendered` equals the drawn architecture count |
| `ConvertTo-DocsReferenceSingleLine` | No `\p{Cc}`, `\p{Zl}`, `\p{Zp}`, double space or edge space in the output; idempotent |
| `ConvertTo-DocsReferenceCodeSpan` | A test-local CommonMark code-span decoder returns the input for drawn single-line texts; the delimiter run is longer than every internal backtick run |
| `Format-DocsReferenceSourceLine` | For drawn paths (including backticks, control characters, U+2028) and drawn nullable line ranges: one line with no LF starting `- Source: `; decoding the code span yields `ConvertTo-DocsReferenceSingleLine` of the path; the parenthesis is present exactly when a range is given and carries both bounds |
| `Format-DocsReferencePropertyLine` | One line per property, ordinal by name, each starting `- Property `; invariant under property permutation |
| `Get-DocsReferenceBlockLine` | The heading word matches the kind; no heading text matches `(?i)^how to ` or `(?i)^step\s+[0-9]+\b`, including for declarations drawn to start with those words; no line starts with `<` or with a marker prefix; no trailing spaces |
| `Get-DocsReferenceMarkerLine` with `ConvertFrom-DocsReferenceMarkerLine` | Round trip for every element kind and position; drawn mutations (leading space, trailing text, identifier outside the grammar) parse as `Malformed` |
| `ConvertFrom-DocsReferenceBody` | For drawn well-formed bodies, block segments equal the drawn blocks in order and prose segments reconstruct the drawn prose; marker-like lines inside fences are never blocks |
| `Merge-DocsReferenceBlock` | Prose preservation; idempotence; removal reporting; applying `Edit` to the input reproduces the output (see the acceptance criterion) |
| `Split-DocsReferenceFrontMatter` | Rejoining delimiters, front-matter lines and body lines reproduces the LF-normalized input; `BodyLineOffset` equals the front-matter line count including delimiters; an input whose first line is not exactly `---` yields `HasFrontMatter` false and the whole text as body; BOM and CRLF variants give identical output |
| `ConvertFrom-DocsReferencePageText` | For drawn valid value sets rendered with `ConvertTo-DocsReferenceFrontMatterText` and drawn bodies: parsed values equal drawn values, the body is unchanged, BOM and CRLF variants agree, and inserting a marker line into the block yields `REFERENCE_MARKER_IN_FRONT_MATTER` with the correct line |
| `Resolve-DocsReferenceFrontMatterValue` | `diataxis_mode` is always `reference`; `surface_refs` equals the sorted page identifiers; drawn valid existing values are preserved; a missing `last_reviewed` equals the first ten characters of the drawn `captured_at` |
| `ConvertTo-DocsReferenceFrontMatterText` | Field order is fixed; every value line is a single line; parsing the output with `ConvertFrom-DocsReferencePageText` returns the input values |
| `Get-DocsReferenceGeneration` | Byte identity across two runs and across a shuffled element order; regenerating over the first run's output gives action `none` for every page |
| `Format-DocsReferenceDiff` | A test-local hunk applier reconstructs the after lines from the before lines and the hunks; an empty edit list gives `''` |
| `ConvertTo-DocsReferenceResult` | Summary counts equal counts derived from `pages`; key sets equal `### -Json envelope and result`; invariant under input page permutation |
| `Get-DocsReferenceReportLine` | Page lines in ordinal path order for every permutation of the input page array; no line contains CR or LF; the note-line count equals the number of `create` pages; two calls return equal arrays |

The first preparation halted at preflight on missing property tests for the pure functions now
named `Resolve-DocsReferenceOutputDirectory`, `Get-DocsReferenceCandidatePagePath`,
`Format-DocsReferenceSourceLine`, `Split-DocsReferenceFrontMatter`,
`ConvertFrom-DocsReferencePageText` and `Get-DocsReferenceReportLine`. Their rows above address
that halt.

Example-based tests complement the properties: every finding trigger in the catalog, each marker
error class blocking only its page, each exit-2 usage case, absent profile and snapshot, an
injected read exception, write conflict on create and on update, and an injected `WriteText`
exception.

### Runner, CI jobs and coverage

- Local runner: `Invoke-PoshQCTest` from `scripts/powershell/PoshQC/PoshQC.psd1` under PowerShell 7;
  pass and fail counts from `artifacts/pester/pester-junit.xml`; per-file line coverage from
  `artifacts/pester/powershell-coverage.xml`, recorded under `<FEATURE>/evidence/coverage/`.
- CI: the suites are discovered through `config/poshqc-scan.json` and assigned automatically to
  `poshqc / PowerShell QC shard 1`, `shard 2` or `shard 3` (`windows-latest`); the required
  aggregate check is `poshqc / PowerShell QC` (`windows-latest`), which verifies shard completeness
  and merges coverage. Formatting and PSScriptAnalyzer run in `poshqc / PowerShell QC static`
  (`windows-latest`). `poshqc / PowerShell hook suites (Linux)` does not run these suites.
- The Python push-down contract tests run unchanged in `quality-checks7 / Code Quality & Tests`.
- Line coverage at least 85% per new production file; Pester measures no branch coverage, so no
  branch gate applies. No production file is excluded from measurement; unreachable defensive code
  is removed rather than left uncovered.
- Isolation evidence: three seeded shuffled file-order runs and one fresh single-process run over
  `tests/scripts`, recorded under `<FEATURE>/evidence/regression-testing/`.

### File size

Logical-line tiers apply to every new production and test file: 500 lines is guidance, 700
advisory, and a file above 800 lines is blocked. `DocsReferenceWriter.psm1` and
`DocsReferenceMarkers.psm1` are the files to watch; the `DocsReferenceReport.psm1` contingency
applies at 500. Logical line counts are recorded in the plan evidence.

## Artifact Classification

Rules: R1 = directive clause (1) (pushed-down skills, helpers, hooks and libs are PowerShell or
bash); R2 = clause (2) (TypeScript only for MCP and extension commands; none here); D = epic
`### Artifact classes for this epic`. "Avoid new Python" applies to every row.

| File (create unless noted) | Class | Language | Permitting rule |
|---|---|---|---|
| `.claude/lib/docs/DocsReferencePlan.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceRender.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceMarkers.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceFrontMatter.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceWriter.psm1` | pushed-down helper/lib (command module) | PowerShell | R1 |
| `.claude/lib/docs/DocsReferenceReport.psm1` (only under the file-size contingency) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` (edit: one row) | pushed-down helper/lib (entry) | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` copies of the files above | pushed-down helper/lib (mirror) | PowerShell | R1, D |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit: one path per new module) | schema/config/data | JSON | D |
| `tests/scripts/claude-lib/docs/DocsReference*.Tests.ps1`, `DocsReference*.Properties.Tests.ps1`, `DocsReference.TestSupport.psm1` | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-reference-generator-1024/**` (spec, user story, plan, research, evidence) | documentation | Markdown | D |

No schema, example, hook, skill, agent, MCP tool, extension command, Python file or TypeScript file
is created or edited. Every artifact follows the language rule; no artifact requires an owner
question on language.

## Non-Goals

- A drift-check mode; 900008 reads `result.summary.pages_changed` from a dry run instead.
- A generated index page or a reserved block identifier.
- Rendering `architecture-component` elements (900009 owns narrative architecture pages).
- Any change to the 1020 or 1021 schemas or modules; contract needs are routed as coordination
  items C1 to C8.
- Emitting Markdown links between pages or from entry pages.
- The MCP tool `generate_docs_reference` (900007).
- Running an external Markdown linter or Vale (D4: linting is optional).
- Preserving YAML comments or formatting inside an existing front-matter block.
- Any Python or TypeScript code.

## Constraints & Risks

- Framework code is domain-neutral; the 1020 neutrality suite scans the new files under
  `.claude/lib/docs/`.
- 1020 and 1021 are re-prepared concurrently and not implemented; every consumed symbol is
  confirmed against merged code before use, and a missing symbol stops the plan with a recorded
  blocker.
- `Invoke-DocsCommand.ps1` and `core.json` are append-only shared edit points with other children;
  conflicts are resolved in the remediation loop.
- The existing Python-invocation guard (`enforcement-hooks-no-python-invocation.Tests.ps1`) scans
  `.claude/lib` and reports `&` through a member expression; context members are therefore called
  through `[scriptblock]`-typed parameters.
- PowerShell `Sort-Object`, `-match`, `-like`, `-eq`, `-split` and `@{}` are case-insensitive and,
  for sorting, culture-aware; every ordering and match uses ordinal comparers and case-sensitive
  operators, so local and `windows-latest` results agree.
- `Test-Json` behavior on the CI runner depends on its PowerShell release; tests assert finding
  codes and pointers, not `Test-Json` message text.
- The write check-then-write sequence is not atomic (documented limit).
- A consumer must link generated pages from an entry page; otherwise `check` reports
  `PAGE_ORPHANED`.

## Decisions Later Children Must Honor

- **900007 (`generate_docs_reference`).** Invokes `pwsh -NoProfile -File
  .claude/lib/docs/Invoke-DocsCommand.ps1 -Command generate-reference -Json` with optional
  `-Profile`, `-Snapshot`, `-OutputDirectory` (and `-Write` only if OQ-1 allows it), with the
  workspace root as working directory; parses the envelope; adds no logic. Its Jest tests pin the
  `result` key set of `### -Json envelope and result`. Exit 1 on a write conflict carries a full
  result; exit 3 carries a null result.
- **900008.** May detect page drift in CI by running the dry run with `-Json` and reading
  `result.summary.pages_changed`; no separate check mode exists. The feature-review
  surface-change check treats generated blocks as generator-owned.
- **900009.** Page templates for `cli-reference`, `http-reference`, `config-reference` and
  `api-reference` use the fixed family file names and front matter with `diataxis_mode: reference`
  and conforming `owner`, `audience` and `last_reviewed`, and contain no generated-block markers.
  Roles author prose only outside markers and never edit inside a generated block. The reconciler
  calls `generate-reference` (or the MCP tool) to refresh blocks. Consumer entry pages link each
  generated page (orphan rule).
- **900010.** The end-to-end fixture drives `generate-reference -Write` through an in-memory
  context and runs `check` over the result.
- **1023.** The `path_or_glob` coverage rule of `### Path matching and precedence` is shared
  (OQ-2); generated pages list their element identifiers in `surface_refs`, which page bindings may
  reference.

Coordination confirmations requested from the concurrent 1020 and 1021 re-preparations (contract
confirmations, routed by the coordinator; not language questions):

- **C1 (1020).** The anchor line for generate-reference in the dispatch table (`900006` in 1020
  spec v0.3; 1024 under the current manifest).
- **C2 (1020).** `WriteText` mode `create` behavior on an existing target and whether it creates
  parent directories; `ReadBytes` availability; whether `ReadText` decodes strictly (invalid UTF-8).
- **C3 (1020).** The envelope schema keeps `result` open (any JSON value); the function the
  envelope test uses (`Test-Json` over a composed or self-contained schema).
- **C4 (1020).** Whether the amended profile schema enforces `^[a-z0-9][a-z0-9-]*$` on audience
  identifiers (this specification assumes it does and drops `REFERENCE_AUDIENCE_INVALID`).
- **C5 (1020).** `analysis_method` and the declaration-lines digest on snapshot elements; the
  generator ignores both, so a change of analysis method causes no page churn.
- **C6 (1021).** Export a front-matter parse function and a fence-aware line classifier from
  `DocsPageFrontMatter.psm1` or a shared page-scan module; the parser accepts `<key>: <JSON>` lines
  (double-quoted strings with `\u` escapes, flow sequences of double-quoted strings).
- **C7 (1021).** The `check` subcommand options for root and entry pages, and continuation of the
  `DX-NO-INSTRUCTION` heading prefixes (`how to `, `step <n>`).
- **C8 (1021).** `page-metadata` in `Get-DocsSchemaName` under the 1021 anchor and a byte-identical
  runtime copy under `.claude/lib/docs/schemas/v1/`.

## Open Questions

Owner questions (each changes another child's criteria or a shared contract). The provisional
default applies until the owner answers; an answer may change the affected criteria through a
specification revision.

1. **OQ-1 - MCP mutation scope.** Epic 900007 states `update_docs_ledger` is the only mutating
   tool, yet `generate_docs_reference` maps to a command whose `-Write` switch writes pages.
   Options: (a) the MCP tool exposes dry run only, and writes happen through a skill calling
   `Invoke-DocsCommand.ps1 -Write`; (b) the tool exposes `-Write` and the 900007 criterion is
   narrowed to ledger, matrix and pin artifacts. Provisional default: (a).
2. **OQ-2 - Home of the shared path-coverage function.** Options: (a) the 1020 amendment adds
   `Test-DocsPathCovered` to `DocsSurface.psm1` and both 1023 and 1024 import it; (b) 1023 owns it
   and 1024 imports a ledger-area module; (c) each child keeps a copy with a parity test.
   Provisional default: (a). Until it is confirmed, the plan keeps `Test-DocsReferencePathCovered`
   in `DocsReferencePlan.psm1`.
3. **OQ-3 - Write failure under the 1020 exit-3 rule.** Exit 3 carries one finding and a null
   result, so pages written before a failure appear only in the finding message. Options: (a)
   accept, with one `REFERENCE_WRITE_FAILED` finding naming the failed path; (b) allow
   `generate-reference` to return exit 1 with a full result for a write failure. Provisional
   default: (a).

Pending dependencies (not owner questions): coordination items C1 to C8 above. Each consumed 1020
and 1021 symbol is re-confirmed against merged code before use.

## Acceptance Criteria

All Pester criteria run locally through `Invoke-PoshQCTest` and in CI under the required check
`poshqc / PowerShell QC` (suites sharded to `PowerShell QC shard 1` to `shard 3` on
`windows-latest`). Every test uses in-memory inputs and creates no temporary file.

- [ ] Rendering the same snapshot twice is byte-identical: for each seed in `11, 23, 47, 101, 211`, `Get-DocsReferenceGeneration` over a drawn profile and snapshot, run twice and run on a shuffled element order, yields identical page texts for every page; and two `-Json` command runs over the same in-memory inputs, plus one over a shuffled snapshot element order, produce identical written page texts and identical envelope bytes (Pester `DocsReferenceWriter.Properties.Tests.ps1` and `DocsReferenceIntegration.Tests.ps1`, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] Prose outside generated markers is preserved across regeneration: for each seed, `Merge-DocsReferenceBlock` over drawn prose segments and drawn existing and desired block sets keeps every non-blank line outside generated blocks in its original relative order, keeps every prose segment byte-identical when the desired identifier set equals the existing one, returns identical lines with every block `unchanged` when applied a second time, and applying its `Edit` records to the input reproduces its output (Pester `DocsReferenceMarkers.Properties.Tests.ps1`, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] A removed element's block is removed and reported: regenerating after one element leaves the snapshot removes that element's block, lists its identifier in `result.pages[].blocks.removed`, emits one `REFERENCE_BLOCK_REMOVED` finding with severity `info` whose `related_ids` contains that identifier, exits 0, and leaves every other page line unchanged (Pester `DocsReferenceIntegration.Tests.ps1`, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] Every generated page passes the 1021 `check` subcommand with zero findings: after `generate-reference -Write` into an in-memory context and the addition of an entry page with conforming front matter linking each generated page, `Invoke-DocsCommandCli -Command check -Json` over the same context (with the root and entry options fixed by 1021, C7) exits 0 with an empty `findings` array; a second case inserts seeded prose around and between the blocks, regenerates, checks again, and also exits 0 with an empty `findings` array and the prose unchanged (Pester integration test `DocsReferenceIntegration.Tests.ps1`, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] Emitted front matter conforms to `page-metadata.schema.json`: for every generated page, the front-matter block parsed with the 1021 parser and serialized with `ConvertTo-DocsJsonText` makes `Test-Json -Schema` against the committed `schemas/docs/v1/page-metadata.schema.json` return `True`; the 1024 pattern constants equal the schema patterns read from the same file; and valid existing `owner`, `audience`, `last_reviewed`, `title` and `extensions` values are preserved on regeneration (Pester `DocsReferenceIntegration.Tests.ps1` and `DocsReferenceFrontMatter.Tests.ps1`, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] `-Json` output validates against `schemas/docs/v1/docs-command-envelope.schema.json`: the stdout of a dry run, a write run, an exit-1 run, an exit-2 run and an exit-3 run each make `Test-Json` return `True` against the envelope schema (composed through `Join-DocsSchemaText` when it references docs common, otherwise self-contained, per D5); the envelope keys are exactly `command`, `exit_code`, `findings`, `ok`, `result`; `command` is `generate-reference`; and on exit 0 the `result`, page and `summary` key sets equal those in `### -Json envelope and result` (Pester `DocsReferenceIntegration.Tests.ps1`, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] Without `-Write` nothing is written and the planned changes are printed: the in-memory context's `WriteText` recording list stays empty, the exit code is 0, text output contains each `<action> <path> (+<added> ~<updated> -<removed>)` line and the hunk headers (`--- /dev/null` and `+++ b/<path>` for a new page) followed by the line `dry run, nothing written`, and the `-Json` result has `mode` `dry-run`, status `planned` and a non-null `diff` for each `create` and `update` page (Pester `DocsReferenceWriter.Tests.ps1`, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] With `-Write`, pages are written only through `Context.WriteText` (the 1020 `Write-DocsFileText` in the real context): the recording list holds one entry per changed page in ordinal path order with mode `create` for new pages and `overwrite` for updated pages and statuses `created` or `updated`; an immediate second run records no write and reports action `none` and status `skipped` for every page (Pester `DocsReferenceWriter.Tests.ps1`, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] A write conflict (an existing target on `create`, or a `ReadBytes` digest that differs from `sha256_before` on `update`) stops writing at that page with status `conflict`, gives later pages `not-attempted`, records no write for the conflicting page, and exits 1 with one `REFERENCE_WRITE_CONFLICT` finding and a non-null result; an exception thrown by `WriteText` exits 3 with `findings` holding only `REFERENCE_WRITE_FAILED` (its `related_paths` holding the failed path), `result` `null`, and one stderr line (Pester `DocsReferenceWriter.Tests.ps1`, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] Exit codes follow 0/1/2/3: an unknown option, a missing option value, a repeated value option, a non-relative `-Profile`, `-Snapshot` or `-OutputDirectory`, and an `-OutputDirectory` ending in `/` each exit 2 with `findings` holding only `DOCS_CLI_ARGUMENTS` and `result` `null`; an absent profile exits 1 with `DOCS_PROFILE_MISSING`; an absent snapshot exits 1 with `REFERENCE_SNAPSHOT_MISSING`; a `ReadText` exception other than absence exits 3 with `findings` holding only `DOCS_CLI_RUNTIME`, `result` `null` and one stderr line; any `error` finding during loading or planning exits 1 with no recorded write in either mode (Pester `DocsReferenceWriter.Tests.ps1`, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] Each trigger in `### Finding-code catalog` produces its listed code and severity in an example-based test, and each marker error class (`REFERENCE_MARKER_MALFORMED`, `REFERENCE_MARKER_DUPLICATE`, `REFERENCE_MARKER_UNBALANCED`, `REFERENCE_MARKER_MISMATCH`, `REFERENCE_MARKER_IN_FRONT_MATTER`, `REFERENCE_FENCE_UNCLOSED`) blocks only the affected page (`action` and `status` `blocked`) while other pages are computed (Pester `DocsReferenceMarkers.Tests.ps1`, `DocsReferenceFrontMatter.Tests.ps1`, `DocsReferenceWriter.Tests.ps1`, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] A seeded property-style Pester test exists for each public pure function that addressed the halted earlier preflight — `Resolve-DocsReferenceOutputDirectory`, `Get-DocsReferenceCandidatePagePath`, `Format-DocsReferenceSourceLine`, `Split-DocsReferenceFrontMatter`, `ConvertFrom-DocsReferencePageText` and `Get-DocsReferenceReportLine` — asserting the property stated in its row of `### Property tests`, with one case per seed in `11, 23, 47, 101, 211`, the seed in the test name and in `-Because` (Pester, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] A seeded property-style Pester test exists for every other public pure function listed in `### Public functions` (`ConvertFrom-DocsReferenceSnapshotText`, `Test-DocsReferencePathCovered` or the shared function chosen under OQ-2, `Get-DocsReferencePagePlan`, `ConvertTo-DocsReferenceSingleLine`, `ConvertTo-DocsReferenceCodeSpan`, `Format-DocsReferencePropertyLine`, `Get-DocsReferenceBlockLine`, `Get-DocsReferenceMarkerLine`, `ConvertFrom-DocsReferenceMarkerLine`, `ConvertFrom-DocsReferenceBody`, `Merge-DocsReferenceBlock`, `Resolve-DocsReferenceFrontMatterValue`, `ConvertTo-DocsReferenceFrontMatterText`, `Get-DocsReferenceGeneration`, `Format-DocsReferenceDiff`, `ConvertTo-DocsReferenceResult`), asserting the property in its `### Property tests` row with the same seed mechanism; a test-side inventory compares the exported functions of every new `DocsReference*.psm1` module with the property-test table and fails when an exported pure function has no property test (Pester, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] Generation rules are enforced by tests: the family pages are exactly `cli-reference.md`, `http-reference.md`, `config-reference.md` and `api-reference.md` under the output directory; `architecture-component` elements appear on no page and are counted in `result.unrendered`; no index page is planned; `-OutputDirectory` overrides the profile, and without it the single non-glob `reference` directory entry is used or `REFERENCE_OUTPUT_DIR_UNRESOLVED` is reported; path matching accepts exact, prefix plus `/` and case-sensitive glob matches with first-match owner and directory-mode precedence; the longest covering documentation root supplies the audience (Pester `DocsReferencePlan.Tests.ps1`, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] Every generated block has standalone marker lines with a blank line after the start marker, a blank line before the end marker, and a blank line between the block and adjacent content; no rendered heading begins, case-insensitively, with `how to ` or matches `^step\s+[0-9]+\b`; and no rendered line other than a marker line begins with `<` (Pester `DocsReferenceRender.Tests.ps1` and `DocsReferenceWriter.Properties.Tests.ps1`, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] Generated pages are deterministic and clock-free: every command test runs with an in-memory context whose `UtcNow` member throws, and passes; every written page is LF-only, ends with exactly one LF, has no trailing spaces on generated lines and no BOM; and changing every element's `analysis_method` (scanner to native) and digest leaves every page action `none` (Pester `DocsReferenceWriter.Tests.ps1`, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] The module-boundary test passes: an AST scan of every new `DocsReference*.psm1` module finds no `CommandAst` named `Set-Content`, `Add-Content`, `Out-File`, `New-Item`, `Remove-Item`, `Copy-Item`, `Move-Item`, `Get-Content`, `Test-Path`, `Get-Date`, `Get-Random` or `Invoke-Expression`, no `[System.IO.File]` or `[System.IO.Directory]` type expression, no `$Context` reference outside `DocsReferenceWriter.psm1`, and no import of a `DocsLedger*`, `DocsAnalyzer*` or `DocsInventory*` module (Pester `DocsReferenceBoundary.Tests.ps1`, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] The `generate-reference` dispatch row is the only line added to the dispatch table, sits directly under the generate-reference anchor fixed by the amended 1020 spec (C1), names `DocsReferenceWriter.psm1` and `Invoke-DocsGenerateReferenceCommand` with options `Profile`, `Snapshot`, `OutputDirectory` (value) and `Write` (switch), and `Test-DocsCommandTable` returns no finding for the committed table (Pester, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] Push-down copies are byte-identical: each of `DocsReferencePlan.psm1`, `DocsReferenceRender.psm1`, `DocsReferenceMarkers.psm1`, `DocsReferenceFrontMatter.psm1`, `DocsReferenceWriter.psm1` and the edited `Invoke-DocsCommand.ps1` is SHA-256 identical to its copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`; each new module is listed exactly once in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; 1020 `Docs.Manifest.Tests.ps1` passes (Pester, `poshqc / PowerShell QC` on `windows-latest`); and the existing push-down contract tests `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py` pass without modification.
- [ ] No Python or TypeScript file is added or modified: `git diff --name-only <merge-base>..HEAD` lists no path ending in `.py`, `.ts`, `.tsx`, `.js`, `.mjs` or `.cjs`; and the plan's artifact classification table lists every created or edited file with its class, language and permitting rule.
- [ ] Tests create no temporary files: no file under `tests/scripts/claude-lib/docs/` added by this feature contains `TestDrive`, `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `$env:TEMP`, `$env:TMP` or `Start-Process`; pure-function tests pass only strings, arrays and hashtables; and every command test uses an in-memory command context.
- [ ] The existing suites `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` and the 1020 neutrality suite pass unmodified with the new modules present (Pester, `poshqc / PowerShell QC` on `windows-latest`).
- [ ] Every new production module under `.claude/lib/docs/` is at most 500 logical lines (the `DocsReferenceReport.psm1` contingency applies otherwise), and every new test file is at most 800 logical lines.
- [ ] Pester line coverage is at least 85% for each of `DocsReferencePlan.psm1`, `DocsReferenceRender.psm1`, `DocsReferenceMarkers.psm1`, `DocsReferenceFrontMatter.psm1` and `DocsReferenceWriter.psm1` (and `DocsReferenceReport.psm1` if created), read from the PoshQC coverage report produced by `Invoke-PoshQCTest`, with no production file excluded from measurement (no branch-coverage gate applies to Pester); the figures are recorded under `<FEATURE>/evidence/coverage/`.
- [ ] The upstream-symbol confirmation record under `<FEATURE>/evidence/other/` lists every 1020 and 1021 symbol in `### Upstream symbols consumed` with its confirmed module and signature on the integration branch, and no 1024 task consumes a symbol before it is confirmed.
- [ ] Test isolation is verified: three seeded shuffled file-order runs and one fresh single-process run over `tests/scripts` pass, each recorded under `<FEATURE>/evidence/regression-testing/` with its seed.
- [ ] (CI-dependent) The required check `poshqc / PowerShell QC` (aggregating `PowerShell QC shard 1` to `shard 3` on `windows-latest`), `poshqc / PowerShell QC static` and the `quality-checks7 / Code Quality & Tests` jobs pass on the pull request head.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)

- [ ] Unit coverage areas: page plan, block rendering, marker parse and merge, front matter, writer dry run
- [ ] Integration scenarios: generated pages checked with the 1021 `check` subcommand
- [ ] CLI/API examples: `Invoke-DocsCommand.ps1 -Command generate-reference` with and without `-Write`
