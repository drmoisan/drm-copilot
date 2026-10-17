# Cycle 2 moved builders AST-identical to HEAD

Timestamp: 2026-10-16T02-36
Command: poetry run python -c "import ast, pathlib, subprocess; names = ('build_valid_orchestrator_state', 'build_valid_policy_audit_text', 'build_complete_large_orchestrator_state'); old = ast.parse(subprocess.run(['git', 'show', 'HEAD:tests/scripts/dev_tools/test_validate_orchestration_artifacts.py'], capture_output=True, encoding='utf-8', check=True).stdout); new = ast.parse(pathlib.Path('tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py').read_text(encoding='utf-8')); pick = lambda tree: {n.name: ast.dump(n) for n in tree.body if isinstance(n, ast.FunctionDef) and n.name in names}; a = pick(old); b = pick(new); print(sorted(a) == sorted(names), a == b)"
EXIT_CODE: 0
Output Summary: True True
