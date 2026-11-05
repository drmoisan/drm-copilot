Timestamp: 2026-11-05T03-06
Started: 2026-11-05T03:01:34.2641259Z
Command: poetry run pytest -q -n auto --cov --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-1082-baseline-python-parallel.json --junitxml=SCRATCH/issue-1082-baseline-python-parallel-junit.xml -o addopts=-ra --strict-markers --strict-config
EXIT_CODE: 0
Output Summary:

```text
scripts\dev_tools\push_down_claude_pack_selection.py                                         83      5     30      5    91%
scripts\dev_tools\push_down_claude_routing_merge.py                                          44      0     18      0   100%
scripts\dev_tools\push_down_codex_and_agents_customizations.py                              109      2     18      2    97%
scripts\dev_tools\push_down_codex_filesystem.py                                              46      3      8      1    93%
scripts\dev_tools\push_down_codex_pack_selection.py                                          99      1     42      2    98%
scripts\dev_tools\push_down_copilot_customizations.py                                       130      7     18      2    93%
scripts\dev_tools\push_down_copilot_customizations_filesystem.py                             29      0     18      0   100%
scripts\dev_tools\push_down_copilot_customizations_rewrites.py                               57      1     10      1    97%
scripts\dev_tools\push_down_exclusion_manifest.py                                           104      0     34      0   100%
scripts\dev_tools\quality_tiers_contract.py                                                 191      0     78      0   100%
scripts\dev_tools\resolve_codex_deployment.py                                                83      0     18      0   100%
scripts\dev_tools\resolve_codex_topology.py                                                 105      0     36      0   100%
scripts\dev_tools\resolve_delegation_model.py                                                19      0      4      0   100%
scripts\dev_tools\resolve_execute_plan_prompt.py                                            172      8     52      5    94%
scripts\dev_tools\resolve_file_prompt.py                                                    183     13     58     10    90%
scripts\dev_tools\resolve_hard_lock_prompt.py                                               126      3     34      1    98%
scripts\dev_tools\schema_loading.py                                                          35      0     14      0   100%
scripts\dev_tools\skill_bundle_contract.py                                                  141      5     60      3    96%
scripts\dev_tools\skill_bundle_contract_cli.py                                               58      4     22      5    89%
scripts\dev_tools\tk_dialog_helpers.py                                                       99     57     30      4    45%
scripts\dev_tools\validate_discovery_artifacts.py                                           103      0     32      0   100%
scripts\dev_tools\validate_discovery_profile.py                                              18      0      6      0   100%
scripts\dev_tools\validate_discovery_schema_artifacts.py                                     33      0      2      0   100%
scripts\dev_tools\validate_epic_orchestrator_state.py                                       128      2     62      2    98%
scripts\dev_tools\validate_epic_planner_state.py                                            191      0    100      1    99%
scripts\dev_tools\validate_evidence_locations.py                                             28      0     12      0   100%
scripts\dev_tools\validate_json.py                                                           98     20     38      2    74%
scripts\dev_tools\validate_orchestration_artifacts.py                                       149      3     56      4    97%
scripts\dev_tools\validate_orchestration_review_artifacts.py                                 20      0     10      1    97%
scripts\dev_tools\validate_orchestrator_state.py                                            170      2     82      2    98%
scripts\dev_tools\validate_orchestrator_state_cli.py                                         33      1      4      0    97%
scripts\dev_tools\validate_parallel_orchestrator_state.py                                    88      2     34      2    97%
scripts\dev_tools\validate_parallel_planner_state.py                                        115      0     46      0   100%
scripts\dev_tools\validate_policy_audit_artifact.py                                         125     12     74     11    88%
---------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                     33367   1097  12516    550    96%
Coverage JSON written to file SCRATCH/issue-1082-baseline-python-parallel.json
=========================== short test summary info ===========================
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_non_mapping_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_unterminated_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_yaml_parse_failure declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_empty_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_missing_opening_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_blast_radius_regression_452.py:483: Issue #722 tolerance layer absent at execution start (Phase 0 detection NOT FOUND); detection-level verdicts for every must-conflict case are recorded as evidence instead.
16087 passed, 6 skipped in 308.01s (0:05:08)
```

Raw output: SCRATCH/issue-1082-python-tests-host-parallel.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
