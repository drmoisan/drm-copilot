# docs-page-quality-checker (Issue #1021) - Research

- Timestamp: 2026-10-30T20-35
- Issue: #1021 (child of epic #1019, `documentation-estate-tooling`, wave 0, band C3)
- Branch: `feature/docs-page-quality-checker-1021`
- Requirements source: `docs/features/epics/documentation-estate-tooling/epic.md`
  (`## Shared Design`, `## Assumptions Pending Owner Confirmation`,
  `### 900002 - docs-page-quality-checker (wave 0, C3)`) and this folder's `issue.md`.
- Environment facts are taken from `.claude/skills/execution-environment/SKILL.md` and are cited
  by heading rather than restated.

The design is framework-native. The requirement was observed in one consumer repository; no source
from that repository is copied, and this artifact does not name it.

## 1. Current State Analysis

### 1.1 Path verification for the epic's 900002 file list

Verified with Glob against the worktree.

| Epic path | State |
|---|---|
| `packages/docs-page-check/` (all files) | Absent; to be created |
| `schemas/docs/v1/page-metadata.schema.json` | Absent; `schemas/docs/` does not exist (900001 creates its siblings) |
| `extensions/drm-copilot/resources/templates/docs-quality/` | Absent; to be created |
| `extensions/drm-copilot/resources/templates/` | Exists. Holds PowerShell wrappers (`run-poshqc-*.ps1`, `hello_pwsh.ps1`, and others) and one subdirectory `policy_audit/` |
| `tests/docs_page_check/` | Absent; to be created |
| Root `pyproject.toml`, `poetry.lock` | Exist |
| Root `.pymarkdown`, `.pymarkdown.json`, `.vale.ini`, `styles/`, `.markdownlint*` | Absent (assumption A3 confirmed) |
| `quality-tiers.yml` | Exists at the root (tier rules apply; see 2.4) |

### 1.2 Discovery runtime package (the precedent to mirror)

`packages/discovery-runtime/pyproject.toml`:
- Build backend `poetry.core.masonry.api` with `poetry-core>=1.9.0`.
- `[tool.poetry]` name `drm-copilot-discovery`, `packages = [{ include = "drm_copilot_discovery", from = "src" }]` (src layout), `include` lists `py.typed` and `_build_manifest.json`.
- `[tool.poetry.scripts]` declares every `dev.discovery.*` command against `drm_copilot_discovery.cli:main_*`.
- `[tool.poetry.dependencies]`: `python = ">=3.10,<4.0"`, `PyYAML = ">=6.0"`, `jsonschema = "^4.25.1"`, `referencing = ">=0.37,<0.38"`, `lxml = ">=5.3.0"`.
- `packages/discovery-runtime/README.md` (`## Installing`): consumers install a built wheel with `python -I -m pip install dist/discovery/drm_copilot_discovery-2.0.0-py3-none-any.whl`; the wheel is built by `scripts/dev_tools/build_discovery_runtime.py` (`build_wheel`, `stage_resources`), which is hard-coded to the discovery package (`PACKAGE_ROOT`, `RESOURCE_ROOTS`, `ALLOWLIST_PATH`) and is not reusable for another package without change.
- Schemas are staged into package data under `src/drm_copilot_discovery/_resources/` (listed in `packages/discovery-runtime/resource-manifest.json`) and read at runtime through `importlib.resources.files("drm_copilot_discovery")` (`_read_installed_bytes` and `RESOURCE_DIRECTORY = "_resources"` in `drm_copilot_discovery/resources.py`; `load_catalog` in `catalog.py`). The staged JSON files are not listed in `include`, so poetry-core packages them as ordinary package files.

Root `pyproject.toml` registration of the discovery runtime:
- `[tool.poetry.dependencies]`: `drm-copilot-discovery = { path = "packages/discovery-runtime", develop = true }`.
- `[tool.poetry.scripts]`: the same `"dev.discovery.<op>" = "drm_copilot_discovery.cli:main_<op>"` entries, quoted dotted names, alphabetically placed among the other `dev.*` aliases (after `dev.collect-commit-context`, before `dev.fix-all`).
- `[tool.coverage.run] source` includes `"packages/discovery-runtime/src"`.
- `[tool.pyright] include` includes `"packages/discovery-runtime/src"`; strict mode, `pythonVersion = "3.12"`, no `extraPaths`.
- `[tool.pytest.ini_options]`: `testpaths = ["tests"]`, `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`; no `pythonpath` or `--import-mode` setting. `tests/conftest.py` (`_ensure_repo_root_on_sys_path`) puts the repository root on `sys.path`.
- `[tool.black]` and `[tool.ruff]`: line length 88, target `py310`; Ruff and Black run over `.` in CI, so a new package is covered without configuration. `tests/**/*` ignores `S101`.
- `tests/discovery_runtime/test_package_contract.py` (`test_root_tooling_includes_the_local_runtime_for_types_and_coverage`) pins the discovery entries in the root `pyproject.toml` by line prefix `drm-copilot-discovery =`; an added `drm-copilot-docs-check =` line does not match that prefix.

