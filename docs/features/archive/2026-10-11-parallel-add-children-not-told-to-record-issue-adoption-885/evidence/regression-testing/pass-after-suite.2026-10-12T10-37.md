Timestamp: 2026-10-12T10-37
Command: poetry run pytest tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v -p no:cacheprovider --no-cov
EXIT_CODE: 0
Output Summary: Result line: 57 passed in 0.32s (BaselineSuitePassCount 52 plus 5).
Required nodes listed PASSED:
PASSED tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py::test_parallel_add_requires_complexity_assessment
PASSED tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py::test_parallel_add_step_two_defers_model_to_parallel_orchestrate
PASSED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
All 16 nodes of test_parallel_issue_adoption_skill_contracts.py PASSED (see pass-after-adoption-contracts artifact); the remaining 41 nodes in the three other files PASSED. A filtered view of the -v output was used; every FAILED or ERROR line would have been shown and none was.
PostSuiteFailingNodes: none
