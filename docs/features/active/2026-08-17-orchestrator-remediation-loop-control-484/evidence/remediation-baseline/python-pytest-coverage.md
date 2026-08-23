Timestamp: 2026-08-22T23-34
Command: `$env:COVERAGE_FILE='docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/remediation-baseline/.coverage'; poetry run pytest -o "addopts=" --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/remediation-baseline/python-coverage.json`
EXIT_CODE: 1
Output Summary:
- LIVE BASELINE ONLY, NOT CLEAN: 4,437 passed, 30 failed, and 5 skipped in 23.30 seconds.
- Repository line coverage: 15,908/17,345 = 91.715192%.
- Repository branch coverage: 5,429/6,490 = 83.651772%.
- `scripts/dev_tools/_orchestrator_state_codex_topology.py`: line 126/126 = 100.000000%; branch 69/72 = 95.833333%.
- `scripts/dev_tools/_orchestrator_state_codex_model_routing.py`: line 87/95 = 91.578947%; branch 46/54 = 85.185185%.
- `scripts/dev_tools/analyze_coverage_policy.py`: line 104/173 = 60.115607%; branch 21/54 = 38.888889%.
- Coverage JSON was written to the canonical feature-local remediation baseline directory. No pre-rebase count or coverage value was substituted.