`poetry.lock`: the discovery path dependency appears as a `[[package]]` entry with `[package.source] type = "directory"`, `url = "packages/discovery-runtime"`, `develop = true`, and its dependency table; `[metadata]` carries `lock-version = "2.1"` and a `content-hash`. Adding a path dependency therefore changes `poetry.lock` (a new package entry and a new `content-hash`). `.github/workflows/_quality-checks.yml` step `Verify poetry.lock is in sync` runs `poetry check --lock` and fails on any `git diff` of `poetry.lock`.

### 1.3 CI and registries a new package must join

- `quality-tiers.yml` exists. `scripts/dev_tools/quality_tiers_contract.py` (`discover_projects`, rule R1) treats the folder of every tracked `pyproject.toml` as a project, and `find_classification_errors` reports `QT008` for an unclassified project. The `tier-classification` step in `_quality-checks.yml` runs `scripts.dev_tools.check_quality_tiers`. A `packages/docs-page-check` entry is therefore required. The discovery runtime is T2 ("Reusable discovery artifact models, validation, and workflows installed in consuming repositories"); the page checker has the same profile and should be T2 (property test per pure function; mutation score trend-only).
- `_quality-checks.yml` `Run tests with Pytest` runs `poetry run pytest --cov --cov-branch` with the JSON report, and `Enforce Python coverage thresholds` checks only the report `totals` (`scripts/dev_tools/check_python_coverage_thresholds.py`, `find_threshold_breaches`). Per-module figures for `drm_copilot_docs_check` are evidence the plan must produce with `--cov=drm_copilot_docs_check` (execution-environment `## Coverage and File-Size Gates`).
- `_build-check.yml` runs `poetry build` and `pip install dist/*.whl` for the root project; the root wheel already carries the discovery path dependency, so a second path dependency follows an existing passing pattern (mechanism UNVERIFIED, see the UNVERIFIED list).
- There is no separate coverage configuration file; `[tool.coverage.run] source` is the only registry.

### 1.4 Consumer installation and the `templates/` tree

- Python packages are not shipped in the extension: `extensions/drm-copilot/.vscodeignore` excludes `**/*.py`, and `packages/mcp-server/prepack.cjs` (`shouldCopy`) skips every `.py` file. `extensions/drm-copilot/test/packaging/discovery-resources.test.ts` pins both exclusions and names the wheel file (`DISCOVERY_WHEEL_FILE_NAME` in `extensions/drm-copilot/src/discovery-runtime.ts`), whose user-facing messages instruct `python -I -m pip install <wheel>`. A consumer therefore installs a Python package from this repository as a wheel into its own interpreter, independent of this repository's Poetry environment.
- The push-down commands copy only three roots: `resources/customizations`, `resources/codex-and-agents-customizations`, and `resources/claude-customizations` (`pushDownCopilotCustomizationsServiceCall`, `pushDownCodexAndAgentsCustomizationsServiceCall`, `pushDownClaudeCustomizationsServiceCall` in `extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts`). `resources/templates/` is not a push-down root. Its files are used by named extension commands (for example `bundledRelativePath: "resources/templates/run-poshqc-format.ps1"` in `repo-automation-service-support.ts`) and by asset resolvers (`policy-audit-template-assets.ts`, MCP tool `resolve_policy_audit_template_asset`).
- The pack-manifest and resource-contract tests listed in execution-environment `## Contract Tests That Pin Mirrored Files` enumerate only the bundled `.claude`, `.agents`, and `.codex` trees (for example `enumerate_bundled_claude_relative_paths` in `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`). A new `templates/docs-quality/` subtree is not seen by them and needs no pack-manifest registration.
- Packaging: `.vscodeignore` has no pattern that reaches `resources/templates/` other than the Python patterns, and `prepack.cjs` copies every non-Python file, so `.pymarkdown.json`, `.vale.ini`, `.yml` rule files, and `.txt` vocabulary files are carried into the VSIX and the npm package. Dotfiles are already shipped from `resources/` (for example `claude-dir-customizations/.mcp.json`, `claude-customizations/.claude/settings.json`, asserted present by `SETUP_RESOURCES` in `discovery-resources.test.ts`). Whether vsce's glob includes dotfiles is inferred from those shipped files, not from vsce documentation (UNVERIFIED).
- Scans that will read the new subtree: `test_pushed_roots_carry_no_hard_coded_solution_file` in `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` scans every file under `extensions/drm-copilot/resources` for a pinned solution-file name; generic content passes it.
- Conclusion: in 900002 the template files are delivered as bundled resources only. No existing command copies them into a consumer repository. A delivery command (MCP tool or CLI) is not in 900002's file list; it belongs to a later child (900007 or 900010) or is documented as a manual copy in `packages/docs-page-check/README.md`. The planner should record this as an explicit non-goal of 900002 rather than add a push-down root.

### 1.5 Approved libraries

