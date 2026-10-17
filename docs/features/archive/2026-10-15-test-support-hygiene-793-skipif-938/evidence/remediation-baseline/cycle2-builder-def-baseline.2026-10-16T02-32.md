# Cycle 2 builder definition baseline

Timestamp: 2026-10-16T02-32
Command: poetry run python -c "import ast, pathlib; names = ('build_valid_orchestrator_state', 'build_valid_policy_audit_text', 'build_complete_large_orchestrator_state'); hits = sorted((p.name, n.name) for p in pathlib.Path('tests/scripts/dev_tools').glob('test_validate_orchestration_artifacts*.py') for n in ast.parse(p.read_text(encoding='utf-8')).body if isinstance(n, ast.FunctionDef) and n.name in names); print(hits)"
EXIT_CODE: 0
Output Summary: [('test_validate_orchestration_artifacts.py', 'build_complete_large_orchestrator_state'), ('test_validate_orchestration_artifacts.py', 'build_valid_orchestrator_state'), ('test_validate_orchestration_artifacts.py', 'build_valid_policy_audit_text')]
