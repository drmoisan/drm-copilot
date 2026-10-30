# docs-reference-generator — Spec

- **Issue:** #1024
- **Parent (optional):** #1019 (epic `documentation-estate-tooling`, wave 1, complexity band C3, epic child 900006)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Research:** `research/research.2026-10-30T20-59.md` (authoritative for the page-plan rules, marker grammar, CLI contract, module responsibilities and test strategy adopted below)

## Overview

The documentation-estate-tooling epic inventories the documentable surface of a destination
repository (CLI commands and options, HTTP routes, configuration keys, public symbols and
architecture components) into a revision-pinned surface inventory snapshot. Reference pages for
that surface are still written by hand, so they drift from the code, and a regeneration step that
overwrote whole pages would destroy hand-written prose. One consumer repository measured the gap by
hand: a feature epic changed 138 `src/` files while only 4 of 79 documentation pages were edited.

This feature adds a deterministic reference-page generator that renders snapshot elements into
marker-delimited generated blocks inside reference pages, preserves every line of author prose
outside those blocks, emits front matter that passes the page checker, and writes nothing unless
`--write` is given. The design is framework-native and domain-neutral; no consumer identifier
appears in framework source.

## Behavior

Add the package `drm_copilot_docs.reference` to `packages/docs-runtime` and the console command
`dev.docs.generate-reference` (module `drm_copilot_docs.cli_generate`).

1. Load and validate the docs profile and the surface inventory snapshot.
2. Resolve the reference output directory and plan one family page per rendered element family.
3. For each planned page, render one generated block per element, merge the blocks into the
   existing page (or a new page skeleton) without moving author prose, and compute the page front
   matter.
4. Without `--write`: print the planned changes (per-page summary and unified diff) and write
   nothing. With `--write`: write changed pages through a digest-guarded port, in path order,
   stopping at the first failure.
5. Report findings and per-page results as text or as one JSON document.

### Upstream symbols consumed

All symbols below are planned by 1020 or 1021 and are not yet implemented. Implementation confirms
each against the merged code before use; this specification does not re-design them.

| Symbol | Source | Use |
|---|---|---|
| `drm_copilot_docs.profile.parse_profile`, `ProfileLoadResult` | 1020 spec `### Profile models and profile.py API` (planned by 1020) | Load and validate the profile |
| `DocsProfile`, `DocumentationRoot`, `PageOwner`, `DiataxisPolicy`, `DirectoryMode`, `ArtifactPaths` | 1020 spec `### Profile models and profile.py API`, `### Artifact schema: docs-profile` (planned by 1020) | Fields read: `repository.id`, `documentation_roots`, `page_owners`, `diataxis_policy.modes`, `diataxis_policy.directory_modes`, `artifact_paths.inventory_snapshot` |
| `drm_copilot_docs.surface_models.SurfaceElement`, `ElementKind`, `ELEMENT_KINDS`, `element_to_json` | 1020 spec `### SurfaceElement and related models`, `### Element identifier function and declaration conventions` (planned by 1020) | Element model; snapshot round trip |
| `drm_copilot_docs.schema_validation.validate_artifact` | 1020 spec `### Schema validation and resources API` (planned by 1020) | Validate the snapshot as `surface-inventory-snapshot` |
| Docs common `$defs/element-id` pattern | 1020 spec `### Docs common $defs` (planned by 1020) | Marker identifier grammar |
| `schemas/docs/v1/page-metadata.schema.json` | 1021 spec `## Page-Metadata Schema` (planned by 1021) | Front-matter contract; read by tests only |
| `drm_copilot_docs_check.cli.run_check` | 1021 spec `### Command` (planned by 1021) | Integration test only; never imported by production code |
| Diataxis rule `DX-NO-INSTRUCTION`, orphan rule, link rules | 1021 spec `## Diataxis Mode Rules`, `## Orphan Detection and Configuration`, `## Links, Anchors, and Slugs` (planned by 1021) | Constraints on emitted Markdown |

Discovery runtime symbols reused unchanged (present on `main`):
`drm_copilot_discovery.findings.Finding`, `finding_key`, `ordered_findings`, `MAX_FINDINGS`,
`validate_finding_path`; `drm_copilot_discovery.parsing.parse_document`.

## Decisions

Orchestrator decisions on the research open questions, recorded as binding for this feature.

- **D1 (research Q1, gap G4; audience grammar).** This feature does not change any upstream schema.
  When a profile-derived audience is empty it reports `REFERENCE_AUDIENCE_MISSING`; when a
  profile audience identifier does not match the page-metadata audience item pattern
  `^[a-z0-9][a-z0-9-]*$` it reports `REFERENCE_AUDIENCE_INVALID`. Epic-level open item: align the
  page-metadata `audience` item pattern with the discovery `identifier` grammar, or restrict
  profile audience identifiers.
- **D2 (research Q2, gap G3; `path_or_glob` coverage).** A `path_or_glob` value `E` covers a page
  path `P` when `P == E`, when `P` starts with `E + "/"`, or when `fnmatch.fnmatchcase(P, E)` is
  true. Among several covering `page_owners` entries the first in profile order wins. The same
  first-match precedence applies to `diataxis_policy.directory_modes` (refinement: a broad
  non-reference entry listed after a specific reference entry does not conflict). Recommendation
  for 900005: adopt the same coverage rule and precedence for `owner_assigned` parity.
- **D3 (research Q3; index page).** No index page and no reserved block identifier in this feature;
  the epic naming contract is unchanged. The consumer links generated pages from an entry page.
  The text report prints a reminder for each page whose action is `create`. The checker
  integration test supplies an entry page that links each generated page.
- **D4 (research Q4, gap G1; snapshot loader placement).** The snapshot loader stays in
  `drm_copilot_docs/reference/snapshot_input.py` to avoid an edit conflict with 900005, which runs
  in the same wave. A later consolidation may move it to a shared `drm_copilot_docs` module.
