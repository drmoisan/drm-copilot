# 2026-10-30-docs-page-quality-checker — Spec

- **Issue:** #1021
- **Parent (optional):** #1019 (epic `documentation-estate-tooling`, wave 0, complexity band C3, epic child 900002)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Research:** `research/research.2026-10-30T20-35.md` (authoritative for registration, schema strategy, finding codes, Diataxis and orphan rules, and base configuration)

## Overview

A destination repository that adopts the documentation-estate tooling has no framework-provided
way to check the structural quality of its documentation pages. Pages can lack ownership and
review metadata, carry broken relative links or missing heading anchors, drift from their declared
Diataxis mode, or become orphans that no other page links to. One consumer repository built a
bespoke checker for these conditions; the framework needs a domain-neutral, consumer-installable
equivalent. No Markdown QC configuration (PyMarkdown or Vale) exists on `main`, so the framework
also has no base configuration a consumer can adopt.

The design is framework-native. The requirement was observed in one consumer repository; no source
from that repository is copied, and consumer vocabulary stays consumer-owned.

## Behavior

Ship a separate, independently installable Python package `packages/docs-page-check` (import name
`drm_copilot_docs_check`) that imports nothing from `drm_copilot_docs`. It provides:

- Front-matter metadata validation against `schemas/docs/v1/page-metadata.schema.json` with the
  fields `owner`, `last_reviewed`, `audience`, `diataxis_mode`, and `surface_refs`.
- Relative-link and heading-anchor checks.
- A Diataxis mode audit (mode rules per declared `diataxis_mode`).
- Orphan-page detection.
- Deterministic findings rendered as text and JSON, each with a distinct finding code naming the
  file.
- A console command `dev.docs.check` that exits 0 on a clean page set and non-zero when any
  finding is present.

Base consumer configuration ships as bundled extension resources under
`extensions/drm-copilot/resources/templates/docs-quality/`: `.pymarkdown.json`, `.vale.ini`, a
base Vale style `styles/DocsBase/`, and an empty consumer-owned vocabulary file at the Vale 3
location `styles/config/vocabularies/<Name>/accept.txt` (this feature uses the vocabulary name
`Project`).

### Naming contract (fixed by the epic; unchanged here)

| Item | Value |
|---|---|
| Package path | `packages/docs-page-check` |
| Distribution name | `drm-copilot-docs-check` |
| Import name | `drm_copilot_docs_check` (imports nothing from `drm_copilot_docs`) |
| Schema | `schemas/docs/v1/page-metadata.schema.json` |
| Front-matter fields | `owner`, `last_reviewed`, `audience`, `diataxis_mode`, `surface_refs` |
| Console command | `dev.docs.check` (entry point `drm_copilot_docs_check.cli:main`) |
| Base configuration root | `extensions/drm-copilot/resources/templates/docs-quality/` |
| Base configuration files | `.pymarkdown.json`, `.vale.ini`, `styles/DocsBase/`, `styles/config/vocabularies/Project/accept.txt` (empty, consumer-owned) |
| Generated-block marker (consumed, not produced) | `<!-- docs:generated:start id=<element-id> -->` / `<!-- docs:generated:end id=<element-id> -->` |

## Page-Metadata Schema

The downstream reference generator (epic sibling 900006) emits pages that must pass this checker
with zero findings, so the schema below is a cross-feature contract and is fixed once this feature
merges.

### Schema header

- `"$schema": "https://json-schema.org/draft/2020-12/schema"`
- `"$id": "urn:drm-copilot:docs:1.0.0:page-metadata"` (the `urn:drm-copilot:docs:` prefix is
  shared with epic sibling 900001; see Open Questions)
- `"title": "Documentation page metadata"` and a `"description"` string (informative only)
- `"type": "object"`
- `"additionalProperties": false`
- `"required": ["owner", "last_reviewed", "audience", "diataxis_mode", "surface_refs"]`
- Self-contained: the schema contains no `$ref` to any file (in particular none into
  `schemas/discovery/v2/` or into any other `schemas/docs/v1/` schema), because neither is
  installed with this package.
