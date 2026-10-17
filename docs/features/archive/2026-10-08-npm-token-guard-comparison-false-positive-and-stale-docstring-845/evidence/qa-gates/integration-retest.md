# Integration Retest

Timestamp: 2026-10-09T20-57
Command: poetry run pytest "tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[npm-token-assignment]" "tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_collect_offenders_names_each_matching_line" -v -- executed as two commands (see Plan Deviations): (1) poetry run pytest "tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_collect_offenders_names_each_matching_line" -v ; (2) poetry run pytest -k "test_github_yaml_files_contain_no_npm_token_route and npm-token-assignment" tests/scripts/dev_tools/test_workflow_npm_token_guard.py -v
EXIT_CODE: 0
Output Summary: 2 passed in total (1 passed + 1 passed, 55 deselected). Both node IDs listed PASSED. The same two nodes are also listed PASSED in evidence/qa-gates/ac-node-listing.md (full module run, 56 passed).

Node lines, verbatim:

```text
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_collect_offenders_names_each_matching_line PASSED [100%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[npm-token-assignment] PASSED [100%]
```

Result lines:

```text
============================== 1 passed in 0.08s ==============================
====================== 1 passed, 55 deselected in 0.11s =======================
```
