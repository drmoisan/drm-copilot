Timestamp: 2026-08-22T23-35
Command: `$env:COVERAGE_FILE='docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/remediation-baseline/.focused-coverage'; poetry run pytest -o "addopts=" tests/scripts/dev_tools/test_validate_orchestrator_state_codex_topology.py tests/scripts/dev_tools/test_validate_orchestrator_state_codex_model_routing.py tests/scripts/dev_tools/test_analyze_coverage_policy.py --cov=scripts.dev_tools._orchestrator_state_codex_topology --cov=scripts.dev_tools._orchestrator_state_codex_model_routing --cov=scripts.dev_tools.analyze_coverage_policy --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/remediation-baseline/focused-python-coverage.json`
EXIT_CODE: 0
Output Summary:
- PASS: 52 tests passed, 0 failed in 0.39 seconds.
- `scripts/dev_tools/_orchestrator_state_codex_topology.py`: line 125/126 = 99.206349%; branch 68/72 = 94.444444%.
- `scripts/dev_tools/_orchestrator_state_codex_model_routing.py`: line 86/95 = 90.526316%; branch 45/54 = 83.333333%.
- `scripts/dev_tools/analyze_coverage_policy.py`: line 104/173 = 60.115607%; branch 21/54 = 38.888889%.
- Focused coverage JSON was written to the canonical feature-local remediation baseline directory.
