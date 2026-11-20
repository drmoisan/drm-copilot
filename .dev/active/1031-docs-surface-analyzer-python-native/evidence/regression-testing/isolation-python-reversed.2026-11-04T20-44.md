# [P6-T12] Fourteen new Python test modules, one process, reversed file order (fresh run on the post-merge head)

Timestamp: 2026-11-04T20-44
Command: sh SCRATCH/issue-1031-pyrev.sh, which runs poetry run python -m pytest --strict-markers --strict-config -p no:cacheprovider <the fourteen modules in reverse lexical order> (no -n, so one process; plugins cov and xdist only, no reordering plugin; the verbose progress lines confirm execution in the given order)
EXIT_CODE: 0
Output Summary: 208 passed, 0 failed in 0.87 s (Python 3.13.18).

Order (all under tests/scripts/claude-lib/docs/python/):
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
