# Python Regression Baseline (P0-T16)

Timestamp: 2026-09-29T17-39
Command: poetry run pytest tests/scripts/dev_tools -q ; poetry run pytest -v <the 19 files of Appendix C3, all under tests/scripts/dev_tools/>
EXIT_CODE: 0
Output Summary:
- Full run summary line: `5252 passed, 6 skipped in 20.62s` (exit 0)
- Baseline failure set (FAILED lines of the full run): none (empty set)
- Named set (C3) summary line: `255 passed in 1.30s` (exit 0); 255 PASSED lines, no FAILED line
- KL-510: PASSED (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts PASSED`)

## Named set (C3) as run

test_skill_bundle_contract.py, test_skill_bundle_contract_evaluation.py, test_skill_bundle_contract_cli.py,
test_skill_bundle_contract_repo.py, test_parallel_abandon_token_seam.py,
test_parallel_drift_detection_cli.py, test_parallel_drift_detection_cli_halt.py,
test_parallel_drift_resolution.py, test_parallel_drift_detection_conflicts.py,
test_parallel_drift_timestamps.py, test_parallel_drift_scheduling.py,
test_parallel_mutation_abandon_cli.py, test_parallel_mutation_protocol.py,
test_parallel_orchestrator_surface_contracts.py, test_push_down_claude_resource_contracts.py,
test_push_down_claude_pack_manifest_completeness.py, test_poshqc_bundled_parity.py,
test_claude_rules_frontmatter.py, test_push_down_codex_and_agents_customizations.py

## Execution note

A first background invocation carried an extra `-p no:cacheprovider` flag that the plan does not
state. It could not be cancelled, so it completed (`5252 passed, 6 skipped in 21.06s`, exit 0) and
the exact plan command was then run separately. The result recorded above is the exact command.