- **D5 (research Q5; drift-check mode).** A `--check` mode is out of scope (see `## Non-Goals`).
- **D6 (research Q6; contract tests and lock).** Once 1020 has merged into the integration branch,
  implementation reads
  `tests/docs_runtime/test_docs_package_contract.py::test_root_pyproject_registers_docs_console_scripts`
  and `::test_package_pyproject_matches_runtime_contract` (planned by 1020 plan task P5-T5). If
  either asserts an exact console-script set, it is updated to include
  `dev.docs.generate-reference`; if it asserts membership only, it is left unchanged. The
  disposition is recorded in the plan evidence. `poetry check --lock` is run after the script lines
  are added. The exact `read_tree` signature of 1021 `run_check` is confirmed against the merged
  1021 code before the integration test is written.
- **D7 (edit set).** Edited files: root `pyproject.toml` and `packages/docs-runtime/pyproject.toml`,
  each gaining the `[tool.poetry.scripts]` line
  `"dev.docs.generate-reference" = "drm_copilot_docs.cli_generate:main"`. Research refinements
  (R) to the epic file list are adopted: `reference/snapshot_input.py`,
  `reference/markdown_text.py`, `reference/generation.py`, `reference/report.py`, and
  `tests/docs_runtime/test_cli_generate.py` mirroring `cli_generate.py`.
- **D8 (md033 and marker layout).** PyMarkdown md033 is resolved: its default `allowed_elements`
  value admits HTML comments, and the 1021 base `.pymarkdown.json` does not override md033.
  Layout decision: each marker is a standalone line; a blank line separates each marker from the
  block body and from surrounding content, so each comment forms its own HTML block and headings
  keep blank-line separation.

## Inputs / Outputs

- Inputs:
  - Docs profile file (JSON; YAML when the path ends in `.yaml` or `.yml`).
  - Surface inventory snapshot file (JSON).
  - Existing reference pages at the planned page paths (UTF-8; a leading BOM is removed and CRLF
    is normalized to LF before processing).
  - CLI arguments listed in `## API / CLI Surface`.
  - No environment variables, no clock, no randomness, no network.
- Outputs:
  - Report on stdout (text or one JSON document).
  - One diagnostic line on stderr for exit `2` and exit `3`.
  - With `--write` only: created or updated pages under the output directory.
- All paths are repository-relative POSIX paths interpreted against the process working directory
  (the same convention as `dev.docs.validate-profile` and `dev.docs.check`). No absolute path, host
  name, timestamp or environment value appears in any output.
- Versioning: `report_version` is `1.0.0`. Removing or renaming a report key, finding code, exit
  code meaning or argument is a breaking change that requires a major version change and an
  epic-level update, because 900007 wraps this contract.

## API / CLI Surface

### Command synopsis

```text
dev.docs.generate-reference [--profile PATH] [--snapshot PATH] [--output-dir PATH]
                            [--write] [--format text|json]
python -I -m drm_copilot_docs.cli_generate [same arguments]
```

Console script, declared in the root and the package `pyproject.toml`:
`"dev.docs.generate-reference" = "drm_copilot_docs.cli_generate:main"`. The module carries an
`if __name__ == "__main__":` guard that calls `raise SystemExit(main())`.

### Arguments

| Argument | Default | Validation | Meaning |
|---|---|---|---|
| `--profile PATH` | `docs/documentation-estate/docs-profile.json` | `validate_finding_path`; failure exits `2` | Profile file. Suffix `.yaml` or `.yml` selects YAML; any other suffix selects JSON |
| `--snapshot PATH` | `artifact_paths.inventory_snapshot` of the loaded profile | `validate_finding_path`; failure exits `2` | Snapshot file, always parsed as JSON |
| `--output-dir PATH` | Derived from the profile (see `### Output directory`) | `validate_finding_path` (no leading or trailing `/`, no `.` or `..` segment); failure exits `2` | Directory that holds the family pages |
| `--write` | absent | flag, takes no value | Absent: dry run, nothing written. Present: write changed pages |
| `--format {text,json}` | `text` | choice; any other value exits `2` | Report format |
| `-h`, `--help` | | | Prints argparse help to stdout and exits `0`; no report |

- Positional arguments are not accepted (exit `2`). A repeated option takes its last value
  (argparse default). There is no `--dry-run` flag; dry run is the default.
- The parser is an `argparse.ArgumentParser` subclass whose `error()` raises an internal usage
  exception instead of printing usage, so exit `2` produces exactly one stderr line. `SystemExit`
  never escapes `run_generate`.

### Exit codes

| Code | Meaning |
|---|---|
| `0` | No `error` finding. Dry run printed the plan, or write mode completed every required write. `warning` and `info` findings do not change the code. |
| `1` | At least one `error` finding during loading or planning. Nothing is written in either mode. |
| `2` | Invocation error: unknown argument, positional argument, missing option value, invalid `--format` value, or a path argument that fails `validate_finding_path`. |
| `3` | Runtime or output failure: profile, snapshot or existing page unreadable (missing file, `OSError`, invalid UTF-8); write conflict or write failure during `--write`; or an unexpected exception. |

### Stdout and stderr per exit code

| Exit | Stdout | Stderr |
|---|---|---|
| `0` | Full report | Empty |
| `1` | Full report (`ok: false`) | Empty |
| `2` | Empty | Exactly one line: `dev.docs.generate-reference: usage error: <message>` |
| `3`, read failure (before any report exists) | Empty | Exactly one line: `dev.docs.generate-reference: cannot read '<path>': <ExceptionClassName>` |
| `3`, write conflict or failure | Full report (`ok: false`, statuses as in `### Write semantics`) | Exactly one line: `dev.docs.generate-reference: write stopped at '<path>': <status>` where `<status>` is `conflict` or `failed` |
| `3`, unexpected exception | Empty | Exactly one line: `dev.docs.generate-reference: internal error: <ExceptionClassName>` |

The report is rendered to one string and written to stdout with a single `write` call after all
work completes; stdout never carries a partial report. Exception text is never printed, because it
can carry absolute paths.

### Python seams

- `run_generate(argv: Sequence[str], *, ports: GeneratePorts, stdout: TextIO, stderr: TextIO) -> int`
  performs the work against injected ports.
