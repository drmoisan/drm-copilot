# [P6-T17] Test hygiene (S19)

Timestamp: 2026-11-07T00-09
Command: Invoke-PythonTestPurityDecision and Invoke-PowerShellTestPurityDecision over a PreToolUse payload per file (`sh SCRATCH/issue-1031-pwsh.sh issue-1031-purity.ps1`); case-insensitive plain search of every file under TESTS for tempfile, New-TemporaryFile, TestDrive, GetTempPath, GetTempFileName and env:TEMP
EXIT_CODE: 0
Output Summary: no decision returned for any of the 21 Python test files or for TESTS/DocsAnalyzerPythonNative.Tests.ps1 (DECISIONS_RETURNED=0); the search printed nothing.

- python PYTESTS/conftest.py | none
- python PYTESTS/test_docs_python_native_architecture.py | none
- python PYTESTS/test_docs_python_native_call_sites.py | none
- python PYTESTS/test_docs_python_native_cli.py | none
- python PYTESTS/test_docs_python_native_cli_argparse.py | none
- python PYTESTS/test_docs_python_native_cli_click.py | none
- python PYTESTS/test_docs_python_native_cli_typer.py | none
- python PYTESTS/test_docs_python_native_corpus.py | none
- python PYTESTS/test_docs_python_native_determinism.py | none
- python PYTESTS/test_docs_python_native_entry.py | none
- python PYTESTS/test_docs_python_native_facts.py | none
- python PYTESTS/test_docs_python_native_imports.py | none
- python PYTESTS/test_docs_python_native_module_names.py | none
- python PYTESTS/test_docs_python_native_protocol.py | none
- python PYTESTS/test_docs_python_native_public_api.py | none
- python PYTESTS/test_docs_python_native_route_model.py | none
- python PYTESTS/test_docs_python_native_route_sites.py | none
- python PYTESTS/test_docs_python_native_routes.py | none
- python PYTESTS/test_docs_python_native_safety.py | none
- python PYTESTS/test_docs_python_native_source.py | none
- python PYTESTS/test_docs_python_native_walk.py | none
- powershell TESTS/DocsAnalyzerPythonNative.Tests.ps1 | none
- DECISIONS_RETURNED=0