- The schema is page metadata, not an artifact document: it declares no `$schema`,
  `schema_version`, or `artifact_kind` header property for the instance.

### Properties

| Field | Required | Type | Constraints |
|---|---|---|---|
| `owner` | yes | string | `minLength: 1`; `pattern: "^\\S(.*\\S)?$"` (no leading or trailing whitespace) |
| `last_reviewed` | yes | string | `pattern: "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"` (ISO calendar date `YYYY-MM-DD`). Calendar validity is checked in Python with `datetime.date.fromisoformat`; there is no comparison with the current date and no clock dependency. |
| `audience` | yes | array of string | `minItems: 1`; `uniqueItems: true`; each item `pattern: "^[a-z0-9][a-z0-9-]*$"` |
| `diataxis_mode` | yes | string | `enum: ["tutorial", "how-to", "reference", "explanation"]` |
| `surface_refs` | yes | array of string | `uniqueItems: true`; may be empty (`minItems` not set); each item `minLength: 1`, `pattern: "^\\S+$"`. The element-identifier grammar belongs to epic sibling 900001; this checker does not import or enforce it. |
| `title` | no | string | `minLength: 1` |
| `extensions` | no | object | Open object (no constraint on its members); the only place for consumer-defined keys, following the discovery `extensions` convention |

Any other top-level key is rejected through `additionalProperties: false`.

### YAML parsing rules for the front-matter block

- A page has front matter when its first line is exactly `---`. The block ends at the next line
  that is exactly `---` or `...`. A UTF-8 byte-order mark is removed and CRLF is normalized to LF
  before matching.
- YAML is parsed with a `yaml.SafeLoader` subclass that (a) maps the `timestamp` tag to its source
  text, so an unquoted `last_reviewed: 2026-10-30` remains the string `"2026-10-30"`, and (b)
  rejects duplicate mapping keys.
- Validation uses `jsonschema.Draft202012Validator(schema).iter_errors(value)`.

### Canonical file and packaged copy

- Canonical schema: `schemas/docs/v1/page-metadata.schema.json`.
- Packaged copy: `packages/docs-page-check/src/drm_copilot_docs_check/_resources/page-metadata.schema.json`,
  byte-identical to the canonical file, read at runtime with
  `importlib.resources.files("drm_copilot_docs_check").joinpath("_resources", "page-metadata.schema.json").read_bytes()`.
  The runtime never reads `schemas/docs/v1/` from a working directory.
- The schema loader is injectable (`schema: Mapping[str, object] | None = None` on the front-matter
  validator); no module-level mutable cache is used (an `lru_cache` over immutable bytes is
  permitted).

## Finding-Code Catalog

Every finding has severity `error`, names the page path (repository-relative POSIX path), and
carries a 1-based line number counted in the original page including front matter. Page-level
findings use line `1`.

| Code | Trigger | Line | `related_path` | Message shape |
|---|---|---|---|---|
| `FRONT_MATTER_MISSING` | The first line (after BOM removal) is not exactly `---` | `1` | `null` | `<path>: front matter block is missing` |
| `FRONT_MATTER_MALFORMED` | Unterminated block, YAML syntax error, duplicate mapping key, or top-level value that is not a mapping | Line of the YAML error or duplicate key mapped to the page; `1` for an unterminated block or a non-mapping value | `null` | `<path>:<line>: front matter is malformed: <reason>` |
| `FRONT_MATTER_FIELD_MISSING` | A required field is absent; one finding per missing field (from the schema `required` validator) | `1` | `null` | `<path>: required front matter field '<field>' is missing` |
| `FRONT_MATTER_FIELD_INVALID` | Any other schema violation (type, enum, pattern, length, uniqueness, unknown key) or a `last_reviewed` value that matches the pattern but is not a valid calendar date; `<field>` is the top-level property name (for an unknown key, the key itself; one finding per unknown key) | `1` | `null` | `<path>: front matter field '<field>' is invalid: <validator message>` |
| `LINK_TARGET_MISSING` | A relative link target resolves to no page and no existing path, or resolves above the repository root | Line of the link | Resolved repository-relative target path, or `null` when it resolves above the root | `<path>:<line>: link target '<target>' does not exist` |
| `LINK_ANCHOR_MISSING` | A fragment matches no anchor in the target Markdown page (the current page for a fragment-only link) | Line of the link | Target page path | `<path>:<line>: anchor '#<fragment>' not found in '<target page>'` |
| `DIATAXIS_MODE_MISMATCH` | A Diataxis rule fails; one finding per failed rule | First offending line; `1` for `DX-STEPS` | `null` | `<path>:<line>: diataxis_mode '<mode>' violates <rule id>: <reason>` |
| `PAGE_ORPHANED` | The page is not reachable from any entry page | `1` | `null` | `<path>: page is not linked from any entry page` |

