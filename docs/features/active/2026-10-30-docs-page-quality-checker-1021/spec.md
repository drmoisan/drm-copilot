# docs-page-quality-checker — Spec

- **Issue:** #1021
- **Parent (optional):** #1019 (epic documentation-estate-tooling, child 1021, wave 1, band C3; depends on 1020)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft
- **Version:** 0.3 (re-preparation for the refined implementation-language rule; new planning cycle under D1)
- **Work Mode:** full-feature
- **Research (primary design source):** `research/2026-10-30T22-45-docs-page-quality-checker-powershell-design-addendum-research.md`
- **Research (language-independent rules only):** `research/research.2026-10-30T20-35.md`

## Revision Note

Version 0.2 of this specification described a separate Python package (`packages/docs-page-check`,
import name `drm_copilot_docs_check`, console command `dev.docs.check`, `jsonschema` and PyYAML
validation, pytest suites, `pyproject.toml`, `poetry.lock` and `quality-tiers.yml` edits, and base
configuration under `extensions/drm-copilot/resources/templates/docs-quality/`). That design is
withdrawn by the epic `## Owner Directive: Implementation Language (2026-10-30, refined)`. Under
owner decision D1 this revision is a new planning cycle with a fresh allowance of one planner
revision and the single-pass preflight.

This version specifies a PowerShell design under `.claude/lib/docs/`, behind
`Invoke-DocsCommand.ps1 -Command check`, built on the 1020 contracts. Language-independent rules
from the earlier research are kept: the front-matter fields, the slug rule, the link and anchor
rules, the Diataxis structure rules and the orphan rule. Where `issue.md` still describes the
Python design, this file is authoritative.

Issue renumbering: epic placeholders are cited by their issue numbers. 1022 (was 900003) is the
Python/config scanner, 1024 (was 900006) is the reference generator, 1034 (was 900008) is
docs-enforcement-and-ci, and 1031 (was 900011) is the Python-native analyzer. The 1020 dispatch
anchors that still carry placeholder labels are not touched by this feature.

## Overview

A destination repository that adopts the documentation-estate tooling has no framework-provided way
to check the structural quality of its documentation pages. Pages can lack ownership and review
metadata, carry broken relative links or missing heading anchors, drift from their declared
Diataxis mode, or become orphans that no entry page reaches. One consumer repository built a
bespoke checker for these conditions; the framework needs a domain-neutral equivalent that a
destination repository receives through the existing Claude push-down and runs with PowerShell 7.4
only. No Markdown QC configuration exists on `main` (epic A3), so the framework also has no base
linter or Vale configuration a consumer can adopt.

The design is framework-native. No source from the consumer repository is copied, and consumer
vocabulary stays consumer-owned.

## Behavior

Create six PowerShell modules under `.claude/lib/docs/` (the five named by the epic plus the
refinement `DocsPageMarkdown.psm1`; module family derived in the research `## Numeric Derivation
Evidence`, claim N1) and edit three 1020 files under their 1021 anchors. The feature provides:

- A shared Markdown line model: line splitting, the fence rule, HTML-comment and inline code-span
  masking, ATX and setext heading detection, generated-block start-marker detection.
- A bounded front-matter parser for a documented YAML subset (no YAML module, epic A8) and
  validation against `schemas/docs/v1/page-metadata.schema.json` through 1020's
  `Test-DocsArtifactText`.
- Relative-link, same-page anchor and cross-page anchor checks.
- A Diataxis mode audit: profile policy, directory modes and three structure rules.
- Orphan detection by reachability from documentation-root entry pages.
- A `check` subcommand registered in `Invoke-DocsCommand.ps1`, with exit codes 0/1/2/3 and the
  1020 `-Json` envelope, which validates against `schemas/docs/v1/docs-command-envelope.schema.json`
  (D5, amendment of 1020).
- Optional base configuration data (D4): a markdownlint configuration and a minimal Vale
  configuration, base style and empty consumer-owned vocabulary, shipped under
  `.claude/lib/docs/templates/page-check/` and written by `Invoke-DocsCommand.ps1 -Command init`.
  No Node.js or Python linter is required; `check` is the required gate.

No Python or TypeScript file is created or edited. No MCP tool, extension command, hook, skill or
agent is created or edited.

## Inputs / Outputs

- Inputs:
  - The docs profile (JSON), default `docs/documentation-estate/docs-profile.json`
    (`Get-DocsDefaultProfilePath`), overridable with `-Profile <relative path>`. The keys read are
    `documentation_roots[{id, path, audience_ids}]`, `audiences[{id}]` and
    `diataxis_policy.{modes, required_front_matter, directory_modes}`.
  - Markdown pages: every file ending in `.md` (ordinal, case-sensitive) listed under each
    `documentation_roots[n].path` through `Context.ListFile`, read through `Context.ReadBytes`.
  - Non-page link targets checked for existence through `Context.TestFile`, once per distinct
    resolved path.
  - Runtime schemas from `.claude/lib/docs/schemas/v1/` through 1020's `Read-DocsSchemaSet`.
  - Optional `-Path <relative path>` values (repeatable) that restrict reported page findings.
- Outputs:
  - Text report (default) through `ConvertTo-DocsReportText`, with the command-specific line
    `check: pages=<n> roots=<n>` before the 1020 summary line.
  - With `-Json`: exactly one canonical JSON envelope on stdout.
  - `check` writes no file and reads no clock.
  - `init -Write` (1020 command) additionally writes the base configuration files listed in
    `### Base configuration data`.
- No environment variable is read.
- Versioning: the page-metadata schema belongs to the docs schema family `1.0.0`
  (`urn:drm-copilot:docs:1.0.0:page-metadata`). A breaking change to the schema, the front-matter
  subset, the finding codes or the `check` result shape requires an epic-level update.
- Runtime prerequisite: PowerShell 7.4 or later (1020 OQ-3); below it `check` exits 3 with
  `DOCS_RUNTIME_UNSUPPORTED` through the 1020 entry boundary.

## API / CLI Surface

### Module conventions

Every module follows 1020 `### Module conventions`: the help-block token `imports its siblings with
-ErrorAction Stop`; `Set-StrictMode -Version Latest` followed immediately by
`$ErrorActionPreference = 'Stop'`; every column-0 `Import-Module` with `-ErrorAction Stop`; every
`$PSScriptRoot` use in the literal form `Join-Path -Path $PSScriptRoot -ChildPath '<literal>'`;
advanced functions with `[CmdletBinding()]` and PascalCase parameters. "Pure" means no filesystem,
clock, process, environment or module-scope mutable state; pure functions take strings, string
arrays, byte arrays and hashtables. All file access goes through the 1020 command context passed to
`Invoke-DocsCheckCommand`; `check` never reads `Context.UtcNow`. Command modules never write output
and never call `exit`.

Context members are invoked as method calls (for example `$Context.ReadBytes.InvokeReturnAsIs($path)`),
not as `& $Context.ReadBytes`, because `enforcement-hooks-no-python-invocation.Tests.ps1` reports an
`&` whose command position is a member expression. If 1020's `DocsProfileCommands.psm1` uses a
different accepted form, 1021 copies that form (contract request CR-10).

### Import graph and allowed import set

| File | Role | Direct imports (literal joins) |
|---|---|---|
| `DocsPageMarkdown.psm1` | Line splitting, fence model, comment and code-span masking, headings, marker detection | none |
| `DocsPageFrontMatter.psm1` | Front-matter subset parser, scalar resolution, page-metadata validation and finding mapping | `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSchema.psm1`, `DocsPageMarkdown.psm1` |
| `DocsPageLinks.psm1` | Slugs, anchors, link extraction, target resolution, link and anchor findings, page edges | `DocsFinding.psm1`, `DocsPageMarkdown.psm1` |
| `DocsPageDiataxis.psm1` | Path-or-glob match, directory mode, mode signals, Diataxis findings | `DocsFinding.psm1`, `DocsPageMarkdown.psm1` |
| `DocsPageOrphans.psm1` | Entry pages, reachability, orphan findings | `DocsFinding.psm1` |
| `DocsPageCheck.psm1` | Page set, byte decoding, rule orchestration, result, `check` command function | `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSchema.psm1`, `DocsSurface.psm1`, `DocsProfile.psm1` and the five page siblings |

- Allowed direct imports for every `DocsPage*.psm1` module: the 1020 foundation modules
  `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSchema.psm1` (and `DocsSchemaWalk.psm1` if 1020 splits
  it), `DocsSurface.psm1`, `DocsProfile.psm1`, and the `DocsPage*.psm1` modules.
