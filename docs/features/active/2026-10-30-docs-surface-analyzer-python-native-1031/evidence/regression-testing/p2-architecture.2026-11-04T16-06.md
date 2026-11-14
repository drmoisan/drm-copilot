# [P2-T7] PKG/architecture.py

Timestamp: 2026-11-04T16-06
Command: poetry run python -m pytest --strict-markers --strict-config -q -p no:cacheprovider tests/scripts/claude-lib/docs/python/test_docs_python_native_architecture.py
EXIT_CODE: 0
Output Summary: 3 passed, 0 failed, 0 errors. Cases: one architecture-component per package (__init__.py) and module with component_kind and null line bounds; internal Import and ImportFrom edges at any depth (TYPE_CHECKING block, function body), relative resolution, a star import, longest-prefix matching, self-edges excluded, ordinal import-NNNN properties and import_count; ARCHITECTURE_DYNAMIC_IMPORT (importlib.import_module, __import__, importlib.util.spec_from_file_location), ARCHITECTURE_RELATIVE_IMPORT_UNRESOLVED (climb above the root, module outside any package), ARCHITECTURE_MODULE_NAME_INVALID and ARCHITECTURE_EDGE_LIMIT (1001 edges: count kept, edge properties dropped).
