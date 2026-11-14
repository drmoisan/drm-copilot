# [P6-T15] File sizes and quality tiers (S21)

Timestamp: 2026-11-07T00-09
Command: logical line count (awk NR) of the eighteen PYLIB files, the five LIB files, packages/mcp-server/prepack.cjs and every Python and Pester test file of the branch diff; poetry run python -m scripts.dev_tools.check_quality_tiers
EXIT_CODE: 0
Output Summary: every production count is below 500 and no test file is at or above 700. The tiers check exits 0 (quality-tiers: OK (30 entries, 30 discovered projects)) and quality-tiers.yml has no diff against MERGE_BASE.

| Class | File | Logical lines |
|---|---|---|
| production | `.claude/lib/docs/python/run_docs_python_native.py` | 68 |
| production | `.claude/lib/docs/python/docs_python_native/__init__.py` | 8 |
| production | `.claude/lib/docs/python/docs_python_native/architecture.py` | 164 |
| production | `.claude/lib/docs/python/docs_python_native/call_sites.py` | 271 |
| production | `.claude/lib/docs/python/docs_python_native/cli.py` | 271 |
| production | `.claude/lib/docs/python/docs_python_native/cli_argparse.py` | 354 |
| production | `.claude/lib/docs/python/docs_python_native/cli_click.py` | 443 |
| production | `.claude/lib/docs/python/docs_python_native/cli_typer.py` | 433 |
| production | `.claude/lib/docs/python/docs_python_native/facts.py` | 151 |
| production | `.claude/lib/docs/python/docs_python_native/imports.py` | 341 |
| production | `.claude/lib/docs/python/docs_python_native/module_names.py` | 117 |
| production | `.claude/lib/docs/python/docs_python_native/protocol.py` | 409 |
| production | `.claude/lib/docs/python/docs_python_native/public_api.py` | 358 |
| production | `.claude/lib/docs/python/docs_python_native/route_model.py` | 158 |
| production | `.claude/lib/docs/python/docs_python_native/route_sites.py` | 311 |
| production | `.claude/lib/docs/python/docs_python_native/routes.py` | 293 |
| production | `.claude/lib/docs/python/docs_python_native/source.py` | 341 |
| production | `.claude/lib/docs/python/docs_python_native/walk.py` | 129 |
| production | `.claude/lib/docs/DocsAnalyzerPythonNative.psm1` | 332 |
| production | `.claude/lib/docs/DocsPythonNativeProtocol.psm1` | 341 |
| production | `.claude/lib/docs/DocsAnalyzerRegistry.psm1` | 376 |
| production | `.claude/lib/docs/DocsInventory.psm1` | 304 |
| production | `.claude/lib/docs/Invoke-DocsCommand.ps1` | 468 |
| production | `packages/mcp-server/prepack.cjs` | 77 |
| test | `tests/scripts/claude-lib/docs/DocsAnalyzerConfigFiles.Tests.ps1` | 328 |
| test | `tests/scripts/claude-lib/docs/DocsAnalyzerPythonNative.Parity.Tests.ps1` | 150 |
| test | `tests/scripts/claude-lib/docs/DocsAnalyzerPythonNative.Tests.ps1` | 295 |
| test | `tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1` | 358 |
| test | `tests/scripts/claude-lib/docs/DocsInventory.PythonNative.Tests.ps1` | 169 |
| test | `tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1` | 351 |
| test | `tests/scripts/claude-lib/docs/DocsInventoryProperties.Tests.ps1` | 332 |
| test | `tests/scripts/claude-lib/docs/DocsInventorySnapshot.Tests.ps1` | 312 |
| test | `tests/scripts/claude-lib/docs/DocsPythonNativeProtocol.Tests.ps1` | 192 |
| test | `tests/scripts/claude-lib/docs/python/conftest.py` | 10 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_architecture.py` | 119 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_call_sites.py` | 188 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_cli.py` | 124 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_cli_argparse.py` | 164 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_cli_click.py` | 208 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_cli_typer.py` | 223 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_corpus.py` | 164 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_determinism.py` | 75 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_entry.py` | 68 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_facts.py` | 96 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_imports.py` | 126 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_module_names.py` | 73 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_protocol.py` | 205 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_public_api.py` | 194 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_route_model.py` | 71 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_route_sites.py` | 98 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_routes.py` | 206 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_safety.py` | 122 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_source.py` | 239 |
| test | `tests/scripts/claude-lib/docs/python/test_docs_python_native_walk.py` | 31 |
| test | `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | 538 |