Interaction rules:

- `FRONT_MATTER_MISSING` and `FRONT_MATTER_MALFORMED` suppress field findings for that page.
- The Diataxis audit runs only on pages whose front matter parsed and whose `diataxis_mode` is
  valid; other pages receive no `DIATAXIS_MODE_MISMATCH`.
- Link, anchor, and orphan checks do not depend on front matter.
- Configuration errors are not findings (see Exit codes).

## Links, Anchors, and Slugs

### Link extraction

Outside fenced code blocks (backtick or tilde fences of three or more characters, indented up to
three spaces, closed by a fence of the same character and at least the same length), outside
inline code spans, and outside front matter:

- Inline links and images: `[text](target)` and `![alt](target)`.
- Reference definitions: `[label]: target`.

Skipped targets: targets with a URI scheme (`^[A-Za-z][A-Za-z0-9+.-]*:`), protocol-relative
targets beginning `//`, and empty targets. A target ending in a bare `#` is treated as having no
fragment.

### Resolution

- Split the fragment, percent-decode the path, and resolve against the page's directory with POSIX
  normalization (`PurePosixPath`; no drive letters, no backslash handling).
- A resolved path is satisfied when it is a key of the page mapping or when the injected predicate
  `path_exists(path: str) -> bool` returns true (non-page targets such as images or source files).
- A target that resolves to an existing directory is accepted. For reachability and anchors, a
  directory link resolves to `<dir>/README.md`, then `<dir>/index.md`, when either is a page.

### Anchors

The anchors of a page are the slugs of its ATX headings (`#` through `######`, closing `#`
sequence removed) and setext headings (`===` or `---` underline under a non-blank paragraph line;
front matter is stripped first), plus explicit `<a id="...">` and `<a name="...">` values. A
fragment-only link is checked against the current page; a fragment on a Markdown page target is
checked against that page; fragments on non-Markdown targets are not checked. Matching is exact
against the percent-decoded fragment.

### Slug algorithm (github-slugger)

1. Reduce inline markup to text: `[text](url)` becomes `text`, images become their alt text, HTML
   tags are removed.
2. Lowercase.
3. Remove every character except: Unicode letters (`L*`), marks (`M*`), decimal and letter numbers
   (`Nd`, `Nl`), connector punctuation (`Pc`, including `_`), the hyphen `-`, and the space.
   Symbol code points that carry the Unicode Alphabetic property (for example circled letters) are
   removed; this is a documented and accepted difference from github-slugger.
4. Replace each space with `-` without collapsing (`a  b` yields `a--b`).
5. De-duplicate per page in document order: the first occurrence keeps the base slug; later
   occurrences become `<base>-1`, `<base>-2`, and so on, skipping any value already taken.

## Diataxis Mode Rules

Signals are computed outside fenced code blocks and front matter:

