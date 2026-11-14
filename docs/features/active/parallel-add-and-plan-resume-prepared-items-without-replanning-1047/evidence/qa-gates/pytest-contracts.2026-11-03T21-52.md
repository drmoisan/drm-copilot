# Contract Test Set (remediation cycle 2)

Timestamp: 2026-11-03T21-52
Task: [P3-T6]
Command: poetry run pytest -p no:cacheprovider -q <the 27 modules of the `## Contract Test Set` of remediation-plan.2026-11-03T18-43.md under tests/scripts/dev_tools/> (serial; project addopts -ra --cov-report=lcov:artifacts/python/lcov.info --strict-markers --strict-config)
EXIT_CODE: 0
Output Summary: 419 passed, 0 failed, 0 errors in 5.81 s. The set includes the bundle-mirror contract tests (test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py) and the pack-manifest tests (test_push_down_claude_pack_manifest_completeness.py, test_push_down_codex_and_agents_pack_manifest_completeness.py, test_push_down_pack_manifest_dependency_closure.py), run after the [P1-T3] bundle copy.

Modules: the 27 files listed under `## Contract Test Set` in remediation-plan.2026-11-03T18-43.md (parallel surface 12, execution-environment mirror pins 12, documentation and tiers 3), passed in that order from SCRATCH/contract-set.txt.
