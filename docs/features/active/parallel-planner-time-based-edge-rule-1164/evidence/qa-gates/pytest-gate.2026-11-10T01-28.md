# Final pytest Gate (P6-T6)

Timestamp: 2026-11-10T01-28
Command: sh SCRATCH/issue-1164-pytest-gate.sh issue-1164-cov-final3.json (env -u VIRTUAL_ENV poetry run pytest tests/ -n auto -q --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1164-cov-final3.json -p no:cacheprovider --junitxml=SCRATCH/issue-1164-cov-final3.json.junit.xml --cov)
EXIT_CODE: 0
Output Summary:
- Run started 2026-11-10T01-23 (UTC); summary line "16658 passed, 6 skipped in 239.08s (0:03:59)"; 0 failed (Phase 0 baseline: 16590 passed, 6 skipped, 0 failed). The JSON report name carries the suffix final3 so the reports of the earlier runs stay in place.
- Repo-wide (JSON report totals): line 34525 / 35546 = 97.13% (baseline 97.11%); branch 12758 / 13514 = 94.41% (baseline 94.38%); terminal TOTAL row 96%.
- Per-file (JSON report), against the Phase 0 baseline:
  - scripts/dev_tools/_blast_radius_scheduling.py: line 100.00% (171/171), branch 100.00% (40/40); baseline 100.00% / 100.00%
  - scripts/dev_tools/_parallel_drift_scheduling.py: line 100.00% (47/47), branch 100.00% (18/18); baseline 100.00% / 100.00%
  - scripts/dev_tools/parallel_drift_detection.py: line 100.00% (80/80), branch 100.00% (26/26); baseline 100.00% / 100.00%
  - scripts/dev_tools/_parallel_state_records.py: line 100.00% (191/191), branch 100.00% (96/96); baseline 100.00% / 100.00%
  - scripts/dev_tools/parallel_manifest_contract.py: line 100.00% (168/168), branch 100.00% (82/82); baseline 100.00% / 100.00%
  - scripts/dev_tools/validate_parallel_planner_state.py: line 100.00% (117/117), branch 100.00% (46/46); baseline 100.00% / 100.00%
  - scripts/dev_tools/validate_parallel_orchestrator_state.py: line 97.78% (88/90), branch 94.12% (32/34); baseline 97.73% / 94.12%
  - Also: scripts/dev_tools/parallel_drift_detection_cli.py: line 100.00% (75/75), branch 100.00% (10/10); baseline 100.00% / 100.00%
- Named tests (SCRATCH/issue-1164-junit-names.py over SCRATCH/issue-1164-pytest-names.txt): NAMED_NOT_ALL_PASSED 0. This covers the 14 tests of test_blast_radius_access_weights.py, the updated config-tolerance and contract-weight tests, the scheduling fixture parametrization including both new stems, both new drift fixtures, the 21 cases of test_parallel_state_scheduling_parity.py, the updated test_out_of_enum_reason_is_still_rejected, the 11 M9 fixtures in both parity lanes (22 cases), test_rule_documents_the_contract_weight, the overlay corpus test, and the contract suites test_push_down_claude_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py, test_push_down_pack_manifest_dependency_closure.py, test_blast_radius_config_parity.py, test_claude_rules_frontmatter.py, test_parallel_planner_surface_contracts.py, test_parallel_orchestrator_surface_contracts.py, and test_parallel_issue_combination_contracts.py, all PASSED.
- History: the first final run failed on the branch (pytest-gate.2026-11-10T01-05.md). A second run after the fixes passed (16655 passed) but left _parallel_drift_scheduling.py at line 95.74% / branch 88.89% and _parallel_state_records.py at line 99.48% / branch 98.96%, below their baseline figures. Three item_access cases and a legacy precedence entry in the valid planner corpus case closed those gaps before this run.