- Ordered step: a line matching `^ {0,3}[0-9]{1,9}[.)] +\S`.
- Instructional heading: a heading whose text, case-insensitively, starts with `how to ` or
  matches `^step\s+[0-9]+\b`. These English prefixes are constants in `diataxis.py` and are
  documented in the package README.
- Generated block: a line containing `<!-- docs:generated:start id=`.

| Rule id | Applies to | Fails when |
|---|---|---|
| `DX-STEPS` | `tutorial`, `how-to` | The page has no ordered step |
| `DX-NO-INSTRUCTION` | `reference`, `explanation` | The page has an instructional heading |
| `DX-GENERATED-REFERENCE` | `tutorial`, `how-to`, `explanation` | The page has a generated block |

A generated reference page (`diataxis_mode: reference`, generated-block markers, no heading
beginning `How to` or `Step <n>`) passes all three rules. Cross-feature constraint: epic sibling
900006 must not emit headings that begin with `How to` or `Step <n>`.

Prose judgment is out of scope (epic non-goal); the rules check structure only.

## Orphan Detection and Configuration

### `CheckConfig` (frozen dataclass in `config.py`)

| Key | CLI flag | Default | Meaning |
|---|---|---|---|
| `root` | `--root` | `docs` | Repository-relative POSIX directory scanned for `*.md` pages |
| `entry_pages` | `--entry` (repeatable) | `("README.md", "index.md")` | Entry pages, relative to `root` |
| `exclude` | `--exclude` (repeatable) | `()` | Glob patterns matched with `fnmatch.fnmatchcase` against the page path relative to `root` |
| `output_format` | `--format` | `text` | `text` or `json` |

No configuration file is read in this feature (TOML is avoided because `tomllib` is unavailable on
Python 3.10).

### Entry-page validation

- When `--entry` is supplied, every supplied entry page must be in the page set; otherwise exit `2`.
- When the defaults apply, at least one default entry page must be in the page set; otherwise exit
  `2`. An empty page set therefore exits `2`.

### Reachability

Breadth-first search from the entry pages over resolved Markdown links between pages (fragments
ignored, directory links resolved as above), visiting neighbours in sorted order. Every page not
reached is reported as `PAGE_ORPHANED`. Entry pages are never orphans. Link cycles terminate.

## Inputs / Outputs

- Inputs: all `*.md` files under `--root` minus `--exclude`, read by `cli.py` into `dict[str, str]`
  (repository-relative POSIX keys, UTF-8, LF-normalized). Paths are relative to the working
  directory passed to the CLI (the repository root).
- Outputs: the report on stdout; configuration and usage errors on stderr.
- No environment variables are read.
- Versioning: `report_version` is `1.0.0`; the schema `$id` carries `1.0.0`. A breaking change to
  either requires a version change and an epic-level update.

## API / CLI Surface

### Command

```text
dev.docs.check [--root DIR] [--entry PATH ...] [--exclude GLOB ...] [--format text|json]
```

Python seams: `run_check(argv, *, stdout, stderr, read_tree, path_exists) -> int` performs the
work against injected ports; `main() -> int` is a thin wrapper that supplies the real file-system
`read_tree` and `path_exists`.

### Exit codes

| Code | Meaning |
|---|---|
| `0` | No findings |
| `1` | One or more findings |
| `2` | Usage or configuration error (argparse usage error, unreadable or missing root, missing entry page per the entry-page rules). No report is printed; stderr names the path. |

### Report ordering

Findings are sorted by the key `(path, line, code, related_path or "", message)`. Output order is
fully determined by this key, independent of check order and file-enumeration order.

### Text output

