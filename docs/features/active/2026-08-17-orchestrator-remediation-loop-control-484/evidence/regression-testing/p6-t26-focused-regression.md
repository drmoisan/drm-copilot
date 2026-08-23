Timestamp: 2026-08-22T23-50
Command: `$env:COVERAGE_FILE='docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/regression-testing/.coverage'; poetry run pytest -o "addopts=" tests/scripts/dev_tools/test_validate_orchestrator_state_codex_topology.py tests/scripts/dev_tools/test_validate_orchestrator_state_codex_model_routing.py tests/scripts/dev_tools/test_analyze_coverage_policy.py --cov=scripts.dev_tools._orchestrator_state_codex_topology --cov=scripts.dev_tools._orchestrator_state_codex_model_routing --cov=scripts.dev_tools.analyze_coverage_policy --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/regression-testing/p6-t26-focused-coverage.json`
EXIT_CODE: 0
Output Summary:
- PASS: 54 focused tests passed, 0 failed in 0.46 seconds.
- Topology module baseline line/branch: 99.206349% / 94.444444%; post line/branch: 130/131 = 99.236641% / 70/74 = 94.594595%; no regression.
- Model-routing module baseline line/branch: 90.526316% / 83.333333%; post line/branch: 94/100 = 94.000000% / 47/56 = 83.928571%; no regression.
- Coverage-analyzer baseline line/branch: 60.115607% / 38.888889%; post line/branch: 104/173 = 60.115607% / 21/54 = 38.888889%; unchanged.
- Topology cache changed executable lines: 10/10 covered = 100.000000%.
- Model-routing cache changed executable lines: 11/11 covered = 100.000000%.
- Analyzer compaction changed executable lines: 0/0; only blank lines were removed, so changed executable-line coverage is 100.000000% by the analyzer convention.
- Aggregate changed executable-line coverage: 21/21 = 100.000000%, above the 90% requirement.
- Every changed executable line is covered, and no affected module regressed from P0-T10.