- `GeneratePorts` (frozen dataclass, `kw_only`): `read_bytes: Callable[[str], bytes]` (profile and
  snapshot reads; raises `OSError` on failure) and `pages: PagePort`.
- `main() -> int` passes `sys.argv[1:]`, `sys.stdout`, `sys.stderr` and
  `GeneratePorts(read_bytes=<Path(path).read_bytes>, pages=FileSystemPagePort(Path()))`.

### JSON report

Rendered as `json.dumps(report, sort_keys=True, indent=2, ensure_ascii=False) + "\n"`, LF only.
Top-level keys (exactly these):

| Key | Type | Content |
|---|---|---|
| `findings` | array of object | `Finding.to_dict()` for each finding, ordered by `finding_key`, aggregated with `ordered_findings(..., limit=MAX_FINDINGS)` (a `FINDINGS_LIMIT` marker appears when truncated) |
| `mode` | string | `dry-run` or `write` |
| `ok` | boolean | `true` exactly when the exit code is `0` |
| `pages` | array of object | One entry per planned page, ordered by `path`; empty when a global error stopped planning |
| `report_version` | string | `1.0.0` |
| `summary` | object | Counts, see below |
| `tool` | string | `dev.docs.generate-reference` |
| `uncertain_paths` | array of string | Sorted paths whose on-disk state is unknown after a write failure; empty otherwise |
| `unrendered` | object | Key `architecture-component` mapped to the number of snapshot elements of that kind (`0` when none) |

Finding object keys (from `Finding.to_dict`): `artifact_path` (string or `null`), `code`,
`message`, `next_action`, `pointer`, `related_ids` (sorted array), `related_paths` (sorted array),
`severity` (`error`, `warning`, `info`).

Page object keys (exactly these):

| Key | Type | Content |
|---|---|---|
| `action` | string | `create` (page absent), `update` (new bytes differ from existing bytes), `none` (bytes equal), `blocked` (a page-scoped `error` finding prevented computation) |
| `blocks` | object | `added`, `removed`, `unchanged`, `updated`: each a sorted array of element identifiers; all empty for `blocked` |
| `diff` | string or `null` | Unified diff in dry run for `create` and `update`; `null` for `none`, `blocked`, and in write mode |
| `path` | string | Repository-relative POSIX page path |
| `sha256_after` | string or `null` | Lowercase hex SHA-256 of the computed page bytes; `null` for `blocked` |
| `sha256_before` | string or `null` | Lowercase hex SHA-256 of the existing raw page bytes; `null` when the page is absent |
| `status` | string | One of `planned`, `skipped`, `created`, `updated`, `conflict`, `failed`, `not-attempted`, `blocked` (see `### Write semantics`) |

`summary` keys (all integers): `blocks_added`, `blocks_removed`, `blocks_unchanged`,
`blocks_updated`, `error_count`, `info_count`, `warning_count`, `page_count`, `pages_blocked`,
`pages_changed` (`create` plus `update`), `pages_unchanged` (`none`). Finding counts are computed
from the reported (possibly truncated) finding list.

### Text report

Lines, in this order, each ending in LF:

1. One line per page in `path` order: `<action> <path> (+<added> ~<updated> -<removed>)`.
2. Dry run only: the `diff` text of each page with a non-empty diff, in `path` order.
3. One line per finding in `finding_key` order: `<CODE> <message>`.
4. One line per page whose action is `create`, in `path` order:
   `note: <path> is new; link it from a documentation entry page so that dev.docs.check does not report PAGE_ORPHANED`.
5. One summary line:
   - exit `0`, dry run: `dev.docs.generate-reference: <pages_changed> page(s) to change, <pages_unchanged> unchanged; dry run, nothing written`
   - exit `0`, write: `dev.docs.generate-reference: wrote <n> page(s), <pages_unchanged> unchanged`
   - exit `1`: `dev.docs.generate-reference: <error_count> error(s); nothing written`
   - exit `3` after a write stop: `dev.docs.generate-reference: wrote <n> page(s) before the write stopped`

### Dry-run diff

`render_diff(change) -> str` uses `difflib.unified_diff` over the LF-normalized decoded existing
text and the new text, split with `splitlines()`, with `fromfile` `a/<path>` (or `/dev/null` for
`create`), `tofile` `b/<path>`, empty file dates, default context of three lines, and
`lineterm=""`; the lines are joined with LF and terminated with one LF. When the only difference is
a BOM or CRLF line endings, the action is `update` and the diff is the empty string.

### Write semantics

- Planning completes before any write. If any `error` finding exists, the write port is not called
  in either mode.
- Dry run: status `planned` for `create` and `update`, `skipped` for `none`, `blocked` for
  `blocked`. The write port's `create` and `replace` methods are never called.
- Write mode: pages are processed in `path` order. `none` gets `skipped`. `create` calls
  `port.create(path, content)`; `update` calls
  `port.replace(path, content, expected_sha256=<sha256_before>)`. Success gives `created` or
  `updated`. `PageConflictError` (target already exists on create, digest mismatch on replace)
  gives `conflict` and nothing is written at that path. Any other `OSError` gives `failed` and the
  path is added to `uncertain_paths`. Processing stops at the first `conflict` or `failed`; every
  later page gets `not-attempted`. Earlier writes are not rolled back and are reported.
- Exit `1` in write mode: computed pages get `not-attempted`; blocked pages get `blocked`.

### Finding-code catalog

All findings are `drm_copilot_discovery.findings.Finding` values. `artifact_path` is the profile,
snapshot or page path named in the message; `pointer` is an RFC 6901 pointer into the profile or
snapshot document, or `""` for page findings (front-matter field findings use `/<field>`). Line
numbers are 1-based in the original page, including front matter. `next_action` is a fixed
sentence per code held in a module constant.