One line per finding: `<CODE> <message>` (the message already begins with `<path>` or
`<path>:<line>`; this refines the research's text shape to avoid repeating the location), followed
by one summary line: `dev.docs.check: <finding_count> finding(s) in <page_count> page(s)`.

### JSON output

Rendered as `json.dumps(report, sort_keys=True, indent=2, ensure_ascii=False) + "\n"` with LF line
endings, no timestamps, no absolute paths, and no host data:

```json
{
  "findings": [
    {
      "code": "LINK_ANCHOR_MISSING",
      "line": 12,
      "message": "docs/guide.md:12: anchor '#setup' not found in 'docs/reference.md'",
      "path": "docs/guide.md",
      "related_path": "docs/reference.md",
      "severity": "error"
    }
  ],
  "report_version": "1.0.0",
  "summary": {"codes": {"LINK_ANCHOR_MISSING": 1}, "finding_count": 1, "page_count": 3},
  "tool": "dev.docs.check"
}
```

Every finding object carries all six keys; `related_path` is `null` where not applicable.
`summary.codes` lists only codes with at least one finding.

## Data & State

- The checker is read-only: it writes no file and keeps no state between runs.
- Pure cores (`front_matter`, `links`, `diataxis`, `orphans`, `report`, and configuration parsing
  in `config`) accept in-memory `Mapping[str, str]` page sets and injected predicates; they never
  touch the file system. Only `cli.py` performs file I/O.
- No migration or backfill.

## Module Boundaries

Files (create), under `packages/docs-page-check/`:

- `pyproject.toml` (poetry-core backend; `name = "drm-copilot-docs-check"`; src layout
  `packages = [{ include = "drm_copilot_docs_check", from = "src" }]`;
  `include = ["src/drm_copilot_docs_check/py.typed"]`; script
  `"dev.docs.check" = "drm_copilot_docs_check.cli:main"`; dependencies `python = ">=3.10,<4.0"`,
  `PyYAML = ">=6.0"`, `jsonschema = "^4.25.1"` only)
- `README.md` (installation as a wheel, usage, finding codes, Diataxis heading prefixes, manual
  adoption of the base configuration)
- `src/drm_copilot_docs_check/__init__.py`, `py.typed`, `front_matter.py`, `links.py`,
  `diataxis.py`, `orphans.py`, `config.py`, `report.py`, `cli.py`
- `src/drm_copilot_docs_check/_resources/page-metadata.schema.json` (byte-identical copy)
- Permitted refinements: `markdown_scan.py` (shared fence-aware line classification used by
  `links.py`, `diataxis.py`, and `orphans.py`) and `anchors.py` (slug logic) if `links.py`
  approaches the 500-line guidance.

The package depends on no Markdown parser and on neither `drm_copilot_docs` nor
`drm_copilot_discovery`; it imports nothing from `scripts`.

## Implementation Strategy

### Research corrections to the epic file list

1. Edit `quality-tiers.yml`: add `path: "packages/docs-page-check"`, `tier: T2`, with a rationale.
   Without it the `tier-classification` CI stage reports `QT008` for an unclassified project.
2. Add `tests/docs_page_check/__init__.py`, so `tests/docs_page_check/test_cli.py` does not collide
   with epic sibling 900001's `tests/docs_runtime/test_cli.py` under pytest's default import mode.
3. Ship the byte-identical packaged schema copy under `src/drm_copilot_docs_check/_resources/`,
   read through `importlib.resources`, with a byte-identity test.
4. Root `pyproject.toml` edits (append-only, shared with sibling features):
   - `[tool.poetry.dependencies]`: `drm-copilot-docs-check = { path = "packages/docs-page-check", develop = true }`.
   - `[tool.poetry.scripts]`: `"dev.docs.check" = "drm_copilot_docs_check.cli:main"`, after
     `"dev.discovery.doctor"` and before `"dev.fix-all"`.
   - `[tool.coverage.run] source`: add `"packages/docs-page-check/src"`.
   - `[tool.pyright] include`: add `"packages/docs-page-check/src"`.
5. Regenerate `poetry.lock` with Poetry (local Poetry is 2.3.2) after the final `pyproject.toml`
   edit; commit the new directory package entry and `content-hash`. CI runs `poetry check --lock`.
6. Property tests use the repository's seeded, digest-driven generator pattern (`Draw` in
   `tests/discovery_runtime/test_t2_properties.py`) or permutation parametrization, not hypothesis,
   which is not an installed dependency.

