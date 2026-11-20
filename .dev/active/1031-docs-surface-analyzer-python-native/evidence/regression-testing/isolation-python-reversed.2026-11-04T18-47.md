# [P6-T12] Python reversed file order

Timestamp: 2026-11-04T18-47
Command: sh SCRATCH/issue-1031-pytest.sh issue-1031-reversed.out -p no:randomly -p no:xdist -v <the fourteen PYTESTS modules in reversed file-name order> (poetry run pytest --strict-markers --strict-config, one process)
EXIT_CODE: 0
Output Summary: 208 passed, 0 failed. The -v output shows the modules executed in this order:
1. test_docs_python_native_source.py
2. test_docs_python_native_safety.py
3. test_docs_python_native_routes.py
4. test_docs_python_native_public_api.py
5. test_docs_python_native_protocol.py
6. test_docs_python_native_imports.py
7. test_docs_python_native_entry.py
8. test_docs_python_native_determinism.py
9. test_docs_python_native_corpus.py
10. test_docs_python_native_cli_typer.py
11. test_docs_python_native_cli_click.py
12. test_docs_python_native_cli_argparse.py
13. test_docs_python_native_cli.py
14. test_docs_python_native_architecture.py
