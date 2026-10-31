# docs-page-quality-checker (Issue #1021) - PowerShell Design Addendum

- Feature: child 1021 of epic #1019 (documentation-estate-tooling), wave 1, band C3; depends on 1020.
- Branch: `feature/docs-page-quality-checker-1021`
- Mode: re-preparation research under owner decision D1 (new planning cycle). No source,
  configuration or test file was changed.
- Relationship to earlier research: `research/research.2026-10-30T20-35.md` (the "earlier research")
  describes the withdrawn Python package `packages/docs-page-check`. This addendum supersedes every
  part of it that names Python, Poetry, pytest, `jsonschema`, PyYAML, `importlib.resources`,
  `dev.docs.check`, `packages/docs-page-check`, `tests/docs_page_check/` or
  `extensions/drm-copilot/resources/templates/docs-quality/`. Section 1 lists what is kept.
- Requirement origin: one consumer repository (epic `## Goal`). No identifier of that repository
  appears in this file.
- Tool limits: the task-researcher tool set has no shell. Nothing here was executed; behavior of
  `Test-Json` is taken from the orchestrator probe recorded in the 1020 spec.

## 0. Decisions in One Line Each

1. Six PowerShell modules under `.claude/lib/docs/`: the five named by the epic plus one refinement,
   `DocsPageMarkdown.psm1` (shared Markdown line model: fences, HTML comments, code spans, headings).
2. Front matter is parsed by a bounded line parser for a documented YAML subset (flat mapping,
   scalars, single-line flow sequences, JSON values, block sequences of scalars); no YAML module (A8).
3. `page-metadata.schema.json` is a non-artifact schema (no artifact header) composed and validated
   through 1020's existing `Test-DocsArtifactText` with `-ArtifactKind 'page-metadata'`; field
   naming comes from the structural walk plus a 1021-owned constraint evaluator for `pattern`,
   `minLength` and `uniqueItems`, which are outside the walk subset.
4. Which front-matter fields are required is profile data (`diataxis_policy.required_front_matter`),
   not a schema `required` list.
5. Finding codes use the prefix `DOCS_PAGE_`, one code per condition, all severity `error`; every
   page finding names the page through `artifact_path`.
6. `check` enumerates pages from profile `documentation_roots` through `Context.ListFile`, reads them
   through `Context.ReadBytes`, and checks existence of non-page link targets through
   `Context.TestFile`; all rule logic is pure.
7. HTML comments (including generated-block markers), fenced code blocks and inline code spans are
   masked before link, anchor, heading and Diataxis scanning.
8. Base configuration: markdownlint (`.markdownlint.json`) plus a minimal Vale configuration, shipped
   as data under `.claude/lib/docs/templates/page-check/` and delivered by `init`; the "one template
   row" wording cannot carry several files, so the per-file row form is an owner question (OQ-A).
9. Import isolation is proven by a static transitive import-graph test over literal joins.
10. Execution runs in the item worktree under an exempt-route checkpoint: 18 production PowerShell
    files are created or edited (section 15 and `## Numeric Derivation Evidence`).

## 1. Sources and Verification Status

Read in full: `docs/features/epics/documentation-estate-tooling/epic.md`; the 1020 `spec.md`;
the 1020 addendum research (`research/2026-10-30T21-45-docs-profile-powershell-design-addendum-research.md`,
sections 0 to 10); the 1020 plan `plan.2026-10-30T16-08.md` (phases 1 to 5); this folder's `issue.md`,
`spec.md`, earlier research and `evidence/other/preflight-fixes.2026-10-30T20-49.md`; the 1024
`spec.md` (marker grammar, front-matter rules, rendering rules); the 1023 `spec.md` (page-related
references only); the policy files named in the delegation.

Verification legend used below:

- **Tree**: confirmed on this worktree with Read, Grep or Glob.
- **1020 text**: the file or symbol does not exist on the tree; it is planned in 1020 `spec.md` or
  `plan.2026-10-30T16-08.md`. Glob for `.claude/lib/docs/**`, `schemas/docs/**` and
  `tests/scripts/claude-lib/docs/**` returned no files.
- **Epic text**: stated in `epic.md` only (amendment not yet reflected in 1020 `spec.md`).

