Timestamp: 2026-10-17T17:33:29.070315+00:00
Command: poetry run pytest --cov=src --cov=scripts/dev_tools --cov=scripts.dev_tools.resolve_codex_deployment --cov=scripts.dev_tools.generate_codex_agent_variants --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-977-baseline-python.json
EXIT_CODE: 0
Output Summary:

TOTAL: lines 16798/17849 (94.1117%); branches 5723/6446 (88.7837%).
scripts\dev_tools\generate_codex_agent_variants.py: lines 121/128 (94.5312%); branches 41/46 (89.1304%).
scripts\dev_tools\resolve_codex_deployment.py: lines 83/83 (100.0000%); branches 18/18 (100.0000%).
scripts\dev_tools\skill_bundle_contract_cli.py                           58      4     22      5    89%   62, 99, 130, 132, 141->143
scripts\dev_tools\tk_dialog_helpers.py                                   99     57     30      4    45%   39-40, 64-67, 85-117, 133-159, 170-171, 184, 191, 236, 238, 245-260
scripts\dev_tools\validate_discovery_artifacts.py                        61      1     16      0    99%   82
scripts\dev_tools\validate_discovery_profile.py                          25      0     10      0   100%
scripts\dev_tools\validate_discovery_schema_artifacts.py                 44      0      4      0   100%
scripts\dev_tools\validate_epic_orchestrator_state.py                   128      2     62      2    98%   278, 283
scripts\dev_tools\validate_epic_planner_state.py                        191      0    100      1    99%   174->178
scripts\dev_tools\validate_evidence_locations.py                         28      0     12      0   100%
scripts\dev_tools\validate_json.py                                       98     20     38      2    74%   21, 104-126, 174-176
scripts\dev_tools\validate_orchestration_artifacts.py                   149      3     56      4    97%   409, 411, 413, 436->440
scripts\dev_tools\validate_orchestration_review_artifacts.py             20      0     10      1    97%   78->80
scripts\dev_tools\validate_orchestrator_state.py                        170      2     82      2    98%   116, 130
scripts\dev_tools\validate_orchestrator_state_cli.py                     33      1      4      0    97%   118
scripts\dev_tools\validate_parallel_orchestrator_state.py                88      2     34      2    97%   231, 270
scripts\dev_tools\validate_parallel_planner_state.py                    115      0     46      0   100%
scripts\dev_tools\validate_policy_audit_artifact.py                     125     12     74     11    88%   156, 340, 372, 376, 382, 386-389, 392, 398, 414, 420, 430
-----------------------------------------------------------------------------------------------------------------
TOTAL                                                                 17849   1051   6446    473    93%
Coverage JSON written to file SCRATCH/issue-977-baseline-python.json
Coverage LCOV written to file artifacts/python/lcov.info
=========================== short test summary info ===========================
SKIPPED [1] tests\scripts\dev_tools\test_blast_radius_regression_452.py:483: Issue #722 tolerance layer absent at execution start (Phase 0 detection NOT FOUND); detection-level verdicts for every must-conflict case are recorded as evidence instead.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_empty_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_missing_opening_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_non_mapping_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_unterminated_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_yaml_parse_failure declares no accessor expectation.
================= 7335 passed, 6 skipped in 75.27s (0:01:15) ==================

Full sanitized output: SCRATCH/issue-977-baseline-python-test.log
