# `2026-10-30-docs-surface-analyzer-python-native` - User Story

- Issue: #1031
- Parent: #1019 (epic documentation-estate-tooling, child 900011, wave 2, band C3)
- Owner: drmoisan
- Status: Draft (preparation; planning only)
- Last Updated: 2026-10-30
- Specification: `docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/spec.md`

## Story Statement

- As a maintainer of a Python destination repository with the python pack installed, I want
  `inventory` to classify my CLI, HTTP route, public API and architecture surfaces with Python's own
  `ast` parser, so that constructs the lexical scanner can only report as diagnostics become
  inventoried elements I can document and track in the coverage ledger.
- As a maintainer of a destination repository without the python pack or without a Python
  interpreter, I want `inventory` to keep working with the PowerShell scanner and record that it did,
  so that installing PowerShell 7 remains the only required prerequisite.
- As a documentation reviewer, I want each element to record whether it came from the native
  analyzer or the scanner and to keep the same identifier and digest either way, so that ledger pins
  stay valid when the analysis method changes.
- As the repository owner, I want the Python helper confined to the python pack, parse-only, and
  covered by the Python quality gates, so that the D3 language exception stays narrow and auditable.

## Problem / Why

The documentation-estate epic (#1019) inventories the documentable surface of a destination
repository with PowerShell lexical scanners (#1022 for Python and configuration surfaces). A lexical
scanner cannot fully classify Python constructs; constructs it cannot classify become diagnostics,
which is the documented precision limit of the baseline. The owner approved exception D3: a
language-native analyzer is allowed when it analyzes that same language and is pushed down only
with that language's pack. The Python-native analyzer is in the first release, and the PowerShell
scanner remains the always-available baseline.

## Personas & Scenarios

- Persona: Python service maintainer in a destination repository
  - Owns a repository with argparse, Click or Typer commands and FastAPI or Flask routes.
  - Cares about an inventory that reflects the real surface, including multi-line decorators,
    aliased imports and blueprint or router prefixes.
  - Constraint: the destination may or may not have Python installed on every machine and CI runner.
  - Goal: document every public surface element and pass `docs-complete`.
  - Frustration: scanner diagnostics for constructs that are plainly declared in the code.
- Persona: documentation reviewer
  - Reviews the coverage ledger and page pins.
  - Cares that identifiers and digests are stable across hosts and analysis methods.
  - Goal: a ledger that does not churn when a developer with Python installed regenerates the
    inventory.
- Persona: repository owner (policy steward)
  - Approved D3 as a narrow exception to the PowerShell/bash rule for pushed-down code.
  - Cares that the exception cannot spread: no Python in the core pack, no execution of analyzed
    code, explicit and auditable interpreter invocation.
- Scenario: native analysis available
  - The maintainer runs `Invoke-DocsCommand.ps1 -Command inventory` on a machine with the python
    pack and Python 3.10 or later.
  - The adapter finds the helper, resolves an interpreter, sends the `.py` sources as JSON, and
    validates the response.
  - The snapshot contains native elements recording `analysis_method: native`, including
    constructs the scanner would report as diagnostics; `config-files` elements still come from the
    scanner.
- Scenario: native analysis unavailable
  - A CI runner without Python runs the same command.
  - The adapter finds no usable interpreter, records one non-blocking diagnostic naming the reason,
    and the scanner produces the elements with `analysis_method: scanner`; the command exits 0.
- Scenario: pinning the method in CI (provisional, OQ-C)
  - The maintainer wants identical inventories on every host and passes `-AnalysisMethod native`
    (or `scanner`) in the consumer CI workflow.
  - With `native` on a host lacking the pack or interpreter, the command exits 3 instead of silently
    producing a different element set.

## Acceptance Criteria

Consistent with `spec.md` `## Acceptance Criteria`; E1 to E5 trace to the epic's five 900011
criteria, R to criteria the research shows are necessary.

- [ ] (E1) For the shared 1022 Python parity fixture, the native analyzer emits the same element identifiers and declaration-lines digests as the scanner for every construct both classify (identifiers and digests computed by the adapter in PowerShell), and the helper emits exactly the expected shared and native-only rows.
- [ ] (E1) Constructs the 1022 scanner reports as diagnostics and that `ast` can resolve are classified as elements by the native analyzer; dynamic forms that `ast` also cannot resolve yield the 1022-defined diagnostics.
- [ ] (E2) Without the python pack, `inventory` succeeds with the scanner, records `analysis_method: scanner`, adds no diagnostic and raises no error.
- [ ] (E2) Without a usable interpreter, or when the helper times out, fails, or returns invalid output, `inventory` with the default method succeeds with the scanner, records `analysis_method: scanner`, raises no error, and adds one non-blocking `DOCS_PYTHON_NATIVE_UNAVAILABLE` diagnostic naming the reason.
- [ ] (E2) A file the helper cannot parse falls back to scanner elements for that file only.
- [ ] (E2, provisional OQ-C) `-AnalysisMethod native` fails closed with exit 3 when native analysis is unavailable; `-AnalysisMethod scanner` never invokes the interpreter.
- [ ] (E3) The helper never imports, executes, compiles or evaluates analyzed code; `ast.parse` is its only parsing entry, verified by a source-inspection test and a behavioral test.
- [ ] (E4) The Python helper is listed only in the Claude python pack manifest; the core pack lists no `.py` file and lists the PowerShell adapter.
- [ ] (E5) Python line coverage >= 85% and branch coverage >= 75% per helper file; Pester line coverage >= 85% per PowerShell production file this feature adds or edits.
- [ ] (E5) Black, Ruff and Pyright (strict) report no findings for the helper and its tests, and the Python tests pass on Python 3.10.
- [ ] (R) Every inventory element records `analysis_method` (`native` or `scanner`); `config-files` and non-`.py` elements always record `scanner`.
- [ ] (R) Element identifiers and digests have a single implementation in PowerShell (`Get-DocsElementId` and the shared declaration-digest function); the helper computes neither.
- [ ] (R) The native provider is registered under the 900011 anchor in `DocsAnalyzerRegistry.psm1` without changing any other anchor or row.
- [ ] (R) Every new or edited `.claude/lib/docs/` file is byte-identical to its push-down mirror and the push-down contract tests pass.
- [ ] (R) Tests write no bytecode under `.claude/`, and the adapter starts the interpreter with `-I`, `-B` and `-X utf8`.
- [ ] (R) The adapter reaches the interpreter only through a `[scriptblock]` seam supplied from the command context; Pester mocks that seam, no test starts a process, and Pytest drives the helper through `main` with in-memory streams.
- [ ] (R, provisional OQ-A) The Python-invocation guard allowlist holds exactly one D3-cited entry for the adapter's single interpreter-start function, matched by a detected finding; no other guarded file invokes an interpreter.
- [ ] (R, provisional OQ-B) The VSIX and npm MCP package carry the helper under `.claude/lib/docs/python/` and still exclude every other `.py` file and all bytecode.
- [ ] (R) No test creates a temporary file.
- [ ] (R) Helper output is deterministic and ASCII-only.
- [ ] (R) No production file added or edited exceeds 500 logical lines; module conventions and quality-tier checks pass.
- [ ] (CI-dependent) `poshqc / PowerShell QC` and the Python quality jobs, including Python 3.10, pass on the pull request head.

## Non-Goals

- Native analysis of configuration surfaces (`config-files`), TOML console-script tables or
  dependency declaration files; these stay scanner-only.
- C# and TypeScript native analyzers (later, optional children); 900004 stays the baseline
  TypeScript/.NET scanner.
- Computing identifiers or digests in Python.
- Executing or importing analyzed code, or using any third-party Python or PowerShell package.
- Calling the Python discovery runtime.
- A Codex or `.agents` copy of the helper (the docs lib ships in the Claude bundle only).
- Excluding the helper from full-tree push-downs (OQ-D provisional default: accept and document).
- Real interpreter process runs in Pester tests.
