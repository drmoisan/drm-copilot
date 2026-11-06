# [P0-T9] Merged-tree re-run of the [P0-T2] existing-test disposition search

Timestamp: 2026-11-06T23-35
Command: git grep -l -E with docs_python_native, Invoke-DocsPythonNativeInventory, Get-DocsPythonNativeKind, DOCS_PYTHON_NATIVE_SCANNER_ROW_MISSING and _helper_trees over tests/scripts/claude-lib/docs, tests/scripts/claude-runtime, tests/scripts/dev_tools and extensions/drm-copilot/test; git grep -n -E for routes.py, imports.py, source.py, cli_argparse.py and cli_click.py over the same paths; git grep for the package symbols over tests/scripts/dev_tools, tests/scripts/claude-runtime and extensions/drm-copilot/test
EXIT_CODE: 0
Output Summary: Every counted match is a planned [P0-T2] disposition; no unplanned existing-test change on the merged tree. The merge brought no new counted match.

## Counted matches

| File | Disposition |
|---|---|
| `PYTESTS/test_docs_python_native_source.py`, `_imports.py`, `_routes.py` | moved classes per [P2-T1], [P2-T2], [P2-T3], [P2-T5]; import lines updated |
| `PYTESTS/test_docs_python_native_cli.py`, `_cli_argparse.py`, `_cli_click.py`, `_cli_typer.py`, `_public_api.py`, `_architecture.py` | import lines updated; bodies unchanged |
| `PYTESTS/test_docs_python_native_safety.py` | `_helper_trees` pin moves from 12 to 18 across [P2-T1] to [P2-T5]; the `docs_python_native/source.py` literal is unchanged |
| `PYTESTS/test_docs_python_native_corpus.py`, `_determinism.py`, `_protocol.py`, `_entry.py`, `PYTESTS/conftest.py` | unchanged (protocol, entry script and path setup only) |
| `TESTS/DocsAnalyzerPythonNative.Tests.ps1` | every existing case unchanged; [P1-T1] adds one case |
| `TESTS/DocsPythonNativeProtocol.Tests.ps1`, `TESTS/DocsInventory.PythonNative.Tests.ps1` | unchanged |
| `extensions/drm-copilot/test/packaging/discovery-resources.test.ts` | unchanged (names only `run_docs_python_native.py` and `source.py`, which keep their paths) |

## Recorded as unchanged and unrelated

Fixture paths in `TESTS/DocsAnalyzerPythonHttp.Tests.ps1` and `TESTS/DocsSurface.Tests.ps1`, and the `source.py` literals in `tests/scripts/dev_tools/test_build_discovery_runtime_io.py` and `tests/scripts/dev_tools/test_discovery_build_identity.py`. No package symbol match exists under `tests/scripts/dev_tools`, `tests/scripts/claude-runtime` or `extensions/drm-copilot/test`.
