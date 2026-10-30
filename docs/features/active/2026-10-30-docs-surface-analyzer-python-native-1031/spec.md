# docs-surface-analyzer-python-native - Spec

- **Issue:** #1031
- **Parent (optional):** #1019 (epic documentation-estate-tooling, child 900011, wave 2, band C3)
- **Depends on:** #1022 (PowerShell baseline scanner for Python and configuration surfaces) and, transitively, #1020 (contracts, including its D3/D5 amendment)
- **Authorization:** owner decision D3 (2026-10-30), the language-native analyzer exception recorded in `docs/features/epics/documentation-estate-tooling/epic.md`
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft (preparation; planning only)
- **Version:** 0.2
- **Research (primary design source):** `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/research/research.2026-10-30T22-48.md`

## Overview

The documentation-estate epic (#1019) inventories the documentable surface of a destination
repository with PowerShell lexical scanners (#1022 for Python and configuration surfaces). A lexical
scanner cannot fully classify Python constructs; constructs it cannot classify become diagnostics,
which is the documented precision limit of the baseline. The owner approved exception D3: a
language-native analyzer is allowed when it analyzes that same language and is pushed down only
with that language's pack. The Python-native analyzer is in the first release, and the PowerShell
scanner remains the always-available baseline.

This feature delivers two parts:

1. A Python helper (standard library only, `ast.parse` only) under `.claude/lib/docs/python/`,
   listed only in the Claude python pack manifest and tested under the Python gates (Black, Ruff,
   Pyright, Pytest with coverage). It reports raw facts (kind, declaration, name, parent, line range,
   properties) for in-memory sources received as JSON on standard input.
2. A PowerShell adapter `.claude/lib/docs/DocsAnalyzerPythonNative.psm1` (core pack) that detects
   the python pack and an interpreter through the command context, sends the request, validates the
   response, computes every identifier and digest with the shared 1020/1022 PowerShell functions,
   and falls back to the 1022 scanner whenever native analysis is unavailable or invalid.

The 1022 specification and plan on this branch still describe a withdrawn Python design. No design
is taken from them. Identifiers, element kinds, the digest rule and fixtures are taken from the epic
and the 1020 contracts; see `## Upstream Dependencies (assumed, not yet on the branch)`.

## Behavior

### Selection and scope

- Native analysis applies to `.py` inputs for the analyzer identifiers `python-cli`,
  `python-http`, `python-public-api` and `python-architecture` only.
- `config-files` is always scanner-only. Non-`.py` inputs are always scanner-only, including the
  TOML console-script tables (`[project.scripts]`, `[project.gui-scripts]`,
  `[tool.poetry.scripts]`) owned by `python-cli` and the dependency declarations read by
  `python-architecture` (`requirements*.txt`, `setup.cfg`, `pyproject.toml`). The scanner's
  console-script entries are passed to the helper as data so the helper can attach a root command to
  its script element as the 1022 rules require.
- The minimum interpreter version for the helper is Python 3.10 (equal to the repository floor and
  the lowest CI matrix entry).

### Analysis method selection (provisional, OQ-C)

- `inventory` accepts `-AnalysisMethod auto|native|scanner`, default `auto`.
- `auto`: native analysis is attempted; any unavailability falls back to the scanner without an
  error.
- `native`: native analysis is required; when the pack, a usable interpreter or a valid response is
  absent, the command exits 3 with one error finding `DOCS_PYTHON_NATIVE_UNAVAILABLE` naming the
  reason token, and no snapshot is written.
- `scanner`: the native provider is not invoked and the process seam is never called.

### Fallback rules (`auto`)

- Process-level unavailability (python pack absent, no candidate interpreter resolves, version
  below 3.10, timeout, non-zero exit, start error, invalid or oversized output, any protocol
  violation): the whole native result is discarded; the scanner runs for the four identifiers; every
  element records `analysis_method: scanner`; the exit code is unaffected.
- Pack absence is silent (the normal state for a destination without the python pack). Every other
  process-level reason yields exactly one non-blocking diagnostic `DOCS_PYTHON_NATIVE_UNAVAILABLE`
  whose message carries one reason token: `interpreter-not-found`, `version-below-floor`,
  `timeout`, `exit-nonzero`, `start-error` or `output-invalid`.
- File-level parse failure reported by the helper for one file (syntax error, null byte, recursion
  or memory limit): that file's elements come from the scanner with `analysis_method: scanner`; the
  native result is kept for the other files. Cross-module prefix composition that depended on the
  failed file follows the 1022 `<dynamic>` rule.

### Element and identity rules

- Native elements carry the scanner analyzer identifier (`python-cli` and so on), not a separate
  native identifier, so registry validation (`analyzer_id` equal to `Id`) and ledger joins are
  unchanged. `analysis_method` (`native` or `scanner`) is recorded on every element.
- The helper never computes identifiers or digests. The adapter computes `element_id` with
  `Get-DocsElementId`, `parent_id` from the reported parent `(kind, declaration)` pair and the
  element path, and the declaration-lines digest with the shared digest function used by the 1022
  scanner. There is exactly one implementation of the identity rule and one of the digest rule.
- Parity rule: for every construct that both methods classify, kind, path, declaration,
  `line_range`, `element_id` and the declaration-lines digest are equal. The native set may add
  elements where the scanner emits a diagnostic.

### Interpreter discovery and invocation

- Pack detection: the context file test for `.claude/lib/docs/python/run_docs_python_native.py`
  (repository-root relative; never derived from `$PSScriptRoot`).
- Candidates in order: `python3`, `python`, `py` (the last with leading argument `-3`), resolved
  through the command context. Each resolved candidate is tried in turn; a candidate that fails for
  any process-level reason moves to the next; when none succeeds the fallback rules apply.
- Interpreter arguments: `-I` (isolated mode, so a module planted in the destination cannot shadow
  the helper's imports), `-B` (no bytecode), `-X utf8`, then the helper's repository-relative path.
  The working directory is the repository root. The entry script inserts only its own directory at
  `sys.path[0]`.
- The adapter strips a leading U+FEFF from each source before sending it.
- The call is bounded by a timeout and an output-size limit whose values the plan fixes.
- Interpreter start is confined to one named function in `DocsAnalyzerPythonNative.psm1`, reached
  only through a `[scriptblock]`-typed parameter supplied from the command context (see
  `## Owner Questions`, OQ-A). Pester replaces that seam with test-local scriptblocks; no Pester or
  Pytest test starts a process.

### Helper behavior

- Reads `sys.stdin.buffer`, decodes UTF-8 explicitly, parses each file with `ast.parse` inside
  `warnings.catch_warnings()` so standard error stays empty, and walks nodes generically
  (`ast.iter_child_nodes`) without naming node types introduced after 3.10.
- Never imports, executes, compiles to code objects or evaluates analyzed sources.
- Writes `json.dumps(..., ensure_ascii=True, sort_keys=True, separators=(",", ":"))` to
  `sys.stdout.buffer`; ASCII-only output is independent of the console code page.
- Output is deterministic: the same request yields identical bytes, and a permutation of the file
  order yields identical output.
- Native coverage per analyzer (`.py` only):
  - `python-cli`: argparse (`ArgumentParser`, `add_subparsers`, nested `add_parser`,
    `add_argument` long, short and positional, argument groups); Click (`command`, `group`, tracked
    group decorators, `add_command`, `option`, `argument`); Typer (`Typer`, `command`, `callback`,
    `add_typer`, `run`, `Option`/`Argument` defaults and `Annotated[...]`).
  - `python-http`: FastAPI and Flask decorators, `api_route`, `add_api_route`, `add_url_rule`,
    `include_router` and `register_blueprint` prefix composition across modules through the import
    table, and the 1022 `<dynamic>` prefix rule.
  - `python-public-api`: literal `__all__` forms (assignment, annotated assignment, `+=`, `extend`,
    `append`) and the naming rule over top-level `def`, `async def`, `class` and assignment targets,
    including `if` and `try` bodies.
  - `python-architecture`: packages and modules from `.py` paths and `Import`/`ImportFrom` edges at
    any depth, with relative-import resolution.
- Constructs a lexical scanner typically reports as diagnostics and `ast` classifies (the binding
  list is the 1022 diagnostic catalogue once published): calls and decorators spanning several lines
  or with nested brackets; implicit concatenation of string literals; `from x import y as z` aliases
  and tracked receivers across assignments; keyword arguments in any order; `Annotated[...]` Typer
  parameters; conditional definitions; look-alike text inside strings or comments; relative imports.
  Dynamic forms that `ast` also cannot resolve yield the same diagnostics the 1022 rules define.

## Inputs / Outputs

- Inputs: captured inputs from 1020 `New-DocsCapturedInput` (path, text, sha256, size), the
  `inventory` selection, the scanner's console-script entries, and the command context.
- Outputs: surface elements in the 1020 snapshot `element` shape plus `analysis_method`, and docs
  diagnostics; no file is written by the adapter or the helper.
- Configuration: `-AnalysisMethod` on `inventory` (provisional, OQ-C), default `auto`. No profile
  field is added.
- Compatibility: switching between `native` and `scanner` keeps `element_id` and the
  declaration-lines digest of every shared construct unchanged, so ledger pins stay valid.

## API / CLI Surface

### `inventory` option (provisional, OQ-C)

- `Invoke-DocsCommand.ps1 -Command inventory -AnalysisMethod auto|native|scanner [...]`; an unknown
  value exits 2 with `DOCS_CLI_ARGUMENTS`.

### Native-provider function

- `Invoke-DocsAnalyzerPythonNative -CapturedInput <object[]> -Selection <object> -Context <object>
  -InvokeInterpreter <scriptblock>` returns
  `@{ Available; Reason; Elements; Diagnostics; ScannerPaths }`. `inventory` runs the scanner rows
  for `ScannerPaths`, or for every input when `Available` is `$false`.
- `Test-DocsPythonNativeResponse` (pure) validates a parsed response: closed key set,
  `protocol_version`, every path present in the request, analyzer identifiers and kinds within the
  four native analyzers, `1 <= line_start <= line_end <= line count` (line splitting on `\r\n`,
  `\n` and `\r` only), declaration grammar through `Get-DocsElementId`, and the stdout size bound.
  Any failure discards the whole native result (`output-invalid`).

### Helper protocol (protocol version 1)

- Request (adapter to helper):
  `{protocol_version: 1, analyzers: [...], source_roots: [...], files: [{path, text}],
  console_scripts: [{name, table, path, target}], limits: {...}}`.
- Response (helper to adapter):
  `{protocol_version: 1, python_version: "x.y.z", files: [{path, status, elements: [{analyzer_id,
  kind, declaration, name, parent: {kind, declaration} | null, line_start, line_end, properties:
  [{name, value}]}], diagnostics: [{analyzer_id, code, line, blocking}]}]}`.
- Helper exit codes: 0 response written; 2 request invalid (malformed JSON, unknown key, limit
  exceeded); 3 internal error; 4 interpreter below 3.10. Every non-zero exit writes one protocol
  error object and is treated by the adapter as `exit-nonzero`.
- Entry: `.claude/lib/docs/python/run_docs_python_native.py`, which calls
  `docs_python_native.protocol.main(stdin=..., stdout=...)`. Tests call `main` with `io.BytesIO`
  streams.

## Data & State

- Snapshot element gains `analysis_method` (`native` | `scanner`) through the 1020 amendment; this
  feature populates it for native elements and relies on 1022 to populate `scanner`.
- No persistent state, cache or migration. The helper is stateless per call.
- Invariants: identifiers and digests are computed only in PowerShell; native and scanner results
  for a shared construct are indistinguishable except for `analysis_method`.

## Constraints & Risks

- Language rule: pushed-down skills, hooks and libs are PowerShell or bash; the Python helper is
  the single owner-approved D3 exception and is tested under the Python gates.
- No new third-party Python or PowerShell dependency; standard library and PowerShell 7 built-ins
  only.
- Tests create no temporary files; Pytest tests start no process (`check-python-test-purity.ps1`);
  Pester tests start no process (`check-powershell-test-purity.ps1`).
- Python-invocation guard: `enforcement-hooks-no-python-invocation.Tests.ps1` forbids interpreter
  invocation in `.claude/lib` and keeps an empty allowlist that only an owner decision recorded in a
  specification may change (OQ-A).
- Distributables: `.vscodeignore` and `packages/mcp-server/prepack.cjs` exclude every `.py` file,
  pinned by `discovery-resources.test.ts`; without a carve-out the helper never reaches a destination
  through the installed extension or the npm package (OQ-B).
- Bytecode: importing the helper package in tests would create `__pycache__` under `.claude/`,
  which `test_push_down_claude_resource_contracts.py` reports as a repository file missing from the
  bundle.
- Pyright runs with `pythonVersion = "3.12"`; an API newer than 3.10 is caught only by the 3.10 CI
  job. Branch coverage of version-sensitive paths is the mitigation.
- File size: the four analyzers cannot share one file below 800 lines; the helper is a package with
  one module per concern, each below 500 lines.
- Host dependence: with `auto`, hosts with and without the pack and an interpreter inventory
  different element sets (OQ-C).
- Upstream drift: 1020's amendment and 1022's re-preparation are concurrent; see
  `## Upstream Dependencies (assumed, not yet on the branch)`.

## Implementation Strategy

- Create the helper package `.claude/lib/docs/python/` (`run_docs_python_native.py`;
  `docs_python_native/__init__.py`, `protocol.py`, `imports.py`, `cli.py`, `routes.py`,
  `public_api.py`, `architecture.py`; `routes.py` rather than `http.py` to avoid a standard-library
  name).
- Create the adapter `.claude/lib/docs/DocsAnalyzerPythonNative.psm1`; split response validation
  into `DocsPythonNativeProtocol.psm1` if the adapter approaches 500 lines.
- Append the native-provider row under the 900011 anchor in `DocsAnalyzerRegistry.psm1`.
- Edit `pack-manifests/python.json` (helper files) and `pack-manifests/core.json` (adapter only);
  mirror every new or edited `.claude/lib/docs/` file byte-identically under
  `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`.
- Edit `pyproject.toml` additively: Pyright `include` and `extraPaths` gain
  `.claude/lib/docs/python`; `[tool.pytest.ini_options] pythonpath` gains it; `[tool.coverage.run]
  source` gains it. Existing pins (`test_pyright_config_alignment.py`,
  `test_ruff_config_alignment.py`, `tests/discovery_runtime/test_package_contract.py`) stay green.
- Python tests under `tests/scripts/claude-lib/docs/python/` (`conftest.py` setting
  `sys.dont_write_bytecode = True`; `test_docs_python_native_<area>.py` with unique basenames).
  Pester tests at `tests/scripts/claude-lib/docs/DocsAnalyzerPythonNative.Tests.ps1`.
- Guard and packaging edits per the provisional defaults of OQ-A and OQ-B.
- Dependencies: none added. Logging: diagnostics only, through `New-DocsDiagnostic`.
- Rollout: the scanner remains the default outcome wherever the pack or interpreter is absent; no
  feature flag beyond `-AnalysisMethod`.
- Execution runs in the item worktree under a large/preparation checkpoint, because the file count
  exceeds the direct-mode batch budget for Python and PowerShell.

## Artifact Classification

Rules: R1 = directive clause (1) (pushed-down helpers and libs are PowerShell or bash); D3 = owner
exception (language-native analyzer for the same language, shipped only in that language's pack,
tested under the Python gates); D = epic `### Artifact classes for this epic` data and test rows;
P = existing packaging or configuration file edited in place.

| File | Class | Language | Permitting rule |
|---|---|---|---|
| `.claude/lib/docs/python/run_docs_python_native.py` | pushed-down helper/lib (native analyzer entry) | Python | D3 exception |
| `.claude/lib/docs/python/docs_python_native/__init__.py`, `protocol.py`, `imports.py`, `cli.py`, `routes.py`, `public_api.py`, `architecture.py` | pushed-down helper/lib (native analyzer) | Python | D3 exception |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/python/**` | pushed-down helper/lib (mirror) | Python | D3 exception |
| `.claude/lib/docs/DocsAnalyzerPythonNative.psm1` and its bundle copy | pushed-down helper/lib (adapter) | PowerShell | R1 |
| `.claude/lib/docs/DocsPythonNativeProtocol.psm1` and its bundle copy (only if split) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` (append under the 900011 anchor) and its bundle copy | pushed-down helper/lib | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/python.json` (edit) | schema/config/data | JSON | D |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit, adapter only) | schema/config/data | JSON | D |
| `pyproject.toml` (edit: Pyright `include`/`extraPaths`, pytest `pythonpath`, coverage `source`) | schema/config/data | TOML | D, P |
| `extensions/drm-copilot/.vscodeignore` (edit, provisional OQ-B) | schema/config/data | ignore patterns | P, OQ-B |
| `packages/mcp-server/prepack.cjs` (edit, provisional OQ-B) | build script (existing packaging) | JavaScript | P, OQ-B (in-place edit; not a new TypeScript or JavaScript artifact) |
| `extensions/drm-copilot/test/packaging/discovery-resources.test.ts` (edit, provisional OQ-B) | test | TypeScript (Jest) | D, OQ-B |
| `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1` (edit, provisional OQ-A) | test | PowerShell (Pester) | D, OQ-A |
| `tests/scripts/claude-lib/docs/python/conftest.py`, `test_docs_python_native_*.py` | test | Python (Pytest) | D3 (Python gates) |
| `tests/scripts/claude-lib/docs/DocsAnalyzerPythonNative.Tests.ps1` | test | PowerShell (Pester) | D |
| shared parity fixture (path set by 1022; native-only rows added by this feature) | test data | JSON | D |
| `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/**` | documentation | Markdown | D |

The Codex python pack manifest is not edited: the docs lib ships in the Claude bundle only (1020
OQ-2 provisional default), and the Codex manifests list no libs.

## Owner Questions

The epic proceeds on provisional defaults pending owner answers. Each default below is
**provisional, not decided**; an owner answer that differs changes the affected criteria through a
specification revision.

- **OQ-A - Python invocation from `.claude/lib`.** The guard suite forbids interpreter invocation
  from every `.claude/lib` PowerShell file and keeps an empty allowlist that only an owner decision
  recorded in a specification may change. D3 approves the analyzer but does not state that a
  `.claude/lib` PowerShell file may start an interpreter.
  - Provisional default: option 1. One explicit, auditable allowlist entry
    `@{ Path = '.claude/lib/docs/DocsAnalyzerPythonNative.psm1'; Function = '<the single interpreter-start function>' }`
    citing D3 in a comment, with the `ships an empty allowlist` test changed to assert exactly that
    entry. The interpreter start uses a form the guard detects, so the entry is matched by a real
    finding (Assertion B keeps it from going stale).
  - Not adopted: any shape that evades the detector (for example a generic
    `ProcessStartInfo`/`Process.Start` runner fed an interpreter path), and excluding
    `.claude/lib/docs/` from the scan roots. If the detectable form cannot satisfy the timeout
    requirement, the planner records that as a further owner question rather than switching to an
    undetected shape.
- **OQ-B - Python exclusion in the distributables.** `.vscodeignore` (`**/*.py`) and
  `prepack.cjs` `shouldCopy` drop every `.py` file, pinned by `discovery-resources.test.ts`.
  - Provisional default: a narrow carve-out for
    `resources/claude-customizations/.claude/lib/docs/python/**` in both distributables, with the
    packaging test updated to assert the carve-out and the continued exclusion of every other `.py`
    file and of `__pycache__`/`.pyc`/`.pyo`.
- **OQ-C - Host-dependent inventory.** With automatic selection, a host with the pack and an
  interpreter inventories more elements than one without; a ledger written on one host can fail
  `docs-complete` on the other.
  - Provisional default: `inventory -AnalysisMethod auto|native|scanner`, default `auto`; `native`
    fails closed (exit 3) when the pack or interpreter is absent, so a consumer CI can pin the
    method.
- **OQ-D - Full-tree push-down.** A push-down without a pack selection publishes the helper to every
  destination.
  - Provisional default: accept and document. The helper is inert without an interpreter and the
    adapter falls back to the scanner. This specification records the behavior; 900010's onboarding
    states it.

## Upstream Dependencies (assumed, not yet on the branch)

`.claude/lib/docs/` does not exist on this branch, and the 1020 specification (v0.3) has not yet
absorbed the epic `### Amendment of 1020 required by D3 and D5`. This feature assumes the following
exist before execution. A mismatch between an assumption and the delivered 1020/1022 contract is
resolved in this feature's remediation loop by conforming to the delivered contract, without editing
another child's anchor or row.

| Item | Owner | Assumed contract |
|---|---|---|
| 900011 anchor in `DocsAnalyzerRegistry.psm1` | 1020 amendment | An anchor comment for 900011 below which this feature appends a native-provider row; the registry supports a native-provider table distinct from `$script:DocsAnalyzerRow`, because a second row with the same `Id` is rejected as a duplicate. Proposed row: `[pscustomobject]@{ Language = 'python'; AnalyzerIds = @('python-cli','python-http','python-public-api','python-architecture'); Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerPythonNative.psm1'); Function = 'Invoke-DocsAnalyzerPythonNative' }`. |
| `analysis_method` field | 1020 amendment | `native` | `scanner` on inventory elements (and on ledger entries, populated by 1023). |
| Declaration-lines digest function | 1020 amendment or 1022 | One PowerShell function shared by scanner and adapter (proposed `Get-DocsDeclarationDigest -Text -LineRange` in `DocsSurface.psm1`): split on `\r\n`, `\n` and `\r` only, join the selected lines with LF and no trailing terminator, SHA-256 of the UTF-8 bytes. |
| Per-kind `line_range` rules | 1022 | Which node bounds each kind (decorator or call node versus `def` line; signature-only versus whole body for `public-symbol`); this feature mirrors them. |
| Shared parity fixture | 1022 | A committed fixture holding the Python fixture sources and expected `(analyzer_id, kind, path, declaration, line_start, line_end)` rows, at a path 1022 sets; this feature adds a native-only row list. |
| Diagnostic catalogue | 1022 | The scanner diagnostic codes and the constructs that trigger them. |
| Command-context process member | 1020 amendment | A context member through which application resolution and the interpreter call are supplied as `[scriptblock]` values (research proposes `ResolveApplication` and `InvokeProcess`); `New-DocsCommandContext` remains the only builder. |
| `inventory` option | 1022 | `-AnalysisMethod` on the `inventory` row (provisional OQ-C); if absent, this feature adds the option in its remediation loop within the inventory command's documented extension point. |
| Manifest test amendment | 1020 amendment | `Docs.Manifest.Tests.ps1` accepts files under `.claude/lib/docs/python/` listed in `python.json` and not in `core.json`, and skips `__pycache__`. |
| Non-blocking diagnostic | 1020 | `New-DocsDiagnostic -Blocking $false` yields `warning` (no `information` constructor exists). |

## Decisions Later Children Must Honor

- The native helper never computes identifiers or digests; `Get-DocsElementId` and the shared
  declaration-digest function are the only implementations.
- Native elements use the scanner analyzer identifiers and record `analysis_method: native`; ledger
  entries (1023) copy the method from the snapshot element.
- `config-files` and all non-`.py` inputs remain scanner-only; console-script entries come from the
  scanner and are passed to the helper as data.
- Any future language-native analyzer (C#, TypeScript) follows the same shape: a native-provider row
  under its own registry anchor, a helper in its language under `.claude/lib/docs/<language>/` listed
  only in that language's pack, process access only through the command context, and the scanner as
  fallback.
- 900007 and 900009 pass no method of their own; with the OQ-C default they forward
  `-AnalysisMethod` unchanged.
- 900010's onboarding states the optional prerequisite: Python 3.10 or later and the python pack for
  native analysis; PowerShell 7.4 remains the only required runtime. It also states the OQ-D
  behavior.

## Acceptance Criteria

Traceability: E1 to E5 are the five 900011 criteria in the epic, in order (E1 identifier parity and
classification of scanner-diagnostic constructs; E2 scanner fallback; E3 `ast.parse` only; E4 python
pack only; E5 coverage). R marks a criterion the research shows is necessary.

- [ ] (E1) For the shared 1022 Python parity fixture, a Pytest test calling the helper's `main` with in-memory streams asserts that the helper emits exactly the expected rows (shared rows plus native-only rows) as `(analyzer_id, kind, path, declaration, line_start, line_end)`, and a Pester test asserts that the adapter, fed a canned helper response equal to that row set, produces `element_id` and declaration-lines digest values equal to the scanner's for every shared row.
- [ ] (E1) For every construct in the parity fixture that the 1022 scanner reports as a diagnostic and that `ast` can resolve, the native result contains a classified element and no corresponding diagnostic; dynamic forms that `ast` also cannot resolve yield the diagnostics defined by the 1022 rules (Pytest per analyzer identifier).
- [ ] (E2) With the python pack absent (context file test false for `.claude/lib/docs/python/run_docs_python_native.py`), `inventory` exits 0, every element of `python-cli`, `python-http`, `python-public-api` and `python-architecture` records `analysis_method: scanner`, no diagnostic or error finding is added, and the interpreter seam is never called (Pester).
- [ ] (E2) With the pack present and each of: no candidate resolving, version below 3.10 (helper exit 4), timeout, start error, non-zero exit, malformed JSON, unknown key, unknown kind, out-of-range line, invalid declaration, path not in the request, and oversized output, `inventory` with `-AnalysisMethod auto` exits 0 with scanner elements recording `analysis_method: scanner`, no error-severity finding, and exactly one non-blocking `DOCS_PYTHON_NATIVE_UNAVAILABLE` diagnostic carrying the matching reason token; when an earlier candidate fails and a later one succeeds, the later candidate's result is used (Pester).
- [ ] (E2, R) A helper response marking one file as a parse failure yields scanner elements with `analysis_method: scanner` for that file and native elements with `analysis_method: native` for the other files (Pester).
- [ ] (E2, R, provisional OQ-C) `-AnalysisMethod native` exits 3 with one error finding `DOCS_PYTHON_NATIVE_UNAVAILABLE` and writes no snapshot when the pack, a usable interpreter or a valid response is absent; `-AnalysisMethod scanner` never calls the interpreter seam; an unknown value exits 2 with `DOCS_CLI_ARGUMENTS` (Pester).
- [ ] (E3) A Pytest source-inspection test over every file under `.claude/lib/docs/python/` asserts that no call to `exec`, `eval`, `compile`, `__import__`, `importlib`, `runpy` or `subprocess` exists and that `ast.parse` is the only parsing entry; a behavioral Pytest test analyzes a fixture source whose execution would raise an exception or change interpreter state and asserts the analysis succeeds with no such effect.
- [ ] (E4) Every file under `.claude/lib/docs/python/` is listed in the Claude `pack-manifests/python.json` and in no other Claude manifest; `pack-manifests/core.json` lists no path ending in `.py` and lists `.claude/lib/docs/DocsAnalyzerPythonNative.psm1`; the Codex python pack manifest is unchanged; the amended `Docs.Manifest.Tests.ps1`, `test_push_down_claude_pack_manifest_completeness.py` and `claude-pack-manifest-completeness.test.ts` pass.
- [ ] (E5) Python line coverage is at least 85% and branch coverage at least 75% for each file of the helper, read from the coverage JSON report produced with the dotted `--cov=` module forms (`docs_python_native`, its submodules and `run_docs_python_native`), with the helper included in `[tool.coverage.run] source`; Pester line coverage is at least 85% for `DocsAnalyzerPythonNative.psm1` (and `DocsPythonNativeProtocol.psm1` if split) and for the edited `DocsAnalyzerRegistry.psm1`, with no production file excluded; figures are recorded under `<FEATURE>/evidence/coverage/`.
- [ ] (E5, R) Black, Ruff and Pyright (strict, with `.claude/lib/docs/python` in `include` and `extraPaths`) report zero findings for the helper and its tests, and the existing pins `test_pyright_config_alignment.py`, `test_ruff_config_alignment.py` and `tests/discovery_runtime/test_package_contract.py` pass unmodified; the Python tests pass on the 3.10 CI matrix job.
- [ ] (R) Every element in the inventory snapshot carries `analysis_method` with value `native` or `scanner`; `config-files` elements and elements from non-`.py` inputs always carry `scanner`; the snapshot validates against the amended `surface-inventory-snapshot.schema.json` (Pester).
- [ ] (R) Identifiers and digests have a single implementation: the helper emits no `element_id`, `parent_id` or digest field and its source contains no `hashlib` import; the adapter obtains every `element_id` from `Get-DocsElementId` and every declaration-lines digest from the shared digest function, and contains no hashing primitive or canonical-JSON serialization of its own (Pester and Pytest source checks).
- [ ] (R) `DocsAnalyzerRegistry.psm1` carries the native-provider row directly under the 900011 anchor, no other anchor or row is changed, registration validation returns no finding for the committed registry, and the registry test asserts membership of the row rather than set equality (Pester).
- [ ] (R) Every new or edited file under `.claude/lib/docs/` (including `python/**`) is SHA-256 identical to its copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`, and `test_push_down_claude_resource_contracts.py` and `test_push_down_pack_manifest_dependency_closure.py` (including `test_every_psscriptroot_occurrence_is_recognized`) pass.
- [ ] (R) No bytecode is written under `.claude/`: after the full Python test run, no `__pycache__` directory or `.pyc` file exists under `.claude/lib/docs/python/` or its bundle copy; `tests/scripts/claude-lib/docs/python/conftest.py` sets `sys.dont_write_bytecode = True`; a Pester test asserts the captured interpreter arguments include `-I`, `-B` and `-X utf8` before the helper path.
- [ ] (R) Process access goes only through the command-context seam: the adapter reaches the interpreter-start function only through a `[scriptblock]`-typed parameter supplied from the command context; every Pester test supplies test-local scriptblocks for resolution and invocation; no Pester or Pytest test starts a process; Pytest exercises the helper end to end only through `main` with `io.BytesIO` streams.
- [ ] (R, provisional OQ-A) The Python-invocation guard allowlist contains exactly one entry, for `.claude/lib/docs/DocsAnalyzerPythonNative.psm1` and its single interpreter-start function, with a comment citing D3 and this specification; the test that previously asserted an empty allowlist asserts exactly that entry; the entry is matched by a detected finding; `enforcement-hooks-no-python-invocation.Tests.ps1` passes with no other finding in `.claude/hooks`, `.claude/lib` or `.codex/hooks`.
- [ ] (R, provisional OQ-B) The VSIX and the npm MCP package include `resources/claude-customizations/.claude/lib/docs/python/**/*.py` and exclude every other `.py` file and all `__pycache__`, `.pyc` and `.pyo` paths; `discovery-resources.test.ts` asserts both the carve-out and the remaining exclusion.
- [ ] (R) No test creates a temporary file: no file under `tests/scripts/claude-lib/docs/` (including `python/`) contains `tempfile`, `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName` or `$env:TEMP`, and the Python and PowerShell test-purity hooks report no violation.
- [ ] (R) The helper output is deterministic: the same request yields byte-identical stdout, a permutation of the request file order yields identical output, and stdout contains only ASCII bytes (Pytest).
- [ ] (R) No production file added or edited by this feature exceeds 500 logical lines, and every new `.claude/lib/docs/` PowerShell file passes `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`; `python -m scripts.dev_tools.check_quality_tiers` exits 0 with no new `quality-tiers.yml` entry.
- [ ] (CI-dependent) The required check `poshqc / PowerShell QC` and the `quality-checks` Python jobs, including the Python 3.10 matrix entry, pass on the pull request head.

## Definition of Done

- [ ] Acceptance criteria mapped to Pytest modules, Pester suites or commands in the plan
- [ ] Every artifact listed in `## Artifact Classification` with class, language and permitting rule in the plan
- [ ] Owner-question defaults applied as provisional, each cited where it changes a guard, a packaging rule or a command option
- [ ] Toolchain loop passes in a single clean pass for Python (Black, Ruff, Pyright, Pytest) and PowerShell (formatter, PSScriptAnalyzer, Pester), plus the Jest packaging test
- [ ] Isolation: the new Python test modules pass in reversed order in one process; touched Pester suites pass in three seeded shuffled file-order runs and in a fresh single-process run over `tests/scripts`; evidence under `<FEATURE>/evidence/regression-testing/`
- [ ] Forbidden-token scan with bracket-class patterns over every changed file reports no match
- [ ] Evidence written under `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/evidence/<kind>/`

## Seeded Test Conditions (from potential)

- [ ] Unit coverage areas: helper parsing per analyzer identifier, identifier and digest parity with the scanner, adapter detection and fallback paths
- [ ] Integration scenarios: `inventory` with and without the python pack and interpreter (through the mocked process seam)
- [ ] CLI/API examples: JSON on standard input and standard output contract