| Code | Severity | Scope | Trigger | Message shape |
|---|---|---|---|---|
| `DOCUMENT_*`, `SCHEMA_INVALID`, and the 1020 semantic profile codes | error | global | Passed through unchanged from `parse_profile`, `parse_document` or `validate_artifact` | As emitted upstream |
| `REFERENCE_SNAPSHOT_INVALID` | error | global | Snapshot is schema-valid but an element cannot be constructed as `SurfaceElement` (identifier mismatch, parent rule, line range), an `element_id` repeats, or a property `name` repeats within one element | `<snapshot>: element at '<pointer>' is invalid: <reason>` |
| `REFERENCE_REPOSITORY_MISMATCH` | error | global | Snapshot `repository` differs from profile `repository.id` | `<snapshot>: repository '<snapshot id>' does not match profile repository '<profile id>'` |
| `REFERENCE_OUTPUT_DIR_UNRESOLVED` | error | global | No `--output-dir` and the profile has zero, or more than one, `directory_modes` entry with `mode: reference` whose `path_or_glob` contains none of `*`, `?`, `[` | `<profile>: reference output directory cannot be derived; <count> candidate entries` |
| `REFERENCE_MODE_CONFLICT` | error | global or page | Global: `reference` is not in `diataxis_policy.modes` (pointer `/diataxis_policy/modes`). Page: the first `directory_modes` entry covering the page has a mode other than `reference`, or the existing page declares a valid `diataxis_mode` other than `reference` | `<path>: page requires diataxis_mode 'reference' but <source> declares '<mode>'` |
| `REFERENCE_OUTPUT_OUTSIDE_ROOTS` | error | page | No `documentation_roots` entry covers the page path | `<path>: page is not under any documentation root` |
| `REFERENCE_OWNER_UNRESOLVED` | error | page | The page has no valid existing `owner` and no `page_owners` entry covers the path | `<path>: no page_owners entry covers this page` |
| `REFERENCE_AUDIENCE_MISSING` | error | page | The page has no valid existing `audience` and the covering root has empty `audience_ids` | `<path>: documentation root '<root id>' declares no audience` |
| `REFERENCE_AUDIENCE_INVALID` | error | page | The page has no valid existing `audience` and a covering-root audience identifier does not match `^[a-z0-9][a-z0-9-]*$` | `<path>: audience '<id>' does not match the page-metadata audience pattern` |
| `REFERENCE_FRONT_MATTER_INVALID` | error | page | Existing front matter is unterminated, is not valid YAML, has a duplicate key, is not a mapping, has a key outside the page-metadata properties, or has a value that violates the page-metadata constraint for its field (including an unknown `diataxis_mode` value) | `<path>:<line>: front matter is invalid: <reason>` |
| `REFERENCE_MARKER_MALFORMED` | error | page | A line outside fenced code and outside an open block whose stripped text starts with `<!-- docs:generated:` but is not an exact start or end marker (including indentation, trailing text, or an identifier outside the element-id pattern) | `<path>:<line>: generated-block marker is malformed` |
| `REFERENCE_MARKER_DUPLICATE` | error | page | A start marker repeats an identifier already opened in the page | `<path>:<line>: generated block '<id>' appears more than once` |
| `REFERENCE_MARKER_UNBALANCED` | error | page | An end marker without an open block, a start marker while a block is open, or a start marker never closed (line of the unclosed start) | `<path>:<line>: generated-block markers are unbalanced: <reason>` |
| `REFERENCE_MARKER_MISMATCH` | error | page | An end marker identifier differs from the open start identifier | `<path>:<line>: end marker '<end id>' does not close '<start id>'` |
| `REFERENCE_MARKER_IN_FRONT_MATTER` | error | page | A front-matter line whose stripped text starts with `<!-- docs:generated:` | `<path>:<line>: generated-block marker inside front matter` |
| `REFERENCE_FENCE_UNCLOSED` | error | page | A fenced code block outside generated blocks is not closed before the end of the page | `<path>:<line>: fenced code block is not closed` |
| `REFERENCE_PARENT_MISSING` | warning | page | A `cli-option` whose `parent_id` is not in the snapshot (rendered after all commands) | `<path>: option '<declaration>' has no parent command in the snapshot` (`related_ids`: option id) |
| `REFERENCE_BLOCK_REMOVED` | info | page | An existing block whose identifier is not among the page's planned elements was removed | `<path>:<line>: removed generated block '<id>'` (`related_ids`: removed id) |
| `REFERENCE_WRITE_CONFLICT` | error | page | Write mode: `PageConflictError` from the port | `<path>: page changed on disk or already exists; nothing written` |
| `REFERENCE_WRITE_FAILED` | error | page | Write mode: other `OSError` from the port | `<path>: write failed; on-disk state is uncertain` |

Error gating: global findings stop the run before the next stage (profile errors before the
snapshot read; snapshot or repository errors before planning; output-directory errors before page
reads), and `pages` is empty. Page-scoped errors are collected for every planned page; each
affected page is `blocked`.

### Marker grammar

- Start line, exact full-line match: `<!-- docs:generated:start id=<element-id> -->`.
- End line, exact full-line match: `<!-- docs:generated:end id=<element-id> -->`.
- `<element-id>` matches the 1020 `element-id` pattern
  `^(?:cli-command|cli-option|http-route|config-key|public-symbol|architecture-component)-[0-9a-f]{64}$`.
- No leading or trailing whitespace on a marker line.
- Scanning skips the front-matter block and fenced code blocks outside generated blocks (backtick
  or tilde fence of three or more characters, indented up to three spaces, closed by a fence of the
  same character and at least the same length; the 1021 fence rule). Inside an open generated block
  only marker lines are interpreted.
- Block layout written by the generator: start marker, blank line, body lines, blank line, end
  marker.

### Merge algorithm

`merge_blocks(body_lines, desired, *, path, line_offset) -> MergeResult`, where `desired` is the
ordered tuple of `(element_id, body_lines)` for the page:

1. Parse the body; any marker or fence error returns findings and no text.
2. Existing block with an identifier in `desired`: replace the lines between its markers with
   blank line, desired body lines, blank line. Report `unchanged` when the replaced lines are equal,
   otherwise `updated`. The block keeps its position.
3. Existing block with an identifier not in `desired`: delete from start marker through end marker
   inclusive, plus one following blank line when the line before the block is blank or the block
   starts the body. Report `removed` and emit `REFERENCE_BLOCK_REMOVED`.
