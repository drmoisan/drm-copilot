# P6-T26 Expanded Full Coverage Analysis

Timestamp: 2026-08-23T03:40:21-04:00

Command: `poetry run python -m scripts.dev_tools.analyze_coverage_policy --mode final --language python --coverage-json docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/regression-testing/p6-t26-expanded-full-coverage.json --baseline-python-analysis docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/remediation-baseline/python-coverage-analysis.json --base-ref HEAD --working-tree --coverage-config pyproject.toml --repo-line-min 85 --repo-branch-min 75 --new-symbol-min 90 --require-configured-changed-files --require-no-changed-line-regression --output docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/regression-testing/p6-t26-expanded-full-coverage-analysis.json`

EXIT_CODE: 0

Output Summary: The analyzer returned `overall_verdict: PASS`. Repository line coverage was 91.780273% and branch coverage was 83.735861%. Repository line, repository branch, configured-changed-file, no-changed-line-regression, and new-symbol verdicts all passed. Changed executable coverage was 1/1 (100%) for `validate_orchestrator_state.py`, 8/8 (100%) for `_orchestrator_state_complexity.py`, 28/28 (100%) for `_orchestrator_state_codex_topology.py`, and 39/39 (100%) for `_orchestrator_state_codex_model_routing.py`, with no regression. Every new production symbol passed the 90% threshold; the minimum production new-symbol result was `_declared_surface` at 94.117647%, while `_validate_one_assessment` was 100%. No threshold, assertion, input, receipt, or suppression was changed or weakened.