- Denied anywhere in the transitive closure: `DocsLedger*`, `DocsParity*`, `DocsEvidencePins*`,
  `DocsStaleness*`, `DocsReceipt*`, `DocsValidation*`, `DocsInventory*`, `DocsReference*`,
  `DocsSurfaceDelta*`, `DocsExtensionImport*`, `Docs*Tokens*`, every `DocsAnalyzer<Name>.psm1`
  other than `DocsAnalyzerRegistry.psm1`, and any file under `.claude/lib/docs/python/`.
- `DocsAnalyzerRegistry.psm1` is reachable only transitively through `DocsProfile.psm1` (1020 import
  graph). It is the 1020 analyzer contract module, not an analyzer: it loads analyzer modules only
  inside `Invoke-DocsAnalyzer` through its `-ImportModule` seam (no literal join), which `check`
  never calls. The epic criterion "imports nothing from the analyzer modules" is read as the
  analyzer implementations.
- No page module uses `using module`, dot-sourcing or `Invoke-Expression`.
- Import-isolation test: `tests/scripts/claude-lib/docs/DocsPageImportIsolation.Tests.ps1` reads the
  committed module texts (read-only), parses each with
  `[System.Management.Automation.Language.Parser]::ParseInput`, follows every `Import-Module` whose
  argument is a literal `Join-Path -Path $PSScriptRoot -ChildPath` join, computes the transitive
  closure from each page module, and asserts the allowlist, the denylist and the absence of
  `using module`, dot-sourcing and `Invoke-Expression`. A positive control asserts that an in-memory
  module text importing `DocsLedger.psm1` is reported. A static graph is used instead of
  `Get-Module` because loaded-module state leaks between suites in shuffled and single-process runs.

Refinement splits (permitted, each with its own suite, bundle copy and `core.json` entry): slug and
anchor functions move to `DocsPageAnchors.psm1` if `DocsPageLinks.psm1` approaches 500 lines; the
constraint evaluator moves to `DocsPageMetadata.psm1` if `DocsPageFrontMatter.psm1` does. Both stay
inside the allowed import set.

### `DocsPageMarkdown.psm1` (pure)

- `Split-DocsPageLine -Text <string>` returns `[string[]]`; removes a leading U+FEFF and splits on
  `\r\n|\n|\r`.
- `Get-DocsPageFenceLine -Line <string>` returns `$null` or `[ordered]@{ FenceCharacter; FenceLength;
  Info }`.
- `Test-DocsPageFenceClose -Fence <IDictionary> -OpenFence <IDictionary>` returns `[bool]`.
- `Get-DocsPageLineModel -Line <string[]> [-FirstLineNumber <int> = 1]` returns one ordered
  dictionary per line: `Number` (1-based in the original page), `Text`, `Kind` (`blank`, `text`,
  `fence-open`, `fence-body`, `fence-close`, `comment`, `heading`, `setext-underline`), `Masked`
  (HTML-comment spans and inline code-span contents replaced by spaces; empty for `fence-*` and
  `comment` lines), `HeadingLevel`, `HeadingText`, `HasGeneratedStartMarker` (`[bool]`).

Fence rule (re-implemented, not imported from `.claude/lib/mermaid/MermaidMarkdownFences.psm1`,
which carries Mermaid-specific semantics): three or more backticks or tildes, up to three spaces of
indentation, closed by the same character with at least the same length and no info string; an
unclosed fence runs to the end of the page.

### `DocsPageFrontMatter.psm1` (pure)

- `ConvertFrom-DocsPageFrontMatter -Text <string> -PagePath <string>` returns `@{ Present;
  Terminated; Value; FieldLine; BodyStartLine; Findings }`. `Value` is an ordinal hashtable, or
  `$null` when any parse finding exists; `FieldLine` maps each key to its 1-based line.
- `ConvertFrom-DocsPageYamlScalar -Text <string>` returns `@{ Ok; Value; Construct }`.
- `Test-DocsPageFrontMatter -FrontMatter <IDictionary> -PagePath <string> -ComposedSchemaSet
  <IDictionary> -RequiredField <string[]> -AudienceId <string[]> [-FieldLine <IDictionary>]` returns
  ordered findings (see `### Validation order and mapping`).
- `Get-DocsPageConstraintFinding -Schema <IDictionary> -Instance <object> -RootSchema <IDictionary>
  -PagePath <string> [-Pointer <string> = '']` returns findings for `pattern`, `minLength` and
  `uniqueItems`, reading every constraint from the composed schema value (no pattern constant is
  duplicated in PowerShell). It is removed if CR-4 is accepted.
- `Test-DocsPageReviewDate -Value <string>` returns `[bool]` through
  `[datetime]::TryParseExact($Value, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture,
  [System.Globalization.DateTimeStyles]::None, [ref]$parsed)`.

### `DocsPageLinks.psm1` (pure)

- `Get-DocsPageSlug -HeadingText <string>` returns the base slug.
- `Get-DocsPageAnchor -LineModel <object[]>` returns the de-duplicated heading slugs plus explicit
  anchors in document order.
- `Get-DocsPageLink -LineModel <object[]>` returns `@{ Line; Target; Form }` records (`Form` is
  `inline`, `image` or `definition`).
- `Resolve-DocsPageLinkTarget -PagePath <string> -Target <string>` returns `@{ Skip; Path; Fragment;
  EscapesRepository }`.
- `Get-DocsPageExternalTarget -PageLink <IDictionary> -PagePath <string[]>` returns the sorted,
  de-duplicated resolved paths that are neither pages nor page directories.
- `Get-DocsPageLinkFinding -PagePath <string> -Link <object[]> -PageAnchor <IDictionary> -PageSet
  <string[]> -ExistingPath <string[]>` returns `@{ Findings; Edges }`, where `Edges` are the sorted
  page paths this page links to (fragments ignored, directory links resolved).

### `DocsPageDiataxis.psm1` (pure)

- `Test-DocsPagePathMatch -Path <string> -PathOrGlob <string>` returns `[bool]` (shared
  path-or-glob rule; hosted here until CR-8 moves it to 1020).
- `Get-DocsPageDirectoryMode -PagePath <string> -DirectoryMode <object[]>` returns `@{ Mode;
  PathOrGlob; Index }` of the first covering entry, or `$null`.
- `Get-DocsPageModeSignal -LineModel <object[]>` returns `@{ OrderedStepLine;
  InstructionHeadingLine; InstructionHeadingText; GeneratedBlockLine }` (0 when absent).
- `Get-DocsPageDiataxisFinding -PagePath <string> -DeclaredMode <string> -LineModel <object[]>
  -DiataxisPolicy <IDictionary>` returns findings.

### `DocsPageOrphans.psm1` (pure)

- `Get-DocsPageEntryPage -RootPath <string> -PageSet <string[]>` returns `<root>/README.md`, else
  `<root>/index.md`, else `$null`.
- `Get-DocsPageReachable -EntryPage <string[]> -Edge <IDictionary>` returns the sorted reachable set
  (breadth-first, neighbors in ordinal order; cycles terminate).
- `Get-DocsPageOrphanFinding -PageSet <string[]> -Reachable <string[]>` returns one finding per
  unreachable page.

### `DocsPageCheck.psm1`

- `Get-DocsPageCandidatePath -RootListing <IDictionary>` (pure) keeps listed paths ending in `.md`
  (ordinal, case-sensitive), de-duplicates across nested roots and sorts ordinally.
- `ConvertFrom-DocsPageBytes -Bytes <byte[]> -PagePath <string> [-MaxBytes <int> = 1048576]` (pure)
  returns `@{ Text; Findings }`; strict UTF-8 through `[System.Text.UTF8Encoding]::new($false,
  $true)`; a leading BOM is removed.
- `Get-DocsPageCheckFinding -PageText <IDictionary> -Profile <IDictionary> -ProfilePath <string>
  -ComposedSchemaSet <IDictionary> -ExistingPath <string[]> [-SelectedPath <string[]>]` (pure) runs
  every rule over an in-memory page map and returns `@{ Findings; Result }`. Rule tests and the 1024
  integration test call this function directly.
- `Invoke-DocsCheckCommand -Argument <IDictionary> -Context <object>` returns the object from
  `New-DocsCommandResult` (1020 command function contract `^Invoke-Docs[A-Za-z]+Command$`).

### `check` subcommand

