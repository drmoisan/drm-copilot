# importer-ast-negative

Timestamp: 2026-10-16T00-41
Command: poetry run python -c "import ast, pathlib; sup = 'tests.scripts.dev_tools.validate_orchestration_artifacts_test_support'; names = ('build_valid_epic_state', 'build_read_text_stub'); hits = [p.name for p in sorted(pathlib.Path('tests').rglob('test_*.py')) for n in ast.walk(ast.parse(p.read_text(encoding='utf-8'))) if isinstance(n, ast.ImportFrom) and n.module != sup and any(a.name in names for a in n.names)]; print(len(hits), hits)"
EXIT_CODE: 0
Output Summary:
```
0 []
```