From `poetry.lock` and the two `pyproject.toml` files:
- PyYAML 6.0.3 (root main dependency and discovery runtime dependency).
- jsonschema 4.26.0 (root dev group `^4.25.1`; discovery runtime dependency `^4.25.1`); referencing 0.37.0.
- markdown-it-py 4.0.0 is present in the lock only as a transitive dependency (not declared by either `pyproject.toml`); `markdown` 3.10.1 is optional. Neither is an approved direct dependency.
- No front-matter library (for example `python-frontmatter`) is present.
- hypothesis is not installed: it appears in `poetry.lock` only inside the `test` extras of other packages. Property tests in this repository use digest-driven generators (`Draw` in `tests/discovery_runtime/test_t2_properties.py`) or exhaustive `itertools.permutations` parametrization (`tests/discovery_runtime/test_package_contract.py`).

Decision: `drm-copilot-docs-check` depends on `PyYAML = ">=6.0"` and `jsonschema = "^4.25.1"` only (the discovery runtime's pins), and does not depend on `drm-copilot-discovery` or on any Markdown parser. Markdown structure is read with a small line-oriented scanner, which is sufficient for headings, fences, lists, links, and HTML comments.

### 1.6 Discovery schema conventions (`schemas/discovery/v2/`)

Verified in `evidence-reference.schema.json` and by a count of `$schema`/`$id`/`additionalProperties` keys across all 29 v2 schemas:
- `"$schema": "https://json-schema.org/draft/2020-12/schema"`.
- `"$id"` is a URN: `urn:drm-copilot:discovery:2.0.0:<kind>`.
- Objects are closed with `"additionalProperties": false`; consumer data goes into an `extensions` property (`common#/$defs/extensions`).
- Artifact documents carry `$schema`, `schema_version`, and `artifact_kind` header properties.
- Validation uses `Draft202012Validator` with a local `referencing` registry and a restricted `FormatChecker` (`_validator`, `discovery_format_checker` in `drm_copilot_discovery/schema_validation.py`); schema errors project to findings with code `SCHEMA_INVALID` and an RFC 6901 pointer (`_add_schema_errors`).
- Schema tests live under `tests/schemas/discovery/` with shared helpers (`v2_schema_test_support.py`) that load schemas from the repository path.

## 2. Recommended Approach

### 2.1 Package layout and registration

Create `packages/docs-page-check/` mirroring the discovery runtime's layout:

- `pyproject.toml`: poetry-core backend; `name = "drm-copilot-docs-check"`; version chosen by the planner (for example `0.1.0`); `packages = [{ include = "drm_copilot_docs_check", from = "src" }]`; `include = ["src/drm_copilot_docs_check/py.typed"]`; `[tool.poetry.scripts] "dev.docs.check" = "drm_copilot_docs_check.cli:main"`; dependencies `python = ">=3.10,<4.0"`, `PyYAML = ">=6.0"`, `jsonschema = "^4.25.1"`.
- `src/drm_copilot_docs_check/`: `__init__.py`, `py.typed`, `front_matter.py`, `links.py`, `diataxis.py`, `orphans.py`, `config.py`, `report.py`, `cli.py`, and `_resources/page-metadata.schema.json` (2.2). A small shared `markdown_scan.py` (fence-aware line classification used by `links.py`, `diataxis.py`, and `orphans.py`) is a permitted refinement under the epic's "research may refine file names" rule; it avoids triplicated fence handling.
- Root `pyproject.toml` edits (append-only, shared with 900001):
  1. `[tool.poetry.dependencies]`: `drm-copilot-docs-check = { path = "packages/docs-page-check", develop = true }`.
  2. `[tool.poetry.scripts]`: `"dev.docs.check" = "drm_copilot_docs_check.cli:main"`, placed after `"dev.discovery.doctor"` and before `"dev.fix-all"` (alphabetical order).
  3. `[tool.coverage.run] source`: add `"packages/docs-page-check/src"`.
  4. `[tool.pyright] include`: add `"packages/docs-page-check/src"`.
- `quality-tiers.yml`: add `path: "packages/docs-page-check"`, `tier: T2`, with a rationale. This edit is not in the epic's 900002 file list and is required to keep `tier-classification` green (QT008). 900001 must add `packages/docs-runtime` to the same file, so it is a third append-only shared edit point.
- `poetry.lock`: regenerate with Poetry after the root edit; commit the new directory package entry and `content-hash`.
- Console entry pattern: follow `drm_copilot_discovery.cli` (`run_cli(...)` takes argv, streams, and injected ports and returns an exit code; `main_*()` is a thin wrapper). For the checker: `run_check(argv, *, stdout, stderr, read_tree) -> int` plus `main() -> int`.

Exit codes: `0` no findings; `1` one or more findings; `2` usage or configuration error (argparse's default for usage errors, and a missing configured entry page).

### 2.2 Schema location strategy

Recommended: canonical file plus a byte-identical package-data copy.
- Author the canonical schema at `schemas/docs/v1/page-metadata.schema.json` (naming contract).
- Ship a byte-identical copy at `packages/docs-page-check/src/drm_copilot_docs_check/_resources/page-metadata.schema.json`, read at runtime with `importlib.resources.files("drm_copilot_docs_check").joinpath("_resources", "page-metadata.schema.json").read_bytes()`, the same mechanism as `drm_copilot_discovery.resources`. This works in a consumer's interpreter after a wheel install and does not read the consumer's checkout.
- A parity test reads both committed files and asserts equal bytes (reading committed repository files is an established pattern, for example `test_runtime_metadata_has_bounded_dependencies_and_minimum_python`).
- The schema must be self-contained: no `$ref` into `schemas/discovery/v2/common.schema.json` or into any docs schema owned by 900001, because neither is installed with this package.
- The loader is injectable: `validate_front_matter(..., schema: Mapping[str, object] | None = None)`; tests pass an in-memory schema or the loaded package resource.

Rejected alternatives:
- Embedding the schema as a Python literal: a second, unpinned copy that can drift from the canonical file.
- Reading `schemas/docs/v1/` from the working directory: the consumer repository does not contain it.
- Reusing `scripts/dev_tools/build_discovery_runtime.py` staging: it is hard-coded to the discovery package; generalizing it is outside 900002's scope.

### 2.3 Page-metadata schema

Following 1.6:
- `"$schema": "https://json-schema.org/draft/2020-12/schema"`, `"$id": "urn:drm-copilot:docs:1.0.0:page-metadata"` (URN prefix to be confirmed with 900001 so both children use the same `docs` namespace).
- `type: object`, `additionalProperties: false`, `required: ["owner", "last_reviewed", "audience", "diataxis_mode", "surface_refs"]`.
- Properties:
  - `owner`: string, `minLength: 1`, pattern rejecting leading or trailing whitespace.
  - `last_reviewed`: string, pattern `^[0-9]{4}-[0-9]{2}-[0-9]{2}$`. Calendar validity is checked in Python with `datetime.date.fromisoformat`; no comparison with the current date (no clock dependency).
  - `audience`: array of identifier strings (`^[a-z0-9][a-z0-9-]*$`), `minItems: 1`, `uniqueItems: true`.
  - `diataxis_mode`: `enum: ["tutorial", "how-to", "reference", "explanation"]`.
  - `surface_refs`: array of non-empty, whitespace-free strings, `uniqueItems: true`, may be empty (narrative pages bind no element). The element-identifier grammar belongs to 900001; the checker does not import it.
  - Optional `title` (string) and `extensions` (object) so a consumer can add keys without breaking the closed object, matching the `extensions` convention.
- The front matter is page metadata, not an artifact document, so it carries no `$schema`/`schema_version`/`artifact_kind` header. If 900001's planned `tests/schemas/docs_schemas/test_docs_schemas_v1.py` iterates every `schemas/docs/v1/*.schema.json` and asserts artifact headers, it must exempt this schema; record this in both plans.

### 2.4 Front-matter parsing

- A page has front matter when its first line is exactly `---`; the block ends at the next line that is exactly `---` (or `...`). Byte-order mark and CRLF are normalized before matching.
- YAML is parsed with a `yaml.SafeLoader` subclass that (a) maps the `timestamp` tag to its source text, so an unquoted `last_reviewed: 2026-10-30` remains a string instead of a `datetime.date`, and (b) rejects duplicate mapping keys. `drm_copilot_discovery.parsing._DiscoveryLoader` shows the same concern (it excludes timestamp construction); the checker reimplements the minimum rather than importing discovery.
- Validation uses `jsonschema.Draft202012Validator(schema).iter_errors(value)`; each error yields one finding (2.6). A missing required field is detected from the `required` validator and reported as its own code, separate from other violations.

### 2.5 Links, anchors, and slugs

Link extraction (outside fenced code blocks and inline code spans): inline links and images `[text](target)` / `![alt](target)`, and reference definitions `[label]: target`. Skipped: targets with a URI scheme (`^[A-Za-z][A-Za-z0-9+.-]*:`), protocol-relative `//` targets, and empty targets.

Resolution: split the fragment, percent-decode the path, resolve against the page's directory with POSIX normalization. The pure core receives the page mapping (`Mapping[str, str]`, repository-relative POSIX paths) plus an injected predicate `path_exists(path: str) -> bool` for non-page targets such as images or source files; tests pass `frozenset.__contains__`. A target that resolves to a directory is accepted when it exists; for reachability, a directory link resolves to `<dir>/README.md`, then `<dir>/index.md`, when either is a page.

Anchors of a page: the slugs of its ATX headings (`#` to `######`, closing `#` sequence removed) and setext headings (`===`/`---` underline; front matter is stripped first), plus explicit `<a id="...">` and `<a name="...">` values. A fragment-only link is checked against the current page; a fragment on a Markdown page target is checked against that page; fragments on non-Markdown targets are not checked. Matching is exact against the percent-decoded fragment.

Slug algorithm (github-slugger, which states it generates slugs "just like GitHub does for markdown headings"; source `index.js` and `script/generate-regex.js` in `Flet/github-slugger`):
1. Reduce inline markup to text: `[text](url)` becomes `text`, images become their alt text, HTML tags are removed.
2. Lowercase.
3. Remove every character except: alphabetic characters (Unicode categories `L*`), marks (`M*`), decimal and letter numbers (`Nd`, `Nl`), connector punctuation (`Pc`, which includes `_`), the hyphen `-`, and the space. github-slugger's generated regex removes Other_Number, all other punctuation (including dashes other than `-`), symbols, controls, private use, format, unassigned, and separators other than space; the category test above is its Python equivalent, except for the few symbol code points that carry the Unicode Alphabetic property (for example circled letters), which this implementation removes. That difference is documented and accepted.
4. Replace each space with `-` (no collapsing; `a  b` yields `a--b`).
5. De-duplicate per page in document order: the first occurrence keeps the base slug; later occurrences of the same base become `<base>-1`, `<base>-2`, and so on, skipping any value already taken (github-slugger `occurrences` loop).

### 2.6 Finding-code catalog

Codes follow the repository's UPPER_SNAKE convention (`SCHEMA_INVALID` in `drm_copilot_discovery.schema_validation`). Every finding has severity `error`, names the page path, and names the line (1-based, counted in the original page including front matter; `1` for page-level findings).

| Code | Trigger | Message shape |
|---|---|---|
| `FRONT_MATTER_MISSING` | First line is not `---` | `<path>: front matter block is missing` |
| `FRONT_MATTER_MALFORMED` | Unterminated block, YAML syntax error, duplicate key, or top-level value not a mapping | `<path>:<line>: front matter is malformed: <reason>` |
| `FRONT_MATTER_FIELD_MISSING` | A required field is absent (one finding per field) | `<path>: required front matter field '<field>' is missing` |
| `FRONT_MATTER_FIELD_INVALID` | Any other schema violation (type, enum, pattern, unknown key) or an invalid calendar date in `last_reviewed` | `<path>: front matter field '<field>' is invalid: <validator message>` |
| `LINK_TARGET_MISSING` | Relative link target does not exist | `<path>:<line>: link target '<target>' does not exist` |
| `LINK_ANCHOR_MISSING` | Fragment matches no anchor in the target page | `<path>:<line>: anchor '#<fragment>' not found in '<target page>'` |
| `DIATAXIS_MODE_MISMATCH` | A rule in 2.7 fails (one finding per failed rule) | `<path>:<line>: diataxis_mode '<mode>' violates <rule id>: <reason>` |
| `PAGE_ORPHANED` | Page is not reachable from any entry page (2.8) | `<path>: page is not linked from any entry page` |

The Diataxis audit and orphan check run only on pages whose front matter parsed; a page with no valid `diataxis_mode` receives no `DIATAXIS_MODE_MISMATCH` (its front-matter finding already fails the run). Link and orphan checks do not depend on front matter.

Configuration errors (a configured entry page that is not in the page set, an unreadable root) are not findings; they print a message naming the path and exit `2`.

### 2.7 Diataxis mode rules

The four modes sit on two axes (Diataxis compass, `diataxis.fr/compass/`): tutorial (action, acquisition), how-to (action, application), reference (cognition, application), explanation (cognition, acquisition). A lexical checker can observe only structure, so the rule set checks structural signals that the Diataxis pages tie to each mode. Prose judgment stays with the reviewer role (epic `## Non-Goals`).

Signals (all computed outside fenced code blocks and front matter):
- Ordered step: a line matching `^ {0,3}[0-9]{1,9}[.)] +\S`.
- Instructional heading: a heading whose text, case-insensitively, starts with `how to ` or matches `^step\s+[0-9]+\b`.
- Generated block: a line containing `<!-- docs:generated:start id=` (epic naming contract).

| Rule | Applies to | Fails when | Justification |
|---|---|---|---|
| `DX-STEPS` | `tutorial`, `how-to` | The page has no ordered step | Diataxis how-to: "The fundamental structure of a how-to guide is a sequence."; tutorials: "Every step the learner follows should produce a comprehensible result." |
| `DX-NO-INSTRUCTION` | `reference`, `explanation` | The page has an instructional heading | Diataxis reference: "reference should not attempt to show how to perform tasks"; explanation: "you're not giving instruction or describing facts." |
| `DX-GENERATED-REFERENCE` | `tutorial`, `how-to`, `explanation` | The page has a generated block | Generated blocks hold reference material ("structure of the documentation should mirror the structure of the product"); the epic's generator (900006) emits them only on `diataxis_mode: reference` pages. |

A generated reference page (`diataxis_mode: reference`, marker blocks, no headings beginning `How to` or `Step N`) passes all three rules. 900006 must not emit headings that begin with `How to` or `Step <n>`; record this as a cross-feature constraint. The heading prefixes are English; they are constants in `diataxis.py` and documented in the package README.

### 2.8 Orphan detection and `config.py`

- `config.py` defines a frozen `CheckConfig`: `root` (repository-relative POSIX directory, default `docs`), `entry_pages` (tuple of root-relative paths, default `("README.md", "index.md")`), `exclude` (tuple of glob patterns, default empty). Values come from CLI flags `--root`, `--entry` (repeatable), `--exclude` (repeatable), and `--format text|json`. A config file is not needed for 900002, and TOML is avoided because `tomllib` is unavailable on Python 3.10.
- Roots are the configured entry pages; at least one must be present in the page set, otherwise exit `2`.
- Reachability is a breadth-first search over resolved Markdown links between pages (fragments ignored, directory links resolved as in 2.5), visiting neighbours in sorted order. Every page not reached is `PAGE_ORPHANED`. Entry pages are never orphans.

### 2.9 Report shape and ordering

- Ordering key: `(path, line, code, related_path or "", message)`, analogous to `finding_key` in `drm_copilot_discovery.findings`.
- Text output: one line per finding, `<path>:<line>: <CODE> <message>`, followed by a summary line.
- JSON output: `json.dumps(report, sort_keys=True, indent=2, ensure_ascii=False) + "\n"` with LF endings, no timestamps, no absolute paths, no host data:

```json
{
  "findings": [
    {"code": "LINK_ANCHOR_MISSING", "line": 12, "message": "...", "path": "docs/guide.md",
     "related_path": "docs/reference.md", "severity": "error"}
  ],
  "report_version": "1.0.0",
  "summary": {"codes": {"LINK_ANCHOR_MISSING": 1}, "finding_count": 1, "page_count": 3},
  "tool": "dev.docs.check"
}
```

Paths are relative to the working directory passed to the CLI (repository root).

### 2.10 Base configuration under `templates/docs-quality/`

- `.pymarkdown.json`: a JSON object with `extensions.front-matter.enabled: true` (pages carry YAML front matter) and a small `plugins` block, for example `md013` with `line_length` 100 and `code_blocks`/`tables` false. PyMarkdown implicitly loads `.pymarkdown`, `.pymarkdown.yml`/`.yaml`, and `pyproject.toml` from the current directory, not `.pymarkdown.json`; the consumer runs `pymarkdown --config .pymarkdown.json scan <root>` (PyMarkdown advanced configuration page). The README must state this. Rule identifiers accept both the id and alias (`md013`, `line-length`; rule page `rule_md013`).
- `.vale.ini`: `StylesPath = styles`, `MinAlertLevel = warning`, `Vocab = Project`, and `[*.md]` with `BasedOnStyles = Vale, DocsBase`. No `Packages` key, so `vale sync` downloads nothing. Keys and semantics: Vale `.vale.ini` reference (`StylesPath` relative to the config file and must exist; `MinAlertLevel` is `suggestion`, `warning`, or `error`; each `Vocab` must exist under `config/vocabularies`).
- `styles/DocsBase/`: one YAML rule per file (`extends`, `message`, optional `level`; Vale styles page), domain-neutral, for example `DocsBase/HeadingPunctuation.yml` (`existence`, `scope: heading`), `DocsBase/RepeatedWords.yml` (`repetition`), `DocsBase/PlaceholderMarkers.yml` (`existence` for `TODO`, `TBD`, `FIXME`). No `substitution` or `spelling` rule carries product or organization terms.
- `styles/config/vocabularies/Project/accept.txt`: zero bytes, consumer-owned. Vale 3 stores vocabularies at `<StylesPath>/config/vocabularies/<name>/` with `accept.txt` and `reject.txt`; versions before 3.0 used `<StylesPath>/Vocab` (Vale vocabularies page). The base ships the Vale 3 layout only.

## 3. Behavior Semantics

- Input: all `*.md` files under `--root` minus `--exclude`, read by the CLI into `dict[str, str]` (repository-relative POSIX keys, UTF-8, normalized LF). The pure cores accept that mapping and never touch the file system.
- Success: no findings, exit `0`. Failure: at least one finding, exit `1`. Usage or configuration error: exit `2`, no report.
- Order of checks per page: front matter, then links and anchors, then Diataxis (only with valid front matter); orphans run over the whole set. The output order is fully determined by the ordering key, not by check order or file enumeration order.
- Edge cases to cover: empty page set (exit `2`, no entry page); BOM and CRLF input; front matter `---` not on line 1; `...` terminator; duplicate YAML keys; unquoted date; links inside fences and inline code; reference-style links; percent-encoded paths and fragments; links escaping the root (checked through `path_exists`); duplicate headings (`-1`, `-2`); setext headings; explicit `<a id>` anchors; self-links; link cycles in orphan search; an entry page linking to a directory.

## 4. Requirements Mapping

| Acceptance criterion | Design element | Proving tests |
|---|---|---|
| Distinct finding code per condition, naming the file | Catalog in 2.6 | `test_front_matter.py`, `test_links.py`, `test_diataxis.py`, `test_orphans.py` (one test per code asserting code and path) |
| Exit 0 clean, non-zero with findings; deterministic JSON | 2.1 exit codes, 2.9 | `test_cli.py` (injected `read_tree`, captured streams), `test_report.py` (permutation invariance of finding input order) |
| No consumer vocabulary or repository name in the base style | 2.10 | A neutrality test reading the committed `templates/docs-quality/` tree: `accept.txt` is zero bytes; no file contains `drm-copilot` or any identifier from the banned-identifier list pattern used by `_BANNED_SUBSTRINGS` in `tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py` (the planner selects the list) |
| Imports nothing from `drm_copilot_docs` | 2.1 dependency set | AST import scan over `src/drm_copilot_docs_check/*.py` (pattern of `test_canonical_modules_do_not_import_repository_tooling`) rejecting `drm_copilot_docs`, `drm_copilot_discovery`, and `scripts`; a `pyproject.toml` dependency-set assertion (pattern of `test_runtime_metadata_has_bounded_dependencies_and_minimum_python`) |
| Line >= 85%, branch >= 75% | All modules | `pytest --cov=drm_copilot_docs_check --cov-branch --cov-report=json:<path>` read from the JSON report |

Files (create), refined from the epic list: the package files in 2.1; `schemas/docs/v1/page-metadata.schema.json`; the `_resources` copy; the template files in 2.10; tests in section 5. Files (edit): root `pyproject.toml`, `poetry.lock`, `quality-tiers.yml`.

## Numeric Derivation Evidence

No approved `spec.md` acceptance criterion in this feature states a count, enumeration, or population derived from the repository; the only figures are the 85% line and 75% branch coverage thresholds, which are policy values, not derived counts. The finding-code catalog in 2.6 is a design choice, not a measured population. This research therefore proposes no numeric assertion for an acceptance criterion, and recommends that the plan refer to finding codes by name rather than by count.

- Complete Family: not applicable; no numeric claim is proposed.
- Exhaustive Search Scope: not applicable.
- Inclusion Rules: not applicable.
- Exclusion Rules: not applicable.
- Primary Search Strategy or Query Expression: not applicable.
- Primary Member Set: not applicable.
- Primary Count: not applicable.
- Cross-check Search Strategy or Query Expression: not applicable.
- Cross-check Member Set: not applicable.
- Cross-check Count: not applicable.
- Member-set Comparison: not applicable; any later numeric criterion requires a new derivation.

## 5. Testing Implications

- Location: `tests/docs_page_check/` (mirrors the package name; matches the epic). Add `tests/docs_page_check/__init__.py`. Without it, pytest's default `prepend` import mode imports `tests/docs_page_check/test_cli.py` as top-level module `test_cli`, and 900001's planned `tests/docs_runtime/test_cli.py` would import under the same name and fail collection. Existing `test_cli.py` files are inside packages (`tests/scripts/dev_tools/atomic_executor/__init__.py`, `tests/scripts/dev_tools/discovery/analyzer/__init__.py`), so they do not collide today. 900001 should add `tests/docs_runtime/__init__.py` as well.
- Planned modules: `test_front_matter.py`, `test_links.py` (including slug cases), `test_diataxis.py`, `test_diataxis_properties.py`, `test_orphans.py`, `test_report.py`, `test_cli.py`, plus `test_config.py`, `test_package_contract.py` (dependency set, import independence, schema byte parity), and `test_template_neutrality.py`. If the planner prefers the epic's exact list, the last three may be folded into `test_cli.py` and `test_report.py`; separate modules keep each under the 500-line guidance.
- Property tests (T2 requires at least one per pure function): use the digest-driven `Draw` pattern from `tests/discovery_runtime/test_t2_properties.py` or permutation parametrization. hypothesis is not installed, and adding it is a dependency change requiring approval. Properties: slug determinism and per-page uniqueness; Diataxis verdict invariance under insertion of plain paragraph lines; generated-marker pages fail `DX-GENERATED-REFERENCE` for every non-reference mode; ordered lists inside fences never count; report bytes invariant under finding input permutation; orphan result invariant under page enumeration order.
- No temporary files. Pure cores take `Mapping[str, str]` and an injected `path_exists`. The CLI's tree reader is an injected seam (`read_tree`); `test_cli.py` passes an in-memory reader. If a test must exercise the real reader, use the `mem_fs_path` fixture in `tests/conftest.py`. Tests that read committed files (schema parity, template neutrality, pyproject contract) read only and write nothing.
- Isolation evidence: a reversed-order single-process run of the new Python test modules (execution-environment `## Test Isolation Checks`).

## Pre-Mortem

- Review checklists: a reviewer can fail the work on an unclassified project (QT008), a missing `poetry.lock` refresh, or a schema that `$ref`s discovery or 900001 schemas. Mitigation: the plan carries explicit tasks for the `quality-tiers.yml` entry, the lock refresh, and a self-contained schema with a byte-parity test.
- Coverage: CI checks only report totals, so a weak module can hide behind the repository total. Mitigation: the plan records per-module line and branch figures from `--cov=drm_copilot_docs_check --cov-branch --cov-report=json:<path>`; the thin `main()` wrapper is the only code not driven through `run_check`, and the CLI's real tree reader is covered through `mem_fs_path`.
- Mirror parity: not applicable for agent and skill mirrors. No `.claude`, `.agents`, `.codex`, or `.github` customization file changes, and `templates/` is outside the pack-manifest and resource-contract tests. The execution-environment brief states no fact this feature changes (no CI job, required context, tool route, or batch-budget rule changes), so no brief update is needed. The schema `_resources` copy is the only mirrored pair, and the parity test covers it.
- File size: modules with rule logic (`links.py`, `front_matter.py`) can grow past 500 lines. Mitigation: the shared fence-aware scanner lives in its own module, slug logic can be split into `anchors.py` if needed, and each test module stays under 500 lines.
- Test isolation: module-level schema caching or `sys.modules` changes can leak between tests. Mitigation: load the schema through an injectable function with no global mutable cache (or an `lru_cache` over immutable bytes only); record a reversed-order run. The package `__init__.py` in `tests/docs_page_check/` prevents the basename collision with 900001.
- CI-only behavior: Linux path handling and the Python 3.10 leg. Mitigation: POSIX paths only (`PurePosixPath`, no drive letters, no backslash literals), no `tomllib`, no 3.11-only syntax, LF-normalized fixtures (the `* text=auto eol=lf` rule makes committed CRLF fixtures LF, so CRLF cases are built in memory). The `Verify poetry.lock is in sync` step fails if the lock is regenerated before the final `pyproject.toml` edit; regenerate last.
- Evidence: per-module coverage and test counts must come from the JSON report and JUnit or terminal output, not from PoshQC MCP results (which carry no output). Command artifacts go under `<FEATURE>/evidence/<kind>/` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`, with no absolute paths. More than three production Python files are created, so execution needs a non-terminal `large`, `remediation`, or `preparation` route checkpoint in the item worktree, or the fourth file is denied with `PYTHON_LARGE_PATH_REQUIRED` (execution-environment `## Batch Budget`).

## Cross-Feature Conflict and Ordering Risks

- Root `pyproject.toml`: 900001 adds `drm-copilot-docs = { path = "packages/docs-runtime", develop = true }` beside this feature's dependency line, and `dev.docs.init` / `dev.docs.validate-profile` beside `dev.docs.check` (all sort between `dev.discovery.doctor` and `dev.fix-all`), plus `packages/docs-runtime/src` in `coverage.run.source` and `pyright.include`. Both children edit adjacent lines in four places, so a textual merge conflict is likely. Resolution: keep both entries in sorted order.
- `poetry.lock`: both children change `content-hash` and add a directory package. A merged lock cannot be produced by hand; the second child to merge regenerates the lock after taking the other's `pyproject.toml`.
- `quality-tiers.yml`: both children append a `packages/...` entry; this file is not listed in the epic's `### Cross-feature conflict surface` and should be added there.
- `tests/<dir>/test_cli.py` basename collision: resolved by an `__init__.py` in each new test directory (section 5).
- 900001's schema tests over `schemas/docs/v1/` must exempt `page-metadata.schema.json` from artifact-header assertions (2.3).
- 900006 depends on the field shapes in 2.3, the Diataxis constraint in 2.7, and the finding codes in 2.6; these should be treated as fixed once 900002 merges.

## Automation Feasibility

Every step can run without human interaction: package and schema creation, root registry edits, lock regeneration (`poetry lock` in the item worktree), tests, coverage, and evidence capture. Neither PyMarkdown nor Vale is a dependency of this repository; the base configuration files are static data, and no step runs either tool. No credential, external service, or manual approval is required beyond the normal pull-request flow.

## UNVERIFIED Items (for the orchestrator)

1. The exact form poetry-core writes into the root wheel's metadata for a `develop = true` path dependency, and whether `_build-check.yml`'s `pip install dist/*.whl` resolves it. The discovery path dependency is the precedent; confirm with the latest `_build-check.yml` result on `main`.
2. The Poetry version used locally for `poetry lock` (the lock carries `lock-version = "2.1"`, consistent with Poetry 2; the CI hint text names the Poetry 1 flag `--no-update`).
3. That vsce includes dotfiles under `resources/templates/docs-quality/` in the VSIX (inferred from other shipped dotfiles, not from vsce documentation).
4. Vale behavior with a zero-byte `accept.txt`, and whether `reject.txt` must exist for a named `Vocab` (the Vale vocabularies page does not say). If either fails, ship an empty `reject.txt` as well.
5. Whether PyMarkdown's `md033` (inline HTML) reports HTML comments such as the generated-block markers, and whether Vale skips YAML front matter in Markdown; both affect only the base configuration, not the checker.
6. 900001's choices for the docs URN prefix and for its schema test's iteration scope (2.3), which are not yet planned on this branch.
7. Whether any consumer distribution channel (published wheel, release asset) for Python packages is planned beyond the local wheel-build path; the epic assigns this to 900001's research.
