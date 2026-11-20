# [P1-T3] PKG/imports.py

Timestamp: 2026-11-04T15-58
Command: poetry run python -m pytest --strict-markers --strict-config -q -p no:cacheprovider tests/scripts/claude-lib/docs/python/test_docs_python_native_imports.py
EXIT_CODE: 0
Output Summary: 45 passed, 0 failed, 0 errors. Cases: import m, import m as a, import m.sub, from m import n [as a], relative from-imports, imports inside top-level if and try (bound) and inside with (not bound); nested framework imports (PYTHON_IMPORT_NESTED_FRAMEWORK) and nested non-framework imports (silent); framework star import (PYTHON_IMPORT_STAR_FRAMEWORK); two targets (PYTHON_BINDING_AMBIGUOUS, name resolves to None); receivers for NAME = ctor(...) and NAME: T = ctor(...) at any depth, rebinding ambiguity; definitions; module_dotted_name for each root form, __init__.py, outside roots, non-.py and non-identifier segments; module_package; resolve_relative including a climb above the root.
