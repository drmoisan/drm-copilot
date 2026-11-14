# docs-surface-analyzer-python-native (#1031) - Research

- Issue: #1031 (epic #1019 child 900011, wave 2, band C3)
- Branch: `feature/docs-surface-analyzer-python-native-1031` (cut from the epic integration branch)
- Mode: preparation (planning only; no code written)
- Timestamp: 2026-10-30T22-48 (UTC; read from a network UTC time source because the
  task-researcher role has no shell; see `## Automation Feasibility`)
- Requirements sources read in full: `docs/features/epics/documentation-estate-tooling/epic.md`;
  `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md` (v0.3);
  `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/spec.md` (v0.1, still
  the withdrawn Python design); the 1031 `spec.md`, `issue.md`, `user-story.md` and the template
  `plan.2026-10-30T18-38.md`.

## 1. Current State (verified on this branch)

- `.claude/lib/docs/` does not exist yet. No `DocsAnalyzerRegistry.psm1`, `DocsSurface.psm1` or
  `Invoke-DocsCommand.ps1` is on the branch; every 1020 contract below is taken from the 1020 spec
  text, not from code.
- No `.py` file exists under `.claude/`, `.codex/`, `.agents/` or
  `extensions/drm-copilot/resources/` (Glob `{.claude,.codex,.agents,extensions/drm-copilot/resources}/**/*.py`
  returned nothing). The 900011 helper would be the first Python file in any push-down payload.
- The 1020 spec (v0.3, last updated 2026-10-30T22-15) has not yet absorbed the D3/D5 amendment
  listed in the epic `### Amendment of 1020 required by D3 and D5`: its registry anchors are
  `# --- 900003 ---` and `# --- 900004 ---` (no 900011 anchor), the element shape has no
  `analysis_method`, the digest rule is not defined, and `#### Exit codes and the -Json envelope`
  still says "The envelope has no schema file" (the epic `### PowerShell contracts` bullet repeats
  this, contradicting D5). These are recorded under `## 9. Conflicts`.

## 2. Pack Layout and Push-down Contracts (question 1)

### 2.1 Manifests

- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/python.json` is
  `{name, label, paths[]}` and lists eight `.claude`-relative paths (rules, one agent, two hooks,
  three skills). No pack lists a lib file except `core.json`, which lists every `.claude/lib/**`
  entry (85 matches of `.claude/lib/` in core, none in other Claude manifests).
- The manifest loader (`_parse_manifest` in `scripts/dev_tools/push_down_claude_pack_selection.py`)
  accepts any string path; nothing restricts a pack to agents, rules, hooks and skills. `python.json`
  can therefore list `.claude/lib/docs/python/...` files.
- Manifests are not disjoint: `.claude/hooks/check-python-test-purity.ps1` and
  `.claude/hooks/enforce-python-batch-budget.ps1` are listed in both `core.json` (lines 28 and 71)
  and `python.json`. No test asserts disjointness or that core contains no Python.
- Codex: `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/python.json`
  lists only `.agents/skills/*` and `.codex/agents/*.toml`; Codex libs are published only through
  `VIRTUAL_RESOURCE_DIRECTORIES` (`lib/discovery-validation` only) and `VIRTUAL_RESOURCE_PAIRS` in
  `scripts/dev_tools/push_down_codex_and_agents_customizations.py`. With 1020 OQ-2 (docs lib in the
  Claude bundle only), no Codex manifest edit is needed for 900011.
- `compute_published_paths` returns `None` for an empty selection, which publishes the full tree.
  "Only the python pack ships the helper" holds for a pack-scoped push-down only; a push-down without
  `--packs` publishes the helper to every destination (owner question OQ-D).

### 2.2 Contract tests and what they cover

| Test | Coverage relevant to a Python helper |
|---|---|
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` | Walks every file under repo `.claude/` (`rglob`, no extension filter) minus `agent-memory`, `state`, `worktrees`, `settings.local.json` (`tests/scripts/dev_tools/claude_payload_scope_test_support.py`) and requires an equal-text bundle copy. Covers `.py`. Also sees any `__pycache__/*.pyc` created under `.claude/lib/docs/python/` by a test import and fails ("Repo file missing from bundle"). |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` | Enumerates only `agents/*.md`, `hooks/*`, `skills/*/SKILL.md`; does not cover libs. |
| `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` | Also walks `lib/**` recursively with no extension filter (the TypeScript twin); the helper must appear in some manifest (union semantics). |
| `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | Scans only manifested `.ps1`/`.psm1` sources (`POWERSHELL_SUFFIXES`) and hook command text. Any literal `Join-Path ... $PSScriptRoot ... '<child>'` in a scanned source, including a data file (form F7 in `tests/scripts/dev_tools/pack_manifest_dependency_scan.py`), must resolve inside core plus the owning pack. Python files are not scanned as sources. |
| `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py::test_every_psscriptroot_occurrence_is_recognized` | Any `$PSScriptRoot` spelling outside the named forms fails. |
| 1020 planned `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` (spec AC) | "every file under `.claude/lib/docs/` (PowerShell and data, recursively) is listed exactly once in ... `core.json`". A helper under `.claude/lib/docs/python/` that is listed only in `python.json` fails this test as written (conflict C-3). |

Consequence for the adapter: a core module that names the helper through
`Join-Path -Path $PSScriptRoot -ChildPath 'python/...'` makes
`test_claude_manifest_powershell_dependency_closure` fail (the target is outside core), and any
non-literal `$PSScriptRoot` spelling fails the recognition test. The adapter must locate the helper
without `$PSScriptRoot` (section 6.3).

### 2.3 Distributable packaging (not named in the delegation; found during verification)

- `extensions/drm-copilot/.vscodeignore` contains `**/*.py` (and `**/__pycache__/**`, `**/*.pyc`,
  `**/*.pyo`), so the VSIX built by vsce drops every `.py` file under `resources/`.
- `packages/mcp-server/prepack.cjs` `shouldCopy` rejects every path ending in `.py` ("the standalone
  MCP server must not ship any `.py` file").
- `extensions/drm-copilot/test/packaging/discovery-resources.test.ts`
  (`keeps the explicit Python-source exclusion in both distributables`, `excludes no published
  discovery resource from the VSIX`) pins both rules.
- Push-downs served by the installed extension write the installed payload
  (execution-environment brief, `## MCP Surfaces Run the Installed Extension`). Without a carve-out
  the helper exists in the repository bundle but never reaches a destination through an installed
  extension or the npm MCP package. This reverses a deliberate repository invariant, so it is an
  owner question (OQ-B), not a decision.

### 2.4 Decision: helper location

Recommended: a Python package under `.claude/lib/docs/python/`, listed only in the Claude
`python.json` and mirrored byte-identically under
`extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/python/`:

- `.claude/lib/docs/python/run_docs_python_native.py` - entry script (thin: inserts its own
  directory at `sys.path[0]`, imports the package, calls `main`).
- `.claude/lib/docs/python/docs_python_native/__init__.py` and modules split by concern, each below
  the 500-line guidance: `protocol.py` (request parsing, response building, limits),
  `imports.py` (per-module alias table and relative-import resolution), `cli.py`, `routes.py` (not
  `http.py`, to avoid a stdlib name), `public_api.py`, `architecture.py`.

Rationale: the epic places the helper "under the docs lib"; `quality-tiers.yml` rule R4
(`scripts/dev_tools/quality_tiers_contract.py`: "every `.claude/lib/<name>` folder") discovers
`.claude/lib/docs` as one project, so no new tier entry is needed; a dedicated `python/` folder gives
the python pack whole-directory ownership, which a manifest test can assert simply.

Rejected alternatives: `.claude/lib/docs-python/` (avoids the 1020 manifest-test amendment but adds
a separately discovered `quality-tiers.yml` project and departs from the epic wording); a single-file
helper (the four analyzers exceed the 800-line hard limit; section 7); a non-`.py` extension to dodge
the packaging exclusion (Black, Ruff, Pyright and Pytest select by `.py`, so the helper would leave
the Python gates required by D3).

## 3. Python Gates (question 2)

Verified configuration (`pyproject.toml`, `poetry.lock`, `.github/workflows/_quality-checks.yml`):

| Gate | Current behavior for `.claude/lib/docs/python/**` | Minimal change |
|---|---|---|
| Black 26.1.0 (`poetry run black --check .`) | Default exclusions do not include `.claude`; `.gitignore` is respected (`.claude/worktrees`, `.claude/agent-memory`, `.claude/state/` only). The helper and its bundle copy are formatted-checked. | none |
| Ruff 0.15.12 (`poetry run ruff check`) | Default `exclude` list (fetched from the Ruff settings page) has no `.claude`; `respect-gitignore` is true. Helper and bundle copy are linted with rules E, F, I, B, UP, S, TID, TCH. | none |
| Pyright 1.1.409 (`poetry run pyright`, strict) | `include` is `scripts`, `src`, `packages/discovery-runtime/src`, `tests`; the helper is checked only when a test imports it. The 1.1.409 documentation states the `**/.*` default exclusion applies only when no `exclude` is given; this `pyproject.toml` gives one, so an included dot-path is analyzed. The current upstream documentation states the defaults are additive and take precedence over `include` (with a `useDefaultExcludes` switch). | add `.claude/lib/docs/python` to `include` and to a top-level `extraPaths` (tests import the package by name) |
| Pytest 9.0.2 (`testpaths = ["tests"]`) | The package is not importable from tests. | add `pythonpath = [".claude/lib/docs/python"]` to `[tool.pytest.ini_options]` |
| Coverage 7.13.2 / pytest-cov 7.0.0 (CI `pytest --cov --cov-branch`, then `check_python_coverage_thresholds` on JSON `totals` only, `--min-line 85 --min-branch 75`) | `[tool.coverage.run] source` is `src`, `scripts/dev_tools`, `packages/discovery-runtime/src`; the helper is not measured in CI. | add `.claude/lib/docs/python` to `source` |

- Dotted module forms for per-file evidence (the brief requires the dotted form; a `.py` path
  measures nothing): `--cov=docs_python_native` (whole package), `--cov=docs_python_native.cli`
  and siblings per module, `--cov=run_docs_python_native` for the entry. These resolve because the
  package directory is on `sys.path` through `pythonpath`; coverage matches executed frames by module
  `__name__` for non-directory sources. The CI threshold step checks repository totals only, so the
  per-file 85/75 figures must be recorded by the executor from the JSON report.
- `[tool.coverage.report] exclude_lines` already excludes `if __name__ == .__main__.:`; the entry
  script's guard line is not counted.
- Import route for tests: normal `import docs_python_native...` through `pythonpath` and Pyright
  `extraPaths`. Rejected: `importlib.util.spec_from_file_location` by path (Pyright strict reports
  unknown member types on a `ModuleType`, and the module would need manual `sys.modules`
  registration for `--cov=` name matching).
- Bytecode: importing the package from tests writes `.claude/lib/docs/python/docs_python_native/__pycache__/`,
  which the resource-contract test's `rglob` then reports as a repository file missing from the
  bundle, in CI as well as locally whenever the helper tests run before the contract test in the same
  process. Mitigation: a `conftest.py` in the helper's test directory sets
  `sys.dont_write_bytecode = True` before the test modules import the package, and the adapter starts
  the helper with `-B`. The 1020 manifest test (amended per C-3) skips `__pycache__` defensively.
- Existing pins on `pyproject.toml` text: `tests/scripts/dev_tools/test_pyright_config_alignment.py`
  (requires `reportMissingTypeArgument = "error"` and the `"drm-copilot",` exclude line),
  `tests/scripts/dev_tools/test_ruff_config_alignment.py` (no fix mode, `show-fixes = true`),
  `tests/discovery_runtime/test_package_contract.py` (discovery source in coverage and Pyright
  sections). The proposed edits are additive and keep all of them green.
- Test location: tests mirror production (`.claude/rules/general-unit-test.md`); the Pester
  convention maps `.claude/lib/` to `tests/scripts/claude-lib/`, so the Python tests go under
  `tests/scripts/claude-lib/docs/python/` (`test_docs_python_native_<area>.py`). That directory has
  no `__init__.py`; pytest's default prepend import mode imports each test by basename, so basenames
  must be unique (`tests/__init__.py` does not exist; existing test packages use their own
  `__init__.py`).
- Test purity: `.claude/hooks/check-python-test-purity.ps1` forbids `tempfile`, `subprocess`,
  `os.system`, `os.popen`, `time.sleep`, sockets and network clients in tests. Helper tests call pure
  functions and `main(stdin=..., stdout=...)` with `io.BytesIO`; no process is started.
- Property tests: no `hypothesis` dependency exists; existing property tests use seeded
  `random.Random` with a per-file Ruff `S311` ignore in `pyproject.toml`. T3 does not require
  property tests (`.claude/rules/quality-tiers.md`); seeded generators are optional.

## 4. PowerShell Side (question 3)

### 4.1 1020 contracts (spec text; files not yet on the branch)

- Registry form: `$script:DocsAnalyzerRow = @( # --- 900003 ... --- # --- 900004 ... --- )`, one
  row per line: `[pscustomobject]@{ Id; Version; ElementKinds; Module = (Join-Path -Path $PSScriptRoot
  -ChildPath 'DocsAnalyzer<Name>.psm1'); Function = 'Invoke-DocsAnalyzer<Name>' }`.
  `Test-DocsAnalyzerRegistration` rejects a duplicate `Id`, a `Module` leaf outside
  `DocsAnalyzer*.psm1` or outside `.claude/lib/docs/`, and a `Function` outside
  `^Invoke-DocsAnalyzer[A-Za-z]+$`.
- Analyzer contract: `Invoke-DocsAnalyzer<Name> -CapturedInput <object[]> -Selection <object>`
  returns `@{ Elements; Diagnostics }`, "pure, deterministic, no I/O". `Invoke-DocsAnalyzer` imports
  through an `-ImportModule` seam, validates kinds, `analyzer_id` equal to `Id`, and recomputed
  identifiers.
- Identities: `Get-DocsElementId -Kind -Path -Declaration` = `<kind>-` + lowercase hex SHA-256 of
  `ConvertTo-DocsCanonicalJson ([ordered]@{kind; path; declaration})` (delegating to
  `ConvertTo-DiscoveryCanonicalJson`, trailing LF). Declaration validation: non-blank, no
  leading/trailing whitespace, no C0 controls, no unpaired surrogate; no Unicode normalization.
- Command context (built only by `New-DocsCommandContext` in `Invoke-DocsCommand.ps1`):
  `RepositoryRoot`, `ReadText`, `ReadBytes`, `TestFile`, `ListFile`, `WriteText`, `UtcNow`; the only
  write primitive is `Write-DocsFileText`. "No filesystem, clock or process access outside the
  command context." There is no process member.
- Dispatch: `[scriptblock]`-typed parameters declared in the same file, because the guard below
  rejects `&` through a non-seam variable.
- `analysis_method` and the declaration-lines digest are required by the epic amendment but absent
  from the spec.

### 4.2 The Python-invocation guard (critical constraint)

`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` with
`EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` scans every `.ps1`/`.psm1` under
`.claude/hooks`, `.claude/lib` (excluding `.claude/lib/bash`) and `.codex/hooks`. Detection
(`Get-PythonInvocationFinding` in `EnforcementHooksNoPythonInvocation.Helpers.ps1`, AST-based):
(1) a constant command `python`, `python3`, `py` or `poetry` in any form, including inside a
`[scriptblock]` default value; (2) `Start-Process` targeting one of those names; (3) `&` on a
non-`[scriptblock]`-parameter variable or an expression (fail-closed); (4) `Invoke-Expression`/`iex`.
The allowlist (`EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1`) is empty, a test
(`ships an empty allowlist`) asserts it stays empty, and its policy text says entries "may be added
ONLY by an explicit owner decision recorded in the feature specification".

Verified gap: the detector inspects `CommandAst` nodes only. A
`[System.Diagnostics.ProcessStartInfo]::new($fileName)` plus `[System.Diagnostics.Process]::Start(...)`
call whose file name is a resolved interpreter path is not detected (the existing hook
`Invoke-DocsOnlyBoundedNative` in `.claude/hooks/hook-docs-only-diff.ps1` uses exactly this shape for
`git`/`gh`). Using that shape to start Python from `.claude/lib/docs/` would pass the test while
contradicting its stated purpose ("no hook or hook library invokes a Python interpreter on any
path"). D3 approves the analyzer, but it does not state that a `.claude/lib` PowerShell file may
start an interpreter. This is owner question OQ-A; research does not decide it.

### 4.3 Recommended adapter mechanics (subject to OQ-A)

- Process access through the command context (1020 amendment C-1): `ResolveApplication`
  (`param($Name)`; `Get-Command -CommandType Application`, first match path or `$null`) and
  `InvokeProcess` (`param($FileName, $ArgumentList, $StandardInputText, $TimeoutMilliseconds)`;
  `ProcessStartInfo` with `ArgumentList`, `UseShellExecute = $false`, redirected stdin/stdout/stderr,
  UTF-8 encodings, `WorkingDirectory = RepositoryRoot`, asynchronous reads, kill on timeout; returns
  `@{ ExitCode; Stdout; Stderr; TimedOut; StartError }`). Precedent for the bounded shape and the
  `[scriptblock] $ProcessStarter` seam: `Invoke-DocsOnlyBoundedNative` (hook-docs-only-diff.ps1);
  precedent for writing stdin then closing it: `Start-CodexChildProcess` in
  `.codex/scripts/launch-epic-child-wave.ps1`.
- Pester tests pass an in-memory context whose `ResolveApplication` and `InvokeProcess` are
  test-local scriptblocks returning canned results; no process starts and no file is written
  (`Start-Process`, `New-TemporaryFile`, `GetTempPath`, `$env:TEMP` are forbidden by
  `.claude/hooks/check-powershell-test-purity.ps1`).
- Pack detection: `Context.TestFile('.claude/lib/docs/python/run_docs_python_native.py')`
  (repository-root relative, consistent with 1020's rule that the root is never derived from
  `$PSScriptRoot`; avoids the closure failure in section 2.2). Absence means "python pack not
  installed" and yields the scanner path.
- Interpreter discovery: candidates in order `python3`, `python`, `py` (the last with leading
  argument `-3`), held as string data in the adapter; each resolved path is tried in turn. Arguments:
  `-I` (isolated: ignores `PYTHON*` variables and user site, and keeps the working directory and
  script directory off `sys.path`, so a planted module in the destination cannot shadow the helper's
  imports), `-B` (no bytecode), `-X utf8`, then the helper's relative path. The entry script inserts
  only its own directory into `sys.path`. A Windows Store alias stub (non-zero exit, no output) is
  treated like any failed candidate.
- Version floor: the helper checks `sys.version_info >= (3, 10)` first and otherwise writes a
  protocol error and exits with a dedicated code; any non-zero exit, timeout, start error or invalid
  output moves to the next candidate, and when none succeeds the scanner runs.
- Output validation: a pure `Test-DocsPythonNativeResponse` function checks the closed key set,
  `protocol_version`, that every path was in the request, analyzer identifiers and element kinds
  within the four native analyzers' kinds, `1 <= start <= end <= line count`, declaration grammar
  (through `Get-DocsElementId`, which throws `DOCS_IDENTITY_INPUT_INVALID`), and a size bound on
  stdout. Any failure discards the whole native result. A dedicated JSON schema file is not
  recommended: it would need a `Get-DocsSchemaName` anchor that 1020 does not provide.

## 5. Canonical JSON and Identifier Parity (question 4)

Comparison of `ConvertTo-DiscoveryCanonicalJson` (`.claude/lib/discovery-validation/DiscoveryEncoding.psm1`)
with `json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False) + "\n"`:

| Aspect | PowerShell | Python | Effect on element identity |
|---|---|---|---|
| Key order | `[StringComparer]::Ordinal` (UTF-16 code units) | code-point order | none: the identity object's keys are the ASCII names `declaration`, `kind`, `path` |
| String escaping | `"`, `\`, `\b \f \n \r \t`, other C0 as lowercase `\u00xx`; all else literal | same set with `ensure_ascii=False`, lowercase hex | equal for valid input |
| Lone surrogates | rejected before hashing by `Get-DocsElementId` | `json.dumps` emits them; UTF-8 encode then fails | must be rejected on both sides |
| Numbers | safe integers only | arbitrary | not used in the identity object |
| Trailing LF | appended | must be appended explicitly | must match |

Decision: the helper emits raw facts only; the PowerShell adapter computes every `element_id`
(`Get-DocsElementId`), every `parent_id`, and every declaration-lines digest with the same functions
the 1022 scanner uses. This keeps one implementation of the identity and digest rules (the D5/1020
rule lives only in PowerShell), removes the key-order and surrogate differences above from the
correctness path, and lets `Invoke-DocsAnalyzer`'s existing identifier re-verification apply
unchanged. Rejected: the helper computes identifiers in Python (a second implementation of the
identity rule that must be kept byte-identical by test only).

Transport: the helper reads `sys.stdin.buffer` and decodes UTF-8 explicitly, and writes
`json.dumps(..., ensure_ascii=True, sort_keys=True, separators=(",", ":"))` to `sys.stdout.buffer`.
ASCII-only stdout is independent of console code pages; System.Text.Json restores the code points.
The adapter strips a leading U+FEFF before sending text (`ast.parse` of a string beginning with U+FEFF
is a syntax error; unverified on each version, so a test pins the stripped form).

Proposed request (adapter to helper): `{protocol_version: 1, analyzers: [...], source_roots: [...],
files: [{path, text}], console_scripts: [{name, table, path, target}], limits: {...}}`. Proposed
response: `{protocol_version: 1, python_version: "x.y.z", files: [{path, status, elements: [{analyzer_id,
kind, declaration, name, parent: {kind, declaration} | null, line_start, line_end, properties:
[{name, value}]}], diagnostics: [{analyzer_id, code, line, blocking}]}]}`. `parent` is a
`(kind, declaration)` pair; the adapter derives `parent_id` with the element path.

## 6. Python `ast` Mapping (question 5)

Design source: the withdrawn 1022 spec v0.1 `## Behavior` already specifies `ast`-based rules
(alias tables, tracked receivers, explicit work lists, D9 dynamic-form diagnostics, D11 Typer
naming). They are language-independent semantics and apply to the native helper; identifiers and
kinds come from the epic `### Analyzer decisions from the first preparation of 1022`.

| Analyzer id | Native coverage (`.py` inputs only) | Left to the scanner |
|---|---|---|
| `python-cli` | argparse (`ArgumentParser`, `add_subparsers`, nested `add_parser`, `add_argument` long/short/positional, argument groups), Click (`command`/`group`, tracked group decorators, `add_command`, `option`/`argument`), Typer (`Typer`, `command`, `callback`, `add_typer`, `run`, `Option`/`Argument` defaults and `Annotated[...]`) | console-script tables `[project.scripts]`, `[project.gui-scripts]`, `[tool.poetry.scripts]` (TOML). `tomllib` exists only from 3.11, so native TOML parsing would make results depend on the consumer interpreter. The adapter passes the scanner's console-script entries in `console_scripts` so the helper attaches a root to its script element as the 1022 rules require. |
| `python-http` | FastAPI and Flask decorators, `api_route`/`add_api_route`/`add_url_rule`, `include_router`/`register_blueprint` prefix composition across modules through the import table, `<dynamic>` prefix rule | none |
| `python-public-api` | literal `__all__` forms (assign, annotated, `+=`, `extend`, `append`), naming rule over top-level `def`/`async def`/`class`/assignment targets including `if`/`try` bodies | none |
| `python-architecture` | packages and modules from `.py` paths, `Import`/`ImportFrom` edges at any depth with relative-import resolution | `requirements*.txt`, `setup.cfg` and `pyproject.toml` dependency declarations (non-Python inputs) |

Constructs a lexical scanner typically reports as diagnostics and `ast` classifies (final list to
be taken from 1022's diagnostic catalogue once its PowerShell design is published): calls and
decorators spanning several lines or with nested brackets; implicit string concatenation of
literals; `from x import y as z` aliases and tracked receivers across assignments; keyword
arguments in any order; `Annotated[...]` Typer parameters; conditional definitions; look-alike text
inside strings or comments (scanner false positives); relative imports.

Python version floor for the helper (consumer interpreter): 3.10, equal to the repository floor
(`python = ">=3.10,<4.0"`) and the lowest CI matrix entry (3.10-3.13), so CI proves it. Avoid:
`tomllib` (3.11), `ast.TryStar` (3.11) and `ast.TypeAlias`/type-parameter nodes (3.12) by name
(walk generically with `ast.iter_child_nodes`), `match` statements in helper code are allowed
(3.10). Pyright runs with `pythonVersion = "3.12"`, so a 3.11+ API is caught only by the 3.10 CI
job's tests; coverage of every branch is the mitigation. Per-file parse handling: catch
`SyntaxError`, `ValueError` (null bytes on 3.10/3.11), `RecursionError` and `MemoryError`; suppress
`SyntaxWarning`/`DeprecationWarning` from `ast.parse` with `warnings.catch_warnings()` so stderr stays
empty. A file written in newer syntax than the consumer interpreter accepts fails to parse on that
host only; it is reported per file and handled by the per-file fallback in section 8.

## 7. Reuse, File Size, Batch Budget, Tier (questions 6 and 7)

- Reuse (PowerShell): `Get-DiscoveryBytesSha256Hex`, `Get-DiscoverySha256Hex`,
  `ConvertTo-DiscoveryCanonicalJson` (through 1020's `DocsJson.psm1` wrappers);
  `Get-DocsElementId`, `New-DocsSurfaceElement`, `New-DocsDiagnostic`, `ConvertFrom-DocsJsonText`
  (1020); the 1022 scanner analyzer functions for fallback; the `[scriptblock]` seam and bounded
  process shape of `Invoke-DocsOnlyBoundedNative` (`.claude/hooks/hook-docs-only-diff.ps1`) and
  `Read-HookPayload`'s `-ReadStandardInput` seam (`.claude/lib/hook-payload/HookPayload.psm1`).
  `.claude/lib/mermaid/` offers nothing directly reusable for the native path (its line scanner is a
  pattern for the 1022 scanner, not for the adapter).
- File size: four analyzers plus protocol and import resolution in one Python file would exceed the
  800-line hard limit; the package split in section 2.4 keeps each module below 500. The adapter
  (detection, request building, response validation, merge) is expected below 500 lines; if response
  validation grows, split it into `DocsPythonNativeProtocol.psm1` (a second core module).
- Batch budget: production files are about seven Python files plus seven bundle copies, and two to
  three PowerShell files plus copies plus the registry edit; both exceed the direct-mode cap of three
  per kind (`.claude/hooks/enforce-python-batch-budget.ps1`, `enforce-powershell-batch-budget.ps1`).
  Execution runs in the item worktree under a `large`/`preparation` checkpoint (epic rule).
- Tier: `.claude/lib/docs` gets one T3 entry from 1020; R4 discovers only `.claude/lib/<name>`, so
  `.claude/lib/docs/python` needs no entry, and adding one would raise QT007 (not a discovered
  project) because no `pyproject.toml`/`package.json` marker exists there. Do not add a
  `pyproject.toml` to the helper folder (R1 would make it a separate project).

## 8. Behavior Semantics and Requirements Mapping

- Selection: `inventory` (1022) asks the native provider for the selected subset of the four
  analyzer identifiers. `config-files` and non-`.py` inputs always use the scanner.
- Process-level failure (pack absent, no usable interpreter, version below floor, timeout, non-zero
  exit, invalid output): the whole native request is discarded, the scanner runs for the four
  identifiers, every element records `analysis_method: scanner`, exit code is unaffected, and one
  non-blocking diagnostic names the reason (`DOCS_PYTHON_NATIVE_UNAVAILABLE` with a fixed reason
  token; pack absence may be silent if the planner prefers). Note: 1020's `New-DocsDiagnostic` maps
  non-blocking to `warning`; an `information` severity exists in the schema but has no constructor
  path (conflict C-6).
- File-level parse failure: that file's elements come from the scanner (`analysis_method: scanner`)
  and the native result is kept for the others; cross-module prefix composition that depended on the
  failed file follows the 1022 `<dynamic>` rule.
- Elements carry the scanner analyzer identifier (`python-cli` and so on), not a separate native
  identifier, so registry validation (`analyzer_id` equal to `Id`) and ledger joins are unchanged;
  `analysis_method` distinguishes the method.
- Parity rule: for every construct both methods classify, kind, path, declaration, `line_range`,
  identifier and digest are equal; the native set may add elements where the scanner emits a
  diagnostic.
- Registry integration (contract C-2): a separate native-provider table under a 900011 anchor in
  `DocsAnalyzerRegistry.psm1`, for example
  `[pscustomobject]@{ Language = 'python'; AnalyzerIds = @('python-cli','python-http','python-public-api','python-architecture'); Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerPythonNative.psm1'); Function = 'Invoke-DocsAnalyzerPythonNative' }`.
  A second row in `$script:DocsAnalyzerRow` with the same `Id` is rejected as a duplicate, and the
  pure analyzer contract has no context for process access, so the native path cannot be an
  ordinary analyzer row. The provider function takes `-CapturedInput -Selection -Context` and
  returns `@{ Available; Reason; Elements; Diagnostics; ScannerPaths }`; `inventory` runs the scanner
  rows for `ScannerPaths` or for everything when `Available` is false.

## 9. Conflicts Found (for the coordinator)

- C-1: 1020's command context has no process or command-resolution member and forbids process
  access outside it. 900011 needs `ResolveApplication` and `InvokeProcess` added by the 1020
  amendment (or an explicitly assigned 900011 edit to `New-DocsCommandContext`).
- C-2: 1020's registry has no 900011 anchor (amendment pending) and no native-provider table; a
  duplicate `Id` is rejected. Proposed shape in section 8.
- C-3: 1020's `Docs.Manifest.Tests.ps1` AC requires every `.claude/lib/docs/**` file in `core.json`.
  Amend to: files under `.claude/lib/docs/python/` are listed in `python.json` and not in `core.json`;
  `__pycache__` is skipped; all other files stay in `core.json`.
- C-4: the declaration-lines digest is undefined in 1020 and in the current 1022 text (the 1023
  research recommends "the bytes of `line_range` lines"). One PowerShell function (proposed
  `Get-DocsDeclarationDigest -Text -LineRange` in `DocsSurface.psm1`) must be shared by scanner and
  adapter, with: line splitting on `\r\n`, `\n` and `\r` only (Python's `ast` line numbering; not
  `str.splitlines`, which also splits on `\v`, `\f`, `\x1c`-`\x1e`, U+0085, U+2028, U+2029), the
  selected lines joined with LF and no trailing terminator, SHA-256 of the UTF-8 bytes. Normalizing
  line endings keeps pins valid across CRLF and LF checkouts.
- C-5: per-kind `line_range` rules (decorator or call node versus `def` line; signature-only versus
  whole body for `public-symbol`) must be fixed by 1022 and mirrored by 900011; a digest over a whole
  function body would mark pages stale on any implementation edit, contrary to D5's intent.
- C-6: 1020 `New-DocsDiagnostic` cannot produce `information` severity although the schema allows it.
- C-7: the epic `### PowerShell contracts` bullet and 1020 spec say the `-Json` envelope has no
  schema; D5 says it gets one. Not a 900011 decision; 900011 follows whichever 1020 amendment lands.
- C-8: the 1022 spec and plan on this branch still describe the withdrawn Python package
  (`packages/docs-runtime`, `dev.docs.inventory`, `tests/docs_runtime/`); identifiers, kinds and
  ownership were taken from the epic instead. 900011's fixtures depend on 1022 publishing a shared
  expected-declarations fixture (section 11).

## 10. Owner Questions (no decision taken)

- OQ-A - Python invocation from `.claude/lib`. The guard suite forbids interpreter invocation from
  every `.claude/lib` PowerShell file and keeps an empty allowlist that only an owner decision may
  change. Options: (1) owner confirms D3 covers the adapter; a single named function in the docs lib
  starts the interpreter with a constant command form, one allowlist entry
  `@{ Path = '<adapter or entry file>'; Function = '<function>' }` is added with a D3 citation in the
  1031 spec, and the `ships an empty allowlist` test is changed to assert exactly that entry;
  (2) owner confirms D3 and the generic `InvokeProcess` context member is used (not detected by the
  guard), with a new guard test that pins the only interpreter-name string data to the adapter file
  and the guard header updated to record the D3 exception; (3) the scan root excludes
  `.claude/lib/docs/` (weakens the guard for all docs modules; not recommended). Research leans to
  (2) because it keeps timeouts and stdin handling in one bounded runner and makes the exception
  explicit, but the choice is the owner's.
- OQ-B - Distributable Python exclusion. `.vscodeignore` (`**/*.py`) and `prepack.cjs` `shouldCopy`
  drop every `.py` file, and `discovery-resources.test.ts` pins that. Options: (1) a narrow carve-out
  for `resources/claude-customizations/.claude/lib/docs/python/**/*.py` in both distributables, with
  the packaging test updated to assert the carve-out and the exclusion of every other `.py`;
  (2) no carve-out: the helper reaches a destination only through a repository-side push-down, never
  through the installed extension or npm package (the native analyzer would be effectively absent for
  extension users). Recommendation: (1).
- OQ-C - Host-dependent inventory. With `auto` selection, a host with the python pack and an
  interpreter inventories more elements than a host without them; a ledger written on one host can
  then fail `docs-complete` on the other (orphan or missing entries). Options: (1) an `inventory`
  option `-AnalysisMethod auto|native|scanner` (default `auto`), where `native` fails closed (exit 3)
  when unavailable, so a consumer CI can pin the method; (2) a profile field fixing the method (a 1020
  schema change); (3) accept host dependence and rely on the recorded `analysis_method`.
  Recommendation: (1), which touches only 1022's `inventory` row options.
- OQ-D - Full-tree push-down. A push-down without a pack selection publishes the helper to every
  destination. Options: accept (the adapter still requires an interpreter, and the helper is inert
  without one) or exclude `.claude/lib/docs/python/` from the default full-tree publish (a change in
  the push-down engines). Recommendation: accept and document.

## 11. Testing Implications

- Python (pytest, under `tests/scripts/claude-lib/docs/python/`): per-analyzer tests over in-memory
  source strings (argparse, Click, Typer, FastAPI, Flask, `__all__` forms, naming rule, import edges,
  relative imports, dynamic forms yielding diagnostics); protocol tests (`main` with `io.BytesIO`
  stdin/stdout: valid request, malformed JSON, unknown keys, oversize, version-floor path through an
  injected version tuple); parse-failure paths (syntax error, null byte, deep nesting); determinism
  (same request twice yields identical bytes; file order permutation yields identical output); an
  AST-only guarantee test asserting the helper source contains no `exec`, `eval`, `compile` of
  analyzed text, `importlib` or `__import__` of analyzed modules (AC "never imports or executes").
- PowerShell (Pester, `tests/scripts/claude-lib/docs/DocsAnalyzerPythonNative.Tests.ps1`): pack
  absent, no interpreter, each candidate failing in turn, timeout, non-zero exit, invalid JSON,
  unknown kind, out-of-range line, bad declaration, path not in request, each yielding scanner
  elements with `analysis_method: scanner` and no error; a valid canned response yielding identifiers
  and digests equal to the scanner's for shared constructs; per-file fallback; BOM stripping; request
  canonical form.
- Cross-language parity without a subprocess: a committed shared fixture (owned by 1022, extended by
  900011) holding the Python fixture sources and the expected `(analyzer_id, kind, path, declaration,
  line_start, line_end)` rows, with a second list for native-only rows. Pytest asserts the helper
  emits exactly the full set; Pester asserts the scanner emits the shared rows and that the adapter,
  fed a canned helper response equal to the full set, produces identifiers and digests equal to the
  scanner's for every shared row. Reading a committed fixture is not a temporary file.
- Integration (stage 7): one Pester test that runs the real helper through the real context
  `InvokeProcess` when an interpreter is present, executed by the executor with evidence; CI
  behavior of that test (interpreter presence on `windows-latest` PowerShell shards is unverified)
  must be stated in the plan rather than silently skipped.
- Contract tests to run after mirroring: `test_push_down_claude_resource_contracts.py`,
  `test_push_down_claude_pack_manifest_completeness.py`,
  `test_push_down_pack_manifest_dependency_closure.py`, the TypeScript
  `claude-pack-manifest-completeness.test.ts`, `discovery-resources.test.ts` (OQ-B),
  `enforcement-hooks-no-python-invocation.Tests.ps1` (OQ-A), `ClaudeLibModuleConvention.Tests.ps1`,
  1020's `Docs.Manifest.Tests.ps1`, and `check_quality_tiers`.
- Coverage: per-file Python line >= 85% and branch >= 75% from the JSON report with the dotted
  `--cov=` forms in section 3; Pester line >= 85% for the adapter from
  `artifacts/pester/powershell-coverage.xml`.
- Isolation: reversed-order run of the new Python test modules in one process; three seeded shuffled
  file-order Pester runs of the touched suites; a fresh single-process Pester run over `tests/scripts`.

## 12. Artifact Classification

Rules: R1 = directive clause (1) (pushed-down helpers and libs are PowerShell or bash); D3 = owner
exception (language-native analyzer, same language, shipped only in that language's pack, Python
gates); D = epic `### Artifact classes for this epic` data and test rows; P = existing packaging or
configuration file edited in place.

| File | Class | Language | Permitting rule |
|---|---|---|---|
| `.claude/lib/docs/python/run_docs_python_native.py` | pushed-down helper/lib (native analyzer entry) | Python | D3 exception |
| `.claude/lib/docs/python/docs_python_native/__init__.py`, `protocol.py`, `imports.py`, `cli.py`, `routes.py`, `public_api.py`, `architecture.py` | pushed-down helper/lib (native analyzer) | Python | D3 exception |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/python/**` | pushed-down helper/lib (mirror) | Python | D3 exception |
| `.claude/lib/docs/DocsAnalyzerPythonNative.psm1` and its bundle copy | pushed-down helper/lib (adapter) | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` (append under 900011 anchor) and its bundle copy | pushed-down helper/lib | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/python.json` (edit) | schema/config/data | JSON | D |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit, adapter only) | schema/config/data | JSON | D |
| `pyproject.toml` (edit: Pyright `include`/`extraPaths`, pytest `pythonpath`, coverage `source`) | schema/config/data | TOML | D, P |
| `extensions/drm-copilot/.vscodeignore` (edit, only if OQ-B option 1) | schema/config/data | ignore patterns | P, OQ-B |
| `packages/mcp-server/prepack.cjs` (edit, only if OQ-B option 1) | build script (existing packaging) | JavaScript | P, OQ-B (not a new TypeScript/JavaScript artifact) |
| `extensions/drm-copilot/test/packaging/discovery-resources.test.ts` (edit, only if OQ-B option 1) | test | TypeScript (Jest) | D |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` and helpers (edit, per OQ-A) | test | PowerShell (Pester) | D, OQ-A |
| `tests/scripts/claude-lib/docs/python/conftest.py`, `test_docs_python_native_*.py` | test | Python (pytest) | D3 (Python gates) |
| `tests/scripts/claude-lib/docs/DocsAnalyzerPythonNative.Tests.ps1` | test | PowerShell (Pester) | D |
| shared parity fixture (path set by 1022) | test data | JSON | D |
| `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/**` | documentation | Markdown | D |

Any artifact that cannot follow the language rule is an owner question: OQ-A (interpreter start from
a `.claude/lib` file) and OQ-B (Python in distributables, and the JavaScript packaging edit).

## 13. Contracts Later Children Must Honor

- The native helper never computes identifiers or digests; `Get-DocsElementId` and the shared
  declaration-digest function are the only implementations.
- Native elements use the scanner analyzer identifiers and record `analysis_method: native`;
  ledger entries (1023) copy the method from the snapshot element.
- `config-files` and all non-`.py` inputs remain scanner-only; console-script entries come from
  the scanner and are passed to the helper as data.
- Any future language-native analyzer (C#, TypeScript) follows the same shape: a native-provider row
  under its own registry anchor, a helper in its language under `.claude/lib/docs/<language>/`
  listed only in that language's pack, process access only through the command context, and the
  scanner as fallback.
- 900007 and 900009 pass no method of their own; when OQ-C option 1 is adopted they forward
  `-AnalysisMethod` unchanged.
- 900010's onboarding states the optional prerequisite: Python 3.10 or later and the python pack for
  native analysis; PowerShell 7.4 remains the only required runtime.

## Numeric Derivation Evidence

No numeric count, enumeration size or population is proposed for a `spec.md` acceptance criterion.
Analyzer identifiers, element kinds and files are named explicitly; the approximate file counts in
section 7 serve only the batch-budget route decision and are not acceptance criteria.

## Pre-Mortem

- Review checklists: a reviewer finds an interpreter start in `.claude/lib` without a recorded owner
  decision, or an allowlist entry added to pass the guard. Mitigation: the plan blocks the adapter
  task on the OQ-A answer and cites the decision in the 1031 spec before any guard edit.
- Coverage: the helper is silently unmeasured because `[tool.coverage.run] source` or Pyright
  `include` omits it, or a per-file figure is read from a path-form `--cov`. Mitigation: the
  `pyproject.toml` edits are a single early task; evidence uses the dotted forms and the JSON report;
  a Pyright evidence step confirms the helper files are in the analyzed set (relevant if a later
  Pyright upgrade makes `**/.*` exclusion additive).
- Mirror parity: the bundle copies drift, a `__pycache__` directory appears under `.claude/lib/docs/python/`
  and fails the resource-contract test, or the helper is missing from `python.json` and fails the
  TypeScript completeness test. Mitigation: `conftest.py` sets `sys.dont_write_bytecode`, the adapter
  passes `-B`, mirror-hash evidence for every copied file, and all contract tests in section 11 run
  after mirroring. No fact in the execution-environment brief changes unless OQ-A option 1 or 3
  changes the guard description (then the brief's `## Hook Execution Context` bullet is updated in all
  six copies).
- File size: a single helper module or the adapter crosses 500 or 800 lines. Mitigation: the package
  split in section 2.4 from the first task; split response validation into a second PowerShell module
  if the adapter nears 500.
- Test isolation: Pester suites leave the adapter or registry module imported, or Python tests leave
  `sys.dont_write_bytecode` or `sys.modules` state that changes other suites. Mitigation: `AfterAll`
  removes modules; the conftest flag is scoped to the helper's test directory and is harmless to
  others; reversed-order and seeded shuffled runs recorded as evidence.
- CI-only behavior: the 3.10 job fails on an API added after 3.10 that Pyright (3.12 setting) does not
  flag; Linux-only path issues in the shared fixture; the real-process integration test behaves
  differently on runners without Python. Mitigation: branch coverage of every version-sensitive path,
  forward-slash relative fixture paths, and an explicit plan statement of the integration test's CI
  behavior.
- Evidence: per-file coverage, parity fixture results and isolation runs are missing or carry a
  plan-time stamp. Mitigation: every evidence file under `<FEATURE>/evidence/<kind>/` with the write
  time from the clock and `Timestamp`, `Command`, `EXIT_CODE`, `Output Summary`.

## Automation Feasibility

No human interaction is expected for execution once the owner questions are answered. All gates
(Black, Ruff, Pyright, pytest with coverage, Pester through the PoshQC module, Jest for the packaging
test, the push-down contract tests and `check_quality_tiers`) run from the command line. The owner
questions OQ-A to OQ-D are decisions, not manual steps. The timestamp of this artifact was read from
a network UTC time source because the task-researcher role has no shell to read the host clock.

## Items for the Orchestrator to Confirm

- Whether the concurrent 1022 re-preparation defines `line_range` rules, the digest function and a
  shared fixture path (C-4, C-5, C-8).
- Whether `windows-latest` PowerShell shards have a Python interpreter on `PATH` (affects the
  integration test statement).
- That the TypeScript push-down copier publishes `.py` files unfiltered (the Python engine has no
  extension filter; the TypeScript engine was not read end to end).