Dispatch row, one line, inserted directly under `# --- 1021: check ---` in `Invoke-DocsCommand.ps1`
(no other anchor or row is edited):

```powershell
[pscustomobject]@{ Name = 'check'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageCheck.psm1'); Function = 'Invoke-DocsCheckCommand'; Option = @{ Profile = 'value'; Path = 'multi' } }
```

Usage:

```text
pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command check [-Profile <relative path>] [-Path <relative path>]... [-Json] [-RepositoryRoot <path>]
```

Options:

- `-Profile <relative path>`: default `Get-DocsDefaultProfilePath`.
- `-Path <relative path>` (repeatable): restricts reported page findings to pages equal to, or
  under, a given path. Links, anchors and reachability are still computed over the full page set.
  Findings whose artifact path is the profile are always reported.
- Both values are checked with `Test-DocsRelativePath` before any context call.

Flow:

1. Validate arguments; a failure is exit 2 with exactly one `DOCS_CLI_ARGUMENTS` and `result`
   `null`.
2. Read the profile through `Context.ReadText`; an absent profile is `DOCS_PROFILE_MISSING`, exit 1,
   `result` `null`. Read and compose the schema set (`Read-DocsSchemaSet`,
   `Get-DocsComposedSchemaSet`); an unreadable or uncomposable set is exit 3.
3. `ConvertFrom-DocsProfileText`; any `error` finding returns those findings with exit 1, `result`
   `null`, and no page check runs.
4. For each `documentation_roots[n]` in profile order, `Context.ListFile`; select pages with
   `Get-DocsPageCandidatePath`; read each page with `Context.ReadBytes`; decode with
   `ConvertFrom-DocsPageBytes`.
5. Extract links for every decoded page; call `Context.TestFile` once per path returned by
   `Get-DocsPageExternalTarget`; pass the paths that exist as `-ExistingPath`.
6. `Get-DocsPageCheckFinding`; apply `-Path` selection; a `-Path` value matching no page yields
   `DOCS_PAGE_PATH_UNMATCHED`.
7. `New-DocsCommandResult -Command 'check' -ExitCode <1 when any error finding, else 0> -Finding ...
   -Result ... -Line @('check: pages=<n> roots=<n>')`.

A read failure other than absence, or any unexpected exception, is exit 3 with `DOCS_CLI_RUNTIME`
at the 1020 entry boundary.

Exit codes:

| Code | `check` meaning |
|---|---|
| 0 | Valid profile, no `error` finding over the selected pages |
| 1 | At least one `error` finding (page, root or profile), or `DOCS_PROFILE_MISSING` |
| 2 | Usage error (`DOCS_CLI_ARGUMENTS`): unknown option, missing value, repeated `-Profile`, non-relative `-Profile` or `-Path` |
| 3 | `DOCS_RUNTIME_UNSUPPORTED`, unreadable or uncomposable schemas, read failure other than absence, unexpected exception (`DOCS_CLI_RUNTIME`) |

Result shape (exit 0 or 1 after a valid profile; otherwise `null`):

```json
{"page_count": 0, "profile_path": "docs/documentation-estate/docs-profile.json", "roots": [{"id": "<root id>", "page_count": 0, "path": "<root path>"}]}
```

`roots` is in profile order; `page_count` counts distinct pages across nested roots.

`-Json` envelope: the 1020 envelope `{command, exit_code, findings, ok, result}` as canonical JSON
(sorted keys, compact, trailing LF), with `command` `check`. Findings are in `Get-DocsOrderedFinding`
order (artifact path, pointer, code, related identifiers, related paths, severity, message, next
action; ordinal comparison), de-duplicated, and bounded at 100 with one `FINDINGS_LIMIT` finding
when truncated (CR-11 requests a configurable bound). Identical page bytes, profile and arguments
give identical bytes regardless of listing order; `check` reads no clock. The stdout document
validates against `schemas/docs/v1/docs-command-envelope.schema.json` (D5) through the validation
route the 1020 amendment provides (CR-9).

Ordering note: body findings carry pointer `''` and a message beginning `line <n>:`, so within one
page and code they sort by ordinal message text (`line 10` sorts before `line 9`). The order is
deterministic; it is not numeric line order.

### Page-metadata schema

Canonical `schemas/docs/v1/page-metadata.schema.json`; byte-identical runtime copy
`.claude/lib/docs/schemas/v1/page-metadata.schema.json`; byte-identical bundle copy under
`extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/`.

- `$schema`: the Draft 2020-12 dialect URI used by every docs schema (1020 `### Schema identity and
  reference conventions`).
- `$id`: `urn:drm-copilot:docs:1.0.0:page-metadata`. `title` (`Documentation page metadata`) and
  `description` are informative.
- Root: `type: object`, `additionalProperties: false`, no `required` list. The schema is page
  metadata, not an artifact: it declares no artifact header (`$schema`, `schema_version`,
  `artifact_kind` and `id` are not instance properties).
- Properties, each through `urn:drm-copilot:docs:1.0.0:common#/$defs/<name>`:

| Field | Required by schema | Shape |
|---|---|---|
| `owner` | no (profile decides) | `identifier` (same grammar as profile `page_owners[].owner`) |
| `last_reviewed` | no (profile decides) | `review-date` (pattern `^[0-9]{4}-[0-9]{2}-[0-9]{2}$`); calendar validity checked in PowerShell; no comparison with the clock |
| `audience` | no (profile decides) | `type: array`, `minItems: 1`, `uniqueItems: true`, `items` `audience-id` (pattern `^[a-z0-9][a-z0-9-]*$`) |
| `diataxis_mode` | no (profile decides) | `diataxis-mode` (`tutorial`, `how-to`, `reference`, `explanation`) |
| `surface_refs` | no (profile decides) | `element-ids` (array, `uniqueItems`, items `element-id`; may be empty) |
| `title` | no (optional field) | `text` |
| `extensions` | no (optional field) | `extensions` (the only place for consumer-defined keys) |

- Audience identifier pattern: `^[a-z0-9][a-z0-9-]*$`, the same pattern that profile
  `audiences[].id` and `documentation_roots[].audience_ids` must carry (epic `### Generator
  decisions from the first preparation of 1024`). The docs common definitions `audience-id` and
  `audience-ids` are requested from the 1020 amendment (CR-1). If the amendment does not add them,
  the page-metadata schema defines `audience-id` locally under `$defs` with the same pattern, and
  the profile change remains a 1020 obligation.
- No `$ref` to a discovery URN or to a file (asserted for every docs schema by 1020's
  `DocsSchemaContract.Tests.ps1`).
- Required fields are profile data: `diataxis_policy.required_front_matter` lists which of the five
  fields a page must carry. A schema `required` list would make that profile field inert. CR-7 asks
  the 1020 starter profile to list all five.

Validation route (research option A): `page-metadata` is appended to `Get-DocsSchemaName` under
`# --- 1021: page-metadata ---` and gets a `Get-DocsSchemaPath` row under the same anchor (CR-2).
The parsed front matter is serialized with `ConvertTo-DocsJsonText` (not canonical JSON, which
throws on fractional numbers) and validated with `Test-DocsArtifactText -ArtifactKind
'page-metadata'` (CR-3). Because every field sits behind an inline `$ref`, `Test-Json` cannot name
a `pattern`, `minLength` or `uniqueItems` failure; `Get-DocsPageConstraintFinding` names them.

### Front-matter subset

Block detection: a page has a block when line 1 (after BOM removal) is exactly `---`; the block
ends at the next line that is exactly `---` or `...`. Without a terminator, one
`DOCS_PAGE_FRONT_MATTER_UNTERMINATED` finding is produced, `Value` is `$null`, and the body scanners
treat the whole page as body. `BodyStartLine` is the line after the terminator (1 without a block).

Line grammar inside the block:

| Line form | Treatment |
|---|---|
| blank or whitespace-only | ignored |
| optional spaces then `#` | comment, ignored |
| `^(?<key>[A-Za-z_][A-Za-z0-9_-]*):(?:[ ]+(?<value>.*))?$` at column 0 | top-level entry |
| `^(?<indent>[ ]*)- (?<item>.*)$` after an entry with an empty value or a previous item | block sequence item (scalar only) |
| a tab in indentation | `DOCS_PAGE_FRONT_MATTER_UNSUPPORTED` (`tab indentation`) |
| a quoted key, `? `, an indented line that is not a sequence item, `- key: value`, `- - x` | `DOCS_PAGE_FRONT_MATTER_UNSUPPORTED` (construct named) |
| anything else | `DOCS_PAGE_FRONT_MATTER_SYNTAX` |

