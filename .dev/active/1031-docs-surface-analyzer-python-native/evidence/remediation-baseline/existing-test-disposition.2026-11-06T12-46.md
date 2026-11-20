# [P0-T2] Existing-test disposition (remediation cycle 1)

Timestamp: 2026-11-06T12-46
Command: git grep (worktree-scoped) over `tests/scripts/claude-lib/docs` (with `python/`), `tests/scripts/claude-runtime`, `tests/scripts/dev_tools` and `extensions/drm-copilot/test` for every moved or renamed symbol of `## Remediation Design`, `_helper_trees`, `Invoke-DocsPythonNativeInventory`, `Get-DocsPythonNativeKind`, `DOCS_PYTHON_NATIVE_SCANNER_ROW_MISSING`, and the file names `routes.py`, `imports.py`, `source.py`, `cli_argparse.py`, `cli_click.py`
EXIT_CODE: 0
Output Summary: Every counted match is a planned disposition; no unplanned existing-test change. Counted matches are in the 15 PYTESTS files, three Pester suites and one Jest suite listed below.

## Counted matches (reference the docs_python_native package, a listed PowerShell function, or a path under docs_python_native/)

| File | Match | Disposition |
|---|---|---|
| `PYTESTS/test_docs_python_native_source.py` | imports `Context`, `walk_with_context` from `docs_python_native.source`; class `TestWalkWithContext` | `TestWalkWithContext` moves unchanged to `test_docs_python_native_walk.py` ([P2-T1]); the import line drops the two moved names (reason: symbols moved); other bodies unchanged |
| `PYTESTS/test_docs_python_native_imports.py` | imports `AnalyzerOutput`, `module_dotted_name`, `module_package`, `resolve_relative` from `docs_python_native.imports`; classes `TestModuleNames`, `TestAnalyzerOutput` | `TestModuleNames` moves unchanged to `test_docs_python_native_module_names.py` ([P2-T3]); `TestAnalyzerOutput` moves unchanged to `test_docs_python_native_facts.py` ([P2-T2]); import line updated (symbols moved) |
| `PYTESTS/test_docs_python_native_routes.py` | imports `AnalyzerOutput` from `imports`, `method_list` from `routes`; class `TestMethodList` | `TestMethodList` moves unchanged to `test_docs_python_native_route_sites.py` ([P2-T5]); import lines updated (symbols moved) |
| `PYTESTS/test_docs_python_native_cli.py` | imports `CliSite` from `cli_argparse`, `Fact` from `imports` | import lines updated ([P2-T2], [P2-T4]); bodies unchanged |
| `PYTESTS/test_docs_python_native_cli_argparse.py` | imports `CliResult`, `CliSite` from `cli_argparse` | import line updated ([P2-T4]); bodies unchanged |
| `PYTESTS/test_docs_python_native_cli_click.py` | imports `CliResult`, `CliSite` from `cli_argparse` | import line updated ([P2-T4]); bodies unchanged |
| `PYTESTS/test_docs_python_native_cli_typer.py` | imports `CliResult`, `CliSite` from `cli_argparse` | import line updated ([P2-T4]); bodies unchanged |
| `PYTESTS/test_docs_python_native_public_api.py` | imports `AnalyzerOutput` from `imports` | import line updated ([P2-T2]); bodies unchanged |
| `PYTESTS/test_docs_python_native_architecture.py` | imports `AnalyzerOutput` from `imports` | import line updated ([P2-T2]); bodies unchanged |
| `PYTESTS/test_docs_python_native_safety.py` | `_helper_trees` asserts `len(files) == 12`; literal `docs_python_native/source.py` in `test_ast_parse_is_the_only_parse_call` | pin changes 12 to 13, 14, 15, 16, 18 across [P2-T1] to [P2-T5] (reason: the pin counts PYLIB files); the `source.py` literal is unchanged (`parse_module` stays in `source.py`) |
| `PYTESTS/test_docs_python_native_corpus.py`, `_determinism.py`, `_protocol.py`, `_entry.py` | import only `docs_python_native.protocol` and the entry script | unchanged |
| `TESTS/DocsAnalyzerPythonNative.Tests.ps1` | `Invoke-DocsPythonNativeInventory` (helper `Invoke-TestInventory`, `Describe 'Invoke-DocsPythonNativeInventory'`) | every existing case unchanged; [P1-T1] adds one case |
| `TESTS/DocsPythonNativeProtocol.Tests.ps1` | `Get-DocsPythonNativeKind` | unchanged (attributes change no behavior) |
| `TESTS/DocsInventory.PythonNative.Tests.ps1` | helper path literal | unchanged |
| `TESTS/DocsAnalyzerPythonNative.Parity.Tests.ps1` | none counted | unchanged |
| `extensions/drm-copilot/test/packaging/discovery-resources.test.ts` | `run_docs_python_native.py`, `docs_python_native/source.py` (and `.pyc`/`.pyo`/`__pycache__` siblings) | unchanged (both files keep their paths) |

`DOCS_PYTHON_NATIVE_SCANNER_ROW_MISSING`: no match (new code).

## Recorded as unchanged and unrelated (textual matches only)

- Pester `Context` blocks and the word `Context` across `TESTS/*.Tests.ps1`, `TESTS/*.TestSupport.psm1`, `tests/scripts/claude-runtime/*.Tests.ps1`, and `Context`/`Fact` words in `tests/scripts/dev_tools/*.py` and `extensions/drm-copilot/test/**/*.test.ts` (none imports or names a `docs_python_native` module).
- Fixture paths `src/app/routes.py` in `TESTS/DocsAnalyzerPythonHttp.Tests.ps1` and `src/example_pkg/routes.py` in `TESTS/DocsSurface.Tests.ps1`.
- `source.py` literals in `tests/scripts/dev_tools/test_build_discovery_runtime_io.py` and `tests/scripts/dev_tools/test_discovery_build_identity.py`.
- Corpus fixtures `TESTS/fixtures/python-native-corpus.json` and `TESTS/fixtures/python-surface-corpus.json` (fixture source paths).

No other counted match exists, so no `BLOCKED: unplanned existing-test change`.
