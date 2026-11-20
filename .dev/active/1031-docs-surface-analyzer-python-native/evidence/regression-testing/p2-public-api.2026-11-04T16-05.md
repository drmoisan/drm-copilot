# [P2-T6] PKG/public_api.py

Timestamp: 2026-11-04T16-05
Command: poetry run python -m pytest --strict-markers --strict-config -q -p no:cacheprovider tests/scripts/claude-lib/docs/python/test_docs_python_native_public_api.py
EXIT_CODE: 0
Output Summary: 7 passed, 0 failed, 0 errors. Cases: literal __all__ by assignment, annotated assignment, +=, extend and append (duplicates dropped, replace semantics, empty list); fourteen dynamic forms falling back to the naming rule; statements that do not start with __all__; the naming rule over top-level def, async def, class and assignment targets inside top-level if and try bodies, symbol_kind and basis, chained and annotated targets, attribute targets; the six codes PUBLIC_API_STAR_IMPORT, PUBLIC_API_NAME_UNRESOLVED, PUBLIC_API_CONDITIONAL_DEFINITION, PUBLIC_API_UNPACKING_TARGET, PUBLIC_API_DYNAMIC_ALL and PUBLIC_API_MODULE_NOT_IMPORTABLE with their effects; private segments, paths outside roots and __init__.py.
