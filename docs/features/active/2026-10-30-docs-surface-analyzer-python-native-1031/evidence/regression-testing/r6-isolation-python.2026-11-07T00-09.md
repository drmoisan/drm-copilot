# [P6-T13] Python isolation

Timestamp: 2026-11-07T00-09
Command: poetry run python -m pytest <every test module in PYTESTS in reversed file order> -q -p no:cacheprovider --no-cov (one process); poetry run python -m pytest -n auto tests/scripts/claude-lib/docs/python
EXIT_CODE: 0
Output Summary: reversed run: 251 passed, 0 failed. -n auto run: 251 passed, 0 failed.

## Reversed file order

- test_docs_python_native_walk.py
- test_docs_python_native_source.py
- test_docs_python_native_safety.py
- test_docs_python_native_routes.py
- test_docs_python_native_route_sites.py
- test_docs_python_native_route_model.py
- test_docs_python_native_public_api.py
- test_docs_python_native_protocol.py
- test_docs_python_native_module_names.py
- test_docs_python_native_imports.py
- test_docs_python_native_facts.py
- test_docs_python_native_entry.py
- test_docs_python_native_determinism.py
- test_docs_python_native_corpus.py
- test_docs_python_native_cli_typer.py
- test_docs_python_native_cli_click.py
- test_docs_python_native_cli_argparse.py
- test_docs_python_native_cli.py
- test_docs_python_native_call_sites.py
- test_docs_python_native_architecture.py