### Base configuration content

- `.pymarkdown.json`: `extensions.front-matter.enabled: true` and a small `plugins` block (for
  example `md013` with `line_length` 100, `code_blocks` and `tables` false). PyMarkdown does not
  load `.pymarkdown.json` implicitly; the consumer runs `pymarkdown --config .pymarkdown.json scan <root>`.
- `.vale.ini`: `StylesPath = styles`, `MinAlertLevel = warning`, `Vocab = Project`, and `[*.md]`
  with `BasedOnStyles = Vale, DocsBase`. No `Packages` key.
- `styles/DocsBase/`: one YAML rule per file, domain-neutral (for example `HeadingPunctuation.yml`
  `existence` with `scope: heading`, `RepeatedWords.yml` `repetition`, `PlaceholderMarkers.yml`
  `existence` for `TODO`, `TBD`, `FIXME`). No `substitution` or `spelling` rule.
- `styles/config/vocabularies/Project/accept.txt`: zero bytes, consumer-owned.

### Tests (under `tests/docs_page_check/`)

`__init__.py`, `test_front_matter.py`, `test_links.py` (including slug cases), `test_diataxis.py`,
`test_diataxis_properties.py`, `test_orphans.py`, `test_report.py`, `test_cli.py`, and, as
permitted refinements, `test_config.py`, `test_package_contract.py` (dependency set, import
independence, schema byte identity), and `test_template_neutrality.py`.

- No test creates a temporary file. Pure cores receive in-memory mappings and
  `frozenset.__contains__` as `path_exists`; `test_cli.py` injects an in-memory `read_tree`. If the
  real reader is exercised, the `mem_fs_path` fixture in `tests/conftest.py` is used. Tests that
  read committed files write nothing.
- Edge cases: empty page set; BOM and CRLF input (built in memory); `---` not on line 1; `...`
  terminator; duplicate YAML keys; unquoted date; links inside fences and inline code;
  reference-style links; percent-encoded paths and fragments; links escaping the root; duplicate
  headings; setext headings; explicit `<a id>` anchors; self-links; link cycles; an entry page
  linking to a directory.
- Properties: slug determinism and per-page uniqueness; Diataxis verdict invariance under insertion
  of plain paragraph lines; generated-marker pages fail `DX-GENERATED-REFERENCE` for every
  non-reference mode; ordered lists inside fences never count; report bytes invariant under
  finding input permutation; orphan result invariant under page enumeration order.
- Isolation evidence: a reversed-order single-process run of the new test modules.
- Coverage evidence: `pytest --cov=drm_copilot_docs_check --cov-branch --cov-report=json:<path>`
  under `<FEATURE>/evidence/coverage/`.

- Dependency changes: one new local path dependency (`drm-copilot-docs-check`); the package itself
  uses only already-approved PyYAML and jsonschema.
- Logging/telemetry: none.
- Rollout: none beyond merge; consumers adopt by installing the wheel.

## Non-Goals

- No push-down command copies `resources/templates/docs-quality/` into a consumer repository in
  this feature. The package README documents manual adoption (copying the files, and that
  PyMarkdown needs `--config .pymarkdown.json`); automated delivery is left to a later epic child.
- No new push-down root and no pack-manifest registration for `resources/templates/docs-quality/`.
- Mechanical judgment of prose correctness (epic non-goal).
- Running PyMarkdown or Vale in this repository, or adopting them for this repository's own
  documentation.
- A wheel-build script for this package or a published distribution channel.
- Enforcement of the surface element-identifier grammar in `surface_refs`.
- Comparison of `last_reviewed` with the current date.

## Constraints & Risks

- Naming contract fixed by the epic: package path, import name, schema path, front-matter fields,
  console command, and template location may not change without an epic-level update.
- The downstream reference generator (epic sibling 900006) depends on the schema, the Diataxis
  heading constraint, and the finding codes; these are fixed once this feature merges.