| Item | Status |
|---|---|
| `.claude/lib/mermaid/MermaidMarkdownFences.psm1` (`Get-MermaidFenceLine`, `Test-MermaidFenceClose`, `Split-MermaidTextLine`) | Tree |
| `.claude/lib/discovery-validation/DiscoveryEncoding.psm1` (`ConvertTo-DiscoveryCanonicalFragment` rejects fractional numbers with `AUTHORIZATION_INPUT_INVALID`) | Tree |
| `schemas/discovery/v2/common.schema.json` `$defs/identifier` pattern `^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$(?![\s\S])` | Tree |
| `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` (discovers `*.psm1` recursively; fail-fast, stop-preference and help-token checks; hard file-size check) | Tree |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` and `EnforcementHooksNoPythonInvocation.Helpers.ps1` (class 3 flags a `CommandAst` whose command position is a non-`[scriptblock]`-parameter variable or an expression) | Tree |
| `tests/scripts/dev_tools/pack_manifest_dependency_scan.py` (`_NAMED_FORM`, `extract_dependency_targets`, `find_missing_dependencies`) and `test_push_down_pack_manifest_dependency_closure.py` (`test_claude_manifest_powershell_dependency_closure`, `test_every_psscriptroot_occurrence_is_recognized`) | Tree |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) and `claude_payload_scope_test_support.py` (`filter_distributable_claude_paths` excludes only `worktrees`, `agent-memory`, `state`, `settings.local.json`) | Tree |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (`paths`, lists `.claude/lib/mermaid/*.psm1` and `DiscoveryEncoding.psm1`) | Tree |
| `config/poshqc-coverage.json` (`roots` includes `.claude/lib`), `config/poshqc-scan.json` (`scanFolders` includes `tests/scripts`) | Tree |
| `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` (reads `config/poshqc-coverage.json`); `scripts/powershell/PoshQC/README.md` (coverage population: `.ps1`/`.psm1` under roots, `*.Tests.ps1` and `tests/` excluded) | Tree |
| `.github/workflows/_poshqc.yml` (job `poshqc-shard`, name `PowerShell QC shard ${{ matrix.shard }}`, `Invoke-PoshQCTest -ShardIndex -ShardCount`) | Tree |
| `quality-tiers.yml` (every existing `.claude/lib/<area>` entry; no `.claude/lib/docs` yet) | Tree |
| `.gitignore` and `extensions/drm-copilot/.vscodeignore` contain no pattern matching `styles`, `.txt`, `.ini`, `.yml`, `vale`, `markdownlint` or `templates` | Tree |
| `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSchema.psm1`, `DocsSurface.psm1`, `DocsAnalyzerRegistry.psm1`, `DocsProfile.psm1`, `DocsProfileCommands.psm1`, `Invoke-DocsCommand.ps1`, every function named from them, the command context, the dispatch table and its anchors, `Get-DocsInitTemplate` and its anchors, `Docs.TestSupport.psm1`, `Docs.Manifest.Tests.ps1`, `DocsSchemaContract.Tests.ps1`, `DocsNeutrality.Tests.ps1` | 1020 text |
| `schemas/docs/v1/docs-command-envelope.schema.json`; `analysis_method`; audience pattern `^[a-z0-9][a-z0-9-]*$` in both schemas | Epic text |
| markdownlint `MD025` parameter `front_matter_title` (default `^\s*title\s*[:=]`; `""` disables); markdownlint `frontMatter` default ignores YAML front matter; `vscode-markdownlint` reads `.markdownlint.json` and `.markdownlint.jsonc` | Upstream documentation (fetched 2026-10-30) |

## 2. Discrepancies Recorded (amended contract followed as stated in epic.md)

1. **Envelope schema.** 1020 `spec.md` (`#### Exit codes and the -Json envelope`) and the epic
   bullet under `### PowerShell contracts from the re-preparation of 1020` say the envelope has no
   schema file. Epic `## Owner Decisions` D5 and `### Amendment of 1020 required by D3 and D5` add
   `schemas/docs/v1/docs-command-envelope.schema.json`. This design follows D5: `check -Json` output
   must validate against that schema.
2. **Anchor placeholders.** 1020 `spec.md` names anchors `# --- 900003: inventory ---` and
   `# --- 900006: generate-reference ---`; the epic manifest uses issue numbers 1022 and 1024. The
   1021 anchors (`# --- 1021: check ---`, `# --- 1021: page-metadata ---`,
   `# --- 1021: page-check configuration ---`) are identical in both and are unaffected.
3. **Audience identifier grammar.** 1020 `### Artifact schema: docs-profile` types `audiences[].id`
   and `documentation_roots[].audience_ids` as docs common `identifier`
   (`^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$`, verified in the discovery common it is copied from). The
   epic (`### Generator decisions from the first preparation of 1024`) binds both schemas to
   `^[a-z0-9][a-z0-9-]*$`. The sets differ: `dev.ops` and `dev_ops` are identifiers but not audience
   ids; `1dev`, `dev-` and `dev--x` are audience ids but not identifiers. The required 1020
   amendment is contract request CR-1 (section 18).
4. **Schema path anchor.** 1020 `spec.md` places the 1021 anchor only in `Get-DocsSchemaName`;
   `Get-DocsSchemaPath` has no anchor. 1021 must add a path row too (CR-2).
5. **"One template row".** 1020 `## Decisions Later Children Must Honor` and the epic say 1021 adds
   one `Get-DocsInitTemplate` row; a row has one `Source` and one `Destination`, and the base
   configuration is several files (section 12, OQ-A).
6. **1024 and 1023 specs are stale.** Both still describe Python (`run_check`, `jsonschema`,
   `yaml.SafeLoader`, owner pattern `^\S(.*\S)?$`). Section 17 states the PowerShell contracts they
   consume; their re-preparation replaces the stale names.

## 3. Module Design

### 3.1 Files and import graph

All modules follow the 1020 module conventions (1020 `spec.md` `### Module conventions`): help-block
token `imports its siblings with -ErrorAction Stop`; `Set-StrictMode -Version Latest` followed
immediately by `$ErrorActionPreference = 'Stop'`; every column-0 `Import-Module` with
`-ErrorAction Stop`; every `$PSScriptRoot` use in the literal form
`Join-Path -Path $PSScriptRoot -ChildPath '<literal>'` (the `_NAMED_FORM` that
`pack_manifest_dependency_scan.py` recognizes); advanced functions with `[CmdletBinding()]`;
"pure" means no filesystem, clock, process, environment or module-scope mutable state.

| File | Role | Imports (literal joins) |
|---|---|---|
| `DocsPageMarkdown.psm1` (refinement) | Line splitting, fence model, HTML-comment and code-span masking, heading and setext detection | none |
| `DocsPageFrontMatter.psm1` | Bounded front-matter parser, scalar resolution, page-metadata validation and finding mapping | `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSchema.psm1`, `DocsPageMarkdown.psm1` |
| `DocsPageLinks.psm1` | Slugs, anchors, link extraction, target resolution, link and anchor findings, page edges | `DocsFinding.psm1`, `DocsPageMarkdown.psm1` |
| `DocsPageDiataxis.psm1` | Path-or-glob match, directory mode, mode signals, Diataxis findings | `DocsFinding.psm1`, `DocsPageMarkdown.psm1` |
| `DocsPageOrphans.psm1` | Entry pages, reachability, orphan findings | `DocsFinding.psm1` |
| `DocsPageCheck.psm1` | Page set, byte decoding, rule orchestration, result, `check` command function | `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSchema.psm1`, `DocsSurface.psm1`, `DocsProfile.psm1`, and the five page siblings |

Reuse decision: the fence rule is the one documented in `MermaidMarkdownFences.psm1` (three or more
backticks or tildes, up to three spaces of indentation, closed by the same character with at least
the same length and no info string), re-implemented in `DocsPageMarkdown.psm1` rather than imported.
Reasons: the Mermaid functions carry Mermaid-specific blockquote and opt-out semantics and a pinned
grammar version, and a docs-owned line model is also needed by 1024 (marker scanning). Importing
the mermaid area would couple two unrelated areas for three small functions.

If `DocsPageLinks.psm1` approaches the 500-line guidance, slug and anchor functions move to a
refinement module `DocsPageAnchors.psm1` (own suite, bundle copy and core entry); section 15 states
the count change.

### 3.2 Exported functions and signatures

`DocsPageMarkdown.psm1` (pure):

- `Split-DocsPageLine -Text <string>` returns `[string[]]`: removes a leading U+FEFF, splits on
  `\r\n|\n|\r`.
- `Get-DocsPageFenceLine -Line <string>` returns `$null` or `[ordered]@{ FenceCharacter;
  FenceLength; Info }`.
- `Test-DocsPageFenceClose -Fence <IDictionary> -OpenFence <IDictionary>` returns `[bool]`.
- `Get-DocsPageLineModel -Line <string[]> [-FirstLineNumber <int> = 1]` returns one ordered
  dictionary per line: `Number` (1-based in the original page), `Text`, `Kind` (`blank`, `text`,
  `fence-open`, `fence-body`, `fence-close`, `comment`, `heading`, `setext-underline`), `Masked`
  (the text with HTML-comment spans and inline code-span contents replaced by spaces; empty for
  `fence-*` and `comment` lines), `HeadingLevel`, `HeadingText` (for `heading`, and for the text line
  that a `setext-underline` promotes), `HasGeneratedStartMarker` (`[bool]`; the raw line equals a
  start marker, see section 6.6).

`DocsPageFrontMatter.psm1` (pure):

- `ConvertFrom-DocsPageFrontMatter -Text <string> -PagePath <string>` returns
  `@{ Present; Terminated; Value; FieldLine; BodyStartLine; Findings }`. `Value` is an ordinal
  hashtable or `$null` when any parse finding exists; `FieldLine` maps each key to its 1-based line.
- `ConvertFrom-DocsPageYamlScalar -Text <string>` returns `@{ Ok; Value; Construct }` (section 4.3).
- `Test-DocsPageFrontMatter -FrontMatter <IDictionary> -PagePath <string> -ComposedSchemaSet
  <IDictionary> -RequiredField <string[]> -AudienceId <string[]> [-FieldLine <IDictionary>]` returns
  ordered findings (section 5.3).
- `Get-DocsPageConstraintFinding -Schema <IDictionary> -Instance <object> -RootSchema <IDictionary>
  -PagePath <string> [-Pointer <string> = '']` returns findings for `pattern`, `minLength` and
  `uniqueItems` (section 5.2; removed if CR-4 is accepted).
- `Test-DocsPageReviewDate -Value <string>` returns `[bool]`.

`DocsPageLinks.psm1` (pure):

- `Get-DocsPageSlug -HeadingText <string>` returns the base slug (section 6.4).
- `Get-DocsPageAnchor -LineModel <object[]>` returns the de-duplicated heading slugs plus explicit
  anchors, in document order.
- `Get-DocsPageLink -LineModel <object[]>` returns `@{ Line; Target; Form }` records (`Form` is
  `inline`, `image` or `definition`).
- `Resolve-DocsPageLinkTarget -PagePath <string> -Target <string>` returns
  `@{ Skip; Path; Fragment; EscapesRepository }`.
- `Get-DocsPageExternalTarget -PageLink <IDictionary> -PagePath <string[]>` returns the sorted,
  de-duplicated resolved paths that are not pages and not page directories; the command checks
  only these through `Context.TestFile`.
- `Get-DocsPageLinkFinding -PagePath <string> -Link <object[]> -PageAnchor <IDictionary>
  -PageSet <string[]> -ExistingPath <string[]>` returns `@{ Findings; Edges }`, where `Edges` are
  the sorted page paths this page links to (fragments ignored, directory links resolved).

`DocsPageDiataxis.psm1` (pure):

- `Test-DocsPagePathMatch -Path <string> -PathOrGlob <string>` returns `[bool]` (section 7.1; the
  fallback owner of the shared matcher, CR-8).
- `Get-DocsPageDirectoryMode -PagePath <string> -DirectoryMode <object[]>` returns
  `@{ Mode; PathOrGlob; Index }` of the first covering entry, or `$null`.
- `Get-DocsPageModeSignal -LineModel <object[]>` returns `@{ OrderedStepLine;
  InstructionHeadingLine; InstructionHeadingText; GeneratedBlockLine }` (0 when absent).
- `Get-DocsPageDiataxisFinding -PagePath <string> -DeclaredMode <string> -LineModel <object[]>
  -DiataxisPolicy <IDictionary>` returns findings.

`DocsPageOrphans.psm1` (pure):

- `Get-DocsPageEntryPage -RootPath <string> -PageSet <string[]>` returns `<root>/README.md`, else
  `<root>/index.md`, else `$null`.
- `Get-DocsPageReachable -EntryPage <string[]> -Edge <IDictionary>` returns the sorted reachable set
  (breadth-first, neighbors in ordinal order; cycles terminate).
- `Get-DocsPageOrphanFinding -PageSet <string[]> -Reachable <string[]>` returns one finding per
  unreachable page.

`DocsPageCheck.psm1`:

- `Get-DocsPageCandidatePath -RootListing <IDictionary>` (pure) takes root id to listed paths,
  keeps paths ending in `.md` (ordinal, case-sensitive), de-duplicates across nested roots, sorts
  ordinally.
- `ConvertFrom-DocsPageBytes -Bytes <byte[]> -PagePath <string> [-MaxBytes <int> = 1048576]` (pure)
  returns `@{ Text; Findings }`; strict UTF-8 through `[System.Text.UTF8Encoding]::new($false, $true)`;
  a leading BOM removed.
- `Get-DocsPageCheckFinding -PageText <IDictionary> -Profile <IDictionary> -ProfilePath <string>
  -ComposedSchemaSet <IDictionary> -ExistingPath <string[]> [-SelectedPath <string[]>]` (pure) runs
  every rule and returns `@{ Findings; Result }`. This is the function the rule tests and the 1024
  integration test call with in-memory pages.
- `Invoke-DocsCheckCommand -Argument <IDictionary> -Context <object>` returns the object from
  `New-DocsCommandResult` (section 9). The name satisfies the 1020 grammar
  `^Invoke-Docs[A-Za-z]+Command$`.

Context calls: the existing guard `enforcement-hooks-no-python-invocation.Tests.ps1` reports an
`&` whose command position is a variable that is not a `[scriptblock]` parameter, or any
expression (verified in `EnforcementHooksNoPythonInvocation.Helpers.ps1`, which inspects `CommandAst`
nodes only). `& $Context.ReadBytes $path` is therefore reported. The command function calls context
members as method invocations (`$Context.ReadBytes.InvokeReturnAsIs($path)`), which are not
`CommandAst` nodes. 1021 follows whatever form 1020's `DocsProfileCommands.psm1` uses; if 1020 uses
another form, the plan copies it (item to confirm, CR-10).

## 4. Front-Matter Subset Parser

### 4.1 Block detection

- Lines come from `Split-DocsPageLine`. A page has a front-matter block when line 1 is exactly
  `---`. The block ends at the next line that is exactly `---` or `...`.
- No terminator: one `DOCS_PAGE_FRONT_MATTER_UNTERMINATED` finding; `Value` is `$null` and the body
  scanners treat the whole page as body (line 1 is then a thematic break).
- `BodyStartLine` is the line after the terminator (1 when there is no block).

### 4.2 Line grammar inside the block

| Line form | Treatment |
|---|---|
| blank or whitespace-only | ignored |
| optional spaces then `#` | full-line comment, ignored |
| `^(?<key>[A-Za-z_][A-Za-z0-9_-]*):(?:[ ]+(?<value>.*))?$` at column 0 | top-level entry |
| `^(?<indent>[ ]*)- (?<item>.*)$` directly after an entry with an empty value (or a previous item) | block sequence item; item must be a scalar |
| a tab in indentation | `DOCS_PAGE_FRONT_MATTER_UNSUPPORTED` (construct `tab indentation`) |
| a quoted key, `? `, an indented line that is not a sequence item, `- key: value`, `- - x` | `DOCS_PAGE_FRONT_MATTER_UNSUPPORTED` (construct named) |
| anything else | `DOCS_PAGE_FRONT_MATTER_SYNTAX` |

A repeated top-level key yields `DOCS_PAGE_FRONT_MATTER_DUPLICATE_KEY` at pointer `/<key>`, naming
both lines. Parsing continues after a finding so every malformed line is reported; any parse finding
makes `Value` `$null`, which suppresses field validation for that page.

### 4.3 Value forms

| Value text (trailing spaces removed) | Result |
|---|---|
| empty, followed by sequence items | array of the item scalars |
| empty, not followed by items | `$null` |
| starts with `"`, `[` or `{` and parses with `ConvertFrom-DocsJsonText` | the JSON value (strings, `Int64`, `Double`, booleans, null, arrays, ordinal hashtables) |
| starts with `[` and is not JSON | single-line flow sequence: comma-separated items, each a plain, single-quoted or JSON double-quoted scalar; `[]` is empty; nested `[`, `{` or an unclosed `]` is `UNSUPPORTED` |
| starts with `{` and is not JSON | `UNSUPPORTED` (construct `flow mapping`) |
| starts with `"` and is not a JSON string (for example the YAML escapes `\x41`, `\e`, `\N`) | `UNSUPPORTED` (construct `YAML escape`) |
| starts with `'` | single-quoted scalar on one line; `''` is one quote; text after the closing quote must be empty or ` #` comment |
| starts with `\|` or `>` | `UNSUPPORTED` (`block scalar`) |
| starts with `&`, `*` or `!` | `UNSUPPORTED` (`anchor`, `alias`, `tag`) |
| starts with `%`, `@`, a backtick, `,`, `]`, `}`, `?` or `- ` | `UNSUPPORTED` (`reserved indicator`) |
| any other text | plain scalar: ` #` starts a comment; a remaining `: ` is `UNSUPPORTED` (`mapping in plain scalar`); then YAML 1.2 core-schema resolution: `null`, `Null`, `NULL`, `~` to null; `true`/`True`/`TRUE`/`false`/`False`/`FALSE` to boolean; `^[-+]?[0-9]+$` to `Int64` (overflow is `UNSUPPORTED`); `^[-+]?(?:\.[0-9]+\|[0-9]+(?:\.[0-9]*)?)(?:[eE][-+]?[0-9]+)?$` to `Double`; `.inf`, `.nan` forms `UNSUPPORTED`; otherwise the string |

Consequences: an unquoted `last_reviewed: 2026-10-30` is the string `2026-10-30` (the core schema
has no timestamp type, which matches the earlier research's intent); the JSON lines emitted by 1024
(`owner: "team-a"`, `audience: ["dev"]`, `surface_refs: []`, `extensions: {}`) parse through the
JSON branch; `audience: [developers, operators]` parses through the flow-sequence branch. Multi-line
values are outside the subset by construction (an indented continuation line is `UNSUPPORTED`).
`ConvertFrom-Json` is not used (1020 rule).

## 5. Page-Metadata Schema and Validation Route

### 5.1 Schema

Canonical `schemas/docs/v1/page-metadata.schema.json`, byte-identical runtime copy
`.claude/lib/docs/schemas/v1/page-metadata.schema.json`, bundle copy under
`extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/`.

- `$schema` `https://json-schema.org/draft/2020-12/schema`; `$id`
  `urn:drm-copilot:docs:1.0.0:page-metadata`; `title` and `description` informative.
- Root: `type: object`, `additionalProperties: false`, no `required` list (section 5.4), no artifact
  header (`$schema`, `schema_version`, `artifact_kind`, `id` are not instance properties).
- Properties, all through `urn:drm-copilot:docs:1.0.0:common#/$defs/<name>` refs:

| Field | Shape |
|---|---|
| `owner` | `identifier` (same grammar as profile `page_owners[].owner` and 1023 deferral owners) |
| `last_reviewed` | `review-date`; calendar validity checked in PowerShell |
| `audience` | `type: array`, `minItems: 1`, `uniqueItems: true`, `items` `audience-id` (CR-1) |
| `diataxis_mode` | `diataxis-mode` |
| `surface_refs` | `element-ids` (may be empty) |
| `title` | `text` (optional) |
| `extensions` | `extensions` (optional) |

Every constraint the walk can name stays in the 1020 subset: `type`, `additionalProperties`,
`enum` (through `diataxis-mode`), `minItems`, `$ref`. `pattern`, `minLength` and `uniqueItems` are
enforced by `Test-Json` and named by the 1021 evaluator (5.2). The schema contains no ref to a
discovery URN or a file, which the 1020 contract test `DocsSchemaContract.Tests.ps1` asserts for
every docs schema.

### 5.2 How a non-artifact schema is validated through the 1020 API

Options compared:

| Option | 1020 change | Field naming |
|---|---|---|
| A. Register `page-metadata` in `Get-DocsSchemaName`/`Get-DocsSchemaPath`; serialize the parsed front matter with `ConvertTo-DocsJsonText`; call `Test-DocsArtifactText -ArtifactKind 'page-metadata'` (selected) | None if `Get-DocsComposedSchemaSet` composes every non-`common` name and `Test-DocsArtifactText` treats `ArtifactKind` as a key of the composed set (CR-3 confirms) | Walk names type, unknown, enum and count failures; 1021 evaluator names `pattern`, `minLength`, `uniqueItems` |
| B. Call `Join-DocsSchemaText` and `Get-DocsSchemaStructuralFinding` directly, plus `Test-Json` in 1021 | None | Same, but duplicates the gate logic of `Test-DocsArtifactText` |
| C. Add a separate "non-artifact schema" API to 1020 | New 1020 function | Same |

Option A is selected: it uses only 1020's published functions and keeps one gate. Two facts drive
the details:

- `ConvertTo-DocsCanonicalJson` delegates to `ConvertTo-DiscoveryCanonicalJson`, whose
  `ConvertTo-DiscoveryCanonicalFragment` throws `AUTHORIZATION_INPUT_INVALID` for a fractional
  number (Tree). A front-matter value such as `owner: 1.5` would then throw instead of producing a
  finding, so the instance text is produced with `ConvertTo-DocsJsonText`, not canonical JSON.
- The 1020 probe records that a failure behind an inline `$ref` makes `Test-Json` return `False`
  with zero ErrorRecords. Every page-metadata field is behind a ref, so `Test-Json` cannot name a
  `pattern` failure. The 1021 evaluator `Get-DocsPageConstraintFinding` walks the composed schema
  value (local `$ref`, `properties`, `items`) and evaluates `pattern` with `[regex]::IsMatch`,
  `minLength` on UTF-16 length of the string (see section 6.4 note on code points), and
  `uniqueItems` by ordinal comparison of `ConvertTo-DocsJsonText` of each item. Constraints are read
  from the composed schema value, so no pattern constant is duplicated in PowerShell.

Contract request CR-4 (optional): adding `pattern`, `minLength` and `uniqueItems` to the 1020 walk
subset would remove the 1021 evaluator. The plan assumes the evaluator (no 1020 change).

### 5.3 `Test-DocsPageFrontMatter` order and mapping

1. Required fields: each name in `-RequiredField` absent from the mapping yields
   `DOCS_PAGE_FIELD_MISSING` at `/<field>`.
2. Schema gate: `Test-DocsArtifactText -ArtifactKind 'page-metadata' -JsonText
   (ConvertTo-DocsJsonText -Value $FrontMatter) -ArtifactPath $PagePath -ComposedSchemaSet ...`.
3. Constraint evaluator over the composed page-metadata schema value.
4. `last_reviewed` calendar check when the value is a string matching the pattern:
   `[datetime]::TryParseExact($value, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture,
   [System.Globalization.DateTimeStyles]::None, [ref]$parsed)`; false yields
   `DOCS_PAGE_LAST_REVIEWED_NOT_A_DATE`. No comparison with the clock.
5. Audience declaration: each `audience` item that is valid but not an id in profile `audiences`
   yields `DOCS_PAGE_AUDIENCE_UNDECLARED` at `/audience/<i>`.
6. Mapping of walk and evaluator findings by the first pointer segment: an unknown property
   (`DOCS_SCHEMA_PROPERTY_UNKNOWN`) becomes `DOCS_PAGE_FIELD_UNKNOWN`; every other finding becomes
   the per-field code (`/owner` to `DOCS_PAGE_OWNER_INVALID`, `/last_reviewed` to
   `DOCS_PAGE_LAST_REVIEWED_INVALID`, `/audience` to `DOCS_PAGE_AUDIENCE_INVALID`, `/diataxis_mode`
   to `DOCS_PAGE_MODE_INVALID`, `/surface_refs` to `DOCS_PAGE_SURFACE_REFS_INVALID`, `/title` to
   `DOCS_PAGE_TITLE_INVALID`, `/extensions` to `DOCS_PAGE_EXTENSIONS_INVALID`). Pointer, artifact
   path and the field-naming message are kept; the line from `-FieldLine` is prefixed to the
   message.
7. Fail closed: a `DOCS_SCHEMA_INVALID` finding (from `Test-Json` `False` with nothing explained)
   is dropped when step 1 to 5 produced a field finding, and otherwise is re-emitted as
   `DOCS_PAGE_FRONT_MATTER_SCHEMA_INVALID` at pointer `''`. A test pins that every committed fixture
   valid under the evaluator is also valid under `Test-Json`.

### 5.4 Required fields come from the profile

1020 already defines `diataxis_policy.required_front_matter` (array of `front-matter-field`). A
schema `required` list of all five would make that profile field inert. The schema therefore
declares shapes only, and `check` passes `required_front_matter` as `-RequiredField`. A page without
a block yields `DOCS_PAGE_FRONT_MATTER_MISSING` only when `required_front_matter` is non-empty.
1024 emits all five fields, so its pages satisfy any setting. Contract request CR-7: the 1020
starter profile sets `required_front_matter` to all five fields so the default is strict.

## 6. Markdown Line Model, Links, Anchors and Slugs

### 6.1 Masking (applies to links, anchors, headings and Diataxis signals)

- Front matter: scanning starts at `BodyStartLine`.
- Fenced code: fence open, body and close lines are not scanned (fence rule of section 3.1). An
  unclosed fence runs to the end of the page.
- HTML comments: from `<!--` to the next `-->`, across lines; text outside the comment on the same
  line is scanned. An unclosed comment runs to the end of the page. Generated-block markers are HTML
  comments and therefore produce no link, anchor or heading.
- Inline code spans: a backtick run up to the next run of equal length on the same line; contents
  are masked for link extraction and kept as text for heading slugs.

Documented precision limits (lexical, not CommonMark): indented code blocks are not recognized
(a link-shaped text inside one is checked; fenced code is the supported form); code spans do not
span lines; raw HTML links (`<a href>`) are not checked; emphasis delimiters `_` remain in slug
input.

### 6.2 Link extraction

- Inline links and images: `[text](destination "title")`, `![alt](destination)`; link text may
  contain one level of nested brackets; destination may be `<...>`.
- Reference definitions: `^ {0,3}\[label\]:\s*(<[^>]*>|\S+)`. Reference uses (`[text][label]`) are
  covered by checking the definition.
- Skipped targets: a URI scheme `^[A-Za-z][A-Za-z0-9+.-]*:`, `//` prefix, empty target.

### 6.3 Resolution

- Split at the first `#`; drop a `?query` part; percent-decode with `[uri]::UnescapeDataString`.
- Fragment-only target: same page.
- A leading `/` resolves from the repository root (the hosting platform's rendering rule); any other
  path resolves against the page's directory with POSIX segment normalization. A result above the
  root yields `DOCS_PAGE_LINK_ESCAPES_REPOSITORY`. Backslash is not a separator.
- The path is satisfied when it is a page; or `<path>/README.md` or `<path>/index.md` is a page
  (the page edge goes to that file); or a page path starts with `<path>/` (a documentation
  directory); or it is in `-ExistingPath` (from `Context.TestFile`). Otherwise
  `DOCS_PAGE_LINK_BROKEN` with `related_paths` holding the resolved path.
- Fragments are checked only when the resolved target is a page in the page set (or a directory
  resolved to one). Fragments on other targets, including Markdown files outside every
  documentation root, are not checked (documented limit).

### 6.4 Anchors and slug rule (language-independent rule kept from the earlier research)

Anchors of a page: slugs of ATX headings (`#` to `######`, closing `#` run removed) and setext
headings (`===` or `---` under a `text` line), plus `<a id="...">` and `<a name="...">` values
(single or double quotes) outside masked regions. Matching against the percent-decoded fragment is
exact and ordinal.

Slug of heading text: (1) replace `[t](u)` with `t`, `![a](u)` with `a`, remove HTML tags;
(2) `ToLowerInvariant()`; (3) keep only characters whose
`[System.Globalization.CharUnicodeInfo]::GetUnicodeCategory(string, index)` is a letter (`Lu`,
`Ll`, `Lt`, `Lm`, `Lo`), mark (`Mn`, `Mc`, `Me`), `Nd`, `Nl` or `Pc` (includes `_`), plus `-` and
space, iterating by code point so surrogate pairs stay intact; (4) each space becomes `-` without
collapsing; (5) per page, the first occurrence keeps the base slug and later occurrences become
`<base>-1`, `<base>-2`, skipping taken values. Precision limit: .NET Unicode tables and
`ToLowerInvariant` may differ from the hosting platform's JavaScript implementation for rare
characters; the earlier research's accepted difference for symbol code points with the Alphabetic
property also stands.

### 6.5 Diataxis signals (from the line model)

- Ordered step: a `text` line matching `^ {0,3}[0-9]{1,9}[.)] +\S` on its masked text.
- Instructional heading: heading text that, case-insensitively, starts with `how to ` or matches
  `^step\s+[0-9]+\b`. The English prefixes are module constants and are documented.
- Generated block: `HasGeneratedStartMarker`.

### 6.6 Generated-block markers

`HasGeneratedStartMarker` is true for an unmasked-position line that equals
`<!-- docs:generated:start id=<element-id> -->` with the docs common `element-id` pattern. 1021
does not validate marker balance or identifiers; 1024 owns those findings
(`REFERENCE_MARKER_*` in its spec).

## 7. Diataxis Rules

### 7.1 Path-or-glob match (shared rule)

Epic `### Generator decisions from the first preparation of 1024`: exact, or prefix plus `/`, or
case-sensitive glob; first match in profile order wins. PowerShell form:
`$Path -ceq $PathOrGlob`, or `$Path.StartsWith($PathOrGlob + '/', [StringComparison]::Ordinal)`, or
`[System.Management.Automation.WildcardPattern]::new($PathOrGlob,
[System.Management.Automation.WildcardOptions]::None).IsMatch($Path)` when the pattern contains `*`,
`?` or `[`. `*` crosses `/`, as Python `fnmatch` did. Difference from `fnmatch`: PowerShell wildcards
have no `[!x]` negation and use a backtick escape; documented. CR-8 asks 1020 to host this as one
shared function so 1023 and 1024 match identically; until then `Test-DocsPagePathMatch` is the
implementation and 1023/1024 import it.

### 7.2 Rules

Evaluated only when the page's `diataxis_mode` is valid (no finding at `/diataxis_mode`):

| Code | Fails when |
|---|---|
| `DOCS_PAGE_MODE_NOT_IN_POLICY` | the declared mode is not in `diataxis_policy.modes` |
| `DOCS_PAGE_MODE_DIRECTORY_MISMATCH` | the first covering `diataxis_policy.directory_modes` entry has a different mode; no covering entry is not a finding |
| `DOCS_PAGE_MODE_STEPS_MISSING` | mode `tutorial` or `how-to` and no ordered step |
| `DOCS_PAGE_MODE_INSTRUCTION_HEADING` | mode `reference` or `explanation` and an instructional heading |
| `DOCS_PAGE_MODE_GENERATED_BLOCK` | mode `tutorial`, `how-to` or `explanation` and a generated-block start marker |

The three structure rules and their justification are the language-independent rules of the earlier
research (`### 2.7 Diataxis mode rules`). Prose judgment stays with the reviewer role (epic
`## Non-Goals`).

## 8. Page Enumeration and Orphans

- For each `documentation_roots[n]` in profile order, `Context.ListFile` with the root `path`.
  `Get-DocsPageCandidatePath` keeps `.md` files, unions nested roots and sorts. The design assumes
  `ListFile` returns repository-relative paths (1020 text says "sorted relative POSIX paths"
  without naming the base; CR-5).
- A root whose listing has no page yields `DOCS_PAGE_ROOT_EMPTY` (artifact path the profile path,
  pointer `/documentation_roots/<n>/path`). Behavior of `ListFile` for an absent directory is not
  stated by 1020 (CR-5); the design treats empty and absent alike.
- Each page is read with `Context.ReadBytes` and decoded by `ConvertFrom-DocsPageBytes`. An
  oversize page (`DOCS_PAGE_TOO_LARGE`, above 1 MiB, the bound the epic records for 1022 inputs) or
  an undecodable page (`DOCS_PAGE_ENCODING_INVALID`) stays in the page set for existence and as a
  graph node with no outgoing edge, and is not scanned.
- Entry pages: per root, `<path>/README.md`, else `<path>/index.md`. A root with neither yields
  `DOCS_PAGE_ROOT_ENTRY_MISSING` (pointer `/documentation_roots/<n>/path`).
- Reachability: breadth-first from every entry page over `Edges`; every page not reached yields
  `DOCS_PAGE_ORPHAN`. Entry pages are never orphans. Links from files outside the page set do not
  count.

## 9. The `check` Subcommand

### 9.1 Dispatch row (under `# --- 1021: check ---` in `Invoke-DocsCommand.ps1`, one line)

```powershell
[pscustomobject]@{ Name = 'check'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageCheck.psm1'); Function = 'Invoke-DocsCheckCommand'; Option = @{ Profile = 'value'; Path = 'multi' } }
```

### 9.2 Options

- `-Profile <relative path>`: default `Get-DocsDefaultProfilePath`
  (`docs/documentation-estate/docs-profile.json`).
- `-Path <relative path>` (repeatable): restricts reported page findings to pages equal to, or
  under, a given path. Links, anchors and reachability are still computed over the full page set.
  Configuration findings (artifact path the profile) are always reported.
- Both values are checked with `Test-DocsRelativePath` before any context call; a failure returns
  exit 2 with exactly one `DOCS_CLI_ARGUMENTS` and `result` `null` (1020 exit-code table).

### 9.3 Flow

1. Validate arguments (exit 2 path).
2. Read the profile through `Context.ReadText`; absent gives `DOCS_PROFILE_MISSING`, exit 1,
   `result` `null`. Read and compose the schema set (`Read-DocsSchemaSet`,
   `Get-DocsComposedSchemaSet`); an unreadable or uncomposable set is exit 3 (1020).
3. `ConvertFrom-DocsProfileText`; any `error` finding: return those findings, exit 1, `result`
   `null`, no page checks.
4. List pages, read bytes, decode.
5. Extract links for every decoded page; `Get-DocsPageExternalTarget`; call `Context.TestFile` once
   per returned path; pass the true set as `-ExistingPath`.
6. `Get-DocsPageCheckFinding`; apply `-Path` selection; a `-Path` value matching no page yields
   `DOCS_PAGE_PATH_UNMATCHED`.
7. `New-DocsCommandResult -Command 'check' -ExitCode (1 if any error finding else 0) -Finding ...
   -Result ... -Line @("check: pages=<n> roots=<n>")`.

Exit 3 also covers a read failure other than absence, caught at the entry boundary as
`DOCS_CLI_RUNTIME` (1020).

### 9.4 Result and envelope

- `result` on exit 0 or 1 after a valid profile: `{profile_path, page_count, roots: [{id, path,
  page_count}]}` with `roots` in profile order; otherwise `null`.
- `-Json`: the 1020 envelope `{command, exit_code, findings, ok, result}` as canonical JSON with
  `command` `check`; findings in `Get-DocsOrderedFinding` order (artifact path, pointer, code,
  related ids, related paths, severity, message, next action; ordinal), de-duplicated and bounded at
  100 with one `FINDINGS_LIMIT` finding when truncated. Identical page bytes, profile and arguments
  give identical bytes (the clock is not read by `check`).
- D5: the stdout document validates against `schemas/docs/v1/docs-command-envelope.schema.json`.
  The 1021 test validates it with whatever function the 1020 amendment provides for the envelope;
  if the envelope is registered as a composed schema name, the same `Test-DocsArtifactText` route as
  section 5.2 applies. The schema's `result` constraint for `check` must admit the shape above (CR-9).
- Ordering note: body findings carry pointer `''` and a message that starts with `line <n>:`, so
  within one page and code they sort by ordinal message text (`line 10` before `line 9`). The order
  is deterministic; it is not numeric line order.

## 10. Finding-Code Catalog

All codes satisfy `^[A-Z][A-Z0-9_]*$`, have severity `error`, and are built with `New-DocsFinding`.
"Page" means `artifact_path` is the page path; "Profile" means the profile path.

| Code | Artifact path | Pointer | `related_paths` | Trigger | Message (after any `line <n>: ` prefix) |
|---|---|---|---|---|---|
| `DOCS_PAGE_FRONT_MATTER_MISSING` | Page | `''` | none | no block and `required_front_matter` non-empty | `front matter block is missing; required fields: <list>` |
| `DOCS_PAGE_FRONT_MATTER_UNTERMINATED` | Page | `''` | none | line 1 `---` with no closing `---`/`...` | `front matter block opened on line 1 is not closed` |
| `DOCS_PAGE_FRONT_MATTER_SYNTAX` | Page | `''` | none | a block line outside the line grammar, or invalid JSON in a JSON-shaped value | `front matter line is not a key, sequence item, comment or blank line` |
| `DOCS_PAGE_FRONT_MATTER_UNSUPPORTED` | Page | `''` | none | a YAML construct outside the subset (section 4) | `front matter construct '<construct>' is outside the supported subset` |
| `DOCS_PAGE_FRONT_MATTER_DUPLICATE_KEY` | Page | `/<key>` | none | repeated top-level key | `front matter key '<key>' repeats the key on line <m>` |
| `DOCS_PAGE_FIELD_MISSING` | Page | `/<field>` | none | field in `required_front_matter` absent | `required front matter field '<field>' is missing` |
| `DOCS_PAGE_FIELD_UNKNOWN` | Page | `/<key>` | none | key not in the schema properties | `front matter field '<key>' is not defined by page-metadata` |
| `DOCS_PAGE_OWNER_INVALID` | Page | `/owner` | none | type or identifier pattern | `front matter field 'owner' ...` (walk or evaluator text) |
| `DOCS_PAGE_LAST_REVIEWED_INVALID` | Page | `/last_reviewed` | none | type or `YYYY-MM-DD` pattern | `front matter field 'last_reviewed' ...` |
| `DOCS_PAGE_LAST_REVIEWED_NOT_A_DATE` | Page | `/last_reviewed` | none | pattern matches, calendar date invalid | `front matter field 'last_reviewed' value '<v>' is not a calendar date` |
| `DOCS_PAGE_AUDIENCE_INVALID` | Page | `/audience` or `/audience/<i>` | none | type, count, item pattern, duplicate item | `front matter field 'audience' ...` |
| `DOCS_PAGE_AUDIENCE_UNDECLARED` | Page | `/audience/<i>` | none | valid id not declared in profile `audiences` | `audience '<id>' is not declared in the docs profile` |
| `DOCS_PAGE_MODE_INVALID` | Page | `/diataxis_mode` | none | type or value outside the four modes | `front matter field 'diataxis_mode' ...` |
| `DOCS_PAGE_SURFACE_REFS_INVALID` | Page | `/surface_refs` or `/surface_refs/<i>` | none | type, element-id pattern, duplicate | `front matter field 'surface_refs' ...` |
| `DOCS_PAGE_TITLE_INVALID` | Page | `/title` | none | type or `text` constraint | `front matter field 'title' ...` |
| `DOCS_PAGE_EXTENSIONS_INVALID` | Page | `/extensions...` | none | `extensions` constraint | `front matter field 'extensions' ...` |
| `DOCS_PAGE_FRONT_MATTER_SCHEMA_INVALID` | Page | `''` | none | `Test-Json` `False` with no field finding (fail closed) | `front matter does not validate against page-metadata` |
| `DOCS_PAGE_LINK_BROKEN` | Page | `''` | resolved path | relative target satisfies no rule of section 6.3 | `link target '<target>' does not resolve to a page or an existing path` |
| `DOCS_PAGE_LINK_ESCAPES_REPOSITORY` | Page | `''` | none | resolves above the repository root | `link target '<target>' resolves above the repository root` |
| `DOCS_PAGE_ANCHOR_MISSING` | Page | `''` | none | same-page fragment matches no anchor | `anchor '#<fragment>' is not a heading or explicit anchor of this page` |
| `DOCS_PAGE_LINK_ANCHOR_MISSING` | Page | `''` | target page | cross-page fragment matches no anchor of the target page | `anchor '#<fragment>' is not a heading or explicit anchor of '<target>'` |
| `DOCS_PAGE_MODE_NOT_IN_POLICY` | Page | `/diataxis_mode` | none | section 7.2 | `diataxis_mode '<m>' is not listed in diataxis_policy.modes` |
| `DOCS_PAGE_MODE_DIRECTORY_MISMATCH` | Page | `/diataxis_mode` | none | section 7.2 | `diataxis_mode '<m>' differs from '<n>' required for '<path_or_glob>'` |
| `DOCS_PAGE_MODE_STEPS_MISSING` | Page | `/diataxis_mode` | none | section 7.2 | `diataxis_mode '<m>' requires an ordered step list` |
| `DOCS_PAGE_MODE_INSTRUCTION_HEADING` | Page | `''` | none | section 7.2 | `heading '<text>' is instructional, which diataxis_mode '<m>' does not allow` |
| `DOCS_PAGE_MODE_GENERATED_BLOCK` | Page | `''` | none | section 7.2 | `generated reference block in a page whose diataxis_mode is '<m>'` |
| `DOCS_PAGE_ORPHAN` | Page | `''` | none | not reachable from any entry page | `page is not reachable from any documentation-root entry page` |
| `DOCS_PAGE_TOO_LARGE` | Page | `''` | none | page above 1 MiB | `page exceeds the 1 MiB scan bound` |
| `DOCS_PAGE_ENCODING_INVALID` | Page | `''` | none | not strict UTF-8 | `page is not valid UTF-8` |
| `DOCS_PAGE_ROOT_EMPTY` | Profile | `/documentation_roots/<n>/path` | none | root lists no page | `documentation root '<id>' at '<path>' contains no Markdown page` |
| `DOCS_PAGE_ROOT_ENTRY_MISSING` | Profile | `/documentation_roots/<n>/path` | none | root has no `README.md`/`index.md` page | `documentation root '<id>' has no README.md or index.md entry page` |
| `DOCS_PAGE_PATH_UNMATCHED` | `null` | `''` | the `-Path` value | a `-Path` value matches no page | `-Path '<p>' matches no page in the documentation roots` |

Reused 1020 codes: `DOCS_PROFILE_MISSING` (exit 1), every finding of `ConvertFrom-DocsProfileText`
(`DOCS_JSON_*`, `DOCS_SCHEMA_*`, `DOCS_PROFILE_*`, `DOCS_ANALYZER_UNKNOWN`; exit 1),
`DOCS_CLI_ARGUMENTS` (exit 2), `DOCS_RUNTIME_UNSUPPORTED` and `DOCS_CLI_RUNTIME` (exit 3),
`FINDINGS_LIMIT`. Every finding carries a fixed `next_action` per code.

Interaction rules: any front-matter parse finding suppresses field findings and Diataxis rules for
that page; Diataxis rules need a valid `diataxis_mode`; link, anchor and orphan rules do not depend
on front matter; `TOO_LARGE` and `ENCODING_INVALID` suppress every other rule for that page except
`DOCS_PAGE_ORPHAN`.

## 11. Compatibility With 1024 Output

Constructs 1024 emits (1024 `spec.md` `### Front-matter rules`, `### Rendering rules`,
`### Marker grammar`) and the 1021 outcome:

| 1024 construct | 1021 handling | Finding |
|---|---|---|
| Front matter `---`, lines `<key>: <JSON value>`, `---` | JSON branch of section 4.3; `\uXXXX` escapes are valid JSON | none |
| `owner` from `page_owners` (identifier) | `identifier` | none |
| `audience` from root `audience_ids` | `audience-id` after CR-1; declared in profile because 1020 rejects undeclared root audience ids (`DOCS_PROFILE_AUDIENCE_UNKNOWN`) | none |
| `last_reviewed` first ten characters of `captured_at` | pattern and calendar valid | none |
| `diataxis_mode: "reference"`; output directory is the `reference` directory-mode entry | rules of section 7.2 pass | none |
| `surface_refs` element ids | `element-ids` | none |
| `# <title>`, `## Command \`<declaration>\`` and similar headings; repeated headings | anchors with de-duplication; no rule on duplicate headings; no heading starts with `how to` or `Step <n>` | none |
| Lists `- Name: \`...\``, no tables, no links, no HTML other than markers | no link to check; no ordered step needed for `reference` | none |
| Standalone marker lines with blank lines around blocks | HTML comments, masked; start marker counted only for `DOCS_PAGE_MODE_GENERATED_BLOCK`, which does not apply to `reference` | none |
| Generated pages with no inbound link | `DOCS_PAGE_ORPHAN` unless an entry page links them | the 1024 integration fixture must include the root entry page linking each generated page (its spec already plans `docs/README.md`) |

## 12. Base Linter and Vale Configuration (D4: data only)

### 12.1 Linter choice

markdownlint, configuration file `.markdownlint.json`. Reasons: the owner's provisional Q3 default
names it; the `vscode-markdownlint` editor extension reads `.markdownlint.json` directly, so a
consumer can apply the configuration in the editor without a project Node install (upstream README,
fetched); markdownlint ignores YAML front matter by default (`frontMatter` option, upstream README).
PyMarkdown (the earlier research's choice) needs Python and does not load `.pymarkdown.json`
implicitly. No linter is a dependency; `check` stays the required gate.

Content (domain-neutral): `{"default": true, "MD013": false, "MD025": {"front_matter_title": ""},
"MD033": {"allowed_elements": ["a"]}}`. `MD025` with `front_matter_title` `""` prevents a page with a
front-matter `title` and an H1 (the 1024 skeleton) from being reported as having two top-level
headings (upstream `md025.md`). Whether `MD033` reports HTML comments is not stated by the upstream
page (item to confirm); the explicit anchor element `a` is allowed because 1021 recognizes
`<a id>` anchors.

### 12.2 Vale

- `vale.ini` template: `StylesPath = .vale/styles`, `MinAlertLevel = warning`, `Vocab = Project`,
  `[*.md]` with `BasedOnStyles = Vale, DocsBase`; no `Packages` key. `.vale/styles` is chosen over
  a root `styles/` to avoid colliding with a consumer's web `styles/` directory.
- `DocsBase/HeadingPunctuation.yml` (`extends: existence`, `scope: heading`) and
  `DocsBase/Placeholders.yml` (`extends: existence`, tokens `TODO`, `TBD`, `FIXME`); no
  `substitution` or `spelling` rule. Repetition is left to the built-in `Vale` style.
- Vocabulary: zero-byte `accept.txt` at the Vale 3 location
  `.vale/styles/config/vocabularies/Project/accept.txt`, consumer-owned.
- Vale facts (key semantics, Vale 3 vocabulary location, behavior with a zero-byte `accept.txt` and
  without `reject.txt`) are carried from the earlier research and remain unverified there.

### 12.3 Template data and delivery

Template sources (no leading dot in the source name, so no dotfile handling in push-down or
packaging is relied on; the destination carries the dot):

| Source under `.claude/lib/docs/` | Destination in the consumer |
|---|---|
| `templates/page-check/markdownlint.json` | `.markdownlint.json` |
| `templates/page-check/vale.ini` | `.vale.ini` |
| `templates/page-check/vale/DocsBase/HeadingPunctuation.yml` | `.vale/styles/DocsBase/HeadingPunctuation.yml` |
| `templates/page-check/vale/DocsBase/Placeholders.yml` | `.vale/styles/DocsBase/Placeholders.yml` |
| `templates/page-check/vale/Project/accept.txt` | `.vale/styles/config/vocabularies/Project/accept.txt` |

All destinations pass the docs common `relative-path` grammar (it rejects `.` and `..` segments,
not names beginning with a dot; Tree, discovery common).

How "one template row" can deliver the set:

| Option | Within the 1020 contract | Evidence |
|---|---|---|
| A. One row per file under the 1021 anchor (recommended default) | Uses the 1020 mechanism unchanged; contradicts the literal "one row" wording | Rows are literal per-file joins, which the closure test resolves to files listed in core |
| B. One directory-valued row (`Source` a directory) | No: 1020 `init` copies one file per row, and a directory target is not a manifest path, so `test_claude_manifest_powershell_dependency_closure` reports it missing (`extract_dependency_targets` returns the joined path; `find_missing_dependencies` compares it with listed file paths) | Tree |
| C. One bundled file expanded by `init` | No: needs 1020 expansion code | 1020 text |
| D. Fewer files: ship only `.markdownlint.json` through `init`; drop Vale or document a manual copy | Yes | Conflicts with the epic 1021 file list (Vale style, vocabulary) |

Owner question OQ-A records the choice between A (wording amendment) and D. Under A, `init -Write`
is all-or-nothing (1020 `init` behavior): a consumer that already has `.markdownlint.json` or
`.vale.ini` gets `DOCS_INIT_TARGET_EXISTS` for that path and nothing is written, including the
profile, unless `-Force` overwrites the consumer file (OQ-B).

## 13. Import Isolation

- Allowed direct imports: 1020 foundation modules `DocsJson.psm1`, `DocsFinding.psm1`,
  `DocsSchema.psm1` (and `DocsSchemaWalk.psm1` if 1020 splits it per its plan task `[P3-T3]`),
  `DocsSurface.psm1`, `DocsProfile.psm1`; and the six `DocsPage*.psm1` modules.
- Denied: `DocsLedger*`, `DocsParity*`, `DocsEvidencePins*`, `DocsStaleness*`, `DocsReceipt*`,
  `DocsValidation*`, `DocsInventory*`, `DocsReference*`, `DocsSurfaceDelta*`, `DocsExtensionImport*`,
  `Docs*Tokens*`, and every `DocsAnalyzer<Name>.psm1` other than `DocsAnalyzerRegistry.psm1`.
- `DocsProfile.psm1` imports `DocsAnalyzerRegistry.psm1` (1020 import graph). The registry is a 1020
  contract module; it loads analyzer modules only inside `Invoke-DocsAnalyzer` through its
  `-ImportModule` seam (no literal join), which `check` never calls.
- Proof: `tests/scripts/claude-lib/docs/DocsPageImportIsolation.Tests.ps1` reads the committed module
  texts (read-only), parses each with `[System.Management.Automation.Language.Parser]::ParseInput`,
  follows every `Import-Module` whose argument is a literal `Join-Path -Path $PSScriptRoot -ChildPath`
  join, and computes the transitive closure from each page module. It asserts that the direct
  imports are within the allowlist, that the closure contains no denied name, that no page module
  uses `using module`, dot-sourcing or `Invoke-Expression`, and, as a positive control, that an
  in-memory module text importing `DocsLedger.psm1` is reported. A static graph is used instead of
  `Get-Module` after import because loaded-module state leaks between suites in shuffled and
  single-process runs (execution-environment `## CI-Only Failure Classes`).

## 14. Push-Down, Coverage and Tiers

- Every new `.claude/lib/docs/` file (six modules, the runtime schema copy, the five templates) is
  appended to `paths` in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
  and copied byte-identically under
  `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`. The three edited 1020
  files keep their entries and are re-copied to the bundle.
- Contract tests that pin this: `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` (1020: each
  file under `.claude/lib/docs/` listed once in core and SHA-256 identical in the bundle);
  `test_push_down_claude_resource_contracts.py`
  (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`);
  `test_push_down_pack_manifest_dependency_closure.py` (`test_claude_manifest_powershell_dependency_closure`,
  `test_every_psscriptroot_occurrence_is_recognized`; the template and schema joins are dependency
  targets); `DocsSchemaContract.Tests.ps1` (1020: runtime and canonical schema file sets equal and
  byte-identical; no discovery or file ref); `DocsNeutrality.Tests.ps1` (1020: scans every file
  under `.claude/lib/docs/` and `schemas/docs/`, so the templates and schema are covered);
  `ClaudeLibModuleConvention.Tests.ps1`; `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`;
  `enforcement-hooks-no-python-invocation.Tests.ps1`.
- `test_push_down_claude_pack_manifest_completeness.py` enumerates bundled agents, hooks and skills
  only (1020 addendum section 6), so it does not cover lib files.
- Coverage population: `Invoke-PoshQCTest` reads `config/poshqc-coverage.json` (`roots` contains
  `.claude/lib`; `PoshQC.Coverage.psm1`) and measures `.ps1`/`.psm1` files under the roots, excluding
  `*.Tests.ps1` and the `tests/` tree (`scripts/powershell/PoshQC/README.md`). The six new modules
  join the population with no configuration edit; the bundle copies are under
  `extensions/drm-copilot/resources/`, which is not a coverage root.
- `quality-tiers.yml`: 1020 adds `.claude/lib/docs` at T3; 1021 adds no entry (no new project
  folder). T3 has no property-test or mutation obligation; seeded property-style tests are still
  planned for the pure functions where cheap (section 16).

## 15. Artifact Classification and Batch Budget

Rule references, as in 1020 `spec.md` `## Artifact Classification`: R1 = language rule clause (1)
(pushed-down helpers and libs are PowerShell or bash); R2 = clause (2) (TypeScript only for MCP and
extension commands; none here); D = epic `### Artifact classes for this epic` (schema, configuration,
data, test and documentation rows). "Avoid new Python" applies to every row.

| File (create unless noted) | Class | Language | Rule |
|---|---|---|---|
| `.claude/lib/docs/DocsPageMarkdown.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsPageFrontMatter.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsPageLinks.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsPageDiataxis.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsPageOrphans.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsPageCheck.psm1` | pushed-down helper/lib (command module) | PowerShell | R1 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` (edit: one row under `# --- 1021: check ---`) | pushed-down helper/lib (entry) | PowerShell | R1 |
| `.claude/lib/docs/DocsSchema.psm1` (edit: name and path rows under the 1021 anchor) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsProfileCommands.psm1` (edit: template rows under `# --- 1021: page-check configuration ---`) | pushed-down helper/lib | PowerShell | R1 |
| `schemas/docs/v1/page-metadata.schema.json` | schema/config/data | JSON | D |
| `.claude/lib/docs/schemas/v1/page-metadata.schema.json` | schema/config/data (pushed down) | JSON | D |
| `.claude/lib/docs/templates/page-check/markdownlint.json` | schema/config/data (pushed down) | JSON | D (D4) |
| `.claude/lib/docs/templates/page-check/vale.ini` | schema/config/data (pushed down) | INI | D (D4) |
| `.claude/lib/docs/templates/page-check/vale/DocsBase/HeadingPunctuation.yml` | schema/config/data (pushed down) | YAML | D (D4) |
| `.claude/lib/docs/templates/page-check/vale/DocsBase/Placeholders.yml` | schema/config/data (pushed down) | YAML | D (D4) |
| `.claude/lib/docs/templates/page-check/vale/Project/accept.txt` (zero bytes) | schema/config/data (pushed down) | text | D (D4) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/**` (bundle copies of the nine PowerShell files, the runtime schema and the five templates) | pushed-down helper/lib and data (mirror) | PowerShell, JSON, INI, YAML, text | R1, D |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit) | schema/config/data | JSON | D |
| `tests/scripts/claude-lib/docs/DocsPage*.Tests.ps1` and in-module test helpers | test | PowerShell (Pester) | D |
| 1020 test files edited for dispositions (section 16.2) | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-page-quality-checker-1021/**` | documentation | Markdown | D |

No MCP tool, extension command, hook, skill, agent, Python or TypeScript file is created or edited.
No artifact needs an exception to the language rule.

Batch budget: 18 production PowerShell files are created or edited (nine under `.claude/lib/docs/`
and nine bundle copies; `## Numeric Derivation Evidence`), above the direct-mode cap of three per
session and worktree (execution-environment `## Batch Budget`). Execution runs in the item worktree
whose `artifacts/orchestration/orchestrator-state.json` selects a non-terminal `large`,
`remediation` or `preparation` route, never in an isolated executor worktree. If `DocsPageAnchors.psm1`
is split out, the figure becomes 20.

File-size tiers (500 guidance, 700 advisory, above 800 blocked): expected sizes are below 500 for
every module; the largest candidates are `DocsPageLinks.psm1` (extraction, resolution, slugs) and
`DocsPageFrontMatter.psm1` (parser plus evaluator). The split rule above applies to the first; the
evaluator can move to `DocsPageMetadata.psm1` for the second (same count change). Test files follow
the same tiers; `DocsPageFrontMatter.Tests.ps1` and `DocsPageLinks.Tests.ps1` are split by context
when they near 500.

## 16. Testing Implications

### 16.1 New suites (`tests/scripts/claude-lib/docs/`, Pester 5)

| Suite | Scope |
|---|---|
| `DocsPageMarkdown.Tests.ps1` | line splitting (CRLF, CR, BOM built in memory), fences (length, character, unclosed), comment masking across lines, code-span masking, ATX and setext headings, marker detection |
| `DocsPageFrontMatter.Tests.ps1` | each row of sections 4.2 and 4.3; each field code; calendar check (leap day valid, `2026-02-30` invalid); fail-closed mapping; JSON-line front matter of the 1024 shape; required-field behavior with an empty and a full `-RequiredField` |
| `DocsPageMetadataSchema.Tests.ps1` | runtime copy byte-identical to canonical; composition through `Join-DocsSchemaText`; fixtures valid under the evaluator also pass `Test-Json`; no discovery or file ref |
| `DocsPageLinks.Tests.ps1` | slug cases (duplicates, Unicode letters and marks, punctuation, `_`, double spaces, code spans); explicit anchors; each link form and skip rule; root-relative and escaping targets; directory links; fragments on non-pages not checked; links in fences, comments and code spans ignored |
| `DocsPageDiataxis.Tests.ps1` | path match forms; first-match precedence; each rule; signals inside fences and comments ignored |
| `DocsPageOrphans.Tests.ps1` | entry selection, cycles, unreachable pages, nested roots |
| `DocsPageCheck.Tests.ps1` | `Invoke-DocsCheckCommand` with the in-memory context of `Docs.TestSupport.psm1`: exit 0 clean set; exit 1 per finding family; exit 2 for a non-relative `-Profile` or `-Path`; `DOCS_PROFILE_MISSING`; invalid profile stops page checks; `-Path` selection and `DOCS_PAGE_PATH_UNMATCHED`; `TestFile` called only for external targets (recorded calls); result shape; envelope through `Invoke-DocsCommandCli` with `-Json` validates against the envelope schema and is byte-identical across two runs and across reversed listing order |
| `DocsPageImportIsolation.Tests.ps1` | section 13 |
| `DocsPageTemplates.Tests.ps1` | template rows under the 1021 anchor resolve to listed files; `accept.txt` is zero bytes; no `extends: substitution` or `extends: spelling`; no file names the repository (`drm-copilot`) and the consumer digests of `DocsNeutrality.Tests.ps1` find nothing; `markdownlint.json` parses with `ConvertFrom-DocsJsonText` |

Seeded property-style tests (seed printed on failure, `[System.Random]`): slug determinism and
per-page uniqueness; finding order invariant under input permutation; orphan result invariant under
page listing order; Diataxis verdict invariant under insertion of plain paragraph lines; ordered-list
lines inside fences never count.

No test creates a temporary file (`New-TemporaryFile`, `TestDrive`, `GetTempPath`,
`GetTempFileName`, `$env:TEMP` absent); suites that read committed files only read. Every suite
removes the `Docs*` and `DiscoveryEncoding` modules it imported in `AfterAll`.

### 16.2 Existing 1020 tests whose assertions 1021 changes (dispositions for the plan)

1020 is not on the tree, so these are named from 1020 text and must be confirmed by searching the
merged 1020 tests for the changed symbols:

- `DocsSchema.Tests.ps1`: any assertion on the exact `Get-DocsSchemaName` list or count changes
  when `page-metadata` is appended; update to membership plus order of the 1020 names.
- `DocsProfileCommands.Tests.ps1`: `[P4-T3]` plans `Get-DocsInitTemplate` "with ... anchors and no
  rows"; a zero-row assertion changes; update to "1020 anchor sections hold no rows".
- `Invoke-DocsCommand.Tests.ps1`: anchor order is unchanged; a committed-table membership check
  gains `check`; per the epic, enumeration tests assert membership, not set equality.
- `DocsSchemaContract.Tests.ps1`: parametrized over the six artifact schemas by name (plan
  `[P3-T4]`), so unchanged; its file-set equality and no-ref checks now include `page-metadata`.
- `Docs.Manifest.Tests.ps1`, `DocsNeutrality.Tests.ps1`: unchanged code, new files in scope.

### 16.3 Acceptance-criterion wording

Pester criteria name the runner and job: suites under `tests/scripts/claude-lib/docs/` run with
coverage on `windows-latest` in `poshqc / PowerShell QC shard 1`, `shard 2` and `shard 3`, merged by
the required check `poshqc / PowerShell QC`; they are not in `poshqc / PowerShell hook suites
(Linux)`. Line coverage of at least 85% per new module is read from
`artifacts/pester/powershell-coverage.xml` of a branch-current `Invoke-PoshQCTest` run; pass counts
from `artifacts/pester/pester-junit.xml`; no PoshQC MCP result is cited as evidence.

### 16.4 Isolation runs

A seeded shuffled file-order run of the touched Pester suites in one process with at least three
seeds (each seed and order recorded), and a fresh single-process run over `tests/scripts`, under
`<FEATURE>/evidence/regression-testing/`.

## 17. Contracts Later Children Must Honor

- **1024 (reference generator).** Emit front matter as `<key>: <JSON value>` lines inside `---`
  delimiters (section 4.3 JSON branch); `owner` must be an `identifier` (replaces the stale
  `^\S(.*\S)?$` in the 1024 spec); `audience` items match `^[a-z0-9][a-z0-9-]*$` and are declared in
  the profile; no heading beginning `how to ` or matching `^step\s+[0-9]+\b`; markers as standalone
  lines; the integration test calls `Get-DocsPageCheckFinding` (or `check` through
  `Invoke-DocsCommandCli`) on generated pages plus an entry page that links them and asserts zero
  findings. 1024 may import `DocsPageFrontMatter.psm1` (`ConvertFrom-DocsPageFrontMatter`,
  `Test-DocsPageFrontMatter`) and `DocsPageMarkdown.psm1` (fence rule) to read existing pages, and
  `Test-DocsPagePathMatch` until CR-8 lands; page-check modules never import reference modules.
- **1023 (ledger and receipt).** May import `DocsPageFrontMatter.psm1` and `DocsPageDiataxis.psm1`
  to assess the `diataxis_mode` parity dimension; uses the same path-or-glob matcher; `DOCS_PAGE_*`
  codes are reserved to 1021.
- **900007 (MCP tools).** `run_docs_check` invokes `-Command check -Json` with optional `-Profile`
  and repeated `-Path`; parses the envelope and returns `exit_code`, `findings` and `result` as in
  section 9.4; adds no logic.
- **900008 (enforcement and CI).** The consumer workflow runs
  `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command check`; exit 1 fails the
  job. Its workflow template row is under its own anchor and follows the OQ-A answer.
- **900009 (authoring workflow).** Page templates conform: all required fields; tutorial and how-to
  templates contain an ordered step list; reference and explanation templates contain no
  instructional heading; generated-block markers only on reference pages; every new page is linked
  from an entry page.
- **900010 (template and onboarding).** The end-to-end fixture pages pass `check`; the onboarding
  guide lists the `DOCS_PAGE_*` codes, the front-matter subset of section 4, the slug and Diataxis
  precision limits, and states that markdownlint and Vale are optional.
- **All.** The `page-metadata` schema, front-matter subset, finding codes and `check` result shape
  are fixed once 1021 merges; changes need an epic-level update.

## 18. Contract Requests to 1020 (for the concurrent amendment; not decided here)

- **CR-1 (required by the epic).** Add docs common `audience-id` (`type: string`, pattern
  `^[a-z0-9][a-z0-9-]*$(?![\s\S])`, the trailing guard following the discovery convention so `$`
  cannot match before a final line feed under .NET regex) and `audience-ids` (array, `uniqueItems`,
  items `audience-id`); type profile `audiences[].id` as `audience-id` and
  `documentation_roots[].audience_ids` as `audience-ids`; keep the 1020 examples, starter profile and
  `DocsProfile.Tests.ps1` identifiers valid under both grammars. Optionally add the same guard to
  `review-date`.
- **CR-2.** Add the `# --- 1021: page-metadata ---` anchor to `Get-DocsSchemaPath` as well as
  `Get-DocsSchemaName`.
- **CR-3.** State that `Get-DocsComposedSchemaSet` composes every name of `Get-DocsSchemaName` except
  `common`, and that `Test-DocsArtifactText` resolves `ArtifactKind` against the composed set (unknown
  means absent from it), not against `docs-artifact-kind`.
- **CR-4 (optional).** Add `pattern`, `minLength` and `uniqueItems` to the structural-walk subset.
- **CR-5.** State the base of `ListFile` paths (repository-relative is assumed), its behavior for an
  absent directory, and whether `TestFile` is true for a directory.
- **CR-6.** Not a contract request: the template-row form is owner question OQ-A.
- **CR-7.** Starter profile: `diataxis_policy.required_front_matter` lists all five fields.
- **CR-8.** Host the path-or-glob matcher as one exported function (for example in
  `DocsProfile.psm1`) for 1021, 1023 and 1024.
- **CR-9.** The envelope schema's `result` for `check` admits `{profile_path, page_count, roots}` or
  is unconstrained per command; state how the envelope schema is validated (composed name or other).
- **CR-10.** State the form command modules use to call context scriptblocks without an `&` on a
  member expression.
- **CR-11 (optional).** A `-Limit` on `New-DocsCommandResult`, because a large page set can exceed
  the default bound of 100 findings.

## 19. Owner Questions

- **OQ-A - Template delivery form.** The base configuration is five files; the 1020 contract and the
  epic say "one `Get-DocsInitTemplate` row". Options: (A) one row per file under the 1021 anchor (no
  1020 code change; epic wording amended to "rows under the child's anchor"); (D) deliver only
  `.markdownlint.json` through `init` and ship the Vale files as data documented for manual copy, or
  drop Vale. A directory-valued row is not available without a 1020 code change and conflicts with
  the dependency-closure test (section 12.3). Provisional default: (A).
- **OQ-B - Existing consumer configuration.** Under the 1020 all-or-nothing `init -Write`, an
  existing `.markdownlint.json` or `.vale.ini` blocks every write, including the profile, unless
  `-Force` overwrites the consumer's file. Options: accept (provisional default, consistent with 1020
  OQ-5); or a per-row "skip if exists" mode in 1020 (contract change).

No artifact fails the language rule; neither question concerns language.

## Numeric Derivation Evidence

### Claim N1 - production PowerShell files created or edited under `.claude/lib/docs/`: 9

- Complete Family: every `.ps1` or `.psm1` production file under `.claude/lib/docs/` that 1021 creates
  or edits.
- Exhaustive Search Scope: this addendum's module design (sections 3.1, 9.1, 12.3) and the 1020
  append-only PowerShell edit points (1020 `spec.md` `## Constraints & Risks` "Shared append-only
  edit points" and `## Decisions Later Children Must Honor`).
- Inclusion Rules: created modules; existing 1020 PowerShell files receiving a 1021 row.
- Exclusion Rules: tests, bundle copies (counted in N2), data files, the optional `DocsPageAnchors.psm1`
  refinement (not planned by default), 1020 edit points that 1021 does not touch
  (`DocsAnalyzerRegistry.psm1`, Claude `core.json` and `quality-tiers.yml` are not PowerShell or not
  edited).
- Primary Search Strategy or Query Expression: enumerate the `File` column of section 3.1 plus every
  1020 file this addendum assigns a 1021 row (sections 5.1 schema rows, 9.1 dispatch row, 12.3
  template rows).
- Primary Member Set: `DocsPageMarkdown.psm1`, `DocsPageFrontMatter.psm1`, `DocsPageLinks.psm1`,
  `DocsPageDiataxis.psm1`, `DocsPageOrphans.psm1`, `DocsPageCheck.psm1`, `Invoke-DocsCommand.ps1`,
  `DocsSchema.psm1`, `DocsProfileCommands.psm1`.
- Primary Count: 9.
- Cross-check Search Strategy or Query Expression: start from the epic `### 1021 - docs-page-quality-checker`
  "Files (create)" and "Files (edit)" lists, add refinements declared in section 0 item 1, then add
  each 1020 owner anchor whose label begins `1021:` (1020 `spec.md`: `Get-DocsSchemaName` anchor,
  dispatch-table anchor, `Get-DocsInitTemplate` anchor) mapped to its file.
- Cross-check Member Set: epic create list `DocsPageFrontMatter.psm1`, `DocsPageLinks.psm1`,
  `DocsPageDiataxis.psm1`, `DocsPageOrphans.psm1`, `DocsPageCheck.psm1`; refinement
  `DocsPageMarkdown.psm1`; anchors `# --- 1021: page-metadata ---` in `DocsSchema.psm1`,
  `# --- 1021: check ---` in `Invoke-DocsCommand.ps1`, `# --- 1021: page-check configuration ---` in
  `DocsProfileCommands.psm1`.
- Cross-check Count: 9.
- Member-set Comparison: the normalized sets are equal (same nine file names); no member appears in
  only one set.

### Claim N2 - production PowerShell files counted by the batch budget: 18

- Complete Family: distinct non-test PowerShell files written by `Write` or `Edit` during execution,
  including bundle mirror copies (execution-environment `## Batch Budget`: bundle copies are
  production files and count).
- Exhaustive Search Scope: N1 plus `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`.
- Inclusion Rules: each N1 member and its bundle copy.
- Exclusion Rules: test files (never counted), data files (not PowerShell).
- Primary Search Strategy or Query Expression: N1 member set, each paired with its bundle path.
- Primary Member Set: the nine N1 files and the nine bundle copies of the same names.
- Primary Count: 18.
- Cross-check Search Strategy or Query Expression: the PowerShell rows of the section 15
  classification table (rows with language PowerShell, counting the bundle-mirror row as one copy
  per PowerShell source row).
- Cross-check Member Set: six create rows, three edit rows, and the mirror row's nine PowerShell
  copies.
- Cross-check Count: 18.
- Member-set Comparison: equal; both sets pair each of the same nine sources with one bundle copy.

### Claim N3 - template data files: 5

- Complete Family: files under `.claude/lib/docs/templates/page-check/` that 1021 creates.
- Exhaustive Search Scope: section 12.3 source table and the section 15 classification table.
- Inclusion Rules: template data delivered by `init`.
- Exclusion Rules: the schema copy, bundle copies, PowerShell files.
- Primary Search Strategy or Query Expression: rows of the section 12.3 source table.
- Primary Member Set: `markdownlint.json`, `vale.ini`, `vale/DocsBase/HeadingPunctuation.yml`,
  `vale/DocsBase/Placeholders.yml`, `vale/Project/accept.txt`.
- Primary Count: 5.
- Cross-check Search Strategy or Query Expression: section 15 rows whose path begins
  `.claude/lib/docs/templates/`.
- Cross-check Member Set: the same five paths.
- Cross-check Count: 5.
- Member-set Comparison: equal.

### Claim N4 - all non-test, non-documentation files created or edited: 32

- Complete Family: every production, data or manifest file 1021 creates or edits.
- Exhaustive Search Scope: section 15 classification table.
- Inclusion Rules: PowerShell (N2), canonical schema, runtime schema copy and its bundle copy,
  templates (N3) and their bundle copies, `core.json`.
- Exclusion Rules: tests and feature documentation.
- Primary Search Strategy or Query Expression: sum by kind from N2, N3 and the schema rows.
- Primary Member Set: 18 PowerShell; `schemas/docs/v1/page-metadata.schema.json`; runtime copy;
  bundle runtime copy; 5 templates; 5 bundle templates; `core.json`.
- Primary Count: 32.
- Cross-check Search Strategy or Query Expression: count section 15 rows one by one, expanding the
  bundle-mirror row into its members (nine PowerShell, one schema, five templates).
- Cross-check Member Set: six create PowerShell, three edit PowerShell, two schema files, five
  templates, fifteen bundle copies, `core.json`.
- Cross-check Count: 32.
- Member-set Comparison: equal; both enumerations list the same files.

The finding-code catalog is a design enumeration named code by code; no acceptance criterion should
assert its size.

## Pre-Mortem

- Review checklists: a reviewer can fail the change for a context call written as `& $Context.X`
  (no-Python guard), a non-literal `$PSScriptRoot` use, a module without the convention help token,
  or a template naming the repository. Mitigation: the plan pins the `.InvokeReturnAsIs` form (or
  1020's form, CR-10), literal joins only, the module-convention suite in the QA loop, and
  `DocsPageTemplates.Tests.ps1` plus `DocsNeutrality.Tests.ps1`.
- Coverage: a module whose branches are reached only through the command function can fall under
  85% line coverage. Mitigation: every rule is a pure function tested directly with in-memory
  inputs; per-file line coverage is read from `artifacts/pester/powershell-coverage.xml` of a
  branch-current `Invoke-PoshQCTest` run and recorded per module, with `poshqc / PowerShell QC` as
  the CI check.
- Mirror parity: the bundle copy of an edited 1020 file goes stale when the source is edited after
  the copy step, and `core.json` can miss a template. Mitigation: one copy step after the last source
  edit, `Docs.Manifest.Tests.ps1`, the resource-contract and dependency-closure tests in the final QA
  loop. The execution-environment brief states no fact this feature changes (no CI job, required
  context, tool route or batch-budget rule), so no brief update task is needed.
- File size: `DocsPageLinks.psm1` and `DocsPageFrontMatter.psm1` can pass 500 lines. Mitigation: the
  named refinement splits (`DocsPageAnchors.psm1`, `DocsPageMetadata.psm1`) with their own suites,
  bundle copies and core entries; the hard limit is enforced by
  `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` and the file-size hook.
- Test isolation: suites that import `Docs*` modules leak them into later suites in shuffled and
  single-process runs, and the import-isolation proof would be order-dependent if it used
  `Get-Module`. Mitigation: `AfterAll` removal in every suite, a static import graph for isolation,
  and three seeded shuffled file-order runs plus a fresh single-process run over `tests/scripts`
  recorded under `<FEATURE>/evidence/regression-testing/`.
- CI-only behavior: `Test-Json` and its bundled JsonSchema.Net version on `windows-latest` may differ
  from a local run, and `.gitattributes` `eol=lf` turns committed CRLF fixtures into LF. Mitigation:
  tests assert codes and pointers, never `Test-Json` wording; CRLF and BOM inputs are built in memory;
  POSIX relative paths only. Docs suites run only in the Windows shards.
- Evidence: PoshQC MCP results carry no output, and isolated subagents run `main`'s hooks.
  Mitigation: counts and coverage from the JUnit and coverage files of direct runs; evidence under
  `<FEATURE>/evidence/<kind>/` with `Timestamp`, `Command`, `EXIT_CODE` and `Output Summary`, no
  absolute paths; execution in the item worktree under the exempt-route checkpoint (18 PowerShell
  production files).

## Rejected Alternatives (brief)

- YAML via a third-party module: forbidden by A8.
- Canonical JSON as the front-matter instance text: throws on fractional numbers (section 5.2).
- Schema `required` list for all five fields: makes the 1020 profile field `required_front_matter`
  inert (section 5.4).
- Importing `MermaidMarkdownFences.psm1`: couples two areas and carries Mermaid-specific semantics
  (section 3.1).
- `Get-Module`-based import-isolation proof: order-dependent under shuffled runs (section 13).
- PyMarkdown configuration: needs Python and an explicit `--config` (section 12.1).
- A directory-valued template row: fails the dependency-closure test and needs 1020 code
  (section 12.3).

## Items for the Orchestrator to Confirm (git, gh or a PowerShell run)

1. Whether the 1020 amendment for D3/D5 has landed on the integration branch, and its final names for
   the envelope schema validation route, the dispatch anchors (`1022`/`1024` versus `900003`/`900006`)
   and any accepted contract request (CR-1 to CR-11).
2. The form 1020's command modules use to invoke context scriptblocks (CR-10), and the base and
   absent-directory behavior of `ListFile` and the directory behavior of `TestFile` (CR-5).
3. How 1020 `init` reads a template `Source` (it is an absolute path from `$PSScriptRoot`, not a
   repository-relative context path).
4. That `.ini`, `.yml` and zero-byte `.txt` files under `.claude/lib/docs/templates/` survive the
   Claude push-down publication and VSIX packaging (no ignore pattern matches them on the tree; the
   publication code path was not traced).
5. markdownlint `MD033` behavior for HTML comments, and the Vale items carried from the earlier
   research (zero-byte `accept.txt`, absent `reject.txt`).
6. `[System.Management.Automation.WildcardPattern]` and `[datetime]::TryParseExact` behavior on the
   `windows-latest` PowerShell version (expected stable; not run here).
7. That issues #1019, #1020, #1021, #1023 and #1024 are open and that this branch's merge base with
   the integration branch contains the 1020 merge before execution starts.