4. New identifiers, processed in `desired` order: insert after the end marker of the nearest
   preceding `desired` member present in the page (including blocks inserted earlier in this step)
   as blank line plus block; otherwise before the start marker of the nearest following present
   member as block plus blank line; otherwise, with no block present, remove trailing blank lines
   from the body, append one blank line when the body is non-empty, then the block. Report `added`.
5. Existing block order and all lines outside blocks are never rearranged or edited, except that
   trailing blank lines at the end of the page are reduced so that the page ends with exactly one
   LF.
6. Merging the result again with the same `desired` returns identical text with every block
   `unchanged`.

### Page-plan rules

- Family pages (fixed file names): `cli-command` and `cli-option` render to `cli-reference.md`
  (title `CLI reference`); `http-route` to `http-reference.md` (`HTTP reference`); `config-key` to
  `config-reference.md` (`Configuration reference`); `public-symbol` to `api-reference.md`
  (`API reference`). `architecture-component` elements are not rendered and are counted in
  `unrendered`.
- A family page is planned when its family has at least one snapshot element or the page already
  exists. An existing page whose family has no elements has all its blocks removed and its prose
  kept.
- Page path: `<output-dir>/<file name>`.

#### Output directory

`--output-dir` when given; otherwise the single `diataxis_policy.directory_modes` entry with
`mode: reference` and no `*`, `?` or `[` in `path_or_glob`. Otherwise
`REFERENCE_OUTPUT_DIR_UNRESOLVED`. `reference` must be a member of `diataxis_policy.modes`.

#### Coverage and precedence

- Coverage rule (D2): `E` covers `P` when `P == E`, `P.startswith(E + "/")`, or
  `fnmatch.fnmatchcase(P, E)`.
- Directory mode: the first `directory_modes` entry in profile order covering `P` decides; a mode
  other than `reference` gives `REFERENCE_MODE_CONFLICT`. No covering entry is not a conflict.
- Owner: a valid existing `owner` is preserved; otherwise the `owner` of the first `page_owners`
  entry in profile order covering `P`; none gives `REFERENCE_OWNER_UNRESOLVED`.
- Documentation root: the covering root with the longest `path`; ties go to the first in profile
  order. No covering root gives `REFERENCE_OUTPUT_OUTSIDE_ROOTS`.
- Audience: a valid existing `audience` is preserved; otherwise the sorted `audience_ids` of the
  documentation root, subject to `REFERENCE_AUDIENCE_MISSING` and `REFERENCE_AUDIENCE_INVALID`.

#### Element order within a page

- CLI page: commands by `(declaration, element_id)`; each command is followed by its options by
  `(declaration, element_id)`; options whose parent is absent from the snapshot follow all commands,
  ordered by `(declaration, element_id)`, each with `REFERENCE_PARENT_MISSING`.
- HTTP page: by `(route template, method, element_id)`, where the declaration is
  `<METHOD> <template>`.
- Configuration and API pages: by `(declaration, path, element_id)`.

### Front-matter rules

- Field order when rendered: `owner`, `last_reviewed`, `audience`, `diataxis_mode`,
  `surface_refs`, `title` (when present), `extensions` (when present).
- Each line is `<key>: <json.dumps(value, ensure_ascii=True, sort_keys=True)>`; the block is
  delimited by `---` lines. JSON scalars and flow collections are valid YAML, so the 1021 loader
  parses them; quoting keeps `last_reviewed` a string; `ensure_ascii=True` escapes characters that
  YAML treats as line breaks.
- Generator-owned values: `diataxis_mode` is `reference`; `surface_refs` is the sorted list of
  identifiers of the elements rendered on the page (possibly empty).
- Preserved when present and valid: `owner`, `audience`, `last_reviewed`, `title`, `extensions`.
  A missing field is filled: `owner` and `audience` per `#### Coverage and precedence`,
  `last_reviewed` as the first ten characters of the snapshot `captured_at`; `title` is filled only
  for a new page.
- Existing front matter is read only when line 1 is exactly `---`; it ends at the next line that is
  exactly `---` or `...`. YAML is parsed with a `yaml.SafeLoader` subclass that maps the timestamp
  tag to its source text and rejects duplicate keys. The block is re-rendered in canonical form;
  YAML comments inside it are not preserved.
- Existing page without front matter: a rendered front-matter block and one blank line are
  inserted before the unchanged body.
- Pattern constants in `front_matter.py` equal the page-metadata schema patterns (`owner`
  `^\S(.*\S)?$`, `last_reviewed` `^[0-9]{4}-[0-9]{2}-[0-9]{2}$` plus
  `datetime.date.fromisoformat`, audience item `^[a-z0-9][a-z0-9-]*$`, `surface_refs` item
  `^\S+$`); a test pins them against the committed schema file.

### Rendering rules

- New page skeleton: front matter, blank line, `# <title>`, blank line, blocks separated by one
  blank line, single trailing LF.
- Block body per element (lists, never tables):

```text
## Command `<declaration>`            (cli-command)
### Option `<declaration>`            (cli-option)
## Route `<declaration>`              (http-route)
## Key `<declaration>`                (config-key)
## Symbol `<declaration>`             (public-symbol)

- Name: `<name>`
- Source: `<path>` (lines <start>-<end>)     (the parenthesis is omitted when line_range is null)
- Property `<property name>`: `<json value>` (one line per property, sorted by name)
```

  A blank line separates the heading from the list. Every heading starts with a fixed English word
  followed by a code span, so no heading text begins with `how to ` or matches `^step\s+[0-9]+\b`
  (1021 `DX-NO-INSTRUCTION`).
- Every consumer-derived string (declaration, name, path, property name, property value as
  `json.dumps(value, ensure_ascii=False, sort_keys=True)`) passes through `single_line` and then
  `code_span`. No consumer text starts a line, so no rendered line can open an HTML block, form a
  marker, or form a link.
- `single_line(text)`: replace each character in Unicode categories `Cc`, `Zl`, `Zp` with a space,
  collapse runs of spaces, strip both ends.