A repeated top-level key yields `DOCS_PAGE_FRONT_MATTER_DUPLICATE_KEY`. Parsing continues so every
malformed line is reported; any parse finding sets `Value` to `$null` and suppresses field and
Diataxis rules for the page.

Value forms (trailing spaces removed):

| Value text | Result |
|---|---|
| empty, followed by sequence items | array of the item scalars |
| empty, not followed by items | `$null` |
| starts with `"`, `[` or `{` and parses with `ConvertFrom-DocsJsonText` | the JSON value |
| starts with `[`, not JSON | single-line flow sequence of plain, single-quoted or JSON double-quoted scalars; `[]` is empty; nesting or an unclosed `]` is `UNSUPPORTED` |
| starts with `{`, not JSON | `UNSUPPORTED` (`flow mapping`) |
| starts with `"`, not a JSON string | `UNSUPPORTED` (`YAML escape`) |
| starts with `'` | single-quoted scalar on one line; `''` is one quote; only an empty remainder or ` #` comment may follow |
| starts with `\|` or `>` | `UNSUPPORTED` (`block scalar`) |
| starts with `&`, `*` or `!` | `UNSUPPORTED` (`anchor`, `alias`, `tag`) |
| starts with `%`, `@`, a backtick, `,`, `]`, `}`, `?` or `- ` | `UNSUPPORTED` (`reserved indicator`) |
| any other text | plain scalar: ` #` starts a comment; a remaining `: ` is `UNSUPPORTED` (`mapping in plain scalar`); YAML 1.2 core-schema resolution of null, boolean, `Int64` (overflow `UNSUPPORTED`) and `Double` forms (`.inf`/`.nan` `UNSUPPORTED`); otherwise the string |

An unquoted `last_reviewed: 2026-10-30` is the string `2026-10-30`. Multi-line values are outside
the subset. `ConvertFrom-Json` is not used.

### Validation order and mapping

1. Each name in `-RequiredField` absent from the mapping yields `DOCS_PAGE_FIELD_MISSING`.
2. Schema gate: `Test-DocsArtifactText -ArtifactKind 'page-metadata'`.
3. Constraint evaluator over the composed page-metadata schema value.
4. `last_reviewed` calendar check when the value matches the pattern (`DOCS_PAGE_LAST_REVIEWED_NOT_A_DATE`).
5. Each valid `audience` item that is not a profile `audiences[].id` yields `DOCS_PAGE_AUDIENCE_UNDECLARED`.
6. Walk and evaluator findings are mapped by the first pointer segment: an unknown property becomes
   `DOCS_PAGE_FIELD_UNKNOWN`; other findings become the per-field code. Pointer, artifact path and
   the field-naming message are kept; the field line is prefixed to the message.
7. Fail closed: a `DOCS_SCHEMA_INVALID` finding with nothing explained is dropped when steps 1 to 5
   produced a field finding, and is otherwise re-emitted as `DOCS_PAGE_FRONT_MATTER_SCHEMA_INVALID`
   at pointer `''`.

### Masking, links, anchors and slugs

Masking (applies to links, anchors, headings and Diataxis signals): scanning starts at
`BodyStartLine`; fenced code (open, body and close lines) is not scanned; HTML comments from `<!--`
to the next `-->` are masked across lines, and an unclosed comment runs to the end of the page;
inline code-span contents are masked for link extraction and kept as text for heading slugs.
Generated-block markers `<!-- docs:generated:start id=<element-id> -->` and
`<!-- docs:generated:end id=<element-id> -->`, every other HTML comment, and fenced code therefore
produce no link, anchor, heading or Diataxis-step finding. The start marker is counted only for
`DOCS_PAGE_MODE_GENERATED_BLOCK`. 1021 does not validate marker balance or identifiers; 1024 owns
those findings.

Link extraction: inline links and images `[text](destination "title")` and `![alt](destination)`
(one level of nested brackets; `<...>` destinations); reference definitions
`^ {0,3}\[label\]:\s*(<[^>]*>|\S+)`. Skipped targets: a URI scheme `^[A-Za-z][A-Za-z0-9+.-]*:`, a
`//` prefix, an empty target.

Resolution: split at the first `#`, drop a `?query`, percent-decode with `[uri]::UnescapeDataString`.
A fragment-only target refers to the same page. A leading `/` resolves from the repository root;
any other path resolves against the page's directory with POSIX segment normalization; a result
above the root yields `DOCS_PAGE_LINK_ESCAPES_REPOSITORY`; backslash is not a separator. A path is
satisfied when it is a page; when `<path>/README.md` or `<path>/index.md` is a page (the edge goes
to that page); when a page path starts with `<path>/`; or when `Context.TestFile` reported it.
Otherwise `DOCS_PAGE_LINK_BROKEN`. Fragments are checked only on targets in the page set.

Anchors: slugs of ATX headings (closing `#` run removed) and setext headings, plus `<a id="...">`
and `<a name="...">` values outside masked regions. Matching against the decoded fragment is exact
and ordinal.

Slug rule (language-independent rule kept from the earlier research): (1) `[t](u)` becomes `t`,
`![a](u)` becomes `a`, HTML tags are removed; (2) `ToLowerInvariant()`; (3) keep only code points
whose Unicode category is a letter (`Lu`, `Ll`, `Lt`, `Lm`, `Lo`), a mark (`Mn`, `Mc`, `Me`), `Nd`,
`Nl` or `Pc`, plus `-` and space, iterating by code point; (4) each space becomes `-` without
collapsing; (5) per page, later duplicates become `<base>-1`, `<base>-2`, skipping taken values.

Documented precision limits (lexical, not CommonMark): indented code blocks are not recognized;
code spans do not span lines; raw HTML links are not checked; fragments on targets outside the page
set are not checked; .NET Unicode tables may differ from the hosting platform's heading-anchor
algorithm for rare characters, including symbol code points with the Alphabetic property.

### Diataxis rules

Path-or-glob match (epic `### Generator decisions from the first preparation of 1024`): exact
(`-ceq`), or ordinal prefix plus `/`, or a case-sensitive
`[System.Management.Automation.WildcardPattern]` match with `WildcardOptions.None` when the pattern
contains `*`, `?` or `[`; `*` crosses `/`; first match in profile order wins. PowerShell wildcards
have no `[!x]` negation and use a backtick escape (documented).

Signals: an ordered step is a `text` line whose masked text matches `^ {0,3}[0-9]{1,9}[.)] +\S`; an
instructional heading is heading text that, case-insensitively, starts with `how to ` or matches
`^step\s+[0-9]+\b` (English module constants, documented); a generated block is a line with
`HasGeneratedStartMarker`.

Rules, evaluated only when `diataxis_mode` is valid:

| Code | Fails when |
|---|---|
| `DOCS_PAGE_MODE_NOT_IN_POLICY` | the declared mode is not in `diataxis_policy.modes` |
| `DOCS_PAGE_MODE_DIRECTORY_MISMATCH` | the first covering `diataxis_policy.directory_modes` entry has a different mode (no covering entry is not a finding) |
| `DOCS_PAGE_MODE_STEPS_MISSING` | mode `tutorial` or `how-to` and no ordered step |
| `DOCS_PAGE_MODE_INSTRUCTION_HEADING` | mode `reference` or `explanation` and an instructional heading |
| `DOCS_PAGE_MODE_GENERATED_BLOCK` | mode `tutorial`, `how-to` or `explanation` and a generated-block start marker |

Prose judgment stays with the reviewer role (epic `## Non-Goals`).

### Page enumeration and orphans

- A root whose listing holds no page yields `DOCS_PAGE_ROOT_EMPTY`; an absent directory is treated
  as empty until CR-5 states `ListFile` behavior.
- An oversize page (above 1 MiB) yields `DOCS_PAGE_TOO_LARGE`; an undecodable page yields
  `DOCS_PAGE_ENCODING_INVALID`. Both stay in the page set as link targets and graph nodes with no
  outgoing edge, and are not scanned.
- Entry pages: per root, `<path>/README.md`, else `<path>/index.md`; a root with neither yields
  `DOCS_PAGE_ROOT_ENTRY_MISSING`.
- Reachability: breadth-first from every entry page over page edges; every page not reached yields
  `DOCS_PAGE_ORPHAN`. Entry pages are never orphans; links from files outside the page set do not
  count.

### Finding-code catalog