- Tests must not create temporary files.
- Root `pyproject.toml`, `poetry.lock`, and `quality-tiers.yml` are shared, append-only edit points
  with epic sibling 900001; the second child to merge regenerates `poetry.lock` after taking the
  other's `pyproject.toml`.
- Epic sibling 900001's schema tests over `schemas/docs/v1/` must exempt
  `page-metadata.schema.json` from artifact-header assertions.
- CI-only behavior: POSIX paths only, no `tomllib`, no Python 3.11-only syntax.
- CI checks only coverage totals; per-module figures for `drm_copilot_docs_check` are recorded as
  evidence.

## Acceptance Criteria

- [ ] Missing or malformed front-matter fields, a broken relative link, a missing heading anchor, a Diataxis mode mismatch and an orphan page each produce a distinct finding code naming the file.
- [ ] `dev.docs.check` exits 0 on a clean page set and non-zero when any finding is present; JSON output ordering is deterministic.
- [ ] No consumer vocabulary or repository name ships in the base Vale style; vocabulary is a consumer-owned file.
- [ ] The package imports nothing from `drm_copilot_docs` (independent installability).
- [ ] Line coverage >= 85% and branch coverage >= 75% for `drm_copilot_docs_check`.
- [ ] `packages/docs-page-check/src/drm_copilot_docs_check/_resources/page-metadata.schema.json` is byte-identical to `schemas/docs/v1/page-metadata.schema.json`, asserted by a test that reads both committed files, and the runtime loads the schema through `importlib.resources`.
- [ ] `quality-tiers.yml` contains an entry with path `packages/docs-page-check` and tier `T2`, and `scripts.dev_tools.check_quality_tiers` exits 0.
- [ ] `poetry check --lock` exits 0 and `poetry.lock` contains a directory package entry for `packages/docs-page-check`.
- [ ] A test over the committed `extensions/drm-copilot/resources/templates/docs-quality/` tree asserts that `styles/config/vocabularies/Project/accept.txt` is zero bytes, that no file in the tree contains `drm-copilot` or any identifier on the test's banned-identifier list, and that no rule under `styles/DocsBase/` uses `extends: substitution` or `extends: spelling`.

## Open Questions and Assumptions (UNVERIFIED research items)

1. The form poetry-core writes into the root wheel's metadata for a `develop = true` path
   dependency, and whether `_build-check.yml`'s `pip install dist/*.whl` resolves it. Assumption:
   it follows the passing discovery-runtime precedent; confirm with the build-check result.
2. Resolved: local Poetry is 2.3.2, consistent with the lock's `lock-version = "2.1"`.
3. Whether vsce includes dotfiles under `resources/templates/docs-quality/` in the VSIX (inferred
   from other shipped dotfiles, not from vsce documentation).
4. Vale behavior with a zero-byte `accept.txt`, and whether `reject.txt` must exist for a named
   `Vocab`. If either fails, an empty `reject.txt` is shipped as well.
5. Whether PyMarkdown's `md033` (inline HTML) reports HTML comments such as the generated-block
   markers, and whether Vale skips YAML front matter in Markdown. Both affect only the base
   configuration, not the checker.
6. Epic sibling 900001's choice of the docs URN prefix and its schema test's iteration scope.
   Assumption: `urn:drm-copilot:docs:` and an exemption for `page-metadata.schema.json`.
7. Whether any consumer distribution channel for Python packages (published wheel, release asset)
   is planned beyond a local wheel build; the epic assigns this to 900001's research.
8. The epic assumptions A1 through A6 are provisional and not approved by the owner. This feature
   relies on A3 (no Markdown QC configuration on `main`; verified by research) and A5 (separate
   package placement, which matches the fixed naming contract).

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)

- [ ] Unit coverage areas: front matter, links, anchors, Diataxis rules, orphans, report ordering, CLI exit codes
- [ ] Integration scenarios: CLI over an injected in-memory page set
- [ ] CLI/API examples: `dev.docs.check` text and JSON output