- `code_span(text)`: delimiter is a backtick run one longer than the longest backtick run in the
  text; one space of padding is added on both sides when the text starts or ends with a backtick, or
  starts and ends with a space.
- The generator emits no Markdown links and no HTML other than marker comments.

### Determinism rules

- Identical profile bytes, snapshot bytes and existing page bytes produce identical page bytes and
  identical report bytes, independent of element order in the snapshot and of `existing_pages`
  mapping order.
- LF only; every written page ends with exactly one LF; no trailing spaces on generated lines;
  UTF-8 without BOM.
- No clock, randomness, environment variable, host name or absolute path is read into output.
- Ordering: pages by `path`; blocks per `#### Element order within a page`; findings by
  `finding_key`; identifier lists sorted.

## Data & State

- Pure transformations: profile and snapshot bytes plus existing page bytes map to page contents
  and a report. Element identity comes from 1020 `element_identifier`; generated-block identity is
  the element identifier.
- The generator keeps no state between runs and writes no artifact other than the reference pages.
- No caching beyond what 1020 `validate_artifact` already does. No migration or backfill.

## Module Boundaries

All production files under `packages/docs-runtime/src/drm_copilot_docs/`. Pure modules accept
in-memory values (bytes, strings, mappings, dataclasses) and perform no I/O. I/O occurs only in
`reference/writer.py` `FileSystemPagePort` and in `cli_generate.py`.

| Module | Public API | I/O |
|---|---|---|
| `reference/__init__.py` | package docstring only | none |
| `reference/snapshot_input.py` (R) | `SnapshotLoadResult` (`repository`, `captured_at`, `elements` sorted by `element_id`, `findings`, `ok`); `load_snapshot(content: bytes, *, artifact_path: str, resources: Mapping[str, bytes] \| None = None) -> SnapshotLoadResult` | none |
| `reference/page_plan.py` | `FAMILY_PAGES`, `path_covered(path, pattern) -> bool`, `resolve_output_dir(profile, *, override, profile_path) -> OutputDirResult`, `candidate_page_paths(output_dir) -> tuple[str, ...]`, `plan_pages(profile, elements, *, output_dir, existing_paths, profile_path) -> PagePlan`, `unrendered_counts(elements)` | none |
| `reference/markdown_text.py` (R) | `single_line`, `code_span`, `source_line`, `property_lines` | none |
| `reference/render_cli.py` | `render_command_block(element) -> tuple[str, ...]`, `render_option_block(element) -> tuple[str, ...]` | none |
| `reference/render_http.py` | `render_http_block(element) -> tuple[str, ...]` | none |
| `reference/render_config.py` | `render_config_block(element) -> tuple[str, ...]` | none |
| `reference/render_api.py` | `render_api_block(element) -> tuple[str, ...]` | none |
| `reference/markers.py` | `START_PATTERN`, `END_PATTERN`, `format_start(id)`, `format_end(id)`, `parse_body(...)`, `merge_blocks(...) -> MergeResult` | none |
| `reference/front_matter.py` | pattern constants, `FIELD_ORDER`, `split_front_matter(text)`, `read_existing(raw, *, path, line_offset)`, `render_front_matter(values) -> str` | none |
| `reference/generation.py` (R) | `PageChange` (`path`, `before`, `after`, `action`, block lists, `findings`), `GenerationResult`, `generate_reference(profile, snapshot, existing_pages: Mapping[str, bytes \| None], *, output_dir, profile_path) -> GenerationResult` | none |
| `reference/writer.py` | `PageConflictError`, `PagePort` (`Protocol`: `read_bytes(path) -> bytes \| None`, `create(path, content: bytes)`, `replace(path, content: bytes, *, expected_sha256: str)`), `render_diff(change) -> str`, `apply_changes(changes, *, port) -> WriteOutcome`, `FileSystemPagePort(base: Path)` | `FileSystemPagePort` only |
| `reference/report.py` (R) | `build_report(...)`, `render_json(report) -> str`, `render_text(report) -> str` | none |
| `cli_generate.py` | `GeneratePorts`, `run_generate`, `main`, `__main__` guard | yes (thin) |

`FileSystemPagePort` rules: UTF-8 bytes in and out; `read_bytes` returns `None` when the path does
not exist; `create` runs `mkdir(parents=True, exist_ok=True)` on the parent, `touch(exist_ok=False)`
(`FileExistsError` becomes `PageConflictError`), then `write_bytes`; `replace` re-reads the bytes,
compares SHA-256 with `expected_sha256` (mismatch raises `PageConflictError`), then `write_bytes`.
It does not use `open(..., "xb")`, because the `mem_fs_path` fixture does not support mode `x`.

Production code never imports `drm_copilot_docs_check`. The package adds no runtime dependency:
`difflib`, `fnmatch`, `hashlib`, `json`, `re`, `unicodedata` are standard library; PyYAML is
already declared by the 1020 package.

## Implementation Strategy

- Files (create): every `reference/` module and `cli_generate.py` listed in
  `## Module Boundaries`.
- Files (edit), append-only:
  - Root `pyproject.toml` `[tool.poetry.scripts]`:
    `"dev.docs.generate-reference" = "drm_copilot_docs.cli_generate:main"`, placed with the other
    `dev.docs.*` lines.
  - `packages/docs-runtime/pyproject.toml` `[tool.poetry.scripts]`: the same line.
  - The 1020 contract tests per D6, only if they assert an exact script set.
  - No `quality-tiers.yml`, `[tool.coverage.run]` or `[tool.pyright]` edit: 1020 already adds
    `packages/docs-runtime` (T2) and `packages/docs-runtime/src`.
- After the `pyproject.toml` edits: `poetry install` (registers the console script) and
  `poetry check --lock` (expected exit `0`; the lock content hash covers dependencies, not
  scripts).
- Tier obligations (T2): zero untyped escape hatches; at least one property test per pure public
  function.
- Dependency changes: none. Logging and telemetry: none; diagnostics go to stderr. Rollout:
  additive; consumers obtain the command with the docs wheel.