All codes match `^[A-Z][A-Z0-9_]*$`, have severity `error`, carry a fixed `next_action` per code and
are built with `New-DocsFinding`. "Page" means `artifact_path` is the page's repository-relative
path, so every page finding names the file. "Profile" means the profile path. Body findings prefix
the message with `line <n>: `.

| Code | Artifact path | Pointer | `related_paths` | Trigger | Message form |
|---|---|---|---|---|---|
| `DOCS_PAGE_FRONT_MATTER_MISSING` | Page | `''` | none | no block and `required_front_matter` non-empty | `front matter block is missing; required fields: <list>` |
| `DOCS_PAGE_FRONT_MATTER_UNTERMINATED` | Page | `''` | none | line 1 `---` with no closing `---` or `...` | `front matter block opened on line 1 is not closed` |
| `DOCS_PAGE_FRONT_MATTER_SYNTAX` | Page | `''` | none | block line outside the line grammar, or invalid JSON in a JSON-shaped value | `front matter line is not a key, sequence item, comment or blank line` |
| `DOCS_PAGE_FRONT_MATTER_UNSUPPORTED` | Page | `''` | none | YAML construct outside the subset | `front matter construct '<construct>' is outside the supported subset` |
| `DOCS_PAGE_FRONT_MATTER_DUPLICATE_KEY` | Page | `/<key>` | none | repeated top-level key | `front matter key '<key>' repeats the key on line <m>` |
| `DOCS_PAGE_FIELD_MISSING` | Page | `/<field>` | none | field in `required_front_matter` absent | `required front matter field '<field>' is missing` |
| `DOCS_PAGE_FIELD_UNKNOWN` | Page | `/<key>` | none | key not in the schema properties | `front matter field '<key>' is not defined by page-metadata` |
| `DOCS_PAGE_OWNER_INVALID` | Page | `/owner` | none | type or identifier pattern | `front matter field 'owner' ...` |
| `DOCS_PAGE_LAST_REVIEWED_INVALID` | Page | `/last_reviewed` | none | type or `YYYY-MM-DD` pattern | `front matter field 'last_reviewed' ...` |
| `DOCS_PAGE_LAST_REVIEWED_NOT_A_DATE` | Page | `/last_reviewed` | none | pattern matches, calendar date invalid | `front matter field 'last_reviewed' value '<v>' is not a calendar date` |
| `DOCS_PAGE_AUDIENCE_INVALID` | Page | `/audience` or `/audience/<i>` | none | type, count, item pattern, duplicate item | `front matter field 'audience' ...` |
| `DOCS_PAGE_AUDIENCE_UNDECLARED` | Page | `/audience/<i>` | none | valid id not declared in profile `audiences` | `audience '<id>' is not declared in the docs profile` |
| `DOCS_PAGE_MODE_INVALID` | Page | `/diataxis_mode` | none | type or value outside the four modes | `front matter field 'diataxis_mode' ...` |
| `DOCS_PAGE_SURFACE_REFS_INVALID` | Page | `/surface_refs` or `/surface_refs/<i>` | none | type, element-id pattern, duplicate | `front matter field 'surface_refs' ...` |
| `DOCS_PAGE_TITLE_INVALID` | Page | `/title` | none | type or `text` constraint | `front matter field 'title' ...` |
| `DOCS_PAGE_EXTENSIONS_INVALID` | Page | `/extensions...` | none | `extensions` constraint | `front matter field 'extensions' ...` |
| `DOCS_PAGE_FRONT_MATTER_SCHEMA_INVALID` | Page | `''` | none | `Test-Json` `False` with no field finding (fail closed) | `front matter does not validate against page-metadata` |
| `DOCS_PAGE_LINK_BROKEN` | Page | `''` | resolved path | relative target satisfies no resolution rule | `link target '<target>' does not resolve to a page or an existing path` |
| `DOCS_PAGE_LINK_ESCAPES_REPOSITORY` | Page | `''` | none | resolves above the repository root | `link target '<target>' resolves above the repository root` |
| `DOCS_PAGE_ANCHOR_MISSING` | Page | `''` | none | same-page fragment matches no anchor | `anchor '#<fragment>' is not a heading or explicit anchor of this page` |
| `DOCS_PAGE_LINK_ANCHOR_MISSING` | Page | `''` | target page | cross-page fragment matches no anchor of the target page | `anchor '#<fragment>' is not a heading or explicit anchor of '<target>'` |
| `DOCS_PAGE_MODE_NOT_IN_POLICY` | Page | `/diataxis_mode` | none | Diataxis rule | `diataxis_mode '<m>' is not listed in diataxis_policy.modes` |
| `DOCS_PAGE_MODE_DIRECTORY_MISMATCH` | Page | `/diataxis_mode` | none | Diataxis rule | `diataxis_mode '<m>' differs from '<n>' required for '<path_or_glob>'` |
| `DOCS_PAGE_MODE_STEPS_MISSING` | Page | `/diataxis_mode` | none | Diataxis rule | `diataxis_mode '<m>' requires an ordered step list` |
| `DOCS_PAGE_MODE_INSTRUCTION_HEADING` | Page | `''` | none | Diataxis rule | `heading '<text>' is instructional, which diataxis_mode '<m>' does not allow` |
| `DOCS_PAGE_MODE_GENERATED_BLOCK` | Page | `''` | none | Diataxis rule | `generated reference block in a page whose diataxis_mode is '<m>'` |
| `DOCS_PAGE_ORPHAN` | Page | `''` | none | not reachable from any entry page | `page is not reachable from any documentation-root entry page` |
| `DOCS_PAGE_TOO_LARGE` | Page | `''` | none | page above 1 MiB | `page exceeds the 1 MiB scan bound` |
| `DOCS_PAGE_ENCODING_INVALID` | Page | `''` | none | not strict UTF-8 | `page is not valid UTF-8` |
| `DOCS_PAGE_ROOT_EMPTY` | Profile | `/documentation_roots/<n>/path` | none | root lists no page | `documentation root '<id>' at '<path>' contains no Markdown page` |
| `DOCS_PAGE_ROOT_ENTRY_MISSING` | Profile | `/documentation_roots/<n>/path` | none | root has no `README.md` or `index.md` page | `documentation root '<id>' has no README.md or index.md entry page` |
| `DOCS_PAGE_PATH_UNMATCHED` | `null` | `''` | the `-Path` value | a `-Path` value matches no page | `-Path '<p>' matches no page in the documentation roots` |

Reused 1020 codes: `DOCS_PROFILE_MISSING` (exit 1); every finding of `ConvertFrom-DocsProfileText`
(exit 1); `DOCS_CLI_ARGUMENTS` (exit 2); `DOCS_RUNTIME_UNSUPPORTED` and `DOCS_CLI_RUNTIME` (exit 3);
`FINDINGS_LIMIT`.

Interaction rules: a front-matter parse finding suppresses field findings and Diataxis rules for
that page; Diataxis rules need a valid `diataxis_mode`; link, anchor and orphan rules do not depend
on front matter; `DOCS_PAGE_TOO_LARGE` and `DOCS_PAGE_ENCODING_INVALID` suppress every other rule
for that page except `DOCS_PAGE_ORPHAN`.

The `DOCS_PAGE_` prefix is reserved to 1021.

### Constructs 1024 must emit to pass with zero findings

| 1024 construct | 1021 handling |
|---|---|
| Front matter `---`, lines `<key>: <JSON value>`, `---` | JSON branch of the value forms; `\uXXXX` escapes are valid JSON |
| `owner` from profile `page_owners` | must match docs common `identifier` |
| `audience` from the root `audience_ids` | items match `^[a-z0-9][a-z0-9-]*$` and are declared in profile `audiences` |
| `last_reviewed` | first ten characters of the snapshot `captured_at` (valid pattern and calendar date) |
| `diataxis_mode: "reference"` in the output directory covered by the `reference` directory-mode entry | Diataxis rules pass |
| `surface_refs` | element identifiers (`element-ids`) |
| Headings such as `# <title>` and `## Command \`<declaration>\`` | anchors with de-duplication; no heading begins `how to ` or matches `^step\s+[0-9]+\b` |
| Lists, no tables, no links, no HTML other than markers | nothing to resolve; no ordered step needed for `reference` |
| Standalone marker lines with blank lines around blocks | masked HTML comments |
| Generated pages linked from a root entry page | not orphans; the 1024 integration fixture includes the entry page that links each generated page |

### Base configuration data (D4: optional, data only)

Template sources under `.claude/lib/docs/templates/page-check/` (no leading dot in source names;
the destination carries the dot), and their destinations written by `init`:

| Source under `.claude/lib/docs/` | Destination in the consumer |
|---|---|
| `templates/page-check/markdownlint.json` | `.markdownlint.json` |
| `templates/page-check/vale.ini` | `.vale.ini` |
| `templates/page-check/vale/DocsBase/HeadingPunctuation.yml` | `.vale/styles/DocsBase/HeadingPunctuation.yml` |
| `templates/page-check/vale/DocsBase/Placeholders.yml` | `.vale/styles/DocsBase/Placeholders.yml` |
| `templates/page-check/vale/Project/accept.txt` (zero bytes, consumer-owned) | `.vale/styles/config/vocabularies/Project/accept.txt` |

- markdownlint content: `{"default": true, "MD013": false, "MD025": {"front_matter_title": ""},
  "MD033": {"allowed_elements": ["a"]}}`. `MD025` with an empty `front_matter_title` keeps a page
  with a front-matter `title` and an H1 from being reported twice; `a` is allowed because 1021
  recognizes `<a id>` anchors. markdownlint is chosen per owner Q3 default; the editor extension
  reads `.markdownlint.json` without a project Node.js install. No linter is a dependency.
- Vale: `StylesPath = .vale/styles`, `MinAlertLevel = warning`, `Vocab = Project`, a `[*.md]`
  section with `BasedOnStyles = Vale, DocsBase`, no `Packages` key. `DocsBase/HeadingPunctuation.yml`
  (`extends: existence`, `scope: heading`) and `DocsBase/Placeholders.yml` (`extends: existence`,
  tokens `TODO`, `TBD`, `FIXME`). No `substitution` or `spelling` rule. The vocabulary file is
  consumer-owned and ships empty.
- No template contains consumer vocabulary, a consumer identifier or the framework repository name.
- Delivery: rows of `Get-DocsInitTemplate` in `DocsProfileCommands.psm1`, inserted under
  `# --- 1021: page-check configuration ---`, one row per file
  (`[pscustomobject]@{ Source = (Join-Path -Path $PSScriptRoot -ChildPath 'templates/page-check/<file>'); Destination = '<destination>' }`).
  This is the provisional default of owner question OQ-A, because one row carries one file. 1020
  `init` semantics apply: dry run by default; `-Write` is all-or-nothing and reports
  `DOCS_INIT_TARGET_EXISTS` for any existing destination unless `-Force` (OQ-B).

## Data & State

- `check` is read-only, keeps no state between runs and reads no clock.
- All rule logic is pure and runs on in-memory page maps; only `Invoke-DocsCheckCommand` calls the
  command context (`ReadText`, `ReadBytes`, `ListFile`, `TestFile`).
- Ordering is deterministic: pages ordinal, roots in profile order, findings by
  `Get-DocsOrderedFinding`, reachability neighbors ordinal.
- No module-scope cache; schemas are read and composed once per invocation.
- Migration or backfill: none.

## Constraints & Risks

- Language rule: every artifact is PowerShell, JSON, INI, YAML, text or Markdown; no Python or
  TypeScript is created or edited. No artifact needs an exception (see `## Artifact
  Classification`).
- PowerShell 7 built-ins only (epic A8): no YAML module; `ConvertFrom-Json` is not used.
- Dependency on the concurrent 1020 amendment: the envelope schema, `audience-id`, the
  `Get-DocsSchemaPath` anchor and the composed-set semantics are requested in `## Contract Requests
  to 1020`. Execution starts only after 1020, with its amendment, is merged into the integration
  branch.
- Batch budget: eighteen production PowerShell files are created or edited (nine under
  `.claude/lib/docs/` plus nine bundle copies; research `## Numeric Derivation Evidence`, claim N2),
  above the direct-mode cap. Execution runs in the item worktree under an exempt-route checkpoint,
  never in an isolated executor worktree.
- File size: `DocsPageLinks.psm1` and `DocsPageFrontMatter.psm1` are the largest candidates; the
  refinement splits apply before 500 lines.
- CI-only behavior: `Test-Json` behavior on `windows-latest` may differ from a local run; tests
  assert codes and pointers, never `Test-Json` wording. `.gitattributes` `eol=lf` normalizes
  committed CRLF fixtures, so CRLF and BOM inputs are built in memory. Docs suites run in the
  Windows Pester shards.
- Test isolation: every suite removes the `Docs*` and `DiscoveryEncoding` modules it imported in
  `AfterAll`.
- Mirror parity: bundle copies of edited 1020 files are refreshed after the last source edit.
- Shared append-only edit points: `Invoke-DocsCommand.ps1`, `DocsSchema.psm1`,
  `DocsProfileCommands.psm1` and `core.json`; conflicts are resolved in this child's remediation
  loop.

## Implementation Strategy

- Create the six `DocsPage*.psm1` modules and their byte-identical bundle copies.
- Edit `Invoke-DocsCommand.ps1` (dispatch row under `# --- 1021: check ---`), `DocsSchema.psm1`
  (name and path rows under `# --- 1021: page-metadata ---`) and `DocsProfileCommands.psm1`
  (template rows under `# --- 1021: page-check configuration ---`); refresh their bundle copies.
- Create `schemas/docs/v1/page-metadata.schema.json`, its runtime copy and bundle copy.
- Create the template data files and their bundle copies.
- Append every new `.claude/lib/docs/` file to `paths` in
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- No change to `config/poshqc-coverage.json` (`.claude/lib` is already a root) or to
  `quality-tiers.yml` (1020 classifies `.claude/lib/docs` as T3).
- New Pester suites under `tests/scripts/claude-lib/docs/`: `DocsPageMarkdown.Tests.ps1`,
  `DocsPageFrontMatter.Tests.ps1`, `DocsPageMetadataSchema.Tests.ps1`, `DocsPageLinks.Tests.ps1`,
  `DocsPageDiataxis.Tests.ps1`, `DocsPageOrphans.Tests.ps1`, `DocsPageCheck.Tests.ps1`,
  `DocsPageImportIsolation.Tests.ps1`, `DocsPageTemplates.Tests.ps1`. Command tests use the
  in-memory context of 1020's `Docs.TestSupport.psm1`.
- Seeded property-style tests (`[System.Random]`, seed printed on failure) for the pure functions:
  slug determinism and per-page uniqueness; finding order invariant under input permutation; orphan
  result invariant under listing order; Diataxis verdict invariant under insertion of plain
  paragraph lines; ordered-list lines inside fences never count; front-matter parse result
  invariant under insertion of comment and blank lines.
- Dispositions for 1020 tests (confirmed by searching the merged 1020 suites): exact schema-name
  list assertions in `DocsSchema.Tests.ps1` become membership plus order of the 1020 names; a
  zero-row template assertion in `DocsProfileCommands.Tests.ps1` becomes "1020 anchor sections hold
  no rows"; `Invoke-DocsCommand.Tests.ps1` asserts membership; `DocsSchemaContract.Tests.ps1`,
  `Docs.Manifest.Tests.ps1` and `DocsNeutrality.Tests.ps1` gain the new files in scope without code
  changes.
- No test creates a temporary file; suites that read committed files only read.
- Evidence under `docs/features/active/2026-10-30-docs-page-quality-checker-1021/evidence/<kind>/`:
  coverage per module from the PoshQC coverage report of a branch-current `Invoke-PoshQCTest` run,
  pass counts from its JUnit report, and isolation runs (no PoshQC MCP result is cited).
- Dependency changes: none. Logging: none. Rollout: additive through the existing Claude push-down;
  consumers run `check` and optionally `init` for the base configuration.

## Artifact Classification

Rule references: R1 = language rule clause (1) (pushed-down skills, helpers, hooks and libs are
PowerShell or bash); R2 = clause (2) (TypeScript only for MCP and extension commands; none here);
D = epic `### Artifact classes for this epic` (schema, configuration, data, test and documentation
rows); D4 = owner decision D4 (linting optional, configuration data only). "Avoid new Python"
applies to every row.