- Execution runs on the large route in the item worktree, because more than three production
  Python files are created (epic decision recorded during preparation of 1021).

### Tests

Layout (pytest prepend import mode; `tests/docs_runtime/__init__.py` exists from 1020):

- `tests/docs_runtime/reference/__init__.py`
- One module per production module: `test_snapshot_input.py`, `test_page_plan.py`,
  `test_markdown_text.py`, `test_render_cli.py`, `test_render_http.py`, `test_render_config.py`,
  `test_render_api.py`, `test_markers.py`, `test_front_matter.py`, `test_generation.py`,
  `test_writer.py`, `test_report.py`.
- Property modules: `test_markers_properties.py`, `test_render_properties.py`,
  `test_generation_properties.py`.
- `test_checker_integration.py`, `test_module_boundaries.py`, and `property_support.py` (a local
  re-implementation of the seeded `Draw` generator and `SEEDS = (11, 23, 47, 101, 211)` following
  `tests/discovery_runtime/test_t2_properties.py`, imported as
  `from tests.docs_runtime.reference.property_support import Draw, SEEDS`).
- `tests/docs_runtime/test_cli_generate.py` mirrors `cli_generate.py`.

Rules:

- No test creates a temporary file. Pure modules receive in-memory values; CLI tests inject
  `GeneratePorts` with an in-memory `read_bytes`, a recording in-memory `PagePort`, and
  `io.StringIO` streams. `FileSystemPagePort` is exercised only under the `mem_fs_path` fixture in
  `tests/conftest.py`. `main()` is covered by monkeypatching `run_generate`.
- Property tests use `Draw` with `@pytest.mark.parametrize("seed", SEEDS)`; `hypothesis` is not
  used. Properties: page bytes invariant under element permutation and repeated generation; report
  bytes invariant under element permutation; `merge_blocks` idempotence; prose preservation;
  marker format and parse round trip for every element kind; `code_span` round trip through a
  CommonMark-rule decoder written in the test; `render_front_matter` output parsed with
  `yaml.safe_load` equals the input mapping; `load_snapshot` of `element_to_json` output reproduces
  the elements; `path_covered` agrees with its definition; no rendered heading begins with
  `how to ` or matches `^step\s+[0-9]+\b` for drawn declarations, including ones that begin with
  those words.
- Negative cases: each marker error class; unclosed fence; malformed, duplicate-key, unknown-key
  and invalid-value front matter; owner unresolved; audience missing and invalid; output directory
  unresolved; page outside roots; mode conflict (profile, directory mode, existing page); snapshot
  repository mismatch; duplicate element identifier; invalid snapshot; each exit-`2` invocation
  error; unreadable profile, snapshot and page (exit `3`); write conflict and write failure (exit
  `3` with partial report).
- Schema pinning: a test reads the committed `schemas/docs/v1/page-metadata.schema.json`
  (read-only) and validates emitted front matter with `jsonschema.Draft202012Validator`, and
  asserts the pattern constants equal the schema patterns.
- Checker integration: build a profile and snapshot in memory, generate pages, add an entry page
  `docs/README.md` with conforming front matter linking each generated page, and call
  `drm_copilot_docs_check.cli.run_check` with an in-memory `read_tree` and
  `frozenset(...).__contains__` as `path_exists`, not under `mem_fs_path` (it would intercept the
  packaged-schema read). A second case regenerates over pages that contain author prose and checks
  again.
- Module boundaries: an AST-based test asserts that no module under `drm_copilot_docs/reference/`
  other than `writer.py` imports `os`, `io`, `pathlib`, `shutil` or `tempfile`, or calls `open`, and
  that no production module imports `drm_copilot_docs_check`.
- Isolation evidence: a reversed-order single-process run of the new modules, recorded under
  `<FEATURE>/evidence/regression-testing/`.

### Coverage gate

`pytest --cov=drm_copilot_docs.reference --cov=drm_copilot_docs.cli_generate --cov-branch
--cov-report=term-missing --cov-report=json:<FEATURE>/evidence/coverage/<timestamp>-coverage.json`.
Line coverage >= 85% and branch coverage >= 75% across `drm_copilot_docs.reference` and
`drm_copilot_docs.cli_generate`; per-file figures are recorded in the evidence. No production path
is excluded from coverage.

### File size

Logical-line tiers apply to every new production and test file: 500 lines is guidance, 700 lines
is advisory, and a file above 800 lines is blocked. `markers.py`, `page_plan.py` and
`cli_generate.py` are the files to watch; shared helpers in `markdown_text.py`, composition in
`generation.py`, and reporting in `report.py` keep them small. Physical line counts are recorded in
the plan evidence.

## Non-Goals

- A `--check` drift-detection mode (D5).
- A generated reference index page or a reserved block identifier (D3).
- Rendering `architecture-component` elements (narrative architecture pages belong to 900009).
- Any change to the 1020 or 1021 schemas, including the audience grammar alignment (D1).
- Emitting Markdown links between pages or from entry pages.
- The MCP tool `generate_docs_reference` (900007).
- Running PyMarkdown or Vale; PyMarkdown md024 and md013 warnings in consumer repositories are not
  gating for this feature.
- Preserving YAML comments or formatting inside an existing front-matter block.

## Constraints & Risks

- Framework code is domain-neutral; the 1020 neutrality test (`tests/docs_runtime/test_neutrality.py`,
  planned by 1020) scans the new files under `packages/docs-runtime/src/`.
- Tests create no temporary files; property tests use the seeded `Draw` pattern.
- Root `pyproject.toml` `[tool.poetry.scripts]` is an append-only shared edit point with other
  wave-1 children; conflicts are resolved in the remediation loop.
- 1020 and 1021 are prepared but not implemented; every consumed symbol is confirmed against merged
  code before use (D6).
- 900005 may need the same snapshot loader (D4) and coverage rule (D2).
- CI runs Python 3.10 to 3.13 on Linux: POSIX paths only (`PurePosixPath`), no `tomllib`, no
  3.11-only syntax, explicit UTF-8 byte writes, CRLF inputs built in memory.
- A consumer must link generated pages from an entry page; otherwise `dev.docs.check` reports
  `PAGE_ORPHANED` (D3).

## Acceptance Criteria

- [ ] Rendering the same snapshot twice is byte-identical (property test): for every seed in `SEEDS`, `generate_reference` over a `Draw`-generated profile and snapshot, run twice and run on a `Draw`-shuffled element order, yields identical page bytes for every page and identical `render_json` report bytes.
- [ ] Prose outside generated markers is preserved across regeneration (property test): for every seed in `SEEDS`, `merge_blocks` over drawn prose segments and drawn existing and desired block sets keeps every non-blank line outside generated blocks in its original order, keeps every prose segment byte-identical when the desired identifier set equals the existing one, and returns identical text with all blocks `unchanged` when applied a second time.
- [ ] A removed element's block is removed and reported: regenerating a page after an element leaves the snapshot deletes that element's block, lists its identifier in the page's `blocks.removed`, and emits one `REFERENCE_BLOCK_REMOVED` finding with severity `info` whose `related_ids` contains that identifier.
- [ ] Every generated page passes `drm_copilot_docs_check` with zero findings (integration test): `run_check` over the generated pages plus an entry page linking each of them returns exit `0` and a JSON report with `summary.finding_count` equal to `0`, both for newly created pages and after regeneration over pages that contain author prose.
- [ ] Without `--write` the command writes nothing and prints the planned changes: a `run_generate` test with a recording `PagePort` records zero `create` and zero `replace` calls, exits `0`, and stdout contains the per-page line and the unified diff (`--- /dev/null` and `+++ b/<path>` for a new page) in text format and a `diff` string with status `planned` in JSON format.
- [ ] Line coverage >= 85% and branch coverage >= 75% for `drm_copilot_docs.reference` and `drm_copilot_docs.cli_generate`, measured with `--cov-branch` and a JSON report under `<FEATURE>/evidence/coverage/`.
- [ ] With `--write`, changed pages are created or updated through the port in `path` order with statuses `created` or `updated`; an immediate second run reports action `none` and status `skipped` for every page and makes no `create` or `replace` call.
- [ ] A digest mismatch or existing target during `--write` stops writing at that page with status `conflict`, gives later pages `not-attempted`, prints the full report on stdout and one stderr line, and exits `3`; an `OSError` from the port gives status `failed` and lists the path in `uncertain_paths`.
- [ ] Each invocation error defined in `### Exit codes` exits `2` with empty stdout and exactly one stderr line beginning `dev.docs.generate-reference: usage error:`; `--help` exits `0`.
- [ ] An unreadable profile, snapshot or existing page exits `3` with empty stdout and exactly one stderr line beginning `dev.docs.generate-reference: cannot read`; an unexpected exception exits `3` with the fixed `internal error` stderr line.
- [ ] Any `error` finding exits `1` in both modes with the full report on stdout and no `create` or `replace` call on the port.
- [ ] `--format json` writes exactly one JSON document equal to `json.dumps(report, sort_keys=True, indent=2, ensure_ascii=False) + "\n"`, with `report_version` `1.0.0`, `tool` `dev.docs.generate-reference`, and top-level, page and summary key sets equal to those defined in `### JSON report` (asserted by a test).
- [ ] Each trigger in `### Finding-code catalog` produces its listed code and severity in a unit test, and each marker error class blocks only the affected page (`action` and `status` `blocked`).
- [ ] Emitted front matter validates against the committed `schemas/docs/v1/page-metadata.schema.json` with `jsonschema.Draft202012Validator`, the `front_matter.py` pattern constants equal the schema patterns, and valid existing `owner`, `audience`, `last_reviewed`, `title` and `extensions` values are preserved.
- [ ] Page-plan rules are enforced by tests: output-directory derivation and `--output-dir` override, the D2 coverage rule with first-match owner and directory-mode precedence, longest-path documentation root for audience, and the family file names in `### Page-plan rules`.
- [ ] A property test over drawn declarations (including ones beginning with `how to` or `step 1`) asserts that no rendered heading text begins, case-insensitively, with `how to ` or matches `^step\s+[0-9]+\b`, and that no rendered line outside marker lines begins with `<`.
- [ ] `load_snapshot` applied to snapshot JSON built from `element_to_json` reproduces the original elements (property test), and duplicate element identifiers or duplicate property names produce `REFERENCE_SNAPSHOT_INVALID`.
- [ ] The root `pyproject.toml` and `packages/docs-runtime/pyproject.toml` each declare `"dev.docs.generate-reference" = "drm_copilot_docs.cli_generate:main"` under `[tool.poetry.scripts]`; a test asserts both entries; the disposition of the 1020 console-script contract tests is recorded per D6; `poetry check --lock` exits `0`.
- [ ] An AST-based test asserts that no module under `drm_copilot_docs/reference/` other than `writer.py` imports `os`, `io`, `pathlib`, `shutil` or `tempfile` or calls `open`, and that no production module imports `drm_copilot_docs_check`.
- [ ] No new test creates a temporary file; `FileSystemPagePort` tests run under `mem_fs_path`; the 1020 neutrality test passes with the new files present.
- [ ] No new production or test file exceeds 800 logical lines.

## Open Questions and Assumptions

1. Epic-level (D1): audience grammar alignment between the discovery `identifier` grammar and the
   page-metadata audience pattern.
2. Epic-level (D2): adoption of the coverage rule and first-match precedence by 900005.
3. Epic-level (D4): later consolidation of the snapshot loader into a shared module.
4. Confirmed at implementation time (D6): exact `run_check` `read_tree` signature; 1020 contract
   test disposition; `poetry check --lock` result.
5. All 1020 and 1021 symbols are planned, not implemented; names in this specification follow the
   prepared specs and are re-confirmed against the merged code.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)

- [ ] Unit coverage areas: page plan, each renderer, marker parse/merge, front matter, writer dry-run
- [ ] Integration scenarios: generated pages checked with `drm_copilot_docs_check`
- [ ] CLI/API examples: `dev.docs.generate-reference` with and without `--write`