| File (create unless noted) | Class | Language | Permitting rule |
|---|---|---|---|
| `.claude/lib/docs/DocsPageMarkdown.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsPageFrontMatter.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsPageLinks.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsPageDiataxis.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsPageOrphans.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsPageCheck.psm1` | pushed-down helper/lib (command module) | PowerShell | R1 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` (edit: row under `# --- 1021: check ---`) | pushed-down helper/lib (entry) | PowerShell | R1 |
| `.claude/lib/docs/DocsSchema.psm1` (edit: rows under `# --- 1021: page-metadata ---`) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsProfileCommands.psm1` (edit: rows under `# --- 1021: page-check configuration ---`) | pushed-down helper/lib | PowerShell | R1 |
| `schemas/docs/v1/page-metadata.schema.json` | schema/config/data | JSON | D |
| `.claude/lib/docs/schemas/v1/page-metadata.schema.json` | schema/config/data (pushed down) | JSON | D |
| `.claude/lib/docs/templates/page-check/markdownlint.json` | schema/config/data (pushed down) | JSON | D, D4 |
| `.claude/lib/docs/templates/page-check/vale.ini` | schema/config/data (pushed down) | INI | D, D4 |
| `.claude/lib/docs/templates/page-check/vale/DocsBase/HeadingPunctuation.yml` | schema/config/data (pushed down) | YAML | D, D4 |
| `.claude/lib/docs/templates/page-check/vale/DocsBase/Placeholders.yml` | schema/config/data (pushed down) | YAML | D, D4 |
| `.claude/lib/docs/templates/page-check/vale/Project/accept.txt` (zero bytes) | schema/config/data (pushed down) | text | D, D4 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/**` (bundle copies of every file above under `.claude/lib/docs/`) | pushed-down helper/lib and data (mirror) | PowerShell, JSON, INI, YAML, text | R1, D |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit) | schema/config/data | JSON | D |
| `tests/scripts/claude-lib/docs/DocsPage*.Tests.ps1` | test | PowerShell (Pester) | D |
| 1020 suites under `tests/scripts/claude-lib/docs/` edited for the dispositions above | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-page-quality-checker-1021/**` (spec, user story, issue note, plan, evidence) | documentation | Markdown | D |

No MCP tool, extension command, hook, skill, agent, Python file or TypeScript file is created or
edited. Every artifact follows the language rule; no owner question concerns language.

## Contract Requests to 1020

These are requests to the concurrent 1020 amendment, not decisions of this feature. Where a request
is not accepted, the fallback stated here applies.

- **CR-1 (required by the epic).** Add docs common `audience-id` (string, pattern
  `^[a-z0-9][a-z0-9-]*$`, optionally with the trailing guard `(?![\s\S])` that the discovery common
  uses so `$` cannot match before a final line feed) and `audience-ids` (array, `uniqueItems`,
  items `audience-id`); type profile `audiences[].id` as `audience-id` and
  `documentation_roots[].audience_ids` as `audience-ids`. Fallback for the page-metadata schema:
  a local `$defs/audience-id` with the same pattern.
- **CR-2.** Add the `# --- 1021: page-metadata ---` anchor to `Get-DocsSchemaPath` as well as
  `Get-DocsSchemaName`.
- **CR-3.** State that `Get-DocsComposedSchemaSet` composes every name of `Get-DocsSchemaName` except
  `common`, and that `Test-DocsArtifactText` resolves `ArtifactKind` against the composed set, not
  against `docs-artifact-kind`.
- **CR-4 (optional).** Add `pattern`, `minLength` and `uniqueItems` to the structural-walk subset;
  `Get-DocsPageConstraintFinding` is then removed.
- **CR-5.** State the base of `ListFile` paths (repository-relative assumed), its behavior for an
  absent directory, and whether `TestFile` is true for a directory.
- **CR-6.** Not a contract request: the template-row form is owner question OQ-A.
- **CR-7.** The starter profile sets `diataxis_policy.required_front_matter` to all five fields.
- **CR-8.** Host the path-or-glob matcher as one exported function (for example in
  `DocsProfile.psm1`) for 1021, 1023 and 1024. Fallback: `Test-DocsPagePathMatch`.
- **CR-9.** The envelope schema's `result` for `check` admits `{page_count, profile_path, roots}` or
  is unconstrained per command; state how the envelope schema is validated (composed name or other
  route).
- **CR-10.** State the form command modules use to call context scriptblocks without an `&` on a
  member expression. Fallback: `.InvokeReturnAsIs(...)`.
- **CR-11 (optional).** A `-Limit` parameter on `New-DocsCommandResult`, because a large page set
  can exceed the default bound of 100 findings.

## Decisions Later Children Must Honor

- **1024 (reference generator).** Emit front matter as `<key>: <JSON value>` lines between `---`
  delimiters; `owner` is an `identifier`; `audience` items match `^[a-z0-9][a-z0-9-]*$` and are
  declared in the profile; `last_reviewed` is a valid `YYYY-MM-DD` date; no heading begins
  `how to ` or matches `^step\s+[0-9]+\b`; generated-block markers are standalone lines. The
  integration test calls `Get-DocsPageCheckFinding` (or `check` through `Invoke-DocsCommandCli`) on
  generated pages plus an entry page that links each of them and asserts zero findings. 1024 may
  import `DocsPageFrontMatter.psm1`, `DocsPageMarkdown.psm1` and `Test-DocsPagePathMatch` (until
  CR-8 lands); page-check modules never import reference modules.
- **1023 (ledger and receipt).** May import `DocsPageFrontMatter.psm1` and `DocsPageDiataxis.psm1`
  to assess the `diataxis_mode` parity dimension; uses the same path-or-glob matcher; does not mint
  `DOCS_PAGE_*` codes.
- **900007 (MCP tools).** `run_docs_check` invokes `-Command check -Json` with optional `-Profile`
  and repeated `-Path`, parses the envelope, and returns `exit_code`, `findings` and `result` as
  specified here; it adds no logic.
- **1034 (enforcement and CI).** The consumer workflow runs
  `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command check`; exit 1 fails the
  job. Its workflow template rows sit under its own anchor and follow the OQ-A answer.
- **900009 (authoring workflow).** Page templates carry every required field; tutorial and how-to
  templates contain an ordered step list; reference and explanation templates contain no
  instructional heading; generated-block markers appear only on reference pages; every new page is
  linked from an entry page.
- **900010 (template and onboarding).** The end-to-end fixture pages pass `check`; the onboarding
  guide lists the `DOCS_PAGE_*` codes, the front-matter subset, the slug and Diataxis precision
  limits, and states that markdownlint and Vale are optional.
- **All.** The page-metadata schema, the front-matter subset, the finding codes and the `check`
  result shape are fixed once 1021 merges; changes need an epic-level update.

## Owner Questions

None of these is decided beyond its provisional default. An owner answer may change the affected
criteria through a specification revision.

1. **OQ-A - Template delivery form.** The base configuration is several files; the 1020 contract and
   the epic say "one `Get-DocsInitTemplate` row", and a row carries one `Source` and one
   `Destination`. Options: (A) one row per file under the 1021 anchor (no 1020 code change; the
   epic wording becomes "rows under the child's anchor"); (D) deliver only `.markdownlint.json`
   through `init` and ship the Vale files as data documented for manual copy, or drop Vale. A
   directory-valued row needs 1020 code and fails the push-down dependency-closure test.
   Provisional default: (A).
2. **OQ-B - Existing consumer configuration.** Under the all-or-nothing `init -Write`, an existing
   `.markdownlint.json` or `.vale.ini` blocks every write, including the profile, unless `-Force`
   overwrites the consumer's file. Options: accept (consistent with 1020 OQ-5); or a per-row "skip
   if exists" mode in 1020 (contract change). Provisional default: accept.

No artifact fails the language rule; neither question concerns language.

## Acceptance Criteria

- [ ] Each failure family produces a distinct finding code whose `artifact_path` is the failing page's repository-relative path, asserted by `tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1` over in-memory page sets: a page missing a required front-matter field yields `DOCS_PAGE_FIELD_MISSING`; malformed front matter yields `DOCS_PAGE_FRONT_MATTER_SYNTAX`, `DOCS_PAGE_FRONT_MATTER_UNSUPPORTED`, `DOCS_PAGE_FRONT_MATTER_UNTERMINATED` or the per-field invalid code; a broken relative link yields `DOCS_PAGE_LINK_BROKEN`; a missing heading anchor yields `DOCS_PAGE_ANCHOR_MISSING` (same page) or `DOCS_PAGE_LINK_ANCHOR_MISSING` (cross page); a Diataxis mode mismatch yields a `DOCS_PAGE_MODE_*` rule code; and an orphan page yields `DOCS_PAGE_ORPHAN`.
- [ ] Every finding code in the `### Finding-code catalog` table is produced by at least one test case with the catalog's artifact path, pointer and severity `error`, and no other code with the `DOCS_PAGE_` prefix is emitted (`DocsPageFrontMatter.Tests.ps1`, `DocsPageLinks.Tests.ps1`, `DocsPageDiataxis.Tests.ps1`, `DocsPageOrphans.Tests.ps1`, `DocsPageCheck.Tests.ps1`).
- [ ] `Invoke-DocsCommand.ps1 -Command check` exits 0 with no `error` finding on a clean in-memory page set, exits 1 when any finding is present, exits 1 with `DOCS_PROFILE_MISSING` for an absent profile, exits 2 with exactly one `DOCS_CLI_ARGUMENTS` and `result` `null` for a non-relative `-Profile` or `-Path`, and exits 3 with `DOCS_CLI_RUNTIME` for an injected read failure (`DocsPageCheck.Tests.ps1` through `Invoke-DocsCommandCli` with an in-memory context).
- [ ] `-Command check -Json` output is byte-identical across two runs with identical inputs and across a reversed `ListFile` order, its findings are in `Get-DocsOrderedFinding` order, and its `result` has the shape `{page_count, profile_path, roots}` (`DocsPageCheck.Tests.ps1`).
- [ ] The `-Command check -Json` stdout document for a clean run, a findings run and a usage-error run validates against `schemas/docs/v1/docs-command-envelope.schema.json` through the validation route the 1020 amendment provides (`DocsPageCheck.Tests.ps1`).
- [ ] An in-memory page containing generated-block markers `<!-- docs:generated:start id=<element-id> -->` and `<!-- docs:generated:end id=<element-id> -->`, another HTML comment with link-shaped and heading-shaped text, and a fenced code block with a broken link, a heading and an ordered list produces no link, anchor or Diataxis-step finding from those regions (`DocsPageMarkdown.Tests.ps1`, `DocsPageLinks.Tests.ps1`, `DocsPageDiataxis.Tests.ps1`).
- [ ] A fixture page set in the 1024 output shape (JSON-valued front matter with `diataxis_mode: "reference"`, declared audiences, element-id `surface_refs`, generated-block markers, no instructional heading, placed in the `reference` directory-mode entry and linked from the root entry page) produces zero findings and exit code 0 (`DocsPageCheck.Tests.ps1`).
- [ ] `schemas/docs/v1/page-metadata.schema.json` has `$id` `urn:drm-copilot:docs:1.0.0:page-metadata`, `type: object`, `additionalProperties: false`, no `required` list, the properties `owner`, `last_reviewed`, `audience`, `diataxis_mode`, `surface_refs`, `title` and `extensions` with the shapes in `### Page-metadata schema`, an `audience` item pattern of `^[a-z0-9][a-z0-9-]*$`, and no `$ref` to a discovery URN or a file; `.claude/lib/docs/schemas/v1/page-metadata.schema.json` is byte-identical to it (`DocsPageMetadataSchema.Tests.ps1`, `DocsSchemaContract.Tests.ps1`).
- [ ] Every committed front-matter fixture that `Test-DocsPageFrontMatter` accepts with no finding also passes `Test-Json` against the composed page-metadata schema, and an audience item such as `Dev_Ops` yields `DOCS_PAGE_AUDIENCE_INVALID` at `/audience/<i>` while `2026-02-30` yields `DOCS_PAGE_LAST_REVIEWED_NOT_A_DATE` (`DocsPageFrontMatter.Tests.ps1`, `DocsPageMetadataSchema.Tests.ps1`).
- [ ] `Invoke-DocsCommand.ps1` contains the `check` row directly under `# --- 1021: check ---` and `Test-DocsCommandTable` returns no finding for the committed table; the feature diff of `Invoke-DocsCommand.ps1` adds lines only under that anchor (`Invoke-DocsCommand.Tests.ps1` membership assertion and diff review).
- [ ] `tests/scripts/claude-lib/docs/DocsPageImportIsolation.Tests.ps1` passes: the static transitive import closure of every `DocsPage*.psm1` module contains only allowed modules and no ledger, analyzer-implementation, reference, inventory, surface-delta or tokens module; no page module uses `using module`, dot-sourcing or `Invoke-Expression`; and an in-memory module text importing `DocsLedger.psm1` is reported (positive control).
- [ ] `tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1` passes: every row under `# --- 1021: page-check configuration ---` resolves to a committed file under `.claude/lib/docs/templates/page-check/`; `vale/Project/accept.txt` is zero bytes; no Vale rule uses `extends: substitution` or `extends: spelling`; no template file contains the framework repository name; `markdownlint.json` parses with `ConvertFrom-DocsJsonText`; and `DocsNeutrality.Tests.ps1` finds no configured consumer-identifier digest under `.claude/lib/docs/` or `schemas/docs/`.
- [ ] `-Command init` without `-Write` lists each base-configuration destination (`.markdownlint.json`, `.vale.ini`, `.vale/styles/DocsBase/HeadingPunctuation.yml`, `.vale/styles/DocsBase/Placeholders.yml`, `.vale/styles/config/vocabularies/Project/accept.txt`) in `planned_writes` and writes nothing; with `-Write` it writes each destination with the bytes of its template source through the in-memory context (`DocsProfileCommands.Tests.ps1` or `DocsPageTemplates.Tests.ps1`).
- [ ] `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` passes: every new file under `.claude/lib/docs/` (modules, runtime schema copy, templates) is listed exactly once in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, and every new or edited file under `.claude/lib/docs/` is SHA-256 identical to its copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`; `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` pass without modification.
- [ ] Seeded property-style tests (seed printed on failure) pass for slug determinism and per-page uniqueness, finding-order invariance under input permutation, orphan-result invariance under listing order, Diataxis verdict invariance under insertion of plain paragraph lines, fenced ordered-list lines never counting as steps, and front-matter parse invariance under insertion of comment and blank lines.
- [ ] Every new or edited file under `.claude/lib/docs/` passes `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` and `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, and no new `DocsPage*.psm1` module exceeds 500 logical lines.
- [ ] No Python or TypeScript file is added or modified: `git diff --name-only <merge-base>..HEAD` lists no path ending in `.py`, `.ts`, `.tsx`, `.js`, `.mjs` or `.cjs`, and the plan's artifact classification table lists every created or edited file with its class, language and permitting rule.
- [ ] No test creates a temporary file: no file under `tests/scripts/claude-lib/docs/` added or edited by this feature contains `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName` or `$env:TEMP`, and every command test uses an in-memory command context.
- [ ] Pester line coverage is at least 85% for each of `DocsPageMarkdown.psm1`, `DocsPageFrontMatter.psm1`, `DocsPageLinks.psm1`, `DocsPageDiataxis.psm1`, `DocsPageOrphans.psm1` and `DocsPageCheck.psm1` (and any refinement split module), read from the PoshQC coverage report of a branch-current `Invoke-PoshQCTest` run with no production file excluded, and recorded under `<FEATURE>/evidence/coverage/` (no branch-coverage gate applies to Pester).
- [ ] (CI-dependent) The required check `poshqc / PowerShell QC` (Pester shards on `windows-latest`, with coverage) passes on the pull request head.

## Definition of Done

- [ ] Acceptance criteria mapped to Pester suites or commands
- [ ] Behavior matches acceptance criteria on PowerShell 7.4 or later and on the CI `windows-latest` runner
- [ ] Edge cases covered: empty page set, BOM and CRLF input built in memory, `...` terminator, duplicate keys, unquoted date, links in fences, comments and code spans, reference-style links, percent-encoded paths and fragments, links escaping the root, duplicate and setext headings, explicit `<a id>` anchors, self-links, link cycles, directory links, nested roots, oversize and non-UTF-8 pages
- [ ] Docs suites pass in seeded shuffled file-order runs in one process (each seed and order recorded) and in a fresh single-process run over `tests/scripts`, with evidence under `<FEATURE>/evidence/regression-testing/`
- [ ] Toolchain pass completed (format, lint with PSScriptAnalyzer, architecture and contract tests, Pester) in a single clean pass
- [ ] Forbidden-token scan with bracket-class patterns over every changed file reports no match
- [ ] Evidence written under `docs/features/active/2026-10-30-docs-page-quality-checker-1021/evidence/<kind>/`

## Seeded Test Conditions (from potential)

- [ ] Unit coverage areas: Markdown line model, front-matter subset, page-metadata validation, links, anchors and slugs, Diataxis rules, orphans, finding order, `check` exit codes
- [ ] Integration scenarios: `check` through `Invoke-DocsCommandCli` over an in-memory context
- [ ] CLI examples: `Invoke-DocsCommand.ps1 -Command check` text and `-Json` output
